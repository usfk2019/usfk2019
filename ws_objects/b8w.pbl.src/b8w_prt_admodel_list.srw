$PBExportHeader$b8w_prt_admodel_list.srw
$PBExportComments$[ceusee] 장비 모델 내역
forward
global type b8w_prt_admodel_list from w_a_print
end type
end forward

global type b8w_prt_admodel_list from w_a_print
end type
global b8w_prt_admodel_list b8w_prt_admodel_list

on b8w_prt_admodel_list.create
call super::create
end on

on b8w_prt_admodel_list.destroy
call super::destroy
end on

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 0 //세로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b2w_prt_admodel_list
	Desc.	: 	장비모델 내역
	Date	:	2002.11.05
	Ver.	: 	1.0
	Programer : Choi Bo Ra
-------------------------------------------------------------------------*/
end event

event ue_ok;//조회
String ls_adtype, ls_modelno, ls_makercd, ls_where
Long ll_row

ls_adtype = Trim(dw_cond.object.adtype[1])
ls_modelno = Trim(dw_cond.object.modelno[1])
ls_makercd = Trim(dw_cond.object.makerpnm[1])
If IsNull(ls_adtype) Then ls_adtype = ""
If IsNull(ls_modelno) Then ls_modelno = ""
If IsNull(ls_makercd) Then ls_makercd = ""

If ls_makercd <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "mod.makercd = '" + ls_makercd + "' "
End If

If ls_modelno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "mod.modelno = '" + ls_modelno + "' "
End If

If ls_adtype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "mod.adtype = '" + ls_adtype + "' "
End IF

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

type dw_cond from w_a_print`dw_cond within b8w_prt_admodel_list
integer x = 41
integer y = 36
integer width = 1134
integer height = 288
string dataobject = "b8dw_cnd_prt_admodel_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b8w_prt_admodel_list
integer x = 1344
integer y = 48
end type

type p_close from w_a_print`p_close within b8w_prt_admodel_list
integer x = 1655
integer y = 48
end type

type dw_list from w_a_print`dw_list within b8w_prt_admodel_list
integer y = 380
integer height = 1240
string dataobject = "b8dw_prt_admodel_list"
end type

type p_1 from w_a_print`p_1 within b8w_prt_admodel_list
end type

type p_2 from w_a_print`p_2 within b8w_prt_admodel_list
end type

type p_3 from w_a_print`p_3 within b8w_prt_admodel_list
end type

type p_5 from w_a_print`p_5 within b8w_prt_admodel_list
end type

type p_6 from w_a_print`p_6 within b8w_prt_admodel_list
end type

type p_7 from w_a_print`p_7 within b8w_prt_admodel_list
end type

type p_8 from w_a_print`p_8 within b8w_prt_admodel_list
end type

type p_9 from w_a_print`p_9 within b8w_prt_admodel_list
end type

type p_4 from w_a_print`p_4 within b8w_prt_admodel_list
end type

type gb_1 from w_a_print`gb_1 within b8w_prt_admodel_list
end type

type p_port from w_a_print`p_port within b8w_prt_admodel_list
end type

type p_land from w_a_print`p_land within b8w_prt_admodel_list
end type

type gb_cond from w_a_print`gb_cond within b8w_prt_admodel_list
integer width = 1175
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within b8w_prt_admodel_list
end type

