#!/bin/bash

# Simple ngrok - Universal ngrok Tunnel Setup
# This script sets up ngrok tunnel for any local development site

set -e

# Configuration - use environment variables or will prompt if not provided
LOCAL_SITE_URL="${NGROK_LOCAL_URL:-}"
LOCAL_PORT="${NGROK_LOCAL_PORT:-}"
PROJECT_NAME="${NGROK_PROJECT_NAME:-}"

NGROK_CONFIG_FILE="$HOME/.simple-ngrok-tunnel.txt"
PID_FILE="/tmp/simple-ngrok-tunnel.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_instruction() {
    echo -e "${BLUE}[INSTRUCTION]${NC} $1"
}

print_header() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

# Function to show help/usage
show_help() {
    echo "🚀 Simple ngrok - Interactive CLI"
    echo "================================="
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Interactive Commands:"
    echo "  start     - Start a new ngrok tunnel"
    echo "  stop      - Stop the current ngrok tunnel"
    echo "  status    - Show current tunnel status"
    echo "  list      - List all active tunnels"
    echo "  restart   - Restart the current tunnel"
    echo "  clear     - Clear the screen"
    echo "  help      - Show this help message"
    echo "  exit/quit - Exit the application"
    echo ""
    echo "CLI Usage (one-time commands):"
    echo "  $0 start          # Start tunnel and exit"
    echo "  $0 stop           # Stop tunnel and exit"
    echo "  $0 status         # Check status and exit"
    echo "  $0 list           # List tunnels and exit"
    echo ""
    echo "Default behavior:"
    echo "  $0                # Start interactive mode"
    echo ""
}

# Function to stop tunnel
stop_tunnel() {
    print_header "🛑 Stopping Simple ngrok Tunnel"
    echo "================================="
    echo ""

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            rm -f "$PID_FILE"
            rm -f "$NGROK_CONFIG_FILE"
            print_status "Tunnel stopped successfully!"
        else
            print_warning "No active tunnel found with stored PID"
            rm -f "$PID_FILE"
        fi
    else
        # Try to kill any ngrok processes
        if pkill ngrok 2>/dev/null; then
            print_status "Stopped ngrok processes"
        else
            print_warning "No active ngrok tunnels found"
        fi
    fi
    echo ""
}

# Function to show tunnel status
show_status() {
    print_header "📊 Simple ngrok Tunnel Status"
    echo "=============================="
    echo ""

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            print_status "Tunnel is RUNNING (PID: $PID)"

            if [ -f "$NGROK_CONFIG_FILE" ]; then
                source "$NGROK_CONFIG_FILE"
                echo ""
                echo -e "${GREEN}Active Configuration:${NC}"
                echo "  Project: $PROJECT_NAME"
                echo "  Local: $LOCAL_SITE_URL:$LOCAL_PORT"

                if [ ! -z "$SELECTED_DOMAIN" ]; then
                    echo "  Custom Domain: $SELECTED_DOMAIN"
                fi

                # Try to get current public URL
                if [ ! -z "$SELECTED_DOMAIN" ]; then
                    CURRENT_URL="https://$SELECTED_DOMAIN"
                else
                    CURRENT_URL=$(curl -s http://127.0.0.1:4040/api/tunnels 2>/dev/null | grep -o '"public_url":"https://[^"]*"' | head -1 | cut -d'"' -f4)
                fi

                if [ ! -z "$CURRENT_URL" ]; then
                    echo -e "  Public: ${YELLOW}$CURRENT_URL${NC}"
                fi
            fi
        else
            print_warning "Tunnel process not found (stale PID file)"
            rm -f "$PID_FILE"
        fi
    else
        print_warning "No active tunnel found"
    fi
    echo ""
}

# Function to list all tunnels
list_tunnels() {
    print_header "📋 Active ngrok Tunnels"
    echo "========================"
    echo ""

    # Check if ngrok API is available
    if curl -s http://127.0.0.1:4040/api/tunnels > /dev/null 2>&1; then
        TUNNELS=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"[^"]*","config":{"addr":"[^"]*"' | sed 's/"public_url":"//; s/","config":{"addr":"/ -> /; s/"$//')

        if [ ! -z "$TUNNELS" ]; then
            echo -e "${GREEN}Active Tunnels:${NC}"
            echo "$TUNNELS" | while IFS= read -r tunnel; do
                echo "  🌐 $tunnel"
            done
        else
            print_warning "No active tunnels found"
        fi
    else
        print_warning "ngrok API not available (no active tunnels)"
    fi
    echo ""
}

# Function to restart tunnel
restart_tunnel() {
    print_header "🔄 Restarting Simple ngrok Tunnel"
    echo "=================================="
    echo ""

    # Stop current tunnel
    stop_tunnel

    # Wait a moment
    sleep 2

    # Start new tunnel
    start_tunnel
}

# Function to list available custom domains
list_domains() {
    print_header "🌐 Available Custom Domains"
    echo "============================="
    echo ""

    # Check if ngrok is configured
    local config_paths=(
        "$HOME/Library/Application Support/ngrok/ngrok.yml"
        "$HOME/.config/ngrok/ngrok.yml"
        "$HOME/.ngrok2/ngrok.yml"
    )
    local config_found=false

    for config_path in "${config_paths[@]}"; do
        if [ -f "$config_path" ]; then
            config_found=true
            break
        fi
    done

    if [ "$config_found" = false ]; then
        print_error "ngrok not configured"
        print_instruction "Run 'ngrok config add-authtoken <token>' first"
        print_instruction "Get your token at: https://dashboard.ngrok.com/get-started/your-authtoken"
        echo ""
        return 1
    fi

    print_status "Fetching your available domains..."
    local available_domains=($(get_available_domains))

    if [ ${#available_domains[@]} -eq 0 ]; then
        print_warning "No custom domains found via auto-detection"
        echo ""
        print_instruction "To use custom domains:"
        print_instruction "1. Check your domains at: https://dashboard.ngrok.com/cloud-edge/domains"
        print_instruction "2. Claim 1 free domain if you don't have any"
        print_instruction "3. Use the 'start' command and select option 2 to enter your domain manually"
        echo ""
        print_status "💡 Use the 'start' command to create tunnels with your domains"
        echo ""
    else
        echo -e "${GREEN}Your available domains:${NC}"
        for domain in "${available_domains[@]}"; do
            echo "  🌐 $domain"
        done
        echo ""
        print_status "Use 'start' command to create a tunnel with domain selection"
        echo ""
    fi
}

get_available_domains() {
    local domains_output
    local domains_list=()

    # Get auth token from config file
    local auth_token=""
    local config_paths=(
        "$HOME/Library/Application Support/ngrok/ngrok.yml"
        "$HOME/.config/ngrok/ngrok.yml"
        "$HOME/.ngrok2/ngrok.yml"
    )

    for config_path in "${config_paths[@]}"; do
        if [ -f "$config_path" ]; then
            auth_token=$(grep "authtoken:" "$config_path" | awk '{print $2}' | tr -d '"' | tr -d "'")
            if [ ! -z "$auth_token" ]; then
                break
            fi
        fi
    done

    if [ -z "$auth_token" ]; then
        return 0
    fi

    # Try to get domains from ngrok API
    if command -v curl &> /dev/null; then
        domains_output=$(curl -s -H "Authorization: Bearer $auth_token" \
                        -H "Ngrok-Version: 2" \
                        "https://api.ngrok.com/reserved_domains" 2>/dev/null)

        if [ $? -eq 0 ] && [ ! -z "$domains_output" ]; then
            # Parse JSON to extract domain names
            domains_list=($(echo "$domains_output" | grep -o '"domain":"[^"]*"' | cut -d'"' -f4))
        fi
    fi

    # Remove duplicates and return
    printf '%s\n' "${domains_list[@]}" | sort -u
}

# Function to prompt for domain selection
prompt_for_domain() {
    echo -e "${BLUE}ngrok Domain Selection${NC}"
    echo "====================="
    echo ""

    print_status "Checking for available custom domains..."
    local available_domains=($(get_available_domains))

    echo -e "${YELLOW}Available options:${NC}"
    echo "  1. Use random ngrok URL (default)"
    echo "  2. Enter custom domain manually"

    if [ ${#available_domains[@]} -gt 0 ]; then
        echo ""
        echo -e "${GREEN}Auto-detected domains:${NC}"
        local i=3
        for domain in "${available_domains[@]}"; do
            echo "  $i. $domain"
            ((i++))
        done
    else
        echo ""
        echo -e "${CYAN}💡 Tip: If you have a custom domain, choose option 2 to enter it manually${NC}"
    fi

    echo ""
    read -p "Select option [1]: " domain_choice
    domain_choice=${domain_choice:-1}

    if [ "$domain_choice" = "1" ]; then
        SELECTED_DOMAIN=""
        echo -e "${GREEN}✓ Using random ngrok URL${NC}"
    elif [ "$domain_choice" = "2" ]; then
        echo ""
        echo -e "${YELLOW}Enter your custom domain:${NC}"
        echo "Example: hardy-centrally-boxer.ngrok-free.app"
        echo ""
        read -p "Domain: " manual_domain

        if [ ! -z "$manual_domain" ]; then
            # Clean up the domain (remove http/https if present)
            manual_domain=$(echo "$manual_domain" | sed 's|^https\?://||' | sed 's|/$||')
            SELECTED_DOMAIN="$manual_domain"
            echo -e "${GREEN}✓ Using custom domain: $SELECTED_DOMAIN${NC}"
        else
            print_warning "No domain entered, using random ngrok URL"
            SELECTED_DOMAIN=""
        fi
    elif [ "$domain_choice" -gt 2 ] && [ ${#available_domains[@]} -gt 0 ] && [ "$domain_choice" -le $((${#available_domains[@]} + 2)) ]; then
        local selected_index=$((domain_choice - 3))
        SELECTED_DOMAIN="${available_domains[$selected_index]}"
        echo -e "${GREEN}✓ Using custom domain: $SELECTED_DOMAIN${NC}"
    else
        print_warning "Invalid selection, using random ngrok URL"
        SELECTED_DOMAIN=""
    fi

    echo ""
}

# Function to prompt for configuration interactively
prompt_for_config() {
    echo -e "${BLUE}Simple ngrok - Tunnel Configuration${NC}"
    echo "==================================="
    echo ""

    # Prompt for URL if not provided
    if [ -z "$LOCAL_SITE_URL" ]; then
        echo -e "${YELLOW}Common local development URLs:${NC}"
        echo "  • localhost (for most dev servers)"
        echo "  • mysite.local (Local by Flywheel, MAMP, etc.)"
        echo "  • site.test (Valet, Laravel Homestead)"
        echo "  • 127.0.0.1 (IP address)"
        echo ""
        while [ -z "$LOCAL_SITE_URL" ]; do
            read -p "Enter your local site URL: " LOCAL_SITE_URL
            if [ -z "$LOCAL_SITE_URL" ]; then
                print_error "URL cannot be empty. Please enter a valid URL."
            fi
        done
    fi

    # Prompt for port if not provided
    if [ -z "$LOCAL_PORT" ]; then
        echo ""
        echo -e "${YELLOW}Common development ports:${NC}"
        echo "  • 80 (Apache, Nginx, WordPress)"
        echo "  • 3000 (React, Node.js, Rails)"
        echo "  • 8000 (Django, Python)"
        echo "  • 8080 (Alternative HTTP)"
        echo "  • 5173 (Vite)"
        echo "  • 4200 (Angular)"
        echo ""
        while [ -z "$LOCAL_PORT" ]; do
            read -p "Enter your local port [default: 80]: " LOCAL_PORT
            LOCAL_PORT=${LOCAL_PORT:-80}

            # Validate port number
            if ! [[ "$LOCAL_PORT" =~ ^[0-9]+$ ]] || [ "$LOCAL_PORT" -lt 1 ] || [ "$LOCAL_PORT" -gt 65535 ]; then
                print_error "Invalid port number. Please enter a number between 1 and 65535."
                LOCAL_PORT=""
            fi
        done
    fi

    # Prompt for project name if not provided
    if [ -z "$PROJECT_NAME" ]; then
        echo ""
        read -p "Enter project name [default: 'Local Development']: " PROJECT_NAME
        PROJECT_NAME=${PROJECT_NAME:-"Local Development"}
    fi

    echo ""

    # Prompt for domain selection
    prompt_for_domain

    echo -e "${GREEN}Configuration Summary:${NC}"
    echo "  Project: $PROJECT_NAME"
    echo "  Local URL: $LOCAL_SITE_URL"
    echo "  Local Port: $LOCAL_PORT"
    if [ ! -z "$SELECTED_DOMAIN" ]; then
        echo "  Custom Domain: $SELECTED_DOMAIN"
    else
        echo "  Domain: Random ngrok URL"
    fi
    echo ""
}

# Start tunnel function
start_tunnel() {
    print_header "🚀 Starting ngrok Tunnel"
    echo "========================="
    echo ""

    # Check if ngrok is installed
    if ! command -v ngrok &> /dev/null; then
        print_error "ngrok is not installed or not in PATH"
        print_instruction "Install ngrok from: https://ngrok.com/download"
        print_instruction "Or via Homebrew: brew install ngrok"
        echo ""
        return 1
    fi

    # Check if tunnel is already running
    if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
        print_warning "A tunnel is already running!"
        echo "Use 'stop' to stop it first or 'restart' to restart with new settings."
        echo ""
        return 1
    fi

    print_status "ngrok is installed"

    # Get configuration interactively
    prompt_for_config

    # Start ngrok tunnel
    print_status "Starting ngrok tunnel for $PROJECT_NAME..."

    # Kill any existing ngrok processes
    pkill ngrok 2>/dev/null || true
    sleep 2

    # Build ngrok command
    ngrok_cmd="ngrok http"

    # Add domain if selected
    if [ ! -z "$SELECTED_DOMAIN" ]; then
        # Use --url for ngrok-free.app domains, --domain for others
        if [[ "$SELECTED_DOMAIN" == *"ngrok-free.app" ]]; then
            ngrok_cmd="$ngrok_cmd --url=$SELECTED_DOMAIN"
        else
            ngrok_cmd="$ngrok_cmd --domain=$SELECTED_DOMAIN"
        fi
    fi

    # Add the port
    ngrok_cmd="$ngrok_cmd $LOCAL_PORT"

    # Add host header if not localhost/IP
    if [[ "$LOCAL_SITE_URL" != "localhost" ]] && [[ ! "$LOCAL_SITE_URL" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        ngrok_cmd="$ngrok_cmd --host-header=$LOCAL_SITE_URL"
    fi    # Start ngrok in background
    nohup $ngrok_cmd > /dev/null 2>&1 &
    NGROK_PID=$!
    echo $NGROK_PID > "$PID_FILE"

    # Wait for ngrok to start
    print_status "Waiting for ngrok to initialize..."
    sleep 5

    # Get the public URL
    attempts=0
    max_attempts=10
    while [ $attempts -lt $max_attempts ]; do
        if [ ! -z "$SELECTED_DOMAIN" ]; then
            # For custom domains, construct the URL directly
            NGROK_URL="https://$SELECTED_DOMAIN"
            break
        else
            # For random domains, get URL from API
            NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"https://[^"]*"' | head -1 | cut -d'"' -f4)
            if [ ! -z "$NGROK_URL" ]; then
                break
            fi
        fi
        sleep 2
        ((attempts++))
    done

    if [ -z "$NGROK_URL" ]; then
        print_error "Failed to get ngrok URL"
        print_instruction "Check if ngrok started correctly or try again"
        print_instruction "Make sure you have an ngrok account and are authenticated"
        echo ""
        return 1
    fi

    # Save the URL and config for later use
    echo "NGROK_URL=$NGROK_URL" > "$NGROK_CONFIG_FILE"
    echo "LOCAL_SITE_URL=$LOCAL_SITE_URL" >> "$NGROK_CONFIG_FILE"
    echo "LOCAL_PORT=$LOCAL_PORT" >> "$NGROK_CONFIG_FILE"
    echo "PROJECT_NAME=$PROJECT_NAME" >> "$NGROK_CONFIG_FILE"
    if [ ! -z "$SELECTED_DOMAIN" ]; then
        echo "SELECTED_DOMAIN=$SELECTED_DOMAIN" >> "$NGROK_CONFIG_FILE"
    fi

    print_status "ngrok tunnel started successfully!"
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  $PROJECT_NAME - Tunnel Active${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo -e "${GREEN}Local:${NC}  $LOCAL_SITE_URL:$LOCAL_PORT"

    if [ ! -z "$SELECTED_DOMAIN" ]; then
        echo -e "${GREEN}Custom Domain:${NC} $SELECTED_DOMAIN"
        echo ""
        echo -e "${YELLOW}Available URLs:${NC}"
        echo -e "  ${YELLOW}$NGROK_URL${NC}"
        echo -e "  ${CYAN}http://$SELECTED_DOMAIN${NC}"
    else
        echo ""
        echo -e "${YELLOW}Available URLs:${NC}"
        echo -e "  ${CYAN}http://${NGROK_URL#https://}${NC}"
        echo -e "  ${YELLOW}$NGROK_URL${NC}"
    fi
    echo -e "${BLUE}================================================${NC}"
    echo ""

    echo ""
    print_status "✅ Tunnel is now active! Use 'status' to check or 'stop' to stop."
    echo ""
}

# Function to show welcome message
show_welcome() {
    clear
    print_header "🚀 Simple ngrok - Interactive CLI"
    echo "=================================="
    echo ""
    echo -e "${GREEN}Welcome to Simple ngrok!${NC}"
    echo "Type commands to manage your ngrok tunnels."
    echo ""
    echo -e "${YELLOW}Available commands:${NC}"
    echo "  start     - Start a new ngrok tunnel"
    echo "  stop      - Stop the current tunnel"
    echo "  status    - Check tunnel status"
    echo "  list      - List all active tunnels"
    echo "  restart   - Restart current tunnel"
    echo "  domains   - Show available custom domains"
    echo "  help      - Show detailed help"
    echo "  clear     - Clear the screen"
    echo "  exit/quit - Exit the application"
    echo ""
}

# Function for interactive CLI mode
interactive_mode() {
    show_welcome

    while true; do
        # Show prompt with current status indicator
        if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
            echo -e -n "${GREEN}[TUNNEL ACTIVE]${NC} ngrok> "
        else
            echo -e -n "${YELLOW}[NO TUNNEL]${NC} ngrok> "
        fi

        # Read user input
        read -r command args

        # Handle empty input
        if [ -z "$command" ]; then
            continue
        fi

        echo ""

        # Process commands
        case "$command" in
            "start")
                start_tunnel
                ;;
            "stop")
                stop_tunnel
                ;;
            "status")
                show_status
                ;;
            "list")
                list_tunnels
                ;;
            "restart")
                restart_tunnel
                ;;
            "domains")
                list_domains
                ;;
            "help")
                show_help
                echo ""
                ;;
            "clear")
                show_welcome
                ;;
            "exit"|"quit"|"q")
                echo -e "${BLUE}Thanks for using Simple ngrok! 👋${NC}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Unknown command: $command"
                echo "Type 'help' for available commands or 'exit' to quit."
                echo ""
                ;;
        esac
    done
}

# Handle command line arguments
case "${1:-interactive}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    "stop")
        stop_tunnel
        exit 0
        ;;
    "status")
        show_status
        exit 0
        ;;
    "list")
        list_tunnels
        exit 0
        ;;
    "restart")
        restart_tunnel
        exit 0
        ;;
    "start")
        start_tunnel
        exit 0
        ;;
    "domains")
        list_domains
        exit 0
        ;;
    "interactive"|"")
        # Start interactive CLI mode
        interactive_mode
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
