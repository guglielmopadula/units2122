#include "stack_pool.hpp"
#include <chrono>
#include <iostream>
#include <stack>
#include <list>
int main(){
	stack_pool<int> pool(5000000);
	std::size_t a=pool.new_stack();
	std::list<int> stack;
	std::list<int> stack2;
	auto custpush0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		a=pool.push(i,a);
	}
	a=pool.free_stack(a);
	std::size_t b=pool.new_stack();
	for (int i=2500000;i>0; i=i-1){
		a=pool.push(i,a);
	}


	for (int i=2500000;i>0; i=i-1){
		b=pool.push(i,b);
	}


	auto custpush1 = std::chrono::high_resolution_clock::now();
	auto custpushelapsed=std::chrono::duration_cast<std::chrono::microseconds>(custpush1 - custpush0);
    	std::cout << "custom stack push time: [" << custpushelapsed.count() << " us]" << std::endl;
	
	auto defpush0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		stack.push_front(i);
	}

	for (int i=5000000;i>0; i=i-1){
		stack.pop_front();
	}

	for (int i=2500000;i>0; i=i-1){
		stack2.push_front(i);
	}

	for (int i=2500000;i>0; i=i-1){
		stack.push_front(i);
	}

	auto defpush1 = std::chrono::high_resolution_clock::now();
	auto defpushelapsed=std::chrono::duration_cast<std::chrono::microseconds>(defpush1 - defpush0);
    std::cout << "default stack push time: [" << defpushelapsed.count() << " us]" << std::endl;
	// push of the custom is around 7 times slower the std::stack one 

}