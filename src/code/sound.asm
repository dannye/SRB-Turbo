section "sound wram", wram0
wCh0Ptr: ds 2
wCh0Pitch: ds 1
wCh0Length: ds 1
wCh0Octave: ds 1

section "sound", rom0
C_: macro
	db 0
	db \1
endm

C#: macro
	db 1
	db \1
endm

D_: macro
	db 2
	db \1
endm

D#: macro
	db 3
	db \1
endm

E_: macro
	db 4
	db \1
endm

F_: macro
	db 5
	db \1
endm

F#: macro
	db 6
	db \1
endm

G_: macro
	db 7
	db \1
endm

G#: macro
	db 8
	db \1
endm

A_: macro
	db 9
	db \1
endm

A#: macro
	db 10
	db \1
endm

B_: macro
	db 11
	db \1
endm

__: macro
	db 12
	db \1
endm

octave: macro
	db 13
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
	ld a, %10000001
	ld [rNR11], a ; duty
	ld a, %11111111
	ld [rNR51], a ; 
	ld a, $40
	ld [rNR14], a ; counter mode
	;ld [rNR24], a
	;ld [rNR44], a
	ld a, $77
	ld [rNR50], a
	ld hl, SongData
StartNextNote:
	ld a, [hli]
	cp 13
	jr nz, .notOctave
	ld a, [hli]
	ld [wCh0Octave], a
	ld a, [hli]
.notOctave
	ld [wCh0Pitch], a
	cp $FF
	ret z
	ld c, a
	ld a, [hli]
	ld [wCh0Length], a
	ld a, l
	ld [wCh0Ptr], a
	ld a, h
	ld [wCh0Ptr + 1], a
	ld a, [wCh0Octave]
	ld b, a
	ld a, c
	cp 12
	jr z, .rest
	call CalculateFrequency
	ld a, [rNR51]
	or %00010001
	ld [rNR51], a
	ld a, e
	ld [rNR13], a
	ld a, d
	ld [rNR14], a
	ret
.rest
	ld a, [rNR51]
	and %11101110
	ld [rNR51], a
	xor a
	ld [rNR13], a
	ld [rNR14], a
	ret

PlaySound:
	ld a, [wCh0Pitch]
	cp $FF
	ret z
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
	call StartNextNote
	ret

CalculateFrequency:
; return the frequency for note a, octave b in de
	ld h, 0
	ld l, a
	add hl, hl
	ld d, h
	ld e, l
	ld hl, Pitches
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, b
.loop
	cp 7
	jr z, .done
	sra d
	rr e
	inc a
	jr .loop
.done
	ld a, 8
	add d
	ld d, a
	ret

Pitches:
	dw $F82C ; C_
	dw $F89D ; C#
	dw $F907 ; D_
	dw $F96B ; D#
	dw $F9CA ; E_
	dw $FA23 ; F_
	dw $FA77 ; F#
	dw $FAC7 ; G_
	dw $FB12 ; G#
	dw $FB58 ; A_
	dw $FB9B ; A#
	dw $FBDA ; B_

EasySongMain:
	octave 5
	C_ 50
	__ 50
	C# 50
	__ 50
	D_ 50
	__ 50
	D# 50
	__ 50
	E_ 50
	__ 50
	F_ 50
	__ 50
	F# 50
	__ 50
	G_ 50
	__ 50
	G# 50
	__ 50
	A_ 50
	__ 50
	A# 50
	__ 50
	B_ 50
	__ 50
	octave 6
	C_ 50
	__ 50
	db $FF, $FF
	

SongData:
	octave 5
	__ $70
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80
	octave 5
	C_ 80
	octave 6
	G_ 80
	A_ 80
	E_ 80
	F_ 80
	C_ 80
	F_ 80
	G_ 80 ; end of main melody
	octave 5
	C_ 40
	E_ 40
	G_ 40
	F_ 40
	E_ 40
	C_ 40
	E_ 40
	D_ 40
	C_ 40
	octave 6
	A_ 40
	octave 5
	C_ 40
	G_ 40
	F_ 40
	A_ 40
	G_ 40
	F_ 40
	E_ 40
	C_ 40
	D_ 40
	B_ 40
	octave 4
	C_ 40
	E_ 40
	octave 5
	G_ 40
	E_ 40
	A_ 38
	__ 2
	A_ 40
	G_ 38
	__ 2
	G_ 40
	A_ 38
	__ 2
	A_ 40
	B_ 38
	__ 2
	B_ 40 ; end of second melody
	octave 5
	C_ 20
	E_ 20
	G_ 20
	octave 4
	C_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	octave 6
	A_ 20
	octave 5
	C_ 20
	E_ 20
	A_ 20
	octave 6
	E_ 20
	G_ 20
	B_ 20
	octave 5
	E_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	C_ 20
	E_ 20
	G_ 20
	octave 5
	C_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	C_ 20
	E_ 20
	G_ 20
	octave 4
	C_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	octave 6
	A_ 20
	octave 5
	C_ 20
	E_ 20
	A_ 20
	octave 6
	E_ 20
	G_ 20
	B_ 20
	octave 5
	E_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	C_ 20
	E_ 20
	G_ 20
	octave 5
	C_ 20
	octave 6
	F_ 20
	A_ 20
	octave 5
	C_ 20
	F_ 20
	octave 6
	G_ 20
	B_ 20
	octave 5
	D_ 20
	G_ 20
	__ 50
	db $FF, $FF
