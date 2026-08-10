# Crew Order

- Schema: `orbit-crew-order.v1`
- Crew Order ID:
- Mission ID:
- Orbit ID:
- Role:
- Order type: `READ_ONLY_SCOUT`
- Task status: `PLANNED`

## Objective

## Why this role is needed

## Allowed sources

## Prohibited actions

- modifying project files or making scratch commits
- implementation or ship work
- external Dispatch or external writes
- Mission State promotion
- changing Gate Control or broadening GO scope
- reconciling this return with another Crew Return

## Dependencies

## Expected return contract

Return role-attributed findings with evidence labels, unresolved questions, and confidence where useful.

## Independence contract

This role must produce its own bounded findings. It must not silently adopt another role's conclusion.

## Authority boundary

This role may analyze and recommend. Runtime completion, findings, recommendations, and worker consensus are not human authority and cannot create or broaden GO.

## Completion condition

Return the expected output with evidence labels, unresolved questions, and confidence where useful. Do not implement, Dispatch, reconcile, or promote Mission State.

> No useful independence, no extra agent.
> No reconciliation, no Crew conclusion.
> No GO, no dispatch.
