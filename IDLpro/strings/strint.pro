function strint, num, format=format

;; bytes don't work the way I want them to.
q = size(num, /type)
if (q EQ 1) then nn = fix(num) else nn = num

return, strtrim(string(nn, format=format), 2)

end
