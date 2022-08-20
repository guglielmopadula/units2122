The folder should contain:
-two .cc files: kdtree.cc (the tree algorithm) and testbinding.cc (for testing omp and mpi binding)
-a bash script: kdtree.sh which compiles the code and takes some measurements
-a R script: tree.R which generates some graphs
- various csv files (measurements)
- various png files (graphs)
- report.pdf

How to compile the code for the tree:

- mpic++ -fopenmp -O3 kdtree.cc -o kdtree -std=c++14

How to run the code for the tree (example with 6 OMP threads nested in 4 MPI threads):

OMP_NUM_THREADS=6 mpirun -np 4 --map-by slot:PE=6 ./kdtree 2>/dev/null

How to transform the the tree dot file in a png file:
- dot -Tpng tree.dot -o tree.png

How to compile the code for the testbinding:

- mpic++ -fopenmp testbinding.cc -o testbinding

How to run the code for the testbinding (example with 6 OMP threads nested in 4 MPI threads):

OMP_NUM_THREADS=6 mpirun -np 4 --map-by slot:PE=6 ./testbinding 2>/dev/null

