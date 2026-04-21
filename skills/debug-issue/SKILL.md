---
name: debug-issue
description: "Structured debugging workflow for tracking down and fixing bugs. Use when the user says 'debug', 'fix this bug', 'why is this broken', 'investigate', 'not working', 'something is wrong', 'error', 'failing', or describes unexpected behavior they need help resolving."
argument-hint: "<description of the issue>"
---

# Debug Issue — Reproduce → Isolate → Fix → Verify

You are debugging an issue. Follow a structured approach — don't guess and patch.

## Step 1: Understand the Problem

1. Restate the issue in your own words. Include:
   - **What's happening:** the observed behavior.
   - **What's expected:** what should happen instead.
   - **When it happens:** specific trigger, input, or conditions (if known).

2. If the user's description is too vague to act on (e.g., "it's broken"), ask ONE round of clarifying questions:
   - What were you doing when it happened?
   - Is there an error message or stack trace?
   - Did this work before? What changed?

## Step 2: Reproduce

1. Try to reproduce the issue. Run the relevant command, test, or workflow.
2. If you can reproduce it:
   > **Reproduced.** [describe what you saw — error message, wrong output, etc.]
3. If you can't reproduce it, say so and explain what you tried. Ask the user for more details before proceeding.

Do NOT skip this step. Fixing a bug you can't reproduce is guessing.

## Step 3: Isolate

Narrow down the root cause. Work from the symptom backward:

1. **Read the error.** Stack traces, log output, and error messages are your starting point. Read the actual source at the line numbers mentioned — don't assume you know what's there.
2. **Trace the code path.** Follow the execution from the entry point to where it breaks. Read each file involved.
3. **Check recent changes.** Use `git log` and `git diff` to see what changed recently in the relevant files. The bug may have been introduced by a recent commit.
4. **Form a hypothesis.** State it clearly:
   > **Hypothesis:** [what you think is wrong and why]

If your first hypothesis doesn't hold, form a new one. Don't tunnel-vision on your first guess.

## Step 4: Fix

1. **Announce the fix before writing it:**
   > **Fix:** [one-line description of the change]
   > **File(s):** [paths]
   > **Why this fixes it:** [brief explanation connecting the fix to the root cause]

2. **Make the minimal change.** Fix the bug, nothing else. Don't refactor surrounding code, don't "improve" nearby logic, don't add unrelated error handling.

3. **Write a test for the bug** if the project has test infrastructure. The test should:
   - Fail before the fix (or would have, given the bug condition).
   - Pass after the fix.
   - Be a unit test unless the bug specifically involves cross-boundary behavior.

## Step 5: Verify

1. Run the reproduction step again — the issue should be gone.
2. Run the relevant test suite to make sure nothing else broke.
3. If the fix introduced new failures, investigate and resolve before reporting done.

## Step 6: Report

> **Fixed: [short title]**
>
> **Root cause:** [1-2 sentences — what was actually wrong]
>
> **Fix:** [what you changed and in which files]
>
> **Test:** [test added, or why not]
>
> **Verified:** [how you confirmed it works]

## Principles

- **Reproduce first.** Never skip straight to reading code and guessing. A reproducible bug is a solvable bug.
- **Read the actual error.** Don't skim the stack trace — read it. The answer is usually in there.
- **Trace, don't grep.** Searching for keywords finds where code lives. Tracing execution finds why it breaks. Do both, but prioritize tracing.
- **One fix at a time.** If you change three things and the bug goes away, you don't know which one fixed it. Make one change, verify, repeat if needed.
- **Minimal fix.** A bug fix is not a refactoring opportunity. Fix the bug. If you spot other problems, note them for later.
- **State your hypothesis.** Saying "I think X is wrong because Y" out loud catches bad reasoning faster than silently editing code.
