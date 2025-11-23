# Podman Image Cleanup Script

An easy and flexible shell script to help manage and clean up Podman images. This script provides safe and controlled cleanup options with the ability to preserve specific images.

## Features

- Remove dangling (untagged) images
- Remove all images while keeping specific ones
- Dry run mode to preview changes
- Disk usage statistics before and after cleanup
- Color-coded output for better readability
- Prevents removal of images used by running containers
- Support for multiple image name patterns to keep

## Prerequisites

- Bash shell
- Podman installed and configured
- Root or sudo privileges (if required by your Podman setup)

## Installation

1. Download the script:
    ```bash
    curl -L -o podman-cleanup.sh https://github.com/emnawer/podman-cleanup/main/podman-cleanup.sh

    # or download using wget:
    wget https://github.com/emnawer/podman-cleanup/main/podman-cleanup.sh

    # (Optional) After downloading:
    curl -L -o podman-cleanup.sh.sha256 https://github.com/emnawer/podman-cleanup/main/podman-cleanup.sh.sha256
    sha256sum -c podman-cleanup.sh.sha256
    ```

2. Make it executable:
   ```bash
   chmod +x podman-cleanup.sh
   ```

3. (Optional) Move it to your PATH for global access:
   ```bash
   sudo cp podman-cleanup.sh /usr/local/bin/
   ```

## Usage

### Basic Usage

```bash
./podman-cleanup.sh [options]
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message and exit |
| `-k, --keep IMAGE` | Image to keep (can be used multiple times) |
| `-a, --all` | Remove all images except those specified with --keep |
| `-d, --dry-run` | Show what would be removed without actually removing |

### Examples

1. **Remove dangling images** (safe, removes untagged images):
   ```bash
   ./podman-cleanup.sh
   ```

2. **Dry run to see what would be removed**:
   ```bash
   ./podman-cleanup.sh --all --dry-run
   ```

3. **Remove all images except specific ones**:
   ```bash
   ./podman-cleanup.sh --all --keep node:20-bookworm --keep postgres
   ```

4. **Keep images by partial name**:
   ```bash
   ./podman-cleanup.sh --all --keep mysql --keep redis
   ```

5. **View disk usage only**:
   ```bash
   ./podman-cleanup.sh --dry-run
   ```

## Best Practices

1. Always use `--dry-run` first to preview changes
2. Keep important base images to avoid re-downloading them
3. Be cautious with `--all` flag as it will remove all images not in the keep list
4. Consider adding this script to your regular maintenance routine

## Exit Codes

- `0`: Success
- `1`: Error in command line arguments
- `2`: Podman command failed

## License

Read LICENSE.md

## Author

Emnawer A - [GitHub](https://github.com/emnawer)
