$PBExportHeader$b1w_hlp_payid.srw
$PBExportComments$[parkkh] Help 납입자 ID
forward
global type b1w_hlp_payid from w_a_hlp
end type
end forward

global type b1w_hlp_payid from w_a_hlp
integer width = 3063
integer height = 1864
end type
global b1w_hlp_payid b1w_hlp_payid

on b1w_hlp_payid.create
call super::create
end on

on b1w_hlp_payid.destroy
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
				ls_where += "SOCIALSECURITY like '" + ls_name + "%' "
			Case "corpnm"
				ls_where += "Upper(corpnm) like '%" + Upper(ls_name) + "%' "
			Case "phone1"
				ls_where += "homephone like '" + ls_name + "%' "
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

event open;call super::open;This.Title = "Help Pay ID"
end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = Trim(dw_hlp.Object.customerid[al_selrow])			//ID
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.customernm[al_selrow])			//Name
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.zipcod[al_selrow])	//우편번호
iu_cust_help.is_data[4] = Trim(dw_hlp.Object.addr1[al_selrow])	//주소1
iu_cust_help.is_data[5] = Trim(dw_hlp.Object.addr2[al_selrow])	//주소2
iu_cust_help.is_data[6] = Trim(dw_hlp.Object.phone1[al_selrow])	//전화번호
end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_payid
integer x = 2007
integer y = 52
boolean originalsize = false
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_payid
integer x = 32
integer y = 60
integer width = 1847
integer height = 208
string dataobject = "b1dw_cnd_hlp_payid"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_payid
integer x = 2304
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b1w_hlp_payid
integer x = 2597
integer y = 52
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_payid
integer x = 18
integer width = 1883
integer height = 296
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_payid
integer x = 23
integer y = 308
integer width = 3003
integer height = 1448
string dataobject = "b1dw_hlp_payid"
boolean livescroll = false
end type

event dw_hlp::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.customerid_t
uf_init(ldwo_SORT)
end event

