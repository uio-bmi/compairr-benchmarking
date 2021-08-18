# Change the number of repetitions, repertoires and sequences per repertoire, and CompAIRR settings as desired
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
for d_setting in 1 2
do
for t_setting in 8 1
do
echo "#$repetition. $repertoires repertoires $sequences sequences -d $d_setting -t $t_setting"
echo "" >> benchmark/compairr/$repertoires\_$sequences\_d$d_setting\_t$t_setting.txt
echo "#$repetition. $repertoires repertoires $sequences sequences -d $d_setting -t $t_setting" >> benchmark/compairr/$repertoires\_$sequences\_d$d_setting\_t$t_setting.txt
/usr/bin/time -f "exitcode %x\nuser     %U\nsystem   %S\nelapsed  %E\nmaxrss   %M\navgtext  %X\navgdata  %D\nCPU      %P\ninputs   %I\noutputs  %O\nmajor    %F\nminor    %R\nswaps    %W" compairr -m -d $d_setting -t $t_setting -g -o tool_outputs/compairr/output/$sequences\_$repertoires\_d$d_setting\_t$t_setting\_repetition$repetition.tsv -l tool_outputs/compairr/compairr_log/$sequences\_$repertoires\_d$d_setting\_t$t_setting\_repetition$repetition.compairr_log $INPUT_PATH/compairr_data/$sequences/$repertoires/repertoires\_$sequences\_$repertoires.tsv 2>>benchmark/compairr/$repertoires\_$sequences\_d$d_setting\_t$t_setting.txt
echo "done"
done
done
done
done
done