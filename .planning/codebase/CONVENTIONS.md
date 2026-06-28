# Coding Conventions

**Analysis Date:** 2026-06-26

## Naming Patterns

**Files:**
- Markdown files: `UPPERCASE.md` for documents, `lowercase-kebab.md` for commands/workflows
- JavaScript files: `lowercase-kebab.cjs` for CommonJS modules
- Agent definitions: `gsd-{role}.md` prefix

**Functions:**
- JavaScript: `camelCase` (e.g., `gsd_run`, `verify-summary`)
- Shell functions: `snake_case` (e.g., `gsd_run`)

**Variables:**
- JavaScript: `camelCase` for local, `UPPER_SNAKE_CASE` for constants
- Shell: `UPPER_SNAKE_CASE` for environment variables

**Types:**
- Not applicable (JavaScript, no TypeScript)

## Code Style

**Formatting:**
- No explicit formatter configured (no Prettier, ESLint, Biome)
- Inconsistent indentation across files (2-space and 4-space mixed)

**Linting:**
- No linter configured

## Import Organization

**Order:**
1. Node.js built-ins
2. External packages
3. Internal modules

**Path Aliases:**
- None used (direct relative paths)

## Error Handling

**Patterns:**
- Try-catch blocks for async operations
- Process exit codes for CLI failures
- Console.error for error output

## Logging

**Framework:** Console (no structured logging)

**Patterns:**
- Console.log for output
- Console.error for errors
- Process.exit for fatal errors

## Comments

**When to Comment:**
- JSDoc for module-level documentation
- Inline comments for complex logic
- No consistent commenting style

**JSDoc/TSDoc:**
- Used in `.opencode/gsd-core/bin/gsd-tools.cjs` for module documentation
- Not consistently applied across all modules

## Function Design

**Size:** No enforced limits (some files exceed 500 lines)

**Parameters:** Object destructuring preferred for complex parameters

**Return Values:** Explicit returns (no implicit undefined)

## Module Design

**Exports:**
- CommonJS `module.exports` pattern
- Some modules export a single function, others export objects

**Barrel Files:**
- Not used (each module is self-contained)

---

*Convention analysis: 2026-06-26*
