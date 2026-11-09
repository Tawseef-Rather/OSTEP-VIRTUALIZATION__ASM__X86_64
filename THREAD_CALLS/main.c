#include    <stdio.h>
#include    <unistd.h>
#include    "threads.h"
#include    <pthread.h>

int counter = 0;

char stack1[8192] __attribute__((aligned(16)));
void *stack_top1 = stack1 + sizeof(stack1);

char stack2[8192] __attribute__((aligned(16)));
void *stack_top2 = stack2 + sizeof(stack2);

unsigned int flags = 0x00310F00;
int parent_pid1;
int child_tid1;
int parent_pid2;
int child_tid2;


void *worker1(void *__arg){
    for (int i = 0; i < 5; i++){
        sleep(1);
        write(1, "Thread 1\n", 10);
        counter++;
    }
    pthread_exits();

    const char *msg = "This is the child 1!\n";
    write(1, msg, 22);
    return NULL;
}

void *worker2(void *__arg){
    for (int i = 0; i < 5; i++){
        sleep(1);
        write(1, "Thread 2\n", 10);
        counter++;
    }
    const char *msg = "This is the child 2!\n";
    write(1, msg, 22);
    return NULL;
}
int main(int argc, char *argv[]){
    tid_t rc1 = pthread_creates(flags, stack_top1, &parent_pid1, &child_tid1, worker1);
    tid_t rc2 = pthread_creates(flags, stack_top2, &parent_pid2, &child_tid2, worker2);

    if (rc1 == -1 || rc2 == -1) {
        perror("Error creating the thread!\n");
        return 1;
    }
    pthread_joins(&child_tid1);
    pthread_joins(&child_tid2);

    printf("The parent finished waiting and the counter = %d\n", counter);
    return 0;
}