library("tidyverse")
library("readxl")
library("tidylog")
rm(list=ls())
setwd("C:\\Users\\B059633\\Dropbox\\Work\\Research\\Projects\\Gender Econ\\Survey Experiment\\Survey for RR")

# Read varnames
df_names<-as.character(read_excel("Data\\Voices_Expert_NoInstitution_20240919 RR_20 September 2024_10.51.xlsx", n_max=1, col_names = FALSE))

# Read data
df<-read_excel("Data\\Voices_Expert_NoInstitution_20240919 RR_20 September 2024_10.51.xlsx", skip=2,col_names = df_names)

# Make long
df<-pivot_longer(df,cols=starts_with("Q"))%>%
    filter(!is.na(value))%>%
     mutate(Q=parse_number(name),
     Expert=substr(name,str_locate(name,as.character(Q))[2]+1,(str_locate(name,"_"))[,1]-1),
     Expert = str_remove_all(Expert, "[X.]|[:digit:]"),
     Expert=ifelse(Expert=="Golderberg","Goldberg",Expert),
     FemaleExpert=ifelse(Expert%in%c("Baicker","Bertrand","Finkelstein","Goldberg","Hoxby","Hoynes","Chevalier"),1,0))

library("haven")
library("janitor")
df<-df %>%
  clean_names()
write_dta(df,"RR_surveyexperimentdata_long.dta")






