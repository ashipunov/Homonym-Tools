source("homonyms.r")

upload <- read.table("../tmp/upload.tmp", sep="", h=FALSE, as.is=TRUE, strip.white=TRUE, encoding="Latin-1")

if (ncol(upload) == 1)
   {
   upload.1 <- data.frame(datasetID="upload",
           taxonID=paste("tmp", 1:nrow(upload), sep=""), scientificName=toupper(upload$V1), kingdom=NA,
           LocalHomonymFlag=NA)
   }

if (ncol(upload) >= 2)
   {
   upload.1 <- data.frame(datasetID="upload",
           taxonID=upload$V1, scientificName=toupper(upload$V2), kingdom=NA,
           LocalHomonymFlag=NA)
   }

all <- rbind(all, upload.1)

sources <- scan(file="../tmp/upload_selected.tmp", what="character", quiet=TRUE)
hm <- Hsub("upload", sources, all$datasetID, all$scientificName)
column.name <- paste(hm$sublist, "vs", paste(hm$against, collapse="_"), sep="_")
res <- data.frame(all[all$datasetID %in% hm$sublist,], hm$external, InternalHomonymFlag=hm$internal)
names(res)[6] <- tolower(column.name)

# textual output
file.name <- "../tmp/upload_output.tmp"
write.table(res, file=file.name, quote=FALSE, col.names=TRUE, row.names=FALSE)
