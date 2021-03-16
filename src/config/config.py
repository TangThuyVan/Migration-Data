import datetime
import os

x = datetime.datetime.now()
a = x.strftime("%B") +" "+ str(x.day) +" "+ str(x.year)

def check_folder(name_folder):
    list_folder = os.listdir()
    return name_folder in list_folder

os.chdir('C:/Users/Administrator/Desktop/task1/Migration-Data/src/')

if check_folder(a) == False:
    os.mkdir(a)

HOST = "localhost"
USER = "postgres"
PASSWORD = "vantang123"
DATABASE = "Car"
bad_table = 'C:/Users/Administrator/Desktop/task1/Migration-Data/src/'+ a +'/car_sample_data_bad.csv'
native_table = 'C:/Users/Administrator/Desktop/task1/Migration-Data/src/'+ a +'/car_sample_data_native.csv'
