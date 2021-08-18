# Change the number of repetitions, repertoires and sequences per repertoire, and CompAIRR settings as desired
# This script always runs CompAIRR with d=1 and indels, for other settings, use compairr_benchmark.sh
# This script should work on the example data when run from the folder compairr-benchmarking/example_data

# replace with the path containing the output of convert_formats.py
INPUT_PATH=formatted

mkdir benchmark
mkdir benchmark/compairr
mkdir tool_outputs
mkdir tool_outputs/compairr
mkdir tool_outputs/compairr/output
mkdir tool_outputs/compairr/compairr_log


for repetition in 1 2 3
do
for repertoires in 100
do
for sequences in 1e2
do
for t_setting in 8 1
do
echo "#$repetition. $repertoires repertoires $sequences sequences -d 1 -t $t_setting -i"
echo "" >> benchmark/compairr/$repertoires\_$sequences\_d1\_t$t_setting\_i.txt
echo "#$repetition. $repertoires repertoires $sequences sequences -d 1 -t $t_setting -i" >> benchmark/compairr/$repertoires\_$sequences\_d1\_t$t_setting\_i.txt
/usr/bin/time -f "exitcode %x\nuser     %U\nsystem   %S\nelapsed  %E\nmaxrss   %M\navgtext  %X\navgdata  %D\nCPU      %P\ninputs   %I\noutputs  %O\nmajor    %F\nminor    %R\nswaps    %W" compairr -m -d 1 -t $t_setting -g -i -o tool_outputs/compairr/output/$sequences\_$repertoires\_d1\_t$t_setting\_i\_repetition$repetition.tsv -l tool_outputs/compairr/compairr_log/$sequences\_$repertoires\_d1\_t$t_setting\_i\_repetition$repetition.compairr_log $INPUT_PATH/compairr_data/$sequences/$repertoires/repertoires\_$sequences\_$repertoires.tsv 2>>benchmark/compairr/$repertoires\_$sequences\_d1\_t$t_setting\_i.txt
echo "done"
done
done
done
done
