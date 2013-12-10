; multi-boot mini kernel - [ start.asm ]
;
; (c) 2002, NeuralDK
section .text
bits 32
; multi boot header defines
MBOOT_PAGE_ALIGN   equ 1 << 0
MBOOT_MEM_INFO     equ 1 << 1
MBOOT_AOUT_KLUDGE  equ 1 << 16
MBOOT_MAGIC equ 0x1BADB002
MBOOT_FLAGS equ MBOOT_PAGE_ALIGN | MBOOT_MEM_INFO | MBOOT_AOUT_KLUDGE
CHECKSUM    equ -(MBOOT_MAGIC + MBOOT_FLAGS)
STACK_SIZE  equ 0x1000
; defined in the linker script
extern textEnd
extern dataEnd
extern bssEnd
extern cmain
global  start
global _start
entry:
    jmp start
    ; The Multiboot header
align 4, db 0
mBootHeader:
    dd MBOOT_MAGIC
    dd MBOOT_FLAGS
    dd CHECKSUM
    ; fields used if MBOOT_AOUT_KLUDGE is set in
    ; MBOOT_HEADER_FLAGS
    dd mBootHeader                     ; these are PHYSICAL addresses
    dd entry                           ; start of kernel .text (code) section
    dd dataEnd                         ; end of kernel .data section
    dd bssEnd                          ; end of kernel BSS
    dd entry                           ; kernel entry point (initial EIP)
 start:
_start:
    ; clear the idt + gdt @ 0x0
    xor edi, edi
    mov ecx, 0x800 + 0x800
    rep stosb
    ; setup a bare bones GDT
    mov esi, my_gdt
    mov edi, 0x0800
    mov ecx, 8 * 4
    rep movsb
    lgdt    [pGDT]                  ; load the GDT
    lidt    [pIDT]                  ; load the IDT
    mov     dx, 0x08        ; 0x08 - kernel data segment
    mov     ds, dx
    mov     es, dx
    mov     fs, dx
    mov     gs, dx
    mov     dx, 0x18        ; 0x18 - kernel stack segment
    mov     ss, dx
    mov    esp, (stack + STACK_SIZE)
    ; push the multiboot info structure, and magic
    push ebx
    push eax
    ; load cs with new selector
    jmp 0x10:new_gdt
  new_gdt:
    ; time for some C!
    call cmain
    jmp short $
section .data
string          db "ndk is alive!", 0
pIDT            dw 800h         ; limit of 256 IDT slots
                dd 00000000h    ; starting at 0
pGDT            dw 800h         ; 256 GDT slots
                dd 00000800h    ; starting at 800h (after IDT)
my_gdt:
        ; Null descriptor
        ;   base : 0x00000000
        ;   limit: 0x00000000 ( 0.0 MB)
        dd 0
        dd 0
        ; 0x08 descriptor - Kernel data segment
        ;   base : 0x00000000
        ;   limit: 0xfffff pages (4 GB)
        ;   DPL  : 0
        ;   32 bit, present, system, expand-up, writeable
        dd 0x0000ffff
        dd 0x00cf9200
        ; 0x10 descriptor - Kernel code segment
        ;   base : 0x00000000
        ;   limit: 0xfffff (4 GB)
        ;   DPL  : 0
        ;   32 bit, present, system, non-conforming, readable
        dd 0x0000ffff
        dd 0x00cf9A00
        ; 0x18 descriptor - Kernel stack segment
        ;   base : 0x00000000 //0x00080000
        ;   limit: 0xfffff (4 GB)
        ;   DPL  : 0
        ;   32 bit, present, system, expand-up, writeable
        dd 0x0000ffff
        dd 0x00cb9200
section .bss
    align 4, db 0
    common stack 0x1000
    resb 0x4000
