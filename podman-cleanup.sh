#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025, Emnawer (https://github.com/emnawer)
# Read LICENSE.md

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
KEEP_IMAGES=()
REMOVE_ALL=false
DRY_RUN=false

# Show help message
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -k, --keep IMAGE      Image to keep (can be used multiple times)"
    echo "  -a, --all             Remove all images except those specified with --keep"
    echo "  -d, --dry-run         Show what would be removed without actually removing"
    echo
    echo "Examples:"
    echo "  # Remove dangling images"
    echo "  $0"
    echo
    echo "  # Remove all images except node:20-bookworm and postgres"
    echo "  $0 --all --keep node:20-bookworm --keep postgres"
    echo
    echo "  # Dry run to see what would be removed"
    echo "  $0 --all --dry-run"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -k|--keep)
            KEEP_IMAGES+=("$2")
            shift 2
            ;;
        -a|--all)
            REMOVE_ALL=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Function to check if an image should be kept
should_keep() {
    local image_id="$1"
    local image_name="$2"
    
    # Always keep images that are in use by running containers
    if podman ps -q --filter "ancestor=$image_id" | grep -q .; then
        return 0
    fi
    
    # Check if image is in the keep list
    for keep in "${KEEP_IMAGES[@]}"; do
        if [[ "$image_name" == *"$keep"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Show disk usage
show_disk_usage() {
    echo -e "\n${YELLOW}=== Disk Usage ===${NC}"
    podman system df
    echo
}

# Main function
main() {
    echo -e "${YELLOW}=== Podman Image Cleanup ===${NC}"
    
    # Show disk usage before cleanup
    show_disk_usage
    
    # Remove dangling images by default
    if [ "$REMOVE_ALL" = false ]; then
        echo -e "${YELLOW}Removing dangling images...${NC}"
        if [ "$DRY_RUN" = true ]; then
            podman images -f "dangling=true" --format "{{.ID}} {{.Repository}}:{{.Tag}}"
        else
            podman image prune -f
        fi
    else
        # Remove all images except those to keep
        echo -e "${YELLOW}Removing all images except those specified...${NC}"
        while read -r line; do
            image_id=$(echo "$line" | awk '{print $1}')
            image_name=$(echo "$line" | awk '{print $2":"$3}')
            
            if ! should_keep "$image_id" "$image_name"; then
                if [ "$DRY_RUN" = true ]; then
                    echo "Would remove: $image_id $image_name"
                else
                    echo "Removing: $image_name"
                    podman rmi -f "$image_id" 2>/dev/null || true
                fi
            else
                echo -e "${GREEN}Keeping: $image_name${NC}"
            fi
        done < <(podman images --format "{{.ID}} {{.Repository}} {{.Tag}}" | grep -v "<none>")
    fi
    
    # Show disk usage after cleanup
    show_disk_usage
    
    echo -e "${GREEN}Cleanup completed!${NC}"
}

# Run the main function
main
