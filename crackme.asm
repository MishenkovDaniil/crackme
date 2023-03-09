.286
.model tiny 
.code
locals @@
org 100h

include         ../macros/vidmem.asm 
include         ../macros/exit.asm 
len             equ 8 

Start:
            LoadVideoES
            call clean_screen
            push ds 
            pop es 

            mov ah, 0ah
            mov dx, offset buff 
            int 21h 

            mov di, offset buff
            add di, 2
            lea si, password 
            call check_password 

            Exit 

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

include             ../frame/new_fr.asm 
include             ../frame/f_clean.asm

.data
buff            db 32h, 9 dup (0)
password        db '0123456'
deny_msg        db "20 2 40 20 FC 1 'access denied!'"
password_len    dw 'G'
grant_msg       db "20 2 40 20 F2 1 'access granted!'"

end         Start 
