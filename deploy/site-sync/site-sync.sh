#!/usr/bin/env bash
# site-sync: fast-forward every git checkout listed in the repos list to the
# latest commit of the branch it has checked out. Installed on the VPS as
# /usr/local/bin/site-sync and run every 5 minutes by site-sync.timer.
#
# Each clone deploys whatever branch it is ON (production clones sit on `main`
# and stay there). Fast-forward only: if a clone has local commits or edits,
# it is left alone and reported, never reset.
#
#   site-sync                          # uses /etc/site-sync/repos.list
#   SITE_SYNC_LIST=./list site-sync    # another list (testing)
#
# The list holds one absolute path per line; blank lines and `#` comments are
# ignored. Exit status is non-zero if any repo failed, so the failure shows in
# `systemctl status site-sync` while the other repos still get updated.
set -uo pipefail

LIST="${SITE_SYNC_LIST:-/etc/site-sync/repos.list}"
[ -r "$LIST" ] || { echo "site-sync: cannot read $LIST" >&2; exit 1; }

fail=0
while IFS= read -r line || [ -n "$line" ]; do
  repo="${line%%#*}"
  repo="${repo#"${repo%%[![:space:]]*}"}"   # trim leading whitespace
  repo="${repo%"${repo##*[![:space:]]}"}"   # trim trailing whitespace
  [ -z "$repo" ] && continue

  if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    echo "$repo: not a git checkout" >&2; fail=1; continue
  fi
  if ! branch="$(git -C "$repo" symbolic-ref --short -q HEAD)"; then
    echo "$repo: detached HEAD, skipping" >&2; fail=1; continue
  fi
  if ! git -C "$repo" fetch --quiet origin "$branch"; then
    echo "$repo: fetch of origin/$branch failed" >&2; fail=1; continue
  fi

  old="$(git -C "$repo" rev-parse HEAD)"
  new="$(git -C "$repo" rev-parse FETCH_HEAD)"
  [ "$old" = "$new" ] && continue

  if git -C "$repo" merge --ff-only --quiet FETCH_HEAD; then
    echo "$repo: $branch ${old:0:7} -> ${new:0:7} ($(git -C "$repo" log -1 --format=%s))"
  else
    echo "$repo: cannot fast-forward $branch to ${new:0:7} (local commits or edits?)" >&2
    fail=1
  fi
done < "$LIST"

exit "$fail"
