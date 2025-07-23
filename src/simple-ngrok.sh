#!/bin/bash

# Simple ngrok - Universal ngrok Tunnel Setup
# This script sets up ngrok tunnel for any local development site

set -e

echo "🚀 Simple ngrok - Universal Tunnel Setup"
echo "========================================="
echo ""
echo "Starting interactive ngrok setup..."
echo ""

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
    echo -e "${GREEN}Configuration Summary:${NC}"
    echo "  Project: $PROJECT_NAME"
    echo "  Local URL: $LOCAL_SITE_URL"
    echo "  Local Port: $LOCAL_PORT"
    echo ""
}

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    print_error "ngrok is not installed or not in PATH"
    print_instruction "Install ngrok from: https://ngrok.com/download"
    print_instruction "Or via Homebrew: brew install ngrok"
    exit 1
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
ngrok_cmd="ngrok http $LOCAL_PORT"

# Add host header if not localhost/IP
if [[ "$LOCAL_SITE_URL" != "localhost" ]] && [[ ! "$LOCAL_SITE_URL" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ngrok_cmd="$ngrok_cmd --host-header=$LOCAL_SITE_URL"
fi

# Start ngrok in background
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
    NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"https://[^"]*"' | head -1 | cut -d'"' -f4)
    if [ ! -z "$NGROK_URL" ]; then
        break
    fi
    sleep 2
    ((attempts++))
done

if [ -z "$NGROK_URL" ]; then
    print_error "Failed to get ngrok URL"
    print_instruction "Check if ngrok started correctly or try again"
    print_instruction "Make sure you have an ngrok account and are authenticated"
    exit 1
fi

# Save the URL and config for later use
echo "$NGROK_URL" > "$NGROK_CONFIG_FILE"
echo "LOCAL_SITE_URL=$LOCAL_SITE_URL" >> "$NGROK_CONFIG_FILE"
echo "LOCAL_PORT=$LOCAL_PORT" >> "$NGROK_CONFIG_FILE"
echo "PROJECT_NAME=$PROJECT_NAME" >> "$NGROK_CONFIG_FILE"

print_status "ngrok tunnel started successfully!"
echo -e "${GREEN}Local Site:${NC} $LOCAL_SITE_URL:$LOCAL_PORT"
echo -e "${GREEN}Public URL:${NC} $NGROK_URL"

# Show success message
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  $PROJECT_NAME - Simple ngrok Tunnel Active${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Your local site is now accessible at:${NC}"
echo -e "  🌐 ${YELLOW}$NGROK_URL${NC}"
echo ""
print_instruction "Use this public URL to:"
echo "   • Test webhooks and external integrations"
echo "   • Share your local development with others"
echo "   • Test OAuth flows with external services"
echo "   • Debug mobile devices on your local site"
echo "   • Access your site from anywhere"
echo ""
print_warning "🔒 Security: Your local site is temporarily accessible from the internet"
echo ""
print_instruction "To stop the tunnel later, run: kill $NGROK_PID"
echo ""
print_status "✅ Setup complete! You can close this Terminal window when done."
