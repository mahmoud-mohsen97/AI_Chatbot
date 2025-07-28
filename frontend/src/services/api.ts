const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export interface ChatMessage {
  message: string;
  conversation_id?: string;
}

export interface ChatStreamMessage extends ChatMessage {
  stream?: boolean;
}

export interface ChatResponse {
  response: string;
  conversation_id: string;
  is_faq: boolean;
  sources?: string[];
}

export interface StreamEvent {
  type: 'token' | 'status' | 'end' | 'error';
  content?: string;
  conversation_id?: string;
  is_faq?: boolean;
  sources?: string[];
}

export interface HospitalInfo {
  info: {
    name: string;
    location: string;
    emergency_number: string;
    phone: string;
    email: string;
    website: string;
    visiting_hours: string;
    pharmacy_hours: string;
  };
  services: string[];
  faq_questions: string[];
  popular_questions: string[];
}

class ApiService {
  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${API_BASE_URL}${endpoint}`;
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`);
    }

    return response.json();
  }

  async sendMessage(message: ChatMessage): Promise<ChatResponse> {
    return this.request<ChatResponse>('/chat', {
      method: 'POST',
      body: JSON.stringify(message),
    });
  }

  async *sendMessageStream(message: ChatStreamMessage): AsyncGenerator<StreamEvent, void, unknown> {
    const url = `${API_BASE_URL}/chat/stream`;
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    });

    if (!response.ok) {
      throw new Error(`API request failed: ${response.status} ${response.statusText}`);
    }

    const reader = response.body?.getReader();
    if (!reader) {
      throw new Error('No response body reader available');
    }

    const decoder = new TextDecoder();

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n');

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            try {
              const data = JSON.parse(line.slice(6));
              yield data as StreamEvent;
            } catch (e) {
              console.error('Error parsing SSE data:', e);
            }
          }
        }
      }
    } finally {
      reader.releaseLock();
    }
  }

  async getHospitalInfo(): Promise<HospitalInfo> {
    return this.request<HospitalInfo>('/hospital-info');
  }
}

export const apiService = new ApiService(); 