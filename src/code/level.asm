section "level wram", wram0
wDifficulty: ds 1
wNotePtr: ds 2
wNextNote: ds 1
wDelay: ds 1
wScore: ds 2
wDisplayedScore: ds 2
wStreak: ds 1
wBombs: ds 1

wOAMCopy: ds 40*4

section "levelscreen", rom0

LevelScreen::
	ld [wDifficulty], a
	call DisableLCD
	call LoadLevelGraphics
	call EnableLCD
	ld a, [wDifficulty]
	call InitSound
	ld a, [wDifficulty]
	cp 2
	ld hl, FireAndFlamesNotes
	jr z, .gotSong
	cp 1
	ld hl, RussianFolkNotes
	jr z, .gotSong
	ld hl, CanonNotes
.gotSong
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
	ld [wDisplayedScore], a
	ld [wDisplayedScore + 1], a
	ld [wStreak], a
	ld [wBombs], a
.loop
	call WaitVBlank
	callback ToggleIcons
	callback DrawScore
	callback DrawStreak
	call Ch0UpdateSound
	call Ch1UpdateSound
	call Joypad

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
	cp D_DOWN
	ld b, 16*3 + 8
	jr z, .cont
	cp D_RIGHT
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
	ld [wStreak], a
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
	bit D_DOWN_F, a
	jr z, .skip3
	; check if note in down hitbox
	ld a, 16*3 + 8
	call NoteInHitbox
	
.skip3
	ld a, [wJoyPressed]
	bit D_RIGHT_F, a
	jr z, .skip4
	; check if note in right hitbox
	ld a, 16*4 + 8
	call NoteInHitbox
	
.skip4
	ld a, [wJoyPressed]
	bit B_BUTTON_F, a
	jr z, .skip5
	; check if note in b hitbox
	ld a, 16*5 + 8
	call NoteInHitbox
	
.skip5
	ld a, [wJoyPressed]
	bit A_BUTTON_F, a
	jr z, .skip6
	; check if note in a hitbox
	ld a, 16*6 + 8
	call NoteInHitbox
	
.skip6
	ld a, [wJoyPressed]
	bit SELECT_F, a
	jr z, .skip7
	ld a, [wBombs]
	and a
	jr z, .skip7
	dec a
	ld [wBombs], a
	;;; scan oam table and delete every note
	ld c, 40
	ld hl, wOAM
.explosionLoop
	ld a, [hl]
	and a
	jr z, .no
	xor a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	call IncrementScore
	jr .yes
.no
	inc hl
	inc hl
	inc hl
	inc hl
.yes
	dec c
	jr nz, .explosionLoop
.skip7
	ld a, [wJoyPressed]
	bit START_F, a
	jr z, .skip8
	;;; pause the game
	ld a, [rNR51]
	push af
	xor a
	ld [rNR51], a
	ld bc, 40*4
	ld hl, wOAM
	ld de, wOAMCopy
	call CopyData
	fill wOAM, 40*4, 0
	ld bc, wQuitOAMEnd - wQuitOAM
	ld hl, wQuitOAM
	ld de, wOAM
	call CopyData
	ld a, %10010100
	ld [rBGP], a
.pauseLoop
	call WaitVBlank
	call Joypad
	ld a, [wJoyPressed]
	;;;
	bit D_LEFT_F, a
	jr z, .noLeft
	ld a, [wOAM + 1]
	cp 128
	jr z, .noLeft
	ld a, 128
	ld [wOAM + 1], a
.noLeft
	ld a, [wJoyPressed]
	bit D_RIGHT_F, a
	jr z, .noRight
	ld a, [wOAM + 1]
	cp 156
	jr z, .noRight
	ld a, 156
	ld [wOAM + 1], a
.noRight
	ld a, [wJoyPressed]
	bit A_BUTTON_F, a
	jr z, .pauseLoop
	ld a, [wOAM + 1]
	cp 128
	jp z, Init
	ld a, %11100100
	ld [rBGP], a
	ld bc, 40*4
	ld hl, wOAMCopy
	ld de, wOAM
	call CopyData
	pop af
	ld [rNR51], a
.skip8
	jp .loop

wQuitOAM:
	db 121, 128, 07, 00
	db 96, 128, 01, 00
	db 96, 136, 02, 00
	db 96, 144, 03, 00
	db 96, 156, 04, 00
	db 112, 128, 05, 00
	db 112, 156, 06, 00
wQuitOAMEnd:

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
	call IncrementStreak
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

IncrementStreak:
	ld a, [wStreak]
	and $0F
	cp 9
	jr nc, .doCarry
	inc a
	ld b, a
	ld a, [wStreak]
	and $F0
	or b
	ld [wStreak], a
	ret
.doCarry
	ld a, [wStreak]
	cp $90
	ret nc
	and $F0
	add $10
	ld [wStreak], a
	ld a, [wBombs]
	cp 3
	ret nc
	inc a
	ld [wBombs], a
	ret

DrawScore:
	ld a, [wDisplayedScore]
	ld hl, wScore
	cp [hl]
	ld a, [wDisplayedScore + 1]
	jp nz, .notEqual
	inc hl
	cp [hl]
	jr z, .equal
.notEqual
	and $0F
	cp 9
	jr nc, .doCarry
	inc a
	ld b, a
	ld a, [wDisplayedScore + 1]
	and $F0
	or b
	ld [wDisplayedScore + 1], a
	jr .print
.doCarry
	ld a, [wDisplayedScore + 1]
	and $F0
	cp $90
	jr nc, .doCarry2
	add $10
	ld [wDisplayedScore + 1], a
	jr .print
.doCarry2
	xor a
	ld [wDisplayedScore + 1], a
	
	ld a, [wDisplayedScore]
	and $0F
	cp 9
	jr nc, .doCarry3
	inc a
	ld b, a
	ld a, [wDisplayedScore]
	and $F0
	or b
	ld [wDisplayedScore], a
	jr .print
.doCarry3
	ld a, [wDisplayedScore]
	and $F0
	cp $90
	jr nc, .doCarry4
	add $10
	ld [wDisplayedScore], a
	jr .print
.doCarry4

.equal
.print
	ld hl, $986F
	ld a, [wDisplayedScore]
	and $F0
	swap a
	add $F0
	ld [hli], a
	ld a, [wDisplayedScore]
	and $0F
	add $F0
	ld [hli], a
	ld a, [wDisplayedScore + 1]
	and $F0
	swap a
	add $F0
	ld [hli], a
	ld a, [wDisplayedScore + 1]
	and $0F
	add $F0
	ld [hli], a
	ret

DrawStreak:
	ld hl, $98D1
	ld a, [wStreak]
	and $F0
	swap a
	add $F0
	ld [hli], a
	ld a, [wStreak]
	and $0F
	add $F0
	ld [hli], a
	
	ld c, 3
	ld a, [wBombs]
	ld hl, $9932
.fillBombs
	and a
	jr z, .finishFill
	ld [hl], $EE
	dec hl
	dec a
	dec c
	jr .fillBombs
.finishFill
	ld a, c
	and a
	jr z, .done
	ld [hl], $00
	dec hl
	dec c
	jr .finishFill
.done
	ret

FireAndFlamesNotes:
	db D_UP, 0
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_RIGHT, 10
	db A_BUTTON, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_LEFT, 10
	
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_UP, 10
	db A_BUTTON, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_LEFT, 10
	
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_UP, 10
	db A_BUTTON, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_LEFT, 10	
	db D_LEFT, 10

	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db D_RIGHT, 5
	db D_DOWN, 5
	db D_UP, 5
	db D_RIGHT, 5
	db D_DOWN, 5
	db D_UP, 5
	db D_LEFT, 5
	db D_DOWN, 5
	db D_LEFT, 5
	db D_LEFT, 5
	db D_LEFT, 5
	db A_BUTTON, 5
	db B_BUTTON, 5
	db D_RIGHT, 5
	db D_DOWN, 5
	
	db D_RIGHT, 5
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db D_UP, 10
	
	db A_BUTTON, 20
	db A_BUTTON, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	
	db B_BUTTON, 20
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 20
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db B_BUTTON, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	
	db D_RIGHT, 20
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db D_UP, 10
	db D_RIGHT, 10
	db D_RIGHT, 10
	db A_BUTTON, 10
	db B_BUTTON, 5
	db D_RIGHT, 5
	db D_DOWN, 5
	db B_BUTTON, 5
	db D_RIGHT, 5
	db D_DOWN, 5
	db D_UP, 5
	db D_UP, 5
	db D_RIGHT, 5
	db D_DOWN, 5
;	db D_UP, 5
;	db D_DOWN, 5
;	db D_UP, 5
	;db D_LEFT, 5
	;db D_UP, 5
	
	db A_BUTTON, 5
	db A_BUTTON, 10
	db A_BUTTON, 10
	db B_BUTTON, 20
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db D_UP, 53
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 20
	db B_BUTTON, 20
	db D_RIGHT, 10
	db D_UP, 20
	db B_BUTTON, 60
	db B_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db B_BUTTON, 10
	db D_RIGHT, 30
	db B_BUTTON, 20
	db A_BUTTON, 20
	db B_BUTTON, 10
	db D_RIGHT, 20
	db D_LEFT, 20
	
	db A_BUTTON, 60
	db A_BUTTON, 10
	db A_BUTTON, 10
	db B_BUTTON, 20
	db B_BUTTON, 10
	db D_RIGHT, 20
	db A_BUTTON, 10
	db D_UP, 30
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 20
	db B_BUTTON, 20
	db D_RIGHT, 10
	db D_DOWN, 10
	db B_BUTTON, 50
	db B_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db B_BUTTON, 20
	db D_RIGHT, 10
	db D_LEFT, 15
	db $FF, $FF

CanonNotes:
	; db D_LEFT, 0
	;db D_RIGHT, 30
	;db D_DOWN, 30
	;db D_UP, 30
	;db A_BUTTON, 30
	;db B_BUTTON, 30
	db A_BUTTON, 0
	db D_RIGHT, 80
	db B_BUTTON, 80
	db D_DOWN, 80
	db D_RIGHT, 80
	db D_LEFT, 80
	db D_RIGHT, 80
	db B_BUTTON, 80
	db A_BUTTON, 80
	db D_RIGHT, 0
	db D_RIGHT, 80
	db D_DOWN, 0
	db B_BUTTON, 80
	db D_UP, 0
	db D_DOWN, 80
	db D_RIGHT, 0
	db D_RIGHT, 80
	db D_UP, 0
	db D_LEFT, 80
	db D_DOWN, 0
	db D_RIGHT, 80
	db D_UP, 0
	db B_BUTTON, 80
	db D_RIGHT, 0 ; end of first melody
	db D_UP, 80
	db D_RIGHT, 40
	db A_BUTTON, 40
	db B_BUTTON, 40
	db D_DOWN, 40
	db D_UP, 40
	db D_RIGHT, 40
	db D_UP, 40
	db D_LEFT, 40
	db B_BUTTON, 40
	db D_LEFT, 40
	db D_RIGHT, 40 
	db D_DOWN, 40
	db A_BUTTON, 40
	db B_BUTTON, 40
	db D_RIGHT, 40
	db D_DOWN, 40
	db D_LEFT, 40
	db D_DOWN, 40
	db D_RIGHT, 40
	db B_BUTTON, 40
	db A_BUTTON, 40
	db D_DOWN, 40
	db D_UP, 40
	db D_RIGHT, 40
	db D_RIGHT, 40
	db D_DOWN, 40
	db D_DOWN, 40
	db B_BUTTON, 40
	db B_BUTTON, 40
	db A_BUTTON, 40
	db A_BUTTON, 40 ; end of 2nd melody
	db D_UP, 40
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db D_LEFT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db D_LEFT, 20
	db D_UP, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_LEFT, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db A_BUTTON, 20
	db D_LEFT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db D_LEFT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db D_LEFT, 20
	db D_UP, 20
	db B_BUTTON, 20
	db A_BUTTON, 20
	db D_LEFT, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db A_BUTTON, 20
	db D_LEFT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db D_UP, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db D_DOWN, 20
	db D_RIGHT, 20
	db B_BUTTON, 20
	db A_BUTTON, 20 ; end of 3rd melody
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db D_LEFT, 20
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	
	db A_BUTTON, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db D_LEFT, 20
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_DOWN, 10
	db D_UP, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	
	db A_BUTTON, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db B_BUTTON, 20
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_RIGHT, 10
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	
	db A_BUTTON, 20
	
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db D_LEFT, 20
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db A_BUTTON, 10
	
	db A_BUTTON, 20
	db A_BUTTON, 20
	db D_RIGHT, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db D_LEFT, 20
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db D_DOWN, 10
	db D_UP, 10
	db D_DOWN, 10
	db A_BUTTON, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_DOWN, 10
	
	db A_BUTTON, 20
	db B_BUTTON, 10
	db A_BUTTON, 10
	
	db B_BUTTON, 20
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	db B_BUTTON, 10
	db D_RIGHT, 10
	db A_BUTTON, 10
	db D_LEFT, 10
	db D_UP, 10
	db D_DOWN, 10
	db D_RIGHT, 10
	
	db A_BUTTON, 20
	
	db A_BUTTON, 20
	db D_RIGHT, 80
	db B_BUTTON, 80
	db D_DOWN, 80
	db D_RIGHT, 80
	db D_LEFT, 80
	db D_RIGHT, 80
	db B_BUTTON, 80
	db A_BUTTON, 80

	db $FF, $FF

RussianFolkNotes:
	db D_LEFT, 12
	db D_UP, 12
	db D_DOWN, 12
	db D_RIGHT, 12
	db B_BUTTON, 12
	db A_BUTTON, 24
	db D_LEFT, 24
	db D_UP, 12
	db A_BUTTON, 12
	db B_BUTTON, 12
	db D_RIGHT, 12
	db D_LEFT, 24
	db D_RIGHT, 22
	db D_RIGHT, 11
	db B_BUTTON, 11
	db D_RIGHT, 11
	db D_UP, 11
	db D_UP, 11
	db D_RIGHT, 11
	db D_UP, 11
	db D_LEFT, 11
	db D_LEFT, 11
	db D_DOWN, 11
	db D_UP, 11
	db D_LEFT, 13
	db D_LEFT, 12
	db D_UP, 12
	db D_DOWN, 12
	db D_RIGHT, 12
	db B_BUTTON, 12
	db A_BUTTON, 24
	db D_LEFT, 24
	db D_UP, 12
	db A_BUTTON, 12
	db B_BUTTON, 12
	db D_RIGHT, 12
	db D_LEFT, 24
	db D_RIGHT, 22
	db D_RIGHT, 11
	db B_BUTTON, 11
	db D_RIGHT, 11
	db D_UP, 11
	db D_UP, 11
	db D_RIGHT, 11
	db D_UP, 11
	db D_LEFT, 11
	db D_LEFT, 11
	db D_DOWN, 11
	db D_UP, 11
	db D_LEFT, 13

	db D_RIGHT, 60
	db D_DOWN, 17
	db D_UP, 17
	db D_LEFT, 17
	db D_RIGHT, 17
	db D_DOWN, 17
	db D_UP, 17
	db D_LEFT, 17
	db D_RIGHT, 13
	db D_DOWN, 13
	db D_UP, 13
	db D_LEFT, 13
	db D_RIGHT, 11
	db D_DOWN, 11
	db D_UP, 11
	db D_LEFT, 11
	db D_RIGHT, 11
	db D_DOWN, 11
	db D_UP, 11
	db D_LEFT, 11
	db D_RIGHT, 11
	db D_DOWN, 11
	db D_UP, 11
	db D_LEFT, 11

	db A_BUTTON, 14
	db D_RIGHT, 14
	db B_BUTTON, 14
	db D_DOWN, 14
	db D_RIGHT, 14
	db D_UP, 14
	db D_DOWN, 14
	db D_UP, 23
	db D_LEFT, 28
	db $FF

ToggleIcons:
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
	bit D_DOWN_F, a
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
	bit D_RIGHT_F, a
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
	ld bc, QuitGraphicsEnd - QuitGraphics
	ld hl, QuitGraphics
	ld de, vChars0 + $10
	call CopyData
	ld bc, ScoreStreakGraphicsEnd - ScoreStreakGraphics
	ld hl, ScoreStreakGraphics
	ld de, vChars1 + (LevelGraphics2End - LevelGraphics)
	call CopyData
	ld bc, DigitsGraphicsEnd - DigitsGraphics
	ld hl, DigitsGraphics
	ld de, $8f00
	call CopyData
	ld bc, BombGraphicsEnd - BombGraphics
	ld hl, BombGraphics
	ld de, vChars1 + (ScoreStreakGraphicsEnd - LevelGraphics)
	call CopyData
	
	call DrawLevelTiles
	
	ld hl, vBGMap0 + 32 * 2 + 16
	ld a, $E6
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

	ld hl, vBGMap0 + 32 * 5 + 15
	ld a, $E9
	ld [hli], a
	inc a
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

ScoreStreakGraphics:
	INCBIN "gfx/scorestreak.2bpp"
ScoreStreakGraphicsEnd:

BombGraphics:
	INCBIN "gfx/bomb.2bpp"
BombGraphicsEnd:

DigitsGraphics:
	INCBIN "gfx/digits.2bpp"
DigitsGraphicsEnd:

QuitGraphics:
	INCBIN "gfx/quit.2bpp"
QuitGraphicsEnd: