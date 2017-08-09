pro print_inputs, inputtemp, file, printarr=printarr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Prints the content of an input structure to the screen
;;
;; Version History
;;   3.0: 7/19/10
;;     * created
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

input = (isa(inputtemp, 'string')) ? inputs_restore(inputtemp) : inputtemp

itags = strlowcase(tag_names(input))
printarr = !null
for t=0,n_elements(itags)-1 do begin
  t0 = input.(t)
  tags = itags[t] + '.' + strlowcase(tag_names(t0))
  for i=0,n_elements(tags)-1 do begin
    val = t0.(i)
    case size(val, /type) of 
      7: 
      10: val = strint(*val)
      else: val = strint(val)
    endcase

    printarr = [printarr, tags[i] + ' = ' + val]
  endfor
  printarr = [printarr, '']
endfor

if (file EQ !null) $
  then hprint, printarr $
  else begin
    openw, lun, file, /get_lun
    for i=0,n_elements(printarr)-1 do printf, lun, printarr[i]
    free_lun, lun
  endelse

end
