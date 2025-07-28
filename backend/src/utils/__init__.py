"""
Utility functions for the hospital chatbot.
"""

from .ui_components_fastapi import (
    get_faq_data,
    generate_static_faq_response,
    is_follow_up_to_faq
)

__all__ = [
    "get_faq_data",
    "generate_static_faq_response", 
    "is_follow_up_to_faq"
]
