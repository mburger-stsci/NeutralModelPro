refpt = 0.352

readcol, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/NaD1_gval_24.txt', $
  wave, g, format='F,F', /silent

g *= refpt^2
s = sort(wave)
wave = wave[s] & g = g[s]

gvalue = {species:'Na', wavelength:5897., a:1., v:ptr_new(wave), g:ptr_new(g), $
  reference:'Killen 2015'}
save, gvalue, file='~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2015.5897.gvalue.sav'

;;;;;;;;;;;;;;;;;;;

readcol, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/NaD2_gval_24.txt', $
  wave, g, format='F,F', /silent
g *= refpt^2
s = sort(wave)
wave = wave[s] & g = g[s]

gvalue = {species:'Na', wavelength:5891., a:1., v:ptr_new(wave), g:ptr_new(g), $
  reference:'Killen 2015'}
save, gvalue, file='~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2015.5891.gvalue.sav'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readcol, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Ca/Ca_gval_24.txt', $
  wave, g, format='F,F', /silent
g *= refpt^2
s = sort(wave)
wave = wave[s] & g = g[s]

gvalue = {species:'Ca', wavelength:4227., a:1., v:ptr_new(wave), g:ptr_new(g), $
  reference:'Killen 2015'}
save, gvalue, file='~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Ca/Ca.Killen2015.4227.gvalue.sav'

;;;;;;;;;;;;;;;;;;;;;;;;;;

readcol, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Mg/Mg_gval_24.txt', $
  wave, g, format='F,F', /silent
g *= refpt^2
s = sort(wave)
wave = wave[s] & g = g[s]

gvalue = {species:'Mg', wavelength:2852., a:1., v:ptr_new(wave), g:ptr_new(g), $
  reference:'Killen 2015'}
save, gvalue, file='~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Mg/Mg.Killen2015.2852.gvalue.sav'

end
