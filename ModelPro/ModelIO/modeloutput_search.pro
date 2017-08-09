function modeloutput_search, inputtemp, verbose=verbose, nfiles=nfiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Program to search through the available model output files to compare
;; with an input set.
;; 
;; Help file: Docs/modeloutput_search.pdf
;;
;;   3.6: 5 Dec 2012
;;     * Adding support for modelstreams
;;   3.5: 8 Dec 2011
;;     * minor updates
;;   3.4: 3 Jan 2011
;;     * Rewriting using compare_inputs
;;   3.3: 26 August 2010
;;     * improving the efficiency a bit by making use of the directory tree
;;   3.1: 7/15/10
;;     * seraches for exact matches only. Use genericmodel_search to find the 
;;       generic models
;;   3.0: 7/14/10
;;     * original
;;     * looks for files - if none found, gives the generics
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


input0 = (isa(inputtemp, 'string')) ? inputs_restore(inputtemp) : inputtemp
if (verbose EQ !null) then verbose = 0

nfiles = 0
ct = 0
taa0 = input0.geometry.taa

;;;;;;;;
;; Find what output files are available
while ((nfiles EQ 0) and (ct LE 3)) do begin
  if (ct EQ 0) then begin
    if (verbose) then print, 'Trying within +/-0.5 deg'
    q = output_filename(input0, path=path)
    filelist = file_search(path, '*.output', count=nfiles)
  endif else begin
    if (verbose) then print, 'Trying within +/-' + strint(ct) + ' deg'
    input0.geometry.taa = taa0-ct*!dtor
    q = output_filename(input0, path=path)
    filelist0 = file_search(path, '*.output', count=nfiles0)

    input0.geometry.taa = taa0+ct*!dtor
    q = output_filename(input0, path=path)
    filelist1 = file_search(path, '*.output', count=nfiles1)

    nfiles = nfiles0+nfiles1
    case (1) of
      nfiles0 EQ 0 and nfiles1 EQ 0: filelist = ''
      nfiles1 EQ 0: filelist = filelist0
      nfiles0 EQ 0: filelist = filelist1
      else: filelist = [filelist0, filelist1]
    endcase

    input0.geometry.taa = taa0
  endelse

  if (nfiles GT 0) then begin
    same = intarr(nfiles)
    for i=0,nfiles-1 do begin
      hfile = headername(filelist[i])
      if ~(file_test(hfile)) then make_model_header, filelist[i]
      input = inputs_restore(hfile)
      
      ;; do a quick check
      t = tag_names(input.options)
      same[i] = compare_inputs(input0, input, verbose=verbose)
    endfor
    q = where(same, nq)
    filelist = (nq NE 0) ? filelist[q] : ''
  endif 
  nfiles = (filelist[0] EQ '') ? 0 : n_elements(filelist)
  ct++
endwhile

if (verbose) then print, strint(nfiles) + ' files found with these inputs.'

return, filelist

end
