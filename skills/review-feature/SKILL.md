---
name: review-feature
description: "Review code changes for bugs, edge cases, security issues, and pattern consistency. Use when the user says 'review', 'check my code', 'audit', 'look over', 'sanity check', 'code review', or after running /build-feature. Can review against a plan file if one exists, or review standalone changes."
argument-hint: "[feature-name or branch]"
---

# Review Feature — Analyze → Flag Issues → Suggest Fixes

You are reviewing code changes. Your job is to catch problems before they ship — not to nitpick style or add unnecessary suggestions.

## Step 1: Identify What to Review

1. Check if the user provided a feature name or branch as an argument.
   - If a feature name → check if `.claude/plans/[feature-name].md` exists. If it does, load it — you'll review against the plan.
   - If a branch → review the diff between that branch and main/master.
   - If no argument → review uncommitted changes (staged + unstaged). If there are none, review the most recent commit.

2. Gather the changes:
   - Use `git diff` for uncommitted changes, or `git diff main...HEAD` for branch changes, or `git show` for the last commit.
   - Read the full content of every changed file — diffs alone miss context like missing imports or broken callers.

3. Display what you're reviewing:
   > **Reviewing: [feature name / branch / last commit]**
   > [N] files changed, [additions] additions, [deletions] deletions.

## Step 2: Analyze

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

## Step 3: Report

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

## Step 4: Plan Check (if applicable)

If a plan file was loaded, add a section:

> ### Plan vs. Implementation
> - **Tasks completed as planned:** [list]
> - **Deviations:** [what was changed and why, if detectable]
> - **Missing from plan:** [any tasks from the plan not reflected in the changes]

## Step 5: Summary

> **Review complete: [feature name]**
>
> [Critical: N] [Warnings: N] [Suggestions: N]
>
> [One sentence overall assessment — is this ready to ship, or does it need work?]

## Principles

- **Focus on what matters.** Bugs and security issues first. Don't waste the user's time with style nits or suggestions to add comments.
- **Be specific.** "This might have issues" is useless. "Line 42: `userId` can be null here because `getUser()` returns `null` when the session expires" is useful.
- **Show the fix.** Don't just point out problems — show what the fix looks like.
- **Don't pad the review.** If the code is solid, say so. A short review with no issues is a good outcome, not a sign you didn't look hard enough.
- **Read full files, not just diffs.** A change that looks fine in isolation may break something elsewhere in the same file or in callers.
