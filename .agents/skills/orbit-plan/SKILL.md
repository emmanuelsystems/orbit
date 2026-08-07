---
name: orbit-plan
description: Triage an active ORBIT Mission/Orbit, select the smallest useful Crew from the Crew Registry, and write bounded Crew Orders before analysis execution. Use after `orbit plan` or before `$orbit-analyze` when Crew work has not yet been planned.
user-invocable: true
---

# orbit-plan

## Context binding

1. Read `~/.orbit/active-orbit.md` first when it exists.
2. Treat its Mission and Orbit as authoritative for this planning run.
3. If it is missing, ask for Mission and Orbit rather than guessing.

## Required reads

1. `AGENTS.md`
2. `protocols/mission-control.md`
3. `protocols/crew-orchestration.md`
4. `protocols/source-boundary.md`
5. `crews/registry.yaml`
6. active Mission `charter.md`
7. active Mission `crew.yaml`
8. active Mission `state/current.md`
9. active Orbit `source-index.md`
10. active Orbit `gate-log.md`
11. active Orbit `mission-control-plan.md`

## Triage

Determine the actual work required for this Orbit before selecting roles.

Identify:

- evidence extraction needs
- systems/workflow analysis needs
- authority verification needs
- contradiction or ambiguity risks
- missing sources
- human gates
- tasks that do not justify an additional role

## Crew selection

Use `crews/registry.yaml` as the role capability contract and Mission `crew.yaml` as the Mission-local availability/configuration contract.

For every activated role, state why separate work materially improves the result.

> **No useful independence, no extra agent.**

Do not activate every available role by default.

## Issue Crew Orders

For each activated role, create a numbered file under the active Orbit `crew-orders/` directory using `templates/crew-order.md`.

Use IDs such as:

- `001-recorder-analyst.md`
- `002-systems-analyst.md`
- `003-decision-verifier.md`

Each order must include:

- exact objective
- why the role is needed
- allowed inputs
- explicitly disallowed work
- required output
- dependencies
- authority boundary
- completion condition

Do not silently rewrite an existing Crew Order. Create a revised order when intent materially changes.

## Update Mission Control Plan

Populate `mission-control-plan.md` with:

- objective
- available/missing inputs
- triage findings
- selected Crew
- execution dependencies
- parallel-capable work
- human gates
- stop conditions
- expected Mission Packet artifacts

Set status to `CREW_ORDERS_READY` when planning is complete.

## Stop

Do not execute Crew Orders as part of `$orbit-plan`.

Planning produces orders. `$orbit-analyze` executes and reconciles them.
