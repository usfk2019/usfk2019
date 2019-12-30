$PBExportHeader$b5w_prt_charge_detail_1_v20.srw
$PBExportComments$[ssong] 요금상세 내역서(접속료포함)
forward
global type b5w_prt_charge_detail_1_v20 from w_a_print
end type
end forward

global type b5w_prt_charge_detail_1_v20 from w_a_print
integer width = 3470
integer height = 2328
end type
global b5w_prt_charge_detail_1_v20 b5w_prt_charge_detail_1_v20

type variables
String is_format
end variables

on b5w_prt_charge_detail_1_v20.create
call super::create
end on

on b5w_prt_charge_detail_1_v20.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_choice, ls_payid, ls_validkey, ls_workdt_fr, ls_workdt_to
String ls_inid_fr, ls_inid_to
		 
ls_choice = Trim(dw_cond.Object.choice[1])
ls_payid = Trim(dw_cond.Object.payid[1])
ls_validkey = Trim(dw_cond.Object.validkey[1])
ls_workdt_fr = Trim(String(dw_cond.Object.workdt_fr[1], 'yyyymmdd'))
ls_workdt_to = Trim(String(dw_cond.Object.workdt_to[1], 'yyyymmdd'))
ls_inid_fr = Trim(dw_cond.Object.inid_fr[1])
ls_inid_to = Trim(dw_cond.Object.inid_to[1])

If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_inid_fr) Then ls_inid_fr = ""
If Isnull(ls_inid_to) Then ls_inid_to = ""
If IsNull(ls_workdt_fr) Then ls_workdt_fr = ""
If Isnull(ls_workdt_to) Then ls_workdt_to = ""

If ls_workdt_fr > ls_workdt_to Then
	f_msg_usr_err(211, Title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_fr")
	Return
End If

////***** Dynamic SQL Where절 형성
ls_where = ""

If ls_choice = "1" Then //청구전
	dw_list.DataObject = "b5dw_prt_det_charge_detail_c"

	If ls_inid_fr <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " post_bilcdr.inid >= '" + ls_inid_fr + "' "
	End If
	If ls_inid_to <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " post_bilcdr.inid <= '" + ls_inid_to + "' "
	End If
	If ls_workdt_fr <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(post_bilcdr.stime,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	End If
	If ls_workdt_to <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(post_bilcdr.stime,'yyyymmdd') <= '" + ls_workdt_to + "' "
	End If
	
	If ls_payid <> "" And ls_validkey <> "" Then
		If ls_where <> "" Then ls_where += " AND "
	End If
	
	Choose Case ls_payid
		Case "11"		//납입자번호
			ls_where += "post_bilcdr.payid = '" + ls_validkey + "' "
		Case "12"		//납입자명
			ls_where += "customerm.customernm like '%" + ls_validkey + "%' "
		Case "13"		//주민번호
			ls_where += "customerm.ssno like '" + ls_validkey + "%' "
	
		Case "15"		//사업자번호
			ls_where += "customerm.cregno like '" + ls_validkey + "%' "
			
		Case "21"		//가입자 번호
			ls_where += "post_bilcdr.validkey like '" + ls_validkey + "%' "
		Case "31"		//대표자명
			ls_where += "customerm.representative like '" + ls_validkey + "%' "
		Case "32"		//전화번호
			ls_where += "customerm.phone1 like '" + ls_validkey + "%' "
	//	
//		Case "99"		//접수번호
//			ls_where += "paymst.recnum like '" + ls_validkey + "%' "
	End Choose
	


ElseIf ls_choice = "2" Then //청구후
	dw_list.DataObject = "b5dw_prt_det_charge_detail_d"
	
	If ls_inid_fr <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " post_bilcdrh.inid >= '" + ls_inid_fr + "' "
	End If
	If ls_inid_to <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " post_bilcdrh.inid <= '" + ls_inid_to + "' "
	End If
	If ls_workdt_fr <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(post_bilcdrh.stime,'yyyymmdd') >= '" + ls_workdt_fr + "' "
	End If
	If ls_workdt_to <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(post_bilcdrh.stime,'yyyymmdd') <= '" + ls_workdt_to + "' "
	End If
	
	If ls_payid <> "" And ls_validkey <> "" Then
		If ls_where <> "" Then ls_where += " AND "
	End If
	
	Choose Case ls_payid
		Case "11"		//납입자번호
			ls_where += "customerm.payid = '" + ls_validkey + "' "
		Case "12"		//납입자명
			ls_where += "customerm.customernm like '%" + ls_validkey + "%' "
		Case "13"		//주민번호
			ls_where += "customerm.ssno like '" + ls_validkey + "%' "	
		Case "15"		//사업자번호
			ls_where += "customerm.cregno like '" + ls_validkey + "%' "
		Case "21"		//가입자 번호
			ls_where += "post_bilcdrh.validkey like '" + ls_validkey + "%' "
		Case "31"		//대표자명
			ls_where += "customerm.representative like '" + ls_validkey + "%' "
		Case "32"		//전화번호
			ls_where += "customerm.phone1 like '" + ls_validkey + "%' "
	//	
//		Case "99"		//접수번호
//			ls_where += "paymst.recnum like '" + ls_validkey + "%' "
	End Choose	

End If

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

type dw_cond from w_a_print`dw_cond within b5w_prt_charge_detail_1_v20
integer y = 68
integer width = 2578
integer height = 208
string dataobject = "b5dw_prt_cnd_charge_detail_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_charge_detail_1_v20
integer x = 2743
integer y = 60
end type

type p_close from w_a_print`p_close within b5w_prt_charge_detail_1_v20
integer x = 3045
integer y = 60
end type

type dw_list from w_a_print`dw_list within b5w_prt_charge_detail_1_v20
integer y = 312
integer width = 3378
integer height = 1644
string dataobject = "b5dw_prt_det_charge_detail_c"
end type

type p_1 from w_a_print`p_1 within b5w_prt_charge_detail_1_v20
integer x = 2898
integer y = 1996
end type

type p_2 from w_a_print`p_2 within b5w_prt_charge_detail_1_v20
integer x = 695
integer y = 1996
end type

type p_3 from w_a_print`p_3 within b5w_prt_charge_detail_1_v20
integer x = 2574
integer y = 1996
end type

type p_5 from w_a_print`p_5 within b5w_prt_charge_detail_1_v20
integer x = 1385
integer y = 1996
end type

type p_6 from w_a_print`p_6 within b5w_prt_charge_detail_1_v20
integer x = 1961
integer y = 1996
end type

type p_7 from w_a_print`p_7 within b5w_prt_charge_detail_1_v20
integer x = 1769
integer y = 1996
end type

type p_8 from w_a_print`p_8 within b5w_prt_charge_detail_1_v20
integer x = 1577
integer y = 1996
end type

type p_9 from w_a_print`p_9 within b5w_prt_charge_detail_1_v20
integer x = 1010
integer y = 1996
end type

type p_4 from w_a_print`p_4 within b5w_prt_charge_detail_1_v20
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_charge_detail_1_v20
integer x = 55
integer y = 1968
end type

type p_port from w_a_print`p_port within b5w_prt_charge_detail_1_v20
integer x = 105
integer y = 2024
end type

type p_land from w_a_print`p_land within b5w_prt_charge_detail_1_v20
integer x = 265
integer y = 2036
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_charge_detail_1_v20
integer y = 8
integer width = 2629
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_charge_detail_1_v20
integer x = 2249
integer y = 1996
end type

