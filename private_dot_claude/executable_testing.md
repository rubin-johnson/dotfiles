---
inclusion: manual
contextKey: testing
---

# Testing Philosophy & Methodology

## Core Philosophy

**Testing is not optional—it's how we define and verify behavior.**

We follow a **BDD-first, TDD-driven** approach that emphasizes behavior over implementation. Tests are executable specifications that guide development and enable confident refactoring.

### What Makes a Good Test?

**Understandable** - Describes behavior, not implementation. Tests should read like specifications.

**Maintainable** - Easy to change without losing intent. Tests should survive refactoring.

**Repeatable** - Deterministic results every time, regardless of order or environment.

**Atomic** - Isolated with no side effects. Tests can run in parallel or any order.

**Necessary** - Guides development decisions. No tests for test's sake.

**Granular** - Small, focused, single assertion. Clear pass/fail with obvious failure reason.

**Fast** - Efficient execution enables frequent running. Keep tests simple and focused.

**First** - Written before implementation. This is fundamental to achieving all other properties.

### Why BDD/TDD?

- **Clear Requirements** - Acceptance tests are executable specifications
- **Design Feedback** - Writing tests first reveals design issues early
- **Confidence** - Comprehensive tests enable fearless refactoring
- **Documentation** - Tests document expected behavior
- **Regression Prevention** - Tests catch breaking changes immediately

## Testing Hierarchy

### 1. Acceptance Tests (Highest Level)

**Purpose**: Validate complete user workflows and business requirements from an end-user perspective.

**Key Characteristics**:

- Describe user actions and expected outcomes
- Test complete features end-to-end
- Abstract away implementation details
- Written in behavior-driven language (Given-When-Then)
- Use DSL for business-readable tests

**When to Write**: ALWAYS write acceptance tests FIRST before implementing any new feature. They define the behavior you're building.

### 2. Integration Tests (Middle Level)

**Purpose**: Test component interactions, module boundaries, and integrations.

**Key Characteristics**:

- Test multiple components working together
- Verify trait implementations
- Test file I/O, external processes
- Use real dependencies where practical

**When to Write**: After acceptance tests define behavior, when testing trait implementations and component boundaries.

### 3. Unit Tests (Lowest Level)

**Purpose**: Test individual functions and methods in isolation.

**Key Characteristics**:

- Test single functions/methods
- Fast execution (< 1ms per test)
- No external dependencies
- Use mocks for dependencies

**When to Write**: After integration tests pass, for pure functions, edge cases, and error conditions.

## TDD Cycle (Red-Green-Refactor)

The TDD cycle is a disciplined approach ensuring every line of code is tested and necessary.

### Step 1: Red (Write Failing Test)

Write the smallest possible test that fails for the right reason.

**Key Rules**:

- Test must fail initially with meaningful failure
- Test should be specific and focused
- Write only one failing test at a time

### Step 2: Green (Make It Pass)

Write the minimal code to make the test pass.

**Key Rules**:

- Write simplest code that passes
- Don't add features not covered by tests
- Avoid premature optimization
- Keep implementation focused

### Step 3: Refactor (Improve Code)

Improve code quality while keeping tests green.

**Key Rules**:

- All tests must remain green
- Improve readability and maintainability
- Extract duplicated code
- Run tests after each change

## BDD Workflow

Behavior-Driven Development ensures we build the right thing by starting with user stories and acceptance criteria.

### 1. Interpret Defined Behavior

Start with user stories and acceptance criteria written in business language:

```
As a [role]
I want to [action]
So that [benefit]

Given [context]
When [action]
Then [expected outcome]
```

### 2. Write Acceptance Test

Translate behavior into executable test using the DSL (Domain-Specific Language).

**Key Principle**: The acceptance test IS the specification. If the test passes, the feature is complete.

### 3. Implement with TDD

Use TDD cycle to implement the behavior:

1. Write unit test for first component (Red)
2. Implement minimal code (Green)
3. Refactor
4. Repeat until acceptance test passes

**Bottom-Up Approach**: Start with lowest-level components, build up to higher-level integration, acceptance test validates the complete feature.

### 4. Verify Behavior

Run acceptance test to confirm behavior is complete. Success means acceptance test passes, all unit/integration tests pass, and code is clean and maintainable.

## Acceptance Test DSL Pattern

### 4-Layer Architecture

Use a **4-layer architecture** for acceptance tests that separates concerns and keeps tests business-readable:

```
┌──────────────────────────────────────────────────────┐
│  Layer 1: Test Scenarios                             │
│  - Given-When-Then format                            │
│  - Business-focused scenarios                        │
│  - Uses DSL methods                                  │
└──────────────────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────┐
│  Layer 2: Domain-Specific Language (DSL)             │
│  - Business-readable methods                         │
│  - Manages test state                                │
│  - Orchestrates protocol driver                      │
└──────────────────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────┐
│  Layer 3: Protocol Driver                            │
│  - Mocks external dependencies only                  │
│  - Executes real business logic                      │
│  - Transforms results for assertions                 │
└──────────────────────────────────────────────────────┘
                     ↓
┌──────────────────────────────────────────────────────┐
│  Layer 4: System Under Test (Real Business Logic)    │
│  - Production code runs unmodified                   │
│  - All domain logic executes normally                │
└──────────────────────────────────────────────────────┘
```

**Key Principle**: Mock only external dependencies (file system, cargo commands). Run real business logic.

### Layer Responsibilities

**Layer 1 (Test Scenarios)**: Written in pure business language using Given-When-Then structure. No technical implementation details.

**Layer 2 (DSL)**: Provides business-readable methods, manages test state, translates business actions to technical operations.

**Layer 3 (Protocol Driver)**: Mocks only external dependencies, executes real business logic, provides realistic test data.

**Layer 4 (System Under Test)**: Unmodified production code with real business logic execution.

### DSL Design Principles

**Business Readability Over Technical Accuracy** - Write tests in business language, not technical implementation language.

**Composability and Reusability** - Design small, focused methods that work well together.

**State Management** - DSL maintains state internally. Given methods add to state, When methods execute and store results, Then methods assert against stored results.

**Naming Conventions**:

- Given methods: `[entity]_exists()`, `[entity]_has_[property]()`
- When methods: `[actor]_[action]()`, `[action]_is_performed()`
- Then methods: `[property]_equals()`, `[property]_contains()`

**Keep DSL Focused** - Small domain: 6-12 methods, Medium: 12-20, Large: 20-30 (consider splitting).

## Test Organization

### Structure

- **Unit tests** - `#[cfg(test)]` modules within source files
- **Integration tests** - `tests/` directory
- **Acceptance tests** - `tests/acceptance/` directory
- **Test helpers** (DSL, builders, mocks) - `tests/helpers/`
- **Fixtures** - `tests/fixtures/`

### Naming Conventions

- **Test functions**: Descriptive snake_case names that explain the scenario
- **Test modules**: Named after the feature being tested
- **Test files**: Match source file names for integration tests, use `test_story_` prefix for acceptance tests

## Best Practices

### DO

**Architecture & Design**:

- Write acceptance tests FIRST
- Start with user stories
- Test behavior, not implementation
- Follow the 4-layer architecture
- Use TDD cycle religiously

**Code Quality**:

- Use descriptive test names
- Keep tests simple and focused
- Mock only external dependencies
- Test error conditions
- Use builders for complex test data

**Maintenance**:

- Run tests frequently
- Maintain fast test execution
- Refactor duplicate setup into DSL
- Keep tests independent
- Remove unused DSL methods

### DON'T

**Architecture Violations**:

- Don't mock business logic
- Don't bypass the DSL in acceptance tests
- Don't put business logic in protocol driver
- Don't mix test concerns across layers

**Code Anti-Patterns**:

- Don't skip tests for "simple" code
- Don't test private implementation details
- Don't write tests that depend on each other
- Don't use random data without seeding
- Don't ignore flaky tests
- Don't test external services directly
- Don't write slow tests
- Don't duplicate test logic

**Test Design**:

- Don't test multiple scenarios in one test
- Don't create dependencies between tests
- Don't use overly generic test names
- Don't skip the Given-When-Then structure

## Summary

Follow this approach for all development:

1. **Start with behavior** - Define acceptance criteria from user stories
2. **Write acceptance test FIRST** - Executable specification that defines done
3. **TDD implementation** - Red-Green-Refactor for all code
4. **Verify behavior** - Acceptance test passes = feature complete
5. **Maintain coverage** - Keep tests green, fast, and comprehensive

This BDD-first, TDD-driven approach ensures clear requirements, high confidence, maintainability, fast feedback, and living documentation.

For detailed code examples and implementation patterns, see project-specific testing documentation.
