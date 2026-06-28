<!-- refreshed: 2026-06-26 -->
# Architecture

**Analysis Date:** 2026-06-26

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    OpenCode CLI                              │
│  `.opencode/opencode.json` - Entry point configuration      │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    GSD Core Engine                           │
│  `.opencode/gsd-core/bin/gsd-tools.cjs` - Main CLI         │
└───────────┬─────────────────────────────────┬───────────────┘
            │                                 │
            ▼                                 ▼
┌───────────────────────┐    ┌───────────────────────────────┐
│   Workflow Commands   │    │       Agent Definitions       │
│  `.opencode/command/` │    │     `.opencode/agents/`       │
│  `.opencode/skills/`  │    │     `.opencode/skills/`       │
└───────────┬───────────┘    └───────────────┬───────────────┘
            │                                 │
            ▼                                 ▼
┌─────────────────────────────────────────────────────────────┐
│                    State Management                         │
│  `.planning/` - Project state, phases, roadmaps             │
│  `.planning/codebase/` - Codebase mapping documents         │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| GSD Tools CLI | Core workflow operations, state management, git commits | `.opencode/gsd-core/bin/gsd-tools.cjs` |
| Workflow Commands | User-facing slash commands | `.opencode/command/*.md` |
| Skills | Reusable agent workflows | `.opencode/skills/*/SKILL.md` |
| Agent Definitions | Subagent behavior specifications | `.opencode/agents/*.md` |
| Hooks | Pre/post execution scripts | `.opencode/hooks/*.js`, `.opencode/hooks/*.sh` |
| Core Libraries | Utility modules for GSD operations | `.opencode/gsd-core/bin/lib/*.cjs` |

## Pattern Overview

**Overall:** Plugin-based workflow automation framework

**Key Characteristics:**
- Markdown-driven configuration (agents, commands, workflows)
- File-system based state management (`.planning/` directory)
- Git-integrated version control for all workflow artifacts
- Modular library architecture with CommonJS modules

## Layers

**CLI Interface:**
- Purpose: Entry point for all GSD operations
- Location: `.opencode/gsd-core/bin/gsd-tools.cjs`
- Contains: Command routing, argument parsing
- Depends on: Core libraries
- Used by: User via OpenCode CLI

**Workflow Layer:**
- Purpose: Define user-facing commands and agent workflows
- Location: `.opencode/command/`, `.opencode/skills/`
- Contains: Markdown files with embedded instructions
- Depends on: Agent definitions, GSD core
- Used by: CLI Interface

**Agent Layer:**
- Purpose: Define subagent behavior for parallel execution
- Location: `.opencode/agents/`
- Contains: Agent specifications with roles, processes, templates
- Depends on: Core libraries
- Used by: Workflow Layer via Agent tool

**Library Layer:**
- Purpose: Shared utility functions
- Location: `.opencode/gsd-core/bin/lib/`
- Contains: ~100+ CommonJS modules for specific concerns
- Depends on: External packages (uuid, msgpackr, zod)
- Used by: CLI Interface, Hooks

## Data Flow

### Command Execution Path

1. User invokes command (e.g., `/gsd-map-codebase`)
2. OpenCode routes to `.opencode/command/gsd-map-codebase.md`
3. Command loads skill from `.opencode/skills/gsd-map-codebase/SKILL.md`
4. Skill orchestrates agents from `.opencode/agents/`
5. Agents write artifacts to `.planning/` directory
6. Git commits track all changes

### State Management Flow

1. `.planning/STATE.md` tracks current phase and progress
2. `.planning/ROADMAP.md` defines milestone structure
3. `.planning/config.json` stores workflow configuration
4. Git history provides audit trail

**State Management:**
- File-system based (no database)
- Git-backed version control
- Markdown documents for human readability

## Key Abstractions

**Phase:**
- Purpose: Atomic unit of work in a milestone
- Examples: `.planning/milestone-*/phase-*/`
- Pattern: Directory with PLAN.md, SUMMARY.md, artifacts

**Skill:**
- Purpose: Reusable workflow component
- Examples: `.opencode/skills/gsd-execute-phase/SKILL.md`
- Pattern: Markdown with embedded instructions and templates

**Agent:**
- Purpose: Specialized subagent for parallel execution
- Examples: `.opencode/agents/gsd-codebase-mapper.md`
- Pattern: Markdown with role, process, templates, rules

## Entry Points

**GSD CLI:**
- Location: `.opencode/gsd-core/bin/gsd-tools.cjs`
- Triggers: OpenCode CLI commands
- Responsibilities: Command routing, state management, git operations

**Workflow Commands:**
- Location: `.opencode/command/*.md`
- Triggers: Slash commands in OpenCode
- Responsibilities: User-facing operations

## Architectural Constraints

- **Threading:** Single-threaded Node.js event loop
- **Global state:** None (all state is file-based)
- **Circular imports:** Not applicable (CommonJS modules)
- **File-system dependency:** Requires write access to project directory

---

*Architecture analysis: 2026-06-26*
