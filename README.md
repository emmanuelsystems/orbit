# ORBIT

**Every meeting closes the loop.**

ORBIT is a local-first operating system for recurring meetings. It turns a repeated meeting into a continuous operating cycle that recovers context, prepares the humans, captures the conversation, separates discussion from authorization, routes only approved work, and carries forward only the state needed for the next cycle.

ORBIT is not a meeting recorder and not just a transcript summarizer. The product is the loop:

```text
MISSION STATE
    -> BRIEFING
    -> HUDDLE
    -> FLIGHT RECORDER
    -> ANALYSIS
    -> GO / NO-GO
    -> FLIGHT PLAN
    -> DISPATCH
    -> UPDATED MISSION STATE
    -> NEXT ORBIT
```

## Status

`v0.1-alpha`

Current scope:

- Codex-first
- local Markdown state
- local `.txt` or `.md` transcripts
- single-agent two-pass analysis
- optional Firstmate orchestration later
- no external writes by default
- no autonomous decision authority
- explicit GO / NO-GO gates

## Core concepts

- **Mission**: one recurring meeting series.
- **Orbit**: one occurrence of that recurring meeting.
- **Commander**: the human ultimately responsible for the Mission.
- **Mission Control**: ORBIT's agent operating layer.
- **Mission Charter**: purpose, cadence, participants, authority, and boundaries.
- **Mission State**: reviewed durable context carried between Orbits.
- **Telemetry**: bounded evidence and supporting sources.
- **Briefing**: pre-meeting preparation.
- **Flight Recorder**: the exact primary meeting transcript.
- **Recorder Analyst**: extracts decisions, actions, owners, and evidence.
- **Systems Analyst**: reviews workflow, friction, handoffs, and opportunities.
- **Flight Plan**: authorized actions resulting from the meeting.
- **Dispatch**: routing GO-authorized work to a destination.
- **Debrief**: review of the completed Orbit.

The governing rule is simple:

> **No GO, no dispatch.**

See `protocols/go-no-go.md`.

## Quick start

Requirements:

- Linux or macOS, or Windows through WSL
- Bash
- Git
- a capable agent harness such as Codex

Clone ORBIT and initialize a Mission:

```sh
git clone https://github.com/YOUR-ORG/orbit.git
cd orbit
./bin/orbit init weekly-leadership "Weekly Leadership Huddle"
```

Private Mission data lives outside the distro repo by default:

```text
~/.orbit/
```

Override it with:

```sh
export ORBIT_HOME=/path/to/private/orbit-home
```

Launch the next Orbit:

```sh
./bin/orbit launch weekly-leadership
```

After the meeting, register its Flight Recorder:

```sh
./bin/orbit ingest weekly-leadership /path/to/transcript.txt
```

Then launch Codex from the ORBIT repo and invoke:

```text
$orbit-analyze
```

Check Mission status:

```sh
./bin/orbit status weekly-leadership
```

Close the Orbit after review:

```sh
./bin/orbit close weekly-leadership
```

`close` validates the packet. It does not silently promote candidate Mission State.

## Public distro vs private state

The cloned repo is the reusable machine:

```text
orbit/
  protocols/
  templates/
  .agents/skills/
  bin/
  examples/
  tests/
```

Private operational data lives in `ORBIT_HOME`:

```text
~/.orbit/
  missions/
    <mission-slug>/
      config.yaml
      charter.md
      state/
      orbits/
      sources/
```

This separation lets ORBIT be shared publicly without publishing private transcripts or meeting state.

## Eight-stage lifecycle

1. **Recover**: load reviewed Mission State.
2. **Brief**: create a bounded Briefing and identify decisions required.
3. **Meet**: humans conduct the actual conversation.
4. **Ingest**: pin the exact Flight Recorder and supporting Telemetry.
5. **Analyze**: run Recorder and Systems analysis independently.
6. **Gate**: classify consequential items as GO, NO-GO, PENDING, or OBSERVED.
7. **Dispatch**: prepare or perform routing only for authorized GO items and only within configured permissions.
8. **Remember**: prepare candidate Mission State for human review and the next Orbit.

## Default artifacts per Orbit

```text
orbits/YYYY-MM-DD/
  source-index.md
  state-snapshot.md
  briefing.md
  flight-recorder-analysis.md
  decision-action-register.md
  dispatch-return.md
  candidate-mission-state.md
```

## Decision model

ORBIT does not treat discussion as authorization.

```text
OBSERVED
  discussed or evidenced, but no decision made

PENDING
  requires a decision from an identified authority

GO
  explicitly approved by an authorized human

NO-GO
  explicitly rejected, paused, or held
```

Only `GO` items may enter an executable Flight Plan, and external Dispatch still requires the configured permission gate.

## Agent execution model

The default v0.1 mode uses one capable agent with two bounded passes:

```text
Flight Recorder
  -> Recorder Analyst: evidence extraction
  -> Systems Analyst: workflow audit
  -> Mission Control reconciliation
  -> GO / NO-GO register
```

A future Firstmate adapter can execute the same contract with separate workers:

```text
Firstmate
  -> Recorder Analyst worker
  -> Systems Analyst worker
  -> reconciled ORBIT packet
```

The Mission lifecycle stays the same regardless of agent runtime.

## Persistent-state rule

The Flight Recorder is history. Mission State is what survives.

```text
Flight Recorder
-> analysis
-> candidate Mission State
-> human review
-> accepted Mission State
```

A transcript never becomes memory merely because it exists.

## Privacy

ORBIT is local-first.

By default:

- transcript bytes stay where the user stores them
- Mission State lives outside the public distro repo
- Dispatch is recommendation-only
- credentials are never stored in tracked files
- external writes require explicit authorization

## Example 001

`examples/systems-shaper-weekly-huddle/` is **Mission 001**, the real prototype that informed ORBIT. It demonstrates a two-person weekly operating huddle while keeping project-specific names and conventions out of the core engine.

## v0.1 success target

A new user should be able to:

1. clone ORBIT,
2. initialize one Mission,
3. launch an Orbit in under 10 minutes,
4. ingest one Flight Recorder,
5. receive a GO / NO-GO decision register and Flight Plan,
6. prepare candidate Mission State,
7. begin the next Orbit without reconstructing the full meeting history.

## License

MIT. See `LICENSE`.
