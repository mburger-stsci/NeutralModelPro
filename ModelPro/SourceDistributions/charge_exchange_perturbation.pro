pro charge_exchange_perturbation, startloc, PerturbVel, options

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Add a perturbation velocity based on charge exchange
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

common constants

;; 1) find the appropriate charge exchange reactions
path = '$HOME/Data/AtomicData/Loss/'
defaults = path+'DefaultsList.dat'
readcol, defaults, species, reac, file, delim=':', /silent, skip=1, format='A,A,A'
species = strtrim(species, 2)
reac = strtrim(reac, 2)
file = strtrim(file, 2)

q = where(species EQ options.atom, nq)
if (nq EQ 0) then stop

rsub = reac[q]
fsub = file[q]

for i=0,nq-1 do begin
  restore, path+fsub[i]
  print, ratecoef.type
  if (strlowcase(ratecoef.type) EQ 'ion-neutral') then begin
    ;; determine if correct product is formed

    stop

  endif else destroy_ratecoef, ratecoef
endfor

stop
end
