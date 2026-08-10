# Crew Orchestration Protocol

ORBIT v0.3 turns Crew roles into bounded work units coordinated by Mission Control.

The goal is not to maximize agent count. The goal is to route the right work to the smallest useful Crew, preserve independent findings, and reconcile them before presenting a Crew conclusion.

## Control flow

```text
INTAKE
  -> TRIAGE
  -> CREW SELECTION
  -> CREW ORDERS
  -> EXECUTION
  -> FINDINGS
  -> RECONCILIATION
  -> HUMAN GATE
```

## Crew selection

Mission Control reads:

1. the Mission Charter,
2. accepted Mission State,
3. Mission `crew.yaml`,
4. the global `crews/registry.yaml`,
5. the current Orbit source boundary,
6. the current Gate Log.

For every proposed role, Mission Control must answer:

- What independent work is this role doing?
- Why can the primary agent not safely absorb that work?
- What inputs is the role allowed to read?
- What output contract must it satisfy?
- What dependencies must complete first?
- What authority is explicitly unavailable to it?

If no useful independence exists, do not add the role.

> **No useful independence, no extra agent.**

## Crew Orders

Each activated role receives a Crew Order stored under:

```text
orbits/YYYY-MM-DD/crew-orders/
```

Crew Orders are immutable intent records for that execution attempt. If the objective materially changes, create a revised order rather than silently changing the prior assignment.

Every order includes:

- Crew Order ID
- Mission ID and Orbit ID
- role and READ_ONLY_SCOUT work type when applicable
- objective and reason selected
- allowed sources
- prohibited actions
- expected return contract
- dependencies
- task status
- authority boundary
- completion condition

## Execution adapters

The Crew contract is runtime-independent.

Supported contract modes:

### Firstmate

Firstmate may assign independent READ_ONLY_SCOUT Crew Orders to separate managed workers. The adapter preserves ORBIT identity and constraints, then captures each completed scout report as a role-attributed Crew Return. Firstmate owns spawning, supervision, completion handling, backends, queues, and recovery; it does not own reconciliation or Gate Control.

### Sequential fallback

One capable agent executes one Crew Order at a time and keeps role outputs separated. This remains the reference/fallback adapter.

### Future adapters

A compatible runtime may assign independent Crew Orders to separate workers. Parallel execution is permitted only when dependencies and source boundaries allow it.

Mission Control owns the plan and Crew semantics. The runtime only executes orders. Runtime task state is provenance and never authority.

## Crew Returns

Each completed order produces one Crew Return using `templates/crew-return.md`. A return preserves the original Crew Order ID, Mission/Orbit identity, role, runtime, runtime task/report provenance, completion state, execution timestamps when available, and returned findings.

Crew findings must remain role-attributed until reconciliation. Do not merge Recorder, Systems, and Verifier findings into a single narrative before conflicts are checked.

## Reconciliation

Mission Control compares:

- agreement
- material disagreement
- evidence conflicts
- authority conflicts
- confidence gaps
- missing evidence

When disagreement is material, preserve it and resolve it through evidence or human review.

> **No reconciliation, no Crew conclusion.**

## Authority

No Crew role can manufacture GO.

A Decision Verifier verifies evidence, authority, and scope. It does not grant authorization.

Only a valid human authority event may create or revise GO / NO-GO state.

> **No GO, no dispatch.**
