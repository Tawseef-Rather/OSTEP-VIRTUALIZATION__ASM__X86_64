#ifndef         __THREADS_H__
#define         __THREADS_h__

typedef __uint32_t tid_t;


// Creates a child thread and returns its tid
extern tid_t pthread_creates(unsigned long flags, void *stack_base,int *parent_tid, int *child_tid, void *(*function)(void *));

extern void pthread_joins(int *child_tid);

extern void pthread_exits(void);
#endif