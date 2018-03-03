section "level wram", wram0

section "levelscreen", rom0
LEVEL_X = 2
LEVEL_Y = 2
LEVEL2_X = 15
LEVEL2_Y = 15
BUTTON_BAR_HEIGHT = 3
BUTTON_BAR_WIDTH = 16
BAR_SECTION_HEIGHT = 12
BAR_SECTION_WIDTH = 7

LevelScreen::
	call DisableLCD
	call LoadLevelGraphics
	call EnableLCD
	xor a
	call PlaySound
.loop
	call WaitVBlank
	jr .loop	

LoadLevelGraphics:
	ld bc, LevelGraphicsEnd - LevelGraphics
	ld hl, LevelGraphics
	ld de, vChars1
	call CopyData
	
	call DrawLevelTiles

	ret

DrawLevelTiles:
	ld c, 17
	ld hl, LevelTileMap
	ld de, vBGMap0
.loop
	push bc
	ld bc, 16
	call CopyData
	ld a, 16
	add a, e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	pop bc
	dec c
	jr nz, .loop
	ret
	

LevelTileMap:
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $00, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $A1, $90, $00, $00
	db $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F
	db $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E, $9F, $A0
	db $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1
LevelTileMapEnd:	

LevelGraphics:
	INCBIN "gfx/level.2bpp"
LevelGraphicsEnd: