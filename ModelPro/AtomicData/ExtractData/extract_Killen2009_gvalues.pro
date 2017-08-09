pro extract_Killen2009_gvalues

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Extracts g-values from Killen et al. 2009.
;; Values for Ti and Mn are unpublished g-values computed with the same method
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

species = ['H', 'He', 'C', 'O', 'Na', 'K', 'Ca', 'Ca+', 'Mg', 'Mg+', 'S', 'OH', $
  'Ti', 'Mn']


path = !model.basepath + 'Data/AtomicData/g-values/'

for i=0,n_elements(species)-1 do begin
  case (species[i]) of 
    'Na': lambda = [3303., 5891., 5897.]
    'C': lambda = [1657., 1560.]
    'Ca': lambda = [2722., 4227., 4567.]
    'Ca+': lambda = [3934., 3969.]
    'H': lambda = 1215.
    'He': lambda = 584.
    'Mg': lambda = 2852.
    'Mg+': lambda = [2796., 2083.]
    'O': lambda = 1303.
    'OH': lambda = [3081., 3092.]
    'S': lambda = [1807., 1820.]
    'K': lambda = 4045.
    'Ti': lambda = [3187., 3193., 3204., 3342., 3371., 3372., 3636., 3644.]
    'Mn': lambda = [2795., 2799., 2802.]
    else: stop
  endcase

  if ((species[i] EQ 'Ti') or (species[i] EQ 'Mn')) then begin
    filest = path + species[i] + '/' + species[i] + '.KillenXXXX'
    reference = 'Killen et al., unpublished'
    a = 1.
  endif else begin
    filest = path + species[i] + '/' + species[i] + '.Killen2009'
    reference = 'Killen et al. 2009'
    a = 0.352  ;; Killen tables use a=0.352 as the reference point
  endelse

  nl = n_elements(lambda)
  case (nl) of
    1: readcol, filest+'.dat', v, g, delim=':', format='F,F', /silent
    2: begin
       readcol, filest+'.dat', v, g0, g1, delim=':', format='F,F,F', /silent
       g = [[g0], [g1]]
       end
    3: begin
       readcol, filest+'.dat', v, g0, g1, g2, delim=':', format='F,F,F,F', /silent
       g = [[g0], [g1], [g2]]
       end
    8: begin
       readcol, filest+'.dat', v, g0, g1, g2, g3, g4, g5, g6, g7, delim=':', $
	 format='F,F,F,F,F,F,F,F,F,F,F', /silent
       g = [[g0], [g1], [g2], [g3], [g4], [g5], [g6], [g7]]
       end
    else: stop
  endcase
  print, 'Species = ' + species[i]

  g = g * a^2
  for j=0,nl-1 do begin
    gvalue = {species:species[i], wavelength:lambda[j], a:1.0, v:ptr_new(v), $
      g:ptr_new(g[*,j]), reference:reference}
    savef = filest + '.' + strint(round(lambda[j])) + '.gvalue.sav'
    save, gvalue, file=savef
    gvalue = 0
    print, '  lambda = ' + strint(round(lambda[j])) + ', file = ' + file_basename(savef)
  endfor
  print, '*****************************************'
endfor

end
