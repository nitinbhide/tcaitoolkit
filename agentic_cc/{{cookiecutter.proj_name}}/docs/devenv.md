# {{cookiecutter.proj_full_name}} Development Environment Setup

Use this checklist for onboarding a new developer:

1. Review the tech stack in `docs/design/ARCHITECTURE.md`.
2. Verify required tools are installed (compiler/interpreter/build tools/dependencies).
3. If anything is missing:
    - Ask whether it is already installed and where.
    - If not installed, guide setup of required software and packages.
4. Create `environment.bat` (Windows) or `environment.sh` (Unix) in the project root.
5. Ensure the environment file:
    - Adds required tool paths.
    - Sets required environment variables.
    - Defines repository paths (root, source, test).
    - Includes any stack-specific best practices.
6. Do not commit the environment file; add it to version control ignore rules.

## Executing Commands with Environment Configuration

Always chain the environment setup script before executing commands to ensure required variables and paths are properly configured.

### Windows (PowerShell)
```powershell
# Basic command execution with environment setup
.\environment.bat && command-here

# Examples:
.\environment.bat && ant build
.\environment.bat && ant clean build test
.\environment.bat && java -version
```

### Unix/Linux (Bash)
```bash
# Basic command execution with environment setup
source ./environment.sh && command-here

# Examples:
source ./environment.sh && python -m pytest tests/
source ./environment.sh && python src/aicalc/main.py
```

### Best Practices
- **Always chain before executing**: Use `&&` (PowerShell/Bash) to ensure environment loads before the command runs.
- **Verify environment**: After running the environment script, it should display confirmation output (e.g., "Environment configured").
- **Project-specific setup**: Navigate to the project root before executing the environment script.
- **CI/CD pipelines**: Include the environment chaining step in all build and test scripts.
    
    