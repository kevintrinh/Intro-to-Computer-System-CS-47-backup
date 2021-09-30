.include "./cs47_proj_macro.asm"
.data 
add:	.word 0x00000000
sub:	.word 0xFFFFFFFF
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	beq 	$a2, '+', add_logical
	beq 	$a2, '-', sub_logical
	beq 	$a2, '*', mul_signed
	beq	$a2, '/', div_signed
add_sub_logic:
	#store frame
	addi 	$sp, $sp, -28
	sw 	$fp, 28($sp)
	sw		$ra, 24($sp)
	sw		$a0, 20($sp)
	sw		$a1, 16($sp)
	sw		$a2, 12($sp)
	sw		$a3, 8($sp)
	addi	$fp, $sp, 28
	
	addi 	$t0, $zero, 0 #i = 0
	addi	$t1, $zero, 0 #s = 0
	extract_nth_bit($a3, $a2, $zero) #$a3(C) = $a2[0]
	beq 	$a3, 1 subtraction #if $a3 = 1, then branch to subtraction
	j 	addition #else jump to addition if $a3 is not = 1
subtraction:
	not 	$a1, $a1 #$a1 = ~$a1
	j 	addition
addition:
	#Y = $a2[0] xor ($a0[i] xor $a1[i])
	extract_nth_bit($t2, $a0, $t0) #$t2 = $a0[i]
	extract_nth_bit($t3, $a1, $t0) #$t3 = $a1[i]
	xor 	$t4, $t2, $t3 #$t4 = $a0[i] xor $a1[i]
	xor	$t5, $a3, $t4 #$t5(Y) = $a2 xor ($a0[i] xor $a1[i])
	
	#C = $a2[0] and ($a0[i] xor $a1[i]) or $a0[i] and $a1[i]
	and 	$t6, $t2, $t3 #$t6 = $a0[i] and $a1[i]
	and 	$t7, $a3, $t4 #$t7 = $a2 and ($a0[i] xor $a1[i])
	or		$a3, $t7, $t6 #$a3(C) = $a2 and ($a0[i] xor $a1[i]) or $a0[i] and $a1[i]
	
	insert_to_nth_bit($t1, $t0, $t5, $t8) #S[i] = Y
	addi 	$t0, $t0, 1 #i = i + 1
	bne  	$t0, 32, addition #if i is not = 32 then branch to addition
	#return
	move 	$v0, $t1 #return the addition of $a0 + $a1 or subtraction of $a0 - $a1
	move 	$v1, $a3 #return the final carryout 
	
	#restore frame
	lw 	$fp, 28($sp)
	lw 	$ra, 24($sp)
	lw 	$a0, 20($sp)
	lw 	$a1, 16($sp)
	lw 	$a2, 12($sp)
	lw 	$a3, 8($sp)
	addi 	$sp, $sp, 28
	jr 	$ra
add_logical:
	#store frame
	addi 	$sp, $sp, -16
	sw 	$fp, 16($sp)
	sw		$ra, 12($sp)
	sw		$a2, 8($sp)
	addi	$fp, $sp, 16
	
	lw		$a2, add #set $a2 = 0x00000000
	jal 	add_sub_logic	#call add_sub_logic
	
	#restore frame
	lw 	$fp, 16($sp)
	lw 	$ra, 12($sp)
	lw 	$a3, 8($sp)
	addi 	$sp, $sp, 16
	jr 	$ra
sub_logical:
	#store frame
	addi 	$sp, $sp, -16
	sw 	$fp, 16($sp)
	sw		$ra, 12($sp)
	sw		$a2, 8($sp)
	addi	$fp, $sp, 16
	
	lw		$a2, sub #set $a2 = 0xFFFFFFFF
	jal 	add_sub_logic #call add_sub_logic
	
	#restore frame
	lw 	$fp, 16($sp)
	lw 	$ra, 12($sp)
	lw 	$a2, 8($sp)
	addi 	$sp, $sp, 16
	jr 	$ra
	
twos_complement:
	#store frame
	addi 	$sp, $sp, -20
	sw 	$fp, 20($sp)
	sw		$ra, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)
	addi	$fp, $sp, 20
	
	not 	$a0, $a0 #$a0 = ~$a0
	addi 	$a1, $zero, 1 #$a1 = 1
	jal 	add_logical #~$a0 + 1
	
	#restore frame
	lw 	$fp, 20($sp)
	lw 	$ra, 16($sp)
	lw 	$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 20
	jr 	$ra
twos_complement_if_neg:
	#store frame
	addi 	$sp, $sp, -20
	sw 	$fp, 20($sp)
	sw		$ra, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)
	addi	$fp, $sp, 20
	
	move	$v0, $a0	
	bge 	$a0, $zero, end_twos_complement_if_neg	#check if $a0 > 0
	jal 	twos_complement #else jump to twos_complement
	j	end_twos_complement_if_neg #jump to end_twos_complement_if_neg
end_twos_complement_if_neg:
	#restore frame
	lw 	$fp, 20($sp)
	lw 	$ra, 16($sp)
	lw 	$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 20
	jr 	$ra
twos_complement_64bit:
	#store frame
	addi 	$sp, $sp, -28
	sw 	$fp, 28($sp)
	sw		$ra, 24($sp)
	sw		$s0, 20($sp)
	sw		$s1, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)	
	addi	$fp, $sp, 28

	not 	$a0, $a0 #$a0 = ~$a0
	not 	$a1, $a1 #$a1 = ~$a1
	move	$s0, $a1 #temporary save ~$a1 into $s0
	addi 	$a1, $zero, 1 #$a1 = 1
	jal add_logical #adding ~$a0 and 1 together
	move	$a1, $s0 #move the ~$a1 back to $a1
	move 	$s0, $v0 #set $s0 the sum of ~$a0 and 1
	move 	$a0, $v1 #move carry to become arg
	jal add_logical #adding the carry and ~$a1 together
	move	$s1, $v0	#set $s1 to the sum of carry and ~$a1
	#return
	move 	$v0, $s0 #set $v0 the sum of ~$a0 and 1 
	move 	$v1, $s1 #set $v1 to $s1

	#restore frame
	lw 	$fp, 28($sp)
	lw		$ra, 24($sp)
	lw		$s0, 20($sp)
	sw		$s1, 16($sp)
	lw		$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 28
	jr 	$ra
bit_replicator:
	#store frame
	addi 	$sp, $sp, -16
	sw 	$fp, 16($sp)
	sw		$ra, 12($sp)
	sw		$a0, 8($sp)
	addi	$fp, $sp, 16
	
	beq 	$a0, $zero, replicator
	lw 	$v0, sub #set $v0 = 0xFFFFFFFF
	
	#restore frame
	lw 	$fp, 16($sp)
	lw 	$ra, 12($sp)
	lw 	$a0, 8($sp)
	addi 	$sp, $sp, 16
	jr 	$ra
replicator:
	lw 	$v0, add #set $v0 = 0x00000000
	
	#restore frame
	lw 	$fp, 16($sp)
	lw 	$ra, 12($sp)
	lw 	$a0, 8($sp)
	addi 	$sp, $sp, 16
	jr 	$ra
mul_unsigned:
	#store frame
	addi 	$sp, $sp, -36
	sw 	$fp, 36($sp)
	sw		$ra, 32($sp)
	sw		$s0, 28($sp)
	sw		$s1, 24($sp)
	sw		$s2, 20($sp)
	sw		$s3, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)
	addi	$fp, $sp, 36
	
	addi 	$s0, $zero, 0 #i = 0
	addi	$s1, $zero, 0 #H = 0
	move	$s2, $a0 #M = MCND
	move 	$s3, $a1 #L = MPLR
	j 	multiplication
multiplication:
	extract_nth_bit($t0, $s3, $zero) #$t0(R) = L[0]
	move 	$a0, $t0 # $a0 = L[0]
	jal	bit_replicator #{32{L[0]}
	move 	$t0, $v0 #move the replicated bit back to $t0
	and 	$t1, $s2, $t0 #$t1(X) = M and R
	move 	$a0, $s1 #set $a0 to $t1(H)
	move 	$a1, $t1 #set $a1 to $t1(X)
	jal	add_logical #jump to add logical to add H and X
	move 	$s1, $v0 #set $s1(H) = $v0(H + X)
	srl 	$s3, $s3, 1 #L = L >> 1
	extract_nth_bit($t2, $s1, $zero) #$t2 = H[0]
	addi	$t3, $zero, 31 #add 31 to $t3
	insert_to_nth_bit($s3, $t3, $t2, $t4) #L[31] = H[0]
	srl	$s1, $s1, 1 #H = H >> 1
	addi 	$s0, $s0, 1 #i = i + 1
	bne	$s0, 32, multiplication #check if i is = 32
	#return
	move	$v0, $s3 #move $s3(L) to $v0
	move	$v1, $s1 #move $s1(H) to $v1
	
	#restore frame
	lw 	$fp, 36($sp)
	lw		$ra, 32($sp)
	lw		$s0, 28($sp)
	lw		$s1, 24($sp)
	lw		$s2, 20($sp)
	lw		$s3, 16($sp)
	lw		$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 36
	jr 	$ra
mul_signed:
	#store frame
	addi 	$sp, $sp, -52
	sw 	$fp, 52($sp)
	sw		$ra, 48($sp)
	sw		$s0, 44($sp)
	sw		$s1, 40($sp)
	sw		$s2, 36($sp)
	sw		$s3, 32($sp)
	sw		$s4, 28($sp)
	sw		$s5, 24($sp)
	sw		$s6, 20($sp)
	sw		$s7, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)	
	addi	$fp, $sp, 52
	
	move  $s0, $a0 #set $s0 to $a0(N1)
   move  $s1, $a1 #set $s1 to $a1(N2)
   jal   twos_complement_if_neg
   move  $s2, $v0 #temporary set $s2 to $v0
   move  $a0, $a1 #set $a0 to $a1
   jal   twos_complement_if_neg
   move  $a1, $v0 #set $a1(N2) to $v0
   move  $a0, $s2 #set $a0(N1) to $s2
   jal   mul_unsigned
   move  $s3, $v0 #$s3 = Rlo
   move  $s4, $v1 #$s4 = Rhi
   addi	$t0, $zero, 31 #$t0 = 31
   extract_nth_bit($s5, $s0, $t0) #$s5 = $s0[31]
   extract_nth_bit($s6, $s1, $t0) #$s6 = $s1[31]
   xor   $s7, $s5, $s6 #$s7(S) = $s5 xor $s6
   bne	$s7, 1, end_mul_signed #if S is not = 1
   move	$a0, $s3	#set $a0 to $s3(Rlo)
   move	$a1, $s4 #set $a1 to $s4(Rhi)
   jal    twos_complement_64bit
   j    end_mul_signed
end_mul_signed:
	#restore frame
	lw 	$fp, 52($sp)
	lw		$ra, 48($sp)
	lw		$s0, 44($sp)
	lw		$s1, 40($sp)
	lw		$s2, 36($sp)
	lw		$s3, 32($sp)
	lw		$s4, 28($sp)
	lw		$s5, 24($sp)
	lw		$s6, 20($sp)
	lw		$s7, 16($sp)
	lw		$a0, 12($sp)
	lw		$a1, 8($sp)	
	addi 	$sp, $sp, 52
	jr 	$ra
div_unsigned:
	#store frame
	addi 	$sp, $sp, -44
	sw 	$fp, 44($sp)
	sw		$ra, 40($sp)
	sw		$s0, 36($sp)
	sw		$s1, 32($sp)
	sw		$s2, 28($sp)
	sw		$s3, 24($sp)
	sw		$s4, 20($sp)
	sw		$s5, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)	
	addi	$fp, $sp, 44
	
	addi	$s0, $zero, 0 # i = 0
	move 	$s1, $a0 #Q = DVND
	move	$s2, $a1 #D = DVSR
	addi	$s3, $zero, 0 # R = 0
	j 	division
division:
	sll	$s3, $s3, 1 # R = R << 1
	addi	$t0, $zero, 31 # $t0 = 31
	extract_nth_bit($s4, $s1, $t0) #$s4 = Q[31]
	insert_to_nth_bit($s3, $zero, $s4, $t1) #R[0] = Q[31]
	sll	$s1, $s1, 1 #Q = Q << 1
	move	$t2, $a0 #temporary move Q to $t1
	move	$a0, $s3 #temporary move R into $a0
	jal 	sub_logical #subtract R and D
	move 	$s3, $a0 #move R back to $s3
	move	$a0, $t2 #move Q back to $a0
	move	$s5, $v0 #$s5(S) = R - D
	bge	$s5, 0, division_one #if S is greater then 0
	j	end_div_unsigned #else jump to end_div_unsigned
division_one:
	move 	$s3, $s5 #R = S
	addi	$t3, $zero, 1 #add 1 to $t3
	insert_to_nth_bit($s1, $zero, $t3, $t4) #Q[0] = 1
	j 	end_div_unsigned	
end_div_unsigned:
	addi 	$s0, $s0, 1 # i = i + 1
	bne	$s0, 32, division #if i is not = 32
	#return
	move	$v0, $s1 #move quotient to $v0
	move	$v1, $s3 #move remainder to $v1
	
	#restore frame
	lw 	$fp, 44($sp)
	lw		$ra, 40($sp)
	lw		$s0, 36($sp)
	lw		$s1, 32($sp)
	lw		$s2, 28($sp)
	lw		$s3, 24($sp)
	lw		$s4, 20($sp)
	lw		$s5, 16($sp)
	lw		$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 44
	jr 	$ra
div_signed:
	#store frame
	addi 	$sp, $sp, -52
	sw 	$fp, 52($sp)
	sw		$ra, 48($sp)
	sw		$s0, 44($sp)
	sw		$s1, 40($sp)
	sw		$s2, 36($sp)
	sw		$s3, 32($sp)
	sw		$s4, 28($sp)
	sw		$s5, 24($sp)
	sw		$s6, 20($sp)
	sw		$s7, 16($sp)
	sw		$a0, 12($sp)
	sw		$a1, 8($sp)	
	addi	$fp, $sp, 52
	
	move 	$s0, $a0 #set $s0 to $a0(N1)
	move	$s1, $a1 #set $s1 to $a1(N2)
	jal 	twos_complement_if_neg
	move	$s2, $v0 #temporary set $s2 to $v0 returned from twos_complement_if_neg
	move 	$a0, $a1 #set $a0 to $a1 because twos_complement_if_neg has one argument $a0
	jal	twos_complement_if_neg
	move	$a1, $v0 #set $a1(N2) to $v0, returned from twos_complement_if_neg
	move 	$a0, $s2 #set $a0(N1) to $s2
	jal	div_unsigned
	move	$s3, $v0 #$s3 = Q
	move	$s4, $v1 #$s4 = R
	addi	$t0, $zero, 31 #$t0 = 31
	extract_nth_bit($s5, $s0, $t0) #$s5 = $s0[31]
	extract_nth_bit($s6, $s1, $t0) #$s6 = $s1[31]
	xor	$s7, $s5, $s6 #$s7(S) = $s5 xor $s7
	bne	$s7, 1, div_signed_one #if S is not = 1 branch to div_signed_one
	move	$a0, $s3 #move Q into $a0 
	jal 	twos_complement #else jump and get the twos complement for Q
	move	$s3, $v0 #move the twos_complement for of Q into $s3
	j	div_signed_one #determined sign S of R
div_signed_one:
	addi	$t0, $zero, 31 #$t0 = 31
	extract_nth_bit($s5, $s0, $t0) #$s5 = $s0[31]
	move	$s7, $s5 #$s7(S) = $s5[31]
	bne	$s7, 1, end_div_signed #if S is not = 1 branch to end_div_signed
	move	$a0, $s4 #move R to $a0
	jal 	twos_complement #get the twos complement for R
	move 	$s4, $v0 #move the twos_complement form of R into $s1
	j	end_div_signed 
	
end_div_signed:
	#return
	move	$v0, $s3 #move quotient into $v0
	move	$v1, $s4 #move remainder into $v0
	
	#restore frame
	lw 	$fp, 52($sp)
	lw		$ra, 48($sp)
	lw		$s0, 44($sp)
	lw		$s1, 40($sp)
	lw		$s2, 36($sp)
	lw		$s3, 32($sp)
	lw		$s4, 28($sp)
	lw		$s5, 24($sp)
	lw		$s6, 20($sp)
	lw		$s7, 16($sp)
	lw		$a0, 12($sp)
	lw		$a1, 8($sp)
	addi 	$sp, $sp, 52
	jr 	$ra
