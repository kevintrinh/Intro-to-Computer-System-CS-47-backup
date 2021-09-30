# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
#for extract_nth_bit($regD, $regS, $regT) 
#You need to rigth shift number in $regS by $regT and mask it for 1st bit position value only. 
#Assign this masked result to $regD.

.macro extract_nth_bit($regD, $regS, $regT) 
#addi	$regD, $zero, 1 #$regD = 1
#srlv	$regS, $regS, $regT #$regS = $regS >> $regT
#and	$regD, $regD, $regS    #$regD = $regD and $regS

addi	$regD, $zero, 1 #$regD = 1 
sllv	$regD, $regD, $regT #$regD = $regD << $regT
and	$regD, $regD, $regS #$regD = $regD and $regS
srlv	$regD, $regD, $regT #$regD = $regD >> $regT
.end_macro
 
#for insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
#Prepare a mask in $maskReg by shifting 0x1 for $regS amount and then 
#inverting it. 
#Mask $regD with $maskReg. 
#Now, shift left register $regT by amount in $regS and then 
#logically OR this resultant pattern to $regD to insert the bit at the nth position.

.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
add	$maskReg, $zero, 1 #$maskReg = 1
sllv	$maskReg, $maskReg, $regS #$maskReg = $maskReg << 1
not	$maskReg, $maskReg #$maskReg = ~$maskReg
and	$regD, $regD, $maskReg #$regD = $regD and $maskReg
sllv	$regT, $regT, $regS #$regT = $RegT << $regS
or		$regD, $regD, $regT #regD = $regD or $regT
.end_macro
