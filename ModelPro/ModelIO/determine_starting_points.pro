pro determine_starting_points, geometry, SystemConsts

;; Need to determine TAA, phi, subsolarlong, subsolarlat for each object

geo = planet_geometry(geometry.time, geometry.planet)

geometry.taa = (*geo.taa)[0]

if (n_elements(*SystemConsts.objects) EQ 1) then begin
  *geometry.phi = 0d
  geometry.subsolarlong = (*geo.subslong)[0]
  geometry.subsolarlat = (*geo.subslat)[0]
endif else begin
  phi = dblarr(n_elements(*SystemConsts.objects))
  subslong = dblarr(n_elements(*SystemConsts.objects))
  subslong[0] = (*geo.subslong)[0]
  subslat = dblarr(n_elements(*SystemConsts.objects))
  subslat[0] = (*geo.subslat)[0]

  for i=1,n_elements(*SystemConsts.objects)-1 do begin
    geo = moon_geometry(geometry.time, (*SystemConsts.objects)[i])
    phi[i] = (*geo.phi)[0]
    subslong[i] = (*geo.subslong)[0]
    subslat[i] = (*geo.subslat)[0]
  endfor
  *geometry.phi = phi
  geometry.subsolarlong = subslong[0]
  geometry.subsolarlat = subslat[0]
endelse

end
