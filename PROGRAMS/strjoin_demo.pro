pro STRJOIN_DEMO

;Result = STRJOIN( String [, Delimiter] [, /SINGLE] )


STR = ['HELLO','GOODBYE','AGAIN']
TXT=STRJOIN(STR,'$')
HELP, TXT & LIST,TXT


TXT=STRJOIN(STR,'$',/SINGLE)
HELP, TXT & LIST,TXT




STR = [['HELLO','GOODBYE','AGAIN'],['HELL','GOODBY','AGAI']]
PRINT, STR
TXT=STRJOIN(STR,'$')
HELP, TXT & LIST,TXT


TXT=STRJOIN(STR,'$',/SINGLE)
HELP, TXT & LIST,TXT

STRUCT=READALL('D:\IDL\DATA\TILEORDR.SAVE')

;TXT = STRJOIN( [TRANSPOSE(DB.STA), TRANSPOSE(DB.TILE)],'$')

KEY=''
POS_TAG=[0,1,2,3]
N_KEYS=N_ELEMENTS(POS_TAG)
;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR nth = 0L,N_KEYS-1L DO BEGIN
		STR 	= STRTRIM(STRUCT.(POS_TAG(nth)),2)
;		===> Determine maximum length of strings so they may padded with leading zeros
;				 This ensures that the final returned structure will be properly sorted by values
		LEN 	= STRTRIM(MAX(STRLEN(STR)), 2)
		FMT   = '(A'+LEN+')'
		STR   = STR_SPACE2ZERO(STRING(STR,FORMAT=FMT))
		KEY = KEY + STR + '$'
	ENDFOR
;	|||||||||||||||||||||||||||||||||||||
STOP

END