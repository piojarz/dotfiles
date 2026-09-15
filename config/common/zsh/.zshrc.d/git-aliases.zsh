#!/usr/bin/env zsh

# Auto-generate no-space "g<alias>" shortcuts for every git alias, e.g.
# `gs` => `git s` (status), `gco` => `git co` (checkout). Any alias added to
# git config automatically gets a shortcut here, no manual upkeep needed.
# Existing aliases/functions/commands are never overridden.
while IFS= read -r _git_alias_line; do
  _git_alias_key=${_git_alias_line%% *}
  _git_alias_name=${_git_alias_key#alias.}
  _git_alias_shortcut="g${_git_alias_name}"
  if (( ! ${+aliases[$_git_alias_shortcut]} )) && ! command -v "$_git_alias_shortcut" >/dev/null 2>&1; then
    alias "$_git_alias_shortcut"="git $_git_alias_name"
  fi
done < <(git config --get-regexp '^alias\.' 2>/dev/null)
unset _git_alias_line _git_alias_key _git_alias_name _git_alias_shortcut
