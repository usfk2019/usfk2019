$PBExportHeader$b0w_prt_connection_sumcdr_v20.srw
$PBExportComments$[ssong] 접속료정산내역보고서
forward
global type b0w_prt_connection_sumcdr_v20 from w_a_print
end type
end forward

global type b0w_prt_connection_sumcdr_v20 from w_a_print
integer width = 3374
end type
global b0w_prt_connection_sumcdr_v20 b0w_prt_connection_sumcdr_v20

event ue_ok;call super::ue_ok;String ls_where, ls_sacnum_kind, ls_priceplan, ls_type
String ls_yyyymmdd_fr, ls_yyyymmdd_to
DAte   ld_yyyymmdd_fr, ld_yyyymmdd_to
Long ll_row
Integer li_check

dw_cond.AcceptText()
ld_yyyymmdd_fr = dw_cond.object.yyyymmdd_fr[1]
ld_yyyymmdd_to = dw_cond.object.yyyymmdd_to[1]
ls_yyyymmdd_fr = Trim(String(ld_yyyymmdd_fr, 'yyyymmdd'))
ls_yyyymmdd_to = Trim(String(ld_yyyymmdd_to, 'yyyymmdd'))
ls_sacnum_kind = Trim(dw_cond.object.sacnum_kind[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_type = Trim(dw_cond.Object.type[1])

If IsNull(ls_yyyymmdd_fr) Then ls_yyyymmdd_fr = ""
If IsNull(ls_yyyymmdd_to) Then ls_yyyymmdd_to = ""
If IsNull(ls_sacnum_kind) Then ls_sacnum_kind = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_type) Then ls_type = ""

If ls_yyyymmdd_fr = "" Then
	f_msg_info(200, Title, "기간 from")
	dw_cond.SetFocus()
	dw_cond.setColumn("yyyymmdd_fr")
	Return
End If

If ls_yyyymmdd_to = "" Then
	f_msg_info(200, Title, "기간 to")
	dw_cond.SetFocus()
	dw_cond.setColumn("yyyymmdd_to")
	Return
End If

// 개통일 Check
If ls_yyyymmdd_fr <> "" AND ls_yyyymmdd_to <> "" Then
	li_check = fi_chk_frto_day(ld_yyyymmdd_fr, ld_yyyymmdd_to)
	If li_check <> -3 AND li_check < 0 Then
		f_msg_usr_err(211, Title, '일자')
		dw_cond.setcolumn("yyyymmdd_fr")
		Return 
	End If
End If

//SQL
ls_where = ""

IF ls_sacnum_kind <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " sacnum_kind = '" + ls_sacnum_kind + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " priceplan = '" + ls_priceplan + "' "
ENd IF

IF ls_yyyymmdd_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " yyyymmdd >= '" + ls_yyyymmdd_fr + "' "
End If

If ls_yyyymmdd_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " yyyymmdd <= '" + ls_yyyymmdd_to + "' "
End If

//If ls_status <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " v.status = '" + ls_status + "' "
//End If

If ls_type = "1"  Then 
	dw_list.DataObject = "b0dw_prt_det_connection_sumcdr_1_v20"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
ElseIf ls_type = "2" Then
	dw_list.DataObject = "b0dw_prt_det_connection_sumcdr_3_v20"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
Else
	dw_list.DataObject = "b0dw_prt_det_connection_sumcdr_2_v20"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
End If

dw_list.SetRedraw(false)

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

dw_list.setredraw(true)
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on b0w_prt_connection_sumcdr_v20.create
call super::create
end on

on b0w_prt_connection_sumcdr_v20.destroy
call super::destroy
end on

event ue_init;call super::ue_init;ii_orientation = 2 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b0w_prt_connection_sumcdr_v20
	Desc.	: 접속료 정산내역보고서
	Ver.	: 1.0
	Date	: 2005.07.22
	Programer : Song Eun Mi
-------------------------------------------------------------------------*/
end event

type dw_cond from w_a_print`dw_cond within b0w_prt_connection_sumcdr_v20
integer x = 82
integer y = 40
integer width = 2368
integer height = 240
string dataobject = "b0dw_prt_cnd_connection_sumcdr_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;//This.idwo_help_col[1] = This.Object.customerid
//This.is_help_win[1] = "b1w_hlp_customerm"
//This.is_data[1] = "CloseWithReturn"
//
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
//Choose Case dwo.name
//	Case "customerid"
//		If This.iu_cust_help.ib_data[1] Then
//			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
// 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
//		End If
//		
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;////Item Change Event
//String ls_customernm
//
//Choose Case dwo.name
//	Case "customerid"
//		
//		 If data = "" then 
//				This.Object.customernm[row] = ""			
//				This.SetFocus()
//				This.SetColumn("customerid")
//				Return -1
// 		 End If		 
//		 
//		 SELECT customernm
//		 INTO :ls_customernm
//		 FROM customerm
//		 WHERE customerid = :data ;
//		 If SQLCA.SQLCode < 0 Then
//			 f_msg_sql_err(parent.Title,"select 고객명")
//			 Return 1
//		 End If		 
//		 
//		 If ls_customernm = "" or isnull(ls_customernm ) then
////				This.Object.customerid[row] = ""
//				This.Object.customernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("customerid")
//				Return -1
//		 End if
//		 
//		 This.Object.customernm[row] = ls_customernm
//		
//End Choose
//
//Return 0 
end event

type p_ok from w_a_print`p_ok within b0w_prt_connection_sumcdr_v20
integer x = 2601
integer y = 60
end type

type p_close from w_a_print`p_close within b0w_prt_connection_sumcdr_v20
integer x = 2926
integer y = 60
end type

type dw_list from w_a_print`dw_list within b0w_prt_connection_sumcdr_v20
integer y = 320
integer height = 1260
string dataobject = "b0dw_prt_det_connection_sumcdr_1_v20"
end type

type p_1 from w_a_print`p_1 within b0w_prt_connection_sumcdr_v20
end type

type p_2 from w_a_print`p_2 within b0w_prt_connection_sumcdr_v20
end type

type p_3 from w_a_print`p_3 within b0w_prt_connection_sumcdr_v20
end type

type p_5 from w_a_print`p_5 within b0w_prt_connection_sumcdr_v20
end type

type p_6 from w_a_print`p_6 within b0w_prt_connection_sumcdr_v20
end type

type p_7 from w_a_print`p_7 within b0w_prt_connection_sumcdr_v20
end type

type p_8 from w_a_print`p_8 within b0w_prt_connection_sumcdr_v20
end type

type p_9 from w_a_print`p_9 within b0w_prt_connection_sumcdr_v20
end type

type p_4 from w_a_print`p_4 within b0w_prt_connection_sumcdr_v20
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_connection_sumcdr_v20
end type

type p_port from w_a_print`p_port within b0w_prt_connection_sumcdr_v20
end type

type p_land from w_a_print`p_land within b0w_prt_connection_sumcdr_v20
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_connection_sumcdr_v20
integer width = 2432
integer height = 300
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_connection_sumcdr_v20
end type

