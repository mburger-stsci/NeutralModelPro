function display_hull, pts

;; pts = an array of points to look at computed by results_voronoi 
;;   (pts = *regions[i])

sz = size(pts)

hullfile = ('hull' + strint(round(random_nr(1)*1000000)) + '.dat')[0]
openw, lun, hullfile, /get_lun
printf, lun, sz[2]
printf, lun, sz[1]
printf, lun, transpose(pts)
free_lun, lun

spawn, 'qconvex s Fv TI hullpts.dat TO ' + hullfile
spawn, 'rm ' + hullfile

nfac = long(out[0])
facets = out[1:*]
if (n_elements(facets) NE nfac) then stop
connect = !null
for i=0,nfac-1 do begin
  w = long(strsplit(line, /extract)
  connect = [connect, w]
endfor

s0 = plot3d(pts[*,0], pts[*,1], pts[*,2], dimensions=[1000,1000], symbol='*', $
  linestyle=' ', /aspect_ratio, /aspect_z, /sym_filled)
s2 = polygon(pts[*,0], pts[*,1], pts[*,2], connectivity=connect, fill_color='blue', $
  fill_transparency=50, /data)

return, [s0, s1]

end
