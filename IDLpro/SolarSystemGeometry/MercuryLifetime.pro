function MercuryLifetime, atom, taa

planet_distance, taa, 'Mercury', d=rr, v=vv

data = search_atomicdata()
life = fltarr(n_elements(taa))

q = (where((data.mechanism EQ 'photo') and (data.species EQ atom), nq))[0]
if (nq NE 1) then stop

print, data[q].file
restore, data[q].file
if (n_elements(ratecoef.kappa) NE 1) then stop
kappa = ratecoef.kappa / rr^2 
life = 1./kappa

return, life

end
