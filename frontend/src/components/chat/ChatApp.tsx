import React, { useState, useEffect } from "react";
import { Bot } from "lucide-react";
import { ChatHeader } from "./ChatHeader";
import { MessageList } from "./MessageList";
import { QuickReplies, QuickReply } from "./QuickReplies";
import { InputBar } from "./InputBar";
import { Message } from "./MessageItem";
import { useToast } from "@/hooks/use-toast";
import { apiService, HospitalInfo } from "@/services/api";

export const ChatApp = () => {
  const { toast } = useToast();
  const [messages, setMessages] = useState<Message[]>([]);
  const [hasMessages, setHasMessages] = useState(false);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isStreaming, setIsStreaming] = useState(false);
  const [streamingMessageId, setStreamingMessageId] = useState<string | null>(null);
  const [hospitalInfo, setHospitalInfo] = useState<HospitalInfo | null>(null);
  const [quickReplies, setQuickReplies] = useState<QuickReply[]>([]);

  useEffect(() => {
    // Load hospital info and set initial quick replies
    const loadHospitalInfo = async () => {
      try {
        const info = await apiService.getHospitalInfo();
        setHospitalInfo(info);
        
        // Set initial quick replies based on hospital info - using exact FAQ questions
        const initialReplies = [
          { id: "services", text: "ما هي العيادات المتوفرة؟", action: "faq", fullText: "ما هي العيادات المتوفرة؟" },
          { id: "hours", text: "ما هي أوقات العمل؟", action: "faq", fullText: "ما هي أوقات العمل؟" },
          { id: "emergency", text: "أريد طلب سيارة إسعاف", action: "faq", fullText: "أريد طلب سيارة إسعاف" },
          { id: "location", text: "أين تقع المستشفى؟", action: "faq", fullText: "أين تقع المستشفى؟" },
        ];
        
        // Add FAQ questions as quick replies
        if (info.faq_questions.length > 0) {
          info.faq_questions.slice(0, 3).forEach((question, index) => {
            initialReplies.push({
              id: `faq_${index}`,
              text: question.length > 30 ? question.substring(0, 30) + "..." : question,
              action: "faq",
              fullText: question
            });
          });
        }
        
        setQuickReplies(initialReplies);
      } catch (error) {
        console.error('Failed to load hospital info:', error);
        toast({
          title: "خطأ في التحميل",
          description: "فشل في تحميل معلومات المستشفى",
          variant: "destructive",
        });
      }
    };

    loadHospitalInfo();
  }, [toast]);

  // Set hasMessages to true if there are already messages
  useEffect(() => {
    setHasMessages(messages.length > 0);
  }, [messages]);

  const generateId = () => Math.random().toString(36).substr(2, 9);

  const addMessage = (text: string, isUser: boolean, sources?: string[]) => {
    const newMessage: Message = {
      id: generateId(),
      text,
      isUser,
      timestamp: new Date(),
      sources,
    };
    setMessages(prev => [...prev, newMessage]);
    return newMessage.id;
  };

  const updateStreamingMessage = (messageId: string, text: string, sources?: string[]) => {
    setMessages(prev => 
      prev.map(msg => 
        msg.id === messageId 
          ? { ...msg, text, sources }
          : msg
      )
    );
  };

  const handleSendMessage = async (text: string, addUserMessage: boolean = true) => {
    // Prevent sending if already loading or streaming
    if (isLoading || isStreaming) return;
    
    setHasMessages(true);
    setIsLoading(true);
    
    if (addUserMessage) {
      addMessage(text, true);
    }
    
    try {
      // Use streaming API
      setIsStreaming(true);
      let streamingText = "";
      let finalConversationId: string | undefined;
      let finalSources: string[] | undefined;
      
      // Create initial empty message for streaming
      const messageId = addMessage("", false);
      setStreamingMessageId(messageId);
      
      for await (const event of apiService.sendMessageStream({
        message: text,
        conversation_id: conversationId || undefined,
        stream: true,
      })) {
        switch (event.type) {
          case 'status':
            // Show status updates (like "Processing your request...")
            updateStreamingMessage(messageId, event.content || '');
            break;
            
          case 'token':
            // Add each token to the streaming text
            streamingText += event.content || '';
            updateStreamingMessage(messageId, streamingText);
            break;
            
          case 'end':
            // Finalize the message
            finalConversationId = event.conversation_id;
            finalSources = event.sources;
            updateStreamingMessage(messageId, streamingText, finalSources);
            
            if (finalConversationId) {
              setConversationId(finalConversationId);
            }
            break;
            
          case 'error':
            // Handle errors
            updateStreamingMessage(messageId, `عذراً، حدث خطأ: ${event.content}`);
            toast({
              title: "خطأ في الإرسال",
              description: event.content || "حدث خطأ أثناء معالجة الرسالة",
              variant: "destructive",
            });
            break;
        }
      }
      
    } catch (error) {
      console.error('Failed to send message:', error);
      
      // If streaming message exists, update it with error
      if (streamingMessageId) {
        updateStreamingMessage(streamingMessageId, "عذراً، حدث خطأ في الإرسال. يرجى المحاولة مرة أخرى.");
      } else {
        addMessage("عذراً، حدث خطأ في الإرسال. يرجى المحاولة مرة أخرى.", false);
      }
      
      toast({
        title: "خطأ في الإرسال",
        description: "فشل في إرسال الرسالة",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
      setIsStreaming(false);
      setStreamingMessageId(null);
    }
  };

  const handleQuickReply = async (reply: QuickReply) => {
    // Prevent sending if already loading or streaming
    if (isLoading || isStreaming) return;
    
    setHasMessages(true);
    const messageText = reply.fullText || reply.text;
    
    // Add user message
    addMessage(messageText, true);
    
    // Always use the backend API for all quick replies (don't add user message again)
    await handleSendMessage(messageText, false);
  };

  if (!hasMessages) {
    return (
      <div className="flex h-screen flex-col items-center justify-center bg-background p-8">
        <div className="flex flex-col items-center text-center mb-12">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary mb-6">
            <Bot className="h-8 w-8 text-primary-foreground" />
          </div>
          <h1 className="text-4xl font-bold text-foreground mb-2">
            {hospitalInfo?.info.name || "AI Assistant"}
          </h1>
          <p className="text-xl text-muted-foreground">How can I help you today?</p>
        </div>
        <div className="w-full max-w-md">
          <QuickReplies replies={quickReplies} onReplyClick={handleQuickReply} centered />
        </div>
        <div className="w-full max-w-md mt-8">
          <InputBar onSendMessage={handleSendMessage} isLoading={isLoading || isStreaming} />
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-screen flex-col bg-background">
      <ChatHeader 
        botName={hospitalInfo?.info.name || "AI Assistant"} 
        compact 
      />
      <MessageList messages={messages} isLoading={isLoading} isStreaming={isStreaming} />
      <div className="p-4">
        <InputBar onSendMessage={handleSendMessage} isLoading={isLoading || isStreaming} />
      </div>
    </div>
  );
};