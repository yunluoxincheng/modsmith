# AI / AI Agent 常用术语与缓存命中率优化研究报告

> 适用方向：AI Agent、RAG 知识库、模型路由、Prompt Cache、Semantic Cache、Tool Result Cache、Agent 后端架构设计  
> 重点关注：缓存命中率优化不能盲目追求高命中，必须保证缓存结果可验证、可追踪、可失效、可正确引用。

---

## 目录

1. 推荐优先阅读的论文和资料
2. AI 基础名词
3. RAG 知识库相关名词
4. AI Agent 相关名词
5. 缓存和性能相关名词
6. 模型调用和 API 相关名词
7. AI 应用工程相关名词
8. Agent 架构相关名词
9. Agent 缓存命中率优化专题
10. 缓存正确性：为什么不能盲目提高命中率
11. 推荐的 Agent 缓存架构
12. 缓存 Key 设计
13. 提高缓存命中率的实战规则
14. 项目落地建议
15. 参考资料

---

## 1. 推荐优先阅读的论文和资料

| 主题 | 推荐资料 | 重点 |
|---|---|---|
| Transformer / LLM 基础 | Attention Is All You Need | 提出 Transformer 架构，现代 LLM 的基础 |
| RAG | Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks | RAG 将模型参数化知识和外部检索知识结合 |
| Agent / ReAct | ReAct: Synergizing Reasoning and Acting in Language Models | 让模型交替进行推理和行动 |
| Tool Calling | Toolformer | 研究模型如何调用外部 API 和工具 |
| 自我反思 | Self-Refine | 模型通过自我反馈和迭代优化提升结果 |
| Embedding | Sentence-BERT | 语义向量表示和相似度计算 |
| 向量检索 | FAISS / Billion-scale similarity search with GPUs | 大规模向量相似度搜索 |
| 关键词检索 | BM25 and Beyond | 关键词检索经典算法 |
| 高质量检索 | ColBERT | 通过 late interaction 提高检索质量 |
| LLM 语义缓存 | GPTCache | 面向大模型请求的语义缓存系统 |
| Prompt / Semantic Cache | GPT Semantic Cache | 研究语义缓存减少 API 调用 |
| KV Cache | vLLM / PagedAttention | 大模型推理 KV Cache 内存优化 |

---

## 2. AI 基础名词

### 2.1 大模型 LLM

LLM，全称 Large Language Model，即大语言模型。它是基于大规模文本、代码和多领域数据训练出来的通用语言理解与生成模型。

常见模型包括：

- GPT
- Claude
- DeepSeek
- GLM
- Qwen
- Gemini
- Llama

在 AI Agent 系统中，LLM 通常扮演“推理核心”或“决策核心”的角色。

---

### 2.2 多模态模型 Multimodal Model

多模态模型不只处理文本，还可以处理图片、音频、视频、截图、PDF 页面等信息。

例如：

- 图片问答
- 图表分析
- 文档截图理解
- 代码截图识别
- 语音转文本后理解

对 Agent 来说，多模态能力可以扩展工具边界，例如让 Agent 读取 UI 截图、分析设计稿、理解图表。

---

### 2.3 推理 Inference

推理是模型上线后，根据输入生成输出的过程。

例如：

```text
用户输入问题 → 模型生成答案
```

推理成本通常和以下因素相关：

- 输入 token 数
- 输出 token 数
- 模型大小
- 上下文长度
- 是否启用工具调用
- 是否启用长推理

---

### 2.4 训练 Training

训练是使用大量数据调整模型参数，让模型学习语言、知识、代码、推理模式的过程。

普通开发者通常不会从零训练大模型，而是使用现成模型 API 或开源模型。

---

### 2.5 微调 Fine-tuning

微调是在已有模型基础上，用特定领域数据继续训练，让模型适配某类任务。

适合场景：

- 固定客服话术
- 垂直行业问答
- 代码风格统一
- 结构化输出格式适配
- 企业内部专业知识问答

但对于大多数 Agent 项目，优先级通常是：

```text
Prompt 优化 > RAG > 工具调用 > 缓存优化 > 微调
```

---

### 2.6 上下文 Context

上下文是模型当前能看到的所有内容，包括：

- 系统提示词
- 用户问题
- 历史对话
- RAG 检索片段
- 工具返回结果
- 输出格式要求
- 项目背景资料

Agent 的表现很大程度取决于上下文组织质量。

---

### 2.7 上下文窗口 Context Window

上下文窗口是模型一次最多能处理的 token 数。

例如：

- 32K
- 128K
- 200K
- 1M

上下文越大，可以塞入更多信息，但并不意味着效果一定更好。过长上下文会带来：

- 成本上升
- 延迟增加
- 注意力稀释
- 缓存难度增加
- 噪声干扰增多

---

### 2.8 Token

Token 是模型处理文本的基本单位，可以近似理解为“字 / 词 / 词片段”。

中文通常一个字接近一个 token，但不同模型 tokenizer 不完全一致。

Token 成本一般分为：

- 输入 token 成本
- 输出 token 成本
- 缓存 token 成本
- 推理 token 成本

---

### 2.9 Prompt

Prompt 是给模型的任务说明。

它可以是简单问题：

```text
什么是 RAG？
```

也可以是复杂指令：

```text
你是一个 Java 后端架构师，请基于以下项目背景，输出 Spring Boot 项目的 AI Agent 缓存架构设计方案，要求包含 Redis、PostgreSQL、Qdrant 和模型路由。
```

---

### 2.10 System Prompt

System Prompt 是系统级提示词，通常用于定义：

- 模型角色
- 安全边界
- 输出风格
- 工具调用规则
- 禁止行为
- 格式要求

Agent 项目中，System Prompt 是非常重要的稳定前缀，应该尽量保持不变，以提高 Prompt Cache 命中率。

---

### 2.11 User Prompt

User Prompt 是用户实际输入的问题或任务。

在缓存设计中，User Prompt 通常属于动态内容，应放在 Prompt 后部，避免破坏稳定前缀缓存。

---

### 2.12 Temperature

Temperature 控制模型输出随机性。

| 值 | 特点 |
|---|---|
| 低 temperature | 稳定、保守、适合代码和结构化输出 |
| 高 temperature | 发散、有创意、适合头脑风暴和写作 |

Agent 系统中，执行类任务通常建议使用低 temperature。

---

### 2.13 Top-p

Top-p 是一种采样控制参数，用于限制模型从概率累计达到 p 的候选 token 中采样。

它和 temperature 一起影响输出的随机性和创造性。

---

### 2.14 Hallucination 幻觉

幻觉是模型生成看起来合理但实际错误的信息。

降低幻觉的方法：

- RAG 检索增强
- Citation 引用来源
- 工具调用验证
- 结构化输出校验
- 多模型交叉检查
- 限制模型只能基于上下文回答

---

## 3. RAG 知识库相关名词

RAG，全称 Retrieval-Augmented Generation，即检索增强生成。

核心思想：

```text
不要让模型只靠自身记忆回答，而是先检索外部资料，再基于资料生成答案。
```

---

### 3.1 RAG

标准流程：

```text
用户问题
  ↓
Query Rewrite 查询改写
  ↓
Embedding 向量化
  ↓
Vector Search 向量检索
  ↓
Rerank 重排序
  ↓
Context Injection 上下文注入
  ↓
LLM Generation 大模型生成
  ↓
Citation 引用来源
```

---

### 3.2 Retrieval 检索

检索是从外部资料中找出与用户问题相关的内容。

数据来源可以包括：

- PDF
- Markdown
- Word 文档
- 数据库
- 网页
- API
- 代码仓库
- 用户历史记录

---

### 3.3 Generation 生成

生成是模型基于用户问题和检索结果生成自然语言答案。

在 RAG 中，生成阶段应该被限制为：

```text
基于检索到的资料回答，而不是自由发挥。
```

---

### 3.4 Embedding 向量化

Embedding 是把文本转换为向量的过程。

例如：

```text
"什么是 RAG？" → [0.12, -0.56, 0.33, ...]
```

语义相近的文本，向量距离更近。

---

### 3.5 Vector Database 向量数据库

向量数据库用于存储和检索 embedding。

常见选择：

- FAISS
- Milvus
- Qdrant
- Chroma
- Weaviate
- pgvector

如果你做 Java / Spring Boot 项目，比较容易落地的选择是：

- PostgreSQL + pgvector
- Qdrant
- Redis Vector Search

---

### 3.6 Chunking 文档切片

Chunking 是把长文档拆成小片段。

原因：

- 模型上下文有限
- 检索整篇文档不精确
- 小片段更适合向量匹配
- 可控制注入上下文长度

常见参数：

- chunk size
- chunk overlap
- 按段落切
- 按标题切
- 按语义切
- 按代码函数切

---

### 3.7 Chunk 文档块

Chunk 是文档切片后的片段，是 RAG 中最常见的检索单位。

一个 chunk 应该包含：

- chunk_id
- document_id
- text
- metadata
- page
- section
- version
- embedding

---

### 3.8 Top-K

Top-K 表示检索时返回最相关的前 K 条结果。

例如：

```text
Top-K = 5
```

表示返回最相关的 5 个 chunk。

K 太小可能漏召回，K 太大可能引入噪声。

---

### 3.9 Similarity 相似度

相似度用于判断 query 和 chunk 的相关程度。

常见计算方式：

- cosine similarity
- dot product
- Euclidean distance
- BM25 score

---

### 3.10 Semantic Search 语义搜索

语义搜索根据含义检索，而不是只看关键词。

例如：

```text
“如何减少大模型调用成本”
```

可能匹配到：

```text
“LLM 缓存优化策略”
```

即使二者字面关键词不同，语义也相近。

---

### 3.11 Keyword Search 关键词搜索

关键词搜索根据字面匹配内容。

典型算法：

- BM25
- TF-IDF
- Elasticsearch inverted index

关键词搜索特别适合：

- 类名
- 方法名
- API 名称
- 报错信息
- 订单号
- 文件名
- 专业缩写

---

### 3.12 Hybrid Search 混合检索

混合检索结合：

```text
向量检索 + 关键词检索
```

适合中文知识库、代码库、技术文档和企业内部资料。

---

### 3.13 Rerank 重排序

Rerank 是先召回一批候选结果，再用更强模型重新排序。

常见流程：

```text
Top-50 粗召回 → Reranker 排序 → 选 Top-5 注入上下文
```

---

### 3.14 Reranker 重排序模型

Reranker 通常比 embedding 模型更准，但更慢。

适合用于：

- 高质量问答
- 复杂文档检索
- 多段内容排序
- 降低 RAG 噪声

---

### 3.15 Recall 召回率

召回率表示应该被找出来的内容中，有多少被成功找出来。

RAG 中召回率低会导致：

```text
模型没有看到正确资料，因此无法正确回答。
```

---

### 3.16 Precision 精确率

精确率表示检索出来的内容中，有多少真正有用。

精确率低会导致：

- 上下文污染
- 模型被错误资料误导
- 回答变长但不准确

---

### 3.17 Knowledge Base 知识库

知识库是给 AI 检索的外部资料集合。

可以包括：

- 用户上传文件
- 公司内部文档
- API 文档
- 项目代码
- 数据库记录
- 网页资料

---

### 3.18 Grounding 事实锚定

Grounding 是要求模型基于资料回答，而不是凭空生成。

可以通过以下方式实现：

- 引用来源
- 限制回答范围
- 检索片段注入
- 要求“不知道就说不知道”
- 让模型输出依据 ID

---

### 3.19 Citation 引用

Citation 是回答中标明信息来源。

例如：

```text
该结论来自 document_id=xxx, chunk_id=yyy, page=3。
```

Agent 缓存系统中，缓存结果也必须保留引用来源，否则命中缓存后无法判断答案依据是否仍然有效。

---

### 3.20 Context Injection 上下文注入

Context Injection 是把检索到的资料插入 Prompt。

关键问题：

- 注入多少内容
- 按什么顺序注入
- 是否包含元数据
- 是否包含引用 ID
- 是否压缩摘要
- 是否区分可信来源

---

## 4. AI Agent 相关名词

AI Agent 可以理解为：

```text
LLM + 工具 + 规划 + 状态 + 记忆 + 执行循环
```

---

### 4.1 AI Agent 智能体

AI Agent 是能接收目标、拆解任务、调用工具、观察结果并继续执行的 AI 系统。

普通聊天机器人：

```text
用户问 → 模型答
```

Agent：

```text
用户给目标 → Agent 制定计划 → 调用工具 → 观察结果 → 修正计划 → 继续执行 → 输出结果
```

---

### 4.2 Agentic AI

Agentic AI 强调 AI 具备一定自主性，可以完成多步任务，而不只是单轮回答。

---

### 4.3 Tool Calling 工具调用

Tool Calling 是让模型调用外部工具的能力。

常见工具：

- 搜索
- 数据库查询
- 文件读写
- 代码执行
- HTTP API
- 邮件
- 日历
- GitHub
- Shell 命令

---

### 4.4 Function Calling 函数调用

Function Calling 是 Tool Calling 的一种形式。

模型输出类似：

```json
{
  "function": "search_docs",
  "arguments": {
    "query": "RAG 缓存优化"
  }
}
```

然后系统真正执行函数。

---

### 4.5 Planning 规划

Planning 是 Agent 把复杂目标拆成步骤。

例如：

```text
目标：分析一个 Spring Boot 项目的鉴权模块

计划：
1. 扫描项目结构
2. 找 Controller、Filter、SecurityConfig
3. 分析登录流程
4. 检查 JWT 生成和校验
5. 输出风险和优化建议
```

---

### 4.6 Reasoning 推理

Reasoning 是模型分析任务、判断下一步行动的过程。

Agent 中的推理通常用于：

- 选择工具
- 判断是否需要检索
- 判断是否继续执行
- 判断结果是否可信
- 判断是否需要用户确认

---

### 4.7 Action 行动

Action 是 Agent 的具体执行动作。

例如：

- 调用 search 工具
- 执行 grep
- 读取文件
- 查询数据库
- 调用模型
- 写入文档

---

### 4.8 Observation 观察结果

Observation 是工具执行后的返回结果。

Agent 会根据 Observation 决定下一步。

---

### 4.9 ReAct

ReAct = Reason + Act。

典型循环：

```text
Thought → Action → Observation → Thought → Action → Observation → Final Answer
```

它让模型不是一次性回答，而是边推理边行动。

---

### 4.10 Reflection 反思

Reflection 是 Agent 检查自己结果是否正确的过程。

例如：

- 代码是否能运行
- 引用是否存在
- 工具结果是否支持结论
- 输出是否符合格式
- 是否遗漏用户要求

---

### 4.11 Memory 记忆

Memory 是 Agent 保存信息的能力。

分为：

- 短期记忆
- 长期记忆

---

### 4.12 Short-term Memory 短期记忆

短期记忆保存当前会话或当前任务的信息。

例如：

- 当前用户问题
- 当前任务状态
- 当前工具结果
- 当前临时计划

---

### 4.13 Long-term Memory 长期记忆

长期记忆保存跨会话信息。

例如：

- 用户偏好
- 项目背景
- 常用技术栈
- 历史决策
- 长期任务进度

---

### 4.14 Multi-Agent 多智能体

Multi-Agent 是多个 Agent 分工合作。

常见角色：

- Planner
- Coder
- Reviewer
- Tester
- Researcher
- Executor

---

### 4.15 Orchestrator 编排器

Orchestrator 是 Agent 系统的调度中心。

负责：

- 接收请求
- 调用 Planner
- 调用工具
- 管理状态
- 处理缓存
- 调度模型
- 汇总结果

---

### 4.16 Worker Agent 工作智能体

Worker Agent 负责执行具体任务。

---

### 4.17 Planner Agent 规划智能体

Planner Agent 负责任务拆解和流程规划。

---

### 4.18 Executor Agent 执行智能体

Executor Agent 负责调用工具和执行动作。

---

### 4.19 Critic Agent 评审智能体

Critic Agent 负责检查结果、发现问题、提出修改建议。

---

### 4.20 Autonomous Agent 自主智能体

Autonomous Agent 可以较少依赖人工干预，连续完成多个步骤。

但生产环境中不建议让 Agent 完全无限制自主执行。

---

### 4.21 Human-in-the-loop 人在回路

人在回路表示关键步骤需要用户确认。

必须确认的操作：

- 删除数据
- 部署生产环境
- 付款
- 修改权限
- 发送邮件
- 访问敏感数据
- 执行危险命令

---

## 5. 缓存和性能相关名词

---

### 5.1 Cache 缓存

缓存是把之前计算过或查询过的结果保存起来，下次复用。

AI 系统中缓存可以减少：

- 模型调用
- token 消耗
- 工具调用
- 数据库查询
- 向量检索
- Rerank 成本

---

### 5.2 Cache Hit 缓存命中

缓存命中表示请求可以直接复用已有缓存结果。

例如：

```text
用户问题 → 查询缓存 → 找到可用结果 → 直接返回
```

---

### 5.3 Cache Miss 缓存未命中

缓存未命中表示没有找到可用结果，需要重新计算。

---

### 5.4 Hit Rate 命中率

命中率计算：

```text
cache_hit_rate = cache_hit_count / total_request_count
```

但在 Agent 中，不能只看总命中率，还要分层统计：

- exact_cache_hit_rate
- semantic_cache_hit_rate
- prompt_cache_hit_rate
- tool_cache_hit_rate
- rag_cache_hit_rate
- final_answer_cache_hit_rate

---

### 5.5 Prompt Cache 提示词缓存

Prompt Cache 是供应商或框架对重复 prompt 前缀进行缓存。

适合缓存：

- 系统提示词
- 工具定义
- 输出 JSON Schema
- 项目背景
- 长文档内容
- 固定规则

Prompt Cache 的核心原则：

```text
稳定内容放前面，动态内容放后面。
```

---

### 5.6 KV Cache

KV Cache 是 Transformer 推理时缓存 attention 的 key/value 中间结果。

它主要用于模型推理加速，尤其是自部署模型时非常重要。

---

### 5.7 Semantic Cache 语义缓存

Semantic Cache 不是要求用户问题完全一样，而是判断语义相似就复用结果。

例如：

```text
“RAG 是什么？”
“解释一下 RAG”
“介绍 RAG 的工作流程”
```

可以命中同一类缓存。

---

### 5.8 Result Cache 结果缓存

Result Cache 是缓存最终回答。

适合：

- FAQ
- 稳定概念解释
- 固定教程
- 不涉及隐私和实时性的内容

不适合：

- 实时新闻
- 当前价格
- 用户权限
- 订单状态
- 私有文件变化频繁的问答

---

### 5.9 TTL

TTL，全称 Time To Live，即缓存有效时间。

例如：

```text
TTL = 10 minutes
```

表示缓存 10 分钟后自动过期。

---

### 5.10 Cache Invalidation 缓存失效

缓存失效是清除或更新不再可靠的缓存。

触发条件：

- 文档更新
- 用户权限变化
- 工具结果过期
- 业务数据变化
- Prompt 模板更新
- 模型版本变化
- 检索策略变化

---

### 5.11 Cold Start 冷启动

冷启动指服务刚启动、模型刚加载、缓存为空时，首次请求较慢。

---

### 5.12 Warm-up 预热

预热是提前加载模型、连接数据库、初始化缓存、预跑常见请求。

---

### 5.13 Latency 延迟

Latency 是请求到响应之间的时间。

AI Agent 延迟通常来自：

- LLM 调用
- 工具调用
- 检索
- Rerank
- 多轮推理
- 网络请求

---

### 5.14 Throughput 吞吐量

吞吐量是单位时间系统能处理的请求数量。

---

### 5.15 QPS

QPS，全称 Queries Per Second，即每秒请求数。

---

### 5.16 TPS

TPS，在 AI 推理中常指 Tokens Per Second，即每秒生成 token 数。

---

### 5.17 Rate Limit 限流

限流用于限制请求频率，防止服务过载或超出 API 配额。

---

### 5.18 Token Usage

Token Usage 是输入和输出消耗的 token 数。

Agent 多轮执行时，token 成本可能快速上升。

---

### 5.19 Cost Optimization 成本优化

成本优化方式包括：

- 缓存
- 模型路由
- 降级模型
- RAG 压缩
- Prompt 前缀复用
- 工具结果缓存
- 减少无效重试
- 使用小模型做预处理

---

## 6. 模型调用和 API 相关名词

---

### 6.1 API Key

API Key 是调用模型服务的密钥。

注意：

- 不要提交到 GitHub
- 不要写死到前端
- 应存储在环境变量或密钥管理系统
- 需要支持轮换

---

### 6.2 Endpoint

Endpoint 是 API 地址。

例如：

```text
/v1/chat/completions
/v1/responses
/v1/embeddings
```

---

### 6.3 Model ID

Model ID 是模型标识。

例如：

```text
gpt-5.5
deepseek-chat
glm-5.1
claude-sonnet
```

---

### 6.4 Streaming

Streaming 是流式输出，模型边生成边返回。

优点：

- 用户体验更好
- 首 token 延迟更低
- 适合聊天和长文生成

---

### 6.5 Non-streaming

Non-streaming 是非流式输出，模型生成完成后一次性返回。

适合：

- 后台任务
- 结构化输出
- JSON 解析
- 工作流中间步骤

---

### 6.6 Retry

Retry 是失败重试。

Agent 中重试要注意：

- 最大重试次数
- 指数退避
- 幂等性
- 避免重复扣费
- 避免重复写入

---

### 6.7 Timeout

Timeout 是超时控制。

每个工具调用都应该设置 timeout。

---

### 6.8 Fallback

Fallback 是降级备用。

例如：

```text
GPT 调用失败 → 切换 GLM
高价模型超预算 → 切换 DeepSeek
Reranker 失败 → 使用 embedding 原始排序
```

---

### 6.9 Router

Router 是模型路由，根据任务选择模型。

可以按以下维度路由：

- 成本
- 上下文长度
- 推理能力
- 代码能力
- 速度
- 可用额度
- 任务类型

---

### 6.10 Load Balancing

Load Balancing 是负载均衡。

可以在多个模型服务、多个 API Key、多个供应商之间分发请求。

---

### 6.11 Batch Processing

Batch Processing 是批处理。

适合：

- 批量 embedding
- 批量总结
- 批量分类
- 离线文档处理

---

### 6.12 Structured Output

Structured Output 是让模型按固定结构输出，例如 JSON。

适合 Agent：

- 工具调用参数
- 执行计划
- 检索结果判断
- 缓存命中判断
- 风险评估

---

### 6.13 JSON Schema

JSON Schema 是 JSON 结构约束。

它可以限制：

- 字段名
- 字段类型
- 是否必填
- 枚举值
- 嵌套结构

---

### 6.14 Guardrails 护栏

Guardrails 是安全和质量控制机制。

包括：

- 权限检查
- 输出过滤
- JSON 校验
- 敏感操作确认
- 黑名单工具限制
- 引用完整性检查

---

## 7. AI 应用工程相关名词

---

### 7.1 Prompt Engineering

Prompt Engineering 是提示词工程。

目标：

- 提高准确性
- 降低幻觉
- 稳定格式
- 控制风格
- 提升工具调用正确率

---

### 7.2 Prompt Template

Prompt Template 是提示词模板。

例如：

```text
你是一个{role}，请基于以下资料回答用户问题。

资料：
{context}

问题：
{question}
```

---

### 7.3 Chain

Chain 是链式调用。

例如：

```text
Query Rewrite → Retrieval → Rerank → Answer Generation
```

---

### 7.4 Workflow

Workflow 是工作流，可以包含：

- 条件分支
- 循环
- 工具调用
- 人工审批
- 错误处理
- 状态持久化

---

### 7.5 Pipeline

Pipeline 是流水线。

例如文档导入流水线：

```text
解析 → 清洗 → 切片 → 向量化 → 入库 → 建索引
```

---

### 7.6 Preprocessing

Preprocessing 是预处理。

包括：

- 文本清洗
- 格式转换
- 语言检测
- 去重
- 敏感内容过滤
- query normalize

---

### 7.7 Postprocessing

Postprocessing 是后处理。

包括：

- JSON 解析
- 格式化
- 引用补全
- 校验字段
- 安全过滤
- 答案压缩

---

### 7.8 Evaluation

Evaluation 是评估。

Agent 需要评估：

- 工具调用准确率
- 检索召回率
- 答案正确率
- 引用准确率
- 幻觉率
- 缓存错误命中率

---

### 7.9 Benchmark

Benchmark 是基准测试。

可以用于比较：

- 不同模型
- 不同 embedding
- 不同 chunk size
- 不同 reranker
- 不同缓存阈值

---

### 7.10 Dataset

Dataset 是数据集。

可用于：

- 训练
- 测试
- 评估
- 回归测试
- 缓存策略验证

---

### 7.11 Labeling

Labeling 是数据标注。

例如：

- 问题对应正确答案
- 问题对应相关文档
- 缓存命中是否正确
- 工具调用是否正确

---

### 7.12 A/B Test

A/B Test 是比较两个方案效果。

例如：

- chunk size 512 vs 1024
- semantic cache threshold 0.88 vs 0.92
- Top-K 5 vs Top-K 10
- 是否启用 rerank

---

### 7.13 Observability

Observability 是可观测性。

Agent 必须观测：

- token
- latency
- cost
- cache hit
- tool call
- error
- trace
- final answer quality

---

### 7.14 Trace

Trace 是调用链追踪。

一次 Agent 请求可能包含：

```text
request → normalize → cache check → plan → retrieval → tool call → llm → postprocess → response
```

Trace 要记录每一步。

---

### 7.15 Log

Log 是日志。

注意区分：

- 调试日志
- 审计日志
- 错误日志
- 安全日志
- 工具调用日志

---

### 7.16 Metrics

Metrics 是指标。

Agent 缓存系统核心指标：

- cache_hit_rate
- false_hit_rate
- cached_tokens_ratio
- avg_latency
- avg_cost
- tool_call_count
- rag_retrieval_hit_rate

---

## 8. Agent 架构相关名词

---

### 8.1 任务拆解

把复杂任务拆成可执行步骤。

---

### 8.2 任务队列

用于保存待执行任务。

可选技术：

- Redis Queue
- RabbitMQ
- Kafka
- RocketMQ

---

### 8.3 状态机

管理任务状态：

```text
pending
running
waiting_user
failed
completed
cancelled
```

---

### 8.4 工具注册表

记录 Agent 可用工具：

- 工具名
- 参数 schema
- 权限要求
- 是否可缓存
- TTL
- 是否需要审批

---

### 8.5 权限控制

限制 Agent 能做什么。

---

### 8.6 沙箱

沙箱用于隔离执行环境，防止危险操作影响真实系统。

---

### 8.7 审批流

高风险操作必须经过用户确认。

---

### 8.8 执行日志

记录 Agent 每一步做了什么。

---

### 8.9 回滚

操作失败后恢复到之前状态。

---

### 8.10 幂等性

同一操作执行多次，结果保持一致。

Agent 工具必须重视幂等性，因为模型可能重复调用工具。

---

### 8.11 Checkpoint

Checkpoint 是检查点，用于长任务恢复。

---

### 8.12 Artifact

Artifact 是任务产物，例如：

- 文档
- 代码
- 测试报告
- 图片
- 表格
- 配置文件

---

### 8.13 Session

Session 是会话，保存当前交互上下文。

---

### 8.14 Workspace

Workspace 是 Agent 的工作区，用于读写文件和执行任务。

---

## 9. Agent 缓存命中率优化专题

---

## 9.1 总体原则

Agent 缓存优化的目标不是单纯提高命中率，而是：

```text
在保证正确性、权限、时效性和引用完整性的前提下，减少重复计算。
```

错误的目标：

```text
缓存命中率越高越好。
```

正确的目标：

```text
高质量命中率越高越好，错误命中率越低越好。
```

---

## 9.2 分层缓存架构

推荐缓存层级：

```text
用户请求
  ↓
1. Request Normalize Cache
  ↓
2. Exact Cache
  ↓
3. Semantic Cache
  ↓
4. Plan Cache
  ↓
5. RAG Retrieval Cache
  ↓
6. Embedding Cache
  ↓
7. Rerank Cache
  ↓
8. Tool Result Cache
  ↓
9. Prompt Cache
  ↓
10. Final Answer Cache
```

---

## 9.3 Request Normalize Cache

请求标准化的目标是把不同表达归一成同一意图。

例如：

```text
“解释一下 RAG”
“RAG 是什么”
“介绍一下 RAG”
```

可以归一成：

```json
{
  "intent": "explain_concept",
  "topic": "RAG",
  "language": "zh-CN",
  "detail_level": "normal"
}
```

---

## 9.4 Exact Cache

Exact Cache 用于完全相同请求。

Key 示例：

```text
hash(normalized_request_json)
```

优点：

- 实现简单
- 无错误语义匹配风险
- 命中后速度最快

缺点：

- 命中率有限

---

## 9.5 Semantic Cache

Semantic Cache 用 embedding 判断相似问题。

建议策略：

```text
similarity >= 0.92：直接命中
0.85 <= similarity < 0.92：候选命中，需要二次判断
similarity < 0.85：不命中
```

二次判断可以交给小模型或规则系统：

```json
{
  "can_reuse": true,
  "reason": "用户问题和缓存问题都是解释 RAG 基本概念，不涉及时效数据。",
  "risk": "low"
}
```

---

## 9.6 Plan Cache

Plan Cache 缓存任务执行计划，而不是最终答案。

适合 Agent：

```text
分析项目结构
检查登录模块
生成测试用例
总结论文
处理文档
```

Plan Cache 的好处：

- 比最终答案更稳定
- 更不容易错误命中
- 可减少 Planner token 消耗
- 方便标准化执行流程

---

## 9.7 RAG Retrieval Cache

RAG 检索缓存可以缓存：

- query rewrite
- embedding
- vector search top-k
- rerank result
- context pack

Key 必须包含版本：

```text
hash(
  normalized_query
  + collection_id
  + collection_version
  + embedding_model_version
  + chunking_strategy_version
  + reranker_version
)
```

---

## 9.8 Embedding Cache

同一 query 或同一 chunk 不应重复计算 embedding。

Key：

```text
hash(text_normalized + embedding_model + embedding_model_version)
```

---

## 9.9 Rerank Cache

Rerank 成本较高，应缓存。

Key：

```text
hash(query + candidate_chunk_ids + reranker_model_version)
```

---

## 9.10 Tool Result Cache

Agent 中工具调用非常适合缓存。

例如：

- 读取 README
- 扫描项目结构
- 查询依赖列表
- 查询 API 文档
- 获取 Git diff
- 搜索固定文档

Key：

```text
hash(
  tool_name
  + normalized_args
  + user_id
  + permission_scope
  + data_version
)
```

---

## 9.11 Prompt Cache

Prompt Cache 的核心是稳定前缀。

推荐顺序：

```text
[稳定系统规则]
[稳定工具定义]
[稳定 JSON Schema]
[稳定项目背景]
[稳定长文档]
[缓存断点]
[用户本轮问题]
[本轮工具结果]
[临时约束]
```

避免：

```text
[当前时间]
[随机 request_id]
[用户问题]
[系统规则]
[工具定义]
```

---

## 9.12 Final Answer Cache

最终答案缓存只适合稳定问题。

适合：

- 概念解释
- FAQ
- 固定教程
- 模板代码
- 非实时知识

不适合：

- 实时信息
- 私有数据
- 用户权限相关
- 订单状态
- 支付状态
- 强上下文相关任务

---

## 10. 缓存正确性：为什么不能盲目提高命中率

---

## 10.1 核心观点

对 AI Agent 来说：

```text
缓存未命中只是多花成本。
缓存错误命中可能导致错误决策。
```

因此，缓存系统必须同时追求：

```text
命中率
正确率
可引用
可追踪
可失效
可审计
```

---

## 10.2 错误命中的风险

错误命中可能导致：

- 回答引用过期资料
- Agent 使用旧工具结果
- RAG 基于旧知识库回答
- 用户权限变化后仍复用旧结果
- 订单、价格、状态类数据错误
- Agent 走错执行计划
- 自动化流程误操作

---

## 10.3 缓存必须保存引用来源

缓存内容不应该只保存 answer，而应该保存：

```json
{
  "answer": "...",
  "source_refs": [
    {
      "document_id": "doc_001",
      "chunk_id": "chunk_009",
      "page": 3,
      "section": "RAG Architecture",
      "content_hash": "abc123",
      "document_version": "v5"
    }
  ],
  "generated_at": "2026-05-14T10:00:00Z",
  "model": "xxx",
  "prompt_template_version": "v3",
  "cache_policy": "semantic_cache",
  "ttl": 3600
}
```

命中缓存后，必须校验：

- 文档是否还存在
- chunk 是否还存在
- content_hash 是否一致
- document_version 是否一致
- 用户是否仍有权限访问
- TTL 是否过期
- 模型输出是否仍适用

---

## 10.4 缓存引用校验流程

推荐流程：

```text
缓存候选命中
  ↓
读取 cache_entry
  ↓
校验 TTL
  ↓
校验 source_refs
  ↓
校验 document_version / content_hash
  ↓
校验 user permission
  ↓
校验 freshness policy
  ↓
通过：返回缓存
不通过：缓存失效，重新计算
```

---

## 10.5 缓存命中类型分级

| 命中类型 | 说明 | 是否可直接返回 |
|---|---|---|
| Strong Hit | 完全匹配，引用未变化，权限未变化 | 可以 |
| Verified Semantic Hit | 语义匹配，并通过二次验证 | 可以 |
| Weak Semantic Hit | 语义相似但未验证 | 不建议直接返回 |
| Stale Hit | 缓存存在但数据版本过期 | 不可以 |
| Permission Risk Hit | 用户权限变化或无法验证 | 不可以 |
| Citation Broken Hit | 引用来源不存在或 hash 不一致 | 不可以 |

---

## 10.6 正确命中率指标

不要只记录：

```text
cache_hit_rate
```

应该记录：

```text
cache_hit_rate
verified_cache_hit_rate
false_hit_rate
stale_hit_rate
citation_broken_rate
permission_rejected_cache_rate
cache_saved_cost
cache_saved_latency
```

其中最重要的是：

```text
verified_cache_hit_rate
false_hit_rate
```

---

## 10.7 缓存答案必须能解释“为什么可复用”

命中缓存时，系统内部应能给出：

```json
{
  "cache_hit": true,
  "hit_type": "verified_semantic_hit",
  "reuse_reason": "用户问题与缓存问题均为 RAG 概念解释，不涉及实时数据；缓存引用文档版本未变化。",
  "similarity": 0.94,
  "source_validated": true,
  "permission_validated": true
}
```

这对调试和审计很重要。

---

## 11. 推荐的 Agent 缓存架构

推荐后端架构：

```text
Client
  ↓
Agent Gateway
  ↓
Request Normalizer
  ↓
Cache Manager
  ├── Exact Cache
  ├── Semantic Cache
  ├── Plan Cache
  ├── Retrieval Cache
  ├── Embedding Cache
  ├── Tool Result Cache
  ├── Prompt Cache Monitor
  └── Final Answer Cache
  ↓
Cache Validator
  ├── TTL Validator
  ├── Source Ref Validator
  ├── Permission Validator
  ├── Version Validator
  └── Freshness Validator
  ↓
Agent Orchestrator
  ├── Planner
  ├── Router
  ├── Tool Executor
  ├── RAG Engine
  ├── Memory Manager
  └── Evaluator
  ↓
LLM Provider
```

---

## 12. 缓存 Key 设计

---

### 12.1 不推荐

```text
cache_key = hash(raw_user_input)
```

问题：

```text
“RAG 是什么”
“介绍一下 RAG”
“解释 RAG”
```

raw hash 完全不同。

---

### 12.2 推荐：结构化 Key

```json
{
  "intent": "explain_concept",
  "topic": "RAG",
  "language": "zh-CN",
  "detail_level": "detailed",
  "freshness_required": false
}
```

Key：

```text
hash(intent + topic + language + detail_level + freshness_required)
```

---

### 12.3 RAG Cache Key

```text
rag_cache_key =
hash(
  normalized_query
  + collection_id
  + collection_version
  + embedding_model
  + chunking_strategy_version
  + top_k
  + reranker_model
)
```

---

### 12.4 Tool Cache Key

```text
tool_cache_key =
hash(
  tool_name
  + normalized_args
  + user_id
  + permission_scope
  + data_version
)
```

---

### 12.5 Prompt Cache 稳定性 Key

要保证：

- system prompt 稳定
- tools 顺序稳定
- JSON schema 稳定
- 文档排序稳定
- 动态内容后置

---

## 13. 提高缓存命中率的实战规则

---

### 13.1 固定 Prompt 前缀

稳定内容放前面：

```text
系统规则 → 工具定义 → 输出格式 → 项目背景 → 用户问题
```

---

### 13.2 工具定义顺序固定

```text
tools = sort_by(tool_name)
```

---

### 13.3 JSON Schema 固定

同一类任务使用：

```text
schema_version = v1
```

不要每次动态生成不同字段顺序。

---

### 13.4 动态内容后置

后置内容包括：

- 当前时间
- 用户问题
- 工具实时结果
- trace_id
- request_id
- 临时约束

---

### 13.5 请求 Normalize

统一：

- 大小写
- 标点
- 空格
- 同义表达
- 输出语言
- 任务类型

---

### 13.6 意图识别

常见 intent：

```text
explain_concept
debug_code
write_doc
search_web
query_private_kb
generate_sql
summarize_file
analyze_project
```

---

### 13.7 Semantic Cache 使用高阈值

建议：

```text
>= 0.92：直接候选命中
0.85 - 0.92：二次验证
< 0.85：不命中
```

---

### 13.8 优先缓存 Plan

Agent 计划比最终答案更稳定。

---

### 13.9 工具结果缓存

重点缓存：

- 文件树
- README
- 依赖列表
- API 文档
- Git diff
- 数据库 schema

---

### 13.10 RAG 缓存带版本号

知识库更新必须导致缓存失效。

---

### 13.11 Embedding 缓存

避免重复 embedding。

---

### 13.12 Rerank 缓存

避免重复 rerank。

---

### 13.13 长文档缓存

缓存：

- parse result
- chunk result
- summary
- embedding
- context pack

---

### 13.14 监控缓存质量

必须记录：

```text
cache_hit_rate
verified_cache_hit_rate
false_hit_rate
stale_hit_rate
citation_broken_rate
avg_latency_saved
avg_cost_saved
```

---

### 13.15 禁止缓存高风险结果

谨慎或禁止缓存：

- 权限判断
- 支付状态
- 订单状态
- 安全策略
- 实时价格
- 生产数据库写操作

---

## 14. 项目落地建议

如果你准备做 AI Agent，可以先做 MVP：

```text
Spring Boot 后端
PostgreSQL：任务、会话、trace、用户配置
Redis：exact cache、tool cache、session cache
Qdrant / pgvector：semantic cache、RAG 向量库
LLM Router：选择 GPT / GLM / DeepSeek / Claude
Agent Orchestrator：Planner + Tool Executor + Memory
Observability：记录 token、latency、cache hit、tool call
```

---

### 14.1 最小缓存模块

```text
1. Request Normalizer
2. Exact Cache
3. Semantic Cache
4. Tool Result Cache
5. RAG Retrieval Cache
6. Cache Validator
7. Cache Metrics
```

---

### 14.2 核心数据表建议

#### cache_entry

```sql
CREATE TABLE cache_entry (
    id BIGSERIAL PRIMARY KEY,
    cache_key TEXT NOT NULL,
    cache_type VARCHAR(64) NOT NULL,
    normalized_intent VARCHAR(128),
    normalized_topic TEXT,
    answer TEXT,
    source_refs JSONB,
    model_name VARCHAR(128),
    prompt_template_version VARCHAR(64),
    data_version VARCHAR(128),
    content_hash TEXT,
    ttl_seconds INT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### cache_hit_log

```sql
CREATE TABLE cache_hit_log (
    id BIGSERIAL PRIMARY KEY,
    request_id TEXT NOT NULL,
    cache_entry_id BIGINT,
    hit_type VARCHAR(64),
    similarity DOUBLE PRECISION,
    source_validated BOOLEAN,
    permission_validated BOOLEAN,
    final_reused BOOLEAN,
    reject_reason TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

### 14.3 核心指标

```text
cache_hit_rate_total
verified_cache_hit_rate
semantic_false_hit_rate
avg_llm_cost_per_request
avg_latency_per_request
cached_tokens_ratio
tool_call_reduction_rate
citation_broken_rate
```

---

## 15. 参考资料

1. Vaswani et al. Attention Is All You Need.  
   https://arxiv.org/abs/1706.03762

2. Lewis et al. Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks.  
   https://arxiv.org/abs/2005.11401

3. Yao et al. ReAct: Synergizing Reasoning and Acting in Language Models.  
   https://arxiv.org/abs/2210.03629

4. Schick et al. Toolformer: Language Models Can Teach Themselves to Use Tools.  
   https://arxiv.org/abs/2302.04761

5. Madaan et al. Self-Refine: Iterative Refinement with Self-Feedback.  
   https://arxiv.org/abs/2303.17651

6. Reimers and Gurevych. Sentence-BERT.  
   https://arxiv.org/abs/1908.10084

7. Johnson et al. Billion-scale similarity search with GPUs.  
   https://arxiv.org/abs/1702.08734

8. Robertson and Zaragoza. The Probabilistic Relevance Framework: BM25 and Beyond.  
   https://www.staff.city.ac.uk/~sbrp622/papers/foundations_bm25_review.pdf

9. Khattab and Zaharia. ColBERT: Efficient and Effective Passage Search via Contextualized Late Interaction over BERT.  
   https://arxiv.org/abs/2004.12832

10. GPTCache paper.  
    https://aclanthology.org/2023.nlposs-1.24/

11. GPTCache GitHub.  
    https://github.com/zilliztech/gptcache

12. vLLM / PagedAttention paper.  
    https://arxiv.org/abs/2309.06180

13. OpenAI Prompt Caching Guide.  
    https://developers.openai.com/api/docs/guides/prompt-caching

14. OpenAI Function Calling Guide.  
    https://developers.openai.com/api/docs/guides/function-calling

15. OpenAI Structured Outputs Guide.  
    https://developers.openai.com/api/docs/guides/structured-outputs

16. Anthropic Prompt Caching Docs.  
    https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching

17. LangChain Agents Docs.  
    https://docs.langchain.com/oss/python/langchain/agents

18. LangChain Memory Docs.  
    https://docs.langchain.com/oss/python/concepts/memory

19. LlamaIndex Observability Docs.  
    https://developers.llamaindex.ai/python/framework/module_guides/observability/

---

## 总结

AI Agent 的缓存优化不能简单追求高命中率。

更正确的目标是：

```text
高 verified hit rate
低 false hit rate
引用可追踪
数据可失效
权限可校验
成本可量化
延迟可观测
```

对生产级 Agent 来说，最危险的不是缓存未命中，而是缓存错误命中。

因此，缓存系统必须从一开始就设计：

```text
Cache Manager + Cache Validator + Source Reference + Version Control + Metrics
```

这样才能在提升性能和降低成本的同时，保证 Agent 的可靠性。
