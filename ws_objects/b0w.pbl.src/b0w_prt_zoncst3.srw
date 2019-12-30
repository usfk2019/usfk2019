$PBExportHeader$b0w_prt_zoncst3.srw
$PBExportComments$[kem] 대역별 요율리스트3 Window
forward
global type b0w_prt_zoncst3 from w_a_print
end type
end forward

global type b0w_prt_zoncst3 from w_a_print
integer width = 3337
end type
global b0w_prt_zoncst3 b0w_prt_zoncst3

on b0w_prt_zoncst3.create
call super::create
end on

on b0w_prt_zoncst3.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_parttype, ls_zoncod, ls_priceplan, ls_opendt

ls_parttype	= Trim(dw_cond.Object.parttype[1])
ls_zoncod	= Trim(dw_cond.Object.zoncod[1])
ls_opendt   = String(dw_cond.Object.opendt[1], 'yyyymmdd')

If( IsNull(ls_parttype) ) Then ls_parttype = ""
If( IsNull(ls_zoncod) ) Then ls_zoncod = ""
If( IsNull(ls_opendt) ) Then ls_opendt = ""

//필수 항목 Check
If ls_parttype = "" Then
	f_msg_info(200, Title,"작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
   Return
End If

If ls_parttype = "A" Then
	ls_priceplan = "ALL"
	
Else
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	
	If ls_priceplan = "" Then
		f_msg_info(200, Title,"가격정책")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
	   Return
	End If

End If


//retrieve
ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " cst.priceplan = '" + ls_priceplan + "' "


If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " cst.zoncod = '" + ls_zoncod + "' "
End If

If ls_opendt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(cst.opendt, 'YYYYMMDD') >= '"+ ls_opendt +"'"
End If

dw_list.is_where = ls_where

////조건 Setting
//If ls_itemcod = "" Then
//	dw_list.object.t_itemcod.Text = "All"
//Else
//	dw_list.object.t_itemcod.Text = dw_cond.Describe("evaluate('lookupdisplay(itemcod)', 1)")
//End If

//Retrieve
ll_rows	= dw_list.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;//Format 지정
String ls_type, ls_parttype, ls_priceplan, ls_desc

dw_cond.object.parttype[1] = "A"
ls_parttype = Trim(dw_cond.object.parttype[1])

If ls_parttype = "A" Then
	ls_type = fs_get_control("B1", "Z100", ls_desc)
	
Else
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
	
	//Format 지정
	Select decpoint
	  Into :ls_type
	  From priceplanmst
	 Where priceplan = :ls_priceplan;
	 
End If

If ls_type = "0" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0"
	dw_list.object.zoncst2_unitfee.Format = "#,##0"
	dw_list.object.unitfee1.Format = "#,##0"
	dw_list.object.unitfee2.Format = "#,##0"
	dw_list.object.unitfee3.Format = "#,##0"
	dw_list.object.unitfee4.Format = "#,##0"
	dw_list.object.unitfee5.Format = "#,##0"
	dw_list.object.confee.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.0"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.0"
	dw_list.object.unitfee1.Format = "#,##0.0"
	dw_list.object.unitfee2.Format = "#,##0.0"
	dw_list.object.unitfee3.Format = "#,##0.0"
	dw_list.object.unitfee4.Format = "#,##0.0"
	dw_list.object.unitfee5.Format = "#,##0.0"
	dw_list.object.confee.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.00"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.00"
	dw_list.object.unitfee1.Format = "#,##0.00"
	dw_list.object.unitfee2.Format = "#,##0.00"
	dw_list.object.unitfee3.Format = "#,##0.00"
	dw_list.object.unitfee4.Format = "#,##0.00"
	dw_list.object.unitfee5.Format = "#,##0.00"
	dw_list.object.confee.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.000"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.000"
	dw_list.object.unitfee1.Format = "#,##0.000"
	dw_list.object.unitfee2.Format = "#,##0.000"
	dw_list.object.unitfee3.Format = "#,##0.000"
	dw_list.object.unitfee4.Format = "#,##0.000"
	dw_list.object.unitfee5.Format = "#,##0.000"
	dw_list.object.confee.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.0000"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.0000"
	dw_list.object.unitfee1.Format = "#,##0.0000"
	dw_list.object.unitfee2.Format = "#,##0.0000"
	dw_list.object.unitfee3.Format = "#,##0.0000"
	dw_list.object.unitfee4.Format = "#,##0.0000"
	dw_list.object.unitfee5.Format = "#,##0.0000"
	dw_list.object.confee.Format = "#,##0.0000"
End If

end event

event ue_reset();call super::ue_reset;//Format 지정
String ls_type, ls_parttype, ls_priceplan, ls_desc

dw_cond.object.parttype[1] = "A"
ls_parttype = Trim(dw_cond.object.parttype[1])

If ls_parttype = "A" Then
	ls_type = fs_get_control("B1", "Z100", ls_desc)
	
Else
	ls_priceplan = Trim(dw_cond.object.priceplan[1])
	
	//Format 지정
	Select decpoint
	  Into :ls_type
	  From priceplanmst
	 Where priceplan = :ls_priceplan;
	 
End If

If ls_type = "0" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0"
	dw_list.object.zoncst2_unitfee.Format = "#,##0"
	dw_list.object.unitfee1.Format = "#,##0"
	dw_list.object.unitfee2.Format = "#,##0"
	dw_list.object.unitfee3.Format = "#,##0"
	dw_list.object.unitfee4.Format = "#,##0"
	dw_list.object.unitfee5.Format = "#,##0"
	dw_list.object.confee.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.0"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.0"
	dw_list.object.unitfee1.Format = "#,##0.0"
	dw_list.object.unitfee2.Format = "#,##0.0"
	dw_list.object.unitfee3.Format = "#,##0.0"
	dw_list.object.unitfee4.Format = "#,##0.0"
	dw_list.object.unitfee5.Format = "#,##0.0"
	dw_list.object.confee.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.00"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.00"
	dw_list.object.unitfee1.Format = "#,##0.00"
	dw_list.object.unitfee2.Format = "#,##0.00"
	dw_list.object.unitfee3.Format = "#,##0.00"
	dw_list.object.unitfee4.Format = "#,##0.00"
	dw_list.object.unitfee5.Format = "#,##0.00"
	dw_list.object.confee.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.000"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.000"
	dw_list.object.unitfee1.Format = "#,##0.000"
	dw_list.object.unitfee2.Format = "#,##0.000"
	dw_list.object.unitfee3.Format = "#,##0.000"
	dw_list.object.unitfee4.Format = "#,##0.000"
	dw_list.object.unitfee5.Format = "#,##0.000"
	dw_list.object.confee.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_list.object.zoncst2_frpoint.Format = "#,##0.0000"	
	dw_list.object.zoncst2_unitfee.Format = "#,##0.0000"
	dw_list.object.unitfee1.Format = "#,##0.0000"
	dw_list.object.unitfee2.Format = "#,##0.0000"
	dw_list.object.unitfee3.Format = "#,##0.0000"
	dw_list.object.unitfee4.Format = "#,##0.0000"
	dw_list.object.unitfee5.Format = "#,##0.0000"
	dw_list.object.confee.Format = "#,##0.0000"
End If

end event

type dw_cond from w_a_print`dw_cond within b0w_prt_zoncst3
integer x = 55
integer y = 48
integer width = 2464
string dataobject = "b0dw_cnd_prt_zoncst3"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_row
String ls_filter, ls_itemcod
DataWindowChild ldc


If dwo.name = "parttype" Then
	
	If data = "A" Then
		This.Object.priceplan.Visible = 0
		This.Object.priceplan_t.Visible = 0
	
	Else
		This.Object.priceplan.Visible = 1
		This.Object.priceplan_t.Visible = 1
	
   End If
End If
end event

type p_ok from w_a_print`p_ok within b0w_prt_zoncst3
integer x = 2642
end type

type p_close from w_a_print`p_close within b0w_prt_zoncst3
integer x = 2944
end type

type dw_list from w_a_print`dw_list within b0w_prt_zoncst3
integer y = 352
integer width = 3237
integer height = 1248
string dataobject = "b0dw_prt_zoncst3"
end type

type p_1 from w_a_print`p_1 within b0w_prt_zoncst3
end type

type p_2 from w_a_print`p_2 within b0w_prt_zoncst3
end type

type p_3 from w_a_print`p_3 within b0w_prt_zoncst3
end type

type p_5 from w_a_print`p_5 within b0w_prt_zoncst3
end type

type p_6 from w_a_print`p_6 within b0w_prt_zoncst3
end type

type p_7 from w_a_print`p_7 within b0w_prt_zoncst3
end type

type p_8 from w_a_print`p_8 within b0w_prt_zoncst3
end type

type p_9 from w_a_print`p_9 within b0w_prt_zoncst3
end type

type p_4 from w_a_print`p_4 within b0w_prt_zoncst3
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_zoncst3
end type

type p_port from w_a_print`p_port within b0w_prt_zoncst3
end type

type p_land from w_a_print`p_land within b0w_prt_zoncst3
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_zoncst3
integer width = 2501
integer height = 340
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_zoncst3
end type

