function results_packet_weighting, output, out_of_shadow, pts0

common constants
common results

case (format.quantity) of
  'column': weight = *output.frac * stuff.atoms_per_packet ;; atoms per packet
  'density': weight = *output.frac * stuff.atoms_per_packet
  'intensity': begin
    if (max(strcmp(format.emission.mechanism, 'resscat', /fold))) then begin
      ;; trim min and max vy_sun values
      w = where(*output.radvel_sun LT min(*gvalue.v), nw)
      if (nw NE 0) then (*output.radvel_sun)[w] = min(*gvalue.v)
      w = where(*output.radvel_sun GT max(*gvalue.v), nw)
      if (nw NE 0) then (*output.radvel_sun)[w] = max(*gvalue.v)

      ;; sum g-value over observed lines
      gg = 0.
      for j=0,n_elements(format.emission.line)-1 do begin
	w = (where(abs(*gvalue.wavelength-(format.emission.line)[j]) LE $
	  1e-2, nw))[0]
	if (nw NE 1) then stop
	gg += interpol((*gvalue.g)[*,w], *gvalue.v, $
	  *output.radvel_sun)  
      endfor

      ;; Compute emission measure for each packet
      weight_resscat = (*output.frac*stuff.atoms_per_packet) * out_of_shadow * $
	(gg/1e6) ;; Ra
      ;; gg/1e6 = 10^6 photons/atom/sec
      ;; *output.frac * atoms_per_packet = atoms
      ;; f_resscat = 10^6 hotons/sec
    endif else weight_resscat = 0.

    ;; Compute electron impact emission
    if (total(strcmp(format.emission.mechanism, 'eimp', /fold))) then begin
      ;; Determine plasma state for each packet
      loc = {t:ptr_new(0), x:ptr_new(0), v:ptr_new(0), frac:ptr_new(0)}
      *loc.x = pts0
      *loc.frac = *output.frac
      *loc.t = dblarr(n_elements(*output.x)) 
      magcoord = xyz_to_magcoord(loc, input)
      case (input.geometry.planet) of 
	'Mercury': weight_eimp = 0.
	'Jupiter': begin
	  n_e = interpol(*plasma.n_e, *plasma.L, *magcoord.M)
	  t_e = interpol(*plasma.t_e, *plasma.L, *magcoord.M)
	  H = interpol(*plasma.h_e, *plasma.L, *magcoord.M)

	  hq = where(n_e LE 0, hct) & if (hct NE 0) then n_e[hq] = 0.
	  hq = where(t_e LE 0.01, hct) & if (hct NE 0) then t_e[hq] = 0.01
	  hq = where(H LE .1, hct)  & if (hct NE 0) then H[hq] = .1

	  q = where(*magcoord.M GT max(*plasma.L), nq)
	  if (nq NE 0) then begin
	    t_e[q] = 0.01
	    H[q] = .1
	  endif

	  n_e = n_e * exp( -(*magcoord.zeta/H)^2 ) 
	  electrons = {n_e:ptr_new(n_e), t_e:ptr_new(t_e)}
	  end
	else: stop
      endcase

      kappa = loginterpol(*ratecoef.kappa, *ratecoef.t_e, *electrons.t_e)
      weight_eimp = (*output.frac*stuff.atoms_per_packet)*(*electrons.n_e)*kappa/1e6 ;Ra 
    endif else weight_eimp = 0.

    ;; Sum emission measures for each process
    weight = weight_resscat + weight_eimp 
    end
  'spectrum': stop
  else: stop
endcase

if (n_elements(weight) NE n_elements(*output.x)) then stop
q = where(finite(weight) EQ 0, nq) & if (nq NE 0) then stop

return, weight

end
