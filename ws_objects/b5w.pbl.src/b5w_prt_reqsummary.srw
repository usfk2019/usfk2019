$PBExportHeader$b5w_prt_reqsummary.srw
$PBExportComments$[parkkh] 월별청구집계표
forward
global type b5w_prt_reqsummary from w_a_print
end type
end forward

global type b5w_prt_reqsummary from w_a_print
integer width = 3127
end type
global b5w_prt_reqsummary b5w_prt_reqsummary

type variables
string is_format, is_card, is_jiro, is_bank
end variables

on b5w_prt_reqsummary.create
call super::create
end on

on b5w_prt_reqsummary.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_trdt
String ls_trdtfr, ls_trdtto, ls_currency

//필수입력사항 check
ls_trdtfr = String(dw_cond.Object.trdtfr[1], "yyyymmdd")
ls_trdtto = String(dw_cond.Object.trdtto[1], "yyyymmdd")
ls_currency = Trim(dw_cond.object.currency_type[1])
If Isnull(ls_trdtfr) Then ls_trdtfr = ""				
If Isnull(ls_trdtto) Then ls_trdtto = ""				
If Isnull(ls_currency) Then ls_currency = ""

//***** 사용자 입력사항 검증 *****
If ls_trdtfr = "" Then
	f_msg_info(200, Title, "청구기준일(From)")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdtfr")
	Return
End If

If ls_trdtto = "" Then
	f_msg_info(200, Title, "청구기준일(To)")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdtto")
	Return
End If

If ls_trdtto <> "" Then
	If ls_trdtfr <> "" Then
		If ls_trdtfr > ls_trdtto Then
			f_msg_info(200, Title, "일자(From) <= 일자(To)")
			Return
		End If
	End If
End If

dw_list.Object.trdt_t.Text = String(ls_trdtfr, "@@@@-@@-@@") + " ~~ " + String(ls_trdtto, "@@@@-@@-@@")
 

ll_rows = dw_list.Retrieve(ls_trdtfr, ls_trdtto, is_jiro, is_bank, is_card, ls_currency)

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If

If is_format = "1" Then
	dw_list.object.tramt_giro.Format = "#,##0.0"
	dw_list.object.tramt_cms.Format = "#,##0.0"
	dw_list.object.tramt_card.Format = "#,##0.0"
	dw_list.object.tramt_etc.Format = "#,##0.0"
	dw_list.object.tramt_sum.Format = "#,##0.0"
	dw_list.object.sum_giro.Format = "#,##0.0"
	dw_list.object.sum_cms.Format = "#,##0.0"
	dw_list.object.sum_card.Format = "#,##0.0"
	dw_list.object.sum_etc.Format = "#,##0.0"	
	dw_list.object.sum_tot.Format = "#,##0.0"		
ElseIf is_format = "2" Then
	dw_list.object.tramt_giro.Format = "#,##0.00"
	dw_list.object.tramt_cms.Format = "#,##0.00"
	dw_list.object.tramt_card.Format = "#,##0.00"
	dw_list.object.tramt_etc.Format = "#,##0.00"
	dw_list.object.tramt_sum.Format = "#,##0.00"
	dw_list.object.sum_giro.Format = "#,##0.00"
	dw_list.object.sum_cms.Format = "#,##0.00"
	dw_list.object.sum_card.Format = "#,##0.00"
	dw_list.object.sum_etc.Format = "#,##0.00"	
	dw_list.object.sum_tot.Format = "#,##0.00"		
Else
	dw_list.object.tramt_giro.Format = "#,##0"
	dw_list.object.tramt_cms.Format = "#,##0"
	dw_list.object.tramt_card.Format = "#,##0"
	dw_list.object.tramt_etc.Format = "#,##0"
	dw_list.object.tramt_sum.Format = "#,##0"
	dw_list.object.sum_giro.Format = "#,##0"
	dw_list.object.sum_cms.Format = "#,##0"
	dw_list.object.sum_card.Format = "#,##0"
	dw_list.object.sum_etc.Format = "#,##0"	
	dw_list.object.sum_tot.Format = "#,##0"		
End If
end event

event ue_reset();call super::ue_reset;Date ld_sysdate

dw_list.Object.trdt_t.Text = ""

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)

Return
end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;Date ld_sysdate
String ls_ref_desc

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)

is_format = fs_get_control("B5", "H200", ls_ref_desc)

is_jiro = fs_get_control("B0", "P129", ls_ref_desc)
is_bank = fs_get_control("B0", "P130", ls_ref_desc)
is_card = fs_get_control("B0", "P131", ls_ref_desc)


Return
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_reqsummary
integer x = 73
integer y = 60
integer width = 1307
integer height = 228
string dataobject = "b5d_cnd_prt_reqsummary"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_reqsummary
integer x = 1522
integer y = 48
end type

type p_close from w_a_print`p_close within b5w_prt_reqsummary
integer x = 1833
integer y = 48
end type

type dw_list from w_a_print`dw_list within b5w_prt_reqsummary
integer x = 32
integer y = 332
integer width = 3031
integer height = 1264
string dataobject = "b5dw_prt_reqsummary"
end type

type p_1 from w_a_print`p_1 within b5w_prt_reqsummary
integer x = 2688
end type

type p_2 from w_a_print`p_2 within b5w_prt_reqsummary
end type

type p_3 from w_a_print`p_3 within b5w_prt_reqsummary
end type

type p_5 from w_a_print`p_5 within b5w_prt_reqsummary
end type

type p_6 from w_a_print`p_6 within b5w_prt_reqsummary
end type

type p_7 from w_a_print`p_7 within b5w_prt_reqsummary
end type

type p_8 from w_a_print`p_8 within b5w_prt_reqsummary
end type

type p_9 from w_a_print`p_9 within b5w_prt_reqsummary
end type

type p_4 from w_a_print`p_4 within b5w_prt_reqsummary
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_reqsummary
end type

type p_port from w_a_print`p_port within b5w_prt_reqsummary
end type

type p_land from w_a_print`p_land within b5w_prt_reqsummary
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_reqsummary
integer width = 1381
integer height = 308
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_reqsummary
end type

