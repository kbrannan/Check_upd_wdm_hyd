modelout <- function(str.file="model.out"){
# reads the model.out from PEST. Ther format of model.out
# is for the comparison of the hydrology for oringial 
# and updated WDM files for Big Elk Creek
# created Kevin Brannan (2015-09-09)

# remove this for development only
  str.file <- paste0(getwd(),"/model/model_org.out")

# read model.out into character vector
  str.out <- scan(file=str.file,what="character",sep="\n")

# get row numbers that have data element names
  num.names <- c(grep(paste0("---",">"),str.out),length(str.out))

# create function to get data element name from row in model.out file
  get.name <- function(str.names) strsplit(str.names,'"',fixed=TRUE)[[1]][2]

# extract the names for the data elements
  str.names <- do.call(rbind,lapply(str.out[num.names],get.name))
  str.names[length(str.names)] <- "end"

# get type of data element
  str.types <- gsub('(".*$)|( )',"",str.out[num.names])
  str.types[length(str.types)] <- "end"

# create data.frame with model.out data info
  df.info <- data.frame(type=str.types,name=str.names,row=num.names)
}

ii <- 22
# TIME_SERIES
if(df.info$type[ii] == "TIME_SERIES") {
  tmp.data <- data.frame(name=df.info$name[ii],type=df.info$type[ii],
                         value=str.out[(df.info$row[ii]+1):(df.info$row[ii+1]-1)],
                         id=((df.info$row[ii]+1):(df.info$row[ii+1]-1))
  )  
}

# S_TABLE
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
ii <- 25
# V_TABLE
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

ii <- 26
# E_TABLE
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



