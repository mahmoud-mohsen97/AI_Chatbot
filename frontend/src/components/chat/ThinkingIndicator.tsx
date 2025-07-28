import { Bot } from "lucide-react";
import { cn } from "@/lib/utils";

export const ThinkingIndicator = () => {
  return (
    <div className="flex w-full gap-3 justify-start">
      <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary">
        <Bot className="h-4 w-4 text-primary-foreground" />
      </div>
      
      <div className="max-w-[80%] rounded-2xl px-4 py-3 shadow-sm border border-chat-bubble-border bg-chat-bot-bg">
        <div className="flex items-center gap-2">
          <div className="flex space-x-1">
            <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
            <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
            <div className="w-2 h-2 bg-muted-foreground rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
          </div>
          <span className="text-sm text-muted-foreground">جاري التفكير...</span>
        </div>
      </div>
    </div>
  );
}; 