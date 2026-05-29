# Agent Readiness Report: os-eco

**Level:** 2/5  
**Overall Score:** 28%  
**Generated:** 2026-05-28 17:08:21 UTC  
**Commit:** `8f60e9b`  
**Branch:** main  

## Summary

| Metric | Value |
|--------|-------|
| Total Criteria | 82 |
| Passed | 16 |
| Failed | 42 |
| Skipped | 24 |

## Pass Rate by Category

| Category | Pass Rate |
|----------|-----------|
| Style & Validation | 0% |
| Build System | 36% |
| Testing | 0% |
| Documentation | 57% |
| Development Environment | 0% |
| Debugging & Observability | 0% |
| Security | 56% |
| Task Discovery | 100% |
| Product & Experimentation | 0% |

## Style & Validation

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Linter Configuration | 0/1 | 🔴 Failed | No linter (ESLint/Biome/etc.) configured at repo root; meta-repo has no source code. |
| Type Checker | 0/1 | 🔴 Failed | No tsconfig.json, mypy, or type checker at root. |
| Code Formatter | 0/1 | 🔴 Failed | No Prettier/Biome/Black config at root. |
| Pre-commit Hooks | 0/1 | 🔴 Failed | No husky, lint-staged, or .pre-commit-config.yaml at root. |
| Naming Consistency | 0/1 | 🔴 Failed | No linter naming rules or documented naming conventions at root. |
| Cyclomatic Complexity | 0/1 | 🔴 Failed | No complexity analyzer configured. |
| Large File Detection | 0/1 | 🔴 Failed | No file-size linter, CI check, git hook, or LFS config present at root. |
| Dead Code Detection | 0/1 | 🔴 Failed | No knip/unimported/SonarQube or equivalent dead-code detector at root. |
| Duplicate Code Detection | 0/1 | 🔴 Failed | No jscpd/PMD/SonarQube duplicate detector configured. |
| Technical Debt Tracking | 0/1 | 🔴 Failed | No TODO/FIXME scanner, SonarQube, or other debt-tracking tooling configured. |
| Strict Typing | N/A | Skipped | No source code or type checker exists; not applicable to a docs-only meta-repo. |
| Code Modularization Enforcement | N/A | Skipped | No source code; module boundaries not meaningful for a coordination meta-repo. |
| N+1 Query Detection | N/A | Skipped | No database or ORM usage; not applicable. |

## Build System

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Dependencies Pinned | 0/1 | 🔴 Failed | No package.json or lockfile at root; meta-repo has no dependencies of its own. |
| Automated PR Review Generation | 0/1 | 🔴 Failed | gh CLI available; no PRs found and no review automation (danger.js, droid, AI bots) configured. |
| Deployment Frequency | 0/1 | 🔴 Failed | No releases and no deployment workflows; gh release list and gh run list both empty. |
| Feature Flag Infrastructure | 0/1 | 🔴 Failed | No feature flag platform (LaunchDarkly, Statsig, etc.) configured. |
| Release Notes Automation | 0/1 | 🔴 Failed | No semantic-release, changesets, or changelog generation at root. |
| Unused Dependencies Detection | 0/1 | 🔴 Failed | No depcheck/knip/equivalent configured at root. |
| Release Automation | 0/1 | 🔴 Failed | No CD pipeline, semantic-release, GitOps, or release automation at root. |
| Build Command Documentation | 1/1 | 🟢 Passed | README and AGENTS.md document per-tool 'bun test && bun run lint && bun run typecheck' commands. |
| VCS CLI Tools | 1/1 | 🟢 Passed | gh CLI installed and authenticated as jayminwest. |
| Agentic Development | 1/1 | 🟢 Passed | Heavy agent presence: scripts/run-plan.sh invokes claude, .claude/commands/, .factory-mission-scratch/, AGENTS.md, CLAUDE.md, mulch/seeds/canopy agent workflows documented. |
| Single Command Setup | 1/1 | 🟢 Passed | README documents quick-start commands ('git clone ... && docker compose up -d' for warren; 'bun install -g ...' per tool). |
| Fast CI Feedback | N/A | Skipped | No PRs exist on the repo, no CI workflow runs tests/builds (no package.json); insufficient signal to evaluate. |
| Build Performance Tracking | N/A | Skipped | Repo has no build process; build performance is not applicable. |
| Progressive Rollout | N/A | Skipped | Not an infrastructure repo; canary/ring deployments not applicable to a docs/coordination meta-repo. |
| Rollback Automation | N/A | Skipped | Not an infrastructure repo; nothing to roll back. |
| Monorepo Tooling | N/A | Skipped | Sub-repos are gitignored independent repositories, not workspaces; not a true monorepo. |
| Heavy Dependency Detection | N/A | Skipped | No bundled application; not applicable. |
| Version Drift Detection | N/A | Skipped | Not a monorepo with shared dependencies; not applicable. |
| Dead Feature Flag Detection | N/A | Skipped | Prerequisite feature_flag_infrastructure fails; not applicable. |

## Testing

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Unit Tests Exist | 0/1 | 🔴 Failed | No tests in the meta-repo; sub-repos host their own tests but are gitignored. |
| Integration Tests Exist | 0/1 | 🔴 Failed | No integration tests at root. |
| Unit Tests Runnable | 0/1 | 🔴 Failed | No test runner or test script at root. |
| Test Performance Tracking | 0/1 | 🔴 Failed | No tests, so no test-timing tracking. |
| Test Coverage Thresholds | 0/1 | 🔴 Failed | No tests or coverage config at root. |
| Test File Naming Conventions | 0/1 | 🔴 Failed | No test framework or naming patterns configured at root. |
| Test Isolation | 0/1 | 🔴 Failed | No test framework configured. |
| Flaky Test Detection | N/A | Skipped | No tests exist to be flaky. |

## Documentation

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Automated Documentation Generation | 0/1 | 🔴 Failed | No API doc generator, JSDoc, changelog automation, or doc workflow configured. |
| Skills Configuration | 0/1 | 🔴 Failed | No .factory/skills/, .claude/skills/, or .skills/ directory with SKILL.md files. The lone SKILL.md under docs/l5-uplift/worker-skill/ is documentation, not a registered skill. |
| AGENTS.md Freshness Validation | 0/1 | 🔴 Failed | No CI job, hook, or automation validates AGENTS.md commands stay accurate. |
| AGENTS.md File | 1/1 | 🟢 Passed | AGENTS.md (7.5KB) at root documents ecosystem contract, commands, and conventions for agents. |
| README File | 1/1 | 🟢 Passed | README.md (10KB) with overview, toolchain table, quick start, and example workflow. |
| Documentation Freshness | 1/1 | 🟢 Passed | README.md and AGENTS.md modified within last 180 days (today). |
| Service Architecture Documented | 1/1 | 🟢 Passed | CLAUDE.md, AGENTS.md, and README contain ASCII architecture diagrams ('How they fit together') showing warren orchestrator + substrate/context/runtime tools. |
| API Schema Docs | N/A | Skipped | Meta-repo exposes no HTTP/GraphQL API; not applicable. |

## Development Environment

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Dev Container | 0/1 | 🔴 Failed | No .devcontainer/devcontainer.json present. |
| Environment Template | 0/1 | 🔴 Failed | No .env.example at root and no env vars documented in README/AGENTS for the meta-repo itself. |
| Local Services Setup | N/A | Skipped | Meta-repo has no external service dependencies; sub-repos manage their own docker-compose. |
| Database Schema | N/A | Skipped | No database; not applicable. |
| Devcontainer Runnable | N/A | Skipped | No devcontainer to run. |

## Debugging & Observability

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Structured Logging | 0/1 | 🔴 Failed | No logging library or logger module (no source code). |
| Distributed Tracing | 0/1 | 🔴 Failed | No tracing instrumentation. |
| Metrics Collection | 0/1 | 🔴 Failed | No metrics/telemetry instrumentation. |
| Error Tracking Contextualized | 0/1 | 🔴 Failed | No Sentry/Bugsnag/Rollbar integration. |
| Alerting Configured | 0/1 | 🔴 Failed | No PagerDuty/OpsGenie/alerting rules defined. |
| Runbooks Documented | 0/1 | 🔴 Failed | No runbooks/ directory or references to incident response procedures in docs. |
| Deployment Observability | 0/1 | 🔴 Failed | No monitoring dashboards or deploy notification integrations referenced. |
| Code Quality Metrics Dashboard | N/A | Skipped | No source code, no coverage, no SonarQube; not applicable. |
| Health Checks | N/A | Skipped | Meta-repo is not a deployed service; not applicable. |
| Circuit Breakers | N/A | Skipped | No external service calls; not applicable. |
| Profiling Instrumentation | N/A | Skipped | No code to profile; not meaningful. |

## Security

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Branch Protection | 0/1 | 🔴 Failed | gh API returns minimal protection on main (no required reviews, enforce_admins=false, no required checks); does not meet PR review or push-prevention bar. |
| Secret Scanning | 0/1 | 🔴 Failed | GitHub secret scanning disabled (404 from API); no gitleaks/trufflehog/detect-secrets configured. |
| Automated Security Review Generation | 0/1 | 🔴 Failed | No code-scanning analyses, SAST tools, or security review automation configured. |
| Sensitive Data Log Scrubbing | 0/1 | 🔴 Failed | No logging code or scrubbing configuration. |
| CODEOWNERS File | 1/1 | 🟢 Passed | CODEOWNERS at root with '* @jayminwest' default owner. |
| Dependency Update Automation | 1/1 | 🟢 Passed | .github/dependabot.yml configured for github-actions ecosystem with weekly schedule. |
| Gitignore Comprehensive | 1/1 | 🟢 Passed | .gitignore excludes .env (preserves .env.example), node_modules, dist, coverage, .idea, .vscode, .DS_Store, and sub-repo dirs. |
| Secrets Management | 1/1 | 🟢 Passed | .env files gitignored; auto-merge workflow uses secrets.AUTO_MERGE_PAT reference (no hardcoded secrets); SECURITY.md documents private vulnerability reporting. |
| Minimum Dependency Release Age | 1/1 | 🟢 Passed | .github/dependabot.yml sets cooldown.default-days: 5, enforcing a release-age delay before adopting new versions. |
| DAST Scanning | N/A | Skipped | Not deployed as a web service; not applicable. |
| PII Handling | N/A | Skipped | No personal/user data processed; not applicable. |
| Privacy Compliance | N/A | Skipped | Meta-repo collects no end-user data; not applicable. |

## Task Discovery

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Issue Templates | 1/1 | 🟢 Passed | .github/ISSUE_TEMPLATE/ contains bug_report.yml, feature_request.yml, and config.yml. |
| Issue Labeling System | 1/1 | 🟢 Passed | .github/labels.yml + sync-labels.yml workflow define priority/P0-P3, kind/{bug,feature,chore}, area/*, status/* namespaced labels. |
| PR Templates | 1/1 | 🟢 Passed | .github/pull_request_template.md exists with Summary/Changes/Test plan sections. |
| Backlog Health | N/A | Skipped | gh issue list returns empty; no open issues exist to evaluate backlog quality. |

## Product & Experimentation

| Criterion | Score | Status | Rationale |
|-----------|-------|--------|-----------|
| Product Analytics Instrumentation | 0/1 | 🔴 Failed | No analytics SDK (Mixpanel/Amplitude/PostHog/etc.) instrumented. |
| Error to Insight Pipeline | 0/1 | 🔴 Failed | No Sentry-GitHub webhook or error-to-issue automation configured. |

---

*Generated by Factory Agent Readiness*