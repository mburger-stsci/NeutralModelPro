pro box_distribution, input, output, npack, seed

*output.x0 = random_nr(npack, seed=seed)*((input.SpatialDist.xrange)[1] - $
  (input.SpatialDist.xrange)[0]) + (input.SpatialDist.xrange)[0]
*output.y0 = random_nr(npack, seed=seed)*((input.SpatialDist.yrange)[1] - $
  (input.SpatialDist.yrange)[0]) + (input.SpatialDist.yrange)[0]
*output.z0 = random_nr(npack, seed=seed)*((input.SpatialDist.zrange)[1] - $
  (input.SpatialDist.zrange)[0]) + (input.SpatialDist.zrange)[0]

end

