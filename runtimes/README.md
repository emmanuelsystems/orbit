# ORBIT Runtime Adapters

ORBIT owns Mission Control, Crew selection, Crew Orders, reconciliation, Gate Control, and the Mission Packet.

A runtime adapter only executes Crew Orders and returns role-attributed outputs.

## Contract

A runtime adapter must:

1. receive one or more immutable Crew Orders,
2. preserve each role's allowed input boundary,
3. preserve dependencies between orders,
4. return one role-attributed output per order,
5. never create human authority,
6. never silently merge Crew findings before Mission Control reconciliation,
7. surface execution failures explicitly.

## v0.3 adapters

- `sequential`: one capable agent executes Crew Orders one at a time.

## Planned adapters

- `codex_multi_agent`
- `firstmate`
- other compatible local or subscription-backed runtimes

The same Crew Orders must remain valid across adapters.
