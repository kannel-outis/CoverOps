#!/bin/bash

check_git_ignore() {
    item_to_ignore="coverage/"
    gitignore_file="$cur/.gitignore"

    if ! grep -Fxq "$item_to_ignore" "$gitignore_file"; then
        echo "$item_to_ignore" >> "$gitignore_file"
        echo "$item_to_ignore has been added to $gitignore_file"
    else
        echo "$item_to_ignore is already in $gitignore_file"
    fi
}

args=("$@")
cur=$(pwd)
pubspec_path="$cur/pubspec.yaml"
target_branch="main"

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

run_lcov_cli() {
    dart ./git_parser_cli/bin/git_parser_cli.dart --target-branch="$target_branch" --source-branch=HEAD --output-dir="$cur/coverage"
    dart ./lcov_cli/bin/lcov_cli.dart --lcov="$cur/coverage/lcov.info" --output="$cur/coverage/" --gitParserFile="$cur/coverage/.gitparser.json"

    file_path="file://$cur/coverage/lcov_html/index.html"
    echo "$file_path"


    if [[ " ${args[@]} " =~ "open" ]]; then
        open "$file_path"
    else
        read -p "Do you want to open the result? (y/n): " ans
        case "$ans" in
            y|Y ) open "$file_path"
                ;;
            n|N ) echo ""
                ;;
            * ) echo ""
                ;;
        esac
    fi
}

target_branch_arg=$(get_arg_value "--target-branch")
if [[ -n "$target_branch_arg" ]]; then
    target_branch="$target_branch_arg"
fi

if [ -f "$pubspec_path" ]; then
    flutter pub get
    check_git_ignore


    if [[ " ${args[@]} " =~ "--skip-coverage" ]]; then
        echo "Skipping flutter test coverage..."
    else
        dart run coverage:test_with_coverage
        lcov --remove coverage/lcov.info '*.g.dart' '*.part.dart' -o coverage/lcov.info
    fi

    # run_lcov_cli
    cliPathDir="${cur%%/lcov_reader_worspace/*}/lcov_reader_worspace"
    dart $cliPathDir/git_parser_cli/bin/git_parser_cli.dart --target-branch="$target_branch" --source-branch=HEAD --output-dir="$cur/coverage"
    dart $cliPathDir/lcov_cli/bin/lcov_cli.dart --lcov="$cur/coverage/lcov.info" --output="$cur/coverage/" --gitParserFile="$cur/coverage/.gitparser.json"

    file_path="file://$cur/coverage/lcov_html/index.html"
    echo "$file_path"


    if [[ " ${args[@]} " =~ "open" ]]; then
        open "$file_path"
    else
        read -p "Do you want to open the result? (y/n): " ans
        case "$ans" in
            y|Y ) open "$file_path"
                ;;
            n|N ) echo ""
                ;;
            * ) echo ""
                ;;
        esac
    fi
   
else
    echo "$cur is not a flutter project directory. Enter a flutter package root directory."
    run_lcov_cli
fi
