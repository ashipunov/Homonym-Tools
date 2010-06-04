source("functions.r")

if (!file.exists("trusted.Rd") | (difftime(Sys.time(), file.info("trusted.Rd")$mtime, units="days") > 1))
   {
   tru <- read.table("../input/gni/trusted.csv", sep=";", h=FALSE, as.is=TRUE, strip.white=TRUE, encoding="UTF-8")
   ifu <- read.table("../input/gni/if.csv", sep=";", h=FALSE, as.is=TRUE, strip.white=TRUE, encoding="UTF-8")
   ifu <- ifu[!duplicated(ifu[,3]),]
   gni <- rbind(tru, ifu)
   trusted <- data.frame(data.source=c(7,8,11), datasetID=c("IF", "ZB", "IPNI"), kingdom=c("Fungi", "Animalia", "Plantae"))
   nz <- read.table("../input/standalone/nz.csv", sep=";", h=TRUE, as.is=TRUE, strip.white=TRUE, encoding="UTF-8")
   union.gni <- data.frame(datasetID=Recode(gni$V1, trusted$data.source, trusted$datasetID),
           taxonID=gni$V2, scientificName=gni$V3, kingdom=Recode(gni$V1, trusted$data.source, trusted$kingdom),
           LocalHomonymFlag=NA)
   union.nz <- data.frame(datasetID=c("NZ"),
           taxonID=nz$uid, scientificName=toupper(nz$name), kingdom=paste("Animalia:", nz$category, sep=""),
           LocalHomonymFlag=nz$homonymFlag)
   all <- rbind(union.gni, union.nz)
   save(all, file="trusted.Rd", compress=TRUE)
   } else
   {
   load("trusted.Rd")
   }

sources <- scan(file="../tmp/trusted_selected.tmp", what="character", quiet=TRUE)
hm <- Hsub(sources[1], sources[-1], all$datasetID, all$scientificName)
column.name <- paste(hm$sublist, "vs", paste(hm$against, collapse="_"), sep="_")
res <- data.frame(all[all$datasetID %in% hm$sublist,], hm$external, InternalHomonymFlag=hm$internal)
names(res)[6] <- tolower(column.name)

# Output
file.name.tgz <- tolower(paste("../output/", column.name, ".tgz", sep=""))
file.name.csv <- "../output/homonym_search_result.csv"
write.table(res, file=file.name.csv, sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE)
tarfiles <- c("../output/eml.xml", "../output/meta.xml", file.name.csv)
Tar(file.name.tgz, files=tarfiles, compression="gzip", tar="tar")
ifelse(file.exists(file.name.csv), file.remove(file.name.csv))

# ===
# XML output (just in case ;)
# very slow, commented
# library(XML)
# xml <- xmlTree()
# xml$addTag("document", close=FALSE)
# for (i in 1:nrow(res)) {
#    xml$addTag("row", close=FALSE)
#    for (j in names(res)) {
#        xml$addTag(j, res[i, j])
#    }
#    xml$closeTag()
# }
# xml$closeTag()
# file.name <- paste("../output/darwin_core/trusted", paste(hm$sublist, ".xml", sep=""), sep="_")
# write(saveXML(xml), file=tolower(file.name))
# The other one:
# write(file="res.xml", paste("<row>\n", apply(res, 1, function (.x) paste("\t<", names(res), ">", .x, "</", names(res), ">\n", sep="", collapse="")), "</row>\n", sep=""))
