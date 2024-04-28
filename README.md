# dosnapshotman.sh

`dosnapshotman.sh` is a Bash script designed to automate the management of snapshots for DigitalOcean droplets. It ensures that only the last two snapshots are retained for each droplet and provides options for verbose output and Telegram notifications.

## Features

- **Snapshot Management**: Automatically takes and retains the last two snapshots of specified DigitalOcean droplets.
- **Multi-Account Support**: Manages droplets across multiple DigitalOcean accounts.
- **Notification System**: Supports sending status updates via Telegram.
- **Verbose Output**: Provides detailed output on the console when run in verbose mode.

## Installation

Follow these steps to get `dosnapshotman.sh` running on your system:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/drhdev/dosnapshotman.sh.git
   cd dosnapshotman.sh
   ```

2. **Install Dependencies**:
   Ensure that `doctl`, the DigitalOcean command line tool, is installed:
   ```bash
   sudo snap install doctl
   ```

3. **Configuration**:
   Configure your API keys and droplet IDs directly in the script or via environment variables for enhanced security.

4. **Set Permissions**:
   ```bash
   chmod +x dosnapshotman.sh
   ```

5. **Environment Setup**:
   (Optional) For improved security, consider using environment variables or a secure vault to store API keys.

## Usage

To run the script, use the following options:

- **Verbose Mode** (`-v`): Outputs the status messages to the console.
- **Telegram Mode** (`-t`): Sends status messages via Telegram to the specified chat ID.

Combine options to activate both modes:
```bash
./dosnapshotman.sh -v -t
```

Ensure the `LOG_FILE` path in the script is writable. Adjust path and permissions as necessary. Configure Telegram bot settings according to your needs.

## Contributing

Contributions to `dosnapshotman.py` are welcome! Please fork the repository and submit a pull request with your proposed changes. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions, please open an issue on the GitHub repository.
