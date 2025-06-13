; $ID:	MEDIAN_FILTER_TUKEY.PRO,	2020-07-08-15,	USER-KJWH	$
; ***********************************************************************

  FUNCTION AMED2,XX,YY
    RETURN, (XX + YY)*.5
  END
  FUNCTION AMED3,XX,YY,ZZ
 ;  RETURN, (XX + YY + ZZ - AMAX1(XX,YY,ZZ) - AMIN1(XX,YY,ZZ))
    RETURN, (XX + YY + ZZ - MAX([XX,YY,ZZ]) - MIN([XX,YY,ZZ]))
  END
;
  FUNCTION AMED4,XX,YY,ZZ,WW
;   RETURN, (XX + YY + ZZ + WW - AMAX1(XX,YY,ZZ,WW) - AMIN1(XX,YY,ZZ,WW))*.5 ;
    RETURN, (XX + YY + ZZ + WW - MAX([XX,YY,ZZ,WW]) - MIN([XX,YY,ZZ,WW]))*.5 ;
  END



; ***************************************************************************
  FUNCTION median_filter_tukey,IMAGE

; NAME:
;       median_filter_tukey
;
; PURPOSE:
;       Median a 2d-image using a special filter by Tukey
;
; CATEGORY:
;       Images
;
; CALLING SEQUENCE:
;       Result = median_filter_tukey(image)
;
; INPUTS:
;       A 2-dimensional Image
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       FORTRAN Code provided by R.W. Reynolds, Sep 24,1999
;       Translated from FORTRAN code to IDL by:  J.E.O'Reilly, Jan, 1995.
;
; NOTES
;
; Median Filter Algorithm
; Citation: R.W. Reynolds, 1988, A Real-time Global Sea Surface
; Temperature Analysis' Journal of Climate
;
; FORTRAN CODE SENT TO J.O'Reilly September 24,1999 from:
; Richard W. Reynolds
; Scientific Services Division
; PHONE:   (301) 763-8000 Ext 7580
; NCDC/NESDIS/NOAA
; FAX:     (301) 763-8125
; 5200 Auth Road, Room 807
; Camp Springs, MD 20746, USA
; e-mail: rreynolds@ncep.noaa.gov
; or : richard.w.reynolds@noaa.gov
;
; Hi John,
; I attach the fortran file below. Note that this program expects at 2-dim array. Because there is not filtering of the end points, extra points are
; added at the poles for the north/south filtering and the data are assumed to be periodic in the east/west direction. Also note the filter can not
; handle missing values. In the PPS I include and example of how I fiddled with the original array to take care of the end point problem.
; Cheers, Dick
;
;-
  ; RETURN,

; M = LAT = Y
  MED_IMAGE = IMAGE
  S=SIZE(IMAGE)
  N=S[1]
  M=S(2)
  PRINT, M,N
  TUKEY, MED_IMAGE,N,M
  RETURN, MED_IMAGE(1:*,1:*)
  END ; END OF PROGRAM MEDIAN_FILTER_TUKEY


; ***********************************************************************
  PRO TUKEY  ,A,N,M
; $$  SUBPROGRAM DOCUMENTATION BLOCK
;                .      .    .                                       .
;     SUBPROGRAM:    TUKEY       PERFORMS MEDIUM FILTERING OF ARRAY A
;     PRGMMR: R. W. REYNOLDS    ORG: W/NMCX4     DATE: 91-07-22
;
;     ABSTRACT: PROVIDES MULTIPLE PASS MEDIAN FILTERING OF ARRAY A.
;     SEE APPENDIX B OF REYNOLDS (1988, J. OF CLIMATE) FOR DETAILS.
;     ARRAY A IS BOTH INPUT AND OUTPUT.
;     FILTER IS APPLIED FIRST TO ROWS (EAST/WEST) THEN COLUMNS.
;
;     PROGRAM HISTORY LOG:
;     91-07-22  RICHARD W. REYNOLDS
;
;     USAGE:    CALL TUKEY (A,N,M)
;
;     INPUT ARGUMENT LIST:
;     A      -   4-DEG RESOLUTION INPUT ARRAY TO BE FILTERED
;     N      -   FIRST DIMENSION OF A
;     M      -   SECOND DIMENSION OF A
;
;     OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
;     A      -   4-DEG RESOLUTION OUTPUT ARRAY AFTER FILTERING
;
;     SUBPROGRAMS CALLED:
;     UNIQUE:    - TUKEYF
;                                                                       C ATTRIBUTES:
;     LANGUAGE: FORTRAN 77 (NFORVCLG); COMPILER OPTIONS (GOSTMT,NOSDD)
;     MACHINE:  NAS
;
; $$
;  A= DBLARR(N+1L,M+1L)& ;;  A= DBLARR(N,M) (ADD 1 TO SIMULATE FORTRAN ARRAYS
;  DY= FLTARR(201)&SDY= FLTARR(201)&Y= FLTARR(201)& Y1= FLTARR(201)&Y2= FLTARR(201)&Y3= FLTARR(201)&SY= FLTARR(201)&
;

  NP = N+1
  MP = M+1
  NM4 = N-4
  MM4 = M-4

  Aa= DBLARR(N+1,M+1)&
  Aa(1,1) = A
  A = AA

;  DY= FLTARR(201)&SDY= FLTARR(201)&Y= FLTARR(201)& Y1= FLTARR(201)&Y2= FLTARR(201)&Y3= FLTARR(201)&SY= FLTARR(201)& Y7= FLTARR(201)&Y2= FLTARR(201)&Y3= FLTARR(201)&SYZ= FLTARR(201)&


  DY= FLTARR(M+1)&SDY= FLTARR(M+1)&Y= FLTARR(M+1)& Y1= FLTARR(M+1)&Y2= FLTARR(M+1)&Y3= FLTARR(M+1)&SY= FLTARR(M+1)& Y7= FLTARR(M+1)&Y2= FLTARR(M+1)&Y3= FLTARR(M+1)&SYZ= FLTARR(M+1)&


  FOR LAT=1,M DO BEGIN ;DO#_150
    FOR I=1,N DO BEGIN ;DO#_100
      Y(I) = A(I,LAT)
    ENDFOR ;#_100

    TUKEYF , Y,Y1,Y2,Y3,SY,N

    FOR I=1,N DO BEGIN ;DO#_120
      DY(I) = Y(I) - SY(I)
    ENDFOR ;#_120

    FOR I=1,4 DO BEGIN ;DO#_130
      DY(I) = 0.
      DY(NP-I) = 0.
    ENDFOR ;#_130

    TUKEYF , DY,Y1,Y2,Y3,SDY,N
    FOR I=5,NM4 DO BEGIN ;DO#_140
      A(I,LAT) = SY(I) +  SDY(I)
    ENDFOR ;#_140

  ENDFOR ;#_150


DY= FLTARR(N+1)&SDY= FLTARR(N+1)&Y= FLTARR(N+1)& Y1= FLTARR(N+1)&Y2= FLTARR(N+1)&Y3= FLTARR(N+1)&SY= FLTARR(N+1)& Y7= FLTARR(N+1)&Y2= FLTARR(N+1)&Y3= FLTARR(N+1)&SYZ= FLTARR(N+1)&
  FOR LONG=5,NM4 DO BEGIN ;DO#_155
    FOR I=1,M DO BEGIN ;DO#_105
      Y(I) = A(LONG,I)
    ENDFOR ;#_105
    TUKEYF , Y,Y1,Y2,Y3,SY,M
    FOR I=1,M DO BEGIN ;DO#_125
      DY(I) = Y(I) - SY(I)
    ENDFOR ;#_125
    FOR I=1,4 DO BEGIN ;DO#_135
      DY(I) = 0.
      DY(MP-I) = 0.
    ENDFOR ;#_135
    TUKEYF , DY,Y1,Y2,Y3,SDY,M
    FOR I=5,MM4 DO BEGIN ;DO#_145
      A(LONG,I) = SY(I) +  SDY(I)
    ENDFOR ;#_145
  ENDFOR ;#_155
;       RETURN
  END ; END OF TUKEY

; ***********************************************************************
  PRO TUKEYF ,Y,Y1,Y2,Y3,SY,N
; $$  SUBPROGRAM DOCUMENTATION BLOCK
;                .      .    .                                       .
;     SUBPROGRAM:    TUKEYF      PERFORMS MEDIUM FILTER REQUIRED BY TUKEY
;     PRGMMR: R. W. REYNOLDS    ORG: W/NMCX4     DATE: 91-07-22
;
;     ABSTRACT: COMPUTES MULTIPLE PASS MEDIAN FILTERING OF ARRAY Y.
;     CALLED BY SUBROUTINE TUKEY.
;     SEE APPENDIX B OF REYNOLDS (1988, J. OF CLIMATE) FOR DETAILS.
;
;     PROGRAM HISTORY LOG:
;     91-07-22  RICHARD W. REYNOLDS
;
;     USAGE:    CALL TUKEYF(Y,Y1,Y2,Y3,SY,N)
;
;     INPUT ARGUMENT LIST:
;     Y      -   ARRAY TO BE FILTERED
;     N      -   SIZE OF Y AND OUTPUT ARRAYS
;
;     OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
;     Y1      -   ARRAY OF FIRST PASS OF FILTER
;     Y2      -   ARRAY OF SECOND OF FILTER
;     Y1      -   ARRAY OF THIRD OF FILTER
;     Y1      -   ARRAY OF FOURTH PASS OF FILTER
;                                                                       C ATTRIBUTES:
;     LANGUAGE: FORTRAN 77 (NFORVCLG); COMPILER OPTIONS (GOSTMT,NOSDD)
;     MACHINE:  NAS
;
; $$
; Y= DBLARR(N)&Y1= DBLARR(N)&Y2= DBLARR(N)&Y3= DBLARR(N)&SY= DBLARR(N)&
;  Y= DBLARR(N+1)&
  Y1= DBLARR(N+1)&Y2= DBLARR(N+1)&Y3= DBLARR(N+1)&SY= DBLARR(N+1)&
;
;     FUNCTIONS
;

;
;

  FOR I=1,4 DO BEGIN ;DO#_5
    Y1(I)=0.0
    Y2(I)=0.0
    Y3(I)=0.0
    SY(I)=0.0
    IN=N-I+1
    Y1(IN)=0.0
    Y2(IN)=0.0
    Y3(IN)=0.0
    SY(IN)=0.0 & ENDFOR ;#_5;

  N3=N-3
  FOR I=1,N3 DO BEGIN ;DO#_10
    Y1(I+3/2)=AMED4(Y(I),Y(I+1),Y(I+2),Y(I+3)) & ENDFOR ;#_10
;
  N4=N-4
  FOR I=2,N4 DO BEGIN ;DO#_20
    Y2(I+3/2)=AMED3(Y1(I+1/2),Y1(I+3/2),Y1(I+5/2)) & ENDFOR ;#_20
;
  FOR I=3,N4 DO BEGIN ;DO#_30
    Y3(I+1)=AMED2(Y2(I+1/2),Y2(I+3/2)) & ENDFOR ;#_30
;
  N5=N-5
  FOR I=4,N5 DO BEGIN ;DO#_40
    SY(I+1)=AMED3(Y3(I),Y3(I+1),Y3(I+2)) & ENDFOR ;#_40


    ;       RETURN
  END
;

;     PPS
  PRO ANAL4  ,SST4,WKT,N,M,N10,M10
; $$  SUBPROGRAM DOCUMENTATION BLOCK
;                .      .    .                                       .
;     SUBPROGRAM:    ANAL4      ANALYZES SST ON 4-DEG GRID
;     PRGMMR: R. W. REYNOLDS    ORG: W/NMCX4     DATE: 91-07-22
;
;     ABSTRACT: TAKES SUPER OBSERVATIONS OF SST OF 4-DEGREE GRID AND
;           FILLS IN INTERNAL VALUES BY INTERPOLATION AND FILLS IN
;           EXTERNAL VALUES BY EXTRAPOLATION.  THE INTERPOLATION IS
;           DONE BY SUBROUTINE WEAVER, THE EXTRAPOLATION BY SUBROUTINE
;           EXTRAP.  THE FILLED IN ARRAY IS THEN SMOOTHED BY THE
;           MEDIAN FILTER OF SUBROUTINE TUKEY.
;
;     PROGRAM HISTORY LOG:
;     91-07-22  RICHARD W. REYNOLDS
;
;     USAGE:    CALL ANAL4 (SST4,WKT,N,M,N10,M10)
;
;     INPUT ARGUMENT LIST:
;     SST4   -   4-DEG RESOLUTION SST SUPEROBS IN DEG C
;            -   TO BE FILLED AND SMOOTHED
;     WKT    -   4-DEG RESOLUTION WORK ARRAY
;            -   THIS ARRAY IS BIGGER THAN THE OTHER 4-DEG FIELDS
;            -   TO AVOID END EFFECTS OF MEDIAN FILTER (SUBR TUKEY)
;     N      -   FIRST DIMENSION OF SST4, NSST4 AND WKW
;                (90 IN CALLING ROUTINE)
;     M      -   SECOND DIMENSION OF SST4, NSST4 AND WKW
;                (45 IN CALLING ROUTINE)
;     N10    -   FIRST DIMENSION OF WKT
;                (100 IN CALLING ROUTINE)
;     M10    -   FIRST DIMENSION OF WKT
;                (55 IN CALLING ROUTINE)
;
;     OUTPUT ARGUMENT LIST:      (INCLUDING WORK ARRAYS)
;     SST4   -   4-DEG RESOLUTION SST ANALYZED FIELD IN DEG C
;            -   FILLED AND SMOOTHED
;
;     REMARKS:  ARRAY INDICES CORRESPOND TO LOCATIONS AS FOLLOWS:
;
;     FOR SST4
;
;     LONG:   1,  21,  41,  61,  81, 101, 121, 141, 161,-179,
;     INDEX:  1,   6,  11,  16,  21,  26,  31,  36,  41,  46,
;
;     LONG:   -159,-139,-119, -99, -79, -59, -39, -19,  -3.
;     INDEX:    51,  56,  61,  66,  71,  76,  81,  86,  90.
;
;     LAT:   -87,-67,-47,-27, -7, 13, 33, 53, 73, 89.
;     INDEX:   1,  6, 11, 16, 21, 26, 31, 35, 41, 45.
;
;     ATTRIBUTES:
;     LANGUAGE: FORTRAN 77 (NFORVCLG); COMPILER OPTIONS (GOSTMT,NOSDD)
;     MACHINE:  NAS
;
; $$
  SST4= DBLARR(N,M)&NSST4= DBLARR(N,M)&WKT= DBLARR(N10,M10)&WKW= DBLARR(N,M)&
  VAL= FLTARR(501)&
  FOR I=6,N5 DO BEGIN ;DO#_20
  IM = I - 5
  FOR J=6,M5 DO BEGIN ;DO#_20
  JM = J - 5
  WKT(I,J) = SST4(IM,JM)
  ENDFOR  & ENDFOR ;#_20
  FOR I=1,5 DO BEGIN ;DO#_30
  FOR J=1,M10 DO BEGIN ;DO#_30
  WKT(I,J) = WKT(I+N,J)
  WKT(I+N5,J) = WKT(I+5,J)
  ENDFOR  & ENDFOR ;#_30
  FOR I=1,N10 DO BEGIN ;DO#_40
  FOR J=1,5 DO BEGIN ;DO#_40
  WKT(I,J) = WKT(I,6)
  WKT(I,J+M5) = WKT(I,M5)
  ENDFOR  & ENDFOR ;#_40
  TUKEY , WKT,N10,M10
  FOR I=6,N5 DO BEGIN ;DO#_50
  IM = I - 5
  FOR J=6,M5 DO BEGIN ;DO#_50
  JM = J - 5
  SST4(IM,JM) = WKT(I,J)
  ENDFOR  & ENDFOR ;#_50
;       RETURN
  END


