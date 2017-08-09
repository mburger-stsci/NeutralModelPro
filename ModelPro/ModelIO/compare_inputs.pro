function compare_inputs_value, value0, value1, tagname

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Compares two values when given a tagname
;; For floating point values, an acceptable tolerance is specified. 
;; Otherwise, the values have to be exact
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

same = array_equal(value0, value1) ;; first do quick check
if ~(same) then begin  ;; Now check to see if things are close
  if (n_elements(value0) EQ n_elements(value1)) then begin
    case strlowcase(tagname) of 
      'phi': tol = 3.0*!dtor  ;; 3 degree tolerance
      'cml': tol = 3.0*!dtor  ;; 3 degree tolerance
      'taa': tol = 2.5*!dtor  ;; 3 degree tolerance
      'lifetime': tol = min(abs([value0,value1]) * 0.05)  ;; 5% tolerance
      'endtime': tol = min([value0,value1]) * 0.05  ;; 5% tolerance
      'temperature': tol = 1.*(value0 NE 0)*(value1 NE 0) ; 1 deg unless one = 0
      'outeredge': tol = min([value0,value1]) * 0.05 ;; 5% tolerance
      'longitude': tol = 1*!dtor
      'latitude': tol = 1*!dtor
      'stickcoef': tol = 0.01
      'accom_factor': tol = 0.01
      'kappa': tol = 0.1
      'diffusionlimit': tol = min([value0,value1]) * 0.01
      'n': tol = 0.01
      'u': tol = 0.01
      'alpha': tol = 0
      'beta': tol = 0
      'vprob': tol = 0.01
      'sigma': tol = 0.01
      'altitude': tol = 1*!dtor
      'azimuth': tol = 1*!dtor
      'include': tol = 0
      'subsolarlong': tol = 3*!dtor
      'subsolarlat': tol = 1*!dtor
      else: stop
    endcase
    same = (max(abs(value0-value1)) LE tol)
  endif else same = 0  ;; different number of elements
endif

return, same

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function compare_inputs, input0temp, input1temp, verbose=verbose

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Make a comparison between two input files
;;
;; Version 3.0: 21 Dec 2010
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if (verbose EQ !null) then verbose = 0

input0 = (isa(input0temp, 'string')) ? inputs_restore(input0temp) : input0temp
input1 = (isa(input1temp, 'string')) ? inputs_restore(input1temp) : input1temp

;; Check top level structure
t0 = tag_names(input0) & t1 = tag_names(input1)
q0 = sort(t0) & q1 = sort(t1)

same = 1
if (array_equal(t0[q0], t1[q1])) then begin
  ;; Compare next level down
  i = 0
  while ((i LT n_elements(t0)) and (same)) do begin
    if (~strcmp(t0[q0[i]], t1[q1[i]])) then stop
    struct0 = input0.(q0[i]) & struct1 = input1.(q1[i])
    s0 = tag_names(struct0) & s1 = tag_names(struct1)
    w0 = sort(s0) & w1 = sort(s1)

    if (array_equal(s0[w0], s1[w1])) then begin
      ;; Compare values of each tag
      j = 0
      while ((j LT n_elements(s0)) and (same)) do begin
        if (~strcmp(s0[w0[j]], s1[w1[j]])) then stop

	;; make sure types are the same, lengths are the same, values are the same
	value0 = struct0.(w0[j]) & value1 = struct1.(w1[j])
	type0 = size(value0, /type) & type1 = size(value1, /type)
	case (1) of 
	  (type0 NE type1): same = 0 
	  (type0 EQ 10): $ ;; value0 and value1 are pointers
	    same = compare_inputs_value(*value0, *value1, s0[w0[j]])
	  (type0 EQ 4) or (type0 EQ 5): $ ;; value0 and value1 are floats
	    same = compare_inputs_value(value0, value1, s0[w0[j]])
	  else: same = array_equal(value0, value1) ;; byte or integer
	endcase
	if (~same and verbose) then begin
	  print, '0 failed at = ' + s0[w0[j]]
	  print, value0, value1
;	  if strcmp(s0[w0[j]], 'lifetime', /fold) then stop
	endif
	j++
      endwhile
      i++
    endif else begin
      same = 0
      if (verbose) then print, '1 failed at ' + t0[q0[i]]
    endelse
  endwhile
endif else begin
  same = 0
  if (verbose) then begin
    q = strcmp(t0[q0], t1[q1])
    w = where(q EQ 0, nw)
    print, '2 Failed at Top Level', xxx
    for i=0,nw-1 do $
      print, '  input0.' + t0[q0[w[i]]] + '; input1.' + t1[q1[w[i]]], xxx
  endif
endelse

return, same

end
