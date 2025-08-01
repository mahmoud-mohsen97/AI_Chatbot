# 🚀 AI Chatbot Deployment Guide

This guide explains how to deploy your AI Chatbot application for remote access and HTTPS deployment.

## 🔧 Quick Fix for Remote Access

### Problem
Your frontend was hardcoded to use `localhost:8000` as the API URL, which works locally but fails when accessing from external devices.

### Solution
The codebase has been updated to use dynamic API URLs through environment variables.

## 📦 Deployment Options

### 1. Local Development
```bash
./run.sh start
# Accessible at: http://localhost:3000
```

### 2. Remote HTTP Deployment
```bash
# On your remote server (167.71.49.141)
API_URL=http://167.71.49.141:8000 ./run.sh deploy

# Now accessible from anywhere at:
# Frontend: http://167.71.49.141:3000
# Backend API: http://167.71.49.141:8000
```

### 3. HTTPS Domain Deployment
```bash
# For domain deployment with HTTPS
API_URL=https://aichatbot.sytes.net ./run.sh deploy

# Or use the production configuration:
docker-compose -f docker-compose.prod.yml up -d
```

## 🌐 Setting Up Domain & HTTPS

### Step 1: Domain Configuration
1. Point your domain `aichatbot.sytes.net` to your server IP `167.71.49.141`
2. Ensure ports 80 and 443 are open on your server

### Step 2: SSL Certificate Setup
You have several options for SSL certificates:

#### Option A: Let's Encrypt (Recommended)
```bash
# Install certbot
sudo apt update
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d aichatbot.sytes.net

# Copy certificates to project
sudo mkdir -p ./ssl
sudo cp /etc/letsencrypt/live/aichatbot.sytes.net/fullchain.pem ./ssl/cert.pem
sudo cp /etc/letsencrypt/live/aichatbot.sytes.net/privkey.pem ./ssl/key.pem
sudo chown -R $USER:$USER ./ssl
```

#### Option B: Use Existing SSL Setup
Since you mentioned having a working HTTPS setup at `assistcareai.com`, you can:
1. Copy the SSL certificates from that setup
2. Update the domain names in the configuration
3. Use the same reverse proxy setup

### Step 3: Deploy with HTTPS
```bash
# Deploy with production configuration
API_URL=https://aichatbot.sytes.net docker-compose -f docker-compose.prod.yml up -d
```

## 🔄 Migration from Existing Setup

Since you have a working setup at `assistcareai.com`, here's how to leverage it:

### Option 1: Add to Existing Nginx
Add this location block to your existing nginx configuration:

```nginx
# Add to your existing server block
location /chatbot/ {
    proxy_pass http://localhost:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location /chatbot-api/ {
    proxy_pass http://localhost:8000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Then deploy with:
```bash
API_URL=https://assistcareai.com/chatbot-api ./run.sh deploy
```

### Option 2: Subdomain Setup
Create a subdomain `chatbot.assistcareai.com` and point it to your AI chatbot application.

## 🛠 Environment Configuration

Create a `.env` file with your configuration:

```bash
# .env file
OPENAI_API_KEY=your_openai_api_key_here

# For remote deployment
API_URL=http://167.71.49.141:8000

# For HTTPS domain deployment
# API_URL=https://aichatbot.sytes.net

# Domain configuration
DOMAIN=aichatbot.sytes.net
HTTPS_ENABLED=true
```

## 📋 Updated Commands

### New Deployment Commands
```bash
# Local development
./run.sh start

# Remote HTTP deployment
API_URL=http://167.71.49.141:8000 ./run.sh deploy

# HTTPS domain deployment
API_URL=https://aichatbot.sytes.net ./run.sh deploy

# Check logs
./run.sh logs

# Stop services
./run.sh stop
```

## 🔍 Troubleshooting

### Common Issues & Solutions

1. **Frontend loads but API calls fail**
   - Check that `API_URL` environment variable is set correctly
   - Verify backend is accessible at the specified URL
   - Check browser console for CORS errors

2. **CORS errors**
   - The nginx configuration includes CORS headers
   - For custom domains, update the CORS configuration in `nginx.prod.conf`

3. **SSL certificate errors**
   - Ensure certificates are valid and properly placed in `./ssl/` directory
   - Check certificate permissions

4. **Port conflicts**
   - Ensure ports 80, 443, 3000, and 8000 are available
   - Update docker-compose port mappings if needed

## 🎯 Next Steps

1. **Test the remote deployment:**
   ```bash
   API_URL=http://167.71.49.141:8000 ./run.sh deploy
   ```

2. **Access your app:**
   - Frontend: `http://167.71.49.141:3000`
   - Backend API: `http://167.71.49.141:8000/docs`

3. **Set up HTTPS when ready:**
   - Configure SSL certificates
   - Use production docker-compose configuration
   - Update DNS records for your domain

Your AI Chatbot should now be accessible from any device! 🎉