$PBExportHeader$b1w_prt_bilcdr_1.srw
$PBExportComments$[jwlee]CDR보고서(접속료)
forward
global type b1w_prt_bilcdr_1 from w_a_print
end type
end forward

global type b1w_prt_bilcdr_1 from w_a_print
integer width = 3323
integer height = 1992
end type
global b1w_prt_bilcdr_1 b1w_prt_bilcdr_1

on b1w_prt_bilcdr_1.create
call super::create
end on

on b1w_prt_bilcdr_1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_validkeyreq
	Desc.	: 인증key요청 내역 보고서
	Ver.	: 1.0
	Date	: 2004.07.26
	Programer : Kwon Jung Min(KwonJM)
-------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_stime1_fr, ls_stime1_to, ls_country_cd, ls_salmanid, ls_rtelnum1, &
		 ls_pid, ls_choice_type, ls_choice_dw, ls_payid
		 
ls_stime1_fr = String(dw_cond.Object.stime1_fr[1], "yyyymmdd")
ls_stime1_to = String(dw_cond.Object.stime1_to[1], "yyyymmdd")
ls_country_cd = Trim(dw_cond.Object.country_cd[1])
ls_salmanid = Trim(dw_cond.Object.salmanid[1])
ls_rtelnum1 = Trim(dw_cond.Object.rtelnum1[1])
ls_pid = Trim(dw_cond.Object.pid[1])
ls_payid = Trim(dw_cond.Object.payid[1])
ls_choice_type = dw_cond.Object.choice_type[1]

If ls_stime1_fr = "" Then
	f_msg_usr_err(200, This.Title, "통화시작일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("stime1_fr")
	Return
ElseIf ls_stime1_to = "" Then
	f_msg_usr_err(200, This.Title, "통화시작일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("stime1_to")
	Return
ElseIf ls_stime1_fr > ls_stime1_to Then
	f_msg_usr_err(211, This.Title, "통화시작일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("stime1_fr")
	Return
End If

If IsNull(ls_country_cd) Then ls_country_cd = ""
If IsNull(ls_salmanid) Then ls_salmanid = ""
If IsNull(ls_rtelnum1) Then ls_rtelnum1 = ""
If IsNull(ls_pid) Then ls_pid = ""
If IsNull(ls_payid) Then ls_payid = ""

is_title = "합산후 전체CDR 보고서(청구후)"

Trigger Event ue_set_header()

ls_where = ""

If ls_choice_type = "1" Then
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.trunk_flag = '3' "
ElseIf ls_choice_type = "2" Then
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.trunk_flag IN ('0', '1', '2') "
End If

If ls_country_cd <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " old_bilcdrh.country_cd like '" + ls_country_cd + "%' "
End If
If ls_rtelnum1 <> "" Then 
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.rtelnum1 like '" + ls_rtelnum1 + "%' "
End If
If ls_pid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.subid like '" + ls_pid + "%' "
End If
If ls_payid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.payid like '" + ls_payid + "%' "
End If


If ls_salmanid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "		
	ls_where += " old_bilcdrh.salmanid = '" + ls_salmanid + "' "
End If

If ls_stime1_fr <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " workdt >= '" + ls_stime1_fr + "' "
End If
If ls_stime1_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "	
	ls_where += " workdt <= '" + ls_stime1_to + "' "
End If
	

dw_list.SetTransObject(SQLCA)

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_bilcdr_1
integer x = 69
integer y = 36
integer width = 2190
integer height = 380
string dataobject = "b1dw_cnd_prt_bilcdr_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_bilcdr_1
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_bilcdr_1
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_bilcdr_1
integer y = 464
integer width = 3232
integer height = 1144
string dataobject = "b1dw_prt_BILCDR_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_bilcdr_1
end type

type p_2 from w_a_print`p_2 within b1w_prt_bilcdr_1
end type

type p_3 from w_a_print`p_3 within b1w_prt_bilcdr_1
end type

type p_5 from w_a_print`p_5 within b1w_prt_bilcdr_1
end type

type p_6 from w_a_print`p_6 within b1w_prt_bilcdr_1
end type

type p_7 from w_a_print`p_7 within b1w_prt_bilcdr_1
end type

type p_8 from w_a_print`p_8 within b1w_prt_bilcdr_1
end type

type p_9 from w_a_print`p_9 within b1w_prt_bilcdr_1
end type

type p_4 from w_a_print`p_4 within b1w_prt_bilcdr_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_bilcdr_1
end type

type p_port from w_a_print`p_port within b1w_prt_bilcdr_1
end type

type p_land from w_a_print`p_land within b1w_prt_bilcdr_1
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_bilcdr_1
integer width = 2254
integer height = 436
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_bilcdr_1
end type

