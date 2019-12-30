$PBExportHeader$b5w_inq_cardtext_each.srw
$PBExportComments$[kwon] 신용카드 결제상태 건별조회
forward
global type b5w_inq_cardtext_each from w_a_inq_m
end type
end forward

global type b5w_inq_cardtext_each from w_a_inq_m
integer width = 3099
integer height = 2024
end type
global b5w_inq_cardtext_each b5w_inq_cardtext_each

event ue_ok;call super::ue_ok;String ls_where
String ls_senddt_fr , ls_senddt_to , ls_status , ls_rescode , ls_payid , ls_customerid , ls_worktype
String ls_updtdt_fr , ls_updtdt_to ,  ls_mandatory_flag
Long ll_rows
Boolean lb_check


ls_senddt_fr = Trim(dw_cond.Object.senddt_fr[1])
ls_senddt_to = Trim(dw_cond.Object.senddt_to[1])
ls_updtdt_fr = Trim(dw_cond.Object.updtdt_fr[1])
ls_updtdt_to = Trim(dw_cond.Object.updtdt_to[1])

ls_status = Trim(dw_cond.Object.status[1])
ls_rescode = Trim(dw_cond.Object.rescode[1])
ls_payid = Trim(dw_cond.Object.payid[1])
ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_worktype = Trim(dw_cond.Object.worktype[1])

If IsNull(ls_senddt_fr) Then ls_senddt_fr = ""
If IsNull(ls_senddt_to) Then ls_senddt_to = ""
If IsNull(ls_updtdt_fr) Then ls_updtdt_fr = ""
If IsNull(ls_updtdt_to) Then ls_updtdt_to = ""

If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_rescode) Then ls_rescode = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_worktype) Then ls_worktype = ""

If ls_worktype = "A" Then ls_worktype = ""



If ls_senddt_fr <> "" AND ls_senddt_to <> "" Then 
	ls_mandatory_flag = "SEND"
Elseif ls_updtdt_fr <> "" AND ls_updtdt_to <> "" Then 
	ls_mandatory_flag = "SYS"
Else 
	ls_mandatory_flag = ""
End if

////// 필수 체크
If ls_mandatory_flag = "" Then
	If ls_senddt_fr = "" Then
		f_msg_info(200, This.Title, "'승인요청일'과 '생성일' 중 하나는 필수 입력입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_fr")
		Return
	End If
	
	If ls_senddt_to = "" Then
		f_msg_info(200, This.Title, "'승인요청일'과 '생성일' 중 하나는 필수 입력입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_to")
		Return
	End If
	
	If ls_updtdt_fr = "" Then
		f_msg_info(200, This.Title, "'승인요청일'과 '생성일' 중 하나는 필수 입력입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("updtdt_fr")
		Return
	End If
	
	If ls_updtdt_to = "" Then
		f_msg_info(200, This.Title, "'승인요청일'과 '생성일' 중 하나는 필수 입력입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("updtdt_to")
		Return
	End If
End if
///////


////// 날짜 체크
If ls_senddt_fr <> "" Then 
	lb_check = fb_chk_stringdate(ls_senddt_fr)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'승인요청일'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_fr")
		Return
	End If
End if

If ls_senddt_to <> "" Then 
	lb_check = fb_chk_stringdate(ls_senddt_to)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'승인요청일'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_to")
		Return
	End If
End if

If ls_updtdt_fr <> "" Then 
	lb_check = fb_chk_stringdate(ls_updtdt_fr)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'생성일'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("updtdt_fr")
		Return
	End If
End if

If ls_updtdt_to <> "" Then 
	lb_check = fb_chk_stringdate(ls_updtdt_to)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'생성일'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("updtdt_to")
		Return
	End If
End if

//////
If ls_senddt_fr <> "" AND ls_senddt_to <> "" Then
	If ls_senddt_fr > ls_senddt_to Then
		f_msg_usr_err(221, This.Title, "'승인요청일'의 시작날짜가 종료날짜보다 작아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_fr")
		Return
	End if
End if

If ls_updtdt_fr <> "" AND ls_updtdt_to <> "" Then
	If ls_updtdt_fr > ls_updtdt_to Then
		f_msg_usr_err(221, This.Title, "'생성일'의 시작날짜가 종료날짜보다 작아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("updtdt_fr")
		Return
	End if
End if

ls_where = ""
If ls_senddt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.SENDDT >= '" + MidA(ls_senddt_fr,3) + "' "
End If
If ls_senddt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.SENDDT <= '" + MidA(ls_senddt_to,3) + "' "
End If
If ls_updtdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " TO_CHAR(CARDTEXT.UPDTDT,'yyyymmdd') >= '" + ls_updtdt_fr + "' "
	
End If
If ls_updtdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " TO_CHAR(CARDTEXT.UPDTDT,'yyyymmdd') <= '" + ls_updtdt_to + "' "
End If
If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.STATUS = '" + ls_status + "' "
End If
If ls_rescode <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.RESCODE = '" + ls_rescode + "' "
End If
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.PAYID = '" + ls_payid + "' "
End If
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.CUSTOEMRID = '" + ls_customerid + "' "
End If
If ls_worktype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDTEXT.WORKTYPE = '" + ls_worktype + "' "
End If
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "dw_detail")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

dw_detail.Object.row_num.text = String(ll_rows) + " Hit(s)"
//// 
end event

on b5w_inq_cardtext_each.create
call super::create
end on

on b5w_inq_cardtext_each.destroy
call super::destroy
end on

event open;call super::open;
//dw_cond.Object.updtdt_fr[1]='20020101'
//dw_cond.Object.updtdt_to[1]= '20021030'



 //dw_cond.Object.senddt_fr[1]='20020102'
 //dw_cond.Object.senddt_to[1]= '20021030'
end event

type dw_cond from w_a_inq_m`dw_cond within b5w_inq_cardtext_each
integer width = 2523
integer height = 484
string dataobject = "b5d_cnd_inq_cardtext_each"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;idwo_help_col[1] = Object.payid
idwo_help_col[2] = Object.customerid  

is_help_win[1] = "b5w_hlp_paymst"
is_help_win[2] = "b5w_hlp_customerm" 

is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[1] = iu_cust_help.is_data2[1]
			Object.marknm.text =   iu_cust_help.is_data2[2] 
		End If
	Case "customerid"
		If iu_cust_help.ib_data[row] Then
			Object.customerid[1] = iu_cust_help.is_data2[1]
			Object.customernm.text =   iu_cust_help.is_data2[2] 
		End If
End Choose

Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_todt_check , ls_column
String ls_payid , ls_customerid , ls_marknm_text , ls_customernm_text

Choose Case dwo.Name
		
	Case "payid"
		ls_payid = Trim(dw_cond.Object.payid[1])
		If IsNull(ls_payid) Then ls_payid = ""

		If ls_payid = "" Then
			dw_cond.Object.marknm.text = ""
			Return
		End If
		SELECT customernm INTO :ls_marknm_text
		From customerm
		WHERE payid = :ls_payid ;
		If IsNull(ls_marknm_text) OR Trim(ls_marknm_text) = "" Then
			dw_cond.Object.marknm.text = "(등록되지않은 payid입니다.)"
		Else			
			dw_cond.Object.marknm.text = "(" + ls_marknm_text+")"
		End if
		
	Case "coutomerid"
		ls_customerid = Trim(dw_cond.Object.customerid[1])
		If IsNull(ls_customerid) Then ls_customerid = ""
		If ls_customerid = "" Then
			dw_cond.Object.customernm.text = ""
		Return
		End If
		SELECT customernm INTO :ls_customernm_text
		From customerm
		WHERE customerid = :ls_customerid ;
		If IsNull(ls_customernm_text) OR Trim(ls_customernm_text) = "" Then
			dw_cond.Object.custoemrnm.text = "(등록되지않은 customerid입니다.)"
		Else			
			dw_cond.Object.customernm.text = "(" + ls_customernm_text+")"
		End if	
	
End Choose
end event

type p_ok from w_a_inq_m`p_ok within b5w_inq_cardtext_each
integer x = 2720
integer y = 92
end type

type p_close from w_a_inq_m`p_close within b5w_inq_cardtext_each
integer x = 2720
integer y = 240
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_inq_cardtext_each
integer width = 2583
integer height = 548
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_inq_cardtext_each
integer x = 18
integer y = 560
integer width = 3022
integer height = 1336
string dataobject = "b5d_inq_cardtext_each"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.senddt_t
uf_init(ldwo_SORT)



end event

