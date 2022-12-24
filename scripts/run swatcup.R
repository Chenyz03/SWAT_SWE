###Yuzhuang Chen (yuzhuang@ualberta.ca)

##Note: This is a simple calibration framework that shows how to remove unrealistic snow parameter combinations 
## during running swatcup projects.

##Note: The original version that supports the parallel processing of this study is available on 
##request from co-author, Dr. Monireh Faramarzi at faramarz@ualberta.ca


##load library (make sure the libraries were installed before load them)
library(tidyverse)
library(gdata)

rm(list=ls())  # removes all objects from the environment
cat("\014")    # clears the console


###1. Set directories and original simulation number---------------
##Before starting the code, make sure your swatcup project is ready to start.

#user defined
wd="D:/your_swatcup_dir/"     #swat-cup projects dir 
prj_name="example.Sufi2.SwatCup"    #project name   
iter=200   #maximum number of folders created for your "Iterations" folder
 
  
#Define working directories
prj_wd=paste(wd,prj_name,sep="")
sufi2_in=paste(prj_wd,"/SUFI2.IN",sep="")
sufi2_out=paste(prj_wd,"/SUFI2.OUT",sep="")
  

#set original simulation number
sim_num=1000    #user defined

#modify par.inf to set original simulation number 
new_str<-paste0(sim_num,"  : number of simulations")
file<- paste(prj_wd,"/SUFI2.IN/par_inf.txt",sep="") 
lines <- readLines(file)
lines[2]=new_str  #replace 2th line with new string
writeLines(lines,file)  # write into txt file


###2. Generate and remove unreasonable par sets---------------------

## generate par sets
#SUFI2_LH_sample (SUFI2_Pre.bat)   
setwd(prj_wd)
shell("echo Y | SUFI2_LH_sample", intern=TRUE) 

##remove unreasonable par sets
#Import data
setwd(prj_wd)
par_val <- read.table("SUFI2.IN/par_val.txt", sep = "" , header = FALSE , 
                      skip=0,na.strings ="",check.names = FALSE)

#SMFMX>SMFMN (Please check the orders of these two parameters!!!)
par_val2<-par_val %>% 
  dplyr::filter(par_val$V4>par_val$V5) ##modify the code if SMFMX and SMFMN are not 3rd and 4th calibrated pars 

str <- read.table("SUFI2.IN/str.txt", sep = "" , header = FALSE , 
                  skip=0,na.strings ="",check.names = FALSE)
#row index 
index<-par_val2$V1

#extract str
str2<-str[index,]

#reorder ID
par_val2$V1<-seq(1:length(par_val2$V1))
str2$V1<-seq(1:length(par_val2$V1))

#write new par sets to txt file
n=ncol(str2)-1
col=c(5,rep(12,n))
write.fwf(par_val2, "SUFI2.IN/par_val.txt",colnames = FALSE,
          sep = "", width = col)
write.fwf(str2, "SUFI2.IN/str.txt",colnames = FALSE, sep = "", width = col)


##modify par.inf to set new simulation number
sim_num<-max(par_val2$V1)   #new simulation number
new_str<-paste0(sim_num,"  : number of simulations")
file<- paste(sufi2_in,"/par_inf.txt",sep="") 
lines <- readLines(file)
lines[2]=new_str  #replace 2th line with new string
writeLines(lines,file)  # write into txt file

##change SUFI2_swEdit.def simulation number
new_str<-paste0(sim_num,"      : ending simulation number")
file<- paste(prj_wd,"/SUFI2_swEdit.def",sep="") 
lines <- readLines(file)
lines[2]=new_str  #replace 2th line with new string
writeLines(lines,file)  # write into txt file



###3. Create iteration folder for saving swatcup project results--------------

#create iteration folder 
  setwd(prj_wd)
  if (file.exists("Iterations")==FALSE) {dir.create("Iterations")}
  setwd("Iterations")
  iter_folder=1
    for (iter_folder in 1:iter)
    if (file.exists(toString(iter_folder))==FALSE) {break}
  dir.create(toString(iter_folder))
  setwd(toString(iter_folder))
  dir.create("SUFI2.IN")
  dir.create("SUFI2.OUT")
  
  setwd("SUFI2.IN")
  sufi2_in_iter=getwd()

  setwd(dirname(getwd()))
  setwd("SUFI2.OUT")
  sufi2_out_iter=getwd()
  
#copy "SUFI2.IN" files into a iteration folder
  sufi2_in_list=list.files(sufi2_in)
  setwd(sufi2_in)
  file.copy(sufi2_in_list,sufi2_in_iter)

  
###4. Run swatcup SUFI2_Run.bat and SUFI2_Post.bat----------------------
  
#remove files from SUFI2.OUT before run swat
  sufi2_out_list=list.files(sufi2_out,include.dirs = F, full.names = T, recursive = )
  file.remove(sufi2_out_list)
  
#run SUFI2_Run.bat
  setwd(wd)
  system("master.bat")  #put master.bat in wd
  
#SUFI2_goal_fn, SUFI2_95ppu and SUFI2_new_pars (SUFI2_Post.bat)
  setwd(prj_wd)
  system("SUFI2_goal_fn")
  system("SUFI2_95ppu")
  system("SUFI2_new_pars")
  

#copy SUFI2.OUT files to Iteration folder
  sufi2_out_list=list.files(sufi2_out)
  setwd(sufi2_out)
  file.copy(sufi2_out_list,sufi2_out_iter)
  
  
  