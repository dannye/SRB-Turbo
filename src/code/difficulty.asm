section "Difficulty wram", wram0
wCurSelection:: ds 1

section "Difficulty", rom0

START_TILE = $80
DIFFICULTY_X = 5
DIFFICULTY_Y = 4
DIFFICULTY_HEIGHT = 9
DIFFICULTY_WIDTH = 9

GetDifficultySelection::
	; load difficult selection screen
	ld bc, 32 * 32
	ld hl, vBGMap0
	xor a
	call DisableLCD
	fill wOAM, 4*28, 0
	call ClearTilemap
	ld bc, DifficultyGraphicsEnd - DifficultyGraphics
	ld hl, DifficultyGraphics
	ld de, vChars1
	call CopyData
	call DrawDifficultyTilemap
	ld bc, ArrowGraphicsEnd - ArrowGraphics
	ld hl, ArrowGraphics
	ld de, vChars0
	call CopyData
	ld hl, wOAM
	ld a, 64
	ld [hli], a
	ld a, 48
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
	ld [wCurSelection], a
	call EnableLCD
.difficultyLoop
	call WaitVBlank
	call Joypad
	ld a, [wJoyPressed]
	and D_DOWN
	jr nz, .noDown
	ld a, [wCurSelection]
	dec a
	cp -1
	jr nz, .noWrap
	ld a, 2
.noWrap
	ld [wCurSelection], a
.noDown
	ld a, [wJoyPressed]
	and D_UP
	jr nz, .noUp
	ld a, [wCurSelection]
	inc a
	cp 3
	jr nz, .noWrap2
	xor a
.noWrap2
	ld [wCurSelection], a
.noUp
	ld a, [wCurSelection]
	ld d, a
	ld e, 16
	call Multiply
	ld a, l
	add 64
	ld [wOAM], a
	
	ld a, [wJoyPressed]
	and B_BUTTON
	jr z, .noB
	xor a
	ld hl, wOAM
	ld [hli], a
	ld [hli], a
	ld [hli], a
	scf
	ret
.noB
	ld a, [wJoyPressed]
	and A_BUTTON
	jr z, .noA
	ld a, [wCurSelection]
	ld b, a
	xor a
	ld hl, wOAM
	ld [hli], a
	ld [hli], a
	ld [hli], a
	scf
	ccf
	ld a, b
	ret
.noA
	jr .difficultyLoop

DrawDifficultyTilemap:
	ld hl, vBGMap0 + BG_WIDTH * DIFFICULTY_Y + DIFFICULTY_X
	ld a, START_TILE
	ld b, DIFFICULTY_HEIGHT
	ld c, DIFFICULTY_WIDTH
	jp DrawTilemapRect

DifficultyGraphics:
	INCBIN "gfx/difficulty.2bpp"
DifficultyGraphicsEnd:

ArrowGraphics:
	INCBIN "gfx/arrow.2bpp"
ArrowGraphicsEnd:
