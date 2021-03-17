CREATE TRIGGER auto_insert_abranch
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_branch();
-----------------------

CREATE TRIGGER auto_insert_bbody
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_temp_body();
-------------------------

CREATE TRIGGER auto_insert_ccylinders
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_temp_cylinders();
-----------------------

CREATE TRIGGER auto_insert_dengine
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_temp_engine();
---------------------------

CREATE TRIGGER auto_insert_efuel
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_temp_fuel();
-------------------------

CREATE TRIGGER auto_insert_fcar
AFTER INSERT 
ON car
FOR EACH ROW
	EXECUTE PROCEDURE insert_temp_car();
	

