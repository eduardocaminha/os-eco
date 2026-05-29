# After the Software Factory

> Strategy/thinking doc. Captured 2026-05-28. Not a spec, not a commitment —
> a reference for the "what comes after warren-as-factory" direction.

## The question

Warren today is a software factory — a dark factory, even. It turns intent
into merged PRs through sandboxed ephemeral agents: cron triggers, plan-runs
gated on PR merges, self-filed seeds. The org-readiness roadmap (R-09–R-18)
and Colonies (R-20) are all *horizontal scaling of the same machine*. The
question this doc answers is not "how do I make the factory bigger" but
**"what is the next kind of thing."**

Framing constraint locked in discussion: **warren is for me, not a product.**
It's OSS but not *for* other people, and it will stay that way. That lets us
drop the entire org-readiness framing where it's about *other* people (SSO,
multi-tenant, RBAC, product polish). The human-in-the-loop is always me; the
taste oracle is *my* taste; we make opinionated single-operator choices.

## The thesis: from factory to institution

A factory optimizes **throughput of a known-good artifact**. Warren's artifact
is the merged PR; its quality gates (CI, ratchets, review, plan-run merge
checkpoints) all check **correctness**. The "dark" part — cron, plan-runs,
auto-merge — just removes humans from the *execution* floor.

But no layer in the stack checks **whether the work was worth doing.** The
Long-Horizon Agent State loop ends at "PR merges → next agent inherits
memory." Nothing observes whether that PR shipped value, got reverted, moved a
metric, or whether downstream work *built on it* versus *routed around it*.
Warren can execute the wrong roadmap, flawlessly, forever. It is open-loop on
value and closed-loop only on correctness.

That gap names the next jump. A factory executes the order book. An
**institution decides the order book and learns from the market.** The next
jump is the layer the five-layer model is missing:

> **Layer 6 — Judgment / Evaluation:** outcomes feed back into
> intent-formation. The system observes what happened *after* the merge,
> forms taste about what's worth doing, and that taste shapes the next plan.

The headline metric flips from *cost-per-PR* (factory) to
**rate-of-improvement-in-its-own-judgment** (institution).

### The reframe that makes it concrete

The factory amortizes human **labor** across many runs. The institution
amortizes human **taste** across many runs. The substrate is the machine for
it: taste is *captured* cheaply (as curation acts — answering a question,
ratifying an outcome, correcting a distilled intent), *accumulated* durably
(memory, extended with outcome-weighting), and *re-applied* automatically
(prompt derivation + intent-formation priors).

## The chosen direction: substrate-first (Axis B)

Two axes were on the table:

- **Axis A — Autonomy/recursion:** a persistent orchestrator agent that
  proposes and runs work; "warren writes warren."
- **Axis B — Substrate/institution:** flip the primary interface from
  "dispatch a run" to "co-think on a Plot"; the product becomes the
  accumulated decision record + judgment.

**Decision: B is the platform, A is the payload.** Build the value-feedback
substrate first; recursion then becomes a dial you turn up safely, because
agent-proposed intent lands in an auditable substrate gated by the write-ACL.

### What substrate-first actually changes

It dissolves two verbs currently treated as fundamental:

- **The prompt dies.** A Plot holds durable intent (goal / non-goals /
  constraints / success_criteria). A run *derives* its prompt from intent +
  substrate state + priors. The human stops writing prompts and starts
  curating intent and constraints.
- **Dispatch dies.** There's no "dispatch a run" — there's "advance a Plot."
  Manual-dispatch, cron, and plan-run collapse into special cases of one
  **advancement policy** surface. This is where Axis A re-enters safely later:
  an orchestrator is just a policy that proposes the next move *into* the
  ACL-gated substrate.

So the atom is **intent**, not the run. A Plot is the runtime representation
of an intent being pursued; a run is a *move*. Possibly the durable, learnable
thing is the **intent-shape** (a reusable, outcome-weighted template — "this
kind of work, judged this way") and a Plot is an instance.

### The value signal: three tiers

1. **Telemetry (free, noisy, Goodhartable).** PR merged? reverted in 7 days?
   CI stayed green? later work built on it or routed around it? Observable
   from git + the event log, zero human effort. Trap: optimize this and agents
   ship small, safe, reversible, low-value changes.
2. **Human ratification (ground truth).** Mark a Plot outcome
   (success/partial/failure). Seeds already has `sd plan outcome` (storage-only
   today). Make it load-bearing — the supervised label.
3. **Executable success_criteria (the real closed loop).** Make (some) criteria
   into **predicates** warren can re-run after merge. The readiness scorer,
   coverage ratchets, and bundle-size budgets are already exactly this. A Plot
   with no measurable criterion is a Plot you can't learn from.

Position: tier 1 is bait, tier 3 is the real control loop, tier 2 anchors tier
1 against Goodhart.

### Telemetry can stand alone for the low-stakes tier

At ~50k agent events/day, human-only review *is* blind — failure modes
accumulate unseen because the only sensor can't keep up. That inverts the
safety argument: **telemetry-autonomy is a safety instrument, not a risk.**

Governing policy: autonomy is gated by **blast radius × reversibility ×
novelty**, not by importance-in-the-abstract.

- Low-blast / reversible / recurring (e.g. "15 runs hit the same memory gap →
  add the feature") → telemetry detects, agent fixes, no human. The predicate
  is the gate; the fix must make the signal go away.
- High-blast / irreversible / novel (architecture shifts, refactors, anything
  touching *my experience of shipping*) → human ratifies.

Human ratification stays heavily weighted — ~90% of the time, and always the
final say on what gets shipped. But the ratifications **train the autonomy
classifier**: every accept/override labels "this bucket was safe to delegate,"
so the boundary moves outward per-domain, legibly. A telemetry auto-fix is only
safe to run human-free *if a predicate closes the loop* — so executable
criteria are the **license for autonomy**, and the work self-prioritizes:
measurable work earns the right to run dark, unmeasurable work earns attention.

### The authoring surface: a canvas, not a form

Plot intent today is compartmentalized (fill goal / non-goals / constraints /
criteria). That extracts labor *from* the human. Invert which side produces the
structure:

- **Today:** human fills structured fields (input) → warren executes.
- **The jump:** human brain-dumps on a free-form canvas → warren **distills**
  the structure (goal, constraints, candidate predicates) as a derived,
  editable projection → human corrects the distillation → warren executes.

The schema doesn't go away; *producing* it becomes warren's job. The
correction step is gold: **when I fix warren's distillation of my intent, that
correction is a top-tier taste signal** — the canvas is a better sensor for
taste than a form, because it captures the gap between what I said and what I
meant. The distiller is **agent-based** (a built-in role — factory-on-itself).

---

## Technical overview

### What already exists (≈ two-thirds of the substrate)

- **Plot as a coordination object** — `@os-eco/plot-cli` + `src/plot-client/`
  + `src/plots/`: intent, attachments, append-only event log, and verbs
  (`creator`, `intent-editor`, `question-answerer`, `attacher`, `formalize`,
  `status-changer`, `sync`, `pr-merger`).
- **The write-ACL is live** — `HUMANS_ONLY_EVENT_TYPES = [intent_edited,
  status_changed, attachment_removed, question_answered]` in
  `plot-client/types.ts`, pinned to the Plot SPEC at compile time.
- **A primitive value-loop surface** — `src/plots/needs-attention.ts` computes
  a "Needs you" inbox (`paused_run`, `merged_pr_unreviewed`, `stale_draft`),
  aggregated deployment-wide in `aggregate.ts`.
- **Cross-project *read* aggregation** — `PlotAggregator` fans out across every
  `hasPlot=true` project; `PlotResolver` finds a Plot's owning project.
- **Plot ⇄ run wiring** — `runs/spawn/plot-append.ts`,
  `runs/reap/plot-merge.ts`, and `plot-plan-runs/` + `plan-runs/coordinator.ts`
  (serial, merge-gated multi-run — the linear prototype of an advancement
  policy).

Hard limit today: **a Plot belongs to exactly one project's `.plot/`**
(`PlotSummary.project_id`, single-repo index). Cross-project work has to break
this.

### The core inversion (conceptual, no deletion)

The front door stops being `POST /runs` ("dispatch") and becomes "create/advance
a Plot." `POST /runs` and **all of RunDetail's real-time stream + inspection
stay fully intact** as the move-primitive and the transparency surface — they
just stop being the conceptual center. (Non-negotiable: I keep full visibility
into runs, live event streams, manual inspection.)

### 1. UPDATE — extend existing modules

- **Plot intent → executable success criteria** *(cross-repo: `plot-cli`)*.
  Add an optional `predicate` per criterion (command + expected result). The
  single change that turns Layer 6 on. Mirror in `plot-client/types.ts`.
- **New value-loop event types** *(cross-repo: `plot-cli` `PlotEventType`)*:
  `criterion_evaluated` (system/agent), `outcome_ratified` (**human-only** →
  add to `HUMANS_ONLY_EVENT_TYPES`), `intent_proposed` (agent proposes; human
  ratifies into the existing human-only `intent_edited`).
- **`needs-attention.ts` → curation inbox grows.** Add `criterion_failing`,
  `unratified_outcome`, `telemetry_anomaly`. Pure function, trivial to extend
  — this *is* the taste-economizing queue.
- **`runs/spawn/` → prompt derivation.** Plot-moves derive their prompt from
  intent + substrate + priors. Literal-prompt path stays for manual/debug.
- **`runs/reap/` → `criterion_evaluation` sub-step.** Same fire-and-log seam as
  `plot-merge.ts`: re-run predicates post-merge, append `criterion_evaluated`,
  write outcome-weight back to memory. Never gates the run.
- **Memory → outcome-weighting** *(cross-repo: `mulch`)*. Records gain an
  outcome dimension; spawn-time prime surfaces outcome-weighted priors per
  intent-shape.
- **UI** — Plot detail becomes the primary workspace; Runs/RunDetail demoted to
  drill-down but **untouched in capability**.

### 2. ADD — new modules on existing seams

- **The distiller (built-in role + draft flow)** — highest-leverage first
  slice. New built-in in `src/registry/builtins/`. Flow: free-form brain-dump
  → spawn distiller → emits `intent_proposed` (structured intent + candidate
  predicates) → curate → `formalize`. Reuses all run machinery; the output is
  an intent proposal, not a PR.
- **Canvas authoring surface (`src/ui/`)** — the notebook. Starts as a
  free-form doc feeding the distiller and rendering the distilled structure as
  an editable projection.
- **Evaluation module (`src/evaluation/`, new)** — predicate execution,
  outcome-ratification recording, memory outcome-weight writes, the
  **autonomy classifier** (blast-radius × reversibility × novelty), and the
  **telemetry auto-fix tick** (same pattern as `triggers/tick.ts` /
  `plan-runs/coordinator.ts`): cluster recurring failure modes, auto-create +
  dispatch a fix Plot for safe buckets, surface the rest to `needs-attention`.
- **Cross-run telemetry queries (`src/db/repos/`)** — the events table already
  holds the volume; add aggregation to detect recurring failure modes.
- **Advancement-policy abstraction** — generalize `plan-runs/coordinator.ts`:
  manual / cron / plan-run / auto-fix become advancement policies on a Plot.
  Where Axis A re-enters safely.

### 3. BUILD FROM GROUND UP — genuinely new primitives

- **Cross-project Plots (the org-level jump).** Break today's "one Plot, one
  project" assumption. A cross-project Plot = intent + fan-out references to
  per-member sub-Plots; needs a resolver/index above the per-project one, a
  coordinator that dispatches into multiple member repos and gates on
  cross-repo PR merges, and upward event aggregation into a colony-level log
  (extend `aggregate.ts` from read-only display to coordination). **Where the
  substrate lives is an open question — see below.**
- **The autonomy classifier + auto-fix loop.** No existing analog. Failure-mode
  clustering → blast-radius classification → auto-Plot creation for safe
  buckets, trained by ratifications.
- **Intent-shapes as a memory primitive.** If intent is the atom, the durable,
  learnable thing is the intent-shape (reusable, outcome-weighted template).
  Likely a new memory record type. The thing the value loop weights and the
  distiller consults ("Plots like this tend to fail — add a measurable
  criterion").

### Cross-repo dependencies (os-eco siblings)

| Change | Repo | Why |
|---|---|---|
| `success_criteria.predicate` + new event types | `plot` (`plot-cli`) | Layer-6 + value-loop verbs |
| cross-project Plot / index | `plot` or a warren colony layer | break single-repo assumption |
| record outcome-weighting | `mulch` | judgment store |
| (shipped) `cn render --json`, `ml prime --format plain` | canopy / mulch | distiller priors |

### Suggested phase order

1. **Distiller + canvas** (ADD) — shippable now, front door to everything,
   reuses run machinery. Proves the invert.
2. **Executable criteria + reap evaluation sub-step** (UPDATE) — turns on the
   closed loop on value; reuses the ratchet/readiness predicate runner.
3. **`needs-attention` value signals + outcome-ratification verb** (UPDATE) —
   the curation inbox becomes the taste-capture surface.
4. **Telemetry auto-fix loop + autonomy classifier** (ADD/BUILD) — the
   low-stakes dark-running tier; depends on 2 + 3 for predicates and labels.
5. **Cross-project Plots** (BUILD) — the org-level jump; biggest, partly
   cross-repo; lands after the single-project loop is proven.

Throughline: phases 1–4 prove the intent→value loop on a single project;
phase 5 lifts it to "think a thought at os-eco." Almost everything reuses an
existing seam — the genuinely new architecture is cross-project Plots, the
autonomy classifier, and intent-shapes as memory.

---

## Open questions (need more thinking before committing)

1. **Where does cross-project / colony substrate live? (colony-as-repo is NOT
   decided.)** The leading candidate is "a colony is a git repo (the os-eco
   umbrella) holding colony-level `.plot/` / `.seeds/` / `.mulch/`," with the
   colony Plot fanning out into per-member sub-Plots. **Leaning yes, but it
   might be overkill** — keep this open. The alternative (warren's own store
   holds the colony index, members keep their pieces) generalizes to an
   arbitrary class of projects with no shared umbrella, at the cost of moving
   org-truth out of git.

2. **Plot storage: git-only is probably too rigid.** Plots may have to break
   out of the "all data only ever lives in git" principle. Imagined failure:
   reopening a Plot I haven't had agents work on yet and adding a single
   sentence shouldn't open a PR / cause commit churn. Likely shape: a
   **database layer that syncs with git**, where git is the *eventual*,
   durable home (Plots live with the code *eventually*) rather than the *only*
   home. This is a deliberate proposed departure from the current "DB only for
   runtime state, definitions live in git" anchor and needs its own design
   pass — what's authoritative when, when does a sync/commit fire, how do
   edits during active agent work reconcile.

3. **Is there any version of value checkable without a human?** Position:
   tier-2 ratification is permanently load-bearing for shipped/high-stakes
   work; telemetry stands alone only for the low-stakes/recurring bucket.
   Economizing the human verb is the product.

4. **Measurable-vs-prose intent** — forcing success_criteria toward predicates
   disciplines intent but the most valuable work is often the least
   measurable. Resolved-ish: predicates *license autonomy*; unmeasurable work
   routes to human attention. Revisit if it feels like a cage in practice.

5. **Is the atom the Plot or the intent-shape?** Leaning intent-shape as the
   durable memory unit, with a Plot as an instance. Not committed.
