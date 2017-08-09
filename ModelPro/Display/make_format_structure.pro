function make_format_structure, params

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; To simuate a MESSENGER orbit use:
;;   IDL> params = list('MESSENGER', 'intensity', orbitnum, dphi, species) 
;;  or
;;   IDL> params = list('MESSENGER', 'column', orbitnum, dphi)
;;   
;;  where dphi is the cone half-angle (packet-s/c-boresight angle must be less than 
;;  dphi to be included). Species = 'Na', 'Mg', or 'Ca'. This needs to be included with 
;;  intensity so that it knows which line to use. For Na, it uses D1+D2.
;;
;;  To make a 2-D image use:
;;   IDL> params = list('Mercury', 'intensity', dim, width, plane, species)
;;  or
;;   IDL> params = list('Mercury', 'column', dim, width, plane)
;;   
;;  where dim = size of image, width = height and width of image in Mercury radii, and 
;;  plane = 'xy', 'xz', or 'yz'.
;;
;;  For dim, I usually use 501. An odd number insures that the center of Mercury is 
;;  centered on a pixel (in this case 250, with 0-249 on one side and 251-500 on the 
;;  other). Each axis in the final image goes from (-width/2) to (width/2). It is 
;;  actually possible to put the center of the image somewhere other than the center 
;;  of Mercury with the field format.geometry.center, but there probably isn't any 
;;  reason to do that. 
;;
;;  The axis are in model coordinates: The +x axis points to dusk, the +y axis points 
;;  away from the sun, and the +z axis points north. The xy-plane is the equatorial 
;;  plane (view from above the north pole), the xz-plane is the dawn-dusk plane (view 
;;  from the sun), and the yz-plane is the noon-midnight plane (view from above the 
;;  dusk point). You can change format.geometry.subobslongitude and 
;;  format.geometry.subobslatitude to view from any direction you want.
;;
;;  Written 2/27/2013
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Determine what type of structure to create

if (size(params[0], /type) NE 7) then begin
  print, 'params[0] must be a string.'
  stop
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make a MESSENGER format structure
if (strcmp(params[0], 'MESSENGER', /fold)) then begin
  ;; Break apart the array and do some tests

  quantity = params[1]
  if (total(strcmp(['intensity', 'column'], quantity, /fold)) NE 1) then begin
    print, 'params[2] must be ''intensity'' or ''column'' '
    stop
  endif

  onum = params[2]
  dphi = double(params[3])
  if (dphi GT 10*!dtor) then begin
    print, 'params[3] = dϕ in radians (dϕ < 0.175)'
    stop
  endif

  goodpts = (n_elements(params) EQ 6) ? params[5] : 0

  ;; Make a MESSENGER format structure
  geometry = {origin:'Mercury', $
    dr:0., $
    dphi:dphi, $
    dt:0., $
    spacecraft:'MESSENGER', $
    orbit:onum, $
    usedata:1}

  if (strcmp(quantity, 'intensity', /fold)) then begin
    species = params[4]
    case (species) of 
      'Ca': line = 4227.
      'Mg': line = 2852.
      'Na': line = [5891., 5897.]
      else: stop
    endcase
    emission = {mechanism:'resscat', line:line}

    format = {type:'los', quantity:'intensity', strength:1., geometry:geometry, $
      emission:emission, only_good_points:goodpts}
  endif else format = {type:'los', quantity:'column', strength:1., geometry:geometry, $
    only_good_points:goodpts}
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Make a Mercury 2D image format structure
if (strcmp(params[0], 'Mercury', /fold)) then begin
  quantity = params[1]
  if (total(strcmp(['intensity', 'column'], quantity, /fold)) NE 1) then begin
    print, 'params[1] must be ''intensity'' or ''column'' '
    stop
  endif

  dim = params[2]
  width = double(params[3])
  plane = params[4]
  case strlowcase(plane) of 
    'xy': begin
	  subobslongitude = 0
	  subobslatitude = 1.5707963
	  end
    'xz': begin
	  subobslongitude = 0
	  subobslatitude = 0
	  end
    'yz': begin
	  subobslongitude = 4.71239
	  subobslatitude = 0
	  end
    else: begin
          print, 'params[4] must be ''xy'', ''xz'', or ''yz''.'
	  stop
	  end
  endcase

  geometry = {origin:'Mercury', $
    dims:[dim,dim], $
    center:[0,0], $
    width:[width,width], $
    subobslongitude:subobslongitude, $
    subobslatitude:subobslatitude, $
    polarangle:0}

  if (strcmp(quantity, 'intensity', /fold)) then begin
    species = params[5]
    case (species) of 
      'Ca': line = 4227.
      'Mg': line = 2852.
      'Na': line = [5891., 5897.]
      else: stop
    endcase
    emission = {mechanism:'resscat', line:line}

    format = {type:'image', quantity:'intensity', strength:1., geometry:geometry, $
      emission:emission}
  endif else $
    format = {type:'image', quantity:'column', strength:1., geometry:geometry}
endif

return, format

end
