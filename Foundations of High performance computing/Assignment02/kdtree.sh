cd /fast/dssc/gpadula/2021Assignment02
rm *.txt
rm *.png
rm *.dot
module load R
module load openmpi-4.1.1+gnu-9.3.0
mpic++ kdtree.cc -fopenmp -o kdtree -O3 -std=c++14
export TIMEFORMAT=%R
echo "omp,mpi,time">>tree.csv
echo "omp,time">>weakomp.csv
echo "mpi,time">>weakmpi.csv
#Strong scaling

for i in {1..24}
do
	for j in {1..24}
	do
		if [ $((i*j)) -le 24 ]
		then	
  			OMP_NUM_THREADS=$i /usr/bin/time -f '%e' -o OUTPUT_FILE mpirun -np $j -map-by slot:PE=$i ./kdtree 100000000 4 2>/dev/null
        		pass=$(cat OUTPUT_FILE)
			echo "$i,$j,$pass">>tree.csv
		fi
	done
done
rm OUTPUT_FILE

#Weak scaling

for i in {1..24}
do
  	b=$(awk "BEGIN {print  $i*5000000; exit}")
        OMP_NUM_THREADS=1 /usr/bin/time -f '%e' -o OUTPUT_FILE mpirun -np $i -map-by slot:PE=1 ./kdtree $b 4 2>/dev/null
        pass=$(cat OUTPUT_FILE)
        echo "$i,$pass">> weakmpi.csv
done

rm OUTPUT_FILE

for i in {1..24}
do
  	b=$(awk "BEGIN {print  $i*5000000; exit}")
        OMP_NUM_THREADS=$i /usr/bin/time -f '%e' -o OUTPUT_FILE mpirun -np 1 -map-by slot:PE=$i ./kdtree $b 4 2>/dev/null
        pass=$(cat OUTPUT_FILE)
        echo "$i,$pass">> weakomp.csv
done

rm OUTPUT_FILE

#Alg comparison part

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


Rscript tree.R

#python treetograph.py > tree.dot
#dot -Tpng tree.dot -o tree.png -Gsize 2
#git add . && git commit -m "first commit" && git branch -M main && git push -u origin main


