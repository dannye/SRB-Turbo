section "sound wram", wram0
wCh0Ptr: ds 2
wCh0Pitch: ds 2
wCh0Length: ds 1

section "sound", rom0
C_: macro
	dw 11
	db \1
endm

C#: macro
	dw $F89D
	db \1
endm

D_: macro
	dw $F907
	db \1
endm

D#: macro
	dw $F96B
	db \1
endm

E_: macro
	dw 261
	db \1
endm

F_: macro
	dw $FA23
	db \1
endm

F#: macro
	dw $FA77
	db \1
endm

G_: macro
	dw $FAC7
	db \1
endm

G#: macro
	dw $FB12
	db \1
endm

A_: macro
	dw $FB58
	db \1
endm

A#: macro
	dw $FB9B
	db \1
endm

B_: macro
	dw $FBDA
	db \1
endm

__: macro
	dw $0000
	db \1
endm


InitSound::
	ld a, $00
	ld [rNR50], a
	ld a, %10000000
	ld a, [rNR52]
	ld a, $8
	ld [rNR10], a
	ld a, %11110111
	ld [rNR12], a ; volume
	ld a, %10000000
	ld [rNR11], a ; duty
	ld a, %11000011
	ld [rNR51], a ; 
	ld a, $40
	ld [rNR14], a ; counter mode
	ld [rNR24], a
	ld [rNR44], a
	ld a, $77
	ld [rNR50], a
	ld hl, SongData
	;ld a, [hli]
	inc hl
	xor a
	ld [wCh0Pitch], a
	;ld a, [hli]
	inc hl
	ld [wCh0Pitch + 1], a
	ld a, [hl]
	ld [wCh0Length], a
	ld a, l
	ld [wCh0Ptr], a
	ld a, h
	ld [wCh0Ptr + 1], a
	ret

PlaySound:
	ld a, [wCh0Pitch]
	cp $FF
	ret z
	ld [rNR14], a
	ld a, [wCh0Pitch + 1]
	ld [rNR13], a
	ld a, [wCh0Length]
	and a
	jr z, .nextNote
	dec a
	ld [wCh0Length], a
	ret
.nextNote
	ld a, [wCh0Ptr]
	ld l, a
	ld a, [wCh0Ptr + 1]
	ld h, a
	;ld a, [hli]
	ld a, [wCh0Pitch]
	;inc a
	ld [wCh0Pitch], a
	;ld a, [hli]
	ld a, [wCh0Pitch + 1]
	inc a
	ld [wCh0Pitch + 1], a
	ld a, [hl]
	ld [wCh0Length], a
	ld a, l
	ld [wCh0Ptr], a
	ld a, h
	ld [wCh0Ptr + 1], a
	ret

SongData:
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	C_ 100 ; E
	;D_ 100 ; X
	;E_ 100 ; Eb
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	F_ 100
	;G_ 100 ; X
	A_ 100
	B_ 100
	C_ 100
	db $FF, $FF, $FF
