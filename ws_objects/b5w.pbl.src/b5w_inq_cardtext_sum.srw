$PBExportHeader$b5w_inq_cardtext_sum.srw
$PBExportComments$[kwon] 신용카드 결재상태 합산 조회 window
forward
global type b5w_inq_cardtext_sum from w_a_inq_m
end type
end forward

global type b5w_inq_cardtext_sum from w_a_inq_m
integer width = 3113
integer height = 1776
end type
global b5w_inq_cardtext_sum b5w_inq_cardtext_sum

on b5w_inq_cardtext_sum.create
call super::create
end on

on b5w_inq_cardtext_sum.destroy
call super::destroy
end on

event ue_ok;String ls_where
String ls_senddt_fr , ls_senddt_to , ls_worktype
Long ll_rows
Boolean lb_check


ls_senddt_fr = Trim(dw_cond.Object.senddt_fr[1])
ls_senddt_to = Trim(dw_cond.Object.senddt_to[1])
ls_worktype = Trim(dw_cond.Object.worktype[1])
If IsNull(ls_senddt_fr) Then ls_senddt_fr = ""
If IsNull(ls_worktype) Then ls_worktype = ""

If ls_worktype = "A" Then ls_worktype = ""


////// 필수 체크
If ls_senddt_fr = "" Then
	f_msg_info(200, This.Title, "'승인요청일'는 필수 입력입니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("senddt_fr")
	Return
End If

If ls_senddt_to = "" Then
	f_msg_info(200, This.Title, "'승인요청일'는 필수 입력입니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("senddt_to")
	Return
End If
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

//////
If ls_senddt_fr <> "" AND ls_senddt_to <> "" Then
	If ls_senddt_fr > ls_senddt_to Then
		f_msg_usr_err(221, This.Title, "'승인요청일'의 시작날짜가 종료날짜보다 작아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("senddt_fr")
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

end event

event open;call super::open;//dw_cond.Object.senddt_fr[1]='20020102'
 //dw_cond.Object.senddt_to[1]= '20021030'
end event

type dw_cond from w_a_inq_m`dw_cond within b5w_inq_cardtext_sum
integer width = 1929
integer height = 196
string dataobject = "b5d_cnd_inq_cardtext_sum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within b5w_inq_cardtext_sum
integer x = 2107
integer y = 36
end type

type p_close from w_a_inq_m`p_close within b5w_inq_cardtext_sum
integer x = 2107
integer y = 160
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_inq_cardtext_sum
integer width = 1966
integer height = 268
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_inq_cardtext_sum
integer x = 23
integer y = 276
integer width = 3031
integer height = 1380
string dataobject = "b5d_inq_cardtext_sum"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.senddt_t
uf_init(ldwo_SORT)

end event

