#!/usr/bin/env bash
set -eo pipefail

REPO="shashank-koppunoori302/fe-test-kit"
BRANCH="main"
TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

AGENT_IDS=("claude" "claude-user" "cursor" "copilot" "gemini" "codex")

get_label() {
  case "$1" in
    claude)      echo "Claude Code  (project-level)" ;;
    claude-user) echo "Claude Code  (user-level, all your projects)" ;;
    cursor)      echo "Cursor" ;;
    copilot)     echo "GitHub Copilot" ;;
    gemini)      echo "Gemini CLI" ;;
    codex)       echo "Codex / agentskills.io" ;;
  esac
}

get_dest() {
  case "$1" in
    claude)      echo "$PWD/.claude/skills" ;;
    claude-user) echo "$HOME/.claude/skills" ;;
    cursor)      echo "$PWD/.cursor/skills" ;;
    copilot)     echo "$PWD/.github/copilot/skills" ;;
    gemini)      echo "$HOME/.gemini/skills" ;;
    codex)       echo "$PWD/.agents/skills" ;;
  esac
}

is_managed() {
  case "$1" in
    fe-test/SKILL.md|\
    fe-test/references/bad-patterns.md|\
    fe-test/references/quality-gates.md|\
    fe-test/references/adapters/svelte.md|\
    fe-test-learn/SKILL.md|\
    fe-testing-setup/SKILL.md|\
    README.md) return 0 ;;
    *) return 1 ;;
  esac
}

is_user_owned() {
  case "$1" in
    fe-test/knowledge/global-learnings.md) return 0 ;;
    *) return 1 ;;
  esac
}

install_to() {
  local dest_base="$1"
  local label="$2"
  local reinstall=false
  local installed=0
  local preserved=0

  [[ -f "$dest_base/fe-test/SKILL.md" ]] && reinstall=true

  while IFS= read -r -d '' src_file; do
    local rel="${src_file#$SKILLS_SRC/}"
    local dest_file="$dest_base/$rel"

    if is_user_owned "$rel" && [[ -f "$dest_file" ]]; then
      preserved=$((preserved + 1))
      continue
    fi

    if $reinstall && ! is_managed "$rel" && ! is_user_owned "$rel" && [[ -f "$dest_file" ]]; then
      preserved=$((preserved + 1))
      continue
    fi

    mkdir -p "$(dirname "$dest_file")"
    cp "$src_file" "$dest_file"
    installed=$((installed + 1))
  done < <(find "$SKILLS_SRC" -type f -print0)

  local tag="installed"
  $reinstall && tag="updated"
  local note=""
  [[ $preserved -gt 0 ]] && note=", ${preserved} user file(s) preserved"

  echo "  ✓ ${label}: ${installed} files ${tag}${note}"
}

# ── setup ──────────────────────────────────────────────────────────────────────

echo ""
echo "  fe-test — frontend testing skill installer"
echo ""

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

echo "  Downloading skills..."
curl -fsSL "$TARBALL_URL" | tar -xz -C "$TMP_DIR"
SKILLS_SRC="$TMP_DIR/fe-test-kit-${BRANCH}/skills"
echo ""

# ── agent selection ────────────────────────────────────────────────────────────

ARGS=()
[[ $# -gt 0 ]] && ARGS=("$@")
SELECTED=()

if [[ ${#ARGS[@]} -gt 0 ]] && [[ " ${ARGS[*]} " == *" --all "* ]]; then
  SELECTED=("${AGENT_IDS[@]}")
else
  for id in "${AGENT_IDS[@]}"; do
    [[ ${#ARGS[@]} -gt 0 ]] && [[ " ${ARGS[*]} " == *" --${id} "* ]] && SELECTED+=("$id")
  done
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  # Guard: curl | bash pipes stdin — process substitution required for interactive
  if [[ ! -t 0 ]]; then
    echo "  stdin is not a terminal. For interactive mode run:"
    echo ""
    echo "    bash <(curl -fsSL https://raw.githubusercontent.com/${REPO}/${BRANCH}/install.sh)"
    echo ""
    echo "  Or pass flags directly:"
    echo ""
    echo "    curl -fsSL ... | bash -s -- --claude --cursor"
    echo ""
    exit 1
  fi

  echo "  Which agents do you want to install for?"
  echo ""
  for i in "${!AGENT_IDS[@]}"; do
    echo "    $((i + 1)). $(get_label "${AGENT_IDS[$i]}")"
  done
  echo "    $((${#AGENT_IDS[@]} + 1)). All of the above"
  echo ""
  read -r -p "  Enter numbers separated by commas: " INPUT
  echo ""

  if [[ "$INPUT" == "$((${#AGENT_IDS[@]} + 1))" ]] || [[ "$INPUT" == "all" ]]; then
    SELECTED=("${AGENT_IDS[@]}")
  else
    IFS=',' read -ra CHOICES <<< "$INPUT"
    for choice in "${CHOICES[@]}"; do
      local_idx=$(( $(echo "$choice" | tr -d ' ') - 1 ))
      [[ $local_idx -ge 0 && $local_idx -lt ${#AGENT_IDS[@]} ]] && SELECTED+=("${AGENT_IDS[$local_idx]}")
    done
  fi
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  echo "  No agents selected. Exiting."
  echo ""
  exit 0
fi

# ── install ────────────────────────────────────────────────────────────────────

for id in "${SELECTED[@]}"; do
  install_to "$(get_dest "$id")" "$(get_label "$id")"
done

echo ""
echo "  Done. Run /fe-test in your agent to get started."
echo ""
