from typing import List, Dict, Any, Optional
import pandas as pd
import logging
from config.settings import FAQ_DATA_FILE

logger = logging.getLogger(__name__)

def get_faq_data() -> Dict[str, str]:
    """Load FAQ data from CSV file."""
    try:
        df = pd.read_csv(str(FAQ_DATA_FILE))
        return dict(zip(df["question"], df["answer"]))
    except Exception as e:
        logger.error(f"Error loading FAQ data: {e}")
        return {}

def generate_static_faq_response(faq_question: str, faq_data: Dict[str, str]) -> Optional[str]:
    """
    Generate a static response for FAQ using the answer directly from CSV.
    Returns None if no exact match is found.
    """
    return faq_data.get(faq_question, None)

def is_follow_up_to_faq(current_message: str, messages: List[Dict], faq_data: Dict[str, str]) -> Optional[str]:
    """
    Check if the current message is a follow-up to a recent FAQ.
    Returns FAQ follow-up response if applicable, None otherwise.
    """
    if len(messages) < 2:
        return None
    
    # Get the last assistant message
    last_assistant_msg = None
    for msg in reversed(messages):
        if msg.get("role") == "assistant":
            last_assistant_msg = msg
            break
    
    if not last_assistant_msg:
        return None
    
    # Check if the last response was from FAQ
    last_response = last_assistant_msg.get("content", "")
    
    # Simple keyword matching for follow-up questions
    follow_up_keywords = [
        "المزيد", "أكثر", "تفاصيل", "معلومات", "كيف", "متى", "أين", 
        "لماذا", "ماذا", "هل", "more", "how", "when", "where", "what"
    ]
    
    is_follow_up = any(keyword in current_message.lower() for keyword in follow_up_keywords)
    
    if is_follow_up and any(answer in last_response for answer in faq_data.values()):
        return "يمكنني مساعدتك بمزيد من التفاصيل. يرجى توضيح ما تريد معرفته بالتحديد."
    
    return None 