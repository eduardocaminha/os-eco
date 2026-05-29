# AI-Readiness Principles for Codebases

A working document distilling the Droid readiness report (82 criteria) into principles, and translating those principles to legacy monoliths and large engineering orgs.

---

## Part 1: The 8 principles behind the 82 criteria

If you cluster the readiness items by what they're trying to prove about a codebase, they collapse into a much smaller set of principles. The 82-item list reads like a checklist, but the underlying claim is a thesis about what makes a repo legible to a non-human collaborator.

**1. Verifiability in seconds, not days.**
Lint, typecheck, test, build, coverage — all runnable with one command, all fast enough to use as an inner loop. ~25 of the 82 items are variations on this. An agent that can't verify its own work either freezes or hallucinates confidence.

**2. The repo describes itself.**
AGENTS.md, README, `.env.example`, single-command setup, documented build commands, architecture docs. The agent should never need tribal knowledge to get from `git clone` to a running test suite. Critically: validate these docs in CI (the `agents_md_validation` item is the key one) or they drift into lies.

**3. Standards are mechanized, not aspirational.**
Anything a style guide says, a linter should enforce. Naming conventions, file size caps, complexity thresholds, dead code, duplication, unused deps — all of these are in the report as *automated checks*, not human review items. Agents will follow rules that fail builds; they will not follow PDFs.

**4. Blast radius is bounded by infrastructure, not by trust.**
Branch protection, PR templates, CODEOWNERS, feature flags, progressive rollout, rollback automation. The assumption is that the agent *will* ship something wrong, so the question is whether that becomes a Slack message or a P0.

**5. Observability closes the loop.**
Structured logs, error tracking with stack traces, metrics, distributed tracing, deployment dashboards. Without these, "did my change work?" becomes a several-day question and the agent has no signal to learn from.

**6. Work arrives in well-scoped units.**
Issue templates, labels, priority/area taxonomy, PR templates. The output quality of an agent is bounded by the input quality of the ticket. Most of "agent isn't reliable" is actually "ticket isn't specific."

**7. Reversibility is everywhere.**
Pinned lockfiles, min release age on deps, release automation that's also rollback automation, immutable artifacts. Reversibility is what makes velocity safe.

**8. Agents are first-class users.**
AGENTS.md, skills, CODEOWNERS that include bots, agent co-authorship in commits, automated PR review, agent-aware secret scanning. The repo acknowledges agents exist and gives them ergonomics, rather than treating them as humans-with-bugs.

### What's missing from the 82-item report

- **Memory / expertise capture across sessions.** No grade for whether learnings from one agent run inform the next (ADRs, decision logs, mulch-style records). Without this, every session reinvents the same context.
- **Spec-first culture.** Grades issue templates but not whether teams write specs before code. The difference between a good and bad implementation is almost entirely upstream of the first tool call.
- **Cost / token observability.** Nothing asks "do you know what your agents cost per task?" This becomes the biggest blocker to scaling agent usage in real companies.
- **Eval suites for the workflow itself.** Teams test their code, not their agent prompts/skills. Drift in agent quality is undetectable without it.

### Frame to take to clients

> An AI-ready codebase is one where (a) any change is verifiable in under 60 seconds, (b) the repo answers its own onboarding questions, (c) every standard is enforced by a machine, (d) every action is reversible, and (e) the team treats agents as users they're designing for, not as junior devs they're managing.

Everything in the 82-item list is a specific instantiation of one of those five. That's a frame a CTO will remember; the 82-item list is a frame their compliance team will run.

---

## Part 2: How Factory itself appears to approach SDLC

Caveat: this is inferred from runtime tooling exposure (tools, skills, system prompts, available subagents), not Factory's internal engineering process. But the *shape* of the tooling is itself a strong opinion:

- **Plan before act.** `TodoWrite`, spec mode (`ExitSpecMode`), and missions all push toward writing the plan as a first-class artifact before any file edit.
- **Specialized droids over a generalist prompt.** Custom droids exist for `worker`, `scrutiny-feature-reviewer`, `user-testing-flow-validator`, plus skills for `review`, `security-review`, `deep-security-review`, `install-qa`, `incident`. The bet is narrow agents > one big prompt.
- **Skills as lazy-loaded capabilities.** Skills aren't always-on context — they activate on demand. Direct response to context-window economics.
- **MCP as the integration boundary.** No lock-in on tools; anything reachable over MCP is fair game (Figma, Sentry, Linear, GitHub, etc.).
- **Sessions as durable artifacts.** `session-navigation` exists as a skill, meaning past work is searchable and resumable, not ephemeral.
- **Documentation is an output of the workflow.** `wiki`, `install-wiki`, `install-code-review`, `install-qa` are "set this up once and it maintains itself."
- **Clarification over guessing.** Structured `AskUser` rather than assumption is embedded in the prompt.
- **Verify before completing.** Don't claim done until lint, typecheck, and tests pass.

The meta-principle: **make the right thing the easy thing for the agent, by encoding workflow into tools rather than into instructions.** Instructions are forgotten; tool affordances are not.

---

## Part 3: Translating to legacy monoliths

The principles don't change, but three patterns dominate everything else.

### 1. Ratcheting beats rewriting

The single most important shift. In greenfield, "100% coverage" or "no files over 500 lines" is achievable. In a 15-year Java monolith with 12,000 files, you'll never get there. Instead: snapshot the current state, write it to a baseline file, and fail CI only on *regressions*. The repo gets monotonically better without anyone authorizing a "cleanup project."

Applies to coverage floors, file size, complexity, dead code, dependency count, even lint rule adoption (allowlist existing violations, block new ones). The legacy equivalent of "verifiable in seconds" — you're not verifying the whole world is clean, you're verifying *this PR didn't make it worse*.

### 2. Slices, not the whole repo

Verifiability in 60 seconds is impossible if your test suite takes 45 minutes. Reframe: agents work on *slices* that can be verified in 60 seconds. Platform work becomes "what's the smallest unit of this monolith I can build, lint, and test in isolation?" Bazel/Nx/Turbo exist largely to enable this. In Java/C# you can usually get there with build module boundaries.

For polyglot monoliths, layer it: each language gets its own AGENTS.md, its own verify command, its own ratchet file. Don't try to unify across languages — the abstraction tax is too high.

### 3. Characterization tests before refactor

The highest-leverage use of agents in a legacy codebase is *writing tests for code that has no tests*, so that future agent edits become safe. Michael Feathers wrote about this 20 years ago for humans; it works even better with agents because they'll patiently write 200 boring test cases. This turns a scary refactor into a routine PR.

### Other legacy-specific shifts

- **Feature flags matter 10x more.** In greenfield you can deploy and revert. In a monolith with a 40-minute deploy and shared state, you can't. Flag infrastructure should come before agent enablement, not after.
- **Tribal knowledge needs to be exfiltrated.** Senior engineers who've been there 8 years are walking AGENTS.md files. Use the agent to *interview* them. This is where memory layers actually pay off, because the cost of forgetting is so high.
- **The agent should read prod, not just code.** Wire up MCP access to Sentry, Datadog, Splunk, the issue tracker, the runbook wiki. Half of any legacy bug fix is "what does this system actually do" — and the answer lives in logs and tickets, not the source.
- **Security/compliance scoping.** Regulated industries can't let an agent touch PII-handling code paths without controls. Get the boundary defined early: which directories are agent-eligible, which require human-in-the-loop, which are off-limits. This is where CODEOWNERS earns its keep.

---

## Part 4: Propagating across large orgs

Here the bottleneck isn't technical, it's organizational.

**Federate, don't centralize.**
You will never get 200 engineers to agree on one toolchain. You can get them to agree on a shared *interface*: every service has an AGENTS.md, every service has a `verify` command that returns nonzero on failure, every service has a `setup` command that gets you from clone to running. What's *inside* that interface can vary by team. The kubernetes pattern applied to dev tooling.

**Champion model over mandates.**
Find one or two engineers per team who already want this. Train them deeply, give them platform team's time, and let them be the local expert. Top-down mandates produce malicious compliance ("we added an AGENTS.md that says 'see Confluence'"). Bottom-up adoption with a shared standard produces real change. Expect 30% of teams to adopt fast, 50% to follow once they see results, and 20% to resist forever — and that's fine.

**Lighthouse projects.**
Pick one service. Make it the showcase. Document the before-and-after. PR cycle time went from 3 days to 4 hours. Time to first commit for new hires went from 2 weeks to 1 day. Production incidents down 40%. Tour it. People copy what works visibly more than what they're told to do.

**Treat agent-readiness as platform engineering.**
At org scale, this needs an owner. Whether it's a 2-person team inside DevEx or a dotted-line group, someone needs to: maintain the shared skills library, maintain the ratchet tooling, run the readiness dashboard, support the champions, lobby for tool budget. Without an owner, it decays.

**Dashboards close the loop.**
The readiness report is the right artifact, scaled out. Run it across every repo, post the scores, let teams compete. Per-team trend lines are more motivating than absolute scores. The dashboard *is* the change-management tool.

**Get security and legal in the room first, not last.**
Agent access to code, secrets, prod data, customer data, and external APIs all need policy. If you skip this, the first incident kills the program. Build the policy with them in the first month.

---

## Part 5: A rough phasing for a 100-person org

- **Month 0–1:** Pick one lighthouse service. Define the shared interface (`AGENTS.md`, `verify`, `setup`). Get security/legal sign-off on agent scope. Stand up the readiness dashboard.
- **Month 1–3:** Get the lighthouse to a Level 4 score. Write up the playbook. Identify champions on 5–10 other teams.
- **Month 3–6:** Champion-led rollout to those 5–10 teams. Ratcheting tooling becomes a shared library. First org-wide skills library lands.
- **Month 6–9:** Open the platform up. Self-serve onboarding. Per-team readiness scoring goes public. First teams start writing custom skills/droids for their domain.
- **Month 9–12:** The boring middle — supporting the laggards, killing dead tooling, measuring outcomes (PR cycle time, incident rate, agent-authored PR acceptance rate).

---

## Part 6: Two honest caveats for clients

**Most "AI readiness" gains in legacy are just "engineering readiness" gains.**
Pre-commit hooks, branch protection, ratcheted coverage, structured logging — these were good ideas in 2015. The AI angle is mostly a forcing function for things teams should have done anyway. That's the easier sell internally: "this isn't a speculative AI bet, it's overdue platform work that also unlocks agents."

**Don't oversell agent autonomy to legacy teams.**
The realistic 12-month outcome for a 15-year monolith isn't "agents ship features end-to-end." It's "agents make engineers 30–50% faster on well-scoped work, and PRs are higher quality because the verify loop is real." Massive win, but requires resetting expectations down from what the demos show.

In greenfield you can get away with no tests because the agent can read everything in context. In legacy, the agent *can't* read everything, so the test suite *is* the agent's memory of how the system should behave. Get that working and most other things follow.

---

## Part 7: The FDE engagement model (working notes)

Realistic engagement length is 3–6 months (contract maxes at a year, but rarely runs that long given the novelty of the role). Full repo access. Typical sequence:

1. **Scouting (weeks 1–3):** Start with the CTO, then work through the engineering org. Identify the "red-pilled" engineers who are already building their own agent systems.
2. **Cohort formation:** The scouted engineers become the local cohort that carries concepts into the org. The FDE doesn't propagate change alone — the cohort does.
3. **Hands-on lift:** Most leverage sits in the IC and Infra axes (see framework below). Org-level change is harder and slower.

### The IC / Infra / Org framework

A diagnostic model placing companies on three axes, each with 5 levels:

- **IC:** how individual engineers use agents
- **Infra:** what the codebase and tooling give agents to work with
- **Org:** how the company structures work, decisions, and ownership around agents

L5 on all three = a self-improving, evolving system that anyone at the company can use to ship to production, and that customers can prompt directly (not just ICs). A handful of companies in the world operate at that level.

Most FDE leverage lands on IC and Infra. Org change is the long pole — requires executive sponsorship, budget shifts, and cultural change that's outside an FDE's direct authority.

---

## Part 8: The IC-level reframe

The core misconception across ICs:

> Treating agents as employees you onboard with documentation, instead of as systems you architect with tools and verification.

The reframe that needs to land:

> Agents are not a hiring problem. They're an environment problem.

ICs ask "how do I tell the agent more clearly?" The shift: "how do I build an environment where it doesn't need to be told?"

### Common IC anti-patterns (observed in the field)

- **Skills graveyards.** Building dozens of skills, each used once, that accumulate as cruft.
- **Docs graveyards.** Massive `.md` collections that go stale immediately and become harder to maintain than the code they describe.
- **Workflow fragmentation.** Every engineer has their own way of interacting with agents — no shared mental model, no shared vocabulary.
- **Prompt perfectionism.** Optimizing prompt wording when the real leverage is in the system around the agent.

All four are symptoms of the same root error: trying to communicate harder rather than removing the need to communicate.

### The conversion moment

What actually shifts IC mindset is not argument but experience — usually some variation of *"I spent 20 hours on a `docs/` directory and it didn't help."* Once an engineer has burned cycles on the wrong knob, the reframe lands instantly. Before that, it bounces.

The FDE's job is to (a) predict that pain out loud so it's named when it happens, and (b) shorten the time-to-realization by showing working examples earlier.

---

## Part 9: A mental model for how agents actually work

Agents operate as a loop:

> read context → propose action → execute → observe → repeat

The model itself is a fixed input. The *quality* of agent output is determined by four surrounding surfaces:

1. **Context** — what the agent can see
2. **Tools** — what the agent can do
3. **Verification** — how the agent knows if it worked
4. **Memory** — what survives across sessions

Most IC effort goes into the prompt. Most of the leverage lives in the four surfaces.

### A vocabulary for failure modes

Naming failure modes gives ICs the ability to diagnose what they're seeing instead of generically blaming "the agent." Working set:

- **Context starvation** — agent can't see what it needs (missing files, missing prod data, no MCP access).
- **Context poisoning** — agent drowns in irrelevant or stale info (always-on `.md` files, oversized prompts).
- **Verification gap** — agent can't tell if it worked (slow tests, no typecheck, no lint, no fast feedback).
- **Tool poverty** — agent can't act on what it knows (no skill for the repeated task, no MCP for the upstream system).
- **Spec drift** — agent solved the wrong problem because the spec was vague (ticket quality, decomposition).
- **Lossy handoff** — next session forgets what this one learned (no memory layer, no ADRs).

Naming these is one of the highest-leverage things to do for a team — once a vocabulary exists, conversations get sharper and triage gets faster.

### The leverage hierarchy

Where ICs should invest their time, from lowest to highest leverage:

1. Prompt phrasing
2. Context curation
3. Tools / skills / MCP
4. Verify loop
5. Specs and decomposition
6. Memory and learning across sessions

Most ICs operate at level 1. The 30–50% productivity gains live in levels 3–5. The point isn't to abandon prompting — it's to know what tier of problem you're solving when you reach for one.

---

## Part 10: What lands and what doesn't (field notes)

**What lands:**
- Lived experience of wasted effort on the wrong abstraction (the docs/ realization).
- Working demos of real systems doing real work — "you don't have to take my word for it."
- Named concepts engineers can use to label problems they've already been encountering.
- Diagnostic charts that let engineers self-locate ("we're L2 on Infra, here's what L3 unlocks") and advocate up.

**What doesn't:**
- Generic best-practices lectures decoupled from their codebase.
- Balanced, neutral framings that avoid taking a position. Polarizing at least once is what separates the cohort from the room.
- Pushing Org-axis change before IC and Infra are real. Cultural change without lived productivity wins reads as overhead.

**The recruiting layer:**
Every IC-facing intervention is also a recruiting event. The FDE's leverage compounds through the cohort, not through individual conversion. Design every presentation, demo, and pairing session as "who in this room is going to carry this forward?" — not as broadcast.
