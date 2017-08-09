function results_trace_tree, pts, tree, points, stpt=stpt

treesize = size(*pts) & dim = treesize[2]
npts = (size(points))[1]

if (stpt EQ !null) then stpt = (where(*tree.level EQ 0))[0]
if ((n_elements(stpt) NE 1) and (n_elements(stpt) NE npts)) then stop

branches = replicate(-1L,npts,max(*tree.level)+2)
branches[*,0] = stpt 

ct = 0
q = where(branches[*,0] NE -1L, nq)
while (nq NE 0) do begin
  ;; Current node
  a = branches[q,ct]

  ;; Level of current node and dimension to look at
  lev = (*tree.level)[a]
  dd = lev mod dim

  pp = points[q,dd]  ;; Points still to do
  tpp = (*pts)[a,dd] ;; Node values to compare with
  www = (pp LT tpp)

  ;; Determine whether to take hi or low branch
  newa = www*(*tree.lowchild)[a] + (1-www)*(*tree.hichild)[a]

  ;; Increment count 
  ct++ 

  ;; add in the next node
  branches[q,ct] = newa
  q = where(branches[*,ct] NE -1L, nq)
endwhile

return, branches

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro results_find_closest, pts, tree, points, stpt=stpt, rmin=rmin, pmin=pmin, $
  lll=lll

if (lll EQ !null) then lll = 0

treesize = size(*pts) & dim = treesize[2]
npts = (size(points))[1]
;;print, 'Tree Level = ', lll, npts

if (stpt EQ !null) then begin
  stpt = (where(*tree.level EQ 0))[0]
;;  rmin = replicate(1d30, npts)
;;  pmin = lonarr(npts)
endif 

if ((n_elements(stpt) NE 1) and (n_elements(stpt) NE npts)) then stop
if (n_elements(rmin) NE npts) then begin
  rmin = replicate(1d30, npts)
  pmin = lonarr(npts)
endif

;; First follow the tree to see where each point belongs
branch = results_trace_tree(pts, tree, points, stpt=stpt)

bb = max(branch, dim=1)
w = (where(bb EQ -1, nw))[0]
if (nw NE 0) then branch = branch[*,0:w-1]

temp = (size(branch))
brmax = (temp[0] EQ 1) ? 0 : temp[2]-1

;; if (dd LT rmin) then it is possible that there is a closer point in that branch
for i=brmax,0,-1 do begin
  nodes = branch[*,i]
;;  printf, 1, lll, i, nodes
  q = where(nodes NE -1, nq)
  if (nq NE 0) then begin
    pp = points[q,*]
    nn = nodes[q]
    ll = (*tree.level)[nn] mod dim
    dd = ((*pts)[nn,ll]-points[q,ll])^2

    w = q[where(dd LT rmin[q], nw)]
    if (nw GT 0) then begin
      pp2 = points[w,*]
      nn2 = nodes[w]
      ll2 = (*tree.level)[nn2] mod dim
      node_pts = (*pts)[nn2,*]
      if (n_elements(pp2) NE n_elements(node_pts)) then stop

      r0 = total((node_pts-pp2)^2,2)
      if (n_elements(r0) NE nw) then stop
      qr = where(r0 LT rmin[w], nr)
      if (nr NE 0) then begin
	rmin[w[qr]] = r0[qr]
	pmin[w[qr]] = nn2[qr]
      endif

      ;; follow the branch not previously used
      dir = (pp2[lindgen(nw),ll2] LT node_pts[lindgen(nw),ll2])
      newst = dir*(*tree.hichild)[nn2] + (1-dir)*(*tree.lowchild)[nn2]
      e = where(newst NE -1L, nee)
      if (nee GT 0) then begin
	pp3 = pp2[e,*]
	newst = newst[e]
	rtemp = rmin[w[e]]
	ptemp = pmin[w[e]]
	results_find_closest, pts, tree, pp3, stpt=newst, rmin=rtemp, pmin=ptemp, $
	  lll=lll+1
	rmin[w[e]] = rtemp
	pmin[w[e]] = ptemp
      endif
    endif
  endif
endfor

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro results_kd_node, tree, pts, index, parent, ndim, level

n = n_elements(index)
case (n) of 
  1: begin
     (*tree.level)[index] = level
     (*tree.parent)[index] = parent
     (*tree.lowchild)[index] = -1
     (*tree.hichild)[index] = -1
     indnode = index
     end
  2: begin
     (*tree.level)[index[0]] = level
     (*tree.parent)[index[0]] = parent
     (*tree.lowchild)[index[0]] = index[1]
     (*tree.hichild)[index[0]] = index[1]

     (*tree.level)[index[1]] = level+1
     (*tree.parent)[index[1]] = index[0]
     (*tree.lowchild)[index[1]] = -1
     (*tree.hichild)[index[1]] = -1
     end
  else: begin
     dim = level mod ndim

     p = (*pts)[dim,index]
     s = sort(p)

     ;; this node is at index[n2] = where(pts[*,dim] EQ median(pts[*,dim]))
     n2 = n/2 & if ((n2 EQ 0) or (n2 EQ n-1)) then stop
     indnode = index[s[n2]]
     indlow = index[s[0:n2-1]] & indhi = index[s[n2+1:*]]

     (*tree.level)[indnode] = level
     (*tree.parent)[indnode] = parent
     results_kd_node, tree, pts, indlow, indnode, ndim, level+1
     results_kd_node, tree, pts, indhi, indnode, ndim, level+1

     ii = indlow[(where((*tree.level)[indlow] EQ level+1, nq))[0]]
     if (nq NE 1) then stop
     if ((*tree.parent)[ii] NE indnode) then stop
     (*tree.lowchild)[indnode] = ii

     ii = indhi[(where((*tree.level)[indhi] EQ level+1, nq))[0]]
     if (nq NE 1) then stop
     if ((*tree.parent)[ii] NE indnode) then stop
     (*tree.hichild)[indnode] = ii
   endelse
endcase

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function results_kd_tree, output

tstart = systime(1)

;;pts = n x 3 array
pts = ptr_new(transpose([[*output.x], [*output.y], [*output.z]]))

sz = size(*pts)
ndim = sz[1]

tree = {level:ptr_new(lonarr(sz[2])), parent:ptr_new(lonarr(sz[2])), $
  lowchild:ptr_new(lonarr(sz[2])), hichild:ptr_new(lonarr(sz[2]))}

index = lindgen(sz[2])
results_kd_node, tree, pts, index, -1, ndim, 0
pts = 0.

tend = systime(1)
print, 'results_kd_tree: ', tend-tstart

return, tree

end
