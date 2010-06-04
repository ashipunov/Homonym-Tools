source("functions.r")

if (!file.exists("ctrusted.Rd") | (difftime(Sys.time(), file.info("ctrusted.Rd")$mtime, units="days") > 1))
   {
   all <- read.table(gzfile("../input/gni/binomials.csv.gz"), sep="\t", quote="", h=FALSE, as.is=TRUE, strip.white=TRUE, encoding="UTF-8")
   names(all) <- c("data", "taxonID", "gen", "sp", "scientificName")
   all$scientificName <- toupper(all$scientificName)
   all$binomial <- paste(all$gen, all$sp)
   trusted <- data.frame(data.source=c(7,8,11), datasetID=c("IF", "ZB", "IPNI"), kingdom=c("Fungi", "Animalia", "Plantae"))
   all$datasetID <- Recode(all$data, trusted$data.source, trusted$datasetID)
   all <- all[,c("datasetID", "taxonID", "binomial", "scientificName")]
   save(all, file="ctrusted.Rd", compress=TRUE)
   } else
   {
   load("ctrusted.Rd")
   }

sources <- scan(file="../tmp/ctrusted_selected.tmp", what="character", quiet=TRUE)
hmb <- Hsub(sources[1], sources[-1], all$datasetID, all$binomial)
hms <- Hsub(sources[1], sources[-1], all$datasetID, all$scientificName)

res <- data.frame(all[all$datasetID %in% hmb$sublist,],
   ExternalHomonymFlagBinomial=hmb$external, InternalHomonymFlagBinomial=hmb$internal,
   ExternalHomonymFlagDiffAuthors=(hmb$external - hms$external), InternalHomonymFlagDiffAuthors=(hmb$internal - hms$internal))

column.name <- paste(hmb$sublist, "vs", paste(hmb$against, collapse="_"), sep="_")

# Output
file.name.tgz <- tolower(paste("../output/binomials_", column.name, ".tgz", sep=""))
file.name.csv <- "../output/binomials.csv"
write.table(res, file=file.name.csv, sep="\t", quote=FALSE, col.names=TRUE, row.names=FALSE)
tarfiles <- c("../output/binomials/eml.xml", "../output/binomials/meta.xml", file.name.csv)
Tar(file.name.tgz, files=tarfiles, compression="gzip", tar="tar")
ifelse(file.exists(file.name.csv), file.remove(file.name.csv))

