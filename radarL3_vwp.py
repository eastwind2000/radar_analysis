# 
# Author: chentao@cma.gov.cn
# Date: 2020-05-10
#
# CMISS VWP data in UTC timezone, vwp data in past 1 hour at 6min interval
#
#

from pylab import *
import os 
import time

from module_vwpdata_pro import *

flist = os.popen("find /home/lse/fs02/vgdisk02/datamusic/radarL3_vwp/ -name '*202005080000*.bin'" ).readlines()

numfile = len(flist)

interm_dir = "./vwp_interm/"
fig_dir    = "./figs/"

for ifile in flist:
    
    fname = ifile.strip("\n")

    vwpdata_pro(fname, interm_dir, fig_dir)   

    # time.sleep(200)

 
  

