; $ID:	EPFERROR.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION epferror,intime,inrate,raterr=inerror,period=period,               $
           pstart=pstart,pstop=pstop, ntrials=ntrials,                      $
           nbins=nbins,chatty=chatty,                                       $
           fitchi=fitchi,                                                   $
           maxperlist=maxperlist,                                           $
           seed=seed,                                                       $
           debug=debug, _EXTRA=ex
;+
; NAME:
;             epferror
;
;
; PURPOSE:
;             estimate epoche folding error with monte-carlo
;             simulation approach.
;
; CATEGORY:
;             timing tools
;
;
; CALLING SEQUENCE:
;             error=epferror(time,rate,period=period, raterr=raterr,
;                    pstart=pstart,pstop=pstop, ntrials=ntrials,
;                    nbins=nbins,sampling=sampling,gti=gti,chatty=chatty,tolerance=tolerance)
;
;
; INPUTS:
;             time : a vector containing the time in arbitary units
;             rate : a vector containing the countrate; if not given,
;                    the times are assumed to come from individual events
;
;            pstart: lowest period to be considered.
;                    Propagated to epfold when analysing simulated
;                    lightcurve.
;             pstop: highest period to be considered.
;                    Propagated to epfold when analysing simulated
;                    lightcurve.
;
; OPTIONAL INPUTS:
;          ntrial: number of trials to apply epoche folding on
;                  a simulated lightcurve. Default: 1000.
;
;             gti: at the moment for event data only: gti[2,*] is an
;                  array with the good times from the event selection,
;                  gti[0,*] are the start times, gti[1,*] the stop
;                  times. Obviously, use the same time system for time
;                  and gti (i.e., also barycenter gtis!). Needed for
;                  the computation of the exposure time of the phase
;                  bins, if not given, the time of the first and the
;                  last event is used instead.
;                  Propagated to epfold when analysing simulated
;                  lightcurve.
;
;             raterror: a given error vector for the countrate. In
;                  this case monte carlo simulation will be performed
;                  with gaussian distribution using this error.
;                  THEREFORE THIS ERROR IS INTERPRETED AS GAUSSIAN
;                  STANDARD DEVIATION!!!
;                  If not given and we are not working on events,
;                  raterror is computed using poissonian statistics.
;                  This should be the standard case.
;
;             nbins:    number of phase-bins to be used in creating
;                  the epoche folded trial profile. Default: 20.
;                  Propagated to epfold when analysing simulated
;                  lightcurve.
;
;          sampling: how many periods per peak to use (default=10)
;                  Propagated to epfold when analysing simulated
;                  lightcurve.
;
;       tolerance: parameter defining the lower limit for the gap
;                  length; the reference is the time difference
;                  between the first and second entry in the time
;                  array; tolerance defines the maximum allowed relative
;                  deviation from this reference bin length;
;                  default: 1e-8; this parameter is passed to timegap
;                  (see timgap.pro for further explanation)
;                  Propagated to epfold when analysing simulated
;                  lightcurve.
;
;       seed     : initial seed number for monte carlo
;                  simulation. Must be negative number when starting
;                  new. Refer ran3 lib function.
;                  Per default seed is set at -systime (seconds since
;                  1970, jan 1.)
;
;       chatty   : if 1 (or /chatty): report progress. If 2, report
;                  single epfold progress also.
;
; KEYWORD PARAMETERS:
;             fitchi   : fit a Gauss distribution to the chi^2 and use
;                        the center of the gauss to determine the
;                        period, instead of using the maximum of the
;                        chi^2 distribution.
;             debug    : Use rate as the estimated data set, i.e. rate
;                        contains the actual period without noise. Can
;                        be used to debug the profile multiplying
;                        method.
;
; OUTPUTS:
;             returns: estimated error value for given period applied
;                      to the input rate data set.
;
; OPTIONAL OUTPUTS:
;          maxperlist: (unsorted) list of periods found to be a
;                      maximum using a simulated input lightcurve. Contains
;                      ntrial entries.
;
;
; COMMON BLOCKS:
;             none !!!
;
;
; SIDE EFFECTS:
;             none
;
; USER HANDLING:
;             The processing may last a long time (be prepared to wait
;             hours to weeks). To abort the main monte carlo loop one
;             may enter "x" on the keyboard. Already computed values
;             are returned in maxperlist.
;
; RESTRICTIONS:
;
;             the input lightcurve has to be given in count rates (not
;             in photon numbers).
;
;
; PROCEDURE:
;             This routine tries to estimate the error of a previous
;             received period using the epoche folding approach. For
;             this we do:
;             1.) calculate a mean profile with given period.
;             2.) compute the intensity for all times applying the
;                 period multiplied profile.
;             3.) simulate an error for all times (standard: using
;                 poisson statistics, or use the error for normal
;                 statistics).
;             4.) Perform epoche folding for that simulated lightcurve.
;             5.) Go to step 2.) Ntrial times, sum up the maximum of epoche
;                 folding found.
;             6.) Compute the standard deviation of the Ntrial maxima
;                 obtained and take these as the error.
;
;             References:
;                 Davies, S.R., 1990, MNRAS 244, 93
;                 Larsson, S., 1996, A&AS 117, 197
;                 Leahy, D.A., Darbro, W., Elsner, R.F., et al., 1983,
;                    ApJ 266, 160-170
;                 Schwarzenberg-Czerny, A., 1989, MNRAS 241, 153
;
; EXAMPLE:
;            epfold,time,rate,chierg=chierg,maxchierg=maxchierg,pstart=9,pstop=11
;            print,"Period:", maxchierg[0],$
;                  "Error:", epferror(time,rate,pstart=9,pstop=11,period=maxchierg[0])
;
;
; MODIFICATION HISTORY:
;
; $Log: epferror.pro,v $
; Revision 1.4  2003/11/04 13:01:01  rodina
; fix: in case of /fitchi option maxchierg[0] also contains the best
;      period found (and *not* chierg[2,0]).
;
; Revision 1.3  2003/10/22 12:16:53  rodina
; Increased chatty period precission (e.g.)
;
; Revision 1.2  2003/10/11 19:46:31  goehler
; replaced random generator with ran3_poisson (misc library)
;
; Revision 1.1  2003/10/10 12:14:19  goehler
; initial, still buggy version
;
;-

    ;; ------------------------------------------------------------
    ;; SETUP
    ;; ------------------------------------------------------------

    IF n_elements(ntrial) EQ 0 THEN ntrial = 1000l

    IF n_elements(chatty) GT 0 THEN BEGIN
        IF chatty GT 1 THEN epfchatty = 1
    ENDIF

    ;; list of period entries
    maxperlist=dblarr(ntrial)

    ;; seed default:
    IF n_elements(seed) EQ 0 THEN seed = -long(systime[1])



    ;; set default nbins:
    IF n_elements(nbins) EQ 0 THEN nbins = 20

    ;; number of bins for lightcurve to simulate. Should equal to
    ;; nbins:
    simnbins=nbins


    ;; create profile with input period:
    pfold,intime,inrate, profile,period=period,raterr=raterr, $
      tolerance=tolerance,nbins=simnbins,gti=gti,proferr=proferr,phbin=phbin


    ;; create base lightcurve with repeated profile:
    simbaserate = interpol(profile,phbin,(intime MOD period)/period)


    ;; if debug -> use original input as base:
    IF keyword_set(debug) THEN simbaserate = inrate

    ;; define error for each time either poissonian or normal
    IF n_elements(raterr) EQ 0 THEN BEGIN
        poisson=1
    ENDIF ELSE BEGIN
        simerr = raterr
        poisson=0
    ENDELSE

    ;; ------------------------------------------------------------
    ;; MAIN MONTE-CARLO LOOP:
    ;; ------------------------------------------------------------


    FOR i=0l,ntrial-1 DO BEGIN

        ;; 1.) create simulated lightcurve:
        simrate = simbaserate
        IF poisson THEN BEGIN

;; do not use IDL random generator -> replacement with IAAT one
;;            FOR j = 0l,n_elements(simrate)-1l DO BEGIN
;;                simrate[j] = randomn(seed,poisson=simbaserate[j],/double)
;;            ENDFOR

            simrate = double(ran3_poisson(seed,simbaserate))

        ENDIF ELSE BEGIN
            ;; create rate scattered with gaussian distribution,
            ;; according bevington, p.85:
            simrate = simerr*randomn(seed,n_elements(simbaserate),/normal) + simbaserate
        ENDELSE

        ;; 2.) perform epoche folding for this lightcurve:
        epfold,intime,simrate,                                     $;raterr=inerror,$
          pstart=pstart,pstop=pstop,                               $
          nbins=nbins, chatty=epfchatty,                           $
          maxchierg=maxchierg,                                     $ ; thats what we are looking for
          fitchi=fitchi, chierg=chierg,                            $
          _EXTRA=ex                                                  ; support entire epfold

        ;; save period found (either as maximum or fitchi estimation):
        maxperlist[i] = maxchierg[0]

        IF keyword_set(chatty) THEN BEGIN
            print, "Processed: ", (100.*i)/ntrial,"%", $
              "  Period: ", maxchierg[0], "  Level: ", maxchierg[1], $
              format="(A,F4.1,A,A,G25.12,A,G10.5)"
        ENDIF

        ;; abort for x pressing
        IF get_kbrd[0] EQ 'x' THEN break

    ENDFOR

    ;; ------------------------------------------------------------
    ;; COLLECT THE SINGLE MAXIMA:
    ;; ------------------------------------------------------------

    ;; avoid errors
    i = i < (n_elements(maxperlist)-1l)

    ;; restrict to actual computed list:
    error = stddev(maxperlist[0:i])

    return, error

END

