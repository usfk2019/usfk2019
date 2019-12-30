$PBExportHeader$ssrt_hlp_customer.srw
$PBExportComments$[1hera] Help : Customer INFO
forward
global type ssrt_hlp_customer from w_a_hlp
end type
end forward

global type ssrt_hlp_customer from w_a_hlp
integer width = 3063
integer height = 1864
end type
global ssrt_hlp_customer ssrt_hlp_customer

type variables
//
end variables

on ssrt_hlp_customer.create
call super::create
end on

on ssrt_hlp_customer.destroy
call super::destroy
end on

event ue_find();call super::ue_find;String 	ls_where
String 	ls_value, 	ls_name, 	ls_status, 	ls_ctype
Long 		ll_row

ls_value 	= Trim(dw_cond.object.value[1])
ls_name 		= Trim(dw_cond.object.name[1])
If IsNull(ls_value) 		Then ls_value 	= ""
If IsNull(ls_name) 		Then ls_name 	= ""

If (ls_value = ""  Or ls_name = "" ) Then
		f_msg_info(200, Title, "조건항목을 입력하십시오.")
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
			Case "buildingno"
				ls_where += "buildingno like '" + ls_name + "%' "
			Case "roomno"
				ls_where += "roomno like '" + ls_name + "%' "
			Case "basecod"
				ls_where += "basecod like '" + ls_name + "%' "
			Case "homephone"
				ls_where += "homephone like '" + ls_name + "%' "
		End Choose		
	End If

//If ls_status <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "status = '" + ls_status + "'"
//End If
//
//If ls_ctype <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "ctype1 = '" + ls_ctype + "'"
//End If
//

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;This.Title = "Customer Info"

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('value')
end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.customerid[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.customernm[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.status[al_selrow])
iu_cust_help.is_data[4] = Trim(dw_hlp.Object.memberid[al_selrow])
iu_cust_help.is_data[5] = Trim(dw_hlp.Object.buildingno[al_selrow])
iu_cust_help.is_data[6] = Trim(dw_hlp.Object.roomno[al_selrow])
iu_cust_help.is_data[7] = Trim(dw_hlp.Object.basecod[al_selrow])
iu_cust_help.is_data[8] = Trim(dw_hlp.Object.logid[al_selrow])

end event

event key;Choose Case key
	Case KeyEnter!, KeyTab!
		This.TriggerEvent('ue_find')
	Case KeyEscape!
		This.TriggerEvent('ue_close')
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

type p_1 from w_a_hlp`p_1 within ssrt_hlp_customer
integer x = 2011
integer y = 52
integer taborder = 1
end type

type dw_cond from w_a_hlp`dw_cond within ssrt_hlp_customer
event ue_key pbm_dwnkey
integer x = 41
integer y = 44
integer width = 1847
integer height = 188
integer taborder = 0
string dataobject = "ssrt_cnd_hlp_customer"
end type

event dw_cond::ue_key;Choose Case key
	Case KeyEnter!
		Parent.TriggerEvent('ue_find')
	Case KeyEscape!
		Parent.TriggerEvent('ue_close')
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

type p_ok from w_a_hlp`p_ok within ssrt_hlp_customer
integer x = 2313
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within ssrt_hlp_customer
integer x = 2610
integer y = 52
end type

type gb_cond from w_a_hlp`gb_cond within ssrt_hlp_customer
integer x = 14
integer width = 1893
integer height = 248
integer taborder = 0
end type

type dw_hlp from w_a_hlp`dw_hlp within ssrt_hlp_customer
integer x = 18
integer y = 276
integer width = 3017
integer height = 1476
string dataobject = "ssrt_hlp_customer"
boolean hscrollbar = true
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.customerid_t
uf_init(ldwo_sort)
end event

