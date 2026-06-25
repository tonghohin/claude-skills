---
name: review-feature
description: "Review code changes for bugs, edge cases, security issues, and pattern consistency. Use when the user says 'review', 'check my code', 'audit', 'look over', 'sanity check', 'code review', or after running /build-feature. Can review against a plan file if one exists, or review standalone changes."
argument-hint: "[feature-name or branch]"
---

# Review Feature — Analyze → Challenge → Flag Issues → Suggest Fixes

You are reviewing code changes. Your job is to catch problems before they ship. Be thorough and adversarial — assume bugs exist and look until you find them or can prove they don't.

## Step 1: Identify What to Review

1. Check if the user provided a feature name or branch as an argument.
   - If a feature name → check if `.claude/plans/[feature-name].md` exists at the **repo root** (not the user's home `~/.claude/` folder). If it does, load it — you'll review against the plan.
   - If a branch → review the diff between that branch and main/master.
   - If no argument → review uncommitted changes (staged + unstaged). If there are none, review the most recent commit.

2. Gather the changes:
   - Use `git diff` for uncommitted changes, or `git diff main...HEAD` for branch changes, or `git show` for the last commit.
   - Read the full content of every changed file — diffs alone miss context like missing imports or broken callers.
   - Also read files that call into the changed code — a change that looks correct in isolation can break callers.

3. Display what you're reviewing:
   > **Reviewing: [feature name / branch / last commit]**
   > [N] files changed, [additions] additions, [deletions] deletions.

## Step 2: First-Pass Analysis

Review the changes across these dimensions, in order of priority:

### Correctness
- Does the logic do what it's supposed to? If a plan exists, does the implementation match the plan's intent?
- Are there off-by-one errors, null/undefined cases, race conditions, or unhandled error paths?
- Are there any missing or broken imports, unused variables, or dead code?

### Security
- Input validation: is user input sanitized before use in queries, commands, or HTML?
- Auth/authz: are new endpoints or routes properly protected?
- Secrets: are any credentials, keys, or tokens hardcoded or logged?
- OWASP top 10: SQL injection, XSS, CSRF, insecure deserialization, etc.

### Edge Cases
- What happens with empty inputs, large inputs, concurrent access?
- Are error states handled, or do they silently fail?
- Are boundary conditions tested?

### Tests
- Do the changes include tests? If not, should they?
- Do existing tests still pass with these changes?
- Are tests covering the important behavior, not just the happy path?

### Pattern Consistency
- Do the changes follow existing codebase patterns? (naming, file structure, error handling, logging)
- Are there new patterns introduced that diverge from the rest of the codebase?

## Step 3: Adversarial Self-Check

After your first pass, switch roles. You are now an attacker and a skeptic trying to break this code and poke holes in your own review.

Work through each of these challenges:

**Challenge your "looks fine" conclusions:**
For every section where you found no issues, ask: "Am I confident, or did I just not look hard enough?" Re-examine the riskiest parts — auth logic, data mutations, external calls, error paths.

**Try to break it:**
- What's the worst input a user could send? What happens?
- What if two requests hit this code at the same time?
- What if a dependency returns null, throws, or times out unexpectedly?
- What if the caller ignores the return value or error?

**Challenge your findings:**
For every issue you flagged, ask: "Is this actually a bug, or am I misreading the context?" Drop any finding you can't defend with specifics.

**Look for what's missing:**
- Is there logic that should exist but doesn't? (missing validation, missing error handling, missing cleanup)
- Are there callers or consumers of this code that will now behave incorrectly?

If the self-check surfaces new issues, add them to your findings. If it invalidates a finding, remove it.

## Step 4: Report

Organize findings by severity:

> ### Critical
> Issues that will cause bugs, data loss, or security vulnerabilities. These must be fixed.
>
> ### Warnings
> Issues that are likely to cause problems or make the code harder to maintain. Should be fixed.
>
> ### Suggestions
> Minor improvements. Fix if easy, skip if not.

For each finding:
- **What:** one-line description of the issue.
- **Where:** file path and line number(s).
- **Why:** what goes wrong if this isn't fixed.
- **Fix:** concrete suggestion — show the code change, don't just describe it.

If there are no findings in a category, skip it — don't say "no issues found" for each one.

## Step 5: Plan Check (if applicable)

If a plan file was loaded, add a section:

> ### Plan vs. Implementation
> - **Tasks completed as planned:** [list]
> - **Deviations:** [what was changed and why, if detectable]
> - **Missing from plan:** [any tasks from the plan not reflected in the changes]

## Step 6: Summary

> **Review complete: [feature name]**
>
> [Critical: N] [Warnings: N] [Suggestions: N]
>
> [One sentence overall assessment — is this ready to ship, or does it need work?]

## Principles

- **Assume bugs exist.** The goal is to find them, not to confirm the code looks okay. Look until you can prove something is correct, not just until nothing jumps out.
- **Be specific.** "This might have issues" is useless. "Line 42: `userId` can be null here because `getUser()` returns `null` when the session expires" is useful.
- **Show the fix.** Don't just point out problems — show what the fix looks like.
- **Read full files, not just diffs.** A change that looks fine in isolation may break something elsewhere in the same file or in callers.
- **Challenge yourself.** If your first pass found nothing, that's a signal to look harder — not to wrap up.
- **Only drop a finding if you can disprove it.** Don't remove something because it feels minor — remove it only if you can show it's not actually a problem.
