# Getting Started with Python Collab Template

This guide walks you through using this template to create a new Python project.

## Prerequisites

- Python 3.9 or higher
- Git
- GitHub account (for template usage)

## Creating a Project from This Template

### Step 1: Create Repository from Template

1. Go to this template repository on GitHub
2. Click **"Use this template"** button
3. Choose **"Create a new repository"**
4. Fill in your repository details:
   - Repository name (e.g., `my-awesome-project`)
   - Description
   - Public/Private visibility

### Step 2: Clone and Initialize

1. Clone your new repository:
   ```bash
   git clone https://github.com/your-username/your-project-name.git
   cd your-project-name
   ```

2. Initialize your project:
   ```bash
   make init
   ```

3. Follow the interactive prompts:
   - **Project name**: Enter your project name (e.g., "My Awesome Project")
   - **Description**: Brief description of your project
   - **Author info**: Your name and email (auto-detected from git config)
   - **Example code**: Choose how to handle example code:
     - Keep (useful for reference)
     - Minimal (basic working example)
     - Remove (clean slate)
   - **Documentation**: Set up MkDocs documentation (default: yes)
   - **Pre-commit hooks**: Enable quality checks on commit (default: yes)

### Step 3: Verify Setup

After initialization, verify everything works:

```bash
# Run all quality checks
make check

# If you enabled documentation
make docs-serve
```

## Project Structure After Initialization

Your initialized project will have:

```
your-project-name/
├── your_project_name/          # Main package (renamed from src/)
├── tests/                      # Test files
├── docs/                       # Documentation (if enabled)
├── .github/workflows/          # CI/CD workflows
├── pyproject.toml             # Project configuration
├── Makefile                   # Development commands
└── README.md                  # Project documentation
```

## Development Workflow

### Daily Development

1. Make your changes to the code
2. Add or update tests
3. Run quality checks:
   ```bash
   make check
   ```
4. Update documentation if needed
5. Commit and push

### Available Commands

Your project comes with these make targets:

- `make setup` - Set up development environment
- `make test` - Run tests with coverage
- `make lint` - Run linting with auto-fix
- `make format` - Format code
- `make ty` - Run type checking
- `make check` - Run all quality checks
- `make docs-serve` - Serve documentation locally (if enabled)
- `make docs-build` - Build documentation (if enabled)
- `make docs-check` - Validate documentation build (if enabled)

### Documentation (If Enabled)

If you chose to set up documentation:

1. **Local development**:
   ```bash
   make docs-serve
   # Visit http://localhost:8000
   ```

2. **Content organization**:
   - `docs/index.md` - Project homepage
   - `docs/getting-started.md` - User guide
   - `docs/reference/api.md` - Auto-generated API docs

3. **GitHub Pages setup**:
   - Go to repository Settings → Pages
   - Set source to "GitHub Actions"
   - Documentation will auto-deploy on main branch pushes

### CI/CD

Your project includes GitHub Actions workflows:

- **Quality checks** (`tests.yml`): Runs on PRs and pushes
- **Documentation** (`docs.yml`): Deploys docs to GitHub Pages (if enabled)

## Next Steps

1. **Update README.md** with project-specific information
2. **Add your code** in the main package directory
3. **Write tests** for your functionality
4. **Update documentation** to describe your project
5. **Set up GitHub Pages** (if documentation enabled)
6. **Configure repository settings** (branch protection, etc.)

## Tips

- The template includes example code you can reference or remove
- All configuration follows modern Python best practices
- The documentation system auto-generates API docs from docstrings
- Pre-commit hooks ensure code quality before commits
- Use `make` commands for consistent development workflow