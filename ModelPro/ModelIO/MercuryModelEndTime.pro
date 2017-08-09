function MercuryModelEndTime, atoms, taa

na = n_elements(atoms) & nt = n_elements(taa)
SystemConstants, 'Mercury', c
planet_dist2, taa, c, d=rr, v=vv

data = search_atomicdata()
result = dblarr(nt,na)
for i=0,na-1 do begin
  q = (where((data.mechanism EQ 'photo') and (data.species EQ atoms[i]), nq))[0]
  if (nq NE 1) then stop

  print, data[q].file
  restore, data[q].file
  if (n_elements(ratecoef.kappa) NE 1) then stop
  kappa = ratecoef.kappa / rr^2 
  life = 1./kappa
  result[*,i] = life * 4.
endfor

return, reform(result)

end
