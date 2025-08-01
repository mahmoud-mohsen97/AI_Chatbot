#!/bin/bash

# Quick deployment script for remote server
# Usage: ./quick-deploy.sh

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick Deploy - AI Chatbot${NC}"
echo -e "${BLUE}============================${NC}"

# Set API URL for this server
export API_URL="http://167.71.49.141:8000"

echo -e "${YELLOW}📍 Setting API_URL to: $API_URL${NC}"

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose down 2>/dev/null || true

# Clean up old images to force fresh build
echo -e "${YELLOW}🧹 Cleaning up old builds...${NC}"
docker system prune -f
docker rmi $(docker images -q ai_chatbot-frontend ai_chatbot-backend) 2>/dev/null || true

# Build with explicit API URL and no cache
echo -e "${GREEN}🔨 Building with API_URL=$API_URL${NC}"
docker-compose build --no-cache --build-arg VITE_API_URL="$API_URL"

# Start containers
echo -e "${GREEN}🚀 Starting containers...${NC}"
docker-compose up -d

# Show status
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${BLUE}📱 Frontend: http://167.71.49.141:3000${NC}"
echo -e "${BLUE}🔧 Backend API: http://167.71.49.141:8000${NC}"
echo -e "${BLUE}📖 API Docs: http://167.71.49.141:8000/docs${NC}"

# Show final status
echo -e "\n${YELLOW}📊 Container Status:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep chatbot

echo -e "\n${YELLOW}🔍 Testing connectivity...${NC}"
sleep 5
curl -s -o /dev/null -w "Frontend: %{http_code}\n" http://localhost:3000 || echo "❌ Frontend not responding"
curl -s -o /dev/null -w "Backend: %{http_code}\n" http://localhost:8000/health || echo "❌ Backend not responding"