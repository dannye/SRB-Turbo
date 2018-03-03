
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

LoadTitleGraphics::
	ld bc, TitleGraphics
	ld de, vChars1
	ld a, TITLE_WIDTH * TITLE_HEIGHT
	call QueueGfx

	callback DrawTitleTilemap

	ret

DrawTitleTilemap::
	ld hl, vBGMap0 + BG_WIDTH * TITLE_Y + TITLE_X
	ld a, START_TILE
	ld b, TITLE_HEIGHT
	ld c, TITLE_WIDTH
	jp DrawTilemapRect

LoadTitle2Graphics::
	ld bc, Title2Graphics
	ld de, vChars1 + (TitleGraphicsEnd - TitleGraphics)
	ld a, TITLE2_WIDTH * TITLE2_HEIGHT
	call QueueGfx

	callback DrawTitle2Tilemap

	ret

DrawTitle2Tilemap::
	ld hl, vBGMap0 + BG_WIDTH * TITLE2_Y + TITLE2_X
	ld a, START2_TILE
	ld b, TITLE2_HEIGHT
	ld c, TITLE2_WIDTH
	jp DrawTilemapRect

LoadStartGraphics::
	ld bc, StartGraphics
	ld de, vChars1 + (TitleGraphicsEnd - TitleGraphics) + (Title2GraphicsEnd - Title2Graphics)
	ld a, START_WIDTH * START_HEIGHT
	call QueueGfx

	callback DrawStartTilemap

	ret

DrawStartTilemap::
	ld hl, vBGMap0 + BG_WIDTH * START_Y + START_X
	ld a, START3_TILE
	ld b, START_HEIGHT
	ld c, START_WIDTH
	jp DrawTilemapRect

TitleGraphics:
	INCBIN "gfx/titlescreen.2bpp"
TitleGraphicsEnd:

Title2Graphics:
	INCBIN "gfx/titlescreen2.2bpp"
Title2GraphicsEnd:

Fire1Graphics:
	INCBIN "gfx/fire1.2bpp"
Fire1GraphicsEnd:

Fire2Graphics:
	INCBIN "gfx/fire2.2bpp"
Fire2GraphicsEnd:

StartGraphics:
	INCBIN "gfx/start.2bpp"
StartGraphicsEnd:
