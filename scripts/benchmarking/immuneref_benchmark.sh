# Change the number of repetitions, repertoires and sequences per repertoire as desired
# This script should work on the example data when run from the folder compairr-benchmarking/example_data

# replace with the path containing the output of convert_formats.py
INPUT_PATH=formatted

# replace with the path to the run_immunarch.R script
IMMUNEREF_PATH=../scripts/benchmarking/run_immuneref.R

mkdir benchmark
mkdir benchmark/immuneref
mkdir tool_outputs
mkdir tool_outputs/immuneref
mkdir tool_outputs/immuneref/stdout

for repetition in 1 2 3
do
for repertoires in 100
do
for sequences in 1e2
do
echo "#$repetition. $repertoires repertoires $sequences sequences"
echo "" >> benchmark/immuneref/$repertoires\_$sequences.txt
echo "#$repetition. $repertoires repertoires $sequences sequences" >> benchmark/immuneref/$repertoires\_$sequences.txt
/usr/bin/time -f "exitcode %x\nuser     %U\nsystem   %S\nelapsed  %E\nmaxrss   %M\navgtext  %X\navgdata  %D\nCPU      %P\ninputs   %I\noutputs  %O\nmajor    %F\nminor    %R\nswaps    %W" Rscript --vanilla $IMMUNEREF_PATH $INPUT_PATH/immuneref_data/$sequences/$repertoires/ tool_outputs/immuneref/$sequences\_$repertoires\repetition$repetition.txt >>tool_outputs/immuneref/stdout/$sequences\_$repertoires\repetition$repetition.txt 2>>benchmark/immuneref/$repertoires\_$sequences.txt
echo "done"
done
done
done