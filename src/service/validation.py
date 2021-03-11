from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
import pandas as pd
import numpy as np
import json
import re

class Validation:
    def __init__(self):
        super().__init__()
    def check_price(self, dataFrame):
        # remove "?", "free"
        df_n1 = pd.DataFrame(dataFrame.loc[dataFrame['Price'].str.isnumeric() == False])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['Price'].str.isnumeric() == False].index, inplace=True))
        # remove data null 
        df_n2 = pd.DataFrame(dataFrame.loc[dataFrame['Price'].isna()])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['Price'].isna()].index, inplace=True))
        # noi 2 bang da remove
        df_null = pd.concat([df_n1,df_n2])
        return df_null, dataFrame
    def check_length(self, dataFrame):
        # remove gia tri co do dai >5
        length_native = pd.DataFrame(dataFrame.loc[dataFrame['Drive-wheels'].str.len() > 5])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['Drive-wheels'].str.len() > 5].index, inplace=True))
        return length_native, dataFrame

    def check_dtype(self, dataFrame):
        data = ['Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke', 'Price']
        for i in data:
            if (dataFrame[i].dtypes != np.int64):
                dataFrame.drop(i, axis = 1, inplace=True)
                # print(dataFrame.columns)
            else: 
                print('no')
        return dataFrame
    def check_dup(self, dataFrame):
        dup = dataFrame[dataFrame.duplicated()]
        print(dup)
        dataFrame.drop_duplicates( inplace=True)
        return dup, dataFrame
    def re_name(self,dataFrame):
        name = dataFrame.rename(columns = {
            "No" : "id",
            "Symboling" : "symboling",
            "Normalized-losses" : "normalized_losses",
            "Make" : "make",
            "Fuel-type" : "fuel_type",
            "Aspiration" : "aspiration",
            "Num-of-doors" : "num_of_doors",
            "Body-style" : "body_style",
            "Drive-wheels" : "drive_wheels",
            "Engine-location" : "engine_location",
            "Wheel-base" : "wheel_base",
            "Length" : "length",
            "Width" : "width",
            "Height" : "height",
            "Curb-weight" : "curb_weight",
            "Engine-type" : "engine_type",
            "Num-of-cylinders" : "num_of_cylinders",
            "Engine-size" : "engine_size",
            "Fuel-system" : "fuel_system",
            "Bore" : "bore",
            "Stroke" : "stroke",
            "Compression-ratio" : "compression_ratio",
            "Horsepower" : "horsepower",
            "peak-rpm" : "peak_rpm",
            "city-mpg" : "city_mpg",
            "highway-mpg" : "highway_mpg",
            "Price" : "price"
            }, inplace = True)
        return str(dataFrame.columns)
    def day_update(self,dataFrame):
        t = []
        for s in dataFrame['Load-date']:
            new_str = re.sub('/\d*/','/01/',s)
            t.append(new_str)
        tb = pd.DataFrame(t)
        dataFrame['load_date'] = tb
        new_df = dataFrame.drop('Load-date', axis = 1)
        return new_df

    def check_int(self, dataFrame):
        dataFrame['check'] = 0
        s = ['Normalized-losses', 'Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke','Horsepower', 'peak-rpm','Price']
        for i in s:
            dataFrame[i] = dataFrame[i].astype(str)
        for j in range(0,len(dataFrame.index)):
            if ((re.match("^\d+?\.\d+?$", dataFrame['Normalized-losses'][j]) or (dataFrame['Normalized-losses'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Height'][j]) or (dataFrame['Height'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Width'][j]) or (dataFrame['Width'][j].isnumeric() == True)) and 
                (re.match("^\d+?\.\d+?$", dataFrame['Length'][j]) or (dataFrame['Length'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Engine-size'][j]) or (dataFrame['Engine-size'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Bore'][j]) or (dataFrame['Bore'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Stroke'][j]) or (dataFrame['Stroke'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Horsepower'][j]) or (dataFrame['Horsepower'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['Price'][j]) or (dataFrame['Price'][j].isnumeric() == True)) and
                (re.match("^\d+?\.\d+?$", dataFrame['peak-rpm'][j]) or (dataFrame['peak-rpm'][j].isnumeric() == True))):
                dataFrame.at[j,'check'] = 1
        n1 = pd.DataFrame(dataFrame.loc[dataFrame['check'] == 0])
        new_n1 = n1.drop('check', axis = 1)
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['check'] == 0].index, inplace=True))
        dataFrame = dataFrame.drop('check', axis = 1)
        m = ['Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke','Horsepower', 'peak-rpm']
        for i in m:
            dataFrame[i] = dataFrame[i].astype(float)
        dataFrame['Normalized-losses'] = dataFrame['Normalized-losses'].astype(int)
        dataFrame['Price'] = dataFrame['Price'].astype(int)
        return new_n1, dataFrame