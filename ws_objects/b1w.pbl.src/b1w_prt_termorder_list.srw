$PBExportHeader$b1w_prt_termorder_list.srw
$PBExportComments$[ceusee] 해지서비스 리스트
forward
global type b1w_prt_termorder_list from w_a_print
end type
end forward

global type b1w_prt_termorder_list from w_a_print
integer width = 3223
end type
global b1w_prt_termorder_list b1w_prt_termorder_list

type variables
String is_reqterm
String is_term
end variables

on b1w_prt_termorder_list.create
call super::create
end on

on b1w_prt_termorder_list.destroy
call super::destroy
end on

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok;call super::ue_ok;//조회
String ls_list, ls_where, ls_svccod, ls_termtype
String ls_orderfromdt, ls_ordertodt, ls_reqfromdt, ls_reqtodt
Date ld_orderfromdt, ld_ordertodt, ld_reqfromdt, ld_reqtodt
Long ll_row
Integer li_check


ld_orderfromdt = dw_cond.object.orderfromdt[1]
ld_ordertodt = dw_cond.object.ordertodt[1]
ld_reqfromdt = dw_cond.object.reqfromdt[1]
ld_reqtodt = dw_cond.object.reqtodt[1]
ls_orderfromdt = String(ld_orderfromdt, 'yyyymmdd')
ls_ordertodt = String(ld_ordertodt,'yyyymmdd')
ls_reqfromdt = String(ld_reqfromdt, 'yyyymmdd')
ls_reqtodt = String(ld_reqtodt,'yyyymmdd')
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_termtype = Trim(dw_cond.object.termtype[1])

If IsNull(ls_orderfromdt) Then ls_orderfromdt = ""
If IsNull(ls_ordertodt) Then ls_ordertodt = ""
If IsNull(ls_reqfromdt) Then ls_reqfromdt = ""
If IsNull(ls_reqtodt) Then ls_reqtodt = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_termtype) Then ls_termtype = ""


ls_list = Trim(dw_cond.object.list[1])
//해지 미처리 내역
If ls_list = "1"  Then 
	is_title = "해지 미처리 리스트"
	//해지 신청일
	If ls_reqfromdt <> ""  and ls_reqtodt <> "" Then
	li_check = fi_chk_frto_day(ld_reqfromdt,  ld_reqtodt)
		If li_check <> -3 and li_check < 0 Then
			f_msg_usr_err(211, Title, "요청일")
			dw_cond.SetFocus()
			dw_cond.SetColumn("reqfromdt")
			Return
		Else
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(svc.requestdt, 'yyyymmdd') >= '" + ls_reqfromdt + "' And " + &
							"to_char(svc.requestdt,'yyyymmdd') < = '" + ls_reqtodt + "' "
		End If
	  
	ElseIf ls_reqfromdt <> "" And ls_ordertodt = "" Then
		If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(svc.requestdt,'yyyymmdd') >= '" + ls_reqfromdt + "' " 
				
	ElseIf ls_reqfromdt = "" And ls_reqtodt <> "" Then
		If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(svc.requestdt,'yyyymmdd') <= '" + ls_reqtodt + "' "
			
	End If
	
	If ls_svccod <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "svc.svccod = '" + ls_svccod + "' "
	End If
	
	If ls_termtype <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "svc.termtype = '" + ls_termtype + "' "
	End If
	 
	 If ls_where <> "" Then ls_where += " And "
	 ls_where += "svc.status = '" + is_reqterm + "' "
	
	//Setting
	dw_list.DataObject = "b1dw_prt_termorder_list_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()

//해지완료내역
ElseIf ls_list = "2" Then
	is_title = "해지 완료 내역 리스트"
	If ls_orderfromdt <> ""  and ls_ordertodt <> "" Then
	li_check = fi_chk_frto_day(ld_orderfromdt, ld_ordertodt)
		If li_check <> -3 and li_check < 0 Then
			f_msg_usr_err(211, Title, "해지일")
			dw_cond.SetFocus()
			dw_cond.SetColumn("orderfromdt")
			Return
		Else
			If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(cmt.termdt, 'yyyymmdd') >= '" + ls_orderfromdt + "' And " + &
							"to_char(cmt.termdt,'yyyymmdd') < = '" + ls_ordertodt + "' "
		End If
	
	ElseIf ls_orderfromdt <> "" And ls_ordertodt = "" Then
		If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(cmt.termdt,'yyyymmdd') >= '" + ls_orderfromdt + "' " 
							
	ElseIf ls_orderfromdt = "" And ls_ordertodt <> "" Then
		If ls_where <> "" Then ls_where += " And "
			ls_where += "to_char(cmt.termdt,'yyyymmdd') <= '" + ls_ordertodt + "' "
	End If
	
	If ls_svccod <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "cmt.svccod = '" + ls_svccod + "' "
	End If
	
	If ls_termtype <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "cmt.termtype = '" + ls_termtype + "' "
	End If
	
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.status = '" + is_term + "' "
	
	
	//setting
	dw_list.DataObject = "b1dw_prt_termorder_list_2"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
End If

If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

event open;call super::open;String ls_ref_desc, ls_status, ls_name[]
Integer li_exist, i

ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		

is_reqterm = ls_name[1]
is_term = ls_name[2]

end event

type dw_cond from w_a_print`dw_cond within b1w_prt_termorder_list
integer y = 40
integer width = 2313
integer height = 388
string dataobject = "b1dw_cnd_prt_termorder_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_termorder_list
integer x = 2546
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_termorder_list
integer x = 2848
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_termorder_list
integer y = 452
integer width = 3104
integer height = 1132
string dataobject = "b1dw_prt_termorder_list_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_termorder_list
integer y = 1652
end type

type p_2 from w_a_print`p_2 within b1w_prt_termorder_list
integer y = 1652
end type

type p_3 from w_a_print`p_3 within b1w_prt_termorder_list
integer y = 1652
end type

type p_5 from w_a_print`p_5 within b1w_prt_termorder_list
integer y = 1652
end type

type p_6 from w_a_print`p_6 within b1w_prt_termorder_list
integer y = 1652
end type

type p_7 from w_a_print`p_7 within b1w_prt_termorder_list
integer y = 1652
end type

type p_8 from w_a_print`p_8 within b1w_prt_termorder_list
integer y = 1652
end type

type p_9 from w_a_print`p_9 within b1w_prt_termorder_list
integer y = 1652
end type

type p_4 from w_a_print`p_4 within b1w_prt_termorder_list
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_termorder_list
integer y = 1612
end type

type p_port from w_a_print`p_port within b1w_prt_termorder_list
integer y = 1676
end type

type p_land from w_a_print`p_land within b1w_prt_termorder_list
integer y = 1688
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_termorder_list
integer width = 2395
integer height = 440
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_termorder_list
integer y = 1652
end type

