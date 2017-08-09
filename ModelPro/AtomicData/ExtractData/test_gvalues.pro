closewin

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2009.5891.gvalue.sav.old'
g0 = temporary(gvalue)

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2015.5891.gvalue.sav'
g1 = temporary(gvalue)

p0 = plot(*g1.v, *g1.g, thick=3, xtitle='Radial Velocity (km s$^{-1}$)', $
  ytitle='g (phot s$^{-1}$)', title='Na D$_2$ g-values at 1 AU', font_size=20, $
  dimensions=[1000,1000], layout=[2,2,1], margin=[.2,.15,.1,.1])
p1 = plot(/overplot, *g0.v, *g0.g, color='red', thick=3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2009.5897.gvalue.sav.old'
g0 = temporary(gvalue)
q = where(*g0.g EQ 0, comp=w)
(*g0.g)[q] = interpol((*g0.g)[w], (*g0.v)[w], (*g0.v)[q])

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Na/Na.Killen2015.5897.gvalue.sav'
g1 = temporary(gvalue)

p2 = plot(*g1.v, *g1.g, thick=3, xtitle='Radial Velocity (km s$^{-1}$)', $
  ytitle='g (phot s$^{-1}$)', title='Na D$_1$ g-values at 1 AU', font_size=20, $
  /current, layout=[2,2,2], margin=[.2,.15,.1,.1])
p3 = plot(/overplot, *g0.v, *g0.g, color='red', thick=3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Ca/Ca.Killen2009.4227.gvalue.sav.old'
g0 = temporary(gvalue)

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Ca/Ca.Killen2015.4227.gvalue.sav'
g1 = temporary(gvalue)

p4 = plot(*g1.v, *g1.g, thick=3, xtitle='Radial Velocity (km s$^{-1}$)', $
  ytitle='g (phot s$^{-1}$)', title='Ca g-values at 1 AU', font_size=20, $
  /current, layout=[2,2,3], margin=[.2,.15,.1,.1])
p5 = plot(/overplot, *g0.v, *g0.g, color='red', thick=3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Mg/Mg.Killen2009.2852.gvalue.sav.old'
g0 = temporary(gvalue)

restore, '~/NeutralExosphereAndCloudModel/trunk/Data/AtomicData/g-values/Mg/Mg.Killen2015.2852.gvalue.sav'
g1 = temporary(gvalue)

p6 = plot(*g1.v, *g1.g, thick=3, xtitle='Radial Velocity (km s$^{-1}$)', $
  ytitle='g (phot s$^{-1}$)', title='Mg G-values at 1 AU', font_size=20, $
  /current, layout=[2,2,4], margin=[.2,.15,.1,.1])
p7 = plot(/overplot, *g0.v, *g0.g, color='red', thick=3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p0.save, '~/Desktop/g-values.png', width=WindowWidth(p0)


end
