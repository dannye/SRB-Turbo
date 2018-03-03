section "sound wram", wram0
wCh0Pitch: ds 1

section "sound", rom0
PlaySound::
	ld a, 15
	ld [rNR12], a ; volume
	xor a
	ld [rNR11], a ; duty
	inc a
	ld [rNR51], a ; 
	ld a, $40
	ld [rNR14], a ; counter mode
	ld [rNR24], a
	ld [rNR44], a
	ld a, $77
	ld [rNR50], a
	ld a, $f8
	ld [rNR13], a
	ld a, $2c
	ld [rNR14], a
	ret
