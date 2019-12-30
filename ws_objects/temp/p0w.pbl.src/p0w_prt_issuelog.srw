$PBExportHeader$p0w_prt_issuelog.srw
$PBExportComments$[jojo] 카드발행 보고서
forward
global type p0w_prt_issuelog from w_a_print
end type
end forward

global type p0w_prt_issuelog from w_a_print
end type
global p0w_prt_issuelog p0w_prt_issuelog

on p0w_prt_issuelog.create
call super::create
end on

on p0w_prt_issuelog.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_pricemodel, ls_lotno, ls_issuestat
String ls_issuedt_fr, ls_issuedt_to
Date ld_issuedt_fr, ld_issuedt_to
Long ll_row

ld_issuedt_fr = dw_cond.object.issuedt_fr[1]
ld_issuedt_to = dw_cond.object.issuedt_to[1]
ls_issuedt_fr = String(ld_issuedt_fr, 'yyyymmdd')
ls_issuedt_to = String(ld_issuedt_to, 'yyyymmdd')
ls_pricemodel = Trim(dw_cond.object.pricemodel[1])
ls_lotno = Trim(dw_cond.object.lotno[1])
ls_issuestat = Trim(dw_cond.object.issuestat[1])

//Null Check
If IsNull(ls_issuedt_fr) Then ls_issuedt_fr = ""
If IsNull(ls_issuedt_fr) Then ls_issuedt_fr = ""
If IsNull(ls_pricemodel) Then ls_pricemodel = ""
If IsNull(ls_lotno) Then ls_lotno = ""
If IsNull(ls_issuestat) Then ls_issuestat = ""

//Retrieve
ls_where = ""
If ls_issuedt_fr <> ""  and ls_issuedt_to <> "" Then
	ll_row = fi_chk_frto_day(ld_issuedt_fr, ld_issuedt_to)
	If ll_row = -1 Then
	 f_msg_usr_err(211, Title, "발행일자")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("issuedt_fr")
	 Return 
	End If
	
	If ls_where <> "" Then ls_where += " And "  
	
   ls_where += "to_char(issuedt, 'yyyymmdd') >='" + ls_issuedt_fr + "' " + &
	   			"and to_char(issuedt, 'yyyymmdd') < = '" + ls_issuedt_to + "' "

ElseIf ls_issuedt_fr <> "" and ls_issuedt_to = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(issuedt,'YYYYMMDD') > = '" + ls_issuedt_fr + "' "
ElseIf ls_issuedt_fr = "" and ls_issuedt_to <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(issuedt, 'YYYYMMDD') < = '" + ls_issuedt_to + "' " 
End If

//조회조건 입력값을 보여준다.
dw_list.Modify ( "t_issuedt_fr.text='" + String(ld_issuedt_fr, 'yyyy-mm-dd')+ "'" )
dw_list.Modify ( "t_issuedt_to.text='" + String(ld_issuedt_to, 'yyyy-mm-dd')+ "'" )


If ls_pricemodel <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "pricemodel = '" + ls_pricemodel + "' "
End If

If ls_lotno <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "lotno = '" + ls_lotno + "' "
End If

If ls_issuestat <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "issuestat = '" + ls_issuestat + "' "
End If


//clipboard(ls_where)
//clipboard(dw_List.getsqlselect())
//messagebox("1",ls_Where)

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

type dw_cond from w_a_print`dw_cond within p0w_prt_issuelog
integer width = 2217
integer height = 224
string dataobject = "p0dw_cnd_prt_issuelog"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p0w_prt_issuelog
end type

type p_close from w_a_print`p_close within p0w_prt_issuelog
end type

type dw_list from w_a_print`dw_list within p0w_prt_issuelog
integer y = 308
string dataobject = "p0dw_prt_issuelog"
end type

type p_1 from w_a_print`p_1 within p0w_prt_issuelog
end type

type p_2 from w_a_print`p_2 within p0w_prt_issuelog
end type

type p_3 from w_a_print`p_3 within p0w_prt_issuelog
end type

type p_5 from w_a_print`p_5 within p0w_prt_issuelog
end type

type p_6 from w_a_print`p_6 within p0w_prt_issuelog
end type

type p_7 from w_a_print`p_7 within p0w_prt_issuelog
end type

type p_8 from w_a_print`p_8 within p0w_prt_issuelog
end type

type p_9 from w_a_print`p_9 within p0w_prt_issuelog
end type

type p_4 from w_a_print`p_4 within p0w_prt_issuelog
end type

type gb_1 from w_a_print`gb_1 within p0w_prt_issuelog
end type

type p_port from w_a_print`p_port within p0w_prt_issuelog
end type

type p_land from w_a_print`p_land within p0w_prt_issuelog
end type

type gb_cond from w_a_print`gb_cond within p0w_prt_issuelog
integer width = 2322
integer height = 292
end type

type p_saveas from w_a_print`p_saveas within p0w_prt_issuelog
end type

