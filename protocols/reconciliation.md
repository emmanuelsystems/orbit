# ORBIT Reconciliation Protocol

Reconciliation converts independent Crew returns into a reviewable operational record without inventing authority or erasing disagreement.

> **No reconciliation, no Crew conclusion.**

## Inputs

Reconciliation may use:

- Crew Orders
- Crew Returns
- the exact Flight Recorder when needed to resolve a claim
- Mission Charter
- accepted Mission State
- Gate Log
- approved Telemetry inside the source boundary

## Required separation

Keep these distinct:

- direct evidence
- evidence-backed interpretation
- recommendation
- role-attributed finding
- reconciled conclusion
- decision status
- action ownership
- Dispatch authorization

## Reconciliation sequence

1. Confirm which Crew Orders completed, failed, or were blocked.
2. Preserve each role's return before synthesis.
3. Identify agreements.
4. Identify material disagreements.
5. Compare the evidence each role used.
6. Check whether a Decision Verifier return resolves authority or scope questions.
7. Reopen the primary source only where the conflict requires it.
8. Downgrade confidence when evidence remains incomplete.
9. Surface unresolved conflict for human review.
10. Write reconciled conclusions only after the conflict pass is complete.

## Decision register

For each consequential item, record:

- item or decision
- classification: decision / proposal / action / hold / question / observation
- status: GO / NO_GO / PENDING / OBSERVED
- authority
- authority provenance
- GO scope when applicable
- owner when applicable
- evidence
- Crew disagreement when material
- destination when applicable
- release condition for NO-GO holds when known

## Contradictions

If two Crew returns, two sources, or two moments in the same Flight Recorder conflict:

1. preserve the competing claims,
2. preserve their evidence,
3. prefer a later explicit human authority event only when it clearly supersedes the earlier state within the same scope,
4. use Decision Verifier findings as verification, not authorization,
5. otherwise mark the item `PENDING` or `OBSERVED` and surface the contradiction.

## Consensus is not authority

Three agents agreeing that something should happen does not make it GO.

Agent suggestions remain `RECOMMENDATION` and `OBSERVED` or `PENDING` until an authorized human explicitly changes their status.

## Output

Populate `reconciliation.md` before producing the final decision/action register and Mission Packet.
