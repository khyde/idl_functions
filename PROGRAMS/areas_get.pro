; $ID:	AREAS_GET.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION AREAS_GET,IM
;
;
;
; PURPOSE: THIS FUNCTION USES LABEL_REGION TO FIND AREAS [BLOBS] IN LANDMASKS
; 
; 
; 
; CATEGORY:	AREAS		 
;
; CALLING SEQUENCE: RESULT = AREAS_GET(VALS)
;
; INPUTS: IM 2-DIMENSIONAL IMAGE ARRAY 

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS: 
;		
;; EXAMPLES:
;  ST, AREAS_GET()
;	NOTES: IDL HELP
;; Each region
;FOR i=0, N_ELEMENTS(h)-1 DO BEGIN
;  ;Find subscripts of members of region i.
;  p = r[r[i]:r[i+1]-1]
;  
;  ; Pixels of region i
;  q = image[P]
;  Print, 'Region ', i, $
;    ', Population = ', h[i], $
;    ', Standard Deviation = ', STDEV(q, mean), $
;    ', Mean = ', mean
;ENDFOR
;END

;
; MODIFICATION HISTORY:
;			WRITTEN JAN 22,2014, J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'AREAS_GET'
;****************************
;
; FOR TESTING > 
 IF N_ELEMENTS(IM) EQ 0 THEN  IM =READ_LANDMASK(MAP='SMI',/LAND)
  
; GET BLOB INDICES:
B = LABEL_REGION(IM)

; GET POPULATION AND MEMBERS OF EACH BLOB:
H = HISTOGRAM(B, REVERSE_INDICES=R)
D = CREATE_STRUCT('AREA',0L,'N',0L,'STD',0.0,'XP',0L,'YP',0L)
NUM = -1L & REGION = -1 & _MAX = -1
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR I=0, N_ELEMENTS(H)-1 DO BEGIN
  ;FIND SUBSCRIPTS OF MEMBERS OF REGION I.
  P = R[R[I]:R[I+1]-1]

  ; PIXELS OF REGION I
  Q = IM[P]
  XY = ARRAY_INDICES(IM, P )
  X = REFORM(XY(0,*))
  Y = REFORM(XY(1,*))
  XP = MEDIAN(X) &  YP = MEDIAN(Y)
 D.AREA = I & D.N = N_ELEMENTS(Q)
 IF D.N GT 1 THEN D.STD = STDEV(Q, MEAN)
 D.XP =XP& D.YP = YP
 IF N_ELEMENTS(DB) EQ 0 THEN DB = D ELSE DB = [DB,D]
  _MAX = _MAX > N_ELEMENTS(Q)
  REGION = [REGION,N_ELEMENTS(Q)]
   NUM = [NUM,I]
  IF N_ELEMENTS(Q) LT 4 THEN CONTINUE

;    PRINT, 'REGION ', I, $
;      ', N = ', H[I], $
;      ', STANDARD DEVIATION = ', STDEV(Q, MEAN), $
;      ', MEAN = ', MEAN
  ENDFOR;FOR I=0, N_ELEMENTS(H)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
;===> SORT ON N
S = (SORT(DB.AREA)) & DB = DB(S)
;
RETURN,DB
DONE:          
	END; #####################  END OF ROUTINE ################################
