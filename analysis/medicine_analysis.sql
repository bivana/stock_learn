-- 医药行业分析



drop table if exists temp_medicine_stock_price;
create table if not exists temp_medicine_stock_price as
select t1.*
from stock_price t1
join (select * from stock_industry where industry_name = '医药制造业' ) t2 
on t1.code=t2.code
where  data_date between '2010-01-01' and '2019-12-31'
;



drop table if exists temp_medicine_stock_price_grp;
create table if not exists temp_medicine_stock_price_grp as
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
from temp_medicine_stock_price t1
    group by t1.code ,substr(data_date,1,7)
) a
left join
(
select * from temp_medicine_stock_price
) b
on a.code=b.code
and a.start_date=b.data_date
left join
(
select * from temp_medicine_stock_price
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
from temp_medicine_stock_price_grp
group by substr(yearmonth,6,7)
order by grow_num desc



02	0.06679241850042208	1615	1162	404
03	0.04683795358183727	1625	909	660
08	0.013325492172991615	1683	857	772
10	0.012951686620869467	1699	819	830
05	0.03646567340847584	1652	801	779
07	0.006978775863960152	1673	786	824
09	0.0088046009868946	1693	786	850
11	0.012225081400627141	1704	784	874
06	-0.02067193923133575	1664	773	824
12	-0.009612013977073279	1710	719	946
04	-0.003970702463222518	1637	628	950
01	-0.021234609800814683	1608	606	950
