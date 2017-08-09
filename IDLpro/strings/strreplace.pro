function strreplace, strings, find, replace

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; String find and replace. 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (size(strings, /type) NE 7) then stop
if ((n_elements(find) NE 1) or (size(find, /type) NE 7)) then stop
if ((n_elements(replace) NE 1) or (size(replace, /type) NE 7)) then stop

new = strarr(n_elements(strings))
for i=0,n_elements(strings)-1 do begin
  ;; figure out how many occurances there are of the string
  q = strpos(strings[i], find)
  while (q[-1] NE -1) do q = [q, strpos(strings[i], find, q[-1]+1)]

  parts = strsplit(strings[i], find, /extract)
  new[i] = (q[0] EQ 0) ? replace + parts[0] : parts[0]
  for j=1,n_elements(parts)-1 do new[i] += replace + parts[j]
  if (n_elements(q) GT 1) then if (q[-2]+strlen(find) EQ strlen(strings[i])) $
    then new[i] += replace
endfor

return, new

end
