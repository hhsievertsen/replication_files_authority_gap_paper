library("tidyverse")
library("readxl")
library("tidylog")
rm(list=ls())
setwd("C:/Users/B059633/Dropbox/Work/Research/Projects/Gender Econ/Survey Experiment/drafts/JEBO/RR2/Replication package")
# Read varnames
df_names<-as.character(read_excel("rawdata/Voices_Expert_Prolific_12 July 2023_18.56.xlsx", n_max=1, col_names = FALSE)
)

# Read data
df<-read_excel("rawdata/Voices_Expert_Prolific_12 July 2023_18.56.xlsx", skip=2,col_names = df_names)%>%
                       rename(`Q3Maskin_Response`=`Q3Hoxby_Response...51`,
                              `Q3Hoxby_Response`=`Q3Hoxby_Response...50`,
                              CheckQuestion=Q83)

# Make long
df<-pivot_longer(df,cols=starts_with("Q"))%>%
    filter(!is.na(value))%>%
     mutate(name=ifelse(name=="Q1AltonjiResponse","Q1Altonji_Response",name), # Clean Typos
     Q=parse_number(name),
     Expert=substr(name,str_locate(name,as.character(Q))[2]+1,(str_locate(name,"_"))[,1]-1),
     Expert = str_remove_all(Expert, "[X.]|[:digit:]"),
     Expert=ifelse(Expert=="Golderberg","Goldberg",Expert),  # Clean Typos
     FemaleExpert=ifelse(Expert%in%c("Baicker","Bertrand","Finkelstein","Goldberg","Hoxby","Hoynes","Chevalier"),1,0))

library("haven")
library("janitor")
df<-df %>%
  clean_names()
write_dta(df,"temporarydata/cleaned_data_survey_1.dta")