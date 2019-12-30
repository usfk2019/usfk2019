$PBExportHeader$b4w_hlp_customer_deposit_v20.srw
$PBExportComments$[ohj] Help : 사용자 ID(보증금관리고객만 조회) v20
forward
global type b4w_hlp_customer_deposit_v20 from w_a_hlp
end type
end forward

global type b4w_hlp_customer_deposit_v20 from w_a_hlp
integer width = 3063
integer height = 1864
end type
global b4w_hlp_customer_deposit_v20 b4w_hlp_customer_deposit_v20

on b4w_hlp_customer_deposit_v20.create
call super::create
end on

on b4w_hlp_customer_deposit_v20.destroy
call super::destroy
end on

event ue_find;call super::ue_find;String ls_where
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

If (ls_value = ""  Or ls_name = "" ) And ls_status = "" And ls_ctype = "" Then
		f_msg_info(200, Title, "최소한 하나이상의 조건항목을 입력하십시오.")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If


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
iu_cust_help.is_data[4] = Trim(dw_hlp.Object.SVCCOD[al_selrow])
end event

type p_1 from w_a_hlp`p_1 within b4w_hlp_customer_deposit_v20
integer x = 2011
integer y = 52
end type

type dw_cond from w_a_hlp`dw_cond within b4w_hlp_customer_deposit_v20
integer x = 41
integer y = 44
integer width = 1847
integer height = 188
string dataobject = "b4dw_cnd_hlp_customer_deposit_v20"
end type

type p_ok from w_a_hlp`p_ok within b4w_hlp_customer_deposit_v20
integer x = 2313
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b4w_hlp_customer_deposit_v20
integer x = 2610
integer y = 52
end type

type gb_cond from w_a_hlp`gb_cond within b4w_hlp_customer_deposit_v20
integer x = 14
integer width = 1893
integer height = 248
end type

type dw_hlp from w_a_hlp`dw_hlp within b4w_hlp_customer_deposit_v20
integer x = 18
integer y = 276
integer width = 3017
integer height = 1476
string dataobject = "b4dw_hlp_customer_deposit_v20"
boolean hscrollbar = true
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.customerid_t
uf_init(ldwo_sort)
end event

