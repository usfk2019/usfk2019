$PBExportHeader$b0w_prt_blacklist.srw
$PBExportComments$[kem] 제한번호 리스트 Window
forward
global type b0w_prt_blacklist from w_a_print
end type
end forward

global type b0w_prt_blacklist from w_a_print
integer width = 3337
end type
global b0w_prt_blacklist b0w_prt_blacklist

on b0w_prt_blacklist.create
call super::create
end on

on b0w_prt_blacklist.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows, ll_rc
String	ls_where
String	ls_parttype, ls_partcod, ls_partcod1
b0u_dbmgr lu_dbmgr

ls_parttype = Trim(dw_cond.object.parttype[1])
ls_partcod1  = Trim(dw_cond.object.partcod1[1])
If IsNull(ls_partcod1) Or ls_partcod1 = "" Then
	dw_cond.object.partcod1[1] = Trim(dw_cond.object.partcod[1])
End If
ls_partcod  = Trim(dw_cond.object.partcod1[1])

If( IsNull(ls_parttype) ) Then ls_parttype = ""
If( IsNull(ls_partcod) ) Then ls_partcod = ""


//retrieve
ls_where = ""
If ls_parttype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.parttype = '" + ls_parttype + "' "
End If

If ls_partcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.partcod = '" + ls_partcod + "' "
End If

dw_list.SetRedraw(False)

//데이터 윈도우 바꾸기 
If ls_parttype = "" Then
	dw_list.DataObject = "b0dw_prt_blacklist"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "A"  Then 
	dw_list.DataObject = "b0dw_prt_blacklist_a"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "R" Then
	dw_list.DataObject = "b0dw_prt_blacklist_r"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "S" Then
	dw_list.DataObject = "b0dw_prt_blacklist_s"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "C" Then
	dw_list.DataObject = "b0dw_prt_blacklist_c"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_parttype = "P" Then
	dw_list.DataObject = "b0dw_prt_blacklist_p"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
End If

//Retrieve
ll_rows	= dw_list.Retrieve()

If ls_parttype <> "" Then
	
	dw_list.SetRedraw(True)
	
	If( ll_rows = 0 ) Then
		f_msg_info(1000, Title, "")
	ElseIf( ll_rows < 0 ) Then
		f_msg_usr_err(2100, Title, "Retrieve()")
	End If

Else
	lu_dbmgr = CREATE b0u_dbmgr
	
	lu_dbmgr.is_caller = "b0w_prt_blacklist%ok"
	lu_dbmgr.is_title = Title
   lu_dbmgr.idw_data[1] = dw_cond
   lu_dbmgr.idw_data[2] = dw_list

	lu_dbmgr.uf_prc_db_01()
	ll_rc = lu_dbmgr.ii_rc

	If ll_rc < 0 Then
		dw_list.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.	
		Destroy lu_dbmgr
		Return
	End If

	Destroy lu_dbmgr
	
	dw_list.SetRedraw(True)
	
End If
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;//Format 지정
String ls_type, ls_desc

dw_cond.Object.partcod_t.Text = "그룹"
end event

type dw_cond from w_a_print`dw_cond within b0w_prt_blacklist
integer x = 55
integer y = 48
integer width = 2153
integer height = 156
string dataobject = "b0dw_cnd_prt_blacklist"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;
If Lower(dwo.name) = "parttype" Then
	Choose Case data
		Case "A"
			This.Object.partcod.Visible   = 0
			This.Object.partcod[1]        = "ALL"
			This.Object.partcod1[1]       = "ALL"
			This.Object.partcod_t.Text    = "ALL"
			
		Case "R"
			This.Object.partcod.Visible   = 1
			This.Object.partcod[1]        = ""
			This.Object.partcod_t.Text    = "가격정책"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_priceplan"
			is_data[1] = "CloseWithReturn"
			
		Case "S"
			This.Object.partcod.Visible    = 1
			This.Object.partcod[1]        = ""
			This.Object.partcod_t.Text     = "대리점"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_partner"
			is_data[1] = "CloseWithReturn"
			
		Case "C"
			This.Object.partcod.Visible    = 1
			This.Object.partcod[1]        = ""
			This.Object.partcod_t.Text     = "고객번호"
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_customerm"
			is_data[1] = "CloseWithReturn"
			
		Case "P"
			This.Object.partcod.Visible    = 1
			This.Object.partcod[1]        = ""
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

If ls_parttype = "R" Then
	Choose Case dwo.Name
		Case "partcod"
			If iu_cust_help.ib_data[1] Then
				This.Object.partcod1[row] = iu_cust_help.is_data[1]
				This.Object.partcod[row] = iu_cust_help.is_data[2]
			End If
	End Choose
	
ElseIf ls_parttype = "C" Then
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

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.partcod
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b0w_prt_blacklist
integer x = 2350
end type

type p_close from w_a_print`p_close within b0w_prt_blacklist
integer x = 2651
end type

type dw_list from w_a_print`dw_list within b0w_prt_blacklist
integer y = 248
integer width = 3237
integer height = 1352
string dataobject = "b0dw_prt_blacklist"
end type

type p_1 from w_a_print`p_1 within b0w_prt_blacklist
end type

type p_2 from w_a_print`p_2 within b0w_prt_blacklist
end type

type p_3 from w_a_print`p_3 within b0w_prt_blacklist
end type

type p_5 from w_a_print`p_5 within b0w_prt_blacklist
end type

type p_6 from w_a_print`p_6 within b0w_prt_blacklist
end type

type p_7 from w_a_print`p_7 within b0w_prt_blacklist
end type

type p_8 from w_a_print`p_8 within b0w_prt_blacklist
end type

type p_9 from w_a_print`p_9 within b0w_prt_blacklist
end type

type p_4 from w_a_print`p_4 within b0w_prt_blacklist
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_blacklist
end type

type p_port from w_a_print`p_port within b0w_prt_blacklist
end type

type p_land from w_a_print`p_land within b0w_prt_blacklist
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_blacklist
integer width = 2190
integer height = 228
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_blacklist
end type

