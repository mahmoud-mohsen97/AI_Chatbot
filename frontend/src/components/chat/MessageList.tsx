import { useEffect, useRef } from "react";
import { MessageItem, Message } from "./MessageItem";
import { ThinkingIndicator } from "./ThinkingIndicator";

interface MessageListProps {
  messages: Message[];
  isLoading?: boolean;
  isStreaming?: boolean;
}

export const MessageList = ({ messages, isLoading = false, isStreaming = false }: MessageListProps) => {
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(scrollToBottom, [messages, isLoading, isStreaming]);

  // Check if the last message is empty (just started streaming)
  const lastMessage = messages[messages.length - 1];
  const showThinkingIndicator = isStreaming && lastMessage && !lastMessage.isUser && lastMessage.text === "";

  return (
    <div className="flex-1 overflow-y-auto bg-background">
      <div className="flex flex-col gap-4 p-4">
        {messages.map((message) => {
          // Don't show empty streaming messages, we'll show thinking indicator instead
          if (isStreaming && !message.isUser && message.text === "") {
            return null;
          }
          return (
            <MessageItem 
              key={message.id} 
              message={message} 
              isStreaming={isStreaming && !message.isUser && message.text !== ""} 
            />
          );
        })}
        
        {/* Show thinking indicator when starting to stream */}
        {showThinkingIndicator && <ThinkingIndicator />}
        
        {/* Show thinking indicator when loading (non-streaming) */}
        {isLoading && !isStreaming && <ThinkingIndicator />}
        
        <div ref={messagesEndRef} />
      </div>
    </div>
  );
};