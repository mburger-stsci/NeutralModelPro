closewin
SpatialDist = {type:'surface', use_map:0, longitude:[0,2*!pi], latitude:[-!pi/2,!pi/2], $
  exobase:1.}
geometry = {planet:'Mercury',StartPoint:'Mercury'}

input = {geometry:geometry, spatialdist:spatialdist}

output = {x0:ptr_new(0), y0:ptr_new(0), z0:ptr_new(0)}

surface_distribution, input, output, 1e5
longitude = (atan(*output.x0, -*output.y0) + 2*!pi) mod (2*!pi)
latitude = asin(*output.z0)

p0 = plot(longitude/!dtor, latitude/!dtor, symbol='.', xrange=[0,360], $
  xmajor=5, xminor=8, ymajor=3, yminor=8, yrange=[-90,90], dimensions=[800,1000], $
  layout=[1,3,1], linestyle=' ', font_size=16, xtitle='Longitude ($\circ$)', $
  ytitle='Latitude ($\circ$)', title='Uniform Surface distribution', /aspect_ratio)
p0.refresh, /disable

input.SpatialDist.longitude = [30,200]*!dtor
input.SpatialDist.latitude = [-90,20]*!dtor

surface_distribution, input, output, 1e4
longitude = (atan(*output.x0, -*output.y0) + 2*!pi) mod (2*!pi)
latitude = asin(*output.z0)

p1 = plot(longitude/!dtor, latitude/!dtor, symbol='.', xrange=[0,360], $
  xmajor=5, xminor=8, ymajor=3, yminor=8, yrange=[-90,90], /current, $
  layout=[1,3,2], linestyle=' ', font_size=16, xtitle='Longitude ($\circ$)', $
  ytitle='Latitude ($\circ$)', title='Uniform Surface distribution with bounds', $
  /aspect_ratio)

input.SpatialDist.longitude = [200,30]*!dtor
input.SpatialDist.latitude = [-90,20]*!dtor

surface_distribution, input, output, 1e4
longitude = (atan(*output.x0, -*output.y0) + 2*!pi) mod (2*!pi)
latitude = asin(*output.z0)

p2 = plot(longitude/!dtor, latitude/!dtor, symbol='.', xrange=[0,360], $
  xmajor=5, xminor=8, ymajor=3, yminor=8, yrange=[-90,90], /current, $
  layout=[1,3,3], linestyle=' ', font_size=16, xtitle='Longitude ($\circ$)', $
  ytitle='Latitude ($\circ$)', title='Uniform Surface distribution with bounds', $
  /aspect_ratio)

t0 = text(.1, .98, /norm, font_size=16, '(a)')
t1 = text(.1, .64, /norm, font_size=16, '(b)')
t2 = text(.1, .31, /norm, font_size=16, '(c)')
p0.refresh

p0.save, 'figures/surfdist0.png', width=800
p0.close
;;;;

p0 = plot3d(*output.x0, *output.y0, *output.z0, symbol='.', linestyle=' ', $
  /aspect_ratio, /aspect_z, xrange=[-1.5,1.5], yrange=[-1.5,1.5], zrange=[-1.5,1.5], $
  dimensions=[800,800])


end
