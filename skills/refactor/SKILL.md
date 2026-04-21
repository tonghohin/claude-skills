---
name: refactor
description: "Plan and execute a refactoring of existing code. Use when the user says 'refactor', 'clean up', 'restructure', 'reorganize', 'extract', 'simplify', 'rename', 'move', 'split', 'consolidate', or wants to improve code structure without changing behavior."
argument-hint: "<what to refactor and why>"
---

# Refactor — Baseline → Plan → Execute → Verify Behavior

You are refactoring existing code. The goal is to improve structure without changing behavior. Tests must pass before and after.

## Step 1: Understand the Goal

1. Restate what the user wants refactored and why. Common motivations:
   - Code is duplicated and should be consolidated.
   - A file/module is too large and should be split.
   - Naming is unclear or inconsistent.
   - A pattern doesn't match the rest of the codebase.
   - Logic is tangled and hard to follow.

2. If the scope is unclear, ask ONE round of clarifying questions. For example:
   - Should this be a structural change (moving files, extracting modules) or an in-place cleanup?
   - Are there parts of this code that should NOT be touched?

## Step 2: Establish a Baseline

Before changing anything:

1. **Run the test suite** (or relevant subset). Record the results.
   > **Baseline: [N] tests passing, [M] failing, [K] skipped.**

2. If tests are already failing, note which ones. These are not your problem — don't fix pre-existing failures as part of the refactor.

3. If there are no tests covering the code being refactored, tell the user:
   > **No test coverage for this code.** I'll add tests for the current behavior before refactoring so we can verify nothing breaks. This adds a task but makes the refactor safe.

   Then write those tests first, as a separate step.

## Step 3: Plan the Refactor

Outline the changes before making them:

> **Refactor plan:**
> 1. [change] — [why]
> 2. [change] — [why]
> ...
>
> **Files affected:** [list]
> **Risk:** [low/medium — what could break]

Keep the plan short. If the refactor needs more than ~8 steps, suggest splitting it into smaller refactors.

Wait for user confirmation before proceeding. A refactor without buy-in leads to rejected PRs.

## Step 4: Execute

For each step in the plan:

1. **Make the change.** Match existing codebase patterns — don't introduce new conventions during a refactor.
2. **Run tests after each step.** If tests fail, fix the regression before moving on. If you can't fix it, revert the step and tell the user.
3. **Update imports and callers.** Refactors often break references — check all usages of anything you renamed, moved, or deleted.

## Step 5: Verify

1. **Run the full test suite.** Compare against the baseline:
   - All previously passing tests must still pass.
   - No new failures introduced.
2. **Run linting and type-checking** if applicable.
3. **Spot-check behavior** — if the refactored code has a UI or CLI surface, verify it still works the same way.

## Step 6: Summarize

> **Refactor complete: [short title]**
>
> **What changed:**
> - [list of structural changes]
>
> **Files affected:** [list]
>
> **Tests:** [baseline] → [after] (no regressions)
>
> **Follow-up:** [anything the user should know — e.g., "callers in X still use the old pattern, consider updating those separately"]

## Principles

- **Behavior stays the same.** If the user wants to change behavior AND refactor, do them separately — refactor first, then change behavior. Mixing the two makes bugs impossible to attribute.
- **Tests are your safety net.** Run them constantly. If there's no coverage, add it before refactoring. A refactor without tests is a rewrite.
- **Small steps.** Each change should be independently verifiable. Don't make a massive change and hope tests catch everything.
- **Don't over-refactor.** Stop when the code is clear and maintainable. Chasing "perfect" structure creates churn with diminishing returns. If the user asked to extract a helper, extract the helper — don't also reorganize the entire module.
- **Update all references.** Renaming a function is easy. Finding every caller is the actual work. Search the codebase thoroughly — grep for the old name, check re-exports, look for string references in configs and tests.
- **Get buy-in before executing.** Show the plan, wait for a go-ahead. The user may have context about why the code is structured the way it is.
