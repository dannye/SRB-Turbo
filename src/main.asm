include "constants.asm"

section "titlescreen", wram0
wFlameCounter: ds 1

section "Main", rom0

START_TILE = $80
DIFFICULTY_X = 5
DIFFICULTY_Y = 7
DIFFICULTY_HEIGHT = 8
DIFFICULTY_WIDTH = 8

Main::
	; load title screen graphics
	call SetPalette	
	call DisableLCD
	call LoadTitleGraphics
	call LoadTitle2Graphics
	call LoadStartGraphics
	call LoadFlames
	call EnableLCD
	xor a
	ld [wFlameCounter], a
.titleLoop
	call WaitVBlank
	
	ld a, [wFlameCounter]
	inc a
	ld [wFlameCounter], a
	cp 10
	jr c, .noAnimate
	xor a
	ld [wFlameCounter], a
	
	ld a, [wOAM + 2]
	and a
	ld b, $1e
	jr z, .frame1
	ld b, -$1e
.frame1
	ld c, 40
	ld hl, wOAM + 2
.flameLoop
	ld a, [hl]
	add b
	ld [hl], a
	inc hl
	inc hl
	inc hl
	inc hl
	dec c
	jr nz, .flameLoop
	
.noAnimate
	; check for A or start
	call Joypad
	ld a, [wJoyPressed]
	and A_BUTTON + START
	; not pressed, do nothing
	jr z, .titleLoop
	; A or start was pressed, exit title screen
	; load difficult selection screen
	ld bc, 32 * 32
	ld hl, vBGMap0
	xor a
	call DisableLCD
	call ClearTilemap
	ld bc, DifficultyGraphicsEnd - DifficultyGraphics
	ld hl, DifficultyGraphics
	ld de, vChars1
	call CopyData
	call DrawDifficultyTilemap
	call EnableLCD
.difficultyLoop
	call WaitVBlank
	jr .difficultyLoop

LoadDifficultyGraphics:
	ld bc, DifficultyGraphics
	ld de, vChars1
	ld a, DIFFICULTY_WIDTH * DIFFICULTY_HEIGHT
	call QueueGfx

	callback DrawDifficultyTilemap

DrawDifficultyTilemap:
	ld hl, vBGMap0 + BG_WIDTH * DIFFICULTY_Y + DIFFICULTY_X
	ld a, START_TILE
	ld b, DIFFICULTY_HEIGHT
	ld c, DIFFICULTY_WIDTH
	jp DrawTilemapRect

SetPalette:
	ld a, %11100100 ; quaternary: 3210
	ld [rOBP0], a
	ld [rOBP1], a
	ld [rBGP], a
	ret

DifficultyGraphics:
	INCBIN "gfx/difficulty.2bpp"
DifficultyGraphicsEnd:
