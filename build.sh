#!/bin/bash

# Variables for logging and CI detection
LOG_FILE="build.log"
IS_CI=false

# Helper function to check if running in CI
function is_ci() {
    if [[ "$1" == "ci" ]]; then
        IS_CI=true
        echo "Running in CI environment" | tee -a "$LOG_FILE"
    else
        echo "Running in standalone environment" | tee -a "$LOG_FILE"
    fi
}

# Log a message with a timestamp
function log() {
    local msg="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $msg" | tee -a "$LOG_FILE"
}

# Exit if an error occurs
function exit_on_error() {
    local exit_code=$1
    if [ "$exit_code" -ne 0 ]; then
        log "Error encountered. Exiting with status $exit_code"
        exit $exit_code
    fi
}

# Clean previous builds (optional step)
function clean_build() {
    log "Cleaning previous build artifacts..."
    # Add commands to clean build here, e.g., removing temporary files, previous builds, etc.
    rm -rf build/ || log "No previous build directory to clean"
}

# Build function
function build() {
    log "Starting the build process..."
    clean_build

    # Command to build Godot project (adjust depending on the platform you're targeting)
    # Example command for Linux (you may need to adjust for Windows/macOS):
    log "Running build for Godot engine..."
    scons platform=x11 target=release_debug -j$(nproc)
    exit_on_error $?  # Check for errors in build step

    log "Build completed successfully"
}

# Test function
function test() {
    log "Running tests..."

    # Example of a test step: Run unit tests or game tests
    # For now, we simulate a test; replace with actual commands for your environment
    ./godot --test --no-window
    exit_on_error $?  # Check for errors in test step

    log "Tests completed successfully"
}

# Package or deploy function
function package() {
    log "Packaging the build..."
    
    # Package or deploy the built project (adjust depending on the platform)
    # Example packaging step for a Linux release:
    if [ "$IS_CI" = true ]; then
        # Perform CI-specific packaging, e.g., zipping build artifacts, uploading to a server
        log "CI packaging..."
        tar -czf godot_build.tar.gz build/
        exit_on_error $?  # Check for errors in package step
    else
        # Perform standalone packaging
        log "Standalone packaging..."
        zip -r godot_build.zip build/
        exit_on_error $?  # Check for errors in standalone package step
    fi

    log "Packaging completed successfully"
}

# Main logic to handle script arguments and CI detection
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 {build|test|package} [ci]" | tee -a "$LOG_FILE"
    exit 1
fi

# Check if running in CI mode
is_ci "$2"

# Parse the first argument to call the appropriate function
case "$1" in
    build)
        build
        ;;
    test)
        test
        ;;
    package)
        package
        ;;
    *)
        echo "Invalid argument. Usage: $0 {build|test|package} [ci]" | tee -a "$LOG_FILE"
        exit 1
        ;;
esac

log "Script execution completed"
