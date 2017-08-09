pro physical_constants

;; Note -- changing from !const to !physconsts to avoid conflict in updated IDL (8.3?)

defsysv, '!physconst', exists=e

if ~(e) then begin
  print, '**** Setting physical constants system variable !PHYSCONST ****'

  defsysv, '!physconst', {constants, $
    AU: 149.598d11, $	;; Astronomical Unit (cm)
    c: 299792458d2, $	;; speed of light (cm/s)
    AMU: 1.660538d-24, $	;; atomic mass unit (g)
    mp: 1.672621d-24, $	;; proton mass (g)
    me: 9.109382d-28, $	;; electron mass (g)
    kb: 1.38065d-16, $	;; Boltzmann constant (erg/K)
    erg_eV: 1.602176d-12, $	;; Energy of 1 eV (erg/eV)
    K_eV: 1.1604d4, $ 	;; Temperature of 1 eV (K/eV)
    G: 6.67428d-8, $		;; Gravitational Constant (dyne cm^2/g^2)
    h: 6.626069d-27, $	;; Planck Constant (erg s)
    sec_year: 31556926d, $
    esu: 4.8032e-10, $    ;; ESU (statcoul)
    contents: strarr(12) $
  }

  !physconst.contents = ['AU = astronomical unit (cm)', $
		     'c = speed of light (cm/s)', $
		     'AMU = atomic mass unit (g)', $
		     'mp = proton mass (g)', $
		     'me = electron mass (g)', $
		     'kb = Boltzmann constant (erg/K)', $
		     'erg_eV = energy of 1 eV (erg/eV)', $
		     'K_eV = Temperature of 1 eV (K/eV)', $
		     'G = Gravitational Constant (dyne cm^2/g^2)', $
		     'h = Planck Constant (erg s)', $
		     'sec_year = number of seconds in one sidereal year', $
		     'ESU = elementary charge (statcoul)']

endif
end
