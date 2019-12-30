$PBExportHeader$b2w_prt_commdet2.srw
$PBExportComments$[jsha] 매출수수료실적보고서
forward
global type b2w_prt_commdet2 from w_a_print
end type
end forward

global type b2w_prt_commdet2 from w_a_print
integer width = 3493
integer height = 1940
end type
global b2w_prt_commdet2 b2w_prt_commdet2

on b2w_prt_commdet2.create
call super::create
end on

on b2w_prt_commdet2.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_partner, ls_org_partner, ls_commdt, ls_salemonth_fr, ls_salemonth_to
DateTime ldt_commdt, ldt_salemonth_fr, ldt_salemonth_to
Long ll_rows

ls_partner = Trim(dw_cond.Object.partner[1])
ls_org_partner = Trim(dw_cond.Object.org_partner[1])

//ldt_commdt = dw_cond.Object.commdt[1]
//ldt_salemonth_fr = dw_cond.Object.sale_month_fr[1]
//ldt_salemonth_to = dw_cond.Object.sale_month_to[1]

ls_commdt = String(dw_cond.Object.commdt[1],'yyyy-mm')
ls_salemonth_fr = String(dw_cond.Object.sale_month_fr[1],'yyyy-mm')
ls_salemonth_to = String(dw_cond.Object.sale_month_to[1],'yyyy-mm')

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_org_partner) Then ls_org_partner = ""
If IsNull(ls_commdt) Then ls_commdt = ""
If IsNull(ls_salemonth_fr) Then ls_salemonth_fr = ""
If IsNull(ls_salemonth_to) Then ls_salemonth_to = ""

/******* Mandatory Field Check *******/
If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetColumn("partner")
	dw_cond.SetFocus()
	Return
End If
If ls_commdt = "" Then
	f_msg_usr_err(200, Title, "발생년월")
	dw_cond.SetColumn("commdt")
	dw_cond.SetFocus()
	Return
End If

ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "' "
End If
If ls_org_partner <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "org_partner = '" + ls_org_partner + "' "
End IF
If ls_commdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(commdt,'yyyy-mm') = '" + ls_commdt + "' "
End If
If ls_salemonth_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(sale_month,'yyyy-mm') >= '" + ls_salemonth_fr + "' "
End If
If ls_salemonth_to <> "" then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(sale_month,'yyyy-mm') <= '" + ls_salemonth_to + "' "
End If

dw_list.is_where = ls_where
ll_rows = dw_list.Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If

end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;dw_cond.Object.org_partner.protect = 1
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_commdet2
integer x = 50
integer width = 2496
integer height = 232
string dataobject = "b2dw_cnd_prt_commdet2"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_org_partner
Int li_exist
String ls_filter

Choose Case dwo.name 
	Case 'partner'
		dw_cond.Object.org_partner[1] = ""
		
		li_exist = dw_cond.getChild("org_partner",ldc_org_partner)
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Sub대리점")
		ls_filter = "hpartner = '" + data + "' "
			
		ldc_org_partner.SetTransObject(SQLCA)
		li_exist = ldc_org_partner.Retrieve()
		ldc_org_partner.SetFilter(ls_filter)			//Filter정함
		ldc_org_partner.Filter()
			
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
		dw_cond.object.org_partner.Protect = 0
		
End Choose
end event

type p_ok from w_a_print`p_ok within b2w_prt_commdet2
integer x = 2679
integer y = 60
end type

type p_close from w_a_print`p_close within b2w_prt_commdet2
integer x = 2981
integer y = 60
end type

type dw_list from w_a_print`dw_list within b2w_prt_commdet2
integer y = 308
integer width = 3392
string dataobject = "b2dw_prt_commdet2"
end type

type p_1 from w_a_print`p_1 within b2w_prt_commdet2
integer y = 1648
end type

type p_2 from w_a_print`p_2 within b2w_prt_commdet2
integer y = 1648
end type

type p_3 from w_a_print`p_3 within b2w_prt_commdet2
integer y = 1648
end type

type p_5 from w_a_print`p_5 within b2w_prt_commdet2
integer y = 1648
end type

type p_6 from w_a_print`p_6 within b2w_prt_commdet2
integer y = 1648
end type

type p_7 from w_a_print`p_7 within b2w_prt_commdet2
integer y = 1648
end type

type p_8 from w_a_print`p_8 within b2w_prt_commdet2
integer y = 1648
end type

type p_9 from w_a_print`p_9 within b2w_prt_commdet2
integer y = 1648
end type

type p_4 from w_a_print`p_4 within b2w_prt_commdet2
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_commdet2
integer y = 1608
end type

type p_port from w_a_print`p_port within b2w_prt_commdet2
integer y = 1672
end type

type p_land from w_a_print`p_land within b2w_prt_commdet2
integer y = 1684
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_commdet2
integer width = 2528
integer height = 288
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_commdet2
integer y = 1648
end type

