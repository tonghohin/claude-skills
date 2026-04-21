---
name: revise-plan
description: "Revise an existing implementation plan in .claude/plans/. Use when the user says 'change the plan', 'revise the plan', 'update the plan', 'add a task to', 'remove task', 'swap X for Y in the plan', 'rethink phase N', or wants to modify a plan created by /plan-feature — including after /build-feature has completed some or all tasks. Edits the plan surgically so it always reads as current desired state; adds cleanup tasks when built code needs to be removed or rewritten, so /build-feature can converge plan and code."
argument-hint: "[feature-name] <what to change>"
---

# Revise Plan — Load → Understand Change → Re-research (if needed) → Rewrite Surgically → Save

You are revising an existing plan **surgically**. The plan is a spec of what the code should look like *now*, not a changelog. Git carries history — the plan file doesn't need to.

You are NOT building. You are NOT re-planning from scratch. You are editing the plan in place so that after your changes:
- Every task describes what *should* exist in the code.
- Tasks that match current code stay `[x]`.
- Tasks whose code no longer matches the spec are cleared to `[ ]` so `/build-feature` will redo them.
- Tasks that were removed from scope are deleted — and if built code needs to go with them, a new cleanup task is added to delete that code.

## Step 1: Load the Plan

1. Parse the argument. The first whitespace-separated token may be a plan name (e.g., `oauth-login`). Everything after it is the change request.
   - If the first token matches a file in `.claude/plans/`, treat it as the plan name and the rest as the change request.
   - Otherwise treat the whole argument as the change request and resolve the plan name as below.

2. Resolve the plan file:
   - If a plan name was given → load `.claude/plans/[feature-name].md`.
   - If not → list files in `.claude/plans/`. If there's one, use it. If there are several, ask the user which one.
   - If `.claude/plans/` is empty or doesn't exist:
     > No plan to revise. Run `/plan-feature [description]` first.

     Stop.

3. Read the plan file completely. Note:
   - Which tasks are marked `[x]` (built).
   - Whether a `## Completed` section exists (fully built already — the revision will almost certainly need cleanup tasks).
   - The Research Summary — the revision may or may not invalidate it.

## Step 2: Understand the Change

If the user's change request is clear, restate it in one sentence and proceed. If vague (`"update the plan"` with no specifics), ask ONE round of clarifying questions.

Classify the change — this determines Step 3 scope:

| Change type | Examples | Re-research? |
|---|---|---|
| **Add** | "add a caching phase", "add a task for rate limiting" | Yes, for the new area only |
| **Remove** | "drop task 2.3", "remove the email provider phase" | No |
| **Modify** | "task 3.1 should use Redis instead of in-memory" | Only if the swap changes patterns |
| **Reorder** | "move phase 3 before phase 2" | No |
| **Swap approach** | "use Postgres instead of SQLite throughout" | Yes, broadly |

## Step 3: Re-research (only if needed)

If the change type is "Add" or "Swap approach", do targeted research on the new area. Don't re-scan the whole codebase. Look for:
- Existing patterns for the new thing (e.g., if swapping to Redis, find how the codebase already configures clients).
- Dependencies that need to be added or removed.
- Cascading impact on other phases.

Update the **Research Summary** in place to reflect reality after the change.

## Step 4: Rewrite Surgically

Apply the change directly. The plan after revision must read as current desired state — no supersede markers, no superseded tasks, no changelog entries inline with tasks.

The rules below cover both built (`[x]`) and unbuilt (`[ ]`) tasks. For unbuilt tasks it's simpler — no code exists yet, so no cleanup task and no "Replaces previous build" note. The extra machinery only kicks in when `[x]` is involved.

### Rules by change type

**Modified task (body/approach changes):**
- Rewrite the task body in place.
- If the task was `[x]`: clear it to `[ ]`. The built code no longer matches the spec; `/build-feature` will redo it. Add a `**Replaces previous build:**` line in the task body so the builder knows to remove/rewrite existing code, not create from scratch. Specify which files/functions to touch.

**Removed task:**
- Delete the task from the plan entirely.
- If the deleted task was `[x]` and its built code should also be removed from the codebase: add a new **cleanup task** in a suitable phase (usually the same phase the deleted task was in, or a dedicated "Cleanup" phase at the end). The cleanup task lists the specific files/functions/config to delete and a concrete Verify step (e.g., `grep -r 'OldHandler' src/ returns no matches`, `pnpm test still passes`).
- If the deleted task's code should *stay* (e.g., it's used elsewhere or the user explicitly wants to keep it as dead code for now): just delete the task, no cleanup. Note this in the Revision log (Step 5).

**Added task:**
- Insert `[ ]` at the right spot.

**Reordered:**
- Move as-is. Preserve `[x]` state and body.

**Swapped approach (cascades):**
- Treat each affected task as either Modified or Removed per the rules above. Often the cleanest path is to clear `[x]` on all affected tasks and add a single cleanup task at the top of the next phase covering what needs to be torn down.

### Numbering

- Renumber freely so the plan reads cleanly top to bottom. `[x]` tasks don't need stable numbers — code doesn't care what number a task had.
- Keep phase structure coherent. If removing leaves a phase with one task, consider merging into an adjacent phase. Don't do this aggressively — only when it obviously reads better.

### Ambiguity

If you're unsure whether built code should be removed or kept (e.g., a removed task touched a shared utility), **ask the user before adding or skipping a cleanup task**. Don't guess — the wrong choice either leaves dead code in the repo or deletes code something else depends on.

## Step 5: Log the Revision (lightly)

Add a dated line to the `## Notes` section:

```
## Notes

- **[today's date] — Revision:** [one-line summary of what changed and why, e.g., "Swapped Google OAuth for Apple; added cleanup task 2.3 to remove Google client."]
```

This is the only breadcrumb kept in the plan itself. Full history lives in git.

## Step 6: Save and Summarize

1. Overwrite `.claude/plans/[feature-name].md`.

2. Show the user:

   > **Plan revised: [Feature Name]**
   >
   > **Changes:**
   > - [one line per change — added / modified / removed / cleanup-added]
   >
   > **Tasks to run next:** [count of `[ ]` tasks, including any new cleanup tasks]
   >
   > **Built code affected:** [list files/functions that will change or be deleted when `/build-feature` runs, or "none — spec-only change"]
   >
   > Review the updated plan at `.claude/plans/[feature-name].md`. When ready:
   > ```
   > /build-feature [feature-name]
   > ```
   > `/build-feature` will skip completed tasks and execute the unchecked ones, including any cleanup tasks — converging the code with the revised plan.

## Principles

- **The plan is a spec, not a log.** After revision it must read as current desired state. No supersede markers. No "old task 2.1" left in place. Git carries history — the file doesn't need to.
- **Surgical edits, not rewrites.** Change what the user asked. Don't "improve" wording, reorder for style, or tighten unrelated task descriptions.
- **`[x]` is a claim that code exists matching this task.** If the revision breaks that claim, either clear `[x]` (task will be rebuilt) or add a cleanup task (code will be removed). Never leave an `[x]` whose body no longer describes reality.
- **Cleanup tasks are real tasks.** They have a body, a file list, and a Verify step. They are how the plan tells `/build-feature` "delete this."
- **Research only the delta.** Don't re-scan the codebase for simple removals or reorders.
- **No implementation code.** Same rule as `/plan-feature`. Revising the plan is not the same as building the delta — that's what `/build-feature` is for.
