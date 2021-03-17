delete from aspiration_table
delete from body_style_table
delete from body_table
delete from brand_table
delete from car
delete from car_table
delete from cylinders_table
delete from drive_wheels_table
delete from engine_location_table
delete from engine_table
delete from engine_type_table
delete from fuel_system_table
delete from fuel_table
delete from fuel_type_table
delete from num_of_cylinders_table
delete from num_of_doors_table

select * from aspiration_table
select * from body_style_table
select * from body_table
select * from brand_table
select * from car
select * from car_table
select * from cylinders_table
select * from drive_wheels_table
select * from engine_location_table
select * from engine_table
select * from engine_type_table
select * from fuel_system_table
select * from fuel_table
select * from fuel_type_table
select * from num_of_cylinders_table
select * from num_of_doors_table



insert into car 
values (8,1,158,'audi','gas','std','four','sedan','fwd','front',105.8,192.7,71.4,55.7,2844,'ohc','five',136,'mpfi',3.19,3.4,8.5,110,5500,19,25,17710,'2/01/2001')
RETURNING *;
insert into car 
values (7,1,158,'audi','gas','std','four','sedan','fwd','front',105.8,192.7,71.4,55.7,2844,'ohc','five',136,'mpfi',3.19,3.4,8.5,110,5500,19,25,17710,'2/01/2001')
RETURNING *;
insert into car 
values (6,1,158,'audi','gas','std','four','sedan','fwd','front',105.8,192.7,71.4,55.7,2844,'ohc','five',136,'mpfi',3.19,3.4,8.5,110,5500,19,25,17710,'2/01/2001')
RETURNING *;
insert into car 
values (5,1,158,'audi','gas','std','four','sedan','fwd','front',105.8,192.7,71.4,55.7,2844,'ohc','five',136,'mpfi',3.19,3.4,8.5,110,5500,19,25,17710,'2/01/2001')
RETURNING *;
insert into car 
values (4,1,158,'audi','gas','std','four','sedan','fwd','front',105.8,192.7,71.4,55.7,2844,'ohc','five',136,'mpfi',3.19,3.4,8.5,110,5500,19,25,17710,'2/01/2001')
RETURNING *;

