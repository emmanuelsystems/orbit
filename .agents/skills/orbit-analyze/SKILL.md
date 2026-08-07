---
name: orbit-analyze
description: Execute an ORBIT v0.3 Mission Control plan by running bounded Crew Orders through the configured runtime, preserving role-attributed returns, reconciling disagreement, applying Gate Control, and preparing the Mission Packet without silently promoting state or dispatching externally.
user-invocable: true
---

# orbit-analyze

## Active context

1. Read `~/.orbit/active-orbit.md` first when it exists.
2. Treat its Mission and Orbit as authoritative.
3. If it is missing, require an explicit Mission and Orbit rather than guessing.

## Required reads

1. `AGENTS.md`
2. `protocols/mission-control.md`
3. `protocols/crew-orchestration.md`
4. `protocols/source-boundary.md`
5. `protocols/reconciliation.md`
6. `protocols/go-no-go.md`
7. `protocols/gate-control.md`
8. `protocols/mission-packet.md`
9. `crews/registry.yaml`
10. `runtimes/README.md`
11. active Mission `charter.md`
12. active Mission `crew.yaml`
13. active Mission `state/current.md`
14. active Orbit `source-index.md`
15. active Orbit `gate-log.md`
16. active Orbit `mission-control-plan.md`
17. active Orbit `crew-orders/`

## Safety gate

Verify the exact primary Flight Recorder is accessible when an active Crew Order requires it. If it is missing, block that order. Do not substitute another transcript.

## Planning gate

Crew Orders must exist before execution.

If `crew-orders/` contains no active orders, stop and invoke or recommend `$orbit-plan` rather than inventing assignments during execution.

## Runtime

Use the Mission `crew.yaml` execution mode.

For v0.3, `sequential` is the reference adapter. Read `runtimes/sequential.md`.

A compatible multi-agent adapter may execute independent orders separately, but it must preserve the same order and return contracts.

## Execute Crew Orders

For each active Crew Order:

1. adopt only the named role,
2. read only allowed inputs plus governing ORBIT safety protocols,
3. respect dependencies,
4. perform the bounded objective,
5. write one role-attributed return under `crew-returns/`,
6. preserve unresolved evidence and uncertainty,
7. never create human authority.

Use matching filenames such as:

```text
crew-orders/001-recorder-analyst.md
crew-returns/001-recorder-analyst.md
```

A later role may read an earlier return only when its Crew Order explicitly allows or requires that dependency.

## Reconcile

After all required Crew Orders complete or are explicitly blocked:

1. read all role returns,
2. populate `crew-findings.md`,
3. populate `reconciliation.md`,
4. preserve material disagreement,
5. compare evidence and authority,
6. use Decision Verifier findings when present,
7. keep ambiguous items `PENDING` or `OBSERVED`.

> **No reconciliation, no Crew conclusion.**

Then populate or update:

- `flight-recorder-analysis.md`
- `decision-action-register.md`

## Gate

Apply only `GO`, `NO_GO`, `PENDING`, or `OBSERVED` under Gate Control.

Crew consensus is not authority. Live valid human directives in `gate-log.md` control active authorization within their scope.

## Flight Plan and Mission Packet

Only GO actions may enter the executable Flight Plan.

Prepare or update:

- `dispatch-return.md`
- `candidate-mission-state.md`
- the complete Mission Packet

Do not promote candidate Mission State without human approval.
Do not perform external Dispatch without separate authorization.

> **No GO, no dispatch.**
