#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.tmp/live-acceptance-remediation"
FIXTURE="$ROOT/tests/fixtures/firstmate"
rm -rf "$TMP"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

export ORBIT_HOME="$TMP/orbit-home"
export ORBIT_FIRSTMATE_ROOT="$TMP/firstmate-root"
export ORBIT_FIRSTMATE_HOME="$TMP/firstmate-home"
export ORBIT_FIRSTMATE_PROJECT="$ROOT"
mkdir -p "$ORBIT_FIRSTMATE_ROOT/bin" "$ORBIT_FIRSTMATE_HOME/data" "$ORBIT_FIRSTMATE_HOME/state"

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-brief.sh" <<'FAKE_BRIEF'
#!/usr/bin/env bash
set -euo pipefail
id=$1
mkdir -p "$FM_HOME/data/$id"
printf '%s\n' "$id" >> "$FM_HOME/brief-calls.log"
cat > "$FM_HOME/data/$id/brief.md" <<EOF
# Scout
{TASK}
EOF
FAKE_BRIEF

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-spawn.sh" <<'FAKE_SPAWN'
#!/usr/bin/env bash
set -euo pipefail
id=$1
printf '%s\n' "$id" >> "$FM_HOME/spawn-calls.log"
cat > "$FM_HOME/state/$id.meta" <<EOF
endpoint_task_id=$id
kind=scout
busy_gen=focused.1.$id
EOF
FAKE_SPAWN

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-crew-state.sh" <<'FAKE_STATE'
#!/usr/bin/env bash
set -euo pipefail
printf 'state: working · source: focused-fixture\n'
FAKE_STATE
chmod +x "$ORBIT_FIRSTMATE_ROOT/bin/"*.sh

slug=systems-shaper-weekly-huddle
orbit_id=2026-07-31
mission="$ORBIT_HOME/missions/$slug"
orbit="$mission/orbits/$orbit_id"
mkdir -p "$mission/state" "$orbit/crew-orders" "$orbit/crew-returns"
printf '# accepted state\n' > "$mission/state/current.md"
printf '# source\n- Status: `PINNED_FOCUSED_FIXTURE`\n' > "$orbit/source-index.md"

copy_order() {
  local source_id=$1 target_id=$2 target_name=$3
  sed "s/Crew Order ID: $source_id/Crew Order ID: $target_id/" \
    "$FIXTURE/crew-orders/$source_id"-"$( [ "$source_id" = 001 ] && printf 'recorder-analyst' || printf 'systems-analyst' )".md \
    > "$orbit/crew-orders/$target_name"
}
copy_order 001 001 001-recorder-analyst.md
copy_order 002 002 002-systems-analyst.md
copy_order 002 003 003-focused-order.md
copy_order 002 004 004-artifact-order.md
copy_order 002 005 005-nonresumable-order.md

setup_mode() {
  printf '%s\n' "$1" > "$mission/crew.yaml"
}

assert_config_hold() {
  local label=$1
  shift
  local output="$TMP/$label.out"
  local before after
  before=$(find "$orbit" -type f -print0 | sort -z | xargs -0 cksum 2>/dev/null || true)
  if "$ROOT/bin/orbit" analyze "$slug" "$orbit_id" > "$output" 2>&1; then
    echo "FAIL: invalid execution mode was accepted: $label" >&2
    exit 1
  fi
  grep -F 'FLIGHT STATUS: HOLD — CONFIGURATION ERROR' "$output" >/dev/null
  grep -F 'No Crew work' "$output" >/dev/null
  after=$(find "$orbit" -type f -print0 | sort -z | xargs -0 cksum 2>/dev/null || true)
  [ "$before" = "$after" ]
}

# Missing, empty, malformed, and unsupported modes all fail closed before the
# order count or any runtime/completion path is reached.
setup_mode 'crews:\n  version: 1'
assert_config_hold missing-mode
setup_mode $'execution:\n  mode:\n'
assert_config_hold empty-mode
setup_mode $'execution:\n  mode sequential\n'
assert_config_hold malformed-mode
setup_mode $'execution:\n  mode: unsupported\n'
assert_config_hold unsupported-mode

setup_mode $'execution:\n  mode: sequential\n'
sequential_output=$("$ROOT/bin/orbit" analyze "$slug" "$orbit_id")
printf '%s\n' "$sequential_output" | grep -F 'Runtime: sequential' >/dev/null
printf '%s\n' "$sequential_output" | grep -F 'CREW ORDERS READY FOR SEQUENTIAL FALLBACK' >/dev/null

setup_mode $'execution:\n  mode: firstmate\n  fallback: sequential\n'
firstmate_output=$("$ROOT/bin/orbit" analyze "$slug" "$orbit_id")
printf '%s\n' "$firstmate_output" | grep -F 'Runtime: firstmate' >/dev/null
printf '%s\n' "$firstmate_output" | grep -F 'CREW ORDERS READY FOR FIRSTMATE' >/dev/null

# A legacy-shaped order that merely adds the scout value is still held: the
# Firstmate adapter cannot infer canonical v1 identity/sections from aliases.
legacy_order="$orbit/crew-orders/006-legacy-read-only-scout.md"
cat > "$legacy_order" <<'LEGACY_ORDER'
# Crew Order

- Order ID: 006
- Mission: systems-shaper-weekly-huddle
- Orbit date: 2026-07-31
- Role: Recorder Analyst
- Order type: `READ_ONLY_SCOUT`
- Status: `PLANNED`

## Objective

Read a bounded synthetic source.

## Allowed inputs

- synthetic source locator

## Explicitly disallowed

- implementation
- external Dispatch
- Mission State promotion

## Dependencies

None.

## Required output

Role-attributed findings.
LEGACY_ORDER
legacy_before=$(find "$orbit" -type f -print0 | sort -z | xargs -0 cksum)
if "$ROOT/bin/orbit" analyze "$slug" "$orbit_id" > "$TMP/legacy.out" 2>&1; then
  echo 'FAIL: legacy-shaped READ_ONLY_SCOUT order was accepted' >&2
  exit 1
fi
grep -F 'FLIGHT STATUS: HOLD — FIRSTMATE PROVENANCE BLOCKED' "$TMP/legacy.out" >/dev/null
grep -F 'canonical Mission ID' "$TMP/legacy.out" >/dev/null
[ "$legacy_before" = "$(find "$orbit" -type f -print0 | sort -z | xargs -0 cksum)" ]
rm "$legacy_order"

# Explicit task ID binding is authoritative when preflight is called later
# without the override, and a duplicate logical prepare is refused.
setup_mode $'execution:\n  mode: firstmate\n'
explicit_task=focused-explicit-task
"$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md "$explicit_task" >/dev/null
preflight_default=$("$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md)
printf '%s\n' "$preflight_default" | grep -F 'FIRSTMATE PREFLIGHT: READY_TO_SUBMIT' >/dev/null
brief_calls_before=$(wc -l < "$ORBIT_FIRSTMATE_HOME/brief-calls.log")
if "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md > "$TMP/duplicate-prepare.out" 2>&1; then
  echo 'FAIL: default duplicate logical prepare was accepted' >&2
  exit 1
fi
grep -F 'refusing duplicate prepare' "$TMP/duplicate-prepare.out" >/dev/null
[ "$(wc -l < "$ORBIT_FIRSTMATE_HOME/brief-calls.log")" = "$brief_calls_before" ]

# A default binding remains authoritative when a caller supplies an explicit
# task ID later; it must not create or submit a second task.
"$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 002-systems-analyst.md >/dev/null
preflight_explicit=$("$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 002-systems-analyst.md another-task-id)
printf '%s\n' "$preflight_explicit" | grep -F 'FIRSTMATE PREFLIGHT: READY_TO_SUBMIT' >/dev/null
"$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 002-systems-analyst.md >/dev/null
spawn_calls_before=$(wc -l < "$ORBIT_FIRSTMATE_HOME/spawn-calls.log")
if "$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 002-systems-analyst.md another-task-id > "$TMP/duplicate-submit.out" 2>&1; then
  echo 'FAIL: explicit duplicate logical submit was accepted' >&2
  exit 1
fi
grep -F 'submission binding' "$TMP/duplicate-submit.out" >/dev/null
[ "$(wc -l < "$ORBIT_FIRSTMATE_HOME/spawn-calls.log")" = "$spawn_calls_before" ]

# Multiple bindings, mismatched provenance, malformed binding, and artifacts
# without a binding all fail closed during logical-order discovery.
cp "$orbit/runtime/firstmate/$explicit_task.binding" "$orbit/runtime/firstmate/duplicate.binding"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md > "$TMP/duplicate-bindings.out" 2>&1; then
  echo 'FAIL: multiple logical bindings were accepted' >&2
  exit 1
fi
grep -F 'multiple Firstmate bindings' "$TMP/duplicate-bindings.out" >/dev/null
rm "$orbit/runtime/firstmate/duplicate.binding"

sed -i 's/^mission_id=.*/mission_id=wrong-mission/' "$orbit/runtime/firstmate/$explicit_task.binding"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md > "$TMP/mismatch.out" 2>&1; then
  echo 'FAIL: mismatched binding provenance was accepted' >&2
  exit 1
fi
grep -F 'mismatched or incomplete provenance' "$TMP/mismatch.out" >/dev/null
sed -i "s/^mission_id=.*/mission_id=$slug/" "$orbit/runtime/firstmate/$explicit_task.binding"

malformed_task=orb-systems-shaper-weekly-huddle-20260731-003
printf 'crew_order_id=003\nnot-a-binding\n' > "$orbit/runtime/firstmate/$malformed_task.binding"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 003-focused-order.md > "$TMP/malformed.out" 2>&1; then
  echo 'FAIL: malformed binding was accepted' >&2
  exit 1
fi
grep -F 'malformed Firstmate binding' "$TMP/malformed.out" >/dev/null
rm "$orbit/runtime/firstmate/$malformed_task.binding"

artifact_task=orb-systems-shaper-weekly-huddle-20260731-004
mkdir -p "$ORBIT_FIRSTMATE_HOME/data/$artifact_task"
printf 'stale report\n' > "$ORBIT_FIRSTMATE_HOME/data/$artifact_task/report.md"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 004-artifact-order.md > "$TMP/artifact.out" 2>&1; then
  echo 'FAIL: artifact without authoritative binding was accepted' >&2
  exit 1
fi
grep -F 'without an authoritative binding' "$TMP/artifact.out" >/dev/null
rm -rf "$ORBIT_FIRSTMATE_HOME/data/$artifact_task"

# A structurally authoritative binding with a terminal status is held rather
# than treated as a fresh attempt.
nonresumable_task=orb-systems-shaper-weekly-huddle-20260731-005
"$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 005-nonresumable-order.md >/dev/null
sed -i 's/^status=.*/status=COMPLETED/' "$orbit/runtime/firstmate/$nonresumable_task.binding"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 005-nonresumable-order.md > "$TMP/nonresumable.out" 2>&1; then
  echo 'FAIL: terminal Firstmate binding was treated as resumable' >&2
  exit 1
fi
grep -F 'already bound' "$TMP/nonresumable.out" >/dev/null

# /orbit-status reads active NO_GO state from the existing Gate Log and does
# not mutate the Mission Packet or private home.
status_mission="$ORBIT_HOME/missions/status-fixture"
status_orbit="$status_mission/orbits/2026-08-01"
mkdir -p "$status_mission/state" "$status_orbit/crew-orders" "$status_orbit/crew-returns"
printf '# accepted\n' > "$status_mission/state/current.md"
printf 'execution:\n  mode: sequential\n' > "$status_mission/crew.yaml"
cp "$FIXTURE/active-hold-gate-log.md" "$status_orbit/gate-log.md"
printf '# source\n- Status: `PINNED_STATUS_FIXTURE`\n' > "$status_orbit/source-index.md"
status_before=$(find "$status_mission" -type f -print0 | sort -z | xargs -0 cksum)
"$ROOT/bin/orbit" status status-fixture > "$TMP/status.out"
status_after=$(find "$status_mission" -type f -print0 | sort -z | xargs -0 cksum)
[ "$status_before" = "$status_after" ]
grep -F 'Active holds:' "$TMP/status.out" >/dev/null
grep -F 'Synthetic implementation release [NO_GO; authority=Commander; source=HUMAN_DIRECTIVE; scope=implementation]' "$TMP/status.out" >/dev/null

echo 'PASS: live-acceptance remediation regressions'
