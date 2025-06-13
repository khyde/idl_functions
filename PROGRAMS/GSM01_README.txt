README
-------

To run the original GSM01 model, 3 IDL codes are needed:

	gsm01_main.pro
	curvefit_sm.pro
	gsm01_model.pro

A test code (test_gsm01_model.pro ) and this README file are also provided to test for correct implementation.


The comments at the beginning of the main program (gsm01_main.pro) should tell you most of what you need to know to run the model.

A few (important) comments :

The parameters (i.e. constants) used by the model result from a global optimization based on the use of a large Case-1, non-polar data set. Although it may work well in other situations, the model is specifically designed for global scale applications with case-1, non-polar waters ! You may want/need to adapt the parameters in the model for it to work well in your region of interest. Keep also in mind that the model uses all available wavelengths so if any channel in the input data is corrupted, for whatever reason, the model retrievals will be affected.

This version of the model works for the SeaWiFS bands only but it can easily be adapted for the MODIS bands. Also, this version of the model was tuned using a data set that was not ideal for acdm(443) and bbp(443) as explained in the Maritorena et al. (2002) paper.ÊTheÊreference for this version of the model is :

Maritorena S., D.A. Siegel & A. Peterson. 2002. Optimization of a Semi-Analytical Ocean Color Model for Global Scale Applications. Applied Optics 41(15): 2705-2714.

I would appreciate if you could keep me posted on how good/bad are the results you are getting with your data when using GSM01 and please let me know of any papers where results using the model are presented.

Should you have any question/problem, just let me know (stephane@icess.ucsb.edu)

Sincerely,

Stephane Maritorena



Running the test script should do the following :

IDL> test_gsm01_model
% Compiled module: TEST_GSM01_MODEL.
Chl  acdm(443)  bbp(443)  Conv.     3.1910      0.072725      0.004901  1
Chl  acdm(443)  bbp(443)  Conv.     1.1940      0.035298      0.002694  1
Chl  acdm(443)  bbp(443)  Conv.     0.3779      0.014450      0.001459  1
Chl  acdm(443)  bbp(443)  Conv.     0.1489      0.008089      0.001103  1
Chl  acdm(443)  bbp(443)  Conv.     0.1416      0.006945      0.001263  1
Chl  acdm(443)  bbp(443)  Conv.     0.1844      0.009604      0.001105  1
Chl  acdm(443)  bbp(443)  Conv.     0.1143      0.007713      0.001320  1
Chl  acdm(443)  bbp(443)  Conv.     0.0862      0.006817      0.001221  1
Chl  acdm(443)  bbp(443)  Conv.     0.0590      0.003771      0.001214  1
Chl  acdm(443)  bbp(443)  Conv.     0.0480      0.004118      0.001397  1
Chl  acdm(443)  bbp(443)  Conv.     0.0669      0.001645      0.001208  1=
