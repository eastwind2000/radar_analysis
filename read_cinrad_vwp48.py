# Author: chentao@cma.gov.cn

import numpy as np
import struct
import time
import logging

def read_cinrad_vwp48(fname):

    # ====================== begin decode vwp file ===================

    wind_list = []

    logging.basicConfig(filename="vwp_decode.log", level=logging.INFO, filemode="w")
    
    databufr = open(fname, "rb").read()
        
    hcode        = struct.unpack(">h", databufr[0:2])[0]
    hdate        = struct.unpack(">h", databufr[2:4])[0]
    htime        = struct.unpack(">i", databufr[4:8])[0]
    hflen        = struct.unpack(">i", databufr[8:12])[0]
    hradarid     = struct.unpack(">h", databufr[12:14])[0]
    hreceivecode = struct.unpack(">h", databufr[14:16])[0]
    hblockcount  = struct.unpack(">h", databufr[16:18])[0]
    print("1. msg header: ", hcode, hdate, htime, hflen, hradarid, hreceivecode, hblockcount)

    blockdesc                   = databufr[18:18+51*2]
    latitude, longitude, lev    = struct.unpack(">2ih", databufr[20:30])
    code                        = struct.unpack(">h", databufr[30:32])[0]
    gapSym, gapGra, gapAlp      = struct.unpack(">3i", databufr[108:120])

    print("2. product desc.block (lat, lon, lev, product_code): ", latitude, longitude, lev, code)
    print("   pointer for gapSym, gapGra, gapAlp: ", gapSym*2, gapGra*2, gapAlp*2)

    pos  = 120

    print("3. =================================", pos)

    # for iblock in [0, 1]: # for left blocks of gapSym, gap_Gra, gapAlp   
    #     blocksep      = struct.unpack(">h", databufr[pos:pos+2])[0]
    #     blockcode     = struct.unpack(">h", databufr[pos+2:pos+4])[0]
    #     blocklength   = struct.unpack(">i", databufr[pos+4:pos+8])[0]
    #     pos = pos + blocklength
    #     print(iblock, blocksep, blockcode, blocklength)
    # time.sleep(200)

    blocksep      = struct.unpack(">h", databufr[pos:pos+2])
    blockcode     = struct.unpack(">h", databufr[pos+2:pos+4])
    blocklength   = struct.unpack(">i", databufr[pos+4:pos+8])
    layercount    = struct.unpack(">h", databufr[pos+8:pos+10])
    layersep     =  struct.unpack(">h", databufr[pos+10:pos+12])
    layerlength  =  struct.unpack(">i", databufr[pos+12:pos+16])

    print("   3.1 product Symbology block: ", blocksep, blockcode, blocklength, layercount)
    print("   3.1 product Symbology block: ", layersep, layerlength)
    print("   ========================")

    pos = pos + 16

    while(True):
        pcode        =  struct.unpack(">h", databufr[pos:pos+2])[0]
        pos = pos + 2
        if (pcode==10): # unlinked vectors for coord-axis
            plength      =  struct.unpack(">h", databufr[pos:pos+2])[0]
            colorlevel   =  struct.unpack(">h", databufr[pos+2:pos+4])[0]
            pos = pos + 4
            pn          = int((plength-2)/8)
            pncord      = np.empty((pn, 4), dtype=np.int16)
            for k in np.arange(int(pn)):
                pncord[k, :] = struct.unpack(">4h", databufr[pos:pos+8] )
                pos=pos+8        
            # print("product Symbology block: ", pos, pcode, plength, pn, pncord )
            logging.info( "product Symbology block: " + str( [pos, pcode, plength, pn, pncord])  )
        elif (pcode==8):  # text information
            plength      =  struct.unpack(">h", databufr[pos:pos+2])[0]
            charcolor    =  struct.unpack(">h", databufr[pos+2:pos+4])[0]
            cx           =  struct.unpack(">h", databufr[pos+4:pos+6])[0]
            cy           =  struct.unpack(">h", databufr[pos+6:pos+8])[0]
            pos = pos + 8
            pn  = plength-6
            cn  = struct.unpack(">"+str(pn)+"s", databufr[pos:pos+pn])[0]
            pos = pos + pn
            # print(pos, pcode, plength, pn, cx, cy,  cn)
            logging.info(str([pos, pcode, plength, pn, cx, cy,  cn ]) )
            if cn==b'ND':
                wind_list.append([pos, cx, cy, np.nan, np.nan])
                # print("Symbology block for windbarb(pcode=8): ", pos, cx, cy, undef, undef)
                logging.info("Symbology block for windbarb(pcode=8): " + str( [pos, cx, cy, np.nan, np.nan] ))
                
        elif(pcode==4):
            plength  = struct.unpack(">h", databufr[pos:pos+2])[0]
            wcolor   = struct.unpack(">h", databufr[pos+2:pos+4])[0] 
            wx, wy   = struct.unpack(">2h", databufr[pos+4:pos+8])
            wdir     = np.float32(struct.unpack(">h", databufr[pos+8:pos+10])[0])
            wspd     = np.float32(struct.unpack(">h", databufr[pos+10:pos+12])[0])*0.51444  # knots to m/s
            pos = pos + 12
            # print("Symbology block for windbarb(pcode=4): ", pos, wx, wy, wdir, wspd)
            logging.info("Symbology block for windbarb(pcode=4): " + str( [pos, wx, wy, wdir, wspd] ))
            wind_list.append([pos, wx, wy, wdir, wspd])
        elif(pcode==-1):
            pos=pos-2
            print( "  symbology block finished ", pos)
            break

    print("4. =================================", pos)

    blocksep      = struct.unpack(">h", databufr[pos:pos+2])
    blockcode     = struct.unpack(">h", databufr[pos+2:pos+4])
    blocklength   = struct.unpack(">i", databufr[pos+4:pos+8])[0]
    pos = pos + 8 + 120 + 2
    numpage      = struct.unpack(">h", databufr[pos:pos+2])[0]
    pos = pos + 2

    for ipage in np.arange(numpage):
        while(True):
            numchar = struct.unpack(">h", databufr[pos:pos+2])[0]
            if (numchar>0):
                datachar = struct.unpack(">" + str(numchar)+"s",databufr[pos+2:pos+2+numchar] )
                pos = pos+2+numchar
                print("   ", numchar, datachar )
            elif (numchar==-1):
                # pageendsep= struct.unpack(">h", databufr[pos+2+numchar:pos+2+numchar+2] )
                # print("   blockcode:", blockcode, blocklength, ipage,  numchar,  datachar, pageendsep, pos)
                break

    
    wpbufr = np.array(wind_list)
    
    print("   wprofile shape:", wpbufr.shape)    
    print("5. VWP Decoding finished ")   
    print("   =====================\n")
    
    return wpbufr
    