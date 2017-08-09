function atomicnumber, species

sp2 = stregex(species, '[^\+]+', /extract)

defsysv, '!model', exists=e
file = ((e) ? !model.basepath : '$HOME/') + '/Work/Data/PhysicalData/periodictable.sav'
if (file_test(file)) then restore, file else stop

n = n_elements(sp2)
number = intarr(n)

for i=0,n-1 do begin
  q = (where(periodictable.sp EQ sp2[i], nq))[0]
  if (nq EQ 1) $
    then number[i] = (periodictable.anum)[q] $
    else begin
      print, sp2[i] + ' is not an element'
      number[i] = -1
    endelse
endfor
  
if (n EQ 1) then number = number[0]

return, number

end

