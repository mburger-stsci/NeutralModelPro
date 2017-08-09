closewin
npack = 1000000
arange = [60., 90]*!dtor
savefile = 'AngularDist.60_90.png'
aa = sin(arange)

;; Isotropic dist
sinalt = random_nr(seed=seed, npack) * (aa[1]-aa[0]) + aa[0]
alt0 = asin(sinalt)/!dtor

;; cos theta dist
n = 1
sinalt = dindgen(1001)/1000. * (aa[1]-aa[0]) + aa[0]
f_sinalt = sinalt^n
sinalt = RandomDeviates_1d(sinalt, f_sinalt, npack)
alt1 = asin(sinalt)/!dtor

n = 0.5
sinalt = dindgen(1001)/1000. * (aa[1]-aa[0]) + aa[0]
f_sinalt = sinalt^n
sinalt = RandomDeviates_1d(sinalt, f_sinalt, npack)
alt2 = asin(sinalt)/!dtor

n = 2
sinalt = dindgen(1001)/1000. * (aa[1]-aa[0]) + aa[0]
f_sinalt = sinalt^n
sinalt = RandomDeviates_1d(sinalt, f_sinalt, npack)
alt3 = asin(sinalt)/!dtor

;;;;;
altitude = dindgen(1001)/1000. * (arange[1]-arange[0]) + arange[0]
f_alt = sin(altitude)
alt4 = RandomDeviates_1d(altitude, f_alt, npack)/!dtor

;;;;
h0 = histw(alt0, bin=1, min=0, max=89, xaxis=x0) & h0 /= max(h0)
g0 = h0/cos(x0*!dtor) & g0 /= max(g0)

h1 = histw(alt1, bin=1, min=0, max=89, xaxis=x0) & h1 /= max(h1)
g1 = h1/cos(x0*!dtor) & g1 /= max(g1)

h2 = histw(alt2, one(alt2), bin=1, min=0, max=89, xaxis=x0) & h2 /= max(h2)
g2 = h2/cos(x0*!dtor) & g2 /= max(g2)

h3 = histw(alt3, one(alt3), bin=1, min=0, max=89, xaxis=x0) & h3 /= max(h3)
g3 = h3/cos(x0*!dtor) & g3 /= max(g3)

h4 = histw(alt4, one(alt4), bin=1, min=0, max=89, xaxis=x0) & h4 /= max(h4)
g4 = h4/cos(x0*!dtor) & g4 /= max(g4)

p0 = plot(x0, h0, yrange=[0,1.1], xtitle='$\theta (\circ)$', $
  ytitle='$f(\theta)$', dimensions=[1000,600], font_size=20, thick=3, color='red', $
  layout=[2,1,1], xrange=[0,90], xmajor=4, xminor=2, margin=[.2,.15,.1,.1], $
  name='Isotropic')
p1 = plot(/overplot, x0, h1, color='blue', thick=3, name='$cos \theta$')
p2 = plot(/overplot, x0, h2, color='forest_green', thick=3, name='$cos^{0.5} \theta$')
p3 = plot(/overplot, x0, h4, color='dark_violet', thick=3, name='plumelike')

leg = legend(target=[p0,p2,p1,p3], shadow=0, linestyle=' ', font_size=16, $
  /data, position=[25, 0.3])

o0 = plot(x0, g0, yrange=[0,1.1], xtitle='$\theta (\circ)$', $
  ytitle='$f(\theta)/cos(\theta)$', dimensions=[1000,600], font_size=20, thick=3, $
  color='red', margin=[.2,.15,.1,.1], $
  layout=[2,1,2], xrange=[0,90], xmajor=4, xminor=2, /current)
o1 = plot(/overplot, x0, g1, color='blue', thick=3)
o2 = plot(/overplot, x0, g2, color='forest_green', thick=3)
o3 = plot(/overplot, x0, g4, color='dark_violet', thick=3)
p0.save, savefile, width=1000

end

