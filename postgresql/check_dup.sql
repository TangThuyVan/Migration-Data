create or replace function check_dup()
returns trigger
language plpgsql
as $$
begin
	execute 'DELETE FROM ' || TG_ARGV[0] ||
	' WHERE ' ||TG_ARGV[1]|| ' IN
	(SELECT ' ||TG_ARGV[1]|| ' FROM
		(SELECT ' ||TG_ARGV[1]|| ' , ROW_NUMBER()
		OVER
			(PARTITION BY ' ||TG_ARGV[2]||
		 	' order by ' ||TG_ARGV[1]|| ' ) AS row_num
			FROM ' ||TG_ARGV[0]|| ' ) t
			WHERE t.row_num > 1)';
	return null;
end;
$$

CREATE TRIGGER del_dup_aspiration
AFTER INSERT 
ON aspiration_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('aspiration_table', 'id_aspiration', 'aspiration');

CREATE TRIGGER del_dup_body_style
AFTER INSERT 
ON body_style_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('body_style_table', 'id_body_style', 'body_style');

CREATE TRIGGER del_dup_drive_wheels
AFTER INSERT 
ON drive_wheels_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('drive_wheels_table', 'id_drive_wheels', 'drive_wheels');

CREATE TRIGGER del_dup_engine_location
AFTER INSERT 
ON engine_location_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('engine_location_table', 'id_engine_location', 'engine_location');

CREATE TRIGGER del_dup_engine_type
AFTER INSERT 
ON engine_type_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('engine_type_table', 'id_engine_type', 'engine_type');

CREATE TRIGGER del_dup_fuel_system
AFTER INSERT 
ON fuel_system_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('fuel_system_table', 'id_fuel_system', 'fuel_system');

CREATE TRIGGER del_dup_fuel_type
AFTER INSERT 
ON fuel_type_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('fuel_type_table', 'id_fuel_type', 'fuel_type');

CREATE TRIGGER del_dup_num_of_cylinders
AFTER INSERT 
ON num_of_cylinders_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('num_of_cylinders_table', 'id_num_of_cylinders', 'num_of_cylinders');

CREATE TRIGGER del_dup_num_of_doors
AFTER INSERT 
ON num_of_doors_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('num_of_doors_table', 'id_num_of_doors', 'num_of_doors');

CREATE TRIGGER del_dup_body
AFTER INSERT 
ON body_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('body_table', 'id_body', 
								'id_body_style, id_num_of_doors,
								length, width, height, wheel_base, curb_weight');

CREATE TRIGGER del_dup_brand
AFTER INSERT 
ON brand_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('brand_table', 'id_make', 'make');
	
CREATE TRIGGER del_dup_cylinders
AFTER INSERT 
ON cylinders_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('cylinders_table', 'id_cylinders', 
								'id_num_of_cylinders, bore, compression_ratio');

CREATE TRIGGER del_dup_fuel
AFTER INSERT 
ON fuel_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('fuel_table', 'id_fuel', 'id_fuel_type, id_fuel_system');

CREATE TRIGGER del_dup_engine
AFTER INSERT 
ON engine_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('engine_table', 'id_engine',
								'engine_size, stroke, horsepower, peak_rpm,id_engine_location,
								id_engine_type, id_drive_wheels, id_aspiration');

CREATE TRIGGER del_dup_car
AFTER INSERT 
ON car_table
FOR EACH ROW
	EXECUTE PROCEDURE check_dup('car_table', 'id',
								'symboling, normalized_losses, city_mpg, highway_mpg, price,
								load_date, id_body, id_make, id_cylinders, id_engine, id_fuel');

select * from car_table

	 
	 