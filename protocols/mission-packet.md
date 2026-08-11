# Mission Packet Protocol

The Mission Packet is ORBIT's durable, reviewable artifact for one Orbit.

It is not the raw transcript and it is not a single summary. It is the structured operating packet produced by Mission Control from bounded evidence, Crew findings, human gates, and approved carry-forward state.

## Required packet components

A complete Mission Packet may include:

1. `briefing.md`
2. `source-index.md`
3. `state-snapshot.md`
4. `mission-control-plan.md`
5. `crew-orders/`
6. `crew-returns/`
7. `crew-findings.md`
8. `reconciliation.md`
9. `flight-recorder-analysis.md`
10. `decision-action-register.md`
11. `gate-log.md`
12. `dispatch-return.md`
13. `candidate-mission-state.md`

Not every Mission needs every component, but any omitted component must be intentionally unnecessary rather than silently missing.

## Packet rules

- Raw Flight Recorder content remains a source, not the packet itself.
- Every activated role has a bounded Crew Order and a role-attributed Crew Return or explicit failure state.
- External runtime metadata is execution provenance only; it cannot overwrite Gate Control.
- Crew findings must retain role attribution until ORBIT reconciliation.
- Decision state must preserve authority and provenance.
- GO scope must be explicit.
- External Dispatch is separate from analysis and planning.
- Candidate Mission State remains unpromoted until human review.

## Review-ready packet

A Mission Packet is review-ready when:

- the exact source boundary is visible,
- Mission Control's plan is visible,
- Crew roles and findings are visible,
- material disagreements are preserved,
- consequential items have gate state,
- GO items identify authority and scope,
- actions identify owners or remain explicitly unassigned,
- Dispatch status is visible,
- candidate Mission State is present,
- no private source has been silently copied into tracked distro files.

## Why the packet matters

The Mission Packet is the handoff object between conversation, human review, delegated work, routing, and the next Orbit.

```text
Conversation
  -> Mission Control
  -> Crew work
  -> Gate Control
  -> Mission Packet
  -> Human review
  -> Dispatch / State promotion
  -> Next Orbit
```
