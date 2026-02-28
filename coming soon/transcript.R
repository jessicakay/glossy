
# setwd("~/glossy/transcripts/Cali/2024/")

file_names <- as.vector(list.files("~/glossy/transcripts/Cali/2024/","vtt"))

data.frame(file_names,date_string=strtrim(file_names,8))-> transcript_index


transcript_index %>% 
  mutate(year_hearing=substring(date_string,1,4)) %>%
  mutate(day_recorded=substring(date_string,5,6)) %>%
  mutate(month_recorded=substring(date_string,7,8)) %>%
  mutate(hearing_date=as.Date(paste(month_recorded,day_recorded,year_hearing,sep="/"),form="%d/%m/%Y")) %>%
  mutate(committee=gsub(str_extract(file_names,"(?<=_)[0-9]?[a-zA-Z_]+"),pattern="_",replacement = " "))%>%
  mutate(week=lubridate::week(hearing_date)) %>%
  mutate(day_recorded=day(hearing_date)) %>%
  mutate(month=month(hearing_date,label = T)) %>%
  select(hearing_date,file_names,committee,month,day_recorded,year_hearing)  -> transcript_index

transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Jt|JT|jt","Joint")) -> transcript_index
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Fi ?$","Finance")) -> transcript_index
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Ag ?$","Agriculture")) -> transcript_index

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

