# packages/llm

LLM infrastructure package for ModSmith AI.

This package owns the model-provider boundary:

- LLM Gateway.
- Provider adapter interfaces.
- OpenAI-compatible MVP provider.
- Future provider adapters for OpenAI Responses-style APIs, Anthropic Messages-style APIs, Gemini generateContent-style APIs, Ollama/local APIs, image providers, and embedding providers.
- Prompt Composer.
- Prompt block registry.
- Cache policy abstraction.
- Structured output validation helpers.
- AI interaction metrics and logging helpers.

Agents should depend on this package for model access instead of calling vendor SDKs directly.
