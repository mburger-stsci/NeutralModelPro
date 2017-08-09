function plotsquare2, xx, yy, _extra=e 

pp = plot(/overplot, [xx[0],xx[0],xx[1],xx[1],xx[0]], [yy[0],yy[1],yy[1],yy[0],yy[0]], $
  _extra=e)

return, pp

end
