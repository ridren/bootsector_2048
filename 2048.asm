[BITS 16]
[ORG 0x7C00]

print_board:
	mov 	ax, 0x003
	int 	0x10

	mov 	bh, 0x0F
	xor 	cx, cx

;should be lower but for less instructions
	mov 	ds, cx
	mov 	es, cx

	mov 	dx, 0x184
	mov 	ax, 0x700
	int 	0x10

;	mov 	ah, 0x7	
;	mov 	al, 0x20
	mov 	ax, 0x720
	int 	0x10

	mov 	dx, 0xF
	xor 	bh, bh
.L1:
	push	dx

	;get which power to print
	mov 	bp, board_row0 
	add 	bp, dx
	;get text that corresponds to it
	mov 	BYTE bl, [bp]
	mov 	bp, text_pow00
	mov 	cl, bl
	shl 	bl, 0x2
	add 	bl, cl
	add 	bp, bx

	;find where to put the string
	;dh row
	;dl column
	mov 	dh, dl
	
	and 	dl, 0b11
	mov 	bl, dl
	shl 	dl, 0x2
	add 	dl, bl
	
	shr 	dh, 0x2

	mov 	cx, 0x5	
	mov 	ax, 0x1300
	mov 	bx, 0x000F
	int 	0x10
	
	pop 	dx

	dec 	dl
	jge  	.L1
	
register_input:
	xor 	ah, ah
	int 	0x16
	

	mov 	dx, 0x3
	xor 	cl, cl


	;left
	mov 	WORD [off_bp],  0x0
	mov 	di,  0x4
	mov 	si, 0x1
	cmp 	ah, 0x4B
	je 		arrow_horiz

	;right
	mov 	WORD [off_bp],  0x3
	mov 	di, -0x4
	mov 	si, -0x1
	cmp 	ah, 0x4D
	je 		arrow_horiz

	;up
	mov 	WORD [row_start], board_row0
	mov 	di,    board_row3 + 0x4
	mov 	si, 0x4
	cmp 	ah, 0x48
	je 		arrow_vert

	;down
	mov 	WORD [row_start], board_row3
	mov 	di,    board_row0 - 0x4
	mov 	si, -0x4
	cmp 	ah, 0x50
	je  	arrow_vert	

	jmp register_input
	
	;arrows are mostly similar, maybe somehow generalize them?
	;at least left right and up down
arrow_horiz:
.L1:
	mov 	bp, board_row0
	mov 	bx, dx
	shl 	bx, 0x2
	add 	bp, bx
	
	add 	WORD bp, [off_bp]
	mov 	bx, bp
	mov 	ax, bp
	add 	ax, di

	add 	bp, si

.L2:
	cmp 	BYTE [bp], cl
	jz 		arrow_horiz.L5

	cmp 	BYTE [bx], cl
	jnz  	arrow_horiz.L3
	
	xchg 	BYTE cl, [bp]
	xchg 	BYTE [bx], cl
	jmp 	arrow_horiz.L1

.L3:
	mov 	ch, BYTE [bp]
	cmp 	BYTE [bx], ch
	jne  	arrow_horiz.L4

	mov 	BYTE [bp], cl 
	inc 	BYTE [bx]

	;start line from the beggining
	jmp 	arrow_horiz.L1

.L4:
	add 	bx, si
	mov 	bp, bx
.L5:
	add 	bp, si
	cmp 	bp, ax
	jne 	arrow_horiz.L2

	dec 	dl
	jge  	arrow_horiz.L1

	jmp 	spawn 

arrow_vert:
.L1:
	mov 	WORD bp, [row_start] 
	add 	bp, dx
	
	mov 	bx, bp

	mov 	ax, di 
	add 	ax, dx

	add 	WORD bp, si 

.L2:
	cmp 	BYTE [bp], cl
	jz 		arrow_vert.L5

	cmp 	BYTE [bx], cl
	jnz  	arrow_vert.L3
	
	xchg 	BYTE cl, [bp]
	xchg 	BYTE [bx], cl
	jmp 	arrow_vert.L1

.L3:
	mov 	ch, BYTE [bp]
	cmp 	BYTE [bx], ch
	jne  	arrow_vert.L4

	mov 	BYTE [bp], cl 
	inc 	BYTE [bx]

	;start line from the beggining
	jmp 	arrow_vert.L1

.L4:
	add 	WORD bx, si 
	mov 	bp, bx
.L5:
	add 	WORD bp, si 
	cmp 	bp, ax
	jne 	arrow_vert.L2

	dec 	dl
	jge  	arrow_vert.L1

spawn:
	mov 	al, 0x32
.L1:
	dec 	al
	jle		game_over

	mov		bp, board_row0
	mov  	BYTE dl, [current_ind]

	add 	bp, dx
	add 	dl, 0x3
	and 	dl, 0b1111
	mov 	BYTE [current_ind], dl
	cmp 	BYTE [bp], cl
	jne 	spawn.L1

	inc 	BYTE [bp]

	jmp 	print_board

text_pow00	db "---- "
text_pow01 	db "---2 "
text_pow02 	db "---4 "
text_pow03 	db "---8 "
text_pow04 	db "--16 "
text_pow05 	db "--32 "
text_pow06 	db "--64 "
text_pow07 	db "-128 "
text_pow08 	db "-256 "
text_pow09 	db "-512 "
text_pow10 	db "1024 "
text_pow11	db "2048 "
text_pow12 	db "4096 "
text_pow13 	db "8192 "
text_lost   db "Game Over"

board_row0 	db 0x0, 0x0, 0x0, 0x0
board_row1 	db 0x0, 0x0, 0x0, 0x0
board_row2 	db 0x0, 0x1, 0x1, 0x0
board_row3 	db 0x1, 0x1, 0x1, 0x1

current_ind db 0x0
row_start:
off_bp  	dw 0xF

game_over:
	mov 	dx, 0x505

	mov 	cx, 0x9	
	mov 	ax, 0x1300
	mov 	bx, 0x000F
	mov 	bp, text_lost
	int 	0x10
	
;added to easier copy things from hex editor
random 		dq 0x0, 0x0, 0x0, 0x0, 0x0
