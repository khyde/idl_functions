; $Id: DIVERSITY_SHANNON.pro Dec 12, 2002
;+
;	This Function returns supplied data that belong to the MARMAP cruise series
; SYNTAX:
;	DIVERSITY_SHANNON,
;	Result  = DIVERSITY_SHANNON(arr)
; OUTPUT:
;		A structure containing the diversity index and equitability index
; ARGUMENTS:
;		Arr: data array
; EXAMPLE:
;		I=DIVERSITY_SHANNON([1,10,20,5])
; CATEGORY:
;		MATH
; NOTES:
;		http://www.tiem.utk.edu/~gross/bioed/bealsmodules/shannonDI.html
;		The proportion of species i relative to the total number of species (pi) is calculated,
;		and then multiplied by the natural logarithm of this proportion (lnpi).
;		The resulting product is summed across species, and multiplied by -1:
;		Shannon's equitability (EH) can be calculated by dividing H by Hmax (here Hmax = lnS).
;		S is the total number of species
;		Equitability assumes a value between 0 and 1 with 1 being complete evenness

;		Begon, M., J. L. Harper, and C. R. Townsend. 1996. Ecology: Individuals, Populations, and Communities, 3rd edition. Blackwell Science Ltd., Cambridge, MA.
;		Magurran, A. E. 1988. Ecological Diversity and its Measurement. Princeton University Press, Princeton, NJ.
;		Rosenzweig, M. L. 1995. Species Diversity in Space and Time. Cambridge University Press, New York, NY
; HISTORY:
;		Dec 12, 2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION DIVERSITY_SHANNON,Arr
  ROUTINE_NAME='DIVERSITY_SHANNON'
  S=CREATE_STRUCT('DIVERSITY',0.0,'EQUITABILITY',0.0)
  IF N_ELEMENTS(ARR) LT 2 THEN RETURN,S

  ok = WHERE(Arr EQ 0,COUNT)
  IF COUNT GE 1 THEN RETURN,S
  num=N_ELEMENTS(Arr)
  sum=TOTAL(arr)
  p  = Arr/sum

  S.DIVERSITY = -1* TOTAL(p*ALOG(p))
  S.EQUITABILITY = S.DIVERSITY/ALOG(num)
  RETURN,S
END; #####################  End of Routine ################################
