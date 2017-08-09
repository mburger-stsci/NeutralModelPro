function model_findpackets, input0, overwrite=overwrite, outputfiles=files

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  * Given an inputfile, determines how many packets are available.
;;  * Also returns the available output files and number of packets in each file
;;
;;  Revision history
;;    3/11/2013
;;      * keyword to give output file names
;;    4.1 -- 11/30/2012
;;      * Removing generic options for simplicity
;;    4.0 -- 12/8/2011
;;      * Moving this part of modeldriver_3.7 to a separate program.
;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Load in the common blocks
common constants

;; Determine run options
if (overwrite EQ !null) then overwrite = 0

totalpackets = 0L    ;; reset the number of packets

files = modeloutput_search(input0, nfiles=nfiles)
print, stuff.strstart + strint(nfiles) + ' output files found.'

;; Delete old files if requested
if ((nfiles GT 0) and (overwrite))  then begin 
  print, stuff.strstart + 'Eraseing old, unwanted files.'
  for i=0,nfiles-1 do spawn, 'rm ' + files[i]
  nfiles = 0
  files = ''
endif
      
;; Determine number of packets available
if (nfiles EQ 0) $
  then totalpackets = 0L $
  else begin
    pack = (input0.options.streamlines) ? extract_parameter('savedpackets', files) : $
      extract_parameter('totalsource', files)
    totalpackets = long(total((pack.values()).ToArray(type='long')))
    pack = 0  ; get around an IDL bug
  endelse

print, stuff.strstart + strint(totalpackets) + ' packets found.'

return, totalpackets

end
