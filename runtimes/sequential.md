# Sequential Runtime Adapter

`sequential` is ORBIT v0.3's reference and fallback execution mode.

It proves the orchestration contract and keeps ORBIT usable when a managed worker runtime is unavailable. It is not the primary managed-worker architecture.

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

## Adapter-neutral handoff

Use `./bin/orbit runtime sequential prepare <mission> <orbit> <order-file>` to validate and expose the same Crew Order identity before executing the bounded pass through `$orbit-analyze`.

A managed adapter may execute independent orders concurrently without changing Crew Order files, Crew Return attribution, or reconciliation semantics.
