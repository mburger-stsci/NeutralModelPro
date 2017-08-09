function extract_parameter, parameter, filelist

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Searches through the given filelist for the specified parameter
;; Returns the list as a hash with key=filename, value=scalar or array
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

temp = filelist
w = where(stregex(filelist, '.output', /bool), nw)
if (nw GT 0) then temp[w] = headername(filelist[w])

if (n_elements(temp) EQ 1) then filetemp = temp 
if (n_elements(temp) GT 1900L) then begin
  error = ''
  list = ''
  for i=0L,n_elements(temp)-1 do begin
    spawn, 'grep -ir ' + parameter + ' ' + temp[i], ltemp, etemp
    if (etemp NE '') then stop
    if (ltemp NE '') then list = [list, ltemp]
  endfor 
  if (n_elements(list) GT 1) then list = list[1:*]
endif else begin
  filetemp = temp[0]
  for i=1,n_elements(temp)-1 do filetemp += ' ' + temp[i]
  q = strsplit(filetemp, '<', /extract)
  if (n_elements(q) GT 1) then begin
    filetemp = q[0]
    for i=1,n_elements(q)-1 do filetemp += '\<' + q[i]
  endif

  q = strsplit(filetemp, '>', /extract)
  if (n_elements(q) GT 1) then begin
    filetemp = q[0]
    for i=1,n_elements(q)-1 do filetemp += '\>' + q[i]
  endif

  spawn, 'grep -ir ' + parameter + ' ' + filetemp, list, error
endelse

if (error NE '') then stop
if (list[0] EQ '') then result = !null else begin
  res0 = strarr(n_elements(list))
  res1 = strarr(n_elements(list))
  for i=0,n_elements(list)-1 do begin
    x = strsplit(list[i], ':|=', /regex, /extract)
    if (n_elements(x) EQ 2) then begin
      res0 = filelist
      res1 = strtrim(x[1], 2)
    endif else begin
      res0[i] = strtrim(x[0], 2)
      res1[i] = strtrim(x[2], 2)
    endelse
  endfor

  u = uniq(res0, sort(res0)) & nu = n_elements(u)
  if (nu NE n_elements(list)) then begin
    ;; Some parameters were repeated
    ulist = (res0[sort(res0)])[u]
    result = hash()
    for i=0,nu-1 do begin
      w = where(res0 EQ ulist[i], nw)
      if (nw EQ 1) $
	then result = result + hash(ulist[i], res1[w[0]]) $
	else result = result + hash(ulist[i], res1[w])
    endfor
  endif else result = hash(res0, res1) 
endelse

return, result

end

