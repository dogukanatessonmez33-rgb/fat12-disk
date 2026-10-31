; NASM ile Basit FAT12 Boot Sector Yapısı

org 0x7C00          
bits 16             

start:
    jmp short boot_code    
    nop                    

; FAT12 BIOS Parameter Block (BPB) - Standart Yapı

oem_name        db "MSWIN4.1"  
bytes_per_sec   dw 512          
sec_per_cluster db 1         
reserved_secs   dw 1          
fat_count       db 2          
root_dir_entries dw 224        
total_sectors   dw 2880         
media_descriptor db 0xF0      
sec_per_fat     dw 9            
sec_per_track   dw 18          
head_count      dw 2       
hidden_sectors  dd 0           
large_sectors   dd 0           

; Genişletilmiş Boot Kaydı (Extended Boot Record)
drive_number    db 0x00        
reserved        db 0x00       
boot_signature  db 0x29         ; Genişletilmiş boot imzası
volume_id       dd 0x12345678  
volume_label    db "FAT12BOOT  " ; 11 Bayt Disk Etiketi
file_system     db "FAT12   "  


; Gerçek Önyükleme Kod Başlangıcı

boot_code:
    ; Segment register'larını sıfırla/ayarla
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00              ; Yığın (Stack) başlangıcını boot altına koy

    ; Ekrana mesaj yazdırma
    mov si, msg_hello
    call print_string

halt:
    cli                        
    hlt                         ; CPU'yu durdur
    jmp halt                   
; Yardımcı fnc.
print_string:
    mov ah, 0x0E                ; BIOS TTY video fonksiyonu
.loop:
    lodsb                       ; AL = [SI] ve SI++
    cmp al, 0               
    je .done
    int 0x10                    ; Karakteri ekrana bas
    jmp .loop
.done:
    ret

; Veri Alanı ve Dolgu
msg_hello db "Merhaba! Fat12 oldu..", 0x0D, 0x0A, 0

; Sektörü 510 bayta tamamla, kalan yerleri sıfır yap.
times 510 - ($ - $$) db 0

; Boot imza bayları  (511 ve 512. baytlar)
dw 0xAA55
