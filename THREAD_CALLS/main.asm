; In this file we will do such basic things
; Create the C/POSIX thread calls such as pthread_create, join, exit
; We use the same clone() sys_call
; We use C with this to make real threads
; This might make you close to think how a KERNEL works
; We use x86_64 ASM - NASM assembler


default rel
global          pthread_creates
global          pthread_joins
global          pthread_exits

section .bss
    thread_tid_futex resq 1

section .text

pthread_creates:
    mov r10, rcx          ; child_tidptr
    mov rdx, rcx          ; parent_tidptr = child_tidptr

    mov eax, 56           ; SYS_clone
    syscall

    test rax, rax
    jz child
    js error

parent:
    ret

child:
    call r8

    xor edi, edi
    mov eax, 60            ; SYS_exit
    syscall

error:
    ret

; pthread_joins()
pthread_joins:
.wait_loop:
    mov edx, dword [rdi]
    test edx, edx
    jz .cleanup

    mov eax, 202
    xor esi, esi
    xor r10d, r10d
    syscall
    jmp .wait_loop

.cleanup:
    ret

; This is the implementation of destroying a thread by its tid
; Dont use this function as this will terminate the entire process
; Because in the Linux all signals kill the entire process
pthread_exit:
    ; in rsi we need the actual tid of the thread to kill
    mov rax, 39     ; to get the thread_group_id
    syscall
    mov rsi, rdi
    mov rdi, rax    ; the group_tid must be in rdi
    mov rdx, 9      ; SIGKILL must be in rdx
    mov rax, 234    ; SYS_EXIT
    
    syscall


; use this as this will just terminate the calling thread
pthread_exits:
    mov rax, 60
    xor rdi, rdi
    syscall