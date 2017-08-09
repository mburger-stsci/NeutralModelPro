function colortriple, num

colors = color(num)

tt = tag_names(!color)
triple = bytarr(3,n_elements(colors))
for i=0,n_elements(colors)-1 do begin
  q = (where(strmatch(tt, colors[i], /fold), nq))[0]
  if (nq NE 1) then stop
  triple[*,i] = !color.(q)
endfor

return, triple

end
