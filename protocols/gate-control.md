# Gate Control Protocol

Gate Control lets an authorized human issue, revise, or revoke GO / NO-GO decisions during an ORBIT conversation.

A live human directive is not transcript evidence. It is a separate authority event and must preserve provenance.

## Authority event types

Use one of:

- `FLIGHT_RECORDER`
- `HUMAN_DIRECTIVE`
- `HUMAN_REVIEW`

## Required fields

Every live gate event must record:

- item
- status: `GO`, `NO_GO`, `PENDING`, or `OBSERVED`
- authority
- authority source
- scope
- reason when available
- release condition when applicable
- timestamp or ordering marker
- supersedes / superseded-by relationship when revising an earlier gate

## Scope model

A GO is scoped. Supported scopes are:

- `research`
- `planning`
- `implementation`
- `dispatch`

A GO at one scope does not imply GO at another scope.

Examples:

- GO to research a Tactiq adapter does not authorize implementation.
- GO to implement a draft does not authorize external Dispatch.
- GO to prepare Linear issue drafts does not authorize creating the issues.

## Live directive examples

> GO on testing Decision Verifier in the next Orbit. Scope: implementation.

Record as `HUMAN_DIRECTIVE`, not as Flight Recorder evidence.

> NO-GO on automatic Linear creation. GO on preparing drafts for review.

Record two separate gate events with their own scopes.

## Supersession

Never erase an older decision when a human changes direction.

Preserve the audit trail:

```text
GO
  -> superseded by HUMAN_DIRECTIVE
NO_GO
```

The newest valid authority event controls active status within its scope.

## Safety

- Never infer a live GO from enthusiasm or vague agreement.
- Never broaden a human's authority beyond the Mission Charter.
- Never convert a GO into external Dispatch unless the Dispatch scope and permission gate both allow it.
- If authority is unclear, keep the item `PENDING`.
