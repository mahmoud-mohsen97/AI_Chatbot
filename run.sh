#!/bin/bash

# AI Chatbot - Run Script
# This script helps you quickly start the application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 AI Chatbot - Hospital Assistant${NC}"
echo -e "${BLUE}====================================${NC}"

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
        exit 1
    fi
}

# Function to check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}⚠️  No .env file found. Creating from .env.example...${NC}"
        if [ -f .env.example ]; then
            cp .env.example .env
            echo -e "${YELLOW}📝 Please edit .env file and add your OpenAI API key${NC}"
            echo -e "${YELLOW}   You can edit it with: nano .env${NC}"
            read -p "Press Enter to continue after editing .env file..."
        else
            echo -e "${RED}❌ No .env.example file found${NC}"
            exit 1
        fi
    fi
}

# Function to show usage
show_usage() {
    echo -e "${GREEN}Usage: ./run.sh [COMMAND] [OPTIONS]${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo -e "  ${BLUE}start${NC}      Start the application (build and run)"
    echo -e "  ${BLUE}up${NC}         Start the application (build and run)"
    echo -e "  ${BLUE}deploy${NC}     Start in production mode with custom API URL"
    echo -e "  ${BLUE}build${NC}      Build Docker images"
    echo -e "  ${BLUE}stop${NC}       Stop all services"
    echo -e "  ${BLUE}logs${NC}       Show logs from all services"
    echo -e "  ${BLUE}clean${NC}      Stop and remove all containers and images"
    echo -e "  ${BLUE}help${NC}       Show this help message"
    echo ""
    echo -e "${GREEN}Environment Variables:${NC}"
    echo -e "  ${BLUE}API_URL${NC}    Set custom API URL (e.g., http://167.71.49.141:8000)"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  ./run.sh start                                    # Local development"
    echo -e "  API_URL=http://167.71.49.141:8000 ./run.sh deploy # Remote deployment"
    echo -e "  API_URL=https://aichatbot.sytes.net ./run.sh deploy # Domain deployment"
    echo -e "  ./run.sh stop                                     # Stop all services"
}

# Function to set deployment environment
setup_deployment() {
    local api_url="${1:-}"
    
    if [ -z "$api_url" ]; then
        if [ -z "$API_URL" ]; then
            echo -e "${YELLOW}⚠️  No API_URL specified. Using localhost for development mode.${NC}"
            export API_URL="http://localhost:8000"
        else
            echo -e "${GREEN}✅ Using API_URL from environment: $API_URL${NC}"
        fi
    else
        export API_URL="$api_url"
        echo -e "${GREEN}✅ Using API_URL: $API_URL${NC}"
    fi
    
    echo -e "${BLUE}📝 Frontend will connect to: $API_URL${NC}"
}

# Check prerequisites
check_docker
check_env

# Main logic
case "${1:-help}" in
    "start"|"up")
        setup_deployment
        echo -e "${GREEN}🚀 Starting application...${NC}"
        docker-compose up --build
        echo -e "${GREEN}✅ Application started successfully!${NC}"
        echo -e "${BLUE}📱 Frontend: http://localhost:3000${NC}"
        echo -e "${BLUE}🔧 Backend API: http://localhost:8000${NC}"
        echo -e "${BLUE}📖 API Docs: http://localhost:8000/docs${NC}"
        ;;
    "deploy")
        setup_deployment "$2"
        echo -e "${GREEN}🚀 Starting in production mode...${NC}"
        echo -e "${BLUE}🌐 API URL: $API_URL${NC}"
        docker-compose up --build -d
        echo -e "${GREEN}✅ Application deployed successfully!${NC}"
        
        # Extract hostname from API_URL for display
        HOSTNAME=$(echo "$API_URL" | sed -E 's|^https?://([^:/]+).*|\1|')
        PROTOCOL=$(echo "$API_URL" | sed -E 's|^(https?)://.*|\1|')
        
        if [ "$HOSTNAME" != "localhost" ] && [ "$HOSTNAME" != "127.0.0.1" ]; then
            echo -e "${BLUE}📱 Frontend: $PROTOCOL://$HOSTNAME:3000${NC}"
            echo -e "${BLUE}🔧 Backend API: $API_URL${NC}"
            echo -e "${BLUE}📖 API Docs: $API_URL/docs${NC}"
        else
            echo -e "${BLUE}📱 Frontend: http://localhost:3000${NC}"
            echo -e "${BLUE}🔧 Backend API: http://localhost:8000${NC}"
            echo -e "${BLUE}📖 API Docs: http://localhost:8000/docs${NC}"
        fi
        ;;
    "build")
        echo -e "${GREEN}🔨 Building Docker images...${NC}"
        docker-compose build
        ;;
    "stop")
        echo -e "${YELLOW}🛑 Stopping all services...${NC}"
        docker-compose down
        echo -e "${GREEN}✅ All services stopped${NC}"
        ;;
    "logs")
        echo -e "${GREEN}📋 Showing logs...${NC}"
        docker-compose logs -f
        ;;
    "clean")
        echo -e "${YELLOW}🧹 Cleaning up...${NC}"
        docker-compose down --rmi all --volumes --remove-orphans
        echo -e "${GREEN}✅ Cleanup completed${NC}"
        ;;
    "help"|*)
        show_usage
        ;;
esac 