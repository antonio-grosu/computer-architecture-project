.data
    v : .space 4096 # retinem 1024 * 4 btes
    formatScanf  : .asciz "%d"
    cerinta : .long 0
    # cerinta ADD
    formatPrintf : .asciz "%d \n"
    descriptor : .long 12
    dimensiune : .long 120

.text

.global main


main:
     # golim vectorul <-> initializam cu 0
    mov $1024, %ecx
    lea v, %edi
    rep stosb

    push %edi
    mov descriptor, %eax
    push %eax
    mov dimensiune, %eax
    push %eax
    call add
    add $12, %esp
    add $8, %esp
    jmp et_exit

add:

    push %ebp
    mov %esp, %ebp
    push %ebx               
    push %ecx
    push %edi
    mov 8(%ebp), %ebx #descriptor
    mov 12(%ebp), %eax #dimensiune
    xor %ecx, %ecx  

gaseste_spatiu:
    cmp $1024, %ecx
    je alocare_esuata


    mov $0, %edx

verifica_spatiu:
    cmp %ebx, %edx
    je update_memorie

    mov (%edi, %ecx, 4), %esi
    cmp $0, %esi
    jne pozitia_urmatoare

    inc %edx
    inc %ecx
    jmp verifica_spatiu

pozitia_urmatoare:
    inc %ecx
    jmp gaseste_spatiu

update_memorie:
    sub %edx, %ecx
    mov %ebx, %edx

loop_update_memorie:
    cmp $0, %edx
    je alocare_terminata
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    dec %edx
    jmp loop_update_memorie

alocare_terminata:
    mov %ecx, %eax  # return the position in %eax
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret

alocare_esuata:
    mov $-1, %eax
    jmp alocare_terminata   
et_exit:
    mov $1, %eax
    mov $0, %ebx
    int $0x80