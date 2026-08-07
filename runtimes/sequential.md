# Sequential Runtime Adapter

`sequential` is ORBIT v0.3's reference execution mode.

It proves the orchestration contract without depending on true sub-agent spawning.

## Execution

1. Read `~/.orbit/active-orbit.md`.
2. Read active `mission-control-plan.md`.
3. Enumerate Crew Orders in lexical order unless dependencies require another order.
4. Execute one order at a time as the named role.
5. Write each return under `crew-returns/` using the same numeric prefix as its order.
6. Do not allow a later role to rewrite an earlier role's return.
7. After all required orders return, run Mission Control reconciliation.

## Separation rule

A single model may execute multiple roles sequentially, but it must treat each Crew Order as a bounded independent pass and keep role outputs separate until reconciliation.

## Failure handling

When an order cannot complete:

- mark that return `FAILED` or `BLOCKED`,
- state the missing dependency/evidence,
- do not fabricate a return,
- allow Mission Control to decide whether remaining independent orders may continue.

## Upgrade path

A multi-agent adapter may later execute independent orders concurrently without changing Crew Order files or reconciliation semantics.
