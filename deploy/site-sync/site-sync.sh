#!/usr/bin/env bash
# site-sync: keep every *.dobrowney.com checkout on the VPS in step with GitHub.
# Installed as /usr/local/bin/site-sync, run as root every 5 minutes by
# site-sync.timer. Replaces the per-project `update.sh --if-changed` cron lines.
#
#   sudo site-sync                          # uses /etc/site-sync/repos.list
#   sudo SITE_SYNC_LIST=./list site-sync    # another list (testing)
#
# List format, one repo per line (blank lines and `#` comments ignored):
#
#   <absolute path to clone>  [deploy command...]
#
# For each repo:
#   1. Pull: git fetch + fast-forward of the branch the clone has checked out
#      (production clones sit on `main` and stay there). Local commits or edits
#      are never overwritten: the repo is reported and skipped.
#   2. Deploy, only if the line has a command and HEAD differs from the last
#      SUCCESSFUL deploy (marker in /var/lib/site-sync). So a failed deploy is
#      retried on the next run, and an unchanged repo costs one `git fetch`.
#      Static sites have no command: the pull is the deploy.
#
# Git always runs as the clone's owner (e.g. ubuntu), never root, so the clone
# never gains root-owned files and stays usable by hand. The deploy command
# runs as ROOT in the clone, with SUDO_USER set to the owner, exactly as if the
# owner had typed `sudo <command>` there (kidnet's install.sh relies on this).
#
# Exit status is non-zero if any repo failed; the others are still processed.
set -uo pipefail

LIST="${SITE_SYNC_LIST:-/etc/site-sync/repos.list}"
STATE="${SITE_SYNC_STATE:-/var/lib/site-sync}"
[ -r "$LIST" ] || { echo "site-sync: cannot read $LIST" >&2; exit 1; }
mkdir -p "$STATE"

fail=0
while IFS= read -r -u 3 line || [ -n "$line" ]; do
  line="${line%%#*}"
  read -r repo cmd <<<"$line"     # first word = path, rest = deploy command
  [ -z "${repo:-}" ] && continue

  if [ ! -d "$repo/.git" ]; then
    echo "$repo: not a git checkout" >&2; fail=1; continue
  fi
  owner="$(stat -c %U "$repo")"
  home="$(getent passwd "$owner" | cut -d: -f6)"
  g() {
    if [ "$(id -u)" -eq 0 ] && [ "$owner" != root ]; then
      runuser -u "$owner" -- env HOME="$home" git -C "$repo" "$@"
    else
      git -C "$repo" "$@"
    fi
  }

  if ! branch="$(g symbolic-ref --short -q HEAD)"; then
    echo "$repo: detached HEAD, skipping" >&2; fail=1; continue
  fi
  if ! g fetch --quiet origin "$branch"; then
    echo "$repo: fetch of origin/$branch failed" >&2; fail=1; continue
  fi
  old="$(g rev-parse HEAD)"
  new="$(g rev-parse FETCH_HEAD)"
  if [ "$old" != "$new" ]; then
    if g merge --ff-only --quiet FETCH_HEAD; then
      echo "$repo: $branch ${old:0:7} -> ${new:0:7} ($(g log -1 --format=%s))"
    else
      echo "$repo: cannot fast-forward $branch to ${new:0:7} (local commits or edits?)" >&2
      fail=1; continue
    fi
  fi

  [ -z "${cmd:-}" ] && continue
  marker="$STATE/$(echo "$repo" | tr / _).deployed"
  head="$(g rev-parse HEAD)"
  [ "$(cat "$marker" 2>/dev/null)" = "$head" ] && continue

  echo "$repo: deploying ${head:0:7}: $cmd"
  if (cd "$repo" && SUDO_USER="$owner" bash -c "$cmd" </dev/null); then
    echo "$head" > "$marker"
    echo "$repo: deployed ${head:0:7}"
  else
    echo "$repo: deploy of ${head:0:7} FAILED (retried next run)" >&2
    fail=1
  fi
done 3< "$LIST"

exit "$fail"
