#!/bin/bash

##########################################################################
################################ SETTINGS ################################
##########################################################################

# MEV Relay list URL
URL="https://raw.githubusercontent.com/eth-educators/ethstaker-guides/main/MEV-relay-list.md"

# Define the service file path
SERVICE_FILE="/etc/systemd/system/mev-boost.service"

# Chain for relays to get
CHAIN="Mainnet" # Mainnet, Sepolia, Goerli

##########################################################################
############################## END SETTINGS ##############################
##########################################################################

# Program version
VERSION="1.0"

# Define color codes
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
red=$(tput setaf 1)
cyan=$(tput setaf 6)
yellow=$(tput setaf 3)

# Create an ASCII art banner for the program name
banner="${yellow}
 ╔╦╗╔═╗╦  ╦  ╦═╗┌─┐┬  ┌─┐┬ ┬  ╦ ╦┌─┐┌┬┐┌─┐┌┬┐┌─┐┬─┐
 ║║║║╣ ╚╗╔╝  ╠╦╝├┤ │  ├─┤└┬┘  ║ ║├─┘ ││├─┤ │ ├┤ ├┬┘  v${VERSION}
 ╩ ╩╚═╝ ╚╝   ╩╚═└─┘┴─┘┴ ┴ ┴   ╚═╝┴  ─┴┘┴ ┴ ┴ └─┘┴└─
       ${cyan}By Jordan Hillis [jordan@hillis.email]${normal}
"
echo -e "${banner}"

# Run the update check
LATEST_VERSION=$(curl -s https://raw.githubusercontent.com/jordanhillis/mev-relay-updater/main/version.txt)
# Check if the fetched version number is greater than the current version
if [ "$LATEST_VERSION" != "$VERSION" ]; then
  echo -e " ${bold}${green}An update is available for MEV Relayer Updater!\n${cyan} Version: $LATEST_VERSION${normal}\n https://github.com/jordanhillis/mev-relay-updater\n"
  read -p "Press enter to continue with old version..."
fi

# Use curl to fetch the content of the URL
content=$(curl -s "$URL")

# Function to restart the service
restart_service() {
  service_name=$(basename "$SERVICE_FILE" .service)
  sudo systemctl restart "$service_name"
}

# Function to view the journal log
view_journal_log() {
  service_name=$(basename "$SERVICE_FILE" .service)
  sudo journalctl -fu "$service_name"
}

# Define a function to compare and display new URLs
compare_urls() {
  local current_relays=("$1")
  local new_relays=("$2")
  new_urls_found=0
  removed_urls_found=0
  # Split the comma-separated strings into arrays
  IFS=',' read -ra current_relays <<<"$current_relays"
  IFS=',' read -ra new_relays <<<"$new_relays"
  # Create associative arrays for easier comparison
  declare -A current_relays_assoc
  declare -A new_relays_assoc
  for url in "${current_relays[@]}"; do
    current_relays_assoc["$url"]=1
  done
  for url in "${new_relays[@]}"; do
    new_relays_assoc["$url"]=1
  done
  # Compare arrays and print URLs that are new to the new_relays list with green color and +
  echo -e "\n${green}${bold}[+] URLs that are new to relay list:${normal}"
  for url in "${new_relays[@]}"; do
    if [[ ! -v current_relays_assoc["$url"] ]]; then
      echo -e " ${green}+${normal} ${url}"
      new_urls_found=1
    fi
  done
  # Display messages if no new URLs
  if [[ "$new_urls_found" -eq 0 ]]; then
    echo -e " - None"
  fi
  # Compare arrays and print URLs that have been removed from new_relays with red color and -
  echo -e "\n${red}${bold}[-] URLs that have been removed from relay list:${normal}"
  for url in "${current_relays[@]}"; do
    if [[ ! -v new_relays_assoc["$url"] ]]; then
      echo -e " ${red}-${normal} ${url}"
      removed_urls_found=1
    fi
  done
  # Display message if no URLs have been removed
  if [[ "$removed_urls_found" -eq 0 ]]; then
    echo -e " - None"
  fi
}

# Show current chain
echo -e "${green}${bold}Chain:${normal} $CHAIN"

# Run a simple sudo command to ensure sudo works
if ! sudo whoami >/dev/null 2>&1; then
    echo -e "${red}${bold}Error:${normal} User does not have sudo access."
    exit 1
fi

# Check if service file exists
if [ ! -f $SERVICE_FILE ]; then
  echo -e "${red}${bold}Error:${normal} service file doesn't exist.\n${cyan}File:${normal} $SERVICE_FILE"
  exit 1
fi

# Check if # MEV relay is found in the content
if ! grep -q '^# MEV relay' <<<"$content"; then
  echo "${red}${bold}Error:${normal} relays not found in the the specified content."
  exit 1
fi

# Find the line numbers for the content you want to extract
start_line=$(grep -n "^# MEV relay list for $CHAIN" <<<"$content" | head -n 1 | cut -d':' -f1)
end_line=$(grep -n '^# ' <<<"$content" | awk -F: -v start="$start_line" '$1 > start {print $1; exit}')

# Extract URLs between backticks and starting with http from the specified content
urls=($(sed -n "${start_line},${end_line}p" <<<"$content" | grep -oE '`([^`]+)`' | awk -F '`' '{print $2}' | grep -E '^http'))

# Check if any URLs were found
if [ ${#urls[@]} -eq 0 ]; then
  echo "${red}No URLs were found${normal} in the specified content."
else

  echo -e "[*] ${green}Latest MEV Relays from: ${red}$URL${normal}"

  # Print the extracted URLs with numbers
  for ((i = 0; i < ${#urls[@]}; i++)); do
    echo " - ${bold}${green}RELAY $((i + 1)):${normal} ${urls[i]}"
  done

  # Current relays
  current_relays=$(grep -oP '(?<=-relays ).*(?=\s*$)' "$SERVICE_FILE")

  # Join the new URLs with commas
  new_relays=$(
    IFS=,
    echo "${urls[*]}"
  )

  # Call the function to compare and display new URLs
  compare_urls "$current_relays" "$new_relays"

  # Ask if the user wants to update the service file
  echo ""
  read -p "${cyan}Do you want to update the service file with the new URLs?${normal} (yes/no): " rewrite_service

  if [ "$rewrite_service" == "yes" ]; then
      # Ask if the user wants to write all URLs or select specific ones
      read -p "${cyan}Do you want to write all URLs or select specific ones?${normal} (all/select): " write_option

      if [ "$write_option" == "all" ]; then
          # Update the mev-boost.service file with all the new URLs
          sudo sed -i "s|\(^ExecStart.*-relays \)[^ ]*\(.*$\)|\1$new_relays\2|" "$SERVICE_FILE"
          echo "${green}Service file updated with all URLs.${normal}"
      elif [ "$write_option" == "select" ]; then
          # Ask the user to select specific URLs
          echo ""
          echo "${cyan}Select the URLs to include (comma-separated, e.g., 1,2,3):${normal}"
          for ((i = 0; i < ${#urls[@]}; i++)); do
              echo "${bold}${green}$((i + 1)):${normal} ${urls[i]}"
          done

          read -p "${cyan}Enter the numbers of the URLs you want to include:${normal} " selected_urls

          selected_relays=()
          IFS=',' read -ra selected_numbers <<<"$selected_urls"
          for number in "${selected_numbers[@]}"; do
              index=$((number - 1))
              if [ "$index" -ge 0 ] && [ "$index" -lt "${#urls[@]}" ]; then
                  selected_relays+=("${urls[index]}")
              fi
          done

          # Update the mev-boost.service file with selected URLs
          selected_relays_string=$(
              IFS=,
              echo "${selected_relays[*]}"
          )
          sed -i "s|\(^ExecStart.*-relays \)[^ ]*\(.*$\)|\1$selected_relays_string\2|" "$SERVICE_FILE"
          echo -e "\n${green}Service file updated with selected URLs:${normal}"
          # Display the list of selected URLs one per line
          for relay in ${selected_relays[@]}; do
              echo "- $relay"
          done
      else
          echo -e "\n${red}Invalid option.${normal} No changes made to the service file."
      fi

      # Daemon reload service
      sudo systemctl daemon-reload

      # Ask if the user wants to restart the service
      read -p "${cyan}Do you want to restart the service?${normal} (yes/no): " restart_option

      if [ "$restart_option" == "yes" ]; then
          restart_service
          echo -e "\n${green}Service restarted successfully.${normal}"

          # Ask if the user wants to view the journal log
          read -p "${cyan}Do you want to view the current MEV-boost journal log?${normal} (yes/no): " view_log_option

          if [ "$view_log_option" == "yes" ]; then
              view_journal_log
          fi
      else
          echo "${cyan}Service was not restarted.${normal}"
      fi
  else
      echo -e "\n${cyan}Service file was not updated.${normal}"
  fi
fi
