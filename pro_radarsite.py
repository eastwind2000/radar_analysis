from pylab import *
import os

fname = "radarsite.conf"

with open(fname, "r") as f:
    txtbufr = f.readlines()

print(txtbufr[2].split())

numrec = len(txtbufr)

radarid  = np.empty((numrec), dtype="S5")
radarlon = np.empty((numrec), dtype="float")
radarlat = np.empty((numrec), dtype="float")
radarlev = np.empty((numrec), dtype="float")


for irec in np.arange(1,numrec):
    linebufr = txtbufr[irec].split()
    # print(linebufr)

    radarid[irec] = linebufr[1]

    radarlon[irec] = float(linebufr[5]) + float(linebufr[6])/60.0 + float(linebufr[7])/3600.0
    radarlat[irec] = float(linebufr[8]) + float(linebufr[9])/60.0 + float(linebufr[10])/3600.0
    radarlev[irec] = float(linebufr[11]) 

    print(radarid[irec], radarlon[irec], radarlat[irec])



with open("radar_info.dat", "wb") as f:
    np.savez(f, radarid, radarlat, radarlon, radarlev)
    # radarlat.save(f)


x = np.load("radar_info.dat")


