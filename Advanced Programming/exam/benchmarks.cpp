#include "stack_pool.hpp"
#include <chrono>
#include <iostream>
#include <stack>
int main(){
	stack_pool<int> pool(50);
	std::size_t a=pool.new_stack();
	std::stack<int> stack;

		auto custpush0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		a=pool.push(i,a);
	}
	auto custpush1 = std::chrono::high_resolution_clock::now();
	auto custpushelapsed=std::chrono::duration_cast<std::chrono::microseconds>(custpush1 - custpush0);
    	std::cout << "custom stack push time: [" << custpushelapsed.count() << " us]" << std::endl;
	auto defpush0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		stack.push(i);
	}
	auto defpush1 = std::chrono::high_resolution_clock::now();
	auto defpushelapsed=std::chrono::duration_cast<std::chrono::microseconds>(defpush1 - defpush0);
    std::cout << "default stack push time: [" << defpushelapsed.count() << " us]" << std::endl;
	// push of the custom is around 7 times slower the std::stack one 



	auto custpop0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		a=pool.pop(a);
	}
	auto custpop1 = std::chrono::high_resolution_clock::now();
	auto custpopelapsed=std::chrono::duration_cast<std::chrono::microseconds>(custpop1 - custpop0);
    	std::cout << "custom stack pop time: [" << custpopelapsed.count() << " us]" << std::endl;
	auto defpop0 = std::chrono::high_resolution_clock::now();
	for (int i=5000000;i>0; i=i-1){
		stack.pop();
	}
	auto defpop1 = std::chrono::high_resolution_clock::now();
	auto defpopelapsed=std::chrono::duration_cast<std::chrono::microseconds>(defpop1 - defpop0);
    std::cout << "default stack pop time: [" << defpopelapsed.count() << " us]" << std::endl;
	// pop of the custom is around 2 times slower the std::stack one 


}
