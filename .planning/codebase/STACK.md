# Technology Stack

**Analysis Date:** 2026-06-26

## Languages

**Primary:**
- JavaScript (Node.js) - Core runtime for GSD tools, hooks, and scripts
- Markdown - Documentation, agent definitions, workflow specifications

**Secondary:**
- Shell (Bash) - Build scripts, hook scripts, workflow launcher

## Runtime

**Environment:**
- Node.js (CommonJS modules)

**Package Manager:**
- npm
- Lockfile: present (`.opencode/package-lock.json`)

## Frameworks

**Core:**
- @opencode-ai/plugin 1.17.11 - OpenCode AI plugin system
- GSD Core 1.6.0 - Workflow automation framework (custom)

**Testing:**
- Not detected

**Build/Dev:**
- Changeset - Version management (`.opencode/scripts/changeset/`)

## Key Dependencies

**Critical:**
- @opencode-ai/plugin - Provides the plugin interface for OpenCode AI
- uuid - Unique identifier generation (used across GSD tools)
- msgpackr - Binary serialization (used for state/data persistence)
- zod - Schema validation

**Infrastructure:**
- Git - Version control and workflow state management

## Configuration

**Environment:**
- `.opencode/opencode.json` - OpenCode permissions and configuration
- `.opencode/settings.json` - Runtime settings (currently empty)
- `.opencode/package.json` - Package dependencies

**Build:**
- No build step required - Direct Node.js execution

## Platform Requirements

**Development:**
- Node.js runtime
- Git for version control
- OpenCode AI CLI installed

**Production:**
- Local development environment only (CLI tooling)

---

*Stack analysis: 2026-06-26*
