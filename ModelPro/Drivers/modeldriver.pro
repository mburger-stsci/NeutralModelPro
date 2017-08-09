pro modeldriver, inputfiles, npackets, seed, $
  outputfiles=outputfiles, $
  packs_per_it=packs_per_it, $
  overwrite=overwrite, $   ;; Erase existing files that match inputfile 
  showplot=showplot, $	   ;; Show intermediate plots
  local=local, $           ;; save locally vs. on DroboData
  compress=compress        ;; compress the output to save space and speed up restore

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Load in the common blocks
common constants
common ratecoefs
common plasma

tstart = systime(1)
tittot = 0. 
ntot = 0L

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up the stuff structure
if (local EQ !null) then local = 0
stuff = {s:0, aplanet:0., vrplanet:0., radpres_v:ptr_new(0), $
  radpres_const:ptr_new(0), local:local, strstart:'', which:ptr_new(0), time_given:0}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Determine run options
if (overwrite EQ !null) then overwrite = 0
if (compress EQ !null) then compress = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop over each inputfile
ninputs = n_elements(inputfiles)
ty = size(inputfiles, /type)

for iii=0,ninputs-1 do begin
  trun0 = systime(1)
  stuff.strstart = 'Inputfile #' + strint(iii) + ': '

  inputfile = inputfiles[iii]
  inputstring = (ty EQ 7) ? inputfiles : ' given input structure.'
  print, '***********************'
  print, stuff.strstart + 'Starting ' + inputstring
  print, stuff.strstart + systime(0)

  ;; Read in the inputs 
  case (ty) of 
    7: input = inputs_restore(inputfile) 
    8: input = inputfile
    else: stop
  endcase 

  ;; Determine how many packets have already been run
  totalpackets = model_findpackets(input, outputfiles=outputfiles, $
    overwrite=overwrite)
  ntodo = long(npackets) - totalpackets
  if (strcmp(outputfiles[0], '') and (n_elements(outputfiles) GT 1)) then stop
  if (strcmp(outputfiles[0], '')) then outputfiles = !null

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (ntodo GT 0) then begin
    ;; Keep track of which objects to include
    *stuff.which = where(*input.geometry.include, nw)
    if (nw EQ 1) then *stuff.which = (*stuff.which)[0]

    ;; Determine if the time is given
    tags = tag_names(input.geometry)
    stuff.time_given = round(total(stregex(tags, 'time', /fold, /bool)))
;;    if (stuff.time_given) then begin
;;      print, 'Setting stuff.time_given to 0.'
;;      stuff.time_given = 0
;;    endif
  
    ;; default number of packets per iteration
    if (packs_per_it EQ !null) then $
      packs_per_it = (input.options.streamlines) ? long(1e3) : long(1e6)

    ;; Load system constants
    SystemConstants, input.geometry.planet, SystemConsts, DipoleConsts

    ;; Determine distance and radial velocity of planet relative to the sun
    planet_dist, input

    stuff.s = (where(strlowcase(*SystemConsts.Objects) EQ $
      strlowcase(input.geometry.StartPoint)))[0]

    ;; Check to make sure at_once is set properly
    if (input.options.streamlines) and (input.options.at_once NE 1) then begin
      print, 'Set input.options.at_once = 1'
      stop
    endif

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Determine how to run the additional packets that are needed
    ;; run interations until have the correct number of packets. 
    ;; After finished running iterations, combine to reduce number of files.
    nits = ceil(float(ntodo)/float(packs_per_it)) 

    print, stuff.strstart + 'Running Model'
    print, stuff.strstart + 'Will complete ' + strint(nits) + $
      ' iterations of ' + strint(packs_per_it) + ' packets.'

    ;; Do the iterations
    for j=0,nits-1 do begin
      tit0 = systime(1)
      print, '** Starting iteration #' + strint(j+1) + ' of ' + strint(nits)
      if (ty EQ 7) then print, inputfile

      output = modeldriver_runit(input, packs_per_it, seed=seed, showplot=showplot)

      ;; Compress if necessary
      if (compress) then begin
	nq0 = n_elements(*output.frac)
	q = where(*output.frac GT 0, nq)
	if (nq GT 0) then out_sub, output, q
	print, 'Compressing output: removing ' + strint(nq) + ' of ' + $
	  strint(nq0) + ' packets.'
      endif

      ;; convert to floats
      *output.x0 = float(*output.x0)
      *output.y0 = float(*output.y0)
      *output.z0 = float(*output.z0)
      *output.f0 = float(*output.f0)
      *output.vx0 = float(*output.vx0)
      *output.vy0 = float(*output.vy0)
      *output.vz0 = float(*output.vz0)
      *output.phi0 = float(*output.phi0)
      *output.lat0 = float(*output.lat0)
      *output.lon0 = float(*output.lon0)
      *output.time = float(*output.time)
      *output.x = float(*output.x)
      *output.y = float(*output.y)
      *output.z = float(*output.z)
      *output.frac = float(*output.frac)
      *output.vx = float(*output.vx)
      *output.vy = float(*output.vy)
      *output.vz = float(*output.vz)

      ;; Save the output
      outputfile = output_filename(input)
      outputfiles = [outputfiles, outputfile]

      print, 'Saving: ' + outputfile
      save, output, input, file=outputfile
      destroy_structure, output

      ;; Make the header file
      make_model_header, outputfile

      ;; Concluding stuff
      tit1 = systime(1)
      ntot++
      tittot += (tit1-tit0)
      print, stuff.strstart + 'Iteration time = ' + strint(tit1-tit0) + ' seconds'
      print, stuff.strstart + 'Mean Iteration time = ' + strint(tittot/ntot) + $
	' seconds'
    endfor

    ;; Cleanup the memory
    if (ty EQ 7) then begin
      print, 'Finished ' + inputfile
      destroy_structure, input
    endif
    destroy_structure, plasma
    destroy_structure, plasmahot
    destroy_structure, plasma
    destroy_structure, coef_eimp
    destroy_structure, coef_chx
    destroy_structure, coef_photo
    destroy_structure, SystemConsts
  endif 

  trun1 = systime(1)
  print, stuff.strstart + 'Finishing ' + inputstring
  print, stuff.strstart + 'Time for inputfile: ' + strint((trun1-trun0)/3600.) + ' hours'
  print, stuff.strstart + 'Total elaspsed time: ' + strint((trun1-tstart)/3600.) + $
    ' hours'
  print
endfor ; iii

end
