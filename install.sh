#!/bin/bash
# Install build-feature and plan-feature skills for Claude Code
# Run: bash install.sh

SKILL_DIR="$HOME/.claude/skills"

echo "Installing Claude Code skills..."

# Create skill directories
mkdir -p "$SKILL_DIR/build-feature"
mkdir -p "$SKILL_DIR/plan-feature"
mkdir -p "$SKILL_DIR/revise-plan"
mkdir -p "$SKILL_DIR/review-feature"
mkdir -p "$SKILL_DIR/debug-issue"
mkdir -p "$SKILL_DIR/refactor"

# Copy skill files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/skills/build-feature/SKILL.md" "$SKILL_DIR/build-feature/SKILL.md"
cp "$SCRIPT_DIR/skills/plan-feature/SKILL.md" "$SKILL_DIR/plan-feature/SKILL.md"
cp "$SCRIPT_DIR/skills/revise-plan/SKILL.md" "$SKILL_DIR/revise-plan/SKILL.md"
cp "$SCRIPT_DIR/skills/review-feature/SKILL.md" "$SKILL_DIR/review-feature/SKILL.md"
cp "$SCRIPT_DIR/skills/debug-issue/SKILL.md" "$SKILL_DIR/debug-issue/SKILL.md"
cp "$SCRIPT_DIR/skills/refactor/SKILL.md" "$SKILL_DIR/refactor/SKILL.md"

echo ""
echo "Done! Six skills installed:"
echo ""
echo "  /plan-feature    — Research codebase → create implementation plan"
echo "  /build-feature   — Execute a saved plan phase by phase"
echo "  /revise-plan     — Edit an existing plan; preserves completed-task markers"
echo "  /review-feature  — Review changes for bugs, security, and consistency"
echo "  /debug-issue     — Structured debugging: reproduce → isolate → fix → verify"
echo "  /refactor        — Restructure code safely with test baseline"
echo ""
echo "Open Claude Code and type /build-feature or /plan-feature to use them."
echo ""
echo "To install as PROJECT-scoped skills instead (shared with your team):"
echo "  cp -r build-feature/ .claude/skills/build-feature/"
echo "  cp -r plan-feature/ .claude/skills/plan-feature/"
