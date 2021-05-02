## data

# chr = 1; start = 20663519; end = 21756276
# genotype_dir = '/project2/mstephens/yuxin/ukb-bloodcells/genotypes/'
# gwasfile = '~/GitHub/susierss_diagnostic/data/BBJ.WBC.autosome.txt.gz'
# gwasres = '~/GitHub/susierss_diagnostic/test'
# GWASsample = 10000
# REFsample = 1000
library(data.table)
library(Matrix)
library(dplyr)
datpos = unlist(strsplit(dataset, ','))
chr=datpos[1]; start=datpos[2]; end=datpos[3]

geno.file = paste0(genotype_dir, 'bloodcells_chr',
                   chr, '.', start, '.', end)

geno <- fread(paste0(geno.file, '.raw.gz'),sep = "\t",header = TRUE,stringsAsFactors = FALSE)
class(geno) <- "data.frame"
# Extract the genotypes.
X <- as(as.matrix(geno[-(1:6)]), 'dgCMatrix')

# Get subset of X (individuals)
n = nrow(X)
in_sample = sort(sample(1:n, GWASsample))
X.sample = X[in_sample,]
if(REFsample > 0){
  if(GWASsample == n){ # random choose individuals
    ref_sample = sample(1:n, REFsample)
  }else{ # choose individuals different from samples
    ref_sample_out = sort(sample(setdiff(1:n, in_sample), REFsample))
  }
  X.ref = X[ref_sample_out,]
}else{
  X.ref = NA
}

rm(X)

# Remove invariant SNPs
sample.idx = apply(X.sample, 2, var, na.rm=TRUE) != 0
if (all(!is.na(X.ref))) {
  ref.idx = apply(X.ref, 2, var, na.rm=TRUE) != 0
} else {
  ref.idx = 1
}
choose.idx = which(sample.idx * ref.idx == 1)
X.sample = X.sample[, choose.idx]
if (all(!is.na(X.ref))){
  X.ref = X.ref[, choose.idx]
}

cmd = paste0("zcat ", gwasfile, " | awk '{if ($2 == ", chr, " && $3 <= ", end, " && $3 >= ", start, ") {print $1,$2,$3,$4,$5,$6,$8,$9,$12}}' > ", gwasres)
system(cmd)
BBJsnps = fread(gwasres)
colnames(BBJsnps) = c('snp','chr', 'pos', 'ref', 'alt', 'freq', 'beta', 'se', 'N')

ukbsnps = fread(paste0(geno.file, '.pvar'),sep = "\t",header = TRUE,stringsAsFactors = FALSE)
ukbsnps = ukbsnps[choose.idx,]
snpscommon = intersect(BBJsnps$snp, ukbsnps$ID)
BBJsnps = BBJsnps %>% filter(snp %in% snpscommon)

X.sample = X.sample[, which(ukbsnps$ID %in% snpscommon)]
if (all(!is.na(X.ref))) {
  X.ref = X.ref[, which(ukbsnps$ID %in% snpscommon)]
}
ukbsnps = ukbsnps %>% filter(ID %in% snpscommon)

BBJsnps$beta[which(BBJsnps$ref == ukbsnps$ALT)] = -BBJsnps$beta[which(BBJsnps$ref == ukbsnps$ALT)]

X.idx = get_genotype(1000, ncol(X.sample))

X.sample = X.sample[,X.idx]
if (all(!is.na(X.ref))) {
  X.ref = X.ref[, X.idx]
}
BBJsnps = BBJsnps[X.idx,]

X.sample = as.matrix(center_scale(X.sample))
r.sample = cor(X.sample)
if (all(!is.na(X.ref))) {
  X.ref = as.matrix(center_scale(X.ref))
  r.ref = cor(X.ref)
}else{
  r.ref = NA
}



