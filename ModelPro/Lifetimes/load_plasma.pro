pro load_plasma, planet, plasma_info, plasma=plasma, hotplasma=plasmahot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Load the plasma and make necessary adjustments
;; 
;; Version History:
;;   2.1: 12/6/2010
;;     * some small adjustments
;;   2.0: created 9/14/2009
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

case (planet) of 
  'Jupiter': begin
    restore, !model.basepath + 'Data/PlasmaData/VoyagerTorus.sav'
    elecscale = *plasma.h_e
    q = where(finite(elecscale) EQ 0, comp=c)
    elecscale[q] = elecscale[c[0]]
    plasma = create_struct('elecscale', ptr_new(elecscale), plasma)

    hotscale = *plasmahot.h_e
    q = where(finite(hotscale) EQ 0, comp=c)
    hotscale[q] = hotscale[c[0]]
    plasmahot = create_struct('elecscale', ptr_new(hotscale), plasmahot)
    end
  'Saturn': begin
    restore, !model.basepath + 'Data/PlasmaData/SaturnPlasma.2008-04-16.sav'
    *plasma.elecden *= plasma_info.ElecDenMod   ;; constant elec den changes
    *plasma.electemp *= plasma_info.ElecTempMod ;; constant elec temp changes
    end
  else: 
endcase 

end
