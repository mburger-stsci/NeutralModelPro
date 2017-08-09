closewin
npack = 100000L

vv = findgen(10001)/10000.*10-5
g = gaussiandist(vv, 0., 1.)
sumdist = g
for i=1,n_elements(g)-1 do sumdist[i] += sumdist[i-1]
sumdist /= max(sumdist)

f1 = RandomDeviates_1d(vv, g, npack)
h1 = histw(f1, bin=.01, xaxis=x0) & h1 /= mean(h1[where(abs(x0) EQ min(abs(x0)))])

yy = random_nr(10)
xx = interpol(vv, sumdist, yy, /spline)

p0 = plot(vv, g, dimensions=[1000,500], layout=[2,1,1], xtitle='x', $
  ytitle='f(x)', font_size=20, margin=[.3,.2,.05,.1], thick=3, $
  title='Probability Fn.', yrange=[0,1.1])
q0 = plot(x0, h1, color='red', /overplot)

p1 = plot(vv, sumdist, /current, layout=[2,1,2], xtitle='x', $
  ytitle='F(x)', font_size=20, margin=[.3,.2,.05,.1], thick=3, $
  title='Cumulative Fn.', yrange=[0,1.1])
for i=0,0 do begin
  p2 = plot([min(vv),xx[i]], [yy[i],yy[i]], color='red', linestyle='--', thick=3, $
    /overplot)
  p3 = plot([xx[i],xx[i]], [0,yy[i]], color='red', linestyle='--', thick=3, /overplot)
  p4 = plot([xx[i]], [yy[i]], symbol='o', /sym_filled, /overplot, color='red')
  print, yy[i], xx[i]
endfor

t0 = text(/normal, 0.01, 0.92, '(a)', font_size=20)
t1 = text(/normal, 0.51, 0.92, '(b)', font_size=20)

p0.save, 'probdist.pdf'

end


