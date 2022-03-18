; asmfunc.asmfunc;
; System V AMD64 Calling Convention
; Registers: RDI, RSI, RDX, RCX, R8, R9

bits 64
section .text
global IoOut32
IoOut32:
    mov dx, di
    mov eax, esi
    out dx, eax
    ret

global IoIn32
IoIn32:
    mov dx, di
    in eax, dx
    ret

global GetCS  ; uint16_t GetCS(void);
GetCS:
    xor eax, eax  ; also clears upper 32 bits of rax
    mov ax, cs
    ret

global LoadIDT  ; void LoadIDT(uint16_t limit, uint64_t offset);
LoadIDT:
    push rbp
    mov rbp, rsp
    sub rsp, 10    ; expand stack area 10 bytes
    mov [rsp], di  ; limit (16bit = 2B)
    mov [rsp + 2], rsi  ; offset (64bit = 8B)
    lidt [rsp]     ; Load Interrupt Descriptor Table
    mov rsp, rbp 
    pop rbp        ; destroy stack area
    ret
