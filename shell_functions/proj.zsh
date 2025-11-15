proj() {
    local base="$HOME/Documents/projects"
    local proj_dir="$base/$1"

    if [[ -d "$proj_dir" ]]; then
        cd "$proj_dir"
    else
        echo "no such project"
    fi
}

_proj() {
    local -a projects
    projects=("$HOME/Documents/projects"/*(/:t))  # Gets just the folder names
    _describe 'project' projects
}

compdef _proj proj

