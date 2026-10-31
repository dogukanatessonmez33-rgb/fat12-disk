; NASM ile Basit FAT12 Boot Sector Yapısı

org 0x7C00          ; BIOS önyükleme sektörünü bu adrese yükler
bits 16             ; 16-bit Gerçek Mod (Real Mode) kodlaması

start:
    jmp short boot_code     ; BPB üzerinden atla
    nop                     ; Kısa atlama sonrası 1 baytlık dolgu

; FAT12 BIOS Parameter Block (BPB) - Standart Yapı

oem_name        db "MSWIN4.1"   ; 8 Bayt OEM Adı
bytes_per_sec   dw 512          ; Sektör başına bayt
sec_per_cluster db 1            ; Küme başına sektör
reserved_secs   dw 1            ; Rezerve edilen sektör sayısı (Boot Sektör)
fat_count       db 2            ; FAT tablosu sayısı
root_dir_entries dw 224         ; Kök dizindeki maksimum dosya sayısı
total_sectors   dw 2880         ; Toplam sektör sayısı (1.44MB Floppy için)
media_descriptor db 0xF0        ; Medya türü (0xF0 = 3.5" Floppy)
sec_per_fat     dw 9            ; FAT başına sektör sayısı
sec_per_track   dw 18           ; İz (track) başına sektör sayısı
head_count      dw 2            ; Kafa (head) sayısı
hidden_sectors  dd 0            ; Gizli sektör sayısı
large_sectors   dd 0            ; Büyük sektör sayısı (Eğer total_sectors > 65535 ise)

; Genişletilmiş Boot Kaydı (Extended Boot Record)
drive_number    db 0x00         ; Sürücü numarası (0x00 = A: Floppy)
reserved        db 0x00         ; Rezerve Windows NT alanı
boot_signature  db 0x29         ; Genişletilmiş boot imzası
volume_id       dd 0x12345678   ; Seri numarası (Rastgele)
volume_label    db "FAT12BOOT  " ; 11 Bayt Disk Etiketi
file_system     db "FAT12   "   ; 8 Bayt Dosya Sistemi Türü


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
    cli                         ; Kesmeleri kapat
    hlt                         ; CPU'yu durdur
    jmp halt                    ; Sonsuz döngü

; Yardımcı fnc.
print_string:
    mov ah, 0x0E                ; BIOS TTY video fonksiyonu
.loop:
    lodsb                       ; AL = [SI] ve SI++
    cmp al, 0                   ; String sonu mu? (Null terminator)
    je .done
    int 0x10                    ; Karakteri ekrana bas
    jmp .loop
.done:
    ret

; Veri Alanı ve Dolgu
msg_hello db "Merhaba! FAT12 Disketi Basariyla Yuklendi.", 0x0D, 0x0A, 0

; Sektörü 510 bayta tamamla, kalan yerleri sıfır yap.
times 510 - ($ - $$) db 0

; Boot imza bayları  (511 ve 512. baytlar)
dw 0xAA55
