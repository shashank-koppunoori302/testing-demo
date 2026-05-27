#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/shashank-koppunoori302/fe-test-kit/main"
SKILLS="skills"
CWD=$(pwd)
HOME_DIR="$HOME"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

copy_skills() {
  local dest="$1"
  mkdir -p "$dest"

  for skill in fe-test fe-testing-setup fe-test-learn; do
    mkdir -p "$dest/$skill"
    # Fetch skill files from GitHub
    curl -fsSL "$REPO/$SKILLS/$skill/SKILL.md" -o "$dest/$skill/SKILL.md" 2>/dev/null
  done

  # fe-test references
  mkdir -p "$dest/fe-test/references/adapters"
  for f in bad-patterns.md behavioral-theory.md quality-gates.md; do
    curl -fsSL "$REPO/$SKILLS/fe-test/references/$f" -o "$dest/fe-test/references/$f" 2>/dev/null
  done
  curl -fsSL "$REPO/$SKILLS/fe-test/references/adapters/svelte.md" -o "$dest/fe-test/references/adapters/svelte.md" 2>/dev/null

  # Never overwrite global-learnings.md — it contains accumulated session knowledge
  local learnings="$dest/fe-test/knowledge/global-learnings.md"
  mkdir -p "$dest/fe-test/knowledge"
  if [ -f "$learnings" ]; then
    warn "Skipped global-learnings.md (already exists — your learnings are safe)"
  else
    curl -fsSL "$REPO/$SKILLS/fe-test/knowledge/global-learnings.md" -o "$learnings" 2>/dev/null
    log "Installed global-learnings.md"
  fi
}

installed=()

# Claude Code — user level (available in all projects)
if [ -d "$HOME_DIR/.claude" ]; then
  copy_skills "$HOME_DIR/.claude/skills"
  installed+=("Claude Code (user-level)")
fi

# Cursor — project level
if [ -d "$CWD/.cursor" ]; then
  copy_skills "$CWD/.cursor/skills"
  installed+=("Cursor")
fi

# GitHub Copilot — project level
if [ -d "$CWD/.github/copilot" ]; then
  copy_skills "$CWD/.github/copilot/skills"
  installed+=("GitHub Copilot")
fi

# Agents standard — project level
if [ -d "$CWD/.agents" ]; then
  copy_skills "$CWD/.agents/skills"
  installed+=("Project (.agents)")
fi

if [ ${#installed[@]} -eq 0 ]; then
  warn "No agents detected in current directory or home."
  echo ""
  echo "To install manually, run from inside your project:"
  echo "  bash <(curl -fsSL https://raw.githubusercontent.com/shashank-koppunoori302/fe-test-kit/main/install.sh)"
  exit 1
fi

echo ""
log "fe-test-kit installed for: ${installed[*]}"
echo ""
echo "  Start with: /fe-testing-setup"
echo "  Then use:   /fe-test"
echo ""
