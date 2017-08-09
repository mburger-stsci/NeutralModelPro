function lifetime_setup, input

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Set up the default reactions and plasma for use later 
;; Function returns loss_info which is only used to keep track of what 
;; reactions were used in running the model
;;
;; Version History
;;   3.1: 12/9/2010
;;     * new rate coeficient structure
;;   3.0: 7/19/2010
;;     * Rewriting with input structure
;;   2.4: 4/26/2010
;;     * Added option for Earth - photoionization only
;;   2.3: 9/14/2009
;;     * moved load_plasma section to separate program
;;   2.2: 5/27/2009
;;     * replaced GetReactionList with create_lossinfo
;;     * added Jupiter plasma
;;   2.1: 4/23/2009
;;     * For Mercury, changing the routine so that I can bock photoionization 
;;       in the shadow. Will keep the coef_photo structure and ionization rk5 will 
;;       call ionization_rate
;;   2.0: 10/22/2008 (MHB)
;;     * Routine created.
;;     * Need to add Jupiter plasma
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants
common ratecoefs
common plasma

;; Find the default reactions
restore, !model.basepath + 'Data/AtomicData/Defaults.Loss.sav'

;; Figure out which reactions to use
q = where(defaults.species EQ input.options.atom, nq)
if (nq EQ 0) then stop
loss_info = defaults[q]

pp = where(strcmp(loss_info.mechanism, 'photo', /fold), np) 
ie = where(strcmp(loss_info.mechanism, 'Electron Impact', /fold), nie)
in = where(strcmp(loss_info.mechanism, 'Ion-Neutral', /fold), nin)
case (input.geometry.planet) of 
  'Mercury': loss_info = reform(loss_info[pp]) ;; only use photoreactions for now
  'Earth': loss_info = reform(loss_info[pp]) ;; only use photoreactions for now
  'Mars': loss_info = reform(loss_info[pp]) ;; only use photoreactions for now
  else: begin ;; Load the plasma
    load_plasma, input.geometry.planet, input.plasma_info, plasma=plasma, $
      hotplasma=plasmahot
    ionlist = [*plasma.ions, *plasmahot.ions]
    ionlist = ionlist[uniq(ionlist, sort(ionlist))]
  endelse
endcase
pp = where(strcmp(loss_info.mechanism, 'photo', /fold), np) 
ie = where(strcmp(loss_info.mechanism, 'Electron Impact', /fold), nie)
in = where(strcmp(loss_info.mechanism, 'Ion-Neutral', /fold), nin)
sd = where(strcmp(loss_info.mechanism, 'spontaneous', /fold), ns)

;; Load the photo-reaction rate coefficients
photrate = 0d
for i=0,np-1 do begin
  file = file_basename(loss_info[pp[i]].file)
  print, file
  restore, !model.basepath + 'Data/AtomicData/Loss/' + input.options.atom + '/' + file

  photrate += ratecoef.kappa / stuff.aplanet^2
  destroy_structure, ratecoef
endfor

;; Load the electron impact rate coefficients
if (nie GT 0) then begin
  electemp = 10.^(dindgen(41)/20.)  ;; electrons valid for 1 eV < t_e < 100 eV
  eimpcoef = 0d
  for i=0,nie-1 do begin
    restore, !model.basepath + strmid(loss_info[ie[i]].file, $
      strlen('/Users/mburger/NeutralExosphereAndCloudModel/trunk/'))
    eimpcoef += loginterpol(*ratecoef.kappa, *ratecoef.t_e, electemp)
    destroy_structure, ratecoef
  endfor
endif else begin
  electemp = 0. & eimpcoef = 0.
endelse

;; Load the ion-neutral rate coefficeints
if (nin GT 0) then begin
  vrel = dindgen(101)*2 		;; 0 km/s < v_rel < 200 km/s
  iontemp = dindgen(101) 
  chxcoef = dblarr(101,101,n_elements(ionlist))
  for i=0,nin-1 do begin
    restore, !model.basepath + strmid(loss_info[in[i]].file, $
      strlen('/Users/mburger/NeutralExosphereAndCloudModel/trunk/'))
    q = (where(ionlist EQ ratecoef.ion, nq))[0]
    if (nq GT 1) then stop ;; problem
    if (nq EQ 1) then chxcoef[*,*,q] += interpolate_xy(*ratecoef.kappa, *ratecoef.t_i, $
      *ratecoef.v_rel, iontemp, vrel, /grid)
    print, ratecoef.reaction, '  ', q
    destroy_structure, ratecoef
  endfor
endif else begin
  vrel = 0. & iontemp = 0. & chxcoef = 0. & ionlist = ''
endelse

kappa = {photo:(photrate NE 0), eimp:(nie GT 0), chx:(nin GT 0), $
  kappa_photo:ptr_new(photrate), t_e:ptr_new(electemp), $
  kappa_ei:ptr_new(eimpcoef), ions:ionlist, t_i:ptr_new(iontemp), $
  v_rel:ptr_new(vrel), kappa_chx:ptr_new(chxcoef)}

return, loss_info

end
