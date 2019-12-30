$PBExportHeader$e01w_prt_delay03_1.srw
$PBExportComments$[juede] 연체자 리스트 => 관리대리점 추가
forward
global type e01w_prt_delay03_1 from w_a_print
end type
end forward

global type e01w_prt_delay03_1 from w_a_print
end type
global e01w_prt_delay03_1 e01w_prt_delay03_1

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_temp, ls_module, ls_ref_no, ls_ref_desc
Integer	li_from, li_to
String ls_last_reqdtfr, ls_last_reqdtto, ls_dlyamt, ls_chargeby
String ls_partner, ls_prefixno

li_from = dw_cond.object.from_month[1]
li_to = dw_cond.object.to_month[1]
ls_last_reqdtfr = String(dw_cond.Object.last_reqdtfr[1], "yyyymm")
ls_last_reqdtto = String(dw_cond.Object.last_reqdtto[1], "yyyymm")
ls_dlyamt 		 = String(dw_cond.Object.dlyamt[1])
ls_chargeby 	 = Trim(dw_cond.Object.chargeby[1])
ls_partner 		 = String(dw_cond.Object.partner[1])

If IsNull(ls_dlyamt) Then ls_dlyamt = ""
If IsNull(ls_chargeby) Then ls_chargeby = ""
If IsNull(ls_partner) Then ls_partner = ""

If isnull( li_from ) Then
	li_from	=	0
End If

If ls_partner <> "" Then 

	SELECT PREFIXNO
	INTO :ls_prefixno
	FROM partnermst
	WHERE partner = :ls_partner;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("관대리점 Prefixno", "Select Partnermst Table")
		Return
	End If	
	
End If

//If isnull( li_to ) Then
//	MessageBox( "알림", "연체개월수를 입력해 주십시오 " )
//	dw_cond.Setcolumn("to_month")
//	dw_cond.Setfocus()
//	return
//end If

//If ( li_from > li_to ) then
//	MessageBox("알림", "연체개월수 입력이 잘못되었습니다 ")
//	dw_cond.Setcolumn("to_month")
//	dw_cond.Setfocus()
//	return
//end if

//마지막 연체추출일 
ls_module = "E2"
ls_ref_no = "A101"
ls_ref_desc = ""
ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

ls_temp = "기준일 : " + string(ls_temp, "@@@@-@@-@@")
ls_temp = "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

//2005.12.06 juede add==================================
ls_where += "  ( DLYMST.PAYID = bil.customerid ) AND "
ls_where += " ( bil.customerid = cus.customerid ) "
//======================================================

If ls_chargeby <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " bil.pay_method = '" + ls_chargeby + "' "
End If
If ls_dlyamt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.amount >= " + ls_dlyamt + " "
End If
If ls_last_reqdtfr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt,'yyyymm') >= '" + ls_last_reqdtfr + "' "
End If
If ls_last_reqdtto <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt, 'yyyymm') <= '" + ls_last_reqdtto + "' "
End If
If Not IsNull(li_from) Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.DELAY_MONTHS >= " + string(li_from)
End If
If Not IsNull(li_to) Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.DELAY_MONTHS <= " + string(li_to) 
End If

If ls_prefixno<>"" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "'"+ ls_prefixno + "'  like cus.partner_prefix "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If


end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on e01w_prt_delay03_1.create
call super::create
end on

on e01w_prt_delay03_1.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False
end event

type dw_cond from w_a_print`dw_cond within e01w_prt_delay03_1
integer x = 50
integer y = 36
integer width = 1769
integer height = 296
string dataobject = "e01d_cnd_prt_delay03_1"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within e01w_prt_delay03_1
integer x = 1911
integer y = 48
end type

type p_close from w_a_print`p_close within e01w_prt_delay03_1
integer x = 2222
integer y = 48
end type

type dw_list from w_a_print`dw_list within e01w_prt_delay03_1
integer x = 23
integer y = 400
integer height = 1268
string dataobject = "e01d_prt_delay03_1"
end type

type p_1 from w_a_print`p_1 within e01w_prt_delay03_1
end type

type p_2 from w_a_print`p_2 within e01w_prt_delay03_1
end type

type p_3 from w_a_print`p_3 within e01w_prt_delay03_1
end type

type p_5 from w_a_print`p_5 within e01w_prt_delay03_1
end type

type p_6 from w_a_print`p_6 within e01w_prt_delay03_1
end type

type p_7 from w_a_print`p_7 within e01w_prt_delay03_1
end type

type p_8 from w_a_print`p_8 within e01w_prt_delay03_1
end type

type p_9 from w_a_print`p_9 within e01w_prt_delay03_1
end type

type p_4 from w_a_print`p_4 within e01w_prt_delay03_1
end type

type gb_1 from w_a_print`gb_1 within e01w_prt_delay03_1
end type

type p_port from w_a_print`p_port within e01w_prt_delay03_1
end type

type p_land from w_a_print`p_land within e01w_prt_delay03_1
end type

type gb_cond from w_a_print`gb_cond within e01w_prt_delay03_1
integer width = 1815
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within e01w_prt_delay03_1
end type

