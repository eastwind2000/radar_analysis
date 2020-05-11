
# 
# Author: chentao@cma.gov.cn
# Date: 2020-05-10
#

from pylab import *
import time
import datetime
import os 
import csv
from module_vwp48_decoder import *

def vwpdata_pro(fname, interm_datadir, fig_dir):               # make intermediate VWP data and figs

    # fixed VWP levels?
    vwp_lev  = np.array([0.3, 0.6, 0.9, 1.2, 1.5, 1.8,  \
                        2.1, 2.4, 2.7, 3.0, 3.4, 3.7,  \
                        4.0, 4.3, 4.6, 4.9, 5.2, 5.5,  \
                        5.8, 6.1, 6.7, 7.3, 7.6, 7.9,  \
                        8.5, 9.1, 10.7, 12.2, 13.7, 15.2], dtype=np.float32)

    # fname = "../mesoanalysis/vwp_z9200/Z_RADR_I_Z9200_20190505234200_P_DOR_SA_VWP_20_NUL_NUL.200.bin"
    # fname = "./data/Z_RADR_I_Z9755_20200508081800_P_DOR_SA_VWP_20_NUL_NUL.755.bin" 
    # fname = "./data/20200508.140000.00.48.200"  # in BT timezone
    # radarid = "Z9200"
    # cdate   = "20200508140000"

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
        bdate = ndate.strftime("%Y%m%d%H%M") + "00"
        print(bdate)
        cdate_list.append(bdate[8:14])

    # print(cdate_list)
    # time.sleep(200)

    nlev  = len(vwp_lev)
    ntime = 11

    [databufr, lat, lon, lev]  = read_cinrad_vwp48(fname)  # decode vwp48 data

    # print(lat, lon, lev)
    # time.sleep(200)

    vwp_data = databufr.reshape((ntime, nlev, 5))   # [time, lev, wdata]

    xpos = vwp_data[:, :, 1 ] 
    ypos = vwp_data[:, :, 2 ] 
    wdir = vwp_data[:, :, 3 ]
    wspd = vwp_data[:, :, 4 ]

    u = wspd*cos((270-wdir)*pi/180)
    v = wspd*sin((270-wdir)*pi/180)
    

    print(" ================== plot begin  ================\n")

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.set_title(radarid + "_"+ cdate + " UTC")

    # ax.set_xticks(xicks)

    ax.barbs(xpos, ypos, u, v, length=6, barbcolor="blue", flagcolor="red", barb_increments={"half":2, "full":4, "flag":20})  # cutomize barbs  

    ax.set_yticks(ypos[0, :])
    ax.set_yticklabels(vwp_lev[:])
    ax.invert_yaxis()
    # ax.set_ylim(480, 10)

    ax.set_ylabel("Height km", fontsize=12)

    ax.set_xticks(xpos[:, 0])
    ax.set_xticklabels(cdate_list)
    ax.set_xlabel("Time HHMMSS", fontsize=12)

    figname = "VWP_" + radarid + "_" + cdate + ".png"
    print(figname, lat, lon, lev)
    plt.savefig(fig_dir + figname,  dpi=450)

    print(" =======Generate intermediate vwpdata; set with nan=-9999 ===========\n") 

    u[isnan(u)] = -9999
    v[isnan(v)] = -9999

    interm_fname = interm_datadir + "vwp_interm_" + radarid + "_" + cdate + ".csv"

    with open(interm_fname, "w") as csvfile:

        writer = csv.writer(csvfile)
        
        buf_head = [radarid, lat, lon, lev, cdate]
        writer.writerow(buf_head)

        nrec = len(vwp_lev)
        for irec in np.arange(nrec):
            buf_vwp =  [ vwp_lev[irec], u[-1, irec], v[-1, irec]  ] 
            writer.writerow(buf_vwp)


    # plt.show()
