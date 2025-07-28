import { Bot, User } from "lucide-react";
import { cn } from "@/lib/utils";

export interface Message {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
  sources?: string[];
}

interface MessageItemProps {
  message: Message;
  isStreaming?: boolean;
}

// Simple markdown renderer component
const MarkdownRenderer = ({ content }: { content: string }) => {
  const renderMarkdown = (text: string) => {
    // Convert **bold** to <strong>
    text = text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
    
    // Convert *italic* to <em>
    text = text.replace(/\*(.*?)\*/g, '<em>$1</em>');
    
    // Convert bullet points
    text = text.replace(/^\* (.+)$/gm, '• $1');
    
    // Convert line breaks
    text = text.replace(/\n/g, '<br />');
    
    return text;
  };

  return (
    <div 
      className="text-sm leading-relaxed markdown-content"
      dangerouslySetInnerHTML={{ __html: renderMarkdown(content) }}
    />
  );
};

const StreamingCursor = () => (
  <span className="inline-block w-1 h-4 bg-foreground animate-pulse ml-1 rounded-sm"></span>
);

export const MessageItem = ({ message, isStreaming = false }: MessageItemProps) => {
  const isUser = message.isUser;

  return (
    <div 
      className={cn(
        "flex w-full gap-3 animate-fade-in",
        isUser ? "justify-end" : "justify-start"
      )}
    >
      {!isUser && (
        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary">
          <Bot className="h-4 w-4 text-primary-foreground" />
        </div>
      )}
      
      <div
        className={cn(
          "max-w-[80%] rounded-2xl px-4 py-3 shadow-sm",
          isUser
            ? "bg-chat-user-bg text-chat-user-text"
            : "border border-chat-bubble-border bg-chat-bot-bg text-chat-bot-text"
        )}
      >
        {!isUser ? (
          <div className="flex items-end">
            <MarkdownRenderer content={message.text} />
            {isStreaming && message.text && <StreamingCursor />}
          </div>
        ) : (
          <p className="text-sm leading-relaxed">{message.text}</p>
        )}
        
        {message.sources && message.sources.length > 0 && (
          <div className="mt-2 pt-2 border-t border-border">
            <p className="text-xs text-muted-foreground">
              المصادر: {message.sources.join(', ')}
            </p>
          </div>
        )}
      </div>

      {isUser && (
        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-muted">
          <User className="h-4 w-4 text-muted-foreground" />
        </div>
      )}
    </div>
  );
};