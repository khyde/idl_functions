; $ID:	CLEAN_SPEC.PRO,	2020-07-08-15,	USER-KJWH	$
;Viewing contents of file '/net/www/deutsch/idl/idllib/ghrs/pro/clean_spec.pro'

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+
;
;*NAME: CLEAN_SPEC
;
;*PURPOSE: Cleans the noise from the spectrum by filtering in the Fourier domain
;
;*CALLING SEQUENCE:
;	CLEAN_SPEC,ft_cspec
;*PARAMETERS:
;   INPUT:
;	ft_cspec - (REQ) - [1] - (I,R,L,D) - Input flux.
;   OUTPUT:
;	FT_CSPEC - (REQ) - [1] - (I,R,L,D) - Fourier transform of flux.
;
;*INTERACTIVE INPUT:
;	1) Noise Analysis - User is prompted to use cursor to indicate
;		point where the noise dominates the signal
;	2) Inputs:
;		- verify LIMIT value.
;		- number of points for spline fit.
;		- cut-off rate
;
;*SUBROUTINES CALLED:
;	cspline  - Spline function.
;*NOTES:
;	This procedure is designed to work with OPT_FILTER.
;
;	!dump is used to control the amount of information displayed where
;		1 = minimum (default)
;		2 = intermediate comments.
;		3 = lots of stuff.
;
;*MODIFICATION HISTORY:
;	Ver 1.0 - 08/29/90 - R. Robinson  - GSFC
;	Ver 2.0 - 12/16/90 - J. Blackwell - GSFC - Modified to conform with
;		                                   GHRS DAF standards.
;	5-MAR-1992	JKF/ACC	-moved to IDL Version 2.
;-
;-------------------------------------------------------------------------------
pro clean_spec,ft_cspec

on_error,2
if n_params[0] lt 1 then $
  message,'Calling Sequence:  CLEAN_SPEC, ft_cspec'
;
;  set up graphics device character output positions
;
if !d.name eq 'TEK' then device,gin_char=6
vspace = !d.y_ch_size * 1.2		; distance between char (Y direction)
vpos   = !d.y_vsize - vspace
hpos   = !d.x_ch_size * 3
thpos  = hpos
tvpos  = vpos
;
dum=' '
n = n_elements(ft_cspec)
num=fix(n/2)
;
; first get the power spectrum of each of these and take the log.
;
lcspec=alog10(abs(ft_cspec(0:num)))
loop:
;
; Plot the log of the spectrum
;

  hpos  = thpos
  vpos  = tvpos
  plot,lcspec, $
	title=' Fourier transform power for the spectrum', $
  	xtitle='Frequency', $
	ytitle='Log Power', $
	lines=0, xmargin=[10,3],ymargin=[4,15],font=-1,charsize=1

;
;  ***************  Noise Analysis ***********************************
; Use cursor to indicate point where the noise dominates the signal
;
  !err  = 0
  if !d.name eq 'TEK' then begin
     xyouts,hpos,vpos,/dev,font=0, $
    	' Place the cursor at the point where the noise first dominates.'
     vpos = vpos - vspace
     xyouts,hpos,vpos,/dev,font=0,  $
	 ' then hit any key (<cr> to ABORT)'
     vpos = vpos - vspace
  end else begin
     print,string(7b)
     print,'PLACE THE CURSOR AT THE POINT WHERE THE NOISE FIRST DOMINATES'
     print,' THEN HIT ANY KEY (<CR> TO ABORT)'
  end
  flush = get_kbrd[0]                 ;flush type buffer
  cursor,xd,yd,/data
  if (!err eq 13) then retall		;abort
;
;  Draw a line to indicate the position of the high frequency cutoff.
;
  yl=[!cymin,!cymax]
  xl=[xd,xd]
  oplot,xl,yl,lines=2
  if !d.name eq 'TEK' then begin
     xyouts,hpos,vpos,/dev,'limit= '+strtrim(xd,2)
     vpos = vpos - vspace
  end else print,'   LIMIT= ',xd
;
  ans=' '
  if !d.name eq 'TEK' then begin
  	xyreads,hpos,vpos,/dev,ans,' Is this ok ?  [y]/n '
     	vpos = vpos - vspace
  end else begin
	print,string(7b)
	read,'    IS THIS OK ?  [y]/n ',ans
  end
  if strupcase(strmid(strtrim(ans,2),0,1)) eq 'N' then goto,loop

;
; fit the noise with a first order polynomial and draw the line on the graph.
;
  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
  	xyouts,hpos,vpos,/dev, $
		'Fitting the noise with a first order polynomial'
     	vpos = vpos - vspace
    end else   print,'FITTING THE NOISE WITH A FIRST ORDER POLYNOMIAL'
  end

  y=lcspec(xd:num)
  npt=n_elements(y)
  x=indgen(npt)+xd
  noise_coef=poly_fit(x,y,1,yfit)
  numpt=indgen(num)
  log_noise=noise_coef[0]+noise_coef*numpt

  if (not (!noplot)) then $
  	oplot,numpt,log_noise,lines=2
;
;  ******************** signal + noise analysis **********************
;
;    set up the arrays:
;    yspec=portion of the transform to fit
;    this consists of both signal and noise contributions
;    will fit with a second or third order polynomial
;    ignore the point at zero frequency
;
  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
  	xyouts,hpos,vpos,/dev, $
		' Fitting data (spline)'
	vpos = vpos - vspace
    end else begin
	  print,' '
	  print,' FITTING DATA (SPLINE)'
    end
  end

  yspec=lcspec(1:xd)
  npt=n_elements(yspec)
  x=indgen(npt)+1
;
  if !d.name eq 'TEK' then begin
  	xyouts,hpos,vpos,/dev, $
  		'Number of points in the signal data= '+strtrim(npt,2)
     	vpos = vpos - vspace
	nave = ' '
  	xyreads,hpos,vpos,/dev,nave, $
  		' Input number of points to average for spline fit: '
     	vpos = vpos - vspace
	nave = long(nave)
  end else begin
	print,' '
  	PRINT,' NUMBER OF POINTS IN THE SIGNAL DATA= ',NPT
	print,string(7b)
  	READ,' INPUT NUMBER OF POINTS TO AVERAGE FOR SPLINE FIT ',NAVE
	print,' '
  end
;
  nspline=fix(npt/nave)
  yave=fltarr(nspline+1)
  xave=fltarr(nspline+1)
  numspl=-1
  for i=0,npt-nave-1,nave do begin
    numspl=numspl+1
    yave(numspl)=total(yspec(i:i+nave-1))/nave
    xave(numspl)=i+(nave/2.)
  endfor
;
; Make sure that the final point is at the noise level.
;
  nfit=fix((nspline+.5)*nave)
  xave(nspline)=nfit
  yave(nspline)=noise_coef[0]+noise_coef[1]*xave(nspline)

  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'Number of points fit by the spline=' + $
	  	strtrim(nfit,2)
     	  vpos = vpos - vspace
    end else print,' NUMBER OF POINTS FIT BY THE SPLINE= ',NFIT
  end
  if !dump gt 3 then print,xave(nspline),yave(nspline)
;
; Now do the spline fit.
;
  xfit=indgen(nfit)+1.
  yfit=cspline(xave,yave,xfit)
  ;  sig_coef=poly_fit(x,yspec,2,yfit)

;
; Now plot the signal + noise and the averages.
;
  if (not(!noplot)) then begin
    plot,x,yspec, $
	title='Fitting the signal + noise to a model', $
  	lines=0, xmargin=[10,3],ymargin=[4,15],font=-1,charsize=1

    oplot,xave,yave,psym=6
    oplot,xfit,yfit,lines=2			; spline
    oplot,x,log_noise,lines=2,thick=2
  end


  flush = get_kbrd[0]                 ;flush type buffer
  if (not (!noplot)) then begin
    hpos = thpos				; reset prompt to top of form
    vpos = tvpos
    if !d.name eq 'TEK' then begin
	print,string(7b)
  	xyreads,hpos,vpos,dum,/dev, $
  		'<cr> to continue:'
     	vpos = vpos - vspace
    end else begin
	print,' '
	print,string(7b)
	read,' <CR> TO CONTINUE:',DUM
	print,' '
    end
  end
;
; ***********  separate signal and noise ******************
;
; Now calculate the signal.
;
  log_signal=fltarr(num)
  log_noise=fltarr(num)
  log_sig_noise=fltarr(num)
  if !d.name eq 'TEK' then begin
  	xyreads,hpos,vpos,/dev,fall_off, $
  	    'Input fall-off rate for low signals (between 1.5 and 10)'
     	vpos = vpos - vspace
  end else $
  	read,' INPUT FALL-OFF RATE FOR LOW SIGNALS (BETWEEN 1.5 AND 10)',FALL_OFF

  for i=0,num-1 do begin
    log_noise(i)=noise_coef[0]+noise_coef[1]*i
    vnoise=10.^log_noise(i)
    if i lt nfit-1 then begin
      log_sig_noise(i)=yfit(i)
      vsig_noise=10.^log_sig_noise(i)
      sig=vsig_noise-vnoise
      if sig lt 1.e-15 then sig=1.e-15
      log_signal(i)=alog10(sig)
    endif else begin
      log_sig_noise(i)=log_noise(i)
      sig=(10.^log_signal(i-1))/fall_off
      if sig lt 1.e-15 then sig=1.e-15
      log_signal(i)=alog10(sig)
    endelse
  endfor
;
;   ******************** optimum filter analysis  ***************
;
  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'Plotting the log of the observed spectrum'
     	  vpos = vpos - vspace
    end else print,' LOG OF THE OBSERVED SPECTRUM'
  end

  uplim=min([num-1,1.4*xd])


  if (not(!noplot)) then begin
    hpos = thpos				; reset prompt to top of form
    vpos = tvpos
    plot,lcspec(0:uplim), $
  	title='optimum filter analysis',lines=0, $
  	xmargin=[10,3],ymargin=[4,15],font=-1,charsize=1
  end

  flush = get_kbrd[0]                 ;flush type buffer

  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'plotting the log of the signal'
     	  vpos = vpos - vspace
    end else print,' LOG OF THE OBSERVED SPECTRUM'
  end

  if (not(!noplot)) then $
  	oplot,log_signal,lines=1

  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'log of the noise'
     	  vpos = vpos - vspace
    end else print,' LOG OF THE NOISE'
  end

  if (not(!noplot)) then $
  	oplot,log_noise,lines=1

  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'signal+noise fit'
     	  vpos = vpos - vspace
    end else print,' SIGNAL + NOISE FIT'
  end
  if (not(!noplot)) then $
  	oplot,log_sig_noise,lines=1
;
; Give the user a chance to redefine the cut-off point.
;
  flush = get_kbrd[0]                 ;flush type buffer
  if !d.name eq 'TEK' then begin
	xyreads,hpos,vpos,/dev,dum, $
  		'Do you want to redefine the cut-off point? y/[n]'
     	vpos = vpos - vspace
  end else begin
	print,' '
	read,' REDEFINE CUT-OFF POINT? Y/[N] ',DUM
  end
  if strupcase(strmid(strtrim(dum,2),0,1)) eq 'Y' then goto,loop
;
;  now determine the optimum filter
;
  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'Determining the optimum filter'
     	  vpos = vpos - vspace
    end else print,'DETERMINING THE OPTIMUM FILTER'
    wait,1
  end

  opt_filter = fltarr(num)
  signal = fltarr(num)
  noise  = fltarr(num)

  for i=0,num-1 do begin
    signal(i)=10.^log_signal(i)
    noise(i)=10.^log_noise(i)
    opt_filter(i)=signal(i)/(signal(i)+noise(i))
  endfor

  log_opt_filter=alog10(opt_filter)

  if (not(!noplot)) then $
  	plot,log_opt_filter(0:uplim),title='optimum filter', $
  		lines=0, xmargin=[10,3],ymargin=[4,15],font=-1,charsize=1

  flush = get_kbrd[0]                 ;flush type buffer
  if (not (!noplot)) then begin
    hpos = thpos				; reset prompt to top of form
    vpos = tvpos
    if !d.name eq 'TEK' then begin
	print,string(7b)
  	xyreads,hpos,vpos,dum,/dev, $
  		'<cr> to continue:'
     	vpos = vpos - vspace
    end else begin
	print,' '
	print,string(7b)
	read,' <CR> TO CONTINUE:',DUM
    end
  end
;
; Now apply the optimum filter.
;
  if !dump gt 1 then begin
    if !d.name eq 'TEK' then begin
	  xyouts,hpos,vpos,/dev,'Applying the optimum filter'
     	  vpos = vpos - vspace
    end else print,' APPLYING THE OPTIMUM FILTER'
    wait,1
  end

  tot_opt_filter=fltarr(n)
  for i=0,num-1 do begin
    tot_opt_filter(i)=opt_filter(i)
    tot_opt_filter(n-i-1)=opt_filter(i)
  endfor

  ft_cspec=ft_cspec*tot_opt_filter
  ly=alog10(abs(ft_cspec))

  if (not(!noplot)) then begin
    title=" Original data (solid), Filtered (dotted), Log (dashed)
    plot,ly(0:uplim),lines=1, xmargin=[10,3],ymargin=[4,15],font=-1, $
	charsize=1,title=title
    oplot,lcspec,lines=0
    oplot,log_opt_filter,lines=2
  end
return
end

