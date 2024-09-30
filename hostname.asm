includelib kernel32.lib

; External function declarations
extern GetComputerNameA: proc
extern GetStdHandle: proc
extern WriteConsoleA: proc
extern ExitProcess: proc

.DATA
buffer db 256 dup(?)
bufferSize dq 256
consoleMsg db "Hostname: ", 0
consoleMsgLen dq $ - consoleMsg - 1
bytesWritten dq ?

.CODE
main PROC
    sub rsp, 40h    ; Reserve shadow space and align stack

    ; Get hostname
    lea rcx, buffer
    lea rdx, bufferSize
    call GetComputerNameA
    test rax, rax
    jz error

    ; Get console handle
    mov rcx, -11    ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov rbx, rax    ; Save console handle

    ; Print "Hostname: " message
    mov rcx, rbx
    lea rdx, consoleMsg
    mov r8, [consoleMsgLen]
    lea r9, bytesWritten
    xor rax, rax
    mov [rsp+20h], rax  ; Reserved parameter (NULL)
    call WriteConsoleA

    ; Print actual hostname
    mov rcx, rbx
    lea rdx, buffer
    mov r8, [bufferSize]
    lea r9, bytesWritten
    xor rax, rax
    mov [rsp+20h], rax  ; Reserved parameter (NULL)
    call WriteConsoleA

    jmp exit

error:
    ; Handle error (you could print an error message here)

exit:
    add rsp, 40h
    xor rcx, rcx    ; Exit code 0
    call ExitProcess

main ENDP
END