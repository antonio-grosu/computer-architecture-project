.data
    v : .space 4096 # retinem 1024 * 4 btes
    formatScanf  : .asciz "%d"
    cerinta : .space 4
    nrCerinte : .space 4

    # cerinta ADD
    formatPrintfADD : .asciz "%d: (%d, %d)\n"
    formatPrintfADDFail : .asciz "%d: (0, 0)\n"
    descriptor : .space 4
    dimensiune : .space 4
    nrAdd : .space 4


.text

.global main


main:

     # golim vectorul <-> initializam cu 0
    mov $1024, %ecx
    lea v, %edi
    rep stosb

    lea nrCerinte, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

loop:
    cmp $0, nrCerinte
    je et_exit

    dec nrCerinte
    lea cerinta, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

    cmp $1, cerinta
    je et_start_add

et_start_add:
    lea nrAdd, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp
et_loop_add:

    cmp $0, nrAdd
    jle et_exit

    dec nrAdd
    #citire descriptor
    lea descriptor, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

    #citire dimensiune
    lea dimensiune, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp


    # calculare dimensiune / 8
    xor %edx, %edx
    mov dimensiune, %eax
    mov $8, %ecx
    div %ecx
    cmp $0, %edx
    je fara_increment
    inc %eax
fara_increment:
   mov %eax, dimensiune 
    push %edi
    mov descriptor, %eax
    push %eax
    mov dimensiune, %eax
    push %eax
    call add
    add $12, %esp

    # afisare
    cmp $-1, %eax
    je et_afisare_esuata_add
    jne et_afisare_add
    jmp et_loop_add


et_afisare_esuata_add:
    mov descriptor, %eax
    push %eax
    push $formatPrintfADDFail
    call printf
    add $8, %esp
    jmp et_loop_add
et_afisare_add:
    mov descriptor, %ecx
    mov %eax, %ebx
    dec %eax
    sub dimensiune, %ebx
    push %eax
    push %ebx
    push %ecx
    push $formatPrintfADD
    call printf
    add $16, %esp
    jmp et_loop_add

add:

    push %ebp # setez cadrul curent
    mov %esp, %ebp
    push %ebx               #salvez registrii pe care ii folosessc
    push %ecx
    push %edi
    mov 8(%ebp), %ebx #dimensiune
    mov 12(%ebp) , %eax #descriptor
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
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80