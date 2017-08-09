	pro los_gval
	f1name='Fe3859.txt'
	f2name='g_val_Fe3859_merc0903.txt'
	openr, 1, f1name
	openw, 2, f2name
	amuh=1.673D-24
	amuFe=56.d0
        clight=2.998d10
       	 h=6.624d-27
	hc=1.986D-16
       	 abscoef= 2.647d-2
	R=0.400D0
;	R=1.000
	temp=1200.D0
	v0=-9.35D0
;	v0=0.0
;	TAA=127.7d0
	k=1.38D-16
	kT=k*temp
	lev2=112.06D0
	poplev2=exp(-hc*lev2/kT)
;	poplev2=1.D0
;
;
	D1=385.99111
	dellamD1=-D1*v0*1.E5/2.998E10
	lamD1=D1+dellamD1
	anuD1=clight*1.D7/lamD1
	print, lamD1, anuD1
	endj=1000
	for j=0,endj do begin
	readf,1, lam, dum, conti
	if lam lt lamD1 then begin 
	lamstart = lam 
	contstart=conti 
	endif else begin
	frac=(lamD1-lamstart)/(lam - lamstart)
	contD1=frac*(conti-contstart) + contstart
	lamstart=lam
	endj2=endj-(j+1)
	goto, out
	endj=j
	endelse
	endfor
	out: print, lamD1, contD1
;	calculate gvals
;
	intf=2.647D-2
;	calculate gvals
;
; 
	fD1=0.0217D0
	c=2.998D10
	h=6.624D-27
	energ=h*c*1.D7/lamD1
	lamfac=lamD1^2*1.D-6/c
	albedo=0.969/1.28
	gvalD1=albedo*intf*fD1*contD1*lamfac/energ/R^2
	print, 'continuum', contD1/energ
         radpressva= h/clight/amuFe/amuh
	  print, radpressva
         radp1= anuD1*radpressva
	  print, radp1
         radpressv= gvalD1*radp1
	  print, radpressv
	beta=radpressv/370.D0
	printf,2,'heliocentric distance=', R
	printf,2, 'RADPRESS ', 'beta ', 'gval3859'
	printf,2, radpressv, beta,  gvalD1
;end
	close, 1
	close, 2
;
;
;	beta=radpressv/162.
	print, '     RADPRESS ', '       beta ', '         gval3859 '
                   print, radpressv,beta,  gvalD1
;	print,gval, $
;        format="(' gval=', e12.5)"
;	endif
	end
	
	 
	

