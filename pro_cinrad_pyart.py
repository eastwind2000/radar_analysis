
from pylab import *
import struct
# from metpy.io import Level3File, Level2File
import pyart

# fname = "Z_RADR_I_Z9200_20190505000000_P_DOR_SA_VWP_20_NUL_NUL.200.bin"

# fname = "20200507.000001.02.19.010"

radar_data = pyart.io.read_cinrad_archive("Z_RADR_I_Z9200_20140508123000_O_DOR_SA_CAP.bin")

# f = Level2File("Z_RADR_I_Z9200_20140508123000_O_DOR_SA_CAP.bin")
#radar_data = pyart.io.read_nexrad_level3(fname)
# databufr = open(fname, "rb").read()
# print(databufr)
# print(len(databufr))
#

print(radar_data)


dir(radar_data)


