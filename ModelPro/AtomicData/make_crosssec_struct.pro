pro make_crosssec_struct, file, savefile=savefile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Read the cross section data from a text file and creates and IDL save file 
;; with a cross section structure.
;;
;; Version 2.2: 14 Sept 2009
;;   * fixed bug in naming emission data files
;; Version 2.0: 22 May 2009
;;   * Replaces the version of this progrm in make_reaction_list. To remake all
;;     the cross section structures at once, use the appropriate flag in 
;;     make_reaction_list_2.0
;;   * New format for atomic data which allows for more information in the header
;;     (100 lines max)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Read in the header info
head = strarr(100)
line = ''
ct = 0
openr, lun, file, /get_lun
while (strlowcase(line) NE '\begindata') do begin
  readf, lun, line
  head[ct] = line
  ct++
endwhile
head = head[0:ct-2]

;; Find the reference
q = (where(stregex(head, 'REFERENCE', /fold_case) NE -1, ct))[0]
if (ct NE 1) then stop
w = stregex(head[q], '//')
ref = strtrim(strmid(head[q], 0, w), 2)

;; Find the data type
q = (where(stregex(head, 'DATATYPE', /fold_case) NE -1, ct))[0]
if (ct GT 1) then stop
if (ct EQ 0) then dtype = 'cross section' else begin
  w = stregex(head[q], '//')
 dtype = strtrim(strmid(head[q], 0, w), 2)
endelse
if (strlowcase(dtype) NE 'cross section') then stop ;; Not set up for other data types yet

;; Find the reaction type
q = (where(stregex(head, 'REACTYPE', /fold_case) NE -1, ct))[0]
if (ct NE 1) then stop
w = stregex(head[q], '//')
type = strtrim(strmid(head[q], 0, w), 2)

;; Find the list of reactions
q = (where(stregex(head, 'NREAC', /fold_case) NE -1, ct))[0]
if (ct NE 1) then stop
w = stregex(head[q], '//')
nreac = fix(strmid(head[q], 0, w))

reactions = strarr(nreac)
q = where(stregex(head, 'REACTION', /fold_case) NE -1, ct)
if (ct NE nreac) then stop
for i=0,nreac-1 do begin
  w = stregex(head[q[i]], '//')
  reactions[i] = strtrim(strmid(head[q[i]], 0, w), 2)
endfor
if (nreac EQ 1) then reactions = reactions[0]

lambda = strarr(nreac)
q = where(stregex(head, 'WAVELENGTH', /fold_case) NE -1, ct)
if (ct EQ nreac) then begin ;; Emission
  nlam = nreac
  for i=0,nreac-1 do begin
    w = stregex(head[q[i]], '//')
    lambda[i] = strtrim(strmid(head[q[i]], 0, w), 2)
  endfor
endif else nlam = 0

;; Read in the cross section data
Energy = dblarr(200)
sigma = dblarr(200, nreac)
ct = 0
line = ''
done = 0 
while ~done do begin
  readf, lun, line
  q = strsplit(line, ':', /extract)
  if (n_elements(q) EQ nreac+1) then begin
    Energy[ct] = double(q[0])
    sigma[ct,*] = double(q[1:*])
    ct += 1
  endif else begin
    w = stregex(line, 'enddata', /fold_case, /bool)
    if w then done = 1 else stop
  endelse
endwhile
free_lun, lun

Energy = Energy[0:ct-1]
sigma = sigma[0:ct-1,*]

savefile = strarr(nreac)
for i=0,nreac-1 do begin
  reaction = reactions[i]
  rrr = (strsplit(reaction, '->', /extract, /regex))[0]
  ppp = (strsplit(reaction, '->', /extract, /regex))[1]

  reactants = strtrim(strsplit(rrr, ',', /extract),2)
  products = strtrim(strsplit(ppp, ',', /extract),2)

  w = where(sigma[*,i] GE 0)
  en = energy[w]
  sig = sigma[w,i]

  ;; Sort the energies just in case
  s = sort(energy)
  en = en[s] & sig = sig[s]
  
  case strlowcase(type) of 
    'electron impact': begin
      if (nlam EQ 0) $
        then crosssec = {type:'Electron Impact', $
	  energy:ptr_new(en), $
	  sigma:ptr_new(sig), $
	  reaction:reaction, $
	  reactants:reactants, $
	  products:products, $
	  source:ref} $
        else crosssec = {type:'Electron Impact', $
	  energy:ptr_new(en), $
	  sigma:ptr_new(sig), $
	  reaction:reaction, $
	  reactants:reactants, $
	  products:products, $
	  lambda:lambda[i], $
	  source:ref}
      plot, *crosssec.energy, *crosssec.sigma, /xlog, /ylog, $
	yr=minmax((*crosssec.sigma)[where(*crosssec.sigma NE 0)])
      end
    'ion-neutral': begin
      if (n_elements(reactants) NE 2) then stop
      q = strpos(reactants[0], '+')
      if (q EQ -1) then begin
	neut = reactants[0] & ion = reactants[1]
      endif else begin
	neut = reactants[1] & ion = reactants[0]
      endelse
      mneut = atomicmass(neut) & mion = atomicmass(ion)

      ;; Determine the energy type
      q = (where(stregex(head, 'ETYPE', /fold_case) NE -1, ct))[0]
      if (ct NE 1) then stop
      w = stregex(head[q], '//')
      etype = strtrim(strmid(head[q], 0, w), 2)

      ;; Convert energy to relative velocity
      case strlowcase(Etype) of 
	'incident energy': vrel = sqrt(2*en*!const.erg_eV/mion)/1e5
	'com energy': vrel = sqrt(2*en*!const.erg_eV*(mneut+mion)/mneut/mion)/1e5
	'vrel': vrel = en/1e5
	else: stop
      endcase

      crosssec = {type:'Ion-Neutral', $
	vrel:ptr_new(vrel), $
	sigma:ptr_new(sig), $
	reaction:reaction, $
	neutral:neut, $
	ion: ion, $
	products:products, $
	source:ref}
      plot, *crosssec.vrel, *crosssec.sigma, /ylog, /xlog, $
	yr=minmax((*crosssec.sigma)[where(*crosssec.sigma NE 0)])
      end
    else: stop
  endcase

  ;; save the structure
  dir = file_dirname(file, /mark)
  rname = (strsplit(file_basename(file), '.', /extract))[0] + '.'
  rstr = ''
  for j=0,n_elements(reactants)-1 do rstr += reactants[j] + '.'
  rstr = strmid(rstr, 0, strlen(rstr)-1) + '-'

  pstr = ''
  for j=0,n_elements(products)-1 do pstr += products[j] + '.'

  if (lambda[i] EQ '') $
    then sfile = dir + rname + rstr + pstr + 'sigma.sav' $ 
    else sfile = dir + rname + rstr + pstr + lambda[i] + '.sigma.sav'
  save, crosssec, file=sfile
  savefile[i] = sfile
  print, sfile

  destroy_structure, crosssec
  ;stop
endfor

end


