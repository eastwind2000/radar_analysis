
! cinrad msg_1 type recorder(NEXRAD-Level2) format in length of 2432 bytes in little_endian
! Author: chentao@cma.goc.cn

real, parameter:: pi=3.1415926
real, parameter:: Re=6371e3

type radar_record
	character*14   unused1
	integer*2      Message_Type
	character*2    channel
	character*10   unused2

	integer*4    radical_collect_time    	 !!  �������ϲɼ���GMTʱ��(����)
	integer*2    radical_collect_date    	 !!  �����գ�Julian����ʾ����1970��1��1�տ�ʼ

	integer*2      unambiguousRange    	     !! ��ģ������,��λ:0.1Km
	integer*2      AzimuthAngle              !!��λ�ǣ�[��ֵ/8.]*[180./4096.]=�ȣ�
	integer*2      DataNumber            	 !! ��ǰ�����ھ����������
	integer*2      DataStatus            	 !! ��������״̬

	integer*2      ElevationAngle         !!����
	integer*2      ElevationNumber        !!��ɨ�ڵ����Ǳ��
	integer*2      FirstGateRangeOfRef    !!��һ��ǿ�ȿ�ľ���(��)
	integer*2      FirstGateRangeOfDoppler !!��һ���ٶ�/�׿���ľ���(��)
	integer*2      ReflectivityGateSize   !! ǿ�ȿⳤ(��)
	integer*2      DopplerGateSize        !!�ٶ�/�׿�����
	integer*2      ReflectivityGates      !!ǿ�ȿ���
	integer*2      DopplerGates           !!�ٶ�/�׿����� 
	integer*2      radicalnumber
	integer*4      coefofsys
	integer*2      RefPointer             !!���״�����ͷ��ǿ�����ݿ�ʼ���ֽ���         
	integer*2      VelPointer             !!���״�����ͷ���ٶ����ݿ�ʼ���ֽ���
	integer*2      SWPointer              !!���״�����ͷ���׿����ݿ�ʼ���ֽ���
	integer*2      VelResolution          !!�ٶȷֱ���:2=0.5m/s;4=1.0m/s
	integer*2      VCP                    !!��ɨVCPģʽ (11,21,31,32)
	character*14   unused3
	integer*2      NyquistVelocity        !!Nyquist����(0.01m/s)��ģ���ٶ�
	character*38   unused4
	character*1      dbz(460)             !! �ز�
	character*1      vel(920)             !! �ٶ�
	character*1      sw(920)              !! �׿�
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