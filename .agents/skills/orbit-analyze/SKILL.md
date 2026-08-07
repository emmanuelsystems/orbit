---
name: orbit-analyze
description: Analyze the exact Flight Recorder for an ORBIT cycle using independent Recorder and Systems passes, apply the GO / NO-GO protocol, build the Flight Plan, and prepare candidate Mission State without silently promoting it. Use after a Flight Recorder is ingested.
user-invocable: true
---

# orbit-analyze

## Safety gate

1. Read `AGENTS.md`, `protocols/source-boundary.md`, `protocols/reconciliation.md`, `protocols/go-no-go.md`, and the Orbit `source-index.md`.
2. Verify the exact primary Flight Recorder is accessible.
3. If it is missing, stop. Do not substitute another transcript.

## Recorder Analyst

Independently extract main themes, explicit decisions, proposals, actions, explicit owners, blockers / holds, unresolved questions, commitments, and timestamps or evidence references where available.

## Systems Analyst

Independently analyze context recovery burden, duplicated work, unclear authority, Telemetry gaps, handoff problems, automation opportunities, and responsibilities that must remain human-owned.

## GO / NO-GO Gate

Classify consequential items using only `GO`, `NO_GO`, `PENDING`, or `OBSERVED`. Never infer GO.

## Reconcile

Populate `flight-recorder-analysis.md`, `decision-action-register.md`, `dispatch-return.md`, and `candidate-mission-state.md`. Only GO actions may enter the Flight Plan. External Dispatch still requires permission. Do not promote candidate Mission State without human approval.
