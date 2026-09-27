#!/usr/bin/env python3
"""Review the Ukrainian translation with the OpenAI API (ChatGPT).

For every tools/ttfp/out/<key>/part<N>.typ that has its original
src-part<N>.txt next to it, the translation is cut into chunks of about
--chunk-words words at paragraph/heading boundaries. Each chunk is sent
together with the matching slice of the original and GLOSSARY.md; the model
answers with a structured list of defects (exact quote, replacement,
severity, category), following the rules in GPT_REVIEW_PROMPT.md.

Every quote is located in the part file, so the report points at a line;
quotes the model made up (not found verbatim) are marked as such.

    export OPENAI_API_KEY=sk-...
    python3 tools/ttfp/gpt_review.py ch02                # one chapter
    python3 tools/ttfp/gpt_review.py ch02:1              # one part
    python3 tools/ttfp/gpt_review.py                     # whole book
    python3 tools/ttfp/gpt_review.py ch02 --dry-run      # chunks + token estimate, no API
    python3 tools/ttfp/gpt_review.py ch02 --min-severity major
    python3 tools/ttfp/gpt_review.py ch02 --apply        # review, then fix the files
    python3 tools/ttfp/gpt_review.py ch02 --apply -i     # confirm each fix (y/n/q)

--apply replaces each quote in out/<key>/part<N>.typ with the suggestion, but
only when the quote matches exactly once, and it keeps a fix only if the part
still compiles with typst. The report records what happened to every issue.
Review with `git diff tools/ttfp/out`, then `make assemble` to carry the
fixes into src/. Rerunning afterwards re-reviews only the changed chunks.

Answers are cached per chunk in tools/ttfp/gpt-review/cache/ (keyed by model,
prompt and text), so an interrupted run resumes where it stopped and an
unchanged chunk is never paid for twice; --force ignores the cache.
Reports: tools/ttfp/gpt-review/<key>.md (+ .json).

Batch mode (OpenAI Batch API: ~50% cheaper, results within 24 h):

    python3 tools/ttfp/gpt_review.py --batch submit        # upload uncached chunks
    python3 tools/ttfp/gpt_review.py --batch status        # progress; downloads finished
                                                           #   results into the cache
    python3 tools/ttfp/gpt_review.py --batch wait          # poll until all are done
    python3 tools/ttfp/gpt_review.py --batch cancel        # cancel pending batches
    python3 tools/ttfp/gpt_review.py --apply               # then report/fix from the cache

Pending batches are recorded in tools/ttfp/gpt-review/batches.json; chunks
already in a pending batch are neither resubmitted nor sent synchronously.

tools/ttfp/gpt-review/ is git-ignored: the reports quote the copyrighted
original, same boundary as tools/ttfp/review/ and tools/ttfp/raw/.
"""
import argparse
import concurrent.futures as cf
import glob
import hashlib
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TT = os.path.join(ROOT, "tools", "ttfp")
OUT = os.path.join(TT, "out")
DEST = os.path.join(TT, "gpt-review")
CACHE = os.path.join(DEST, "cache")
PROMPT_PATH = os.path.join(TT, "GPT_REVIEW_PROMPT.md")
GLOSSARY_PATH = os.path.join(ROOT, "GLOSSARY.md")

API_URL = os.environ.get("OPENAI_BASE_URL", "https://api.openai.com/v1").rstrip("/") + "/chat/completions"
DEFAULT_MODEL = os.environ.get("OPENAI_MODEL", "gpt-5")

SEVERITIES = ["critical", "major", "minor"]
CATEGORIES = ["meaning", "omission", "math", "terminology", "grammar",
              "russianism", "calque", "style", "punctuation", "typst"]
ICON = {"critical": "🔴", "major": "🟠", "minor": "🟡"}

SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["summary", "score", "issues"],
    "properties": {
        "summary": {"type": "string"},
        "score": {"type": "integer"},
        "issues": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["severity", "category", "quote", "suggestion",
                             "original", "explanation", "confidence"],
                "properties": {
                    "severity": {"type": "string", "enum": SEVERITIES},
                    "category": {"type": "string", "enum": CATEGORIES},
                    "quote": {"type": "string"},
                    "suggestion": {"type": "string"},
                    "original": {"type": "string"},
                    "explanation": {"type": "string"},
                    "confidence": {"type": "number"},
                },
            },
        },
    },
}


# ---------------------------------------------------------------------------
# input: parts and chunks
# ---------------------------------------------------------------------------
def find_parts(selectors):
    """[(key, n, typ_path, src_path)] for the selected keys ('ch02' or 'ch02:1')."""
    wanted = {}
    for s in selectors:
        key, _, n = s.partition(":")
        wanted.setdefault(key, set())
        if n:
            wanted[key].add(int(n))
    parts = []
    for typ in sorted(glob.glob(os.path.join(OUT, "*", "part*.typ"))):
        key = os.path.basename(os.path.dirname(typ))
        n = int(re.search(r"part(\d+)\.typ$", typ).group(1))
        if wanted and (key not in wanted or (wanted[key] and n not in wanted[key])):
            continue
        src = os.path.join(os.path.dirname(typ), f"src-part{n}.txt")
        if os.path.exists(src):
            parts.append((key, n, typ, src))
        else:
            print(f"skip {key}/part{n}: no src-part{n}.txt (run make extract && make jobs)",
                  file=sys.stderr)
    return parts


def chunk_lines(lines, max_words):
    """Split into (start_line_index, text) chunks, cutting only before a
    heading or after a blank line, once a chunk has max_words words."""
    chunks, start, words = [], 0, 0
    for i, line in enumerate(lines):
        at_boundary = line.startswith("= ") or line.startswith("== ") or (
            i > 0 and not lines[i - 1].strip())
        if words >= max_words and at_boundary and i > start:
            chunks.append((start, "".join(lines[start:i])))
            start, words = i, 0
        words += len(line.split())
    if start < len(lines):
        chunks.append((start, "".join(lines[start:])))
    return [c for c in chunks if c[1].strip()]


def source_slice(src, typ_len, a, b, margin=0.35):
    """The part of the original that corresponds to translation chars [a, b),
    by proportional position, widened by `margin` of the chunk on each side."""
    pad = (b - a) * margin
    lo = max(0, int((a - pad) / typ_len * len(src)))
    hi = min(len(src), int((b + pad) / typ_len * len(src)))
    # snap to line boundaries so the slice does not start mid-word
    lo = src.rfind("\n", 0, lo) + 1
    nl = src.find("\n", hi)
    hi = len(src) if nl < 0 else nl
    return src[lo:hi]


# ---------------------------------------------------------------------------
# API
# ---------------------------------------------------------------------------
API_BASE = API_URL.rsplit("/chat/completions", 1)[0]
BATCHES = os.path.join(DEST, "batches.json")


def request_body(model, effort, system, user):
    body = {
        "model": model,
        "messages": [{"role": "system", "content": system},
                     {"role": "user", "content": user}],
        "response_format": {"type": "json_schema", "json_schema": {
            "name": "translation_review", "strict": True, "schema": SCHEMA}},
    }
    if effort:
        body["reasoning_effort"] = effort
    return body


def parse_completion(resp):
    """(review dict, usage) from a chat completion response body."""
    choice = resp["choices"][0]
    msg = choice["message"]
    if msg.get("refusal"):
        raise RuntimeError(f"model refused: {msg['refusal']}")
    if choice.get("finish_reason") == "length":
        raise RuntimeError("answer cut off (finish_reason=length)")
    return json.loads(msg["content"]), resp.get("usage", {})


def http(method, path, data=None, content_type="application/json", raw=False,
         timeout=600, retries=6):
    """Call the OpenAI API with retries on 429/5xx; JSON in, JSON (or bytes) out."""
    url = path if path.startswith("http") else API_BASE + path
    headers = {"Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}"}
    if data is not None:
        headers["Content-Type"] = content_type
        if not isinstance(data, bytes):
            data = json.dumps(data).encode()
    for attempt in range(retries):
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                body = r.read()
            return body if raw else json.loads(body)
        except urllib.error.HTTPError as e:
            detail = e.read().decode(errors="replace")[:500]
            if e.code in (429, 500, 502, 503, 504) and attempt < retries - 1:
                wait = min(60, 2 ** attempt * 3)
                print(f"  HTTP {e.code}, retry in {wait}s", file=sys.stderr)
                time.sleep(wait)
                continue
            raise RuntimeError(f"HTTP {e.code}: {detail}") from None
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < retries - 1:
                time.sleep(min(60, 2 ** attempt * 3))
                continue
            raise RuntimeError(f"network error: {e}") from None


def call_openai(model, effort, system, user):
    return parse_completion(http("POST", "/chat/completions",
                                 request_body(model, effort, system, user)))


# ---------------------------------------------------------------------------
# Batch API
# ---------------------------------------------------------------------------
def load_batches():
    try:
        return json.load(open(BATCHES, encoding="utf-8"))
    except FileNotFoundError:
        return []


def save_batches(batches):
    with open(BATCHES, "w", encoding="utf-8") as f:
        json.dump(batches, f, ensure_ascii=False, indent=2)


def pending_ids():
    return {cid for b in load_batches() if not b.get("collected") for cid in b["custom_ids"]}


def upload_jsonl(lines):
    boundary = "----ttfp" + hashlib.sha256(os.urandom(16)).hexdigest()[:16]
    payload = "\n".join(lines).encode() + b"\n"
    data = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"purpose\"\r\n\r\n"
            f"batch\r\n--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; "
            f"filename=\"ttfp-review.jsonl\"\r\nContent-Type: application/jsonl\r\n\r\n"
            ).encode() + payload + f"\r\n--{boundary}--\r\n".encode()
    return http("POST", "/files", data, f"multipart/form-data; boundary={boundary}")["id"]


def batch_submit(todo, model, effort, system, max_bytes=150 * 2 ** 20):
    """Upload todo chunks as one or more batches (API limit: 200 MB / 50k lines)."""
    groups, cur, size = [], [], 0
    for t in todo:
        cid = os.path.basename(t[6])[:-5]
        line = json.dumps({"custom_id": cid, "method": "POST", "url": "/v1/chat/completions",
                           "body": request_body(model, effort, system, t[5])},
                          ensure_ascii=False)
        if cur and (size + len(line.encode()) > max_bytes or len(cur) >= 50000):
            groups.append(cur)
            cur, size = [], 0
        cur.append((cid, line))
        size += len(line.encode())
    if cur:
        groups.append(cur)
    batches = load_batches()
    for g in groups:
        file_id = upload_jsonl([line for _, line in g])
        b = http("POST", "/batches", {"input_file_id": file_id,
                                      "endpoint": "/v1/chat/completions",
                                      "completion_window": "24h",
                                      "metadata": {"project": "ttfp-review"}})
        batches.append({"id": b["id"], "model": model, "created": time.strftime("%Y-%m-%d %H:%M"),
                        "custom_ids": [cid for cid, _ in g], "collected": False})
        save_batches(batches)
        print(f"submitted batch {b['id']}: {len(g)} request(s)")


def batch_collect():
    """Check pending batches, move finished answers into the cache.
    Returns the number of batches still running."""
    batches = load_batches()
    running = 0
    usage_total = {"prompt_tokens": 0, "completion_tokens": 0}
    for b in batches:
        if b.get("collected"):
            continue
        info = http("GET", f"/batches/{b['id']}")
        st, rc = info["status"], info.get("request_counts") or {}
        print(f"{b['id']} ({b['created']}): {st}, "
              f"{rc.get('completed', 0)}/{rc.get('total', len(b['custom_ids']))} done, "
              f"{rc.get('failed', 0)} failed")
        if st not in ("completed", "expired", "cancelled", "failed"):
            running += 1
            continue
        got = 0
        if info.get("output_file_id"):
            out = http("GET", f"/files/{info['output_file_id']}/content", raw=True)
            for line in out.decode().splitlines():
                if not line.strip():
                    continue
                rec = json.loads(line)
                resp = rec.get("response") or {}
                try:
                    if resp.get("status_code") != 200:
                        raise RuntimeError(f"HTTP {resp.get('status_code')}: "
                                           f"{json.dumps(resp.get('body'))[:300]}")
                    result, usage = parse_completion(resp["body"])
                except Exception as e:
                    print(f"  {rec['custom_id']}: {e}", file=sys.stderr)
                    continue
                with open(os.path.join(CACHE, rec["custom_id"] + ".json"), "w",
                          encoding="utf-8") as f:
                    json.dump(result, f, ensure_ascii=False, indent=2)
                for k in usage_total:
                    usage_total[k] += usage.get(k, 0)
                got += 1
        if info.get("error_file_id"):
            err = http("GET", f"/files/{info['error_file_id']}/content", raw=True)
            for line in err.decode().splitlines()[:5]:
                print(f"  error: {line[:300]}", file=sys.stderr)
        for e in ((info.get("errors") or {}).get("data") or [])[:5]:
            print(f"  error: {e.get('message')}", file=sys.stderr)
        b["collected"] = True
        b["status"] = st
        save_batches(batches)
        print(f"  collected {got} answer(s)"
              + ("" if got == len(b["custom_ids"]) else "; rerun --batch submit for the rest"))
    if usage_total["prompt_tokens"]:
        print(f"tokens: {usage_total['prompt_tokens']} in, {usage_total['completion_tokens']} out "
              "(billed at batch rates)")
    return running


def batch_cancel():
    for b in load_batches():
        if not b.get("collected"):
            info = http("POST", f"/batches/{b['id']}/cancel", {})
            print(f"{b['id']}: {info['status']}")


def build_user_message(glossary, original, translation, where):
    return (f"Фрагмент: {where}\n\n"
            f"<glossary>\n{glossary}\n</glossary>\n\n"
            f"<original>\n{original}\n</original>\n\n"
            f"<translation>\n{translation}\n</translation>\n\n"
            "Перевір <translation> за правилами й поверни JSON за схемою.")


# ---------------------------------------------------------------------------
# locating quotes
# ---------------------------------------------------------------------------
def quote_pattern(quote):
    """Whitespace-insensitive regex for `quote`, or None if it is empty."""
    q = quote.strip().strip("…").strip()
    if not q:
        return None
    return re.compile(r"\s+".join(re.escape(w) for w in q.split()))


def locate(quote, text, base_line):
    """1-based line of `quote` in the chunk (whitespace-insensitive), or None."""
    pat = quote_pattern(quote)
    m = pat and pat.search(text)
    if not m:
        return None
    return base_line + text.count("\n", 0, m.start()) + 1


# ---------------------------------------------------------------------------
# applying fixes
# ---------------------------------------------------------------------------
def typst_ok(path):
    """(ok, first error line) for compiling one part file."""
    out = os.path.join(CACHE, "_check.pdf")
    r = subprocess.run(["typst", "compile", "--root", ROOT, path, out],
                       capture_output=True, text=True)
    err = next((l for l in r.stderr.splitlines() if l.startswith("error")), r.stderr.strip()[:200])
    return r.returncode == 0, err


def plan_edits(text, issues):
    """Turn issues into non-overlapping (start, end, suggestion, issue) edits
    against the current `text`. Sets it['status'] on every issue: a quote must
    match exactly once inside its chunk's span (or once in the whole file)."""
    edits = []
    for it in issues:
        pat = quote_pattern(it["quote"])
        if not pat or it["suggestion"].strip() == it["quote"].strip():
            it["status"] = "пропущено: заміна порожня або ідентична"
            continue
        lo, hi = it["_span"]
        inside = [m for m in pat.finditer(text) if lo <= m.start() < hi]
        found = inside if inside else list(pat.finditer(text))
        if len(found) != 1:
            it["status"] = ("пропущено: цитату не знайдено (текст змінився?)" if not found
                            else f"пропущено: цитата неоднозначна ({len(found)} збіги)")
            continue
        m = found[0]
        if any(m.start() < e and s < m.end() for s, e, *_ in edits):
            it["status"] = "пропущено: перетинається з іншою правкою"
            continue
        edits.append((m.start(), m.end(), it["suggestion"].strip(), it))
    return edits


def splice(text, edits):
    for s, e, new, _ in sorted(edits, key=lambda x: x[0], reverse=True):
        text = text[:s] + new + text[e:]
    return text


def confirm(path, text, edit):
    s, e, new, it = edit
    line = text.count("\n", 0, s) + 1
    print(f"\n{ICON[it['severity']]} {it['category']}  {os.path.relpath(path, ROOT)}:{line}")
    print(f"  - {md_quote(text[s:e])}")
    print(f"  + {md_quote(new)}")
    print(f"  {it['explanation'].strip()}")
    while True:
        ans = input("  застосувати? [y]es / [n]o / [q]uit: ").strip().lower()
        if ans in ("y", "n", "q"):
            return ans


def apply_fixes(path, issues, interactive):
    """Apply issues to the part file; keep only edits that still compile."""
    text = open(path, encoding="utf-8").read()
    edits = plan_edits(text, issues)
    if interactive:
        chosen = []
        for ed in sorted(edits, key=lambda x: x[0]):
            ans = confirm(path, text, ed)
            if ans == "q":
                for rest in edits:
                    rest[3].setdefault("status", "пропущено вручну")
                break
            if ans == "y":
                chosen.append(ed)
            else:
                ed[3]["status"] = "відхилено вручну"
        edits = chosen
    if not edits:
        return 0

    base_ok, _ = typst_ok(path)
    new_text = splice(text, edits)
    open(path, "w", encoding="utf-8").write(new_text)
    if not base_ok or typst_ok(path)[0]:
        # file did not compile before either: nothing to protect, keep all
        for ed in edits:
            ed[3]["status"] = "застосовано"
        return len(edits)

    # something broke the build: redo one edit at a time, keep those that compile
    kept = []
    for ed in sorted(edits, key=lambda x: x[0]):
        open(path, "w", encoding="utf-8").write(splice(text, kept + [ed]))
        ok, err = typst_ok(path)
        if ok:
            kept.append(ed)
            ed[3]["status"] = "застосовано"
        else:
            ed[3]["status"] = f"відкочено: ламає компіляцію ({err})"
    open(path, "w", encoding="utf-8").write(splice(text, kept))
    return len(kept)


# ---------------------------------------------------------------------------
# report
# ---------------------------------------------------------------------------
def md_quote(s):
    return s.replace("\n", " ").strip()


def write_report(key, results, min_sev):
    keep = set(SEVERITIES[: SEVERITIES.index(min_sev) + 1])
    lines = [f"# Рецензія перекладу — {key}", ""]
    all_issues = []
    for (n, ci), r in sorted(results.items()):
        for it in r["issues"]:
            if it["severity"] in keep:
                all_issues.append((n, it))
    counts = {s: sum(1 for _, it in all_issues if it["severity"] == s) for s in SEVERITIES}
    scores = [r["score"] for r in results.values()]
    lines.append(" · ".join(f"{ICON[s]} {s}: {counts[s]}" for s in SEVERITIES if s in keep)
                 + (f" · середня оцінка: {sum(scores) / len(scores):.1f}/10" if scores else ""))
    lines.append("")
    for n in sorted({n for n, _ in results}):
        lines += [f"## part{n}.typ", ""]
        for (pn, ci), r in sorted(results.items()):
            if pn == n:
                lines.append(f"> **Фрагмент {ci + 1}** ({r['score']}/10): {r['summary']}")
                lines.append("")
        issues = sorted((it for pn, it in all_issues if pn == n),
                        key=lambda it: (it["line"] or 10 ** 9, SEVERITIES.index(it["severity"])))
        for it in issues:
            status = f" — **{it['status']}**" if it.get("status") else ""
            loc = f"out/{key}/part{n}.typ:{it['line']}" if it["line"] else "⚠ цитату не знайдено"
            lines.append(f"### {ICON[it['severity']]} {it['category']} — `{loc}`"
                         f" (впевненість {it['confidence']:.1f}){status}")
            lines.append("")
            lines.append(f"- **Було:** {md_quote(it['quote'])}")
            lines.append(f"- **Стало:** {md_quote(it['suggestion'])}")
            if it["original"].strip():
                lines.append(f"- **Оригінал:** {md_quote(it['original'])}")
            lines.append(f"- {it['explanation'].strip()}")
            lines.append("")
    with open(os.path.join(DEST, f"{key}.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    with open(os.path.join(DEST, f"{key}.json"), "w", encoding="utf-8") as f:
        json.dump([{"part": n, "chunk": ci, **r} for (n, ci), r in sorted(results.items())],
                  f, ensure_ascii=False, indent=2)
    return counts


# ---------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("keys", nargs="*", help="ch02, ch02:1, appA ... (default: all)")
    ap.add_argument("--model", default=DEFAULT_MODEL, help=f"default: {DEFAULT_MODEL} ($OPENAI_MODEL)")
    ap.add_argument("--effort", default="high", choices=["", "minimal", "low", "medium", "high"],
                    help="reasoning_effort for reasoning models ('' to omit for non-reasoning models)")
    ap.add_argument("--chunk-words", type=int, default=1200)
    ap.add_argument("--jobs", type=int, default=4, help="parallel requests")
    ap.add_argument("--min-confidence", type=float, default=0.6)
    ap.add_argument("--min-severity", default="minor", choices=SEVERITIES)
    ap.add_argument("--only", default="", help="comma-separated categories to report/apply, "
                    "e.g. grammar,russianism,punctuation")
    ap.add_argument("--apply", action="store_true", help="apply the suggestions to the part files")
    ap.add_argument("-i", "--interactive", action="store_true", help="with --apply: confirm each fix")
    ap.add_argument("--batch", choices=["submit", "status", "wait", "cancel"],
                    help="use the OpenAI Batch API instead of direct requests")
    ap.add_argument("--force", action="store_true", help="ignore the cache")
    ap.add_argument("--dry-run", action="store_true", help="show chunks, do not call the API")
    a = ap.parse_args()

    only = {c.strip() for c in a.only.split(",") if c.strip()}
    if only - set(CATEGORIES):
        sys.exit(f"unknown categories: {', '.join(sorted(only - set(CATEGORIES)))}")
    a.apply = a.apply or a.interactive
    if not a.dry_run and not os.environ.get("OPENAI_API_KEY"):
        sys.exit("OPENAI_API_KEY is not set")
    system = open(PROMPT_PATH, encoding="utf-8").read()
    glossary = open(GLOSSARY_PATH, encoding="utf-8").read()
    parts = find_parts(a.keys)
    if not parts:
        sys.exit("nothing to review")
    os.makedirs(CACHE, exist_ok=True)

    # (key, n, ci, base_line, chunk_text, user_message, cache_path, span, typ_path)
    tasks = []
    for key, n, typ_path, src_path in parts:
        typ = open(typ_path, encoding="utf-8").read()
        src = open(src_path, encoding="utf-8", errors="replace").read()
        lines = typ.splitlines(keepends=True)
        offsets = [0]
        for line in lines:
            offsets.append(offsets[-1] + len(line))
        chunks = chunk_lines(lines, a.chunk_words)
        for ci, (start, text) in enumerate(chunks):
            a_off = offsets[start]
            orig = source_slice(src, len(typ), a_off, a_off + len(text))
            where = f"{key}/part{n}.typ, фрагмент {ci + 1} з {len(chunks)}, від рядка {start + 1}"
            user = build_user_message(glossary, orig, text, where)
            h = hashlib.sha256("\0".join([a.model, a.effort, system, user]).encode()).hexdigest()[:20]
            tasks.append((key, n, ci, start, text, user, os.path.join(CACHE, f"{h}.json"),
                          (a_off, a_off + len(text)), typ_path))

    if a.batch == "cancel":
        return batch_cancel()
    if a.batch in ("status", "wait") and not a.dry_run:
        while batch_collect() and a.batch == "wait":
            print("waiting 60s ...")
            time.sleep(60)

    pending = pending_ids()
    in_flight = [t for t in tasks if os.path.basename(t[6])[:-5] in pending]
    if in_flight and not a.force:
        print(f"{len(in_flight)} chunk(s) are in a pending batch; skipping them "
              "(check with --batch status)")
    todo = [t for t in tasks if (a.force or not os.path.exists(t[6]))
            and (a.force or os.path.basename(t[6])[:-5] not in pending)]
    if a.batch in ("status", "wait"):
        todo = []  # only report what the batches brought back
    est_in = sum(len(system) + len(t[5]) for t in todo) // 3  # ~3 chars/token for mixed uk/en
    print(f"{len(parts)} part(s), {len(tasks)} chunk(s), {len(todo)} to send "
          f"(~{est_in / 1e6:.2f}M input tokens), model {a.model}")
    if a.dry_run:
        for key, n, ci, start, text, *_ in tasks:
            print(f"  {key}/part{n} #{ci + 1}: line {start + 1}, {len(text.split())} words")
        return
    if a.batch == "submit":
        if todo:
            batch_submit(todo, a.model, a.effort, system)
        print("check later with: python3 tools/ttfp/gpt_review.py --batch status")
        return

    usage_total = {"prompt_tokens": 0, "completion_tokens": 0}

    def run(t):
        key, n, ci, start, text, user, cache_path, *_ = t
        result, usage = call_openai(a.model, a.effort, system, user)
        with open(cache_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        return t, usage

    failed = 0
    with cf.ThreadPoolExecutor(max_workers=a.jobs) as pool:
        futures = [pool.submit(run, t) for t in todo]
        for i, fut in enumerate(cf.as_completed(futures), 1):
            try:
                (key, n, ci, *_), usage = fut.result()
                for k in usage_total:
                    usage_total[k] += usage.get(k, 0)
                print(f"[{i}/{len(todo)}] {key}/part{n} #{ci + 1} done")
            except Exception as e:  # keep going; the rest is cached
                failed += 1
                print(f"[{i}/{len(todo)}] FAILED: {e}", file=sys.stderr)

    keep_sev = set(SEVERITIES[: SEVERITIES.index(a.min_severity) + 1])
    by_key, by_file = {}, {}
    for key, n, ci, start, text, user, cache_path, span, typ_path in tasks:
        if not os.path.exists(cache_path):
            continue
        r = json.load(open(cache_path, encoding="utf-8"))
        r["issues"] = [dict(it, line=locate(it["quote"], text, start), _span=span)
                       for it in r["issues"] if it["confidence"] >= a.min_confidence
                       and (not only or it["category"] in only)]
        by_key.setdefault(key, {})[(n, ci)] = r
        by_file.setdefault(typ_path, []).extend(
            it for it in r["issues"] if it["severity"] in keep_sev)

    if a.apply:
        total = 0
        for typ_path, issues in sorted(by_file.items()):
            n_applied = apply_fixes(typ_path, issues, a.interactive)
            total += n_applied
            print(f"{os.path.relpath(typ_path, ROOT)}: applied {n_applied}/{len(issues)}")
        print(f"applied {total} fix(es); review with: git diff tools/ttfp/out")
    for results in by_key.values():
        for r in results.values():
            for it in r["issues"]:
                it.pop("_span", None)

    for key, results in sorted(by_key.items()):
        counts = write_report(key, results, a.min_severity)
        print(f"{key}: " + ", ".join(f"{s} {c}" for s, c in counts.items())
              + f" -> {os.path.relpath(os.path.join(DEST, key + '.md'), ROOT)}")
    if todo:
        print(f"tokens: {usage_total['prompt_tokens']} in, {usage_total['completion_tokens']} out")
    if failed:
        sys.exit(f"{failed} chunk(s) failed; rerun to retry them (done chunks are cached)")


if __name__ == "__main__":
    main()
