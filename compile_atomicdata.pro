retall
;; This compiles the functions used to maintain the atomic data. These functions are not
;; used to when actually running the model.

modelpath =  !model.basepath + 'ModelPro/'

files = ['AtomicData/set_default_reactions', $
  'AtomicData/rate_integral', $
  'AtomicData/make_crosssec_struct', $
  'AtomicData/make_ratecoef_struct', $
  'AtomicData/ExtractData/extract_Killen2009_gvalues', $
  'AtomicData/ExtractData/extract_Huebner']

openw, 1, 'comp_adata.pro'
for i=0,n_elements(modelfiles)-1 do printf, 1, '.compile ' + modelpath + files[i]
close, 1

print, '**** Compiling AtomicData ****'
@comp_adata
spawn, 'rm comp_adata.pro'

