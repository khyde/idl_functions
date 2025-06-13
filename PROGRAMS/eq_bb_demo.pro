pro eq_bb_demo
pal36
chl=interval([-3,2],base=10,.1)
lam=670

bbp670 = -0.00113*lam + 1.62517


bbpchl = 0.4126*chl^0.766

plot, chl,bbpchl,/xlog,/ylog

bbp = 0.01829*bbpchl*bbp670 + 0.00006
oplot, chl,bbp,color=18

; bricaud et al. 1998
bp_660 = 0.252*chl^0.635
oplot, chl,bp_660,color=21
oplot, chl,bp_660,color=27

end