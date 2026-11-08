; This is a basic implementation of the KERNEL thread creation
; we create 8 threads and use a struc to handle all the threads
; This may lack synchronization and optimization
; later we can update this code to make that threads come in the random
; You can add synchronization later to this code to make work better
; you may like the LINUX KERNEL and x86_64 ASM coding

default rel
global _start

thread_size equ 40
limit equ 8

section .data
    msg db "ALL 8 THREADS FINISHED!", 10
    len equ $ - msg
    
    t0_msg db "THREAD IS RUNNING!", 10
    t0_len equ $ - t0_msg


; struc threads \ same as the struct task{} in the Linux KERNEL 
struc threads
    .tid:                   resq 1
    .stack_base:            resq 1
    .stack_size:            resq 1
    .status:                resq 1
    .result:                resq 1
endstruc

; un-initialized variables that are decided during run-time
section .bss
    thread: resb 8 * thread_size

    counter resd 1
    done resd 1

    parent_tid resq 1
    child_tid resq 1

    ; stack
    stack resb 8 * 8192                 ; 8KB stack for each thread
    stack_base:                         ; label holds the stacks base address


section .text
_start:
    mov dword [counter], 0
    mov dword [done], 0

.loop:
    ; THE LOOP START
    mov r15d, [counter]             ; the r15 holds the counter
    inc r15d                        ; increment the counter by 1

    mov dword [counter], r15d       ; mov the value back to the counter
    
    ; Calculate unique stack: rsi = stack_base - (counter * 8192)
    mov rax, 8192
    imul rax, r15                   ; rax = counter * 8192
    lea rsi, [stack_base]
    sub rsi, rax                    ; Each thread now gets its own isolated stack pointer area! 
    mov r12, rsi                    ; The stack base to the r12 register

    ; THE THREAD CREATION PART
    mov rax, 56                     ; mov the syscall number clone to the rax 
    mov rdi, 0x00010F00             ; mov the flags to the rdi register
    mov rdx, parent_tid             ; the parents tid
    mov r10, child_tid              ; write the childs tid

    ;syscall
    syscall

    cmp rax, 0                      ; clone return 0 to child in rax
    je t0                           ; jump to child code
    mov r10, [child_tid]            ; move child_tid to r10
    
    ; MOVE THE DATA OF THE THREAD TO ITS STRUC
    mov rax, thread_size
    mov rdi, [counter]
    sub rdi, 1
    imul rax, rdi ; calculate thread address

    mov qword [thread + rax + threads.tid], r10 ; mov the tid
    mov qword [thread +  rax + threads.stack_base], r12 ; mov the stack_base
    mov qword [thread + rax + threads.stack_size], 8192 ; mov the stack size

    ; THE DECISION PART
    cmp r15, limit          ; is rcx [counter] < limit
    jl .loop                ; if yes go to the loop again
    je wait_loop            ; jump to the parent code

wait_loop:
.l00p:
    pause                   ; pause the execution for a moment
    mfence                  ; clear out the registers and update RAM

    mov rax, [counter]
    mov rdi, limit

   ; Decision part 
    cmp rax, rdi
    je parent_code
    jle .l00p

; invokes KERNEL sys_write and puts the FD=1 -> to the monitor
sys_write:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

t0:
    ; PRINT SYSCALL
    mov rsi, t0_msg
    mov rdx, t0_len
    call sys_write

    ; MOV A DUMMY RESULT TO THE TCB OF THE THREADS
    mov rax, [counter]
    sub rax, 1
    imul rax, thread_size
    mov qword [thread + rax + threads.result], 100 ; a dummy result
    mov rdi, [thread + rax + threads.result]

    ; EXIT SYSCALL
    mov rax, 60
    syscall

parent_code:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall
    
    mov rax, 60
    mov rdi, 101
    syscall