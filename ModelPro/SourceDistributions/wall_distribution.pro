pro wall_distribution, input, output, npack, seed

p0 = replicate(input.SpatialDist.p0, npack)
p1 = random_nr(npack, seed=seed)*((input.SpatialDist.range)[1]-$
 (input.SpatialDist.range)[0]) + (input.SpatialDist.range)[0]
p2 = random_nr(npack, seed=seed)*((input.SpatialDist.range)[1]-$
 (input.SpatialDist.range)[0]) + (input.SpatialDist.range)[0]

case (input.SpatialDist.axis) of 
  'x': begin
       *output.x0 = p0
       *output.y0 = p1
       *output.z0 = p2
       end
  'y': begin
       *output.y0 = p0
       *output.x0 = p1
       *output.z0 = p2
       end
  'z': begin
       *output.z0 = p0
       *output.x0 = p1
       *output.y0 = p2
       end
  else: stop
endcase

end

