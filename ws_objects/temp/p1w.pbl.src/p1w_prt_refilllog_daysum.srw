$PBExportHeader$p1w_prt_refilllog_daysum.srw
$PBExportComments$[chooys] 충전보고서 일별합계
forward
global type p1w_prt_refilllog_daysum from w_a_print
end type
end forward

global type p1w_prt_refilllog_daysum from w_a_print
integer width = 3150
end type
global p1w_prt_refilllog_daysum p1w_prt_refilllog_daysum

on p1w_prt_refilllog_daysum.create
call super::create
end on

on p1w_prt_refilllog_daysum.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_refilldt_fr, ls_refilldt_to, ls_pid, ls_contno_fr, ls_contno_to, ls_sql, ls_refill_type, ls_prefixno
Date ld_refilldt_fr, ld_refilldt_to
Integer li_check

ld_refilldt_fr = dw_cond.object.refilldt_fr[1]
ld_refilldt_to = dw_cond.object.refilldt_to[1]
ls_refilldt_fr = Trim(String(ld_refilldt_fr, 'yyyymmdd'))
ls_refilldt_to = Trim(String(ld_refilldt_to, 'yyyymmdd'))
ls_refill_type = Trim(dw_cond.object.refill_type[1])
ls_pid = Trim(dw_cond.object.pid[1])
ls_contno_fr = Trim(dw_cond.object.contno_fr[1])
ls_contno_to = Trim(dw_cond.object.contno_to[1])
ls_prefixno = Trim(dw_cond.object.salman[1])

If IsNull(ls_refilldt_fr) Then ls_refilldt_fr = ""
If IsNull(ls_refilldt_to) Then ls_refilldt_to = ""
If IsNull(ls_refill_type) Then ls_refill_type = ""
If IsNull(ls_pid) Then ls_pid = ""
If IsNull(ls_contno_fr) Then ls_contno_fr = ""
If IsNull(ls_contno_to) Then ls_contno_to = ""
If IsNull(ls_prefixno) Then ls_prefixno = ""

// 충전일자의 From ~ To Check
If ls_refilldt_fr <> "" AND ls_refilldt_to <> "" Then
	li_check = fi_chk_frto_day(ld_refilldt_fr, ld_refilldt_to)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "충전일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("refilldt_fr")
		Return
	END IF
END IF

// Pin#, 관리번호 입력 Check
//If (ls_pid = "" And ls_contno_fr = "" And ls_contno_to = "" And ls_refill_type = "" And ls_refilldt_fr = "" And ls_refilldt_to = "") Then
//	f_msg_usr_err(9000, Title, "조건들 중 한가지는 입력해야 합니다.")
//	dw_cond.setfocus()
//	dw_cond.setcolumn("pid")
//	Return
//End If

// Dynamic SQL
ls_where = ""

If ls_refilldt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(refilldt, 'yyyymmdd') >= '" + ls_refilldt_fr + "' "
End If

If ls_refilldt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(refilldt, 'yyyymmdd') <= '" + ls_refilldt_to + "' "
End If

If ls_refill_type <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " refill_type = '" + ls_refill_type + "' "
End If

If ls_pid <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " pid = '" + ls_pid + "' "
End If

If ls_contno_Fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " contno >= '" + ls_contno_fr + "' "
End If

If ls_contno_to <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " contno <= '" + ls_contno_to + "' "
End If

If ls_prefixno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner_prefix = '" + ls_prefixno + "'"
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()


If ll_row = 0 Then
	f_msg_info(1000, Title,"")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 
End If

end event

event ue_init();call super::ue_init;ii_orientation = 2
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_refilllog_daysum
integer x = 55
integer y = 56
integer width = 2021
integer height = 296
string dataobject = "p1dw_cnd_prt_refilllog_daysum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p1w_prt_refilllog_daysum
integer x = 2185
integer y = 80
end type

type p_close from w_a_print`p_close within p1w_prt_refilllog_daysum
integer x = 2496
integer y = 80
end type

type dw_list from w_a_print`dw_list within p1w_prt_refilllog_daysum
integer y = 412
integer width = 3035
integer height = 1208
string dataobject = "p1dw_prt_refilllog_daysum"
end type

type p_1 from w_a_print`p_1 within p1w_prt_refilllog_daysum
end type

type p_2 from w_a_print`p_2 within p1w_prt_refilllog_daysum
end type

type p_3 from w_a_print`p_3 within p1w_prt_refilllog_daysum
end type

type p_5 from w_a_print`p_5 within p1w_prt_refilllog_daysum
end type

type p_6 from w_a_print`p_6 within p1w_prt_refilllog_daysum
end type

type p_7 from w_a_print`p_7 within p1w_prt_refilllog_daysum
end type

type p_8 from w_a_print`p_8 within p1w_prt_refilllog_daysum
end type

type p_9 from w_a_print`p_9 within p1w_prt_refilllog_daysum
end type

type p_4 from w_a_print`p_4 within p1w_prt_refilllog_daysum
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_refilllog_daysum
end type

type p_port from w_a_print`p_port within p1w_prt_refilllog_daysum
end type

type p_land from w_a_print`p_land within p1w_prt_refilllog_daysum
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_refilllog_daysum
integer width = 2089
integer height = 376
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_refilllog_daysum
end type

