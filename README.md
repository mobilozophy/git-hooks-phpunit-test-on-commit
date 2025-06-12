# Git Hooks for PHP Unit Testing

This repository contains Git hooks that automatically run PHP Unit tests before commits to ensure code quality and maintain development standards in your PHP/Laravel projects.

## Why Use This?

This tool acts as a **quality gate** at the commit level, preventing untested or breaking code from entering your repository. It provides:

- **Early Detection**: Catch failing tests immediately, before they reach your main branch
- **Cleaner Git History**: Every commit in your history has passed tests
- **Team Protection**: Prevents teammates from pulling broken code
- **Development Discipline**: Encourages writing and maintaining tests
- **Faster Debugging**: Test results are recorded with each commit for easy tracking

**Think of it as a safety net** - it's much easier to fix a failing test before you commit than to hunt down which commit broke the build later.

## What This Does

- **pre-commit**: Runs PHP Unit tests before allowing a commit. If tests fail, the commit is aborted.
- **post-commit**: Appends PHP Unit test results to the commit message for tracking purposes.

## Quick Installation (One-liner)

Run this command from your project's root directory:

```bash
curl -sSL https://raw.githubusercontent.com/mobilozophy/git-hooks-phpunit-test-on-commit/main/install.sh | bash -s -- --remote-install
```

## Manual Installation

### Step 1: Clone and Install

From your project's root directory:

```bash
# Clone the hooks repository
git clone https://github.com/mobilozophy/git-hooks-phpunit-test-on-commit.git .git-hooks-temp

# Install the hooks
./.git-hooks-temp/install.sh

# Clean up
rm -rf .git-hooks-temp
```

### Step 2: Alternative - Download and Install

```bash
# Download the repository as a zip
curl -L https://github.com/mobilozophy/git-hooks-phpunit-test-on-commit/archive/main.zip -o git-hooks.zip

# Extract and install
unzip git-hooks.zip
cd git-hooks-phpunit-test-on-commit-main
./install.sh

# Clean up
cd ..
rm -rf git-hooks-phpunit-test-on-commit-main git-hooks.zip
```

## Requirements

- PHP project with Unit tests
- Laravel project with `php artisan test --testsuite=Unit` command available
- Git repository initialized in your project
- Unix-like system (Linux, macOS, WSL)

## How It Works

### Pre-commit Hook
The pre-commit hook:
1. Checks for skip-tests flags (see "Skipping Tests" section below)
2. Temporarily stashes any unstaged changes
3. Runs `php artisan test --testsuite=Unit`
4. Prevents the commit if tests fail
5. Restores any stashed changes
6. Allows the commit if all tests pass

### Post-commit Hook
The post-commit hook:
1. Automatically appends test results to your commit message
2. Provides a record of which tests passed with each commit
3. Helps maintain development history and debugging

## Best Practices

### When This Works Best
- **Individual Development**: Perfect for personal projects and feature branches
- **Small to Medium Teams**: Ensures everyone commits working code
- **Fast Test Suites**: Works best when unit tests run in under 30 seconds
- **TDD/BDD Workflows**: Complements test-driven development practices

### Team Workflow Integration
1. **Install on all developer machines** for consistency
2. **Use with feature branches** - let developers fix issues before merging
3. **Combine with CI/CD** - this catches issues early, CI/CD provides comprehensive testing
4. **Document skip policies** - make it clear when skipping tests is acceptable

### Performance Considerations
- **Test Suite Speed**: Hook runs on every commit, so fast tests are crucial
- **Only Unit Tests**: Runs `--testsuite=Unit` to avoid slow integration/feature tests
- **Stashing Strategy**: Temporarily stashes unstaged changes to test only committed code

## Relationship to CI/CD

This tool **complements** (doesn't replace) your CI/CD pipeline:

| Git Hooks (This Tool) | CI/CD Pipeline |
|----------------------|----------------|
| Runs on developer machine | Runs on dedicated servers |
| Fast unit tests only | Full test suite + integration tests |
| Prevents bad commits | Prevents bad deployments |
| Individual developer feedback | Team/deployment feedback |
| Works offline | Requires server infrastructure |

**Use both together** for maximum code quality!

## Skipping Tests

There are several ways to skip tests when appropriate (e.g., documentation changes, quick fixes, WIP commits):

### Method 1: Commit Message Flag (Recommended for Terminal)

Include `[skip-tests]` or `--skip-tests` in your commit message:

```bash
git commit -m "Update documentation [skip-tests]"
git commit -m "Quick typo fix --skip-tests"
git commit -m "WIP: experimental feature [skip-tests]"
```

**Note**: This method works best when using `git commit -m` directly in terminal.

### Method 2: Environment Variable (Recommended for IDEs)

```bash
SKIP_TESTS=true git commit -m "Your commit message"
```

**Note**: This method is most reliable when using IDEs, GUI clients, or complex git operations.

### Method 3: Emergency Bypass (Use Sparingly)

In rare emergency situations, you can bypass ALL git hooks:

```bash
git commit --no-verify -m "Emergency fix - server down"
```

**Note**: `--no-verify` bypasses ALL hooks, not just tests. The flag methods above are preferred as they only skip tests while maintaining other hook functionality.

## When to Skip Tests

**✅ Good reasons to skip tests:**
- Documentation-only changes
- README updates
- Configuration file changes
- Quick typo fixes
- Work-in-progress commits
- Emergency hotfixes (when server is down)

**❌ Avoid skipping tests for:**
- New features
- Bug fixes
- Code refactoring
- Database migrations
- API changes

## Uninstalling

To remove the hooks from your project:

```bash
# Remove the hook symlinks
rm .git/hooks/pre-commit .git/hooks/post-commit

# Remove the git-hooks directory if it exists
rm -rf git-hooks
```

## Troubleshooting

If you encounter any issues with the Git hooks:

1. **Permission Issues**: Ensure hooks are executable
   ```bash
   chmod +x .git/hooks/pre-commit .git/hooks/post-commit
   ```

2. **Hook Not Found**: Check that hooks exist in `.git/hooks/` directory
   ```bash
   ls -la .git/hooks/
   ```

3. **Test Command Fails**: Ensure your project supports `php artisan test --testsuite=Unit`
   ```bash
   # Test the command manually
   php artisan test --testsuite=Unit
   ```

4. **Git Directory Issues**: Make sure you're in the root of a Git repository
   ```bash
   git status
   ```

## Examples

```bash
# Normal commit (runs tests)
git commit -m "Add user authentication feature"

# Skip tests for documentation
git commit -m "Update API documentation [skip-tests]"

# Skip tests with environment variable
SKIP_TESTS=true git commit -m "Update composer dependencies"

# Emergency bypass (use sparingly)
git commit --no-verify -m "Hotfix: critical security patch"
```

## Advanced Usage

### Customizing Test Commands

To modify which tests run, edit the `pre-commit` hook and change this line:
```bash
php artisan test --testsuite=Unit > test_output.txt 2>&1
```

Examples:
```bash
# Run all tests (slower)
php artisan test > test_output.txt 2>&1

# Run specific test groups
php artisan test --group=unit,integration > test_output.txt 2>&1

# Run tests with different output format
php artisan test --testsuite=Unit --compact > test_output.txt 2>&1
```

### Team Configuration

For teams, consider creating a shared configuration:

1. **Document your skip policies** in your project's README
2. **Set team standards** for when tests can be skipped
3. **Consider branch-specific rules** (stricter on main/develop branches)
4. **Review test results** in commit messages during code reviews

## Contributing

Found a bug or want to contribute? Visit the [GitHub repository](https://github.com/mobilozophy/git-hooks-phpunit-test-on-commit) to report issues or submit pull requests. 