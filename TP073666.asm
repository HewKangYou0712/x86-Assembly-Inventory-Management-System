;Define Constant
SYS_EXIT	equ	1
SYS_READ	equ	3
SYS_WRITE	equ	4
SYS_OPEN	equ	5
SYS_CLOSE	equ 6

O_RDONLY	equ	0
O_WRONLY	equ	1
O_TRUNC		equ 512

STDIN		equ	0
STDOUT		equ	1

;Data Section
section .data
	temp_file		db	"temp.txt", 0
	error_op_file	db	"Error Opening the File!", 0
	first			db	1
	current_state	db	0
	empty_string	db	"", 0

	;User Details
	userdata_file	db	'userdata.txt', 0
	username1		times	30	db	0
	password1		times 	30	db	0
	user_role1		times	30	db	0
	username2		times	30	db	0
	password2		times	30	db	0
	user_role2		times	30	db	0
	username3		times	30	db	0
	password3		times	30	db	0
	user_role3		times	30	db	0
	username4		times	30	db	0
	password4		times	30	db	0
	user_role4		times	30	db	0
	username5		times	30	db	0
	password5		times	30	db	0
	user_role5		times	30	db	0

	;Inventory Details
	inventory_file	db	'inventory.txt', 0
	item_code1		times	30	db	0
	item_name1		times	30	db	0
	item_code2		times	30	db	0
	item_name2		times	30	db	0
	item_code3		times	30	db	0
	item_name3		times	30	db	0
	item_code4		times	30	db	0
	item_name4		times	30	db	0
	item_code5		times	30	db	0
	item_name5		times	30	db	0
	item_code6		times	30	db	0
	item_name6		times	30	db	0
	item_code7		times	30	db	0
	item_name7		times	30	db	0
	item_code8		times	30	db	0
	item_name8		times	30	db	0
	item_code9		times	30	db	0
	item_name9		times	30	db	0
	item_code10		times	30	db	0
	item_name10		times	30	db	0

	delimiter		db	';', 0
	buffer			times	1024	db	0
	newline			db	0xA, 0
	main_menu		db	"==============", 0xA, \
						"     Menu     ", 0xA, \
						"==============", 0xA, \
						"1. Login      ", 0xA, \
						"2. Exit System", 0xA, \
						"==============", 0xA, \
						"Choice: ", 0

	error_choice1			db	"Invalid Choice! Please select between 1 to 2!", 0xA, 0
	error_choice2			db	"Invalid Choice! Please select between 1 to 4!", 0xA, 0
	error_choice3			db	"Invalid Choice! Please select between 1 to 7!", 0xA, 0
	inv_int_input			db	"Invalid Input! Please enter an INTEGER", 0
	clear_screen			db	0x1B, '[2J', 0x1B, '[H', 0
	number1					db	"1", 0
	number2					db	"2", 0
	number3					db	"3", 0
	number4					db	"4", 0
	number5					db	"5", 0
	number6					db	"6", 0
	number7					db	"7", 0

;Reserve Section
section .bss
	item_in_stock1		resb	30
	item_in_stock2		resb	30
	item_in_stock3		resb	30
	item_in_stock4		resb	30
	item_in_stock5		resb	30
	item_in_stock6		resb	30
	item_in_stock7		resb	30
	item_in_stock8		resb	30
	item_in_stock9		resb	30
	item_in_stock10		resb	30

	fd					resd	1
	fd_temp				resd	1

	login_or_exit		resb	30
	username			resb	30
	password			resb	30
	user_role			resb	30
	admin_choice		resb	30
	inv_choice			resb	30
	
	new_username		resb	30
	new_password1		resb	30
	new_password2		resb	30
	new_user_role		resb	30
	role_choice			resb	30
	new_user_detail		resb	93

	del_user_item		resb	30
	del_choice			resb	30
	username_code_found	resb	30
	data_to_store		resb	1024
	data_to_write		resb	1024

	new_item_code		resb	30
	new_item_name		resb	30
	new_item_quan		resb	30
	quan_to_store		resb	30
	new_item_detail		resb	93

	rep_take_item_code	resb	30
	user_input			resb	30
	box_rep_take		resb	30
	piece_per_box		resb	30
	total_item			resb	30
	item_name			resb	30
	item_in_stock		resb	30
	final_item_num		resb	30
	rep_choice			resb	30
	item_to_store		resb	93

section .text
	global _start

;Exit Program if Cannot Open Files
file_open_error:
    mov ecx, error_op_file
    call print

	call print_newline
    jmp exit_program

;Verify All Files
file_handling:
	mov eax, SYS_OPEN
	mov ebx, userdata_file
	mov ecx, O_RDONLY
	int 0x80
	test eax, eax
	js file_open_error
	mov [fd], eax

	mov eax, SYS_CLOSE
	mov ebx, [fd]
	int 0x80

	mov eax, SYS_OPEN
	mov ebx, inventory_file
	mov ecx, O_RDONLY
	int 0x80
	test eax, eax
	js file_open_error
	mov [fd], eax

	mov eax, SYS_CLOSE
	mov ebx, [fd]
	int 0x80

	mov eax, SYS_OPEN
	mov ebx, temp_file
	mov ecx, O_RDONLY
	int 0x80
	test eax, eax
	js file_open_error
	mov [fd], eax

	mov eax, SYS_CLOSE
	mov ebx, [fd]
	int 0x80

	ret

;Read User Data
_start:
	call file_handling

	mov ebx, temp_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [current_state], 1
	call read_userdata
	jmp parse_loop1

;Read Inventory
start2:	
	mov ebx, temp_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [current_state], 2
	call load_inventory
	jmp parse_loop2

where_to_go:
	mov eax, SYS_CLOSE
	mov ebx, dword [fd]
	int 0x80

	mov al, [current_state]
	cmp al, 1
	je start2
	cmp al, 2
	je display_main_menu
	cmp al, 3
	je loop_admin_menu
	cmp al, 4
	je loop_inv_menu

clean_user_data:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, username1
	mov ecx, 30
	call clear_buffer
	mov esi, username2
	mov ecx, 30
	call clear_buffer
	mov esi, username3
	mov ecx, 30
	call clear_buffer
	mov esi, username4
	mov ecx, 30
	call clear_buffer
	mov esi, username5
	mov ecx, 30
	call clear_buffer

	mov esi, password1
	mov ecx, 30
	call clear_buffer
	mov esi, password2
	mov ecx, 30
	call clear_buffer
	mov esi, password3
	mov ecx, 30
	call clear_buffer
	mov esi, password4
	mov ecx, 30
	call clear_buffer
	mov esi, password5
	mov ecx, 30
	call clear_buffer

	mov esi, user_role1
	mov ecx, 30
	call clear_buffer
	mov esi, user_role2
	mov ecx, 30
	call clear_buffer
	mov esi, user_role3
	mov ecx, 30
	call clear_buffer
	mov esi, user_role4
	mov ecx, 30
	call clear_buffer
	mov esi, user_role5
	mov ecx, 30
	call clear_buffer

	ret

read_userdata:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer
	call clean_user_data

	mov eax, SYS_OPEN
	mov ebx, userdata_file
	mov ecx, O_RDONLY
	int 0x80
	mov dword [fd], eax

	mov eax, SYS_READ
	mov ebx, dword [fd]
	mov ecx, buffer
	mov edx, 1024
	int 0x80

	mov esi, buffer
	mov edi, username1
	mov ecx, 0
	mov ebx, 1

	ret

parse_loop1:
	lodsb
	cmp al, 0
	je where_to_go
	cmp al, byte [delimiter]
	je next_part1
	cmp al, 0xA
	je next_user
	stosb
	jmp parse_loop1

next_part1:
	inc ecx
	cmp ecx, 1
	je switch_to_password
	cmp ecx, 2
	je switch_to_role
	jmp parse_loop1

switch_to_password:
	cmp ebx, 1
	je store_password1
	cmp ebx, 2
	je store_password2
	cmp ebx, 3
	je store_password3
	cmp ebx, 4
	je store_password4
	cmp ebx, 5
	je store_password5

store_password1:
	mov edi, password1
	jmp parse_loop1

store_password2:
	mov edi, password2
	jmp parse_loop1

store_password3:
	mov edi, password3
	jmp parse_loop1

store_password4:
	mov edi, password4
	jmp parse_loop1

store_password5:
	mov edi, password5
	jmp parse_loop1

switch_to_role:
	cmp ebx, 1
	je store_user_role1
	cmp ebx, 2
	je store_user_role2
	cmp ebx, 3
	je store_user_role3
	cmp ebx, 4
	je store_user_role4
	cmp ebx, 5
	je store_user_role5

store_user_role1:
	mov edi, user_role1
	jmp parse_loop1

store_user_role2:
	mov edi, user_role2
	jmp parse_loop1

store_user_role3:
	mov edi, user_role3
	jmp parse_loop1

store_user_role4:
	mov edi, user_role4
	jmp parse_loop1

store_user_role5:
	mov edi, user_role5
	jmp parse_loop1

next_user:
	inc ebx
	mov ecx, 0
	cmp ebx, 2
	je set_user2_destination

	mov ecx, 0
	cmp ebx, 3
	je set_user3_destination

	mov ecx, 0
	cmp ebx, 4
	je set_user4_destination

	mov ecx, 0
	cmp ebx, 5
	je set_user5_destination

	jmp parse_loop1

set_user2_destination:
	mov edi, username2
	jmp parse_loop1

set_user3_destination:
	mov edi, username3
	jmp parse_loop1

set_user4_destination:
	mov edi, username4
	jmp parse_loop1

set_user5_destination:
	mov edi, username5
	jmp parse_loop1

clean_inventory_data:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, item_code1
	mov ecx, 30
	call clear_buffer
	mov esi, item_code2
	mov ecx, 30
	call clear_buffer
	mov esi, item_code3
	mov ecx, 30
	call clear_buffer
	mov esi, item_code4
	mov ecx, 30
	call clear_buffer
	mov esi, item_code5
	mov ecx, 30
	call clear_buffer
	mov esi, item_code6
	mov ecx, 30
	call clear_buffer
	mov esi, item_code7
	mov ecx, 30
	call clear_buffer
	mov esi, item_code8
	mov ecx, 30
	call clear_buffer
	mov esi, item_code9
	mov ecx, 30
	call clear_buffer
	mov esi, item_code10
	mov ecx, 30
	call clear_buffer

	mov esi, item_name1
	mov ecx, 30
	call clear_buffer
	mov esi, item_name2
	mov ecx, 30
	call clear_buffer
	mov esi, item_name3
	mov ecx, 30
	call clear_buffer
	mov esi, item_name4
	mov ecx, 30
	call clear_buffer
	mov esi, item_name5
	mov ecx, 30
	call clear_buffer
	mov esi, item_name6
	mov ecx, 30
	call clear_buffer
	mov esi, item_name7
	mov ecx, 30
	call clear_buffer
	mov esi, item_name8
	mov ecx, 30
	call clear_buffer
	mov esi, item_name9
	mov ecx, 30
	call clear_buffer
	mov esi, item_name10
	mov ecx, 30
	call clear_buffer

	mov esi, item_in_stock1
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock2
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock3
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock4
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock5
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock6
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock7
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock8
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock9
	mov ecx, 30
	call clear_buffer
	mov esi, item_in_stock10
	mov ecx, 30
	call clear_buffer

	ret

load_inventory:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer
	call clean_inventory_data

	mov eax, SYS_OPEN
	mov ebx, inventory_file
	mov ecx, O_RDONLY
	int 0x80
	mov dword [fd], eax

	mov eax, SYS_READ
	mov ebx, dword [fd]
	mov ecx, buffer
	mov edx, 1024
	int 0x80

	mov esi, buffer
	mov edi, item_code1
	mov ecx, 0
	mov ebx, 1
	
	ret

parse_loop2:
	lodsb
	cmp al, 0
	je where_to_go
	cmp al, byte [delimiter]
	je next_part2
	cmp al, 0xA
	je next_item
	stosb
	jmp parse_loop2

next_part2:
	inc ecx
	cmp ecx, 1
	je switch_to_name
	cmp ecx, 2
	je switch_to_number
	jmp parse_loop2

switch_to_name:
	cmp ebx, 1
	je store_name1
	cmp ebx, 2
	je store_name2
	cmp ebx, 3
	je store_name3
	cmp ebx, 4
	je store_name4
	cmp ebx, 5
	je store_name5
	cmp ebx, 6
	je store_name6
	cmp ebx, 7
	je store_name7
	cmp ebx, 8
	je store_name8
	cmp ebx, 9
	je store_name9
	cmp ebx, 10
	je store_name10

store_name1:
	mov edi, item_name1
	jmp parse_loop2

store_name2:
	mov edi, item_name2
	jmp parse_loop2

store_name3:
	mov edi, item_name3
	jmp parse_loop2

store_name4:
	mov edi, item_name4
	jmp parse_loop2

store_name5:
	mov edi, item_name5
	jmp parse_loop2

store_name6:
	mov edi, item_name6
	jmp parse_loop2

store_name7:
	mov edi, item_name7
	jmp parse_loop2

store_name8:
	mov edi, item_name8
	jmp parse_loop2

store_name9:
	mov edi, item_name9
	jmp parse_loop2

store_name10:
	mov edi, item_name10
	jmp parse_loop2

switch_to_number:
	cmp ebx, 1
	je store_number1
	cmp ebx, 2
	je store_number2
	cmp ebx, 3
	je store_number3
	cmp ebx, 4
	je store_number4
	cmp ebx, 5
	je store_number5
	cmp ebx, 6
	je store_number6
	cmp ebx, 7
	je store_number7
	cmp ebx, 8
	je store_number8
	cmp ebx, 9
	je store_number9
	cmp ebx, 10
	je store_number10

store_number1:
	mov edi, item_in_stock1
	jmp parse_loop2

store_number2:
	mov edi, item_in_stock2
	jmp parse_loop2

store_number3:
	mov edi, item_in_stock3
	jmp parse_loop2

store_number4:
	mov edi, item_in_stock4
	jmp parse_loop2

store_number5:
	mov edi, item_in_stock5
	jmp parse_loop2

store_number6:
	mov edi, item_in_stock6
	jmp parse_loop2

store_number7:
	mov edi, item_in_stock7
	jmp parse_loop2

store_number8:
	mov edi, item_in_stock8
	jmp parse_loop2

store_number9:
	mov edi, item_in_stock9
	jmp parse_loop2

store_number10:
	mov edi, item_in_stock10
	jmp parse_loop2

next_item:
	inc ebx
	mov ecx, 0
	cmp ebx, 2
	je set_item2_destination

	mov ecx, 0
	cmp ebx, 3
	je set_item3_destination

	mov ecx, 0
	cmp ebx, 4
	je set_item4_destination

	mov ecx, 0
	cmp ebx, 5
	je set_item5_destination

	mov ecx, 0
	cmp ebx, 6
	je set_item6_destination

	mov ecx, 0
	cmp ebx, 7
	je set_item7_destination

	mov ecx, 0
	cmp ebx, 8
	je set_item8_destination

	mov ecx, 0
	cmp ebx, 9
	je set_item9_destination

	mov ecx, 0
	cmp ebx, 10
	je set_item10_destination

	jmp parse_loop2

set_item2_destination:
	mov edi, item_code2
	jmp parse_loop2

set_item3_destination:
	mov edi, item_code3
	jmp parse_loop2

set_item4_destination:
	mov edi, item_code4
	jmp parse_loop2

set_item5_destination:
	mov edi, item_code5
	jmp parse_loop2

set_item6_destination:
	mov edi, item_code6
	jmp parse_loop2

set_item7_destination:
	mov edi, item_code7
	jmp parse_loop2

set_item8_destination:
	mov edi, item_code8
	jmp parse_loop2

set_item9_destination:
	mov edi, item_code9
	jmp parse_loop2

set_item10_destination:
	mov edi, item_code10
	jmp parse_loop2

invalid_choice:
	mov ecx, error_choice1
	call print

	call print_newline

	jmp display_main_menu

;Start System
display_main_menu:
	mov ecx, main_menu
	call print

	mov ecx, login_or_exit
	mov edx, 30
	call read

	call print_newline

	mov al, [login_or_exit]
	cmp al, 0xA
	je invalid_choice

	mov esi, login_or_exit
	call strip_newline

	mov esi, login_or_exit
	mov edi, number1
	call strcmp
	mov eax, 0
	je login

	mov esi, login_or_exit
	mov edi, number2
	call strcmp
	mov eax, 0
	je exit_program

	jmp invalid_choice

section .data
	enter_username		db	"Username (<ENTER> to Leave): ", 0
	enter_password		db	"Password: ", 0
	error_login			db	"Invalid Username or Password!", 0xA, 0
	user_role_admin		db	"Admin", 0
	user_role_inv		db	"Inventory_Checker", 0

login_fail:
	mov ecx, error_login
	call print

	call print_newline
	jmp login

;User Login
login:
	mov ecx, enter_username
	call print

	mov ecx, username
	mov edx, 30
	call read

	call print_newline

	mov al, [username]
	cmp al, 0xA
	je display_main_menu

	mov ecx, enter_password
	call print

	mov ecx, password
	mov edx, 30
	call read

	call print_newline

	mov esi, username
	call strip_newline
	mov esi, password
	call strip_newline

	mov esi, user_role
	mov ecx, 30
	call clear_buffer

	mov esi, username
	mov edi, username1
	call strcmp
	cmp eax, 0
	je check_user1

	mov esi, username
	mov edi, username2
	call strcmp
	cmp eax, 0
	je check_user2

	mov esi, username
	mov edi, username3
	call strcmp
	cmp eax, 0
	je check_user3

	mov esi, username
	mov edi, username4
	call strcmp
	cmp eax, 0
	je check_user4

	mov esi, username
	mov edi, username5
	call strcmp
	cmp eax, 0
	je check_user5

	jmp login_fail

check_user1:
	mov esi, password
	mov edi, password1
	call strcmp
	cmp eax, 0
	jne login_fail

	mov esi, user_role1
	jmp check_user_role

check_user2:
	mov esi, password
	mov edi, password2
	call strcmp
	cmp eax, 0
	jne login_fail

	mov esi, user_role2
	jmp check_user_role

check_user3:
	mov esi, password
	mov edi, password3
	call strcmp
	cmp eax, 0
	jne login_fail

	mov esi, user_role3
	jmp check_user_role

check_user4:
	mov esi, password
	mov edi, password4
	call strcmp
	cmp eax, 0
	jne login_fail

	mov esi, user_role4
	jmp check_user_role

check_user5:
	mov esi, password
	mov edi, password5
	call strcmp
	cmp eax, 0
	jne login_fail

	mov esi, user_role5
	jmp check_user_role

check_user_role:
	mov edi, user_role
	mov esi, esi
	call copy_loop

	mov esi, user_role
	mov edi, user_role_admin
	call strcmp
	cmp eax, 0
	je admin_menu

	mov esi, user_role
	mov edi, user_role_inv
	call strcmp
	cmp eax, 0
	je inventory_checker_menu

	jmp login
	
section .data:
	welcome_admin		db	"Welcome Admin, ", 0
	print_admin_menu	db	"=================", 0xA, \
							"    Admin Menu   ", 0xA, \
							"=================", 0xA, \
							"1. List All Users", 0xA, \
							"2. Add New User", 0xA, \
							"3. Delete User", 0xA, \
							"4. List All Items", 0xA, \
							"5. Add New Item", 0xA, \
							"6. Delete Item", 0xA, \
							"7. Exit", 0xA, \
							"=================", 0xA, \
							"Choice: ", 0

;Admin Menu
admin_invalid_choice:
	mov ecx, error_choice3
	call print

	call print_newline

	jmp loop_admin_menu

admin_menu:
	mov ecx, welcome_admin
	call print

	mov ecx, username
	call print

	call print_newline
	call print_newline

	jmp loop_admin_menu

loop_admin_menu:
	mov ecx, print_admin_menu
	call print

	mov ecx, admin_choice
	mov edx, 30
	call read

	call print_newline

	mov al, [admin_choice]
	cmp al, 0xA
	je admin_invalid_choice

	mov esi, admin_choice
	call strip_newline

	mov byte [current_state], 3

	mov esi, admin_choice
	mov edi, number1
	call strcmp
	mov eax, 0
	je list_all_users

	mov esi, admin_choice
	mov edi, number2
	call strcmp
	mov eax, 0
	je add_new_user

	mov esi, admin_choice
	mov edi, number3
	call strcmp
	mov eax, 0
	je delete_user

	mov esi, admin_choice
	mov edi, number4
	call strcmp
	mov eax, 0
	je list_all_items

	mov esi, admin_choice
	mov edi, number5
	call strcmp
	mov eax, 0
	je add_new_item

	mov esi, admin_choice
	mov edi, number6
	call strcmp
	mov eax, 0
	je delete_item

	mov esi, admin_choice
	mov edi, number7
	call strcmp
	mov eax, 0
	je exit_to_menu

	mov esi, admin_choice
	mov ecx, 30
	call clear_buffer

	jmp admin_invalid_choice

section .data
	message_user		db	"Username        Password        User Role", 0
	message_list		db	"Item Code        Item Name        Item In Stock", 0

	;Add New User
	add_user_msg		db	"Please enter the USERNAME of user to be added (<ENTER> to Leave): ", 0
	add_pass1_msg		db	"Please enter the PASSWORD of user to be added: ", 0
	add_pass2_msg		db	"Please confirm again the PASSWORD of user: ", 0
	add_role_msg		db	"Please enter the USER ROLE of user to be added!", 0xA, \
							"Enter <1> for Admin", 0xA, \
							"Enter <2> for Inventory Checker", 0xA, \
							"User Role: ", 0
	inv_username		db	"Invalid Username! This Username has existed", 0
	inv_password1		db	"The Password cannot be EMPTY!", 0
	inv_password2		db	"Please enter the same password!", 0
	add_user_success	db	"The USER has been ADDED successfully!", 0

	;Delete User
	del_user_msg		db	"Please enter the USERNAME of user to be deleted (<ENTER> to Leave): ", 0
	rej_del_msg			db	"Invalid Action! You CAN'T DELETE this user!", 0
	user_unfound		db	"Invalid Input! This USERNAME not existed!", 0
	confirm_del			db	"Are you sure want to Continue DELETING?", 0xA, \
							"1. CONTINUE Delete", 0xA, \
							"2. CANCEL", 0xA, \
							"Choice: ", 0
	del_user_success	db	"The USER has been DELETED successfully!", 0

	;Add New Item
	add_item_msg		db	"Please enter the ITEM CODE of item to be added (<ENTER> to Leave): ", 0
	add_name_msg		db	"Please enter the NAME of item to be added: ", 0
	add_quan_msg		db	"Please enter the QUANTITY of item to be added: ", 0
	inv_code_msg		db	"Invalid Code! This Item Code has existed!", 0
	inv_name_msg		db	"The Item Name cannot be empty!", 0
	inv_quan_msg1		db	"The Quantity of item cannot be empty!", 0
	inv_quan_msg2		db	"The Quantity of item must be POSITIVE INTEGER!", 0
	add_item_success	db	"The ITEM has been ADDED successfully!", 0

	;Delete Item
	del_item_msg		db	"Please enter the ITEM CODE to be deleted (<ENTER> to Leave): ", 0
	item_unfound		db	"Invalid Input! This ITEM not existed!", 0
	del_item_success	db	"The ITEM has been DELETED successfully!", 0

	space				db	"		", 0

;Admin Function
verify_user_item:
	mov esi, ecx
	mov edi, empty_string
	call strcmp
	cmp eax, 0
	je print_line_after_verify
	ret

print_line_after_verify:
	call print_newline
	mov al, [current_state]
	cmp al, 3
	je loop_admin_menu
	cmp al, 4
	je loop_inv_menu

print_user_item:
	call print

	call print_space

	mov ecx, ebp
	call print

	call print_space

	mov ecx, esi
	call print

    call print_newline
    ret

list_all_users:
	mov byte [current_state], 3
	mov ecx, message_user
	call print

	call print_newline

	mov ecx, username1
	call verify_user_item
	mov ebp, password1
	mov esi, user_role1
    call print_user_item

	mov ecx, username2
	call verify_user_item
	mov ebp, password2
	mov esi, user_role2
    call print_user_item

	mov ecx, username3
	call verify_user_item
	mov ebp, password3
	mov esi, user_role3
    call print_user_item

	mov ecx, username4
	call verify_user_item
	mov ebp, password4
	mov esi, user_role4
    call print_user_item

	mov ecx, username5
	call verify_user_item
	mov ebp, password5
	mov esi, user_role5
    call print_user_item

	ret

list_all_items:
	mov ecx, message_list
	call print

	call print_newline

	mov ecx, item_code1
	call verify_user_item
	mov ebp, item_name1
	mov esi, item_in_stock1
    call print_user_item

	mov ecx, item_code2
	call verify_user_item
	mov ebp, item_name2
	mov esi, item_in_stock2
    call print_user_item

	mov ecx, item_code3
	call verify_user_item
	mov ebp, item_name3
	mov esi, item_in_stock3
    call print_user_item

	mov ecx, item_code4
	call verify_user_item
	mov ebp, item_name4
	mov esi, item_in_stock4
    call print_user_item

	mov ecx, item_code5
	call verify_user_item
	mov ebp, item_name5
	mov esi, item_in_stock5
    call print_user_item

	mov ecx, item_code6
	call verify_user_item
	mov ebp, item_name6
	mov esi, item_in_stock6
    call print_user_item

	mov ecx, item_code7
	call verify_user_item
	mov ebp, item_name7
	mov esi, item_in_stock7
    call print_user_item

	mov ecx, item_code8
	call verify_user_item
	mov ebp, item_name8
	mov esi, item_in_stock8
    call print_user_item

	mov ecx, item_code9
	call verify_user_item
	mov ebp, item_name9
	mov esi, item_in_stock9
    call print_user_item

	mov ecx, item_code10
	call verify_user_item
	mov ebp, item_name10
	mov esi, item_in_stock10
    call print_user_item

    ret

invalid_username:
	mov ecx, inv_username
	call print

	call print_newline
	call print_newline
	
	jmp add_new_user

verify_username:
	mov esi, new_username
	mov edi, username1
	call strcmp
	mov eax, 0
	je invalid_username

	mov esi, new_username
	mov edi, username2
	call strcmp
	mov eax, 0
	je invalid_username

	mov esi, new_username
	mov edi, username3
	call strcmp
	mov eax, 0
	je invalid_username

	mov esi, new_username
	mov edi, username4
	call strcmp
	mov eax, 0
	je invalid_username

	mov esi, new_username
	mov edi, username5
	call strcmp
	mov eax, 0
	je invalid_username

	ret

invalid_password:
	call print

	call print_newline
	call print_newline
	jmp add_new_user

print_invalid_password1:
	mov ecx, inv_password1
	jmp invalid_password

print_invalid_password2:
	mov ecx, inv_password2
	jmp invalid_password

verify_password:
	mov esi, new_password1
	mov edi, new_password2
	call strcmp
	mov eax, 0
	jne print_invalid_password2

	ret

set_role_admin:
	mov esi, user_role_admin
    mov edi, new_user_role
	call copy_loop
	jmp store_user_to_file

set_role_inv:
	mov esi, user_role_inv
    mov edi, new_user_role
	call copy_loop
	jmp store_user_to_file

verify_user_role:
	mov al, al
	cmp al, '1'
	je set_role_admin
	cmp al, '2'
	je set_role_inv

	call print_newline
	mov ecx, error_choice1
	call print
	call print_newline

	jmp add_new_user

store_user_to_file:
	mov edi, new_user_detail
	mov esi, newline
	call copy_loop

	mov esi, new_username
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, new_password2
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, new_user_role
	call copy_loop

    mov byte [edi], 0

	mov ebx, userdata_file
	mov ecx, 0x401
	mov edi, new_user_detail
	call write_to_file

	call print_newline

	mov esi, new_username
	mov ecx, 30
	call clear_buffer
	mov esi, new_password1
	mov ecx, 30
	call clear_buffer
	mov esi, new_password2
	mov ecx, 30
	call clear_buffer
	mov esi, new_user_role
	mov ecx, 30
	call clear_buffer
	mov esi, new_user_detail
	mov ecx, 93
	call clear_buffer

	mov ecx, add_user_success
	call print

	call print_newline
	call print_newline

	mov byte [current_state], 3
	call read_userdata
	jmp parse_loop1

add_new_user:
	mov ecx, add_user_msg
	call print

	mov ecx, new_username
	mov edx, 30
	call read

	call print_newline

	mov al, [new_username]
	cmp al, 0xA
	je loop_admin_menu

	mov esi, new_username
	call strip_newline
	call verify_username

	mov ecx, add_pass1_msg
	call print

	mov ecx, new_password1
	mov edx, 30
	call read

	mov al, [new_password1]
	cmp al, 0xA
	je print_invalid_password1

	call print_newline

	mov ecx, add_pass2_msg
	call print

	mov ecx, new_password2
	mov edx, 30
	call read

	mov al, [new_password2]
	cmp al, 0xA
	je print_invalid_password1

	mov esi, new_password1
	call strip_newline
	mov esi, new_password2
	call strip_newline
	call verify_password

	call print_newline	

	mov ecx, add_role_msg
	call print

	mov ecx, role_choice
	mov edx, 30
	call read

	mov al, [role_choice]
	je verify_user_role

	jmp add_new_user

delete_rejected:
	mov ecx, rej_del_msg
	call print

	call print_newline
	call print_newline
	jmp delete_user

verify_existed_username:
	mov esi, del_user_item
	mov edi, username
	call strcmp
	mov eax, 0
	je delete_rejected

	mov esi, del_user_item
	mov edi, user_role_admin
	call strcmp
	mov eax, 0x0
	je delete_rejected

	mov esi, del_user_item
	mov edi, username1
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, username2
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, username3
	call strcmp
	mov eax, 0
	je delete_or_not	

	mov esi, del_user_item
	mov edi, username4
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, username5
	call strcmp
	mov eax, 0
	je delete_or_not

	jmp print_user_unfound

delete_user:
	mov byte [current_state], 1
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [first], 1
	
	mov ecx, del_user_msg
	call print

	mov ecx, del_user_item
	mov edx, 30
	call read

	call print_newline

	mov al, [del_user_item]
	cmp al, 0xA
	je loop_admin_menu

	mov esi, del_user_item
	call strip_newline

    mov eax, SYS_OPEN
    mov ebx, userdata_file
    mov ecx, O_RDONLY
    int 0x80
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

	mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

	jmp verify_existed_username

delete_item:
	mov byte [current_state], 2
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [first], 1

	mov ecx, del_item_msg
	call print

	mov ecx, del_user_item
	mov edx, 30
	call read

	call print_newline

	mov al, [del_user_item]
	cmp al, 0xA
	je loop_admin_menu

	mov esi, del_user_item
	call strip_newline

    mov eax, SYS_OPEN
    mov ebx, inventory_file
    mov ecx, O_RDONLY
    int 0x80
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

	mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

	jmp verify_existed_item

delete_or_not:
	mov ecx, confirm_del
	call print

	mov ecx, del_choice
	mov edx, 30
	call read

	mov esi, del_choice
	call strip_newline

	call print_newline

	mov esi, del_choice
	mov edi, number1
	call strcmp
	mov eax, 0
	je continue_delete

	mov esi, del_choice
	mov edi, number2
	call strcmp
	mov eax, 0
	je back_to_delete

	mov ecx, error_choice1
	call print
	call print_newline
	
	jmp delete_or_not

back_to_delete:
	mov al, [current_state]
	cmp al, 1
	je delete_user
	cmp al, 2
	je delete_item
	jmp loop_admin_menu

continue_delete:	
	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	mov esi, data_to_store
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, buffer
	mov edi, username_code_found
	jmp delete_in_file

delete_in_file:
	lodsb
	cmp al, 0
	je done_delete
	cmp al, byte [delimiter]
	je store_next_part
	stosb
	jmp delete_in_file

store_next_part:
	mov edi, data_to_store
	mov esi, esi
	call copy_loop

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	call compare_username_code
	mov esi, data_to_store
	jmp write_newline

compare_username_code:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, username_code_found
	call strip_newline	
	mov edi, esi
	mov esi, del_user_item
	call strcmp
	mov eax, 0
	je skip_line

	ret

write_newline:
	mov al, [first]
	cmp al, 1
	je write_username_code

	mov ebx, temp_file
	mov ecx, 0x401
	mov edi, newline
	call write_to_file

	jmp write_username_code

write_username_code:
	mov byte [first], 0

	mov ebx, temp_file
	mov ecx, 0x401
	mov edi, username_code_found
	call write_to_file

	mov ebx, temp_file
	mov ecx, 0x401
	mov edi, delimiter
	call write_to_file

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer
	
	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_store
	mov edi, data_to_write
	jmp write_line

write_line:
	lodsb
	cmp al, 0
	je done_delete
	cmp al, 0xA
	je write_and_delete_in_file
	stosb
	jmp write_line

write_and_delete_in_file:
	mov edi, buffer
	mov esi, esi
	call copy_loop

	mov ebx, temp_file
	mov ecx, 0x401
	mov edi, data_to_write
	call write_to_file

	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	mov esi, data_to_store
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, buffer
	mov edi, username_code_found
	jmp delete_in_file

skip_line:
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer
	
	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_store
	mov edi, data_to_write
	jmp skip_line_loop

skip_line_loop:
	lodsb
	cmp al, 0
	je clear_everything
	cmp al, 0xA
	je back_delete_in_file
	stosb
	jmp skip_line_loop

back_delete_in_file:
	mov edi, buffer
	mov esi, esi
	call copy_loop

	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	mov esi, data_to_store
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, buffer
	mov edi, username_code_found
	jmp delete_in_file

clear_everything:
	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_store
	mov ecx, 1024
	call clear_buffer

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

	jmp done_delete

done_delete:
	mov ebx, temp_file
	mov ecx, 0x401
	mov edi, data_to_write
	call write_to_file

	mov ebx, temp_file
	mov ecx, 0x401
	mov byte [edi], 0
	call write_to_file

	mov esi, data_to_write
	mov ecx, 1024
	call clear_buffer

	mov esi, data_to_store
	mov ecx, 1024
	call clear_buffer

	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov esi, username_code_found
	mov ecx, 30
	call clear_buffer

    mov eax, SYS_OPEN
    mov ebx, temp_file
    mov ecx, O_RDONLY
    int 0x80
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

	mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

	mov ebx, temp_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov al, [current_state]
	cmp al, 1
	je store_to_user_file
	cmp al, 2
	je store_to_inv_file
	cmp al, 3
	je replenish_to_inv_file
	cmp al, 4
	je stock_taking_to_inv_file

	jmp loop_admin_menu
	
store_to_user_file:
	mov ebx, userdata_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov ebx, userdata_file
	mov ecx, 0x401
	mov edi, buffer
	call write_to_file

	mov ecx, del_user_success
	call print

	call print_newline
	call print_newline

    mov byte [current_state], 3
    call read_userdata
    jmp parse_loop1

store_to_inv_file:
	mov ebx, inventory_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, buffer
	call write_to_file

	mov ecx, del_item_success
	call print

	call print_newline
	call print_newline

    mov byte [current_state], 3
    call load_inventory
    jmp parse_loop2

verify_existed_item:
	mov esi, del_user_item
	mov edi, item_code1
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code2
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code3
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code4
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code5
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code6
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code7
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code8
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code9
	call strcmp
	mov eax, 0
	je delete_or_not

	mov esi, del_user_item
	mov edi, item_code10
	call strcmp
	mov eax, 0
	je delete_or_not

	jmp print_item_unfound

print_user_unfound:
	mov ecx, user_unfound
	call print

	call print_newline
	call print_newline

	jmp delete_user

print_item_unfound:
	mov ecx, item_unfound
	call print

	call print_newline
	call print_newline

	jmp delete_item

add_new_item:
	mov esi, new_item_code
	mov ecx, 30
	call clear_buffer

	mov esi, new_item_name
	mov ecx, 30
	call clear_buffer

	mov esi, new_item_quan
	mov ecx, 30
	call clear_buffer

	mov esi, quan_to_store
	mov ecx, 30
	call clear_buffer

	mov esi, new_item_detail
	mov ecx, 93
	call clear_buffer

	mov ecx, add_item_msg
	call print

	mov ecx, new_item_code
	mov edx, 30
	call read

	call print_newline

	mov al, [new_item_code]
	cmp al, 0xA
	je loop_admin_menu

	mov esi, new_item_code
	call strip_newline

	call verify_item_code

	mov ecx, add_name_msg
	call print

	mov ecx, new_item_name
	mov edx, 30
	call read

	mov al, [new_item_name]
	cmp al, 0xA
	je invalid_item_name

	mov esi, new_item_name
	call strip_newline

	call print_newline

	mov ecx, add_quan_msg
	call print

	mov ecx, new_item_quan
	mov edx, 30
	call read

	mov al, [new_item_quan]
	cmp al, 0xA
	je invalid_item_quantity1

	mov esi, new_item_quan
	call strip_newline

	mov edi, quan_to_store
	mov esi, new_item_quan
	call copy_loop

	mov esi, new_item_quan
	call check_integer
	jnz invalid_item_quantity2

	mov ecx, new_item_quan
	call string_to_integer

	mov [new_item_quan], eax
	call check_positive
	jnz invalid_item_quantity2

	jmp store_item_to_file

store_item_to_file:
	mov edi, new_item_detail
	mov esi, newline
	call copy_loop

	mov esi, new_item_code
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, new_item_name
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, quan_to_store
	call copy_loop

    mov byte [edi], 0

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, new_item_detail
	call write_to_file

	call print_newline

	mov esi, new_item_code
	mov ecx, 30
	call clear_buffer
	mov esi, new_item_name
	mov ecx, 30
	call clear_buffer
	mov esi, new_item_quan
	mov ecx, 30
	call clear_buffer
	mov esi ,quan_to_store
	mov ecx, 30
	call clear_buffer
	mov esi, new_item_detail
	mov ecx, 93
	call clear_buffer

	mov ecx, add_item_success
	call print

	call print_newline
	call print_newline	

	mov byte [current_state], 3
	call load_inventory
	call parse_loop2

verify_item_code:
	mov esi, item_code1
	call compare_item_code
	mov esi, item_code2
	call compare_item_code
	mov esi, item_code3
	call compare_item_code
	mov esi, item_code4
	call compare_item_code
	mov esi, item_code5
	call compare_item_code
	mov esi, item_code6
	call compare_item_code
	mov esi, item_code7
	call compare_item_code
	mov esi, item_code8
	call compare_item_code
	mov esi, item_code9
	call compare_item_code
	mov esi, item_code10
	call compare_item_code

	ret

compare_item_code:
	mov edi, new_item_code
	call strcmp
	mov eax, 0
	je invalid_item_code

	ret

invalid_item_code:
	mov ecx, inv_code_msg
	call print

	call print_newline
	call print_newline

	jmp add_new_item

invalid_item_name:
	mov ecx, inv_name_msg
	call print

	call print_newline
	call print_newline

	jmp add_new_item

invalid_item_quantity1:
	mov ecx, inv_quan_msg1
	call print

	call print_newline
	call print_newline

	jmp add_new_item

invalid_item_quantity2:
	mov ecx, inv_quan_msg2
	call print

	call print_newline
	call print_newline

	jmp add_new_item

section .data:
	welcome_inv				db	"Welcome Inventory Checker, ", 0
	print_inv_menu			db	"============================", 0xA, \
								"   Inventory Checker Menu   ", 0xA, \
								"============================", 0xA, \
								"1. List All Items", 0xA, \
								"2. Inventory Replenishment", 0xA, \
								"3. Stock Taking", 0xA, \
								"4. Exit", 0xA, \
								"============================", 0xA, \
								"Choice: ", 0
	replenish_item_msg		db	"Please enter the ITEM CODE to be replenished (<ENTER> to Leave): ", 0
	replenish_box_msg		db	"Please enter the number of BOXES/PACKAGES to be replenished: ", 0
	rep_tak_piece_msg		db	"Please enter the number of PIECES per BOX/PACKAGE: ", 0
	replenish_number_msg	db	"Total Number of Item to be REPLENISHED: ", 0
	replenish_conf_msg		db	"Do you want to CONTINUE REPLENISH this item?", 0xA, \
								"1. Continue", 0xA, \
								"2. Cancel", 0xA, \
								"Choice: ", 0

	taking_item_msg			db	"Please enter the ITEM CODE to be taked (<ENTER> to Leave): ", 0
	taking_box_msg			db	"Please enter the number of BOXES/PACKAGES to be taked: ", 0
	taking_number_msg		db	"Total Number of Item to be TAKED: ", 0
	taking_conf_msg			db	"Do you want to CONTINUE STOCK TAKING this item?", 0xA, \
								"1. Continue", 0xA, \
								"2. Cancel", 0xA, \
								"Choice: ", 0

	inv_rep_box1			db	"Invalid Input! The numbr of BOXES/PACKAGES cannot be EMPTY!", 0
	inv_rep_box2			db	"Invalid Input! Please enter a POSITIVE INTEGER!", 0
	rep_inv_success			db	"The ITEM has been REPLENISHED successfully!", 0
	stock_tak_success		db	"The ITEM has been TAKED successfully!", 0

	inv_tak_msg				db	"Invalid Action! The number of item to be TAKED is larger than the ITEM IN STOCK!"

;Inventory Checker Menu
inventory_checker_menu:
	mov ecx, welcome_inv
	call print

	mov ecx, username
	call print

	call print_newline
	call print_newline

	jmp loop_inv_menu

loop_inv_menu:
	mov ecx, print_inv_menu
	call print

	mov ecx, inv_choice
	mov edx, 30
	call read
	call print_newline

	mov al, [inv_choice]
	cmp al, 0xA
	je inv_invalid_choice

	mov esi, inv_choice
	call strip_newline

	mov byte [current_state], 4

	mov esi, inv_choice
	mov edi, number1
	call strcmp
	mov eax, 0
	je list_all_items

	mov byte [current_state], 1
	mov esi, inv_choice
	mov edi, number2
	call strcmp
	mov eax, 0
	je clear_buffer_bef_rep_tak

	mov esi, inv_choice
	mov edi, number3
	call strcmp
	mov eax, 0
	je stock_taking_clear_buffer

	mov esi, inv_choice
	mov edi, number4
	call strcmp
	mov eax, 0
	je exit_to_menu

	jmp inv_invalid_choice

inv_invalid_choice:
	mov ecx, error_choice2
	call print

	call print_newline

	jmp loop_inv_menu

;Inventory Checker Functions
clear_buffer_bef_rep_tak:
	mov esi, rep_take_item_code
	mov ecx, 30
	call clear_buffer

	mov esi, user_input
	mov ecx, 30
	call clear_buffer

	mov esi, box_rep_take
	mov ecx, 30
	call clear_buffer

	mov esi, piece_per_box
	mov ecx, 30
	call clear_buffer

	mov esi, total_item
	mov ecx, 30
	call clear_buffer

	mov esi, item_name
	mov ecx, 30
	call clear_buffer

	mov esi, item_in_stock
	mov ecx, 30
	call clear_buffer

	mov esi, final_item_num
	mov ecx, 30
	call clear_buffer

	mov esi, rep_choice
	mov ecx, 30
	call clear_buffer

	mov esi, item_to_store
	mov ecx, 93
	call clear_buffer

	mov al, [current_state]
	cmp al, 1
	je replenish_item
	cmp al, 2
	je stock_taking

replenish_item:
	mov byte [first], 0

	mov ecx, replenish_item_msg
	call print

	mov ecx, rep_take_item_code
	mov edx, 30
	call read

	call print_newline

	mov al, [rep_take_item_code]
	cmp al, 0xA
	je loop_inv_menu

	mov esi, rep_take_item_code
	call strip_newline

	jmp check_rep_take_item_code

clear_replenish_buffer:
	mov esi, item_name
	mov ecx, 30
	call clear_buffer

	mov esi, item_in_stock
	mov ecx, 30
	call clear_buffer

	ret

check_rep_take_item_code:
	mov edi, item_name
	mov esi, item_name1
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock1
	call copy_loop

	mov esi, item_code1
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name2
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock2
	call copy_loop

	mov esi, item_code2
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name3
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock3
	call copy_loop

	mov esi, item_code3
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name4
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock4
	call copy_loop

	mov esi, item_code4
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name5
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock5
	call copy_loop

	mov esi, item_code5
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name6
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock6
	call copy_loop

	mov esi, item_code6
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name7
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock7
	call copy_loop

	mov esi, item_code7
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name8
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock8
	call copy_loop

	mov esi, item_code8
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name9
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock9
	call copy_loop

	mov esi, item_code9
	call compare_rep_take_item_code
	call clear_replenish_buffer

	mov edi, item_name
	mov esi, item_name10
	call copy_loop

	mov edi, item_in_stock
	mov esi, item_in_stock10
	call copy_loop

	mov esi, item_code10
	call compare_rep_take_item_code
	call clear_replenish_buffer

	jmp replenish_item_unfound

compare_rep_take_item_code:
	mov edi, rep_take_item_code
	call strcmp
	mov eax, 0
	je replenish_where_to_go

	ret

replenish_where_to_go:
	mov al, [first]
	cmp al, 0
	je get_total1
	cmp al, 1
	je continue_replenish
	cmp al, 3
	je get_total2
	cmp al, 4
	je continue_taking

	jmp clear_buffer_bef_rep_tak

replenish_item_unfound:
	mov ecx, item_unfound
	call print

	call print_newline
	call print_newline

	jmp clear_buffer_bef_rep_tak

get_total1:
	mov esi, user_input
	mov ecx, 30
	call clear_buffer

	mov esi, box_rep_take
	mov ecx, 30
	call clear_buffer

	mov esi, piece_per_box
	mov ecx, 30
	call clear_buffer	

	mov ecx, replenish_box_msg
	call print

	mov ecx, user_input
	mov edx, 30
	call read

	mov al, [user_input]
	cmp al, 0xA
	je invalid_replenish_quantity1

	mov esi, user_input
	call strip_newline

	mov edi, box_rep_take
	mov esi, user_input
	call copy_loop

	mov esi, user_input
	call check_integer
	jnz invalid_replenish_quantity2

	mov ecx, user_input
	call string_to_integer
	mov [user_input], eax
	call check_positive
	jnz invalid_replenish_quantity2

	mov esi, user_input
	mov ecx, 30
	call clear_buffer

	call print_newline
	
	mov ecx, rep_tak_piece_msg
	call print

	mov ecx, user_input
	mov edx, 30
	call read

	mov al, [user_input]
	cmp al, 0xA
	je invalid_replenish_quantity1

	mov esi, user_input
	call strip_newline

	mov edi, piece_per_box
	mov esi, user_input
	call copy_loop

	mov esi, user_input
	call check_integer
	jnz invalid_replenish_quantity2

	mov ecx, user_input
	call string_to_integer
	mov [user_input], eax
	call check_positive
	jnz invalid_replenish_quantity2

	mov ecx, box_rep_take
	call string_to_integer
	mov esi, eax

	mov ecx, piece_per_box
	call string_to_integer
	mov edi, eax
	
	imul edi, esi
	mov eax, edi
	mov edi, total_item
    call integer_to_string

	call print_newline

	jmp replenish_choice

replenish_choice:
	mov byte [first], 1
	mov ecx, replenish_number_msg
	call print

	mov ecx, total_item
	call print

	call print_newline
	mov ecx, replenish_conf_msg
	call print

	mov ecx, rep_choice
	mov edx, 30
	call read

	mov esi, rep_choice
	call strip_newline

	call print_newline

	mov edi, rep_choice
	mov esi, number1
	call strcmp
	mov eax, 0
	je check_rep_take_item_code

	mov edi, rep_choice
	mov esi, number2
	call strcmp
	mov eax, 0
	je clear_buffer_bef_rep_tak

	mov ecx, error_choice1
	call print
	call print_newline

	jmp replenish_choice

continue_replenish:
	mov ecx, item_in_stock
	call string_to_integer
	mov esi, eax

	mov ecx, total_item
	call string_to_integer
	mov edi, eax

	add edi, esi
	mov eax, edi
	mov edi, final_item_num
    call integer_to_string

	mov edi, item_to_store
	mov esi, newline
	call copy_loop

	mov esi, rep_take_item_code
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, item_name
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, final_item_num
	call copy_loop

    mov byte [edi], 0

	mov byte [current_state], 3
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [first], 1

    mov eax, SYS_OPEN
    mov ebx, inventory_file
    mov ecx, O_RDONLY
    int 0x80
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

	mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

	mov edi, del_user_item
	mov esi, rep_take_item_code
	call copy_loop

	jmp continue_delete

invalid_replenish_quantity1:
	mov ecx, inv_rep_box1
	call print

	call print_newline
	call print_newline

	mov al, [first]
	cmp al, 0
	je get_total1
	cmp al, 3
	je get_total2

invalid_replenish_quantity2:
	mov ecx, inv_rep_box2
	call print

	call print_newline
	call print_newline

	mov al, [first]
	cmp al, 0
	je get_total1
	cmp al, 3
	je get_total2

replenish_to_inv_file:
	mov ebx, inventory_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, buffer
	call write_to_file

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, item_to_store
	call write_to_file

	mov ecx, rep_inv_success
	call print

	call print_newline
	call print_newline

    mov byte [current_state], 4
    call load_inventory

    jmp parse_loop2

stock_taking_clear_buffer:
	mov byte [current_state], 2
	jmp clear_buffer_bef_rep_tak

stock_taking:
	mov byte [first], 3

	mov ecx, taking_item_msg
	call print

	mov ecx, rep_take_item_code
	mov edx, 30
	call read

	call print_newline

	mov al, [rep_take_item_code]
	cmp al, 0xA
	je loop_inv_menu

	mov esi, rep_take_item_code
	call strip_newline

	jmp check_rep_take_item_code

get_total2:
	mov esi, user_input
	mov ecx, 30
	call clear_buffer

	mov esi, box_rep_take
	mov ecx, 30
	call clear_buffer

	mov esi, piece_per_box
	mov ecx, 30
	call clear_buffer	

	mov ecx, taking_box_msg
	call print

	mov ecx, user_input
	mov edx, 30
	call read

	mov al, [user_input]
	cmp al, 0xA
	je invalid_replenish_quantity1

	mov esi, user_input
	call strip_newline

	mov edi, box_rep_take
	mov esi, user_input
	call copy_loop

	mov esi, user_input
	call check_integer
	jnz invalid_replenish_quantity2

	mov ecx, user_input
	call string_to_integer
	mov [user_input], eax
	call check_positive
	jnz invalid_replenish_quantity2

	mov esi, user_input
	mov ecx, 30
	call clear_buffer

	call print_newline
	
	mov ecx, rep_tak_piece_msg
	call print

	mov ecx, user_input
	mov edx, 30
	call read

	mov al, [user_input]
	cmp al, 0xA
	je invalid_replenish_quantity1

	mov esi, user_input
	call strip_newline

	mov edi, piece_per_box
	mov esi, user_input
	call copy_loop

	mov esi, user_input
	call check_integer
	jnz invalid_replenish_quantity2

	mov ecx, user_input
	call string_to_integer
	mov [user_input], eax
	call check_positive
	jnz invalid_replenish_quantity2

	mov ecx, box_rep_take
	call string_to_integer
	mov esi, eax

	mov ecx, piece_per_box
	call string_to_integer
	mov edi, eax
	
	imul edi, esi
	mov eax, edi
	mov edi, total_item
    call integer_to_string

	mov ecx, total_item
	call string_to_integer
	mov edi, eax

	mov ecx, item_in_stock
	call string_to_integer
	mov esi, eax

	cmp edi, esi
	jg print_invalid_taking_msg

	call print_newline

	jmp stock_taking_choice

print_invalid_taking_msg:
	call print_newline
	mov ecx, inv_tak_msg
	call print
	call print_newline
	call print_newline

	jmp get_total2

stock_taking_choice:
	mov byte [first], 4
	mov ecx, taking_number_msg
	call print

	mov ecx, total_item
	call print

	call print_newline
	mov ecx, taking_conf_msg
	call print

	mov ecx, rep_choice
	mov edx, 30
	call read

	mov esi, rep_choice
	call strip_newline

	call print_newline

	mov edi, rep_choice
	mov esi, number1
	call strcmp
	mov eax, 0
	je check_rep_take_item_code

	mov edi, rep_choice
	mov esi, number2
	call strcmp
	mov eax, 0
	je stock_taking_clear_buffer

	mov ecx, error_choice1
	call print
	call print_newline

	jmp stock_taking_choice

continue_taking:
	mov ecx, item_in_stock
	call string_to_integer
	mov esi, eax

	mov ecx, total_item
	call string_to_integer
	mov edi, eax

	sub esi, edi
	mov eax, esi
	mov edi, final_item_num
    call integer_to_string

	mov edi, item_to_store
	mov esi, newline
	call copy_loop

	mov esi, rep_take_item_code
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, item_name
	call copy_loop

	mov esi, delimiter
	call copy_loop

	mov esi, final_item_num
	call copy_loop

    mov byte [edi], 0

	mov byte [current_state], 4
	mov esi, buffer
	mov ecx, 1024
	call clear_buffer

	mov byte [first], 1

    mov eax, SYS_OPEN
    mov ebx, inventory_file
    mov ecx, O_RDONLY
    int 0x80
    mov [fd], eax

    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

	mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

	mov edi, del_user_item
	mov esi, rep_take_item_code
	call copy_loop

	jmp continue_delete

stock_taking_to_inv_file:
	mov ebx, inventory_file
	mov ecx, O_WRONLY | O_TRUNC
	mov edi, empty_string
	call write_to_file

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, buffer
	call write_to_file

	mov ebx, inventory_file
	mov ecx, 0x401
	mov edi, item_to_store
	call write_to_file

	mov ecx, stock_tak_success
	call print

	call print_newline
	call print_newline

    mov byte [current_state], 4
    call load_inventory

    jmp parse_loop2

;End Program
exit_program:
	mov eax, SYS_EXIT
	xor ebx, ebx
	int 0x80

;Helper Functions
strip_newline:
	push esi
	.strip_loop:
		cmp byte [esi], 0
		je .done
		cmp byte [esi], 0xA
		je .set_null
		inc esi
		jmp .strip_loop
	.set_null:
		mov byte [esi], 0
	.done:
		pop esi
		ret

;Compare Two Strings
strcmp:
	xor eax, eax
	.compare_loop:
		lodsb
		scasb
		jne .not_equal
		test al, al
		jne .compare_loop
		ret
	.not_equal:
		mov eax, 1
		ret

string_to_integer:
    xor eax, eax
    xor ebx, ebx
	atoi_loop:
		mov bl, byte [ecx]
		cmp bl, 0	
		je atoi_done
		sub bl, '0'
		imul eax, eax, 10
		add eax, ebx
		inc ecx
		jmp atoi_loop
	atoi_done:
		ret

integer_to_string:
    mov ebx, 10
    xor ecx, ecx
	xor edx, edx
	itoa_loop:
		xor edx, edx
		div ebx
		add dl, '0'
		mov [edi + ecx], dl
		inc ecx
		test eax, eax
		jnz itoa_loop

		xor esi, esi
		dec ecx
	reverse_loop:
		cmp esi, ecx
		jge reverse_done
		; Swap characters
		mov al, [edi + esi]
		mov bl, [edi + ecx]
		mov [edi + esi], bl
		mov [edi + ecx], al
		inc esi
		dec ecx
		jmp reverse_loop
	reverse_done:
		ret

check_integer:
    xor eax, eax
    .check_loop:
        lodsb
        cmp al, 0
        je .done
        cmp al, '0'
        jb .invalid_input
        cmp al, '9'
        ja .invalid_input
        jmp .check_loop
    .invalid_input:
        mov eax, 1
    .done:
        ret

check_positive:
	cmp eax, 0
	jg .positive
	mov eax, 1
	ret
	
	.positive:
		xor eax, eax
		ret

;Output
print:
	mov edi, ecx
	call calculate_length
	mov edx, eax
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	int 0x80

	ret

;Input
read:
	mov eax, SYS_READ
	mov ebx, STDIN
	int 0x80

	ret

;Print Space in Table
print_space:
	mov ecx, space
	call print

	ret

;Print New Line
print_newline:
	mov ecx, newline
	call print

	ret

;Clear Screen before Back to Main Menu
exit_to_menu:
    mov ecx, clear_screen
	call print

	jmp display_main_menu

; Combine Strings
copy_loop:
    lodsb
    test al, al
    je .done_copy
    stosb
    jmp copy_loop
	.done_copy:
		ret

;Calculate Length of String
calculate_length:
    xor eax, eax
    .length_loop:
        cmp byte [edi], 0
        je .done
        inc edi
        inc eax
        jmp .length_loop
    .done:
        ret

;Write File in Specific Mode
write_to_file:
	mov eax, SYS_OPEN
	mov edx, 0644
	int 0x80

	mov dword [fd], eax

	mov ebp, edi
	mov edi, edi
	call calculate_length

	mov edx, eax
	mov eax, SYS_WRITE
	mov ebx, dword [fd]
	mov ecx, ebp
	int 0x80

	mov eax, SYS_CLOSE
	mov ebx, dword [fd]
	int 0x80

	ret

;Clear buffer in Variable
clear_buffer:
	clear_loop:
		mov byte [esi], 0
		inc esi
		loop clear_loop
		ret