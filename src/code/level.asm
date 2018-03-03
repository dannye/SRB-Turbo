section "level wram", wram0
wNotePtr: ds 2
wNextNote: ds 1
wDelay: ds 1

section "levelscreen", rom0

LevelScreen::
	call DisableLCD
	call LoadLevelGraphics
	call EnableLCD
	xor a
	call PlaySound
	ld hl, Level1Notes
	ld a, [hli]
	ld [wNextNote], a
	ld a, [hli]
	ld [wDelay], a
	ld a, l
	ld [wNotePtr], a
	ld a, h
	ld [wNotePtr + 1], a
.loop
	call WaitVBlank
	ld a, [wNextNote]
	cp $ff
	jr z, .advanceNotes ; song is over
	ld a, [wDelay]
	and a
	jr z, .beginNote
	dec a
	ld [wDelay], a
	jr .advanceNotes
.beginNote
	;;; spawn new note sprite
	ld c, 40
	ld hl, wOAM + 1
.findSpaceLoop
	ld a, [hl]
	and a
	jr z, .found
	inc hl
	inc hl
	inc hl
	inc hl
	dec c
	jr nz, .findSpaceLoop
	;;; error, all notes full, ignore new note
	jr .skip
.found
	dec hl
	;;; create note at hl
	ld a, [wNextNote]
	cp D_LEFT
	ld b, 16*1 + 8
	jr z, .cont
	cp D_UP
	ld b, 16*2 + 8
	jr z, .cont
	cp D_RIGHT
	ld b, 16*3 + 8
	jr z, .cont
	cp D_DOWN
	ld b, 16*4 + 8
	jr z, .cont
	cp B_BUTTON
	ld b, 16*5 + 8
	jr z, .cont
	;cp A_BUTTON
	ld b, 16*6 + 8
	;jr z, .cont
.cont
	ld a, 8
	ld [hli], a
	ld a, b
	ld [hli], a
	xor a
	ld [hli], a
	ld [hli], a
.skip
	ld a, [wNotePtr]
	ld l, a
	ld a, [wNotePtr + 1]
	ld h, a
	ld a, [hli]
	ld [wNextNote], a
	ld a, [hli]
	ld [wDelay], a
	ld a, l
	ld [wNotePtr], a
	ld a, h
	ld [wNotePtr + 1], a
.advanceNotes
	;;; for all visible notes, scroll down
	ld c, 40
	ld hl, wOAM
.advanceLoop
	ld a, [hl]
	and a
	jr z, .skipAdvance
	inc a
	cp 160
	jr nc, .dead
	ld [hl], a
	jr .skipAdvance
.dead
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	jr .skipInc
.skipAdvance
	inc hl
	inc hl
	inc hl
	inc hl
.skipInc
	dec c
	jr nz, .advanceLoop
	jp .loop

Level1Notes:
	db D_LEFT, 0
	db D_UP, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db B_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_DOWN, 20
	db A_BUTTON, 50
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_DOWN, 20
	db B_BUTTON, 20
	db D_DOWN, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db D_DOWN, 20
	db A_BUTTON, 50
	db A_BUTTON, 50
	db D_UP, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db D_DOWN, 20
	db B_BUTTON, 20
	db $FF, $FF

LoadLevelGraphics:
	ld bc, LevelGraphicsEnd - LevelGraphics
	ld hl, LevelGraphics
	ld de, vChars1
	call CopyData
	ld bc, NoteGraphicsEnd - NoteGraphics
	ld hl, NoteGraphics
	ld de, vChars0
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

NoteGraphics:
	INCBIN "gfx/note.2bpp"
NoteGraphicsEnd: