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

For each Crew Order:

```sh
./bin/orbit runtime firstmate prepare \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

`prepare` validates the immutable order and asks Firstmate to scaffold a scout brief. The generated brief visibly carries the Crew Order ID, Mission/Orbit IDs, role, objective, allowed sources, prohibited actions, dependencies, expected return contract, task status, Firstmate task ID, and report path.

Inspect that brief, then submit the same mapping:

```sh
./bin/orbit runtime firstmate submit \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

ORBIT calls Firstmate's spawn script once with `--scout`. Firstmate owns everything after that launch. ORBIT does not watch terminals, poll workers, manage queues, or recover the task.

After Firstmate's task-state surface reports `done` and the scout report exists:

```sh
./bin/orbit runtime firstmate collect \
  systems-shaper-weekly-huddle 2026-07-31 \
  001-recorder-analyst.md
```

`collect` writes the matching file under the Orbit's `crew-returns/`. The return records role and runtime attribution, Firstmate task/report provenance, completion state, timestamps when Firstmate metadata provides them, and the returned findings.

A caller may pass an explicit final task ID when the deterministic ID would collide or exceed Firstmate's task-ID limit. The same ID must be passed to all three actions.

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
