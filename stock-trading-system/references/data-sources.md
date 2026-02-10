# A股数据源参考

## 实时行情 — 新浪财经

```
GET https://hq.sinajs.cn/list=sh600519,sz000858
```
返回逗号分隔字符串：名称,开盘,昨收,当前价,最高,最低,买一价,卖一价,成交量,成交额...

## K线数据 — 新浪

```
GET https://quotes.sina.cn/cn/api/jsonp.php/var=/CN_MarketDataService.getKLineData
    ?symbol=sh600519&scale=240&ma=no&datalen=60
```
scale: 5/15/30/60/240(日线) datalen: K线条数

## 东方财富 Push2 API — 排行榜/板块

```
GET https://push2.eastmoney.com/api/qt/clist/get
    ?pn=1&pz=50&po=1&np=1&fltt=2&invt=2
    &fid=f3              # 排序字段：f3涨幅 f6成交额 f62主力净流入
    &fs=m:0+t:6,m:0+t:80,m:1+t:2,m:1+t:23  # 沪深A股
    &fields=f2,f3,f4,f5,f6,f7,f8,f9,f10,f12,f14,f15,f16,f17,f18,f20,f21,f62
```

字段对照：
- f2: 最新价, f3: 涨跌幅%, f4: 涨跌额, f5: 成交量(手)
- f6: 成交额, f7: 振幅%, f8: 换手率%, f9: PE, f10: PB
- f12: 代码, f14: 名称, f15: 最高, f16: 最低, f17: 开盘, f18: 昨收
- f20: 总市值, f21: 流通市值, f62: 主力净流入

板块筛选：
- `fs=m:90+t:2` — 行业板块
- `fs=m:90+t:3` — 概念板块
- `fs=b:BK0XXX` — 具体板块成分股

## 东方财富 新闻 7x24

```
GET https://np-listapi.eastmoney.com/comm/web/getFastNewsList
    ?client=web&biz=web_724&pageSize=50
```

## 东方财富 个股新闻

```
GET https://search-api-web.eastmoney.com/search/jsonp
    ?cb=jQuery&param={"uid":"","keyword":"贵州茅台","type":["cmsArticleWebOld"],
     "client":"web","clientType":"web","clientVersion":"curr",
     "param":{"cmsArticleWebOld":{"searchScope":"default","sort":"default",
     "pageIndex":1,"pageSize":10}}}
```

## 新浪财经 新闻

```
GET https://feed.mix.sina.com.cn/api/roll/get
    ?pageid=153&lid=2516&num=50&page=1
```

## BaoStock — 备用数据源 (Python库)

```python
import baostock as bs
bs.login()
rs = bs.query_history_k_data_plus("sh.600519",
    "date,open,high,low,close,volume,amount",
    start_date='2024-01-01', frequency="d")
bs.logout()
```

## 注意事项
1. 东财API无需认证但有频率限制，建议间隔0.5s
2. 新浪实时行情在非交易时段返回上个交易日数据
3. BaoStock免费但延迟1天，不适合盘中实时
4. 所有API调用加 timeout=10 和 try/except
