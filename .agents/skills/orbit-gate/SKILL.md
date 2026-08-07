---
name: orbit-gate
description: Record or revise a human GO / NO-GO / PENDING decision during an ORBIT conversation with explicit authority, scope, provenance, and supersession history. Use when a human makes or changes a decision mid-Orbit.
user-invocable: true
---

# orbit-gate

## Purpose

Capture a live authority event without pretending it came from the Flight Recorder.

## Required reads

1. `AGENTS.md`
2. `protocols/go-no-go.md`
3. `protocols/gate-control.md`
4. Mission-local `charter.md`
5. current Orbit `gate-log.md`

## Capture

For the user's directive, identify:

- target item
- status: `GO`, `NO_GO`, `PENDING`, or `OBSERVED`
- human authority
- source: `HUMAN_DIRECTIVE` unless this is final review
- scope: `research`, `planning`, `implementation`, or `dispatch`
- reason when supplied
- release condition for holds when supplied
- whether it supersedes an earlier gate event

If target, authority, or scope is materially ambiguous, ask only for the missing field rather than guessing.

## Write

Append the authority event to the current Orbit `gate-log.md` and update its Active Gate State section.

Do not delete superseded events.

If the event changes a consequential item in `decision-action-register.md`, update that item's active status while preserving prior provenance.

## Safety

- A GO at one scope does not authorize another scope.
- Never broaden the user's authority beyond the Mission Charter.
- Never treat GO as external Dispatch permission unless scope is `dispatch` and the permission gate allows it.
- No GO, no dispatch.
