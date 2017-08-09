function streamline_headername, outputfile

return, reform((strmid(outputfile, 0, strlen(outputfile)-6) + 'sthead')[0,*])

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function streamline_name, headerfile

return, reform((strmid(headerfile, 0, strlen(headerfile)-6) + 'stream')[0,*])

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function streamline_filename, inputtemp, path=path, file=file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Create a unique streamline filename
;; 
;; These are not user readable fileneames to keep them short. The header files 
;; are user readable.
;;
;; path = '/Volumes/DroboData/burger/modeloutputs/PLANET/' + 
;;              TAA_DEG/ATOM/SPEEDDIST/SPATIALDIST/'  or 
;;              MOON/PHI_DEG/ATOM/SPEEDDIST/SPATIALDIST/'
;; file = 'USER.HOSTNAME.####.stream'
;;
;; Version History
;; 3.4: 9/28/2011
;;   * adding option to search locally
;; 3.3: 3 Jan 2011
;;   * changing path to DroboData
;; 3.1: 26 August 2010
;;   * Making a bit more of a directory tree
;;   * Making filenames a bit more unique
;;   * adding computer identifier to avoid an ambiguity
;; 3.0: Original
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

input = (isa(inputtemp, 'string')) ? inputs_restore(inputtemp) : inputtemp
SystemConstants, input.geometry.planet,  sysc

;; Determine if startpoint = planet
s = (where(strcmp(*sysc.objects, input.geometry.startpoint, /fold)))[0]
sysc = 0

;; Create the path
path = input.geometry.planet + '/'

if (s EQ 0) then begin
  taastr = strint(round(input.geometry.taa/!dtor))
  path += taastr + '/'
endif else begin
  path += input.geometry.startpoint + '/'

  phistr = strint(round((*input.geometry.phi)[s]/!dtor))
  path += phistr + '/'
endelse

path += input.options.atom + '/' 
path += strlowcase(input.speeddist.type) + '/'
path += strlowcase(input.spatialdist.type) + '/'
path = strcompress(path, /remove_all)

sh = file_test(!model.SharedOutputPath)
loc = file_test(!model.LocalOutputPath)

case (1) of 
;;  (stuff EQ !null) and (sh): path = !model.SharedOutputPath + path
  (stuff EQ !null): path = !model.LocalOutputPath + path
  (stuff.local) and (loc): path = !model.LocalOutputPath + path 
  ~(stuff.local) and (sh): path = !model.SharedOutputPath + path
  else: stop
endcase

if ~(file_test(path)) then file_mkdir, path

;; Create the filename
filest = !model.user + '.' + !model.hostname + '.' 

q = file_search(path, filest+'*.stream', count=nq)

if (nq EQ 0) $
  then filename = filest + '0000.stream' $
  else begin
    file = file_basename(q, '.stream')
    num = max(fix(stregex(file, '[0-9]+$', /extract))) + 1
    case (1) of 
      (num LT 10): nn = '000' + strint(num)
      (num LT 100): nn = '00' + strint(num)
      (num LT 1000): nn = '0' + strint(num)
      else: nn = strint(num)
    endcase
    filename = filest + nn + '.stream'
  endelse
if file_test(path+filename) then stop

return, path+filename

end
