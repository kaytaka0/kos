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

global LoadGDT
LoadGDT:
    push rbp
    mov rbp, rsp
    sub rsp, 10
    mov [rsp], di ; limit
    mov [rsp + 2], rsi ; offset
    lgdt [rsp]
    mov rsp, rbp
    pop rbp
    ret

global SetDSAll  ; void SetDSAll(uint16_t value);
SetDSAll:
    mov ds, di
    mov es, di
    mov fs, di
    mov gs, di
    ret

global SetCSSS  ; void SetCSSS(uint16_t cs, uint16_t ss);
SetCSSS:
    push rbp
    mov rbp, rsp
    mov ss, si
    mov rax, .next
    push rdi ; CS
    push rax ; RIP
    o64 retf
.next:
    mov rsp, rbp
    pop rbp
    ret

global SetCR3  ; void SetCR3(uint64_t value);
SetCR3:
    mov cr3, rdi
    ret

extern kernel_main_stack
extern kernelMainNewStack

global KernelMain
KernelMain:
    mov rsp, kernel_main_stack + 1024 * 1024
    call kernelMainNewStack
.fin:
    hlt
    jmp .fin
