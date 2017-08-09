function atomicmass, species

sp2 = stregex(species, '[^\+]+', /extract)

defsysv, '!model', exists=e
file = (e) ? !model.basepath + 'Data/PhysicalData/periodictable.sav' : $
  '$HOME/Work/Data/PhysicalData/periodictable.sav'
if (file_test(file)) then restore, file else stop

n = n_elements(sp2)
mass = fltarr(n)

for i=0,n-1 do begin
  q = (where(periodictable.sp EQ sp2[i], nq))[0]
  
  case (nq) of 
    1: mass[i] = (periodictable.mass)[q]*!physconst.mp
    0: case (sp2[i]) of 
	 ;; Diatomic molecules
	 'OH': mass[i] = total(atomicmass(['O','H']))
	 'O_2': mass[i] = 2*atomicmass('O')
	 'N_2': mass[i] = 2*atomicmass('N')
	 'CO': mass[i] = total(atomicmass(['C', 'O']))
	 'CaO': mass[i] = total(atomicmass(['Ca', 'O']))
	 'SO': mass[i] = total(atomicmass(['S', 'O']))

	 ;; Larger molecules
	 'H_2O': mass[i] = total(atomicmass(['H', 'H', 'O']))
	 'SO_2': mass[i] = total(atomicmass(['S', 'O_2']))
	 'CO_2': mass[i] = total(atomicmass(['C', 'O_2']))
	 'CaOH': mass[i] = total(atomicmass(['Ca', 'OH']))
	 'Ca<OH>_2': mass[i] = total(atomicmass(['CaOH', 'OH']))

	 ;; Electron/Positron
	 'e': mass[i] = !physconst.me

	 else: begin
           ;; Is this a generic mass?
           gen = stregex(sp2[i], 'Mass', /bool)
	   if ~(gen) then stop
	   mm = double(strmid(sp2[i], 4))
	   mass[i] = mm * !physconst.mp
	 endelse
       endcase
    else: stop
  endcase
endfor

if (n EQ 1) then mass = mass[0]

return, mass

end

