---
name: stock-trading-system
description: |
  A股量化交易系统 — 从选股发现到盘中监控到自动交易到复盘调参的全闭环。
  当用户提到股票交易、量化分析、A股选股、交易策略、盘中监控、复盘、风控时触发。
---

# A股量化交易系统技能

## 系统架构

```
三模型交叉复盘(15:32)
  → Phase1: 数据准备(5-Why+蒙特卡洛+马尔可夫+选股发现)
  → Phase2: 三模型并行独立分析(GPT-5.2/Opus-4.5/Opus-4.6)
  → Phase3: 五轮交叉质询(日常2轮,重大事件5轮)
  → Phase4: 裁定→改参数→改代码→git push→备份
  → Phase5: 飞书通知完整报告

盘中监控(每30min, 9:00-15:30)
  → 采集快照 → 趋势分析 → 持仓管理(ATR自适应止盈/追踪止盈/硬止损)
  → watchlist扫描 → 高分股自动建仓(涨停过滤) → 飞书通知

AI基础设施股票跟踪(每日05:00)
  → 读取现有跟踪池 → 三模型并行研究(GPT-5.2/Opus-4.5/Opus-4.6)
  → 3轮交叉质询收敛 → 更新跟踪池+数据持久化 → git push → 飞书日报
```

## 核心模块

| 模块 | 职责 | 关键函数 |
|------|------|----------|
| `fetch_stock_data.py` | 数据获取 | `fetch_realtime_sina()`, `fetch_kline()`, `fetch_market_overview()` |
| `technical_analysis.py` | 技术指标+混合ATR | `generate_signals()`, `calculate_hybrid_atr()` — MACD/RSI/KDJ/BOLL/量比/趋势+ATR |
| `factor_model.py` | 多因子模型 | `FactorModel.score()` — 动量/技术/量价/资金/情绪5因子 |
| `sentiment_enhanced.py` | AI情绪分析 | `calculate_fear_greed()`, `analyze_stock_sentiment()` |
| `stock_discovery.py` | 选股发现 | `discover_stocks()` — 涨幅榜/成交额/板块龙头/北向资金/连涨/机构增持 |
| `risk_manager.py` | 风险管理 | `calculate_portfolio_risk()`, `position_size_kelly()`, `check_drawdown_circuit_breaker()` |
| `trading_engine.py` | 交易决策 | `score_stock()`, `execute_trade()`, `check_trailing_stop()`, `check_limit_up_filter()` |
| `intraday_monitor.py` | 盘中监控 | `run_monitor()`, `scan_watchlist_opportunities()` |
| `news_sentiment.py` | 新闻数据源 | `fetch_eastmoney_news()`, `fetch_sina_news()`, `analyze_sentiment()` |
| `monte_carlo.py` | 蒙特卡洛模拟 | 1000×bootstrap重排，95%置信区间，正收益概率 |
| `market_regime.py` | 市场状态检测 | 马尔可夫bull/range/bear分类，东方财富指数API |

## AI基础设施股票跟踪模块

### 投资逻辑
AI发展导致硬盘、内存、芯片等基础设施紧缺，在A股寻找受益标的。

### 跟踪品类(6大类)
| 品类 | 逻辑 | 示例标的 |
|------|------|----------|
| 存储/硬盘 | AI训练推理产生海量数据 | 佰维存储、朗科科技、江波龙 |
| 内存/DRAM/HBM | AI服务器单台内存用量远超传统 | 兆易创新、北京君正 |
| 芯片/GPU/ASIC | AI算力核心硬件 | 寒武纪、海光信息 |
| 服务器/算力 | AI服务器出货量高增 | 浪潮信息、中科曙光 |
| 光模块/网络 | AI集群互联高速需求 | 中际旭创、新易盛 |
| IDC/数据中心 | AI算力承载 | 润泽科技、光环新网 |

### 每日流程 (05:00, cron `a00a90f3`)
1. **读取现有数据**: `ai-infra-tracking/config.json` + 最近日报
2. **三模型并行研究**: GPT-5.2 + Opus-4.5 + Opus-4.6 独立搜索分析
   - 标的发现 → 数据采集(股价/PE/PB/财报/新闻/机构) → 估值分析(DCF+相对估值+技术面) → Top 10推荐
3. **3轮交叉质询**: 分歧追问 → 数据挑战 → 最终Top 5 + "只改一个"投票
4. **整合输出**: 统一报告 → 更新config.json跟踪池 → 写入daily/YYYY-MM-DD.json → git push → 飞书日报

### 数据文件
| 文件 | 用途 |
|------|------|
| `ai-infra-tracking/config.json` | 跟踪池配置(品类+标的列表) |
| `ai-infra-tracking/daily/YYYY-MM-DD.json` | 每日分析报告(三模型结果+共识) |

### Git仓库
- 路径: `/root/.openclaw/workspace/stock-trading/`
- Remote: `git@github.com:cintia09/stock-trading-bot.git`
- 每日分析后自动 `git add ai-infra-tracking/ && git commit && git push`

## 数据文件

| 文件 | 用途 |
|------|------|
| `account.json` | 账户状态(现金/持仓/历史峰值/high_since_entry) |
| `watchlist.json` | 关注列表(代码/评分/来源) |
| `strategy_params.json` | 策略参数v3(ATR自适应/追踪止盈/涨停过滤等) |
| `transactions.json` | 交易记录 |
| `data/intraday_snapshots/YYYY-MM-DD.json` | 盘中快照(累积) |
| `data/discovered_stocks.json` | 选股发现结果 |

## 数据源

- **实时行情**: 新浪财经API (`hq.sinajs.cn`)
- **K线数据**: 新浪+BaoStock备用
- **选股/板块**: 东方财富push2 API
- **新闻**: 东方财富7x24 + 新浪财经
- **北向资金**: 东方财富沪深港通数据
- **大盘指数**: 东方财富指数API（避免000001映射平安银行的bug）

## 策略参数 v3 (strategy_params.json)

```json
{
  "version": 3,
  "stop_loss_pct": -0.042,
  "take_profit_atr_multiplier": 2.0,
  "take_profit_full_atr_multiplier": 4.0,
  "trailing_stop_atr_multiplier": 1.5,
  "trailing_stop_trigger_atr_multiplier": 2.0,
  "trailing_stop_sell_pct": 0.6,
  "take_profit_pct": 0.04,
  "take_profit_full_pct": 0.08,
  "max_position_pct": 0.12,
  "max_total_position": 0.50,
  "passive_overweight_tolerance": 0.55,
  "clearance_first_batch_pct": 0.60,
  "residual_clear_threshold_pct": 0.005,
  "limit_up_filter_daily_pct": 0.07,
  "limit_up_filter_daily_soft_pct": 0.05,
  "limit_up_filter_soft_min_score": 80,
  "limit_up_filter_3day_pct": 0.12,
  "underperform_consecutive_days_to_act": 2,
  "underperform_reduce_pct": 0.50,
  "atr_period": 20,
  "atr_fast_period": 5,
  "atr_use_hybrid": true
}
```

### v3 关键改动 (vs v2)
- **止损**: -5% → -4.2%（基于最大回撤2.72% × 1.5安全系数）
- **止盈**: 固定百分比 → ATR自适应（减仓=2×ATR, 全出=4×ATR），固定值作下限
- **混合ATR**: max(20日ATR, 5日ATR, 当日实时振幅)，解决ATR滞后问题
- **追踪止盈**: 盈利超2×ATR后启动，从最高价回撤1.5×ATR → 减仓60%
- **仓位硬阻断**: 50%代码强制，被动超限55%容忍→次日减最弱持仓
- **单只最大**: 15% → 12%
- **涨停过滤**: >7%禁买, >5%需≥80分, 3日累计>12%禁买
- **逆市预警**: 连续2天大盘涨个股跌 → 减仓50%
- **残仓清理**: 市值<总资产0.5% → 清理（最长持有5天）
- **最高价追踪**: account.json 加 `high_since_entry` 字段

参数由每日复盘根据实际表现动态调整，trading_engine.py 启动时自动加载。

## 三模型交叉复盘流程

### 每日复盘 (15:32, cron)

**Phase 1 — 数据准备**
1. 运行 `scripts/main.py` 生成当日报告
2. 运行 5-Why 深度分析
3. 运行蒙特卡洛模拟 (`scripts/monte_carlo.py`)
4. 运行市场状态检测 (`scripts/market_regime.py`)
5. 运行选股发现 (`scripts/stock_discovery.py`)

**Phase 2 — 三模型独立分析**
- 并行 spawn 三个子代理：
  - `review-gpt52`: github-copilot/gpt-5.2
  - `review-opus45`: github-copilot/claude-opus-4.5
  - `review-opus46`: github-copilot/claude-opus-4.6
- 每个模型独立分析：交易评价、参数建议、风险评估、明日计划

**Phase 3 — 交叉质询**
- 日常：2轮（节省token）
- 重大事件（大幅亏损/策略失效）：5轮
- 每轮：提取分歧 → 定向追问 → 收窄分歧
- 第3轮追问实操细节最有价值（ATR滞后、采样频率、阈值定义）
- 最终"只能改一个"投票揭示优先级

**Phase 4 — 裁定执行**
1. 收敛参数 → 更新 `strategy_params.json`
2. 必要时改代码 → commit + push
3. 备份配置到 `backups/config/`

**Phase 5 — 飞书通知**
- 发送完整复盘报告到飞书（有交易或重要信号时）
- 无信号时静默

### Cron配置
- **每日复盘**: `32 15 * * 1-5` (Asia/Shanghai), timeout 1800s, delivery=none
- **盘中监控**: `0,30 9,10,11,13,14,15 * * 1-5` (Asia/Shanghai)
- **AI基础设施跟踪**: `0 5 * * 1-5` (Asia/Shanghai), timeout 1800s, delivery=none, cron id `a00a90f3`
- **新闻简报**: 06:00/12:05/18:03 每日

## 交易决策流程

### 买入条件 (watchlist新股)
1. `score_stock()` 评分 ≥ 65
2. 大盘情绪中性以上 (恐贪指数 > 30)
3. 当日涨幅 -1% ~ +5%
4. **涨停过滤**: >7%禁买, >5%需≥80分, 3日累计>12%禁买
5. 总仓位 < 50%（代码硬阻断）
6. 单只 < 12%
7. 单次最多买2只新股，每只 ≤ 25% 可用现金

### 卖出条件 (持仓管理)
1. **硬止损**: 浮亏 ≥ 4.2%
2. **ATR止盈减仓**: 浮盈 > 2×混合ATR → 减仓60%
3. **ATR止盈全出**: 浮盈 > 4×混合ATR → 全部卖出
4. **追踪止盈**: 盈利超2×ATR后启动，从最高价回撤1.5×ATR → 减仓60%
5. **趋势恶化**: 连续下跌 + 亏损 > 3% → 减半仓
6. **逆市预警**: 连续2天大盘涨个股跌 → 减仓50%
7. **大盘暴跌防御**: 大盘跌 > 2% + 个股跌 → 减1/3
8. **残仓清理**: 市值 < 总资产0.5% → 清理

### 风控规则
- 总仓位50%硬阻断（代码强制）
- 被动超限：50-55%容忍，>55%次日减最弱持仓
- 单只集中度 > 30% → 警告
- 行业集中度 > 40% → 警告
- 回撤 > 10% → 熔断(暂停所有买入)
- 凯利公式计算最优仓位(半凯利)

## 数学模型

### 蒙特卡洛模拟 (monte_carlo.py)
- 从 transactions.json 读取有 pnl 的卖出交易
- 1000次 bootstrap 重排
- 输出：中位收益、95%置信区间、正收益概率、夏普分布
- 注意：需 ≥30 笔交易才有统计意义

### 市场状态检测 (market_regime.py)
- 马尔可夫风格 bull/range/bear 分类
- 使用东方财富指数API（不用 fetch_kline，避免000001映射平安银行bug）
- 支持上证/深证/创业板
- HMM可选（try import hmmlearn），默认纯规则

### 恐贪指数 (Fear & Greed Index)
- 5个子指标加权：涨跌比(0.25) + 涨跌停比(0.15) + 量比(0.20) + 新闻情绪(0.20) + 北向资金(0.20)
- 0-100分：0极度恐惧 → 50中性 → 100极度贪婪
- 恐贪<30：买入阈值-5（逆向建仓机会）
- 恐贪>70：卖出阈值+5（止盈减仓）

### 凯利公式仓位管理
- Kelly% = W - (1-W)/R, W=胜率, R=盈亏比
- 实际使用半凯利(×0.5)更保守
- 从交易历史自动计算

### 回撤熔断
- 记录账户峰值(peak_value)
- 当前资产/峰值 < 90% → 触发熔断
- 熔断后暂停所有买入，只允许减仓

## 评分体系

`score_stock()` 综合评分 0-100：

| 因子 | 权重 | 来源 |
|------|------|------|
| 技术面 | 30% | MACD/RSI/KDJ/BOLL/趋势/量价 |
| 动量 | 20% | 5日/20日涨幅/RS |
| 资金面 | 20% | 主力净流入/北向资金 |
| 情绪面 | 15% | 个股新闻情绪+市场恐贪指数 |
| 基本面 | 15% | PE/PB/市值/板块 |

买入阈值 ≥65, 强买入 ≥70, 卖出 ≤40, 强卖出 ≤30

## 踩坑经验

1. **涨停板追高是最大漏洞** — 涨停买入次日胜率<30%，必须代码硬阻断(>7%禁买)
2. **决定清仓就果断首批60%** — 分批越卖越低的教训
3. **逆市下跌的股票高度警惕** — 大盘涨它跌连续2天→自动减仓50%
4. **复盘必须改代码** — 光总结不行动等于没复盘
5. **情绪极度贪婪时减仓** — 恐贪指数>70适合止盈
6. **情绪极度恐惧时建仓** — 恐贪指数<30是机会
7. **北向资金方向是重要参考** — 外资持续流出要减仓
8. **T+1限制下不能当日止损** — 买入前评分必须够高
9. **ATR有滞后性** — 用混合ATR: max(20日ATR, 5日ATR, 当日实时振幅)
10. **蒙特卡洛样本不足会给假信心** — 95%CI零宽度≠稳定，而是样本太少
11. **API可能超时** — 所有数据获取都有 try/except + 默认值
12. **cron delivery必须设none** — announce模式会导致error→retry循环→重复执行
13. **000001是上证指数不是平安银行** — fetch_kline对指数代码会错误映射，用东方财富指数API
14. **GPT-5.2单次heredoc太长(>500行)会exec超时** — Opus分段cat>>更稳定
