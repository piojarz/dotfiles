(( $+commands[workmux] )) || return 1

# Smart worktree creation with branch naming conventions, layered on top of
# workmux's `workmux add` (which creates the branch if it doesn't exist).
# Mirrors the old feature/chore/fix/refactor/jira prefixes from
# bin/git-worktree-create, carried over from the Worktrunk-based version of
# these helpers (`wt switch --create` -> `workmux add`).

_wt_kebab() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -s '-' | sed 's/^-//;s/-$//'
}

_wt_create() {
  local prefix="$1"
  shift
  local input="$*"

  # Input with a slash is treated as an explicit branch name, used as-is.
  if [[ "$input" == *"/"* ]]; then
    workmux add "$input"
    return
  fi

  workmux add "${prefix}/$(_wt_kebab "$input")"
}

wtc()  { _wt_create "feature" "$@" }
wtcc() { _wt_create "chore" "$@" }
wtcf() { _wt_create "fix" "$@" }
wtcr() { _wt_create "refactor" "$@" }

# Create a worktree from a branch that's only on the remote so far (e.g.
# pushed from another machine). Fetches it first so `workmux add` can see it.
wtr() {
  local branch="$1"
  [[ -z "$branch" ]] && { echo "Usage: wtr <branch>" >&2; return 1 }

  git fetch origin "$branch" && workmux add "$branch"
}

wtcj() {
  local input="$*"

  if [[ "$input" == *"/"* ]]; then
    workmux add "$input"
    return
  fi

  if [[ "$input" =~ ^([A-Z]+-[0-9]+)[[:space:]]+(.+)$ ]]; then
    workmux add "${match[1]}/$(_wt_kebab "${match[2]}")"
  else
    echo "Warning: No JIRA ticket pattern found (e.g., SM-123). Using as-is." >&2
    workmux add "$(_wt_kebab "$input")"
  fi
}

# Per-worktree HTTPS domains. See ~/.config/worktree-domains/README.md.
_WT_SYNC="$HOME/.config/worktree-domains/sync_worktree_domains.py"

# Print this worktree's HTTPS domain; -o opens it in the browser.
wtd() {
  local root host
  root="$(git rev-parse --show-toplevel 2>/dev/null)" \
    || { echo "wtd: not inside a git worktree" >&2; return 1 }

  # --host-for is read-only: it derives the name from the live worktree set
  # without pruning, writing or reloading anything.
  host="$("$_WT_SYNC" --host-for "$root" 2>/dev/null)" \
    || { echo "wtd: no domain for $root — start it, then run wtsync" >&2; return 1 }

  if [[ "$1" == "-o" || "$1" == "--open" ]]; then
    open "https://$host"
  else
    echo "https://$host"
  fi
}

# Rebuild every worktree's routes and reload Caddy.
wtsync() { "$_WT_SYNC" "$@" }
