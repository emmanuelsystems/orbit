# ORBIT Lifecycle Protocol

ORBIT has eight stages. Each stage produces a bounded artifact or human outcome that becomes input to the next stage.

## 1. Recover

Read the last accepted `state/current.md` and identify:

- active goals
- active experiments
- open decisions
- NO-GO holds
- commitments
- unfinished actions
- questions carried into this Orbit

Do not recover by rereading all historical Flight Recorders unless Mission State points to a source that must be reopened.

## 2. Brief

Create or update:

- `state-snapshot.md`
- `briefing.md`
- `source-index.md`

The Briefing should answer:

- What changed since the previous Orbit?
- What is blocked?
- What is already GO or NO-GO?
- What remains PENDING?
- What needs discussion now?
- Which sources support those claims?

## 3. Meet

Humans conduct the meeting. Mission Control may prepare context but does not replace human discussion or authority.

## 4. Ingest

Pin the Flight Recorder by exact local path, durable URL, file ID, or another stable locator.

Never substitute another meeting transcript when the intended Flight Recorder is missing.

## 5. Analyze

Default v0.1 mode uses two independent passes.

### Recorder Analyst

Extract:

- discussion themes
- explicit decisions
- proposals
- actions
- owners
- blockers
- holds
- unresolved questions
- commitments
- supporting timestamps or evidence references

### Systems Analyst

Analyze:

- context recovery burden
- duplicated work
- unclear authority
- source gaps
- handoff problems
- automation opportunities
- work that must remain human-owned

The Systems Analyst may recommend changes but cannot convert a recommendation into GO.

## 6. Gate

Apply `protocols/go-no-go.md`.

Classify consequential items as:

- `GO`
- `NO_GO`
- `PENDING`
- `OBSERVED`

Populate:

- `flight-recorder-analysis.md`
- `decision-action-register.md`

## 7. Dispatch

Create `dispatch-return.md`.

Only GO items may enter an executable Flight Plan.

Even then, external writes require the configured permission gate or explicit human authorization.

## 8. Remember

Create `candidate-mission-state.md`.

A human reviews the candidate before anything is promoted into `state/current.md`.

The next Orbit starts from accepted Mission State, not from unreviewed transcript history.
