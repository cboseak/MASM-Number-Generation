TITLE Program 5 - Random Number Array

; Author				: Christopher Boseak
; Course / Project ID	: CS271 - Program 5						Date: 11/21/2015
; Description			: This is a program that generates random numbers, adds them to an array, sorts the array and calculates the median	

INCLUDE Irvine32.inc

LOWERLIMITINPUT = 10
UPPERLIMITINPUT = 200

LOWERLIMITRANDOMS = 100
UPPERLIMITRANDOMS = 999

.data

studentName		BYTE	"Christopher Boseak - Assignment #5 - Random Integer Program",0
howManyPrompt	BYTE	"Please enter how many numbers you would like generated (between 10 & 200): ",0
tooHighNum		BYTE	"***The number you entered was too high***",0
tooLowNum		BYTE	"***The number you entered was too low***",0
debugText		BYTE	"testing",0
unsortedHeader	BYTE	"UNSORTED ARRAY",0
sortedHeader	BYTE	"SORTED ARRAY",0
lineForUI		BYTE	"-----------------------------------",0
medianPrint		BYTE	"Median: ",0

numOfInts		DWORD	?
lineCounter		DWORD	?
tempVal1		DWORD	?
numOfSortLoops	DWORD	?

numArray		DWORD	200 DUP(?)

.code
main PROC

	call	Randomize						;Seeding the random number generator
	call	intro							;Calls the proc with intro
	call	promptUser						;Calls the proc with prompt for user input

	push	OFFSET numArray					;Passing Array by reference
	push	numOfInts						;Passing user input by value      -ditto for all cases of this below
	call	GenerateRandomArray				;Calls the proc to generate the array

	call	UnsortedHeaderProc				;Calls the header above the printed array

	push	OFFSET numArray
	push	numOfInts	
	call	DisplayArray					;Calls proc to iterate through and print out array
	Call	CrLF
	Call	CrLF

	mov		ebx,50					
	mov		eax,numOfInts
	mul		ebx
	mov		numOfSortLoops,eax
	mov		ecx, numOfSortLoops				;To ensure all is sorted propertly the sort proc
SortLooper:									;will loop through 50 x how many elements
	mov		tempVal1,ecx					;storing the value of ecx to be later restored
	push	OFFSET numArray
	push	numOfInts	
	call	Sorter							;Calls proc that sorts the array
	mov		ecx,tempVal1					;Restore ecx
	loop	SortLooper				

	push	OFFSET numArray
	push	numOfInts
	call	FindMedian						;Calls proc to find median

	call	SortedHeaderProc				;Calls the header above the printed array
		
	push	OFFSET numArray
	push	numOfInts
	call	DisplayArray					;Calls proc to iterate through and print out array

	call	ReadInt							;Added so that the console window would not close when finished running
	exit	; exit to operating system
main ENDP

; INTRODUCTION PROCEDURE - Lists my name and more information about the assignmnet
intro PROC
	mov		edx, OFFSET studentName
	call	WriteString
	call	CrLF
	call	CrLF
	ret
intro ENDP



; PROMPT USER PRODCEDURE -	Prompts the user for how many random numbers they would like to generate
;							This procedure will also validate the input
promptUser PROC
PromptUserForNum:
	mov		edx, OFFSET howManyPrompt
	call	WriteString
	call	ReadInt
	mov		numOfInts, eax

CheckUpperLimit:							;Checks if input is less than upperlimit
	cmp		eax, UPPERLIMITINPUT
	jle		CheckLowerLimit
	call	CrLF
	mov		edx, OFFSET tooHighNum
	call	WriteString
	call	CrLF
	call	CrLF
	cmp		eax, UPPERLIMITINPUT
	jg		PromptUserForNum

CheckLowerLimit:						;Checks if input is more than more than lowerlimit
	cmp		eax, LOWERLIMITINPUT
	jge		ReturnFromProc
	call	CrLF
	mov		edx, OFFSET tooLowNum
	call	WriteString
	call	CrLF
	call	CrLF
	cmp		eax, LOWERLIMITINPUT
	jl		PromptUserForNum

ReturnFromProc:							;Added label so I had flexibility to jump back to main whenever
	ret

promptUser ENDP



; RANDOM NUMBER GENERATION PROCEDURE -	This procedure will generate an array of random numbers between the
;										upper and lower limit. How many numbers is based on the user input.
GenerateRandomArray PROC
	push	ebp
	mov		ebp,esp
	mov		edi,[ebp+12]				;mov start of array to edi
	mov		ecx, [ebp+8]				;mov user input param to ecx

RandLoop:
	mov		eax, OFFSET UPPERLIMITRANDOMS
	call	RandomRange						;Generate random number
	cmp		eax, OFFSET LOWERLIMITRANDOMS
	jl		RandLoop						;double check if number is higher than lower limit
	mov		[edi],eax						;mov generated number to current position in array
	add		edi,4						;advance pointer to next position in array

	loop	RandLoop					;loop while more numbers are required(based on ecx)

	pop		ebp							;pop ebp off stack
	ret		8							;return to original calling area
GenerateRandomArray	ENDP



; DISPLAY ARRAY PROCEDURE -	This prodecure will loop through the array and display all values
;							in lines, 10 values each line.
DisplayArray PROC
	push	ebp
	mov		ebp,esp
	mov		edi,[ebp+12]
	mov		ecx, [ebp+8]
	mov		lineCounter,0				;A counter that constantly increments so the program
DispLoop:								;knows when to create a new line	

	mov		eax,[edi]					;mov current element to eax
	call	WriteDec					;display current element
	mov		eax,TAB						;tab on screen
	call	WriteChar				
	add		edi,4						;advance pointer to next element in array
	inc		lineCounter					;increment lineCounter

	mov		eax,lineCounter
	cmp		eax,10						;if there are 10 elements in current line, create new line
	je		NewLine
ReturnFrom:								;added label so I could jump back from new line creation
	loop	DispLoop	
		
	pop		ebp							;pop ebp off stack
	ret		8							;return to original calling area

NewLine:
	call	CrLf						;Create new line
	mov		lineCounter,0				;reset counter
	jmp		ReturnFrom

DisplayArray ENDP


; NUMBER SORTING PROCEDURE -	This procedure runs through the array and performs a bubble sort
Sorter PROC
SorterMain:
	push	ebp
	mov		ebp,esp
	mov		edi,[ebp+12]
	mov		ecx, [ebp+8] 
	dec		ecx							;since edi-4 won't exist the first time around we'll dec ecx
	add		edi,4						;and move to the next element. starting on element 2 

SortLoop:
	mov		eax,[edi-4]
	cmp		eax,[edi]					;compare last element to current element
	jle		ReturnFromElse				
	jg		Switcher					;if element sub1 is greater than element, jmp to switch label;

ReturnFromElse:
	add		edi,4
	loop	SortLoop				
	jmp		Exiter

Switcher:								;Switch elements if out of order (bubble sort)
	mov		ebx,[edi-4]
	mov		eax,[edi]
	mov		[edi],ebx
	mov		[edi-4],eax
	jmp		SortLoop

Exiter:
	pop		ebp
	ret		8
Sorter ENDP

; HEADER FOR UNSORTED ARRAY DISPLAY -	This function just prints a header so the user knows that the array is unsored
SortedHeaderProc PROC
	mov		edx, OFFSET lineForUI
	call	WriteString
	Call	CrLF
	mov		eax,TAB
	call	WriteChar
	mov		edx, OFFSET sortedHeader
	call	WriteString
	call	CrLF
	mov		edx, OFFSET lineForUI
	call	WriteString
	Call	CrLF
	ret
SortedHeaderProc ENDP

; HEADER FOR UNSORTED ARRAY DISPLAY -	This function just prints a header so the user knows that the array is unsored
UnsortedHeaderProc PROC
	mov		edx, OFFSET lineForUI
	call	WriteString
	Call	CrLF
	mov		eax,TAB
	call	WriteChar
	mov		edx, OFFSET unsortedHeader
	call	WriteString
	call	CrLF
	mov		edx, OFFSET lineForUI
	call	WriteString
	Call	CrLF
	ret
UnsortedHeaderProc ENDP

FindMedian PROC
	push	ebp
	mov		ebp,esp
	mov		edi,[ebp+12]

	mov		eax,[ebp+8]
	mov		ebx,2
	div		ebx		

	cmp		edx,1
	je		OddCase
	jne		EvenCase	

OddCase:									;If there are odd number of elements, the 
	call	CrLF							;middle element can be selected so this
	mov		ebx,4							;this the pointer to the middle element and
	mul		ebx								;prints it to the screen
	mov		ebx,[edi+eax]
	mov		edx, OFFSET medianPrint
	call	WriteString
	mov		eax,ebx
	call	WriteDec
	call	CrLF
	call	CrLF
	jmp		Exiter

EvenCase:									;If there are an even number of elements, the
	mov		ebx,4							;program needs to take the 2 middle numbers and find
	mul		ebx								;average of the two, this is the median
	mov		ebx,[edi+eax]
	sub		eax,4
	add		ebx,[edi+eax]
	mov		eax,ebx
	mov		ebx,2
	div		ebx
	mov		edx, OFFSET medianPrint
	call	WriteString
	call	WriteDec
	call	CrLF
	call	CrLF
	jmp		Exiter

Exiter:										;added label for return to main since it
	pop		ebp								;could be called be either of the labels
	ret		8

FindMedian ENDP

END main