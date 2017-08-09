function plot_data_models, data0, models, filename=filename, title=title, $
  modelnames=modelnames

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; black = good data
;; yellow = low S/N
;; magenta = scattered
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

onum = (*data0.orbit)[0]
if (yst EQ !null) then yst=0

if (models EQ !null) $
  then nmod = 0 $
  else begin
    sz = size(models)
    nmod = (sz[0] EQ 1) ? 1 : sz[2]
  endelse

if (title EQ !null) then title = orbit_string(onum)
ii = indgen(n_elements(*data0.radiance))

doleg = 0
if ((n_elements(modelnames) EQ nmod) and (nmod GT 0)) then doleg = 1 

q = where(*data0.quality EQ 0)
p0 = plot(ii[q], (*data0.radiance)[q], dimensions=[1600,800], linestyle=' ', $
  /sym_filled, symbol='o', xtitle='Spectrum #', ytitle='Radiance (kR)', $
  font_size=20, buffer=(filename NE !null), title=title, position=[.1,.1,.75,.9], $
  xrange=[0,n_elements(*data0.radiance)])
yr = p0.yrange
p0a = plot(ii, *data0.radiance, /overplot, linestyle=' ', symbol='o', /sym_filled, $
  color='magenta')
p0.refresh, /disable
q = where(*data0.quality EQ 1, nq)
if (nq GT 0) then p1 = plot(ii[q], (*data0.radiance)[q], /overplot, linestyle=' ', $
  symbol='o', /sym_filled, color='yellow')
q = where(*data0.quality EQ 3, nq)
if (nq GT 0) then p1 = plot(ii[q], (*data0.radiance)[q], /overplot, linestyle=' ', $
  symbol='o', /sym_filled, color='cyan')
q = where(*data0.quality EQ 0, nq)
if (nq GT 0) then p2 = errorplot(ii[q], (*data0.radiance)[q], (*data0.sigma)[q], $
  /overplot, linestyle=' ', symbol='o', /sym_filled)
p0.yrange = yr

a = [.25, .5, .75]*n_elements(*data0.radiance)
for i=0,2 do p0a = plot([a[i],a[i]], p0.yrange, /overplot, linestyle=':')

if (nmod GT 0) then p3 = objarr(nmod)
for i=0,nmod-1 do p3[i] = plot(/overplot, ii, models[*,i], color=color(i+2), thick=3, $
  name=modelnames[i])

l0 = text(/device, 1100, 660, align=.5, font_size=20, $
  'TAA = ' + strint(round(mean(*data0.taa/!dtor))) + '$\circ$')

if (doleg) then l1 = legend(target=p3, /auto_text_color, /device, $
  position=[1125,650], linestyle=' ', shadow=0, font_size=20, sample_width=0)

kk = p0.ConvertCoord(p0.xrange, p0.yrange, /data, /to_device)
jj = p0.ConvertCoord(kk[0,0], kk[1,1]-5, /device, /to_data)
yr = p0.yrange

;; Plot obstype color
ct = 0 
while (ct LT n_elements(*data0.radiance)-1) do begin
  q0 = ct
  while ((*data0.obstype_num)[ct] EQ (*data0.obstype_num)[q0]) and $
    (ct LT n_elements(*data0.radiance)-1) do ct++

  l2 = plot(/overplot, [q0,ct-1], [jj[1],jj[1]], thick=25, $
    color=color((*data0.obstype_num)[q0]))
endwhile

p0.yrange = yr

;; plot tangent point radius
p3 = plot(/current, ii, *data0.rtan, linestyle=' ', symbol='o', /sym_filled, $
  color='magenta', position=[.76,.653,.95,.9], title='Tangent Point Radius', $
  xshowtext=0, yshowtext=0, xrange=[0,n_elements(*data0.radiance)], sym_size=0.5, $
  yrange=[0,max(*data0.rtan)])
q = where(*data0.quality EQ 1, nq)
if (nq GT 0) then p3a = plot(/overplot, ii[q], (*data0.rtan)[q], linestyle=' ', $
  symbol='o', /sym_filled, color='yellow', sym_size=0.5)
q = where(*data0.quality EQ 3, nq)
if (nq GT 0) then p3b = plot(/overplot, ii[q], (*data0.rtan)[q], linestyle=' ', $
  symbol='o', /sym_filled, color='cyan', sym_size=0.5)
q = where(*data0.quality EQ 0, nq)
if (nq GT 0) then p3c = plot(/overplot, ii[q], (*data0.rtan)[q], linestyle=' ', $
  symbol='o', /sym_filled, sym_size=0.5)
a3 = axis('Y', location=[n_elements(*data0.radiance),0], title='Radius (R$_M$)', $
  /textpos, /data, /tickdir, target=p3)
p3d = plot(/overplot, [0,n_elements(*data0.radiance)], [1,1], linestyle='--')
for i=0,2 do p3e = plot([a[i],a[i]], p3.yrange, /overplot, linestyle=':')
  
;; plot tangent point local time
p4 = plot(/current, ii, *data0.loctimetan, linestyle=' ', symbol='o', /sym_filled, $
  color='magenta', position=[.76,.376,.95,.623], title='Tangent Point Local Time', $
  xshowtext=0, yshowtext=0, yrange=[0,24], xrange=[0,n_elements(*data0.radiance)], $
  sym_size=0.5, ymajor=5, yminor=5)
a4 = axis('Y', location=[n_elements(*data0.radiance), 0], title='Local Time (hr)', $
  /textpos, /data, target=p4, major=5, minor=5, /tickdir)
q = where(*data0.quality EQ 1, nq)
if (nq GT 0) then p4a = plot(/overplot, ii[q], (*data0.loctimetan)[q], linestyle=' ', $
  symbol='o', /sym_filled, color='yellow', sym_size=0.5)
q = where(*data0.quality EQ 3, nq)
if (nq GT 0) then p4b = plot(/overplot, ii[q], (*data0.loctimetan)[q], linestyle=' ', $
  symbol='o', /sym_filled, color='cyan', sym_size=0.5)
q = where(*data0.quality EQ 0, nq)
if (nq GT 0) then p4c = plot(/overplot, ii[q], (*data0.loctimetan)[q], linestyle=' ', $
  symbol='o', /sym_filled, sym_size=0.5)
p4d = plot(/overplot, [0,n_elements(*data0.radiance)], [6,6], linestyle='--')
p4e = plot(/overplot, [0,n_elements(*data0.radiance)], [18,18], linestyle='--')
for i=0,2 do p4e = plot([a[i],a[i]], p4.yrange, /overplot, linestyle=':')

;; plot tangent latitude
p5 = plot(/current, ii, (*data0.lattan)[0,*]/!dtor, linestyle=' ', symbol='o', $
  /sym_filled, color='magenta', position=[.76, .1, .95, .347], $
  title='Tangent Point Latitude', yshowtext=0, yrange=[-90,90], sym_size=0.5, $
  xrange=[0,n_elements(*data0.radiance)], ymajor=5, yminor=8, $
  xtitle='Specutrm #')
a5 = axis('Y', location=[n_elements(*data0.radiance),0], title='Latitude ($\circ$)', $
  /textpos, /data, target=p5, major=5, minor=8)
q = where(*data0.quality EQ 1, nq)
if (nq GT 0) then p5a = plot(/overplot, ii[q], (*data0.lattan)[0,q]/!dtor, $
  linestyle=' ', symbol='o', /sym_filled, color='yellow', sym_size=0.5)
q = where(*data0.quality EQ 3, nq)
if (nq GT 0) then p5b = plot(/overplot, ii[q], (*data0.lattan)[0,q]/!dtor, $
  linestyle=' ', symbol='o', /sym_filled, color='cyan', sym_size=0.5)
q = where(*data0.quality EQ 0, nq)
if (nq GT 0) then p5c = plot(/overplot, ii[q], (*data0.lattan)[0,q]/!dtor, $
  linestyle=' ', symbol='o', /sym_filled, sym_size=0.5)
p5d = plot(/overplot, [0,n_elements(*data0.radiance)], [0,0], linestyle='--')
for i=0,2 do p5e = plot([a[i],a[i]], p5.yrange, /overplot, linestyle=':')

p0.refresh

if (filename NE !null) then begin
  p0.save, filename, width=WindowWidth(p0)
  p0.close
endif else p0.select

return, p0

end

