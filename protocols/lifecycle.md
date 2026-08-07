# ORBIT Lifecycle Protocol

ORBIT is a human-governed orchestration system for recurring conversations and the work they produce.

The lifecycle has ten stages. Mission Control owns triage, planning, orchestration, and reconciliation. Humans retain decision authority.

## 1. Recover

Read the last accepted `state/current.md` and identify active goals, experiments, open decisions, NO-GO holds, commitments, unfinished actions, and questions carried into this Orbit.

Do not recover by rereading all historical Flight Recorders unless Mission State points to a source that must be reopened.

## 2. Brief

Create or update `state-snapshot.md`, `briefing.md`, and `source-index.md`.

The Briefing should answer what changed, what is blocked, what is already GO or NO-GO, what remains PENDING, what needs discussion now, and which sources support those claims.

## 3. Converse

Humans conduct the meeting or other recurring conversation. Mission Control may prepare context but does not replace human discussion or authority.

## 4. Ingest

Pin the exact Flight Recorder or other primary conversation record by stable locator.

Never substitute another conversation record when the intended source is missing.

## 5. Triage

Mission Control evaluates the available inputs and determines what work is actually needed.

Identify evidence extraction, systems analysis, decision verification, contradiction checks, context scouting, planning, or other specialist needs.

Do not activate extra Crew roles without useful independence.

## 6. Plan

Update `mission-control-plan.md` with objective, source boundary, selected Crew roles, execution strategy, dependencies, expected artifacts, human gates, and stop conditions.

The Mission `crew.yaml` defines available roles and runtime policy.

## 7. Orchestrate

Execute selected Crew roles using the available runtime.

The v0.2 default remains sequential execution with one capable agent. Multi-agent runtimes may execute independent roles concurrently as long as they obey the same role contracts.

Standard huddle roles are Recorder Analyst, Systems Analyst, and Decision Verifier.

Write role-attributed results to `crew-findings.md`.

## 8. Reconcile and Gate

Mission Control reconciles Crew findings without hiding disagreement.

Apply `protocols/go-no-go.md` and `protocols/gate-control.md`.

Use only:

- `GO`
- `NO_GO`
- `PENDING`
- `OBSERVED`

Live human directives are recorded separately from Flight Recorder evidence and apply only within their authorized scope.

Populate or update `flight-recorder-analysis.md`, `decision-action-register.md`, and `gate-log.md`.

## 9. Dispatch

Create `dispatch-return.md` and the Flight Plan.

Only GO items may enter executable work. External writes still require the configured permission gate or explicit human authorization.

> **No GO, no dispatch.**

## 10. Remember

Create `candidate-mission-state.md`.

A human reviews the candidate before anything is promoted into `state/current.md`.

The next Orbit starts from accepted Mission State, not unreviewed conversation history.

## Mission Packet

The reviewable artifact for the full Orbit is the Mission Packet defined in `protocols/mission-packet.md`.
