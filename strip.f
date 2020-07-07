\ -*- text -*-

\ strip FORTH source code of most comments and some whitespace

1024 CELLS MORECORE

256 CELLS CONSTANT OUTPUT-BUFFER-SIZE
OUTPUT-BUFFER-SIZE ALLOT CONSTANT OUTPUT-BUFFER
OUTPUT-BUFFER VALUE OUTPUT-BUFFER-POSITION

: FLUSH-BUFFER
	OUTPUT-BUFFER OUTPUT-BUFFER-POSITION <> IF
		OUTPUT-BUFFER OUTPUT-BUFFER-POSITION OUTPUT-BUFFER - TYPE
		OUTPUT-BUFFER TO OUTPUT-BUFFER-POSITION
	THEN
;

: BUFFERED-EMIT
	OUTPUT-BUFFER-POSITION OUTPUT-BUFFER OUTPUT-BUFFER-SIZE + < UNLESS
		FLUSH-BUFFER
	THEN
	OUTPUT-BUFFER-POSITION C!
	1 +TO OUTPUT-BUFFER-POSITION
;
HIDE OUTPUT-BUFFER
HIDE OUTPUT-BUFFER-POSITION
HIDE OUTPUT-BUFFER-SIZE

TRUE VALUE BEGINNING-OF-LINE
FALSE VALUE SKIP-CHARS
0 VALUE PAREN

: '\\' 92 ;
: '\t' 9 ;

: PROCESS-CHAR ( c-addr1 u1 -- c-addr2 u2 )
OVER C@
SKIP-CHARS IF
	'\n' = IF TRUE TO BEGINNING-OF-LINE FALSE TO SKIP-CHARS THEN
ELSE
	PAREN 0> IF
		CASE
		'(' OF 1 +TO PAREN ENDOF
		')' OF -1 +TO PAREN ENDOF
		ENDCASE
	ELSE
		BEGINNING-OF-LINE IF
			CASE
			'\\' OF
				TRUE TO SKIP-CHARS
				FALSE TO BEGINNING-OF-LINE
			ENDOF
			'\n' OF
				TRUE TO BEGINNING-OF-LINE
			ENDOF
			'\t' OF	( skip first tab character )
				FALSE TO BEGINNING-OF-LINE
			ENDOF
                        '(' OF	( beginning of block comment )
				1 +TO PAREN
				FALSE TO BEGINNING-OF-LINE
			ENDOF
				DUP BUFFERED-EMIT
				FALSE TO BEGINNING-OF-LINE
			ENDCASE
		ELSE
			CASE
			'\n' OF
				TRUE TO BEGINNING-OF-LINE
				'\n' BUFFERED-EMIT
			ENDOF
				DUP BUFFERED-EMIT
			ENDCASE
		THEN
	THEN
THEN

1 /STRING
;
HIDE PAREN
HIDE BEGINNING-OF-LINE
HIDE SKIP-CHARS

0 VALUE FD
512 CELLS CONSTANT BUFFER-SIZE
BUFFER-SIZE ALLOT CONSTANT BUFFER

: STRIP
R/O OPEN-FILE
?DUP IF S" strip.f" PERROR QUIT THEN

TO FD

BEGIN
	BUFFER BUFFER-SIZE FD READ-FILE
	?DUP IF S" READ-FILE" PERROR QUIT THEN
	BUFFER OVER
	BEGIN
		DUP 0>
	WHILE
		PROCESS-CHAR
	REPEAT
	2DROP
0= UNTIL

FLUSH-BUFFER

FD CLOSE-FILE
?DUP IF S" CLOSE-FILE" PERROR QUIT THEN
;
HIDE PROCESS-CHAR
HIDE FD
HIDE BUFFER-SIZE
HIDE BUFFER

S" jonesforth.f" STRIP
