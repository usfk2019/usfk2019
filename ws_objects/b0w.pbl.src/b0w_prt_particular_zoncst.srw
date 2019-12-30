$PBExportHeader$b0w_prt_particular_zoncst.srw
$PBExportComments$[kem] 개별 요율리스트 Window
forward
global type b0w_prt_particular_zoncst from w_a_print
end type
end forward

global type b0w_prt_particular_zoncst from w_a_print
integer width = 3337
end type
global b0w_prt_particular_zoncst b0w_prt_particular_zoncst

on b0w_prt_particular_zoncst.create
call super::create
end on

on b0w_prt_particular_zoncst.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_parttype, ls_zoncod, ls_partcod, ls_partcod1, ls_opendt

ls_parttype = Trim(dw_cond.object.parttype[1])
ls_partcod1 = Trim(dw_cond.object.partcod1[1])
If IsNull(ls_partcod1) Or ls_partcod1 = "" Then
	dw_cond.object.partcod1[1] = Trim(dw_cond.object.partcod[1])
End If
ls_partcod  = Trim(dw_cond.object.partcod1[1])
ls_zoncod   = Trim(dw_cond.object.zoncod[1])
ls_opendt   = String(dw_cond.object.opendt[1], 'yyyymmdd')

If( IsNull(ls_parttype) ) Then ls_parttype = ""
If( IsNull(ls_partcod) ) Then ls_partcod = ""
If( IsNull(ls_zoncod) ) Then ls_zoncod = ""
If( IsNull(ls_opendt) ) Then ls_opendt = ""

//필수 항목 Check
If ls_parttype = "" Then
	f_msg_info(200, Title,"그룹선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
   Return
End If

//retrieve
ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " cst.parttype = '" + ls_parttype + "' "

If ls_partcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " cst.partcod = '" + ls_partcod + "' "
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " cst.zoncod = '" + ls_zoncod + "' "
End If

If ls_opendt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(cst.opendt, 'YYYYMMDD') >= '"+ ls_opendt +"'"
End If

dw_list.SetRedraw(False)

//데이터 윈도우 바꾸기 
If ls_parttype = "S"  Then 
	dw_list.DataObject = "b0dw_prt_particular_zoncst"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "C" Then
	dw_list.DataObject = "b0dw_prt_particular_zoncst_c"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "P" Then
	dw_list.DataObject = "b0dw_prt_particular_zoncst_p"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
End If

//Retrieve
ll_rows	= dw_list.Retrieve()
dw_list.SetRedraw(True)

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
String ls_type, ls_desc

ls_type = fs_get_control("B1", "Z100", ls_desc)
	
If ls_type = "0" Then
	dw_list.object.frpoint.Format = "#,##0"
	dw_list.object.unitfee.Format = "#,##0"
	dw_list.object.unitfee1.Format = "#,##0"
	dw_list.object.unitfee2.Format = "#,##0"
	dw_list.object.unitfee3.Format = "#,##0"
	dw_list.object.unitfee4.Format = "#,##0"
	dw_list.object.unitfee5.Format = "#,##0"
	dw_list.object.confee.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_list.object.frpoint.Format = "#,##0.0"	
	dw_list.object.unitfee.Format = "#,##0.0"
	dw_list.object.unitfee1.Format = "#,##0.0"
	dw_list.object.unitfee2.Format = "#,##0.0"
	dw_list.object.unitfee3.Format = "#,##0.0"
	dw_list.object.unitfee4.Format = "#,##0.0"
	dw_list.object.unitfee5.Format = "#,##0.0"
	dw_list.object.confee.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_list.object.frpoint.Format = "#,##0.00"	
	dw_list.object.unitfee.Format = "#,##0.00"
	dw_list.object.unitfee1.Format = "#,##0.00"
	dw_list.object.unitfee2.Format = "#,##0.00"
	dw_list.object.unitfee3.Format = "#,##0.00"
	dw_list.object.unitfee4.Format = "#,##0.00"
	dw_list.object.unitfee5.Format = "#,##0.00"
	dw_list.object.confee.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_list.object.frpoint.Format = "#,##0.000"	
	dw_list.object.unitfee.Format = "#,##0.000"
	dw_list.object.unitfee1.Format = "#,##0.000"
	dw_list.object.unitfee2.Format = "#,##0.000"
	dw_list.object.unitfee3.Format = "#,##0.000"
	dw_list.object.unitfee4.Format = "#,##0.000"
	dw_list.object.unitfee5.Format = "#,##0.000"
	dw_list.object.confee.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_list.object.frpoint.Format = "#,##0.0000"	
	dw_list.object.unitfee.Format = "#,##0.0000"
	dw_list.object.unitfee1.Format = "#,##0.0000"
	dw_list.object.unitfee2.Format = "#,##0.0000"
	dw_list.object.unitfee3.Format = "#,##0.0000"
	dw_list.object.unitfee4.Format = "#,##0.0000"
	dw_list.object.unitfee5.Format = "#,##0.0000"
	dw_list.object.confee.Format = "#,##0.0000"
End If

end event

event ue_reset();call super::ue_reset;//Format 지정
String ls_type, ls_desc

dw_cond.Object.partcod_t.Text = "그룹"

ls_type = fs_get_control("B1", "Z100", ls_desc)
	
If ls_type = "0" Then
	dw_list.object.frpoint.Format = "#,##0"
	dw_list.object.unitfee.Format = "#,##0"
	dw_list.object.unitfee1.Format = "#,##0"
	dw_list.object.unitfee2.Format = "#,##0"
	dw_list.object.unitfee3.Format = "#,##0"
	dw_list.object.unitfee4.Format = "#,##0"
	dw_list.object.unitfee5.Format = "#,##0"
	dw_list.object.confee.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_list.object.frpoint.Format = "#,##0.0"	
	dw_list.object.unitfee.Format = "#,##0.0"
	dw_list.object.unitfee1.Format = "#,##0.0"
	dw_list.object.unitfee2.Format = "#,##0.0"
	dw_list.object.unitfee3.Format = "#,##0.0"
	dw_list.object.unitfee4.Format = "#,##0.0"
	dw_list.object.unitfee5.Format = "#,##0.0"
	dw_list.object.confee.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_list.object.frpoint.Format = "#,##0.00"	
	dw_list.object.unitfee.Format = "#,##0.00"
	dw_list.object.unitfee1.Format = "#,##0.00"
	dw_list.object.unitfee2.Format = "#,##0.00"
	dw_list.object.unitfee3.Format = "#,##0.00"
	dw_list.object.unitfee4.Format = "#,##0.00"
	dw_list.object.unitfee5.Format = "#,##0.00"
	dw_list.object.confee.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_list.object.frpoint.Format = "#,##0.000"	
	dw_list.object.unitfee.Format = "#,##0.000"
	dw_list.object.unitfee1.Format = "#,##0.000"
	dw_list.object.unitfee2.Format = "#,##0.000"
	dw_list.object.unitfee3.Format = "#,##0.000"
	dw_list.object.unitfee4.Format = "#,##0.000"
	dw_list.object.unitfee5.Format = "#,##0.000"
	dw_list.object.confee.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_list.object.frpoint.Format = "#,##0.0000"	
	dw_list.object.unitfee.Format = "#,##0.0000"
	dw_list.object.unitfee1.Format = "#,##0.0000"
	dw_list.object.unitfee2.Format = "#,##0.0000"
	dw_list.object.unitfee3.Format = "#,##0.0000"
	dw_list.object.unitfee4.Format = "#,##0.0000"
	dw_list.object.unitfee5.Format = "#,##0.0000"
	dw_list.object.confee.Format = "#,##0.0000"
End If

end event

type dw_cond from w_a_print`dw_cond within b0w_prt_particular_zoncst
integer x = 55
integer y = 48
integer width = 2153
integer height = 252
string dataobject = "b0dw_cnd_prt_particular_zoncst"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;
If Lower(dwo.name) = "parttype" Then
	Choose Case data
		Case "S"
			This.Object.partcod_t.Text     = "대리점"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_partner"
			is_data[1] = "CloseWithReturn"
			
		Case "C"
			This.Object.partcod_t.Text     = "고객번호"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_customerm"
			is_data[1] = "CloseWithReturn"
			
		Case "P"
			This.Object.partcod_t.Text     = "Pin"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_cardmst"
			is_data[1] = "CloseWithReturn"
	End Choose
	
End If
end event

event dw_cond::doubleclicked;call super::doubleclicked;String ls_parttype

This.AcceptText()

ls_parttype = Trim(This.Object.parttype[1])

If IsNull(ls_parttype) Or ls_parttype = "" Then
	f_msg_info(200, Title, "그룹선택")
	This.SetFocus()
	This.SetColumn("parttype")
	Return
End If

If ls_parttype = "C" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[2]
			End If
	End Choose
	
ElseIf ls_parttype = "S" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[2]
			End If 

	End Choose
	
ElseIf ls_parttype = "P" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[1]
			End If

	End Choose
	
End If
end event

event dw_cond::ue_init();call super::ue_init;//고객 help popup
idwo_help_col[1] = Object.partcod
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b0w_prt_particular_zoncst
integer x = 2350
end type

type p_close from w_a_print`p_close within b0w_prt_particular_zoncst
integer x = 2651
end type

type dw_list from w_a_print`dw_list within b0w_prt_particular_zoncst
integer y = 336
integer width = 3237
integer height = 1264
string dataobject = "b0dw_prt_particular_zoncst"
end type

type p_1 from w_a_print`p_1 within b0w_prt_particular_zoncst
end type

type p_2 from w_a_print`p_2 within b0w_prt_particular_zoncst
end type

type p_3 from w_a_print`p_3 within b0w_prt_particular_zoncst
end type

type p_5 from w_a_print`p_5 within b0w_prt_particular_zoncst
end type

type p_6 from w_a_print`p_6 within b0w_prt_particular_zoncst
end type

type p_7 from w_a_print`p_7 within b0w_prt_particular_zoncst
end type

type p_8 from w_a_print`p_8 within b0w_prt_particular_zoncst
end type

type p_9 from w_a_print`p_9 within b0w_prt_particular_zoncst
end type

type p_4 from w_a_print`p_4 within b0w_prt_particular_zoncst
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_particular_zoncst
end type

type p_port from w_a_print`p_port within b0w_prt_particular_zoncst
end type

type p_land from w_a_print`p_land within b0w_prt_particular_zoncst
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_particular_zoncst
integer width = 2190
integer height = 324
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_particular_zoncst
end type

