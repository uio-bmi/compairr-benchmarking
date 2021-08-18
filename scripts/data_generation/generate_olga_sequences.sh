# Change the number of repertoires and number of sequences per repertoire as desired
N_REP=1000
REP_SIZE=1e5

mkdir $REP_SIZE

for i in $(eval echo "{1..$N_REP}")
do
   echo "###### Repertoire $i/$N_REP"
   olga-generate_sequences --humanIGH -o $REP_SIZE/rep_$i.tsv -n $REP_SIZE --seed=$i
done