$PBExportHeader$b1w_prt_validkey_detail_list.srw
$PBExportComments$[jsha] 인증Key List
forward
global type b1w_prt_validkey_detail_list from w_a_print
end type
end forward

global type b1w_prt_validkey_detail_list from w_a_print
integer width = 3374
end type
global b1w_prt_validkey_detail_list b1w_prt_validkey_detail_list

event ue_ok();call super::ue_ok;String ls_where, ls_validkey, ls_customerid, ls_fromdt, ls_todt, ls_status
Date ld_fromdt, ld_todt
Long ll_row
Integer li_check

ld_fromdt = dw_cond.object.fromdt[1]
ld_todt = dw_cond.object.todt[1]

ls_fromdt = Trim(String(ld_fromdt,'yyyymmdd'))
ls_todt = Trim(String(ld_todt,'yyyymmdd'))
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_status = Trim(dw_cond.Object.status[1])

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_status) Then ls_status = ""

// 개통일 Check
If ls_fromdt <> "" AND ls_todt <> "" Then
	li_check = fi_chk_frto_day(ld_fromdt, ld_todt)
	If li_check <> -3 AND li_check < 0 Then
		f_msg_usr_err(211, Title, '개통일')
		dw_cond.setcolumn("fromdt")
		Return 
	End If
End If

//SQL
ls_where = ""

IF ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " v.validkey = '" + ls_validkey + "' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " v.customerid = '" + ls_customerid + "' "
ENd IF

IF ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(v.fromdt,'yyyymmdd') >= '" + ls_fromdt + "' "
End If

If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(v.fromdt, 'yyyymmdd') <= '" + ls_todt + "' "
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " v.status = '" + ls_status + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on b1w_prt_validkey_detail_list.create
call super::create
end on

on b1w_prt_validkey_detail_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_validkey_detail_list
integer x = 46
integer width = 2368
integer height = 312
string dataobject = "b1dw_cond_prt_validkey_detail_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_customernm
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 고객명")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm
		
End Choose

Return 0 
end event

type p_ok from w_a_print`p_ok within b1w_prt_validkey_detail_list
integer x = 2601
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_validkey_detail_list
integer x = 2926
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_validkey_detail_list
integer y = 420
integer height = 1160
string dataobject = "b1dw_prt_validkey_detail_list"
end type

type p_1 from w_a_print`p_1 within b1w_prt_validkey_detail_list
end type

type p_2 from w_a_print`p_2 within b1w_prt_validkey_detail_list
end type

type p_3 from w_a_print`p_3 within b1w_prt_validkey_detail_list
end type

type p_5 from w_a_print`p_5 within b1w_prt_validkey_detail_list
end type

type p_6 from w_a_print`p_6 within b1w_prt_validkey_detail_list
end type

type p_7 from w_a_print`p_7 within b1w_prt_validkey_detail_list
end type

type p_8 from w_a_print`p_8 within b1w_prt_validkey_detail_list
end type

type p_9 from w_a_print`p_9 within b1w_prt_validkey_detail_list
end type

type p_4 from w_a_print`p_4 within b1w_prt_validkey_detail_list
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_validkey_detail_list
end type

type p_port from w_a_print`p_port within b1w_prt_validkey_detail_list
end type

type p_land from w_a_print`p_land within b1w_prt_validkey_detail_list
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_validkey_detail_list
integer width = 2432
integer height = 388
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_validkey_detail_list
end type

