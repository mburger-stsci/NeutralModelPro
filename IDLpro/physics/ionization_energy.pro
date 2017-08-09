function ionization_energy, atom

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Looks up the 1st ionization potential from ionization_potential.dat
;; Reference: http://en.wikipedia.org/wiki/Ionization_energies_of_the_elements
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cc = 96.48534
file = '/Users/mburger/Data/PhysicalData/ionization_energy.dat'
if ~(file_test(file)) then file = (file_search('$HOME', 'ionization_energy.dat'))[0]

readcol, file, num, symb, name, en1, skip=2, format='F,A,A,F', /silent
symb = strlowcase(strtrim(symb, 2))
name = strlowcase(strtrim(name, 2))

ll = strlen(atom)
if ((ll EQ 1) or (ll EQ 2)) $
  then q = (where(symb EQ strlowcase(atom), nq))[0] $
  else q = (where(name EQ strlowcase(atom), nq))[0]

if (nq EQ 0) then begin
  print, 'Not a valid element'
  return, -1
endif else return, en1[q]/cc

end
