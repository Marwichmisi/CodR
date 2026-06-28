# Codebase Structure

**Analysis Date:** 2026-06-26

## Directory Layout

```
CodR/
├── .opencode/                    # OpenCode configuration and tooling
│   ├── agents/                   # Subagent definitions (37 files)
│   ├── command/                  # Slash command definitions (60+ files)
│   ├── gsd-core/                 # GSD workflow engine
│   │   ├── bin/                  # CLI tools and libraries
│   │   │   ├── gsd-tools.cjs     # Main CLI entry point
│   │   │   ├── gsd_run           # Shell launcher
│   │   │   └── lib/              # ~100+ utility modules
│   │   ├── contexts/             # Context templates
│   │   ├── references/           # Reference documentation
│   │   ├── templates/            # Document templates
│   │   └── workflows/            # Workflow definitions
│   ├── hooks/                    # Pre/post execution scripts
│   ├── scripts/                  # Build and utility scripts
│   ├── skills/                   # Reusable workflow skills (50+ dirs)
│   ├── opencode.json             # OpenCode permissions
│   ├── package.json              # Dependencies
│   └── settings.json             # Runtime settings
├── .agents/                      # Additional agent skills
│   └── skills/                   # External skills (3 dirs)
├── .planning/                    # Project state (created by GSD)
├── .git/                         # Git repository
└── skills-lock.json              # Installed skills manifest
```

## Directory Purposes

**.opencode/agents/:**
- Purpose: Subagent behavior specifications
- Contains: Markdown files defining agent roles, processes, templates
- Key files: `gsd-codebase-mapper.md`, `gsd-executor.md`, `gsd-planner.md`

**.opencode/command/:**
- Purpose: User-facing slash commands
- Contains: Markdown files with command instructions
- Key files: `gsd-map-codebase.md`, `gsd-execute-phase.md`, `gsd-plan-phase.md`

**.opencode/skills/:**
- Purpose: Reusable workflow components
- Contains: Subdirectories with SKILL.md files
- Key files: `gsd-execute-phase/SKILL.md`, `gsd-plan-phase/SKILL.md`

**.opencode/gsd-core/bin/lib/:**
- Purpose: Shared utility modules
- Contains: CommonJS modules for specific concerns
- Key files: `config.cjs`, `state.cjs`, `phase.cjs`, `git-base-branch.cjs`

**.opencode/hooks/:**
- Purpose: Pre/post execution scripts
- Contains: JavaScript and shell scripts
- Key files: `gsd-read-guard.js`, `gsd-workflow-guard.js`

**.agents/skills/:**
- Purpose: External skills from GitHub
- Contains: Context7, Font M3, Material Symbols

## Key File Locations

**Entry Points:**
- `.opencode/gsd-core/bin/gsd-tools.cjs`: Main CLI entry point
- `.opencode/gsd-core/bin/gsd_run`: Shell launcher script

**Configuration:**
- `.opencode/opencode.json`: OpenCode permissions
- `.opencode/package.json`: Dependencies
- `.opencode/settings.json`: Runtime settings (empty)
- `skills-lock.json`: Installed skills manifest

**Core Logic:**
- `.opencode/gsd-core/bin/lib/*.cjs`: Utility modules (~100+ files)
- `.opencode/gsd-core/workflows/*.md`: Workflow definitions

**Templates:**
- `.opencode/gsd-core/templates/*.md`: Document templates
- `.opencode/gsd-core/templates/codebase/*.md`: Codebase mapping templates

## Naming Conventions

**Files:**
- Agent definitions: `gsd-{role}.md` (lowercase, hyphenated)
- Command definitions: `gsd-{command}.md` (lowercase, hyphenated)
- Skills: `gsd-{skill-name}/SKILL.md` (directory with uppercase SKILL.md)
- Library modules: `{module-name}.cjs` (lowercase, hyphenated)

**Directories:**
- Skills: `gsd-{skill-name}/` (lowercase, hyphenated)
- GSD core: `gsd-core/` (lowercase, hyphenated)

## Where to Add New Code

**New Skill:**
- Create `.opencode/skills/gsd-{skill-name}/SKILL.md`
- Register in skill discovery (auto-discovered from directory)

**New Agent:**
- Create `.opencode/agents/gsd-{role}.md`
- Follow agent definition template

**New Command:**
- Create `.opencode/command/gsd-{command}.md`
- Follow command definition template

**New Library Module:**
- Create `.opencode/gsd-core/bin/lib/{module-name}.cjs`
- Follow CommonJS module pattern

**New Hook:**
- Create `.opencode/hooks/gsd-{hook-name}.js` or `.sh`
- Register in hook registry if needed

## Special Directories

**.opencode/gsd-core/templates/:**
- Purpose: Document templates for codebase mapping, phases, etc.
- Generated: No (manually maintained)
- Committed: Yes

**.planning/:**
- Purpose: Runtime project state (phases, roadmaps, codebase maps)
- Generated: Yes (by GSD commands)
- Committed: Yes

---

*Structure analysis: 2026-06-26*
