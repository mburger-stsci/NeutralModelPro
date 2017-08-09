function decstr, num

str = strarr(n_elements(num))
for i=0,n_elements(num)-1 do begin
  if (num[i] EQ fix(num[i])) then str[i] = strint(fix(num[i])) else begin
    ii = strint(num[i])
    jj = strsplit(double(num[i]), '.', /extract)
    e = stregex(jj[1], '0+$', len=l)
    if (e NE -1) $
      then str[i] = jj[0] + 'p' + strmid(jj[1], 0, e) $
      else str[i] = jj[0] + 'p' + jj[1]
  endelse
endfor

str = strcompress(str, /remove_all)
if (n_elements(str) EQ 1) then str = str[0]
return, str

end
