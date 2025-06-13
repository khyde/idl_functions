pro  gaussfit_demo

   ; Define the independent variable.
   n = 101
   x = (FINDGEN(n)-(n/2))/4

   ; Define the coefficients.
   a = [4.0, 1.0, 2.0, 1.0, 0.25, 0.01]
   print, 'Expected: ', a
   z = (x - a[1])/a[2]    ; Gaussian variable
   !P.MULTI = [0,2,2]     ; set up 2x2 plot window
   seed = 123321          ; Pick a starting seed value

   for nterms=3,6 do begin
      ; Define the dependent variables. Start with random noise.
      y = 0.4*RANDOMN(seed, n)

      ; Use a switch statement so we fall through to each term.
      switch nterms of
         6: y = y + a[5]*x^2
         5: y = y + a[4]*x
         4: y = y + a[3]
         3: y = y + a[0]*exp(-z^2/2)
      endswitch

      ; Fit the data to the function, storing coefficients in
      ; coeff:
      yfit = GAUSSFIT(x, y, coeff, NTERMS=nterms)
      print, 'Result:   ', coeff[0:nterms-1]
      ; Plot the original data and the fitted curve:
      PLOT, x, y, TITLE='nterms='+STRTRIM(nterms,2)
      OPLOT, x, yfit, THICK=2
   endfor
end

