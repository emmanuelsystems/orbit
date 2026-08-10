#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.tmp/smoke"
rm -rf "$TMP"
mkdir -p "$TMP"
export ORBIT_HOME="$TMP/home"
transcript="$TMP/transcript.txt"
printf 'Speaker A: We agreed to test the workflow next week.\n' > "$transcript"
"$ROOT/bin/orbit" init test-mission "Test Mission" >/dev/null
"$ROOT/bin/orbit" launch test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" ingest test-mission "$transcript" 2026-08-07 >/dev/null
"$ROOT/bin/orbit" plan test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" analyze test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" gate test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" check test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" close test-mission 2026-08-07 >/dev/null
mission="$ORBIT_HOME/missions/test-mission"
orbit="$mission/orbits/2026-08-07"
[ -f "$mission/crew.yaml" ]
grep -F 'mode: firstmate' "$mission/crew.yaml" >/dev/null
grep -F 'fallback: sequential' "$mission/crew.yaml" >/dev/null
if grep -Eq 'execution_mode|fallback_execution_mode|(^|[[:space:]])runtime:' "$mission/config.yaml"; then
  echo 'FAIL: generated Mission config duplicates crew.yaml runtime policy' >&2
  exit 1
fi
[ -f "$ORBIT_HOME/active-orbit.md" ]
[ -f "$orbit/source-index.md" ]
[ -f "$orbit/briefing.md" ]
[ -f "$orbit/mission-control-plan.md" ]
[ -f "$orbit/crew-findings.md" ]
[ -f "$orbit/reconciliation.md" ]
[ -f "$orbit/gate-log.md" ]
[ -d "$orbit/crew-orders" ]
[ -d "$orbit/crew-returns" ]
[ -f "$orbit/flight-recorder-analysis.md" ]
[ -f "$orbit/decision-action-register.md" ]
[ -f "$orbit/dispatch-return.md" ]
[ -f "$orbit/candidate-mission-state.md" ]
[ -f "$ROOT/crews/registry.yaml" ]
[ -f "$ROOT/templates/crew-order.md" ]
grep -F "$transcript" "$orbit/source-index.md" >/dev/null
grep -F 'No GO, no dispatch.' "$orbit/decision-action-register.md" >/dev/null
grep -F 'No useful independence, no extra agent.' "$orbit/mission-control-plan.md" >/dev/null
grep -F 'No reconciliation, no Crew conclusion.' "$orbit/reconciliation.md" >/dev/null
grep -F 'Mission: test-mission' "$ORBIT_HOME/active-orbit.md" >/dev/null
if grep -R -F 'We agreed to test the workflow next week.' "$ORBIT_HOME" >/dev/null; then echo 'FAIL: Flight Recorder content leaked into ORBIT_HOME' >&2; exit 1; fi
echo 'PASS: ORBIT v0.3 Crew Orchestration smoke test'
