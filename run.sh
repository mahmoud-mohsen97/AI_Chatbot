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
    echo -e "  ${BLUE}start${NC}      Start the application (build and run)"
    echo -e "  ${BLUE}up${NC}         Start the application (build and run)"
    echo -e "  ${BLUE}build${NC}      Build Docker images"
    echo -e "  ${BLUE}stop${NC}       Stop all services"
    echo -e "  ${BLUE}logs${NC}       Show logs from all services"
    echo -e "  ${BLUE}clean${NC}      Stop and remove all containers and images"
    echo -e "  ${BLUE}help${NC}       Show this help message"
    echo ""
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  ./run.sh start   # Start the application"
    echo -e "  ./run.sh up      # Start the application"
    echo -e "  ./run.sh stop    # Stop all services"
}

# Check prerequisites
check_docker
check_env

# Main logic
case "${1:-help}" in
    "start"|"up")
        echo -e "${GREEN}🚀 Starting application...${NC}"
        docker-compose up --build
        echo -e "${GREEN}✅ Application started successfully!${NC}"
        echo -e "${BLUE}📱 Frontend: http://localhost:3000${NC}"
        echo -e "${BLUE}🔧 Backend API: http://localhost:8000${NC}"
        echo -e "${BLUE}📖 API Docs: http://localhost:8000/docs${NC}"
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