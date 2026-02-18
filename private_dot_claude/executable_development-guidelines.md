---
inclusion: manual
contextKey: development-guidelines
---

# Development Guidelines

## Core Development Philosophy

**Write tests first, ship fast, learn continuously.**

Every feature follows the same disciplined approach: understand requirements through acceptance criteria, validate with tests, then implement the simplest solution that works.

## Development Workflow

### The BDD → TDD → Implementation Cycle

**Step 1: Define Acceptance Criteria (BDD)**
```gherkin
Given [context/precondition]
When [action/event]
Then [expected outcome]
```

- Start with business requirements and user stories
- Write acceptance tests that define "done"
- These tests will fail initially (expected)
- Acceptance tests validate behavior, not implementation

**Step 2: Write Unit Tests (TDD)**
```python
def test_calculate_availability_when_no_allocations():
    # Given: A team member with no current allocations
    team_member = TeamMember(...)

    # When: Calculating availability
    result = calculator.calculate_availability(team_member)

    # Then: Should show 100% availability
    assert result.availability_percent == 100
```

- Break down acceptance criteria into smaller units
- Write failing unit tests for each component
- Focus on one piece of functionality at a time

**Step 3: Implement (Red-Green-Refactor)**

**RED** - Write a failing test
```bash
pytest tests/test_availability.py::test_calculate_availability_when_no_allocations
# FAILED - AvailabilityCalculator not implemented
```

**GREEN** - Write minimal code to pass
```python
class AvailabilityCalculator:
    def calculate_availability(self, team_member):
        return ResourceAvailability(availability_percent=100)
```

**REFACTOR** - Improve without changing behavior
```python
class AvailabilityCalculator:
    def calculate_availability(self, team_member: TeamMember) -> ResourceAvailability:
        """Calculate resource availability based on current allocations."""
        total_allocation = sum(a.percentage for a in team_member.allocations)
        availability = 100 - total_allocation
        return ResourceAvailability(
            team_member_id=team_member.id,
            availability_percent=max(0, availability)
        )
```

**Step 4: Verify Acceptance Tests Pass**
```bash
pytest tests/acceptance/
# All acceptance tests should pass when feature is complete
```

### When to Use Each Testing Level

**Acceptance/E2E Tests:**
- Use for: Validating complete user workflows
- Use for: Testing business requirements end-to-end
- Use for: Ensuring system behavior is correct
- Use for: Written first (define "done")
- Avoid for: Testing edge cases
- Avoid for: Unit-level validation

**Unit Tests:**
- Use for: Testing individual functions/classes in isolation
- Use for: Fast feedback (milliseconds)
- Use for: High coverage of edge cases
- Use for: Easy debugging when they fail
- Use for: Mocking external dependencies
- Avoid for: Testing implementation details

**Example Test Pyramid:**
```
        /\
       /  \      E2E Tests (10%)
      /____\     - Critical user flows
     /      \    - Happy path + key edge cases
    /        \
   /  Unit    \  Unit Tests (90%)
  /   Tests    \ - All business logic
 /______________\ - All edge cases
                 - All error paths
```

## Git Workflow (GitHub Flow)

### Branch Strategy

**Main Branch:**
- Always deployable
- Protected (requires PR + CI passing)
- All tests must pass
- Deploy automatically or on-demand

**Feature Branches:**
- Short-lived (< 2-3 days ideal)
- Descriptive names: `feature/add-skills-to-availability`
- Or ticket-based: `DGT-1148/refactor-capacity-models`

### Commit Practices

**Commit Messages:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Code restructuring (no behavior change)
- `test:` Adding/updating tests
- `docs:` Documentation changes
- `chore:` Maintenance (deps, config)

**Examples:**
```bash
# Good commits
feat(availability): add skills and certifications to resource data
fix(allocation): correct calculation for partial week allocations
refactor(models): extract Week value object from string manipulation
test(availability): add edge cases for zero-allocation scenarios

# Bad commits
"fixed bug"
"WIP"
"asdf"
"updated files"
```

### Pull Request Process

**Before Opening PR:**
```bash
# 1. All acceptance tests pass
pytest tests/acceptance/ --disable-warnings

# 2. All unit tests pass
pytest tests/unit/ --disable-warnings

# 3. Linting passes
make check

# 4. Local testing complete
make dev  # Verify manually if needed
```

**PR Template:**
```markdown
## Summary
Brief description of what changed and why

## Changes
- Added X feature
- Refactored Y component
- Fixed Z bug

## Testing
- All acceptance tests pass
- Added unit tests for new logic
- Manual testing completed

## Notes
- Any breaking changes?
- Any deployment considerations?
- Follow-up work needed?
```

**Review Process:**
- **Educational focus** - Help each other learn
- **Ship fast** - Don't block on minor issues
- **Create tickets** - Track improvements for later
- **Knowledge sharing** - Explain "why" in comments

## Testing Best Practices

### Writing Good Tests

**Arrange-Act-Assert Pattern:**
```python
def test_availability_with_multiple_allocations():
    # Arrange (Given)
    team_member = TeamMember(
        id="tm-1",
        allocations=[
            Allocation(percentage=60, project="Project A"),
            Allocation(percentage=20, project="Project B")
        ]
    )
    calculator = AvailabilityCalculator()

    # Act (When)
    result = calculator.calculate_availability(team_member)

    # Assert (Then)
    assert result.availability_percent == 20
    assert result.team_member_id == "tm-1"
```

**Test Names Should Read Like Documentation:**
```python
# GOOD - Describes scenario and expected outcome
def test_calculate_availability_returns_zero_when_fully_allocated()
def test_calculate_availability_includes_partial_week_allocations()
def test_calculate_availability_handles_overlapping_engagements()

# BAD - Vague, doesn't describe scenario
def test_availability()
def test_calculator()
def test_edge_case()
```

**Test One Thing:**
```python
# GOOD - Tests one scenario
def test_availability_is_zero_when_allocated_100_percent():
    team_member = create_team_member(allocation=100)
    result = calculator.calculate_availability(team_member)
    assert result.availability_percent == 0

# BAD - Tests multiple unrelated things
def test_calculator():
    # Tests zero allocation
    result1 = calculator.calculate_availability(member1)
    assert result1.availability_percent == 100

    # Tests full allocation
    result2 = calculator.calculate_availability(member2)
    assert result2.availability_percent == 0

    # Tests error handling
    with pytest.raises(ValueError):
        calculator.calculate_availability(None)
```

### Mocking Guidelines

**Only Mock External Dependencies:**
```python
# GOOD - Mock external service
@patch('capacity_planning.adapters.salesforce.SalesforceClient')
def test_fetch_engagements_from_salesforce(mock_sf_client):
    mock_sf_client.query.return_value = [...]
    fetcher = SalesforceEngagementFetcher(mock_sf_client)
    result = fetcher.fetch_engagements()
    assert len(result) == 5

# BAD - Mocking internal business logic
@patch('capacity_planning.services.AvailabilityCalculator')
def test_get_availability(mock_calculator):
    # This defeats the purpose - we're not testing anything!
    mock_calculator.calculate.return_value = 100
    result = service.get_availability()
    assert result == 100
```

**When to Mock:**
- External APIs (Salesforce, Greenhouse)
- Database calls (DynamoDB)
- File system operations
- Time/dates (for consistent tests)
- Do NOT mock internal domain logic
- Do NOT mock pure functions
- Do NOT mock value objects

### Test Fixtures and Factories

**Use Fixtures for Common Setup:**
```python
# conftest.py
@pytest.fixture
def sample_team_member():
    return TeamMember(
        id="tm-1",
        name="Jane Doe",
        practice="CAE",
        role="Architect"
    )

@pytest.fixture
def availability_calculator():
    return AvailabilityCalculator(
        rules=CapacityPlanningRules()
    )

# test_availability.py
def test_calculate_availability(sample_team_member, availability_calculator):
    result = availability_calculator.calculate_availability(sample_team_member)
    assert result.availability_percent == 100
```

**Use Factories for Variations:**
```python
def create_team_member(
    practice: str = "CAE",
    role: str = "Architect",
    allocation: int = 0
) -> TeamMember:
    return TeamMember(
        id=f"tm-{uuid.uuid4()}",
        practice=practice,
        role=role,
        allocations=[Allocation(percentage=allocation)] if allocation else []
    )

# Tests can easily create variations
def test_different_practices():
    cae_member = create_team_member(practice="CAE")
    dpe_member = create_team_member(practice="DPE")
    ...
```

## Refactoring Guidelines

### When Refactoring

**Always Follow This Order:**

1. **Acceptance tests pass** (baseline)
   ```bash
   pytest tests/acceptance/ --disable-warnings
   ```

2. **Make the change** (refactor)
   - Extract function/class
   - Rename variables
   - Simplify logic
   - Remove duplication

3. **Acceptance tests STILL pass** (verify)
   ```bash
   pytest tests/acceptance/ --disable-warnings
   ```

4. **Add unit tests** (if new structure warrants it)

### Refactoring Safety

**The Golden Rule:**
> If acceptance tests pass before and after, behavior is preserved.

**Safe Refactorings:**
- Extract function/class
- Rename variables/functions
- Move code to different files
- Simplify complex expressions
- Remove duplication
- Replace magic numbers with constants

**Risky Refactorings** (need extra care):
- Changing business logic calculations
- Modifying data transformations
- Altering API responses
- Updating database queries

### The Boy Scout Rule

**"Leave code better than you found it."**

When touching code, make small improvements:
- Rename confusing variables
- Extract magic numbers to constants
- Add type hints if missing
- Simplify complex conditionals
- Add docstrings if unclear

But keep changes **small and focused**:
- Don't refactor entire file when fixing a bug
- Don't change unrelated code
- Do make code clearer in the area you're working

## Code Review Guidelines

### For Authors

**Before Requesting Review:**
- All tests pass locally
- Code is self-documenting (clear names)
- PR description explains "why" not just "what"
- No commented-out code
- No debug print statements

**Responding to Feedback:**
- **Learn** - Ask questions if unclear
- **Collaborate** - Discuss trade-offs openly
- **Ship** - Don't let perfect block good
- **Track** - Create tickets for future improvements

### For Reviewers

**Review Focus Areas:**

1. **Correctness**
   - Does it solve the problem?
   - Are edge cases handled?
   - Do tests validate behavior?

2. **Clarity**
   - Can I understand what's happening?
   - Are names self-documenting?
   - Is the approach straightforward?

3. **Testing**
   - Are there tests?
   - Do they cover important cases?
   - Are they easy to understand?

4. **Patterns**
   - Does it follow our architecture principles?
   - Is it consistent with existing code?
   - Does it fit the domain model?

**Review Style:**

```markdown
# Educational Comments (teach, don't block)

Consider: This could be simplified using...
Question: Why did you choose this approach over...?
FYI: We typically use X pattern for this...
Nice: I like how you handled this edge case

# Avoid Blocking Comments

BAD: "This is wrong" → GOOD: "Consider this alternative because..."
BAD: "Style violation" → GOOD: "Our convention is X, see ARCHITECTURE.md"
BAD: "Needs more tests" → GOOD: "Could we add a test for the Y edge case?"

# Block Only for Critical Issues

BLOCKER: This will break production (security, data loss, etc)
BLOCKER: Tests are failing
BLOCKER: This violates a core architecture principle
```

**Ship Fast Mentality:**
- Minor issues: Comment + merge + ticket
- Medium issues: Discuss + decide (merge or fix?)
- Critical issues: Must fix before merge

## Common Workflows

### Adding a New Feature

```bash
# 1. Create feature branch
git checkout -b feature/add-skills-to-availability

# 2. Write acceptance test (BDD)
# File: tests/acceptance/test_skills_availability.py
def test_availability_includes_skills_data():
    # Given: Resources with skills
    # When: Fetching availability
    # Then: Response includes skills
    pass  # This will fail

# 3. Run acceptance test (expect failure)
pytest tests/acceptance/test_skills_availability.py
# FAILED - feature not implemented

# 4. Write unit tests (TDD)
# File: tests/unit/test_skill_model.py
def test_skill_has_name_and_proficiency():
    pass  # This will fail

# 5. Implement feature (Red-Green-Refactor)
# - Write minimal code to pass tests
# - Refactor for clarity
# - Repeat until acceptance test passes

# 6. Verify all tests pass
pytest tests/

# 7. Commit with clear message
git add .
git commit -m "feat(availability): add skills and certifications to resource data

- Added Skill and Certification domain models
- Extended TeamMember to include skills list
- Updated fetcher to parse skills from Salesforce
- Updated API response to include skills data

Acceptance tests validate end-to-end behavior."

# 8. Push and create PR
git push -u origin feature/add-skills-to-availability
gh pr create --title "Add skills to availability data" --body "..."

# 9. Address review feedback
# - Make changes based on educational feedback
# - Create tickets for future improvements

# 10. Merge and deploy
gh pr merge --squash
```

### Fixing a Bug

```bash
# 1. Create bug fix branch
git checkout -b fix/allocation-calculation-rounding

# 2. Write failing test that reproduces bug
def test_allocation_rounds_correctly_for_partial_weeks():
    # Given: Engagement with 2.5 days scheduled
    # When: Calculating allocation
    # Then: Should round to nearest percent
    engagement = create_engagement(scheduled_days=2.5)
    result = calculator.calculate_allocation(engagement)
    assert result.percentage == 50  # Currently fails, returns 49

# 3. Run test (expect failure)
pytest tests/unit/test_allocation.py::test_allocation_rounds_correctly
# FAILED - AssertionError: assert 49 == 50

# 4. Fix the bug
# Update calculation to use proper rounding

# 5. Run test (expect success)
pytest tests/unit/test_allocation.py::test_allocation_rounds_correctly
# PASSED

# 6. Run all tests
pytest tests/
# All tests pass

# 7. Commit and PR
git commit -m "fix(allocation): correct rounding for partial week allocations"
```

### Refactoring Existing Code

```bash
# 1. Ensure acceptance tests pass (baseline)
pytest tests/acceptance/
# All pass

# 2. Create refactoring branch
git checkout -b refactor/extract-availability-service

# 3. Add unit tests for new structure (if needed)
def test_availability_service_calculates_correctly():
    pass

# 4. Refactor in small steps
# - Extract AvailabilityService
# - Move logic from activity_utils
# - Update imports

# 5. After EACH step, verify acceptance tests still pass
pytest tests/acceptance/
# All pass (behavior preserved)

# 6. Continue until refactoring complete

# 7. Clean up old code

# 8. Final verification
pytest tests/
# All pass

# 9. Commit and PR
git commit -m "refactor(services): extract AvailabilityService from activity_utils

Moved availability calculation logic into focused domain service.
No behavior changes - all acceptance tests pass unchanged."
```

## Key Principles Summary

1. **Tests define "done"** - Acceptance tests pass = feature complete
2. **Red-Green-Refactor** - Write failing test, minimal implementation, improve
3. **Test behavior, not implementation** - Tests should survive refactoring
4. **Ship fast, learn continuously** - Don't let perfection block progress
5. **Leave code better** - Small improvements compound
6. **Educational reviews** - Help each other grow
7. **Main is always deployable** - Every merge should be production-ready
8. **Simplicity wins** - Clear code beats clever code

## Common Pitfalls to Avoid

- **Writing code before tests** - Leads to hard-to-test code
- **Testing implementation details** - Tests break during refactoring
- **Mocking internal logic** - Defeats purpose of testing
- **Unclear commit messages** - Hard to understand history
- **Large PRs** - Difficult to review effectively
- **Skipping tests** - "I'll add them later" (you won't)
- **Premature optimization** - Make it work, then make it fast
- **Over-engineering** - Build what's needed, not what might be needed

## Questions?

- See `architecture-guidelines.md` for design principles
- See project `CLAUDE.md` for project-specific patterns
- See `docs/development_guide.md` for setup and tooling
