#include <iostream>
#include <cstddef>
#include <vector>
#include <utility>
#include <algorithm>
#include <array>
#include <sstream>
#include <string>
#include <queue>
#include <mpi.h>
#include <math.h>
#include <random>
#include <ctime>
#include <parallel/algorithm>
#define USE MPI
#include <omp.h>
#include <iomanip>
#include <fstream>

#if !defined(DOUBLE_PRECISION)
#define float_t float
#define mpitype MPI_FLOAT
#else
#define float_t double
#define mpitype MPI_DOUBLE
#endif

template <int K> 
struct Node
{
    std::array<float_t, K> point;
    Node<K> *left, *right;
    int depth;
};

//comparison operator
template <int K>
struct comp_dim {
	comp_dim(int index) : index_(index) {}
        bool operator()(const std::array<float_t, K> arr1, const std::array<float_t, K> arr2) const {
        	return arr1[index_] < arr2[index_];
        }
	int index_;
};

// swap operator
template<typename T>
void myswap(T& a, T& b) {
    T temp(std::move(a));
    a = std::move(b);
    b = std::move(temp);
}

template<int K>
Node<K>* deserialize(const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last);
template<int K>
void serialize(Node<K>* tree, std::vector<std::array<float_t,K>>& data);
template <int K>
Node<K>* build_tree_int(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag);
template <int K>
Node<K>* build_tree(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag);
template <int K>
Node<K>* create_treenode(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag);
  template <int K>
Node<K>* create_treenode_int(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth,  int mergeflag);
template <int K>
void sortwrapper(const typename  std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last, int index, int mergeflag);

//this functions calculates the depth of every node in the tree

template<int K>
void adjustDepth (Node<K> * root, int mydepth){

	root->depth=mydepth;

	if (root->left!=nullptr){
        	adjustDepth<K>(root->left,mydepth+1);
        }
	if (root->right!=nullptr){
        	adjustDepth<K>(root->right,mydepth+1);
        }
}

//this function deletes the tree from memory

template<int K>
void deleteTree (Node<K> * root){
	if (root->left!=nullptr){
        	deleteTree<K>(root->left);
        }
	if (root->right!=nullptr){
        	deleteTree<K>(root->right);
        }
	delete root;
}

template <int K>
void printTree (Node<K> * root){
	std::cout<<"Node point"<<std::endl;
	for (int i=0; i<K; i++){ 
		std::cout<<"element"<<i<<"is:"<<root->point[i]<<std::endl; 
	}
	std::cout<<"Depth: "<<root->depth<<std::endl;
	if (root->left!=nullptr){
		printTree<K>(root->left);
	}
	if (root->right!=nullptr){
		printTree<K>(root->right);
	}
}


//some useful functions follows

int child(int num, int depth){
return num+pow(2,depth);
}


int initdepth(int num){
	if(num==0){
		return 0;
	}
	return floor(log2(num))+1;
}


int father(int num){
	return num-pow(2,initdepth(num)-1);
}

int sizerank(int num, int n, int depth){

	if(depth>0){
		int temp=sizerank(father(num),n,depth-1);
		if (num<pow(2,depth-1)){

			return temp/2;
		}
		else{

			return temp-temp/2-1;
		}
	}
	else{
		return n;
	}
	
}

//quickselect algorithm
template <int K>
void quickselect(const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last, int k, int index)
{
   const int len=last-first;
   int left = 0, right = len - 1;
   int pos, i;
   float_t pivot;

   while (left < right)
   {
      pivot = (*(first+k))[index];
      myswap(*(first+k), *(first+right));
      for (i = pos = left; i < right; i++)
      {
       	 if ((*(first+i))[index] < pivot)
         {
            myswap(*(first+i), *(first+pos));
            pos++;
         }
      }
      myswap(*(first+right), *(first+pos));
      if (pos == k) break;
      if (pos < k) left = pos + 1;
      else right = pos - 1;
   }
}


//executes a merge sort serially
template <int K>
void mergesortSerial( const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last, const typename std::vector<std::array<float_t, K>>::iterator firstMerge, comp_dim<K> cmp)
{
    const int n = last - first;

    if (n <= 1)
        return;

    const int m = n / 2;

    mergesortSerial<K>(first, first + m, firstMerge, cmp);
    mergesortSerial<K>(first + m, last,firstMerge, cmp);

    auto merge = firstMerge;

    typename std::vector<std::array<float_t,K>>::iterator lower = first;
    typename std::vector<std::array<float_t,K>>::iterator upper = first + m;

    while (lower != first + m && upper != last)
        *(merge++) = cmp(*lower, *upper) ? *(lower++) : *(upper++);

    std::move(lower, first + m, merge);
    std::move(upper, last, merge);

    std::move(firstMerge, firstMerge + n, first);
}
//executes a merge sort using OpenMP
template <int K>
void mergesortParallelOpenMP( const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last, const typename std::vector<std::array<float_t, K>>::iterator firstMerge, comp_dim<K> cmp)
{	
    	const int n = last - first;

    	if (n <= 1)
        	return;

	if (n < 100) {
        	mergesortSerial<K>(first, last, firstMerge  ,cmp);
		return;
    	}

   	 const int m = n / 2;
    	#pragma omp task 
	{
	mergesortParallelOpenMP<K>(first, first + m, firstMerge, cmp);
	}
	#pragma omp task 
	{
	mergesortParallelOpenMP<K>(first + m, last,firstMerge, cmp);
	}
    #pragma omp taskwait
    auto merge = firstMerge;

    typename std::vector<std::array<float_t,K>>::iterator lower = first;
    typename std::vector<std::array<float_t,K>>::iterator upper = first + m;

    while (lower != first + m && upper != last)
        *(merge++) = cmp(*lower, *upper) ? *(lower++) : *(upper++);

    std::move(lower, first + m, merge);
    std::move(upper, last, merge);

    std::move(firstMerge, firstMerge + n, first);
}

//this function chooses the sorting method to use
template <int K>
void sortwrapper(const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last, int index, int mergeflag)
{
    std::vector<std::array<float_t, K> > mergeSpace(last - first);
    if (mergeflag==0)
    {
    	mergesortSerial<K>(first, last, mergeSpace.begin(), comp_dim<K>(index));
    }
    if (mergeflag==1){
        mergesortParallelOpenMP<K>(first, last, mergeSpace.begin(), comp_dim<K>(index));
    }
    if (mergeflag==2){
	int n = (last-first) / 2;
        quickselect<K>(first,last,n ,index);
    }
}

//creates a new internal node in the OMP phase
template <int K>
Node<K> * create_treenode_int(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag)
{
    Node<K> * temp=new Node<K>;
    temp->depth=mydepth;
    int n = mydata.size() / 2;
	# pragma omp master
	{
	    sortwrapper<K>(mydata.begin(), mydata.end(), dim, mergeflag);
	}

    std::vector<std::array<float_t, K>> left_data={mydata.begin(), mydata.begin()+n};
    std::vector<std::array<float_t, K>> right_data={mydata.begin()+n+1, mydata.end()};
    std::swap(temp->point,mydata[n]);
    # pragma omp task final(n<500)
     {
    	temp->left=build_tree_int<K>(left_data, (dim+1)%K,mydepth+1, mergeflag);
    }
    # pragma omp task final(n<500)
    {
	temp->right=build_tree_int<K>(right_data, (dim+1)%K,mydepth+1, mergeflag);		
    }
    # pragma omp taskwait
    return temp;
}

//internal MPI node function
template <int K>
Node<K> * create_treenode2(std::vector<std::array<float_t, K>> &data, std::vector<std::array<float_t, K>> &mydata ,int dim, int depth, int mergeflag){
	MPI_Status status;
	MPI_Request request;
	int n = mydata.size();
	int nmpi;
	int rank;
	MPI_Comm_size(MPI_COMM_WORLD, &nmpi);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank); 
        # pragma omp parallel
        {
		#pragma omp master
                {
                	sortwrapper<K>(data.begin(), data.end(), initdepth(rank)%K, mergeflag);
                }
	}
	int m=data.size()/2;
	Node<K>* temp=new Node<K>;
	std::swap(temp->point,data[m]);
	temp->depth=depth;
	std::vector<std::array<float_t, K>> right_data={data.begin()+m+1, data.end()};
	std::vector<std::array<float_t, K>> left_data={data.begin(), data.begin()+m};
 		if( child(rank,depth)<nmpi && sizerank(child(rank,depth),n,depth+1)>2){
		    MPI_Isend(&right_data[0],K*sizerank(child(rank,depth),n,depth+1),mpitype,child(rank,depth),0,MPI_COMM_WORLD, &request);
		    std::vector<std::array<float_t,K>> sersubtree(sizerank(child(rank,depth),n,depth+1));
                    MPI_Irecv(&sersubtree[0],K*sizerank(child(rank,depth),n,depth+1),mpitype,child(rank,depth),0,MPI_COMM_WORLD,&request);
		    temp->left=create_treenode2<K>(left_data,mydata,dim,depth+1,mergeflag);
		    MPI_Wait(&request,&status);
	            temp->right=deserialize<K>(sersubtree.begin(),sersubtree.end());
		}
		else{
		    #pragma omp parallel 
			{
				#pragma omp master
				{
				    temp->left=build_tree_int<K>(left_data,depth%K,depth,mergeflag);
				    temp->right=build_tree_int<K>(right_data,depth%K,depth,mergeflag);
				}
			}
		}
		return temp;
}  


//external MPI node function
template <int K>
Node<K> * create_treenode(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag){
	MPI_Request request;
	MPI_Status status;
        int rank;
	int nmpi;
	MPI_Comm_size(MPI_COMM_WORLD, &nmpi);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        int depth=initdepth(rank);

	int n = mydata.size();	
	std::vector<std::array<float_t, K> > data(std::max(sizerank(rank,n,depth),1));

	if (rank==0){
		std::move(mydata.begin(),mydata.end(),data.begin());
	}
	else{
	if(sizerank(rank,n,depth)<=2){Node<K> *temp; return temp;}
	MPI_Recv(&data[0],K*sizerank(rank,n,depth),mpitype,father(rank),0,MPI_COMM_WORLD,&status);
	}


	# pragma omp parallel
        {
		#pragma omp master
                {
                	sortwrapper<K>(data.begin(), data.end(), depth%2, mergeflag);
                }
	}
	int m=data.size()/2;
	Node<K>* temp=new Node<K>;
        std::swap(temp->point,data[m]);
	temp->depth=initdepth(rank);
	std::vector<std::array<float_t, K>> right_data={data.begin()+m+1, data.end()};
	std::vector<std::array<float_t, K>> left_data={data.begin(), data.begin()+m};

		if( child(rank,depth)<nmpi && sizerank(child(rank,depth),n,depth+1)>2){
		    MPI_Isend(&right_data[0],K*sizerank(child(rank,depth),n,depth+1),mpitype,child(rank,depth),0,MPI_COMM_WORLD, &request);
		    std::vector<std::array<float_t,K>> sersubtree(sizerank(child(rank,depth),n,depth+1));
                    MPI_Irecv(&sersubtree[0],K*sizerank(child(rank,depth),n,depth+1),mpitype,child(rank,depth),0,MPI_COMM_WORLD,&request);
		    temp->left=create_treenode2<K>(left_data,mydata,dim,depth+1,mergeflag);
		    MPI_Wait(&request,&status);
	            temp->right=deserialize<K>(sersubtree.begin(),sersubtree.end());
                    std::vector<std::array<float_t,K>>().swap(sersubtree);
		

		}
		else{
		    #pragma omp parallel 
			{
				#pragma omp master
				{
		                    temp->left=build_tree_int<K>(left_data,(depth+1)%2,depth+1,mergeflag);
				    temp->right=build_tree_int<K>(right_data,(depth+1)%2,depth+1,mergeflag);
				}
			}
		}
		
		if (rank!=0){
                        std::vector<std::array<float_t,K>> sersubtree;
			serialize<K>(temp, sersubtree);
			int len=sersubtree.size();
			MPI_Isend(&sersubtree[0], K*len, mpitype, father(rank), 0, MPI_COMM_WORLD, &request);
			deleteTree(temp);
			MPI_Wait(&request,&status);
		}
		return temp;
}




//this function serializes the tree in an std::vector
template<int K>
void serialize(Node<K>* tree, std::vector<std::array<float_t,K>>& data){
	std::array<float_t,K> treedata;
	for (int i=0; i<K; i++){
		treedata[i]=tree->point[i];
	}
	data.push_back(treedata);
	if(tree->right!=NULL) {
		serialize<K>(tree->right, data);
	}
	        if(tree->left!=NULL) {
                serialize<K>(tree->left, data);
        }
}

//this function deserializes an std::vector in  a tree
template<int K>
Node<K>* deserialize(const typename std::vector<std::array<float_t,K>>::iterator first, const typename std::vector<std::array<float_t, K>>::iterator last){
	int size=last-first;
	int rightsize=size/2;
	int leftsize=size-rightsize-1;
	Node<K>* tree=new Node<K>;
	std::swap(tree->point, first[0]);
	if(rightsize!=0){
		tree->right=deserialize<K>(first+1, first+rightsize+1);
	}
	else{tree->right=NULL;}
	if(leftsize!=0){
		tree->left=deserialize<K>(first+rightsize+1, last);
	}
	else{tree->left=NULL;}
	return tree;
}

  
//creates some leaves
template <int K>
Node<K> * create_treeleaf(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag) 
{
    Node<K> * temp=new Node<K>;
    temp->depth=mydepth;
    if (mydata.size()<=1)
    {
            temp->left=nullptr;
	    temp->right=nullptr;
	    for(int i=0; i<K; i++){
                temp->point[i]=mydata[0][i];
        	}
    }
    if (mydata.size()==2)
    {
	sortwrapper<K>(mydata.begin(), mydata.end(), dim, mergeflag);
	std::vector<std::array<float_t, K>> right_data={mydata.begin()+1, mydata.end()};
	temp->left=nullptr;
	temp->right=create_treeleaf<K>(right_data, (dim+1)%K, mydepth+1, mergeflag);           
	for(int i=0; i<K; i++){
                temp->point[i]=mydata[0][i];
        }
    }
    return temp;
}

//build tree for the OMP part
template <int K>
Node<K> * build_tree_int(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag) {
    Node<K> *temp;
    if (mydata.size()<=2)
    {
	    temp=create_treeleaf<K>(mydata, dim, mydepth, mergeflag);
    }
    else {
	    temp=create_treenode_int<K>(mydata, dim, mydepth, mergeflag);
    }
    return temp;
}

// build tree for the MPI part
template <int K>    
Node<K> * build_tree(std::vector<std::array<float_t, K>> &mydata, int dim, int mydepth, int mergeflag) {
    Node<K> *temp;
    if (mydata.size()<=2){
	    temp=create_treeleaf<K>(mydata, dim, mydepth, mergeflag);
    }
    else {
	    temp=create_treenode<K>(mydata, dim, mydepth, mergeflag);
    }
    return temp;
}
    
// the following functions export the tree in a dot file, there are two versions, one in C++14 and one in C
template <int K>
void exportTree_int(Node<K>* root, std::ostream& s, int* count){
	if(root->left!=nullptr){
		s<<"\"";
		for(int i=0; i<K-1; i++){
			s<<root->point[i];
			s<<";";	
		}
		s<<root->point[K-1]<<"\" -> \"";
		for(int i=0; i<K-1; i++){
                	s<<root->left->point[i];
                        s<<";";
                }
 		s<<root->left->point[K-1]<<"\";\n";
		exportTree_int<K>(root->left,s,count);
	}
	else{
		s<<"\"";
		for(int i=0; i<K-1; i++){
             		s<<root->point[i];
           		s<<";";
                	}
                s<<root->point[K-1]<<"\" -> null"<< (*count) <<"; \n";
		(*count)++;
	}
        if(root->right!=nullptr){
                s<<"\"";
                for(int i=0; i<K-1; i++){
                        s<<root->point[i];
                        s<<";";
                }
	        s<<root->point[K-1]<<"\" -> \"";
                for(int i=0; i<K-1; i++){
                        s<<root->right->point[i];
                        s<<";";
                }
 	        s<<root->right->point[K-1]<<"\";\n";
                exportTree_int<K>(root->right,s,count);
        }
	else{
		  s<<"\"";
               for(int i=0; i<K-1; i++){
                       s<<root->point[i];
                        s<<";";
                        }
               s<<root->point[K-1]<<"\" -> null"<<(*count)<<"; \n";
		(*count)++;
        }

}

template <int K>
void exportTree_intC(Node<K>* root, FILE *s , int* count){
        if(root->left!=nullptr){
                fprintf(s,"\"");
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->point[i]);
                }
                fprintf(s,"%f\" -> \"",root->point[K-1]);
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->left->point[i]);
                }
                fprintf(s,"%f\";\n",root->left->point[K-1]);
                exportTree_intC<K>(root->left,s,count);
        }
        else{
                fprintf(s,"\"");
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->point[i]);
                        }
		fprintf(s,"%f\" -> null%d;\n",root->point[K-1], *count);
                (*count)++;
        }
        if(root->right!=nullptr){
                fprintf(s,"\"");
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->point[i]);
                }
                fprintf(s,"%f\" -> \"",root->point[K-1]);
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->right->point[i]);
                }
                fprintf(s,"%f\";\n",root->right->point[K-1]);
                exportTree_intC<K>(root->right,s,count);
        }
        else{
                fprintf(s,"\"");
                for(int i=0; i<K-1; i++){
                        fprintf(s,"%f;",root->point[i]);
                        }
                fprintf(s,"%f\" -> null%d;\n",root->point[K-1], *count);
                (*count)++;
        }
}



template <int K>
void exportTree(Node<K>* root){
	std::ofstream out("tree.dot");
	out<<"strict digraph tree { \n";
	out<<"ordering=out\n";
	int a=0;
	int *p=&a;
	exportTree_int(root, out,p);
	out<<"}";
	out.close();

}


template <int K>
void exportTreeC(Node<K>* root){
	FILE *fp;        
 	fp=fopen("tree.dot","w");
        fprintf(fp,"strict digraph tree { \n");
        fprintf(fp,"ordering=out\n");
        int a=0;
        int *p=&a;
        exportTree_intC<K>(root, fp,p);
        fprintf(fp,"}");
        fclose(fp);

}


int main(int argc , char *argv[ ]){
	constexpr int K=2;
	int reorder=1;
	int rank;
	int numprocs;
	int size;
	int mergeflag;
	if(argc==1){
		size=100000000;
		mergeflag=2;
	} 
	if (argc==2){
		size=std::atoi(argv[1]);
		mergeflag=2;
	}
	if(argc>2){
		size=std::atoi(argv[1]);
		int mergeflag{std::atoi(argv[2])};
	}
	std::srand(unsigned(std::time(nullptr)));
	std::random_device rd;
    	std::mt19937 gen(rd());
	std::uniform_real_distribution<> dis(0,1);
	std::vector<std::array<float_t,K>> data(size);
	MPI_Init(&argc,&argv);
        MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	if (rank==0){
                for (auto it1 = data.begin(); it1 != data.end(); it1++) {
                        for (auto it2 = it1->begin(); it2 != it1->end(); it2++) {
                                *it2 = dis(gen); // dereference iterator, set the value
                        }
                }	
		Node<K> * root=build_tree<K>(data,0,0,mergeflag);
		adjustDepth<K>(root,0);
		//exportTree(root);
               	//printTree<K>(root);
		deleteTree<K>(root);

	}
	else{
		Node<K>* temp=create_treenode<K>(data,0,0,mergeflag);
	}
	MPI_Finalize();	
}
