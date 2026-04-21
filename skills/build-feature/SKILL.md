---
name: build-feature
description: "Execute an implementation plan created by /plan-feature. Use when the user says 'build', 'implement', 'execute', 'start building', 'build it', 'go', or references a plan they want executed. Reads a saved plan from .claude/plans/, then implements each task with verification. If no plan exists, directs the user to run /plan-feature first."
argument-hint: "[feature-name]"
---

# Build Feature — Load Plan → Execute → Verify

You are executing a pre-made implementation plan. Do NOT re-plan from scratch. Follow the plan.

## Step 1: Load the Plan

1. Check if the user provided a feature name as an argument (e.g., `/build-feature user-notifications`).
   - If yes → look for `.claude/plans/[feature-name].md`
   - If no argument → list all files in `.claude/plans/` and ask the user which plan to execute. If there's only one plan, use it automatically.

2. If the plan file doesn't exist or `.claude/plans/` is empty:
   > No plan found. Run `/plan-feature [description]` first to create one, then come back here to build it.

   Stop here.

3. Read the plan file. Check for a `## Completed` section or tasks marked as `[x]` — if some tasks are already done, resume from the first incomplete task.

4. Display a brief summary:
   > **Loading plan: [Feature Name]**
   > [one-line description from the plan]
   > [N] phases, [M] total tasks. [K already completed — resuming from Phase X, Task Y.]
   >
   > Starting now. I'll pause if I hit anything unexpected.

## Step 2: Execute Phase by Phase

For each phase in the plan, in order:

1. **Announce the phase:** `## Phase N: [title]`

2. **Execute each task in the phase**, in order:
   1. **Announce:** `### Task N.M: [title]`
   2. **Re-read relevant files** listed in the task's "Files" field to get current state (the plan may have been written in a different session — don't assume context).
   3. **Implement** the changes. Write clean code that matches the codebase patterns described in the plan's Research Summary.
   4. **Verify** using the exact method specified in the task's "Verify" field. If verification fails, fix the issue before moving on. If you can't fix it after 2 attempts, pause and tell the user what's wrong.
   5. **Mark complete** in the plan file by adding `[x]` to the task heading (e.g., `#### 1.1. [x] Short title`). This enables resuming if the build is interrupted. Then move to the next task.

3. **Phase check:** After completing all tasks in a phase, run relevant tests and verify the phase works as a cohesive unit. Fix anything that broke.

4. **Pause for review:** Stop before starting the next phase. Show the user:

   > **Phase N complete: [title]**
   >
   > **What changed:**
   > - `path/to/file.ts` — [one-line summary]
   > - ...
   >
   > **Verification:** [what was run and the result]
   >
   > **Next up:** Phase N+1 — [title]
   >
   > Reply to continue, or tell me what to adjust.

   Wait for the user's explicit go-ahead before starting the next phase. Do not proceed automatically. If they request changes, address them, then re-prompt before moving on.

## Step 3: Final Check

After all phases are done:

1. Run the full test suite (or relevant subset) if the project has tests.
2. Run linting and type-checking if applicable.
3. Fix anything that broke.

## Step 4: Update the Plan & Summarize

1. Update the plan file — add a `## Completed` section at the bottom:

```markdown
## Completed

- **Date:** [today's date]
- **All tasks executed successfully:** [yes/no]
- **Files changed:**
  - `path/to/file.ts` — [what changed]
  - ...
- **How to test:** [manual steps or commands]
- **Follow-up items:** [anything from the Notes section that still needs attention]
```

2. Show the user a summary:

> **Build complete: [Feature Name]**
>
> [2-3 sentence summary of what was built]
>
> **Files changed:** [short list]
>
> **How to test:** [commands or steps]
>
> Plan updated at `.claude/plans/[feature-name].md` with completion details.

## Principles

- **Follow the plan.** Don't add scope, refactor unrelated code, or introduce patterns not in the plan. If you spot something worth improving, note it in the follow-up items.
- **Match existing patterns.** Use the conventions described in the plan's Research Summary. If the plan says the codebase uses a service layer, use a service layer.
- **Re-read before writing.** Each task may run in a context where you haven't seen the files recently. Always read the relevant files fresh before making changes.
- **Keep the user informed but not overwhelmed.** Show task start/complete announcements. Don't narrate every file read or search.
- **If something goes wrong,** explain what happened, what you tried, and propose a fix. Don't silently retry in a loop. If a task is blocked, pause and ask the user.
- **Don't modify the plan's task list.** If you realize a task needs adjustment, implement the spirit of it and note what you changed in the completion summary. The user wrote/approved that plan — respect it.
