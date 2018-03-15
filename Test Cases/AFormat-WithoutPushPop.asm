2                 ;the program starts at address 2
125               ;ISR address

;rise Reset signal, R0=R1=R2=0d,R3=255d,PC=Mem[0]=2
;program
;set value 45d at In Port
In R0              ;R0 = 45d
;set value 5d at In Port
In R1              ;R1 = 5d
;set value 70d at In Port
In R2              ;R2 = 70d = 01000110b
;set value 126d at In Port
In R3              ;R3 = 126d

ADD R0, R1         ;R0 = 50d = 00110010b, CCR=VCNZ=0000
SUB R1, R3         ;R1 = -121d = 10000111b, CCR=VCNZ=0110
AND R0, R1         ;R0=2d=000000010b, CCR=VCNZ=0100
NOT R0              ;R0 = -3d = 11111101b, CCR=VCNZ=0110       
ADD R3, R0         ;R3 = 123d = 01111011b, CCR=VCNZ=0100
RRC R0             ;R0 = -2d = 11111110b, CCR=VCNZ=0100
RRC R0             ;R0 = -1d = 11111111b, CCR=VCNZ=0000
RLC R2             ;R2 = -116d = 10001100b, CCR=VCNZ=0000
SUB R2, R2	       ;R2 = 0d, CCR=VCNZ=0001
MOV R1, R3         ;R1 = 123d, CCR=VCNZ=0001
OUT R1             ;OUT PORT = 123d, CCR=VCNZ=0001        
NOP
NOP
NEG R0			   ;R0 = 1d = 00000001b, CCR=VCNZ=0000
SETC               ;                   , CCR=VCNZ=0100
RRC R2             ;R2 = -128 = 10000000b, CCR=VCNZ=0010
NOT R2             ;R2 = 127d = 01111111b, CCR=VCNZ=0000
AND R2, R0         ;R2 = 1d = 00000001b, CCR=VCNZ=0000
RRC R2             ;R2 = 0d = 00000000b, CCR=VCNZ=0100
CLRC               ;                   , CCR=VCNZ=0000
INC R2             ;R2 = 1d = 00000001b, CCR=VCNZ=0000
RRC R2             ;R2 = 0d = 00000000b, CCR=VCNZ=0100
DEC R2             ;R2 = -1d = 11111111b, CCR=VCNZ=0110

.125                ;go to address 125
RTI