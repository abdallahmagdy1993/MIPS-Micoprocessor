2                   ;the program starts at address 2
125                 ;ISR address

;rise Reset signal, R0=R1=R2=0d,R3=255d,PC=Mem[0]=2
;program
;set value 15d at In Port
In R0               ;R0 = 15d
;set value 30d at In Port
In R1               ;R1 = 30d
;set value 75d at In Port
In R2               ;R2 = 75d
;set value 5d at In Port
In R3               ;R3 = 5d

;JC JV not tested here

JMP R0               ;Branch to address 15, PC=15
SUB R2, R1

.15	            ;go to adrress 15	    
SUB R0, R0          ;R0=0, Z=1
JZ R1             ;Branch taken, PC=30
SUB R2, R1          

.30
SUB R2, R1          ;R2=45, N=0
JN R0             ;Branch Not Taken!
CALL R2           ;Mem[255]=PC+1=33, R3(SP)=254, PC=45
ADD R0, R1          ;R0=60
JMP R0               ;PC=60

.45
ADD R0, R1          ;R0=30
RET                 ;PC=33, R3(SP)=255

.60
ADD R2,R3          ; R2 = 50, 54, 57, 59, 60
LOOP R3, R0

.125                
RTI
