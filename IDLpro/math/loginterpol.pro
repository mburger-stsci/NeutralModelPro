function loginterpol, a, b, c

atemp = a
w = where(atemp LE 0)
if (w[0] NE -1) then atemp[w] = 1e-30

q = where((atemp GT 0) and (b GT 0))

result = 10.^interpol(alog10(atemp[q]), alog10(b[q]), alog10(c))
return, result

end
