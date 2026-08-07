---
name: orbit-launch
description: Launch a new Orbit by recovering accepted Mission State, creating a dated Orbit, and drafting a bounded Mission Briefing. Use before a configured recurring meeting or when the user asks to prepare the next meeting cycle.
user-invocable: true
---

# orbit-launch

Read the Mission Charter and accepted `state/current.md`; run `./bin/orbit launch <slug> [date]`; populate `briefing.md` with active goals, experiments, commitments, open actions, GO decisions, NO-GO holds, PENDING decisions, bounded changes, decision questions, and Telemetry gaps; do not read all historical Flight Recorders by default; label missing evidence explicitly; do not Dispatch externally unless explicitly requested and authorized.
