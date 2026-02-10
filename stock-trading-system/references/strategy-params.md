# 策略参数详解 (v3)

## strategy_params.json 字段说明

### 止损止盈

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| stop_loss_pct | float | -0.042 | 硬止损线(基于最大回撤2.72%×1.5安全系数) |
| take_profit_atr_multiplier | float | 2.0 | ATR自适应减仓线：浮盈>此倍×混合ATR→减仓 |
| take_profit_full_atr_multiplier | float | 4.0 | ATR自适应全出线：浮盈>此倍×混合ATR→全卖 |
| trailing_stop_trigger_atr_multiplier | float | 2.0 | 追踪止盈触发：盈利>此倍×ATR后启动追踪 |
| trailing_stop_atr_multiplier | float | 1.5 | 追踪止盈回撤：从最高价回撤此倍×ATR→触发 |
| trailing_stop_sell_pct | float | 0.6 | 追踪止盈触发时卖出比例 |
| take_profit_pct | float | 0.04 | 固定止盈减仓线(ATR下限) |
| take_profit_full_pct | float | 0.08 | 固定止盈全出线(ATR下限) |

### ATR配置

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| atr_period | int | 20 | 标准ATR周期 |
| atr_fast_period | int | 5 | 快速ATR周期(捕捉近期波动) |
| atr_use_hybrid | bool | true | 混合ATR=max(20日ATR, 5日ATR, 当日振幅) |

### 仓位管理

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| max_position_pct | float | 0.12 | 单只最大仓位(从0.15降) |
| max_total_position | float | 0.50 | 总仓位硬阻断(代码强制) |
| passive_overweight_tolerance | float | 0.55 | 被动超限容忍线,>55%次日减仓 |
| clearance_first_batch_pct | float | 0.60 | 清仓首批比例(从0.70降) |
| residual_clear_threshold_pct | float | 0.005 | 残仓清理阈值(市值<总资产0.5%) |
| residual_clear_max_hold_days | int | 5 | 残仓最长持有天数 |

### 涨停过滤

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| limit_up_filter_daily_pct | float | 0.07 | 当日涨幅>7%禁买 |
| limit_up_filter_daily_soft_pct | float | 0.05 | 当日涨幅>5%需高分 |
| limit_up_filter_soft_min_score | int | 80 | 5-7%区间最低评分要求 |
| limit_up_filter_3day_pct | float | 0.12 | 3日累计涨幅>12%禁买 |

### 逆市预警

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| underperform_alert_pct | float | -0.015 | 逆市下跌判定：大盘涨但个股跌超此值 |
| underperform_consecutive_days_to_act | int | 2 | 连续逆市天数→触发动作 |
| underperform_reduce_pct | float | 0.50 | 逆市减仓比例 |

### 其他

| 参数 | 类型 | v3值 | 说明 |
|------|------|------|------|
| min_score | int | 65 | 买入最低评分 |
| volume_ratio_min | float | 1.2 | 量比最低要求 |
| rsi_oversold | int | 30 | RSI超卖线 |
| rsi_overbought | int | 70 | RSI超买线 |
| daily_max_loss | float | 30000 | 每日最大亏损(元) |

## 调参原则

### 何时收紧止损
- 连续亏损交易后
- 大盘环境恶化（下跌趋势）
- 临近长假（减少持仓风险）
- 蒙特卡洛模拟显示风险偏高

### 何时放宽止损
- 持仓股基本面优良且为短期波动
- 大盘强势上涨趋势
- 恐贪指数处于极度恐惧区间（<20）

### 仓位调整参考
- 牛市/震荡市：可调高至60%
- 熊市/节前：降至30-40%
- 市场状态检测(market_regime)输出作为参考

## 费率参数 (trading_engine.py 中固定)

| 费用 | 比例 | 说明 |
|------|------|------|
| 佣金 | 万2.5 | 买卖双向收取，最低5元 |
| 印花税 | 千1 | 仅卖出收取 |
| 过户费 | 万0.2 | 买卖双向 |
