


load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./trimPNG.ncl"

begin



cdate  =  "2020050808"

fh_synop          = (/"000", "006", "012", "018", "024", "030", "036"/)

nt = dimsizes(fh_synop)

ncdatadir = "./" + cdate + "/"

fig_dir ="./figs/ecmwf/"

model_name = " ECMWF_HR "

nvars = 1
nlevs = 1

; minlat = 10
; maxlat = 55
; minlon = 70
; maxlon = 140

minlat = 18
maxlat = 55
minlon = 90
maxlon = 130

wks_type = "x11"
wks_type@wkWidth = 3200
wks_type@wkHeight = 2500

;======================= getting VWP intermediate data ===================
vwp_datadir = "../radar_analysis/vwp_interm/"

vwp_flist   = systemfunc("find  " + vwp_datadir + " -name '*.csv'")

num_vwp = dimsizes(vwp_flist)

radar_id  = new((/num_vwp/), "string")
radar_lat = new((/num_vwp/), "float")
radar_lon = new((/num_vwp/), "float")
vwp_u     = new((/30, num_vwp/), "float")  ; pay attention to -9999 values
vwp_v     = new((/30, num_vwp/), "float")  

vwp_u@_FillValue = -9999.0
vwp_v@_FillValue = -9999.0

delim="," 
; vwp_lev = new((/30/), "float")  
do k = 0, num_vwp-1

   fname = vwp_flist(k)  

   print(fname)

   txtbufr   = asciiread(fname, -1, "string")     ;  reading in CSV format VWP data
   print(txtbufr(0))

   radar_id(k)      = str_get_field(txtbufr(0), 1, delim)

   radar_lat(k)     = tofloat(str_get_field(txtbufr(0), 2, delim))
   radar_lon(k)     = tofloat(str_get_field(txtbufr(0), 3, delim))
   radar_lev        = tofloat(str_get_field(txtbufr(0), 4, delim))

   radar_cdate      = str_get_field(txtbufr(0), 5, delim)

   vwp_lev      =  tofloat(str_get_field(txtbufr(1:), 1, delim))
   vwp_u(:, k)  =  tofloat(str_get_field(txtbufr(1:), 2, delim))
   vwp_v(:, k)  =  tofloat(str_get_field(txtbufr(1:), 3, delim))

end do

print("====== Step5: Reading VWP intermediate data  " + " ======")

; print(radar_lon)

; sleep(200)

;======================= getting ecmwf file ===============================

print("====== Step5: Drawing Model figs:  " + " ======")

do k = 0,  0;nt   ; time-dimension

        flist = (/ ncdatadir + "/" + "ECMWF_HR_HGT_500_" + cdate + "_f" + fh_synop(k) + ".nc4", \
                   ncdatadir + "/" + "ECMWF_HR_PRMSL_"+ cdate + "_f" + fh_synop(k) + ".nc4",    \
                   ncdatadir + "/" + "ECMWF_HR_WIND_850_"+ cdate + "_f" + fh_synop(k) + ".nc4"  /)

        ; ListSetType(era5_flist, "join")

        fs00     = addfile(flist(0), "r")
        fs01     = addfile(flist(1), "r")
        fs02     = addfile(flist(2), "r")
        

        h500   = fs00->ECMWF_HR_HGT_500(0,  0, {minlat:maxlat}, {minlon:maxlon})
        slp    = fs01->ECMWF_HR_PRMSL(0,  0, {minlat:maxlat}, {minlon:maxlon})
        ulev   = fs02->ECMWF_HR_WIND_850_U(0,0, {minlat:maxlat}, {minlon:maxlon})
        vlev   = fs02->ECMWF_HR_WIND_850_V(0,0, {minlat:maxlat}, {minlon:maxlon})

        ; print(h500)

        vardims = dimsizes(h500)

        spd = sqrt(ulev^2.0 + vlev^2.0)
        copy_VarCoords(ulev, spd)

        lat  = fs00->latitude
        lon  = fs00->longitude

        ; timeinfo = grbfs[:]->initial_time0
        ; =================================================================================== Starting Plot
            
        fig_prefix = fig_dir + "ecmwf_synop_" + cdate + "_f" + fh_synop(k)        ;+ tostring(k)

        print("Generating figname: " + fig_prefix + ".eps" )
        
        ; wks_type@wkOrientation                 = "landscape"

        wks = gsn_open_wks(wks_type, fig_prefix)   

        ; ; ==================================================================== draw map

        mpres = True

        ; mpres@gsnPaperMargin                    = 0

        mpres@gsnDraw                           = False

        mpres@gsnFrame                          = False

        mpres@gsnMaximize                       = False

        ; mpres@gsnCenterString                   = timeinfo(k)

        mpres@mpLimitMode                       = "Corners"
        mpres@mpLeftCornerLatF                  = minlat
        mpres@mpLeftCornerLonF                  = minlon
        mpres@mpRightCornerLatF                 = maxlat
        mpres@mpRightCornerLonF                 = maxlon

        mpres@mpOutlineOn                       = False
        mpres@mpFillOn                          = False

        mpres@pmTickMarkDisplayMode             =  "Always"

        mpres@tmXBLabelFontHeightF              = 0.012

        mpres@gsnMaximize                       = False

        mpres@gsnLeftStringFontHeightF          = 0.015
        mpres@gsnLeftString                     = model_name + ": " + cdate + " fcst+"  + fh_synop(k)
        mpres@gsnRightString                    = ""

        plot_mp  = gsn_csm_map(wks, mpres)
        ; ; ==================================================================== Adding shapefiles
        
        shp_path = "/home/lse/fs02/vgdisk01/res/ncarg/shp/"
        shp_list =(/ "bou1_4l.shp", "continents_lines.shp", "hyd1_4l.shp", "province_l.shp" /)
        shp_color = (/"Black",      "Black",                "Blue",        "Black"  /)
        nshp = 4
        shpplot = new(4, graphic)
        shpres                  = True
        do ishp = 0, nshp - 1 
            shpres@gsLineColor      = shp_color(ishp)
            shpres@gsLineThicknessF = 1.5
            shpplot(ishp) = gsn_add_shapefile_polylines(wks, plot_mp, shp_path + shp_list(ishp), shpres)  
        end do

        getvalues plot_mp                                   ; important for overplay control
        "vpXF"      : xpos
        "vpYF"      : ypos
        "vpWidthF"  : width
        "vpHeightF" : height
        end getvalues

        print("xpos = " + xpos)

        ; ==============================================================================plot spd

        ; spdres                                   =  True
        ; spdres@vpXF                              =  xpos
        ; spdres@vpYF                              =  ypos
        ; spdres@vpWidthF                          =  width
        ; spdres@vpHeightF                         =  height
        ; spdres@gsnDraw                           = False
        ; spdres@gsnFrame                          = False
        ; spdres@gsnAddCyclic                      = False
        ; spdres@gsnMaximize                       = False       ; pay attention to correcness of overlay         
        ; spdres@cnLevelSelectionMode              = "ManualLevels"    ; 
        ; spdres@cnMaxLevelValF                    = 24
        ; spdres@cnMinLevelValF                    =  8
        ; spdres@cnLevelSpacingF                   =  2

        ; spdres@cnLineLabelInterval               = 1       
        ; spdres@cnLinesOn                         = False
        ; spdres@cnLineLabelsOn                    = False  
        ; spdres@cnLineThicknessF                  = 4.0

        ; spdres@cnFillOn                          = True
        ; ; spdres@
        ; cmap                                     = read_colormap_file("precip2_17lev")
        ; spdres@cnFillPalette                     = cmap

        ; spdres@cnInfoLabelOn                     = False
                
        ; spdres@pmLabelBarDisplayMode             = "Always"
        ; ; spdres@pmLabelBarSide                    = "Right"

        ; spdres@pmLabelBarOrthogonalPosF          =  0.04       ; Move labelbar up
        ; spdres@pmLabelBarParallelPosF            =  0.5        ; Move labelbar up   
        ; spdres@pmLabelBarHeightF                 =  0.4
        ; spdres@pmLabelBarWidthF                  =  0.06
        
        ; spdres@lbLabelStride                     =  2
        ; spdres@lbLabelFontHeightF                =  0.025

        ; spdres@cnFillDrawOrder                   = "Predraw"
        ; ; spdres@lbOverrideFillOpacity             = True
        ; ; spdres@lbFillOpacityF                    = 0
        
        ; spdres@lbLabelBarOn                      = False   ; importrant settings when overlay map !


        ; slpres@cnLineColor                       = "blue4"

        ; ==============================================================================plot slp

        slpres                                   =  True
        slpres@vpXF                              =  xpos
        slpres@vpYF                              =  ypos
        slpres@vpWidthF                          =  width
        slpres@vpHeightF                         =  height
        slpres@gsnDraw                           = False
        slpres@gsnFrame                          = False
        slpres@gsnAddCyclic                      = False
        slpres@gsnMaximize                       = False        ; pay attention to correcness of overlay 

        slpres@gsnLeftString                     = ""
        slpres@gsnRightString                    = ""
        
       
        slpres@cnLevelSelectionMode              = "ManualLevels"    ; 
        slpres@cnMaxLevelValF                    = 1060
        slpres@cnMinLevelValF                    =  970
        slpres@cnLevelSpacingF                   = 5.0
        slpres@cnLineLabelInterval               = 1

        slpres@cnFillOn                          = True      
        cmap                                     = read_colormap_file("testcmap")
        slpres@cnFillPalette                     = cmap(::-1, :)    ; reverse colormap
        
        slpres@cnLinesOn                         = True
        slpres@cnLineThicknessF                  = 4.0
        slpres@cnLineColor                       = "tan"
        
        
        slpres@cnLineLabelsOn                    = True
        slpres@cnLineLabelPlacementMode          = "Computed"
        slpres@cnLineLabelFontHeightF            = 0.01
        slpres@cnLineLabelBackgroundColor        = -1
        
        
        slpres@cnHighLabelsOn                    = False
        slpres@cnHighLabelFontColor              = "gray3"

        slpres@cnLowLabelsOn                     = False
        slpres@cnLowLabelFontColor               = "red3"
        slpres@cnHighLabelCount                  = 2
        slpres@cnLowLabelCount                   = 2

        slpres@cnInfoLabelOn                     = False
        ; slpres@cnLabelBar                        =
        slpres@lbOrientation                     = "Vertical"
        slpres@lbLabelBarOn                      =  False

        slpres@pmLabelBarDisplayMode             = "Always"
        ; slpres@pmLabelBarSide                    = "Right"
        ; slpres@pmLabelBarParallelPosF            = 1.1
        ; slpres@pmlabelBarOrthogonalPosF          = 0.2
        slpres@pmLabelBarHeightF                 = 0.4
        slpres@pmLabelBarWidthF                  = 0.05

        ; slpres@cnLabelBar
               
   

        ; ==============================================================================plot hgt
        
        hgtres                                   =  True

        hgtres@vpXF                              =  xpos
        hgtres@vpYF                              =  ypos
        hgtres@vpWidthF                          =  width
        hgtres@vpHeightF                         =  height

        hgtres@gsnDraw                           = False
        hgtres@gsnFrame                          = False
        hgtres@gsnAddCyclic                      = False
        hgtres@gsnMaximize                       = False        ; pay attention to correcness of overlay 

        hgtres@gsnLeftString                     = ""
        hgtres@gsnRightString                    = ""


        ; hgtres@trGridType                        = "TriangularMesh"
        ; hgtres@tmXTOn                            = False
        ; hgtres@tmYLOn                            = False
        ; hgtres@tmXBLabelsOn                      = False      
        ; hgtres@tmYLLabelsOn                      = False
        
        hgtres@cnLevelSelectionMode              = "ManualLevels"    ; 
        hgtres@cnMaxLevelValF                    = 600
        hgtres@cnMinLevelValF                    = 400
        hgtres@cnLevelSpacingF                   = 4

        hgtres@cnLineLabelInterval               = 2
        hgtres@cnLineLabelFontHeightF            = 0.01
        hgtres@cnLineLabelBackgroundColor        = -1


        hgtres@cnFillOn                          = False

        hgtres@cnLinesOn                         = True
        hgtres@cnLineThicknessF                  = 6.0
        hgtres@cnLineColor                       = "blue4"

        hgtres@cnInfoLabelOn                     = "False"
               
        ; hgtres@pmTickMarkDisplayMode             =  "Always"

        ;=================================================================================== 

        vecres = True
        
        vecres@vpXF= xpos
        vecres@vpYF= ypos
        vecres@vpWidthF =  width
        vecres@vpHeightF = height
        vecres@gsnDraw                    = False
        vecres@gsnFrame                   = False
        vecres@gsnMaximize                = False
        vecres@gsnAddCyclic               = False

        vecres@gsnLeftString = " "
        vecres@gsnRightString = " "

        vecres@vcGlyphStyle                = "WindBarb"
        vecres@vcWindBarbScaleFactorF      =  2.5       ; important settings !
        vecres@vcWindBarbColor             = "blue4"
        vecres@vcWindBarbLineThicknessF    =  3.0
        vecres@vcWindBarbTickLengthF       =  0.4
        vecres@vcWindBarbTickSpacingF      =  0.14
        vecres@vcWindBarbCalmCircleSizeF   =  0.01

        vecres@vcRefAnnoOn                =  False
        vecres@vcRefMagnitudeF            =  10
        vecres@vcRefLengthF               =  0.018       ; controling res for windbarb length

        vecres@vcRefAnnoOrthogonalPosF    =  0.05
        vecres@vcLineArrowColor           =  "blue4"
        vecres@vcMinDistanceF             =  0.015

        ;=================================================================================== 


        ; plot_qpe  = gsn_csm_contour(wks, databufr( {minlat:maxlat}, {minlon:maxlon} ), qperes)

        ; plot_spd = gsn_csm_contour(wks, spd850, spdres )

        plot_wind = gsn_csm_vector(wks, ulev, vlev, vecres)
        
        plot_slp  = gsn_csm_contour(wks, slp, slpres )
        
        plot_hgt  = gsn_csm_contour(wks, h500, hgtres )

        
    ; ========================================================   Adding track and marks

        ; plres                              = True
        ; plres@gsLineThicknessF             = 6.0
        ; plres@gsLineColor                  = "blue"
        ; trackplot                          = gsn_add_polyline(wks, plot_mp, cen_lon, cen_lat, plres)
        ; tfDoNDCOverlay 
             
        overlay(plot_mp, plot_slp)

        overlay(plot_mp, plot_hgt)

        ; ; overlay(plot_mp, plot_slp)        
       
        overlay(plot_mp, plot_wind)

        draw(plot_mp)

        ; ================================================================================  plotting vector    


        wmsetp("col", 200  )    ; windbarb color
        wmsetp("wbs", 0.02)   ; windbarb length
        wmsetp("wbr", 0.0)
        wmsetp("blw", 5.0)    ; windbarb line thick
        wmsetp("wbd", 0.18)   ; windbarb tickbar interval distance as fraction of whole windbarb length

        ; wmsetp("")    
        px = ind( (radar_lat.ge.minlat) .and.  (radar_lat.le.maxlat) .and.       \
                  (radar_lon.ge.minlon) .and.  (radar_lon.le.maxlon)  )
    
        ; nvec = dimsizes(px)

        print(radar_lat)
        print(radar_lon)
        ; print(vwp_u(:,5))


        wmbarbmap(wks, radar_lat(px), radar_lon(px), 2.5*vwp_u(5, px), 2.5*vwp_v(5, px)) 

        
        ;=================================================================================== 
        
        ; maximize_output(wks, True)                       ; important function for overlay 

        ; draw(plot_hgt)

        ; frame(wks)

        frame(wks)
        
        ; delete(databufr)

        ; delete(plot_hgt)
        delete(plot_mp)
        ; delete(plot_slp)
        delete(shpplot)
        delete(shpres)
        ; delete(slpres)
        delete(hgtres)
        delete(mpres)
        delete(wks)

        trimPNG(fig_prefix+".png")

    end do ; for k level
    
   
; ==================================================================== Preforme interpolation using ESMF

end


; Z9660,22.818,115.356,322.7832,20200508000000
; 0.3,-9999.0,-9999.0
; 0.6,0.9404169753201611,7.659081633755425
; 0.9,2.569059599546137,5.042063359338103
; 1.2,1.6079682333415624,9.119241008272807
; 1.5,3.261176078548281,6.9936146694470125
; 1.8,5.2699952771107474,4.117371561764911
; 2.1,5.3522479362602695,4.819185687893515
; 2.4,3.2161235478403536,7.576712268961174
; 2.7,-9999.0,-9999.0
; 3.0,13.357109424337718,0.7000164425701206
; 3.4,-9999.0,-9999.0
; 3.7,-9999.0,-9999.0
; 4.0,-9999.0,-9999.0
; 4.3,-9999.0,-9999.0
; 4.6,-9999.0,-9999.0
; 4.9,0.4264900888252156,0.28767119726149104
; 5.2,-9999.0,-9999.0
; 5.5,-9999.0,-9999.0
; 5.8,-9999.0,-9999.0
; 6.1,-9999.0,-9999.0
; 6.7,-9999.0,-9999.0
; 7.3,-9999.0,-9999.0
; 7.6,-9999.0,-9999.0
; 7.9,-9999.0,-9999.0
; 8.5,0.0,-0.0
; 9.1,-9999.0,-9999.0
; 10.7,-9999.0,-9999.0
; 12.2,-9999.0,-9999.0
; 13.7,-9999.0,-9999.0
; 15.2,-9999.0,-9999.0


