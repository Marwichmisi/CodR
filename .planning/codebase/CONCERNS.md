# Codebase Concerns

**Analysis Date:** 2026-06-26

## Tech Debt

**No Testing Infrastructure:**
- Issue: No unit tests, integration tests, or test framework configured
- Files: `.opencode/` (entire directory)
- Impact: Changes cannot be validated automatically; regressions possible
- Fix approach: Add test framework (Jest/Vitest) and write tests for critical GSD tools

**Inconsistent Code Style:**
- Issue: No linter or formatter configured; mixed indentation (2-space and 4-space)
- Files: `.opencode/gsd-core/bin/lib/*.cjs`
- Impact: Code readability, harder to maintain
- Fix approach: Add ESLint + Prettier configuration

**Large File Sizes:**
- Issue: Some library modules exceed 500 lines (e.g., `gsd-tools.cjs` at 2971 lines)
- Files: `.opencode/gsd-core/bin/gsd-tools.cjs`, `.opencode/gsd-core/bin/lib/*.cjs`
- Impact: Hard to navigate, understand, and maintain
- Fix approach: Refactor into smaller, focused modules

**Empty Settings File:**
- Issue: `.opencode/settings.json` is empty `{}`
- Files: `.opencode/settings.json`
- Impact: No runtime configuration despite having config infrastructure
- Fix approach: Document required settings or remove file

## Known Bugs

**No Known Bugs:**
- Not detected during analysis

## Security Considerations

**Permissions Configuration:**
- Risk: Wide-open read permissions on `.opencode/gsd-core/*`
- Files: `.opencode/opencode.json`
- Current mitigation: Read-only permissions (no write access granted)
- Recommendations: Review if all core files need read access

**Git Credentials:**
- Risk: Skills installation requires git credentials
- Files: `skills-lock.json`
- Current mitigation: System-level git credentials
- Recommendations: Ensure credentials are not committed

## Performance Bottlenecks

**No Significant Performance Issues:**
- Not detected (CLI tooling, not performance-critical)

## Fragile Areas

**GSD Core CLI:**
- Files: `.opencode/gsd-core/bin/gsd-tools.cjs`
- Why fragile: Single large file with many responsibilities (2971 lines)
- Safe modification: Add tests before modifying
- Test coverage: None

**Workflow Definitions:**
- Files: `.opencode/gsd-core/workflows/*.md`
- Why fragile: Complex embedded instructions; changes can break workflows
- Safe modification: Test workflows end-to-end after changes
- Test coverage: None

## Scaling Limits

**Not Applicable:**
- This is a local CLI tool; scaling is not a concern

## Dependencies at Risk

**@opencode-ai/plugin:**
- Risk: External dependency on OpenCode AI ecosystem
- Impact: Changes to OpenCode plugin API could break GSD
- Migration plan: Monitor OpenCode releases; keep version pinned

## Missing Critical Features

**Testing:**
- Problem: No test infrastructure exists
- Blocks: Automated validation, CI/CD integration

**CI/CD:**
- Problem: No continuous integration pipeline
- Blocks: Automated testing, quality gates

**Documentation:**
- Problem: No project README or setup instructions
- Blocks: Onboarding new contributors

## Test Coverage Gaps

**Entire Codebase:**
- What's not tested: All GSD tools, workflows, agents
- Files: `.opencode/gsd-core/bin/lib/*.cjs`, `.opencode/agents/*.md`
- Risk: Regressions in workflow automation
- Priority: High

---

*Concerns audit: 2026-06-26*
