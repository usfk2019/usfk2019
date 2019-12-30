$PBExportHeader$b0w_reg_blacklist.srw
$PBExportComments$[kem] 개별 제한번호 등록
forward
global type b0w_reg_blacklist from w_a_reg_m
end type
end forward

global type b0w_reg_blacklist from w_a_reg_m
integer width = 3163
integer height = 1908
event ue_reload ( )
end type
global b0w_reg_blacklist b0w_reg_blacklist

type variables


end variables

on b0w_reg_blacklist.create
call super::create
end on

on b0w_reg_blacklist.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_blacklist_z
	Desc	: 	개별 제한번호 등록
	Ver	:	1.0
	Date	: 	2003.10.01
	Prgogramer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/

dw_cond.object.partcod_t.Text = "그룹"
end event

event type integer ue_extra_insert(long al_insert_row);String ls_parttype

ls_parttype = Trim(dw_cond.object.parttype[1])


If ls_parttype = 'A' Then
	//Insert 시 해당 row 첫번째 컬럼에 포커스
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("areanum")
	
	//Setting
	dw_detail.object.parttype[al_insert_row] = Trim(dw_cond.object.parttype[1])
	dw_detail.object.partcod[al_insert_row] = 'ALL'
	dw_detail.object.opendt[al_insert_row] = fdt_get_dbserver_now()
	
Elseif ls_parttype = 'R' Then
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("partcod")
	
	dw_detail.object.parttype[al_insert_row] = Trim(dw_cond.object.parttype[1])
	dw_detail.object.partcod[al_insert_row] = Trim(dw_cond.object.partcod1[1])
	dw_detail.object.priceplan_desc[al_insert_row] = dw_detail.object.partcod[al_insert_row]
	dw_detail.object.opendt[al_insert_row] = fdt_get_dbserver_now()

Elseif ls_parttype = "S" Then
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("partcod")
	
	dw_detail.object.parttype[al_insert_row] = Trim(dw_cond.object.parttype[1])
	dw_detail.object.partcod[al_insert_row] = Trim(dw_cond.object.partcod1[1])
	dw_detail.object.partnernm[al_insert_row] = dw_detail.object.partcod[al_insert_row]
	dw_detail.object.opendt[al_insert_row] = fdt_get_dbserver_now()

Elseif ls_parttype = "C" Then
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("partcod")
	
	dw_detail.object.parttype[al_insert_row] = Trim(dw_cond.object.parttype[1])
	dw_detail.object.partcod[al_insert_row] = Trim(dw_cond.object.partcod1[1])
	dw_detail.object.customernm[al_insert_row] = dw_detail.object.partcod[al_insert_row]
	dw_detail.object.opendt[al_insert_row] = fdt_get_dbserver_now()
	
Else
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("partcod")
	
	dw_detail.object.parttype[al_insert_row] = Trim(dw_cond.object.parttype[1])
	dw_detail.object.partcod[al_insert_row] = Trim(dw_cond.object.partcod1[1])
	dw_detail.object.opendt[al_insert_row] = fdt_get_dbserver_now()

End If
//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row]   = fdt_get_dbserver_now()

Return 0
end event

event ue_ok();call super::ue_ok;//조회
String ls_parttype, ls_partcod, ls_partcod1, ls_where
Long ll_row

ls_parttype = Trim(dw_cond.object.parttype[1])
ls_partcod1  = Trim(dw_cond.object.partcod1[1])
If IsNull(ls_partcod1) Or ls_partcod1 = "" Then
	dw_cond.object.partcod1[1] = Trim(dw_cond.object.partcod[1])
End If
ls_partcod  = Trim(dw_cond.object.partcod1[1])

If IsNull(ls_parttype) Then ls_parttype = ""
If IsNull(ls_partcod) Then ls_partcod = ""


//필수 항목 Check
If ls_parttype = "" Then
	f_msg_info(200, Title, "그룹선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("parttype")
	Return
End If

ls_where = ""
If ls_partcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.PARTCOD = '" + ls_partcod + "' "
End If

dw_detail.SetRedraw(False)

//데이터 윈도우 바꾸기 
If ls_parttype = "A"  Then 
	dw_detail.DataObject = "b0dw_reg_blacklist_a"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
ElseIf ls_parttype = "R" Then
	dw_detail.DataObject = "b0dw_reg_blacklist_r"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
ElseIf ls_parttype = "C" Then
	dw_detail.DataObject = "b0dw_reg_blacklist_c"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
ElseIf ls_parttype = "S" Then
	dw_detail.DataObject = "b0dw_reg_blacklist_s"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
ElseIf ls_parttype = "P" Then
	dw_detail.DataObject = "b0dw_reg_blacklist_p"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
End If

//Retrieve
ll_row = dw_detail.Retrieve()

dw_detail.SetRedraw(True)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


	
end event

event type integer ue_extra_save();//Save Check
String ls_parttype, ls_partcod, ls_areanum, ls_opendt, ls_enddt
String ls_parttype1, ls_partcod1, ls_areanum1, ls_opendt1, ls_enddt1
String ls_parttype2, ls_partcod2, ls_areanum2, ls_opendt2, ls_enddt2
Long i, ll_row, ll_rows, ll_rows1

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0

ls_parttype = Trim(dw_cond.object.parttype[1])

If  ls_parttype = 'A' Or ls_parttype = 'R' Then
	For i = 1 To ll_row
		ls_areanum = Trim(dw_detail.object.areanum[i])
		If IsNull(ls_areanum) Then ls_areanum = ""
		If ls_areanum = "" Then
			f_msg_usr_err(200, Title, "제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("areanum")
			Return -1
		End If
	
		ls_opendt = String(dw_detail.object.opendt[i], 'YYYYMMDD')
		If IsNull(ls_opendt) Then ls_opendt = ""
		If ls_opendt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("opendt")
			Return -1
		End If
		
		
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next
ElseIf ls_parttype = 'S' Then
	For i = 1 To ll_row
		ls_partcod = Trim(dw_detail.object.partcod[i])
		If IsNull(ls_partcod) Then ls_partcod = ""
		If ls_partcod = "" Then
			f_msg_usr_err(200, Title, "대리점")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("partcod")
			Return -1
		End If
		
		ls_areanum = Trim(dw_detail.object.areanum[i])
		If IsNull(ls_areanum) Then ls_areanum = ""
		If ls_areanum = "" Then
			f_msg_usr_err(200, Title, "제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("areanum")
			Return -1
		End If
	
		ls_opendt = String(dw_detail.object.opendt[i], 'YYYYMMDD')
		If IsNull(ls_opendt) Then ls_opendt = ""
		If ls_opendt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("opendt")
			Return -1
		End If
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next
	
ElseIf ls_parttype = 'C' Then
	For i = 1 To ll_row
		ls_partcod = Trim(dw_detail.object.partcod[i])
		If IsNull(ls_partcod) Then ls_partcod = ""
		If ls_partcod = "" Then
			f_msg_usr_err(200, Title, "고객번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("partcod")
			Return -1
		End If
		
		ls_areanum = Trim(dw_detail.object.areanum[i])
		If IsNull(ls_areanum) Then ls_areanum = ""
		If ls_areanum = "" Then
			f_msg_usr_err(200, Title, "제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("areanum")
			Return -1
		End If
	
		ls_opendt = String(dw_detail.object.opendt[i], 'YYYYMMDD')
		If IsNull(ls_opendt) Then ls_opendt = ""
		If ls_opendt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("opendt")
			Return -1
		End If
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next
ElseIf ls_parttype = 'P' Then
	For i = 1 To ll_row
		ls_partcod = Trim(dw_detail.object.partcod[i])
		If IsNull(ls_partcod) Then ls_partcod = ""
		If ls_partcod = "" Then
			f_msg_usr_err(200, Title, "Pin")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("partcod")
			Return -1
		End If
		
		ls_areanum = Trim(dw_detail.object.areanum[i])
		If IsNull(ls_areanum) Then ls_areanum = ""
		If ls_areanum = "" Then
			f_msg_usr_err(200, Title, "제한번호")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("areanum")
			Return -1
		End If
	
		ls_opendt = String(dw_detail.object.opendt[i], 'YYYYMMDD')
		If IsNull(ls_opendt) Then ls_opendt = ""
		If ls_opendt = "" Then
			f_msg_usr_err(200, Title, "적용개시일")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("opendt")
			Return -1
		End If
	
		//Update Log
		If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i]   = fdt_get_dbserver_now()
	   End If
	Next
End If

//적용종료일 체크
For i = 1 To ll_row
	ls_opendt = Trim(String(dw_detail.object.opendt[i], 'yyyymmdd'))
	ls_enddt  = Trim(String(dw_detail.object.enddt[i], 'yyyymmdd'))
	
	If IsNull(ls_enddt) Or ls_enddt = "" Then ls_enddt = "99991231"
	
	If ls_opendt > ls_enddt Then
		f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
		dw_detail.setColumn("enddt")
		dw_detail.setRow(i)
		dw_detail.scrollToRow(i)
		dw_detail.setFocus()
		Return -2
	End If
Next

//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
For ll_rows = 1 To dw_detail.RowCount()
	ls_parttype1 = Trim(dw_detail.object.parttype[ll_rows])
	ls_partcod1  = Trim(dw_detail.object.partcod[ll_rows])
	ls_areanum1  = Trim(dw_detail.object.areanum[ll_rows])
	ls_opendt1   = String(dw_detail.object.opendt[ll_rows], 'yyyymmdd')
	ls_enddt1    = String(dw_detail.object.enddt[ll_rows], 'yyyymmdd')
	
	If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
	
	For ll_rows1 = dw_detail.RowCount() To ll_rows - 1 Step -1
		If ll_rows = ll_rows1 Then
			Exit
		End If
		ls_parttype2 = Trim(dw_detail.object.parttype[ll_rows1])
		ls_partcod2  = Trim(dw_detail.object.partcod[ll_rows1])
		ls_areanum2  = Trim(dw_detail.object.areanum[ll_rows1])
		ls_opendt2   = String(dw_detail.object.opendt[ll_rows1], 'yyyymmdd')
		ls_enddt2    = String(dw_detail.object.enddt[ll_rows1], 'yyyymmdd')
		
		If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
		
		If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_areanum1 = ls_areanum2) Then
			If ls_enddt1 >= ls_opendt2 Then
				f_msg_info(9000, Title, "같은 그룹[ " + ls_partcod1 + " ]에 같은 제한번호[ " + ls_areanum1 + " ]로 적용개시일이 중복됩니다.")
				Return -1
			End If
		End If
		
	Next
	
Next

Return 0
	
	
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.parttype[1] = ""
dw_cond.Object.partcod[1] = ""
dw_cond.Object.partcod1[1] = ""
dw_cond.Object.partcod_t.Text = "그룹"

dw_cond.SetColumn("parttype")

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_blacklist
integer y = 52
integer width = 2053
integer height = 168
string dataobject = "b0dw_cnd_reg_blacklist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
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
			This.Object.partcod_t.Text    = "가격정책"
			This.Object.partcod[1]        = ""
			This.Object.partcod1[1]       = ""
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_priceplan"
			is_data[1] = "CloseWithReturn"
			
		Case "S"
			This.Object.partcod.Visible    = 1
			This.Object.partcod_t.Text     = "대리점"
			This.Object.partcod[1]        = ""
			This.Object.partcod1[1]       = ""
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_partner"
			is_data[1] = "CloseWithReturn"
			
		Case "C"
			This.Object.partcod.Visible    = 1
			This.Object.partcod_t.Text     = "고객번호"
			This.Object.partcod[1]        = ""
			This.Object.partcod1[1]       = ""
			
			This.Object.partcod.Pointer    = "Help!"
			idwo_help_col[1] = Object.partcod
			is_help_win[1] = "b1w_hlp_customerm"
			is_data[1] = "CloseWithReturn"
			
		Case "P"
			This.Object.partcod.Visible    = 1
			This.Object.partcod_t.Text     = "Pin"
			This.Object.partcod[1]        = ""
			This.Object.partcod1[1]       = ""
			
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

type p_ok from w_a_reg_m`p_ok within b0w_reg_blacklist
integer x = 2245
integer y = 72
end type

type p_close from w_a_reg_m`p_close within b0w_reg_blacklist
integer x = 2560
integer y = 72
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_blacklist
integer width = 2098
integer height = 240
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_blacklist
integer y = 1652
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_blacklist
integer y = 1652
end type

type p_save from w_a_reg_m`p_save within b0w_reg_blacklist
integer y = 1652
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_blacklist
integer y = 268
integer width = 3067
integer height = 1304
string dataobject = "b0dw_reg_blacklist_a"
boolean hscrollbar = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::retrieveend;call super::retrieveend;String ls_parttype

If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If


ls_parttype = Trim(dw_cond.object.parttype[1])
	
Choose Case ls_parttype
	Case "A"
		This.Object.partcod.Protect    = 1
		This.Object.partcod.Pointer    = "Arrow!"
		idwo_help_col[1] = Object.parttype
//		is_help_win[1] = "b1w_hlp_priceplan"
//		is_data[1] = "CloseWithReturn"

	Case "R"
		This.Object.partcod.Pointer    = "Help!"
		idwo_help_col[1] = Object.partcod
		is_help_win[1] = "b1w_hlp_priceplan"
		is_data[1] = "CloseWithReturn"
			
	Case "S"
		This.Object.partcod.Pointer    = "Help!"
		idwo_help_col[1] = Object.partcod
		is_help_win[1] = "b1w_hlp_partner"
		is_data[1] = "CloseWithReturn"
			
	Case "C"
		This.Object.partcod.Pointer    = "Help!"
		idwo_help_col[1] = Object.partcod
		is_help_win[1] = "b1w_hlp_customerm"
		is_data[1] = "CloseWithReturn"
		
	Case "P"
		This.Object.partcod.Pointer    = "Help!"
		idwo_help_col[1] = Object.partcod
		is_help_win[1] = "b1w_hlp_cardmst"
		is_data[1] = "CloseWithReturn"
		
End Choose
	
	
Return 0

end event

event dw_detail::ue_init();call super::ue_init;idwo_help_col[1] = dw_detail.Object.partcod
is_help_win[1] = "b1w_hlp_priceplan"
is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;String ls_parttype

This.AcceptText()

Choose Case dwo.Name
	Case "partcod"
		ls_parttype = Trim(This.object.parttype[row])
		
		If ls_parttype = "R" Then
			If This.iu_cust_help.ib_data[1] Then
				This.Object.partcod[row] = This.iu_cust_help.is_data[1]
				This.Object.priceplan_desc[row] = This.Object.partcod[row]
			End If
			
		ElseIf ls_parttype = "C" Then
			If This.iu_cust_help.ib_data[1] Then
				This.Object.partcod[row] = This.iu_cust_help.is_data[1]
				This.Object.customernm[row] = This.Object.partcod[row]
			End If
			
		ElseIf ls_parttype = "S" Then
			If This.iu_cust_help.ib_data[1] Then
				This.Object.partcod[row] = This.iu_cust_help.is_data[1]
				This.Object.partnernm[row] = This.Object.partcod[row]
			End If
			
		ElseIf ls_parttype = "P" Then
			If This.iu_cust_help.ib_data[1] Then
				This.Object.partcod[row] = This.iu_cust_help.is_data[1]
			End If
		End If
	
End Choose
	
end event

event dw_detail::itemchanged;call super::itemchanged;//String ls_opendt
//
//If dwo.name = "enddt" Then
//
//	//적용종료일 체크
//	ls_opendt	= Trim(String(dw_detail.Object.opendt[row],'yyyymmdd'))
//		
//	If data <> "" Then
//		If ls_opendt > data Then
//			f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//			dw_detail.setColumn("enddt")
//			dw_detail.setRow(row)
//			dw_detail.scrollToRow(row)
//			dw_detail.setFocus()
//			Return -1
//		End If
//	End If
//End If
//
//Return 0
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_blacklist
integer y = 1652
end type

