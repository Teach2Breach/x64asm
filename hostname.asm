includelib kernel32.lib

extrn __imp_GetComputerNameA:proc
extrn __imp_GetStdHandle:proc
extrn __imp_WriteConsoleA:proc
extrn __imp_ExitProcess:proc

.DATA
buffer db 256 dup(?)
bufferSize dq 256
consoleMsg db "Hostname: ", 0
consoleMsgLen dq $ - consoleMsg - 1
bytesWritten dq ?

; without api hashing

.CODE
main PROC
    sub rsp, 40h    ; Reserve shadow space and align stack

    ; Get hostname
    lea rcx, buffer
    lea rdx, bufferSize
    call qword ptr __imp_GetComputerNameA
    test rax, rax
    jz error

    ; Get console handle
    mov rcx, -11    ; STD_OUTPUT_HANDLE
    call qword ptr __imp_GetStdHandle
    mov rbx, rax    ; Save console handle

    ; Print "Hostname: " message
    mov rcx, rbx
    lea rdx, consoleMsg
    mov r8, [consoleMsgLen]
    lea r9, bytesWritten
    xor rax, rax
    mov [rsp+20h], rax  ; Reserved parameter (NULL)
    call qword ptr __imp_WriteConsoleA

    ; Print actual hostname
    mov rcx, rbx
    lea rdx, buffer
    mov r8, [bufferSize]
    lea r9, bytesWritten
    xor rax, rax
    mov [rsp+20h], rax  ; Reserved parameter (NULL)
    call qword ptr __imp_WriteConsoleA

    jmp exit

error:
    ; Handle error (you could print an error message here)

exit:
    add rsp, 40h
    xor rcx, rcx    ; Exit code 0
    call qword ptr __imp_ExitProcess

main ENDP
END