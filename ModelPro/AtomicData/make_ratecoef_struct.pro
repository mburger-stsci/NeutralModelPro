pro make_ratecoef_struct, sigmafile, savefile=savefile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;  Version 2.1: ion-neutral rate coefficient is fn of v_rel and T_i.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restore, sigmafile

case strlowcase(crosssec.type) of 
  'electron impact': begin
    m = alog10(max(*crosssec.energy/2))
    t_e = 10.^(findgen(101)/100.*m)

    kappa = rate_integral('electron impact', temperature=t_e, $
      energy=*crosssec.energy, sigma=*crosssec.sigma)

    q = tag_names(crosssec)
    if (total(strcmp(q, 'LAMBDA', /fold_case))) $
      then ratecoef = {type:'Electron Impact', $
	reaction:crosssec.reaction, $
	t_e:ptr_new(t_e), $
	kappa:ptr_new(kappa), $
	reactants:crosssec.reactants, $
	products:crosssec.products, $
	source:crosssec.source, $
	lambda:crosssec.lambda} $
      else ratecoef = {type:'Electron Impact', $
	reaction:crosssec.reaction, $
	t_e:ptr_new(t_e), $
	kappa:ptr_new(kappa), $
	reactants:crosssec.reactants, $
	products:crosssec.products, $
	source:crosssec.source}
    plot, t_e, kappa, /xlog, /ylog
    end
  'ion-neutral': begin
    ;; Currently does not integrate over full speed distribution
    ;; This will need to be fixed.
    m = max(*crosssec.vrel)
    vrel = [findgen(11), findgen(11)/10.*(m-11)+11]
    t_i = findgen(26)*4.
    kappa = rate_integral('ion-neutral', u=vrel, temperature=t_i, vrel=*crosssec.vrel, $
      sigma=*crosssec.sigma, species1=crosssec.neutral, species2=crosssec.ion)
    ratecoef = {type:'Ion-Neutral', $
      kappa:ptr_new(kappa), $
      v_rel:ptr_new(vrel), $
      t_i:ptr_new(t_i), $
      reaction:crosssec.reaction, $
      neutral:crosssec.neutral, $
      ion:crosssec.ion, $
      products:crosssec.products, $
      source:crosssec.source}
    end
  else: stop
endcase

q = stregex(sigmafile, '.sigma.sav')
savefile = strmid(sigmafile, 0, q)+'.rate.sav'
save, ratecoef, file=savefile

destroy_structure, crosssec
destroy_structure, ratecoef

end
