# GO / NO-GO Protocol

The GO / NO-GO model is ORBIT's authority boundary.

Its purpose is to prevent an agent from confusing discussion, recommendation, or momentum with authorization.

> **No GO, no dispatch.**

## Status definitions

### GO

Use `GO` only when all of the following are true:

1. the item is sufficiently specific to act on,
2. an authorized human explicitly approved it,
3. the approving authority is identified,
4. supporting evidence or a direct human confirmation is available,
5. no later evidence in the same Orbit reverses or supersedes the approval.

GO means the direction is authorized. It does not automatically authorize an external write if the Mission's permission policy requires a separate Dispatch approval.

### NO_GO

Use `NO_GO` when an authorized human explicitly:

- rejects the item,
- pauses it,
- places it on hold,
- says not to proceed,
- or establishes a release condition that has not yet been satisfied.

Record the reason and release condition when available.

### PENDING

Use `PENDING` when:

- a decision is required,
- the authority is known or can be identified,
- but explicit approval or rejection is not present.

Questions such as "Should we do this?" normally remain PENDING.

### OBSERVED

Use `OBSERVED` when something was discussed, suggested, demonstrated, or evidenced but no decision request or authorization is established.

OBSERVED is not a weaker GO. It carries no execution authority.

## What does not count as GO

None of these alone establish GO:

- positive language
- agreement with a problem statement
- brainstorming
- "we could"
- "maybe"
- "I like that"
- silence or lack of objection
- an agent recommendation
- an existing draft
- a previous proposal
- a task appearing technically feasible

When uncertain, classify as `PENDING` or `OBSERVED`, never GO.

## Authority

Every GO or NO-GO entry should identify the human authority.

If the Mission Charter does not make the authority clear, do not infer it. Mark the item `PENDING` and surface the authority gap.

## Supersession

Later explicit decisions can supersede earlier ones.

Record both the original and superseding evidence when the change matters to auditability.

## Dispatch gate

An item may be dispatched only when:

```text
status == GO
AND
owner is explicit or assigned by an authorized human
AND
Mission permissions allow the destination/write
```

If any condition is false, Dispatch remains recommendation-only.

## State promotion

GO / NO-GO classifications may be proposed in `candidate-mission-state.md`, but persistent Mission State still requires human review before promotion.
