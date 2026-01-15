# AI Project Memory

> **Last Updated**: [AI: Insert current date and time]
> **Session**: [AI: Insert session number or identifier]
> **Status**: Active

---

## START HERE

**What we're building**: [AI: Write 2-3 sentences describing this project - what it does, who it's for, what problem it solves]

**Current objective**: [AI: What specific feature or task are we working on right now?]

**Next step**: [AI: What's the immediate next action to take?]

**Last 3 things done**:
1. [AI: Most recent change - timestamp]
2. [AI: Previous change - timestamp]
3. [AI: Earlier change - timestamp]

---

## PROJECT STATE

### What Works
[AI: List features/components that are complete and functional]
- [Component/feature name]: Brief description

### In Progress
[AI: What's currently being built or modified]
- [Component/feature name]: What's done, what's left

### Blocked/Broken
[AI: Known issues preventing progress or broken functionality]
- [Issue description]: Why it's blocked, what's needed to unblock

---

## PROJECT STRUCTURE

```
[AI: Create a directory tree showing the project layout. Include key files and directories.]
project-root/
├── src/
│   ├── [key files]
│   └── [subdirectories]
├── tests/
├── config/
└── [other important directories]
```

### Key Files
[AI: List the most important files and what they do]
- `path/to/file.ext`: Purpose and role in the project

---

## ARCHITECTURE DECISIONS

[AI: Log significant architectural choices here. Each entry should explain WHAT you decided, WHY you chose it, and what alternatives you considered.]

### [Decision Title] - [Date]
**Context**: [What problem or need prompted this decision?]

**Decision**: [What did we choose to do?]

**Reasoning**: [Why this approach? What makes it the best choice?]

**Alternatives Considered**:
- [Alternative 1]: Why we didn't choose this
- [Alternative 2]: Why we didn't choose this

**Trade-offs**: [What did we give up or compromise on?]

**Tags**: #dev:[category]

---

## CHANGE LOG

[AI: Reverse chronological log of changes. Most recent at the top. Be specific about what changed and why.]

### [Date/Time] - [Component/Area]
**File(s)**: `path/to/file.ext`
**Tag**: #dev:[category]
**What**: [One line description of the change]
**Why**: [Brief explanation of the reasoning]
**Impact**: [What other parts of the system does this affect?]

---

## COMPONENT REFERENCE

[AI: Maintain a living reference of major components/modules in the project]

### [Component Name]
**Status**: Complete | In Progress | Not Started | Broken
**Files**: `path/to/file1.ext`, `path/to/file2.ext`
**Purpose**: [What does this component do?]
**Dependencies**: [What does it depend on?]
**Used By**: [What depends on it?]
**Last Modified**: [Date]
**Tags**: #dev:[category]

---

## KNOWLEDGE BASE

[AI: Document important "how to" and "where is" information that you or future AI sessions will need]

### How To...
**[Task description]**
[Step-by-step or explanation of how to accomplish this task in this project]

### Why We...
**[Decision or pattern]**
[Explanation of why the project does things a certain way]

### Where Is...
**[Feature or functionality]**
File: `path/to/file.ext`
Function/Class: `name`
Description: [Brief explanation]

---

## KNOWN ISSUES

[AI: Track bugs, limitations, and technical debt]

### [Issue Title]
**Severity**: Critical | High | Medium | Low
**Affects**: [What components or features are impacted?]
**Description**: [What's wrong?]
**Workaround**: [Temporary solution, if any]
**Resolution Plan**: [How we plan to fix it]
**Discovered**: [Date]

---

## TAG CATEGORIES

[AI: Maintain a list of #dev:category tags being used in the codebase and what they mean]

- `#dev:api`: API endpoints and external interfaces
- `#dev:auth`: Authentication and authorization logic
- `#dev:database`: Database schema, queries, migrations
- `#dev:business-logic`: Core business rules and domain logic
- `#dev:ui`: User interface components and layouts
- `#dev:config`: Configuration and environment setup
- `#dev:testing`: Test files and test utilities
- `#dev:performance`: Performance optimizations
- `#dev:security`: Security-related implementations
- `#dev:integration`: Third-party integrations
- `#dev:error-handling`: Error handling and validation
- `#dev:architecture`: Major architectural decisions or patterns

[AI: Add more categories as needed for your specific project]

---

## AI INSTRUCTIONS

### When You Start a Session
1. Read the START HERE section first
2. Check PROJECT STATE to understand what exists
3. Review last 5 CHANGE LOG entries
4. Update "Last Updated" timestamp

### When You Make ANY Change
YOU MUST update this file immediately after writing code. This is NOT optional.

1. Add #dev:[category] tag in the code at decision points
2. Add entry to CHANGE LOG with:
   - Timestamp
   - File path
   - Tag used
   - What you did (1 line)
   - Why you did it (brief)
3. Update PROJECT STATE if you completed/started/broke something
4. Update COMPONENT REFERENCE if you modified a component
5. Update PROJECT STRUCTURE if you created new files/directories

### When You Make Decisions
1. Log it in ARCHITECTURE DECISIONS with reasoning
2. Explain alternatives you considered
3. Note any trade-offs made

### Before You End a Session
1. Update "Last 3 things done" in START HERE
2. Set clear "Next step" for the next AI
3. Update Status (Active/Paused/Blocked)
4. Commit all PROJECT STATE changes

### Critical Rules
- NEVER skip updating this file after making changes
- ALWAYS explain WHY, not just WHAT
- Keep future AI instances in mind - be explicit
- If you're unsure what a section should contain, ask the user
- When handing off to another AI session, make "Next step" crystal clear
- Tag all significant code with appropriate #dev:[category] markers
- Update timestamps religiously - context decay is real
- If something breaks, document it immediately in KNOWN ISSUES
- Your updates are how the next AI understands the project - be thorough
