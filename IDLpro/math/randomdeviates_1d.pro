function RandomDeviates_1d, x, f_x, num, seed=seed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Randomly choose points from a 1D probability distribution using the 
;; Transformation method (see Numerical Recepies section 7.3.2)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sz = size(f_x)
if (n_elements(x) NE n_elements(f_x)) then stop
if (num EQ !null) then num = 1

;; Find the cumulative distribution function
sum = f_x
for i=0L,n_elements(f_x)-2 do sum[i+1] += sum[i]
sum -= min(sum) & sum /= max(sum)
result = interpol(x, sum, random_nr(seed=seed, num))

return, result

end
