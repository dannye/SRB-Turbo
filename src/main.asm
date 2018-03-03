include "constants.asm"

section "Main wram", wramx
wDifficulty: ds 1

section "Main", rom0

Main::
	call DisableLCD
	fill vBGMap0, 32*32, 0
	fill vChars1, $600, 0
	call EnableLCD
	; load title screen graphics
	call SetPalette
	
	call TitleScreen
	
	call GetDifficultySelection
	jr c, Main
	ld [wDifficulty], a
	call LevelScreen


SetPalette:
	ld a, %11100100 ; quaternary: 3210
	ld [rOBP0], a
	ld [rOBP1], a
	ld [rBGP], a
	ret
