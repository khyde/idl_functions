; $ID:	STRUCT_JOIN_DEMO.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO STRUCT_JOIN_DEMO
;+
; NAME:
;       STRUCT_JOIN
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Dec 16, 2004
;-

ROUTINE_NAME='STRUCT_JOIN_DEMO'

PRINT,'MOST MATCHUP USING TWO JOINING KEYS A & B'
S1=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_1'),6)
S1[1].A = '1' 	& S1(2).A = '1' 	& S1(3).A = '2' 	& S1(4).A = '2' 	& S1(5).A = '3'
S1[1].B = '20' 	& S1(2).B = '30' 	& S1(3).B = '40' 	& S1(4).B = '50' 	& S1(5).B = '60'
S1[1].C = '2_1' & S1(2).C = '3_1' & S1(3).C = '4_1' & S1(4).C = '5_1' & S1(5).C = '6_1'

S2=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_2'),6)
S2[1].A = '1' 	& S2(2).A = '1' 	& S2(3).A = '2' 	& S2(4).A = '2' 	& S2(5).A = '3'
S2[1].B = '21' 	& S2(2).B = '30' 	& S2(3).B = '40' 	& S2(4).B = '50' 	& S2(5).B = '60'
S2[1].C = '2_2' & S2(2).C = '3_2' & S2(3).C = '4_2' & S2(4).C = '5_2' & S2(5).C = '6_2'

S = STRUCT_JOIN(S1,S2, TAGNAMES=['A','B'])
SPREAD,S






STOP

PRINT,'DIRECT 1:1 MATCH, 2 STRUCTURES'
S1=REPLICATE(CREATE_STRUCT('A','1','B','1'),1)
S2=REPLICATE(CREATE_STRUCT('A','1','B','2'),1)
S = STRUCT_JOIN(S1,S2, TAGNAMES='A')
SPREAD,S


PRINT,'DIRECT 1:1 MATCH, 3 STRUCTURES'
S1=REPLICATE(CREATE_STRUCT('A','1','B','1'),1)
S2=REPLICATE(CREATE_STRUCT('A','1','B','2'),1)
S3=REPLICATE(CREATE_STRUCT('A','1','B','3'),1)
S = STRUCT_JOIN(S1,S2,S3,TAGNAMES='A')
SPREAD,S

PRINT,'SOME IN COMMON'
S1=REPLICATE(CREATE_STRUCT('A','0'),2)  & S1[1].A='1'
S2=REPLICATE(CREATE_STRUCT('A','1','B','1','C','1'),3)
S2[1].A = '2' & S2(2).A = '3' & S2[1].B = '2' & S2(2).B = '3'& S2[1].C = '2' & S2(2).C = '3'
S = STRUCT_JOIN(S1,S2,TAGNAMES='A')
SPREAD,S

PRINT,'NONE IN COMMON'
S1=REPLICATE(CREATE_STRUCT('A','0'),2)  & S1[1].A='1'
S2=REPLICATE(CREATE_STRUCT('A','2','B','1','C','1'),3)
S2[1].A = '3' & S2(2).A = '4' & S2[1].B = '2' & S2(2).B = '3'& S2[1].C = '2' & S2(2).C = '3'
S = STRUCT_JOIN(S1,S2,TAGNAMES='A')
SPREAD,S





PRINT,'ONE PRIME, 3 RELATIONS'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),1)
S2=REPLICATE(CREATE_STRUCT('A','1','B','1'),3) & S2[1].B='2' & S2(2).B='3'
S = STRUCT_JOIN(S1,S2, TAGNAMES='A')
SPREAD,S

PRINT,'TWO PRIMES, 2 RELATIONS EACH'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),2) & S1[1].A = '2' & S1[1].B = 'SECOND'
S2=REPLICATE(CREATE_STRUCT('A','1','B','1'),4) & S2[1].A = '1' & S2[1].B='2' & S2(2).A = '2' & S2(2).B='3' & S2(3).A='2' & & S2(3).B='4'
S = STRUCT_JOIN(S1,S2, TAGNAMES='A')
SPREAD,S

PRINT,'THREE PRIMES, THIRD HAS NO RELATIONS'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),3) & S1[1].A = '2' & S1[1].B = 'SECOND' & S1(2).A = '3' & S1(2).B = 'THIRD'
S2=REPLICATE(CREATE_STRUCT('A','1','B','1'),4) & S2[1].A = '1' & S2[1].B='2' & S2(2).A = '2' & S2(2).B='3' & S2(3).A='2' & & S2(3).B='4'
S = STRUCT_JOIN(S1,S2, TAGNAMES='A')
SPREAD,S


PRINT,'ALL MATCHUP USING TWO JOINING KEYS A & B'
S1=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_1'),6)
S1[1].A = '1' 	& S1(2).A = '1' 	& S1(3).A = '2' 	& S1(4).A = '2' 	& S1(5).A = '3'
S1[1].B = '20' 	& S1(2).B = '30' 	& S1(3).B = '40' 	& S1(4).B = '50' 	& S1(5).B = '60'
S1[1].C = '2_1' & S1(2).C = '3_1' & S1(3).C = '4_1' & S1(4).C = '5_1' & S1(5).C = '6_1'

S2=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_2'),6)
S2[1].A = '1' 	& S2(2).A = '1' 	& S2(3).A = '2' 	& S2(4).A = '2' 	& S2(5).A = '3'
S2[1].B = '20' 	& S2(2).B = '30' 	& S2(3).B = '40' 	& S2(4).B = '50' 	& S2(5).B = '60'
S2[1].C = '2_2' & S2(2).C = '3_2' & S2(3).C = '4_2' & S2(4).C = '5_2' & S2(5).C = '6_2'

S = STRUCT_JOIN(S1,S2, TAGNAMES=['A','B'])
SPREAD,S

PRINT,'MOST MATCHUP USING TWO JOINING KEYS A & B'
S1=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_1'),6)
S1[1].A = '1' 	& S1(2).A = '1' 	& S1(3).A = '2' 	& S1(4).A = '2' 	& S1(5).A = '3'
S1[1].B = '20' 	& S1(2).B = '30' 	& S1(3).B = '40' 	& S1(4).B = '50' 	& S1(5).B = '60'
S1[1].C = '2_1' & S1(2).C = '3_1' & S1(3).C = '4_1' & S1(4).C = '5_1' & S1(5).C = '6_1'

S2=REPLICATE(CREATE_STRUCT('A','1','B','10','C','1_2'),6)
S2[1].A = '1' 	& S2(2).A = '1' 	& S2(3).A = '2' 	& S2(4).A = '2' 	& S2(5).A = '3'
S2[1].B = '21' 	& S2(2).B = '30' 	& S2(3).B = '40' 	& S2(4).B = '50' 	& S2(5).B = '60'
S2[1].C = '2_2' & S2(2).C = '3_2' & S2(3).C = '4_2' & S2(4).C = '5_2' & S2(5).C = '6_2'

S = STRUCT_JOIN(S1,S2, TAGNAMES=['A','B'])
SPREAD,S



PRINT,'MUST PROVIDE TAGNAMES'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),1)
S2=REPLICATE(CREATE_STRUCT('A','1','C','1'),2) & S2[0].C ='2'
S = STRUCT_JOIN(S1,S2)
SPREAD,S

PRINT, 'ERROR: KEY TAGNAME  NOT PRESENT IN BOTH STRUCTURES'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),1)
S2=REPLICATE(CREATE_STRUCT('B','1','C','1'),2) & S2[0].C ='2'
S = STRUCT_JOIN(S1,S2,TAGNAMES='A')
SPREAD,S

PRINT,'ERROR DUPLICATES IN 1'
S1=REPLICATE(CREATE_STRUCT('A','1','B','FIRST'),2)
S2=REPLICATE(CREATE_STRUCT('A','1','B','1'),3) & S2[1].B='2' & S2(2).B='3'
S = STRUCT_JOIN(S1,S2, TAGNAMES='A')
SPREAD,S







END; #####################  End of Routine ################################



