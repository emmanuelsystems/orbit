# Firstmate Runtime Adapter

`firstmate` is ORBIT's managed worker adapter for independent READ_ONLY_SCOUT Crew Orders. ORBIT keeps Mission Control and authority; Firstmate owns worker spawning, isolated execution, task lifecycle, queues, supervision, completion handling, runtime backends, and recovery.

The adapter calls Firstmate's installed `bin/fm-brief.sh --scout`, `bin/fm-spawn.sh --scout`, and read-only `bin/fm-crew-state.sh` task-state surface. It does not copy or reimplement any Firstmate supervision, completion classification, or backend logic.

## Scope

Supported in this phase:

- evidence extraction and analysis,
- independent source-bounded scouting,
- role-attributed reports,
- completed report capture as Crew Returns.

Not supported:

- ship or implementation tasks,
- Flight Planner or Dispatch Agent execution,
- external Dispatch or external writes,
- reconciliation outside ORBIT,
- Gate Control changes,
- Mission State promotion.

An order must declare `Order type: READ_ONLY_SCOUT` and explicitly prohibit project-file/scratch-commit changes, implementation/ship work, Dispatch/external writes, and Mission State promotion. The generated ORBIT hard stop overrides Firstmate's generic scout-laboratory wording: workers may write only the required scout report/status, not project files. The adapter fails closed otherwise.

## Configuration

Private Mission artifacts continue to live under `ORBIT_HOME` (default `~/.orbit`). Firstmate keeps its own operational records in its configured home.

```sh
export ORBIT_FIRSTMATE_ROOT="$HOME/code/firstmate"
# Optional when the operational home differs from the distro root:
export ORBIT_FIRSTMATE_HOME="$HOME/code/firstmate"
# Optional project checkout used by Firstmate to allocate scout worktrees:
export ORBIT_FIRSTMATE_PROJECT="/path/to/orbit"
# Optional explicit backend passed unchanged to Firstmate:
export ORBIT_FIRSTMATE_BACKEND=tmux
```

No backend is selected by ORBIT unless `ORBIT_FIRSTMATE_BACKEND` is set. Firstmate's own configuration and detection therefore remain authoritative. Herdr is optional; ORBIT has no Herdr dependency. tmux remains available through Firstmate.

## Explicit workflow

Before Firstmate analysis, run `./bin/orbit analyze <mission> <orbit>`. It read-only preflights every active order: all required `READ_ONLY_SCOUT` fields must be explicit, and any existing submission binding must be compatible with the immutable order and current Firstmate generation. A stale, incompatible, missing, or already-bound provenance record produces an ORBIT HOLD naming the order and reason. The HOLD does not select sequential, create a Crew Return, reconcile, alter a Mission Packet, or create GO. Sequential runs only when Mission `crew.yaml` explicitly selects it.

For each Crew Order:

```sh
./bin/orbit runtime firstmate prepare \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

`prepare` requires a fresh Firstmate task ID, fingerprints the complete immutable Crew Order, allocates a unique ORBIT submission ID, and asks Firstmate to scaffold a scout brief. The generated brief visibly carries the Crew Order ID, Mission/Orbit IDs, role, objective, allowed sources, prohibited actions, dependencies, expected return contract, task status, submission ID, Firstmate task ID, report path, and order fingerprint.

Inspect that brief, then submit the same mapping:

```sh
./bin/orbit runtime firstmate submit \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

Immediately before launch, ORBIT fails closed if the report or Firstmate task-state artifacts already exist. ORBIT then calls Firstmate's spawn script once with `--scout` and binds the successful submission to Firstmate's exact `endpoint_task_id`, `kind=scout`, and per-launch `busy_gen` metadata. A spawn without that trustworthy generation metadata is not collectable. Firstmate owns everything after launch; ORBIT does not watch terminals, poll workers, manage queues, or recover the task.

After Firstmate's task-state surface reports `done` and the scout report exists:

```sh
./bin/orbit runtime firstmate collect \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

`collect` requires the current Firstmate metadata to match the submitted task generation, snapshots the current report, records its SHA-256, and writes the matching file under the Orbit's `crew-returns/`. The return records role and runtime attribution, ORBIT submission ID, complete Crew Order fingerprint, Firstmate task/generation and report provenance, completion state, timestamps when Firstmate metadata provides them, and the returned findings.

A caller may pass an explicit final task ID when the deterministic ID would collide or exceed Firstmate's task-ID limit. The same ID must be passed to all three actions. Retrying the same logical Crew Order requires a distinct explicit Firstmate task ID; prior briefs, reports, bindings, or task metadata are never reused.

## Authority boundary

A Firstmate report is an external execution result, not an authority event. Capturing it does not edit `gate-log.md`, create implementation authorization, reconcile findings, Dispatch work, or promote Mission State.

After all required returns are captured, Mission Control performs reconciliation inside ORBIT and applies the existing Gate Log. The sequence remains:

```text
Crew Orders -> Firstmate scout reports -> ORBIT Crew Returns
  -> ORBIT reconciliation -> ORBIT Gate Control -> human review
```

> No reconciliation, no Crew conclusion.
>
> No GO, no dispatch.
