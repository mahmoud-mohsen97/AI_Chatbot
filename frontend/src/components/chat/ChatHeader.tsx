import { Bot } from "lucide-react";

interface ChatHeaderProps {
  botName?: string;
  tagline?: string;
  compact?: boolean;
}

export const ChatHeader = ({ 
  botName = "ChatBot", 
  compact = false 
}: ChatHeaderProps) => {
  return (
    <div className="border-b border-border bg-background p-4">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary">
          <Bot className="h-6 w-6 text-primary-foreground" />
        </div>
        <div>
          <h1 className="text-lg font-semibold text-foreground">{botName}</h1>
        </div>
      </div>
    </div>
  );
};