$PBExportHeader$a0_sams.sra
$PBExportComments$Generated Application Object
forward
global type a0_sams from application
end type
global u_trans_app sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
	//Ini 파일
	//String	gs_ini_file = "sams_pink.ini"
	String	gs_ini_file = "sams.ini"
	
	//실행시킨 프로그램 관련정보
	String	gs_pgm_id[]
	Integer	gi_max_win_no = 0, gi_open_win_no = 0
	
	//Icon 정보
	String	gs_ico_reg = "reg.ico"		//등록 Icon
	String	gs_ico_inq = "view.ico"		//조회 Icon
	String	gs_ico_prt = "print.ico"	//출력 Icon
	
	//DataBase 명
	String	gs_database
	Char		gc_server_no					//IP체계: 공인/내부
	
	//패치 다운로드 확인
	String 	gs_down_ok
	
	//사용자 정보
	String	gs_user_group					//사용자 Group
	String	gs_user_id						//사용자번호
	Integer	gi_auth							//사용자권한
	Integer  gi_group_auth					//사용자가 열수 있는 메뉴의 그룹 권한
	String	gs_dept							//소속 부서
	String	gs_costct						//소속 CostCenter
	String	gs_access_i_dept[]			//접근가능 내부부서
	Integer	gi_access_i_dept_no			//접근가능 내부부서갯수
	
	//MDI FRAME
	Window	gw_mdi_frame
	String	gs_title
	
	
	//COLOR 값들
	long	Cream 		= 15793151
	long	Silver 		= 12632256	
	long	Teal			= 9016172
	long	Gray			= 8421504
	long	Black			= 0
	long	White			= 16777215
	long	Blue			= 16711680
	long	Transparent	= 553648127
	long	ButtonFace	= 67108864
	LONG	NAVY 			= 8404992
	
	//POS장비관련
	String 	GS_PRN, GS_DSP
	
	//SYSTEM New Start Date
	String	GS_STARTDT = '20060827'
	
	//Shop 선택정보
	String GS_ShopID, GS_ShopNm, gs_CID, GS_OnOff
	LONG		GL_SCHEDULSEQ
	// payid
	string gs_payid
	
	//Add 2015-02-03 by lys
	String gs_lang = 'K'
	integer ii_bill_user
	
	//Add 2019/05/01 SSRT_API.DLL 대체
	s_receipt_print gs_str_receipt_print 

end variables

global type a0_sams from application
string appname = "a0_sams"
string themepath = "C:\Program Files\Appeon\Shared\PowerBuilder\theme190"
string themename = "Do Not Use Themes"
long richtextedittype = 2
long richtexteditversion = 1
string richtexteditkey = ""
end type
global a0_sams a0_sams

type prototypes
// WIN API
FUNCTION ulong GetCurrentDirectoryA(ulong buf, ref string wdir) LIBRARY "kernel32.dll" alias for "GetCurrentDirectoryA;Ansi"
FUNCTION uint FindWindowA (long classname,string windowname) LIBRARY "user32.dll" alias for "FindWindowA;Ansi"


Function boolean PRN_OpenPort   ( String  comx) 					LIBRARY "SSRT_API.DLL" alias for "_PRN_OpenPort@4;Ansi" 
Function Boolean PRN_ClosePort  () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_ClosePort@0;Ansi"
Function Boolean PRN_SetPort    ( Integer BaudRate ,  Integer ByteSize,  Integer Parity,  Integer StopBits) LIBRARY "SSRT_API.DLL" alias for "_PRN_SetPort@16;Ansi"
Function Boolean PRN_IsOpen     () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_IsOpen@0;Ansi"
Function Boolean PRN_SetTimeout () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_SetTimeout@0;Ansi"
Function Boolean PRN_PutBufN    (String byBuf, Long bLen ) 	LIBRARY "SSRT_API.DLL" alias for "_PRN_PutBufN@8;Ansi"
Function Long    PRN_GetBuf     (String byBuf, Long bLen ) 	LIBRARY "SSRT_API.DLL" alias for "_PRN_GetBuf@8;Ansi"
Function Boolean PRN_HT         () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_HT@0;Ansi"
Function Boolean PRN_CR         () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_CR@0;Ansi"
Function Boolean PRN_LF         (Integer count) 				LIBRARY "SSRT_API.DLL" alias for "_PRN_LF@4;Ansi"
Function Boolean PRN_CMD        (Integer cnt, String szCmd) LIBRARY "SSRT_API.DLL" alias for "_PRN_CMD@8;Ansi"
Function Boolean PRN_GS         (Integer cnt, String szCmd) LIBRARY "SSRT_API.DLL" alias for "_PRN_GS@8;Ansi"
Function Boolean PRN_CDOPEN     () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_CDOPEN@0;Ansi"
Function Boolean PRN_ESC        (Integer cnt, String szCmd) LIBRARY "SSRT_API.DLL" alias for "_PRN_ESC@8;Ansi"
Function Boolean PRN_CLR        () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_CLR@0;Ansi"
Function Boolean PRN_CUT        () 									LIBRARY "SSRT_API.DLL" alias for "_PRN_CUT@0;Ansi"
Function Boolean PRN_LOGO       (Integer loc ) 					LIBRARY "SSRT_API.DLL" alias for "_PRN_LOGO@4;Ansi"
Function Boolean PRN_PMODE      (Integer mode) 					LIBRARY "SSRT_API.DLL" alias for "_PRN_PMODE@4;Ansi"
Function Boolean PRN_BARMODE (Integer font, Integer high , Integer width) LIBRARY "SSRT_API.DLL" alias for "_PRN_BARMODE@12;Ansi"
Function Boolean PRN_BARCODE (Integer mode, String data) 	LIBRARY "SSRT_API.DLL" alias for "_PRN_BARCODE@8;Ansi"
Function Boolean DSP_OpenPort   ( String comx) 					LIBRARY "SSRT_API.DLL" alias for "_DSP_OpenPort@4;Ansi"
Function Boolean DSP_ClosePort  () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_ClosePort@0;Ansi"
Function Boolean DSP_IsOpen     () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_IsOpen@0;Ansi"
Function Boolean DSP_SetPort    ( Integer BaudRate,  Integer ByteSize,  Integer Parity, Integer StopBits) LIBRARY "SSRT_API.DLL" alias for "_DSP_SetPort@16;Ansi"
Function Boolean DSP_SetTimeout () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_SetTimeout@0;Ansi"
Function Boolean DSP_PutBuf     (String byBuf , Long bLen ) LIBRARY "SSRT_API.DLL" alias for "_DSP_PutBuf@8;Ansi"
Function boolean DSP_GetBuf     (String byBuf , Long bLen ) LIBRARY "SSRT_API.DLL" alias for "_DSP_GetBuf@8;Ansi"
Function Boolean DSP_US        (Integer cnt, String szCmd) 	LIBRARY "SSRT_API.DLL" alias for "_DSP_US@8;Ansi"
Function Boolean DSP_ESC       (Integer cnt, String szCmd) 	LIBRARY "SSRT_API.DLL" alias for "_DSP_ESC@8;Ansi"
Function Boolean DSP_CMD       (Integer cnt, String szCmd) 	LIBRARY "SSRT_API.DLL" alias for "_DSP_CMD@8;Ansi"
Function Boolean DSP_INIT      () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_INIT@0;Ansi"
Function Boolean DSP_CUR_ONOFF (Integer mode) 					LIBRARY "SSRT_API.DLL" alias for "_DSP_CUR_ONOFF@4;Ansi"
Function Boolean DSP_LEFT      () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_LEFT@0;Ansi"
Function Boolean DSP_RIGHT     () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_RIGHT@0;Ansi"
Function Boolean DSP_UP        () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_UP@0;Ansi"
Function Boolean DSP_DOWN      () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_DOWN@0;Ansi"
Function Boolean DSP_MOVE      (Integer x, Integer y) 		LIBRARY "SSRT_API.DLL" alias for "_DSP_MOVE@8;Ansi"
Function Boolean DSP_CLR       () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_CLR@0;Ansi"
Function Boolean DSP_CAN       () 									LIBRARY "SSRT_API.DLL" alias for "_DSP_CAN@0;Ansi"
Function Boolean DSP_MODE      (Integer mode) 					LIBRARY "SSRT_API.DLL" alias for "_DSP_MODE@4;Ansi"
Function Boolean DSP_BA        (Integer vac) 					LIBRARY "SSRT_API.DLL" alias for "_DSP_BA@4;Ansi"
SUBROUTINE Sleep(ulong milisec) 										LIBRARY "kernel32.dll" 
function boolean CloseHandle(ulong w_handle)  LIBRARY "kernel32.dll"
FUNCTION LONG SendMessageA(ULONG whnd, UINT wmsg, ulong wparam, ulong lparam) Library "USER32.DLL" 


end prototypes

on a0_sams.create
appname="a0_sams"
message=create message
sqlca=create u_trans_app
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on a0_sams.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event systemerror;OPEN(w_system_error)

end event

event open;string ls_ref_desc, ls_temp, ls_timeout[]
integer li_close_time

OPEN(w_file_download)

//if gs_down_ok = 'OK' then
//	OPEN(w_login_1)
//end if




ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("X0", "X001", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_timeout[])


if trim(ls_timeout[1]) = '' or isnull(ls_timeout[1]) then ls_timeout[1] = 'N' 
if trim(ls_timeout[2]) = '' or isnull(ls_timeout[2]) then ls_timeout[2] = '20' 

li_close_time = INTEGER( ls_timeout[2]) * 60

IF ls_timeout[1] = 'Y' THEN
	 idle(li_close_time)
END IF 
end event

event idle;messagebox("알림","홀인원 미사용시간이 초과되어 프로그램을 종료합니다.")
halt close
end event

