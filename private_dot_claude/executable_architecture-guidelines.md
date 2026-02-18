---
inclusion: manual
contextKey: architecture
---

# Architecture Principles

## Core Design Philosophy

**Good software is simple, easy to maintain, and easy to extend.**

This is the guiding principle that informs every architecture and engineering decision.

### Simplicity First

- **Add only what is needed** - Resist the temptation to build for hypothetical future requirements
- **Clear over clever** - Prefer straightforward solutions that are easy to understand
- **Minimal dependencies** - Each dependency is a liability; choose carefully
- **Small, focused modules** - Each component should do one thing well

### Maintainability

- **Well-organized structure** - Logical file and module organization that's easy to navigate
- **Consistent patterns** - Follow established conventions throughout the codebase
- **Comprehensive tests** - Tests document behavior and enable confident refactoring
- **Clear documentation** - Code should be self-documenting; comments explain "why" not "what"

### Extensibility

- **Interface design** - Define interfaces that can have multiple implementations
- **Dependency injection** - Components receive dependencies rather than creating them
- **Open for extension, closed for modification** - Add new behavior without changing existing code
- **Design for the future, build for now** - Create extension points without implementing unused features

### Proven Patterns

We follow established software architecture patterns:

- **Layered architecture** - Clear separation between interface, application, and domain layers
- **Dependency inversion** - High-level modules don't depend on low-level modules; both depend on abstractions
- **Single responsibility** - Each module, struct, and function has one reason to change
- **Domain-driven design** - Business logic lives in the core domain, isolated from infrastructure concerns

## When NOT to Add Complexity

### Avoid Premature Abstraction

- Don't create abstractions until you have 2-3 concrete use cases
- Don't add configuration options "just in case"
- Don't implement features before they're needed
- Don't optimize before measuring performance problems

### Avoid Over-Engineering

- Don't add layers that don't provide clear value
- Don't create elaborate type hierarchies for simple concepts
- Don't use complex patterns when simple functions suffice
- Don't add dependencies for trivial functionality

### When to Add Abstraction

- When you have multiple concrete implementations
- When you need to swap implementations (testing, different environments)
- When the abstraction makes the code simpler, not more complex
- When it enables extension without modification

### The Rule of Three

Wait until you have three similar pieces of code before extracting an abstraction. Two instances might be coincidence; three indicates a pattern worth abstracting.

## Key Takeaways

1. **Simplicity is the ultimate sophistication** - Simple code is easier to understand, test, and maintain
2. **Add only what is needed** - Build for today's requirements, design for tomorrow's possibilities
3. **Follow the Rule of Three** - Wait for patterns to emerge before abstracting
4. **Test thoroughly** - Tests are documentation and enable confident refactoring
5. **Maintain compatibility** - New features are additive, not breaking
6. **Layers depend downward** - Never let core depend on interface layers
7. **Clear organization** - Well-structured code is easier to navigate and maintain
8. **Document intent** - Explain "why" not "what"
9. **Handle errors explicitly** - Add context to every error
10. **Keep modules focused** - Each component should have a single, clear responsibility
