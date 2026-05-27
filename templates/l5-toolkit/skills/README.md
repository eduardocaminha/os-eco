# skills/ — `.factory/skills/<name>/SKILL.md` reference

A repo "skill" is a Markdown file with YAML frontmatter that ships with the
repo and tells AI coding agents how to perform a specific procedure inside
it. Skills follow the [open agents.md skill convention][agents-md] — the
file lives at `.factory/skills/<name>/SKILL.md`, the frontmatter declares
what the skill is for, and the body is the procedure.

A single real (non-placeholder) `SKILL.md` is what closes the `skills`
Agent-Readiness criterion. This README is the schema reference and minimal
example; the actual `SKILL.md` lives **inside the target sub-repo**, not
inside the toolkit.

[agents-md]: https://agents.md

## Where SKILL.md lives

In a sub-repo:

```
<<REPO_NAME>>/
└── .factory/
    └── skills/
        └── <skill-name>/
            └── SKILL.md
```

- `<<REPO_NAME>>` — the consuming repo (e.g. `canopy`, `plot`).
- `<skill-name>` — kebab-case identifier. Match the `name` field in
  frontmatter exactly (e.g. directory `plot-coordination/` → frontmatter
  `name: plot-coordination`).

A repo can ship multiple skills; each gets its own `<skill-name>/`
directory. Only one is required to close the rubric criterion, but ship
more whenever a procedure is reused across sessions.

## SKILL.md schema (frontmatter)

The frontmatter is YAML between two `---` fences. Required keys:

| Field | Type | Purpose |
|-------|------|---------|
| `name` | string (kebab-case) | Stable identifier. Must equal the parent directory name. Agents reference the skill by this name. |
| `description` | string (one sentence) | When to invoke this skill. Written so an agent can decide from the description alone whether to load the full body. Keep < 200 chars. |

Optional keys the toolkit understands (extend as the convention evolves):

| Field | Type | Purpose |
|-------|------|---------|
| `tools` | string[] | Tool names the skill expects to be available (e.g. `gh`, `bun`, `sd`). Lets the agent fail fast if any are missing. |
| `inputs` | string[] | Plain-text labels for arguments the agent must collect before running the skill. |
| `outputs` | string[] | What the skill produces (commits, files, comments). |
| `version` | string | Optional semver for the skill itself; bump when the procedure changes meaningfully. |

The body (everything after the closing `---`) is Markdown. Treat it as the
script an agent will execute: numbered steps, code fences for commands,
explicit acceptance criteria at the end.

### Frontmatter style rules

- Use the YAML colon-space form: `name: my-skill`, not `name:my-skill`.
- Quote strings only when they contain colons, leading whitespace, or
  start with a YAML-significant character.
- Keep the frontmatter under ~10 lines. Push detail into the body.

## Minimal example

The file below is a real, runnable example — copy it as a starting point.
For a sub-repo named `<<REPO_NAME>>`, drop it at
`.factory/skills/<<REPO_NAME>>-onboard/SKILL.md`:

```markdown
---
name: <<REPO_NAME>>-onboard
description: Walk a new agent through priming context, finding unblocked work, and running the quality gates in <<REPO_NAME>>.
tools:
  - bun
  - git
  - sd
inputs:
  - issue-id (optional)
outputs:
  - commit on <<REPO_NAME>>/main
  - closed issue (if issue-id provided)
---

# <<REPO_NAME>>-onboard

Use this skill when you are an agent starting work in `<<REPO_NAME>>` for
the first time in a session.

## Procedure

1. **Prime context.** Read `AGENTS.md`, `RUNBOOK.md`, and the latest
   `CHANGELOG.md` entry. Note the repo's tracker prefix and CLI name.
2. **Find unblocked work.** Run `sd ready` (Seeds) or `gh issue list`
   to pick a task. If an `issue-id` was supplied, claim that:
   `sd update <id> --status in_progress`.
3. **Make focused changes.** One concern per commit. Preserve existing
   conventions: kebab-case filenames, strict TypeScript, no `any`.
4. **Run gates.** All four must exit 0 before committing:
   ```bash
   bun run lint
   bun run typecheck
   bun test
   bun run check:all
   ```
5. **Pin debt markers.** Any new `TODO` / `FIXME` carries a tracker
   reference (`<<REPO_NAME>>-XXXX`, `mx-XXXX`, `#NNN`, or a URL).
6. **Commit.** `<area>: <summary>` format. Do not push unless the user
   asks; leave the commit local.
7. **Close the issue** if one was claimed: `sd close <id>`.

## Acceptance

- `bun run check:all` exits 0.
- `git log -1` shows your single, focused commit on `main`.
- `git status` is clean.
- If an issue was claimed, it is closed and synced.
```

That's it. Frontmatter, a one-paragraph "when to use this," numbered
procedure, explicit acceptance. Keep the body under ~150 lines; if it's
growing past that, split into multiple skills.

## Porting checklist

When porting the toolkit into `<<REPO_NAME>>`, the worker creates the
skill in three steps:

1. **Pick a skill name.** Reach for the most distinctive procedure the
   repo benefits from documenting — e.g. `plot-coordination` for plot,
   `canopy-prompt-edit` for canopy, `mulch-record` for mulch. Avoid
   generic names like `setup` or `dev`.
2. **Create the directory + file.**
   ```bash
   mkdir -p .factory/skills/<skill-name>
   $EDITOR .factory/skills/<skill-name>/SKILL.md
   ```
   Use the minimal example above as a starting point. Replace every
   `<<REPO_NAME>>` placeholder.
3. **Verify.** The file must exist at the expected path with valid YAML
   frontmatter. The auditor's `skills` criterion checks for both
   the file's presence and that the frontmatter parses.

If the repo already has a custom agent / droid configuration in
`.factory/droids/`, it can co-exist with `.factory/skills/` — they target
different mechanisms.

## What this directory does NOT contain

- A SKILL.md for any sub-repo. Skills are repo-specific procedures and
  belong inside each sub-repo's tree.
- An "auto-installer." A skill is just a Markdown file; no script
  ports it. The worker authors it by hand following this README.
- A registry of available agents. Agents discover skills by reading
  `.factory/skills/*/SKILL.md` at session start.
