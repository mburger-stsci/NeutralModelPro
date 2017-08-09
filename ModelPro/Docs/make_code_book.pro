files = file_search('~/Work/NeutralModel/modelpro/', '*.pro')
q = where(stregex(files, 'old', /bool), comp=w)
files = files[w]

q = where(stregex(files, 'Docs', /bool), comp=w)
files = files[w]

q = where(stregex(files, 'Examples', /bool), comp=w)
files = files[w]

q = where(stregex(files, 'Misc', /bool), comp=w)
files = files[w]

openw, 1, 'prolist.dat'
printf, 1, transpose(files)
close, 1

for i=0,n_elements(files)-1 do begin
  ii = (i LT 10) ? '0' + strint(i) + '-' : strint(i) + '-'
  psfile = 'codebook/' + ii + file_basename(files[i], '.pro') + '.ps'
  print, psfile
  spawn, 'vi -c ":ha > ' + psfile + '" ' + files[i]
  pspdf, psfile
  wait, 0.1
endfor

spawn, 'cat codebook/*.ps > codebook.ps'
pspdf, 'codebook.ps', /del

end
