---
name: orbit-analyze
description: Run ORBIT Mission Control for an ingested Orbit: triage the work, plan the Crew, execute the needed analysis roles, reconcile findings, apply Gate Control, build the Flight Plan, and prepare the Mission Packet without silently promoting state or dispatching externally.
user-invocable: true
---

# orbit-analyze

## Mission Control read order

1. `AGENTS.md`
2. `protocols/mission-control.md`
3. `protocols/source-boundary.md`
4. `protocols/reconciliation.md`
5. `protocols/go-no-go.md`
6. `protocols/gate-control.md`
7. `protocols/mission-packet.md`
8. Mission-local `charter.md`
9. Mission-local `crew.yaml`
10. Mission-local `state/current.md`
11. current Orbit `source-index.md`
12. current Orbit `gate-log.md`

## Safety gate

Verify the exact primary Flight Recorder is accessible. If it is missing, stop. Do not substitute another transcript.

## 1. Intake and triage

Determine what work is actually required. Identify ambiguity, missing evidence, conflicts, authority questions, and likely human gates.

Update `mission-control-plan.md`.

Do not activate another Crew role unless independent work materially improves the Orbit.

> **No useful independence, no extra agent.**

## 2. Plan the Crew

Use the Mission `crew.yaml` as the available Crew contract, not as a requirement to run every role.

For the standard huddle path, consider:

- Recorder Analyst
- Systems Analyst
- Decision Verifier

Run sequentially when only one agent is available. A multi-agent runtime may run independent roles concurrently.

## 3. Execute Crew roles

### Recorder Analyst

Extract themes, explicit decisions, proposals, actions, explicit owners, blockers / holds, unresolved questions, commitments, and evidence references.

### Systems Analyst

Analyze context recovery burden, duplicated work, unclear authority, Telemetry gaps, handoff problems, automation opportunities, and work that should remain human-owned.

### Decision Verifier

Independently check consequential decision claims against the Flight Recorder, Mission Charter, and live Gate Log. Verify authority and scope. When evidence is ambiguous, recommend `PENDING` or `OBSERVED`, not GO.

Write role-attributed findings to `crew-findings.md`.

## 4. Reconcile

Preserve material disagreement. Do not flatten conflicting findings into false certainty.

Populate or update:

- `flight-recorder-analysis.md`
- `decision-action-register.md`
- `crew-findings.md`

## 5. Gate

Apply `GO`, `NO_GO`, `PENDING`, or `OBSERVED` only under the Gate Control rules.

Live human directives in `gate-log.md` supersede older status only within their valid scope.

## 6. Flight Plan and Mission Packet

Only GO actions may enter the executable Flight Plan. External Dispatch still requires permission.

Prepare:

- `dispatch-return.md`
- `candidate-mission-state.md`
- the complete Mission Packet

Do not promote candidate Mission State without human approval.
Do not perform external Dispatch without separate authorization.
