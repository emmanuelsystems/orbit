# ORBIT Crews

A Crew is a composable set of specialist roles selected by Mission Control for an Orbit.

Crews are execution structures, not authority structures. Crew members may analyze, verify, plan, and recommend. They do not receive human GO authority merely by being activated.

## Core rule

> **No useful independence, no extra agent.**

Mission Control should activate another role only when separate work materially improves evidence quality, speed, specialization, or verification.

## v0.2 standard Crew

The standard huddle Crew contains:

- Recorder Analyst
- Systems Analyst
- Decision Verifier

Pre-Orbit roles are available as contracts for future use:

- State Analyst
- Context Scout

Post-GO roles are planned but remain non-executing by default:

- Flight Planner
- Dispatch Agent

## Runtime independence

The same Crew contract may be executed by:

- one agent running bounded sequential passes,
- a native multi-agent runtime,
- a Firstmate adapter,
- another future runtime adapter.

ORBIT owns role contracts and reconciliation. The runtime only executes the work.
