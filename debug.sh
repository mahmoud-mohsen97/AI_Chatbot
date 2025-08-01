#!/bin/bash

# Debug script for deployment issues
echo "🔍 AI Chatbot Debug Information"
echo "================================"

# Check if containers are running
echo -e "\n📦 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check container logs
echo -e "\n📋 Recent Frontend Logs:"
docker logs ai-chatbot-frontend --tail 10 2>/dev/null || echo "Frontend container not running"

echo -e "\n📋 Recent Backend Logs:"
docker logs ai-chatbot-backend --tail 10 2>/dev/null || echo "Backend container not running"

# Check port accessibility
echo -e "\n🌐 Port Accessibility:"
echo "Testing localhost:3000..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:3000 2>/dev/null || echo "❌ Port 3000 not accessible"

echo "Testing localhost:8000..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8000/health 2>/dev/null || echo "❌ Port 8000 not accessible"

# Check environment variables
echo -e "\n🔧 Environment Check:"
echo "API_URL: ${API_URL:-not set}"

# Check network interfaces
echo -e "\n🌍 Network Interfaces:"
docker port ai-chatbot-frontend 2>/dev/null || echo "Frontend ports not bound"
docker port ai-chatbot-backend 2>/dev/null || echo "Backend ports not bound"

# Check firewall status (if ufw is available)
echo -e "\n🔥 Firewall Status:"
if command -v ufw &> /dev/null; then
    sudo ufw status
else
    echo "UFW not available"
fi

echo -e "\n💡 Troubleshooting Tips:"
echo "1. Ensure API_URL is set: export API_URL=http://167.71.49.141:8000"
echo "2. Force rebuild: ./run.sh stop && docker system prune -f && API_URL=http://167.71.49.141:8000 ./run.sh deploy"
echo "3. Check firewall: sudo ufw allow 3000 && sudo ufw allow 8000"
echo "4. Check logs: ./run.sh logs"