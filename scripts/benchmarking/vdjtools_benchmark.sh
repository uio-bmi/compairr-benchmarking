# Change the number of repetitions, repertoires and sequences per repertoire as desired
# Note, with large input datasets the -Xmx flag needs to be used to allocate enough memory (e.g., java -Xmx128G -jar ...)
# This script should work on the example data when run from the folder compairr-benchmarking/example_data

# replace with the path of the vdjtools executable
VDJTOOLS_PATH=~/Programs/vdjtools-1.2.1/vdjtools-1.2.1.jar

# replace with the path containing the output of convert_formats.py
INPUT_PATH=formatted

mkdir benchmark
mkdir benchmark/vdjtools
mkdir tool_outputs
mkdir tool_outputs/vdjtools
mkdir tool_outputs/vdjtools/stdout

for repetition in 1 2 3
do
for repertoires in 100
do
for sequences in 1e2
do
echo "#$repetition. $repertoires repertoires $sequences sequences"
echo "" >> benchmark/vdjtools/$repertoires\_$sequences.txt
echo "#$repetition. $repertoires repertoires $sequences sequences" >> benchmark/vdjtools/$repertoires\_$sequences.txt
/usr/bin/time -f "exitcode %x\nuser     %U\nsystem   %S\nelapsed  %E\nmaxrss   %M\navgtext  %X\navgdata  %D\nCPU      %P\ninputs   %I\noutputs  %O\nmajor    %F\nminor    %R\nswaps    %W" java -jar $VDJTOOLS_PATH CalcPairwiseDistances -m $INPUT_PATH/vdjtools_data/$sequences/$repertoires/metadata.txt tool_outputs/vdjtools/$sequences\_$repertoires\repetition$repetition/ >>tool_outputs/vdjtools/stdout/$sequences\_$repertoires\repetition$repetition.txt 2>>benchmark/vdjtools/$repertoires\_$sequences.txt
echo "done"
done
done
done