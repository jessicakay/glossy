# jessdkant.bsky.social

import csv
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

import csv
import webvtt

num_file=0
for file in os.listdir() :
    if file.endswith(".vtt") :
        num_file=num_file+1
        print("processing "+str(num_file)+": "+(file)+"...")
        temp=webvtt.read(file)
        cap_text=[]
        transcript_line = []
        paranum=0
        for caption in temp:
            cap_text.append(caption.raw_text)
            outname = ''.join([file.removesuffix(".vtt"),".txt"])
            if Path(outname).exists():
                file_year = str(file)[0:4]
                file_month = str(file)[5:6]
                file_day = str(file)[7:8]
                file_date = str(''.join([file_month, file_day, file_year]))
                with open(outname, "a") as f:
                   f.write((caption.raw_text).lower()+" ")
                   if paranum<20 :
                       paranum=paranum+1
                       transcript_line.append(caption.raw_text)
                   else :
                       with open(''.join([file.removesuffix(".vtt"), ".csv"]), "a", newline='') as csvfile:
                           csveet = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL,
                                               dialect='unix')
                           csveet.writerow([file_date, file_month, file_day, file_year,
                                            caption.start, caption.end,
                                            str(' '.join(transcript_line)).lower()])
                       f.write('\n'+str(caption.start)+'\n\n')
                       paranum=0
                       transcript_line=[]
                   f.close()
            else:
                with open(outname, "w") as f:
                    f.write("============== transcript generated from "+file+"==============\n\n")
                    f.close()
        print("\n ~ read " + str(len(cap_text)) + " lines\n")
