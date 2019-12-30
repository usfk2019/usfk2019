$PBExportHeader$p1w_prt_pmst_cp.srw
$PBExportComments$[uhmjj] 선불카드마스터 조회 (CPASS 출력물)
forward
global type p1w_prt_pmst_cp from w_a_print
end type
end forward

global type p1w_prt_pmst_cp from w_a_print
integer width = 3840
end type
global p1w_prt_pmst_cp p1w_prt_pmst_cp

on p1w_prt_pmst_cp.create
call super::create
end on

on p1w_prt_pmst_cp.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_pid
String ls_contnofr
String ls_contnoto
String ls_status
String ls_issuedtfr
String ls_issuedtto
String ls_partner
String ls_model
String ls_lotno
String ls_priceplan
String ls_validkey
Long ll_row
String ls_where


ls_pid = Trim(dw_cond.object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contnofr = Trim(dw_cond.object.contno_from[1])
If IsNull(ls_contnofr) Then ls_contnofr = ""

ls_contnoto = Trim(dw_cond.object.contno_to[1])
If IsNull(ls_contnoto) Then ls_contnoto = ""

ls_status = Trim(dw_cond.object.status[1])
If IsNull(ls_status) Then ls_status = ""

ls_issuedtfr = String(dw_cond.object.issuedt_from[1],"YYYYMMDD")
If IsNull(ls_issuedtfr) Then ls_issuedtfr = ""

ls_issuedtto = String(dw_cond.object.issuedt_to[1],"YYYYMMDD")
If IsNull(ls_issuedtto) Then ls_issuedtto = ""

ls_partner = Trim(dw_cond.object.partner[1])
If IsNull(ls_partner) Then ls_partner = ""

ls_model = Trim(dw_cond.object.pricemodel[1])
If IsNull(ls_model) Then ls_model = ""

ls_lotno = Trim(dw_cond.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_priceplan = Trim(dw_cond.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_validkey = Trim(dw_cond.object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""

 

If ls_issuedtfr > ls_issuedtto Then
	f_msg_usr_err(210, Title, "발행일시작 <= 발행일종료")
	dw_cond.SetFocus()
	dw_cond.setColumn("issuedt_from")
	Return 
End If


IF ls_pid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid = '"+ ls_pid +"'"
END IF

IF ls_contnofr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno >= '"+ ls_contnofr +"'"
END IF

IF ls_contnoto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.contno <= '"+ ls_contnoto +"'"
END IF

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.status = '"+ ls_status +"'"
END IF

IF ls_issuedtfr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') >= '"+ ls_issuedtfr +"'"
END IF

IF ls_issuedtto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(p_cardmst.issuedt,'YYYYMMDD') <= '"+ ls_issuedtto +"'"
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.partner_prefix = '"+ ls_partner +"'"
END IF

IF ls_model <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pricemodel = '"+ ls_model +"'"
END IF

IF ls_lotno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.lotno = '"+ ls_lotno +"'"
END IF

IF ls_priceplan <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.priceplan = '"+ ls_priceplan +"'"
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "p_cardmst.pid in (select pid from validinfo where svctype = (select ref_content from sysctl1t where module = 'P0' and ref_no = 'P100') and validkey = '"+ ls_validkey +"')"
END IF

If ls_where = "" Then
	f_msg_info(200, Title, "1가지 이상 조회 조건")
	dw_cond.SetFocus()
	dw_cond.setColumn("pid")
	Return 
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")			
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If

Return

end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_pmst_cp
integer width = 2606
integer height = 392
string dataobject = "p1dw_cnd_prt_pmst_cp"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p1w_prt_pmst_cp
integer x = 2885
end type

type p_close from w_a_print`p_close within p1w_prt_pmst_cp
integer x = 3186
end type

type dw_list from w_a_print`dw_list within p1w_prt_pmst_cp
integer y = 472
integer width = 3712
integer height = 1096
string dataobject = "p1dw_prt_pcardmst_cp"
end type

type p_1 from w_a_print`p_1 within p1w_prt_pmst_cp
end type

type p_2 from w_a_print`p_2 within p1w_prt_pmst_cp
end type

type p_3 from w_a_print`p_3 within p1w_prt_pmst_cp
end type

type p_5 from w_a_print`p_5 within p1w_prt_pmst_cp
end type

type p_6 from w_a_print`p_6 within p1w_prt_pmst_cp
end type

type p_7 from w_a_print`p_7 within p1w_prt_pmst_cp
end type

type p_8 from w_a_print`p_8 within p1w_prt_pmst_cp
end type

type p_9 from w_a_print`p_9 within p1w_prt_pmst_cp
end type

type p_4 from w_a_print`p_4 within p1w_prt_pmst_cp
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_pmst_cp
end type

type p_port from w_a_print`p_port within p1w_prt_pmst_cp
end type

type p_land from w_a_print`p_land within p1w_prt_pmst_cp
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_pmst_cp
integer width = 2697
integer height = 444
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_pmst_cp
end type

