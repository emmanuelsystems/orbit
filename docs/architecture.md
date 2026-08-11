# ORBIT Architecture

ORBIT separates the reusable operating system from each user's private Mission data and from the worker runtime.

```text
ORBIT distro repo
  protocols + templates + skills + thin adapter CLI

Private ORBIT_HOME (default ~/.orbit)
  Mission identity + Charter + accepted Mission State + Orbit artifacts

Firstmate runtime (managed worker route)
  scout spawning + isolated execution + task lifecycle + queues
  + supervision + completion + runtime backends + recovery

Sequential runtime
  reference/fallback bounded passes in one capable agent
```

## Data model

```text
Mission
  = one recurring conversation series

Orbit
  = one occurrence of that Mission
```

One installation may manage multiple Missions:

```text
Mission Control
  -> Mission: Weekly Leadership
       -> Orbit 001
       -> Orbit 002
  -> Mission: Product Review
       -> Orbit 001
```

## Ownership boundary

ORBIT owns:

- Mission and Orbit identity,
- Charter and accepted/candidate Mission State,
- source boundaries,
- Crew Registry, Orders, and Returns,
- reconciliation,
- Gate Control and scoped GO / NO_GO,
- Mission Packet and human review boundaries.

Firstmate owns:

- worker spawning and isolated execution,
- task lifecycle, queues, and supervision,
- completion handling,
- runtime backends and recovery,
- generic delivery mechanics.

ORBIT calls Firstmate's existing scout scripts through `bin/orbit-runtime`. It does not copy Firstmate process supervision, watcher logic, wake queues, tmux/Herdr management, or recovery.

Herdr is an optional Firstmate operator environment, not an ORBIT dependency. tmux remains available through Firstmate. ORBIT does not select a backend unless the operator explicitly configures one.

## Why distro and state are separate

The tracked repo should be reusable and safe to share. Flight Recorders, live state, Crew Orders/Returns, runtime provenance, and internal decisions are private operational data and stay in a user-controlled `ORBIT_HOME` by default.

## Core execution contract

```text
Mission State
  -> Briefing
  -> Conversation
  -> Flight Recorder
  -> Crew Orders
  -> runtime execution
  -> role-attributed Crew Returns
  -> ORBIT reconciliation
  -> ORBIT GO / NO-GO Gate
  -> Flight Plan
  -> Dispatch
  -> Candidate Mission State
  -> Human review
  -> Accepted Mission State
```

## Runtime adapters

### Firstmate

The Firstmate adapter accepts only `READ_ONLY_SCOUT` Crew Orders in this phase. It translates an immutable order into an inspectable scout brief, delegates launch to Firstmate, and captures a completed report as an ORBIT Crew Return.

The translation preserves Crew Order ID, Mission/Orbit IDs, role, objective, source boundary, prohibited actions, dependencies, expected return contract, task status, Firstmate task ID, and report path.

### Sequential fallback

One capable agent runs bounded role passes and writes separate Crew Returns before ORBIT reconciliation. It remains available when Firstmate is not configured and as the reference implementation of the runtime contract.

### Shared invariant

Runtime choice never changes Crew Order semantics or human authority:

- no useful independence, no extra agent,
- no reconciliation, no Crew conclusion,
- no GO, no dispatch.

A completed task, a recommendation, or worker consensus cannot create or broaden GO.

## Adapter boundary

Other adapters can translate external systems into or out of the ORBIT lifecycle without changing Mission semantics.

Potential adapters include:

- Flight Recorder: local files, Tactiq, Zoom, Google Meet,
- agent runtime: Firstmate, sequential, future compatible runtimes,
- Dispatch: GitHub, Linear, Slack, Notion.

ORBIT core remains usable with local files and Markdown. External Dispatch and Mission State promotion are outside the Phase 2 runtime adapter.
