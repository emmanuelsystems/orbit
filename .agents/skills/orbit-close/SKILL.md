---
name: orbit-close
description: Close an ORBIT cycle by verifying the required packet, surfacing unresolved GO / NO-GO gates, and preparing the human review handoff without promoting candidate Mission State automatically.
user-invocable: true
---

# orbit-close

1. Run `./bin/orbit check <slug> [date]`.
2. Review `decision-action-register.md`, `dispatch-return.md`, and `candidate-mission-state.md`.
3. Surface all PENDING authority questions and any GO items lacking an explicit owner or evidence.
4. Confirm that no non-GO item appears in an executable Flight Plan.
5. Run `./bin/orbit close <slug> [date]` only when the packet exists.
6. Report `PENDING HUMAN REVIEW` unless a human has explicitly approved Mission State promotion.
