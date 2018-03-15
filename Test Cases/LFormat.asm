6                    ;the program starts at address 6
125                  ;ISR address

;rise Reset signal, R0=R1=R2=0d,R3=255d,PC=Mem[0]=6
;data segment
10
20
30
40

;program
LDM R0, 2         ;R0 = 2d
LDM R1, 3         ;R1 = 3d
LDD R2, 2            ;R2 = 10d
LDD R3, 3            ;R3 = 20d
STD R2, 4           ;Mem[4]=10
STD R3, 5           ;Mem[5]=20
LDI R0, R3          ;R3 = Mem[R0], R3=M[2]= 10d
Add R3, R0			;R3= 12d
STI R1, R3          ;M[R1] = R3, M[3] = 12d

.125                ;go to address 125
RTI