# ORBIT Reconciliation Protocol

Reconciliation converts analysis into a reviewable operational record without inventing authority.

## Required separation

Keep these distinct:

- direct evidence
- evidence-backed interpretation
- recommendation
- decision status
- action ownership
- Dispatch authorization

## Decision register

For each consequential item, record:

- item or decision
- classification: decision / proposal / action / hold / question / observation
- status: GO / NO_GO / PENDING / OBSERVED
- authority
- owner when applicable
- evidence
- destination when applicable
- release condition for NO-GO holds when known

## Contradictions

If two sources or two moments in the same Flight Recorder conflict:

1. preserve both pieces of evidence,
2. prefer later explicit human authority only when it clearly supersedes the earlier statement,
3. otherwise mark the item PENDING and surface the contradiction.

## Suggestions

Agent suggestions remain `RECOMMENDATION` and `OBSERVED` or `PENDING` until an authorized human explicitly changes their status.
