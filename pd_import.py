import pandas as pd
import numpy as np
import os
import sqlite3
import glob

s = pd.read_csv("./g1874.txt")
s.str.slice(start=1, stop=5)

"""
 df$Year(df$V1,1,4)
rgoB$Month <-substr(df$V1,5,6)
rgoB$Day <-substrdf$V1,7,8)
rgoB$Time <-substr(df$V1,9,12)
rgoB$cwsa <-substr(rgoB$V1,41,44)
rgoB$cld <-substr(rgoB$V1,58,62)
rgoB$lns <-substr(rgoB$V1,64,68)
df.describe()

connection = sqlite3.connect("RGO1.sqlite3")
df.to_sql('df',connection)
db = pd.read_sql("select * from df limit 5;",connection)
 """
 