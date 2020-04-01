```sql
杜邦分析sql
roe: 净资产收益率

净资产收益=净利润/净资产=（净利润/销售收入）*（销售收入/平均总资产）*(平均总资产/净资产)

净利润/销售收入=产品净利润率   表示公司的效益，高利润
销售收入/平均总资产=总资产周转率   表示公司效率， 薄利多销策略
平均总资产/净资产=杠杆系数    表示借的钱多不多

set @code='600089.XSHG';
set @start_year=2000;
set @end_year=2018;
select a.code,a.end_date
,a.net_profit*2/(b.total_owner_equities+c.total_owner_equities) as roe -- roe
,a.net_profit/a.operating_revenue as product_net_profit_ratio -- 产品净利润率
,a.operating_revenue*2/(b.total_assets+c.total_assets) as total_assets_tunover_ratio -- 总资产周转率
,(b.total_assets+c.total_assets)/2/a.net_profit as leverage -- 杠杆率
from (select *
      from stk_income_statement
      where type = 'year'
        and code = @code
        and year(end_date) between @start_year and @end_year
     ) a
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year and @end_year) b
on a.code=b.code
and a.end_date=b.end_date
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year-1 and @end_year) c
on a.code=c.code
and a.end_date=date_add(c.end_date,interval 1 year)
order by a.end_date
```

## 安全性分析 

### 流动比率&速冻比率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code
     ,end_date
                 , total_current_assets / total_current_liability                 as liudong_ratio
                 , (total_current_assets - inventories) / total_current_liability as sudong_ratio
            from stk_balance_sheet
            where year(end_date) between @end_year-10 and @end_year
              and type = 'year'
and code=@code
order by end_date
```

### 资产负债率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,end_date
,(coalesce(longterm_loan,0)+coalesce(shortterm_loan,0)+coalesce(notes_payable,0))  / total_assets  as liability_ratio
,coalesce(longterm_loan,0)/total_assets as longterm_loan_ratio
,coalesce(shortterm_loan,0)/total_assets as shortterm_loan_ratio
,coalesce(notes_payable,0)/total_assets as notes_payable_ratio
from stk_balance_sheet
            where year(end_date) between @end_year-10 and @end_year
              and type = 'year'
and code=@code
order by end_date
```

## 盈利能力分析

### 毛利率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,stat_date,gross_profit_margin from finance_indicator where code=@code and year(stat_date) between @start_year and @end_year order by stat_date
```

### 营业利润率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,end_date,(operating_revenue-operating_cost-sale_expense-administration_expense-financial_expense)/operating_revenue as operation_profit_ratio
from stk_income_statement
where type='year' and code=@code and  year(end_date) between  @start_year and @end_year order by end_date
```

### roe

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,stat_date,roe from finance_indicator where code=@code and year(stat_date) between @start_year and @end_year order by stat_date
```

## 营运能力分析

### 应收账款周转率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select a.code,a.end_date,a.operating_revenue*2/(b.account_receivable+c.account_receivable) as account_receivable_tunover_ratio
from (select *
      from stk_income_statement
      where type = 'year'
        and code = @code
        and year(end_date) between @start_year and @end_year
     ) a
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year and @end_year) b
on a.code=b.code
and a.end_date=b.end_date
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year -1 and @end_year) c
on a.code=c.code
and a.end_date=date_add(c.end_date,interval 1 year)
order by a.end_date


```

### 存货周转率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select a.code,a.end_date,a.operating_revenue*2/(b.inventories+c.inventories) as inventories_tunover_ratio
from (select *
      from stk_income_statement
      where type = 'year'
        and code = @code
        and year(end_date) between @start_year and @end_year
     ) a
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year and @end_year) b
on a.code=b.code
and a.end_date=b.end_date
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year-1 and @end_year) c
on a.code=c.code
and a.end_date=date_add(c.end_date,interval 1 year)
order by a.end_date




```


### 固定资产周转率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select a.code,a.end_date,a.operating_revenue*2/(b.fixed_assets+c.fixed_assets) as fixed_assets_tunover_ratio
from (select *
      from stk_income_statement
      where type = 'year'
        and code = @code
        and year(end_date) between @start_year and @end_year
     ) a
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year and @end_year) b
on a.code=b.code
and a.end_date=b.end_date
left join
    (select * from stk_balance_sheet
        where type='year' and code=@code and year(end_date) between @start_year -1 and @end_year) c
on a.code=c.code
and a.end_date=date_add(c.end_date,interval 1 year)
order by a.end_date





```

## 成长性分析

### 净利润&净利润增长率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,end_date,net_profit from stk_income_statement where type='year' and code=@code and year(end_date) between @start_year-1 and @end_year order by end_date

```

### 营业收入&营业收入增长率

```sql
set @end_year=2018;
set @code='000065.XSHE';
select code,end_date,operating_revenue from stk_income_statement where type='year' and code=@code and year(end_date) between @start_year -1 and @end_year order by end_date

```