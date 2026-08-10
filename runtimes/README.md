# ORBIT Runtime Adapters

ORBIT owns Mission/Orbit identity, the Charter, accepted and candidate Mission State, source boundaries, the Crew Registry, Crew Orders and Returns, reconciliation, Gate Control, scoped GO / NO_GO, and the Mission Packet.

A runtime adapter executes bounded Crew Orders and returns role-attributed outputs. Runtime task state is execution provenance; it cannot replace ORBIT authority state.

## Adapter-neutral contract

Every adapter must preserve and expose:

- Crew Order ID
- Mission ID and Orbit ID
- role and objective
- allowed sources and prohibited actions
- dependencies and expected return contract
- runtime task status and runtime-specific task/report identifiers
- one role-attributed Crew Return per completed order
- explicit blocked and failure states

Every adapter must also preserve these invariants:

1. no source-boundary expansion or source substitution,
2. no silent merging before ORBIT reconciliation,
3. no GO or broader GO scope from runtime completion, findings, recommendations, or worker consensus,
4. no external Dispatch without ORBIT Gate Control and the permission gate,
5. no Mission State promotion without human review.

## v0.3 adapters

- `firstmate`: managed READ_ONLY_SCOUT workers with reports captured as ORBIT Crew Returns; see `runtimes/firstmate.md`.
- `sequential`: reference/fallback bounded passes in one capable agent; see `runtimes/sequential.md`.

The thin CLI surface is adapter-neutral:

```sh
./bin/orbit runtime <adapter> <action> <mission-slug> <orbit-id> <order-file> [runtime-task-id]
```

Firstmate implements `prepare`, `submit`, and `collect`. Sequential implements `prepare`; execution and return writing remain inside `$orbit-analyze`. Future runtimes can add actions without changing Crew Order semantics.

ORBIT does not implement process supervision, terminal/session management, watcher logic, wake queues, recovery, or generic delivery mechanics. Those remain runtime responsibilities.
