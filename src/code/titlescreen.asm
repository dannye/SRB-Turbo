section "titlescreen wram", wram0
wFlameCounter: ds 1

section "titlescreen", rom0
START_TILE = $80
TITLE_X = 4
TITLE_Y = 4
TITLE_HEIGHT = 4
TITLE_WIDTH = 12
START2_TILE = $B0
TITLE2_X = 6
TITLE2_Y = 10
TITLE2_HEIGHT = 2
TITLE2_WIDTH = 8
START3_TILE = $C0
START_X = 6
START_Y = 15
START_HEIGHT = 2
START_WIDTH = 8

FIRE_HEIGHT = 3
FIRE_WIDTH = 10

TitleScreen::
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
	cp 8
	jr c, .noAnimate
	xor a
	ld [wFlameCounter], a
	
	ld a, [wOAM + 2]
	and a
	ld b, $1e
	jr z, .frame1
	ld b, -$1e
.frame1
	ld c, 28
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
	ret

LoadTitleGraphics::
	ld bc, TitleGraphicsEnd - TitleGraphics
	ld hl, TitleGraphics
	ld de, vChars1
	call CopyData

	callback DrawTitleTilemap

	ret

DrawTitleTilemap::
	ld hl, vBGMap0 + BG_WIDTH * TITLE_Y + TITLE_X
	ld a, START_TILE
	ld b, TITLE_HEIGHT
	ld c, TITLE_WIDTH
	jp DrawTilemapRect

LoadTitle2Graphics::
	ld bc, Title2GraphicsEnd - Title2Graphics 
	ld hl, Title2Graphics
	ld de, vChars1 + (TitleGraphicsEnd - TitleGraphics)
	call CopyData

	callback DrawTitle2Tilemap

	ret

DrawTitle2Tilemap::
	ld hl, vBGMap0 + BG_WIDTH * TITLE2_Y + TITLE2_X
	ld a, START2_TILE
	ld b, TITLE2_HEIGHT
	ld c, TITLE2_WIDTH
	jp DrawTilemapRect

LoadStartGraphics::
	ld bc, StartGraphicsEnd - StartGraphics
	ld hl, StartGraphics
	ld de, vChars1 + (Title2GraphicsEnd - TitleGraphics)
	call CopyData

	callback DrawStartTilemap

	ret

DrawStartTilemap::
	ld hl, vBGMap0 + BG_WIDTH * START_Y + START_X
	ld a, START3_TILE
	ld b, START_HEIGHT
	ld c, START_WIDTH
	jp DrawTilemapRect

LoadFlames::
	ld bc, Fire1GraphicsEnd - Fire1Graphics
	ld hl, Fire1Graphics
	ld de, vChars0
	call CopyData
	
	ld bc, Fire2GraphicsEnd - Fire2Graphics
	ld hl, Fire2Graphics
	ld de, vChars0 + (Fire1GraphicsEnd - Fire1Graphics)
	call CopyData
	
	; setup wOAM for flames...
	ld bc, FlamesOAMTableEnd - FlamesOAMTable
	ld hl, FlamesOAMTable
	ld de, wOAM
	call CopyData
	
	ret

FlamesOAMTable:
	db 88, 8*6, 0, 0
	db 88, 8*7, 1, 0
	db 88, 8*8, 2, 0
	db 88, 8*9, 3, 0
	db 88, 8*10, 4, 0
	db 88, 8*11, 5, 0
	db 88, 8*12, 6, 0
	db 88, 8*13, 7, 0
	db 88, 8*14, 8, 0
	db 88, 8*15, 9, 0
	
	db 112, 8*6, 10, 0
	db 112, 8*7, 11, 0
	db 112, 8*8, 12, 0
	db 112, 8*9, 13, 0
	db 112, 8*10, 14, 0
	db 112, 8*11, 15, 0
	db 112, 8*12, 16, 0
	db 112, 8*13, 17, 0
	db 112, 8*14, 18, 0
	db 112, 8*15, 19, 0
	
	db 96, 8*6, 20, 0
	db 96, 8*7, 21, 0
	db 96, 8*14, 22, 0
	db 96, 8*15, 23, 0
	db 104, 8*6, 24, 0
	db 104, 8*7, 25, 0
	db 104, 8*14, 26, 0
	db 104, 8*15, 27, 0
FlamesOAMTableEnd:

TitleGraphics:
	INCBIN "gfx/titlescreen.2bpp"
TitleGraphicsEnd:

Title2Graphics:
	INCBIN "gfx/titlescreen2.2bpp"
Title2GraphicsEnd:

StartGraphics:
	INCBIN "gfx/start.2bpp"
StartGraphicsEnd:

Fire1Graphics:
	INCBIN "gfx/fire1.2bpp"
Fire1GraphicsEnd:

Fire2Graphics:
	INCBIN "gfx/fire2.2bpp"
Fire2GraphicsEnd:
