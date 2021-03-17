create OR REPLACE function insert_branch()
returns trigger
language plpgsql 
as $$
begin
	insert into body_style_table(body_style) select distinct body_style from car;
	insert into num_of_doors_table(num_of_doors) select distinct num_of_doors from car;
	insert into num_of_cylinders_table(num_of_cylinders) select distinct num_of_cylinders from car;
	insert into engine_location_table(engine_location) select distinct engine_location from car;
	insert into engine_type_table(engine_type) select distinct engine_type from car;
	insert into drive_wheels_table(drive_wheels) select distinct drive_wheels from car;
	insert into aspiration_table(aspiration) select distinct aspiration from car;
	insert into fuel_type_table(fuel_type) select distinct fuel_type from car;
	insert into fuel_system_table(fuel_system) select distinct fuel_system from car;
	insert into brand_table(make) select distinct make from car;
	return null;
end;
$$;
select insert_branch()
drop function insert_branch()

------------
CREATE OR REPLACE FUNCTION insert_temp_body()
returns trigger
LANGUAGE plpgsql  
AS $$
begin
	create temporary table body_tb(
		body_style varchar(50),
		num_of_doors varchar(50),
		length float,
		width float,
		height float,
		wheel_base float,
		curb_weight int
	);
 	insert into body_tb(body_style,num_of_doors,length, width, height,wheel_base, curb_weight)
	select distinct body_style,num_of_doors,length, width, height,wheel_base, curb_weight
	from car;
	
	update body_tb
	set body_style = id_body_style from body_style_table
	where body_style_table.body_style = body_tb.body_style ;

	update body_tb
	set num_of_doors = id_num_of_doors from num_of_doors_table
	where num_of_doors_table.num_of_doors = body_tb.num_of_doors;
	
	alter table body_tb 
	alter column body_style type int USING body_style::int;
	
	alter table body_tb 
	alter column num_of_doors type int USING num_of_doors::int;
	
	insert into body_table (id_body_style,id_num_of_doors,length, width, height,wheel_base,curb_weight )
	select distinct body_style,num_of_doors,length, width, height,wheel_base,curb_weight 
	from body_tb;
	DROP TABLE IF EXISTS body_tb;
	return null;
end;
$$;

call insert_temp_body()
select * from body_table
delete from body_table

--------------------------

CREATE OR REPLACE FUNCTION insert_temp_cylinders()
returns trigger
LANGUAGE plpgsql  
AS $$
begin
	create temporary table cylinders_tb(
		num_of_cylinders varchar(50),
		bore float,
		compression_ratio float
	);
 	insert into cylinders_tb(num_of_cylinders,bore,compression_ratio)
	select distinct num_of_cylinders,bore,compression_ratio
	from car;
	
	update cylinders_tb
	set num_of_cylinders = id_num_of_cylinders from num_of_cylinders_table
	where num_of_cylinders_table.num_of_cylinders = cylinders_tb.num_of_cylinders ;

	alter table cylinders_tb 
	alter column num_of_cylinders type int USING num_of_cylinders::int;
	
	insert into cylinders_table (id_num_of_cylinders,bore,compression_ratio)
	select distinct num_of_cylinders,bore,compression_ratio 
	from cylinders_tb;
	DROP TABLE IF EXISTS cylinders_tb;
	return null;
end;
$$;

call insert_temp_cylinders()
select * from cylinders_table
delete from cylinders_table

---------------------------------

CREATE OR REPLACE FUNCTION insert_temp_engine()
returns trigger
LANGUAGE plpgsql  
AS $$
begin
	create temporary table engine_tb(
		engine_size float,
		stroke float,
		horsepower float,
		peak_rpm float,
		engine_location varchar(50),
		engine_type varchar(50),
		drive_wheels varchar(50),
		aspiration varchar(50)
	);
 	insert into engine_tb(engine_size,stroke,horsepower,peak_rpm,engine_location,engine_type,drive_wheels,aspiration)
	select distinct engine_size,stroke,horsepower,peak_rpm,engine_location,engine_type,drive_wheels,aspiration
	from car;
	
	update engine_tb
	set engine_location = id_engine_location from engine_location_table
	where engine_location_table.engine_location = engine_tb.engine_location ;
	
	update engine_tb
	set engine_type = id_engine_type from engine_type_table
	where engine_type_table.engine_type = engine_tb.engine_type ;
	
	update engine_tb
	set drive_wheels = id_drive_wheels from drive_wheels_table
	where drive_wheels_table.drive_wheels = engine_tb.drive_wheels ;
	
	update engine_tb
	set aspiration = id_aspiration from aspiration_table
	where aspiration_table.aspiration = engine_tb.aspiration ;

	alter table engine_tb 
	alter column engine_location type int USING engine_location::int;
	
	alter table engine_tb 
	alter column engine_type type int USING engine_type::int;
	
	alter table engine_tb 
	alter column drive_wheels type int USING drive_wheels::int;
	
	alter table engine_tb 
	alter column aspiration type int USING aspiration::int;
	
	insert into engine_table (engine_size,stroke,horsepower,peak_rpm,id_engine_location,id_engine_type,id_drive_wheels,id_aspiration)
	select distinct engine_size,stroke,horsepower,peak_rpm,engine_location,engine_type,drive_wheels,aspiration
	from engine_tb;
	DROP TABLE IF EXISTS engine_tb;
	return null;
end;
$$;

call insert_temp_engine()
select * from engine_table
delete from engine_table
-----------------------------------------

CREATE OR REPLACE FUNCTION insert_temp_fuel()
returns trigger
LANGUAGE plpgsql  
AS $$
begin
	create temporary table fuel_tb(
		fuel_type varchar(50),
		fuel_system varchar(50)
	);
 	insert into fuel_tb(fuel_type,fuel_system)
	select distinct fuel_type,fuel_system
	from car;
	
	update fuel_tb
	set fuel_type = id_fuel_type from fuel_type_table
	where fuel_type_table.fuel_type = fuel_tb.fuel_type ;
	
	update fuel_tb
	set fuel_system = id_fuel_system from fuel_system_table
	where fuel_system_table.fuel_system = fuel_tb.fuel_system ;

	alter table fuel_tb 
	alter column fuel_type type int USING fuel_type::int;
	
	alter table fuel_tb 
	alter column fuel_system type int USING fuel_system::int;
	
	insert into fuel_table (id_fuel_type,id_fuel_system)
	select distinct fuel_type,fuel_system 
	from fuel_tb;
	DROP TABLE IF EXISTS fuel_tb;
	return null;
end;
$$;

call insert_temp_fuel()
select * from fuel_table
delete from fuel_table
------------------------------------------

CREATE OR REPLACE FUNCTION insert_temp_car()
returns trigger
LANGUAGE plpgsql  
AS $$
begin
	create temporary table car_tb(
		symboling int,normalized_losses int,make varchar(50),fuel_type varchar(50),
		aspiration varchar(50),num_of_doors varchar(50),body_style varchar(50),
		drive_wheels varchar(50),engine_location varchar(50),wheel_base float,
		length float,width float,height float,curb_weight int,engine_type varchar(50),
		num_of_cylinders varchar(50),engine_size float,fuel_system varchar(50),
		bore float,stroke float,compression_ratio float,horsepower float,peak_rpm float,
		city_mpg int,highway_mpg int,price integer,load_date varchar(50),
		body int, cylinders int,brand int, engine int, fuel int
	);
	insert into car_tb(symboling,normalized_losses,make,fuel_type,aspiration,num_of_doors,body_style,
					   drive_wheels,engine_location,wheel_base,length,width,height,curb_weight,engine_type,
					   num_of_cylinders,engine_size,fuel_system,bore,stroke,compression_ratio,horsepower,
					   peak_rpm,city_mpg,highway_mpg,price,load_date)
	select distinct symboling,normalized_losses,make,fuel_type,aspiration,num_of_doors,body_style,
					   drive_wheels,engine_location,wheel_base,length,width,height,curb_weight,engine_type,
					   num_of_cylinders,engine_size,fuel_system,bore,stroke,compression_ratio,horsepower,
					   peak_rpm,city_mpg,highway_mpg,price,load_date
	from car;

	update car_tb
	set body = id_body from body_table, body_style_table
	where body_table.length = car_tb.length and
		  body_table.width = car_tb.width and
		  body_table.height = car_tb.height and
		  body_table.wheel_base = car_tb.wheel_base and
		  body_table.curb_weight = car_tb.curb_weight and
		  (select body_style from body_style_table where body_style_table.id_body_style = body_table.id_body_style) = car_tb.body_style and
		  (select num_of_doors from num_of_doors_table where num_of_doors_table.id_num_of_doors = body_table.id_num_of_doors) = car_tb.num_of_doors;

	update car_tb
	set cylinders = id_cylinders from cylinders_table, num_of_cylinders_table
	where cylinders_table.bore = car_tb.bore and
		  cylinders_table.compression_ratio = car_tb.compression_ratio and
		  (select num_of_cylinders from num_of_cylinders_table where num_of_cylinders_table.id_num_of_cylinders = cylinders_table.id_num_of_cylinders) = car_tb.num_of_cylinders;

	update car_tb
	set brand = id_make from brand_table
	where brand_table.make = car_tb.make ;

	update car_tb
	set engine = id_engine from engine_table
	where engine_table.engine_size = car_tb.engine_size and
		  engine_table.stroke = car_tb.stroke and
		  engine_table.horsepower = car_tb.horsepower and
		  engine_table.peak_rpm = car_tb.peak_rpm and
		  (select engine_location from engine_location_table where engine_location_table.id_engine_location = engine_table.id_engine_location) = car_tb.engine_location and
		  (select engine_type from engine_type_table where engine_type_table.id_engine_type = engine_table.id_engine_type) = car_tb.engine_type and
		  (select drive_wheels from drive_wheels_table where drive_wheels_table.id_drive_wheels = engine_table.id_drive_wheels) = car_tb.drive_wheels and
		  (select aspiration from aspiration_table where aspiration_table.id_aspiration = engine_table.id_aspiration) = car_tb.aspiration;

	update car_tb
	set fuel = id_fuel from fuel_table
	where (select fuel_type from fuel_type_table where fuel_type_table.id_fuel_type = fuel_table.id_fuel_type) = car_tb.fuel_type and
		  (select fuel_system from fuel_system_table where fuel_system_table.id_fuel_system = fuel_table.id_fuel_system) = car_tb.fuel_system;

	insert into car_table (symboling,normalized_losses,city_mpg,highway_mpg,price,load_date,
						  id_body,id_make,id_cylinders,id_engine,id_fuel)
	select distinct symboling,normalized_losses,city_mpg,highway_mpg,price,load_date,
			body,brand,cylinders,engine,fuel
	from car_tb;
	DROP TABLE IF EXISTS car_tb;
	return null;
end;
$$;

call insert_temp_car()
select * from car_table
delete from car_table
