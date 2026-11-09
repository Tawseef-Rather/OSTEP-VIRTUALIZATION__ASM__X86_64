#ifndef         __THREADS_H__
#define         __THREADS_h__

typedef __uint32_t tid_t;

// Creates a child thread and returns its tid
extern tid_t pthread_creates(unsigned long flags, void *stack_base,int *parent_tid, int *child_tid, void *(*function)(void *));
//parent waits for the child
extern void pthread_joins(int *child_tid);
// destroys the calling thread
extern void pthread_exits(void);
#endif
