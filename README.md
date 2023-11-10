# MEV Relay Updater

[![Version](https://img.shields.io/badge/Version-v1.0-brightgreen)](https://github.com/jordanhillis/mev-relay-updater)
[![License: MIT](https://img.shields.io/badge/license-GPL-brightgreen)](https://www.gnu.org/licenses/gpl-3.0.en.html)
![Updated](https://img.shields.io/github/last-commit/jordanhillis/mev-relay-updater)
![Debian](https://img.shields.io/badge/-Debian-red)
![Debian](https://img.shields.io/badge/-Ubuntu-orange)


Easily Update and Manage MEV Relays with Precision and Ease.

## Introduction
The MEV Relay Updater is a Bash script designed to help Ethereum stakers update their `mev-boost` service file with the latest MEV relay URLs fetched from a predefined list from ETH Stakers. It supports Mainnet, Sepolia, and Goerli chains.

## Features
- Fetches the latest MEV relay URLs.
- Compares new URLs with the current list and highlights additions or removals.
- Provides an option to update the service file with new URLs.
- Restarts the `mev-boost` service upon update.

## Requirements
- `mev-boost`: This script is designed to modify relays for the `mev-boost` service.
- `curl`: Required for fetching the relay list from the internet.
- `systemctl`: Utilized for managing the service file.
- `sudo`: Needed for performing operations that require root privileges.

## Installation

### Prerequisites
- Ensure you have `git` installed on your system.
- `mev-boost` should be installed and configured correctly.

### Steps
```bash
# Clone the repository
git clone https://github.com/jordanhillis/mev-relay-updater

# Navigate to the directory
cd mev-relay-updater

# Make the script executable
chmod +x mev-relay-updater.sh
```

## Usage

To run the script, simply execute it in your terminal:

```bash
./mev-boost-updater.sh
```
Follow the interactive prompts to:

- View the new MEV relay URLs.
- Choose to update the service file with all or selected URLs.
- Restart the mev-boost service.

## Configuration
Before running the script, ensure to set the following configurations in the script file:

- `URL`: Set this to the URL where the MEV relay list can be fetched.
- `SERVICE_FILE`: Path to your mev-boost.service file.
- `CHAIN`: Choose which chain's relay URLs to fetch (Mainnet, Sepolia, Goerli).

## Contributing

Your contributions and feedback are essential in enhancing the MEV Relay Updater. If you have any suggestions, encounter issues, or want to discuss potential improvements, I encourage you to get involved:

- **Open an Issue**: For bugs, questions, or suggestions, feel free to open an issue on the GitHub repository. This is a great way to report problems or initiate discussions about the script.

- **Email Me**: If you prefer direct communication or have extensive feedback, you can email me at [jordan@hillis.email](mailto:jordan@hillis.email). Whether it's a potential enhancement, user experience feedback, or other aspects of the script, I'm open to hearing your insights.

Every piece of feedback, suggestion, or query helps in the ongoing improvement of this project. I appreciate your interest and willingness to contribute!

## Developers

* **Jordan Hillis** - *Lead Developer*

## License
Distributed under the MIT License. See LICENSE for more information.

## Acknowledgments

* This program is not an official program by Flashbots or the Ethereum Foundation

