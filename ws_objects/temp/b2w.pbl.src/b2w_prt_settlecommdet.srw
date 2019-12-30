$PBExportHeader$b2w_prt_settlecommdet.srw
$PBExportComments$[y.k.min] 사업자 커미션 상세 내역서
forward
global type b2w_prt_settlecommdet from w_a_print
end type
end forward

global type b2w_prt_settlecommdet from w_a_print
integer width = 3168
end type
global b2w_prt_settlecommdet b2w_prt_settlecommdet

type variables
String	is_levelcode  //대리점 Levelcode
end variables

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b2w_prt_settlecommdet
	Desc.	: 	사업자 커미션 상세내역서 
	Date	:	2003.02.18
	Ver.	: 	1.0
	Programer : Min Yoon Ki
-------------------------------------------------------------------------*/

dw_cond.object.commdt[1] = Date(fdt_get_dbserver_now())

end event

on b2w_prt_settlecommdet.create
call super::create
end on

on b2w_prt_settlecommdet.destroy
call super::destroy
end on

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String ls_commdt, ls_org_levelcod, ls_partner, ls_where
String ls_desc
Long ll_row

ls_commdt = String(dw_cond.object.commdt[1], 'yyyymm')
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_commdt) Then ls_commdt = ""
If IsNull(ls_partner) Then ls_partner = ""

ls_where = ""
If ls_commdt = "" Then
	f_msg_info(200, Title, "발생년월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("commdt")
	Return
Else
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(settle.commdt, 'yyyymm') = '" + ls_commdt + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "settle.partner = '" + ls_partner + "' "
End If


dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

dw_list.object.t_date.Text = MidA(ls_commdt, 1, 4) + "-" + MidA(ls_commdt, 5,2)
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_settlecommdet
integer x = 46
integer y = 40
integer width = 2126
integer height = 160
string dataobject = "b2dw_cnd_reg_settlecommdet"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;//DataWindowChild ldc
//String ls_filter
//Long ll_row
////Level Code에 해당하는 Partner 반 보여주기
//If dwo.name = "org_levelcod" Then
//	dw_cond.object.partner.Protect = 0
//	ll_row = dw_cond.GetChild("partner", ldc)
//	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//	If data <> "" Then
//		ls_filter = "levelcod = '" + data + "' "
//	Else
//		ls_filter = ""
//	End If
//	ldc.SetFilter(ls_filter)			//Filter정함
//	ldc.Filter()
//	ldc.SetTransObject(SQLCA)
//	ll_row =ldc.Retrieve() 
//	
//	If ll_row < 0 Then 				//디비 오류 
//		f_msg_usr_err(2100, Title, "Retrieve()")
//		Return -2
//	End If
//End If
	
end event

type p_ok from w_a_print`p_ok within b2w_prt_settlecommdet
integer x = 2304
integer y = 48
end type

type p_close from w_a_print`p_close within b2w_prt_settlecommdet
integer x = 2610
integer y = 48
end type

type dw_list from w_a_print`dw_list within b2w_prt_settlecommdet
integer x = 23
integer y = 248
integer width = 3063
integer height = 1368
string dataobject = "b2dw_prt_settlecommdet"
end type

type p_1 from w_a_print`p_1 within b2w_prt_settlecommdet
end type

type p_2 from w_a_print`p_2 within b2w_prt_settlecommdet
end type

type p_3 from w_a_print`p_3 within b2w_prt_settlecommdet
end type

type p_5 from w_a_print`p_5 within b2w_prt_settlecommdet
end type

type p_6 from w_a_print`p_6 within b2w_prt_settlecommdet
end type

type p_7 from w_a_print`p_7 within b2w_prt_settlecommdet
end type

type p_8 from w_a_print`p_8 within b2w_prt_settlecommdet
end type

type p_9 from w_a_print`p_9 within b2w_prt_settlecommdet
end type

type p_4 from w_a_print`p_4 within b2w_prt_settlecommdet
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_settlecommdet
end type

type p_port from w_a_print`p_port within b2w_prt_settlecommdet
end type

type p_land from w_a_print`p_land within b2w_prt_settlecommdet
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_settlecommdet
integer x = 23
integer width = 2171
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_settlecommdet
end type

