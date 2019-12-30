$PBExportHeader$b1w_1_hlp_customerm_carrier.srw
$PBExportComments$[jsha] 중계호사업자용 help
forward
global type b1w_1_hlp_customerm_carrier from b1w_hlp_customerm
end type
end forward

global type b1w_1_hlp_customerm_carrier from b1w_hlp_customerm
end type
global b1w_1_hlp_customerm_carrier b1w_1_hlp_customerm_carrier

type variables
String is_ctype1
end variables

on b1w_1_hlp_customerm_carrier.create
call super::create
end on

on b1w_1_hlp_customerm_carrier.destroy
call super::destroy
end on

event ue_find();String ls_where
String ls_value, ls_name
Long ll_row

dw_cond.AcceptText()

ls_value = Trim(dw_cond.object.value[1])
ls_name = Trim(dw_cond.object.name[1])
If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""

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

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve(is_ctype1)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;String ls_ref_desc

is_ctype1 = fs_get_control('B0', 'P120', ls_ref_desc)
end event

type p_1 from b1w_hlp_customerm`p_1 within b1w_1_hlp_customerm_carrier
end type

type dw_cond from b1w_hlp_customerm`dw_cond within b1w_1_hlp_customerm_carrier
integer height = 132
string dataobject = "b1dw_cnd_hlp_customerm_carrier"
end type

type p_ok from b1w_hlp_customerm`p_ok within b1w_1_hlp_customerm_carrier
end type

type p_close from b1w_hlp_customerm`p_close within b1w_1_hlp_customerm_carrier
end type

type gb_cond from b1w_hlp_customerm`gb_cond within b1w_1_hlp_customerm_carrier
integer height = 188
end type

type dw_hlp from b1w_hlp_customerm`dw_hlp within b1w_1_hlp_customerm_carrier
integer y = 212
string dataobject = "b1dw_hlp_customerm_carrier"
end type

