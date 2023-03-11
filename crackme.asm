.286
.model tiny 
.code
locals @@
org 100h

include         ../macros/vidmem.asm 
include         ../macros/exit.asm 
len             equ 44h
sum_start       equ 33d

Start:
            LoadVideoES
            call clean_screen
            push ds 
            pop es 

            mov ah, 0ah
            mov dx, offset buff 
            int 21h 

            mov di, dx
            inc di
            mov bx, offset str_len 
            mov cl, byte ptr [bx]
            call hash  

            mov bx, offset buff_hash
            mov word ptr [bx], dx 
            mov word ptr [bx + 2], ax 
            
            mov di, offset buff_hash
            lea si, password 
            call check_password 

            Exit 

;-----------------------------------
;hash the given string
;-----------------------------------
;Entry: DI = attr: start of string
;       CL = attr: len of str 
;Exit:  DX:AX = hash_sum
;Destroys: BX, CL, DI
;-----------------------------------
hash                proc 

                    xor dx, dx

                    xor ah, ah 
                    mov al, sum_start

                    xor bh, bh 

@@next: 
                    mov bl, byte ptr [di]
                    
                    add ax, dx
                    mov bh, dl
                    mul bx
                    
                    inc di
                    dec cl 

                    cmp cl, 0
                    jne @@next  


                    ret
                    endp 
;-----------------------------------

;-----------------------------------
;checks if input password is correct or not
;-----------------------------------
;Entry: SI := attr: start addr of password 
;       DI := attr: start addr of input data
;Exit: None
;Destroys: AX, BX, CX, DX, SI, DI, BP, ES 
;-----------------------------------
check_password      proc

                    mov cx, len 
                    inc cx 

@@check:            dec cx
                    cmp cx, 0
                    je @@good_check
                    
                    dec di 
                    dec si 

                    mov al, byte ptr [si]
                    cmp byte ptr [di], al 
                    
                    inc di
                    inc si 
                    jne @@check
                    jmp @@check 

@@good_check:
                    mov bx, offset password_len 
                    mov cx, [bx]
                    xor ch, ch
                    sub cl, 40h
                    

                    repe cmpsb 
                    jne @@access_denied
                    jmp @@access_granted 

@@access_granted:   
                    LoadVideoES
                    mov bx, offset grant_msg
                    call Frameprint 
                    jmp @@end 

@@access_denied:    
                    LoadVideoES
                    mov bx, offset deny_msg
                    call Frameprint

@@end:
                    ret
                    endp 
;-----------------------------------

include             ../frame/new_fr.asm 
include             ../frame/f_clean.asm

.data
buff            db 32h, 9 dup (0)
str_len         db 5d
password        db 0DFh, 15h, 0EDh, 9Eh               ;0123
deny_msg        db "20 2 40 20 FC 1 'access denied!'"
password_len    dw 44h
grant_msg       db "20 2 40 20 F2 1 'access granted!'"
buff_hash       db 4 dup (0)

end         Start 
