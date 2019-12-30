$PBExportHeader$p1w_prt_termcard.srw
$PBExportComments$[jojo] 만료카드 보고서
forward
global type p1w_prt_termcard from w_a_print
end type
end forward

global type p1w_prt_termcard from w_a_print
integer width = 3598
end type
global p1w_prt_termcard p1w_prt_termcard

on p1w_prt_termcard.create
call super::create
end on

on p1w_prt_termcard.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2 //세로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_work, ls_partner_prefix, ls_priceplan, ls_priceplan_txt, ls_status
String ls_enddt_fr, ls_enddt_to, ls_contno_fr, ls_contno_to
Date ld_enddt_fr, ld_enddt_to
Long ll_row
String ls_balance_from, ls_balance_to

ls_work = Trim(dw_cond.object.work[1])
ld_enddt_fr = dw_cond.object.enddt_fr[1]
ld_enddt_to = dw_cond.object.enddt_to[1]
ls_enddt_fr = String(ld_enddt_fr, 'yyyymmdd')
ls_enddt_to = String(ld_enddt_to, 'yyyymmdd')
ls_contno_fr = dw_cond.object.contno_fr[1]
ls_contno_to = dw_cond.object.contno_to[1]
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_partner_prefix = Trim(dw_cond.object.partner[1])
ls_status = Trim(dw_cond.object.status[1])
ls_balance_from = String(dw_cond.object.balance_from[1])
ls_balance_to = String(dw_cond.object.balance_to[1])

//Null Check
If IsNull(ls_work) Then ls_work = ""
If IsNull(ls_enddt_fr) Then ls_enddt_fr = ""
If IsNull(ls_enddt_to) Then ls_enddt_to = ""
If IsNull(ls_contno_fr) Then ls_contno_fr = ""
If IsNull(ls_contno_to) Then ls_contno_to = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_balance_from) Then ls_balance_from = ""
If IsNull(ls_balance_to) Then ls_balance_to = ""

If ls_work = "" Then
	 f_msg_usr_err(200, Title, "작업구분")     
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("work")
	 Return 
End IF

If ls_priceplan = "" Then
	 f_msg_usr_err(200, Title, "가격정책")     
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("work")
	 Return 
End IF

//Retrieve
ls_where = ""
If ls_enddt_fr <> "" and ls_enddt_to <> "" Then
	ll_row = fi_chk_frto_day(ld_enddt_fr, ld_enddt_to)
	If ll_row = -1 Then
	 f_msg_usr_err(211, Title, "유효기간")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("enddt_fr")
	 Return 
	End If
	
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(enddt, 'yyyymmdd') >='" + ls_enddt_fr + "' " + &
	   			"and to_char(enddt, 'yyyymmdd') <= '" + ls_enddt_to + "' "

ElseIf ls_enddt_fr <> "" and ls_enddt_to = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(enddt,'YYYYMMDD') >= '" + ls_enddt_fr + "' "
ElseIf ls_enddt_fr = "" and ls_enddt_to <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(enddt, 'YYYYMMDD') <= '" + ls_enddt_to + "' " 
End If


If ls_contno_fr <> "" and ls_contno_to <> "" Then
   If ls_contno_fr < ls_contno_to Then
   	 f_msg_usr_err(202, Title, "유효기간")             //입력 순서 잘못됨
	    dw_cond.SetFocus()
	    dw_cond.SetColumn("contno_fr")
	 Return 
	End If
	
	If ls_where <> "" Then ls_where += " And "
		ls_where += "contno >= '" + ls_contno_fr + "' " + &
	   			"and contno <= '" + ls_contno_to + "' "
End If


If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + ls_priceplan + "' "
End If

If ls_partner_prefix <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner_prefix = '" + ls_partner_prefix + "' "
End If


If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contno >= '" + ls_contno_fr + "' "+ &
	   			"and contno <= '" + ls_contno_to + "' "
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "status = '" + ls_status + "' "
End If

If ls_balance_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "balance >= '" + ls_balance_from + "' "
End If

If ls_balance_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "balance <= '" + ls_balance_to + "' "
End If



//기간만료, 잔액만료 구분
IF ls_work = '0' THEN
	dw_list.dataObject = "p1dw_prt_termcard_period"
	dw_list.SetTransObject(SQLCA)
	
	//조회조건 입력값을 보여준다.
	dw_list.Modify ( "p_work.text='기간만료'" )
	//dw_list.Modify ( "p_priceplan.text='" + ls_priceplan + "'" )
   
ELSEIF ls_work = '1' THEN
	dw_list.dataObject = "p1dw_prt_termcard_balance"
	dw_list.SetTransObject(SQLCA)
	
	//조회조건 입력값을 보여준다.
	dw_list.Modify ( "p_work.text='잔액만료'" )
	dw_list.Modify ( "p_priceplan.text='" + ls_priceplan + "'" )
	
END IF

	ls_priceplan_txt = dw_cond.object.compute_priceplan[1] 
   dw_list.object.t_priceplan.Text = ls_priceplan_txt


dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_termcard
integer x = 46
integer y = 40
integer width = 2843
integer height = 304
string dataobject = "p1dw_cnd_prt_termcard"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;if dwo.name = "contno_fr" Then
	This.Object.contno_to[1] = data
End If


end event

type p_ok from w_a_print`p_ok within p1w_prt_termcard
integer x = 2953
end type

type p_close from w_a_print`p_close within p1w_prt_termcard
integer x = 3255
end type

type dw_list from w_a_print`dw_list within p1w_prt_termcard
integer y = 376
integer width = 3483
integer height = 1212
string dataobject = "p1dw_prt_termcard_period"
end type

type p_1 from w_a_print`p_1 within p1w_prt_termcard
end type

type p_2 from w_a_print`p_2 within p1w_prt_termcard
end type

type p_3 from w_a_print`p_3 within p1w_prt_termcard
end type

type p_5 from w_a_print`p_5 within p1w_prt_termcard
end type

type p_6 from w_a_print`p_6 within p1w_prt_termcard
end type

type p_7 from w_a_print`p_7 within p1w_prt_termcard
end type

type p_8 from w_a_print`p_8 within p1w_prt_termcard
end type

type p_9 from w_a_print`p_9 within p1w_prt_termcard
end type

type p_4 from w_a_print`p_4 within p1w_prt_termcard
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_termcard
end type

type p_port from w_a_print`p_port within p1w_prt_termcard
end type

type p_land from w_a_print`p_land within p1w_prt_termcard
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_termcard
integer width = 2866
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_termcard
end type

