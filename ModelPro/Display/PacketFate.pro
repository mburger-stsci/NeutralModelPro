function PacketFate, input

files = modeloutput_search(input)

hit_frac = 0.
left_frac = 0.
ion_frac = 0. & ion_frac2 = 0
here_frac = 0.
npackets = 0.

for j=0,n_elements(files)-1 do begin
  restore, files[j]
  index = (*output.index)[uniq(*output.index, sort(*output.index))]

  for i=0,n_elements(index)-1 do begin
    q = where(*output.index EQ i, nq)
    x = (*output.x)[q] & y = (*output.y)[q] & z = (*output.z)[q]
    f = (*output.frac)[q] & t = input.options.endtime - (*output.time)[q]
    hit = (*output.hitfrac)[q] & loss = (*output.lossfrac)[q]
    left = (*output.leftfrac)[q]
    r = sqrt(x^2 + y^2 + z^2)

    ion_frac2 += loss[-1]

    ;; keep track of stuff that stuck on bounces
    hit_frac += hit[-1]

    npackets += f[0]
    case (1) of 
      (r[-1] LT 1.05): begin
	;; assume it hit the surface
	hit_frac += f[-1] 
	ion_frac += (1-f[-1])
	end
      ~(input.options.fullsystem) and (r[-1] GT 0.95*input.options.outeredge): begin 
	;; assume it escaped
	left_frac += f[-1]
	ion_frac += (1-f[-1])
	end
      else: begin
	;; packet is still there
	here_frac += f[-1]
	ion_frac += (1-f[-1])
	end
    endcase
  endfor
  print, 'Finished file ' + strint(j+1) + ' of ' + strint(n_elements(files))
endfor

result = {left_frac:left_frac/npackets, ion_frac:ion_frac/npackets, $
  hit_frac:hit_frac/npackets, remain_frac:here_frac/npackets}

print, 'Escaping fraction = ' + strint(result.left_frac)
print, 'Ionized fraction = ' + strint(result.ion_frac)
print, 'Hit fraction = ' + strint(result.hit_frac)
print, 'Remaining fraction = ' + strint(result.remain_frac)
print, 'Total fraction = ' + strint(result.left_frac + result.ion_frac + $
  result.hit_frac + result.remain_frac)

return, result

end

