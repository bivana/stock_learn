根据近10年roe平均值排序
```sql
drop table if exists temp_stock_roe_filter;
create table if not exists temp_stock_roe_filter as
select b.code
,b.short_name
,a.avg_roe
,a.max_roe
,a.min_roe
from
  (select code
   ,avg(roe) as avg_roe
   ,max(roe) as max_roe
   ,min(roe) as min_roe 
   ,count(*) as num
   ,stddev(roe) as roe_std
   from 
     (select code
      ,case when roe>=200 then 200
            when roe<=-200 then -200
            else roe end as roe -- 极值处理
    from finance_indicator
   where stat_date between dateadd(getdate(),-11,'yyyy') and getdate()
     ) t1
   group by code
  ) a
left join stk_company_info b
on a.code=b.code
where a.num>=5 -- 上市满足5年
and roe_std<=10
order by a.avg_roe desc limit 500
;


```

流动比率&速动比率过滤
```sql
drop table if exists temp_liudong_sudong_ratio_filter;
create table if not exists temp_liudong_sudong_ratio_filter as
select a.code
,a.short_name
,a.avg_roe
,b.avg_liudong_ratio
,b.avg_sudong_ratio
from temp_stock_roe_filter a
join
     (select code
           , avg(liudong_ratio) as avg_liudong_ratio
           , avg(sudong_ratio)  as avg_sudong_ratio
           , std(liudong_ratio) as liudong_ratio_std
           , std(sudong_ratio)  as sudong_ratio_std
      from (select code
                 , total_current_assets / total_current_liability                 as liudong_ratio
                 , (total_current_assets - inventories) / total_current_liability as sudong_ratio
            from stk_balance_sheet
            where end_date between date_sub(current_date(), interval 11 year) and current_date
              and type = 'year'
           ) t1
      group by code
     ) b
on a.code=b.code
where b.liudong_ratio_std<=10
and b.sudong_ratio_std<=10
and b.avg_liudong_ratio>=2
and b.avg_sudong_ratio>=1
order by a.avg_roe desc
limit 200

```

营业收入&净利润 同比增长
```sql
drop table if exists temp_inc_revenue_filter;
create table if not exists temp_inc_revenue_filter as
select a.code
,a.short_name
,a.avg_roe
,b.avg_inc_revenue_year_on_year
,b.avg_inc_operation_profit_year_on_year
from temp_liudong_sudong_ratio_filter a
join
     (select code
           , avg(inc_revenue_year_on_year) as avg_inc_revenue_year_on_year
           , avg(inc_operation_profit_year_on_year)  as avg_inc_operation_profit_year_on_year
      from finance_indicator
      where stat_date between date_sub(current_date(),interval 365*11 day) and current_date()
      group by code
     ) b
on a.code=b.code
where b.avg_inc_revenue_year_on_year>=15
and b.avg_inc_operation_profit_year_on_year>=15
order by a.avg_roe desc
limit 200



```

资金周转率 固定资产周转率
```sql

select a.code
,a.short_name
,a.avg_roe
,b.avg_total_assets_zzl
,b.avg_fixed_assets_zzl
,b.avginventories_zzl
from temp_inc_revenue_filter a
join
    (
        select t1.code
        ,avg(t1.operating_revenue) as avg_operating_revenue
        ,avg(t2.total_assets) as avg_total_assets
        ,avg(t3.total_assets) as avg_last_total_assets
        ,avg(t1.operating_revenue*2/(t2.total_assets+t3.total_assets)) as avg_total_assets_zzl
        ,avg(t1.operating_revenue*2/(t2.fixed_assets+t3.fixed_assets)) as avg_fixed_assets_zzl
        ,avg(t1.operating_revenue*2/(t2.inventories+t3.inventories)) as avginventories_zzl
        from
             (select *
               from stk_income_statement
               where end_date between date_sub(current_date(),interval 365*11 day) and current_date()
               and type='year'
             ) t1
        join
            (select *
             from stk_balance_sheet
             where end_date between date_sub(current_date(),interval 365*11 day) and current_date()
               and type='year'
            ) t2
        on t1.end_date=t2.end_date
        and t1.code=t2.code
        join
            (select *
             from stk_balance_sheet
             where end_date between date_sub(current_date(),interval 12 year) and current_date()
               and type='year'
            ) t3
        on t1.end_date=date_add(t3.end_date,interval 1 year)
        and t1.code=t3.code
        group by t1.code
     ) b
on a.code=b.code
order by a.avg_roe desc
limit 200


```