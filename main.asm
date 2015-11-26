; Compile/Run this code at https://schweigi.github.io/assembler-simulator/
;
; Assembly BrainFuck parser by TajamSoft
; Input and output are working perfectly!
; There is a big problem. Memory. You barely  have 20 bytes of
; memory, which reduces with loops, so about 8 bytes safe.
;
; The limit for input + program is 35 characters
;
; Safety:
; Moving back, out of the virtual memory is allowed, but it will 
; make behaviour undefined, loops won't end, you may change some
; program code, etc...
;
; Try to make your BF safe ;)

JMP main
bfInput:
	DB "Hey!"   ; Your input here
	DB 0
bfProg:
	DB 0
	DB ">[>,][<][>.]"  ; Your program here


; Register overview:
; A: PC
; B: Console Pointer
; C: Actual PC char
; D: Virtual memory pointer
; Memlocs:
; 0xD1 start of BF memory (feel free to change it)
; 0xCF input pointer (No more registers xD)


main:
	MOV C, 0xCF
	MOV [C], 2 ;Point 0xCF to input 
	MOV D, 0xD1     ;Point D to virtual memory
	MOV B, 0xE8     ;Point B to output
	MOV A, bfProg   ;Point A to program
	jmp loop        ;Start program

moveRight:
	INC D           ;Increment D
	JMP loop

moveLeft:
	DEC D           ;Decrement D
	JMP loop
add:
	PUSH D
	MOV D, [D]      ;Move addrdat at D to D
	INC D           ;Increment D
	POP C
	MOV [C], D      ;Move D into addrdat at C
	MOV D, C        ;Restore D
	JMP loop
	
sub:
	PUSH D          ;Save D
	MOV D, [D]      ;Move addrdat at D to D
	DEC D           ;Decrement D
	POP C
	MOV [C], D      ;Move D into addrdat at C
	MOV D, C        ;Restore D
	JMP loop
out:
	MOV C, B
	PUSH B
	MOV B, [D]      ;Move MEMPOINTER to Output
	MOV [C], B
	POP B
	INC B           ;Increment Output
	JMP loop
in:
	PUSH D
	MOV D, 0xCF     ;Workaround not having registers...
	MOV C, [D]      ;Load C with 0xAA data
	MOV C, [C]	;Load C with 0xAA addrs 
	POP D    
	MOV [D], C
	;Now to increase In Pointer
	MOV C, [0xCF]
	INC C
	MOV [0xCF], C
	JMP loop
startLoop:
	PUSH A          ;Push PC into stack to rewind
	JMP loop
endLoop:
	MOV C, [D]
	CMP C, 0         ;CMP MEMPOINTER and zero
	JZ endLoopOpt1  ;if true
	JNZ endLoopOpt2 ;else
	JMP loop
endLoopOpt1:   ;Keep going
	JMP loop

endLoopOpt2:   ;Go back to start bracket
	POP C           ;Push startloop location into C
	MOV A, C        ;Set PC to C
	PUSH C          ;Push it back
	JMP loop
loop:
	INC A
	MOV C, [A]
	CMP C, '>'
	JZ moveRight
	CMP C, '<'
	JZ moveLeft
	CMP C, '+'
	JZ add
	CMP C, '-'
	JZ sub
	CMP C, '.'
	JZ out
	CMP C, ','
	JZ in
	CMP C, '['
	JZ startLoop
	CMP C, ']'
	JZ endLoop
	HLT ;Halt if unknown command/EOF
