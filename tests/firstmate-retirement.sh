#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$ROOT/.tmp/firstmate-retirement"
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
[ "${3:-}" = --scout ] || exit 2
mkdir -p "$FM_HOME/data/$id"
cat > "$FM_HOME/data/$id/brief.md" <<EOF
# Synthetic Firstmate scout
{TASK}
EOF
FAKE_BRIEF

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-spawn.sh" <<'FAKE_SPAWN'
#!/usr/bin/env bash
set -euo pipefail
id=$1
[ "${3:-}" = --scout ] || exit 2
n=0
[ ! -f "$FM_HOME/generation" ] || n=$(cat "$FM_HOME/generation")
n=$((n + 1))
printf '%s\n' "$n" > "$FM_HOME/generation"
cat > "$FM_HOME/state/$id.meta" <<EOF
endpoint_task_id=$id
kind=scout
busy_gen=retire.$n.$id
EOF
printf 'working: synthetic task started\n' > "$FM_HOME/state/$id.status"
FAKE_SPAWN

cat > "$ORBIT_FIRSTMATE_ROOT/bin/fm-crew-state.sh" <<'FAKE_STATE'
#!/usr/bin/env bash
set -euo pipefail
id=$1
last=$(grep -v '^[[:space:]]*$' "$FM_HOME/state/$id.status" | tail -1)
case "$last" in
  done:*) printf 'state: done · source: synthetic-status · %s\n' "${last#done: }" ;;
  failed:*) printf 'state: failed · source: synthetic-status · %s\n' "${last#failed: }" ;;
  blocked:*) printf 'state: blocked · source: synthetic-status · %s\n' "${last#blocked: }" ;;
  paused:*) printf 'state: paused · source: synthetic-status · %s\n' "${last#paused: }" ;;
  *) printf 'state: working · source: synthetic-status · %s\n' "$last" ;;
esac
FAKE_STATE
chmod +x "$ORBIT_FIRSTMATE_ROOT/bin/"*.sh

slug=systems-shaper-weekly-huddle
orbit_id=2026-07-31
mission="$ORBIT_HOME/missions/$slug"
orbit="$mission/orbits/$orbit_id"
mkdir -p "$mission/state" "$orbit/crew-orders" "$orbit/crew-returns"
printf '# Synthetic accepted Mission State\n' > "$mission/state/current.md"
printf 'execution:\n  mode: firstmate\n  fallback: sequential\n' > "$mission/crew.yaml"
printf '# Synthetic source index\n- Status: `PINNED_SYNTHETIC_RETIREMENT`\n' > "$orbit/source-index.md"
cp "$FIXTURE/crew-orders/001-recorder-analyst.md" "$orbit/crew-orders/001-recorder-analyst.md"
cp "$FIXTURE/crew-orders/002-systems-analyst.md" "$orbit/crew-orders/002-systems-analyst.md"
cp "$FIXTURE/gate-log.md" "$orbit/gate-log.md"
cp "$FIXTURE/reconciliation.md" "$orbit/reconciliation.md"
cp "$ROOT/templates/dispatch-return.md" "$orbit/dispatch-return.md"

make_submitted() {
  local order=$1 task=$2 report=$3
  "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" "$order" "$task" >/dev/null
  "$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" "$order" "$task" >/dev/null
  cp "$FIXTURE/reports/$report" "$ORBIT_FIRSTMATE_HOME/data/$task/report.md"
  printf 'working: synthetic task started\ndone: historical report preserved\n' > "$ORBIT_FIRSTMATE_HOME/state/$task.status"
  printf 'started_at=2026-07-31T10:00:00Z\ncompleted_at=2026-07-31T10:01:00Z\n' >> "$ORBIT_FIRSTMATE_HOME/state/$task.meta"
}

recorder_task=orb-20260731-recorder-acceptance
systems_task=orb-20260731-systems-acceptance
make_submitted 001-recorder-analyst.md "$recorder_task" 001-recorder-analyst.md
make_submitted 002-systems-analyst.md "$systems_task" 002-systems-analyst.md
recorder_binding="$orbit/runtime/firstmate/$recorder_task.binding"
systems_binding="$orbit/runtime/firstmate/$systems_task.binding"
recorder_report="$ORBIT_FIRSTMATE_HOME/data/$recorder_task/report.md"
systems_report="$ORBIT_FIRSTMATE_HOME/data/$systems_task/report.md"
recorder_brief="$ORBIT_FIRSTMATE_HOME/data/$recorder_task/brief.md"
systems_brief="$ORBIT_FIRSTMATE_HOME/data/$systems_task/brief.md"
recorder_meta="$ORBIT_FIRSTMATE_HOME/state/$recorder_task.meta"
systems_meta="$ORBIT_FIRSTMATE_HOME/state/$systems_task.meta"
recorder_status="$ORBIT_FIRSTMATE_HOME/state/$recorder_task.status"
systems_status="$ORBIT_FIRSTMATE_HOME/state/$systems_task.status"

# A current binding blocks a duplicate attempt before explicit retirement.
if "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md fresh-before-retire >"$TMP/duplicate-before.out" 2>&1; then
  echo 'FAIL: current historical binding did not block duplicate prepare' >&2
  exit 1
fi
grep -F 'refusing duplicate prepare' "$TMP/duplicate-before.out" >/dev/null

mission_state_before=$(cksum "$mission/state/current.md")
gate_before=$(cksum "$orbit/gate-log.md")
dispatch_before=$(cksum "$orbit/dispatch-return.md")
recorder_binding_before=$(cat "$recorder_binding")
systems_binding_before=$(cat "$systems_binding")
recorder_report_before=$(cksum "$recorder_report")
systems_report_before=$(cksum "$systems_report")
recorder_brief_before=$(cksum "$recorder_brief")
systems_brief_before=$(cksum "$systems_brief")
recorder_meta_before=$(cksum "$recorder_meta")
systems_meta_before=$(cksum "$systems_meta")
recorder_status_before=$(cksum "$recorder_status")
systems_status_before=$(cksum "$systems_status")

# A, B, G, H, I. Retirement is explicit, terminal-state gated, and ORBIT-only.
recorder_retire_out=$("$ROOT/bin/orbit" runtime firstmate retire "$slug" "$orbit_id" 001-recorder-analyst.md "$recorder_task")
systems_retire_out=$("$ROOT/bin/orbit" runtime firstmate retire "$slug" "$orbit_id" 002-systems-analyst.md "$systems_task")
printf '%s\n%s\n' "$recorder_retire_out" "$systems_retire_out" | grep -F 'Binding status: RETIRED' >/dev/null
grep -Fx 'status=RETIRED' "$recorder_binding" >/dev/null
grep -Fx 'status=RETIRED' "$systems_binding" >/dev/null
grep -Fx 'retired_from_status=SUBMITTED' "$recorder_binding" >/dev/null
grep -Fx 'retired_firstmate_state=done' "$recorder_binding" >/dev/null
grep -Fx 'retired_authority=HUMAN_DIRECTIVE' "$recorder_binding" >/dev/null
grep -E '^retired_binding_sha256=[0-9a-f]{64}$' "$recorder_binding" >/dev/null
grep -E '^retired_report_sha256=[0-9a-f]{64}$' "$recorder_binding" >/dev/null
grep -E '^retired_task_sha256=[0-9a-f]{64}$' "$recorder_binding" >/dev/null
# Every original binding field survives; only status is terminalized and retirement provenance is added.
diff -u <(printf '%s\n' "$recorder_binding_before" | grep -v '^status=') <(grep -Ev '^(status|retired_|retirement_)' "$recorder_binding") >/dev/null
diff -u <(printf '%s\n' "$systems_binding_before" | grep -v '^status=') <(grep -Ev '^(status|retired_|retirement_)' "$systems_binding") >/dev/null
[ "$(cksum "$recorder_report")" = "$recorder_report_before" ]
[ "$(cksum "$systems_report")" = "$systems_report_before" ]
[ "$(cksum "$recorder_brief")" = "$recorder_brief_before" ]
[ "$(cksum "$systems_brief")" = "$systems_brief_before" ]
[ "$(cksum "$recorder_meta")" = "$recorder_meta_before" ]
[ "$(cksum "$systems_meta")" = "$systems_meta_before" ]
[ "$(cksum "$recorder_status")" = "$recorder_status_before" ]
[ "$(cksum "$systems_status")" = "$systems_status_before" ]
grep -F "firstmate_task_id=$recorder_task" "$recorder_binding" >/dev/null
grep -F "report_path=$recorder_report" "$recorder_binding" >/dev/null
[ "$(cksum "$mission/state/current.md")" = "$mission_state_before" ]
[ "$(cksum "$orbit/gate-log.md")" = "$gate_before" ]
[ "$(cksum "$orbit/dispatch-return.md")" = "$dispatch_before" ]
printf '%s\n%s\n' "$recorder_retire_out" "$systems_retire_out" | grep -F 'No GO' >/dev/null

# A retired binding must fail closed if its retirement provenance or preserved
# binding/report/task hash is altered before preflight.
retired_binding_backup="$TMP/recorder-retired.binding"
cp "$recorder_binding" "$retired_binding_backup"
assert_retired_preflight_holds() {
  local label=$1
  if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md >"$TMP/retired-$label.out" 2>&1; then
    echo "FAIL: retired preflight accepted altered $label" >&2
    exit 1
  fi
  grep -F 'error:' "$TMP/retired-$label.out" >/dev/null
  cp "$retired_binding_backup" "$recorder_binding"
}
sed -i 's/^retired_authority=.*/retired_authority=FLIGHT_RECORDER/' "$recorder_binding"
assert_retired_preflight_holds authority
sed -i 's/^retired_firstmate_state=.*/retired_firstmate_state=failed/' "$recorder_binding"
assert_retired_preflight_holds state
sed -i 's/^orbit_submission_id=.*/orbit_submission_id=mutated-retirement-submission/' "$recorder_binding"
assert_retired_preflight_holds binding-preservation
sed -i 's/^retired_binding_sha256=.*/retired_binding_sha256=0000000000000000000000000000000000000000000000000000000000000000/' "$recorder_binding"
assert_retired_preflight_holds binding-hash
sed -i 's/^retired_report_sha256=.*/retired_report_sha256=0000000000000000000000000000000000000000000000000000000000000000/' "$recorder_binding"
assert_retired_preflight_holds report-hash
sed -i 's/^retired_task_sha256=.*/retired_task_sha256=0000000000000000000000000000000000000000000000000000000000000000/' "$recorder_binding"
assert_retired_preflight_holds task-hash
report_original=$(cksum "$recorder_report")
printf '\nretired task artifact mutation\n' >> "$recorder_status"
assert_retired_preflight_holds task-artifact
[ "$(cksum "$recorder_status")" != "$recorder_status_before" ]
cp "$retired_binding_backup" "$recorder_binding"
printf '\nretired report artifact mutation\n' >> "$recorder_report"
assert_retired_preflight_holds report-artifact
cp "$retired_binding_backup" "$recorder_binding"
[ "$(cksum "$recorder_report")" != "$report_original" ]
cp "$FIXTURE/reports/001-recorder-analyst.md" "$recorder_report"
printf 'working: synthetic task started\ndone: historical report preserved\n' > "$recorder_status"
[ "$(cksum "$recorder_report")" = "$recorder_report_before" ]

# C. Retired history is a historical preflight result and permits a distinct clean prepare.
retired_preflight=$("$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md)
printf '%s\n' "$retired_preflight" | grep -F 'FIRSTMATE PREFLIGHT: READY_TO_PREPARE' >/dev/null
printf '%s\n' "$retired_preflight" | grep -F 'Historical bindings: RETIRED' >/dev/null
analysis_after_retirement=$("$ROOT/bin/orbit" analyze "$slug" "$orbit_id")
printf '%s\n' "$analysis_after_retirement" | grep -F 'CREW ORDERS READY FOR FIRSTMATE' >/dev/null
fresh_task=recorder-fresh-20260811
fresh_prepare=$("$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md "$fresh_task")
printf '%s\n' "$fresh_prepare" | grep -F "Firstmate task ID: $fresh_task" >/dev/null
[ -f "$orbit/runtime/firstmate/$fresh_task.binding" ]
[ "$(cksum "$recorder_report")" = "$recorder_report_before" ]

# D. The new current binding still blocks duplicate execution.
current_preflight=$("$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 001-recorder-analyst.md)
printf '%s\n' "$current_preflight" | grep -F 'FIRSTMATE PREFLIGHT: READY_TO_SUBMIT' >/dev/null
if "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 001-recorder-analyst.md another-fresh-task >"$TMP/duplicate-current.out" 2>&1; then
  echo 'FAIL: current binding did not block duplicate execution' >&2
  exit 1
fi
grep -F 'refusing duplicate prepare' "$TMP/duplicate-current.out" >/dev/null

# E. An artifact with no authoritative binding still holds.
cp "$FIXTURE/crew-orders/002-systems-analyst.md" "$orbit/crew-orders/003-orphan-order.md"
sed -i 's/Crew Order ID: 002/Crew Order ID: 003/' "$orbit/crew-orders/003-orphan-order.md"
orphan_task=orphan-retirement-artifact
mkdir -p "$ORBIT_FIRSTMATE_HOME/data/$orphan_task"
cat > "$ORBIT_FIRSTMATE_HOME/data/$orphan_task/brief.md" <<EOF
- Crew Order ID: 003
- Mission ID: $slug
- Orbit ID: $orbit_id
EOF
printf 'orphan report\n' > "$ORBIT_FIRSTMATE_HOME/data/$orphan_task/report.md"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 003-orphan-order.md >"$TMP/orphan.out" 2>&1; then
  echo 'FAIL: orphaned Firstmate artifacts passed preflight' >&2
  exit 1
fi
grep -F 'without an authoritative binding' "$TMP/orphan.out" >/dev/null
rm -rf "$orbit/crew-orders/003-orphan-order.md" "$ORBIT_FIRSTMATE_HOME/data/$orphan_task"

# F. A malformed binding remains a hold, not historical cleanup.
cp "$FIXTURE/crew-orders/002-systems-analyst.md" "$orbit/crew-orders/004-malformed-order.md"
sed -i 's/Crew Order ID: 002/Crew Order ID: 004/' "$orbit/crew-orders/004-malformed-order.md"
malformed_task=orb-systems-shaper-weekly-huddle-20260731-004
printf 'crew_order_id=004\nnot-a-binding\n' > "$orbit/runtime/firstmate/$malformed_task.binding"
if "$ROOT/bin/orbit" runtime firstmate preflight "$slug" "$orbit_id" 004-malformed-order.md >"$TMP/malformed.out" 2>&1; then
  echo 'FAIL: malformed Firstmate binding passed preflight' >&2
  exit 1
fi
grep -F 'malformed Firstmate binding' "$TMP/malformed.out" >/dev/null
rm -f "$orbit/crew-orders/004-malformed-order.md" "$orbit/runtime/firstmate/$malformed_task.binding"

# An active task cannot be retired just because a human supplied the command.
cp "$FIXTURE/crew-orders/002-systems-analyst.md" "$orbit/crew-orders/005-active-order.md"
sed -i 's/Crew Order ID: 002/Crew Order ID: 005/' "$orbit/crew-orders/005-active-order.md"
active_task=active-retirement-attempt
"$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" 005-active-order.md "$active_task" >/dev/null
"$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" 005-active-order.md "$active_task" >/dev/null
if "$ROOT/bin/orbit" runtime firstmate retire "$slug" "$orbit_id" 005-active-order.md "$active_task" >"$TMP/active-retire.out" 2>&1; then
  echo 'FAIL: active Firstmate task was retired' >&2
  exit 1
fi
grep -F 'terminal non-active state' "$TMP/active-retire.out" >/dev/null
grep -Fx 'status=SUBMITTED' "$orbit/runtime/firstmate/$active_task.binding" >/dev/null
rm -rf "$orbit/crew-orders/005-active-order.md" "$orbit/runtime/firstmate/$active_task.binding" "$ORBIT_FIRSTMATE_HOME/data/$active_task" "$ORBIT_FIRSTMATE_HOME/state/$active_task.meta" "$ORBIT_FIRSTMATE_HOME/state/$active_task.status"

# A blocked or paused task is not terminalized by this ORBIT operation.
for nonterminal_state in blocked paused; do
  nonterminal_order_id=$([ "$nonterminal_state" = blocked ] && printf '005' || printf '006')
  nonterminal_order="$nonterminal_order_id-$nonterminal_state-order.md"
  cp "$FIXTURE/crew-orders/002-systems-analyst.md" "$orbit/crew-orders/$nonterminal_order"
  sed -i "s/Crew Order ID: 002/Crew Order ID: $nonterminal_order_id/" "$orbit/crew-orders/$nonterminal_order"
  nonterminal_task="${nonterminal_state}-retirement-attempt"
  "$ROOT/bin/orbit" runtime firstmate prepare "$slug" "$orbit_id" "$nonterminal_order" "$nonterminal_task" >/dev/null
  "$ROOT/bin/orbit" runtime firstmate submit "$slug" "$orbit_id" "$nonterminal_order" "$nonterminal_task" >/dev/null
  cp "$FIXTURE/reports/002-systems-analyst.md" "$ORBIT_FIRSTMATE_HOME/data/$nonterminal_task/report.md"
  printf 'working: synthetic task started\n%s: synthetic nonterminal state\n' "$nonterminal_state" > "$ORBIT_FIRSTMATE_HOME/state/$nonterminal_task.status"
  if "$ROOT/bin/orbit" runtime firstmate retire "$slug" "$orbit_id" "$nonterminal_order" "$nonterminal_task" >"$TMP/$nonterminal_state-retire.out" 2>&1; then
    echo "FAIL: $nonterminal_state Firstmate task was retired" >&2
    exit 1
  fi
  grep -F 'terminal non-active state' "$TMP/$nonterminal_state-retire.out" >/dev/null
  grep -Fx 'status=SUBMITTED' "$orbit/runtime/firstmate/$nonterminal_task.binding" >/dev/null
  rm -rf "$orbit/crew-orders/$nonterminal_order" "$orbit/runtime/firstmate/$nonterminal_task.binding" "$ORBIT_FIRSTMATE_HOME/data/$nonterminal_task" "$ORBIT_FIRSTMATE_HOME/state/$nonterminal_task.meta" "$ORBIT_FIRSTMATE_HOME/state/$nonterminal_task.status"
done

[ "$(cksum "$mission/state/current.md")" = "$mission_state_before" ]
[ "$(cksum "$orbit/gate-log.md")" = "$gate_before" ]
[ "$(cksum "$orbit/dispatch-return.md")" = "$dispatch_before" ]

echo 'PASS: ORBIT Firstmate historical binding retirement regressions (A-I)'
