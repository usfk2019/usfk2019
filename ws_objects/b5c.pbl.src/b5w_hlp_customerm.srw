﻿$PBExportHeader$b5w_hlp_customerm.srw
$PBExportComments$[ceusee] Help : 사용자 ID
forward
global type b5w_hlp_customerm from w_a_hlp
end type
end forward

global type b5w_hlp_customerm from w_a_hlp
integer width = 3064
integer height = 1864
end type
global b5w_hlp_customerm b5w_hlp_customerm

on b5w_hlp_customerm.create
call super::create
end on

on b5w_hlp_customerm.destroy
call super::destroy
end on

event ue_find();call super::ue_find;String ls_where
String ls_value, ls_name, ls_status, ls_ctype
Long ll_row

ls_value = Trim(dw_cond.object.value[1])
ls_name = Trim(dw_cond.object.name[1])
ls_status = Trim(dw_cond.object.status[1])
ls_ctype = Trim(dw_cond.object.ctype[1])
If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_ctype) Then ls_ctype = ""
ls_where = ""

If ls_value <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "customerid"
				ls_where += "customerid like '" + ls_name + "%' "
			Case "customernm"
				ls_where += "Upper(customernm) like '%" + Upper(ls_name) + "%' "
			Case "payid"
				ls_where += "payid like '" + ls_name + "%' "
			Case "logid"
				ls_where += "Upper(logid) like '%" + Upper(ls_name) + "%' "
			Case "ssno"
				ls_where += "ssno like '" + ls_name + "%' "
			Case "corpno"
				ls_where += "corpno like '" + ls_name + "%' "
			Case "corpnm"
				ls_where += "Upper(corpnm) like '%" + Upper(ls_name) + "%' "
			Case "cregno"
				ls_where += "cregno like '" + ls_name + "%' "
			Case "phone1"
				ls_where += "phone1 like '" + ls_name + "%' "
			Case "email"
				ls_where += "Upper(EMAIL1) like '%" + Upper(ls_name) + "%' "
		End Choose		
	End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "status = '" + ls_status + "'"
End If

If ls_ctype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "ctype1 = '" + ls_ctype + "'"
End If


dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;This.Title = "Help - 사용자 Customer ID"
end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.customerid[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.customernm[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.status[al_selrow])

end event

type p_1 from w_a_hlp`p_1 within b5w_hlp_customerm
integer x = 2025
integer y = 56
end type

type dw_cond from w_a_hlp`dw_cond within b5w_hlp_customerm
integer x = 41
integer y = 44
integer width = 1851
integer height = 184
string dataobject = "b5dw_cnd_hlp_customerm"
end type

type p_ok from w_a_hlp`p_ok within b5w_hlp_customerm
integer x = 2327
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b5w_hlp_customerm
integer x = 2624
integer y = 56
end type

type gb_cond from w_a_hlp`gb_cond within b5w_hlp_customerm
integer x = 23
integer width = 1893
integer height = 252
end type

type dw_hlp from w_a_hlp`dw_hlp within b5w_hlp_customerm
integer x = 23
integer y = 268
integer width = 2994
integer height = 1500
string dataobject = "b5dw_hlp_customerm"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.customerid_t
uf_init(ldwo_sort)
end event

