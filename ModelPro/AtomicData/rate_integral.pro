function rate_integral, type, temperature=temperature, u=u, species1=species1, $
  species2=species2, sigma=sigtemp, energy=entemp, minvth=minvth, vrel=vtemp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Determine the rate coefficient as function of electron/ion temperature
;;  Inputs:
;;    type: "electron impact" or "ion-neutral"
;;  
;;  If electron impact, then need to specify:
;;    temperature 
;;    energy & sigma(energy) -- reaction cross section vs. energy
;;
;;  if ion-neutral -- stop
;;
;;    temperature: energy range to determine rate coefficeint
;;    u: relative ion-neutral speed [km/s]
;;    sigen: energy range for which cross-sections are available in the center
;;      of mass frame
;;    tempsigma: cross section as function of sigenergy
;;  
;;  Keywords: 
;;    res=0-4: resolution to use for computing the integral
;;    minvth=minvth: if vth < minvth, then the distribution is assumed to be a delta fn
;;
;;  Computes the integral:
;;    nu = int (v-u) sigma(v-u) f(v-u) d^3 v
;;  where u = flow speed, f(v) is a Maxwelllian and sigma is the cross section
;;  
;;  Reactants are ion + neutral where the neutral is assumed stationary and ion 
;;  has speed u
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

minvth = 1000.
case strlowcase(type) of 
  'electron impact': begin
    ;; If electron impact ionization, then need to integrate 
    ;;   kappa = int(sigma * v^3 * exp(-mv^2/2kT)) dv
    ;; or 
    ;;   kappa = int(sigma * E * exp(-E/kT)) dE
    ;; Note 9/15/08 -- Checked once again that these to equations are equivalent.
    ;;   see notes RateCoefficients.pages for the math.

    ;; Remove any place where sigma < 0
    q = where(sigtemp GE 0) 
    sigma = sigtemp[q]
    energy = entemp[q]

    en = dindgen(round(max(energy))+1) & en[0] = .01
    sig = interpol(sigma, energy, en)
    q = where(sig LE 0, nq) & if (nq NE 0) then sig[q] = 0.
    w = where(finite(sig) EQ 1)
    en = en[w]
    sig = sig[w]

    ratecoef = dblarr(n_elements(temperature))
    constant = 8*!pi/!physconst.me^2 * $
      (!physconst.me/(2*!pi*temperature*!physconst.erg_ev))^1.5
    for i=0,n_elements(temperature)-1 do ratecoef[i] = constant[i] * $
      int_tabulated(en*!physconst.erg_eV, en*!physconst.erg_eV * sig * $
      exp(-en/temperature[i]), /double)
    end
  'ion-neutral': begin
    ;; Remove any place where sigma < 0
    q = where(sigtemp GE 0) 
    sigma = sigtemp[q]
    vrel = vtemp[q]

    sig = interpol(sigma, vrel, u)
    q = where(sig LE 0, nq) & if (nq NE 0) then sig[q] = 0.

    ratecoef = dblarr(n_elements(temperature),n_elements(u))

    ;; integral is performed using int_3d
    pts = 96;
    m2 = atomicmass(species2)
    for i=0,n_elements(temperature)-1 do begin
      for j=0,n_elements(u)-1 do begin
	uu = u[j]*1d5  ;; cm/s
	kT  = temperature[i] * !physconst.erg_eV
	vth = sqrt(2*kT/m2)
	if (vth GT minvth)  then begin
	  c1 = (m2/2/!pi/kT)^1.5   ;; do the full integral if vth gt 1 km/s
	  ratecoef[i,j] = int_3d('rate_func', [uu-10*vth,uu+10*vth], 'rate_ylimits', $
	    'rate_zlimits', pts, /double) 
	endif else begin  ;; 
	  print, temperature[i], vth
	  print, 'v LT minvth'
	  ss = sig[j] ;; loginterpol(sigma, vrel, uu)
	  ratecoef[i,j] = uu * ss
	endelse
      endfor
      print, i, j
   endfor
    end
  else: ratecoef = -1
endcase

w = where(finite(ratecoef) EQ 0, nw) & if (nw NE 0) then stop
return, ratecoef

end

