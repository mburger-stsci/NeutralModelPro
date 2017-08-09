function random_nr, n, seed=seed, routine=routine, compile=compile

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Written 20 October 2007
;; IDL calling routine for the c++ random number generators from Numerical 
;; Recipies, ch 7.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (n EQ 0) then stop
if (n GT 1000000L) then stop

defsysv, '!model', exists=e

if (e) then begin
  home = !model.basepath 
  if stregex(!model.user, 'killen', /fold, /bool) then routine = 0
  if stregex(!model.user, 'tica9197', /fold, /bool) then routine = 0
endif else begin
  spawn, 'echo $HOME', home 
  home += '/'
endelse
routine = 0

if (ul EQ !null) then ul=0
n = long(n)
result = dblarr(n)

if (seed EQ !null) $
  then ss = long(randomu(w)*1000000) $ 
  else ss = seed

if (n_elements(compile) EQ 0) then compile = 0
if (compile) then begin
  file = home + 'IDLpro/ran/ran.C'
  spawn, 'g++ -flat_namespace -m64 -c -fPIC ' + file, out, err
  if (err NE '') then stop

  spawn, 'g++ -bundle -dynamic -m64 -lm -lc -o ran.so ran.o', out, err
  if (err NE '') then stop
  
  spawn, 'mv ran.so ' + home + 'IDLpro/ran/'
  spawn, 'mv ran.o ' + home + 'IDLpro/ran/'
endif

if (routine EQ !null) then routine = 4
case (routine) of
  0: result = randomu(ss, n, /double)
  1: s = call_external(home+'IDLpro/ran/ran.so', $
    'ranq1_nr', ss, n, result, /auto_glue)
  2: s = call_external(home+'IDLpro/ran/ran.so', $
    'ranq2_nr', ss, n, result, /auto_glue)
  else: s = call_external(home+'IDLpro/ran/ran.so', $
    'ran_nr', ss, n, result, /auto_glue)
endcase
seed = long(result[0]*100000)

if (n EQ 1) then result = result[0]

return, result

end
