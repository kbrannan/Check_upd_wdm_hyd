modelout_table <- function(ii,lst.in) {
# Extracts data from the model.out file format from PEST and returns a 
# data.frame with name of the data element type of data and an id for the each. 
# This function uses output from the modelout function (df.info) and the 
# charater vector of the model.out file (str.out) read in using the the 
# general.R script. There are four table types: TIME_SERIES, S_TABLE, V_TABLE 
# and E_TABLE. Refer to tsproc documentation for PEST"s Surface Water Utilities 
# for the descriptions of these table types.The specific format of model.out is 
# for the comparison of the hydrology for oringial and updated WDM files for 
# Big Elk Creek. Function created by Kevin Brannan (2015-09-10)

# get charactervecot of model.out and info data.frame from input list
  str.out <- lst.in$str.out
  df.info <- lst.in$df.info

  paste0("ii = ",ii)
  
  
# extract from a TIME_SERIES type
  if(df.info$type[ii] == "TIME_SERIES") {
    tmp.data <- data.frame(name=df.info$name[ii],type=df.info$type[ii],
                           value=str.out[(df.info$row[ii]+1):(df.info$row[ii+1]-1)],
                           id=((df.info$row[ii]+1):(df.info$row[ii+1]-1))
    )  
  }
  
# extract from S_TABLE type
  if(df.info$type[ii] == "S_TABLE") {
    tmp.value <- do.call(c,strsplit(
      gsub(" ","",str.out[(df.info$row[ii+1]-1)]),
      split=":")
    )
    tmp.data <- data.frame(name=df.info$name[ii],type=df.info$type[ii],
                           value=tmp.value[2],
                           id=(df.info$row[ii+1]-2)
    ) 
  }

# extract from V_TABLE type
  if(df.info$type[ii] == "V_TABLE") {
    
    tmp.value <- do.call(rbind,strsplit(str.out[(df.info$row[ii]+2):(df.info$row[ii+1]-1)],
                                        split="=")
    )
    tmp.value[,1] <- gsub("(^\\s+)|(\\s+volume.*$)","",tmp.value[,1])
    tmp.data <- data.frame(name=df.info$name[ii],type=df.info$type[ii],
                           value=tmp.value[,2],
                           id=tmp.value[,1]
    ) 
  }

# extract from E_TABLE type
  if(df.info$type[ii] == "E_TABLE") {
    tmp.cols <- do.call(c,strsplit(str.out[(df.info$row[ii]+1)],split="\\s{3,}"))[-1]
    tmp.value <- do.call(rbind,strsplit(str.out[(df.info$row[ii]+2):(df.info$row[ii+1]-1)],
                                        split="\\s+")
    )[,-1]
    jj<-1
    tmp.id<-paste0(paste0(tmp.cols[1],"=",tmp.value[jj,1]),"-",tmp.cols[2:length(tmp.cols)])
    tmp.data <- data.frame(name=df.info$name[ii],type=df.info$type[ii],
                           value=tmp.value[jj,2:length(tmp.value[jj,])],
                           id=tmp.id) 
    for(jj in 2:length(tmp.value[,1])) {
      tmp.id<-paste0(paste0(tmp.cols[1],"=",tmp.value[jj,1]),"-",tmp.cols[2:length(tmp.cols)])
      tmp.data <- rbind(tmp.data,data.frame(name=df.info$name[ii],type=df.info$type[ii],
                                            value=tmp.value[jj,2:length(tmp.value[jj,])],
                                            id=tmp.id))
    }
  }
# convert value from character to numeric
  tmp.data$value <- as.numeric(tmp.data$value)
# done
  return(tmp.data)
}
