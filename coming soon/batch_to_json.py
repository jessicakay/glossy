# jessdkant.bsky.social
import os
import pathlib
from shlex import join
from traceback import print_tb

import pandas as pd
import tkinter as tk
from tkinter import filedialog
from pandas.core.dtypes.common import infer_dtype_from_object

root = tk.Tk()
root.withdraw()

from pathlib import Path

print("\ncurrent working directory: "+pathlib.Path.cwd()._str+"\n")
change_choice=input("continue with "+pathlib.Path.cwd().name+" [return] or switch [s]: ")
if change_choice=="s":
    pathy = filedialog.askdirectory()
    os.chdir(pathy)
    print("\n\ndirectory changed to "+os.getcwd()+"\n")
else   :
    print("\nusing current directory"+os.getcwd()+"\n")
    pathy = pathlib.Path.cwd()

print("\ncontains: "+str(len(os.listdir()))+" files\n")

vtt_count=0
for file in os.listdir() :
    if file.endswith(".vtt") :
        vtt_count=vtt_count+1
        if vtt_count<6 :
            print(str(vtt_count)+". "+file)
if vtt_count>5 :
    print("\n(truncated)... "+str(vtt_count)+" WebVTT files total\n")

for file in os.listdir() :
    if file.endswith(".vtt") :

        df = pd.read_csv(pathlib.Path(file).absolute(), header=0, skipinitialspace=True, sep=",")

        print(df.head())