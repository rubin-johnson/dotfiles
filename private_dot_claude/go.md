# Go Development

## Toolchain

```bash
go version       # Check Go version
go env GOPATH    # Verify workspace
golangci-lint --version
```

## Module Management

```bash
go mod init <module-path>   # Initialize module (e.g. github.com/user/repo)
go mod tidy                 # Add missing, remove unused dependencies
go get <pkg>@<version>      # Add/upgrade a dependency
go mod download             # Pre-fetch module cache
```

Always commit both `go.mod` and `go.sum`.

## Build & Run

```bash
go build ./...              # Build all packages
go run .                    # Run main package
go vet ./...                # Static analysis (run before lint)
gofmt -w .                  # Format all files (or use goimports)
golangci-lint run           # Full lint suite
```

## Testing

```bash
go test ./...               # Run all tests
go test -v ./...            # Verbose output
go test -run TestFoo ./...  # Run specific test
go test -cover ./...        # Coverage summary
go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out
```

Go test files live alongside source: `foo.go` → `foo_test.go`.

Use `t.Helper()` in test helpers so failures report the caller's line, not the helper's.

## Error Handling

- Always check errors — never `_` an error return unless intentionally discarding it with a comment
- Wrap errors with context: `fmt.Errorf("loading config: %w", err)`
- Unwrap with `errors.Is` / `errors.As`, not string matching
- Sentinel errors: `var ErrNotFound = errors.New("not found")`

## Idioms to Know

- Prefer returning `(value, error)` over panicking
- `defer` for cleanup: runs even on early return, in LIFO order
- Zero values are useful: `var mu sync.Mutex` is ready to use
- Interfaces are satisfied implicitly — define them at the consumer, not the producer
- Use `context.Context` as the first parameter for cancellable/timeout-aware functions
- Short variable declarations (`:=`) inside functions; `var` at package scope

## Project Layout (standard)

```
cmd/          # Entry points (one dir per binary)
internal/     # Packages private to this module
pkg/          # Packages safe to import externally (optional)
```

`internal/` is enforced by the compiler — external modules cannot import it.

## Linting

`golangci-lint` is installed. Run it before committing. Default config covers:
- `errcheck` — unchecked errors
- `govet` — suspicious constructs
- `staticcheck` — advanced static analysis

Add `.golangci.yml` to project root to customize enabled linters.
