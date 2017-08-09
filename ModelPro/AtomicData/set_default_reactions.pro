pro set_default_reactions, atom, loss=doloss, emission=doemission

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Find all the reactions for which I have atomic data for a given species.
;; 
;; Revision History:
;;   3.0 - 12/8/2010
;;     * Rewriting from scratch
;;   2.0 - 5/26/09
;;     * changed find_reactions to set_default_reactions and create_lossinfo
;;       to make things a bit clearer
;;   1.1 - 10/23/08
;;     * Clean up minor details
;;   1.0 - 10/23/08
;;     * Begin version control
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (doloss EQ !null) then doloss = 0
if (doemission EQ !null) then doemission = 0
if (doloss + doemission EQ 0) then begin
  doloss = 1 & doemission = 1
endif

path = !model.basepath + 'Data/AtomicData/'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remake the reaction list
allreactions = search_atomicdata()

if (doloss) then begin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Do loss reactions with rate coefficients
  q = where(strcmp(allreactions.datatype, 'rate', /fold) and $
    strcmp(allreactions.type, 'loss', /fold))
  reactions = allreactions[q]

  ;; Determine which atoms to look at. 
  ;; If none given, then do everything
  ;; If something has been specified, restore the saved defaults and remove the
  ;; specified species from the list
  if (n_elements(atom) EQ 0) then begin
    atom = reactions[uniq(reactions.species, sort(reactions.species))].species
    defaults = !null
  endif else begin
    if (file_test(path+'Defaults.Loss.sav')) then begin
      restore, path+'Defaults.Loss.sav'
      for i=0,n_elements(atom)-1 do begin
	q = where(defaults.species NE atom[i], nq)
	if (nq EQ 0) then defaults = !null else defaults = defaults[q]
      endfor
    endif else defaults = !null
  endelse

  for i=0,n_elements(atom)-1 do begin
    def = !null
    q = where(strcmp(reactions.species, atom[i]), nq)
    sub = reactions[q]
    if (nq EQ 1) then def = [def, sub] else begin
      ;; Create unique strings for the left and right sides of the reactions
      ;; The problem is that the reactants and products could be in any order
      tt = strsplit(sub.reaction, '->', /reg, /extract)
      left = strarr(nq) & right = strarr(nq)
      for k=0,nq-1 do begin
	q = strsplit((tt[k])[0], ',', /extract)
	left[k] = strjoin(q[sort(q)]+',')

	q = strsplit((tt[k])[1], ',', /extract)
	right[k] = strjoin(q[sort(q)]+',')
      endfor
      newr = strcompress(left + '->' + right, /remove_all)

      ;; Find out if any reactions are repeated
      u = newr[uniq(newr, sort(newr))] & nu = n_elements(u)
      if (nu EQ nq) $
	then def = [def, sub] $
	else begin
	  for k=0,nu-1 do begin
	    q = where(newr EQ u[k], nq)
	    if (nq EQ 1) $
	      then def = [def, sub[q]] $ 
	      else begin
		print
		print, 'Reaction: ' + sub[q[0]].reaction
		for j=0,nq-1 do print, '('+strint(j)+') ' + sub[q[j]].source
		read, c, prompt='Choose a reference: '
		c = round(c)
		if ((c LT 0) or (c GE nq)) then stop

		def = [def, sub[q[c]]]
	      endelse
	  endfor
	endelse
    endelse

    print
    print, 'Atom = ' + atom[i]
    for j=0,n_elements(def)-1 do $
      print, def[j].reaction, '  ', def[j].mechanism, '  ', def[j].source
    print, '***'
    asdf = ''
    read, asdf

    defaults = [defaults, def]
  endfor
  save, defaults, file=path+'Defaults.Loss.sav'
endif

if (doemission) then begin
  stop
endif

end
