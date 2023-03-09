.286
.model tiny 
.code
locals @@
org 100h

include         ../macros/vidmem.asm 
include         ../macros/exit.asm 

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
;Destroys: None
;-----------------------------------
check_password      proc

                    mov cx, 7

                    repe cmpsb 
                    jne @@access_denied 

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
buff        db 10h, 8 dup (0)
password    db '0123456'
deny_msg    db "20 2 40 20 CC 1 'access denied!'"
grant_msg   db "20 2 40 20 F2 1 'access granted!'"

end         Start 
