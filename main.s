	.syntax unified
	.arch armv7

	.data
	result: .word 0   

	.text
	.thumb

	.global _start
	.type _start, %function
_start:
    @b main
    .global main
    .type main, %function
    .thumb_func
main:
    mov r0, #4  
    bl xor_operation  
    ldr r1, =result  
    str r0, [r1]  
    b  .  

xor_operation:
    mov r2, #0  
    @str r2, [r1] 
    mov r3, #0 
    
    xor_loop:
        cmp r3, r0
        beq xor_done   
        @ldr r2, [r1]  
        eor r2, r2, r3   
        add r3, r3, #1   
        b xor_loop  
    
    xor_done:
        mov r0, r2
        bx lr
	
