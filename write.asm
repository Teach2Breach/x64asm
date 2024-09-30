includelib kernel32.lib

extrn __imp_GetStdHandle:proc
extrn __imp_WriteFile:proc
extrn __imp_ReadFile:proc
extrn __imp_CreateFileA:proc
extrn __imp_GetLastError:proc

.DATA
filename db "test.txt", 0  ; Change filename to test.txt
buffer db "proof", 0       ; Change buffer to contain "proof"

.CODE
main PROC
    sub rsp, 40h    ; Reserve shadow space and align stack

    ; Create file handle for test.txt
    lea rcx, filename
    mov rdx, 40000000h  ; GENERIC_WRITE instead of GENERIC_READ
    xor r8, r8          ; No sharing
    xor r9, r9          ; No security attributes
    mov qword ptr [rsp+20h], 2  ; CREATE_ALWAYS instead of OPEN_EXISTING
    mov qword ptr [rsp+28h], 80h  ; FILE_ATTRIBUTE_NORMAL
    xor rax, rax
    mov [rsp+30h], rax  ; No template file
    call qword ptr __imp_CreateFileA
    
    ; Check if file opened successfully
    cmp rax, -1
    je error

    ; Save file handle
    mov rbx, rax

    ; Write to file
    mov rcx, rbx    ; File handle
    lea rdx, buffer ; Buffer to write from
    mov r8, 5       ; Number of bytes to write (length of "proof")
    lea r9, [rsp+38h] ; Address to store number of bytes written
    mov qword ptr [rsp+20h], 0 ; Overlapped structure (NULL)
    call qword ptr __imp_WriteFile

    ; Close file handle
    ; ... (implement file closing here)

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