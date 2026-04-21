# Project Wiki — AI Instructions

This file defines how an AI creates, maintains, queries, and audits the project wiki. The wiki is a structured, interlinked collection of markdown pages that compile project knowledge for fast AI access.

**Core principle:** Knowledge is compiled once and kept current — not re-derived on every conversation.

---

## 1. Purpose

The wiki eliminates the need for an AI to read every source file to understand a project. It captures architecture, data flows, business rules, decisions, and relationships in structured pages that the AI reads first and trusts until proven stale.

**The wiki is a map, not the territory.** When modifying code, always verify wiki claims against actual source. When understanding context, read the wiki first.

---

## 2. Structure

```
.wiki/
├── SCHEMA.md              # This file — how to manage the wiki
├── index.md               # Master catalog of all pages with one-line summaries
├── log.md                 # Append-only chronological record of wiki changes
├── architecture.md        # System components, deployment, infrastructure
├── data-model.md          # Database schemas, relationships, access patterns
├── stack.md               # Technologies, dependencies, tooling, scripts
├── conventions.md         # Naming rules, code standards, project-specific patterns
├── features/              # One page per feature
│   └── <feature>.md
└── concepts/              # Cross-cutting concerns
    └── <concept>.md
```

**When to create a new page:**
- New feature added to the project → `features/<feature>.md`
- New cross-cutting pattern emerges (spans 2+ features) → `concepts/<concept>.md`

**When NOT to create a new page:**
- Information fits naturally in an existing page
- The topic is too small to justify its own page (add to the relevant feature/concept page instead)

---

## 3. Page Types

### 3.1 Feature Pages (`features/<feature>.md`)

One page per cohesive feature. A feature = a set of functionality a user would recognize as one thing (auth, billing, notifications).

**Required sections:**
| Section | Content |
|---|---|
| Summary | One sentence — what the feature does |
| Scope | Which files implement this feature (paths relative to project root) |
| User-facing behavior | What the user sees/does |
| Data flow | How a request moves through the layers for this feature |
| Business rules | Validation, constraints, edge cases |
| Gotchas | Non-obvious behavior, known issues, things that break assumptions |
| Status | Complete / partial / planned |
| Related pages | Links to other wiki pages this feature connects to |

**Optional sections (include only when applicable):**
| Section | When to include |
|---|---|
| API endpoints | Feature exposes HTTP/RPC endpoints — document method, path, purpose, request/response shapes. Skip for pure-UI and client-only features. |

**Planned features:** pages marked `Status: Planned` still follow the shape above. Unknown content goes under its section as `_TBD._` or a short note explaining what is undecided. Do not invent sections — keep open questions inside `Gotchas` or a section-level `_TBD._` marker.

### 3.2 Concept Pages (`concepts/<concept>.md`)

Cross-cutting concerns that span multiple features or layers.

**Examples:** error handling, configuration management, shared validation, testing strategy, deployment pipeline, auth middleware.

**Required sections:**
| Section | Content |
|---|---|
| Summary | One sentence — what this concept covers |
| Scope | Which files/layers are involved |
| How it works | Implementation across the project |
| Rules | Conventions, constraints, hard rules |
| Why | Decisions, trade-offs, rationale (if non-obvious) |
| Related pages | Links to features/concepts that use this |

### 3.3 Root Pages

| Page | Content |
|---|---|
| `architecture.md` | System-level view — components, how they connect, deployment topology, environments |
| `data-model.md` | All database tables/collections, schemas with field types, relationships, indexes, access patterns |
| `stack.md` | All technologies with versions, dev tooling, build/deploy commands, dependency purpose |
| `conventions.md` | Naming rules, file patterns, code standards, layer responsibilities — the "how we do things here" page |

### 3.4 Index (`index.md`)

Master catalog. Every wiki page appears here with a one-line summary. Organized by category. Updated on every wiki change.

### 3.5 Log (`log.md`)

Append-only chronological record. Every wiki operation (build, update, lint) gets an entry. Entries are parseable by prefix.

---

## 4. Page Format

Every wiki page (except index and log) follows this template:

```markdown
# Page Title

> One-line summary of what this page covers.

**Scope:** list of files/areas this page documents (≤5 files: list individually; >5 files: use directory paths with a brief note, e.g. `server/routes/<feature>/* — route handlers`). Always relative to project root.
**Last verified:** YYYY-MM-DD

---

[Sections as defined by the page type]

## Related Pages

- [page-name](relative/path.md) — how it relates
```

**Formatting rules:**
- Use standard markdown links for cross-references: `[page-name](../path/to/page.md)`
- File paths are relative to project root, not wiki root
- Use tables for structured data (endpoints, schemas, config shapes)
- Use code blocks for config shapes, request/response examples, CLI commands
- ASCII diagrams for architecture — keep them simple and maintainable
- No YAML frontmatter — keep pages as plain markdown

---

## 5. Scope Rules — Tiered Depth

Not everything belongs in the wiki. Use these tiers to decide what to document and at what depth.

### Tier 1 — Full Detail

Architecture, data flows, business rules, decisions and rationale, gotchas, cross-cutting concerns.

Document **why** + **how** + **what**.

*Example:* "Auth uses token-based sessions because the app is stateless. Tokens expire at 24h. On 401 with an expired token, the frontend clears storage and redirects to the login page. There is no refresh flow — the user re-authenticates."

### Tier 2 — Summary

Module purposes, API contracts, config shapes, component responsibilities, file-to-feature mapping.

**One-liner + key facts.** Enough to know what something does without reading the file.

*Example:* "authService.js — handles login and register. Hashes passwords, signs session tokens (24h expiry). Calls the user data layer for persistence."

### Tier 3 — Never Document

Implementation details obvious from reading the code. Simple CRUD operations, loop mechanics, local variable names, boilerplate, trivial getters/setters.

**Inclusion test:** *"Would an AI starting a new conversation waste significant time re-deriving this from source?"*
- Yes → document it (Tier 1 or 2)
- No → skip it (Tier 3)

---

## 6. Operations

### 6.1 Build — First-Time Wiki Generation

**Trigger:** Wiki directory has no `index.md`, or user explicitly requests a full build/rebuild.

**Steps:**
1. Read project entry points — root config, package.json files, main app files
2. Read existing documentation — README, CLAUDE.md, any docs/ or resources/ files
3. Identify all features, concepts, and architectural patterns
4. For each feature: read the relevant source files, extract Tier 1 and Tier 2 knowledge
5. For each cross-cutting concept: trace it across features, document how it works system-wide
6. Write root pages: `architecture.md`, `data-model.md`, `stack.md`, `conventions.md`
7. Write feature pages: `features/<feature>.md`
8. Write concept pages: `concepts/<concept>.md`
9. Write `index.md` — one-line summary per page, organized by category
10. Write `log.md` — initial build entry

**Uncertainty handling:** If the AI cannot determine a feature's behavior from source alone (e.g., undocumented side effects, ambiguous business logic), it marks that section with `[FLABBERGASTED]` and explains what is unclear. `[FLABBERGASTED]` sections must not be trusted — they are treated as stale until resolved. The user should review and clarify the underlying logic so the AI can replace the marker with verified content.

**After build:** Report to user what was created. List all `[FLABBERGASTED]` sections so the user can address them.

**Resolving `[FLABBERGASTED]`:**

- When the user clarifies the logic (in conversation or by pointing to documentation), the AI replaces the marker with verified content and updates `Last verified`
- During lint, unresolved `[FLABBERGASTED]` sections are flagged as a finding and reported to the user
- The marker is never silently removed — it requires either user clarification or source verification to resolve

### 6.2 Update — After Code Changes

**Trigger:** Automatically after any code modification that changes:
- Behavior (new feature, bug fix that changes logic)
- API contracts (new/changed endpoints, request/response shapes)
- Data model (new tables, changed schemas, new fields)
- Architecture (new services, changed deployment, new dependencies)
- Conventions (new patterns, changed rules)

**Skip test:** *"Would this change cause a wiki reader to make a wrong assumption?"* If no → skip. If yes → update.

**Steps:**
1. Identify which wiki pages cover the changed files/features
2. Read the affected wiki pages
3. Update only the sections that changed — do not rewrite unaffected content
4. Update `Last verified` date on changed pages
5. Update `index.md` if page summaries changed or pages were added/removed
6. Append entry to `log.md`

**Rules:**
- Update in the same conversation as the code change
- Keep updates proportional to the code change — a one-line fix doesn't need a paragraph
- If a change affects multiple pages, update all of them
- If a new feature emerges that has no page, create one

### 6.3 Lint — Periodic Health Check

**Trigger modes:**

- **Automatic:** At the start of a new conversation when any wiki page is stale (see Hard Rule 10). Scope is limited to pages covering files the AI modified in the current conversation.
- **User-invoked:** User explicitly requests a lint. The user must specify which pages or areas to lint. If no specification is given, ask the user what to lint before proceeding.

**Steps:**

1. Determine lint scope (automatic: pages affected by your changes; user-invoked: pages specified by user)
2. For each in-scope page, spot-check key claims against current source:
   - Do referenced files still exist at the stated paths?
   - Do API endpoints match the documented shapes?
   - Do business rules in the wiki match the code?
   - Are there new features/files with no wiki coverage?
3. Classify findings:
   - **Drift** — wiki says X, code says Y → fix the wiki page
   - **Stale** — wiki documents something that was removed → remove or mark as removed
   - **Missing** — new code with no wiki coverage → create page or add section
   - **Broken links** — cross-references to pages/files that don't exist → fix or remove
   - **Flabbergasted** — unresolved `[FLABBERGASTED]` markers → report to user for clarification
4. Report findings to user with proposed fixes
5. Apply fixes after approval
6. Update `Last verified` dates on all checked pages
7. Append lint entry to `log.md`

**Lint is not a rewrite.** Fix what's wrong, leave what's correct untouched.

### 6.4 Query — Using the Wiki

**When the AI needs to understand the project:**
1. Read `index.md` to find relevant pages
2. Read the specific wiki pages needed for the task
3. Only read source files when:
   - The wiki doesn't have enough detail for the current task
   - You need to modify code (always read the actual file before editing)
   - You suspect the wiki is stale for the area you're working in

**The wiki is the starting point, not the ending point.** Use it to orient, then go to source for precision.

### 6.5 Remove — Page Deletion

**Trigger:** A feature or concept has been fully removed from the codebase, or a page documents something that no longer exists.

**Steps:**

1. Confirm the page's subject no longer exists in the codebase
2. Identify all cross-references to the page across the wiki
3. Remove or rewrite every cross-reference — no broken links may remain
4. Delete the page file
5. Remove the entry from `index.md`
6. Append removal entry to `log.md`

**Rules:**

- Removal is total — no markers, no stubs, no "this used to exist" notes
- If other pages referenced the removed page for context (not just linking), rewrite those sections to be self-contained or link to a different relevant page
- If removing a concept page, verify no feature page depends on it for critical documentation before deleting

---

## 7. Index Format

```markdown
# Wiki Index

> Master catalog of all wiki pages. One-line summaries. Updated on every wiki change.

## Architecture & Infrastructure
- [<page-name>](<page-name>.md) — one-line summary

## Conventions
- [conventions](conventions.md) — one-line summary

## Features
- [<feature-name>](features/<feature-name>.md) — one-line summary

## Concepts
- [<concept-name>](concepts/<concept-name>.md) — one-line summary
```

**Rules:**
- Alphabetical within each category
- Every page must appear — no orphans
- Summary must match the page's `> summary` line
- When a page is removed, remove it from the index

---

## 8. Log Format

```markdown
# Wiki Log

> Append-only record. Most recent entries at the bottom.

## [YYYY-MM-DD] build | Initial wiki generation
Pages created: <list of created pages>
Source: built from codebase + existing documentation

## [YYYY-MM-DD] update | <short description of what changed>
Created: <new pages>
Updated: <changed pages with brief reason>

## [YYYY-MM-DD] lint | Health check
Fixed: <page> — <what was corrected>
Missing: <page> — <what needs coverage>
All other pages verified current.
```

**Entry format:** `## [YYYY-MM-DD] <operation> | <short description>`

**Operations:** `build`, `update`, `lint`, `rebuild`

---

## 9. Hard Rules

1. **The wiki documents *about* the code — it does not replace the code.** Never put implementation logic in the wiki that should live in source files.
2. **Always read source before modifying code.** The wiki tells you *where* to look and *what to expect*, but the source file is the authority when editing.
3. **Updates are proportional.** A one-line bug fix gets a one-line wiki update (if any). A new feature gets a new page.
4. **No speculative content.** Don't document planned features as if they exist. Use the Status field to mark things as "planned" if needed.
5. **No significant duplication across pages.** If a concept is documented in `concepts/config.md`, feature pages link to it — they don't repeat it. Minor contextual overlap (a sentence restating something for readability) is acceptable. When significant overlap is found — the same logic, rules, or data documented in multiple pages — resolve it: consolidate into the more specific page (feature page over concept page for feature-specific details), or extract to a concept page if the overlap spans two feature pages equally. Overlap found during lint is classified as Drift.
6. **Broken links are bugs.** Every cross-reference must resolve. Fix them immediately.
7. **Wiki pages are AI-maintained.** The AI owns the content. Humans can edit, but the AI is responsible for keeping pages current and consistent. Wiki pages are exempt from rules that require user confirmation for file modifications (e.g., markdown management schemas in CLAUDE.md) — the AI updates them as part of its maintenance workflow.
8. **Stale is worse than missing.** A missing page forces the AI to read source (slow but correct). A stale page gives the AI wrong information (fast but dangerous). When in doubt, delete or flag as unverified.
9. **One source of truth.** If the wiki absorbs content from another doc (e.g., project-structure.md), that doc should be removed or replaced with a pointer to the wiki. No competing sources.
10. **Staleness threshold is 7 days.** Any page with a `Last verified` date older than 7 days is considered stale. Stale pages must be re-verified against source before being trusted. All staleness checks across the wiki reference this rule.
11. **Undocumented code discovered during a task.** If the AI encounters significant existing code with no wiki coverage while working on an unrelated task, it finishes the current task first. Then: if context capacity allows, create the missing wiki pages. If context is running low, report the gap to the user and ask whether to create them.

---

## 10. Integration

### 10.1 With Project Instructions (CLAUDE.md / README / etc.)

Add to the project's AI instruction file:

```markdown
## Project Wiki

- `.wiki/` contains the AI-maintained project knowledge base
- Read `.wiki/index.md` at conversation start to understand the project
- After code changes, update affected wiki pages per `.wiki/SCHEMA.md`
- The wiki is the primary source of project understanding
- See `.wiki/SCHEMA.md` for full wiki maintenance rules
```

When the wiki is built, if there are project documentations available, it absorbs them:
- Structure docs (like `project-structure.md`) → absorbed into wiki pages → original removed or replaced with pointer
- Convention/rule sections in instruction files → moved to `conventions.md`
- The AI instruction file keeps only: stack summary, pointer to wiki, and AI-behavior rules (things like decision tiers, workflow steps, tone preferences)

### 10.2 With Git

- Wiki files are committed alongside code changes
- Wiki updates can be in the same commit as the code they document
- On lint, wiki fixes can be a separate commit: `wiki: lint — fix drift in [pages]`

### 10.3 With AI Memory Systems

The wiki and memory systems (e.g., Claude's auto-memory) serve different purposes:

| System | Stores | Lifespan | Scope |
|---|---|---|---|
| **Wiki** | Project technical knowledge — architecture, features, data flows, conventions | Lives with the project, committed to git | Any AI or human reading the project |
| **Memory** | User preferences, feedback, project context, external references | Persists across conversations per user | Specific to one user's workflow |

**Rule:** Do not duplicate wiki content in memory or vice versa. Memory stores *how to work with this user*. Wiki stores *how the project works*.

### 10.4 New Conversation Startup

When an AI starts a new conversation on a project with a wiki:

1. Check if `.wiki/index.md` exists
2. If yes: read `index.md`, then read only the pages directly relevant to the user's first request. Read additional pages on-demand as the task requires — do not pre-read the entire wiki
3. If no: offer to build the wiki (`SCHEMA.md` exists but wiki hasn't been generated yet)
4. If wiki exists but pages are stale (per Hard Rule 10): suggest a lint pass

---

## 11. Portability

This SCHEMA.md is designed to work with any project and any AI tool that reads files.

**To use in a new project:**
1. Copy `.wiki/SCHEMA.md` to the new project's `.wiki/` directory
2. Add the integration snippet (Section 10.1) to the project's AI instruction file
3. Ask the AI to run a build (Section 6.1)

**No project-specific content belongs in SCHEMA.md.** All project knowledge lives in the wiki pages. This file is pure instructions.
