OAM_SPRITES = 40

section "OAM", wram0[$c100]
wOAM::
	ds 4 * OAM_SPRITES

section "OAM DMA Transfer", rom0
; copies DMA routine to HRAM. By GB specifications, all DMA needs to be done in HRAM (no other memory section is available during DMA)
WriteDMATransferToHRAM:
	ld c, $80
	ld b, DMATransferEnd - DMATransfer
	ld hl, DMATransfer
.copyLoop
	ld a, [hli]
	ld [$ff00+c], a
	inc c
	dec b
	jr nz, .copyLoop
	ret

; this routine is copied to HRAM and executed there on every VBlank
DMATransfer:
	ld a, wOAM >> 8
	ld [rDMA], a   ; start DMA
	ld a, OAM_SPRITES
.waitLoop               ; wait for DMA to finish
	dec a
	jr nz, .waitLoop
	ret
DMATransferEnd:
