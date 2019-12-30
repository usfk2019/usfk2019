$PBExportHeader$b4w_prt_customer_deposit_used_v20.srw
$PBExportComments$[ohj] 고객보증금사용내역 보고서 v20
forward
global type b4w_prt_customer_deposit_used_v20 from w_a_print
end type
end forward

global type b4w_prt_customer_deposit_used_v20 from w_a_print
integer width = 3296
end type
global b4w_prt_customer_deposit_used_v20 b4w_prt_customer_deposit_used_v20

on b4w_prt_customer_deposit_used_v20.create
call super::create
end on

on b4w_prt_customer_deposit_used_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where, ls_payid, ls_svccod, ls_priceplan, ls_customernm
String	ls_crtfrom, ls_crtto
Date     ld_crtfrom, ld_crtto

ls_payid      = Trim(dw_cond.object.payid[1])
ls_customernm = Trim(dw_cond.object.customernm[1])
ls_svccod     = Trim(dw_cond.object.svccod[1])
ls_priceplan  = Trim(dw_cond.object.priceplan[1])
ls_crtfrom	  = Trim(String(dw_cond.object.crtdt_from[1],'yyyymmdd'))
ld_crtfrom    = dw_cond.Object.crtdt_from[1]
ls_crtto		  = Trim(String(dw_cond.object.crtdt_to[1],'yyyymmdd'))
ld_crtto      = dw_cond.object.crtdt_to[1]

If(IsNull(ls_payid))     Then ls_payid     = ""
If(IsNull(ls_svccod))    Then ls_svccod    = ""
If(IsNull(ls_priceplan)) Then ls_priceplan = ""
If(IsNull(ls_crtfrom))   Then ls_crtfrom   = ""
If(IsNull(ls_crtto))     Then ls_crtto     = ""

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "고객번호")
	dw_cond.SetColumn("payid")
	dw_cond.SetFocus()
   Return
End If

If ls_svccod = "" Then
	f_msg_usr_err(200, Title, "서비스")
	dw_cond.SetColumn("svccod")
	dw_cond.SetFocus()
   Return
End If

If ls_crtfrom = "" Then
	If ls_crtto <> "" Then
		f_msg_usr_err(200, Title, "작업일from")
		dw_cond.SetColumn("crtdt_from")
		dw_cond.SetFocus()
   	Return 
	End If
Else 
	If ls_crtto = "" Then		
		dw_cond.Object.crtdt_to[1] = ld_crtfrom
	ElseIf ld_crtto < ld_crtfrom Then
		f_msg_usr_err(200, Title, "작업일From 을 확인하세요.")
		dw_cond.SetColumn("crtdt_from")
		dw_cond.SetFocus()
		Return 		
	End If
End If

//If ls_crtto <>"" Then
//	If ls_crtfrom = "" Then
//		f_msg_usr_err(200, Title, "작업일from")
//		dw_cond.SetColumn("crtdt_from")
//		dw_cond.SetFocus()
//  		Return 		
//	End If
//	
//	If ld_crtto < ld_crtfrom Then
//		f_msg_usr_err(200, Title, "작업일From 을 확인하세요.")
//		dw_cond.SetColumn("crtdt_from")
//		dw_cond.SetFocus()
//		Return 		
//	End If	
//End If	

//Dynamic SQL
ls_where = ""
If ls_payid <> "" Then
	If ls_where <> ""  Then ls_where += " AND "
	ls_where += " a.payid = '"+ ls_payid +"'"
End If

If ls_svccod <> "" Then
	If ls_where <> ""  Then ls_where += " AND "
	ls_where += " a.svccod = '"+ ls_svccod +"'"
End If

If ls_priceplan <> "" Then
	If ls_where <> ""  Then ls_where += " AND "
	ls_where += " a.priceplan = '"+ ls_priceplan +"'"
End If

If( ls_crtfrom <> "") Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += " a.workdt >= '"+ ls_crtfrom +"'"
End If

If( ls_crtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += " a.workdt <= '"+ ls_crtto +"'"
End If

dw_list.is_where	= ls_where
//MessageBox("쿼리", ls_where)

dw_list.object.customernm_t.Text = ls_customernm
dw_list.object.svccod_t.Text     = dw_cond.Describe("evaluate('lookupdisplay(svccod)',1 )")

//Retrieve
ll_rows	= dw_list.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
End If


end event

event ue_init();call super::ue_init;ii_orientation = 2
dw_list.object.datawindow.print.orientation = ii_orientation

end event

event open;call super::open;string ls_format, ls_ref_desc, ls_gubun
//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)

If ls_format = "1" Then
	dw_list.object.bilamt.Format     = "#,##0.0"
	dw_list.object.bilamt_sum.Format = "#,##0.0"
	
ElseIf ls_format = "2" Then
	dw_list.object.bilamt.Format     = "#,##0.00"
	dw_list.object.bilamt_sum.Format = "#,##0.00"
Else
	dw_list.object.bilamt.Format     = "#,##0"
	dw_list.object.bilamt_sum.Format = "#,##0"	
End If
end event

type dw_cond from w_a_print`dw_cond within b4w_prt_customer_deposit_used_v20
integer width = 1751
integer height = 320
string dataobject = "b4dw_cnd_prt_customer_deposit_used_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;String ls_filter, ls_svccod, ls_priceplan
Int li_rc

DataWindowChild ldwc_priceplan
dw_cond.Accepttext()

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row]      = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
			Object.svccod[row]     = iu_cust_help.is_data[4]
		End If
		
	Case "svccod"
		dw_cond.object.priceplan[1] = ''
		
		ls_svccod = dw_cond.object.svccod[1] 
		
		li_rc = This.GetChild("priceplan", ldwc_priceplan)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : priceplan")
			Return
		End If
		
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldwc_priceplan.SetFilter(ls_filter)
		ldwc_priceplan.Filter()
		
		ldwc_priceplan.SetTransObject(SQLCA)
		
		li_rc = ldwc_priceplan.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "priceplan Retrieve()")
			Return
		End If		
				
End Choose
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b4w_hlp_customer_deposit_v20"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "payid"
		Object.customernm[1] = ""
		
End Choose
end event

type p_ok from w_a_print`p_ok within b4w_prt_customer_deposit_used_v20
integer x = 1975
integer y = 32
end type

type p_close from w_a_print`p_close within b4w_prt_customer_deposit_used_v20
integer x = 2277
integer y = 32
end type

type dw_list from w_a_print`dw_list within b4w_prt_customer_deposit_used_v20
integer y = 424
integer width = 3182
integer height = 1184
string dataobject = "b4dw_prt_customer_deposit_used_v20"
end type

type p_1 from w_a_print`p_1 within b4w_prt_customer_deposit_used_v20
end type

type p_2 from w_a_print`p_2 within b4w_prt_customer_deposit_used_v20
end type

type p_3 from w_a_print`p_3 within b4w_prt_customer_deposit_used_v20
end type

type p_5 from w_a_print`p_5 within b4w_prt_customer_deposit_used_v20
end type

type p_6 from w_a_print`p_6 within b4w_prt_customer_deposit_used_v20
end type

type p_7 from w_a_print`p_7 within b4w_prt_customer_deposit_used_v20
end type

type p_8 from w_a_print`p_8 within b4w_prt_customer_deposit_used_v20
end type

type p_9 from w_a_print`p_9 within b4w_prt_customer_deposit_used_v20
end type

type p_4 from w_a_print`p_4 within b4w_prt_customer_deposit_used_v20
end type

type gb_1 from w_a_print`gb_1 within b4w_prt_customer_deposit_used_v20
end type

type p_port from w_a_print`p_port within b4w_prt_customer_deposit_used_v20
end type

type p_land from w_a_print`p_land within b4w_prt_customer_deposit_used_v20
end type

type gb_cond from w_a_print`gb_cond within b4w_prt_customer_deposit_used_v20
integer width = 1879
integer height = 408
integer taborder = 30
end type

type p_saveas from w_a_print`p_saveas within b4w_prt_customer_deposit_used_v20
end type

