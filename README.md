# Claude Code Skills

A set of skills for structured development with Claude Code: plan before you build, revise plans as scope shifts, and review, debug, or refactor existing code with repeatable workflows.

The core loop is plan → build, with `/revise-plan` for mid-flight changes. The remaining skills cover review, debugging, and refactoring — each is a standalone workflow, usable on its own.

## How the plan → build loop works

```
/plan-feature add user notifications with email and in-app support
    │
    ├── Researches your codebase (structure, patterns, conventions)
    ├── Creates a detailed task breakdown
    └── Saves to .claude/plans/user-notifications.md

    ⏸️  You review the plan. Edit it. Sleep on it. Share it.
    ⏸️  Scope changed? → /revise-plan user-notifications <what to change>

/build-feature user-notifications
    │
    ├── Reads the saved plan
    ├── Executes each task in order, skipping any already marked [x]
    ├── Verifies each task works before moving on
    └── Updates the plan file with completion details
```

## Skills

| Skill | Trigger | What it does |
|-------|---------|--------------|
| `/plan-feature` | "plan", "scope", "break down", "design" | Research codebase → create task plan → save to `.claude/plans/` |
| `/build-feature` | "build", "implement", "execute", "go" | Load plan from `.claude/plans/` → execute tasks → verify → summarize |
| `/revise-plan` | "change the plan", "add a task to", "swap X for Y" | Edit an existing plan; preserves `[x]` markers so in-flight builds resume cleanly |
| `/review-feature` | "review", "check my code", "audit" | Review changes for bugs, edge cases, security, and consistency |
| `/debug-issue` | "debug", "fix this bug", "why is this broken" | Structured debugging: reproduce → isolate → fix → verify |
| `/refactor` | "refactor", "clean up", "restructure" | Plan and execute a refactor with a test baseline |

## Install

### Option A: Personal skills (available in all your projects)

```bash
bash install.sh
```

This copies all six skills to `~/.claude/skills/`.

### Option B: Project skills (shared with your team via git)

```bash
mkdir -p .claude/skills
cp -r skills/plan-feature   .claude/skills/plan-feature
cp -r skills/build-feature  .claude/skills/build-feature
cp -r skills/revise-plan    .claude/skills/revise-plan
cp -r skills/review-feature .claude/skills/review-feature
cp -r skills/debug-issue    .claude/skills/debug-issue
cp -r skills/refactor       .claude/skills/refactor
git add .claude/skills/
git commit -m "Add Claude Code skills"
```

Only include the skills you want — each directory is independent.

## Usage

### Plan a feature

```
/plan-feature add OAuth2 login with Google and GitHub providers
```

Claude researches your codebase, produces a task plan, and saves it to `.claude/plans/oauth-login.md`. Open that file, review the tasks, reorder them, edit descriptions, or remove things you don't want.

### Build from a plan

```
/build-feature oauth-login
```

Claude reads the plan, executes each task, verifies it works, and moves on. When done, it updates the plan file with a completion summary.

If you run `/build-feature` without a name, it'll list available plans and let you pick one. If the plan has some tasks already marked `[x]`, it resumes from the first incomplete task.

### Revise a plan

```
/revise-plan oauth-login swap Google provider for Apple
```

Claude loads the existing plan, classifies the change (add / remove / modify / reorder / swap approach), and edits **surgically** — the plan always reads as current desired state, not a changelog. Git carries the history.

Unbuilt (`[ ]`) tasks are revised freely — bodies get rewritten, tasks get removed or inserted. No special handling, since no code exists yet.

Built (`[x]`) tasks need more care because the `[x]` is a claim that code exists matching the spec:

- **Modified task** — the task body gets rewritten in place. If it was `[x]`, Claude clears it to `[ ]` (the built code no longer matches the spec) and notes which existing files the rebuild should touch.
- **Removed task** — the task is deleted from the plan. If the built code should also go, Claude adds a **cleanup task** with specific files/functions to delete and a concrete Verify step (e.g., `grep -r 'OldHandler' returns no matches`).
- **Added task** — inserted unchecked, ready for the next build.

Then:

```
/build-feature oauth-login
```

Runs the unchecked tasks — including any cleanup tasks — so plan and code converge. If Claude is unsure whether built code should be removed or kept (e.g., a shared utility), it asks before adding the cleanup task.

### Review changes

```
/review-feature
```

Reviews the pending diff against a plan if one exists, or reviews standalone changes otherwise.

### Debug an issue

```
/debug-issue the /api/users endpoint returns 500 when the body is empty
```

Runs a structured debugging workflow: reproduce → isolate → fix → verify.

### Refactor

```
/refactor extract the notification dispatch logic from UserService
```

Establishes a test baseline, plans the refactor, and executes it without changing behavior.

## The plans directory

Plans live in `.claude/plans/` in your project root:

```
.claude/
└── plans/
    ├── oauth-login.md          ← ready to build
    ├── user-notifications.md   ← completed (has ## Completed section)
    └── db-migration.md         ← ready to build
```

You can `.gitignore` this directory or commit it — up to you. Committing plans gives you a nice history of what was planned vs. what was built.

## Customization

All skills are plain markdown — edit them to fit your workflow:

- **Add project-specific conventions** (e.g., "always create a migration file", "run `pnpm test` after each task")
- **Change the plan format** to match your issue tracker
- **Adjust task granularity** (default targets 3-8 tasks per feature)
- **Add a verification step** to the plan skill (e.g., "always include a task for writing tests")

## Tips

- Works best when your project has a `CLAUDE.md` or `README.md` — the research phase reads these.
- For large features, review the plan carefully and split into multiple smaller plans if needed.
- You can edit the saved plan file manually before running `/build-feature` — Claude follows whatever's in the file.
- Plans from previous sessions still work — the build skill reads the file fresh each time.
- If scope shifts mid-build, use `/revise-plan` rather than editing by hand — it protects completed-task markers so resume still works.
