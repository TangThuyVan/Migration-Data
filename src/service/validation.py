from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
import pandas as pd
import numpy as np
import json

class Validation:
    def __init__(self):
        super().__init__()
    def check_price(self, dataFrame):
        price_null = pd.DataFrame(dataFrame.loc[dataFrame['Price'] == '?'])
        return price_null.to_json()
    def check_length(self, dataFrame):
        length = pd.DataFrame(dataFrame.loc[dataFrame['Drive-wheels'].str.len() > 5])
        return length.to_json()
    def check_dtype(self, dataFrame):
        data = ['Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke', 'Price']
        for i in range(0,len(data)-1):
            if (dataFrame[data[i]].dtypes == np.dtype(int)):
                df = dataFrame.drop(data[i], axis = 1, inplace=True)
                return df.to_json()
            else: 
                return 'no'
    def check_dup(self, dataFrame):
        dup = dataFrame.duplicated()
        return dup.to_json()
    def re_name(self,dataFrame):
        dataFrame.rename(columns = {"Fuel-type":"type","Num-of-cylinders":"Num_cylinders"}, inplace = True)
        return dataFrame.columns