pro MESSENGER_orbittime, oname, tstart=tstart, tend=tend, tca=tca

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file contains the following routines:
;;   * MESSENGER_orbittime: For a given orbit number, given the start and end times
;;   * MESSENGER_orbit: For a given ET, determine the orbit number
;;   * orbit_string: For an intenger orbit number, give the string name
;;   * orbit_number: For a string orbit name, give the integer number
;;   * MESSENGER_taa: Given an orbit number or a time, returns the Mercury TAA
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; pro MESSENGER_orbittime
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; For a given orbit number, give the start and end times
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (size(oname, /tname) EQ 'STRING') then orbnum = orbit_number(oname)
orbnum = floor(oname) 
no = n_elements(orbnum)
tstart = dblarr(no) & tend = dblarr(no) & tca = dblarr(no)

defsysv, '!model', exists=e
if (e) $
  then restore, !model.basepath + 'Data/MESSENGER/MESSENGER.orbitdata.sav' $ 
  else restore, '~/Data/MESSENGER/MESSENGER.orbitdata.sav'

for i=0,no-1 do begin
  q = (where(*orbit_data.orbit EQ orbnum[i], nq))[0]
  if (nq NE 0) then begin
    tstart[i] = (*orbit_data.t_apoapse)[q]
    tend[i] = (*orbit_data.t_apoapse)[q+1]
    tca[i] = (*orbit_data.t_periapse)[q]
  endif
endfor

if (no EQ 1) then begin
  tstart = tstart[0]
  tend = tend[0]
  tca = tca[0]
endif

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function MESSENGER_orbit, time

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; For a given time, determine the MESSENGER orbit number
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

defsysv, '!model', exists=e
if (e) $
  then restore, !model.basepath + 'Data/MESSENGER/MESSENGER.orbitdata.sav' $ 
  else restore, '~/Data/MESSENGER/MESSENGER.orbitdata.sav'

t = size(time, /type)
case (t) of 
  7: time2 = utc2et(time)
  5: time2 = time
endcase

q = floor(interpol(indgen(n_elements(*orbit_data.orbit)), *orbit_data.t_apoapse, time2))
if ((min(q) LT 0) or (max(q) GE n_elements(*orbit_data.orbit))) then stop

orbnum = (*orbit_data.orbit)[q]

return, orbnum

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function orbit_string, onum

n = n_elements(onum)
ostring = strarr(n)

for i=0,n-1 do $
  case (1) of
    (onum[i] LT 0): ostring[i] = 'M' + strint(abs(onum[i]))
    (onum[i] LT 10): ostring[i] = 'Orbit000' + strint(onum[i])
    (onum[i] LT 100): ostring[i] = 'Orbit00' + strint(onum[i])
    (onum[i] LT 1000): ostring[i] = 'Orbit0' + strint(onum[i])
    else: ostring[i] = 'Orbit' + strint(onum[i])
  endcase

if (n EQ 1) then ostring = ostring[0]

return, ostring

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function orbit_number, ostring

n = n_elements(ostring)
onum = replicate(-99, n)

m = where(strcmp(strmid(ostring, 0, 1), 'M', /fold), nm)
o = where(strcmp(strmid(ostring, 0, 1), 'O', /fold), no)

if (nm NE 0) then onum[m] = -fix(strmid(ostring[m], 1))
if (no NE 0) then onum[o] = fix(strmid(ostring[o], 5))

return, onum

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function MESSENGER_taa, input

defsysv, '!model', exists=e
if (e) $
  then restore, !model.basepath + 'Data/MESSENGER/MESSENGER.orbitdata.sav' $ 
  else restore, '~/Data/MESSENGER/MESSENGER.orbitdata.sav'

t = size(input, /type)
case (t) of 
  2: onum = input  ;; orbit number is given
  7: onum = MESSENGER_orbit(input)  ;; string time is given
  5: onum = MESSENGER_orbit(input) ;; et is given
  else: stop
endcase

q = (where(*orbit_data.orbit EQ onum, nq))[0]
if (nq EQ 0) then begin
  print, 'Not a valid time or orbit number given.'
  taa = -1
endif else taa = (*orbit_data.geometry_peri.taa)[q]

return, taa

end
