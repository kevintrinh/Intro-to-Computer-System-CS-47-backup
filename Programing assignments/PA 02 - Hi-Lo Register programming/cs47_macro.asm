#<------------------ MACRO DEFINITIONS ---------------------->#
        # Macro : print_str
        # Usage: print_str(<address of the string>)
        .macro print_str($arg)
	li	$v0, 4     # System call code for print_str  
	la	$a0, $arg   # Address of the string to print
	syscall            # Print the string        
	.end_macro
	
	# Macro : print_int
        # Usage: print_int(<val>)
        .macro print_int($arg)
	li 	$v0, 1     # System call code for print_int
	li	$a0, $arg  # Integer to print
	syscall            # Print the integer
	.end_macro
	
	# Macro : exit
        # Usage: exit
        .macro exit
	li 	$v0, 10 
	syscall
	.end_macro
	
	.macro read_int($arg)
	li	$v0, 5
	syscall
	move	$arg, $v0
	.end_macro 
	
	.macro print_reg_int($arg)
	li	$v0, 1
	move	$a0, $arg
	syscall 
	.end_macro
	
	.macro swap_hi_lo ($reg1, $reg2)
	mthi $reg1 	# Move $reg1 to Hi 
	mtlo $reg2	# Move $reg2 to Lo
	move $t0, $reg1	# Move $reg1 to $t0
	move $t1, $reg2	# Move $reg2 to $t1
	mthi $t1	# Move $t1 to Hi 
	mtlo $t0	# Move $t0 to Lo
	.end_macro 
	
	.macro print_hi_lo ($strHi, $strEqual, $strComma, $strLo)
	print_str($strHi)     # Print "Hi"
	print_str($strEqual)  # Print "="
	mfhi $t0 	      # Move HI value to $t0
	print_reg_int($t0)    # Print Hi value
	print_str($strComma)  # Print ","
	print_str($strLo)     # Print "Lo"
	print_str($strEqual)  # Print "="
	mflo $t1	      # Move Lo value to $t1
	print_reg_int($t1)    # Print Lo value
	.end_macro 
	
	.macro lwi ($reg, $ui, $li)
	lui $reg, $ui		
	ori $reg, $reg, $li 	#set $reg to $reg or $li
	.end_macro
	
	.macro push($reg)
	sw  $reg 0($sp)
	addi $sp, $sp, -4
	.end_macro 
	
	.macro pop($reg)
	addi $sp, $sp, +4
	lw $reg, 0($sp)
	.end_macro 
