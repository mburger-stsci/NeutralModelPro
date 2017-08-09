pro SaturnPlasma, Lshell, maglat, loss_info, ElecTherm=ElecTherm, IonTherm=IonTherm, $
  ElecEner=ElecEner

common constants
common ratecoefs
common plasma

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  
;;  OUTPUTS:
;;    ElecTherm: state of the thermal electrons
;;    IonTherm: state of thermal ions
;;    ElecEner: state of the energetic electrons
;;    IonEner: state of energetic ions
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

num = n_elements(Lshell)

eimp = strcmp(coef_eimp.type, 'Electron Impact', /fold_case)
chx = strcmp(coef_chx.type, 'Ion-Neutral', /fold_case)

;; NOTE: Only cool ions and electrons are included for Saturn
;; indices for grid interpolation -- needed to find densities
xind = interpol(findgen(n_elements(*plasma.L)), *plasma.L, Lshell)
yind = interpol(findgen(n_elements(*plasma.latitude)), *plasma.latitude, maglat)
badL = where((Lshell LT min(*plasma.L)) or (Lshell GT max(*plasma.L)), nl) 

;;;;;;;;;;;;;;;;;
;; State of electrons 
if (eimp) then begin
  elecden = interpolate(*plasma.elecden, xind, yind)
  q = where(elecden LT 0, nq) & if (nq NE 0) then elecden[q] = 0.

  electemp = interpol(*plasma.electemp, *plasma.L, Lshell)
  q = where(electemp LE 0.01, nq) & if (nq NE 0) then electemp[q] = 0.01

  if (nl NE 0) then begin
    elecden[badl] = 0.
    electemp[badl] = 0.01
  endif
  ElecTherm = {n_e:ptr_new(elecden), t_e:ptr_new(electemp)}
  ElecEner = {n_e:ptr_new(-1), t_e:ptr_new(-1)}
endif

;;;;;;;;;;;;;;;;;;
;; State of the ions
;; Currently have info for H+ and W+
if (chx) then begin
  nion = n_elements(*coef_chx.ion)
  ThermDen = fltarr(num, nion)
  ThermTemp = fltarr(num, nion)
  for i=0,nion-1 do begin
    case ((*coef_chx.ion)[i]) of
      'H+': begin
	w = (where(*plasma.ions EQ 'H+'))[0]
	ThermDen[*,i] = interpolate((*plasma.ionden)[*,*,w], xind, yind) ;; Protons
	ThermTemp[*,i] = interpol((*plasma.iontemp)[*,w], *plasma.L, Lshell)
	end
      'H_2O+': begin
	w = (where(*plasma.ions EQ 'W+'))[0]
	ratio = interpol((*plasma.ratio)[*,0], *plasma.L, Lshell)
	ThermDen[*,i] = interpolate((*plasma.ionden)[*,*,w], xind, yind)*ratio ;; W+
	ThermTemp[*,i] = interpol((*plasma.iontemp)[*,w], *plasma.L, Lshell)
	end
      'O+': begin
	w = (where(*plasma.ions EQ 'W+'))[0]
	ratio = interpol((*plasma.ratio)[*,1], *plasma.L, Lshell)
	ThermDen[*,i] = interpolate((*plasma.ionden)[*,*,w], xind, yind)*ratio ;; W+
	ThermTemp[*,i] = interpol((*plasma.iontemp)[*,w], *plasma.L, Lshell)
	end
      'OH+': begin
	w = (where(*plasma.ions EQ 'W+'))[0]
	ratio = interpol((*plasma.ratio)[*,2], *plasma.L, Lshell)
	ThermDen[*,i] = interpolate((*plasma.ionden)[*,*,w], xind, yind)*ratio ;; W+
	ThermTemp[*,i] = interpol((*plasma.iontemp)[*,w], *plasma.L, Lshell)
	end
      'H_3O+': begin
	w = (where(*plasma.ions EQ 'W+'))[0]
	ratio = interpol((*plasma.ratio)[*,3], *plasma.L, Lshell)
	ThermDen[*,i] = interpolate((*plasma.ionden)[*,*,w], xind, yind)*ratio ;; W+
	ThermTemp[*,i] = interpol((*plasma.iontemp)[*,w], *plasma.L, Lshell)
	end
      else:stop
    endcase
  endfor
  hq = where(ThermDen LE 0, hct) & if (hct NE 0) then ThermDen[hq] = 0 
  hq = where(ThermTemp LE 0.01, hct) & if (hct NE 0) then ThermTemp[hq] = 0.01 

  if (nl NE 0) then begin
    ThermDen[badl,*] = 0.
    ThermTemp[badl,*] = 0.01
  endif
  IonTherm = {ions:ptr_new(*coef_chx.ion), n_i:ptr_new(ThermDen), $
    t_i:ptr_new(thermtemp)}
endif

end

