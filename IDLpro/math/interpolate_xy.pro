function interpolate_xy, z, x, y, xpts, ypts, _extra=e

q = where(finite(z) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(x) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(y) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(xpts) EQ 0, nq) & if (nq NE 0) then stop
q = where(finite(ypts) EQ 0, nq) & if (nq NE 0) then stop

xind = interpol(dindgen(n_elements(x)), x, xpts)
yind = interpol(dindgen(n_elements(y)), y, ypts)

result = interpolate(z, xind, yind, _extra=e)

return, result

end

