pro junk_stats_test

arrsz = 95046858
nfiles = 10

tic
arr = fltarr([arrsz,nfiles])
arr(*) = missings(0.0)
for i=0, nfiles-1 do begin
  arr(*,i) = randomu(seed,arrsz)*1.5
endfor
toc

ok = where(indgen(n_elements(arr)) mod 50 eq 0,count,complement=comp)
marr = arr
marr[ok] = missings(0.0)


tic
me = mean(arr,dimension=2,/nan,/double)
md = median(arr,dimension=2,/even)
sm = total(arr,2,/nan)
sd = stddev(arr,dimension=2,/double)
mn = min(arr,dimension=2,/nan)
mx = max(arr,dimension=2,/nan)
toc

tic
mom =  MOMENT(ARR, /DOUBLE, dimension=2, KURTOSIS=KURT, MDEV=MDEV , MEAN=MEN , /NAN , SDEV=STD , SKEWNESS=SKEW , VARIANCE=VAR )
med = median(arr,dimension=2,/even)
tot= total(arr,2,/nan)
nim = min(arr,dimension=2,/nan)
xam = max(arr,dimension=2,/nan)
toc


;tic
;mme = mean(marr,dimension=2,/nan)
;mmd = median(marr,dimension=2,/even)
;msm = total(marr,2,/nan)
;msd = stddev(marr,dimension=2)
;mmn = min(marr,dimension=2,/nan)
;mmx = max(marr,dimension=2,/nan)
;toc
;
;pmm, me-mme
;pmm, md-mmd
;pmm, sm-msm
;pmm, sd-msd
;pmm, mn-mmn
;pmm, mx-mmx 

p, 'Can we add "dimension" to stats???'
stop


str = []
tic
for i=0, arrsz-1 do begin
  if i mod 1000 eq 0 then pof, i, arrsz, /nopro 
;  sar = double(arr(i,*))
;  if odd(i) then sar(*) = missings(sar)
;  stat = stats(sar)
  str = [str,stats(arr[i,*])]
endfor


toc
p, 'array size = ' + num2str(arrsz)
p, 'n files = ' + num2str(nfiles)

stop






end