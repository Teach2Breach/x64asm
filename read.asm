includelib kernel32.lib

extrn __imp_GetStdHandle:proc
extrn __imp_WriteFile:proc
extrn __imp_ReadFile:proc
extrn __imp_CreateFileA:proc
extrn __imp_GetLastError:proc

.DATA
filename db "README.md", 0
buffer db 1024 dup(?)

.CODE
main PROC
    sub rsp, 40h    ; Reserve shadow space and align stack

    ; Create file handle for README.md
    lea rcx, filename
    mov rdx, 80000000h  ; GENERIC_READ
    xor r8, r8          ; No sharing
    xor r9, r9          ; No security attributes
    mov qword ptr [rsp+20h], 3  ; OPEN_EXISTING
    mov qword ptr [rsp+28h], 80h  ; FILE_ATTRIBUTE_NORMAL
    xor rax, rax
    mov [rsp+30h], rax  ; No template file
    call qword ptr __imp_CreateFileA
    
    ; Check if file opened successfully
    cmp rax, -1
    je error

    ; Save file handle
    mov rbx, rax

    ; Get stdout handle
    mov rcx, -11    ; STD_OUTPUT
    call qword ptr __imp_GetStdHandle
    mov r12, rax    ; Save stdout handle in r12

read_loop:
    ; Read from file
    mov rcx, rbx    ; File handle
    lea rdx, buffer ; Buffer to read into
    mov r8, 1024    ; Number of bytes to read
    lea r9, [rsp+38h] ; Address to store number of bytes read
    mov qword ptr [rsp+20h], 0 ; Overlapped structure (NULL)
    call qword ptr __imp_ReadFile

    ; Check if any bytes were read
    mov rax, [rsp+38h]
    test rax, rax
    jz close_file

    ; Write to console
    mov rcx, r12    ; Stdout handle
    lea rdx, buffer ; Buffer to write from
    mov r8, rax     ; Number of bytes to write
    lea r9, [rsp+38h] ; Address to store number of bytes written
    mov qword ptr [rsp+20h], 0 ; Overlapped structure (NULL)
    call qword ptr __imp_WriteFile

    jmp read_loop

close_file:
    ; Close file handle (omitted for brevity, but should be implemented)

    add rsp, 40h
    xor rax, rax    ; Return 0
    ret

error:
    ; Handle error (e.g., print error message)
    call qword ptr __imp_GetLastError
    ; ... code to print error message ...

    add rsp, 40h
    mov rax, 1      ; Return 1 to indicate error
    ret

main ENDP
END