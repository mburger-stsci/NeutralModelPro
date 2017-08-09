function apoapse_time, orbitnum

defsysv, '!model', exists=e
datapath = e ? !model.basepath + 'Data/MESSENGER/' : '~/Data/MESSENGER/MASCS/'

restore, datapath + 'MESSENGER.orbitdata.sav'
q = (where(*orbit_data.orbit EQ orbitnum, nq))[0]

apotime = (nq EQ 0) ? -1 : (*orbit_data.t_apoapse)[q]

return, apotime

end
