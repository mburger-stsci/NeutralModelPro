pro destroy_structure, structure

t = size(structure, /type)
if (t EQ 8) then begin
  tags = tag_names(structure)
  for i=0,n_elements(tags)-1 do begin
    t = (size(structure.(i), /type))
    case t of 
      10: if (total(ptr_valid(structure.(i))) GT 0) then ptr_free, structure.(i)
      8: destroy_structure, structure.(i)
      else:
    endcase
  endfor
endif

end

