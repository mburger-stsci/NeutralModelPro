function streamline_findpackets, input, dt, overwrite=overwrite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  * Given an inputfile, determines how many packets are available.
;;  * Will extract from generic files if requetsed.
;;  * Also returns the available output files and number of packets in each file
;;
;;  Revision history
;;    4.0 -- 12/8/2011
;;      * Moving this part of modeldriver_3.7 to a separate program.
;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Load in the common blocks
common constants

;; Determine run options
if (overwrite EQ !null) then overwrite = 0
totalpackets = 0L    ;; reset the number of packets

files = modeloutput_search(input, dt, nfiles=nfiles, /stream)
print, stuff.strstart + strint(nfiles) + ' output files found.'

;; Delete old files if requested
if (overwrite) then begin 
  print, stuff.strstart + 'Eraseing old, unwanted files.'
  for i=0,nfiles-1 do spawn, 'rm ' + files[i]
  nfiles = 0
endif
      
;; Search through the files for the number of saved packets
if (nfiles GT 0) then begin
  pack = extract_parameter('savedpackets', files)
  totalpackets = long(total((pack.values()).ToArray(type='long')))
  pack = 0  ; get around an IDL bug
endif else totalpackets = 0L

return, totalpackets

end
