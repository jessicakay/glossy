# jessdkant.bsky.social
from shlex import join
import pandas as pd
from pathlib import Path
import tkinter as tk
from tkinter import filedialog
import time
from pandas.core.dtypes.common import infer_dtype_from_object

root = tk.Tk()
root.withdraw()

pathy = filedialog.askopenfilename()
df = pd.read_csv( pathy, header=0, skipinitialspace=True, sep=",")

df['time_start']=df['start'].str[0:8]
df['hour']=pd.to_datetime(df['time_start'],format='%H:%M:%S').dt.hour
df['minute']=pd.to_datetime(df['time_start'],format='%H:%M:%S').dt.minute

df_new=df[['minute','hour','start','end','text']]
print(df_new.head())
outJSON=Path(pathy).stem+'.json'
print("\nsaving to "+outJSON+"...\n")
by_minute=df_new.groupby(['minute','hour'], as_index=False).agg({'text': lambda x: ' '.join(x) })
by_minute.to_json(outJSON,orient='records', indent=4)

pd.set_option('display.max_columns', None, 'display.max_colwidth', 100, 'display.max_rows', None)

# print("\n".join(by_minute['text'].str.wrap(width=80)))
first_line=by_minute.iloc[min(by_minute.index)]
print("\nstart: \n\n",first_line['text'])
last_line=by_minute.iloc[max(by_minute.index)]
print("\nend: \n\n",last_line['text'])