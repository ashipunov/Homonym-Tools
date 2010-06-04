options(stringsAsFactors = FALSE)

Recode <- function(var, from, to){
   x <- as.vector(var)
   x.tmp <- x
   for (i in 1:length(from)){x <- replace(x, x.tmp == from[i], to[i])}
   if(is.factor(var)) factor(x) else x}
   
Tar <- function (tarfile, files = NULL, compression = c("none", "gzip", 
    "bzip2", "xz"), compression_level = 6, tar = Sys.getenv("tar")) 
{
    if (is.character(tarfile)) {
        TAR <- tar
        if (nzchar(TAR) && TAR != "internal") {
            flags <- switch(match.arg(compression), none = "cf", 
                gzip = "zcf", bzip2 = "jcf", xz = "Jcf")
            cmd <- paste(shQuote(TAR), flags, shQuote(tarfile), 
                paste(shQuote(files), collapse = " "))
            return(invisible(system(cmd)))
        }
        con <- switch(match.arg(compression), none = file(tarfile, 
            "wb"), gzip = gzfile(tarfile, "wb", compress = compression_level), 
            bzip2 = bzfile(tarfile, "wb", compress = compression_level), 
            xz = xzfile(tarfile, "wb", compress = compression_level))
        on.exit(close(con))
    }
    else if (inherits(tarfile, "connection")) 
        con <- tarfile
    else stop("'tarfile' must be a character string or a connection")
    files <- list.files(files, recursive = TRUE, all.files = TRUE, 
        full.names = TRUE)
    bf <- unique(dirname(files))
    files <- c(bf[!bf %in% c(".", files)], files)
    for (f in unique(files)) {
        info <- file.info(f)
        if (is.na(info$size)) {
            warning(gettextf("file '%s' not found", f), domain = NA)
            next
        }
        header <- raw(512L)
        if (info$isdir && !grepl("/$", f)) 
            f <- paste(f, "/", sep = "")
        name <- charToRaw(f)
        if (length(name) > 100L) {
            if (length(name) > 255L) 
                stop("file path is too long")
            s <- max(which(name[1:155] == charToRaw("/")))
            if (is.infinite(s) || s + 100 < length(name)) 
                stop("file path is too long")
            warning("storing paths of more than 100 bytes is not portable:\n  ", 
                sQuote(f), domain = NA)
            prefix <- name[1:(s - 1)]
            name <- name[-(1:s)]
            header[345 + seq_along(prefix)] <- prefix
        }
        header[seq_along(name)] <- name
        header[101:107] <- charToRaw(sprintf("%07o", info$mode))
        if (!is.na(info$uid)) 
            header[109:115] <- charToRaw(sprintf("%07o", info$uid))
        if (!is.na(info$gid)) 
            header[117:123] <- charToRaw(sprintf("%07o", info$gid))
        size <- ifelse(info$isdir, 0, info$size)
        header[137:147] <- charToRaw(sprintf("%011o", as.integer(info$mtime)))
        if (info$isdir) 
            header[157L] <- charToRaw("5")
        else {
            lnk <- Sys.readlink(f)
            if (is.na(lnk)) 
                lnk <- ""
            header[157L] <- charToRaw(ifelse(nzchar(lnk), "2", 
                "0"))
            if (nzchar(lnk)) {
                if (length(lnk) > 100L) 
                  stop("linked path is too long")
                header[157L + seq_len(nchar(lnk))] <- charToRaw(lnk)
                size <- 0
            }
        }
        header[125:135] <- charToRaw(sprintf("%011o", as.integer(size)))
        header[258:262] <- charToRaw("ustar")
        header[264:265] <- charToRaw("0")
        if (!is.na(s <- info$uname)) {
            ns <- nchar(s, "b")
            header[265L + (1:ns)] <- charToRaw(s)
        }
        if (!is.na(s <- info$grname)) {
            ns <- nchar(s, "b")
            header[297L + (1:ns)] <- charToRaw(s)
        }
        header[149:156] <- charToRaw(" ")
        checksum <- sum(as.integer(header))%%2^24
        header[149:154] <- charToRaw(sprintf("%06o", as.integer(checksum)))
        header[155L] <- as.raw(0L)
        writeBin(header, con)
        if (info$isdir || nzchar(lnk)) 
            next
        inf <- file(f, "rb")
        for (i in seq_len(ceiling(info$size/512L))) {
            block <- readBin(inf, "raw", 512L)
            writeBin(block, con)
            if ((n <- length(block)) < 512L) 
                writeBin(raw(512L - n), con)
        }
        close(inf)
    }
    block <- raw(512L)
    writeBin(block, con)
    writeBin(block, con)
    invisible(0L)
}

Hsub <- function (sublist, against, indices, what)
   {
   what.against <- what[indices %in% against]
   what.sublist <- what[indices %in% sublist]
   wsu <- unique(what.sublist) # remove internal homonyms
   external.1 <- which(duplicated(c(what.against, wsu))) - length(what.against)
   external.2 <- external.1[external.1 > 0] # remove indices from "against" list
   external <- which(what.sublist %in% wsu[external.2]) # project results from "wsu" to sublist
   internal <- which(duplicated(what.sublist) | duplicated(what.sublist, fromLast=TRUE)) # mark all homonyms, not only the n+1 ones
   itn <- ext <- rep(0, length(what.sublist))
   ext[external] <- 1
   itn[internal] <- 1
   return(list(sublist=sublist, against=against, external=ext, internal=itn))
   }
