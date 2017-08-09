pro closewin

catch, err
if err NE 0 then return

q = getwindows()

for i=0,n_elements(q)-1 do q[i].close

end
