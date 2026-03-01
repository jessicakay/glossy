
# setwd("~/glossy/transcripts/Cali/2024/")

file_names <- as.vector(list.files("~/glossy/transcripts/Cali/2024/csv/","csv"))

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
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Budget Sub|BudgetSub|Budgetsub","Budget")) -> transcript_index


table(transcript_index$committee,transcript_index$month) |> View()

#### ------------------------------------------------------------------ ###

list.files("~/glossy/transcripts/Cali/2023/csv/",".csv") -> transcripts
setwd("~/glossy/transcripts/Cali/2023/csv")

master_sheet<-as.data.frame(NULL)
filenames <-as.data.frame(NULL)
for(i in 1:length(transcripts)){
  rbind(master_sheet, read.csv(transcripts[i],header = F))->> master_sheet
}


colnames(master_sheet)[1]<-"filename"
colnames(master_sheet)[2]<-"date_string"
colnames(master_sheet)[4]<-"year"
colnames(master_sheet)[5]<-"timestamp_start"
colnames(master_sheet)[6]<-"timestamp_end"
colnames(master_sheet)[7]<-"text"


master_sheet %>% 
  select(filename,date_string,year,timestamp_start,timestamp_end,text) %>%
  mutate(year_hearing=substring(date_string,1,4)) %>%
  mutate(day_recorded=substring(date_string,5,6)) %>%
  mutate(month_recorded=substring(date_string,7,8)) %>%
  mutate(hearing_date=as.Date(paste(month_recorded,day_recorded,year_hearing,sep="/"),form="%d/%m/%Y")) %>%
  mutate(committee=gsub(str_extract(filename,"(?<=_)[0-9]?[a-zA-Z_]+"),pattern="_",replacement = " "))%>%
  mutate(week=lubridate::week(hearing_date)) %>%
  mutate(day_recorded=day(hearing_date)) %>%
  mutate(month=month(hearing_date,label = T)) %>%
  mutate(dayofweek=weekdays(hearing_date)) %>%
  select(hearing_date,filename,text,committee,dayofweek,day_recorded,month,year_hearing,timestamp_start,timestamp_end)  -> transcript_index


transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Jt|JT|jt","Joint")) -> transcript_index
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Fi ?$","Finance")) -> transcript_index
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Ag ?$","Agriculture")) -> transcript_index
transcript_index %>% mutate(committee=str_replace(transcript_index$committee,"Budget Sub|BudgetSub|Budgetsub","Budget")) -> transcript_index

transcript_index %>% View()

transcript_index -> transcript_index_2025

Cali_2023_to_2025 %>% 
  mutate(term_trans=str_detect(text,"transgender")) %>%
  mutate(term_gender=str_detect(text,"gender identity")) %>%
  mutate(term_pblocker=str_detect(text,"puberty blocker")) %>%
  mutate(term_biosex=str_detect(text,"biological sex")) %>%
  mutate(term_genderid=str_detect(text,"gender ideology")) %>%
  mutate(term_woke=str_detect(text,"woke")) %>%
  mutate(term_hormones=str_detect(text,"hormones")) %>%
  
  mutate(keyword=case_when(
    term_trans==TRUE ~ "transgender",
    term_biosex==TRUE ~ "biological sex",
    term_genderid==TRUE ~ "gender ideology",
    term_pblocker==TRUE ~ "puberty blocker",
    term_gender==TRUE ~ "gender identity",
    term_woke==TRUE ~ "woke",
    term_hormones==TRUE ~ "hormones"
  ))%>%
  select(keyword,year_hearing) %>% table()


#   select(year_hearing,starts_with("term_"),keyword)
# filter((term_trans|term_pblocker|term_biosex|term_gender)==TRUE) %>%