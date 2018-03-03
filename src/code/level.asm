section "level wram", wram0
wDifficulty: ds 1
wNotePtr: ds 2
wNextNote: ds 1
wDelay: ds 1
wScore: ds 2
wStreak: ds 1

section "levelscreen", rom0

LevelScreen::
	ld [wDifficulty], a
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
	xor a
	ld [wScore], a
	ld [wScore + 1], a
	ld [wStreak], a
.loop
	call WaitVBlank
	callback ToggleIcons
	callback DrawScore

.checkNotesLoop
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
	ld a, [wDelay]
	and a
	jr z, .checkNotesLoop ; in case of a chord
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
	
	; check button presses for hits/misses
	ld a, [wJoyPressed]
	bit D_LEFT_F, a
	jr z, .skip1
	; check if note in left hitbox
	ld a, 16*1 + 8
	call NoteInHitbox
	
.skip1
	ld a, [wJoyPressed]
	bit D_UP_F, a
	jr z, .skip2
	; check if note in up hitbox
	ld a, 16*2 + 8
	call NoteInHitbox
	
.skip2
	ld a, [wJoyPressed]
	bit D_RIGHT_F, a
	jr z, .skip3
	; check if note in up hitbox
	ld a, 16*3 + 8
	call NoteInHitbox
	
.skip3
	ld a, [wJoyPressed]
	bit D_DOWN_F, a
	jr z, .skip4
	; check if note in up hitbox
	ld a, 16*4 + 8
	call NoteInHitbox
	
.skip4
	ld a, [wJoyPressed]
	bit B_BUTTON_F, a
	jr z, .skip5
	; check if note in up hitbox
	ld a, 16*5 + 8
	call NoteInHitbox
	
.skip5
	ld a, [wJoyPressed]
	bit A_BUTTON_F, a
	jr z, .skip6
	; check if note in up hitbox
	ld a, 16*6 + 8
	call NoteInHitbox
	
.skip6
	
	jp .loop

; input: x-coord of left edge of hitbox in reg a
; deletes sprite if hit
; resets streak if no hit
NoteInHitbox:
	ld b, a
	ld c, 0
	ld hl, wOAM
.loop
	ld a, [hli]
	cp $80
	jr c, .no
	cp $90
	jr nc, .no
	ld a, [hl]
	cp b
	jr nz, .no
	; yes
	xor a
	dec hl
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld a, [wStreak]
	inc a
	ld [wStreak], a
	call IncrementScore
	ret
.no
	inc hl
	inc hl
	inc hl
	inc c
	ld a, c
	cp 40
	jr nz, .loop
	xor a
	ld [wStreak], a
	ret

IncrementScore:
	ld a, [wScore + 1]
	cp $90
	jr nc, .doCarry
	add $10
	ld [wScore + 1], a
	ret
.doCarry
	xor a
	ld [wScore + 1], a
	ld a, [wScore]
	and $0F
	cp 9
	jr nc, .doCarry2
	inc a
	ld b, a
	ld a, [wScore]
	and $F0
	or b
	ld [wScore], a
	ret
.doCarry2
	ld a, [wScore]
	cp $90
	ret nc
	and $F0
	add $10
	ld [wScore], a
	ret

DrawScore:
	ld hl, $986F
	ld a, [wScore]
	and $F0
	swap a
	add $F0
	ld [hli], a
	ld a, [wScore]
	and $0F
	add $F0
	ld [hli], a
	ld a, [wScore + 1]
	and $F0
	swap a
	add $F0
	ld [hli], a
	ld a, [wScore + 1]
	and $0F
	add $F0
	ld [hli], a
	ret

Level1Notes:
	db D_LEFT, 80
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db D_LEFT, 20
	db D_UP, 0
	db D_RIGHT, 0
	db D_DOWN, 0
	db B_BUTTON, 0
	db A_BUTTON, 0
	db B_BUTTON, 20
	db D_UP, 20
	db B_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_DOWN, 20
	db A_BUTTON, 50
	db A_BUTTON, 2
	db D_UP, 2
	db D_RIGHT, 2
	db B_BUTTON, 2
	db D_RIGHT, 2
	db D_RIGHT, 2
	db D_UP, 2
	db D_DOWN, 2
	db D_RIGHT, 2
	db B_BUTTON, 2
	db D_DOWN, 20
	db A_BUTTON, 20
	db D_DOWN, 0
	db D_UP, 20
	db A_BUTTON, 20
	db D_DOWN, 0
	db A_BUTTON, 50
	db A_BUTTON, 0
	db D_DOWN, 20
	db D_UP, 20
	db A_BUTTON, 50
	db A_BUTTON, 0
	db D_RIGHT, 20
	db D_RIGHT, 20
	db D_DOWN, 20
	db D_RIGHT, 0
	db D_UP, 20
	db B_BUTTON, 20
	db D_DOWN, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_DOWN, 20
	db A_BUTTON, 50
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db A_BUTTON, 50
	db D_UP, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db D_DOWN, 20
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

ToggleIcons:
	call Joypad
	ld bc, 0
	ld a, [wJoy]
	bit D_LEFT_F, a
	jr z, .released1
	ld a, $33
	jr .skip1
.released1
	ld a, -$33
.skip1
	call .toggleIcon
	
	inc bc
	inc bc
	ld a, [wJoy]
	bit D_UP_F, a
	jr z, .released2
	ld a, $33
	jr .skip2
.released2
	ld a, -$33
.skip2
	call .toggleIcon
	
	inc bc
	inc bc
	ld a, [wJoy]
	bit D_RIGHT_F, a
	jr z, .released3
	ld a, $33
	jr .skip3
.released3
	ld a, -$33
.skip3
	call .toggleIcon
	
	inc bc
	inc bc
	ld a, [wJoy]
	bit D_DOWN_F, a
	jr z, .released4
	ld a, $33
	jr .skip4
.released4
	ld a, -$33
.skip4
	call .toggleIcon
	
	inc bc
	inc bc
	ld a, [wJoy]
	bit B_BUTTON_F, a
	jr z, .released5
	ld a, $33
	jr .skip5
.released5
	ld a, -$33
.skip5
	call .toggleIcon
	
	inc bc
	inc bc
	ld a, [wJoy]
	bit A_BUTTON_F, a
	jr z, .released6
	ld a, $33
	jr .skip6
.released6
	ld a, -$33
.skip6
	call .toggleIcon
	ret

.toggleIcon
	ld hl, $99C2
	add bc
	ld e, a
	ld a, [hl]
	cp $B2
	jr c, .looksReleased
	; looks pressed
	ld a, e
	cp $33 + 1
	ret c
	; needs fixing
	add [hl]
	ld [hl], a
	ld de, 32
	add hl, de
	add $11
	ld [hl], a
	ret
.looksReleased
	ld a, e
	cp $33 + 1
	ret nc
	; needs fixing
	add [hl]
	ld [hl], a
	ld de, 32
	add hl, de
	add $11
	ld [hl], a
	ret

LoadLevelGraphics:
	ld bc, LevelGraphicsEnd - LevelGraphics
	ld hl, LevelGraphics
	ld de, vChars1
	call CopyData
	ld bc, LevelGraphics2End - LevelGraphics2
	ld hl, LevelGraphics2
	ld de, vChars1 + (LevelGraphicsEnd - LevelGraphics)
	call CopyData
	ld bc, NoteGraphicsEnd - NoteGraphics
	ld hl, NoteGraphics
	ld de, vChars0
	call CopyData
	ld bc, DigitsGraphicsEnd - DigitsGraphics
	ld hl, DigitsGraphics
	ld de, $8f00
	call CopyData
	
	call DrawLevelTiles
	
	ld hl, vBGMap0 + 32 * 2 + 16
	ld a, $FA
	ld [hli], a
	inc a
	ld [hli], a
	inc a
	ld [hl], a
	ld de, 32
	add hl, de
	ld a, $F0
	ld [hld], a
	ld [hld], a
	ld [hld], a
	ld [hld], a
	
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

LevelGraphics2:
	INCBIN "gfx/level_pressed.2bpp"
LevelGraphics2End:

NoteGraphics:
	INCBIN "gfx/note.2bpp"
NoteGraphicsEnd:

DigitsGraphics:
	INCBIN "gfx/digits.2bpp"
DigitsGraphicsEnd: