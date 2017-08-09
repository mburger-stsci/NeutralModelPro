function ionization_rate, loc, input, magcoord

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compute the ionozation rate of the species due to each possible process
;;
;; Version History
;; 3.3: 12/13/2010
;;   * rewriting with new kappa structure
;; 3.2: 7/21/2010
;;   * rewritten with new structure architecture
;; 3.1: 4/26/10
;;   * Added support for Earth (photoionization only)
;;   * Added check for moon's shadow -- before only checked to see if the packet 
;;     was in the planet's shadow
;; 3.0: original based on neutlt
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common ratecoefs

if (input.options.lifetime GT 0) $    ;;; Explicitly set 
  then rate = 1./replicate(input.options.lifetime, n_elements(*loc.t)) $ 
  else begin
    num = n_elements(*loc.t)
    
    ;; Get plasma parameters
    dotherm = 0
    doener = 0
    case (input.geometry.planet) of 
      'Mercury': 
      'Earth': 
      'Mars': 
      'Jupiter': begin
	JupiterPlasma, loc, *magcoord.M, *magcoord.zeta, input.plasma_info, $
	  *magcoord.lam, ElecTherm=ElecTherm, ElecEner=ElecEner, IonTherm=IonTherm
	dotherm = 1 & doener = 1
	end
      'Saturn': begin
	SaturnPlasma, *magcoord.M, *magcoord.zeta, ElecTherm=ElecTherm, $
	  IonTherm=IonTherm, ElecEner=ElecEner
	dotherm = 1
	doener = 0
	end
      else: stop
    endcase

    chxrate = dblarr(num) 

    ;; Compute photo-loss rate
    if (kappa.photo) then begin
      if (n_elements(*magcoord.out_of_shadow) NE num) then stop
      photorate = double(*magcoord.out_of_shadow * *kappa.kappa_photo)
      ;;photorate = double(*kappa.kappa_photo*abs(*loc.x))
    endif else photorate = dblarr(num)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Compute electron impact rate
    eimprate = dblarr(num)
    if ((kappa.eimp) and (dotherm)) then begin
      K = loginterpol(*kappa.kappa_ei, *kappa.t_e, *ElecTherm.t_e)
      w = where((*ElecTherm.n_e GE 0) and (K GT 0), ctw)
      if (ctw NE 0) then eimprate[w] = (*ElecTherm.n_e)[w] * K[w] 
      destroy_structure, ElecTherm
    endif

    if ((kappa.eimp) and (doener)) then begin
      K = loginterpol(*kappa.kappa_ei, *kappa.t_e, *ElecEner.t_e)
      w = where((*ElecEner.n_e GE 0) and (K GT 0), ctw)
      if (ctw NE 0) then eimprate[w] += (*ElecEner.n_e)[w] * K[w] 
      destroy_structure, ElecEner
    endif
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; Compute charge exchange rate
    if (kappa.chx) then begin
      ;; Calculate relative velocity
      Bvx = -DipoleConsts.magrat * (*loc.x)[*,1]
      Bvy = DipoleConsts.magrat * (*loc.x)[*,0]
      vrel = (sqrt(((*loc.v)[*,0]-Bvx)^2 + ((*loc.v)[*,1]-Bvy)^2 + (*loc.v)[*,2]^2)) $ 
	* SystemConsts.rplan
      q = where(vrel GT max(*kappa.v_rel), nq)
      if (nq NE 0) then vrel[q] = max(*kappa.v_rel)
      q = where(vrel LT min(*kappa.v_rel), nq)
      if (nq NE 0) then vrel[q] = min(*kappa.v_rel)
  
      ;; Compute the rate
      for kk=0,n_elements(kappa.ions)-1 do chxrate += (*IonTherm.n_i)[*,kk] * $
	interpolate_xy((*kappa.kappa_chx)[*,*,kk], *kappa.t_i, *kappa.v_rel, $
	(*IonTherm.t_i)[*,kk], vrel)
      destroy_structure, IonTherm
    endif

    rate = photorate + eimprate + chxrate
    q = where(rate EQ 0, nq) & if (nq NE 0) then rate[q] = 1d-30
  endelse

;Return the lifetimes
q = where(finite(rate) EQ 0, nq) & if (nq NE 0) then stop
q = where(rate LT 0, nq) & if (nq NE 0) then stop
return, rate

end

