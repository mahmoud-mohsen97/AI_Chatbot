import { Button } from "@/components/ui/button";

export interface QuickReply {
  id: string;
  text: string;
  action?: string;
  fullText?: string;
}

interface QuickRepliesProps {
  replies: QuickReply[];
  onReplyClick: (reply: QuickReply) => void;
  centered?: boolean;
}

export const QuickReplies = ({ replies, onReplyClick, centered = false }: QuickRepliesProps) => {
  // Debug: Log when component renders
  console.log(`QuickReplies rendered - centered: ${centered}, replies count: ${replies.length}`);
  
  if (replies.length === 0) return null;

  if (centered) {
    return (
      <div className="w-full" data-testid="quick-replies-centered">
        <div className="flex flex-wrap justify-center gap-2">
          {replies.map((reply) => (
            <Button
              key={reply.id}
              variant="outline"
              size="sm"
              onClick={() => onReplyClick(reply)}
              className="rounded-full text-sm hover:bg-accent transition-colors animate-scale-in"
              data-testid={`quick-reply-${reply.id}`}
            >
              {reply.text}
            </Button>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="border-t border-border bg-background p-4" data-testid="quick-replies-bottom">
      <p className="text-xs font-medium text-muted-foreground mb-3 uppercase tracking-wide">
        Quick Replies
      </p>
      <div className="flex flex-wrap gap-2">
        {replies.map((reply) => (
          <Button
            key={reply.id}
            variant="outline"
            size="sm"
            onClick={() => onReplyClick(reply)}
            className="rounded-full text-sm hover:bg-accent transition-colors animate-scale-in"
            data-testid={`quick-reply-${reply.id}`}
          >
            {reply.text}
          </Button>
        ))}
      </div>
    </div>
  );
};