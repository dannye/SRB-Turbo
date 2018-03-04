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
	ld a, %10000000
	ld [rNR52], a
	;ld a, %10000000
	ld [rNR11], a ; duty
	ld a, %11110011
	ld [rNR12], a ; volume
	ld a, %11111111
	ld [rNR51], a ; 
	ld a, $77
	ld [rNR50], a
	;ld a, $8
	;ld [rNR10], a
	ld a, $40
	ld [rNR14], a ; counter mode
	;ld [rNR24], a
	;ld [rNR44], a
	;ld a, $77
	;ld [rNR50], a
	ld hl, One
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

SongData:
	octave 6
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
	octave 5
	C_ 50
	__ 50
	db $FF, $FF

RussianFolk:
	__ $78
	octave 5
	D_ 12
	E_ 12
	F_ 12
	G_ 12
	A_ 12
	octave 4
	__ 12
	D_ 12
	__ 12
	octave 5
	A# 12
	octave 4
	C_ 12
	D_ 12
	octave 5
	A# 12
	A_ 12
	__ 12
	F_ 12
	__ 12
	G_ 10
	__ 1
	G_ 10
	__ 1
	A# 10
	__ 1
	G_ 10
	__ 1
	F_ 10
	__ 1
	F_ 10
	__ 1
	A_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	E_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	D_ 12
	E_ 12
	F_ 12
	G_ 12
	A_ 12
	__ 12
	octave 4
	D_ 12
	__ 12
	octave 5
	A# 12
	octave 4
	C_ 12
	D_ 12
	octave 5
	A# 12
	A_ 12
	__ 12
	F_ 12
	__ 12
	G_ 10
	__ 1
	G_ 10
	__ 1
	A# 10
	__ 1
	G_ 10
	__ 1
	F_ 10
	__ 1
	F_ 10
	__ 1
	A_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	E_ 10
	__ 1
	F_ 10
	__ 1
	E_ 10
	__ 1
	D_ 10
	__ 30
	octave 4
	D_ 16
	__ 1
	C_ 16
	__ 1
	octave 5
	A# 16
	__ 1
	A_ 16
	__ 1
	octave 4
	D_ 16
	__ 1
	C_ 16
	__ 1
	octave 5
	A# 16
	__ 1
	A_ 16
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 10
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 10
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 8
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	octave 4
	D_ 8
	__ 1
	C_ 8
	__ 1
	octave 5
	A# 8
	__ 1
	A_ 8
	__ 1
	A# 8
	__ 1
	A_ 8
	__ 1
	G_ 8
	__ 1
	A_ 8
	__ 1
	A# 8
	__ 1
	G_ 8
	__ 1
	A_ 8
	__ 1
	F_ 8
	__ 1
	G_ 16
	__ 16
	E_ 16
	__ 1
	F_ 16
	__ 1
	E_ 16
	__ 8
	D_ 32
	__ 20
	db $FF, $FF

One:
	octave 5
	__ $78
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 5
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 40
	G_ 60

	octave 5
	B_ 20
	octave 4
	F# 20
	octave 5
	B_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	A_ 20
	octave 4
	F# 20
	octave 6
	A_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	G_ 20
	octave 4
	F# 20
	octave 6
	G_ 20
	octave 4
	D_ 50
	__ 10
	D_ 40

	octave 6
	E_ 20
	octave 5
	B_ 20
	octave 6
	F# 20
	octave 5
	B_ 20

	octave 5
	E_ 10
	octave 4
	F# 10
	octave 3
	A_ 20
	B_ 10
	C# 10
	B_ 20







	__ 20
	db $FF, $FF




	






















