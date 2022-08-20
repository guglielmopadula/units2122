#define _GNU_SOURCE
#include <iostream>
#include <mpi.h>
#include <thread>
#include <sstream>
#include <omp.h>
#include <sched.h>
#define USE MPI

int main(int args, char *argv[]) {
    int rank, nprocs, thread_id, nthreads;
    MPI_Init(&args, &argv);

    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    #pragma omp parallel private(thread_id)
    {
     	thread_id = omp_get_thread_num();
        nthreads = omp_get_num_threads();
        std::stringstream omp_stream;
        omp_stream <<" My CPU is " << sched_getcpu()
	<< ", my omp thread is " 
	<< thread_id
        <<", my mpi thread is " << rank <<std::endl;
        std::cout << omp_stream.str();
    }
    MPI_Finalize();
    return 0;
}


