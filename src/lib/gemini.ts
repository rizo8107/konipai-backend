/**
 * Utility for interacting with Google's Gemini API using direct API calls
 */
import { SERVER_ENV } from './env';

// The API key is loaded from environment variables
const GEMINI_API_KEY = SERVER_ENV.GEMINI_API_KEY;
const API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

/**
 * Generate WhatsApp template content using Gemini AI
 * @param templateType The type of template to generate (e.g., order_confirmation)
 * @param description Brief description of the template's purpose
 * @returns Generated template content
 */
export async function generateTemplateContent(
  templateType: string,
  description: string
): Promise<string> {
  try {
    // List of available variables for templates
    const availableVariables = [
      'customerName', 'orderId', 'amount', 'retryUrl', 'carrier',
      'trackingLink', 'estimatedDelivery', 'feedbackLink', 'reviewLink',
      'refundAmount', 'daysSinceDelivery', 'reorderLink', 'cartUrl'
    ];

    // Construct the prompt for Gemini
    const prompt = `
      Create a short WhatsApp message template for a business CRM system. The template type is: ${templateType}.
      
      Template purpose: ${description}
      
      IMPORTANT FORMATTING INSTRUCTIONS:
      1. Start with 1-2 relevant emojis followed by a *bold title*
      2. Use line breaks (\n) between paragraphs
      3. Keep the message under 500 characters total
      4. Format key information with *asterisks* to make it bold in WhatsApp
      5. Use a friendly, professional tone
      6. Include a clear call-to-action if relevant
      7. DO NOT include any explanations or comments about the template
      8. ONLY return the template text itself
      
      AVAILABLE VARIABLES (use exactly as shown):
      ${availableVariables.map(v => `- {{${v}}}`).join('\n')}
      
      For the template "${templateType}", be sure to include the most relevant variables from the list above.
      
      EXAMPLE FORMAT (for a different template type):
      🎉 *Order Confirmed* 🎉\n\nHi {{customerName}},\n\nYour order #{{orderId}} has been confirmed!\n\nThank you for shopping with us.\n\nWe'll update you when your order ships.
    `;

    // Call the Gemini API directly using the curl example format
    const response = await fetch(`${API_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: prompt }]
        }]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      console.error('Gemini API error:', errorData);
      throw new Error(`Gemini API error: ${errorData.error?.message || response.statusText || 'Unknown error'}`);
    }

    const data = await response.json();
    
    // Extract the generated text from the response
    const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text;
    
    if (!generatedText) {
      throw new Error('No content generated by Gemini API');
    }

    // Clean up the response to extract just the template content
    // Remove any markdown code blocks if present
    const cleanedText = generatedText.replace(/```[\s\S]*?```/g, '');
    
    // For debugging
    console.log('Raw Gemini response:', generatedText);
    
    // Return the full text if we can't extract a specific template pattern
    return cleanedText.trim();
  } catch (error) {
    console.error('Error generating template with Gemini:', error);
    throw new Error(`Failed to generate template: ${error.message}`);
  }
}

/**
 * Generate a description for a WhatsApp template
 * @param templateType The type of template
 * @returns Generated description
 */
export async function generateTemplateDescription(templateType: string): Promise<string> {
  try {
    const prompt = `Write a brief one-sentence description (maximum 100 characters) for a WhatsApp message template of type "${templateType}". The description should explain when this template would be sent to customers.`;

    // Call the Gemini API
    const response = await fetch(`${API_URL}?key=${GEMINI_API_KEY}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{ text: prompt }]
        }]
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Gemini API error: ${errorData.error?.message || response.statusText || 'Unknown error'}`);
    }

    const data = await response.json();
    const generatedText = data.candidates?.[0]?.content?.parts?.[0]?.text;
    
    if (!generatedText) {
      throw new Error('No content generated by Gemini API');
    }

    // For debugging
    console.log('Raw Gemini description response:', generatedText);
    
    // Clean up the response
    return generatedText.trim();
  } catch (error) {
    console.error('Error generating template description with Gemini:', error);
    return `Template for ${templateType.replace(/_/g, ' ').toLowerCase()}`;
  }
}
