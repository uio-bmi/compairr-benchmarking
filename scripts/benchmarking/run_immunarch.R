# Wrapper script to read in AIRR data, calculate AIRR overlap with immunarch and write the results.
library(immunarch)

args = commandArgs(trailingOnly=TRUE)
input_path = args[1]
output_path = args[2]

my_data <- repLoad(input_path)
result = repOverlap(my_data$data)

write.table(result, output_path, sep="\t")