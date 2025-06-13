; $Id: pca_demo.pro $  VERSION: March 26,2002
;+
;	This Function returns supplied data that belong to the MARMAP cruise series
; SYNTAX:
;	pca_demo,
;	Result  = pca_demo
; OUTPUT:
; ARGUMENTS:
; KEYWORDS:;
; EXAMPLE:
; CATEGORY:
; NOTES:
; HISTORY:
;		March 26,2002	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO pca_demo,FILE
  ROUTINE_NAME='pca_demo'
; Define an array with 4 variables and 20 samples:

; Define an array with 4 variables and 20 observations:

array = [[19.5, 43.1, 29.1, 11.9], $
         [24.7, 49.8, 28.2, 22.8], $
         [30.7, 51.9, 37.0, 18.7], $
         [29.8, 54.3, 31.1, 20.1], $
         [19.1, 42.2, 30.9, 12.9], $
         [25.6, 53.9, 23.7, 21.7], $
         [31.4, 58.5, 27.6, 27.1], $
         [27.9, 52.1, 30.6, 25.4], $
         [22.1, 49.9, 23.2, 21.3], $
         [25.5, 53.5, 24.8, 19.3], $
         [31.1, 56.6, 30.0, 25.4], $
         [30.4, 56.7, 28.3, 27.2], $
         [18.7, 46.5, 23.0, 11.7], $

         [19.7, 44.2, 28.6, 17.8], $
         [14.6, 42.7, 21.3, 12.8], $
         [29.5, 54.4, 30.1, 23.9], $
         [27.7, 55.3, 25.7, 22.6], $
         [30.2, 58.6, 24.6, 25.4], $
         [22.7, 48.2, 27.1, 14.8], $
         [25.2, 51.0, 27.5, 21.1]]



; Compute the derived variables based upon the principal
; components. The COEFFICENTS, EIGENVALUES, and VARIANCES keywords
; must be initialized as nonzero values prior to calling PCOMP:
coefficients = 1 & eigenvalues = 1 & variances = 1

result = PCOMP(array, COEFFICIENTS = coefficients, $
   EIGENVALUES = eigenvalues, VARIANCES = variances,/standardize,/double)

PRINT, 'Result: '
PRINT, result, FORMAT = '(4(f5.1, 2x))'
PRINT, 'Coefficients: '
PRINT, coefficients
PRINT, 'Eigenvalues: '
PRINT, eigenvalues
PRINT, 'Variances: '
PRINT, variances

 STOP
END; #####################  End of Routine ################################
