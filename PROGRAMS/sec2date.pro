;-------
;SEC2DATE       Created: 10/28/97     Author:  Dave Sausville
;
;This programs converts the number of seconds from Jan 1, 1970 GMT to calendar date
;format.  The TIMEZONE keyword corrects for user location.  The values that should be used
;for the TIMEZONE keyword are listed in the chart below (Any value can be used though).
;   EASTERN     ->  TIMEZONE = -5
;   CENTRAL     ->  TIMEZONE = -6
;   MOUNTAIN   ->  TIMEZONE = -7
;   PACIFIC        ->  TIMEZONE = -8
;
;The RETURN_TIME_ONLY keyword, when set, will return only the hours:minutes:seconds for the
;  given number of seconds.  The Day of the Week, Day, Month, and Year are discarded.
;  The default behavior is to return Day of the Week, Day, Month, Year, and Time.
;
;The RETURN_DATE_ONLY keyword, when set, will return only the Day of the Week, Day, Month, and
;  Year for the given number of seconds.  The time will be discarded.
;  The default behavior is to return Day of the Week, Day, Month, Year,and Time.
;
;*** NOTE *** If both RETURN_TIME_ONLY and RETURN_DATE_ONLY keywords areset, this
;  routine will return the Day of the Week, Day, Month, Year, and Time. This is the default behavior.
;
;  This routine is not supported by Research Systems Inc.
;------

FUNCTION sec2date, seconds, TIMEZONE=tz, $
			RETURN_TIME_ONLY=retTimeOnly,RETURN_DATE_ONLY=retDateOnly


IF KEYWORD_SET(tz) THEN BEGIN
    HourCorrection = tz
ENDIF ELSE HourCorrection=0

retTimeOnly=KEYWORD_SET(retTimeOnly)
retDateOnly=KEYWORD_SET(retDateOnly)

IF (retTimeOnly EQ 1) AND (retDateOnly EQ 1) THEN BEGIN
	retTimeOnly=0
	retDateOnly=0
ENDIF

;Initialize constants
FourYearsSec=126230400L
YearSec=31536000L
DaySec=86400L
HourSec=3600L
MinutesSec=60L

;Correct for time zone
SecondsLeft=FLOOR(seconds) + (HourCorrection * HourSec)

;Calculate Year
NumYears=FLOOR((seconds/FourYearsSec)*4)

;Subtract 4 year blocks
SecondsLeft=SecondsLeft - (FLOOR(SecondsLeft/FourYearsSec) *FourYearsSec)
;Subtract remaining years
Temp=NumYears MOD 4
SecondsLeft=SecondsLeft - (Temp * YearSec)

;Correct Year
Year=NumYears+1970

;Calculate number of days
NumDays=FLOOR(SecondsLeft/DaySec)

;Test for Leap Year
IF ((Year MOD 4) NE 0) THEN BEGIN
    ;NOT LEAP YEAR
    CASE 1 OF
        ;Jan
        (NumDays GE 0) AND (NumDays LE 30): BEGIN
            Month = 'Jan '
            Day=NumDays + 1
            END
        ;Feb
        (NumDays GE 31) AND (NumDays LE 59): BEGIN
            Month = 'Feb '
            Day=NumDays - 30
            END
        ;Mar
        (NumDays GE 60) AND (NumDays LE 90): BEGIN
            Month = 'Mar '
            Day = NumDays - 59
            END
        ;Apr
        (NumDays GE 91) AND (NumDays LE 120): BEGIN
            Month = 'Apr '
            Day = NumDays - 90
            END
        ;May
        (NumDays GE 121) AND (NumDays LE 151): BEGIN
            Month = 'May '
            Day = NumDays - 120
            END
        ;Jun
        (NumDays GE 152) AND (NumDays LE 181): BEGIN
            Month = 'Jun '
            Day = NumDays - 151
            END
        ;Jul
        (NumDays GE 182) AND (NumDays LE 212): BEGIN
            Month = 'Jul '
            Day = NumDays - 181
            END
        ;Aug
        (NumDays GE 213) AND (NumDays LE 243): BEGIN
            Month = 'Aug '
            Day = NumDays - 212
            END
        ;Sep
        (NumDays GE 244) AND (NumDays LE 273): BEGIN
            Month = 'Sep '
            Day = NumDays - 243
            END
        ;Oct
        (NumDays GE 274) AND (NumDays LE 304): BEGIN
            Month = 'Oct '
            Day = NumDays - 273
            END
        ;Nov
        (NumDays GE 305) AND (NumDays LE 334): BEGIN
            Month = 'Nov '
            Day = NumDays - 304
            END
        ;Dec
        (NumDays GE 335) AND (NumDays LE 365): BEGIN
            Month = 'Dec '
            Day = NumDays - 334
            END
    ENDCASE
ENDIF ELSE BEGIN
    ;LEAP YEAR
    CASE 1 OF
        ;Jan
        (NumDays GE 0) AND (NumDays LE 30): BEGIN
            Month = 'Jan '
            Day=NumDays + 1
            END
        ;Feb
        (NumDays GE 31) AND (NumDays LE 60): BEGIN
            Month = 'Feb '
            Day=NumDays - 30
            END
        ;Mar
        (NumDays GE 61) AND (NumDays LE 91): BEGIN
            Month = 'Mar '
            Day = NumDays - 60
            END
        ;Apr
        (NumDays GE 92) AND (NumDays LE 121): BEGIN
            Month = 'Apr '
            Day = NumDays - 91
            END
        ;May
        (NumDays GE 122) AND (NumDays LE 152): BEGIN
            Month = 'May '
            Day = NumDays - 121
            END
        ;Jun
        (NumDays GE 153) AND (NumDays LE 182): BEGIN
            Month = 'Jun '
            Day = NumDays - 152
            END
        ;Jul
        (NumDays GE 183) AND (NumDays LE 213): BEGIN
            Month = 'Jul '
            Day = NumDays - 182
            END
        ;Aug
        (NumDays GE 214) AND (NumDays LE 244): BEGIN
            Month = 'Aug '
            Day = NumDays - 213
            END
        ;Sep
        (NumDays GE 245) AND (NumDays LE 274): BEGIN
            Month = 'Sep '
            Day = NumDays - 244
            END
        ;Oct
        (NumDays GE 275) AND (NumDays LE 305): BEGIN
            Month = 'Oct '
            Day = NumDays - 274
            END
        ;Nov
        (NumDays GE 306) AND (NumDays LE 335): BEGIN
            Month = 'Nov '
            Day = NumDays - 305
            END
        ;Dec
        (NumDays GE 336) AND (NumDays LE 366): BEGIN
            Month = 'Dec '
            Day = NumDays - 335
            END
    ENDCASE
ENDELSE

;Subtract number of days
SecondsLeft=SecondsLeft - (NumDays * DaySec)

;Calculate day of week
NumLeapYrs=FLOOR((Year-1970) / 4)
NumDays=NumDays + (5 * NumLeapYrs)
YrsLeft = (Year-1970) MOD 4
IF (YrsLeft NE 0) THEN NumDays = NumDays + YrsLeft

CASE (NumDays MOD 7) OF
    0:  DayOWeek='Thu '
    1:  DayOWeek='Fri '
    2:  DayOWeek='Sat '
    3:  DayOWeek='Sun '
    4:  DayOWeek='Mon '
    5:  DayOWeek='Tue '
    6:  DayOWeek='Wed '
ENDCASE

;Calculate hour
Hour = FLOOR(SecondsLeft/HourSec)

;Subtract number of hours
SecondsLeft=SecondsLeft - (Hour * HourSec)

;Timezone correction
;Hour = Hour + HourCorrection

;Calculate minutes
Minutes = FLOOR(SecondsLeft/MinutesSec)

;Subtract number of minutes
SecondsLeft=SecondsLeft - (Minutes * MinutesSec)

;Seconds
Seconds=FLOOR(SecondsLeft)

IF (Seconds LT 10) THEN Seconds = '0' + STRCOMPRESS(STRING(Seconds),/Remove) $
    ELSE Seconds=STRCOMPRESS(STRING(Seconds), /Remove)

IF (Minutes LT 10) THEN Minutes = '0' + STRCOMPRESS(STRING(Minutes),/Remove) $
    ELSE Minutes=STRCOMPRESS(STRING(Minutes), /Remove)

IF (Hour LT 10) THEN Hour = '0' + STRCOMPRESS(STRING(Hour), /Remove) $
	ELSE Hour = STRCOMPRESS(STRING(Hour), /Remove)

Time = Hour + ':' + Minutes + ':' + Seconds

Day=STRCOMPRESS(STRING(Day), /Remove)
Year=STRCOMPRESS(STRING(Year), /Remove)

IF (retTimeOnly EQ 0) AND (retDateOnly EQ 0) THEN BEGIN
	Result = DayOWeek + Month + Day + ',' + Year + ' '+ Time
	RETURN, Result
ENDIF ELSE IF (retDateOnly EQ 1) THEN BEGIN
	Result = DayOWeek + Month + Day + ',' + Year
	RETURN, Result
ENDIF ELSE 	RETURN, Time
END
;;;;;;;;;;;;;;;;;;;;;;;;;;END SAMPLE CODE


;John
;Well. You found a bug- thanks! For some reason the code is not linked in
;for that function.
;Enclosed is a function called Sec2Date written by one of the tech
;support engineers here that will
;do exactly what sec_to_date should do and much more. Let me know if you
;have other questions on it.
;I have logged your finding as a bug.
;Jennifer Kolar
;RSI Technical Support Engineer
;PS.  Please include my FULL name in your subject line when replying to
;tech support


;> -----Original Message-----
;> From:	John E. O'Reilly [SMTP:oreilly@fish1.gso.uri.edu]
;> Sent:	Wednesday, June 17, 1998 1:52 PM
;> To:	'RSI SUPPORT'
;> Subject:	problem with SEC_TO_DT
;>
;> J.E. O'Reilly
;> using idl 5.1 on windows NT
;
;>
;> PROBLEM:
;> I am trying to use SEC_TO_DT , a RSI idl routine available according
;> to the help menu.
;>
;> The ERROR i GET :
;>
;> date = sec_to_dt(3333)
;> % Variable is undefined: SEC_TO_DT.
;> % Execution halted at:  $MAIN$
;>