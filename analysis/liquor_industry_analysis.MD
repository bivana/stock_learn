# 白酒行业分析

白酒行业一共有17只股票，sql如下图
```sql
select b.code
     ,b.short_name
     ,b.start_date -- 上市日期
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
        left join stock.stk_company_info b
                  on a.code=b.code
order by b.code
```
股票如下所示：
```
000568.XSHE	泸州老窖	1994-05-09
000596.XSHE	古井贡酒	1996-09-27
000799.XSHE	酒鬼酒	1997-07-18
000858.XSHE	五粮液	1998-04-27
000860.XSHE	顺鑫农业	1998-11-04
002304.XSHE	洋河股份	2009-11-06
600197.XSHG	伊力特	1999-09-16
600199.XSHG	金种子酒	1998-08-12
600519.XSHG	贵州茅台	2001-08-27
600559.XSHG	老白干酒	2002-10-29
600702.XSHG	舍得酒业	1996-05-24
600779.XSHG	水井坊	1996-12-06
600809.XSHG	山西汾酒	1994-01-06
603198.XSHG	迎驾贡酒	2015-05-28
603369.XSHG	今世缘	2014-07-03
603589.XSHG	口子窖	2015-06-29
603919.XSHG	金徽酒	2016-03-10

```
可以看到，大部分白酒上市年份都比较早，都超过了10年，只有

首先来看白酒是不是个好行业,过去10年，从2008到2018，上市公司

来看2018年毛利率，17只股票中，贵州茅台一枝独秀，毛利率达到了91%,第二集团较多，水井坊，酒鬼酒，古井贡酒，泸州老窖，口子窖，五粮液，洋河股份，今世缘，舍得酒业，毛利率达到了70%~80%的区间，剩下的为第三区间，
```sql
select b.short_name
,c.stat_date
,c.gross_profit_margin
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join 
  (select * from stock.finance_indicator where stat_date='2018-12-31') c
on a.code=c.code
order by c.gross_profit_margin desc

贵州茅台	2018-12-31	91.1420
水井坊	2018-12-31	81.8659
酒鬼酒	2018-12-31	78.8343
古井贡酒	2018-12-31	77.7569
泸州老窖	2018-12-31	77.5266
口子窖	2018-12-31	74.3678
五粮液	2018-12-31	73.8028
洋河股份	2018-12-31	73.7033
今世缘	2018-12-31	72.8711
舍得酒业	2018-12-31	72.6253
山西汾酒	2018-12-31	66.2135
金徽酒	2018-12-31	62.2985
老白干酒	2018-12-31	61.1502
迎驾贡酒	2018-12-31	60.9249
金种子酒	2018-12-31	51.2459
伊力特	2018-12-31	49.0114
顺鑫农业	2018-12-31	39.9588

```

过去10年毛利率
```sql
select b.code
,b.short_name
,c.stat_date
,c.gross_profit_margin
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join 
  (select * from stock.finance_indicator where stat_date between date_sub(current_date(),interval 11 year ) and current_date) c
on a.code=c.code
order by b.code,c.stat_date

```

过去10年流动比率
```sql
select b.code
,b.short_name
,c.end_date
,c.total_current_assets
,c.total_current_liability
,c.inventories
,c.total_current_assets/c.total_current_liability as liudong_ratio
,(c.total_current_assets-c.inventories)/c.total_current_liability as sudong_ratio
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join 
  (select * from stock.stk_balance_sheet where end_date between date_sub(current_date(),interval 11 year ) and current_date and type='year') c
on a.code=c.code
order by b.code,c.end_date
```

过去10年资产负债率
```sql
select b.code
,b.short_name
,c.end_date
,c.total_liability
,c.total_assets
,c.total_liability/total_assets as liability_ratio
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join
  (select * from stock.stk_balance_sheet where end_date between date_sub(current_date(),interval 11 year ) and current_date and type='year') c
on a.code=c.code
order by b.code,c.end_date
```

过去10年(现金及现金等价物)%有息负债
```sql
select b.code
,b.short_name
,c.end_date
,c.cash_equivalents -- 货币资金
,c.trading_assets -- 交易性金融资产
,c.bill_receivable -- 应收票据
,c.hold_for_sale_assets -- 可供出售金融资产
,c.shortterm_loan -- 短期借款
,c.longterm_loan -- 长期借款
,c.bonds_payable -- 应付债券
,if(coalesce(c.safety_ratio,10)>=10,10,coalesce(c.safety_ratio,10)) as safety_ratio
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join
  (select *
   ,(coalesce(cash_equivalents,0)+coalesce(trading_assets,0)+coalesce(bill_receivable,0)+coalesce(hold_for_sale_assets,0))/(coalesce(shortterm_loan,0)+coalesce(longterm_loan,0)+coalesce(bonds_payable,0)) as safety_ratio from stock.stk_balance_sheet where end_date between date_sub(current_date(),interval 11 year ) and current_date and type='year') c
on a.code=c.code
order by b.code,c.end_date
```

过去10年 营业利润率
```sql
select b.code
,b.short_name
,c.end_date
,c.operating_revenue -- 营业收入
,c.operating_cost -- 营业成本
,c.sale_expense -- 销售费用
,c.administration_expense -- 管理费用
,c.financial_expense -- 财务费用
,(c.operating_revenue-c.operating_cost-c.sale_expense-c.administration_expense-c.financial_expense)/c.operating_revenue as operation_ratio
,(c.operating_revenue-c.operating_cost)/c.operating_revenue as gross_profit
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join
  (select * from stock.stk_income_statement where end_date between date_sub(current_date(),interval 11 year ) and current_date and type='year') c
on a.code=c.code
order by b.code,c.end_date
```


过去10年 roe 净资产收益率
```sql
select b.code
,b.short_name
,c.end_date
,c.operating_revenue -- 营业收入
,c.operating_cost -- 营业成本
,c.sale_expense -- 销售费用
,c.administration_expense -- 管理费用
,c.financial_expense -- 财务费用
,(c.operating_revenue-c.operating_cost-c.sale_expense-c.administration_expense-c.financial_expense)/c.operating_revenue as operation_ratio
,(c.operating_revenue-c.operating_cost)/c.operating_revenue as gross_profit
from
    (select distinct code from stock.stock_industry where industry_name='白酒III') a
left join stock.stk_company_info b
on a.code=b.code
left join
  (select * from stock.stk_income_statement where end_date between date_sub(current_date(),interval 11 year ) and current_date and type='year') c
on a.code=c.code
order by b.code,c.end_date
```