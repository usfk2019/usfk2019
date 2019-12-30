$PBExportHeader$b1w_prt_trouble_note.srw
$PBExportComments$[ceusee] 장애처리보고서
forward
global type b1w_prt_trouble_note from w_a_print
end type
end forward

global type b1w_prt_trouble_note from w_a_print
integer width = 3465
integer height = 2060
end type
global b1w_prt_trouble_note b1w_prt_trouble_note

type variables
DataWindowChild idcA, idcB , idwc_troubletype
end variables

on b1w_prt_trouble_note.create
call super::create
end on

on b1w_prt_trouble_note.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;String ls_troubletypea, ls_troubletypeb, ls_troubletypec, ls_troubletype
String ls_customerid, ls_trouble_status, ls_receiptdt_fr, ls_receiptdt_to
String ls_receipt_user, ls_modelno, ls_option, ls_worktype
String ls_where
Long ll_row

ls_receiptdt_fr = String(dw_cond.object.receptdt_fr[1], 'yyyymmdd')
ls_receiptdt_to = String(dw_cond.object.receptdt_to[1], 'yyyymmdd')
ls_troubletypec = Trim(dw_cond.object.troubletypec[1])
ls_troubletypeb = Trim(dw_cond.object.troubletypeb[1])
ls_troubletypea = Trim(dw_cond.object.troubletypea[1])
ls_troubletype = Trim(dw_cond.object.trouble_type[1])
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_option = Trim(dw_cond.object.option[1])
ls_receipt_user = trim(dw_cond.object.receipt_user[1])
ls_trouble_status = Trim(dw_cond.object.trouble_status[1])
ls_modelno = Trim(dw_cond.object.modelno[1])
ls_worktype = Trim(dw_cond.object.worktype[1])

If IsNull(ls_receiptdt_fr) Then ls_receiptdt_fr = ""
If IsNull(ls_receiptdt_to) Then ls_receiptdt_to = ""
If IsNull(ls_troubletypec) Then ls_troubletypec = ""
If IsNull(ls_troubletypeb) Then ls_troubletypeb = ""
If IsNull(ls_troubletypea) Then ls_troubletypea = ""
If IsNull(ls_troubletype) Then ls_troubletype = ""
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_option) Then ls_option = ""
If IsNull(ls_modelno) Then ls_modelno = ""
If IsNull(ls_receipt_user) Then ls_receipt_user = ""
If IsNull(ls_trouble_status) Then ls_trouble_status = ""
If IsNull(ls_worktype) Then ls_worktype = ""

If ls_worktype = "S" Then
	dw_list.DataObject = "b1dw_prt_trouble_note"
	dw_list.SetTransObject(SQLCA)
ElseIf ls_worktype = "D" Then
	dw_list.DataObject = "b1dw_prt_trouble_note_1"
	dw_list.SetTransObject(SQLCA)
End If

ls_where = ""
If ls_receiptdt_fr <> "" And ls_receiptdt_to <> "" Then
	 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("receiptdt_fr")
	 Return 
End If

If ls_receiptdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(c.receiptdt, 'yyyymmdd') >= '" + ls_receiptdt_fr + "' "
End If

If ls_receiptdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(c.receiptdt, 'yyyymmdd') <= '" + ls_receiptdt_to + "' "
End If

If ls_troubletypec <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tc.troubletypec = '" + ls_troubletypec + "' "
End If

If ls_troubletypeb <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tb.troubletypeb = '" + ls_troubletypeb + "' "
End If

If ls_troubletypea <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "ta.troubletypea = '" + ls_troubletypea + "' "
End If

If ls_troubletype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tm.troubletype = '" + ls_troubletype + "' "
End If

If ls_option = "S" Then  //미처리
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tr.responsedt is null "
ElseIf ls_option = "C"  Then  //처리중
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tr.responsedt is not null AND c.closeyn = 'N' "
ElseIf ls_option = "E"  Then  //완료
	If ls_where <> "" Then ls_where += " And "
   ls_where += "c.closeyn = 'Y' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "c.customerid = '" + ls_customerid + "' "
End If

If ls_trouble_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "c.trouble_status = '" + ls_trouble_status + "' "
End If

If ls_modelno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "c.model = '" + ls_modelno + "' "
End If

If ls_receipt_user <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "c.receipt_user = '" + ls_receipt_user + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
End If




end event

type dw_cond from w_a_print`dw_cond within b1w_prt_trouble_note
integer width = 2853
integer height = 448
string dataobject = "b1dw_cnd_prt_trouble_note"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_filter
Long ll_row

Choose Case dwo.name
	Case "troubletypec"
		This.object.troubletypeb[1] = ""
		This.object.troubletypea[1] = ""
		This.object.trouble_type[1] = ""
		ls_filter = "troubletypeb_troubletypec = '" + data + "' "
		idcB.SetFilter(ls_filter)			//Filter정함
		idcB.Filter()
		idcB.SetTransObject(SQLCA)
		ll_row =idcB.Retrieve() 
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	Case "troubletypeb"
		This.object.troubletypea[1] = ""
		This.object.trouble_type[1] = ""
		ls_filter = "troubletypea_troubletypeb = '" + data + "' "
			
		idcA.SetFilter(ls_filter)			//Filter정함
		idcA.Filter()
		idcA.SetTransObject(SQLCA)
		ll_row =idcA.Retrieve() 
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	Case "troubletypea"
		This.object.trouble_type[1] = ""
		ls_filter = "troubletypea = '" + data + "' "
		idwc_troubletype.SetFilter(ls_filter)			//Filter정함
		idwc_troubletype.Filter()
		idwc_troubletype.SetTransObject(SQLCA)
		ll_row =idwc_troubletype.Retrieve() 
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
End Choose
end event

event dw_cond::constructor;call super::constructor;Long ll_row

//중분류
ll_row = dw_cond.GetChild("troubletypeb", idcB)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 1")

//소분류
ll_row = dw_cond.GetChild("troubletypea", idcA)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 2")

//민원유형
ll_row = dw_cond.GetChild("trouble_type", idwc_troubletype)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 3")

end event

type p_ok from w_a_print`p_ok within b1w_prt_trouble_note
integer x = 3017
integer y = 56
end type

type p_close from w_a_print`p_close within b1w_prt_trouble_note
integer x = 3017
integer y = 172
end type

type dw_list from w_a_print`dw_list within b1w_prt_trouble_note
integer y = 524
integer width = 3351
integer height = 1184
string dataobject = "b1dw_prt_trouble_note"
end type

type p_1 from w_a_print`p_1 within b1w_prt_trouble_note
integer y = 1756
end type

type p_2 from w_a_print`p_2 within b1w_prt_trouble_note
integer y = 1756
end type

type p_3 from w_a_print`p_3 within b1w_prt_trouble_note
integer y = 1756
end type

type p_5 from w_a_print`p_5 within b1w_prt_trouble_note
integer y = 1756
end type

type p_6 from w_a_print`p_6 within b1w_prt_trouble_note
integer y = 1756
end type

type p_7 from w_a_print`p_7 within b1w_prt_trouble_note
integer y = 1756
end type

type p_8 from w_a_print`p_8 within b1w_prt_trouble_note
integer y = 1756
end type

type p_9 from w_a_print`p_9 within b1w_prt_trouble_note
integer y = 1756
end type

type p_4 from w_a_print`p_4 within b1w_prt_trouble_note
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_trouble_note
integer y = 1716
end type

type p_port from w_a_print`p_port within b1w_prt_trouble_note
integer y = 1780
end type

type p_land from w_a_print`p_land within b1w_prt_trouble_note
integer y = 1792
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_trouble_note
integer width = 2889
integer height = 504
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_trouble_note
integer y = 1756
end type

