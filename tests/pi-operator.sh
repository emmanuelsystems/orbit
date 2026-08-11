#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.tmp/pi-operator"
rm -rf "$TMP"
mkdir -p "$TMP"

extension="$ROOT/.pi/extensions/orbit-operator.ts"
[ -f "$extension" ]
cd "$ROOT"

for command in launch plan analyze status gate close; do
  grep -F "orbit-$command" "$extension" >/dev/null
done

if grep -Eq 'fm-spawn|fm-send|fm-watch|orbit runtime firstmate|busy_gen|submission binding' "$extension"; then
  echo 'FAIL: Pi extension duplicates Firstmate lifecycle or provenance logic' >&2
  exit 1
fi

node --experimental-strip-types --check "$extension" >/dev/null

node --experimental-strip-types --input-type=module <<'NODE'
const extension = (await import("./.pi/extensions/orbit-operator.ts")).default;
const commands = new Map();
extension({
  registerCommand(name, options) {
    commands.set(name, options);
  },
});
const expected = ["orbit-launch", "orbit-plan", "orbit-analyze", "orbit-status", "orbit-gate", "orbit-close"];
if (JSON.stringify([...commands.keys()]) !== JSON.stringify(expected)) {
  throw new Error(`unexpected Pi commands: ${JSON.stringify([...commands.keys()])}`);
}
for (const command of expected) {
  if (!commands.get(command)?.description || !commands.get(command)?.handler) {
    throw new Error(`incomplete Pi command: ${command}`);
  }
}
NODE

export ORBIT_HOME="$TMP/home"
export ORBIT_FIRSTMATE_ROOT="$TMP/firstmate-root"
export ORBIT_FIRSTMATE_HOME="$TMP/firstmate-home"
export ORBIT_FIRSTMATE_PROJECT="$ROOT"
mkdir -p "$ORBIT_FIRSTMATE_ROOT/bin" "$ORBIT_FIRSTMATE_HOME/data" "$ORBIT_FIRSTMATE_HOME/state"
for script in fm-brief.sh fm-spawn.sh fm-crew-state.sh; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$ORBIT_FIRSTMATE_ROOT/bin/$script"
  chmod +x "$ORBIT_FIRSTMATE_ROOT/bin/$script"
done
transcript="$TMP/transcript.txt"
printf 'Client: We should review the bounded workflow next week.\n' > "$transcript"
"$ROOT/bin/orbit" init test-mission "Test Mission" >/dev/null
"$ROOT/bin/orbit" launch test-mission 2026-08-10 >/dev/null
"$ROOT/bin/orbit" ingest test-mission "$transcript" 2026-08-10 >/dev/null

before_plan=$(cksum "$ORBIT_HOME/missions/test-mission/orbits/2026-08-10/mission-control-plan.md")
if "$ROOT/bin/orbit" analyze test-mission 2026-08-10 >"$TMP/analyze.out" 2>&1; then
  echo 'FAIL: analyze succeeded without Crew Orders' >&2
  exit 1
fi
grep -F 'NO CREW ORDERS' "$TMP/analyze.out" >/dev/null
grep -F 'Analysis cannot begin because no approved Crew Orders exist for this Orbit.' "$TMP/analyze.out" >/dev/null
grep -F 'Run /orbit-plan first.' "$TMP/analyze.out" >/dev/null
grep -F 'Do not silently generate orders.' "$TMP/analyze.out" >/dev/null
[ "$(cksum "$ORBIT_HOME/missions/test-mission/orbits/2026-08-10/mission-control-plan.md")" = "$before_plan" ]
[ "$(find "$ORBIT_HOME/missions/test-mission/orbits/2026-08-10/crew-orders" -type f | wc -l | tr -d ' ')" = 0 ]

status_before=$(find "$ORBIT_HOME" -type f -print0 | sort -z | xargs -0 cksum)
"$ROOT/bin/orbit" status test-mission >"$TMP/status.out"
status_after=$(find "$ORBIT_HOME" -type f -print0 | sort -z | xargs -0 cksum)
[ "$status_before" = "$status_after" ]
grep -F 'Mission: test-mission' "$TMP/status.out" >/dev/null
grep -F 'Crew Orders: 0' "$TMP/status.out" >/dev/null
grep -F 'Flight Plan: AVAILABLE (decision-action-register.md#Flight Plan)' "$TMP/status.out" >/dev/null
grep -F 'Candidate Mission State: AVAILABLE (candidate-mission-state.md; `candidate_not_promoted`)' "$TMP/status.out" >/dev/null
grep -F 'Active holds: NONE_REPORTED' "$TMP/status.out" >/dev/null

order_dir="$ORBIT_HOME/missions/test-mission/orbits/2026-08-10/crew-orders"
sed -e 's/systems-shaper-weekly-huddle/test-mission/' -e 's/2026-07-31/2026-08-10/' \
  "$ROOT/tests/fixtures/firstmate/crew-orders/001-recorder-analyst.md" > "$order_dir/001-recorder-analyst.md"
before_order=$(cksum "$order_dir/001-recorder-analyst.md")
"$ROOT/bin/orbit" analyze test-mission 2026-08-10 >"$TMP/analyze-ready.out"
grep -F 'Runtime: firstmate' "$TMP/analyze-ready.out" >/dev/null
grep -F 'FLIGHT STATUS: CREW ORDERS READY FOR FIRSTMATE' "$TMP/analyze-ready.out" >/dev/null
[ "$(cksum "$order_dir/001-recorder-analyst.md")" = "$before_order" ]

if grep -F 'bash "$ROOT/bin/orbit-plan"' "$ROOT/bin/orbit-analyze" >/dev/null; then
  echo 'FAIL: orbit-analyze still invokes planning' >&2
  exit 1
fi
grep -F 'fallback: sequential' "$ROOT/templates/crew-manifest.yaml" >/dev/null
grep -F 'sequential' "$ROOT/runtimes/sequential.md" >/dev/null
grep -F 'READ_ONLY_SCOUT' "$ROOT/.agents/skills/orbit-plan/SKILL.md" >/dev/null
grep -F 'expected return contract' "$ROOT/.agents/skills/orbit-plan/SKILL.md" >/dev/null
grep -F 'If target, authority, or scope is materially ambiguous' "$ROOT/.agents/skills/orbit-gate/SKILL.md" >/dev/null
grep -F 'without promoting candidate Mission State automatically' "$ROOT/.agents/skills/orbit-close/SKILL.md" >/dev/null

state_before_close=$(cksum "$ORBIT_HOME/missions/test-mission/state/current.md")
"$ROOT/bin/orbit" gate test-mission 2026-08-10 >/dev/null
"$ROOT/bin/orbit" check test-mission 2026-08-10 >/dev/null
"$ROOT/bin/orbit" close test-mission 2026-08-10 >/dev/null
[ "$(cksum "$ORBIT_HOME/missions/test-mission/state/current.md")" = "$state_before_close" ]

if git -C "$ROOT" ls-files | grep -E '(^|/)(\.orbit|\.env|state/|crew-returns/)' >/dev/null; then
  echo 'FAIL: private ORBIT data is tracked' >&2
  exit 1
fi

echo 'PASS: Pi ORBIT operator flow tests'
