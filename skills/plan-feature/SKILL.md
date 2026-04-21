---
name: plan-feature
description: "Research the codebase and create a detailed implementation plan for a new feature or project. Use when the user says 'plan', 'scope', 'break down', 'design', 'outline', 'how would I build', 'what would it take to', or wants to understand the approach before building. Also use when starting any new feature — planning should come before building. Produces a research summary and task breakdown, saves it to .claude/plans/ so /build-feature can pick it up later."
argument-hint: "<feature description>"
---

# Plan Feature — Research → Plan → Save

You are creating an implementation plan. You will NOT write any implementation code. Your job is to research, think, and produce a plan that `/build-feature` can execute later.

## Step 1: Understand the Request

Restate what the user wants in your own words. If anything is genuinely ambiguous (not just minor details), ask ONE round of clarifying questions before proceeding. For minor details, pick the most reasonable default and note your assumption.

## Step 2: Research

Use subagents or direct exploration to understand the codebase:

- What is the project structure? (frameworks, languages, key directories)
- Are there existing patterns for similar features? (auth, routing, state, API calls, DB access, tests)
- What dependencies are relevant?
- Are there any CLAUDE.md, README, or architecture docs?
- What testing patterns exist? (framework, conventions, coverage)
- Check recent git history — are there in-flight changes or PRs touching the same areas? The plan should account for concurrent work.

If the feature involves a library, API, or technique you're unsure about, search docs or the web. Don't guess.

## Step 3: Create the Plan

Write a plan document with this structure:

```markdown
# Plan: [Feature Name]

> [One-line description of what this feature does]

## Research Summary

- **Stack:** [e.g., Next.js 14 App Router, TypeScript, Prisma, PostgreSQL]
- **Relevant patterns:** [e.g., existing auth uses NextAuth in src/lib/auth.ts]
- **Key files:** [list the 3-8 most relevant existing files/dirs]
- **New dependencies:** [any new packages needed, or "none"]
- **Risks/Considerations:** [edge cases, breaking changes, migrations]

## Tasks

### Phase 1: [Phase title, e.g., Data Layer]

#### 1.1. [Short title]
- **What:** [1-2 sentence description]
- **Files:** [files to create/modify]
- **Verify:** [how to confirm it works — run test, check output, etc.]

#### 1.2. [Short title]
- **What:** ...
- **Files:** ...
- **Verify:** ...

### Phase 2: [Phase title, e.g., API]

#### 2.1. [Short title]
- **What:** ...
- **Files:** ...
- **Verify:** ...

[...more phases/tasks as needed. Small features may use a single phase.]

## Notes

[Anything the builder should know — open questions, alternative approaches considered, follow-up work]
```

Guidelines for tasks:
- **3-8 tasks per phase.** A small feature may have a single phase. For larger features, group tasks into phases (e.g., "Phase 1: Data Layer", "Phase 2: API", "Phase 3: UI"). Each phase should be a cohesive chunk of work that can be verified as a unit.
- Each task should touch **1-3 files** and be **independently verifiable**.
- Order by dependency — foundational phases first, then tasks within each phase.
- The verify step should be concrete: a command to run, a behavior to check, not "make sure it works."
- **Each phase should include a testing task.** Prefer unit tests over integration/e2e tests — they're faster and cheaper. Only add integration or e2e tests when the feature genuinely requires testing across boundaries (e.g., API + DB, multi-step UI flows). Don't write tests for trivial glue code or simple pass-through logic.

## Step 4: Save the Plan

1. Create the directory `.claude/plans/` if it doesn't exist.
2. Save the plan as `.claude/plans/[feature-name].md` using a kebab-case slug derived from the feature name (e.g., `user-notifications.md`, `oauth-login.md`). If a plan with the same name already exists, ask the user whether to overwrite it or use a different name.
3. Tell the user:

> **Plan saved to `.claude/plans/[feature-name].md`**
>
> Review it, edit anything you'd like to change, then run:
> ```
> /build-feature [feature-name]
> ```
> to start building.

## Principles

- **No implementation code.** You're planning, not building. Don't create source files, install packages, or run migrations.
- **Be specific.** "Update the API route" is a bad task. "Add a POST handler in `src/app/api/notifications/route.ts` that accepts `{userId, message, channel}` and writes to the notifications table" is a good task.
- **Match existing patterns.** The plan should follow the conventions already in the codebase, not introduce new ones.
- **Surface decisions, don't bury them.** If there's a meaningful choice (e.g., polling vs websockets), call it out in Notes so the user can weigh in before building.
- **Code quality defaults.** Prefer specific types over `any` or type casts; if a task introduces a new type/schema, call it out. For runtime validation at boundaries (API input, parsed config, external data), reach for the idiomatic schema library in the stack — **Zod** for TypeScript, **Pydantic** for Python.