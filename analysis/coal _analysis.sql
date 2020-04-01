-- 煤炭行业分析



drop table if exists temp_coal_stock_price;
create table if not exists temp_coal_stock_price as
select t1.*
from stock_price t1
join (select * from stock_industry where industry_code = '801021' ) t2 
on t1.code=t2.code
where  data_date between '2010-01-01' and '2019-12-31'
;



drop table if exists temp_coal_stock_price_grp;
create table if not exists temp_coal_stock_price_grp as
select a.code
,d.short_name
,a.yearmonth
,a.start_date
,a.end_date
,b.close_price as start_price
,c.close_price as end_price
,(c.close_price-b.close_price)/b.close_price as grow_per
from  (
select substr(data_date,1,7) as yearmonth
,t1.code
,max(data_date) as end_date
,min(data_date) as start_date
from temp_coal_stock_price t1
    group by t1.code ,substr(data_date,1,7)
) a
left join
(
select * from temp_coal_stock_price
) b
on a.code=b.code
and a.start_date=b.data_date
left join
(
select * from temp_coal_stock_price
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
from temp_coal_stock_price_grp
group by substr(yearmonth,6,7)
order by grow_num desc

02	0.04580379240153657	350	250	87
07	0.02503812483865784	354	182	162
09	0.007079119326520742	354	165	180
10	0.011983993937890023	354	158	187
12	0.0013801170825919241	355	151	199
08	-0.006537727228160153	354	147	194
11	-0.012711594504017916	355	143	194
03	-0.006860103365875711	352	143	193
04	0.001095663122232477	352	141	197
01	-0.03186042745737914	350	136	204
06	-0.04095337252041924	354	135	206
05	-0.027315072330596338	354	117	225
