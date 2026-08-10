# Crew Order

- Schema: `orbit-crew-order.v1`
- Crew Order ID: 001
- Mission ID: systems-shaper-weekly-huddle
- Orbit ID: 2026-07-31
- Role: Recorder Analyst
- Order type: `READ_ONLY_SCOUT`
- Task status: `PLANNED`

## Objective

Verify the synthetic acceptance source structure and return role-attributed evidence categories without inferring decisions or authority.

## Why this role is needed

A separate extraction pass preserves independence from workflow recommendations.

## Allowed sources

- current Orbit `source-index.md`
- `synthetic://acceptance/flight-recorder-structure`

## Prohibited actions

- modifying project files or making scratch commits
- implementation or ship work
- external Dispatch or external writes
- Mission State promotion
- changing Gate Control or broadening GO scope
- reconciling this return with another Crew Return

## Dependencies

None.

## Expected return contract

Return synthetic structural findings with evidence labels, unresolved questions, and confidence. Do not claim that any human decision occurred.

## Authority boundary

This role may analyze evidence. It cannot create or broaden GO.
