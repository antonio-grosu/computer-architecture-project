
.data
    v: .space 4096 # retinem 1024 * 4 bytes
    formatScanf: .asciz "%d"
    cerinta: .space 4
    nrCerinte: .space 4
    # cerinta ADD
    formatPrintfADD: .asciz "%d: (%d, %d)\n"
    formatPrintfADDFail: .asciz "%d: (0, 0)\n"
    descriptor: .space 4
    dimensiune: .space 4
    nrAdd: .space 4

    # cerinta GET
    formatPrintfGETFail : .asciz "(0, 0)\n"
    formatPrintfGET: .asciz "(%d, %d)\n"
    startInterval: .space 4
    sfInterval: .space 4

    # procedura afisare_memorie
    descriptorMemorie: .space 4
    startDescriptorMemorie: .space 4
    sfDescriptorMemorie: .space 4
    formatPrintfMemorie: .asciz "%d: (%d, %d)\n"


.text

.global main

main:
    lea v, %edi
    mov $0, %eax
    xor %ecx, %ecx

    # intializarea array ului cu 0
et_vector:
    cmp $1024, %ecx
    je et_start
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    jmp et_vector
et_start:
    xor %eax, %eax
    xor %ebx, %ebx
    xor %ecx, %ecx
    lea nrCerinte, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp


# loop pentru cerintele din input
loop:
    mov nrCerinte, %eax
    cmp $0, %eax
    je et_exit

    dec nrCerinte
    lea cerinta, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp
    mov cerinta, %eax
    cmp $1, %eax
    cmp $1, cerinta
    je et_start_add

   cmp $2, %eax
    je et_start_get

    cmp $3, %eax
    je et_start_delete

    cmp $4, %eax
    je et_start_defrag

# ----------------- PROCEDURA AFISARE MEMORIE -----------------

# ca sa afisez memoria ma folosesc de get

# asa aflu start ul si endul unui descriptor nou gasit si pur si simplu le afisez
afisare_memorie:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %ecx
    push %edi
    xor %ecx, %ecx
    xor %edx, %edx
    lea v, %edi
    mov $0, %ebx
    mov $0, %eax

loop_memorie:
    cmp $1024, %ecx
    je ret_memorie

    mov (%edi, %ecx, 4), %edx
    mov %ecx, %eax
    dec %eax

    mov (%edi, %eax, 4), %ebx
    cmp %edx, %ebx
    jne update_descriptor
    
    inc %ecx
    jmp loop_memorie


update_descriptor:

    cmp $0, %edx
    je intoarce_loop
    mov %edx, descriptorMemorie

    push %ecx
  

    push descriptorMemorie
    call get_inceput
    add $4, %esp
    
    mov %eax, startDescriptorMemorie

    push descriptorMemorie
    call get_end
    add $4, %esp

    mov %eax, sfDescriptorMemorie

    push sfDescriptorMemorie
    push startDescriptorMemorie
    push descriptorMemorie
    push $formatPrintfMemorie
    call printf
    add $16, %esp

    

    pop %ecx
    inc %ecx
    jmp loop_memorie

intoarce_loop:
    inc %ecx
    jmp loop_memorie
ret_memorie:

   pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret



# ----------------- DEFRAG -----------------
et_start_defrag:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %ecx
    push %edi
    xor %ecx, %ecx
    xor %edx, %edx
    lea v, %edi
    mov $0, %ebx
    mov $0, %eax

parcurgere_defrag:
    cmp $1024, %ecx
    je terminare_defrag

    mov (%edi, %ecx, 4), %eax
    cmp $0, %eax
    jne diferit_de_0_defrag

    mov %ecx, %ebx
    inc %ebx
gaseste_diferit_de_0_defrag:
    cmp $1024, %ebx
    je terminare_defrag

    mov (%edi, %ebx, 4), %eax
    cmp $0, %eax
    jne swap_valori

    inc %ebx
    jmp gaseste_diferit_de_0_defrag

swap_valori:
    mov %eax, (%edi, %ecx, 4)
    mov $0, (%edi, %ebx, 4)

diferit_de_0_defrag:
inc %ecx
jmp parcurgere_defrag

terminare_defrag:
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    call afisare_memorie
    jmp loop
# ----------------- DELETE -----------------

# pun 0 acolo unde poz din vecotr este egala cu descriptorul meu

et_start_delete:
    lea descriptor, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

    mov descriptor, %eax
    push %eax
    call delete
    add $4, %esp

    call afisare_memorie
    jmp loop




delete:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %ecx
    push %edi
    mov 8(%ebp), %eax # descriptor ul pe care il caut
    xor %ecx, %ecx
    xor %edx, %edx

start_cautare_delete:
    cmp $1024, %ecx
    je ret_delete
    mov (%edi, %ecx, 4), %edx
    cmp %eax, %edx
    je gasit_delete

    inc %ecx
    jmp start_cautare_delete
gasit_delete:
    mov $0, %edx
    mov %edx, (%edi, %ecx, 4)

    inc %ecx
    jmp start_cautare_delete

ret_delete:
    mov $1, %eax
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret
# ----------------- GET -----------------

et_start_get:
    lea descriptor, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

    mov descriptor, %eax
    push %eax
    call get_inceput
    add $4, %esp

    cmp $-1, %eax
    je et_afisare_esuata_get
    
    mov %eax, startInterval

    push %eax # start interval
    mov descriptor, %eax
    push %eax # descriptor 

    call get_end
    add $4, %esp

    cmp $-1, %eax
    je et_afisare_esuata_get

    mov %eax, sfInterval
    jne et_afisare_get

et_afisare_esuata_get:
    push $formatPrintfGETFail
    call printf
    add $4, %esp
    jmp loop

et_afisare_get:
    push sfInterval
    push startInterval
    push $formatPrintfGET
    call printf
    add $12, %esp
    jmp loop
# caut unde incepe descriptorul
get_inceput:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %ecx
    push %edi
    mov 8(%ebp), %eax # descriptor ul pe care il caut
    xor %ecx, %ecx
    xor %edx, %edx

start_cautare_inceput:
    cmp $1024, %ecx
    je get_inceput_esuat

    mov (%edi, %ecx, 4), %edx
    cmp %eax, %edx
    je gasit_inceput
    inc %ecx
    jmp start_cautare_inceput

gasit_inceput:
    mov %ecx, %eax
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret

get_inceput_esuat:
    mov $-1, %eax
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret



# caut dimensiunea

get_end:
    push %ebp
    mov %esp, %ebp
    push %ebx
    push %ecx
    push %edi
    mov 8(%ebp), %eax # descriptor ul pe care il caut
    mov 12(%ebp), %ebx # inceputul intervalului
    mov %ebx, %ecx
    xor %edx, %edx

# caut unde se termina incepand cu inceputul intervalului si apoi returnez indexul final
start_cautare_sf:
    cmp $1024, %ecx
    je ret_sf
    mov (%edi, %ecx, 4), %edx
    cmp %eax, %edx
    jne ret_sf
    inc %ecx
    jmp start_cautare_sf

# returnez indexul final
ret_sf:
    dec %ecx
    mov %ecx, %eax
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret    
et_start_add:
    lea nrAdd, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp
    
# ----------------- ADD -----------------
et_loop_add:

    cmp $0, nrAdd
    je loop

    dec nrAdd
    # citire descriptor
    lea descriptor, %eax
    push %eax
    push $formatScanf
    call scanf
    add $8, %esp

    # citire dimensiune
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
    push %ebx               # salvez registrii pe care ii folosessc
    push %ecx
    push %edi
    mov 8(%ebp), %ebx # dimensiune
    mov 12(%ebp) , %eax # descriptor
    xor %ecx, %ecx  
    cmp $1024, %ebx
    jg alocare_esuata

gaseste_spatiu:
    cmp $1024, %ecx
    jge alocare_esuata

    mov $0, %edx

# faza este ca am nevoie de ceva care verifica daca nu am gasit suficient spatiu ca sa bag in memeorie \
# si sa ma duca in alocare esuata

et_verifica_spatiu:
    cmp %ebx, %edx
    jge et_update_memorie

    cmp $1024, %ecx
    jge alocare_esuata
    mov (%edi, %ecx, 4), %esi
    cmp $0, %esi
    jne pozitia_urmatoare

    inc %edx
    inc %ecx
    jmp et_verifica_spatiu

pozitia_urmatoare:
    mov $0, %edx
    inc %ecx
    jmp gaseste_spatiu

et_update_memorie:
    sub %edx, %ecx
    mov %ebx, %edx

loop_update_memorie:
    cmp $0, %edx
    je alocare_terminata
    mov %eax, (%edi, %ecx, 4)
    inc %ecx
    sub $1, %edx
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
    pop %edi
    pop %ecx
    pop %ebx
    pop %ebp
    ret


et_exit:
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80   