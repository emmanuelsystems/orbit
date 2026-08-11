# Crew Order

- Schema: `orbit-crew-order.v1`
- Crew Order ID: 002
- Mission ID: systems-shaper-weekly-huddle
- Orbit ID: 2026-07-31
- Role: Systems Analyst
- Order type: `READ_ONLY_SCOUT`
- Task status: `PLANNED`

## Objective

Assess the synthetic handoff structure and return a recommendation while keeping implementation authority unresolved.

## Why this role is needed

An independent systems pass can identify handoff risk without rewriting Recorder Analyst evidence.

## Allowed sources

- current Orbit `source-index.md`
- `synthetic://acceptance/workflow-structure`

## Prohibited actions

- modifying project files or making scratch commits
- implementation or ship work
- external Dispatch or external writes
- Mission State promotion
- changing Gate Control or broadening GO scope
- reconciling this return with another Crew Return

## Dependencies

None. This order is independent of order 001.

## Expected return contract

Return synthetic workflow observations and recommendations with evidence labels, unresolved decisions, and confidence. Recommendations must remain unauthorized.

## Authority boundary

This role may recommend later consideration. It cannot authorize implementation or Dispatch.
