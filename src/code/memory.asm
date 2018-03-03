; fill bc bytes at hl with a
FillMemory::
	ld e, a
	ld a, b
	or c
	ret z
	ld a, e
	ld [hli], a
	dec bc
	jr FillMemory
