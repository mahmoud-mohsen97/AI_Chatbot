# AI Chatbot - Hospital Assistant

A modern AI-powered hospital chatbot with a React frontend and FastAPI backend, featuring advanced conversation capabilities with LangGraph and retrieval-augmented generation (RAG).

## Features

- 🤖 **Intelligent Chat Interface**: Modern React-based chat UI with real-time responses
- 🏥 **Hospital-Specific Knowledge**: Specialized for hospital services, FAQs, and information
- 🔍 **Retrieval-Augmented Generation**: Uses vector database for accurate, context-aware responses  
- 📚 **FAQ System**: Quick access to frequently asked questions
- 🌐 **Multilingual Support**: Arabic and English interface support
- ⚡ **Real-time Communication**: Fast API responses with WebSocket-like experience
- 📱 **Responsive Design**: Works seamlessly on desktop and mobile devices

## Project Structure

```
AI_Chatbot/
├── backend/               # FastAPI backend
│   ├── src/              # Core backend logic
│   │   ├── chains/       # LangChain processing chains
│   │   ├── nodes/        # LangGraph nodes
│   │   └── utils/        # Utility functions
│   ├── config/           # Configuration settings
│   ├── data/             # Knowledge base and FAQ data
│   ├── main.py           # FastAPI application
│   └── requirements.txt  # Python dependencies
├── frontend/             # React TypeScript frontend
│   ├── src/
│   │   ├── components/   # React components
│   │   ├── services/     # API services
│   │   └── pages/        # Page components
│   ├── package.json      # Node.js dependencies
│   └── vite.config.ts    # Vite configuration
└── README.md
```

## Quick Start

### 🐳 Docker (Recommended)

The easiest way to run the entire application:

1. **Set up environment:**
   ```bash
   cd AI_Chatbot
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

2. **Run with the convenience script:**
   ```bash
   ./run.sh prod    # Production mode
   # OR
   ./run.sh dev     # Development mode with hot reload
   ```

3. **Access the application:**
   - Frontend: `http://localhost:3000` (production) or `http://localhost:5173` (development)
   - Backend API: `http://localhost:8000`
   - API Documentation: `http://localhost:8000/docs`

4. **Other useful commands:**
   ```bash
   ./run.sh logs    # View logs
   ./run.sh stop    # Stop all services
   ./run.sh clean   # Clean up containers and images
   ```

### 🔧 Manual Setup (Alternative)

#### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd AI_Chatbot/backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

5. **Start the backend server:**
   ```bash
   python main.py
   ```

   The API will be available at `http://localhost:8000`

#### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd AI_Chatbot/frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```

   The frontend will be available at `http://localhost:5173`

## API Endpoints

### Main Endpoints

- `GET /` - API status
- `GET /health` - Health check
- `POST /chat` - Send chat message
- `GET /hospital-info` - Get hospital information
- `GET /faq` - Get FAQ data
- `GET /conversation/{id}` - Get conversation history
- `DELETE /conversation/{id}` - Clear conversation

### Example API Usage

**Send a chat message:**
```bash
curl -X POST "http://localhost:8000/chat" \
     -H "Content-Type: application/json" \
     -d '{"message": "What are your visiting hours?"}'
```

**Get hospital information:**
```bash
curl -X GET "http://localhost:8000/hospital-info"
```

## Configuration

### Backend Configuration

Edit `backend/config/settings.py` to customize:

- Hospital information (name, location, contact details)
- Available services
- FAQ questions
- LLM settings (model, temperature, max tokens)

### Frontend Configuration

The frontend automatically connects to the backend API. You can customize:

- API endpoint URL in `frontend/src/services/api.ts`
- UI components in `frontend/src/components/`

## Technologies Used

### Backend
- **FastAPI** - Modern Python web framework
- **LangChain** - LLM application framework
- **LangGraph** - Graph-based conversation flow
- **ChromaDB** - Vector database for embeddings
- **OpenAI GPT** - Language model
- **Pydantic** - Data validation

### Frontend
- **React 18** - Modern React framework
- **TypeScript** - Type-safe JavaScript
- **Vite** - Fast build tool
- **Tailwind CSS** - Utility-first CSS framework
- **shadcn/ui** - Modern UI component library
- **Radix UI** - Accessible component primitives
- **React Query** - Data fetching and caching

## Development

### Adding New Features

1. **Backend**: Add new endpoints in `backend/main.py`
2. **Frontend**: Create new components in `frontend/src/components/`
3. **API Integration**: Update `frontend/src/services/api.ts`

### Customizing the Chatbot

1. **Update Hospital Info**: Edit `backend/config/settings.py`
2. **Add FAQ Data**: Update CSV files in `backend/data/`
3. **Modify UI**: Customize components in `frontend/src/components/`

## Deployment

### Using Docker (Recommended)

1. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

2. **Build and run with docker-compose:**
   ```bash
   docker-compose up --build
   ```

   This will start both services:
   - Backend API: `http://localhost:8000`
   - Frontend UI: `http://localhost:3000`

3. **Run in background:**
   ```bash
   docker-compose up -d --build
   ```

4. **View logs:**
   ```bash
   docker-compose logs -f
   ```

5. **Stop services:**
   ```bash
   docker-compose down
   ```

### Manual Deployment

1. **Backend**: Deploy FastAPI app using uvicorn, gunicorn, or similar
2. **Frontend**: Build with `npm run build` and serve static files

### Production Docker Deployment

For production, create a `docker-compose.prod.yml`:

```yaml
version: '3.8'
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - PYTHONPATH=/app
    env_file:
      - .env
    restart: always
    
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    environment:
      - VITE_API_URL=https://your-api-domain.com
    restart: always
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - backend
      - frontend
    restart: always
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For support and questions:
- Check the hospital information endpoint for contact details
- Review the FAQ section
- Create an issue in the repository

## License

This project is part of a hospital management system. Please ensure compliance with healthcare data regulations when deploying in production.
