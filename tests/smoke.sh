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
"$ROOT/bin/orbit" analyze test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" gate test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" check test-mission 2026-08-07 >/dev/null
"$ROOT/bin/orbit" close test-mission 2026-08-07 >/dev/null
mission="$ORBIT_HOME/missions/test-mission"
orbit="$mission/orbits/2026-08-07"
[ -f "$mission/crew.yaml" ]
[ -f "$orbit/source-index.md" ]
[ -f "$orbit/briefing.md" ]
[ -f "$orbit/mission-control-plan.md" ]
[ -f "$orbit/crew-findings.md" ]
[ -f "$orbit/gate-log.md" ]
[ -f "$orbit/flight-recorder-analysis.md" ]
[ -f "$orbit/decision-action-register.md" ]
[ -f "$orbit/dispatch-return.md" ]
[ -f "$orbit/candidate-mission-state.md" ]
grep -F "$transcript" "$orbit/source-index.md" >/dev/null
grep -F 'No GO, no dispatch.' "$orbit/decision-action-register.md" >/dev/null
grep -F 'No useful independence, no extra agent.' "$orbit/mission-control-plan.md" >/dev/null
if grep -R -F 'We agreed to test the workflow next week.' "$ORBIT_HOME" >/dev/null; then echo 'FAIL: Flight Recorder content leaked into ORBIT_HOME' >&2; exit 1; fi
echo 'PASS: ORBIT v0.2 Mission Control smoke test'
