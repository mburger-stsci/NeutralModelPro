;;pro view_packets, outtemp, data
data = load_mascs_data('Ca', 
inputfiles = 'Mercury.Mg.orbit514.uniform.T' + ['1000', '1500'] + '.input'
outtemp = (modeloutput_search(inputfiles[0]))[0]

if (n_elements(outtemp) NE 1) then stop
case (size(outtemp, /type)) of 
  7: restore, outtemp  ;; filename given
  8: output = outtemp  ;; output structure given
  else: stop
endcase

;; Make a plot window
p0 = MASCS_viewer(data, /keep)

end
