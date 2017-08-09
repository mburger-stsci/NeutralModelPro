function data_cat, data0, data1

if (data0.species NE data1.species) then stop
if (data0.frame NE data1.frame) then stop

datanew = {species:data0.species, $
  UTC:ptr_new([*data0.UTC, *data1.UTC]), $
  mercyear:ptr_new([*data0.mercyear, *data1.mercyear]), $
  orbit:ptr_new([*data0.orbit,*data1.orbit]), $

  taa:ptr_new([*data0.taa, *data1.taa]), $
  rmerc:ptr_new([*data0.rmerc, *data1.rmerc]), $
  drdt:ptr_new([*data0.drdt, *data1.drdt]), $
  subslong:ptr_new([*data0.subslong, *data1.subslong]), $
  g:ptr_new([*data0.g, *data1.g]), $

  radiance:ptr_new([*data0.radiance, *data1.radiance]), $
  sigma:ptr_new([*data0.sigma, *data1.sigma]), $

  x:ptr_new([*data0.x, *data1.x]), $
  y:ptr_new([*data0.y, *data1.y]), $
  z:ptr_new([*data0.z, *data1.z]), $
  xbore:ptr_new([*data0.xbore, *data1.xbore]), $
  ybore:ptr_new([*data0.ybore, *data1.ybore]), $
  zbore:ptr_new([*data0.zbore, *data1.zbore]), $
  xcorner:ptr_new(0), $
  ycorner:ptr_new(0), $
  zcorner:ptr_new(0), $

  macro:ptr_new([*data0.macro, *data1.macro]), $
  obstype:ptr_new([*data0.obstype, *data1.obstype]), $
  obstype_num:ptr_new([*data0.obstype_num, *data1.obstype_num]), $
  filename:ptr_new([*data0.filename, *data1.filename]), $
  index:ptr_new([*data0.index, *data1.index]), $
  quality:ptr_new([*data0.quality, *data1.quality]), $

  xtan:ptr_new([*data0.xtan, *data1.xtan]), $
  ytan:ptr_new([*data0.ytan, *data1.ytan]), $
  ztan:ptr_new([*data0.ztan, *data1.ztan]), $
  rtan:ptr_new([*data0.rtan, *data1.rtan]), $

  alttan:ptr_new(0), $
  minalt:ptr_new([*data0.minalt, *data1.minalt]), $
  loctimetan:ptr_new([*data0.loctimetan, *data1.loctimetan]), $
  longtan:ptr_new(0), $
  lattan:ptr_new(0), $
  
  frame:data0.frame}

nn = n_elements(*datanew.x)
temp = fltarr(4,nn)
temp[0,*] = [reform((*data0.xcorner)[0,*]), reform((*data1.xcorner)[0,*])]
temp[1,*] = [reform((*data0.xcorner)[1,*]), reform((*data1.xcorner)[1,*])]
temp[2,*] = [reform((*data0.xcorner)[2,*]), reform((*data1.xcorner)[2,*])]
temp[3,*] = [reform((*data0.xcorner)[3,*]), reform((*data1.xcorner)[3,*])]
*datanew.xcorner = temp
temp[0,*] = [reform((*data0.ycorner)[0,*]), reform((*data1.ycorner)[0,*])]
temp[1,*] = [reform((*data0.ycorner)[1,*]), reform((*data1.ycorner)[1,*])]
temp[2,*] = [reform((*data0.ycorner)[2,*]), reform((*data1.ycorner)[2,*])]
temp[3,*] = [reform((*data0.ycorner)[3,*]), reform((*data1.ycorner)[3,*])]
*datanew.ycorner = temp
temp[0,*] = [reform((*data0.zcorner)[0,*]), reform((*data1.zcorner)[0,*])]
temp[1,*] = [reform((*data0.zcorner)[1,*]), reform((*data1.zcorner)[1,*])]
temp[2,*] = [reform((*data0.zcorner)[2,*]), reform((*data1.zcorner)[2,*])]
temp[3,*] = [reform((*data0.zcorner)[3,*]), reform((*data1.zcorner)[3,*])]
*datanew.zcorner = temp

temp = fltarr(5,nn)
temp[0,*] = [reform((*data0.alttan)[0,*]), reform((*data1.alttan)[0,*])]
temp[1,*] = [reform((*data0.alttan)[1,*]), reform((*data1.alttan)[1,*])]
temp[2,*] = [reform((*data0.alttan)[2,*]), reform((*data1.alttan)[2,*])]
temp[3,*] = [reform((*data0.alttan)[3,*]), reform((*data1.alttan)[3,*])]
temp[4,*] = [reform((*data0.alttan)[4,*]), reform((*data1.alttan)[4,*])]
*datanew.alttan = temp

temp[0,*] = [reform((*data0.longtan)[0,*]), reform((*data1.longtan)[0,*])]
temp[1,*] = [reform((*data0.longtan)[1,*]), reform((*data1.longtan)[1,*])]
temp[2,*] = [reform((*data0.longtan)[2,*]), reform((*data1.longtan)[2,*])]
temp[3,*] = [reform((*data0.longtan)[3,*]), reform((*data1.longtan)[3,*])]
temp[4,*] = [reform((*data0.longtan)[4,*]), reform((*data1.longtan)[4,*])]
*datanew.longtan = temp
temp[0,*] = [reform((*data0.lattan)[0,*]), reform((*data1.lattan)[0,*])]
temp[1,*] = [reform((*data0.lattan)[1,*]), reform((*data1.lattan)[1,*])]
temp[2,*] = [reform((*data0.lattan)[2,*]), reform((*data1.lattan)[2,*])]
temp[3,*] = [reform((*data0.lattan)[3,*]), reform((*data1.lattan)[3,*])]
temp[4,*] = [reform((*data0.lattan)[4,*]), reform((*data1.lattan)[4,*])]
*datanew.lattan = temp

return, datanew
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function data_extract, data, q

if ((*data.orbit)[0] LT 0) $
  then data2 = {species:data.species, $
    et:ptr_new((*data.et)[q]), $
    radiance:ptr_new((*data.radiance)[q]), $
    sigma:ptr_new((*data.sigma)[q]), $
    x:ptr_new((*data.x)[q]), $
    y:ptr_new((*data.y)[q]), $
    z:ptr_new((*data.z)[q]), $
    xbore:ptr_new((*data.xbore)[q]), $
    ybore:ptr_new((*data.ybore)[q]), $
    zbore:ptr_new((*data.zbore)[q]), $
    xcorner:ptr_new((*data.xcorner)[*,q]), $
    ycorner:ptr_new((*data.ycorner)[*,q]), $
    zcorner:ptr_new((*data.zcorner)[*,q]), $
    quality:ptr_new((*data.quality)[q]), $
    index:ptr_new((*data.index)[q]), $
    file:ptr_new((*data.file)[q]), $
    macro:ptr_new((*data.macro)[q]), $
    orbit:ptr_new((*data.orbit)[q]), $
    phase:ptr_new((*data.phase)[q]), $
    frame:data.frame} $ 
  else begin
    tags = tag_names(data)
    if (max(strcmp(tags, 'PHASE'))) then begin
      data2 = {species:data.species, $
	et:ptr_new((*data.et)[q]), $
	ymd:ptr_new((*data.ymd)[*,q]), $
	mercyear:ptr_new((*data.mercyear)[q]), $
	orbit:ptr_new((*data.orbit)[q]), $

	taa: ptr_new((*data.taa)[q]), $
	rmerc: ptr_new((*data.rmerc)[q]), $
	drdt: ptr_new((*data.drdt)[q]), $
	subslong: ptr_new((*data.subslong)[q]), $

	radiance:ptr_new((*data.radiance)[q]), $
	sigma:ptr_new((*data.sigma)[q]), $

	x:ptr_new((*data.x)[q]), $
	y:ptr_new((*data.y)[q]), $
	z:ptr_new((*data.z)[q]), $
	xbore:ptr_new((*data.xbore)[q]), $
	ybore:ptr_new((*data.ybore)[q]), $
	zbore:ptr_new((*data.zbore)[q]), $
	xcorner:ptr_new((*data.xcorner)[q,*]), $
	ycorner:ptr_new((*data.ycorner)[q,*]), $
	zcorner:ptr_new((*data.zcorner)[q,*]), $

	macro:ptr_new((*data.macro)[q]), $
	obstype:ptr_new((*data.obstype)[q]), $
	slit:ptr_new(0), $
	phase:ptr_new((*data.phase)[q]), $
	quality:ptr_new((*data.quality)[q]), $
	index:ptr_new((*data.index)[q]), $
	file:ptr_new((*data.file)[q]), $

	xtan:ptr_new((*data.xtan)[q]), $
	ytan:ptr_new((*data.ytan)[q]), $
	ztan:ptr_new((*data.ztan)[q]), $
	rtan:ptr_new((*data.rtan)[q]), $
	alttan:ptr_new((*data.alttan)[*,q]), $
	minalt:ptr_new((*data.minalt)[q]), $
	longtan:ptr_new((*data.longtan)[*,q]), $
	lattan:ptr_new((*data.lattan)[*,q]), $
	loctimetan:ptr_new((*data.loctimetan)[q]), $

	frame:data.frame}
    endif else begin
      data2 = {species:data.species, $
	UTC:ptr_new((*data.UTC)[q]), $
	mercyear:ptr_new((*data.mercyear)[q]), $
	orbit:ptr_new((*data.orbit)[q]), $

	taa: ptr_new((*data.taa)[q]), $
	rmerc: ptr_new((*data.rmerc)[q]), $
	drdt: ptr_new((*data.drdt)[q]), $
	subslong: ptr_new((*data.subslong)[q]), $
	g:ptr_new((*data.g)[q]), $

	radiance:ptr_new((*data.radiance)[q]), $
	sigma:ptr_new((*data.sigma)[q]), $

	x:ptr_new((*data.x)[q]), $
	y:ptr_new((*data.y)[q]), $
	z:ptr_new((*data.z)[q]), $
	xbore:ptr_new((*data.xbore)[q]), $
	ybore:ptr_new((*data.ybore)[q]), $
	zbore:ptr_new((*data.zbore)[q]), $
	xcorner:ptr_new((*data.xcorner)[*,q]), $
	ycorner:ptr_new((*data.ycorner)[*,q]), $
	zcorner:ptr_new((*data.zcorner)[*,q]), $

	macro:ptr_new((*data.macro)[q]), $
	obstype:ptr_new((*data.obstype)[q]), $
	obstype_num:ptr_new((*data.obstype_num)[q]), $
	filename:ptr_new((*data.filename)[q]), $
	index:ptr_new((*data.index)[q]), $
	quality:ptr_new((*data.quality)[q]), $

	xtan:ptr_new((*data.xtan)[q]), $
	ytan:ptr_new((*data.ytan)[q]), $
	ztan:ptr_new((*data.ztan)[q]), $
	rtan:ptr_new((*data.rtan)[q]), $
	alttan:ptr_new((*data.alttan)[*,q]), $
	minalt:ptr_new((*data.minalt)[q]), $
	longtan:ptr_new((*data.longtan)[*,q]), $
	lattan:ptr_new((*data.lattan)[*,q]), $
	loctimetan:ptr_new((*data.loctimetan)[q]), $

	frame:data.frame}
    endelse
  endelse

return, data2

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro data_subset, data, q

if ((*data.orbit)[0] LT 0) then begin
  *data.et = (*data.et)[q]
  *data.radiance = (*data.radiance)[q]
  *data.sigma = (*data.sigma)[q]
  *data.x = (*data.x)[q]
  *data.y = (*data.y)[q]
  *data.z = (*data.z)[q]
  *data.xbore = (*data.xbore)[q]
  *data.ybore = (*data.ybore)[q]
  *data.zbore = (*data.zbore)[q]
  *data.quality = (*data.quality)[q]
  *data.index = (*data.index)[q]
  *data.file = (*data.file)[q]
  *data.macro = (*data.macro)[q]
  *data.orbit = (*data.orbit)[q]
  *data.phase = (*data.phase)[q]
endif else begin
  tags = tag_names(data)
  if (max(strcmp(tags, 'PHASE'))) then begin
    *data.et = (*data.et)[q]
    *data.ymd = (*data.ymd)[*,q]
    *data.mercyear = (*data.mercyear)[q]
    *data.orbit = (*data.orbit)[q]

    *data.taa = (*data.taa)[q]
    *data.rmerc = (*data.rmerc)[q]
    *data.drdt = (*data.drdt)[q]
    *data.subslong = (*data.subslong)[q]

    *data.radiance = (*data.radiance)[q]
    *data.sigma = (*data.sigma)[q]

    *data.x = (*data.x)[q]
    *data.y = (*data.y)[q]
    *data.z = (*data.z)[q]
    *data.xbore = (*data.xbore)[q]
    *data.ybore = (*data.ybore)[q]
    *data.zbore = (*data.zbore)[q]
    *data.xcorner = (*data.xcorner)[q,*]
    *data.ycorner = (*data.ycorner)[q,*]
    *data.zcorner = (*data.zcorner)[q,*]

    *data.macro = (*data.macro)[q]
    *data.obstype = (*data.obstype)[q]
    *data.slit = 0
    *data.phase = (*data.phase)[q]
    *data.quality = (*data.quality)[q]
    *data.index = (*data.index)[q]
    *data.file = (*data.file)[q]

    *data.xtan = (*data.xtan)[q]
    *data.ytan = (*data.ytan)[q]
    *data.ztan = (*data.ztan)[q]
    *data.rtan = (*data.rtan)[q]
    *data.alttan = (*data.alttan)[*,q]
    *data.minalt = (*data.minalt)[q]
    *data.longtan = (*data.longtan)[*,q]
    *data.lattan = (*data.lattan)[*,q]
    *data.loctimetan = (*data.loctimetan)[q]
  endif else begin
    *data.UTC = (*data.UTC)[q]
    *data.mercyear = (*data.mercyear)[q]
    *data.orbit = (*data.orbit)[q]

    *data.taa = (*data.taa)[q]
    *data.rmerc = (*data.rmerc)[q]
    *data.drdt = (*data.drdt)[q]
    *data.subslong = (*data.subslong)[q]
    *data.g = (*data.g)[q]

    *data.radiance = (*data.radiance)[q]
    *data.sigma = (*data.sigma)[q]

    *data.x = (*data.x)[q]
    *data.y = (*data.y)[q]
    *data.z = (*data.z)[q]
    *data.xbore = (*data.xbore)[q]
    *data.ybore = (*data.ybore)[q]
    *data.zbore = (*data.zbore)[q]
    *data.xcorner = (*data.xcorner)[*,q]
    *data.ycorner = (*data.ycorner)[*,q]
    *data.zcorner = (*data.zcorner)[*,q]

    *data.macro = (*data.macro)[q]
    *data.obstype = (*data.obstype)[q]
    *data.obstype_num = (*data.obstype_num)[q]
    *data.filename = (*data.filename)[q]
    *data.index = (*data.index)[q]
    *data.quality = (*data.quality)[q]

    *data.xtan = (*data.xtan)[q]
    *data.ytan = (*data.ytan)[q]
    *data.ztan = (*data.ztan)[q]
    *data.rtan = (*data.rtan)[q]
    *data.alttan = (*data.alttan)[*,q]
    *data.minalt = (*data.minalt)[q]
    *data.longtan = (*data.longtan)[*,q]
    *data.lattan = (*data.lattan)[*,q]
    *data.loctimetan = (*data.loctimetan)[q]
  endelse
endelse

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function spectra_extract, spectra, q

spec2 = {$
  spectra:ptr_new((*spectra.spectra)[*,q]), $
  sigma:ptr_new((*spectra.sigma)[*,q]), $
  raw:ptr_new((*spectra.raw)[*,q]), $
  solar:ptr_new((*spectra.solar)[*,q]), $
  dark:ptr_new((*spectra.dark)[*,q]), $
  wavelength:ptr_new((*spectra.wavelength)[*,q])}

return, spec2

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function merkel_extract, merkel, q

merkel2 = {$
  BORESIGHT_UNIT_VECTOR_C1_TG:ptr_new((*merkel.BORESIGHT_UNIT_VECTOR_C1_TG)[*,q]), $
  BORESIGHT_UNIT_VECTOR_C2_TG:ptr_new((*merkel.BORESIGHT_UNIT_VECTOR_C2_TG)[*,q]), $
  BORESIGHT_UNIT_VECTOR_CENTER_TG:ptr_new((*merkel.BORESIGHT_UNIT_VECTOR_CENTER_TG)[*,q]), $

  CORR:ptr_new((*merkel.CORR)[*,q]), $
  DARK:ptr_new((*merkel.DARK)[*,q]), $
  DARK_PERCENT:ptr_new((*merkel.DARK_PERCENT)[q]), $
  FILENAME:ptr_new((*merkel.FILENAME)[q]), $
  IND_OBS:ptr_new((*merkel.IND_OBS)[q]), $
  JD_OBS:ptr_new((*merkel.JD_OBS)[q]), $
  MACRO_NUM:ptr_new((*merkel.MACRO_NUM)[q]), $
  MIDTIME:ptr_new((*merkel.MIDTIME)[q]), $
  RAD_KR:ptr_new((*merkel.RAD_KR)[*,q]), $
  RAD_UNC:ptr_new((*merkel.RAD_UNC)[*,q]), $
  TOT_RAD_KR:ptr_new((*merkel.TOT_RAD_KR)[*,q]), $
  TOT_RAD_SNR:ptr_new((*merkel.TOT_RAD_SNR)[*,q]), $
  OBS_SOLAR_LOCALTIME:ptr_new((*merkel.OBS_SOLAR_LOCALTIME)[*,q]), $
  OBS_TYP:ptr_new((*merkel.OBS_TYP)[q]), $
  OBS_TYP_KEY:ptr_new(*merkel.OBS_TYP_KEY), $
  OBS_TYP_NUM:ptr_new((*merkel.OBS_TYP_NUM)[q]), $
  ORB_NUM:ptr_new((*merkel.ORB_NUM)[q]), $
  ORIG:ptr_new((*merkel.ORIG)[*,q]), $
  PLANET_SC_VECTOR_TG:ptr_new((*merkel.PLANET_SC_VECTOR_TG)[*,q]), $
  PLANET_SUN_VECTOR_TG:ptr_new((*merkel.PLANET_SUN_VECTOR_TG)[*,q]), $
  SCAN_NUM:ptr_new((*merkel.SCAN_NUM)[q]), $
  SOLSCAT_PERCENT:ptr_new((*merkel.SOLSCAT_PERCENT)[q]), $
  SOL_ANG:ptr_new((*merkel.SOL_ANG)[q]), $
  SOL_FIT:ptr_new((*merkel.SOL_FIT)[q]), $
  SPACECRAFT_SOLAR_LOCALTIME:ptr_new((*merkel.SPACECRAFT_SOLAR_LOCALTIME)[q]), $
  STEP_UTC_TIME:ptr_new((*merkel.STEP_UTC_TIME)[q]), $
  SUBSOLAR_LATITUDE:ptr_new((*merkel.SUBSOLAR_LATITUDE)[q]), $
  SUBSOLAR_LONGITUDE:ptr_new((*merkel.SUBSOLAR_LONGITUDE)[q]), $
  SUBSPACECRAFT_LATITUDE:ptr_new((*merkel.SUBSPACECRAFT_LATITUDE)[q]), $
  SUBSPACECRAFT_LONGITUDE:ptr_new((*merkel.SUBSPACECRAFT_LONGITUDE)[q]), $
  TARGET_ALTITUDE_SET:ptr_new((*merkel.TARGET_ALTITUDE_SET)[*,q]), $), $
  TARGET_LATITUDE_SET:ptr_new((*merkel.TARGET_LATITUDE_SET)[*,q]), $
  TARGET_LONGITUDE_SET:ptr_new((*merkel.TARGET_LONGITUDE_SET)[*,q]), $
  THETA:ptr_new((*merkel.THETA)[q]), $
  TRUE_ANOMALY:ptr_new((*merkel.TRUE_ANOMALY)[q]), $
  WAVELENGTH:ptr_new((*merkel.WAVELENGTH)[*,q]), $
  YD_OBS:ptr_new((*merkel.YD_OBS)[q]), $
  YMD_OBS:ptr_new((*merkel.YMD_OBS)[*,q])}
 
return, merkel2

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro spectra_subset, spectra, q

*spectra.spectra = (*spectra.spectra)[*,q]
*spectra.specsigma = (*spectra.specsigma)[*,q]
*spectra.rawspec = (*spectra.rawspec)[*,q]
*spectra.sol_fit = (*spectra.sol_fit)[*,q]
*spectra.dark = (*spectra.dark)[*,q]
*spectra.wavelength = (*spectra.wavelength)[*,q]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro merkel_subset, merkel, q

*merkel.BORESIGHT_UNIT_VECTOR_C1_TG = (*merkel.BORESIGHT_UNIT_VECTOR_C1_TG)[*,q]
*merkel.BORESIGHT_UNIT_VECTOR_C2_TG = (*merkel.BORESIGHT_UNIT_VECTOR_C2_TG)[*,q]
*merkel.BORESIGHT_UNIT_VECTOR_CENTER_TG = (*merkel.BORESIGHT_UNIT_VECTOR_CENTER_TG)[*,q]
*merkel.CORR = (*merkel.CORR)[*,q]
*merkel.DARK = (*merkel.DARK)[*,q]
*merkel.DARK_PERCENT = (*merkel.DARK_PERCENT)[q]
*merkel.FILENAME = (*merkel.FILENAME)[q]
*merkel.IND_OBS = (*merkel.IND_OBS)[q]
*merkel.JD_OBS = (*merkel.JD_OBS)[q]
*merkel.MACRO_NUM = (*merkel.MACRO_NUM)[q]
*merkel.MIDTIME = (*merkel.MIDTIME)[q]
*merkel.RAD_KR = (*merkel.RAD_KR)[*,q]
*merkel.RAD_UNC = (*merkel.RAD_UNC)[*,q]
*merkel.TOT_RAD_KR = (*merkel.TOT_RAD_KR)[q]
*merkel.TOT_RAD_SNR = (*merkel.TOT_RAD_SNR)[q]
*merkel.OBS_SOLAR_LOCALTIME = (*merkel.OBS_SOLAR_LOCALTIME)[q]
*merkel.OBS_TYP = (*merkel.OBS_TYP)[q]
*merkel.OBS_TYP_KEY = *merkel.OBS_TYP_KEY
*merkel.OBS_TYP_NUM = (*merkel.OBS_TYP_NUM)[q]
*merkel.ORB_NUM = (*merkel.ORB_NUM)[q]
*merkel.ORIG = (*merkel.ORIG)[*,q]
*merkel.PLANET_SC_VECTOR_TG = (*merkel.PLANET_SC_VECTOR_TG)[*,q]
*merkel.PLANET_SUN_VECTOR_TG = (*merkel.PLANET_SUN_VECTOR_TG)[*,q]
*merkel.SCAN_NUM = (*merkel.SCAN_NUM)[q]
*merkel.SOLSCAT_PERCENT = (*merkel.SOLSCAT_PERCENT)[q]
*merkel.SOL_ANG = (*merkel.SOL_ANG)[q]
*merkel.SOL_FIT = (*merkel.SOL_FIT)[q]
*merkel.SPACECRAFT_SOLAR_LOCALTIME = (*merkel.SPACECRAFT_SOLAR_LOCALTIME)[q]
*merkel.STEP_UTC_TIME = (*merkel.STEP_UTC_TIME)[q]
*merkel.SUBSOLAR_LATITUDE = (*merkel.SUBSOLAR_LATITUDE)[q]
*merkel.SUBSOLAR_LONGITUDE = (*merkel.SUBSOLAR_LONGITUDE)[q]
*merkel.SUBSPACECRAFT_LATITUDE = (*merkel.SUBSPACECRAFT_LATITUDE)[q]
*merkel.SUBSPACECRAFT_LONGITUDE = (*merkel.SUBSPACECRAFT_LONGITUDE)[q]
*merkel.TARGET_ALTITUDE_SET = (*merkel.TARGET_ALTITUDE_SET)[*,q]
*merkel.TARGET_LATITUDE_SET = (*merkel.TARGET_LATITUDE_SET)[*,q]
*merkel.TARGET_LONGITUDE_SET = (*merkel.TARGET_LONGITUDE_SET)[*,q]
*merkel.THETA = (*merkel.THETA)[q]
*merkel.TRUE_ANOMALY = (*merkel.TRUE_ANOMALY)[q]
*merkel.WAVELENGTH = (*merkel.WAVELENGTH)[*,q]
*merkel.YD_OBS = (*merkel.YD_OBS)[q]
*merkel.YMD_OBS = (*merkel.YMD_OBS)[*,q]

end
