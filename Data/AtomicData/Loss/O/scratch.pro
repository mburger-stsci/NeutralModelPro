;;make_crosssec_struct, 'McGrath1989-0.sigma.dat', s=s        
;;make_ratecoef_struct, s, s=s2                               
;;restore, s2
;;
;;plot, *ratecoef.v_rel, (*ratecoef.kappa)[0,*], /ylog
;;for i=1,24 do oplot, *ratecoef.v_rel, (*ratecoef.kappa)[i,*]

make_crosssec_struct, 'McGrath1989-1.sigma.dat', s=s        
make_ratecoef_struct, s, s=s2                               
restore, s2

plot, *ratecoef.v_rel, (*ratecoef.kappa)[0,*], /ylog, yr=[1e-10,1e-8]
for i=1,24 do oplot, *ratecoef.v_rel, (*ratecoef.kappa)[i,*]
stop

make_crosssec_struct, 'McGrath1989-2.sigma.dat', s=s        
make_ratecoef_struct, s, s=s2                               
restore, s2

plot, *ratecoef.v_rel, (*ratecoef.kappa)[0,*], /ylog
for i=1,24 do oplot, *ratecoef.v_rel, (*ratecoef.kappa)[i,*]
end
