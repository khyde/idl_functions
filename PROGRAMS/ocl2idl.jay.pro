; *****************************************************************
; P R O G R A M    O C L 2 I  D  L
; *****************************************************************


; This Program:
;  1)  Translates World Ocean Database 1998 ASCII data for a
;      single station into an idl structure
;  2)  and returns the structure to the calling program
;      as a parameter STA

;      This Program is called by OCLREAD
;
;      OCL2IDL Calls Four Functions  (see below):
;           EXTRACT_NEXT
;           EXTRACT_TEXT
;           EXTRACT_LONG
;           EXTRACT_VALUE
;      which are used to translate the ASCII data

; NOTE: THIS IS A PRELIMINARY VERSION AND MAY HAVE SOME ERRORS
; Version: February 12, 1998
; John E. O'Reilly, NOAA, Narragansett, RI 02882
; (oreilly@fish1.gso.uri.edu)
; Program runs under IDL version 5.0.2


; The Programs EXTRACT_NEXT, EXTRACT_TEXT, EXTRACT_LONG, EXTRACT_VALUE
; are called by OCL2IDL


; ************************************************************
  Pro EXTRACT_NEXT, holder=holder
; ************************************************************
; Extracts the number of bytes in the next field
; based on the byte width value in the present field
  first  = holder.position
  last   = holder.position + holder.length -1L
  holder.longs = LONG(STRING(holder.byte_array(first:last)))
  holder.position = last +1L

; Now get the nbytes
  first  = holder.position
  last   = holder.position + holder.longs -1L
  holder.longs = LONG(STRING(holder.byte_array(first:last)))
  holder.position = last +1L
; ************************************************************
  END; END OF PROGRAM EXTRAC_NEXT
; ************************************************************




; ************************************************************
  Pro EXTRACT_TEXT, holder=holder
; ************************************************************
; Extracts a text value
  first  = holder.position
  last   = holder.position + holder.length -1L
  holder.text =  STRING(holder.byte_array(first:last))
  holder.position = last +1L
; ************************************************************
  END ; PROGRAM EXTRACT_TEXT
; ************************************************************




; ************************************************************
  Pro EXTRACT_LONG, holder=holder
; ************************************************************
; Extracts a Long value
  first  = holder.position
  last   = holder.position + holder.length -1L
  holder.longs =  LONG(STRING(holder.byte_array(first:last)))
  holder.position = last +1L
; ************************************************************
  END ; PROGRAM EXTRACT_TEXT
; ************************************************************




; *****************************************************************
  Pro EXTRACT_VALUE, holder=holder, MISSING=missing
; ************************************************************
; Extracts a Float Value
  holder.length=1
  EXTRACT_TEXT, holder=holder
  test = holder.text
  IF test EQ '-' THEN BEGIN
    holder.value = missing
  ENDIF ELSE BEGIN
    sig_figures = LONG(holder.text)
    EXTRACT_TEXT, holder=holder
    tot_figures = LONG(holder.text)
    EXTRACT_TEXT, holder=holder
    precision   = LONG(holder.text)
    holder.length=tot_figures
    EXTRACT_TEXT, holder=holder
    holder.value = FLOAT(LONG(holder.text)/(10.0D^precision))
    holder.length = 1L
  ENDELSE
; ************************************************************
  END; END OF PROGRAM EXTRAC_VALUE
; ************************************************************




; **************************************************************
; **************************************************************
  PRO OCL2IDL, STA
; **************************************************************
; **************************************************************
; M a i n   F u n c t i o n
; Converts the ASCII code for a Station into an IDL Structure Array
;
; ============================================================
; D e f i n e    OCL_COMMON
; ============================================================
; (For Keeping Track of Variables used by OCLREAD and OCL2IDL)
  COMMON OCL_COMMON, ocl_lun, ocl_file, ocl_structure



; ============================================================
; C h e c k   P a r a m e t e r   S t a
; ============================================================
  IF N_PARAMS() EQ 0 THEN BEGIN
    txt = [['ERROR: '],['Parmeter STA Must be Provided']]
    error = DIALOG_MESSAGE(txt,/ERROR)
    GOTO,DONE_OCL2IDL
  ENDIF


; ============================================================
; D e f i n e  S t a n d a r d _ l e v e l s (meters)
; ============================================================
  standard_levels=[ $
       0.,   10.,   20.,   30.,   50.,   75.,  100.,  125., 150., $
     200.,  250.,  300.,  400.,  500.,  600.,  700.,  800., 900.,$
    1000., 1100., 1200., 1300., 1400., 1500., 1750., 2000.,$
    2500., 3000., 3500., 4000., 4500., 5000., 5500., 6000.,$
    6500., 7000., 7500., 8000., 8500., 9000.]


; ============================================================
; Extract the structures from the Structure (ocl_structure)
; ============================================================
  ph = ocl_structure.ph
  ch = ocl_structure.ch
  sh = ocl_structure.sh
  bh = ocl_structure.bh
  dc = ocl_structure.dc
  pc = ocl_structure.pc

  p  = ocl_structure.p
  e  = ocl_structure.e
  TB = ocl_structure.tb

  ph_names = TAG_NAMES(ph)
  ch_names = TAG_NAMES(ch)
  sh_names = TAG_NAMES(sh)
  bh_names = TAG_NAMES(bh)
  dc_names = TAG_NAMES(dc)
  pc_names = TAG_NAMES(pc)
  p_names  = TAG_NAMES(p)
  e_names  = TAG_NAMES(e)


; ===============>
; Place the World Ocean Database File name into the ph structure
  ph.file = ocl_file


; ============================================================
; B e g i n  E x t r a c t i o n   of   P r i m a r y   H e a d e r
; ============================================================

; Logic:
; 0) The World Ocean Database file must first be opened by OCLREAD
; 1) The first character in the ocl ascii file defines
;    the characters for the second field;
; 2) The second field defines the total number of
;    ocl ascii characters in the complete profile;
; 3) Each new station will always begin on a new line.
; 4) Read an entire station profile and store the
;    data in STA, a structure array
; 5) Return STA to calling Program

; ===================>
; Define character_count, a counter for keeping track of the number of characters read
  character_count = 0L

; ====================>
; Read the first text line from the OCL ASCII file into a string variable 'line'
  line = ''
  READF, ocl_lun, FORMAT='(a80)', line
  character_count = character_count + 80L

; ====================>
; Convert the line into a byte array
  byte_array = BYTE(line)

; ====================>
; Create holder, a structure used to hold data extracted
; from OCL byte_array, and used to keep track of the
; the current reading/extracting position in the byte_array

  holder = CREATE_STRUCT('byte_array',  byte_array,$
                             'length',  0L,$
                           'position',  0L,$
                              'longs',  0L,$
                               'text',  '',$
                              'value',  0.0)

; =====================>
; Fields 1 and 2 define the number of bytes in the profile
; Field 1 is the number of bytes in field 2 (I1)
; Set the position to zero
; Set the length of the next field to read to 1.
  holder.position = 0L
  holder.length   = 1L

; =====================>
; Field 2 is the Number of Bytes in the Profile (Integer)
; Use Program EXTRACT_NEXT to get the Number of Bytes in the Profile
  EXTRACT_NEXT,holder=holder
  bytes_in_profile = holder.longs

; =====================>
; Now Read the rest of the data for a Single StatION
; While the character_count is less than bytes_in_profile then:
; 1) Read a new line of ASCII text into the string varialbe 'line';
; 2) Convert line to byte data;
; 3) Concatenate the byte data to the byte_array.
  WHILE character_count LT bytes_in_profile DO BEGIN
    READF,ocl_lun,FORMAT='(a80)', line
    character_count = character_count + 80L
    byte_array = [byte_array,BYTE(line)]
  ENDWHILE

; ====================>
; Update values in holder
  holder = CREATE_STRUCT('byte_array', byte_array,$
                             'length', holder.length,$
                           'position', holder.position,$
                              'longs', 0L,$
                               'text', ' ',$
                              'value', 0.0)




; =====================>
; Fields 3 and 4 define the OCL Profile Number
; Field 3 is the Number of Bytes in Field 4 (I1)
  holder.length = 1L
; =====================>
; Field 4 is OCL Profile Number (Integer)
  EXTRACT_NEXT,holder=holder
  ph.profile = holder.longs


; =====================>
; Field 5 is the Country Code (A2)
  holder.length =  2L
  EXTRACT_TEXT,holder=holder
  ph.country = holder.text

; =====================>
; Fields 6 and 7 define the Cruise Number
; Field 6 is the Number of Bytes in Field 7 (I1)
  holder.length = 1L

; =====================>
; Field 7 is Cruise Number (Integer)
  EXTRACT_NEXT,holder=holder
  ph.cruise = holder.longs

; =====================>
; Field 8 is Year (i4)
  holder.length =  4L
  EXTRACT_LONG,holder=holder
  ph.year = FIX(holder.longs)

; =====================>
; Field 9 is Month (i2)
  holder.length = 2L
  EXTRACT_LONG,holder=holder
  ph.month = FIX(holder.longs)

; =====================>
; Field 10 is Day (i2)
  holder.length = 2L
  EXTRACT_LONG ,holder=holder
  ph.day = FIX(holder.longs)

; =====================>
; Field 11 is Time , missing value is 99.99
  missing= (99.99)
  EXTRACT_VALUE, holder=holder,missing=missing
  ph.time  = FLOAT(holder.value)

; =====================>
; Field 12 is Latitude , missing value is -99.9
; Negative latitude is south.
; Negative longitude is west.
  missing= (-99.9)
  EXTRACT_VALUE, holder=holder,missing=missing
  ph.lat  = FLOAT(holder.value)

; ====================>
; Field 13 is Longitude , missing value is -999
  missing= (-999.0)
  EXTRACT_VALUE, holder=holder,missing=missing
  ph.lon  = holder.value

; ====================>
; Fields 14 and 15 Define the number of Depth Levels
; Field 14 is the Number of Bytes in Field 15 (I1)
  holder.length = 1L
; ====================>
; Field 15 is the Number of depth levels (Integer)
  EXTRACT_NEXT,holder=holder
  ph.n_levels = holder.longs

; ====================>
; Field 16 is the Station Profile Type (I1)
; Observed levels = 0
; Standard levels = 1
  holder.length =1L
  EXTRACT_LONG,holder=holder
  ph.sta_type = FIX(holder.longs)

; ====================>
; Field 17 is Number of Parameters in the Profile (I2)
; Place this into the Parameter Codes structure (pc)
  holder.length = 2L
  EXTRACT_LONG,holder=holder
  pc.n_params = FIX(holder.longs)

; ====================>
; Read in the parameter codes and the whole profile error flags
; Put into the Parameter Codes structure (pc)

  FOR n = 1, pc.n_params DO BEGIN
    nth = n-1
;   Field 18 is Bytes in Field 19 (I1)
    holder.length = 1L
    EXTRACT_NEXT,holder=holder
    pc.p_codes(nth) = holder.longs
    name = 'PE'+ STRTRIM(STRING(holder.longs),2)
    _tag = WHERE(pc_names EQ name)
    EXTRACT_LONG,holder=holder
    pc.(_tag[0]) = holder.longs
  ENDFOR   ; FOR nth = 0, pc.n_params-1 DO BEGIN






; ============================================================
;  E x t r a c t        C h a r a c t e r  a n d
;  P r i n c i p a l    I n v e s t i g a t o r   d a t a
; ============================================================

  CHARACTER_DATA:  ; L A B E L

; ====================>
; Field 1 is Bytes in Field 2 (I1)
; HOWEVER, Check the value in field 1.  If it is 0 then
; there are no character data to read, and leave this program section
; and GOTO SECONDARY_HEADER program section.
  holder.length =1L
  EXTRACT_LONG,holder=holder
  length = holder.longs
  IF length EQ 0 THEN BEGIN
    GOTO, SECONDARY_HEADER
  ENDIF

; ====================>
; Field 2 is Total Bytes for Character Data
  holder.length = length
  EXTRACT_LONG,holder=holder
  total_char_bytes = holder.longs

; ====================>
; Field 3 is Number of Entries (I1)
  holder.length = 1L
  EXTRACT_LONG,holder=holder
  n_entries = holder.longs
  CH.n_ch = n_entries


; ====================>
; ====================>
; FOR EACH of the Entries get the character data
  FOR n = 1, n_entries DO BEGIN

;   ====================>
;   Field 4 is Type of Character Data (I1)
;   1=Originators Cruise
;   2=Originators Station
;   3=Principal Investigator Information

    holder.length = 1L
    EXTRACT_LONG,holder=holder
    char_data_type = holder.longs

    IF char_data_type EQ 1 OR char_data_type EQ 2 THEN BEGIN
;     ======================>
;     Field 5 is Bytes in field 6 (i2)
      holder.length = 2L
      EXTRACT_LONG,holder=holder
      holder.length = holder.longs

;     ====================>
;     Field 6 is the Character Data (A)
      EXTRACT_TEXT,holder=holder
      ch.(char_data_type) = holder.text
    ENDIF ; IF char_data_type EQ 1 OR char_data_type EQ 2 THEN BEGIN

    IF char_data_type EQ 3 THEN BEGIN
;     ====================>
;     Field 5 is Number of P.I. Names (i2)
      holder.length = 2L
      EXTRACT_LONG,holder=holder
      n_pi_names = holder.longs
      ch.n_pi = n_pi_names

;     ===================>
;     Now fill the pi_param and pi_code arrays
      FOR n=1,n_pi_names DO BEGIN
        nth = n-1
;       ====================>
;       Fields 6 and 7 define the pi parameter codes
;       Field 6 is Bytes in Field 7 (I1)
        holder.length = 1L
;       ====================>
;       Field 7 is parameter code
        EXTRACT_NEXT,holder=holder
        pi_code = holder.longs
        ch.pi_codes(nth) = pi_code
        name = 'PI_'+ STRTRIM(STRING(pi_code),2)
        _tag = WHERE(ch_names EQ name)

;       ====================>
;       Fields 8 and 9 define the pi codes
;       Field 8 is Bytes in Field 9 (I1)
        holder.length = 1L
;       ====================>
;       Field 9 is the pi code
        EXTRACT_NEXT,holder=holder
        ch.(_tag[0]) = holder.longs
      ENDFOR  ; FOR n=1,n_pi_namesL DO BEGIN
    ENDIF  ; IF char_data_type EQ 3 THEN BEGIN
  ENDFOR   ; FOR n = 1, n_entries DO BEGIN






; ============================================================
; E x t r a c t   S e c o n d a r y   H e a d e r   D a t a
; ============================================================

; Define a Label, SECONDARY_HEADER
; When there are no charaacter data (above),
; program jumps to SECONDARY_HEADER label
  SECONDARY_HEADER:  ; L A B E L

;  ====================>
; Field 1 is Bytes in Field 2 (I1)
; HOWEVER, Check the value in field 1.  If it is 0 then
; there are no SECONDARY_HEADER data to read, and leave this program section
; and GOTO BIOLOGICAL_HEADER program section.
  holder.length =1L
  EXTRACT_LONG,holder=holder
  length = holder.longs


; ====================>
; If there are no SECONDARY HEADER data THEN GOTO BIOLOGICAL_HEADER
  IF length EQ 0 THEN  GOTO, BIOLOGICAL_HEADER

; ====================>
; Field 2 is Total Bytes for Secondary Header
  holder.length = length
  EXTRACT_LONG,holder=holder
  total_sh_bytes = holder.longs

; ====================>
; Fields 3 and 4 define number of secondary header entries
; Field 3 is Bytes in Field 4 (i1)
  holder.length= 1L
; ====================>
; Field 4 is Number of Entries (Integer)
  EXTRACT_NEXT,holder=holder
  sh.n_sh = holder.longs

; ==================>
; Fill in the secondary header codes and values for each entry
  FOR n = 1, sh.n_sh DO BEGIN
    nth = n-1
;   ====================>
;   Fields 5 and 6 define the secondary header code
;   Field 5 is Number of Bytes in Field 6 (I1)
    holder.length = 1L
;   ====================>
;   Field 6 is the Secondary Header Code
    EXTRACT_NEXT,holder=holder
    sh_code = holder.longs
    sh.sh_codes(nth) = sh_code
    name = 'SH_'+ STRTRIM(STRING(sh_code),2)
    _tag = WHERE(sh_names EQ name)
;   ====================>
;   Fields 7,8,9,10 define the
;   Significant Figures, Total Figures, Precision, Value, respectively,
;   for translating the secondary header value
    EXTRACT_VALUE, holder=holder
    sh.(_tag[0]) = holder.value

  ENDFOR ;FOR n = 0, n_entries-1L DO BEGIN




; ============================================================
; E x t r a c t   B i o l o g i c a l   H e a d e r   D a t a
; ============================================================

; Define a Label, BIOLOGICAL_HEADER
; When there are no Secondary Header data (above),
; program jumps to BIOLOGICAL_HEADER label
  BIOLOGICAL_HEADER:  ; L A B E L

; ====================>
; Field 1 is Bytes in Field 2 (I1)
; HOWEVER, Check the value in field 1.  If it is 0 then
; there are no BIOLOGICAL_HEADER data to read, and leave this program section
; and GOTO PROFILE_DATA program section.

  holder.length =1L
  EXTRACT_LONG,holder=holder
  length = holder.longs



  IF length EQ 0 THEN  GOTO, PROFILE_DATA


; ====================>
; Field 2 is Total Bytes for Biological Header
  holder.length = length
  EXTRACT_LONG,holder=holder
  total_biological_bytes = holder.longs

; ====================>
; Fields 3 and 4 define the Number of Entries
; Field 3 is Bytes in Field 4 (I1)
  holder.length= 1L
; ====================>
; Field 4 is Number of Entries (Integer)
  EXTRACT_NEXT,holder=holder
  bh.n_bh = holder.longs

  IF bh.n_bh GE 1 THEN BEGIN

;   =================>
;   Fill in the biological_header codes and values for each entry
    FOR n = 1, bh.n_bh DO BEGIN
      nth = n-1
;     ====================>
;     Fields 5 and 6 define the biological header code
;     Field 5 is Number of Bytes in Field 6 (I1)
      holder.length = 1L
;     ====================>
;     Field 6 is the Biological Header Code
      EXTRACT_NEXT,holder=holder
      bh_code = holder.longs
      bh.bh_codes(nth) = bh_code
      name = 'BH_'+ STRTRIM(STRING(bh_code),2)
      _tag = WHERE(bh_names EQ name)

;     ====================>
;     Fields 7,8,9,10 define the
;     Significant Figures, Total Figures, Precision, Value, respectively,
;     for translating the biological_header value
      EXTRACT_VALUE, holder=holder
      bh.(_tag[0]) = holder.value
    ENDFOR ;FOR n = 1, n_entries DO BEGIN
  ENDIF ;  IF bh.n_bh GE 1 THEN BEGIN



; ============================================================
; E x t r a c t    T A X O N  &  B I O M A S S  D A T A
; ============================================================

; ===================>
; Define a Label, TAXON_AND_BIOMASS
; When there are no BIOLOGICAL_HEADER data (above),
; program jumps to TAXON_AND_BIOMASS label
  TAXON_AND_BIOMASS:  ; L A B E L    (NOT USED)

; ====================>
; Field 1 is Bytes in Field 2 (I1)
; HOWEVER, Check the value in field 1.  If it is 0 then
; there are no TAXON_AND_BIOMASS data to read, and leave this program section
; and GOTO PROFILE_DATA program section.

  holder.length =1L
  EXTRACT_LONG,holder=holder
  length = holder.longs

; ====================>
; Field 2 is Number of Taxa/Biomass sets
  holder.length = length
  EXTRACT_LONG,holder=holder
  TB.n_tb = holder.longs

  IF TB.n_tb GE 1 THEN BEGIN
;   ====================>
;   Create arrays to hold TB codes, values, and error codes
    TB_code =  ''
    TB_value = 0.0
    TB_error = 0

;   ===================>
;   For each TB set
    FOR set = 1, TB.n_TB   DO BEGIN
      _set = STRTRIM(STRING(set),2) + '_'

;     ====================>
;     Fields 3 and 4 define the Number of Entries
;     Field 3 is Bytes in Field 4 (I1)
      holder.length= 1L
;     ====================>
;     Field 4 is Number of Entries (Integer)
      EXTRACT_NEXT,holder=holder
      n_per_set = holder.longs


;     =================>
;     Fill in the codes, values, and error codes for each entry
      FOR n = 1, n_per_set DO BEGIN
;       ====================>
;       Fields 5 and 6 define the taxon/biomass code
;       Field 5 is Number of Bytes in Field 6 (I1)
        holder.length = 1L
;       ====================>
;       Field 6 is the taxon/biomass code
        EXTRACT_NEXT,holder=holder
        txt = _set + STRTRIM(STRING(holder.longs),2)
        TB_code =  [TB_code, txt ]

;       ====================>
;       Fields 7,8,9,10,11 define the
;       Significant Figures, Total Figures, Precision, Value, and Error Code respectively,
;       for translating the taxon/biomass data
        holder.length = 1L
        EXTRACT_VALUE, holder=holder
        TB_value = [TB_value, holder.value]

;       ====================>
;       Field 11 is the Error Code for the TB value
        holder.length = 1L
        EXTRACT_LONG,holder=holder
        TB_error = [TB_error, holder.longs]

      ENDFOR ;FOR n = 1, n_entries DO BEGIN
    ENDFOR ; FOR set = 1,N_ELEMENTS(TB.n_TB) DO BEGIN


;   ===================>
;   Place the TB codes, values and error codes into the TB structure
    TB = CREATE_STRUCT(TB,'tb_code',  tb_code(1:*), $
                          'tb_value',tb_value(1:*), $
                          'tb_error',tb_error(1:*)  )
  ENDIF ; IF TB.n_tb GE 1 THEN BEGIN







; ============================================================
; E X T R A C T   P A R A M E T E R    P R O F I L E   D A T A
; ============================================================

  PROFILE_DATA:

  IF ph.n_levels EQ 0 THEN  GOTO, STATION

; ====================>
; MISSING CODE FOR PARAMETER VALUES IS -999
  missing = -999
  holder.length = 1L

; ===================>
; Replicate the depth structure (dc) for levels
  dc = REPLICATE(dc, ph.n_levels)

; ===================>
; Replicate the parameter structure (p) for levels
  p = REPLICATE(p, ph.n_levels)

; ===================>
; Replicate the parameter structure (p) for levels
  e = REPLICATE(e, ph.n_levels)

  holder.length =1L
; ====================>
; Fill the depth-parameter array
  FOR _level = 0, ph.n_levels-1L DO BEGIN

;   ====================>
;   If profile_type is 0 then Actual Sampling Depths
;   Else use standard_levels for depth
    IF (ph.sta_type EQ 0 ) THEN BEGIN
;     Field 1 is Number of Significant Figures for the Depth
;     Field 2 is Total Figures for depth
;     Field 3 is the Precision of the Depth value
;     Field 4 is the Depth Value based on Fields 1-3
      EXTRACT_VALUE, holder=holder
      dc(_level).(0) = holder.value

;     ====================>
;     Field 5 is the Depth Error Code (I1)
      EXTRACT_LONG,holder=holder
      dc(_level).(1) = BYTE(holder.longs)
    ENDIF ELSE BEGIN
      dc(_level).(0) = standard_levels(_level)
;     IF Standard Levels then there is no Depth Error Code
;     So the Depth Error Code in the DC structure is unchanged
;     from its initialization (Always 0)
    ENDELSE ;  IF (ph.sta_type EQ 0 ) THEN BEGIN




;   ====================>
;   Now fill in Parameter Value and Parameter Error Code
;   for each of the parameters
    FOR _param = 0, pc.n_params-1  DO BEGIN

;     ====================>
;     Field 6 is Number of Significant Figures in Parameter
;     Fidld 7 is Total Figures in Parameter
;     Field 8 is Precision of Parameter
;     Field 9 is the Parameter Value (based on fields 6,7,8)

      EXTRACT_VALUE, holder=holder ,MISSING=missing
      param_value = holder.value
      name = 'P'+ STRTRIM(STRING(pc.p_codes(_param)),2)
      _tag = WHERE(p_names EQ name)
      p(_level).(_tag[0]) = param_value

;     IF param_value is GT missing (was not negative in ascii file)
;     then read the Parameter Error Code from Field 10
;     Field 10 is the Parameter Error Code (I1)
      IF param_value GT missing THEN BEGIN
        holder.length = 1L
        EXTRACT_LONG,holder=holder
        param_error_code = BYTE(holder.longs)
         name = 'E'+ STRTRIM(STRING(pc.p_codes(_param)),2)
        _tag = WHERE(e_names EQ name)
        e(_level).(_tag[0]) = param_error_code
      ENDIF ; IF param_value GT missing THEN BEGIN


     ENDFOR ;FOR n = 1, pc.n_params DO BEGIN
  ENDFOR;   FOR _level = 0, ph.n_levels-1L DO BEGIN





; ============================================================
; M A K E   A   S T R U C T U R E   F O R  T H E   S T A T I O N
; ============================================================
  STATION:
  sta = CREATE_STRUCT('PH',ph,'PC',pc,'CH',ch,'SH',sh,'BH',bh,'dc',dc,'P',p,'E',e,'TB',TB)

  DONE_OCL2IDL:

; *****************************************************************
  END; PRO OCL2IDL
; *****************************************************************



