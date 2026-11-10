# helpers for the part 2 layout scripts
# newcell <name>: open <name> and remove everything in it, so a script can be run again
proc newcell {name} {
  load $name
  box -100000 -100000 100000 100000
  select area
  delete
  select clear
}

# pinlabel <name> <layer> x0 y0 x1 y1: paint a little <layer> there and put a label on it (LVS wrappers)
proc pinlabel {name layer x0 y0 x1 y1} {
  box $x0 $y0 $x1 $y1
  paint $layer
  label $name c $layer
}
