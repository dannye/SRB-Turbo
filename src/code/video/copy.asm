section "video copy", rom0

DrawTilemapRect::
; Fill a cxb rectangle at bg map address hl with a++.

	push af
	ld a, BG_WIDTH
	sub c
	ld e, a
	ld d, 0
	pop af

.y
	push bc
.x
	ld [hli], a
	inc a
	dec c
	jr nz, .x
	pop bc

	add hl, de
	dec b
	jr nz, .y

	ret

ClearTilemap::
	ld hl, vBGMap0 ; + BG_WIDTH * TITLE_Y + TITLE_X
	ld a, 0 ; START_TILE
	ld b, BG_WIDTH ; TITLE_HEIGHT
	ld c, BG_WIDTH ; TITLE_WIDTH
; Fill a cxb rectangle at bg map address hl with a.

	push af
	ld a, BG_WIDTH
	sub c
	ld e, a
	ld d, 0
	pop af

.y
	push bc
.x
	ld [hli], a
	dec c
	jr nz, .x
	pop bc

	add hl, de
	dec b
	jr nz, .y

	ret

; copy bc bytes from hl to de
CopyData::
	ld a, b
	or c
	ret z
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	jr CopyData
