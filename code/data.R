## data
library(data.table)
datpos = unlist(strsplit(dataset, ','))
chr=datpos[1]; start=datpos[2]; end=datpos[3]

# extract data
cmd = paste0('/project2/mstephens/software/plink-1.90b6.10/plink --bfile data/1kg_unrelated ',
             '--chr ', chr, ' --from-bp ', start, ' --to-bp ', end, ' --make-bed ',
             '--threads 2 --memory 5000 --out ', plinkfile)
system(cmd)
cmd = paste0('/project2/mstephens/software/plink-1.90b6.10/plink --bfile ', plinkfile, ' ',
             '--export A --out ', plinkfile)
system(cmd)

# load data
geno <- fread(paste0(plinkfile, '.raw'),sep = " ",header = TRUE,stringsAsFactors = FALSE,
              showProgress = FALSE)
class(geno)    <- "data.frame"
ids            <- with(geno,paste(FID,IID,sep = "_"))
geno           <- geno[-(1:6)]
rownames(geno) <- ids
geno           <- as.matrix(geno)
storage.mode(geno) <- "double"

files = unlist(strsplit(plinkfile, '/'))
junk <- dir(path = paste(files[1:(length(files)-1)], collapse = '/'), 
            pattern=files[length(files)],
            full.names = T)
file.remove(junk)

# select individual label: GBR IBS
labels <- read.table("data/omni_samples.20141118.panel",
                     sep = " ",header = TRUE,as.is = "id")
ids <- sapply(strsplit(rownames(geno),"_"),"[",2) 
labels <- subset(labels,is.element(labels$id,ids)) 

X = geno[labels$pop == 'GBR',] # British in England and Scotland.
X.IBS = geno[labels$pop == 'IBS',] # Iberian Populations in Spain.
X.CLM = geno[labels$pop == 'CLM',] # Colombians in Medellin, Colombia.

# filter on missing rate, maf, and do mean imputation
X = filter_X(X, 0.05, 0.05)
X.IBS = filter_X(X.IBS, 0.05, 0.05)
X.CLM = filter_X(X.CLM, 0.05, 0.05)

# get common SNPs
indx <- Reduce(intersect, list(colnames(X), colnames(X.IBS),colnames(X.CLM)))
X = X[, indx]
X.IBS = X.IBS[, indx]  
X.CLM = X.CLM[, indx]

X = susieR:::set_X_attributes(X)
X = t((t(X) - attributes(X)[["scaled:center"]]) / attributes(X)[["scaled:scale"]]);
r.sample = cor(X)
N.GBR = nrow(X)

X.IBS = susieR:::set_X_attributes(X.IBS)
X.IBS_scaled = t((t(X.IBS) - attributes(X.IBS)[["scaled:center"]]) / attributes(X.IBS)[["scaled:scale"]]);
r.IBS = cor(X.IBS)
N.IBS = nrow(X.IBS)

X.CLM = susieR:::set_X_attributes(X.CLM)
X.CLM_scaled = t((t(X.CLM) - attributes(X.CLM)[["scaled:center"]]) / attributes(X.CLM)[["scaled:scale"]]);
r.CLM = cor(X.CLM)
N.CLM = nrow(X.CLM)

r.IBS.2dist = Matrix::norm(r.sample - r.IBS, type='2')
r.CLM.2dist = Matrix::norm(r.sample - r.CLM, type='2')

r.IBS.Mdist = max(abs(r.sample - r.IBS))
r.CLM.Mdist = max(abs(r.sample - r.CLM))




