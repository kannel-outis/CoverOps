#!/bin/bash

check_git_ignore() {
    item_to_ignore="coverage/"
    gitignore_file="$cur/.gitignore"

    if ! grep -Fxq "$item_to_ignore" "$gitignore_file"; then
        echo "$item_to_ignore" >>"$gitignore_file"
        echo "$item_to_ignore has been added to $gitignore_file"
    else
        echo "$item_to_ignore is already in $gitignore_file"
    fi
}

args=("$@")
cur=$(pwd)
target_branch="main"

# Extract a specific argument value from CLI args
get_arg_value() {
    local arg_name="$1"
    for arg in "${args[@]}"; do
        if [[ "$arg" == "$arg_name="* ]]; then
            echo "${arg#*=}"
            return
        fi
    done
    echo ""
}

# Handle target branch override
target_branch_arg=$(get_arg_value "--target-branch")
if [[ -n "$target_branch_arg" ]]; then
    target_branch="$target_branch_arg"
fi

# Extract --config if provided
config_file=$(get_arg_value "--config")

flutter pub get
check_git_ignore

flutter test --coverage

# Build cover command
cover_command="cover report"
cover_command+=" --lcov=\"$cur/coverage/lcov.info\" --output=\"$cur/coverage/\" --gitParserFile=\"$cur/coverage/.gitparser.json\" --target-branch=\"$target_branch\" --source-branch=HEAD --report-format=console,json"
if [[ -n "$config_file" ]]; then
    cover_command+=" --config=\"$config_file\""
else
    echo "No config file provided. Using default config."
fi

echo "Running: $cover_command"
eval "$cover_command"
