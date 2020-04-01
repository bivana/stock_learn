# 财务因子对股价的影响

## roe 对股价影响
```sql
drop table if exists temp_roe_indicator;
create table if not exists temp_roe_indicator
select a.year_str
,a.roe_grp
,avg((d.close_price-c.close_price)/c.close_price) as avg_grow_per
,count(*) as num
from
(
select code,year_str
,case when roe_ge_20_year>=5 then 'grp_5'
      else 'grp_0'
end as roe_grp
from stock_indicator where year_str>='2010'
) a
left join
    (select code,year(data_date) as year_str
    ,max(data_date) as end_date
        ,min(data_date) as start_date
        from stock_price
        where data_date>='2010'
        group by code
        ,year(data_date)
    ) b
on a.code=b.code and a.year_str+1=b.year_str -- 从前一年roe看后一年的涨幅情况
left join
    (select code,close_price,year(data_date) as year_str,data_date
        from stock_price
        where data_date>='2010'
    ) c
on a.code=c.code
and b.start_date=c.data_date
left join
    (select code,close_price,year(data_date) as year_str,data_date
        from stock_price
        where data_date>='2010'
    ) d
on a.code=d.code
and b.end_date=d.data_date
group by a.year_str, a.roe_grp
order by a.year_str,avg_grow_per
;
```

结论：高roe对股价呈正向关系，但涨幅一般

## 产品净利润率对股价影响

```sql
select a.year_str
,a.grp
,avg((d.close_price-c.close_price)/c.close_price) as avg_grow_per
,count(*) as num
from
(
select code,year_str
,case when product_net_profit_ratio<=0.03 then 'grp_003'
      when product_net_profit_ratio<=0.05 then 'grp_005'
      when product_net_profit_ratio<=0.1 then 'grp_01'
       when product_net_profit_ratio<=0.2 then 'grp_02'
       when product_net_profit_ratio<=0.3 then 'grp_03'
       when product_net_profit_ratio<=0.4 then 'grp_04'
        when product_net_profit_ratio<=0.5 then 'grp_05'
       when product_net_profit_ratio<=1 then 'grp_1'
        when product_net_profit_ratio>1 then 'grp_11'
      else 'grp_unknown'
end as grp
from stock_indicator where year_str>='2010'
) a
left join
    (select code,year(data_date) as year_str
    ,max(data_date) as end_date
        ,min(data_date) as start_date
        from stock_price
        where data_date>='2010'
        group by code
        ,year(data_date)
    ) b
on a.code=b.code and a.year_str+1=b.year_str -- 从前一年roe看后一年的涨幅情况
left join
    (select code,close_price,year(data_date) as year_str,data_date
        from stock_price
        where data_date>='2010'
    ) c
on a.code=c.code
and b.start_date=c.data_date
left join
    (select code,close_price,year(data_date) as year_str,data_date
        from stock_price
        where data_date>='2010'
    ) d
on a.code=d.code
and b.end_date=d.data_date
group by a.year_str, a.grp
order by a.year_str,avg_grow_per
;
```