readcol, 'Huebner1992.dat', sp0, reac0, rate0, format='A,A,F', delim=':'
readcol, 'Huebner2011.dat', sp1, reac1, rate1, format='A,A,F', delim=':'

if ~(array_equal(sp0,sp1)) then stop
if ~(array_equal(reac0,reac1)) then stop

for i=0,n_elements(rate0)-1 do print, reac0[i], ' & ', rate0[i], ' & ', rate1[i], ' \\'

end
