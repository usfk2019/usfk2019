$PBExportHeader$b5w_prt_insummary.srw
$PBExportComments$[parkkh] 월별수금집계표
forward
global type b5w_prt_insummary from w_a_print
end type
end forward

global type b5w_prt_insummary from w_a_print
integer height = 1992
end type
global b5w_prt_insummary b5w_prt_insummary

type variables
String is_format, is_arg_gu[]
end variables

on b5w_prt_insummary.create
call super::create
end on

on b5w_prt_insummary.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
Integer li_cnt
String ls_where
String ls_trdt, ls_temp, ls_ref_desc, ls_content[], ls_title[], ls_null, ls_currency_type
String ls_trdtfr, ls_trdtto

//필수입력사항 check
ls_trdtfr = String(dw_cond.Object.trdtfr[1], "yyyymmdd")
ls_trdtto = String(dw_cond.Object.trdtto[1], "yyyymmdd")
ls_currency_type = Trim(dw_cond.object.currency_type[1])
If Isnull(ls_trdtfr) Then ls_trdtfr = ""				
If Isnull(ls_trdtto) Then ls_trdtto = ""		
If Isnull(ls_currency_type) Then ls_currency_type = ""

//***** 사용자 입력사항 검증 *****
If ls_trdtfr = "" Then
	f_msg_info(200, Title, "지급일자(From)")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdtfr")
	Return
End If

If ls_trdtto = "" Then
	f_msg_info(200, Title, "지급일자(To)")
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

dw_list.Object.paydt_t.Text = String(ls_trdtfr, "@@@@-@@-@@") + " ~~ " + String(ls_trdtto, "@@@@-@@-@@")

//수금 집계 항목 가져오기
ls_temp = fs_get_control("B5","I102", ls_ref_desc)
If ls_temp = "" Then Return 
li_cnt = fi_cut_string(ls_temp, ";" , ls_content[])
//5개까지 기본 Setting
For li_cnt = li_cnt To 5
	If li_cnt < 5 Then
		li_cnt ++
		ls_content[li_cnt] = ls_null
	End If
Next

//수금 Title 가져오기
ls_temp = fs_get_control("B5","I103", ls_ref_desc)
If ls_temp = "" Then Return 
li_cnt = fi_cut_string(ls_temp, ";" , ls_title[])
//5개까지 기본 Setting
For li_cnt = li_cnt To 5
	If li_cnt < 5 Then
		li_cnt ++
		ls_title[li_cnt] = ls_null
	End If
Next

dw_list.SetRedraw(FALSE)
 
//Retrieve 
ll_rows = dw_list.Retrieve(ls_trdtfr,ls_trdtto,ls_content[1], ls_content[2], ls_content[3], ls_content[4],ls_content[5], ls_currency_type)

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If

//Title Setting
dw_list.object.tramt_1_t.Text = ls_title[1]
dw_list.object.tramt_2_t.Text = ls_title[2]
dw_list.object.tramt_3_t.Text = ls_title[3]
dw_list.object.tramt_4_t.Text = ls_title[4]
dw_list.object.tramt_5_t.Text = ls_title[5]
dw_list.object.tramt_etc_t.Text = "ETC"


If is_format = "1" Then
	dw_list.object.tramt_1.Format = "#,##0.0"
	dw_list.object.tramt_2.Format = "#,##0.0"
	dw_list.object.tramt_3.Format = "#,##0.0"
	dw_list.object.tramt_4.Format = "#,##0.0"	
	dw_list.object.tramt_5.Format = "#,##0.0"	
	dw_list.object.tramt_etc.Format = "#,##0.0"
	dw_list.object.tramt_sum.Format = "#,##0.0"
	dw_list.object.sum_1.Format = "#,##0.0"
	dw_list.object.sum_2.Format = "#,##0.0"
	dw_list.object.sum_3.Format = "#,##0.0"
	dw_list.object.sum_etc.Format = "#,##0.0"	
	dw_list.object.sum_4.Format = "#,##0.0"		
	dw_list.object.sum_5.Format = "#,##0.0"		
	dw_list.object.sum_tot.Format = "#,##0.0"		
ElseIf is_format = "2" Then
	dw_list.object.tramt_1.Format = "#,##0.00"
	dw_list.object.tramt_2.Format = "#,##0.00"
	dw_list.object.tramt_3.Format = "#,##0.00"
	dw_list.object.tramt_4.Format = "#,##0.00"	
	dw_list.object.tramt_5.Format = "#,##0.00"		
	dw_list.object.tramt_etc.Format = "#,##0.00"
	dw_list.object.tramt_sum.Format = "#,##0.00"
	dw_list.object.sum_1.Format = "#,##0.00"
	dw_list.object.sum_2.Format = "#,##0.00"
	dw_list.object.sum_3.Format = "#,##0.00"
	dw_list.object.sum_etc.Format = "#,##0.00"	
	dw_list.object.sum_4.Format = "#,##0.00"		
	dw_list.object.sum_5.Format = "#,##0.00"		
	dw_list.object.sum_tot.Format = "#,##0.00"		
Else
	dw_list.object.tramt_1.Format = "#,##0"
	dw_list.object.tramt_2.Format = "#,##0"
	dw_list.object.tramt_3.Format = "#,##0"
	dw_list.object.tramt_etc.Format = "#,##0"
	dw_list.object.tramt_4.Format = "#,##0"	
	dw_list.object.tramt_5.Format = "#,##0"		
	dw_list.object.tramt_sum.Format = "#,##0"
	dw_list.object.sum_1.Format = "#,##0"
	dw_list.object.sum_2.Format = "#,##0"
	dw_list.object.sum_3.Format = "#,##0"
	dw_list.object.sum_etc.Format = "#,##0"	
	dw_list.object.sum_4.Format = "#,##0"	
	dw_list.object.sum_5.Format = "#,##0"		
	dw_list.object.sum_tot.Format = "#,##0"		
End If
end event

event ue_reset();call super::ue_reset;date ld_sysdate

dw_list.Object.paydt_t.Text = ""

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)


end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;Date ld_sysdate
String ls_ref_desc, ls_temp, ls_result[]

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)

is_format = fs_get_control("B5", "H200", ls_ref_desc)  //소수점 자리수

end event

type dw_cond from w_a_print`dw_cond within b5w_prt_insummary
integer x = 64
integer y = 56
integer width = 1312
integer height = 228
string dataobject = "b5d_cnd_prt_insummary"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_insummary
integer x = 1609
integer y = 60
end type

type p_close from w_a_print`p_close within b5w_prt_insummary
integer x = 1915
integer y = 60
end type

type dw_list from w_a_print`dw_list within b5w_prt_insummary
integer x = 23
integer y = 344
integer width = 3031
integer height = 1288
string dataobject = "b5dw_prt_insummary"
end type

type p_1 from w_a_print`p_1 within b5w_prt_insummary
integer x = 2688
integer y = 1684
end type

type p_2 from w_a_print`p_2 within b5w_prt_insummary
integer y = 1676
end type

type p_3 from w_a_print`p_3 within b5w_prt_insummary
integer y = 1684
end type

type p_5 from w_a_print`p_5 within b5w_prt_insummary
integer y = 1684
end type

type p_6 from w_a_print`p_6 within b5w_prt_insummary
integer y = 1684
end type

type p_7 from w_a_print`p_7 within b5w_prt_insummary
integer y = 1684
end type

type p_8 from w_a_print`p_8 within b5w_prt_insummary
integer y = 1684
end type

type p_9 from w_a_print`p_9 within b5w_prt_insummary
integer y = 1676
end type

type p_4 from w_a_print`p_4 within b5w_prt_insummary
integer y = 1676
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_insummary
integer y = 1640
end type

type p_port from w_a_print`p_port within b5w_prt_insummary
integer y = 1696
end type

type p_land from w_a_print`p_land within b5w_prt_insummary
integer y = 1708
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_insummary
integer width = 1445
integer height = 312
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_insummary
integer y = 1688
end type

