pro extract_Huebner_data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This extracts the data from Huebner et al. 1992 and Huebner & Mukherjee 2011.
;; Also prints a comparison of the two
;; Huebner \& Mukherjee 2011 is the website http://phidrates.space.swri.edu
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

path = !model.basepath + 'Data/AtomicData/Loss/'

for o=0,1 do begin
  case (o) of 
    0: begin
       file = !model.basepath + 'Data/AtomicData/Loss/multi-species/Huebner1992.dat'
       source = 'Huebner et al. 1992'
       end
    1: begin
       file = !model.basepath + 'Data/AtomicData/Loss/multi-species/Huebner2011.dat'
       source = 'Huebner & Mukherjee 2011' 
       end
    else: stop
  endcase

  readcol, file, species, reaction, low, high, format='A,A,F,F', /silent, delim=':'
  reaction = strtrim(reaction, 2)
  species = strtrim(species, 2)

  for i=0,n_elements(reaction)-1 do begin
    rrr = (strsplit(reaction[i], '->', /extract, /regex))[0]
    ppp = (strsplit(reaction[i], '->', /extract, /regex))[1]

    reactants = strtrim(strsplit(rrr, ',', /extract),2)
    products = strtrim(strsplit(ppp, ',', /extract),2)

    ratecoef = {type:'photo', $
      reaction:reaction[i], $
      kappa:low[i], $
      reactants:reactants, $
      products:products, $
      source:source}

    ;; save the structure
    dir = path + reactants[0] + '/'
    rname = (strsplit(file_basename(file), '.', /extract))[0] + '.'
    rstr = ''
    for j=0,n_elements(reactants)-1 do rstr += reactants[j] + '.'
    rstr = strmid(rstr, 0, strlen(rstr)-1) + '-'

    pstr = ''
    for j=0,n_elements(products)-1 do pstr += products[j] + '.'

    savefile = dir + rname + rstr + pstr + 'rate.sav'
    save, ratecoef, file=savefile 
    print, savefile
  endfor
endfor

;;;;;;;;;;;;;
;; Make a comparison list
file0 = file_search(!model.basepath + 'Data/AtomicData/Loss/', 'Huebner1992*.rate.sav')
file1 = file_search(!model.basepath + 'Data/AtomicData/Loss/', 'Huebner2011*.rate.sav')

ff0 = strmid(file_basename(file0), strlen('Huebner1992.'))
ff1 = strmid(file_basename(file1), strlen('Huebner2011.'))

print, 'REACTION     Huebner et al. (1992)   Hubner & Mukherjee (2011)'
for i=0,n_elements(ff0)-1 do begin
  q = (where(strmatch(ff1, ff0[i]), nq))[0]
  case (nq) of 
    0: 
    1: begin
       restore, file0[i]
       ratecoef0 = temporary(ratecoef)
       restore, file1[q]
       if ~(strmatch(ratecoef0.reaction, ratecoef.reaction)) then stop
       print, ratecoef0.reaction, ratecoef0.kappa, ratecoef.kappa
       end
    else: stop
  endcase
endfor

end
