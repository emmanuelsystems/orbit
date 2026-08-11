# ORBIT

**Every conversation closes the loop.**

ORBIT is a local-first, human-governed orchestration system for recurring conversations and the work they produce.

Meetings are ORBIT's first Mission type, not its permanent boundary.

ORBIT turns conversation into a controlled operating loop:

```text
MISSION STATE
    -> BRIEFING
    -> CONVERSATION
    -> FLIGHT RECORDER / TELEMETRY
    -> MISSION CONTROL
         INTAKE
         TRIAGE
         CREW SELECTION
         CREW ORDERS
         EXECUTION
         RECONCILIATION
    -> GO / NO-GO
    -> FLIGHT PLAN
    -> DISPATCH
    -> UPDATED MISSION STATE
    -> NEXT ORBIT
```

ORBIT is not just a transcript summarizer. It decides what work is required, coordinates the smallest useful Crew, preserves source boundaries and disagreement, enforces human authority, and produces a reviewable Mission Packet.

## Status

`v0.3-alpha` on the Crew Orchestration development branch.

Current scope:

- Codex-first
- local Markdown state
- local `.txt` or `.md` Flight Recorders
- Mission Control intake and triage
- machine-readable Crew Registry
- bounded READ_ONLY_SCOUT Crew Orders
- role-attributed Crew Returns
- Firstmate managed-worker adapter
- sequential reference/fallback adapter
- reconciliation artifact and protocol
- live GO / NO-GO Gate Control
- Mission Packet artifact model
- no external writes by default
- no autonomous decision authority

Firstmate may execute dependency-safe scout orders independently while ORBIT retains reconciliation and authority. ORBIT does not depend on Herdr or any other Firstmate backend.

## Core principles

> **No useful independence, no extra agent.**

Mission Control activates another role only when separate work materially improves evidence quality, specialization, speed, or verification.

> **No reconciliation, no Crew conclusion.**

Crew returns remain role-attributed until Mission Control explicitly checks agreement, conflict, evidence, and authority.

> **No GO, no dispatch.**

Crew consensus, analysis, and recommendations do not create human authorization.

## Core concepts

- **Mission**: a recurring conversation or operating series.
- **Orbit**: one cycle of that Mission.
- **Commander**: the accountable human authority.
- **Mission Control**: ORBIT's router and orchestrator.
- **Mission Charter**: purpose, participants, authority, cadence, and boundaries.
- **Mission State**: reviewed context carried between Orbits.
- **Telemetry**: bounded supporting evidence.
- **Briefing**: pre-conversation preparation.
- **Flight Recorder**: the exact primary conversation record.
- **Crew**: specialist roles available to Mission Control.
- **Crew Registry**: machine-readable role capability contracts.
- **Crew Order**: bounded assignment issued by Mission Control to one role.
- **Crew Return**: role-attributed output for one Crew Order.
- **Reconciliation**: explicit comparison of Crew Returns before a Crew conclusion.
- **Gate Control**: human GO / NO-GO authority layer.
- **Flight Plan**: authorized work resulting from an Orbit.
- **Dispatch**: routing approved work to an external destination.
- **Mission Packet**: the reviewable operating artifact produced by an Orbit.

## Mission Control

The v0.3 control flow is:

```text
INTAKE
  -> TRIAGE
  -> CREW SELECTION
  -> CREW ORDERS
  -> EXECUTION
  -> CREW RETURNS
  -> RECONCILIATION
  -> HUMAN GATE
```

Mission Control answers:

- What just came in?
- What evidence is available?
- What work actually needs to happen?
- Which Crew roles add useful independent work?
- What is each role allowed to read and produce?
- Which orders depend on earlier work?
- Which orders can eventually run in parallel?
- Where do findings conflict?
- Which decisions require human authority?

See `protocols/mission-control.md` and `protocols/crew-orchestration.md`.

## Crew Registry and Crew Orders

The global role registry lives at:

```text
crews/registry.yaml
```

It defines capabilities and boundaries for roles such as:

- Recorder Analyst
- Systems Analyst
- Decision Verifier
- State Analyst
- Context Scout
- Flight Planner
- Dispatch Agent

Mission-local availability and runtime preferences live in:

```text
~/.orbit/missions/<mission>/crew.yaml
```

This Crew Manifest is the single owner of Mission runtime selection. `bin/orbit-analyze` reads `execution.mode`; Mission `config.yaml` does not select a runtime adapter. The default policy is explicit and keeps the sequential route available:

```yaml
execution:
  mode: firstmate
  fallback: sequential
```

Selecting the fallback is an explicit policy change to `mode: sequential`; ORBIT does not perform automatic failover.

Mission Control does not run every available role. `$orbit-plan` first triages the Orbit and issues only the Crew Orders that are justified.

Crew Orders live at:

```text
orbits/YYYY-MM-DD/crew-orders/
```

Crew Returns live at:

```text
orbits/YYYY-MM-DD/crew-returns/
```

## Runtime adapters

ORBIT owns Mission/Orbit identity, source boundaries, Crew semantics, reconciliation, Gate Control, and the Mission Packet. A runtime only executes bounded orders.

`firstmate` is the managed READ_ONLY_SCOUT adapter. It delegates spawning, isolation, task lifecycle, queues, supervision, completion, backends, and recovery to installed Firstmate scripts, then captures completed reports as ORBIT Crew Returns.

`sequential` remains the reference/fallback adapter: one capable agent executes one bounded Crew Order at a time while preserving role separation.

Herdr is optional and owned by Firstmate; ORBIT has no Herdr dependency. tmux remains available through Firstmate.

See `runtimes/README.md`, `runtimes/firstmate.md`, and `runtimes/sequential.md`.

## Reconciliation

A multi-role result is not considered a Crew conclusion until `reconciliation.md` is completed.

Mission Control compares:

- agreements
- material disagreements
- conflicting evidence
- authority conflicts
- missing evidence
- confidence gaps

A Decision Verifier may verify whether evidence supports an authority claim. It does not grant GO.

## GO / NO-GO and Gate Control

Use only:

```text
OBSERVED
PENDING
GO
NO_GO
```

A GO is scoped:

- `research`
- `planning`
- `implementation`
- `dispatch`

GO at one scope never automatically authorizes another.

Gate event provenance remains explicit:

- `FLIGHT_RECORDER`
- `HUMAN_DIRECTIVE`
- `HUMAN_REVIEW`

Superseded decisions remain in the audit trail.

## Mission Packet

A v0.3 Orbit may contain:

```text
orbits/YYYY-MM-DD/
  briefing.md
  source-index.md
  state-snapshot.md
  mission-control-plan.md
  crew-orders/
  crew-returns/
  crew-findings.md
  reconciliation.md
  flight-recorder-analysis.md
  decision-action-register.md
  gate-log.md
  dispatch-return.md
  candidate-mission-state.md
```

The transcript is evidence. The Mission Packet is the operational artifact.

## Quick start

Requirements:

- Linux or macOS, or Windows through WSL
- Bash
- Git
- a capable agent harness such as Pi or Codex
- an installed Firstmate home for managed scout execution, or Mission `crew.yaml` configured for the sequential fallback

Clone and verify:

```sh
git clone https://github.com/emmanuelsystems/orbit.git
cd orbit
./tests/runtime-adapters.sh
./tests/smoke.sh
./bin/orbit --help
```

Initialize a Mission:

```sh
./bin/orbit init weekly-leadership "Weekly Leadership Huddle"
```

Launch an Orbit:

```sh
./bin/orbit launch weekly-leadership 2026-08-07
```

Ingest the exact Flight Recorder:

```sh
./bin/orbit ingest \
  weekly-leadership \
  ~/.orbit/missions/weekly-leadership/sources/flight-recorders/2026-08-07.txt \
  2026-08-07
```

Bind Mission Control planning context:

```sh
./bin/orbit plan weekly-leadership 2026-08-07
```

Then use the configured operator harness:

Pi:

```text
/orbit-plan
```

Codex or another skill-based harness:

```text
$orbit-plan
```

Both forms load the same ORBIT planning behavior.

That step triages the work and creates bounded Crew Orders without executing them.

Inspect readiness:

```sh
./bin/orbit analyze weekly-leadership 2026-08-07
```

The analyze output identifies the configured runtime. For Firstmate, explicitly prepare, inspect, submit, and collect each scout order:

```sh
./bin/orbit runtime firstmate prepare weekly-leadership 2026-08-07 001-recorder-analyst.md
./bin/orbit runtime firstmate submit  weekly-leadership 2026-08-07 001-recorder-analyst.md
# After Firstmate completion:
./bin/orbit runtime firstmate collect weekly-leadership 2026-08-07 001-recorder-analyst.md
```

Then invoke the configured operator command for ORBIT-owned reconciliation, Gate Control, and Mission Packet preparation:

- Pi: `/orbit-analyze`
- Codex or another skill-based harness: `$orbit-analyze`

Missions configured for `sequential` continue to execute bounded fallback passes through the same skill behavior.

For a live human decision:

```sh
./bin/orbit gate weekly-leadership 2026-08-07
```

Then use the configured operator command:

- Pi: `/orbit-gate`
- Codex or another skill-based harness: `$orbit-gate`

Check Mission status:

```sh
./bin/orbit status weekly-leadership
```

Close only after human review:

```sh
./bin/orbit close weekly-leadership 2026-08-07
```

Closing validates the packet. It does not silently promote candidate Mission State.

## Agent skills

User-facing ORBIT commands remain intentionally small.

Pi project commands:

```text
/orbit-launch
/orbit-plan
/orbit-analyze
/orbit-status
/orbit-gate
/orbit-close
```

Codex or another skill-based harness:

```text
$orbit-init
$orbit-launch
$orbit-plan
$orbit-analyze
$orbit-gate
$orbit-status
$orbit-close
```

Both forms use the same ORBIT CLI, skills, runtime adapters, and authority rules.

Crew roles are generally internal to Mission Control rather than commands the user must manually orchestrate.

## Backward compatibility

Existing Missions under `~/.orbit` remain private and are not replaced.

When v0.3 touches an existing Orbit, it creates missing orchestration artifacts such as `reconciliation.md`, `crew-orders/`, and `crew-returns/` without replacing the Mission Charter, accepted Mission State, Flight Recorder, or prior analysis artifacts.

## Persistent-state rule

```text
Flight Recorder
  -> Crew Orders
  -> Crew Returns
  -> Mission Control reconciliation
  -> Gate Control
  -> candidate Mission State
  -> human review
  -> accepted Mission State
```

A transcript never becomes persistent memory merely because it exists.

## Privacy

ORBIT is local-first.

By default:

- private Mission data lives outside the public distro repo,
- transcript bytes remain under user control,
- credentials are never stored in tracked files,
- external writes require explicit authorization,
- candidate state requires human review before promotion.

## Mission 001

`examples/systems-shaper-weekly-huddle/` remains Mission 001 and the first comparison environment for Crew Orchestration.

## Roadmap

### v0.3 Crew Orchestration

- Crew Registry
- dynamic Crew selection through Mission Control triage
- bounded Crew Orders
- role-attributed Crew Returns
- Firstmate READ_ONLY_SCOUT runtime adapter
- sequential reference/fallback adapter
- explicit ORBIT-owned reconciliation
- runtime-independent orchestration contract

### Next runtime milestone

- additional native sub-agent adapters
- broader dependency-safe scheduling policies
- model-tier routing
- subscription-aware cost routing
- escalation rules

### Routing milestone

- Tactiq ingestion adapter
- GitHub adapter
- Linear adapter
- Notion adapter
- Slack adapter
- controlled external Dispatch

## License

MIT. See `LICENSE`.
