runmodel = 1
getresults = 1

orbit = 30
npackets = 2e6

inputfiles = ['Mercury.Na.orbit30.T10000.input', $
  'Mercury.Na.orbit30.T20000.input']
formatfile = 'Mercury.Na.orbit30.format'

if (runmodel) then begin
  ;; 1) Determine Mercury TAA for orbit
  taa = MESSENGER_taa(orbit)
  print, 'Mercury TAA for orbit ' + strint(orbit) + ' = ' + strint(taa)

  ;; 2) Determine how long to run the model for
  endtime = MercuryModelEndTime('Na', taa)
  print, 'set endtime to ' + strint(long(endtime))

  ;; 3) Make the changes to the input file
  print, 'Make sure geometry.taa and options.endtime are set correctly in ' 
  for i=0,n_elements(inputfiles)-1 do print, '  ' + inputfiles[i]
  print, 'Then type ''.cont'' '
  stop

  modeldriver, inputfiles, npackets, /local
endif

if (getresults) then begin
  data = load_MASCS_data('Na', orbit, /level3)
  model = fltarr(n_elements(*data.radiance), n_elements(inputfiles))
  for i=0,n_elements(inputfiles)-1 do begin
    result = produce_results(inputfiles[i], formatfile, /local)
    model[*,i] = *result.radiance/1000.
  endfor

  str = mean(*data.radiance)/mean(model, dim=1)
  print, str
  
  plot, *data.et-min(*data.et), *data.radiance
  oplot, *data.et-min(*data.et), model[*,0]*str[0], color=2
  oplot, *data.et-min(*data.et), model[*,1]*str[1], color=4
endif

end
