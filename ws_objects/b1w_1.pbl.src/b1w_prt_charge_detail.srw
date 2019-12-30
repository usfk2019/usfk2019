$PBExportHeader$b1w_prt_charge_detail.srw
$PBExportComments$[jwlee]요금상세내역(접속료포함)
forward
global type b1w_prt_charge_detail from w_a_print
end type
end forward

global type b1w_prt_charge_detail from w_a_print
integer width = 3323
integer height = 1992
end type
global b1w_prt_charge_detail b1w_prt_charge_detail

on b1w_prt_charge_detail.create
call super::create
end on

on b1w_prt_charge_detail.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_validkeyreq
	Desc.	: 인증key요청 내역 보고서
	Ver.	: 1.0
	Date	: 2004.07.26
	Programer : Kwon Jung Min(KwonJM)
-------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_choice, ls_payid, ls_subid, ls_workdt_fr, ls_workdt_to
String ls_inid_fr, ls_inid_to
		 
ls_payid = Trim(dw_cond.Object.payid[1])
ls_subid = Trim(dw_cond.Object.subid[1])
ls_workdt_fr = String(dw_cond.Object.workdt_fr[1], "yyyymmdd")
ls_workdt_to = String(dw_cond.Object.workdt_to[1], "yyyymmdd")
ls_inid_fr = Trim(dw_cond.Object.inid_fr[1])
ls_inid_to = Trim(dw_cond.Object.inid_to[1])

If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_subid) Then ls_subid = ""
If IsNull(ls_inid_fr) Then ls_inid_fr = ""
If Isnull(ls_inid_to) Then ls_inid_to = ""

If ls_workdt_fr > ls_workdt_to Then
	f_msg_usr_err(211, Title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_fr")
	Return
End If

////***** Dynamic SQL Where절 형성
ls_where = ""


If ls_inid_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " old_bilcdrh.inid >= '" + ls_inid_fr + "' "
End If
If ls_inid_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " old_bilcdrh.inid <= '" + ls_inid_to + "' "
End If
If ls_workdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " old_bilcdrh.workdt >= '" + ls_workdt_fr + "' "
End If
If ls_workdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " old_bilcdrh.workdt <= '" + ls_workdt_to + "' "
End If

If ls_payid <> "" And ls_subid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
End If

Choose Case ls_payid
	Case "11"		//납입자번호
		ls_where += "old_paymst.payid = '" + ls_subid + "' "
	Case "12"		//납입자명
		ls_where += "old_paymst.marknm like '%" + ls_subid + "%' "
	Case "13"		//주민번호
		ls_where += "old_paymst.mannum like '" + ls_subid + "%' "	
	Case "15"		//사업자번호
		ls_where += "paymst.busnum like '" + ls_subid + "%' "
	Case "21"		//가입자 번호
		ls_where += "old_bilcdrh.subid like '" + ls_subid + "%' "
	Case "31"		//대표자명
		ls_where += "old_paymst.chief like '" + ls_subid + "%' "
	Case "32"		//전화번호
		ls_where += "old_paymst.tel like '" + ls_subid + "%' "
//	
	Case "99"		//접수번호
		ls_where += "old_paymst.recnum like '" + ls_subid + "%' "
End Choose	


// 날짜 출력
If ls_workdt_fr <> "" And ls_workdt_to = "" Then
	dw_list.Object.date_t.Text = String(ls_workdt_fr, "@@@@-@@-@@") + " 부터  "
	
ElseIf ls_workdt_fr = "" And ls_workdt_to <> "" Then
	dw_list.Object.date_t.Text = String(ls_workdt_to, "@@@@-@@-@@") + " 까지"
	
ElseIf ls_workdt_fr = "" And ls_workdt_to = "" Then
	dw_list.Object.date_t.Text = "처음부터 끝까지"
Else
	dw_list.Object.date_t.Text = String(ls_workdt_fr, "@@@@-@@-@@") + " 부터  " + &
	                             String(ls_workdt_to, "@@@@-@@-@@") + " 까지"
End If

dw_list.SetTransObject(SQLCA)
dw_list.is_where = ls_where
ll_rows = dw_list.Retrieve()

If ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

	

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_list.Object.date_t.Text = ""

end event

type dw_cond from w_a_print`dw_cond within b1w_prt_charge_detail
integer x = 69
integer y = 36
integer width = 2190
integer height = 184
string dataobject = "b1dw_cnd_prt_charge_detail"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_charge_detail
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_charge_detail
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_charge_detail
integer y = 260
integer width = 3232
integer height = 1348
string dataobject = "b1d_prt_charge_detail"
end type

type p_1 from w_a_print`p_1 within b1w_prt_charge_detail
end type

type p_2 from w_a_print`p_2 within b1w_prt_charge_detail
end type

type p_3 from w_a_print`p_3 within b1w_prt_charge_detail
end type

type p_5 from w_a_print`p_5 within b1w_prt_charge_detail
end type

type p_6 from w_a_print`p_6 within b1w_prt_charge_detail
end type

type p_7 from w_a_print`p_7 within b1w_prt_charge_detail
end type

type p_8 from w_a_print`p_8 within b1w_prt_charge_detail
end type

type p_9 from w_a_print`p_9 within b1w_prt_charge_detail
end type

type p_4 from w_a_print`p_4 within b1w_prt_charge_detail
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_charge_detail
end type

type p_port from w_a_print`p_port within b1w_prt_charge_detail
end type

type p_land from w_a_print`p_land within b1w_prt_charge_detail
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_charge_detail
integer width = 2254
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_charge_detail
end type

