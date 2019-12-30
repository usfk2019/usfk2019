$PBExportHeader$w_reg_post.srw
$PBExportComments$[ceusee] 우편번호 등록/수정
forward
global type w_reg_post from w_a_reg_m
end type
end forward

global type w_reg_post from w_a_reg_m
integer width = 2231
integer height = 1960
windowstate windowstate = normal!
end type
global w_reg_post w_reg_post

on w_reg_post.create
call super::create
end on

on w_reg_post.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where
Long ll_rows
String ls_code, ls_codenm, ls_codenm2

ls_code = Trim(dw_cond.Object.code[1])
If Isnull(ls_code) Then ls_code = ""
ls_codenm = Trim(dw_cond.Object.codenm[1])
If Isnull(ls_codenm) Then ls_codenm = ""
ls_codenm2 = Trim(dw_cond.Object.codenm2[1])
If Isnull(ls_codenm2) Then ls_codenm2 = ""

If ls_code = "" AND ls_codenm = "" AND ls_codenm2 = "" Then
	f_msg_info(200, Title, "우편번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("code")
	Return
End If
	
ls_where = ""
If ls_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " code like '" + ls_code + "%' "
End If
If ls_codenm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " codenm like '%" + ls_codenm + "%' "
End If
If ls_codenm2 <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " codenm2 like '%" + ls_codenm2 + "%' "
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

event type integer ue_extra_save();Long ll_rows, i
String ls_code, ls_codenm, ls_codenm2

For i = 1 To dw_detail.RowCount()
	
	ls_code = Trim(dw_detail.Object.code[i])
	If Isnull(ls_code) Then ls_code = ""
	ls_codenm = Trim(dw_detail.Object.codenm[i])
	If Isnull(ls_codenm) Then ls_codenm = ""
	
	If ls_code = "" Then
		f_msg_usr_err(200, Title, "우편번호")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("code")
		Return -2
	End If
	
	If ls_codenm = "" Then
		f_msg_usr_err(200, Title, "주소1")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("codenm")
		Return -2
	End If
Next
Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_post
integer y = 44
integer width = 1335
integer height = 272
string dataobject = "d_cnd_reg_post"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_post
integer x = 1541
integer y = 68
end type

type p_close from w_a_reg_m`p_close within w_reg_post
integer x = 1847
integer y = 68
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_post
integer width = 1385
integer height = 328
end type

type p_delete from w_a_reg_m`p_delete within w_reg_post
integer x = 329
integer y = 1712
end type

type p_insert from w_a_reg_m`p_insert within w_reg_post
integer x = 37
integer y = 1712
end type

type p_save from w_a_reg_m`p_save within w_reg_post
integer y = 1712
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_post
integer x = 27
integer y = 352
integer width = 2139
integer height = 1320
string dataobject = "d_reg_post"
end type

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
	
end event

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(Off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_post
integer x = 1198
integer y = 1712
end type

