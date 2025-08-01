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
    echo -e "${GREEN}Usage: ./run.sh [COMMAND]${NC}"
    echo ""
    echo -e "${GREEN}Commands:${NC}"
    echo -e "  ${BLUE}dev${NC}        Start in development mode (localhost)"
    echo -e "  ${BLUE}deploy${NC}     Deploy for remote access (requires API_URL)"
    echo -e "  ${BLUE}https${NC}      Deploy with HTTPS support (production)"
    echo -e "  ${BLUE}stop${NC}       Stop all services"
    echo -e "  ${BLUE}logs${NC}       Show logs from all services"
    echo -e "  ${BLUE}status${NC}     Show container status and connectivity"
    echo -e "  ${BLUE}clean${NC}      Clean up containers and images"
    echo -e "  ${BLUE}help${NC}       Show this help message"
    echo ""
    echo -e "${GREEN}Deployment Examples:${NC}"
    echo -e "  ./run.sh dev                                      # Local development"
    echo -e "  API_URL=http://167.71.49.141:8000 ./run.sh deploy # Remote HTTP"
    echo -e "  API_URL=https://aichatbot.sytes.net ./run.sh https # HTTPS with domain"
    echo ""
    echo -e "${GREEN}Environment Variables:${NC}"
    echo -e "  ${BLUE}API_URL${NC}    Backend API URL (required for deploy/https commands)"
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

# Function to show status
show_status() {
    echo -e "${GREEN}📊 Container Status:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep chatbot || echo "No chatbot containers running"
    
    echo -e "\n${GREEN}🔍 Connectivity Test:${NC}"
    if curl -s -o /dev/null -w "Frontend: %{http_code}\n" http://localhost:3000 2>/dev/null; then
        echo "✅ Frontend accessible"
    else
        echo "❌ Frontend not accessible"
    fi
    
    if curl -s -o /dev/null -w "Backend: %{http_code}\n" http://localhost:8000/health 2>/dev/null; then
        echo "✅ Backend accessible"
    else
        echo "❌ Backend not accessible"
    fi
}

# Main logic
case "${1:-help}" in
    "dev"|"start"|"up")
        echo -e "${GREEN}🚀 Starting in development mode...${NC}"
        export API_URL="http://localhost:8000"
        docker-compose up --build
        echo -e "${GREEN}✅ Development server started!${NC}"
        echo -e "${BLUE}📱 Frontend: http://localhost:3000${NC}"
        echo -e "${BLUE}🔧 Backend API: http://localhost:8000${NC}"
        echo -e "${BLUE}📖 API Docs: http://localhost:8000/docs${NC}"
        ;;
    "deploy")
        if [ -z "$API_URL" ]; then
            echo -e "${RED}❌ API_URL environment variable is required for deployment${NC}"
            echo -e "${YELLOW}Example: API_URL=http://167.71.49.141:8000 ./run.sh deploy${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}🚀 Deploying for remote access...${NC}"
        echo -e "${BLUE}🌐 API URL: $API_URL${NC}"
        
        # Export API_URL for docker-compose
        export API_URL
        
        # Stop and clean for fresh build
        docker-compose down
        echo -e "${YELLOW}🔨 Building with API_URL=$API_URL (this may take a few minutes)...${NC}"
        docker-compose build --no-cache
        docker-compose up -d
        
        echo -e "${GREEN}✅ Deployment completed!${NC}"
        
        # Extract hostname for display
        HOSTNAME=$(echo "$API_URL" | sed -E 's|^https?://([^:/]+).*|\1|')
        PROTOCOL=$(echo "$API_URL" | sed -E 's|^(https?)://.*|\1|')
        
        echo -e "${BLUE}📱 Frontend: $PROTOCOL://$HOSTNAME:3000${NC}"
        echo -e "${BLUE}🔧 Backend API: $API_URL${NC}"
        echo -e "${BLUE}📖 API Docs: $API_URL/docs${NC}"
        
        # Test connectivity
        sleep 3
        show_status
        ;;
    "https")
        if [ -z "$API_URL" ]; then
            echo -e "${RED}❌ API_URL environment variable is required for HTTPS deployment${NC}"
            echo -e "${YELLOW}Example: API_URL=https://aichatbot.sytes.net ./run.sh https${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}🚀 Deploying with HTTPS support...${NC}"
        echo -e "${BLUE}🌐 API URL: $API_URL${NC}"
        
        # Check if SSL certificates exist
        if [ ! -d "./ssl" ] || [ ! -f "./ssl/cert.pem" ] || [ ! -f "./ssl/key.pem" ]; then
            echo -e "${YELLOW}⚠️  SSL certificates not found in ./ssl/ directory${NC}"
            echo -e "${YELLOW}Please set up SSL certificates first. See DEPLOYMENT.md for instructions.${NC}"
            exit 1
        fi
        
        export API_URL
        docker-compose -f docker-compose.prod.yml up --build -d
        echo -e "${GREEN}✅ HTTPS deployment completed!${NC}"
        echo -e "${BLUE}📱 Frontend: $API_URL (port 443)${NC}"
        echo -e "${BLUE}🔧 Backend API: $API_URL${NC}"
        ;;
    "stop")
        echo -e "${YELLOW}🛑 Stopping all services...${NC}"
        docker-compose down
        docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
        echo -e "${GREEN}✅ All services stopped${NC}"
        ;;
    "logs")
        echo -e "${GREEN}📋 Showing logs...${NC}"
        docker-compose logs -f
        ;;
    "status")
        show_status
        ;;
    "clean")
        echo -e "${YELLOW}🧹 Cleaning up...${NC}"
        docker-compose down --rmi all --volumes --remove-orphans
        docker-compose -f docker-compose.prod.yml down --rmi all --volumes --remove-orphans 2>/dev/null || true
        echo -e "${GREEN}✅ Cleanup completed${NC}"
        ;;
    "help"|*)
        show_usage
        ;;
esac 