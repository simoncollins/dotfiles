# Show git status with concise, colorized output
gst() {
    git status --short --branch
}

# Create and switch to a new branch
gnb() {
    if [[ -z "$1" ]]; then
        echo "Error: Please provide a branch name"
        return 1
    fi
    git checkout -b "$1"
}

# Push current branch to origin
gp() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$branch"
}

# List all branches with last commit date and author
gbl() {
    git for-each-ref --sort=-committerdate refs/heads/ \
        --format='%(refname:short) | %(committerdate:relative) | %(authorname)' | \
        column -t -s '|'
}

