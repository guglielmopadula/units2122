#include <cassert>
#include <algorithm> 
#include <iostream>
#include <vector>


template<typename T,typename N> 
class stack_pool;

template<typename T,typename N> 
class _iterator{
	
    stack_pool<T,N>* pool_ptr;
    N index;
    public:
    using value_type = T;
    using stack_type = N;
    using reference = value_type&;
    using pointer = value_type*;
    using difference_type = std::ptrdiff_t;
    using iterator_category = std::forward_iterator_tag;
     _iterator( stack_pool<T,N>* _pool_ptr, N i) : pool_ptr{_pool_ptr}, index{i}  {}
    reference operator*() noexcept { return pool_ptr->value(index); }
    _iterator& operator++() noexcept {  // pre-increment
        index=pool_ptr->next(index);
        return *this;
    }

    _iterator& operator++(int) noexcept {  // post-increment
        auto tmp=*(this);
        ++(*this);
        return tmp;
    }
   
  friend bool operator==(const _iterator& x, const _iterator& y) noexcept {
    return x.index == y.index;
  }

  friend bool operator!=(const _iterator& x, const _iterator& y) noexcept {
    return !(x == y);
  }

 friend std::ostream& operator<<(std::ostream& os, const _iterator<T,N>& v) noexcept{
        os<<v.index<<std::endl;
        return os;
}
};


template <typename T, typename N = std::size_t>
class stack_pool{
    struct node_t{
        T value;
        N next; 

        node_t(): value{T()}, next{N(0)}  {}

    };
    std::vector<node_t> pool;
    using stack_type = N;
    using value_type = T;
    using size_type = typename std::vector<node_t>::size_type;
    stack_type free_nodes; // at the beginning, it is empty
    node_t& node(stack_type x) noexcept { return pool[x-1]; }
    const node_t& node(stack_type x) const noexcept { return pool[x-1]; }
	size_type size;

template<typename X>
    stack_type _push(X&& val, stack_type head){
        if(free_nodes==end()){
            pool.emplace_back(std::move(node_t()));
            free_nodes=pool.size();
        }
        auto a=free_nodes;
        free_nodes=next(free_nodes);
        next(a)=head;
        value(a)=std::forward<X>(val);
        return a;
    };

    template<typename X>
    stack_type _vecpush(X&& val, stack_type head){
        for (value_type x : val){
            head=_push(x,head);
        }    
        return head;
    };

    public:
        stack_pool() noexcept {
        free_nodes=end();
        };
    void reserve(size_type n){
        /**
         * @brief reserves some space in the pool
         * 
         * @param n size of the space reserved
         * 
         */
        pool.reserve(n);
        return;
    }; 

   void resize(size_type n){
       /**
        * @brief resizes the pool
        * 
        * @param n new size of the pool
        * 
        */
        pool.resize(n);
        return;
    }; 

    explicit stack_pool(size_type n){
        reserve(n);
        free_nodes=end();
     };



    using iterator = _iterator<T,N>;
    using const_iterator = _iterator<const T,N>;
    
    iterator begin(stack_type x) noexcept {
                /**
         * @brief Returns an iterator to the stack index x 
         * 
         * @param x the stack index
         * 
         * 
         * 
         */

        return iterator{this, x};
    };
    
    iterator end(stack_type) noexcept {
        /**
         * @brief Returns an iterator to the end of the stack
         * 
         * 
         * 
         * 
         */

        return iterator{this, stack_type(0)};
    }


    const_iterator begin(stack_type x) const noexcept{
                        /**
         * @brief Returns a const iterator to the stack index x 
         * 
         * @param x the stack index
         * 
         * 
         * 
         */

        return  const_iterator{this,x};
    };
    const_iterator end(stack_type ) const noexcept{
                /**
         * @brief Returns a const iterator to the end of the stack
         * 
         * 
         * 
         * 
         */

        return  const_iterator{&node(end()),&pool,stack_type(0)};
    }; 
    const_iterator cbegin(stack_type x) const noexcept{
        /**
         * @brief Returns a cost iterator to the stack index x 
         * 
         * @param x the stack index
         * 
         * 
         * 
         */
        return  const_iterator{this, x};
    };
    const_iterator cend(stack_type ) const noexcept{
        /**
         * @brief Returns a const iterator to the end of the stack
         * 
         * 
         * 
         * 
         */

        return const_iterator{this,&pool, stack_type(0)};
    }; 
    

    stack_type new_stack() noexcept{
        /**
         * @brief returns an empty stack
         * 
         */
        return stack_type(0);
    }; 
    
    size_type capacity() const noexcept{
        /**
         * @brief returns the capacity of the pool
         * 
         */
        return pool.capacity();
    }; 

    stack_type end() const noexcept { return stack_type(0); }
    
    
    bool empty(stack_type x) const noexcept{
        /**
         * @brief checks that a given stack is empty
         * 
         * @param x the stack
         * 
         */
        return x==end();
    }; 

    stack_type push( const T& val, stack_type head){
        /**
         * @brief Pushes a given element to the stack 
         * 
         * @param val the element
         * 
         * @param head the head of the stack
         * 
         */

        return _push(val,head);
    };
    stack_type push(T&& val, stack_type head){
                /**
         * @brief Pushes a given element to the stack 
         * 
         * @param val the element
         * 
         * @param head the head of the stack
         * 
         */

        return _push(std::move(val),head);
    };  


    stack_type pop(stack_type x) noexcept{
        /**
         * @brief deletes the first node of a stack
         * 
         * @param x the stack
         */
        auto temp=node(x).next;
        node(x).next=free_nodes;
        free_nodes=x;
        return temp;
    }; 

    stack_type free_stack(stack_type x) noexcept{
        /**
         * @brief deletes a stack
         * 
         */
              auto temp=x;
        while(temp!=end()){
            auto temp1=node(temp).next;
            node(temp).next=free_nodes;
            free_nodes=temp;
            temp=temp1;
        }
        return temp;

    }; 

    void print_stack(stack_type x) noexcept{
                /**
         * @brief prints a stack
         * 
         * @param x the stack
         */

        auto temp=x;
        while (temp!=0){
            std::cout<<value(temp)<<std::endl;
            temp=next(temp);
        }
    }

     T& value(stack_type x) noexcept {
        /**
         * @brief returns the value of a node of the pool
         * 
         * @param x the node
         */
        return node(x).value;
    };

    const T& value(stack_type x) const noexcept{
        /**
         * @brief returns the value of a node of the pool
         * 
         * @param x the node
         */

        return node(x).value;
    };

    const stack_type& next(stack_type x) const noexcept{
        /**
         * @brief returns the pointed node by a node
         * 
         * @param x the node
         */

        return node(x).next;
    };

    stack_type& next(stack_type x) noexcept {
        /**
         * @brief returns the pointed node by a node
         * 
         * @param x the node
         */
        return node(x).next;

    };

    template<class... Args>
    stack_type emplace(stack_type head,Args&&... args) {
        /**
         * @brief pushes the elements of a variable pack
         * 
         * @param head the head of the stack
         * 
         * 
         * @param args the variable pack
         */
        for (value_type x : std::vector<T>{std::forward<Args>(args)...}){
            head=_push(x,head);
        }    
        return head;
    }

};
