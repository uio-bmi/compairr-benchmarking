# Wrapper script to read in AIRR data, calculate AIRR overlap with immuneREF and write the results.
library(immuneREF)

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]

test_immuneref_func <- function(path){
  print("loading data...")
  #setwd(path)
  n = paste0(path, list.files(path))
  repertoires = lapply(setNames(n, n), FUN=function(filename){read.table(file=filename, sep = '\t', header = TRUE, fill = TRUE)})
  print("done")
  print("calculating overlap...")
  overlap_layer<-repertoire_overlap(repertoires,basis="CDR3_aa")
  print("done")
  return(overlap_layer)
}

result = test_immuneref_func(input_path)

write.table(result, output_path, sep="\t")