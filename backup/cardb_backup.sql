PGDMP         '    
            y            Car    13.2    13.2 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    24654    Car    DATABASE     i   CREATE DATABASE "Car" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'English_United States.1252';
    DROP DATABASE "Car";
                postgres    false                       1255    64238    check_dup()    FUNCTION     �  CREATE FUNCTION public.check_dup() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 "   DROP FUNCTION public.check_dup();
       public          postgres    false            �            1255    63943    insert_branch()    FUNCTION     �  CREATE FUNCTION public.insert_branch() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
 &   DROP FUNCTION public.insert_branch();
       public          postgres    false            �            1255    63945    insert_temp_body()    FUNCTION     �  CREATE FUNCTION public.insert_temp_body() RETURNS trigger
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
 )   DROP FUNCTION public.insert_temp_body();
       public          postgres    false                       1255    63949    insert_temp_car()    FUNCTION     o  CREATE FUNCTION public.insert_temp_car() RETURNS trigger
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
 (   DROP FUNCTION public.insert_temp_car();
       public          postgres    false            �            1255    63946    insert_temp_cylinders()    FUNCTION     D  CREATE FUNCTION public.insert_temp_cylinders() RETURNS trigger
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
 .   DROP FUNCTION public.insert_temp_cylinders();
       public          postgres    false            �            1255    63947    insert_temp_engine()    FUNCTION     
  CREATE FUNCTION public.insert_temp_engine() RETURNS trigger
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
 +   DROP FUNCTION public.insert_temp_engine();
       public          postgres    false                        1255    63948    insert_temp_fuel()    FUNCTION     `  CREATE FUNCTION public.insert_temp_fuel() RETURNS trigger
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
 )   DROP FUNCTION public.insert_temp_fuel();
       public          postgres    false            �            1259    25444    aspiration_table    TABLE     s   CREATE TABLE public.aspiration_table (
    id_aspiration integer NOT NULL,
    aspiration character varying(50)
);
 $   DROP TABLE public.aspiration_table;
       public         heap    postgres    false            �            1259    25442 "   aspiration_table_id_aspiration_seq    SEQUENCE     �   CREATE SEQUENCE public.aspiration_table_id_aspiration_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.aspiration_table_id_aspiration_seq;
       public          postgres    false    223            �           0    0 "   aspiration_table_id_aspiration_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.aspiration_table_id_aspiration_seq OWNED BY public.aspiration_table.id_aspiration;
          public          postgres    false    222            �            1259    25396    body_style_table    TABLE     s   CREATE TABLE public.body_style_table (
    id_body_style integer NOT NULL,
    body_style character varying(50)
);
 $   DROP TABLE public.body_style_table;
       public         heap    postgres    false            �            1259    25394 "   body_style_table_id_body_style_seq    SEQUENCE     �   CREATE SEQUENCE public.body_style_table_id_body_style_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.body_style_table_id_body_style_seq;
       public          postgres    false    211            �           0    0 "   body_style_table_id_body_style_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.body_style_table_id_body_style_seq OWNED BY public.body_style_table.id_body_style;
          public          postgres    false    210            �            1259    25477 
   body_table    TABLE     	  CREATE TABLE public.body_table (
    id_body integer NOT NULL,
    id_body_style integer,
    id_num_of_doors integer,
    length double precision,
    width double precision,
    height double precision,
    wheel_base double precision,
    curb_weight integer
);
    DROP TABLE public.body_table;
       public         heap    postgres    false            �            1259    25475    body_table_id_body_seq    SEQUENCE     �   CREATE SEQUENCE public.body_table_id_body_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.body_table_id_body_seq;
       public          postgres    false    231            �           0    0    body_table_id_body_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.body_table_id_body_seq OWNED BY public.body_table.id_body;
          public          postgres    false    230            �            1259    25468    brand_table    TABLE     b   CREATE TABLE public.brand_table (
    id_make integer NOT NULL,
    make character varying(50)
);
    DROP TABLE public.brand_table;
       public         heap    postgres    false            �            1259    25466    brand_table_id_make_seq    SEQUENCE     �   CREATE SEQUENCE public.brand_table_id_make_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.brand_table_id_make_seq;
       public          postgres    false    229            �           0    0    brand_table_id_make_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.brand_table_id_make_seq OWNED BY public.brand_table.id_make;
          public          postgres    false    228            �            1259    25585    car    TABLE     �  CREATE TABLE public.car (
    id bigint,
    symboling bigint,
    normalized_losses bigint,
    make text,
    fuel_type text,
    aspiration text,
    num_of_doors text,
    body_style text,
    drive_wheels text,
    engine_location text,
    wheel_base double precision,
    length double precision,
    width double precision,
    height double precision,
    curb_weight bigint,
    engine_type text,
    num_of_cylinders text,
    engine_size double precision,
    fuel_system text,
    bore double precision,
    stroke double precision,
    compression_ratio double precision,
    horsepower double precision,
    peak_rpm double precision,
    city_mpg bigint,
    highway_mpg bigint,
    price bigint,
    load_date text
);
    DROP TABLE public.car;
       public         heap    postgres    false            �            1259    25554 	   car_table    TABLE     H  CREATE TABLE public.car_table (
    id integer NOT NULL,
    symboling integer,
    normalized_losses integer,
    city_mpg integer,
    highway_mpg integer,
    price integer,
    load_date character varying(50),
    id_body integer,
    id_make integer,
    id_cylinders integer,
    id_engine integer,
    id_fuel integer
);
    DROP TABLE public.car_table;
       public         heap    postgres    false            �            1259    25552    car_table_id_seq    SEQUENCE     �   CREATE SEQUENCE public.car_table_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.car_table_id_seq;
       public          postgres    false    239            �           0    0    car_table_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.car_table_id_seq OWNED BY public.car_table.id;
          public          postgres    false    238            �            1259    25495    cylinders_table    TABLE     �   CREATE TABLE public.cylinders_table (
    id_cylinders integer NOT NULL,
    id_num_of_cylinders integer,
    bore double precision,
    compression_ratio double precision
);
 #   DROP TABLE public.cylinders_table;
       public         heap    postgres    false            �            1259    25493     cylinders_table_id_cylinders_seq    SEQUENCE     �   CREATE SEQUENCE public.cylinders_table_id_cylinders_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.cylinders_table_id_cylinders_seq;
       public          postgres    false    233            �           0    0     cylinders_table_id_cylinders_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.cylinders_table_id_cylinders_seq OWNED BY public.cylinders_table.id_cylinders;
          public          postgres    false    232            �            1259    25436    drive_wheels_table    TABLE     y   CREATE TABLE public.drive_wheels_table (
    id_drive_wheels integer NOT NULL,
    drive_wheels character varying(50)
);
 &   DROP TABLE public.drive_wheels_table;
       public         heap    postgres    false            �            1259    25434 &   drive_wheels_table_id_drive_wheels_seq    SEQUENCE     �   CREATE SEQUENCE public.drive_wheels_table_id_drive_wheels_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.drive_wheels_table_id_drive_wheels_seq;
       public          postgres    false    221            �           0    0 &   drive_wheels_table_id_drive_wheels_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.drive_wheels_table_id_drive_wheels_seq OWNED BY public.drive_wheels_table.id_drive_wheels;
          public          postgres    false    220            �            1259    25420    engine_location_table    TABLE     �   CREATE TABLE public.engine_location_table (
    id_engine_location integer NOT NULL,
    engine_location character varying(50)
);
 )   DROP TABLE public.engine_location_table;
       public         heap    postgres    false            �            1259    25418 ,   engine_location_table_id_engine_location_seq    SEQUENCE     �   CREATE SEQUENCE public.engine_location_table_id_engine_location_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 C   DROP SEQUENCE public.engine_location_table_id_engine_location_seq;
       public          postgres    false    217            �           0    0 ,   engine_location_table_id_engine_location_seq    SEQUENCE OWNED BY     }   ALTER SEQUENCE public.engine_location_table_id_engine_location_seq OWNED BY public.engine_location_table.id_engine_location;
          public          postgres    false    216            �            1259    25508    engine_table    TABLE     8  CREATE TABLE public.engine_table (
    id_engine integer NOT NULL,
    engine_size double precision,
    stroke double precision,
    horsepower double precision,
    peak_rpm double precision,
    id_engine_location integer,
    id_engine_type integer,
    id_drive_wheels integer,
    id_aspiration integer
);
     DROP TABLE public.engine_table;
       public         heap    postgres    false            �            1259    25506    engine_table_id_engine_seq    SEQUENCE     �   CREATE SEQUENCE public.engine_table_id_engine_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.engine_table_id_engine_seq;
       public          postgres    false    235            �           0    0    engine_table_id_engine_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.engine_table_id_engine_seq OWNED BY public.engine_table.id_engine;
          public          postgres    false    234            �            1259    25428    engine_type_table    TABLE     v   CREATE TABLE public.engine_type_table (
    id_engine_type integer NOT NULL,
    engine_type character varying(50)
);
 %   DROP TABLE public.engine_type_table;
       public         heap    postgres    false            �            1259    25426 $   engine_type_table_id_engine_type_seq    SEQUENCE     �   CREATE SEQUENCE public.engine_type_table_id_engine_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.engine_type_table_id_engine_type_seq;
       public          postgres    false    219            �           0    0 $   engine_type_table_id_engine_type_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.engine_type_table_id_engine_type_seq OWNED BY public.engine_type_table.id_engine_type;
          public          postgres    false    218            �            1259    25460    fuel_system_table    TABLE     v   CREATE TABLE public.fuel_system_table (
    id_fuel_system integer NOT NULL,
    fuel_system character varying(50)
);
 %   DROP TABLE public.fuel_system_table;
       public         heap    postgres    false            �            1259    25458 $   fuel_system_table_id_fuel_system_seq    SEQUENCE     �   CREATE SEQUENCE public.fuel_system_table_id_fuel_system_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.fuel_system_table_id_fuel_system_seq;
       public          postgres    false    227            �           0    0 $   fuel_system_table_id_fuel_system_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.fuel_system_table_id_fuel_system_seq OWNED BY public.fuel_system_table.id_fuel_system;
          public          postgres    false    226            �            1259    25536 
   fuel_table    TABLE     w   CREATE TABLE public.fuel_table (
    id_fuel integer NOT NULL,
    id_fuel_type integer,
    id_fuel_system integer
);
    DROP TABLE public.fuel_table;
       public         heap    postgres    false            �            1259    25534    fuel_table_id_fuel_seq    SEQUENCE     �   CREATE SEQUENCE public.fuel_table_id_fuel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.fuel_table_id_fuel_seq;
       public          postgres    false    237            �           0    0    fuel_table_id_fuel_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.fuel_table_id_fuel_seq OWNED BY public.fuel_table.id_fuel;
          public          postgres    false    236            �            1259    25452    fuel_type_table    TABLE     p   CREATE TABLE public.fuel_type_table (
    id_fuel_type integer NOT NULL,
    fuel_type character varying(50)
);
 #   DROP TABLE public.fuel_type_table;
       public         heap    postgres    false            �            1259    25450     fuel_type_table_id_fuel_type_seq    SEQUENCE     �   CREATE SEQUENCE public.fuel_type_table_id_fuel_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.fuel_type_table_id_fuel_type_seq;
       public          postgres    false    225            �           0    0     fuel_type_table_id_fuel_type_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.fuel_type_table_id_fuel_type_seq OWNED BY public.fuel_type_table.id_fuel_type;
          public          postgres    false    224            �            1259    25412    num_of_cylinders_table    TABLE     �   CREATE TABLE public.num_of_cylinders_table (
    id_num_of_cylinders integer NOT NULL,
    num_of_cylinders character varying(50)
);
 *   DROP TABLE public.num_of_cylinders_table;
       public         heap    postgres    false            �            1259    25410 .   num_of_cylinders_table_id_num_of_cylinders_seq    SEQUENCE     �   CREATE SEQUENCE public.num_of_cylinders_table_id_num_of_cylinders_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 E   DROP SEQUENCE public.num_of_cylinders_table_id_num_of_cylinders_seq;
       public          postgres    false    215            �           0    0 .   num_of_cylinders_table_id_num_of_cylinders_seq    SEQUENCE OWNED BY     �   ALTER SEQUENCE public.num_of_cylinders_table_id_num_of_cylinders_seq OWNED BY public.num_of_cylinders_table.id_num_of_cylinders;
          public          postgres    false    214            �            1259    25404    num_of_doors_table    TABLE     y   CREATE TABLE public.num_of_doors_table (
    id_num_of_doors integer NOT NULL,
    num_of_doors character varying(50)
);
 &   DROP TABLE public.num_of_doors_table;
       public         heap    postgres    false            �            1259    25402 &   num_of_doors_table_id_num_of_doors_seq    SEQUENCE     �   CREATE SEQUENCE public.num_of_doors_table_id_num_of_doors_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.num_of_doors_table_id_num_of_doors_seq;
       public          postgres    false    213            �           0    0 &   num_of_doors_table_id_num_of_doors_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE public.num_of_doors_table_id_num_of_doors_seq OWNED BY public.num_of_doors_table.id_num_of_doors;
          public          postgres    false    212            �           2604    25447    aspiration_table id_aspiration    DEFAULT     �   ALTER TABLE ONLY public.aspiration_table ALTER COLUMN id_aspiration SET DEFAULT nextval('public.aspiration_table_id_aspiration_seq'::regclass);
 M   ALTER TABLE public.aspiration_table ALTER COLUMN id_aspiration DROP DEFAULT;
       public          postgres    false    222    223    223            �           2604    25399    body_style_table id_body_style    DEFAULT     �   ALTER TABLE ONLY public.body_style_table ALTER COLUMN id_body_style SET DEFAULT nextval('public.body_style_table_id_body_style_seq'::regclass);
 M   ALTER TABLE public.body_style_table ALTER COLUMN id_body_style DROP DEFAULT;
       public          postgres    false    211    210    211            �           2604    25480    body_table id_body    DEFAULT     x   ALTER TABLE ONLY public.body_table ALTER COLUMN id_body SET DEFAULT nextval('public.body_table_id_body_seq'::regclass);
 A   ALTER TABLE public.body_table ALTER COLUMN id_body DROP DEFAULT;
       public          postgres    false    231    230    231            �           2604    25471    brand_table id_make    DEFAULT     z   ALTER TABLE ONLY public.brand_table ALTER COLUMN id_make SET DEFAULT nextval('public.brand_table_id_make_seq'::regclass);
 B   ALTER TABLE public.brand_table ALTER COLUMN id_make DROP DEFAULT;
       public          postgres    false    228    229    229            �           2604    25557    car_table id    DEFAULT     l   ALTER TABLE ONLY public.car_table ALTER COLUMN id SET DEFAULT nextval('public.car_table_id_seq'::regclass);
 ;   ALTER TABLE public.car_table ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    239    238    239            �           2604    25498    cylinders_table id_cylinders    DEFAULT     �   ALTER TABLE ONLY public.cylinders_table ALTER COLUMN id_cylinders SET DEFAULT nextval('public.cylinders_table_id_cylinders_seq'::regclass);
 K   ALTER TABLE public.cylinders_table ALTER COLUMN id_cylinders DROP DEFAULT;
       public          postgres    false    233    232    233            �           2604    25439 "   drive_wheels_table id_drive_wheels    DEFAULT     �   ALTER TABLE ONLY public.drive_wheels_table ALTER COLUMN id_drive_wheels SET DEFAULT nextval('public.drive_wheels_table_id_drive_wheels_seq'::regclass);
 Q   ALTER TABLE public.drive_wheels_table ALTER COLUMN id_drive_wheels DROP DEFAULT;
       public          postgres    false    221    220    221            �           2604    25423 (   engine_location_table id_engine_location    DEFAULT     �   ALTER TABLE ONLY public.engine_location_table ALTER COLUMN id_engine_location SET DEFAULT nextval('public.engine_location_table_id_engine_location_seq'::regclass);
 W   ALTER TABLE public.engine_location_table ALTER COLUMN id_engine_location DROP DEFAULT;
       public          postgres    false    216    217    217            �           2604    25511    engine_table id_engine    DEFAULT     �   ALTER TABLE ONLY public.engine_table ALTER COLUMN id_engine SET DEFAULT nextval('public.engine_table_id_engine_seq'::regclass);
 E   ALTER TABLE public.engine_table ALTER COLUMN id_engine DROP DEFAULT;
       public          postgres    false    234    235    235            �           2604    25431     engine_type_table id_engine_type    DEFAULT     �   ALTER TABLE ONLY public.engine_type_table ALTER COLUMN id_engine_type SET DEFAULT nextval('public.engine_type_table_id_engine_type_seq'::regclass);
 O   ALTER TABLE public.engine_type_table ALTER COLUMN id_engine_type DROP DEFAULT;
       public          postgres    false    218    219    219            �           2604    25463     fuel_system_table id_fuel_system    DEFAULT     �   ALTER TABLE ONLY public.fuel_system_table ALTER COLUMN id_fuel_system SET DEFAULT nextval('public.fuel_system_table_id_fuel_system_seq'::regclass);
 O   ALTER TABLE public.fuel_system_table ALTER COLUMN id_fuel_system DROP DEFAULT;
       public          postgres    false    227    226    227            �           2604    25539    fuel_table id_fuel    DEFAULT     x   ALTER TABLE ONLY public.fuel_table ALTER COLUMN id_fuel SET DEFAULT nextval('public.fuel_table_id_fuel_seq'::regclass);
 A   ALTER TABLE public.fuel_table ALTER COLUMN id_fuel DROP DEFAULT;
       public          postgres    false    237    236    237            �           2604    25455    fuel_type_table id_fuel_type    DEFAULT     �   ALTER TABLE ONLY public.fuel_type_table ALTER COLUMN id_fuel_type SET DEFAULT nextval('public.fuel_type_table_id_fuel_type_seq'::regclass);
 K   ALTER TABLE public.fuel_type_table ALTER COLUMN id_fuel_type DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    25415 *   num_of_cylinders_table id_num_of_cylinders    DEFAULT     �   ALTER TABLE ONLY public.num_of_cylinders_table ALTER COLUMN id_num_of_cylinders SET DEFAULT nextval('public.num_of_cylinders_table_id_num_of_cylinders_seq'::regclass);
 Y   ALTER TABLE public.num_of_cylinders_table ALTER COLUMN id_num_of_cylinders DROP DEFAULT;
       public          postgres    false    214    215    215            �           2604    25407 "   num_of_doors_table id_num_of_doors    DEFAULT     �   ALTER TABLE ONLY public.num_of_doors_table ALTER COLUMN id_num_of_doors SET DEFAULT nextval('public.num_of_doors_table_id_num_of_doors_seq'::regclass);
 Q   ALTER TABLE public.num_of_doors_table ALTER COLUMN id_num_of_doors DROP DEFAULT;
       public          postgres    false    212    213    213            l          0    25444    aspiration_table 
   TABLE DATA           E   COPY public.aspiration_table (id_aspiration, aspiration) FROM stdin;
    public          postgres    false    223   ��       `          0    25396    body_style_table 
   TABLE DATA           E   COPY public.body_style_table (id_body_style, body_style) FROM stdin;
    public          postgres    false    211   �       t          0    25477 
   body_table 
   TABLE DATA           }   COPY public.body_table (id_body, id_body_style, id_num_of_doors, length, width, height, wheel_base, curb_weight) FROM stdin;
    public          postgres    false    231   ^�       r          0    25468    brand_table 
   TABLE DATA           4   COPY public.brand_table (id_make, make) FROM stdin;
    public          postgres    false    229   ��       }          0    25585    car 
   TABLE DATA           ^  COPY public.car (id, symboling, normalized_losses, make, fuel_type, aspiration, num_of_doors, body_style, drive_wheels, engine_location, wheel_base, length, width, height, curb_weight, engine_type, num_of_cylinders, engine_size, fuel_system, bore, stroke, compression_ratio, horsepower, peak_rpm, city_mpg, highway_mpg, price, load_date) FROM stdin;
    public          postgres    false    240   ��       |          0    25554 	   car_table 
   TABLE DATA           �   COPY public.car_table (id, symboling, normalized_losses, city_mpg, highway_mpg, price, load_date, id_body, id_make, id_cylinders, id_engine, id_fuel) FROM stdin;
    public          postgres    false    239   �      v          0    25495    cylinders_table 
   TABLE DATA           e   COPY public.cylinders_table (id_cylinders, id_num_of_cylinders, bore, compression_ratio) FROM stdin;
    public          postgres    false    233   B      j          0    25436    drive_wheels_table 
   TABLE DATA           K   COPY public.drive_wheels_table (id_drive_wheels, drive_wheels) FROM stdin;
    public          postgres    false    221   �      f          0    25420    engine_location_table 
   TABLE DATA           T   COPY public.engine_location_table (id_engine_location, engine_location) FROM stdin;
    public          postgres    false    217   �      x          0    25508    engine_table 
   TABLE DATA           �   COPY public.engine_table (id_engine, engine_size, stroke, horsepower, peak_rpm, id_engine_location, id_engine_type, id_drive_wheels, id_aspiration) FROM stdin;
    public          postgres    false    235         h          0    25428    engine_type_table 
   TABLE DATA           H   COPY public.engine_type_table (id_engine_type, engine_type) FROM stdin;
    public          postgres    false    219   �      p          0    25460    fuel_system_table 
   TABLE DATA           H   COPY public.fuel_system_table (id_fuel_system, fuel_system) FROM stdin;
    public          postgres    false    227         z          0    25536 
   fuel_table 
   TABLE DATA           K   COPY public.fuel_table (id_fuel, id_fuel_type, id_fuel_system) FROM stdin;
    public          postgres    false    237   _      n          0    25452    fuel_type_table 
   TABLE DATA           B   COPY public.fuel_type_table (id_fuel_type, fuel_type) FROM stdin;
    public          postgres    false    225   �      d          0    25412    num_of_cylinders_table 
   TABLE DATA           W   COPY public.num_of_cylinders_table (id_num_of_cylinders, num_of_cylinders) FROM stdin;
    public          postgres    false    215   �      b          0    25404    num_of_doors_table 
   TABLE DATA           K   COPY public.num_of_doors_table (id_num_of_doors, num_of_doors) FROM stdin;
    public          postgres    false    213   !      �           0    0 "   aspiration_table_id_aspiration_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.aspiration_table_id_aspiration_seq', 2010, true);
          public          postgres    false    222            �           0    0 "   body_style_table_id_body_style_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.body_style_table_id_body_style_seq', 3476, true);
          public          postgres    false    210            �           0    0    body_table_id_body_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.body_table_id_body_seq', 67195, true);
          public          postgres    false    230            �           0    0    brand_table_id_make_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.brand_table_id_make_seq', 11606, true);
          public          postgres    false    228            �           0    0    car_table_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.car_table_id_seq', 70418, true);
          public          postgres    false    238            �           0    0     cylinders_table_id_cylinders_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.cylinders_table_id_cylinders_seq', 30808, true);
          public          postgres    false    232            �           0    0 &   drive_wheels_table_id_drive_wheels_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.drive_wheels_table_id_drive_wheels_seq', 3046, true);
          public          postgres    false    220            �           0    0 ,   engine_location_table_id_engine_location_seq    SEQUENCE SET     ]   SELECT pg_catalog.setval('public.engine_location_table_id_engine_location_seq', 1068, true);
          public          postgres    false    216            �           0    0    engine_table_id_engine_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.engine_table_id_engine_seq', 34679, true);
          public          postgres    false    234            �           0    0 $   engine_type_table_id_engine_type_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.engine_type_table_id_engine_type_seq', 3825, true);
          public          postgres    false    218            �           0    0 $   fuel_system_table_id_fuel_system_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.fuel_system_table_id_fuel_system_seq', 5240, true);
          public          postgres    false    226            �           0    0    fuel_table_id_fuel_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.fuel_table_id_fuel_seq', 5728, true);
          public          postgres    false    236            �           0    0     fuel_type_table_id_fuel_type_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.fuel_type_table_id_fuel_type_seq', 1800, true);
          public          postgres    false    224            �           0    0 .   num_of_cylinders_table_id_num_of_cylinders_seq    SEQUENCE SET     _   SELECT pg_catalog.setval('public.num_of_cylinders_table_id_num_of_cylinders_seq', 4006, true);
          public          postgres    false    214            �           0    0 &   num_of_doors_table_id_num_of_doors_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.num_of_doors_table_id_num_of_doors_seq', 2956, true);
          public          postgres    false    212            �           2606    25449 &   aspiration_table aspiration_table_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.aspiration_table
    ADD CONSTRAINT aspiration_table_pkey PRIMARY KEY (id_aspiration);
 P   ALTER TABLE ONLY public.aspiration_table DROP CONSTRAINT aspiration_table_pkey;
       public            postgres    false    223            �           2606    25401 &   body_style_table body_style_table_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.body_style_table
    ADD CONSTRAINT body_style_table_pkey PRIMARY KEY (id_body_style);
 P   ALTER TABLE ONLY public.body_style_table DROP CONSTRAINT body_style_table_pkey;
       public            postgres    false    211            �           2606    25482    body_table body_table_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.body_table
    ADD CONSTRAINT body_table_pkey PRIMARY KEY (id_body);
 D   ALTER TABLE ONLY public.body_table DROP CONSTRAINT body_table_pkey;
       public            postgres    false    231            �           2606    25473    brand_table brand_table_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.brand_table
    ADD CONSTRAINT brand_table_pkey PRIMARY KEY (id_make);
 F   ALTER TABLE ONLY public.brand_table DROP CONSTRAINT brand_table_pkey;
       public            postgres    false    229            �           2606    25559    car_table car_table_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT car_table_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.car_table DROP CONSTRAINT car_table_pkey;
       public            postgres    false    239            �           2606    25500 $   cylinders_table cylinders_table_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.cylinders_table
    ADD CONSTRAINT cylinders_table_pkey PRIMARY KEY (id_cylinders);
 N   ALTER TABLE ONLY public.cylinders_table DROP CONSTRAINT cylinders_table_pkey;
       public            postgres    false    233            �           2606    25441 *   drive_wheels_table drive_wheels_table_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.drive_wheels_table
    ADD CONSTRAINT drive_wheels_table_pkey PRIMARY KEY (id_drive_wheels);
 T   ALTER TABLE ONLY public.drive_wheels_table DROP CONSTRAINT drive_wheels_table_pkey;
       public            postgres    false    221            �           2606    25425 0   engine_location_table engine_location_table_pkey 
   CONSTRAINT     ~   ALTER TABLE ONLY public.engine_location_table
    ADD CONSTRAINT engine_location_table_pkey PRIMARY KEY (id_engine_location);
 Z   ALTER TABLE ONLY public.engine_location_table DROP CONSTRAINT engine_location_table_pkey;
       public            postgres    false    217            �           2606    25513    engine_table engine_table_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.engine_table
    ADD CONSTRAINT engine_table_pkey PRIMARY KEY (id_engine);
 H   ALTER TABLE ONLY public.engine_table DROP CONSTRAINT engine_table_pkey;
       public            postgres    false    235            �           2606    25433 (   engine_type_table engine_type_table_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.engine_type_table
    ADD CONSTRAINT engine_type_table_pkey PRIMARY KEY (id_engine_type);
 R   ALTER TABLE ONLY public.engine_type_table DROP CONSTRAINT engine_type_table_pkey;
       public            postgres    false    219            �           2606    25465 (   fuel_system_table fuel_system_table_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.fuel_system_table
    ADD CONSTRAINT fuel_system_table_pkey PRIMARY KEY (id_fuel_system);
 R   ALTER TABLE ONLY public.fuel_system_table DROP CONSTRAINT fuel_system_table_pkey;
       public            postgres    false    227            �           2606    25541    fuel_table fuel_table_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.fuel_table
    ADD CONSTRAINT fuel_table_pkey PRIMARY KEY (id_fuel);
 D   ALTER TABLE ONLY public.fuel_table DROP CONSTRAINT fuel_table_pkey;
       public            postgres    false    237            �           2606    25457 $   fuel_type_table fuel_type_table_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.fuel_type_table
    ADD CONSTRAINT fuel_type_table_pkey PRIMARY KEY (id_fuel_type);
 N   ALTER TABLE ONLY public.fuel_type_table DROP CONSTRAINT fuel_type_table_pkey;
       public            postgres    false    225            �           2606    25417 2   num_of_cylinders_table num_of_cylinders_table_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.num_of_cylinders_table
    ADD CONSTRAINT num_of_cylinders_table_pkey PRIMARY KEY (id_num_of_cylinders);
 \   ALTER TABLE ONLY public.num_of_cylinders_table DROP CONSTRAINT num_of_cylinders_table_pkey;
       public            postgres    false    215            �           2606    25409 *   num_of_doors_table num_of_doors_table_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY public.num_of_doors_table
    ADD CONSTRAINT num_of_doors_table_pkey PRIMARY KEY (id_num_of_doors);
 T   ALTER TABLE ONLY public.num_of_doors_table DROP CONSTRAINT num_of_doors_table_pkey;
       public            postgres    false    213            �           2620    64737    fuel_table auto_delete_dup    TRIGGER     �   CREATE TRIGGER auto_delete_dup AFTER INSERT ON public.fuel_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('fuel_table', 'id_fuel', 'id_fuel_type, id_fuel_system');
 3   DROP TRIGGER auto_delete_dup ON public.fuel_table;
       public          postgres    false    237    257            �           2620    63950    car auto_insert_abranch    TRIGGER     t   CREATE TRIGGER auto_insert_abranch AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_branch();
 0   DROP TRIGGER auto_insert_abranch ON public.car;
       public          postgres    false    252    240            �           2620    63951    car auto_insert_bbody    TRIGGER     u   CREATE TRIGGER auto_insert_bbody AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_temp_body();
 .   DROP TRIGGER auto_insert_bbody ON public.car;
       public          postgres    false    240    253            �           2620    63952    car auto_insert_ccylinders    TRIGGER        CREATE TRIGGER auto_insert_ccylinders AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_temp_cylinders();
 3   DROP TRIGGER auto_insert_ccylinders ON public.car;
       public          postgres    false    254    240            �           2620    63953    car auto_insert_dengine    TRIGGER     y   CREATE TRIGGER auto_insert_dengine AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_temp_engine();
 0   DROP TRIGGER auto_insert_dengine ON public.car;
       public          postgres    false    255    240            �           2620    63954    car auto_insert_efuel    TRIGGER     u   CREATE TRIGGER auto_insert_efuel AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_temp_fuel();
 .   DROP TRIGGER auto_insert_efuel ON public.car;
       public          postgres    false    256    240            �           2620    63955    car auto_insert_fcar    TRIGGER     s   CREATE TRIGGER auto_insert_fcar AFTER INSERT ON public.car FOR EACH ROW EXECUTE FUNCTION public.insert_temp_car();
 -   DROP TRIGGER auto_insert_fcar ON public.car;
       public          postgres    false    240    258            �           2620    64964 #   aspiration_table del_dup_aspiration    TRIGGER     �   CREATE TRIGGER del_dup_aspiration AFTER INSERT ON public.aspiration_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('aspiration_table', 'id_aspiration', 'aspiration');
 <   DROP TRIGGER del_dup_aspiration ON public.aspiration_table;
       public          postgres    false    223    257            �           2620    64973    body_table del_dup_body    TRIGGER     �   CREATE TRIGGER del_dup_body AFTER INSERT ON public.body_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('body_table', 'id_body', 'id_body_style, id_num_of_doors,
								length, width, height, wheel_base, curb_weight');
 0   DROP TRIGGER del_dup_body ON public.body_table;
       public          postgres    false    257    231            �           2620    64965 #   body_style_table del_dup_body_style    TRIGGER     �   CREATE TRIGGER del_dup_body_style AFTER INSERT ON public.body_style_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('body_style_table', 'id_body_style', 'body_style');
 <   DROP TRIGGER del_dup_body_style ON public.body_style_table;
       public          postgres    false    257    211            �           2620    64974    brand_table del_dup_brand    TRIGGER     �   CREATE TRIGGER del_dup_brand AFTER INSERT ON public.brand_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('brand_table', 'id_make', 'make');
 2   DROP TRIGGER del_dup_brand ON public.brand_table;
       public          postgres    false    257    229            �           2620    65024    car_table del_dup_car    TRIGGER       CREATE TRIGGER del_dup_car AFTER INSERT ON public.car_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('car_table', 'id', 'symboling, normalized_losses, city_mpg, highway_mpg, price,
								load_date, id_body, id_make, id_cylinders, id_engine, id_fuel');
 .   DROP TRIGGER del_dup_car ON public.car_table;
       public          postgres    false    257    239            �           2620    64975 !   cylinders_table del_dup_cylinders    TRIGGER     �   CREATE TRIGGER del_dup_cylinders AFTER INSERT ON public.cylinders_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('cylinders_table', 'id_cylinders', 'id_num_of_cylinders, bore, compression_ratio');
 :   DROP TRIGGER del_dup_cylinders ON public.cylinders_table;
       public          postgres    false    257    233            �           2620    64966 '   drive_wheels_table del_dup_drive_wheels    TRIGGER     �   CREATE TRIGGER del_dup_drive_wheels AFTER INSERT ON public.drive_wheels_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('drive_wheels_table', 'id_drive_wheels', 'drive_wheels');
 @   DROP TRIGGER del_dup_drive_wheels ON public.drive_wheels_table;
       public          postgres    false    257    221            �           2620    64977    engine_table del_dup_engine    TRIGGER       CREATE TRIGGER del_dup_engine AFTER INSERT ON public.engine_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('engine_table', 'id_engine', 'engine_size, stroke, horsepower, peak_rpm,id_engine_location,
								id_engine_type, id_drive_wheels, id_aspiration');
 4   DROP TRIGGER del_dup_engine ON public.engine_table;
       public          postgres    false    257    235            �           2620    64967 -   engine_location_table del_dup_engine_location    TRIGGER     �   CREATE TRIGGER del_dup_engine_location AFTER INSERT ON public.engine_location_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('engine_location_table', 'id_engine_location', 'engine_location');
 F   DROP TRIGGER del_dup_engine_location ON public.engine_location_table;
       public          postgres    false    217    257            �           2620    64968 %   engine_type_table del_dup_engine_type    TRIGGER     �   CREATE TRIGGER del_dup_engine_type AFTER INSERT ON public.engine_type_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('engine_type_table', 'id_engine_type', 'engine_type');
 >   DROP TRIGGER del_dup_engine_type ON public.engine_type_table;
       public          postgres    false    257    219            �           2620    64976    fuel_table del_dup_fuel    TRIGGER     �   CREATE TRIGGER del_dup_fuel AFTER INSERT ON public.fuel_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('fuel_table', 'id_fuel', 'id_fuel_type, id_fuel_system');
 0   DROP TRIGGER del_dup_fuel ON public.fuel_table;
       public          postgres    false    257    237            �           2620    64969 %   fuel_system_table del_dup_fuel_system    TRIGGER     �   CREATE TRIGGER del_dup_fuel_system AFTER INSERT ON public.fuel_system_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('fuel_system_table', 'id_fuel_system', 'fuel_system');
 >   DROP TRIGGER del_dup_fuel_system ON public.fuel_system_table;
       public          postgres    false    257    227            �           2620    64970 !   fuel_type_table del_dup_fuel_type    TRIGGER     �   CREATE TRIGGER del_dup_fuel_type AFTER INSERT ON public.fuel_type_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('fuel_type_table', 'id_fuel_type', 'fuel_type');
 :   DROP TRIGGER del_dup_fuel_type ON public.fuel_type_table;
       public          postgres    false    257    225            �           2620    64971 /   num_of_cylinders_table del_dup_num_of_cylinders    TRIGGER     �   CREATE TRIGGER del_dup_num_of_cylinders AFTER INSERT ON public.num_of_cylinders_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('num_of_cylinders_table', 'id_num_of_cylinders', 'num_of_cylinders');
 H   DROP TRIGGER del_dup_num_of_cylinders ON public.num_of_cylinders_table;
       public          postgres    false    257    215            �           2620    64972 '   num_of_doors_table del_dup_num_of_doors    TRIGGER     �   CREATE TRIGGER del_dup_num_of_doors AFTER INSERT ON public.num_of_doors_table FOR EACH ROW EXECUTE FUNCTION public.check_dup('num_of_doors_table', 'id_num_of_doors', 'num_of_doors');
 @   DROP TRIGGER del_dup_num_of_doors ON public.num_of_doors_table;
       public          postgres    false    257    213            �           2606    25514    engine_table fk_aspiration    FK CONSTRAINT     �   ALTER TABLE ONLY public.engine_table
    ADD CONSTRAINT fk_aspiration FOREIGN KEY (id_aspiration) REFERENCES public.aspiration_table(id_aspiration) ON UPDATE CASCADE ON DELETE CASCADE;
 D   ALTER TABLE ONLY public.engine_table DROP CONSTRAINT fk_aspiration;
       public          postgres    false    2984    235    223            �           2606    25560    car_table fk_body    FK CONSTRAINT     �   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT fk_body FOREIGN KEY (id_body) REFERENCES public.body_table(id_body) ON UPDATE CASCADE ON DELETE CASCADE;
 ;   ALTER TABLE ONLY public.car_table DROP CONSTRAINT fk_body;
       public          postgres    false    239    2992    231            �           2606    25483    body_table fk_body_style    FK CONSTRAINT     �   ALTER TABLE ONLY public.body_table
    ADD CONSTRAINT fk_body_style FOREIGN KEY (id_body_style) REFERENCES public.body_style_table(id_body_style) ON UPDATE CASCADE ON DELETE CASCADE;
 B   ALTER TABLE ONLY public.body_table DROP CONSTRAINT fk_body_style;
       public          postgres    false    211    231    2972            �           2606    25565    car_table fk_cylinders    FK CONSTRAINT     �   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT fk_cylinders FOREIGN KEY (id_cylinders) REFERENCES public.cylinders_table(id_cylinders) ON UPDATE CASCADE ON DELETE CASCADE;
 @   ALTER TABLE ONLY public.car_table DROP CONSTRAINT fk_cylinders;
       public          postgres    false    239    2994    233            �           2606    25519    engine_table fk_drive_wheels    FK CONSTRAINT     �   ALTER TABLE ONLY public.engine_table
    ADD CONSTRAINT fk_drive_wheels FOREIGN KEY (id_drive_wheels) REFERENCES public.drive_wheels_table(id_drive_wheels) ON UPDATE CASCADE ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.engine_table DROP CONSTRAINT fk_drive_wheels;
       public          postgres    false    235    221    2982            �           2606    25570    car_table fk_engine    FK CONSTRAINT     �   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT fk_engine FOREIGN KEY (id_engine) REFERENCES public.engine_table(id_engine) ON UPDATE CASCADE ON DELETE CASCADE;
 =   ALTER TABLE ONLY public.car_table DROP CONSTRAINT fk_engine;
       public          postgres    false    239    235    2996            �           2606    25524    engine_table fk_engine_location    FK CONSTRAINT     �   ALTER TABLE ONLY public.engine_table
    ADD CONSTRAINT fk_engine_location FOREIGN KEY (id_engine_location) REFERENCES public.engine_location_table(id_engine_location) ON UPDATE CASCADE ON DELETE CASCADE;
 I   ALTER TABLE ONLY public.engine_table DROP CONSTRAINT fk_engine_location;
       public          postgres    false    235    217    2978            �           2606    25529    engine_table fk_engine_type    FK CONSTRAINT     �   ALTER TABLE ONLY public.engine_table
    ADD CONSTRAINT fk_engine_type FOREIGN KEY (id_engine_type) REFERENCES public.engine_type_table(id_engine_type) ON UPDATE CASCADE ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.engine_table DROP CONSTRAINT fk_engine_type;
       public          postgres    false    219    235    2980            �           2606    25575    car_table fk_fuel    FK CONSTRAINT     �   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT fk_fuel FOREIGN KEY (id_fuel) REFERENCES public.fuel_table(id_fuel) ON UPDATE CASCADE ON DELETE CASCADE;
 ;   ALTER TABLE ONLY public.car_table DROP CONSTRAINT fk_fuel;
       public          postgres    false    239    2998    237            �           2606    25542    fuel_table fk_fuel_system    FK CONSTRAINT     �   ALTER TABLE ONLY public.fuel_table
    ADD CONSTRAINT fk_fuel_system FOREIGN KEY (id_fuel_system) REFERENCES public.fuel_system_table(id_fuel_system) ON UPDATE CASCADE ON DELETE CASCADE;
 C   ALTER TABLE ONLY public.fuel_table DROP CONSTRAINT fk_fuel_system;
       public          postgres    false    2988    227    237            �           2606    25547    fuel_table fk_fuel_type    FK CONSTRAINT     �   ALTER TABLE ONLY public.fuel_table
    ADD CONSTRAINT fk_fuel_type FOREIGN KEY (id_fuel_type) REFERENCES public.fuel_type_table(id_fuel_type) ON UPDATE CASCADE ON DELETE CASCADE;
 A   ALTER TABLE ONLY public.fuel_table DROP CONSTRAINT fk_fuel_type;
       public          postgres    false    237    2986    225            �           2606    25580    car_table fk_make    FK CONSTRAINT     �   ALTER TABLE ONLY public.car_table
    ADD CONSTRAINT fk_make FOREIGN KEY (id_make) REFERENCES public.brand_table(id_make) ON UPDATE CASCADE ON DELETE CASCADE;
 ;   ALTER TABLE ONLY public.car_table DROP CONSTRAINT fk_make;
       public          postgres    false    2990    229    239            �           2606    25501 #   cylinders_table fk_num_of_cylinders    FK CONSTRAINT     �   ALTER TABLE ONLY public.cylinders_table
    ADD CONSTRAINT fk_num_of_cylinders FOREIGN KEY (id_num_of_cylinders) REFERENCES public.num_of_cylinders_table(id_num_of_cylinders) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.cylinders_table DROP CONSTRAINT fk_num_of_cylinders;
       public          postgres    false    233    2976    215            �           2606    25488    body_table fk_num_of_doors    FK CONSTRAINT     �   ALTER TABLE ONLY public.body_table
    ADD CONSTRAINT fk_num_of_doors FOREIGN KEY (id_num_of_doors) REFERENCES public.num_of_doors_table(id_num_of_doors) ON UPDATE CASCADE ON DELETE CASCADE;
 D   ALTER TABLE ONLY public.body_table DROP CONSTRAINT fk_num_of_doors;
       public          postgres    false    213    231    2974            l   !   x�3437�,.I�24�0�,)-J������ Pj�      `   <   x�3�03�,NMI��2�07��H,I�HJL�r-�8������2E)%�\1z\\\ �{�      t   �  x���Yr#9D���(�Xx���9&����.��Qt��AkRn�~�
|t��d��qכ���Ƹ�M���A��_d���'9���{�RH:�%�i��DK_�F�Ө4�'j�'�{4�h���.�h�� U��U��3	�-7s��~��T��lK��x�6ȉ.������p�ɩ�"ヌ��|��k����"��KReIBo?�qA2�$n�0h�$K�Xv�����Q�
$�H����A|�>v�$�<H�o�'�P��������I|�F��� gQV���H|�B��6ϮZ
�y�-!�m�I��g2����f���4�`�Ǭ4�[�n��iK ��_&R�A[r4�����t�=�=�q%�$S�����X�2I24��5gQ�&*n	�t�$;�k[��T�ĘYSDN�%�E���i�ے���rN�i7s�Ek�\�'�X�s^��|4
���LZ�h��-�������/���C��n;R[�d�_���̹�M�JV|��ڂ��.;�ò�:~S������q�l��n�ތd��ȁ௻�!s�՞�;�(I�6�7�Gvj�פM��\E�}��>�#�װ�鎡��Z��d��6���t�o8�Z���3�ҸR�U��������!�<���\j��%�0`]�2����s����G'�|�ꇐqv�Ձ�֗�pB�V��J^4�b���X�!E
�_6jw֛����%PX˰I��1%�����s�"�@��Ug�s]�_H�R���� �W��!m�)uȞ�5KW�!{�T��'?�BW+U��eh,������TH��3Q�a��X�ip�j8�.�Y� Y��mo3[�����y�!��YlP�	�~V��e��C?���>Vw\@�����~���Qy�^2~�8R�%����1�)���0��6�M{*v��N>�GB�J9�G��Rjv�MFfRJi�}���Tw����V��\j�"��B�|PhQ��ݏ����-�mF%OB3��<Y번�"Y2�9�$#���i�X��OcO/C����}N�A
_sx��Ƣr���Z<Hם�6��@��������7�'�y��U��<>�^s�!��*�����bp4�����8�� ��B�����N�F���lK��/8��a����D�k�\p)�o��ɓ����Bi<�Y��x����:�V��:��`�n�>���Yo�rHމ � E}Z��J�z?���BL86��~.���	?T�Tm�A�����D+B��u�_�� ?��5)
��6Ѷ�Fؖ�f�	]e�?��?=�Gqs�u%��A���Y~'L�	5d@!ZB\�ayB�sǁZ�M�V���!6V�����*�(��|nc�R:��J]�uF� �
![��x���������x-�E����~��������Z �c      r   �   x��Kr�0D��]�� 6�]�c�`�򇩙�G����V+�a�q�0����0��_En���ĕ5�3l�#i�~i�T��!����ZH\��~-�?�����ڗ�n���y��2?x8���;>88�w��6Z�SJ�G��J����@OQ�
����-��d�㯾h�bv����7"���CZ      }   �  x�͜�r7���w�4�W�"{CI��D6U"eo����9��k��QI
E|�n�	�1��rF������QO�����M������O��v�~1����s¹;��iAZ{qxz��d�^�<}�"����Z+� #4~����?����T���)��4 o� ���� de��*�Z�T�{���a� ��,�Hw^x� �Q0� w�A�����DP�eI���"�~���@�QA��K��hK�3D����J��:��#�[W Z�x¯��a�����.����b����!�;>*� ��֏, ����������TQ<�NO����
e���`ԝN��j3�/���������_ ��R��0+�x�	���� HAİ#V/!
�a����:��	 ����e��րBa�p
�C�ޗ���"Dl�u�W�w6�����>�z�?��Ac+(�	@@�_HA���.�����|����aJ�V1�Dt�/���Y�B�`��	���p�=m�}L8�����v�`C�Bz�"���v�:[n�B��h��6ɻRyv��9 Ӡ
e����H !�j���gDrՈyO�y/��J�!��?m��o/���n��݉On�_�4c|��v'\�2�Fo琌��i ���W�� �* � r_�U�8`!�� ����t�]J��Z) �.�X�c}�����z�/�ݠ1%�A Z
X �-�@���Wg9w�A��KS�0��	�C@��I�&4>p� #�M�\޲l����4���T�_Z��m���U��?���0�� �Ա�$n�'�Z��?w_�woCE���"{�\'�F:���nd[�� �G��8�C���.�j�3�R(�H�v�,��qG��,
b�#U��XH���y;@&���<��\��C���U�*_#�MwƲ��5�|��Y���׷�׷�*��{]��8}�@�P�2�x{ZS�C�'Q06:�/['���j�n�\(�&�Nc��j:m�2����)��B�Ea��"s�jY�GN¸,�פ��2�b���u��i��Q9�2�vl�Fd;��,	�������{�?�����������cG�6����4��,���h9-��sĀ���`���h.��{d-�d�|f(�\�?��@��.@^���,��K�@c9��ޯF���RiާޔߞO��������\7?l:9�*T��T���Q�$�j$�,&�>^�$�J$x��$7IH޾O2רhSTQ/����\��UB	�KSd �P�NQ�rF��)��3E�T<u]â�%F[��0�Ly�'){7�׵������ƼwM�@R��k d,Gf
�92�D��n���r�X+'y:�ٷ��W���]lKs~����+�;�ݮ�?[j�9T]�E��q�=���3�����@��w]��j�gϊ���ݞ=+��M���)�5m�C�O��9S�d��!�h���Z�P#�&�D�5Ғ�X!5��&��k�YV�$���v=���-��<[�k�S��{{<^�&ǽ�n(ɕ���d�3��Q��`���(H-.\J����u�쮁�@��bD�5ҳ�aI+!��@pkg`k�J>�
�|���X�c��X9BS4����2��'xT>�Եi�U�t���6�&��Z΃AAѭ�0�Ca&(�dq�Ȳpr1E>#���r^�9�I��y)�JA\�N<"�hZfo1�Ғë��s�ys$J�I�s�fxU�aa�I��Ke�na�_AҗI�ZHjC"ݿ=�W�6/��cy�)�uI3ئ/�{fp��_�;�8�I��"�*�a���F��FN���DEjÇp��Tc��+`�[��:�P�
*�v�J��5���,<�K��dn����n�ay>5��r͌I
5A,�Ŋח���OOW;R_P��+XR`M��ێ�K�$>Wv�@~�h����)z��ˎ�K
�U���{��J
����tY��X·��Pr�������v|x��ǔ����	�)��e���1q��@��h\��8���=
gk��������0b:FrU�C�V]���2�g�!�4�u�N�����p~�4�����)z�����ۥ�� �1+M��6
�ϫ�aU��$A�|�9��3����Ʊ� �+�^`��@A���QM�d���~�{{_ڏuyh�4GN2��tKH��|�G. Ml<<���+�� |;9� 8R^ 8���)��!�i{�3���Z�aJ��%��:ɬ�p��H%$bqd������3
��8;�@�Ѧ)5��f#������ �B:���*�4v��Ѕ/�ϣ�aN�xBe=�Z��~o�NX5#�v���BD>�Ut7�#QB���SC�6<�g��B`%x�j!�-������!���5�<(3�~��L��V\\���Bi�9Hb����T���߇ӂSy�����r��<��mvŭ�4_��ٍ�*d�����dgvo�!g�Z���"��0����j� 2�e��|O��� \l8���/�_�A	`��8�����H<:W�[� �R� g�%������[�7��������G�� �:fƗ7��R�U���Bx�QB� �ð�b@6[
��˜�.JÆN�T�N�����$�ra�B	|&Q���6�Bu4��6��*6A��C%�8mk�A�rг �: �\Ѕ�(��T���oG�	�b��1}~�Yގ/?Y�$�A�@;��4���dhRJ5UHdi��r��Gd���J;���\��i)yL�pȚjj�y'X��um����T�d����%�銁oj�3�c��<'^F�}��Bm���q%��XC�vQxeVc��*��?+�c'fLtP %۶rV�l��"�6!�G�]���Yf�vE'�J,���B��md9�ڌR��	��YM�R�#�p%�ذEQ]o�!�Xj�L/:��d��x�=ic$�`�9��O�s [� ��h�V�4RF"B��L儍ԓ�|�yG6)��9(�++b�,9t��J����#���,�O�4c`�:��\=��7�L�����2�Q�p%��cL3�Yx�
x��?7sӨ�����qXc��AY�5����p=��n���5���QU���2��$�*N�9�9=�5_�C����s�B��M2���	Z��G���)��1T�X�)����a�m�Z���-U��be�u�|�%���|)�{X��W���Q�q�[g�_%Gh+0z�z<(��Y#�����C���<�HJ�hY%dX0����؀fD*p?�B�+��+�"��ju(Ar���$�G%���v���zCu|�ĠƤb*��A��8	R����/�IQv@L�d eH(�����Dב�X��R:�6���5v�vBiHꆝWR=����� }��')�Q��I�KE��u����*"(�\+Bf�q�Q���	�c7�4Ay^얷&(?�ga2)vՕZ��;��7(=����l"�g6i�Aڔ��!��X��8���"?L`�Wp#[�v�,�y:7�9@��������i���C!��?���}:#Vp-�H�C �m�v|��A��R����� �Y��R���� ���c�zf'���~��.JCB7��EiX�w�(�|�;]�����ӿ����      |   �  x���I��8E�ʻT�	�]�����9H3��0�p=H�P���'>R���#�Jx�A��!�SR��X2>�"����[H�
�4iiO�'Ϳ��������GJ{Ğ�Ϫr��ѹ���&�m�J�H����NiK]��Am��ӓ./��l��mF�@��ѧH[x,����B� ��8��'�'�?V��l��-/+��,��g�^�د���V+�a�}eI����=O�"�����y�;�\��_ɹx��j;�~�Ku��`O�[�.x��x������N�K�O�8�&{��E[����UI�rٞ�����f���`&n�;*��}D�������Ǯw���;�z������8a���S��5�ve�w�����@>)�WNĂ��B�/��u'�u��Ζ�vV©����R&�/�"�d��U��1z�p��c)F�OG#�O#=�죭GU莍�(r�n�3~��%f`T����p­��T=�F�;�#�/p�K���5.XD.)4�+�zxI�a�삙��˂�:X��oiX�GUy�x��;��v��tz��uz�Y����<�>͙�Z�od����;*H��GO�g�qK�$A����Fnl�N��WZ��$5x͓�@�hN�(��=��Q���g�h)�yiڣm��K��0����qg���^
x��zH�(B�JZ�(4HahI�� �����2�G��	����{�l<ZF8L�c�Q&\�P��5��h�`h˩7N�����y�[]z�4D��v0��*� �H^��]!O�p���0*������Nr�����^$#�u8.�pKz�e��4a�FP\a��]m�Ǚ�(���>S[��� q�^m�p	�~fH�a��F.9�r�m��j/�n�Ò_�k�OMa�M����0G�l�wT��I鸱W�V$rк�/*����s:�n4��E��7���+�_��0B�&��M���|tk�z��u3�ҭ��2:",=e���E�U6��Г�l��P9]A7N~�qn�ּ�¢"�<ŃF3�h��ۍ��8~9���5ȝn�����EsTc/[�+�Bޔ�&irЭ.�5��5f�)��)o����zΗ�����z%�󥃙&|LyS��9_np�p�����!l1��n�D�ҵ>�?��V&�[�k��D��ј�p�;�({���Ո�[�mzxq�ҭ��w:1��9@�.���{�¡u�Q�ә֚4zSGG�^v��w��O6�7��\,I������&Ք-�N��}k4hL��]��Ɗؔ��=�%�i��mT����W��c`�Rs����Ѭr�!�&>�h9S�S>��\���z��5�`��9y	ڰ�
~e�5�
�����MͤMzL�r��8u}We�yxҙy�br���<�;�.�>����ɧ���w��Ó�h^��AٳaD�V/�m���:7�[�0'�S�Y&��s�<�b�o'[�1u�ѕޏ��h��#�c6C�n���)B�a�s�5��S:����z>�0��V�	�jh�9;�8}�`��j�-V���ì&;�"�Qr�����`<$WX�sv�{��/�q��0�	q�kU�찊W�a��.a��<sKߙ�o@CY��Ĵ�n\C��l��Kg.��~Wcͼ��[i�;\��\�è�������҄�p�����bh!���q�V�m�UI3\1x�Ԥ9���� �{��)d���OvV��<_W �'O[M��;K�4g��p�����p���S:�r��|��w-;�Zz����ըz?��9�Y���8��u1������Bv4�C8���Z=.�'r�v����؄z�(P���<nv�fId퇁�F�n5&	�{چs[s���˷�����qDǋ���������p� ���|k84���%6�2[*�߹����A��:="Ur�K6;x���h��.�����s��Jf���|���;��-��ိ�Cm̆S��/�"���)���Z"�[tJla5.ken7��}1�~e���|�]��ue���'�|�"�/B�u:���g�$�E��x�rǹ��疤�%�Σ�{y.A��1���u�/α��jw���.��*�,��P��������sy?�ʬ%��R0 -�u��Y������
�qj+�2Pݞ>��y�V�I�Ϸ�𜈿W�����%�������6��       v   c  x�U�ɑ�0D�v0.��\&�8�����h	�q\D8/z`^0n�h,�E�$���P��Jf��YD���d���A�4���l1}uQk��`s���e	�[o����0�z3�̺Hڕ���J�$�q� M|�N��h����f��(;E�!��N,6/f��d�-,p��4��z��Ӌ��۰��� ��wܕq"�s�a,&ܨ�@�@:���Ⱥv]�#e)��d�،�O]�NIq�'������V:���ې�<	pk�9!f3c����`��]Cc��\|�2g>}'�������t���Cr����W��kW��]����BWVܪ_�]#������=��      j   #   x�3256�L+O�2256�43L�8���=... w��      f      x���4�L+��+�����  �      x   �  x���[�� D��b\�{��_�m�����3_N�S�^4��k�:�l���Z�Ň!����B�ڋA��IR�$m�v!����7ǗJ�;��Hhu�&�BLE�%�R:��W�4Z��������Taj��Z����%H�)Ɉ�2�jQ#H*�YSI�$G1�>�(�D��z�����/�A��G�/��"�5��ķ�����_�!4�A��(R(!b��Ǡ��;��2�D]Ѯwѵ;#6r�q"�I��$E�]00{E�+Fm�I!��	q��P�^��AtGi���}��)��T#y5�=TԂ�:I ����G?�o|A��c˅�g��j�G��Wt/��G�����O��{��g*�O��Q�$�7��z�_Dw���~��!�Yj4�T>�3P��t9��M}����8M���}��~s����c:Z
�!YL���x�la���C�p�4#{T򉴓�c���5��q-$~�!y'�ٳ湻a0N�Ъ��^%�4"�NO�T�E��rX�Oc�+�7Mw�.M�Nj� s�c�F1'�'.�ߧc���%�۫�Δj��f4=1F�a	�16�Zib8B�˃��&ᪿx�=P��\P�)G��1Ey�qn��b��6�������)8���V.N�忿XV2^k� \_AW��x��a
��X���|,&m�o{�^����      h   1   x�3646���H�2646��R�F�)`#s�L����������� .��      p   =   x�3164��-H��2162�4JJ����8s�BƖ��`!##������%gq����� ���      z   @   x�=���@�w\��@����"�<G���X���lf,&7�|y�(�Eg��X������      n   "   x�34�4�LO,�2452�L�L-N������ U      d   0   x�366��L�/-�2666�L�,K��9�3+@KΒ���T�=...       b   %   x�3215�L�/-�221��,)�2��9��b���� w��     