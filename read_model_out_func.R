modelout <- function(str.file="model.out"){
# reads the model.out from PEST. Ther format of model.out is for the comparison 
# of the hydrology for oringial and updated WDM files for Big Elk Creek. 
# Function created by Kevin Brannan (2015-09-09)

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

# put model.out character vector and df.info together as a list
  ls.out <- list(str.out=str.out,df.info=df.info)

# done
  return(ls.out)
}