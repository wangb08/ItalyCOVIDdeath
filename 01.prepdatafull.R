################################################################################
# ANALYSIS ON THE EXCESS MORTALITY IN ITALY DURING COVID-19
################################################################################

################################################################################
# DOWNLOAD THE DATA, RESHAPE, RENAME AND TRANSFORM 
################################################################################

# DOWNLOAD AND UNZIP THE DATA
# NB: ZIP IN FOLDER, UNCOMMENT TO DOWNLOAD AGAIN
source <- "https://www.istat.it/it/files//2020/03/Dataset-decessi-comunali-giornalieri-e-tracciato-record-4giugno.zip"
file <- "Dataset-decessi-comunali-giornalieri-e-tracciato-record-4giugno.zip"
# curl_download(url=source, destfile=file, quiet=FALSE, mode="wb")
unzip(zipfile=file, exdir=getwd(), overwrite=F)

# READ THE DATA, THEN ERASE UNZIPPED (LARGE FILE)
dataorig <- fread("comuni_giornaliero-decessi.csv",na.strings="n.d.")
file.remove("comuni_giornaliero-decessi.csv")

# RESHAPE TO LONG
datafull <- dataorig[rep(seq(nrow(dataorig)), each=6), 1:9]
datafull$year <- rep(2015:2020, nrow(dataorig))
datafull$male <- c(t(dataorig[,grep("M_", names(dataorig), fixed=T), with=F]))
datafull$female <- c(t(dataorig[,grep("F_", names(dataorig), fixed=T), with=F]))
datafull$tot <- c(t(dataorig[,grep("T_", names(dataorig), fixed=T), with=F]))

# SELECT AND RENAME VARIABLES
datafull <- datafull %>% 
  rename(regcode=REG, regname=NOME_REGIONE, provcode=PROV,
    provname=NOME_PROVINCIA, municcode=COD_PROVCOM, municname=NOME_COMUNE,
  munictype=TIPO_COMUNE, agegr=CL_ETA)

# GENERATE DATE
datafull <- datafull %>%
  mutate(month=floor(GE/100), day=GE-month*100, date=make_date(year,month,day))

# DEFINE THE DATE SERIES, THEN REMOVE LAST PERIOD AND ERRONEOUS LEAP DAYS
seqdate <- seq(from=dmy("01012015"), to=dmy("30042020"), by=1)
datafull <- subset(datafull, date%in%seqdate)

# ORDER BY REGION AND PROVINCE, AND CREATE SEQUENCE AND LABELS (REDUCED)
datafull <- arrange(datafull, regcode, provcode)
seqprov <- unique(datafull$provcode)
labprov <- sapply(strsplit(unique(datafull$provname), "/|-"), "[[", 1)