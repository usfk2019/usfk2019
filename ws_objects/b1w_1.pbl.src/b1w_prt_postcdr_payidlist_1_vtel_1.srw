﻿$PBExportHeader$b1w_prt_postcdr_payidlist_1_vtel_1.srw
$PBExportComments$[kem] 후불납입고객통화상세내역서
forward
global type b1w_prt_postcdr_payidlist_1_vtel_1 from w_a_print
end type
end forward

global type b1w_prt_postcdr_payidlist_1_vtel_1 from w_a_print
integer width = 3099
integer height = 1952
end type
global b1w_prt_postcdr_payidlist_1_vtel_1 b1w_prt_postcdr_payidlist_1_vtel_1

type variables

end variables

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_postcdr_payidlist
	Desc.	: 후불납입고객통화상세내역서(브이텔)
	Ver.	: 1.0
	Date	: 2003.9.23
	Programer : Kim Eun Mi(kem)
-------------------------------------------------------------------------*/

//dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
//dw_cond.object.todt[1]   = fdt_get_dbserver_now()
dw_cond.object.gubun[1]  = '0'



end event

on b1w_prt_postcdr_payidlist_1_vtel_1.create
call super::create
end on

on b1w_prt_postcdr_payidlist_1_vtel_1.destroy
call super::destroy
end on

event ue_ok();String ls_fromdt, ls_todt, ls_gubun, ls_area, ls_validkey, ls_payid, ls_where
string ls_trdt, ls_chargedt
Date ld_trdt
Long ll_row

dw_cond.AcceptText()

ld_trdt     = dw_cond.Object.trdt[1]
ls_trdt     = String(ld_trdt,'yyyymmdd')
ls_gubun    = Trim(dw_cond.object.gubun[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_payid    = Trim(dw_cond.object.payid[1])
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
//Null Check
If IsNull(ls_trdt) Then ls_trdt = "00000000"

If IsNull(ls_gubun) Then ls_gubun = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_chargedt) Then ls_chargedt =""		
//Retrieve
//If ls_payid = "" And ls_validkey = "" Then
//	f_msg_info(200, Title, "납입고객 혹은 인증KEY")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("payid")
//	Return
//End If

If ls_trdt = "" Then
	f_msg_info(200, Title, "청구기준일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
End If

//If ls_fromdt <> "" And ls_todt <> "" Then
//	If ls_fromdt > ls_todt Then
//		f_msg_usr_err(210, title, "통화일자")
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("fromdt")
//		Return
//	End If
//End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " p.payid = '" + ls_payid + "' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " p.validkey = '" + ls_validkey + "' "
End If

If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.bilcycle = '"+ ls_chargedt +"' "
End If

dw_list.SetRedraw(false)

If ls_gubun = "0"  Then 
	dw_list.DataObject = "b1dw_prt_postcdr_payidlist_1_vtel_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve(ls_trdt)
	
ElseIf ls_gubun = "1" Then
	dw_list.DataObject = "b1dw_prt_postcdrh_payidlist_1_vtel_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve(ls_trdt)
End If

dw_list.object.date_t.Text = String(ld_trdt,'yyyy-mm-dd')

//dw_list.is_where = ls_where
//ll_row = dw_list.Retrieve()

dw_list.setredraw(true)

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_reset();call super::ue_reset;
//dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
//dw_cond.object.todt[1]   = fdt_get_dbserver_now()
dw_cond.object.gubun[1]  = '0'
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 40
integer width = 2162
integer height = 376
string dataobject = "b1dw_cnd_prt_postcdr_payidlist_vtel_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "payid"
		
		If data <> "" then 
			SELECT CUSTOMERNM
			  INTO :ls_customernm
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :data ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, title, 'select error')
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, title, 'select not found')
			Else
				This.object.customernm[1] = ls_customernm
			End If
		Else
			This.object.customernm[1] = ""
			
		End If		 
		 
End Choose

Return 0 
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row]      = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b1w_prt_postcdr_payidlist_1_vtel_1
integer x = 2368
end type

type p_close from w_a_print`p_close within b1w_prt_postcdr_payidlist_1_vtel_1
integer x = 2688
end type

type dw_list from w_a_print`dw_list within b1w_prt_postcdr_payidlist_1_vtel_1
integer x = 23
integer y = 476
integer width = 2999
integer height = 1088
string dataobject = "b1dw_prt_postcdr_payidlist_1_vtel_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_2 from w_a_print`p_2 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_3 from w_a_print`p_3 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_5 from w_a_print`p_5 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_6 from w_a_print`p_6 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_7 from w_a_print`p_7 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_8 from w_a_print`p_8 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_9 from w_a_print`p_9 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

type p_4 from w_a_print`p_4 within b1w_prt_postcdr_payidlist_1_vtel_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1596
end type

type p_port from w_a_print`p_port within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1660
end type

type p_land from w_a_print`p_land within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1672
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_postcdr_payidlist_1_vtel_1
integer width = 2226
integer height = 448
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_postcdr_payidlist_1_vtel_1
integer y = 1636
end type

