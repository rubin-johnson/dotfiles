# Python Toolchain Requirements

## Package & Environment Management — NO EXCEPTIONS

**ALWAYS use:**
- **pyenv** for Python version management
- **uv** for package/dependency management and virtual environments

**NEVER use:**
- pip (use `uv pip` instead)
- pip-tools
- poetry
- pipenv
- venv module (use `uv venv` instead)

## Before Any Python Task

```bash
pyenv version    # Check Python version
uv --version     # Verify uv is available
```

If you catch yourself about to use pip, STOP. Use uv.

## Common uv Commands

```bash
uv venv                              # Create virtual environment
uv pip install <package>             # Install a package
uv pip install -r requirements.txt   # Install from requirements file
uv run <script.py>                   # Run script in project environment
uv add <package>                     # Add to project dependencies (uv projects)
```
