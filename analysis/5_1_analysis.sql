-- 51劳动节题材分析
-- 找出 4-11 至 5-10 这段时间涨幅最大的股票

drop table if exists temp_5_1_stock_price;
create table if not exists temp_5_1_stock_price as
select a.code
,d.short_name
,a.year_str
,a.start_date
,a.end_date
,b.close_price as start_price
,c.close_price as end_price
,(c.close_price-b.close_price)/b.close_price as grow_per
from  (
select year(data_date) as year_str
,code
,max(data_date) as end_date
,min(data_date) as start_date
from stock_price
where substr(data_date,6,10) between '04-11' and '05-10'
    group by code ,year(data_date)
) a
    join
(
select * from stock_price
where substr(data_date,6,10) between '04-11' and '05-10'
) b
on a.code=b.code
and a.start_date=b.data_date
join
(
select * from stock_price
where substr(data_date,6,10) between '04-11' and '05-10'
) c
on a.code=c.code
and a.end_date=c.data_date
join stk_company_info d 
on a.code=d.code
;

select *
from (
select  t1.code,short_name
,count(*) as num
,count(if(grow_per>0,t1.code,null)) as grow_num
,count(if(grow_per<0,t1.code,null)) as degree_num
,avg(grow_per)as grow_per_avg
from temp_5_1_stock_price t1
join (select * from stock_industry where industry_name = '旅游' ) t2
on t1.code=t2.code
where year_str between 2010 and 2019
# and grow_per>0
group by t1.code,short_name
) a
order by num desc limit 100



drop table if exists temp_travel_stock_price;
create table if not exists temp_travel_stock_price as
select t1.*
from stock_price t1
join (select * from stock_industry where industry_name = '旅游' ) t2
on t1.code=t2.code
where  data_date between '2010-01-01' and '2019-12-31'
;



drop table if exists temp_travel_stock_price_grp_1;
create table if not exists temp_travel_stock_price_grp_1 as
select a.code
,a.yearmonth
,a.start_date
,a.end_date
,b.close_price as start_price
from  (
select substr(data_date,1,7) as yearmonth
,t1.code
,max(data_date) as end_date
,min(data_date) as start_date
from temp_travel_stock_price t1
    group by t1.code ,substr(data_date,1,7)
) a
    join
(
select * from temp_travel_stock_price
) b
on a.code=b.code
and a.start_date=b.data_date
;



drop table if exists temp_travel_stock_price_grp;
create table if not exists temp_travel_stock_price_grp as
select a.code
,d.short_name
,a.yearmonth
,a.start_date
,a.end_date
,a.start_price
,c.close_price as end_price
,(c.close_price-a.start_price)/a.start_price as grow_per
from  temp_travel_stock_price_grp_1 a
join
(
select * from temp_travel_stock_price
) c
on a.code=c.code
and a.end_date=c.data_date
join stk_company_info d
on a.code=d.code
;


select substr(yearmonth,6,7) as month_str
,avg(grow_per) as grow_per
,count(*) as total_num
,count(if(grow_per>0,1,null)) as grow_num
,count(if(grow_per<0,1,null)) as degree_num
from temp_travel_stock_price_grp
group by substr(yearmonth,6,7)
order by grow_num desc

02	0.05815061574297068	265	186	66
08	0.016024740522037922	269	148	114
03	0.04635251640214881	267	143	114
09	0.020622255525424085	269	137	123
12	0.016266038226682766	271	130	131
11	0.008253890257188302	270	128	134
07	0.014601512491770649	268	122	135
06	-0.025665493753925843	268	120	135
05	0.012442756544597559	267	116	141
10	0.0006735886514656339	269	107	152
01	-0.02045965052403153	263	105	148
04	-0.022063135678957003	267	78	176
