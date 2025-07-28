import React, { useState, useCallback } from 'react';
import { apiService, ChatStreamMessage, StreamEvent } from '../services/api';

export const StreamingChatExample: React.FC = () => {
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState('');
  const [isStreaming, setIsStreaming] = useState(false);
  const [conversationId, setConversationId] = useState<string | undefined>();

  const handleStreamingChat = useCallback(async () => {
    if (!message.trim()) return;

    setIsStreaming(true);
    setResponse('');

    const streamMessage: ChatStreamMessage = {
      message: message.trim(),
      conversation_id: conversationId,
      stream: true,
    };

    try {
      let finalConversationId: string | undefined;
      
      for await (const event of apiService.sendMessageStream(streamMessage)) {
        const streamEvent = event as StreamEvent;
        
        switch (streamEvent.type) {
          case 'status':
            setResponse(streamEvent.content || '');
            break;
            
          case 'token':
            setResponse(prev => prev + (streamEvent.content || ''));
            break;
            
          case 'end':
            finalConversationId = streamEvent.conversation_id;
            if (streamEvent.sources) {
              setResponse(prev => prev + '\n\nSources: ' + streamEvent.sources?.join(', '));
            }
            break;
            
          case 'error':
            setResponse('Error: ' + (streamEvent.content || 'Unknown error'));
            break;
        }
      }
      
      if (finalConversationId) {
        setConversationId(finalConversationId);
      }
    } catch (error) {
      setResponse('Error: ' + (error as Error).message);
    } finally {
      setIsStreaming(false);
      setMessage('');
    }
  }, [message, conversationId]);

  return (
    <div className="p-4 max-w-2xl mx-auto">
      <h2 className="text-xl font-bold mb-4">Streaming Chat Example</h2>
      
      <div className="mb-4">
        <textarea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Type your message here..."
          className="w-full p-2 border rounded-lg"
          rows={3}
          disabled={isStreaming}
        />
      </div>
      
      <button
        onClick={handleStreamingChat}
        disabled={isStreaming || !message.trim()}
        className="px-4 py-2 bg-blue-500 text-white rounded-lg disabled:opacity-50"
      >
        {isStreaming ? 'Streaming...' : 'Send Message'}
      </button>
      
      {response && (
        <div className="mt-4 p-4 bg-gray-50 rounded-lg">
          <h3 className="font-semibold mb-2">Response:</h3>
          <div className="whitespace-pre-wrap">{response}</div>
        </div>
      )}
    </div>
  );
}; 