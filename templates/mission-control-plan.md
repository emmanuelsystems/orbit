# Mission Control Plan

- Mission:
- Orbit date:
- Status: `WAITING_FOR_TRIAGE`

## Objective

## Intake

### Available inputs

### Missing inputs

## Triage

### Work required

### Work not required

### Ambiguity / conflicts

### Human gates likely required

## Crew Selection

| Role | Why separate work is useful | Inputs | Output | Independent? | Runtime tier |
|---|---|---|---|---|---|

## Crew Orders

| Order ID | Role | Objective | Dependencies | Status |
|---|---|---|---|---|

## Execution Graph

Describe which orders can run independently and which must wait for dependencies.

Example:

```text
001 Recorder Analyst ----\
                          -> 003 Decision Verifier -> Reconciliation
002 Systems Analyst -----/
```

## Runtime

- Adapter: `sequential`
- Maximum parallel workers:
- Escalation conditions:

## Stop Conditions

## Human Gates

## Expected Mission Packet

## Notes

> No useful independence, no extra agent.
> No reconciliation, no Crew conclusion.
> No GO, no dispatch.
