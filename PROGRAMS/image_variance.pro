function IMAGE_VARIANCE , image, halfWidth, MEAN=av_im,  $
        NEIGHBOURHOOD=NEIGHBOURHOOD,$
        POPULATION_ESTIMATE=POPULATION_ESTIMATE
;+
; NAME:
; IMAGE_VARIANCE
;
; PURPOSE:
;   This function calculates the local-neighbourhood statistical variance.I.e. for each array element a the variance
;   of the neighbourhood of +- halfwidth is calculated.
;  The routine avoids any loops and so is fast and "should" work for any dimension of array
;
; CATEGORY:
; Image Processing
;
; CALLING SEQUENCE:
;
; Result = IMAGE_VARIANCE(Image, HalfWidth)
;
; INPUTS:
; Image : the array of which we calculate the variance. Can be any dimension
;   HalfWidth:  the half width of the NEIGHBOURHOOD, indicates we are looking at a
;        neigborhood +/- N from the pixel in each dimension
;
; OPTIONAL INPUTS:
; Parm2: Describe optional inputs here. If you don't have any, just
;  delete this section.
;
; KEYWORD PARAMETERS:
;
; NEIGHBOURHOOD: calculate for the NEIGHBOURHOOD only not the central pixel.
;
; POPULATION_ESTIMATE: return the population estimate of variance, not the sample variance
;
; OUTPUT:
;  returns an array of same dimensions as input array in which each pixel represents the local variance centred at that position
;
; OPTIONAL OUTPUTS:
; MEAN_IM: set to array of local area mean, same dimensionality as input.
;
; RESTRICTIONS:
;    Edges are dealt with by replicating border pixels this is likely to give an underestimate of variance in these regions
;
; PROCEDURE:
;  Based on the formula for variance:
;  var = (sum of the squares)/n + (square of the sums)/n*n
;
; EXAMPLE:
; Example of simple statistical-based filter for removing spike-noise
;
;     var_im =  image_variance(image,  5, mean=mean_im, /neigh)
;     zim = (image-mim)/sqrt(var_im)
;     ids = where(zim gt 3, count)
;     if count gt 0 then image[ids] = mean_im[ids]
;
; MODIFICATION HISTORY:
;  Written by: Martin Downing, 30th September 2000
; m.downing@abdn.ac.uk
;Martin Downing,
;Clinical Research Physicist,
;Orthopaedic RSA Research Centre,
;Woodend Hospital,
;Aberdeen, AB15 6LS.
;m.downing@abdn.ac.uk
;-
 ; full mask size as accepted by SMOOTH()
 n = halfWidth*2+1

 ; this keyword to SMOOTH() is always set
 EDGE_TRUNCATE= 1
 ; sample size
    m = n^2
 ; temporary double image copy to prevent overflow
 im = double(image)
 ; calc average
 av_im = smooth(im, n, EDGE_TRUNCATE=EDGE_TRUNCATE)
 ; calc squares image
 sq_im = temporary(im)^2
 ; average squares
 asq_im = smooth(sq_im, n, EDGE_TRUNCATE=EDGE_TRUNCATE)

 if  keyword_set(NEIGHBOURHOOD) then begin
  ; remove centre pixel from estimate
  ; calc neighbourhood average (removing centre pixel)
  av_im = (av_im*m - image)/(m-1)
  ; calc neighbourhood average of squares (removing centre pixel)
  asq_im = (asq_im*m - temporary(sq_im))/(m-1)
  ; adjust sample size
   m = m-1
 endif

 var_im =  temporary(asq_im) - (av_im^2)
 if keyword_set(POPULATION_ESTIMATE) then begin
  var_im = var_im *( double(m)/(m-1))
 endif

 return, var_im

end




