; $ID:	TOPO_LEVELS.PRO,	2019-11-22-13,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION TOPO_LEVELS,LEVELS

; PURPOSE: RETURNS STANDARD TOPO LEVELS
; 
; CATEGORY:	TOPO_ FAMILY;		 
;
; CALLING SEQUENCE: RESULT = TOPO_LEVELS(FILES)
;
; INPUTS: LEVELS [OPTIONAL] 

; OUTPUTS: STANDARD LEVELS
;		
;; EXAMPLES:  PLIST,TOPO_LEVELS()
;             PLIST,TOPO_LEVELS([0,10,20,30,40])



;
; MODIFICATION HISTORY:
;			WRITTEN DEC 31, 2015 J.O'REILLY
;			Nov 22, 2019 - KJWH: Added SORT(LEVELS) and changed UNIQUE to UNIQ 
;			
;#################################################################################
;-
;*****************************
  ROUTINE_NAME  = 'TOPO_LEVELS'
;*****************************
  IF NONE(LEVELS) THEN LEVELS = -[0,INTERVAL([5,100],5),INTERVAL([100,2000],100),INTERVAL([2000,10000],1000)]
  LEVELS = REVERSE(LEVELS[SORT(LEVELS)])
  LEVELS = LEVELS[UNIQ(LEVELS)] 
  
  RETURN, LEVELS
          
END; #####################  END OF ROUTINE ################################
