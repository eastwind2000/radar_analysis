      
	parameter pi=3.1415926,Re=6371e3

	type radar_record
	character*14   unused1
	integer*2      Message_Type
	character*2      channel
	character*10   unused2

	integer*4    radical_collect_time   !!  径向资料采集的GMT时间(毫秒)
      integer*2    radical_collect_date   !!  儒略日（Julian）表示，自1970年1月1日开始

	integer*2      unambiguousRange      !! 不模糊距离,单位:0.1Km
	integer*2      AzimuthAngle          !!方位角（[数值/8.]*[180./4096.]=度）
      integer*2      DataNumber            !! 当前仰角内径向数据序号
	integer*2      DataStatus            !! 径向数据状态

	integer*2      ElevationAngle        !!仰角
	integer*2      ElevationNumber       !!体扫内的仰角编号
	integer*2      FirstGateRangeOfRef   !!第一个强度库的距离(米)
	integer*2      FirstGateRangeOfDoppler !!第一个速度/谱宽库的距离(米)
      integer*2      ReflectivityGateSize   !! 强度库长(米)
	integer*2      DopplerGateSize        !!速度/谱宽库数
	integer*2      ReflectivityGates      !!强度库数
	integer*2      DopplerGates           !!速度/谱宽库数 
	integer*2      radicalnumber
	integer*4      coefofsys
	integer*2      RefPointer             !!从雷达数据头到强度数据开始的字节数         
	integer*2      VelPointer             !!从雷达数据头到速度数据开始的字节数
	integer*2      SWPointer              !!从雷达数据头到谱宽数据开始的字节数
      integer*2      VelResolution          !!速度分辨率:2=0.5m/s;4=1.0m/s
      integer*2      VCP                    !!体扫VCP模式 (11,21,31,32)
	character*14   unused3
	integer*2      NyquistVelocity        !!Nyquist速率(0.01m/s)不模糊速度
	character*38   unused4
	character*1      dbz(460)             !! 回波
	character*1      vel(920)             !! 速度
	character*1      sw(920)              !! 谱宽
	character*4     unused5
      endtype


	type radar_grads
	     real*4 x0,y0
	     real*4 AzimuthAngle 
	     real*4 ElevationAngle 
	     real*4 FirstGateRangeOfRef
	     real*4 FirstGateRangeOfDoppler
           real*4 dbz(460)
	     real*4 vel(920)
	     real*4 sw(920)
	     real*4,dimension(460) :: x_dbz, y_dbz, z_dbz
           real*4,dimension(920) :: x_dpl, y_dpl, z_dpl
	endtype

	real vcp21(11)
	data vcp21/0.5,0.5, 1.5, 1.5, 2.4, 3.4, 4.3, 6.0, 9.9, 14.6, 19.5/

