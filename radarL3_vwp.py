
# Author: chentao@cma.gov.cn
# Date: 2020-05-08

from pylab import *
import time
import datetime
import os 

from read_cinrad_vwp48 import *

#
# https://wenku.baidu.com/view/625d512b69eae009581becbb.html                  cinrad level3 format  same with WSR88D LEVEL3 data
# https://wenku.baidu.com/view/3f8758cc03d8ce2f006623d9.html?fr=search&pn=50  ncdc level3 data document
#

undef = -999

# fixed VWP levels?
vwp_lev  = np.array([0.3, 0.6, 0.9, 1.2, 1.5, 1.8,  \
                     2.1, 2.4, 2.7, 3.0, 3.4, 3.7,  \
                     4.0, 4.3, 4.6, 4.9, 5.2, 5.5,  \
                     5.8, 6.1, 6.7, 7.3, 7.6, 7.9,  \
                     8.5, 9.1, 10.7, 12.2, 13.7, 15.2], dtype=np.float32)


# fname = "Z_RADR_I_Z9200_20190505000000_P_DOR_SA_VWP_20_NUL_NUL.200.bin"  # have to be unzipped
fname = "../mesoanalysis/vwp_z9200/Z_RADR_I_Z9200_20190505070000_P_DOR_SA_VWP_20_NUL_NUL.200.bin"

finfo = os.popen("basename " + fname).readlines()
radarid = finfo[0][9:9+5]
cdate   = finfo[0][15:15+14]
print(radarid, cdate)
cyear   = cdate[0:4]
cmon    = cdate[4:6]
cday    = cdate[6:8]
chour   = cdate[8:10]
cmin    = cdate[10:12]

cdate_list = []

for imin in np.arange(-60, 6, 6):
    ndate = datetime.datetime(int(cyear), int(cmon), int(cday), int(chour),int(cmin)) + datetime.timedelta(minutes=int(imin))
    cdate = ndate.strftime("%Y%m%d%H%M") + "00"
    print(cdate)
    cdate_list.append(cdate[8:14])

# print(cdate_list)

# time.sleep(200)
nlev  = len(vwp_lev)
ntime = 11

databufr = read_cinrad_vwp48(fname)
vwp_data = databufr.reshape((ntime, nlev, 5))   # [time, lev, wdata]

xpos = vwp_data[:, :, 1 ] 
ypos = vwp_data[:, :, 2 ] 

wdir = vwp_data[:, :, 3 ]
wspd = vwp_data[:, :, 4 ]

u = wspd*cos( (270-wdir)*pi/180  )
v = wspd*sin( (270-wdir)*pi/180  )

print(" ================== plot begin  =======\n")

fig, ax = plt.subplots(figsize=(12, 8))
ax.barbs(xpos, ypos, u, v, barb_increments={"half":4, "full":8, "flag":20})  # cutomize barbs 
ax.set_title(fname)

# ax.set_xticks(xicks)
ax.set_yticks(ypos[0, :])
ax.set_yticklabels(vwp_lev[:])
ax.invert_yaxis()

ax.set_ylabel("Height km", fontsize=12)

ax.set_xticks(xpos[:, 0])
ax.set_xticklabels(cdate_list)
ax.set_xlabel("Time DDHHMMSS", fontsize=12)

plt.savefig("test_vwp.png", dpi=300)
# plt.show()

