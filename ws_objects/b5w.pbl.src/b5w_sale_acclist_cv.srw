$PBExportHeader$b5w_sale_acclist_cv.srw
$PBExportComments$[chooys] 매출정산보고서 Window
forward
global type b5w_sale_acclist_cv from w_a_print
end type
type dw_hidden from datawindow within b5w_sale_acclist_cv
end type
end forward

global type b5w_sale_acclist_cv from w_a_print
dw_hidden dw_hidden
end type
global b5w_sale_acclist_cv b5w_sale_acclist_cv

type variables
String is_format
String is_chk
String is_currency
end variables

on b5w_sale_acclist_cv.create
int iCurrent
call super::create
this.dw_hidden=create dw_hidden
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_hidden
end on

on b5w_sale_acclist_cv.destroy
call super::destroy
destroy(this.dw_hidden)
end on

event open;call super::open;String ls_desc
 
dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())

//금액의 소숫점 자리수 가져오기(B5:H200)
is_format = fs_get_control("B5","H200",ls_desc)

//고객유형2가 개인인 코드
is_chk = fs_get_control("B0","P111",ls_desc)

//통화유형
is_currency = fs_get_control("B0","P105",ls_desc)
end event

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long ll_rc, ll_rows, ll_cur
String ls_where
String ls_trdt, ls_trdtfr, ls_trdtto
Date ld_trdate


//필수입력사항 check
ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm")
If Isnull(ls_trdt) Then ls_trdt = ""				
	

//***** 사용자 입력사항 검증 *****
If ls_trdt = "" Then
	f_msg_info(200, Title, "거래기준년월")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdt")
	Return
End If

dw_list.object.t_yyyymm.text = MidA(ls_trdt,1,4) + "-" + MidA(ls_trdt,5,2)

ld_trdate = dw_cond.Object.trdt[1]

ls_trdtfr = String(f_mon_first_date(ld_trdate),"yyyymmdd")
ls_trdtto = String(f_mon_last_date(ld_trdate),"yyyymmdd")


//If is_format = "1" Then
//	dw_list.object.reqdtl_tramt.Format = "#,##0.0"
//	dw_list.object.indamt.Format = "#,##0.0"
//	dw_list.object.comamt.Format = "#,##0.0"
//	dw_list.object.sum_tramt.Format = "#,##0.0"
//	dw_list.object.sum_indamt.Format = "#,##0.0"
//	dw_list.object.sum_comamt.Format = "#,##0.0"
//ElseIf is_format = "2" Then
//	dw_list.object.reqdtl_tramt.Format = "#,##0.00"
//	dw_list.object.indamt.Format = "#,##0.00"
//	dw_list.object.comamt.Format = "#,##0.00"
//	dw_list.object.sum_tramt.Format = "#,##0.00"
//	dw_list.object.sum_indamt.Format = "#,##0.00"
//	dw_list.object.sum_comamt.Format = "#,##0.00"
//Else
//	dw_list.object.reqdtl_tramt.Format = "#,##0"
//	dw_list.object.indamt.Format = "#,##0"
//	dw_list.object.comamt.Format = "#,##0"
//	dw_list.object.sum_tramt.Format = "#,##0"
//	dw_list.object.sum_indamt.Format = "#,##0"
//	dw_list.object.sum_comamt.Format = "#,##0"
//End If


//dw_hidden.
ll_rows = dw_hidden.Retrieve(is_chk, ls_trdtfr, is_currency)
//ll_rows = dw_hidden.Retrieve(is_chk, ls_trdtfr, ls_trdtto, is_currency)
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If


String ls_crdr
Dec ld_tramt, ld_indamt, ld_comamt
Dec ld_tot_cr, ld_tot
Dec ld_tot_cr_ind, ld_tot_ind
Dec ld_tot_cr_com, ld_tot_com
ld_tot_cr = 0
ld_tot = 0
ld_tot_cr_ind = 0
ld_tot_ind = 0
ld_tot_cr_com = 0
ld_tot_com = 0

dw_list.reset()

dw_list.setRedraw(false)

FOR ll_cur=1 to ll_rows
	
	ls_crdr = Trim(dw_hidden.object.cr_dr[ll_cur])
	
	IF ls_crdr = "CR" THEN
		ld_tramt = dw_hidden.object.reqdtl_tramt[ll_cur]
		ld_indamt = dw_hidden.object.indamt[ll_cur]
		ld_comamt = dw_hidden.object.comamt[ll_cur]
		
		ld_tot_cr = ld_tot_cr + ld_tramt
		ld_tot_cr_ind = ld_tot_cr_ind + ld_indamt
		ld_tot_cr_com = ld_tot_cr_com + ld_comamt
		
		ld_tot = ld_tot + ld_tramt
		ld_tot_ind = ld_tot_ind + ld_indamt
		ld_tot_com = ld_tot_com + ld_comamt
	ELSE
		ld_tramt = dw_hidden.object.reqdtl_tramt[ll_cur]
		ld_indamt = dw_hidden.object.indamt[ll_cur]
		ld_comamt = dw_hidden.object.comamt[ll_cur]
		
		ld_tot = ld_tot + ld_tramt
		ld_tot_ind = ld_tot_ind + ld_indamt
		ld_tot_com = ld_tot_com + ld_comamt
	END IF
	
	dw_list.insertrow(0)
	dw_list.object.cr_dr[ll_cur] = ls_crdr
	dw_list.object.transaction[ll_cur] = dw_hidden.object.transaction[ll_cur]
	dw_list.object.trcnt[ll_cur] = dw_hidden.object.reqdtl_trcnt[ll_cur]
	dw_list.object.tramt[ll_cur] = ld_tramt
	dw_list.object.indamt[ll_cur] = ld_indamt
	dw_list.object.comamt[ll_cur] = ld_comamt
	dw_list.object.date[ll_cur] = fdt_get_dbserver_now()
NEXT


ll_cur = ll_rows +1

//매출계 Insert
dw_list.insertrow(0)
dw_list.object.cr_dr[ll_cur] = "CR"
dw_list.object.transaction[ll_cur] = "매출계"
//dw_list.object.trcnt[ll_cur] = 
dw_list.object.tramt[ll_cur] = ld_tot_cr
dw_list.object.indamt[ll_cur] = ld_tot_cr_ind
dw_list.object.comamt[ll_cur] = ld_tot_cr_com

ll_cur = ll_cur +1

//매출총계(매출+부가세) Insert
dw_list.insertrow(0)
dw_list.object.cr_dr[ll_cur] = "CV"
dw_list.object.transaction[ll_cur] = "Total Amount Due"
//dw_list.object.trcnt[ll_cur] = 
dw_list.object.tramt[ll_cur] = ld_tot
dw_list.object.indamt[ll_cur] = ld_tot_ind
dw_list.object.comamt[ll_cur] = ld_tot_com

dw_list.sort()

dw_list.setRedraw(true)

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within b5w_sale_acclist_cv
integer width = 878
integer height = 164
string dataobject = "b5dw_cnd_sale_acclist_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_sale_acclist_cv
integer x = 997
integer y = 48
end type

type p_close from w_a_print`p_close within b5w_sale_acclist_cv
integer x = 1298
integer y = 48
end type

type dw_list from w_a_print`dw_list within b5w_sale_acclist_cv
integer y = 248
integer height = 1372
string dataobject = "b5dw_prt_sale_acclist_cv_ext"
end type

type p_1 from w_a_print`p_1 within b5w_sale_acclist_cv
end type

type p_2 from w_a_print`p_2 within b5w_sale_acclist_cv
end type

type p_3 from w_a_print`p_3 within b5w_sale_acclist_cv
end type

type p_5 from w_a_print`p_5 within b5w_sale_acclist_cv
end type

type p_6 from w_a_print`p_6 within b5w_sale_acclist_cv
end type

type p_7 from w_a_print`p_7 within b5w_sale_acclist_cv
end type

type p_8 from w_a_print`p_8 within b5w_sale_acclist_cv
end type

type p_9 from w_a_print`p_9 within b5w_sale_acclist_cv
end type

type p_4 from w_a_print`p_4 within b5w_sale_acclist_cv
end type

type gb_1 from w_a_print`gb_1 within b5w_sale_acclist_cv
end type

type p_port from w_a_print`p_port within b5w_sale_acclist_cv
end type

type p_land from w_a_print`p_land within b5w_sale_acclist_cv
end type

type gb_cond from w_a_print`gb_cond within b5w_sale_acclist_cv
integer width = 910
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within b5w_sale_acclist_cv
end type

type dw_hidden from datawindow within b5w_sale_acclist_cv
boolean visible = false
integer x = 55
integer y = 268
integer width = 2885
integer height = 1300
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5dw_prt_sale_acclist_cv"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

