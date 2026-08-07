# ORBIT Architecture

ORBIT separates the reusable operating system from each user's private meeting data.

```text
ORBIT distro repo
  protocols + templates + skills + scripts

Private ORBIT_HOME
  Mission configuration + accepted Mission State + Orbit artifacts

Agent harness
  Codex first, others possible

Optional orchestration adapter
  Firstmate or another multi-agent supervisor
```

## Data model

```text
Mission
  = one recurring meeting series

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

## Why distro and state are separate

The public repo should be reusable and safe to share. Flight Recorders, live state, and internal decisions are private operational data and stay in a user-controlled `ORBIT_HOME` by default.

## Core execution contract

```text
Mission State
  -> Briefing
  -> Huddle
  -> Flight Recorder
  -> Recorder Analysis + Systems Analysis
  -> GO / NO-GO Gate
  -> Flight Plan
  -> Dispatch
  -> Candidate Mission State
  -> Human review
  -> Accepted Mission State
```

## Execution modes

### Single-agent mode

One capable agent runs independent Recorder and Systems passes, then reconciles them.

### Multi-agent mode

An orchestrator dispatches separate workers for Recorder analysis and Systems analysis, then reconciles their findings.

The GO / NO-GO contract does not change between execution modes.

## Adapter boundary

Adapters translate external systems into or out of the ORBIT lifecycle without changing Mission semantics.

Potential adapters:

- Flight Recorder: local files, Tactiq, Zoom, Google Meet
- agent runtime: Codex, Firstmate
- Dispatch: GitHub, Linear, Slack, Notion

ORBIT core should remain usable with local files and Markdown even when no adapter is installed.
