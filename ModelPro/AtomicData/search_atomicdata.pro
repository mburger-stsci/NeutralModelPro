function search_atomicdata, savefile, help=help, mktable=mktable

if (mktable EQ !null) then mktable = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Searches through all the atomic data to make a master list of 
;; emission, loss, recombination(?) reactions
;;
;; Version History
;;   3.1: 9/14/2011
;;     * A few minor changes
;;   3.0: 12/8/2010
;;     * created from make_reaction_list_3.0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (help EQ !null) then help = 0
if (help) then begin
  print, 'A REACTION structure contains: '
  print, '  * species'
  print, '  * reaction: the reaction this data is for'
  print, '  * line: An emission line if this is emission data (A)'
  print, '  * type: Emission or Loss'
  print, '  * mechanism: photo, Electron Impact, Ion-Neutral'
  print, '  * dtype: Data type - Rate or Cross Section'
  print, '  * file: Location of saved file'
  print, '  * source: Data reference'
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
defsysv, '!model', exists=e
path = !model.basepath + 'Data/AtomicData/' 
if ~(file_test(path)) then stop

files = [file_search(path+'Loss/', '*.sav'), $
  file_search(path+'Emission/', '*.sav'), $
  file_search(path+'Recombination/', '*.sav')]
q = where(~stregex(files, 'dontuse', /bool) and ~stregex(files, 'old', /bool))
files = files[q] 
q = where(stregex(files, '.rate.sav', /bool) or stregex(files, '.sigma.sav', /bool))
files = files[q] & nfiles = n_elements(files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the data
reac = strarr(nfiles)    ;; reactions
source = strarr(nfiles)  ;; reference
spec0 = strarr(nfiles)   ;; reactant 1
spec1 = strarr(nfiles)   ;; reactant 2
type = strarr(nfiles)    ;; Loss, Emission, etc.
mech = strarr(nfiles)    ;; Mechanism (electron impact, etc.)
line = fltarr(nfiles)    ;; Emission line
dtype = strarr(nfiles)   ;; Data type (ratecoef, cross section)

for i=0,nfiles-1 do begin
  ;; Determine reaction type
  case (1) of 
    (stregex(files[i], 'loss', /fold, /bool)): type[i] = 'Loss'
    (stregex(files[i], 'emission', /fold, /bool)): type[i] = 'Emission'
    (stregex(files[i], 'recombination', /fold, /bool)): type[i] = 'Recombination'
    else: stop
  endcase

  ;; Determine data type
  case (1) of
    (stregex(files[i], 'rate', /fold, /bool)): dtype[i] = 'Rate'
    (stregex(files[i], 'sigma', /fold, /bool)): dtype[i] = 'Cross Section'
    else: stop
  endcase

  ;; Restore the file
  restore, files[i]
  if (dtype[i] EQ 'Cross Section') then ratecoef = temporary(crosssec)
  
  ;; Save the reference
  source[i] = ratecoef.source

  ;; Save the reactants
  if (strcmp(ratecoef.type, 'ion-neutral', /fold)) then begin
    spec0[i] = ratecoef.neutral
    spec1[i] = ratecoef.ion
  endif else begin
    spec0[i] = (ratecoef.reactants)[0]
    spec1[i] = (ratecoef.reactants)[1]
  endelse

  ;; Save the mechanism, reaction, and line
  mech[i] = ratecoef.type
  reac[i] = ratecoef.reaction

  ;; Save the emission line
  line[i] = (type[i] EQ 'Emission') ? float(ratecoef.lambda) : -1
endfor

;; Make a single long list
reac2 = [reac, reac]
files2 = [files, files]
type2 = [type, type]
dtype2 = [dtype, dtype]
source2 = [source, source]
spec2 = [spec0, spec1]
mech2 = [mech, mech]
line2 = [line, line]

;; Remove electrons and photons from the list
q = where((spec2 NE 'e') and (spec2 NE 'photon'))
reac2 = reac2[q]
files2 = files2[q]
type2 = type2[q]
dtype2 = dtype2[q]
source2 = source2[q]
spec2 = spec2[q]
mech2 = mech2[q]
line2 = line2[q]

;; Make the structures
nn = n_elements(spec2)
temp = {species:'', reaction:'', line:0., type:'', mechanism:'', datatype:'', $
  file:'', source:''}
reactions = replicate(temp, nn)
reactions.species = spec2
reactions.reaction = reac2
reactions.line = line2
reactions.type = type2
reactions.mechanism = mech2
reactions.datatype = dtype2
reactions.file = files2
reactions.source = source2

if (savefile EQ !null) then savefile = path + 'AtomicData.sav'
save, reactions, file=savefile

s = sort(reactions.reaction)
reactions = reactions[s]

if (mktable) then begin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Make a latex table of all the reactions
  openw, lun, /get_lun, path + 'AtomicData.tex', width=100
  printf, lun, '\documentclass[11pt]{article}'
  printf, lun, '\include{noteinclude}'
  printf, lun, '\usepackage{supertabular}'
  printf, lun
  printf, lun, '\begin{document}'
  printf, lun

  ;; First table: photo-loss reactions
  q = where(strmatch(reactions.type, 'Loss', /fold) and $
    strmatch(reactions.mechanism, 'photo', /fold), nq)
  if (nq EQ 0) then stop

  printf, lun, '\tablecaption{Photodissociation and photoionization reactions \\}'
  printf, lun, '\tablehead{\textbf{Species} & \textbf{Reaction} & \textbf{Source} \\ \hline }'
  printf, lun, '\tabletail{\hline \multicolumn{3}{r}{\emph{Continued on next page}}\\}'
  printf, lun, '\tablelasttail{\hline}'
  printf, lun, '\begin{supertabular}{ccl}'

  for i=0,nq-1 do begin
    sp = (reactions.species)[q[i]]

    w = strsplit(sp, '_')
    sp = (n_elements(w) EQ 1) ? sp : $
      strmid(sp, 0, w[1]-1) + '$_' + strmid(sp, w[1], 1) + '$' + strmid(sp, w[1]+1) 
    sp = strreplace(sp, '+', '$^+$')
    sp = strreplace(sp, '<', '(')
    sp = strreplace(sp, '>', ')')

    reac = (reactions.reaction)[q[i]]
    a = strsplit(reac, '->', /regex, /extract)
    b = strsplit(a[0], ',', /extract)
    c = strsplit(a[1], ',', /extract)

    w = strsplit(b[0], '_')
    b0 = (n_elements(w) EQ 1) ? b[0] : $
      strmid(b[0], 0, w[1]-1) + '$_' + strmid(b[0], w[1], 1) + '$' + strmid(b[0], w[1]+1) 
    b0 = strreplace(b0, '+', '$^+$')
    b0 = strreplace(b0, '<', '(')
    b0 = strreplace(b0, '>', ')')

    w = strsplit(b[1], '_')
    b1 = (n_elements(w) EQ 1) ? b[1] : $
      strmid(b[1], 0, w[1]-1) + '$_' + strmid(b[1], w[1], 1) + '$' + strmid(b[1], w[1]+1) 
    b1 = strreplace(b1, '+', '$^+$')
    b1 = strreplace(b1, '<', '(')
    b1 = strreplace(b1, '>', ')')

    if (strmatch(b1, 'photon', /fold)) then b1 = 'h$\nu$'

    w = strsplit(c[0], '_')
    c0 = (n_elements(w) EQ 1) ? c[0] : $
      strmid(c[0], 0, w[1]-1) + '$_' + strmid(c[0], w[1], 1) + '$' + strmid(c[0], w[1]+1) 
    c0 = strreplace(c0, '+', '$^+$')
    c0 = strreplace(c0, '<', '(')
    c0 = strreplace(c0, '>', ')')

    w = strsplit(c[1], '_')
    c1 = (n_elements(w) EQ 1) ? c[1] : $
      strmid(c[1], 0, w[1]-1) + '$_' + strmid(c[1], w[1], 1) + '$' + strmid(c[1], w[1]+1) 
    c1 = strreplace(c1, '+', '$^+$')
    c1 = strreplace(c1, '<', '(')
    c1 = strreplace(c1, '>', ')')

    reac = b0 + ' + ' + b1 + ' \rarrow\ ' + c0 + ' + ' + c1

    source = strreplace((reactions.source)[q[i]], '&', '\&')
    
    printf, lun, sp + ' & ' + reac + ' & ' + source + ' \\'
  endfor

  printf, lun, '\end{supertabular}'
  printf, lun
  printf, lun, '\end{document}'
  free_lun, lun

  spawn, 'pdflatex ' + path + 'AtomicData.tex'
  spawn, 'pdflatex ' + path + 'AtomicData.tex'
  spawn, 'pdflatex ' + path + 'AtomicData.tex'
  spawn, 'mv AtomicData.pdf ' + path 
endif

return, reactions

end
