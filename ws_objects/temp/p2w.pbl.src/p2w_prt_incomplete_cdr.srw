$PBExportHeader$p2w_prt_incomplete_cdr.srw
$PBExportComments$[ceusee] 불완료호 현황
forward
global type p2w_prt_incomplete_cdr from w_a_print
end type
end forward

global type p2w_prt_incomplete_cdr from w_a_print
integer width = 3282
end type
global p2w_prt_incomplete_cdr p2w_prt_incomplete_cdr

on p2w_prt_incomplete_cdr.create
call super::create
end on

on p2w_prt_incomplete_cdr.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = false
end event

event ue_ok();call super::ue_ok;String ls_yyyymmdd, ls_tm_fr, ls_tm_to, ls_rtelnum , ls_errcode
String ls_where, ls_svctype, ls_ref_desc
Integer ll_row
p2c_dbmgr lu_dbmgr


ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

ls_yyyymmdd = String(dw_cond.Object.yyyymmdd[1], 'yyyymmdd')
If IsNull(ls_yyyymmdd) Then ls_yyyymmdd = ""

ls_tm_fr = String(dw_cond.Object.tm_fr[1], "hhmm")
If IsNull(ls_tm_fr) Then ls_tm_fr = ""
ls_tm_to = String(dw_cond.Object.tm_to[1], "hhmm")
If IsNull(ls_tm_to) Then ls_tm_to = ""

ls_rtelnum = dw_cond.Object.rtelnum[1]
If IsNull(ls_rtelnum) Then ls_rtelnum = ""
ls_errcode = dw_cond.Object.code[1]
If IsNull(ls_errcode) Then ls_errcode = ""

If ls_yyyymmdd = "" Then
	f_msg_info(200, title, "일자")
	dw_cond.SetFocus()
	dw_cond.Setcolumn("yyyymmdd")
	Return
End If

If ls_tm_fr > ls_tm_to Then
	f_msg_usr_err(211, title, "시간대")
	dw_cond.SetFocus()
	dw_cond.Setcolumn("tm_fr")
	Return
End If

//조회조건 입력값을 보여준다.
dw_list.object.t_yyyymmdd.Text = MidA(ls_yyyymmdd, 1,4) + "-" + MidA(ls_yyyymmdd, 5,2) + "-" + MidA(ls_yyyymmdd, 7,2)
SetPointer(HourGlass!)
dw_list.setredraw(False)
lu_dbmgr = Create p2c_dbmgr
lu_dbmgr.is_caller = "p2w_prt_incomplete_cdr"
lu_dbmgr.is_title = title
lu_dbmgr.is_data[1] = ls_yyyymmdd
lu_dbmgr.is_data[2] = ls_tm_fr
lu_dbmgr.is_data[3] = ls_tm_to
lu_dbmgr.is_data[4] = ls_rtelnum
lu_dbmgr.is_data[5] = ls_errcode
lu_dbmgr.is_data[6] = ls_svctype
lu_dbmgr.idw_data[1] = dw_list
lu_dbmgr.uf_prc_db_01()

ll_row = lu_dbmgr.ii_rc
If ll_row < 0 Then
	Destroy lu_dbmgr
	dw_list.setredraw(True)
	Return
End If

dw_list.setredraw(True)
SetPointer(Arrow!)
If lu_dbmgr.il_data[1] = 0 Then 
	f_msg_info(1000, title, "")
End If

Destroy lu_dbmgr
Return






end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.object.tm_fr[1] = Time(00,00,00)
dw_cond.object.tm_to[1] = Time(23,59,59)
end event

type dw_cond from w_a_print`dw_cond within p2w_prt_incomplete_cdr
integer x = 69
integer y = 72
integer width = 2039
integer height = 292
string dataobject = "p2w_cnd_prt_incomplete_cdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p2w_prt_incomplete_cdr
integer x = 2240
integer y = 60
end type

type p_close from w_a_print`p_close within p2w_prt_incomplete_cdr
integer x = 2542
integer y = 60
end type

type dw_list from w_a_print`dw_list within p2w_prt_incomplete_cdr
integer x = 27
integer y = 400
integer width = 3200
integer height = 1228
string dataobject = "p2dw_prt_incomplete_cdr"
end type

type p_1 from w_a_print`p_1 within p2w_prt_incomplete_cdr
end type

type p_2 from w_a_print`p_2 within p2w_prt_incomplete_cdr
end type

type p_3 from w_a_print`p_3 within p2w_prt_incomplete_cdr
end type

type p_5 from w_a_print`p_5 within p2w_prt_incomplete_cdr
end type

type p_6 from w_a_print`p_6 within p2w_prt_incomplete_cdr
end type

type p_7 from w_a_print`p_7 within p2w_prt_incomplete_cdr
end type

type p_8 from w_a_print`p_8 within p2w_prt_incomplete_cdr
end type

type p_9 from w_a_print`p_9 within p2w_prt_incomplete_cdr
end type

type p_4 from w_a_print`p_4 within p2w_prt_incomplete_cdr
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_incomplete_cdr
end type

type p_port from w_a_print`p_port within p2w_prt_incomplete_cdr
end type

type p_land from w_a_print`p_land within p2w_prt_incomplete_cdr
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_incomplete_cdr
integer y = 12
integer width = 2103
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_incomplete_cdr
end type

