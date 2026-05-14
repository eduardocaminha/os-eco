#!/usr/bin/env bash
# Run claude code sessions in sequence over the children of a seeds plan.
#
# Usage: ./run-plan.sh <plan-id>
#
# For each open child issue in the plan, invokes:
#   claude -p "work on sd <id>. use ml. commit when done, no push." \
#     --permission-mode bypassPermissions
#
# Stops on the first non-zero claude exit. Closed children are skipped so
# re-runs are idempotent. Logs land in ./.run-plan-logs/<plan>/<id>.log.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <plan-id>" >&2
  exit 2
fi

plan_id="$1"

for bin in sd claude jq; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' not found on PATH" >&2
    exit 2
  fi
done

plan_json="$(sd plan show "$plan_id" --json)"

if [[ "$(jq -r '.success' <<<"$plan_json")" != "true" ]]; then
  echo "error: sd plan show failed for $plan_id" >&2
  jq '.' <<<"$plan_json" >&2
  exit 2
fi

children=()
while IFS= read -r line; do
  children+=("$line")
done < <(jq -r '.plan.children[]' <<<"$plan_json")

if [[ ${#children[@]} -eq 0 ]]; then
  echo "no children found in plan $plan_id" >&2
  exit 0
fi

log_dir=".run-plan-logs/$plan_id"
mkdir -p "$log_dir"

echo "plan $plan_id: ${#children[@]} children"
for id in "${children[@]}"; do
  status="$(sd show "$id" --json 2>/dev/null | jq -r '.issue.status // .issues[0].status // empty')"
  if [[ "$status" == "closed" ]]; then
    echo "  skip  $id (closed)"
    continue
  fi

  echo "  run   $id (status=${status:-unknown})"
  prompt="work on sd $id. use ml. commit when done, no push."
  log="$log_dir/$id.log"

  if ! claude -p "$prompt" --permission-mode bypassPermissions 2>&1 | tee "$log"; then
    echo "error: claude exited non-zero on $id — see $log" >&2
    exit 1
  fi
done

echo "done."
