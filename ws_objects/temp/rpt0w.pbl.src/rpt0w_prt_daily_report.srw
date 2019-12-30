$PBExportHeader$rpt0w_prt_daily_report.srw
$PBExportComments$[parkkh] Daily Report
forward
global type rpt0w_prt_daily_report from w_a_print
end type
end forward

global type rpt0w_prt_daily_report from w_a_print
end type
global rpt0w_prt_daily_report rpt0w_prt_daily_report

type variables
Int ii_pos
String is_pagetype[]
end variables

on rpt0w_prt_daily_report.create
call super::create
end on

on rpt0w_prt_daily_report.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;String ls_pageno, ls_yyyymmdd
Date ld_fromdt
rpt0u_dbmgr	lu_dbmgr
Integer li_rc

ls_yyyymmdd = string(dw_cond.object.yyyymmdd[1], 'yyyymmdd')
If IsNull(ls_yyyymmdd) Then ls_yyyymmdd = ""

If ls_yyyymmdd = "" Then
	f_msg_info(200, title, "일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyymmdd")
	Return
End If

ls_pageno = dw_cond.object.pageno[1]
If IsNull(ls_pageno) Then ls_pageno = ""

If ls_pageno = "" Then
	f_msg_info(200, title, "PageNo")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pageno")
	Return
End If

dw_list.SetRedraw(False)
dw_list.Reset()

//모래시계표시
SetPointer (HourGlass! )

//Daily Report 작성...
lu_dbmgr = Create rpt0u_dbmgr
lu_dbmgr.is_caller = "rpt0w_prt_daily_report%ue_ok"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = ls_yyyymmdd
lu_dbmgr.is_data[2] = ls_pageno
lu_dbmgr.is_data[3] = is_pagetype[1]
lu_dbmgr.idw_data[1] = dw_list

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
End If

Destroy lu_dbmgr

//모래시계표시 해제
SetPointer (Arrow! )

dw_list.SetRedraw(True)
end event

event open;call super::open;String ls_pos, ls_ref_desc, ls_temp

dw_cond.object.yyyymmdd[1] = Date(fdt_get_dbserver_now())

//PageType
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("R0", "R400", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";",is_pagetype[] )

String ls_filter
Long li_exist
DataWindowChild ldc_pageno

li_exist = dw_cond.GetChild("pageno", ldc_pageno)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : PageNo")
ls_filter = " pagetype = '" + is_pagetype[1] + "' " 
ldc_pageno.SetTransObject(SQLCA)
li_exist =ldc_pageno.Retrieve()
ldc_pageno.SetFilter(ls_filter)		//Filter정함
ldc_pageno.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 	//선택 취소 focus는 그곳에
End If  
end event

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.object.yyyymmdd[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within rpt0w_prt_daily_report
integer x = 73
integer y = 68
integer width = 1097
integer height = 212
string dataobject = "rpt0dw_cnd_prt_daily_report"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within rpt0w_prt_daily_report
integer x = 1394
integer y = 48
end type

type p_close from w_a_print`p_close within rpt0w_prt_daily_report
integer x = 1696
integer y = 48
end type

type dw_list from w_a_print`dw_list within rpt0w_prt_daily_report
integer y = 328
integer height = 1292
string dataobject = "rpt0dw_prt_daily_report"
end type

type p_1 from w_a_print`p_1 within rpt0w_prt_daily_report
end type

type p_2 from w_a_print`p_2 within rpt0w_prt_daily_report
end type

type p_3 from w_a_print`p_3 within rpt0w_prt_daily_report
end type

type p_5 from w_a_print`p_5 within rpt0w_prt_daily_report
end type

type p_6 from w_a_print`p_6 within rpt0w_prt_daily_report
end type

type p_7 from w_a_print`p_7 within rpt0w_prt_daily_report
end type

type p_8 from w_a_print`p_8 within rpt0w_prt_daily_report
end type

type p_9 from w_a_print`p_9 within rpt0w_prt_daily_report
end type

type p_4 from w_a_print`p_4 within rpt0w_prt_daily_report
end type

type gb_1 from w_a_print`gb_1 within rpt0w_prt_daily_report
end type

type p_port from w_a_print`p_port within rpt0w_prt_daily_report
end type

type p_land from w_a_print`p_land within rpt0w_prt_daily_report
end type

type gb_cond from w_a_print`gb_cond within rpt0w_prt_daily_report
integer width = 1211
integer height = 300
end type

type p_saveas from w_a_print`p_saveas within rpt0w_prt_daily_report
end type

