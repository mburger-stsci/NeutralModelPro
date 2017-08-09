	pro los_gval
	f1name='solar_hi_res_muv_spec.txt'
	f2name='g_val_Fe2522_merc.txt'
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
	v0=-9.37D0
;	v0=0.0
;	TAA=127.7d0
	k=1.38D-16
	kT=k*temp
	lev2=112.06D0
	poplev2=exp(-hc*lev2/kT)
;	poplev2=1.D0
;
;
;	D1=252.2849
	D1=252.3608
	dellamD1=-D1*v0*1.E5/2.998E10
	lamD1=D1+dellamD1
	anuD1=clight*1.D7/lamD1
	print, anuD1
	endj=10000
	for j=0,endj do begin
	readf,1, lam, conti
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
	out: print, j, contD1
;	D2=271.9027
	D2=271.9833
	dellamD2=-D2*v0*1.E5/2.998E10
	lamD2=D2+dellamD2
	anuD2=clight*1.D7/lamD2
	print, anuD2
	endj=10000
	for j=endj2,endj do begin
	readf,1, lam, conti
	if lam lt lamD2 then begin 
	lamstart = lam 
	contstart=conti 
	endif else begin
	frac=(lamD2-lamstart)/(lam - lamstart)
	contD2=frac*(conti-contstart) + contstart
	lamstart=lam
	endj2=endj-(j+1)
	goto, out2
	endj=j
	endelse
	endfor
	out2: print, j, contD2
;	calculate gvals
;
	intf=2.647D-2
;	calculate gvals
;
; 
	fD1=0.203D0
	c=2.998D10
	h=6.624D-27
;	energ=h*c*1.D7/lamD1
	lamfac=lamD1^2*1.D-6/c
	gvalD1=intf*fD1*contD1*lamfac/R^2
;
	fD2=0.122D0
	gi=9.
	gk=7.
	gigk=gi/gk
;	energ=h*c*1.D7/lamD2
	lamfac=lamD2^2*1.D-6/c
	gvalD2=intf*fD2*contD2*lamfac/R^2
;
                  radpressva= h/clight/amuFe/amuh
                  radp1= anuD1*radpressva
                  radpressv= gvalD1*radp1
;	beta=radpressv/370.
	beta=radpressv/162.D0
                  radp2= anuD2*radpressva
                  radpressv= gvalD2*radp2
;	beta2=radpressv/370.
	beta2=radpressv/162.D0
	print, '     RADPRESS ', '       beta1 ', '    beta2 ' ,'        gval2522 ',   'gval2719'
                   print, radpressv,beta,  beta2, gvalD1, gvalD2
	printf,2,'heliocentric distance=', R
	printf,2, '   RADPRESS ', '    beta ','    beta2', '    gval2522', '     gval2719'
	printf, 2, radpressv,beta,  beta2, gvalD1, gvalD2
	close, 1
	close, 2
	end
;        format="(' gval=', e12.5)"
;	endif
	    close, 1
   	    close, 2
	end
	
	 
	

