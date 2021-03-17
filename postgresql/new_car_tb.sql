CREATE TABLE body_style_table
(
    id_body_style serial primary key,
    body_style varchar(50)
);
CREATE TABLE num_of_doors_table
(
    id_num_of_doors serial primary key,
    num_of_doors varchar(50)
);
CREATE TABLE num_of_cylinders_table
(
    id_num_of_cylinders serial primary key,
    num_of_cylinders varchar(50)
);
CREATE TABLE engine_location_table
(
    id_engine_location serial primary key,
    engine_location varchar(50)
);
CREATE TABLE engine_type_table
(
    id_engine_type serial primary key,
    engine_type varchar(50)
);
CREATE TABLE drive_wheels_table
(
    id_drive_wheels serial primary key,
    drive_wheels varchar(50)
);
CREATE TABLE aspiration_table
(
    id_aspiration serial primary key,
    aspiration varchar(50)
);
CREATE TABLE fuel_type_table
(
    id_fuel_type serial primary key,
    fuel_type varchar(50)
);
CREATE TABLE fuel_system_table
(
    id_fuel_system serial primary key,
    fuel_system varchar(50)
);
CREATE TABLE brand_table
(
    id_make serial primary key,
    make varchar(50)
);
CREATE TABLE body_table
(
    id_body serial primary key,
    id_body_style int,
    id_num_of_doors int,
    length float,
    width float,
    height float,
    wheel_base float,
    curb_weight int,
    CONSTRAINT fk_body_style FOREIGN KEY (id_body_style) REFERENCES body_style_table(id_body_style)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_num_of_doors FOREIGN KEY (id_num_of_doors) REFERENCES num_of_doors_table(id_num_of_doors)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ;
CREATE TABLE cylinders_table
(
    id_cylinders serial primary key,
    id_num_of_cylinders int,
    bore float,
    compression_ratio float,
    CONSTRAINT fk_num_of_cylinders FOREIGN KEY (id_num_of_cylinders) REFERENCES num_of_cylinders_table (id_num_of_cylinders)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE engine_table
(
    id_engine serial primary key,
    engine_size float,
    stroke float,
    horsepower float,
    peak_rpm float,
    id_engine_location int,
    id_engine_type int,
    id_drive_wheels int,
    id_aspiration int,
    CONSTRAINT fk_aspiration FOREIGN KEY (id_aspiration) REFERENCES aspiration_table (id_aspiration)        
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_drive_wheels FOREIGN KEY (id_drive_wheels)  REFERENCES drive_wheels_table (id_drive_wheels)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_engine_location FOREIGN KEY (id_engine_location) REFERENCES engine_location_table (id_engine_location)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_engine_type FOREIGN KEY (id_engine_type) REFERENCES engine_type_table (id_engine_type)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE fuel_table
(
    id_fuel serial primary key,
    id_fuel_type int,
    id_fuel_system int,
    CONSTRAINT fk_fuel_system FOREIGN KEY (id_fuel_system) REFERENCES fuel_system_table (id_fuel_system)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_fuel_type FOREIGN KEY (id_fuel_type) REFERENCES fuel_type_table (id_fuel_type)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
CREATE TABLE car_table
(
    id serial primary key,
    symboling int,
    normalized_losses int,
    city_mpg int,
    highway_mpg int,
    price int,
    load_date varchar(50),
    id_body int,
    id_make int,
    id_cylinders int,
    id_engine int,
    id_fuel int,
    CONSTRAINT fk_body FOREIGN KEY (id_body) REFERENCES body_table(id_body)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_cylinders FOREIGN KEY (id_cylinders) REFERENCES cylinders_table(id_cylinders)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_engine FOREIGN KEY (id_engine) REFERENCES engine_table(id_engine)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_fuel FOREIGN KEY (id_fuel) REFERENCES fuel_table(id_fuel)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_make FOREIGN KEY (id_make) REFERENCES brand_table(id_make)
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

select * from car

create procedure insert_body_style()
language sql 
as $$
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
$$
call insert_body_style()

select * from fuel_type_table

alter table body_style_table 
alter column id_body_style type int USING id_body_style::int;
