function colorbar2, position, range, log=log, _extra=e

;; position = [x0,y0,x1,y1] in device coords

if (n_elements(position) NE 4) then stop
if (log EQ !null) then log=0

wid = position[2]-position[0]
cb = bytscl(lindgen(wid,1001)/wid)
xx = findgen(wid)
yy = findgen(1001)/1000.

if ~(log) $
  then yy = yy*(max(range)-min(range)) + min(range) $
  else begin
    q = alog10(range)
    yy = 10.^(yy*(max(q)-min(q)) + min(q))
  endelse

cc0 = plot(findgen(10), yrange=minmax(yy), /current, position=position, hide=1, $
  xmajor=0, xminor=0, xrange=[0,1], /device, ymajor=0, yminor=0, margin=0, ylog=log)

if (total(strcmp('rgb_table', tag_names(e), /fold))) $
  then rgb_table = e.rgb_table $ 
  else rgb_table = !null

cc1 = image(cb, /current, aspect_ratio=0, position=position, /dev, $
  title=' ', rgb_table=rgb_table)
a0 = axis('Y', location=[1,min(yy)], /textpos, /tickdir, target=cc0, $
  tickfont_size=e.font_size, title=e.title)
cc1.order, /send_backward

;;p2 = plotsquare2([0,1], minmax(range), thick=3)

return, [cc0, cc1, a0] ;, p2]

end
