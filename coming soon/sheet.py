# jessdkant.bsky.social

import pandas as pd
from pathlib import Path
import tkinter as tk
from tkinter import filedialog

root = tk.Tk()
root.withdraw()

pathy = filedialog.askopenfilename()
df = pd.read_csv(
    pathy,
    header=0,
    skipinitialspace=True,
    sep=",")

df['hour']=df['start'].str[:2]
df['minute']=df['start'].str[4:5]

df_new=df[['hour','minute','start','end','text']]
print(df_new.head())
# dfJSON=df_new.to_json(orient='records')

outJSON=Path(pathy).stem+'.json'
df_json=df_new.to_json(outJSON,orient='records', indent=4)

# df_joined=df_new.to_json().join(['hour','minute'])
print("\n\nattempting to group...\n\n")
print(df_json)

print(df_new.groupby(['minute','hour']).agg({'text': list}))