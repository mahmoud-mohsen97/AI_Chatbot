from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import time
import json
import asyncio
from dotenv import load_dotenv

from src.graph import app as graph_app
from src.utils.ui_components_fastapi import (
    get_faq_data,
    generate_static_faq_response,
    is_follow_up_to_faq
)
from config.settings import (
    HOSPITAL_INFO,
    HOSPITAL_SERVICES,
    SAMPLE_FAQ_QUESTIONS,
    POPULAR_QUESTIONS
)

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="Hospital Chatbot API",
    description="API for Hospital Chatbot with AI-powered conversation",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173", "http://localhost:8080"],  # Frontend URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models for request/response
class ChatMessage(BaseModel):
    message: str
    conversation_id: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    conversation_id: str
    is_faq: bool = False
    sources: Optional[List[str]] = None

class HospitalInfoResponse(BaseModel):
    info: Dict[str, Any]
    services: List[str]
    faq_questions: List[str]
    popular_questions: List[str]

class ChatStreamMessage(BaseModel):
    message: str
    conversation_id: Optional[str] = None
    stream: bool = True

# In-memory storage for conversations (in production, use a database)
conversations: Dict[str, List[Dict[str, Any]]] = {}

@app.get("/")
async def root():
    return {"message": "Hospital Chatbot API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/hospital-info", response_model=HospitalInfoResponse)
async def get_hospital_info():
    """Get hospital information, services, and FAQ data"""
    return HospitalInfoResponse(
        info=HOSPITAL_INFO,
        services=HOSPITAL_SERVICES,
        faq_questions=SAMPLE_FAQ_QUESTIONS,
        popular_questions=POPULAR_QUESTIONS
    )

async def generate_stream_response(message: ChatMessage):
    """Generate streaming response for chat"""
    try:
        conversation_id = message.conversation_id or f"conv_{int(time.time())}"
        
        # Initialize conversation if not exists
        if conversation_id not in conversations:
            conversations[conversation_id] = []
        
        # Add user message to conversation
        conversations[conversation_id].append({
            "role": "user",
            "content": message.message,
            "timestamp": time.time()
        })
        
        # Check if this is an FAQ question first
        faq_data = get_faq_data()
        is_faq = False
        sources = None
        
        # Check for FAQ match
        faq_response = generate_static_faq_response(message.message, faq_data)
        if faq_response:
            response = faq_response
            is_faq = True
            
            # Stream the FAQ response
            yield f"data: {json.dumps({'type': 'token', 'content': response})}\n\n"
            yield f"data: {json.dumps({'type': 'end', 'conversation_id': conversation_id, 'is_faq': is_faq, 'sources': sources})}\n\n"
        else:
            # Check if it's a follow-up to FAQ
            last_messages = conversations[conversation_id][-5:] if len(conversations[conversation_id]) >= 5 else conversations[conversation_id]
            follow_up_response = is_follow_up_to_faq(message.message, last_messages, faq_data)
            
            if follow_up_response:
                response = follow_up_response
                is_faq = True
                
                # Stream the follow-up response
                yield f"data: {json.dumps({'type': 'token', 'content': response})}\n\n"
                yield f"data: {json.dumps({'type': 'end', 'conversation_id': conversation_id, 'is_faq': is_faq, 'sources': sources})}\n\n"
            else:
                # Use the LangGraph pipeline for complex queries
                conversation_history = conversations[conversation_id][:-1] if len(conversations[conversation_id]) > 1 else []
                
                # Stream status updates
                yield f"data: {json.dumps({'type': 'status', 'content': 'Processing your request...'})}\n\n"
                
                result = graph_app.invoke({
                    "question": message.message,
                    "conversation_history": conversation_history
                })
                response = result.get("generation", "I apologize, but I'm having trouble processing your request right now. Please try again.")
                
                # Extract sources if available
                if "documents" in result and result["documents"]:
                    sources = [doc.metadata.get("source", "Unknown") for doc in result["documents"][:3]]
                
                # Stream the response word by word for a more natural feel
                words = response.split()
                for i, word in enumerate(words):
                    if i == 0:
                        yield f"data: {json.dumps({'type': 'token', 'content': word})}\n\n"
                    else:
                        yield f"data: {json.dumps({'type': 'token', 'content': ' ' + word})}\n\n"
                    await asyncio.sleep(0.05)  # Small delay between words
                
                yield f"data: {json.dumps({'type': 'end', 'conversation_id': conversation_id, 'is_faq': is_faq, 'sources': sources})}\n\n"
        
        # Add assistant response to conversation
        conversations[conversation_id].append({
            "role": "assistant",
            "content": response,
            "timestamp": time.time(),
            "is_faq": is_faq,
            "sources": sources
        })
        
    except Exception as e:
        yield f"data: {json.dumps({'type': 'error', 'content': f'Error processing request: {str(e)}'})}\n\n"

@app.post("/chat/stream")
async def chat_stream(message: ChatStreamMessage):
    """Streaming chat endpoint"""
    return StreamingResponse(
        generate_stream_response(message),
        media_type="text/plain",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Content-Type": "text/event-stream",
        }
    )

@app.post("/chat", response_model=ChatResponse)
async def chat(message: ChatMessage):
    """Main chat endpoint"""
    try:
        conversation_id = message.conversation_id or f"conv_{int(time.time())}"
        
        # Initialize conversation if not exists
        if conversation_id not in conversations:
            conversations[conversation_id] = []
        
        # Add user message to conversation
        conversations[conversation_id].append({
            "role": "user",
            "content": message.message,
            "timestamp": time.time()
        })
        
        # Check if this is an FAQ question
        faq_data = get_faq_data()
        is_faq = False
        sources = None
        
        # Check for FAQ match
        faq_response = generate_static_faq_response(message.message, faq_data)
        if faq_response:
            response = faq_response
            is_faq = True
        else:
            # Check if it's a follow-up to FAQ
            last_messages = conversations[conversation_id][-5:] if len(conversations[conversation_id]) >= 5 else conversations[conversation_id]
            follow_up_response = is_follow_up_to_faq(message.message, last_messages, faq_data)
            
            if follow_up_response:
                response = follow_up_response
                is_faq = True
            else:
                # Use the LangGraph pipeline for complex queries
                # Get conversation history for context (excluding the current message)
                conversation_history = conversations[conversation_id][:-1] if len(conversations[conversation_id]) > 1 else []
                
                result = graph_app.invoke({
                    "question": message.message,
                    "conversation_history": conversation_history
                })
                response = result.get("generation", "I apologize, but I'm having trouble processing your request right now. Please try again.")
                
                # Extract sources if available
                if "documents" in result and result["documents"]:
                    sources = [doc.metadata.get("source", "Unknown") for doc in result["documents"][:3]]
        
        # Add assistant response to conversation
        conversations[conversation_id].append({
            "role": "assistant",
            "content": response,
            "timestamp": time.time(),
            "is_faq": is_faq,
            "sources": sources
        })
        
        return ChatResponse(
            response=response,
            conversation_id=conversation_id,
            is_faq=is_faq,
            sources=sources
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing chat request: {str(e)}")

@app.get("/conversation/{conversation_id}")
async def get_conversation(conversation_id: str):
    """Get conversation history"""
    if conversation_id not in conversations:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    return {
        "conversation_id": conversation_id,
        "messages": conversations[conversation_id],
        "message_count": len(conversations[conversation_id])
    }

@app.delete("/conversation/{conversation_id}")
async def clear_conversation(conversation_id: str):
    """Clear conversation history"""
    if conversation_id in conversations:
        del conversations[conversation_id]
    
    return {"message": "Conversation cleared successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 