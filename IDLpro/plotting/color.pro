function color, num

tt = tag_names(!color)
cc = ['white', 'black', 'red', 'forest_green', 'blue', 'dark_violet', 'cyan', $
  'magenta', 'orange', 'purple', 'peru', 'sea_green', 'saddle_brown', 'deep_pink', $
  'dark_slate_blue', 'CHARTREUSE', 'chocolate', strlowcase(tt)]
out = (num EQ !null) ? cc : cc[num]

return, out

end
