#!/bin/sh

# directories
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)/bin"
TOOL_NAME="cover" # Base name
DART_FILE="$(cd "$(dirname "$0")" && pwd)/bin/cover_ops.dart" # Path to source file

# Normalize current platform name
current_platform="$(uname | tr '[:upper:]' '[:lower:]')"

echo "Detected current platform: $current_platform"

# Function to set up PATH
setup_path() {
    local profile_file="$1"

    # Create bin directory if it doesn't exist
    mkdir -p "$TOOL_DIR"

    # Add TOOL_DIR to PATH if not already there
    if ! grep -q "$TOOL_DIR" "$profile_file"; then
        echo -e "\n# Added for $TOOL_NAME\nexport PATH=\"\$PATH:$TOOL_DIR\"" >> "$profile_file"
        echo "✅ Added $TOOL_DIR to PATH in $profile_file"
    else
        echo "ℹ️ $TOOL_DIR already in PATH in $profile_file"
    fi

    echo "🔁 Restart your terminal or run: source $profile_file"
}

# Function to build Dart executable for a given platform
build_dart() {
    local target_platform="$1"
    local output_name="$TOOL_NAME"

    # Check if Dart is installed
    if ! command -v dart &> /dev/null; then
        echo "❌ Dart SDK not found. Please install Dart: https://dart.dev/get-dart"
        exit 1
    fi

    # Check if Dart source file exists
    if [[ ! -f "$DART_FILE" ]]; then
        echo "❌ Dart source file not found at: $DART_FILE"
        exit 1
    fi

    # Create bin directory if it doesn't exist
    mkdir -p "$TOOL_DIR"

    echo "🛠️ Building Dart executable for $target_platform..."

    if [[ "$target_platform" == "windows" ]]; then
        output_name="$TOOL_NAME.exe"
        # Windows: Compile to .exe
        dart compile exe "$DART_FILE" -o "$TOOL_DIR/$output_name" --target-os=windows
        if [[ $? -eq 0 ]]; then
            echo "✅ Built $output_name in $TOOL_DIR"
        else
            echo "❌ Failed to build $output_name"
            return 1
        fi
    elif [[ "$target_platform" == "linux" ]]; then
        # Linux: Compile executable
        dart compile exe "$DART_FILE" -o "$TOOL_DIR/$output_name" --target-os=linux
        if [[ $? -eq 0 ]]; then
            # Make the output executable
            chmod +x "$TOOL_DIR/$output_name"
            echo "✅ Built $output_name in $TOOL_DIR"
        else
            echo "❌ Failed to build $output_name"
            return 1
        fi
    elif [[ "$target_platform" == "macos" ]]; then
        # macOS Compile executable
        dart compile exe "$DART_FILE" -o "$TOOL_DIR/$output_name" --target-os=macos
        if [[ $? -eq 0 ]]; then
            # Make the output executable
            chmod +x "$TOOL_DIR/$output_name"
            echo "✅ Built $output_name in $TOOL_DIR"
        else
            echo "❌ Failed to build $output_name"
            return 1
        fi
    else
        echo "❌ Unsupported platform: $target_platform"
        return 1
    fi
}

# Main logic
if [[ "$1" == "--build" ]]; then
    shift # Remove --build from arguments
    platforms=("$@") # Remaining arguments are platforms

    # If no platforms specified, default to current platform
    if [[ ${#platforms[@]} -eq 0 ]]; then
        if [[ "$current_platform" == mingw* || "$current_platform" == msys* || "$current_platform" == cygwin* ]]; then
            platforms=("windows")
        else
            platforms=("$current_platform")
        fi
    fi

    # Validate and build for each platform
    for platform in "${platforms[@]}"; do
        if [[ "$platform" != "linux" && "$platform" != "macos" && "$platform" != "windows" ]]; then
            echo "❌ Invalid platform: $platform. Supported: linux, macos, windows"
            exit 1
        fi
        build_dart "$platform"
        if [[ $? -ne 0 ]]; then
            exit 1
        fi
    done

    echo "🚀 You can now run your tool using: $TOOL_NAME"
else
    # Determine shell profile file
    if [[ "$current_platform" == "macos" || "$current_platform" == "linux" ]]; then
        # macOS or Linux
        if [[ -n "$ZSH_VERSION" ]]; then
            PROFILE_FILE="$HOME/.zshrc"
        elif [[ -n "$BASH_VERSION" ]]; then
            PROFILE_FILE="$HOME/.bash_profile"
        else
            PROFILE_FILE="$HOME/.profile"
        fi
        setup_path "$PROFILE_FILE"
    elif [[ "$current_platform" == mingw* || "$current_platform" == msys* || "$current_platform" == cygwin* ]]; then
        # Windows (Git Bash, MSYS2, or similar)
        PROFILE_FILE="$HOME/.bash_profile"
        setup_path "$PROFILE_FILE"
    else
        echo "❌ Unsupported platform: $current_platform"
        exit 1
    fi
    echo "🚀 You can now run your tool using: $TOOL_NAME"
fi