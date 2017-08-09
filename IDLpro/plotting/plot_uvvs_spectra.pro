pro plot_uvvs_spectra, data, spectra

o0 = plot(lindgen(n_elements(*data.radiance)), *data.radiance, dimensions=[1000,800], $
  thick=3, xtitle='Spectrum number', ytitle='Radiance (kR)', color='magenta', $
  symbol='o', /sym_filled, linestyle=' ', font_size=20)
q = where(*data.quality EQ 1, nq)
if (nq GT 0) then o1 = plot(/overplot, q, (*data.radiance)[q], symbol='o', /sym_filled, $
  linestyle=' ', color='yellow')
q = where(*data.quality EQ 0, nq)
o2 = plot(/overplot, q, (*data.radiance)[q], symbol='o', /sym_filled, linestyle=' ')
o3 = plot([0], [(*data.radiance)[0]], symbol='o', /sym_filled, sym_size=2, $
  /overplot, color='cyan')

;;;;;;;;;;;;;;;;;;;
p0 = plot(findgen(10), findgen(10), xrange=minmax(*spectra.wavelength), $
  thick=3, xtitle='Wavelength (nm)', ytitle='Counts', dimensions=[1000,800], $
  font_size=20)
p1 = plot(findgen(10), findgen(10), /overplot, thick=3, color='red')
p2 = plot(findgen(10), findgen(10), /overplot, thick=3, color='blue')
p3 = plot(minmax(*spectra.wavelength), [0,0], thick=3, /overplot)

;;;;;;;;;;;;;;;;;;;
for i=0,n_elements(*data.radiance)-1 do begin
  p0.refresh, /disable
  p0.setdata, (*spectra.wavelength)[*,i], (*spectra.raw)[*,i]-(*spectra.dark)[*,i]
  p1.setdata, (*spectra.wavelength)[*,i], (*spectra.solar)[*,i]
  p2.setdata, (*spectra.wavelength)[*,i], (*spectra.raw)[*,i]-(*spectra.dark)[*,i]-$
    (*spectra.solar)[*,i]
  p3.setdata, minmax(*spectra.wavelength), [0,0]
  p0.refresh

  o3.setdata, [i], [(*data.radiance)[i]]
  print, i, (*data.radiance)[i]
  click
endfor

end
