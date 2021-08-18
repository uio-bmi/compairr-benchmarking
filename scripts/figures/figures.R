library(ggplot2)
library(viridis)
library(plyr)


base_folder = "~/PycharmProjects/compairr-benchmarking/results/aggregated_results/"

all_results = read.csv(paste0(base_folder, "tool_stats_agg.tsv"), sep="\t")
all_results = all_results[all_results$exitcode == 0,]

# remove error bars for runs with 1 repetition
all_results[all_results$n_repetitionssum == 1,]$elapsed_secondsmin = NA
all_results[all_results$n_repetitionssum == 1,]$elapsed_secondsmax = NA
all_results[all_results$n_repetitionssum == 1,]$maxrssmin = NA
all_results[all_results$n_repetitionssum == 1,]$maxrssmax = NA


all_results$full_tool_name = relevel(all_results$full_tool_name, "compairr-t8")

all_results$full_tool_name = revalue(all_results$full_tool_name, c("compairr-t8"="CompAIRR (8)",
                                                                   "compairr-t1"="CompAIRR (1)",
                                                                   "immunarch"="immunarch (1)",
                                                                   "immuneref"="immuneREF (1)",
                                                                   "vdjtools"="VDJtools (8)"))

tool_benchmark = all_results

tool_benchmark = tool_benchmark[tool_benchmark$t %in% c("t1", "t8", ""),]
tool_benchmark = tool_benchmark[tool_benchmark$d == "" | tool_benchmark$d == "d0",]

options(scipen=999)



######################################################
# Figure 1A + 1B: performance benchmark 100k seq/AIRR
######################################################

tool_benchmark_100kseq =tool_benchmark[tool_benchmark$n_seq == 100000,]


# 100k sequences running time
ggplot(data=tool_benchmark_100kseq, aes(x=as.factor(n_rep), y=elapsed_secondsmean,
                                        group=full_tool_name,
                                        color=full_tool_name)) +
  labs(x="Number of AIRRs", y="Running time", color="Tool (threads)") +
  geom_line(alpha=0.5) +
  geom_point(size=1.5) +
  scale_y_log10(breaks=c(1, 60, 60*60, 60*60*24, 60*60*60, 60*60*24*10,  60*60*24*25), labels=c("1 second","1 minute","1 hour","1 day", "60 hours", "10 days", "25 days")) +
  scale_shape_manual(values=c(1, 8, 16)) +
  geom_errorbar(aes(ymin = elapsed_secondsmin, ymax = elapsed_secondsmax), width=0.1, alpha=0.7) +
  theme_bw() + theme(panel.grid.minor.y = element_blank(), legend.position = "none") + scale_color_viridis(discrete=TRUE, option="plasma", end=0.90)



# 100k sequences memory
ggplot(data=tool_benchmark_100kseq, aes(x=as.factor(n_rep), y=maxrssmean,
                                        group=full_tool_name,
                                        color=full_tool_name)) +
  labs(x="Number of AIRRs", y="Maximum RAM used", color="Tool (threads)") +
  geom_line(alpha=0.5)+
  geom_point(size=1.5) + scale_y_log10(breaks=c(1e+4, 1e+5, 1e+6, 1e+7, 1e+8, 1e+9), labels=c("10 MB", "100 MB", "1 GB", "10 GB", "100 GB", "1 TB")) +
  theme_bw() + theme(panel.grid.minor.y = element_blank(), legend.position = "none") +
  geom_errorbar(aes(ymin = maxrssmin, ymax = maxrssmax), width=0.1, alpha=0.7) +
  scale_color_viridis(discrete=TRUE, option="plasma", end=0.90) + scale_shape_manual(values=c(1, 8, 16))


compairr_biggest_dataset = tool_benchmark_100kseq[tool_benchmark_100kseq$full_tool_name == "CompAIRR (8)" &
                                                    tool_benchmark_100kseq$d == "d0" &
                                                    tool_benchmark_100kseq$n_rep == 10000 &
                                                    tool_benchmark_100kseq$n_seq == 1e5,]


immunarch_biggest_dataset = tool_benchmark_100kseq[tool_benchmark_100kseq$full_tool_name == "immunarch (1)" &
                                                     tool_benchmark_100kseq$n_rep == 10000 &
                                                     tool_benchmark_100kseq$n_seq == 1e5,]

# CompAIRR is 923 times faster than immunarch (fastest competitor) on the biggest dataset
immunarch_biggest_dataset$elapsed_secondsmean / compairr_biggest_dataset$elapsed_secondsmin

# CompAIRR uses at most 0.302 part of the max RAM compared to immunarch (most memory efficient competitor)
compairr_biggest_dataset$maxrssmax / immunarch_biggest_dataset$maxrssmean
compairr_biggest_dataset$maxrssmin / immunarch_biggest_dataset$maxrssmean

#######################################################
# Figure 1C: CompAIRR settings benchmark 100k seq/AIRR
#######################################################


setting_benchmark = all_results[all_results$tool == "compairr",]

n_rep = 1000
n_seq = 1e+05
t = c("t1", "t8")

setting_benchmark = setting_benchmark[setting_benchmark$n_rep == n_rep,]
setting_benchmark = setting_benchmark[setting_benchmark$n_seq == n_seq,]
setting_benchmark = setting_benchmark[setting_benchmark$t %in% t,]

setting_benchmark$t = relevel(setting_benchmark$t, "t1")
setting_benchmark$t = relevel(setting_benchmark$t, "t8")
setting_benchmark$t = revalue(setting_benchmark$t, c("t1"="1", "t8"="8"))

setting_benchmark$annotation = NA
setting_benchmark$annotation[setting_benchmark$d == "d2" & setting_benchmark$t == "8"] = "8 threads"
setting_benchmark$annotation[setting_benchmark$d == "d2" & setting_benchmark$t == "1"] = "1 thread"


setting_benchmark$setting = factor(paste0(setting_benchmark$d, "_", setting_benchmark$i), levels=c("d0_False", "d1_False", "d1_True", "d2_False"))

setting_benchmark$setting = revalue(setting_benchmark$setting, c("d0_False"="d=0,\nno indels",
                                                                 "d1_False"="d=1,\nno indels",
                                                                 "d1_True"="d=1,\nindels allowed",
                                                                 "d2_False"="d=2,\nno indels"))


ggplot(data=setting_benchmark, aes(x=setting, y=elapsed_secondsmean,
                                   group=full_tool_name,
                                   color=t)) +
  labs(x="CompAIRR settings", y="Running time", color="Number of threads") + #, title=paste0("CompAIRR running time with ", n_rep, " AIRRs of \n", n_seq, " sequences")) +
  geom_line(alpha=0.5)+
  geom_point(size=1.5) +
  scale_y_log10(breaks=c(1, 60, 60*5, 60*60, 60*60*5, 60*60*24), labels=c("1 second","1 minute", "5 minutes", "1 hour", "5 hours", "1 day"), limits=c(50, 60*60*50)) +
  theme_bw() + theme(panel.grid.minor.y = element_blank()) +
  geom_text(aes(label=annotation), hjust=0.45, vjust=-0.8, size=3) +
  geom_errorbar(aes(ymin = elapsed_secondsmin, ymax = elapsed_secondsmax), width=0.1, alpha=0.7) +
  scale_color_viridis(discrete=TRUE, option="plasma", end=0.225) + scale_shape_manual(values=c(1, 8, 16)) +
  theme(legend.position = "none")




##########################################################
# Supplementary figure 1: performance benchmark 1000 AIRRs
##########################################################


tool_benchmark_1000rep = tool_benchmark[tool_benchmark$n_rep == 1000,]


# 1000 AIRRs running time
ggplot(data=tool_benchmark_1000rep, aes(x=as.factor(n_seq), y=elapsed_secondsmean,
                                        group=full_tool_name,
                                        color=full_tool_name)) +
  labs(x="Number of sequences per AIRR", y="Running time", color="Tool (threads)") +
  geom_line(alpha=0.5) +
  geom_point(size=1.5) +
  scale_y_log10(breaks=c(1, 60, 60*60, 60*60*24, 60*60*24*5), labels=c("1 second","1 minute","1 hour","1 day", "5 days")) +
  scale_shape_manual(values=c(1, 8, 16)) +
  geom_errorbar(aes(ymin = elapsed_secondsmin, ymax = elapsed_secondsmax), width=0.1, alpha=0.7) +
  theme_bw() + theme(panel.grid.minor.y = element_blank(), legend.position = "none") + scale_color_viridis(discrete=TRUE, option="plasma", end=0.90)


# 1000 AIRRs sequences memory
ggplot(data=tool_benchmark_1000rep, aes(x=as.factor(n_seq), y=maxrssmean,
                                        group=full_tool_name,
                                        color=full_tool_name)) +
  labs(x="Number of AIRRs", y="Maximum RAM used", color="Tool (threads)") +
  geom_line(alpha=0.5)+
  geom_point(size=1.5) + scale_y_log10(breaks=c(1e+4, 1e+5, 1e+6, 1e+7, 1e+8, 3e+8, 1e+9), labels=c("10 MB", "100 MB", "1 GB", "10 GB", "100 GB", "300 GB", "1 TB")) +
  theme_bw() + theme(panel.grid.minor.y = element_blank(), legend.position = "none") +
  geom_errorbar(aes(ymin = maxrssmin, ymax = maxrssmax), width=0.1, alpha=0.7) +
  scale_color_viridis(discrete=TRUE, option="plasma", end=0.90) + scale_shape_manual(values=c(1, 8, 16))





#########################################################################
# Supplementary figure 2: CompAIRR time breakdown of analysis components
#########################################################################


compairr_steps_time = read.csv(paste0(base_folder, "compairr_time_parts.tsv"), sep="\t")
compairr_steps_time = compairr_steps_time[compairr_steps_time$t %in% c("t1", "t8"),]

compairr_steps_time[compairr_steps_time$n_repetitionssum == 1,]$valuemin = NA
compairr_steps_time[compairr_steps_time$n_repetitionssum == 1,]$valuemax = NA

compairr_steps_time$setting = factor(paste0(compairr_steps_time$d, "_", compairr_steps_time$i), levels=c("d0_False", "d1_False", "d1_True", "d2_False"))

compairr_steps_time$setting = revalue(compairr_steps_time$setting, c("d0_False"="d=0,\nno indels",
                                                                     "d1_False"="d=1,\nno indels",
                                                                     "d1_True"="d=1,\nindels allowed",
                                                                     "d2_False"="d=2,\nno indels"))

compairr_steps_time$t = revalue(compairr_steps_time$t, c("t1"="1 thread", "t8"="8 threads"))

compairr_steps_time$variable = relevel(compairr_steps_time$variable, "Writing results")
compairr_steps_time$variable = relevel(compairr_steps_time$variable, "Analysing")
compairr_steps_time$variable = relevel(compairr_steps_time$variable, "Indexing, sorting\nand hashing")
compairr_steps_time$variable = relevel(compairr_steps_time$variable, "Reading input")

ggplot(data=compairr_steps_time, aes(x=as.factor(n_seq), y=valuemean,
                                     group=variable,
                                     color=variable)) +
  geom_line(alpha=0.5)+
  scale_y_log10(breaks=c(1, 60, 60*60,60*60*5, 60*60*24,60*60*24*10), labels=c("1 second","1 minute", "1 hour", "5 hours", "1 day", "10 days"), limits=c(NA, NA)) +
  labs(x="Number of AIRRs", y="Running time", color="Analysis step") +
  geom_point(size=1.5, position="dodge") +
  facet_grid(t~setting) +
  geom_errorbar(aes(ymin = valuemin, ymax = valuemax), width=0.2, alpha=0.7) +
  scale_color_viridis(discrete=TRUE, option="plasma", end=0.90) +
  theme_bw() + theme(panel.grid.minor.y = element_blank(),
                     strip.background =element_rect(fill="white"))




###########################################################################################
# Supplementary figure 3: violin plots of emerson matches with different CompAIRR settings
###########################################################################################
library(plyr)
library(reshape2)
library(ggforce)

emerson_folder = "~/PycharmProjects/compairr-benchmarking/results/emerson/"


emerson_d0 = as.matrix(read.csv(paste0(emerson_folder, "d0/out.txt"), sep="\t", row.names=1))
emerson_d1 = as.matrix(read.csv(paste0(emerson_folder, "d1/out.txt"), sep="\t", row.names=1))
emerson_d1i = as.matrix(read.csv(paste0(emerson_folder, "d1i/out.txt"), sep="\t", row.names=1))
emerson_d2 = as.matrix(read.csv(paste0(emerson_folder, "d2/out.txt"), sep="\t", row.names=1))

emerson_df = data.frame("d0" = emerson_d0[upper.tri(emerson_d0, diag=F)],
                        "d1" = emerson_d1[upper.tri(emerson_d1, diag=F)],
                        "d1i" = emerson_d1i[upper.tri(emerson_d1i, diag=F)],
                        "d2" = emerson_d2[upper.tri(emerson_d2, diag=F)])


melted = melt(emerson_df)

melted$variable = revalue(melted$variable, c("d0"="d=0,\nno indels",
                                             "d1"="d=1,\nno indels",
                                             "d1i"="d=1,\nindels allowed",
                                             "d2"="d=2,\nno indels"))



ggplot(data=melted, aes(x=variable, y=value)) +
  labs(x="CompAIRR settings", y="Number of matching sequences") +
  geom_violin() + geom_sina(alpha=0.001, size=0.001) + theme_bw() + scale_y_log10()
