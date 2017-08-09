function headername, outputfile

nf = n_elements(outputfile)
result = strarr(nf)
for i=0,nf-1 do result[i] = strmid(outputfile[i], 0, strlen(outputfile[i])-6) + 'header'

if (nf EQ 1) then result = result[0]

return, result

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function outputname, headerfile

nf = n_elements(headerfile)
result = strarr(nf)
for i=0,nf-1 do result[i] = strmid(headerfile[i], 0, strlen(headerfile[i])-6) + 'output'

return, result

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function output_filename, inputtemp, path=path, file=file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Create a unique output filename
;; 
;; These are not user readable fileneames to keep them short. The header files 
;; are user readable.
;;
;; path = '/Volumes/DroboData/burger/modeloutputs/PLANET/' + 
;;              TAA_DEG/ATOM/SPEEDDIST/SPATIALDIST/'  or 
;;              MOON/PHI_DEG/ATOM/SPEEDDIST/SPATIALDIST/'
;; file = 'USER.HOSTNAME.####.output'
;;
;; Version History
;; 3.6: 11/30/2012
;;   * adding support for streamline models
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

common constants

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
  (stuff EQ !null): basepath = !model.LocalOutputPath
  (stuff.local) and (loc): basepath = !model.LocalOutputPath 
  ~(stuff.local) and (sh): basepath = !model.SharedOutputPath
  else: stop
endcase

if (input.options.streamlines) then begin
  case (1) of 
    stregex(!model.user, 'burger', /bool): basepath = file_dirname(basepath, /mark) + $
      'streamoutputs/'
    stregex(!model.user, 'killen', /bool): basepath = file_dirname(basepath, /mark) + $
      'streamoutputs/'
    stregex(!model.user, 'tica9197', /bool): basepath = basepath + 'streamoutputs/'
    stregex(!model.user, 'merkel', /bool): basepath = basepath + 'streamoutputs/'
    else: stop
  endcase
endif

path = basepath + path
if ~(file_test(path)) then file_mkdir, path

;; Create the filename
filest = !model.user + '.' + !model.hostname + '.' 

q = file_search(path, filest+'*.output', count=nq)

if (nq EQ 0) $
  then filename = filest + '0000.output' $
  else begin
    file = file_basename(q, '.output')
    num = max(ulong(stregex(file, '[0-9]+$', /extract))) + 1
    case (1) of 
      (num LT 10): nn = '000' + strint(num)
      (num LT 100): nn = '00' + strint(num)
      (num LT 1000): nn = '0' + strint(num)
      else: nn = strint(num)
    endcase
    filename = filest + 'v' + strint(!model.version) + '.' + nn + '.output'
  endelse
if file_test(path+filename) then stop

return, path+filename

end
