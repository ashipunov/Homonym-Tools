source("homonyms.r")

textbox <- read.table("../tmp/textbox.tmp", sep="", h=FALSE, as.is=TRUE, strip.white=TRUE, encoding="Latin-1")

if (ncol(textbox) == 1)
   {
   textbox.1 <- data.frame(datasetID="textbox",
           taxonID=paste("tmp", 1:nrow(textbox), sep=""), scientificName=toupper(textbox$V1), kingdom=NA,
           LocalHomonymFlag=NA)
   }

if (ncol(textbox) >= 2)
   {
   textbox.1 <- data.frame(datasetID="textbox",
           taxonID=textbox$V1, scientificName=toupper(textbox$V2), kingdom=NA,
           LocalHomonymFlag=NA)
   }

all <- rbind(all, textbox.1)

sources <- scan(file="../tmp/textbox_selected.tmp", what="character", quiet=TRUE)
hm <- Hsub("textbox", sources, all$datasetID, all$scientificName)
column.name <- paste(hm$sublist, "vs", paste(hm$against, collapse="_"), sep="_")
res <- data.frame(all[all$datasetID %in% hm$sublist,], hm$external, InternalHomonymFlag=hm$internal)
names(res)[6] <- tolower(column.name)

# textual output
file.name <- "../tmp/textbox_output.tmp"
write.table(res, file=file.name, quote=FALSE, col.names=TRUE, row.names=FALSE)
