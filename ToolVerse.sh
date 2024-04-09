#!/bin/bash

# Symbolexe - 05/09/2024


clear
echo "
"████████╗░█████╗░░█████╗░██╗░░░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗"
"╚══██╔══╝██╔══██╗██╔══██╗██║░░░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝"
"░░░██║░░░██║░░██║██║░░██║██║░░░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░"
"░░░██║░░░██║░░██║██║░░██║██║░░░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░"
"░░░██║░░░╚█████╔╝╚█████╔╝███████╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗"
"░░░╚═╝░░░░╚════╝░░╚════╝░╚══════╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝"
"
echo ""
echo "Simplified tool installer for Linux systems with customizable options."
echo "Created By : Yasin Saffari (Symbolexe)"
# ANSI color codes
bold=$(tput bold)
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
echo "${bold}${green}Please Run This script as Root${reset}"
# Function to add Kali repository and install GPG keys
setup_kali_repo() {
    echo "${bold}${green}Preparing...${reset}"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6 &>/dev/null
    echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/kali.list &>/dev/null
    wget -q -O - https://archive.kali.org/archive-key.asc | sudo apt-key add - &>/dev/null
    apt update &>/dev/null
}

# Associative array for categories and their default tools
declare -A categories=(
    ["Reconnaissance"]="theharvester sublist3r dnsenum fierce maltego metagoofil subfinder netdiscover nmap netcat wpscan masscan wireshark hping3 dnsmap dnsrecon dnsenum whatweb wafw00f recon-ng wafw00f skipfish nikto"
    ["Network_Scanning"]="nmap voiphopper macchanger wifite masscan arp-scan nbtscan hping3 bettercap fping tcpdump p0f dsniff scapy metasploit-framework safecopy unicornscan"
    ["Password_Cracking"]="medusa hydra john hash-identifier"
    ["Wireless_Attacks"]="aircrack-ng wifite"
    ["Exploitation_Tools"]="metasploit-framework beef-xss sqlmap xsser"
    ["Web_Hacking"]="burpsuite zaproxy sqlmap wfuzz dirbuster wapiti xsser nuclei ffuf dirb"
    ["Mobile_Hacking"]="apktool jadx smali"
    ["Reverse_Eng"]="radare2 ollydbg ghidra"
)

# Associative arrays to store custom tools and commands for categories
declare -A custom_tools
declare -A custom_commands

# Function to install tools based on category
install_tools() {
    category=$1
    tools="${categories[$category]}"
    custom="${custom_tools[$category]}"
    commands="${custom_commands[$category]}"
    if [[ -n "$tools" ]]; then
        echo ""
        echo "${bold}${green}Installing tools for category '$category'...${reset}"
        echo "Default tools: $tools"
        echo "Custom tools: $custom"
        echo "Custom commands: $commands"
        echo ""
        sudo apt install $tools $custom -y &>/dev/null
        if [[ $? -eq 0 ]]; then
            echo ""
            echo "${bold}${green}Installation of tools for category '$category' completed.${reset}"
        else
            echo ""
            echo "${bold}${red}Installation of tools for category '$category' failed.${reset}"
        fi
        eval "$commands"  # Execute custom commands
    else
        echo ""
        echo "${bold}${red}No tools found for category '$category'.${reset}"
    fi
}

# Function to display help information
display_help() {
    cat << EOF
${bold}Usage:${reset} $0 [options]

${bold}Options:${reset}
  -h, --help          Display this help message
EOF
}

# Function to display categories and tools
display_categories() {
    echo "${bold}${green}Available Categories and Tools:${reset}"
    index=1
    for category in "${!categories[@]}"; do
        echo "${bold}$((index++)). ${category}:${reset} ${categories[$category]}"
    done
}

# Function to validate category selection
validate_category() {
    category_num=$1
    if [[ "$category_num" == "q" ]]; then
        echo "Exiting..."
        exit 0
    elif [[ "$category_num" == "s" ]]; then
        return 0
    elif ! [[ "$category_num" =~ ^[0-9]+$ ]]; then
        echo "${bold}${red}Invalid input. Please enter a number.${reset}"
        return 1
    elif (( category_num < 1 || category_num > ${#categories[@]} )); then
        echo "${bold}${red}Invalid category number.${reset}"
        return 1
    fi
    return 0
}

# Function to prompt user for category selection
prompt_categories() {
    selected_categories=()
    while true; do
        read -p "${bold}${green}Enter the numbers of the categories you want to install tools from (comma-separated), 's' to skip, or 'q' to quit:${reset} " category_nums
        IFS=',' read -ra num_array <<< "$category_nums"
        for num in "${num_array[@]}"; do
            validate_category "$num" || continue 2
            selected_categories+=($(printf "%s\n" "${!categories[@]}" | sed -n "${num}p"))
        done
        break
    done
}

# Function to prompt user for custom tools in a category
prompt_custom_tools() {
    for category in "${selected_categories[@]}"; do
        read -p "${bold}${green}Enter custom tools (space-separated) for category '$category' (leave blank if none):${reset} " custom_tools_input
        custom_tools["$category"]=$custom_tools_input
    done
}

# Function to prompt user for custom commands in a category
prompt_custom_commands() {
    for category in "${selected_categories[@]}"; do
        read -p "${bold}${green}Enter custom commands for category '$category' (leave blank if none):${reset} " custom_commands_input
        custom_commands["$category"]=$custom_commands_input
    done
}

# Function to confirm installation
confirm_installation() {
    while true; do
        read -p "${bold}${green}Do you want to install the selected tools? (yes/no):${reset} " confirmation
        case $confirmation in
            [Yy]*)
                return 0
                ;;
            [Nn]*)
                echo ""
                echo "Installation aborted."
                exit 0
                ;;
            *)
                echo ""
                echo "${bold}${red}Invalid input. Please enter 'yes' or 'no'.${reset}"
                ;;
        esac
    done
}

# Function to display summary of selected categories and tools
display_summary() {
    echo "${bold}${green}Summary of Selected Categories and Tools:${reset}"
    for category in "${selected_categories[@]}"; do
        echo "${bold}Category:${reset} $category"
        echo "${bold}Default Tools:${reset} ${categories[$category]}"
        if [[ -n "${custom_tools[$category]}" ]]; then
            echo "${bold}Custom Tools:${reset} ${custom_tools[$category]}"
        fi
        if [[ -n "${custom_commands[$category]}" ]]; then
            echo "${bold}Custom Commands:${reset} ${custom_commands[$category]}"
        fi
        echo
    done
}

# Function to display progress indicator
display_progress() {
    echo -n "${bold}${green}Installing tools...${reset}"
    local delay=0.2
    while true; do
        echo -n "."
        sleep $delay
    done
}

# Function to prompt user for installing custom tools and commands
prompt_custom_install() {
    read -p "${bold}${green}Do you want to install custom tools and commands for any category? (yes/no):${reset} " custom_install
    case $custom_install in
        [Yy]*)
            return 0
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            echo ""
            echo "${bold}${red}Invalid input. Please enter 'yes' or 'no'.${reset}"
            prompt_custom_install
            ;;
    esac
}

# Main function
main() {
    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                display_help
                exit 0
                ;;
            *)
                echo "${bold}${red}Invalid option: $1${reset}"
                exit 1
                ;;
        esac
    done

    setup_kali_repo
    display_categories
    prompt_categories
    prompt_custom_install
    if [[ ${#selected_categories[@]} -gt 0 ]]; then
        if [[ "$custom_install" == "yes" ]]; then
            prompt_custom_tools
            prompt_custom_commands
        fi
        display_summary
        confirm_installation
        display_progress &
        pid=$!
        trap "kill $pid" EXIT
        for category in "${selected_categories[@]}"; do
            install_tools "$category"
        done
        kill $pid
        echo ""
        echo " ${bold}${green}Installation completed.${reset}"
        trap - EXIT
    else
        echo "No categories selected. Exiting..."
    fi
}

# Execute main function
main "$@"
