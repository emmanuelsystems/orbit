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
         PLAN
         ORCHESTRATE
         RECONCILE
    -> GO / NO-GO
    -> FLIGHT PLAN
    -> DISPATCH
    -> UPDATED MISSION STATE
    -> NEXT ORBIT
```

ORBIT is not just a transcript summarizer. Its job is to decide what work is required, coordinate the right specialist roles, preserve evidence and disagreement, enforce human authority, produce a reviewable Mission Packet, and carry forward only approved state.

## Status

`v0.2-alpha` on the Mission Control development branch.

Current scope:

- Codex-first
- local Markdown state
- local `.txt` or `.md` Flight Recorders
- Mission Control triage and planning protocol
- Crew Manifest and specialist role contracts
- Recorder Analyst
- Systems Analyst
- Decision Verifier
- live GO / NO-GO Gate Control
- Mission Packet artifact model
- sequential single-agent execution as the default runtime
- multi-agent execution supported by contract, not yet automatically spawned by the CLI
- optional Firstmate adapter planned
- no external writes by default
- no autonomous decision authority

## Core principles

> **No useful independence, no extra agent.**

Mission Control activates another Crew role only when separate work materially improves evidence quality, specialization, speed, or verification.

> **No GO, no dispatch.**

Analysis, recommendations, and Crew findings do not authorize external action.

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
- **Gate Control**: human GO / NO-GO authority layer.
- **Flight Plan**: authorized work resulting from an Orbit.
- **Dispatch**: routing approved work to an external destination.
- **Mission Packet**: the reviewable operating artifact produced by the Orbit.

## Mission Control

Mission Control is the central v0.2 change.

```text
INTAKE
  -> TRIAGE
  -> PLAN
  -> ORCHESTRATE
  -> RECONCILE
  -> GATE
  -> DISPATCH
  -> REMEMBER
```

Mission Control answers:

- What just came in?
- What evidence is available?
- What work actually needs to happen?
- Which Crew roles are useful?
- Which tasks can be independent or parallel?
- Where is evidence missing or conflicting?
- Which decisions require human authority?
- What may proceed?
- What should become durable Mission State?

See `protocols/mission-control.md`.

## Crews

A Crew defines specialist roles available to Mission Control.

The standard huddle Crew includes:

```text
Mission Control
    |
    +-- Recorder Analyst
    +-- Systems Analyst
    +-- Decision Verifier
```

The Mission-local `crew.yaml` also provides contracts for future State Analyst, Context Scout, Flight Planner, and Dispatch Agent roles.

Crews are runtime-independent. The same role contracts may execute through:

- one capable agent running sequential passes,
- native sub-agents,
- a future Firstmate adapter,
- another multi-agent runtime.

ORBIT owns the work contract. The runtime executes it.

See `crews/README.md` and `crews/roles/`.

## GO / NO-GO and Gate Control

ORBIT does not treat discussion as authorization.

Use only:

```text
OBSERVED
  discussed or evidenced, but no decision exists

PENDING
  a decision is required

GO
  explicitly approved by valid human authority

NO_GO
  explicitly rejected, paused, or held
```

A GO is also scoped:

- `research`
- `planning`
- `implementation`
- `dispatch`

GO to research something does not authorize implementation. GO to implement something does not automatically authorize external Dispatch.

Humans may issue or revise gates during an ORBIT conversation through `$orbit-gate`.

Gate events preserve provenance:

- `FLIGHT_RECORDER`
- `HUMAN_DIRECTIVE`
- `HUMAN_REVIEW`

Superseded decisions remain in the audit trail.

See `protocols/go-no-go.md` and `protocols/gate-control.md`.

## Mission Packet

The durable artifact of an Orbit is the Mission Packet, not the transcript alone.

A complete packet may contain:

```text
orbits/YYYY-MM-DD/
  briefing.md
  source-index.md
  state-snapshot.md
  mission-control-plan.md
  crew-findings.md
  flight-recorder-analysis.md
  decision-action-register.md
  gate-log.md
  dispatch-return.md
  candidate-mission-state.md
```

See `protocols/mission-packet.md`.

## Quick start

Requirements:

- Linux or macOS, or Windows through WSL
- Bash
- Git
- a capable agent harness such as Codex

Clone ORBIT:

```sh
git clone https://github.com/emmanuelsystems/orbit.git
cd orbit
```

Verify the distro:

```sh
./tests/smoke.sh
./bin/orbit --help
```

Initialize a Mission:

```sh
./bin/orbit init weekly-leadership "Weekly Leadership Huddle"
```

Private Mission data lives outside the repo by default:

```text
~/.orbit/
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

Inspect Mission Control readiness:

```sh
./bin/orbit analyze weekly-leadership 2026-08-07
```

Then launch Codex from the ORBIT repo and invoke:

```text
$orbit-analyze
```

During the conversation, record a live human decision with:

```sh
./bin/orbit gate weekly-leadership 2026-08-07
```

Then inside the agent:

```text
$orbit-gate
```

Check Mission status:

```sh
./bin/orbit status weekly-leadership
```

Close after human review:

```sh
./bin/orbit close weekly-leadership 2026-08-07
```

Closing validates the packet. It does not silently promote candidate Mission State.

## Existing v0.1 Missions

v0.2 is designed to be backward-compatible with Missions already under `~/.orbit`.

On the next `orbit launch`, if the Mission does not yet have `crew.yaml`, ORBIT creates the default Crew Manifest without replacing the Mission Charter, accepted Mission State, transcripts, or prior Orbit artifacts.

New Mission Control artifacts are added to the current Orbit only when missing.

Private Flight Recorder bytes remain where the user stored them.

## Agent skills

User-facing ORBIT skills are intentionally small:

```text
$orbit-init
$orbit-launch
$orbit-analyze
$orbit-gate
$orbit-status
$orbit-close
```

Crew roles are generally internal to Mission Control rather than separate commands the user must manually orchestrate.

## Multi-agent direction

v0.2 establishes the contracts required for multi-agent execution but keeps the default execution path simple:

```text
$orbit-analyze
    -> Mission Control triage
    -> select Crew
    -> sequential or multi-agent runtime
    -> role-attributed findings
    -> reconciliation
    -> human Gate Control
```

Automatic sub-agent spawning, parallel runtime adapters, model-tier routing, and subscription-aware cost routing are v0.3 work.

## Persistent-state rule

The Flight Recorder is history. Mission State is what survives.

```text
Flight Recorder
  -> Crew analysis
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
- Dispatch is recommendation-only,
- external writes require explicit authorization,
- candidate state requires human review before promotion.

## Mission 001

`examples/systems-shaper-weekly-huddle/` is Mission 001, the real weekly huddle prototype that informed ORBIT.

It remains the first validation environment while ORBIT expands from a meeting workflow into a reusable conversation router and orchestration system.

## Roadmap

### v0.2 Mission Control

- intake / triage protocol
- planning protocol
- Crew Manifest
- Decision Verifier
- live Gate Control
- Mission Packet
- scoped GO decisions
- runtime-independent Crew contracts

### v0.3 Orchestration

- real sub-agent spawning
- parallel Crew execution
- dynamic Crew selection
- runtime adapters
- Firstmate adapter
- model-tier and cost-aware routing
- escalation rules

### v0.4 Routing

- Tactiq ingestion adapter
- GitHub adapter
- Linear adapter
- Notion adapter
- Slack adapter
- controlled external Dispatch

## License

MIT. See `LICENSE`.
