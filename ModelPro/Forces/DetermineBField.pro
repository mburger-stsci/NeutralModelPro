function DetermineBfield, loc, input

common constants

case (input.geometry.planet) of
  'Mercury': begin   
    ;; Mercury dipole field
    x = (*loc.x)[*,0]
    y = (*loc.x)[*,1]
    z = (*loc.x)[*,2]-DipoleConsts.offset
    r = sqrt(x^2 + y^2 + z^2)
    Bx = 3*x*z*DipoleConsts.strength*r^(-5)
    By = 3*y*z*DipoleConsts.strength*r^(-5)
    Bz = (3*z^2-r^2)*DipoleConsts.strength*r^(-5)
    end
  else: stop
endcase

Bfield = {Bx:ptr_new(Bx), By:ptr_new(By), Bz:ptr_new(Bz)}
return, Bfield

end

