---
name: orbit-gate
description: Record or revise a human GO / NO-GO / PENDING decision during an ORBIT conversation with explicit authority, scope, provenance, and supersession history. Use when a human makes or changes a decision mid-Orbit.
user-invocable: true
---

# orbit-gate

## Purpose

Capture a live authority event without pretending it came from the Flight Recorder.

## Resolve the active Mission and Orbit first

Before inferring anything from the user's wording, read the private active Gate Control pointer:

`$ORBIT_HOME/active-gate.md`, where `ORBIT_HOME` defaults to `$HOME/.orbit`.

If that file exists, treat its Mission, Orbit date, Orbit path, and Gate Log as the authoritative current Gate Control context.

Do not reinterpret phrases in the user's directive as a Mission name when an active Gate Control context is present.

If `active-gate.md` is missing, then locate the intended Mission/Orbit from explicit user-provided context. If more than one valid target remains, ask only for the missing Mission or Orbit date rather than guessing.

## Required reads

1. `AGENTS.md`
2. `protocols/go-no-go.md`
3. `protocols/gate-control.md`
4. `$ORBIT_HOME/active-gate.md` when present
5. active Mission `charter.md`
6. active Orbit `gate-log.md`
7. active Orbit `decision-action-register.md` when relevant

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

Append the authority event to the active Orbit `gate-log.md` and update its Active Gate State section.

Do not delete superseded events.

If the event changes a consequential item in `decision-action-register.md`, update that item's active status while preserving prior provenance.

## Safety

- A GO at one scope does not authorize another scope.
- Never broaden the user's authority beyond the Mission Charter.
- Never treat GO as external Dispatch permission unless scope is `dispatch` and the permission gate allows it.
- No GO, no dispatch.
