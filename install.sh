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
    
    # Make hooks executable
    chmod +x "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/post-commit"
    
    # Check if Git hooks directory exists
    GIT_HOOKS_DIR=".git/hooks"
    if [ ! -d "$GIT_HOOKS_DIR" ]; then
        echo "Error: .git/hooks directory not found. Make sure you're in the root of a Git repository."
        exit 1
    fi
    
    # Create symlink to pre-commit hook
    ln -sf "../../git-hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    
    # Create symlink to post-commit hook
    ln -sf "../../git-hooks/post-commit" "$GIT_HOOKS_DIR/post-commit"
    
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
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo "Error: Not in a Git repository. Please run this from your project's root directory."
        exit 1
    fi
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download the repository
    echo "Downloading git hooks..."
    curl -L https://github.com/mobilozophy/git-hooks-phpunit-test-on-commit/archive/main.zip -o hooks.zip
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download git hooks repository."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Extract
    unzip -q hooks.zip
    cd git-hooks-phpunit-test-on-commit-main
    
    # Go back to original directory
    cd - > /dev/null
    
    # Create git-hooks directory in project
    mkdir -p git-hooks
    
    # Copy hooks to project
    cp "$TEMP_DIR/git-hooks-phpunit-test-on-commit-main/pre-commit" git-hooks/
    cp "$TEMP_DIR/git-hooks-phpunit-test-on-commit-main/post-commit" git-hooks/
    
    # Install hooks
    install_hooks "git-hooks"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
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