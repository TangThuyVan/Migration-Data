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
    
    def check_length(self, dataFrame, column_name):
        length_native = pd.DataFrame(dataFrame.loc[dataFrame[column_name].str.len() > 5])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame[column_name].str.len() > 5].index, inplace=True))
        return length_native, dataFrame

    def check_dup(self, dataFrame):
        dup = dataFrame[dataFrame.duplicated()]
        print(dup)
        dataFrame.drop_duplicates( inplace=True)
        return dup, dataFrame
   
    def day_update(self,dataFrame):
        t = []
        for s in dataFrame['Load-date']:
            new_str = re.sub('/\d*/','/01/',s)
            t.append(new_str)
        tb = pd.DataFrame(t)
        dataFrame['load_date'] = tb
        new_df = dataFrame.drop('Load-date', axis = 1)
        return new_df

    def check_value(self, dataFrame, columns_name):
        dataFrame['check'] = 0
        for i in columns_name:
            dataFrame[i] = dataFrame[i].astype(str)
        p = "^\d+?\.\d+?$"
        for i in range(0, len(dataFrame.index)):
            t = 0
            for j in columns_name:
                if ((re.match(p, dataFrame[j][i]) or (dataFrame[j][i].isnumeric() == True))):
                    t += 1
            if t == len(columns_name):
                dataFrame.at[i,'check'] = 1
        n1 = pd.DataFrame(dataFrame.loc[dataFrame['check'] == 0])
        new_n1 = n1.drop('check', axis = 1)
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['check'] == 0].index, inplace=True))
        dataFrame = dataFrame.drop('check', axis = 1)
        return new_n1, dataFrame

    def re_name(self,dataFrame, columns_name):
        return dataFrame.rename(columns = columns_name)

    def change_type_float(self,dataFrame, columns_name):
        for i in columns_name:
            dataFrame[i] = dataFrame[i].astype(float)
        return dataFrame

    def change_type_int(self,dataFrame, columns_name):
        for i in columns_name:
            dataFrame[i] = dataFrame[i].astype(int)
        return dataFrame