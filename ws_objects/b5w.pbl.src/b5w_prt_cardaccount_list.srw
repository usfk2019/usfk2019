$PBExportHeader$b5w_prt_cardaccount_list.srw
$PBExportComments$[kwon] 신용카드 가맹점별 입금 내역 List window
forward
global type b5w_prt_cardaccount_list from w_a_print
end type
end forward

global type b5w_prt_cardaccount_list from w_a_print
integer width = 3122
end type
global b5w_prt_cardaccount_list b5w_prt_cardaccount_list

on b5w_prt_cardaccount_list.create
call super::create
end on

on b5w_prt_cardaccount_list.destroy
call super::destroy
end on

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 1
ib_margin = False
end event

event ue_ok;call super::ue_ok;String ls_where
String ls_outdt_fr , ls_outdt_to , ls_membercode
Long ll_rows
Boolean lb_check


ls_outdt_fr = Trim(dw_cond.Object.outdt_fr[1])
ls_outdt_to = Trim(dw_cond.Object.outdt_to[1])
ls_membercode = Trim(dw_cond.Object.membercode[1])
If IsNull(ls_outdt_fr) Then ls_outdt_fr = ""
If IsNull(ls_membercode) Then ls_membercode = ""


////// 필수 체크
If ls_outdt_fr = "" Then
	f_msg_info(200, This.Title, "'입금일자'의 필수 입력입니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("outdt_fr")
	Return
End If

If ls_outdt_to = "" Then
	f_msg_info(200, This.Title, "'입금일자'의 필수 입력입니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("outdt_to")
	Return
End If
///////


////// 날짜 체크
If ls_outdt_fr <> "" Then 
	lb_check = fb_chk_stringdate(ls_outdt_fr)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'입금일자'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("outdt_fr")
		Return
	End If
End if

If ls_outdt_to <> "" Then 
	lb_check = fb_chk_stringdate(ls_outdt_to)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'입금일자'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("outdt_to")
		Return
	End If
End if

//////
If ls_outdt_fr <> "" AND ls_outdt_to <> "" Then
	If ls_outdt_fr > ls_outdt_to Then
		f_msg_usr_err(221, This.Title, "'입금일자'의 시작날짜가 종료날짜보다 작아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("outdt_fr")
		Return
	End if
End if

ls_where = ""




If ls_outdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDACCOUNT.OUTDT >= '" + MidA(ls_outdt_fr,3) + "' "
End If

If ls_outdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDACCOUNT.OUTDT <= '" + MidA(ls_outdt_to,3) + "' "
End If

If ls_membercode <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CARDACCOUNT.MEMBERCODE = '" + ls_membercode + "' "
End If

dw_list.is_where = ls_where
ll_rows = dw_list.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "dw_detail")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_print`dw_cond within b5w_prt_cardaccount_list
integer width = 1454
integer height = 208
string dataobject = "b5d_cnd_prt_cardaccount_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_cardaccount_list
integer x = 1595
integer y = 40
end type

type p_close from w_a_print`p_close within b5w_prt_cardaccount_list
integer x = 1595
integer y = 156
end type

type dw_list from w_a_print`dw_list within b5w_prt_cardaccount_list
integer y = 296
integer width = 3031
integer height = 1352
string dataobject = "b5d_prt_cardaccount_list"
end type

type p_1 from w_a_print`p_1 within b5w_prt_cardaccount_list
end type

type p_2 from w_a_print`p_2 within b5w_prt_cardaccount_list
end type

type p_3 from w_a_print`p_3 within b5w_prt_cardaccount_list
end type

type p_5 from w_a_print`p_5 within b5w_prt_cardaccount_list
end type

type p_6 from w_a_print`p_6 within b5w_prt_cardaccount_list
end type

type p_7 from w_a_print`p_7 within b5w_prt_cardaccount_list
end type

type p_8 from w_a_print`p_8 within b5w_prt_cardaccount_list
end type

type p_9 from w_a_print`p_9 within b5w_prt_cardaccount_list
end type

type p_4 from w_a_print`p_4 within b5w_prt_cardaccount_list
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_cardaccount_list
end type

type p_port from w_a_print`p_port within b5w_prt_cardaccount_list
end type

type p_land from w_a_print`p_land within b5w_prt_cardaccount_list
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_cardaccount_list
integer width = 1486
integer height = 272
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_cardaccount_list
end type

