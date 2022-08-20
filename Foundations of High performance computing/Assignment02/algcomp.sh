cd /fast/dssc/gpadula/2021Assignment02
rm *.txt
rm *.png
rm *.dot
module load R
module load openmpi-4.1.1+gnu-9.3.0
mpic++ kdtree.cc -fopenmp -o kdtree -O3
export TIMEFORMAT=%R
echo "omp,alg,time">>ompalg.csv
echo "omp,alg,time">>mpialg.csv


for j in {0..2}
do
	for i in {1..24}
	do
        	OMP_NUM_THREADS=1 /usr/bin/time -f '%e' -o OUTPUT_FILE mpirun -np $i -map-by slot:PE=1 ./kdtree 100000000 $j 2>/dev/null
        	pass=$(cat OUTPUT_FILE)
        	echo "$i,$j,$pass">> mpialg.csv
	done
done
rm OUTPUT_FILE

for j in {0..2}
do
	for i in {1..24}
	do
  		b=$(awk "BEGIN {print  $i*5000000; exit}")
        	OMP_NUM_THREADS=$i /usr/bin/time -f '%e' -o OUTPUT_FILE mpirun -np 1 -map-by slot:PE=$i ./kdtree 100000000 $j 2>/dev/null
        	pass=$(cat OUTPUT_FILE)
        	echo "$i,$j,$pass">> ompalg.csv
	done
done


