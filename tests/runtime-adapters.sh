#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.tmp/runtime-adapters"
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
id=${1:?}
repo=${2:?}
mode=${3:?}
[ "$mode" = --scout ] || { echo 'fake Firstmate accepts scout only' >&2; exit 2; }
mkdir -p "$FM_HOME/data/$id"
printf '%s\n' "$id|$repo|$mode" >> "$FM_HOME/brief-calls.log"
cat > "$FM_HOME/data/$id/brief.md" <<EOF
You are a deterministic fake Firstmate scout.

# Task
{TASK}

# Definition of done
Write the scout report to $FM_HOME/data/$id/report.md.
EOF
FAKE_BRIEF

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-spawn.sh" <<'FAKE_SPAWN'
#!/usr/bin/env bash
set -euo pipefail
id=${1:?}
project=${2:?}
mode=${3:?}
[ "$mode" = --scout ] || { echo 'fake Firstmate accepts scout only' >&2; exit 2; }
printf '%s\n' "$*" >> "$FM_HOME/spawn-calls.log"
printf 'spawned %s kind=scout project=%s\n' "$id" "$project"
FAKE_SPAWN

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-crew-state.sh" <<'FAKE_STATE'
#!/usr/bin/env bash
set -euo pipefail
id=${1:?}
status="$FM_HOME/state/$id.status"
last=$(grep -v '^[[:space:]]*$' "$status" | tail -1)
case "$last" in
  done:*) printf 'state: done · source: status-log · %s\n' "${last#done: }" ;;
  *) printf 'state: working · source: status-log · %s\n' "$last" ;;
esac
FAKE_STATE
chmod +x "$ORBIT_FIRSTMATE_ROOT/bin/fm-brief.sh" "$ORBIT_FIRSTMATE_ROOT/bin/fm-spawn.sh" "$ORBIT_FIRSTMATE_ROOT/bin/fm-crew-state.sh"

slug=systems-shaper-weekly-huddle
orbit_id=2026-07-31
mission="$ORBIT_HOME/missions/$slug"
orbit="$mission/orbits/$orbit_id"
mkdir -p "$mission/state" "$orbit/crew-orders" "$orbit/crew-returns"
printf '# Synthetic accepted state\n' > "$mission/state/current.md"
printf 'execution:\n  mode: firstmate\n  fallback: sequential\n' > "$mission/crew.yaml"
printf '# Synthetic source index\n- Status: `PINNED_SYNTHETIC_STRUCTURE`\n' > "$orbit/source-index.md"
cp "$FIXTURE/crew-orders/"*.md "$orbit/crew-orders/"
cp "$FIXTURE/gate-log.md" "$orbit/gate-log.md"
cp "$FIXTURE/reconciliation.md" "$orbit/reconciliation.md"
analyze_out=$("$ROOT/bin/orbit" analyze "$slug" "$orbit_id")
printf '%s\n' "$analyze_out" | grep -F 'Runtime: firstmate' >/dev/null
printf '%s\n' "$analyze_out" | grep -F 'CREW ORDERS READY FOR FIRSTMATE' >/dev/null
gate_before=$(cksum "$orbit/gate-log.md")
reconciliation_before=$(cksum "$orbit/reconciliation.md")

sed -e 's/Crew Order ID: 001/Crew Order ID: 900/' -e 's/READ_ONLY_SCOUT/IMPLEMENTATION/' \
  "$orbit/crew-orders/001-recorder-analyst.md" > "$orbit/crew-orders/900-implementation.md"
if "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 900-implementation.md >"$TMP/rejected.out" 2>&1; then
  echo 'FAIL: Firstmate adapter accepted a non-scout implementation order' >&2
  exit 1
fi
grep -F 'accepts only Order type READ_ONLY_SCOUT' "$TMP/rejected.out" >/dev/null
rm -f "$orbit/crew-orders/900-implementation.md" "$TMP/rejected.out"

prepare_001=$("$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md)
prepare_002=$("$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 002-systems-analyst.md)
task_001=$(printf '%s\n' "$prepare_001" | awk -F': ' '/^Firstmate task ID:/ { print $2; exit }')
task_002=$(printf '%s\n' "$prepare_002" | awk -F': ' '/^Firstmate task ID:/ { print $2; exit }')
report_001="$ORBIT_FIRSTMATE_HOME/data/$task_001/report.md"
report_002="$ORBIT_FIRSTMATE_HOME/data/$task_002/report.md"
brief_001="$ORBIT_FIRSTMATE_HOME/data/$task_001/brief.md"
brief_002="$ORBIT_FIRSTMATE_HOME/data/$task_002/brief.md"

# A. Crew Order -> Firstmate scout mapping.
[ -n "$task_001" ] && [ -n "$task_002" ] && [ "$task_001" != "$task_002" ]
project_name=$(basename "$ORBIT_FIRSTMATE_PROJECT")
grep -F -- "$task_001|$project_name|--scout" "$ORBIT_FIRSTMATE_HOME/brief-calls.log" >/dev/null
grep -F -- "$task_002|$project_name|--scout" "$ORBIT_FIRSTMATE_HOME/brief-calls.log" >/dev/null
grep -F -- '- Runtime: firstmate' "$brief_001" >/dev/null
grep -F -- "- Firstmate report path: $report_001" "$brief_001" >/dev/null

# B. Identity, role, constraints, source boundaries, dependencies, and status survive translation.
grep -F -- '- Crew Order ID: 001' "$brief_001" >/dev/null
grep -F -- "- Mission ID: $slug" "$brief_001" >/dev/null
grep -F -- "- Orbit ID: $orbit_id" "$brief_001" >/dev/null
grep -F -- '- Role: Recorder Analyst' "$brief_001" >/dev/null
grep -F -- '- ORBIT order status: PLANNED' "$brief_001" >/dev/null
grep -F -- 'Verify the synthetic acceptance source structure' "$brief_001" >/dev/null
grep -F -- '`synthetic://acceptance/flight-recorder-structure`' "$brief_001" >/dev/null
grep -F -- 'modifying project files or making scratch commits' "$brief_001" >/dev/null
grep -F -- 'do not edit project files or make scratch commits' "$brief_001" >/dev/null
grep -F -- 'implementation or ship work' "$brief_001" >/dev/null
grep -F -- 'Mission State promotion' "$brief_001" >/dev/null
grep -F -- 'not eligible for promotion to a Firstmate ship task' "$brief_001" >/dev/null
grep -F -- 'None.' "$brief_001" >/dev/null
grep -F -- 'Return synthetic structural findings' "$brief_001" >/dev/null

sed -i 's/synthetic:\/\/acceptance\/flight-recorder-structure/synthetic:\/\/unapproved-source/' \
  "$orbit/crew-orders/001-recorder-analyst.md"
if "$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 001-recorder-analyst.md >"$TMP/changed-order.out" 2>&1; then
  echo 'FAIL: Firstmate adapter submitted a Crew Order changed after preparation' >&2
  exit 1
fi
grep -F 'Crew Order changed after Firstmate preparation' "$TMP/changed-order.out" >/dev/null
cp "$FIXTURE/crew-orders/001-recorder-analyst.md" "$orbit/crew-orders/001-recorder-analyst.md"

"$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 001-recorder-analyst.md >/dev/null
"$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 002-systems-analyst.md >/dev/null
grep -F -- "$task_001 $ROOT --scout" "$ORBIT_FIRSTMATE_HOME/spawn-calls.log" >/dev/null
grep -F -- "$task_002 $ROOT --scout" "$ORBIT_FIRSTMATE_HOME/spawn-calls.log" >/dev/null
if grep -E -- '--mode|--yolo|ship' "$ORBIT_FIRSTMATE_HOME/spawn-calls.log" >/dev/null; then
  echo 'FAIL: ORBIT mapped a scout order to Firstmate ship arguments' >&2
  exit 1
fi

mkdir -p "$(dirname "$report_001")" "$(dirname "$report_002")"
cp "$FIXTURE/reports/001-recorder-analyst.md" "$report_001"
cp "$FIXTURE/reports/002-systems-analyst.md" "$report_002"
printf 'working: synthetic scout started\ndone: synthetic recorder report complete\n' > "$ORBIT_FIRSTMATE_HOME/state/$task_001.status"
printf 'working: synthetic scout started\ndone: synthetic systems report complete\n' > "$ORBIT_FIRSTMATE_HOME/state/$task_002.status"
printf 'kind=scout\nstarted_at=2026-08-10T10:00:00Z\ncompleted_at=2026-08-10T10:01:00Z\n' > "$ORBIT_FIRSTMATE_HOME/state/$task_001.meta"
printf 'kind=scout\nstarted_at=2026-08-10T10:00:30Z\ncompleted_at=2026-08-10T10:02:00Z\n' > "$ORBIT_FIRSTMATE_HOME/state/$task_002.meta"

sed -i 's/kind=scout/kind=implementation/' "$ORBIT_FIRSTMATE_HOME/state/$task_001.meta"
if "$ROOT/bin/orbit" runtime firstmate collect "$slug" "$orbit_id" 001-recorder-analyst.md >"$TMP/non-scout.out" 2>&1; then
  echo 'FAIL: Firstmate adapter accepted a non-scout task report' >&2
  exit 1
fi
grep -F 'metadata does not identify this task as a scout' "$TMP/non-scout.out" >/dev/null
sed -i 's/kind=implementation/kind=scout/' "$ORBIT_FIRSTMATE_HOME/state/$task_001.meta"

"$ROOT/bin/orbit" runtime firstmate collect "$slug" "$orbit_id" 001-recorder-analyst.md >/dev/null
"$ROOT/bin/orbit" runtime firstmate collect "$slug" "$orbit_id" 002-systems-analyst.md >/dev/null
return_001="$orbit/crew-returns/001-recorder-analyst.md"
return_002="$orbit/crew-returns/002-systems-analyst.md"

# C. Completed reports become role-attributed ORBIT Crew Returns.
grep -F -- '- Original Crew Order ID: 001' "$return_001" >/dev/null
grep -F -- '- Role: Recorder Analyst' "$return_001" >/dev/null
grep -F -- '- Runtime: `firstmate`' "$return_001" >/dev/null
grep -F -- "- Firstmate task ID: $task_001" "$return_001" >/dev/null
grep -F -- "- Runtime report path / source: $report_001" "$return_001" >/dev/null
grep -F -- '- Completion state: `COMPLETED`' "$return_001" >/dev/null
grep -F -- '- Execution started at: 2026-08-10T10:00:00Z' "$return_001" >/dev/null
grep -F -- 'The acceptance fixture contains two distinct Crew Order identities' "$return_001" >/dev/null
grep -F -- '- Role: Systems Analyst' "$return_002" >/dev/null

# D. Firstmate completion cannot create GO.
[ "$(cksum "$orbit/gate-log.md")" = "$gate_before" ]
grep -F -- '- Gate authority effect: `NONE`' "$return_001" >/dev/null
grep -F -- 'Only ORBIT Gate Control records valid human authority.' "$return_001" >/dev/null

# E. Firstmate recommendations cannot authorize implementation.
grep -F -- 'Consider an implementation improvement only after ORBIT reconciliation' "$return_002" >/dev/null
grep -F -- '- Implementation authorization: `NONE`' "$return_002" >/dev/null
grep -F -- 'Implementation authorization is absent.' "$return_002" >/dev/null

# F. Reconciliation remains inside ORBIT and Gate Control remains authoritative.
[ "$(cksum "$orbit/reconciliation.md")" = "$reconciliation_before" ]
grep -F -- 'ORBIT owns this reconciliation.' "$orbit/reconciliation.md" >/dev/null
grep -F -- 'Gate Control remains authoritative.' "$orbit/reconciliation.md" >/dev/null

# G. Sequential fallback remains available through the same runtime interface.
sequential_out=$("$ROOT/bin/orbit" runtime sequential prepare "$slug" "$orbit_id" 001-recorder-analyst.md)
printf '%s\n' "$sequential_out" | grep -F 'Runtime: sequential' >/dev/null
printf '%s\n' "$sequential_out" | grep -F 'Task status: READY_FOR_SEQUENTIAL_EXECUTION' >/dev/null
[ -f "$ROOT/runtimes/sequential.md" ]

# H. Legacy v0.3 Crew Order field names and sequential Mission configuration remain compatible.
legacy_slug=legacy-v03-mission
legacy_orbit=2026-08-07
legacy_mission="$ORBIT_HOME/missions/$legacy_slug"
legacy_path="$legacy_mission/orbits/$legacy_orbit"
mkdir -p "$legacy_mission/state" "$legacy_path/crew-orders" "$legacy_path/crew-returns"
printf '# Legacy accepted state\n' > "$legacy_mission/state/current.md"
printf 'execution:\n  mode: sequential\n' > "$legacy_mission/crew.yaml"
cat > "$legacy_path/crew-orders/001-recorder-analyst.md" <<'LEGACY_ORDER'
# Crew Order

- Order ID: 001
- Mission: legacy-v03-mission
- Orbit date: 2026-08-07
- Role: Recorder Analyst
- Status: `PLANNED`

## Objective

Read a bounded synthetic source.

## Allowed inputs

- synthetic source locator

## Explicitly disallowed

- implementation
- external Dispatch
- Mission State promotion

## Required output

Role-attributed findings.

## Dependencies

None.
LEGACY_ORDER
legacy_out=$("$ROOT/bin/orbit" runtime sequential prepare "$legacy_slug" "$legacy_orbit" 001-recorder-analyst.md)
printf '%s\n' "$legacy_out" | grep -F 'Crew Order ID: 001' >/dev/null
printf '%s\n' "$legacy_out" | grep -F 'Runtime: sequential' >/dev/null
grep -F 'mode: sequential' "$legacy_mission/crew.yaml" >/dev/null

v02_slug=legacy-v02-mission
v02_mission="$ORBIT_HOME/missions/$v02_slug"
mkdir -p "$v02_mission/state" "$v02_mission/orbits"
printf '# Legacy v0.2 charter marker\n' > "$v02_mission/charter.md"
printf '# Legacy v0.2 accepted state marker\n' > "$v02_mission/state/current.md"
"$ROOT/bin/orbit" launch "$v02_slug" 2026-08-08 >/dev/null
grep -F 'Legacy v0.2 charter marker' "$v02_mission/charter.md" >/dev/null
grep -F 'Legacy v0.2 accepted state marker' "$v02_mission/state/current.md" >/dev/null
[ -f "$v02_mission/crew.yaml" ]
grep -F 'mode: firstmate' "$v02_mission/crew.yaml" >/dev/null
grep -F 'fallback: sequential' "$v02_mission/crew.yaml" >/dev/null
[ -d "$v02_mission/orbits/2026-08-08/crew-orders" ]
[ -d "$v02_mission/orbits/2026-08-08/crew-returns" ]

echo 'PASS: ORBIT v0.3 Firstmate runtime adapter acceptance tests (A-H)'
