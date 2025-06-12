#!/bin/bash

# Check if this is a remote install
REMOTE_INSTALL=false
if [ "$1" = "--remote-install" ]; then
    REMOTE_INSTALL=true
fi

# Function to install hooks
install_hooks() {
    local HOOKS_DIR="$1"
    
    echo "Setting up Git hooks..."
    echo "DEBUG: Current working directory: $(pwd)"
    echo "DEBUG: Hooks directory parameter: $HOOKS_DIR"
    echo "DEBUG: Checking for .git directory: $(ls -la | grep -E '^d.*\.git$' || echo 'NOT FOUND')"
    
    # Make hooks executable
    chmod +x "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/post-commit"
    
    # Check if Git hooks directory exists
    GIT_HOOKS_DIR=".git/hooks"
    echo "DEBUG: Looking for Git hooks directory at: $GIT_HOOKS_DIR"
    echo "DEBUG: Full path would be: $(pwd)/$GIT_HOOKS_DIR"
    echo "DEBUG: Directory exists check: $([ -d "$GIT_HOOKS_DIR" ] && echo 'YES' || echo 'NO')"
    echo "DEBUG: Contents of .git/: $(ls -la .git/ 2>/dev/null | head -5 || echo 'Cannot list .git directory')"
    
    if [ ! -d "$GIT_HOOKS_DIR" ]; then
        echo "DEBUG: .git/hooks directory not found!"
        echo "DEBUG: Attempting to create it..."
        mkdir -p "$GIT_HOOKS_DIR"
        if [ $? -eq 0 ]; then
            echo "DEBUG: Successfully created .git/hooks directory"
        else
            echo "Error: Could not create .git/hooks directory. Make sure you're in the root of a Git repository."
            exit 1
        fi
    else
        echo "DEBUG: .git/hooks directory found successfully"
    fi
    
    # Create symlink to pre-commit hook
    echo "DEBUG: Creating symlink: ln -sf ../../git-hooks/pre-commit $GIT_HOOKS_DIR/pre-commit"
    ln -sf "../../git-hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    
    # Create symlink to post-commit hook
    echo "DEBUG: Creating symlink: ln -sf ../../git-hooks/post-commit $GIT_HOOKS_DIR/post-commit"
    ln -sf "../../git-hooks/post-commit" "$GIT_HOOKS_DIR/post-commit"
    
    echo "DEBUG: Verifying symlinks:"
    echo "DEBUG: pre-commit link: $(ls -la $GIT_HOOKS_DIR/pre-commit 2>/dev/null || echo 'NOT FOUND')"
    echo "DEBUG: post-commit link: $(ls -la $GIT_HOOKS_DIR/post-commit 2>/dev/null || echo 'NOT FOUND')"
    
    echo -e "\033[0;32mGit hooks successfully installed!\033[0m"
    echo "The pre-commit hook will now run PHP unit tests before each commit."
    echo "The post-commit hook will append test results to your commit message."
    echo ""
    echo -e "\033[0;33mTip:\033[0m You can skip tests by including [skip-tests] or --skip-tests in your commit message:"
    echo "  git commit -m 'Quick documentation fix [skip-tests]'"
    echo "  git commit -m 'WIP: new feature --skip-tests'"
    echo "Or use: SKIP_TESTS=true git commit -m 'Your message'"
}

if [ "$REMOTE_INSTALL" = true ]; then
    # Remote installation - download and set up hooks
    echo "Performing remote installation..."
    echo "DEBUG: Starting directory: $(pwd)"
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo "Error: Not in a Git repository. Please run this from your project's root directory."
        echo "DEBUG: Contents of current directory:"
        ls -la | head -10
        exit 1
    fi
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    echo "DEBUG: Created temp directory: $TEMP_DIR"
    
    # Store original directory
    ORIGINAL_DIR=$(pwd)
    echo "DEBUG: Original directory: $ORIGINAL_DIR"
    
    cd "$TEMP_DIR"
    echo "DEBUG: Changed to temp directory: $(pwd)"
    
    # Download the repository
    echo "Downloading git hooks..."
    curl -L https://github.com/mobilozophy/git-hooks-phpunit-test-on-commit/archive/main.zip -o hooks.zip
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download git hooks repository."
        cd "$ORIGINAL_DIR"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    echo "DEBUG: Download completed, extracting..."
    # Extract
    unzip -q hooks.zip
    echo "DEBUG: Extraction completed"
    echo "DEBUG: Contents of temp directory: $(ls -la)"
    
    # Go back to original directory
    cd "$ORIGINAL_DIR"
    echo "DEBUG: Back to original directory: $(pwd)"
    
    # Create git-hooks directory in project
    mkdir -p git-hooks
    echo "DEBUG: Created git-hooks directory"
    
    # Copy hooks to project
    echo "DEBUG: Copying hooks from $TEMP_DIR/git-hooks-phpunit-test-on-commit-main/"
    cp "$TEMP_DIR/git-hooks-phpunit-test-on-commit-main/pre-commit" git-hooks/
    cp "$TEMP_DIR/git-hooks-phpunit-test-on-commit-main/post-commit" git-hooks/
    echo "DEBUG: Hooks copied successfully"
    echo "DEBUG: Contents of git-hooks directory: $(ls -la git-hooks/)"
    
    # Install hooks
    install_hooks "git-hooks"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    echo "DEBUG: Cleaned up temp directory"
    
    echo -e "\033[0;32mRemote installation completed successfully!\033[0m"
    
else
    # Local installation - original behavior
    SCRIPT_DIR=$(dirname "$(realpath "$0")")
    if [ "$(basename "$SCRIPT_DIR")" != "git-hooks" ]; then
        echo "Please run this script from the project root directory using: ./git-hooks/install.sh"
        echo "Or use remote installation: curl -sSL https://raw.githubusercontent.com/mobilozophy/git-hooks-phpunit-test-on-commit/main/install.sh | bash -s -- --remote-install"
        exit 1
    fi
    
    install_hooks "$SCRIPT_DIR"
fi

exit 0 