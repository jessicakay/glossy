
setwd("~/glossy/transcripts/Cali/2024/")

file_names <- as.vector(list.files("~/glossy/transcripts/Cali/2024/","vtt") )

data.frame(file_names,date_string=strtrim(file_names,8))-> transcript_index


#### ------------------------------------------------------------------ ###

list.files("~/glossy/transcripts/Cali/2024/",".csv") -> transcripts
setwd("~/glossy/transcripts/Cali/2024/")

master_sheet<-as.data.frame(NULL)
for(i in 1:length(transcripts)){
  rbind(master_sheet, read.csv(transcripts[i],header = F))->> master_sheet
}

colnames(master_sheet)[1]<-"month_year"
names(master_sheet)

head(master_sheet,n=1)

