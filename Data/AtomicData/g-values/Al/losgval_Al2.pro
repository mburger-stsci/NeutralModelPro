	pro los_gval

	f1name='solar_Al3092.txt'
	f2name='solar_Al394.txt'

	f3name='solar_Al396.txt'

	f4name='g_val_Al_May14.txt'

	openr, 1, f1name
	openr, 2, f2name

	openr, 3, f3name

	openw, 4, f4name

	amuh=1.673D-24

	amuAl=26.d0

        clight=2.998d10

       	 h=6.624d-27
	hc=1.986E-16

       	 abscoef= 2.647d-2

	R=0.389
	temp=1200.0

	v0=9.69

;	v0=0.0

	TAA=127.7d0
	k=1.38E-16
	kT=k*temp
	lev2=112.06
	poplev2=exp(-hc*lev2/kT)

;

;

	D1=308.21529

	D2=309.271

	D3=309.28386

	D4=394.4006

	D5=396.1520

	dellamD1=-D1*v0*1.E5/2.998E10

	dellamD2=-D2*v0*1.E5/2.998E10

	dellamD3=-D3*v0*1.E5/2.998E10

	dellamD4=-D4*v0*1.E5/2.998E10

	dellamD5=-D5*v0*1.E5/2.998E10

	lamD1=D1+dellamD1

	lamD2=D2+dellamD2
	lamD3=D3+dellamD3

	lamD4=D4+dellamD4
	lamD5=D5+dellamD5
	anuD1=clight*1.D7/lamD1
	anuD2=clight*1.D7/lamD2

	anuD3=clight*1.D7/lamD3
	anuD4=clight*1.D7/lamD4

	anuD5=clight*1.D7/lamD5

	print, anuD1, anuD2, anuD3, anuD4, anuD5
	endj=250

	for j=0,endj do begin

	readf,1, lam, dum, conti

	if lam lt lamD1 then begin 

	lamstart = lam 

	contstart=conti 

	endif else begin

	frac=(lamD1-lamstart)/(lam - lamstart)

	contD1=frac*(conti-contstart) + contstart
	lamstart=lam
	goto, jump1
	endelse
	endfor
	jump1: print, contD1
	close, 1
	openr, 1, f1name
	for j=0,endj do begin

	readf,1, lam, dum, conti

	if lam lt lamD2 then begin 

	lamstart = lam 

	contstart=conti 

	endif else begin

	frac=(lamD2-lamstart)/(lam - lamstart)

	contD2=frac*(conti-contstart) + contstart
	lamstart=lam
	goto, jump2
	endelse
	endfor
	jump2: print, contD2
	close, 1
	openr, 1, f1name
	for j=0,endj do begin

	readf,1, lam, dum, conti

	if lam lt lamD3 then begin 

	lamstart = lam 

	contstart=conti 

	endif else begin

	frac=(lamD3-lamstart)/(lam - lamstart)

	contD3=frac*(conti-contstart) + contstart
	goto, jump3

	endelse

	endfor
	jump3: print, contD3
	close, 1

	endj=400

	for j=0,endj do begin

	readf,2, lam, dum, conti

	if lam lt lamD4 then begin 

	lamstart = lam 

	contstart=conti 

	endif else begin

	frac=(lamD4-lamstart)/(lam - lamstart)

	contD4=frac*(conti-contstart) + contstart
	goto, jump4
	lamstart=lam
	endelse
	endfor
	jump4: print, contD4
	for j=0,endj do begin

	readf,3, lam, dum, conti

	if lam lt lamD5 then begin 

	lamstart = lam 

	contstart=conti 

	endif else begin

	frac=(lamD5-lamstart)/(lam - lamstart)

	contD5=frac*(conti-contstart) + contstart
	goto, jump5

	endelse

	endfor
	jump5: print, contD5

;   10   CONTINUE

;	calculate gvals

;	print, d1, lamd1,dellamD1,  cont

;

	intf=2.647E-2

;	calculate gvals

;

; 

	fD1=0.180

	c=2.998E10

	h=6.624E-27

	energ=h*c*1.E7/lamD1

	lamfac=lamD1^2*1.E-6/c
	albedo=0.84

	gvalD1=albedo*intf*fD1*contD1*lamfac/energ/R^2

;

	fD2=0.16

	energ=h*c*1.E7/lamD2

	lamfac=lamD2^2*1.E-6/c
	albedo=1.

	gvalD2=intf*fD2*contD2*lamfac/energ/R^2
;
	fD3=0.0170

	energ=h*c*1.E7/lamD3

	lamfac=lamD3^2*1.E-6/c
	albedo=0.16

	gvalD3=albedo*intf*fD3*contD3*lamfac/energ/R^2

;

	fD4=0.115

	energ=h*c*1.E7/lamD4

	lamfac=lamD4^2*1.E-6/c
	poplevs=0.3346

	gvalD4=poplevs*intf*fD4*contD4*lamfac/energ/R^2
;

	fD5=0.12

	energ=h*c*1.E7/lamD5

	lamfac=lamD5^2*1.E-6/c
	poplevs=0.665

	gvalD5=poplevs*intf*fD5*contD5*lamfac/energ/R^2
;
                  radpressva= h/clight/amuAl/amuh

                  radp1= anuD1*radpressva

                  radp2=  anuD2*radpressva

                  radp3=  anuD3*radpressva

                  radp4=  anuD4*radpressva

                  radp5=  anuD5*radpressva

                  radpressv= gvalD1*radp1+gvalD2*radp2+gvalD3*radp3+gvalD4*radp4+gvalD5*radp5

	beta=radpressv/370.

	print, 'RADPRESS ', 'beta ', 'gval3082 ',' gval3092' ,'gval3092b', 'gval3944', 'gval3961'

                   print, radpressv,beta,  gvalD1, gvalD2, gvalD3, gvalD4, gvalD5 

	printf,4,'heliocentric distance=', R
	printf,4, 'gval3082 ',' gval3092' ,'gval3092b', 'gval3944', 'gval3961'

	printf,4, gvalD1, gvalD2, gvalD3, gvalD4, gvalD5 

;	end

;	print,gval, $

;        format="(' gval=', e12.5)"

;	endif

;	    close, 1

   	    close, 2

   	    close, 3 

   	    close, 4 

	end


	

	 

	



