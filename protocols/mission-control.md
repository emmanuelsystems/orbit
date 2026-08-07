# Mission Control Protocol

Mission Control is ORBIT's router and orchestrator. It does not replace human authority and it does not assume that every incoming conversation needs the same analysis path.

Its job is to turn bounded conversation context into a reviewable Mission Packet by deciding what work is required, which Crew roles should perform it, what can run independently, what must be reconciled, and where human gates are required.

## Core loop

```text
INTAKE
  -> TRIAGE
  -> PLAN
  -> ORCHESTRATE
  -> RECONCILE
  -> GATE
  -> DISPATCH
  -> REMEMBER
```

The recurring meeting lifecycle wraps this control loop with Mission State recovery, Briefing, the human conversation, and Flight Recorder ingestion.

## 1. Intake

Identify the exact inputs available for the current Orbit.

Possible inputs include:

- accepted Mission State
- current Briefing
- exact Flight Recorder
- supporting Telemetry
- direct human directives issued during the ORBIT conversation
- approved external source references

Do not silently expand the source boundary.

## 2. Triage

Determine what kind of work is actually required.

Classify needs such as:

- evidence extraction
- workflow / systems analysis
- decision verification
- contradiction checking
- state recovery
- context scouting
- planning
- routing preparation

Triage should also identify:

- ambiguity
- missing evidence
- conflicting evidence
- unresolved authority
- likely human gates
- work that does not need another agent

## 3. Plan

Write or update `mission-control-plan.md`.

The plan must state:

- objective for this Orbit
- source boundary
- required Crew roles
- execution strategy
- independent work that may run in parallel
- dependencies
- expected artifacts
- human approval gates
- stop conditions

Do not add a Crew member unless independent work materially improves the Orbit.

> **No useful independence, no extra agent.**

## 4. Orchestrate

Execute the plan using the available runtime.

ORBIT v0.2 must remain functional in sequential mode with one capable agent. A multi-agent runtime may execute independent Crew roles concurrently, but the role contracts and outputs must remain the same.

Mission Control may delegate analysis. It may not delegate human authority.

## 5. Reconcile

Combine Crew findings without flattening disagreement.

When findings conflict:

1. preserve both claims,
2. compare their evidence,
3. ask a Decision Verifier when appropriate,
4. downgrade confidence when evidence remains ambiguous,
5. keep the item `PENDING` or `OBSERVED` unless a valid authority event exists.

## 6. Gate

Apply `protocols/go-no-go.md` and `protocols/gate-control.md`.

Consequential items must be one of:

- `GO`
- `NO_GO`
- `PENDING`
- `OBSERVED`

Human directives issued during ORBIT are authority events only within the human's declared scope.

## 7. Dispatch

Only authorized GO items may enter the executable Flight Plan.

External writes remain separately permission-gated.

> **No GO, no dispatch.**

## 8. Remember

Prepare candidate Mission State from reviewed, carry-forward-worthy information only.

Do not promote candidate state without human approval.

## Mission Control output

The output of Mission Control is not merely a summary. It is the Mission Packet for the Orbit.

See `protocols/mission-packet.md`.
