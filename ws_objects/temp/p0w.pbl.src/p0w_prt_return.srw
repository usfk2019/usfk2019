$PBExportHeader$p0w_prt_return.srw
$PBExportComments$[y.k.min] 반품카드보고서
forward
global type p0w_prt_return from w_a_print
end type
end forward

global type p0w_prt_return from w_a_print
integer width = 3122
integer height = 2204
boolean ib_saveas = true
end type
global p0w_prt_return p0w_prt_return

on p0w_prt_return.create
call super::create
end on

on p0w_prt_return.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_type, ls_partner_prefix, ls_priceplan, ls_return_type
String ls_returndt_from, ls_returndt_to
Date ld_returndt_from, ld_returndt_to
Long ll_row

ls_type = Trim(dw_cond.object.type[1])
ld_returndt_from = dw_cond.object.returndt_from[1]
ld_returndt_to = dw_cond.object.returndt_to[1]
ls_returndt_from = String(ld_returndt_from, 'yyyymmdd')
ls_returndt_to = String(ld_returndt_to, 'yyyymmdd')
ls_return_type = Trim(dw_cond.object.return_type[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_partner_prefix = Trim(dw_cond.object.partner_prefix[1])

//Null Check
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_returndt_from) Then ls_returndt_from = ""
If IsNull(ls_returndt_to) Then ls_returndt_to = ""
If IsNull(ls_return_type) Then ls_return_type = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""

//Retrieve
ls_where = ""
If ls_returndt_from <> "" and ls_returndt_to <> "" Then
	ll_row = fi_chk_frto_day(ld_returndt_from, ld_returndt_to)
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "반품일자")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("returndt_from")
	 Return 
	End If
	
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(a.returndt, 'yyyymmdd') >='" + ls_returndt_from + "' " + &
	   			"and to_char(a.returndt, 'yyyymmdd') < = '" + ls_returndt_to + "' "

ElseIf ls_returndt_from <> "" and ls_returndt_to = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(a.returndt,'YYYYMMDD') > = '" + ls_returndt_from + "' "
ElseIf ls_returndt_from = "" and ls_returndt_to <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(a.returndt, 'YYYYMMDD') < = '" + ls_returndt_to + "' " 
End If

////조회조건 입력값을 보여준다.
//dw_list.Modify ( "t_issuedt_fr.text='" + String(ld_issuedt_fr, 'yyyy-mm-dd')+ "'" )
//dw_list.Modify ( "t_issuedt_to.text='" + String(ld_issuedt_to, 'yyyy-mm-dd')+ "'" )


If ls_return_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.return_type = '" + ls_return_type + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "b.priceplan = '" + ls_priceplan + "' "
End If

If ls_partner_prefix <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.partner_prefix = '" + ls_partner_prefix + "' "
End If

//대리점별, 기간별 구분
IF ls_type = '0' THEN
	dw_list.dataObject = "p0dw_prt_return_partner"
	dw_list.SetTransObject(SQLCA)
	
	//조회조건 입력값을 보여준다.
	dw_list.Modify ( "p_type.text='대리점별'" )
	dw_list.Modify ( "p_returndt_from.text='" + String(ld_returndt_from, 'yyyy-mm-dd') + "'" )
	dw_list.Modify ( "p_returndt_to.text='" + String(ld_returndt_to, 'yyyy-mm-dd') + "'" )
ELSEIF ls_type = '1' THEN
	dw_list.dataObject = "p0dw_prt_return_period"
	dw_list.SetTransObject(SQLCA)
	
	//조회조건 입력값을 보여준다.
	dw_list.Modify ( "p_type.text='기간별'" )
	dw_list.Modify ( "p_returndt_from.text='" + String(ld_returndt_from, 'yyyy-mm-dd') + "'" )
	dw_list.Modify ( "p_returndt_to.text='" + String(ld_returndt_to, 'yyyy-mm-dd') + "'" )
END IF

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로인쇄
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p0w_prt_return
integer x = 55
integer y = 36
integer height = 308
string dataobject = "p0dw_cnd_prt_return"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p0w_prt_return
end type

type p_close from w_a_print`p_close within p0w_prt_return
end type

type dw_list from w_a_print`dw_list within p0w_prt_return
integer y = 392
integer height = 1408
string dataobject = "p0dw_prt_return_partner"
end type

type p_1 from w_a_print`p_1 within p0w_prt_return
integer y = 1856
end type

type p_2 from w_a_print`p_2 within p0w_prt_return
integer y = 1856
end type

type p_3 from w_a_print`p_3 within p0w_prt_return
integer y = 1856
end type

type p_5 from w_a_print`p_5 within p0w_prt_return
integer y = 1856
end type

type p_6 from w_a_print`p_6 within p0w_prt_return
integer y = 1856
end type

type p_7 from w_a_print`p_7 within p0w_prt_return
integer y = 1856
end type

type p_8 from w_a_print`p_8 within p0w_prt_return
integer y = 1856
end type

type p_9 from w_a_print`p_9 within p0w_prt_return
integer y = 1856
end type

type p_4 from w_a_print`p_4 within p0w_prt_return
end type

type gb_1 from w_a_print`gb_1 within p0w_prt_return
integer y = 1816
end type

type p_port from w_a_print`p_port within p0w_prt_return
integer y = 1880
end type

type p_land from w_a_print`p_land within p0w_prt_return
integer y = 1892
end type

type gb_cond from w_a_print`gb_cond within p0w_prt_return
integer width = 2341
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within p0w_prt_return
integer y = 1856
end type

