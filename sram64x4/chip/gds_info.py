# klayout -b -r gds_info.py -rd gds=<file.gds>
#   top cell of a GDS file and where its instances sit (um)
import pya

ly = pya.Layout()
ly.read(gds)  # noqa: F821  (set by -rd gds=...)
top = ly.top_cell()
print(f"top cell: {top.name}   box (um): {top.dbbox()}")
for inst in top.each_inst():
    print(f"  {inst.cell.name:22} {inst.dbbox()}")
