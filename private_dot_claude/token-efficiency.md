# Token Efficiency Guidelines

**Core Principle: Index-First Architecture**

Don't load what you don't need. Index → Filter → Fetch.

---

## The Three-Layer Memory Access Pattern

Memory systems (like claude-mem) should follow this pattern:

```
1. search(query)           → Get index with IDs (50-100 tokens/result)
2. timeline(anchor=ID)     → Get context around interesting results
3. get_observations([IDs]) → Fetch full details ONLY for filtered IDs
```

**Rule**: Never fetch full details without filtering first. **10x token savings.**

### Example: Context Economics

Real-world example from a multi-session project:

- **Loading cost**: 50 observations = 25,421 tokens to read
- **Work preserved**: 281,090 tokens of research/building/decisions
- **Savings**: 255,669 tokens (91% reduction through reuse)

The semantic index (titles, types, files, token counts) is usually sufficient.

Only fetch full observation details when you need:
- Implementation details
- Rationale behind specific decisions
- Debugging context
- Critical types (bug fixes, architectural decisions)

---

## Cross-Session Continuity

### Within-Session: Scratch File Pattern

For non-trivial work spanning multiple hours or complex tasks:

**Maintain `/tmp/claude-session-state.md`**
- Append key decisions/goals/approaches as they happen (one-liners)
- Re-read before making significant decisions
- **Compression detector**: If file contains context you lack in conversation, compression has eaten something → flag it and consider escalation

Example entries:
```markdown
- Goal: Migrate EC2 module to dynamic org ID lookup
- Decision: Two-phase approach - modules first, then consumers
- Tried: Hardcoded dual IDs in v1.0.16 - insufficient for multi-org
- Key files: ~/code/terraform-aws-ec2-module/sub-module/iam-instance-profile/ec2-role.tf
- Blocker: 40 consumer PRs point to old hardcoded version
```

**Keep entries terse** — one line per decision, not prose.

### Across-Session: Proactive Logging

Log to persistent memory (claude-mem, project docs) **immediately when decisions are made**, not at session end.

**Why**: Users frequently start fresh sessions rather than resuming. Persistent memory is the primary continuity mechanism.

**Log immediately if**:
- A decision would be painful to re-derive
- You discovered a non-obvious constraint
- You chose approach B over A for specific reasons
- You identified a future blocker

---

## Context Warmup Checklist

**At session start, load only what's essential:**

- [ ] Check current directory and git status
- [ ] Search memory for projectName + last 7 days
- [ ] Read context index, note any critical types (🔴 bugfix, ⚖️ decision) from last session
- [ ] Check for scratch file from previous session

**Total warmup budget: <2000 tokens**

Do NOT load:
- Full file trees
- All past observations
- Detailed history unless directly relevant

---

## Staleness Heuristics

**When to re-verify cached context:**

| Age | Action |
|-----|--------|
| <7 days | Trust index, fetch details only if needed |
| 7-30 days | Validate high-impact decisions before acting |
| >30 days | Re-verify before trusting |
| >90 days | Treat as historical reference, not current state |

**Always fetch full context for:**
- Architectural decisions (regardless of age)
- Bug fixes if the bug has resurfaced
- Security-related decisions
- Dependencies that may have changed

**Title usually sufficient for:**
- Feature implementations
- Routine updates
- Process/workflow decisions

---

## Search Strategy Decision Tree

**Which tool should you use?**

```
Known file/function name?
  → Glob/Grep (fastest, <1000 tokens)

Broad codebase exploration?
  → Task tool with Explore agent (slower but thorough)

Past decision or approach?
  → Memory search (claude-mem, project docs)

Cross-cutting concern (e.g., "all API endpoints")?
  → Grep + memory search

Multiple rounds of exploration?
  → Task/Explore agent (better than sequential Glob/Grep)
```

**Prefer parallel searches when possible:**
- Multiple independent Glob patterns → single message, multiple tool calls
- Multiple memory searches → batch in one request
- File reads with no dependencies → parallel Read calls

---

## Model Selection for Cost Efficiency

### Subagent Model Selection

| Model | Use Case | Cost |
|-------|----------|------|
| **Haiku** | Purely mechanical, zero ambiguity (file lookups, formatting, boilerplate) | Lowest |
| **Sonnet** | Default for most tasks | Medium |
| **Opus** | Deep reasoning, complex debugging, architecture, or when sonnet failed | Highest |

**Decision rule:**
- Default to **sonnet** — handles most tasks well
- Use **opus** when sonnet produced wrong/confused result (retry without discarding prior attempt), or for complex multi-step reasoning
- Use **haiku** ONLY when 100% confident: purely mechanical, zero judgment needed

**Never use haiku for:**
- Pattern matching
- Decision-making
- Anything requiring judgment calls
- Ambiguous requirements

### Escalation Signals

**When to suggest moving to a more capable model (Opus):**

- Complex multi-step debugging where you keep trying wrong fixes
- Architecture decisions with many interacting tradeoffs
- Subtle bugs in concurrent/async code
- You keep contradicting yourself or losing the reasoning thread
- Going in circles without progress

**When to suggest extended context (1M-token window):**

- Need to hold 10+ files in working memory simultaneously
- Conversation compression actively losing prior decisions
- Large refactoring touching many files where you keep forgetting earlier changes
- Reviewing a large diff or PR end-to-end

### Handoff Protocol

When escalating to a different model, provide a structured handoff:

```markdown
## Handoff to [Model/Context Level]

**Goal**: What the user is trying to accomplish

**Current State**: What's been done, key decisions made

**What Was Tried**: Approaches attempted and why they failed/stalled

**Key Files**: Paths the new session needs to read first
- file1.tf
- file2.py

**Remaining Work**: Specific next steps
1. Step one
2. Step two
```

Don't struggle silently. **Escalating early saves more time than grinding.**

---

## Cost Control Triggers

**Set boundaries to prevent runaway token usage:**

| Scenario | Trigger | Action |
|----------|---------|--------|
| Low value delivered | >20k tokens without user-facing progress | Ask if approach is right |
| Single turn bloat | >50k tokens in one turn | Break into subagent tasks |
| Compression detected | Scratch file has context you lack | Suggest extended context |
| Repeated failures | Same approach tried 3+ times | Stop, analyze, escalate or pivot |
| Broad exploration | Need >5 Grep/Glob rounds | Use Task/Explore agent instead |

**Budget checkpoints:**
- After loading context: "Do I have enough to proceed, or am I missing key info?"
- Before deep exploration: "Is this the right problem to solve?"
- After 3 failed attempts: "Should I escalate or try a completely different approach?"

---

## Batch Operation Guidelines

**When you need to touch 20+ repositories/files:**

### Decision Matrix

| Operation Type | Parallelization | Review Points |
|----------------|-----------------|---------------|
| Read-only analysis | Full parallel (agents or scripts) | After completion |
| Low-risk changes (docs, comments) | Parallel execution, batch review | Sample check, then proceed |
| Medium-risk (refactors, renames) | Parallel execution, human review before merge | Every change reviewed |
| High-risk (logic, security) | Sequential with checkpoints | Every change reviewed before proceeding |

### Patterns

**Pattern 1: Parallel Agents**
- Spawn multiple Task agents in single message
- Each operates independently
- Aggregate results after completion
- Best for: independent analysis, separate features

**Pattern 2: Batch Script**
- Generate script, review with user
- Execute in one pass
- Best for: mechanical changes, low-risk operations

**Pattern 3: Iterative with Checkpoints**
- Process in batches of 5-10
- Review after each batch
- Best for: medium-risk changes requiring human judgment

**Never:**
- Auto-commit batch changes without explicit approval
- Proceed with batch operations if first 2-3 fail similarly
- Skip testing on a representative sample before full rollout

---

## Anti-Patterns

**Token waste patterns to avoid:**

### 1. Premature Deep Dives
❌ Reading entire files when grep would answer the question
✅ Grep for pattern, then read only relevant sections

### 2. Exhaustive Loading
❌ "Let me read all the test files to understand the pattern"
✅ Read 1-2 representative examples, infer pattern

### 3. Redundant Fetching
❌ Re-reading the same file multiple times in one session
✅ Read once, reference line numbers in subsequent discussion

### 4. Over-Exploration
❌ Exploring every corner of the codebase "just in case"
✅ Start with most likely locations, expand only if needed

### 5. Context Hoarding
❌ Loading everything you might need
✅ Load incrementally based on what you discover

### 6. Wrong Tool Selection
❌ Using Task/Explore agent for a known file path
✅ Direct Read for known paths, Explore for discovery

---

## Summary: The Efficiency Mindset

**Think in layers:**
1. What's the minimum context to validate my hypothesis?
2. Can an index/title/summary answer this, or do I need full details?
3. Is this exploration, or do I already know where to look?

**Optimize for:**
- **Precision** over exhaustiveness
- **Incremental loading** over bulk loading
- **Reuse** over re-derivation
- **Fast failure** over comprehensive coverage

**Remember:**
- The best token is the one you didn't spend
- Context loaded is context you must maintain
- Index first, fetch later
- Escalate early, don't grind

**Measure success by:**
- User problems solved per token spent
- Decisions preserved across sessions
- Time saved by reusing past work
- Questions answered from index vs full fetch

---

## Appendix: Real-World Example

**Scenario**: User asks about EC2 module migration status across 140 repositories.

**Inefficient approach** (~80k tokens):
1. Read all 140 repository main.tf files
2. Read module source code
3. Read version history
4. Analyze each consumer individually

**Efficient approach** (~8k tokens):
1. Memory search "EC2 module migration" (500 tokens) → get observation IDs
2. Fetch 2-3 key observations with full details (2k tokens)
3. Grep for module version across repos (1k tokens)
4. Count unique versions (500 tokens)
5. Read 2 representative examples (2k tokens)
6. Synthesize from index + samples (2k tokens)

**Result**: Same answer, 90% token reduction, 10x faster.

**Key moves**:
- Trusted the memory index for status
- Used grep for quantitative data (version distribution)
- Sampled rather than exhaustively reading
- Synthesized from partial data + past context
