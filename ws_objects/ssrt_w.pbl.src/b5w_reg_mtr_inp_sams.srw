$PBExportHeader$b5w_reg_mtr_inp_sams.srw
$PBExportComments$[1hera] 입금수동거래등록 - sams
forward
global type b5w_reg_mtr_inp_sams from w_a_reg_m_sql
end type
type st_horizontal from statictext within b5w_reg_mtr_inp_sams
end type
type dw_detail2 from u_d_indicator within b5w_reg_mtr_inp_sams
end type
type dw_split from datawindow within b5w_reg_mtr_inp_sams
end type
type p_reset from u_p_reset within b5w_reg_mtr_inp_sams
end type
type cb_1 from commandbutton within b5w_reg_mtr_inp_sams
end type
type cb_contract from commandbutton within b5w_reg_mtr_inp_sams
end type
type cb_2 from commandbutton within b5w_reg_mtr_inp_sams
end type
type cb_close2 from commandbutton within b5w_reg_mtr_inp_sams
end type
type st_hotbill from statictext within b5w_reg_mtr_inp_sams
end type
type r_1 from rectangle within b5w_reg_mtr_inp_sams
end type
type r_2 from rectangle within b5w_reg_mtr_inp_sams
end type
end forward

global type b5w_reg_mtr_inp_sams from w_a_reg_m_sql
integer width = 4384
integer height = 2192
event type long ue_retive ( )
event ue_reset ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event type integer ue_process ( )
st_horizontal st_horizontal
dw_detail2 dw_detail2
dw_split dw_split
p_reset p_reset
cb_1 cb_1
cb_contract cb_contract
cb_2 cb_2
cb_close2 cb_close2
st_hotbill st_hotbill
r_1 r_1
r_2 r_2
end type
global b5w_reg_mtr_inp_sams b5w_reg_mtr_inp_sams

type variables
//NVO For Processing
u_cust_a_db iu_cust_db_prc

//AncestorReturnValue사용으로 필요가 없어짐.
//Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

//Messeage for messagebox
String is_msg_text
String is_msg_process

//Messeage No. for messagebox
Long il_msg_no

protected privatewrite string is_cur_fr,is_cur_to,is_next_fr,is_next_to
protected privatewrite Integer ii_input_error


String 	is_paycod, 		is_format, 	is_reqdt
Double 	ib_seq
DATE		idt_shop_closedt

DEC{2} 	idc_amt[], 		idc_total, 	idc_income_tot, idc_impack
String 	is_method[], 	is_trcod[],	is_refresh
Integer 	ii_method_cnt 	

end variables

forward prototypes
public subroutine of_resizepanels ()
public function integer wf_set_impack (string as_data)
public subroutine wf_set_total ()
public function integer wf_split (date wfdt_paydt)
public function long wfi_call_proc ()
public function integer wfi_get_payid (string as_payid, string as_memberid)
public function integer wfi_get_paytype (string as_paytype)
public function integer wf_split_new (date wfdt_paydt)
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
end prototypes

event type long ue_retive();String 	ls_paydt, 	ls_trdt, 	ls_trcod, 	ls_remark, 	ls_paycod
String 	ls_crtdt, 	ls_payid, 	ls_reqdt, 	ls_filter
Dec    	ld_payamt, 	ld_preamt, 	ld_curamt
Long   	ll_rc, 		ll_row

DataWindowChild ldc_trdt

ls_payid = Trim(dw_cond.object.payid[1])

//청구 기준일 구하기
SELECT to_char(reqdt, 'yyyymmdd') INTO :ls_reqdt FROM reqconf
WHERE chargedt = ( select chargedt from reqinfo where payid = :ls_payid );

// 해당 청구년월의 미납액
SELECT sum(tramt + taxamt - payidamt) INTO :ld_preamt FROM reqdtl 
 WHERE to_char(trdt,'yyyymmdd')  < :ls_reqdt
   AND COMPLETE_YN 					= 'N'
   AND payid 							= :ls_payid ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error 1(REQDTL)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	Return -1
End If

// 해당 청구년월의 미납액
SELECT sum(tramt + taxamt - payidamt) INTO :ld_curamt FROM reqdtl 
 WHERE to_char(trdt,'yyyymmdd') 	= :ls_reqdt
   AND COMPLETE_YN 					= 'N'
   AND payid 							= :ls_payid ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error 2(REQDTL)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	Return -1
End If

dw_cond.object.pre_balance[1] = ld_preamt
dw_cond.object.cur_balance[1] = ld_curamt

//해당 납입 고객의 청구기준일 구하기
ll_row = dw_cond.GetChild("trdt", ldc_trdt)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")


ldc_trdt.SetTransObject(SQLCA)
ll_row = ldc_trdt.Retrieve(ls_payid) 

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

Return 0

end event

event ue_reset;Int 		li_rc
String 	ls_paytype
String 	ls_ref_desc, 	ls_paymethod
F_INIT_DSP(1,"","")

dw_cond.Reset()
dw_cond.InsertRow(0)

dw_detail.object.write.text = String(0, '#,##0.00')
dw_detail.Object.t_3.Color 				= RGB(0, 0, 0)
dw_detail.Object.write.Color 				= RGB(0, 0, 0)	

dw_detail.Reset()
dw_detail2.Reset()
dw_split.Reset()

// Set the Top, Bottom Controls
idrg_Top 		= dw_detail
idrg_Bottom 	= dw_detail2

//Change the back color so they cannot be seen.
ii_WindowTop 				= idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor 			= BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

//****kEnn : 이부분이 필요하면 수정사항 반영할 것
//li_rc = This.TriggerEvent("ue_reset")
//****
//ls_paytype = " "

//dw_cond.object.trdt.Protect 	= 1
li_rc 								= wfi_get_paytype(ls_paytype)
dw_cond.object.paydt[1] 		= f_find_shop_closedt(GS_SHOPID)
//dw_cond.object.operator[1]		= gs_user_id

//PayMethod101, 102, 103, 104, 105, 107
String ls_temp, ls_method[], ls_trcod[]
ls_temp 			= fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_method[])

dw_cond.object.paymethod1[1] 	= ls_method[1]
dw_cond.object.paymethod2[1] 	= ls_method[2]
dw_cond.object.paymethod3[1] 	= ls_method[3]
dw_cond.object.paymethod4[1] 	= ls_method[4]
dw_cond.object.paymethod5[1] 	= ls_method[5]
dw_cond.object.paymethod6[1] 	= ls_method[6]
//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_trcod[])

dw_cond.object.trcode1[1] 	= ls_trcod[1]
dw_cond.object.trcode2[1] 	= ls_trcod[2]
dw_cond.object.trcode3[1] 	= ls_trcod[3]
dw_cond.object.trcode4[1] 	= ls_trcod[4]
dw_cond.object.trcode5[1] 	= ls_trcod[5]
dw_cond.object.trcode6[1] 	= ls_trcod[6]

p_ok.TriggerEvent("ue_enable")
dw_cond.Enabled = true
p_save.TriggerEvent("ue_disable")

is_refresh = 'Y'

Decimal ldc_null[]
String  ls_null[]

ii_method_cnt 	= 0
idc_amt[] 		= ldc_null[]
is_trcod[] 		= ls_null[]
is_method[]		= ls_null[]
idc_total 		= 0
idc_income_tot = 0
idc_impack 		= 0
cb_2.Enabled = FALSE
st_hotbill.visible = false

end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_cond.GetRow()

lb_check = fb_save_required(dw_cond, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);STRING	ls_payid,		ls_memberid,		ls_customerid,		ls_paydt,		ls_remark,		&
			ls_trcod,		ls_trdt,				ls_transdt,			ls_paydt_c,		ls_sysdate, 	ls_paydt_1	
DEC		ldc_receive,	ldc_total,			ldc_card_total
DATE		ldt_paydt,		ldt_shop_closedt
INTEGER  li_rc

IF dw_cond.AcceptText() < 1 THEN
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	ai_return = -1
	RETURN
END IF

IF dw_detail.AcceptText() < 1 THEN
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	ai_return = -1	
	RETURN
END IF

ls_payid 			= Trim(dw_cond.Object.payid[1])
ls_memberid 		= Trim(dw_cond.object.memberid[1])
ls_customerid 		= Trim(dw_cond.object.customerid[1])
ldc_receive 		= dw_cond.Object.total[1]
ldt_paydt 			= dw_cond.Object.paydt[1]
ls_paydt 			= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ls_remark			= dw_cond.Object.remark[1]
ldc_total 			= dw_cond.Object.total[1]
ldc_card_total 	= dw_cond.Object.amt2[1] + &
						  dw_cond.Object.amt3[1] + &
						  dw_cond.Object.amt4[1] + &
						  dw_cond.Object.amt5[1]
						
ls_trcod 			= dw_cond.object.trcod[1]
ls_trdt 				= String(dw_cond.object.trdt[1],    'yyyymmdd')
ls_transdt 			= String(dw_cond.object.transdt[1], 'yyyymmdd')

If IsNull(ls_memberid) 	Then ls_memberid 	= ""
If IsNull(ls_payid) 		Then ls_payid 		= ""
If IsNull(ls_paydt) 		Then ls_paydt 		= ""
If IsNull(ls_transdt) 	Then ls_transdt 	= ""


 
IF ii_bill_user > 0 THEN
   //권한자는 마이너스 수납가능
ELSE
	IF ldc_receive<= 0 THEN
		f_msg_usr_err(9000, Title, "[처리불능] ==> Data를 확인하세요.")
		dw_cond.SetFocus()
		ai_return = -1	
		RETURN
	END IF	
END IF

IF ldt_paydt <> ldt_shop_closedt THEN
	ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
	ls_paydt  = String(ldt_paydt, 'yyyymmdd')
		
	SELECT TO_CHAR(TO_DATE(TO_CHAR(:ldt_paydt, 'yyyymmdd'), 'YYYYMMDD') + 1, 'YYYYMMDD'),
			 TO_CHAR(SYSDATE, 'YYYYMMDD'),
			 REPLACE(:ls_paydt, '-', '') 
	INTO   :ls_paydt_1, :ls_sysdate, :ls_paydt_c
	FROM   DUAL;
		
	IF ls_paydt_c > ls_paydt_1 OR ls_paydt_c < ls_paydt THEN
		dw_cond.object.paydt[1]	= ldt_paydt
		f_msg_usr_err(9000, Title, "Shop 마감일과 Pay Date가 다릅니다. 확인 하세요.")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.SetColumn("paydt")
		ai_return = -1	
		RETURN
	END IF
END IF

IF IsNull(ls_payid) THEN ls_payid = ''

SELECT COUNT(*) INTO :li_rc
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF IsNull(li_rc) OR SQLCA.SQLCode <> 0 THEN li_rc = 0

IF li_rc = 0 THEN
	f_msg_usr_err(9000, Title, "PayID를 확인하세요.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	ai_return = -1	
	RETURN
END IF

IF ldc_total > 0 THEN
	IF ldc_card_total > ldc_total THEN
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetColumn("amt1")
		ai_return = -1			
		RETURN
	END IF
ELSE
	IF ldc_card_total < ldc_total THEN
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetColumn("amt1")
		ai_return = -1					
		Return
	END IF
END IF

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Pay ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	ai_return = -1						
	Return
End If

If ls_paydt = "" Then
	f_msg_usr_err(200, Title, "Payment Date")
	dw_cond.SetFocus()
	ai_return = -1						
	Return
End If

//If ii_method_cnt = 0 Then
//	f_msg_usr_err(200, Title, "Amount")
//	dw_cond.SetFocus()	
//	dw_cond.SetColumn("amt1")
//	ai_return = -1						
//	Return	
//End If

ai_return = 0
Return	
end event

event type integer ue_process();STRING 	ls_payid,		ls_paydt,			ls_trdt,				ls_trcod,			ls_transdt, 	&
			ls_pgm_id,		ls_remark,			ls_code,				ls_codenm,			ls_method0[],	&
			ls_trcod0[],	ls_appseq,			ls_saletrcod,		ls_customerid,		ls_req_trdt,	&
			ls_memberid,	ls_itemcod,			ls_method,			ls_regcod,			ls_errmsg
LONG		ll_seq,			ll_rtn,				ll_paycnt,			ll_return,			ll,				&
			ll_det_cnt
INTEGER 	li_rc,			li_rtn,				li_method_cnt, 	li_lp
DEC{2}  	ldc_amt0[], 	ldc_total, 			ldc_receive, 		ldc_change,		&
			ldc_cash, 		ldc_card_total,	ldc_10, 				ldc_90, 				ldc_100, 		&
			ldc_impact, 	ldc_card,			ldc_saleamt
DATE		ldt_paydt,		ldt_trdt,			ldt_saledt
DEC		ldc_tramt,		ldc_taxmt						
DOUBLE	lb_count,		lb_tramt
DEC{2}   ldc_impack
STRING	ls_operator

idt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)
ldt_paydt			= dw_cond.Object.paydt[1]
ls_remark			= dw_cond.Object.remark[1]
ldc_impack			= dw_cond.Object.amt5[1]
ls_operator			= dw_cond.Object.operator[1]

IF IsNull(ls_remark) then ls_remark = ''

// 카드입금액이 총판매액보다 크면...
ldc_total 		= 	dw_cond.Object.total[1]
ldc_card_total = 	dw_cond.Object.amt2[1] + &
						dw_cond.Object.amt3[1] + &
						dw_cond.Object.amt4[1] + &
						dw_cond.Object.amt5[1]
						
IF ldc_total > 0 then
	IF ldc_card_total > ldc_total then
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.SetColumn("amt1")
		Return -1 
	END IF
ELSE
	IF ldc_card_total < ldc_total then
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.SetColumn("amt1")
		Return -1 
	END IF
END IF

//2009.06.10 추가
IF ldc_impack <> 0 THEN
	ldc_90 = dw_cond.Object.credit[1]	
	ldc_card = dw_cond.Object.amt3[1]	
	ldc_10   = (ldc_card + ldc_impack) - ldc_90
	dw_cond.Object.amt5[1] = ldc_10
	dw_cond.Object.amt3[1] = ldc_card + ( ldc_impack - ldc_10 )
END IF
						
dw_cond.Accepttext()

//정렬순서 조정.
//IF ldc_total > 0 THEN
//	IF ldc_impack > 0 THEN
//		dw_detail2.SetSort('impack_check A, impack_card A, cp_amt A')
//	ELSEIF ldc_impack < 0 THEN
//		dw_detail2.SetSort('impack_check A, impack_card D, cp_amt A')
//	ELSE
//		dw_detail2.SetSort('sale_amt A')
//	END IF
//ELSE
//	IF ldc_impack < 0 THEN
//		dw_detail2.SetSort('impack_check A, impack_card D, cp_amt D')
//	ELSEIF ldc_impack > 0 THEN
//		dw_detail2.SetSort('impack_check A, impack_card A, cp_amt D')
//	ELSE
//		dw_detail2.SetSort('cp_amt D')
//	END IF		
//END IF

//dw_detail2.Sort()

li_method_cnt 	= 0
ldc_amt0[1] 	= dw_cond.object.amt3[1] 
ldc_amt0[2] 	= dw_cond.object.amt2[1] 
ldc_amt0[3] 	= dw_cond.object.amt4[1] 
ldc_amt0[4] 	= dw_cond.object.amt1[1]
ldc_amt0[5] 	= dw_cond.object.amt6[1]

ls_method0[1] 	= dw_cond.object.paymethod3[1]
ls_method0[2] 	= dw_cond.object.paymethod2[1]
ls_method0[3] 	= dw_cond.object.paymethod4[1]
ls_method0[4] 	= dw_cond.object.paymethod1[1]
ls_method0[5] 	= dw_cond.object.paymethod6[1]

ls_trcod0[1] 	= dw_cond.object.trcode3[1]
ls_trcod0[2] 	= dw_cond.object.trcode2[1]
ls_trcod0[3] 	= dw_cond.object.trcode4[1]
ls_trcod0[4] 	= dw_cond.object.trcode1[1]
ls_trcod0[5] 	= dw_cond.object.trcode6[1]

ii_method_cnt 	= 0 
idc_total 		= 0

ldc_total =  dw_cond.Object.total[1]
If IsNull(ldc_total) then ldc_total = 0
IF ldc_total  = 0 then 
	f_msg_usr_err(200, Title, "Total -- Zero")
	dw_cond.Setfocus()
	Return -1
END IF

if ii_bill_user > 0 THEN  //빌수납 권한자 이면 마이너스 수납가능
	FOR li_lp = 1 to 5
		IF ldc_amt0[li_lp] <> 0 then
			idc_total 						+= ldc_amt0[li_lp]
			ii_method_cnt 					+= 1
			idc_amt[ii_method_cnt] 		= ldc_amt0[li_lp]
			is_method[ii_method_cnt] 	= ls_method0[li_lp]
			is_trcod[ii_method_cnt] 	= ls_trcod0[li_lp]
		END IF
	NEXT
ELSE
	FOR li_lp = 1 to 5
		IF ldc_amt0[li_lp] > 0 then
			idc_total 						+= ldc_amt0[li_lp]
			ii_method_cnt 					+= 1
			idc_amt[ii_method_cnt] 		= ldc_amt0[li_lp]
			is_method[ii_method_cnt] 	= ls_method0[li_lp]
			is_trcod[ii_method_cnt] 	= ls_trcod0[li_lp]
		END IF
	NEXT
END IF

IF ii_method_cnt  = 0 then 
	f_msg_usr_err(200, Title, "Amount")
	dw_cond.SetColumn("amt1")
	Return -1
END IF

//add---end

//Int li_return
li_rc 			= -2  //필수 입력 항목 요구
ls_payid 		= Trim(dw_cond.object.payid[1])
ls_memberid 	= Trim(dw_cond.object.memberid[1])
ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_paydt 		= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_paydt 		= dw_cond.object.paydt[1]
ls_trcod 		= dw_cond.object.trcod[1]
ls_pgm_id 		= gs_pgm_id[gi_open_win_no]
ls_remark 		= dw_cond.object.remark[1]
ls_transdt 		= String(dw_cond.object.transdt[1], 'yyyymmdd')

If IsNull(ls_memberid) 	Then ls_memberid 	= ""
If IsNull(ls_payid) 		Then ls_payid 		= ""
If IsNull(ls_paydt) 		Then ls_paydt 		= ""
If IsNull(ls_transdt) 	Then ls_transdt 	= ""

//이체일자 입력 안하면 입금일과 동일.
IF ls_transdt = "" THEN			ls_transdt = ls_paydt

ldt_paydt 		= dw_cond.Object.paydt[1]
ldc_total 		= dw_cond.object.total[1]
ldc_receive 	= dw_cond.object.cp_receive[1]
ldc_change 		= dw_cond.object.cp_change[1]


F_INIT_DSP(3, String(ldc_receive), String(ldc_change))

//영수증 출력 무조건 하기 위해서
ll_rtn = 1

//해당 금액 나누기 처리
wf_split_new(ldt_paydt)

// 영수증 Approvalno 가져오기
SELECT SEQ_RECEIPT.NEXTVAL 
INTO :ls_appseq 
FROM DUAL;

// DAIRYPAYMENT, REQPAY 입력
FOR li_lp =  1 to dw_split.RowCount()
	ls_trcod 		= dw_split.Object.trcod[li_lp]
	ls_req_trdt		= dw_split.Object.req_trdt[li_lp]
	ls_saletrcod 	= dw_split.Object.sale_trcod[li_lp] 
	ldc_tramt 		= dw_split.Object.payamt[li_lp]
	ldc_taxmt 		= dw_split.Object.taxamt[li_lp]
//	lb_tramt 		= dw_split.Object.payamt[li_lp]	
	ls_itemcod 		= dw_split.Object.itemcod[li_lp]
	ls_method  		= dw_split.Object.paymethod[li_lp]
	ls_regcod  		= dw_split.Object.regcod[li_lp]
	ldc_saleamt 	= dw_split.Object.payamt[li_lp]
	ll_paycnt 		= dw_split.Object.paycnt[li_lp]
	ldt_saledt  	= date(dw_split.Object.paydt[li_lp])
	ldt_trdt  		= date(dw_split.Object.trdt[li_lp])	
	ls_trdt  = string(dw_split.Object.trdt[li_lp],'yyyymmdd')
	
	//수납 입력
	ls_errmsg = space(1000)
//	SQLCA.UBS_REG_DAILYPAYMENT(gs_shopid,		DATE(String(ls_paydt, '@@@@-@@-@@')),		ls_payid,			ls_itemcod,		&
//										ls_method,		STRING(ldc_saleamt), 							ls_remark, 			ls_appseq,		&
//										ls_operator,	'BILL',												ll_paycnt,		   ll_return,			ls_errmsg)
	SQLCA.REG_DAILYPAYMENT(gs_shopid,		DATE(String(ls_paydt, '@@@@-@@-@@')),		ls_payid,			ls_itemcod,		&
										ls_method,		STRING(ldc_saleamt), 	STRING(ldc_taxmt),		ls_remark, 	DATE(String(ls_trdt, '@@@@-@@-@@')),  0,		ls_appseq,		&
										ls_operator,	'BILL',												ll_paycnt,		   ll_return,			ls_errmsg)
											
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
		RETURN -1
	END IF										
	
	//수동 입금 반영 Insert
	ls_errmsg = space(1000)
	SQLCA.UBS_REG_REQPAY(ls_payid,											is_paycod,		ls_saletrcod,		DATE(String(ls_paydt, '@@@@-@@-@@')),		&
								DATE(String(ls_req_trdt, '@@@@-@@-@@')),	ls_remark, 		ldc_tramt + ldc_taxmt,			DATE(String(ls_transdt, '@@@@-@@-@@')),	&
								ls_trcod,											ls_appseq,		gs_user_id,			ls_pgm_id,											&
								ll_return,											ls_errmsg)
								
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
		RETURN -1
	END IF																		

NEXT



// 원래 아래 부분은 영수증 출력 이후에 있었는데, 수납반영이 실패하
//처리부분...수동 입금 반영
ls_errmsg = space(1000)
lb_count  = 0 
ll_return = 0
SQLCA.B5REQPAY2DTL_PAYID(ls_payid, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count) 

IF SQLCA.SQLCode < 0 THEN		//For Programer
	MessageBox(THIS.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	RETURN  -1
ELSEIF ll_return < 0 THEN	//For User
	MessageBox(THIS.Title, ls_errmsg, StopSign!)
	RETURN -1
END IF

//dailiypayment 부가세 보정 start
integer li_ret
li_ret = f_vat_diff_update('BILL', ls_payid, 'APPROV', ls_appseq)
if li_ret < 0 then
	messagebox("부가세보정","부가세를 보정하지 못했습니다.");
end if
//dailiypayment 부가세 보정 end

//영수증 처리를 위한 object 선언
//ls_paydt			= String(dw_hlp.Object.paydt[1], '@@@@@@@@')
//ld_paydt			= dw_hlp.Object.paydt[1]
//ls_customerid	= dw_hlp.Object.customerid[1]
//ls_memberid		= dw_hlp.Object.memberid[1]

ubs_dbmgr_receiptmst	lu_dbmgr
lu_dbmgr = CREATE ubs_dbmgr_receiptmst

lu_dbmgr.is_caller   = "b5w_reg_mtr_inp_sams%direct"
lu_dbmgr.is_title	   = Title
lu_dbmgr.is_data[1]  = ls_customerid
lu_dbmgr.is_data[2]  = ls_paydt
lu_dbmgr.is_data[3]  = gs_shopid
lu_dbmgr.is_data[4]  = ls_operator
lu_dbmgr.is_data[5]  = 'Y'
lu_dbmgr.is_data[6]  = ls_memberid
lu_dbmgr.is_data[7]  = ls_pgm_id
lu_dbmgr.is_data[8]  = ls_appseq
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_split
lu_dbmgr.idw_data[3] = dw_detail2

lu_dbmgr.uf_prc_db_01()

li_rc		 = lu_dbmgr.ii_rc
//ls_appseq = lu_dbmgr.is_appseq

IF li_rc < 0 THEN
	DESTROY lu_dbmgr
	dw_cond.SetColumn("amt1")
	RETURN -1
END IF

p_save.TriggerEvent("ue_disable")
dw_cond.Enabled = False

DESTROY lu_dbmgr

dw_split.Reset()

Return 0

end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)




end subroutine

public function integer wf_set_impack (string as_data);LONG		ll_row1
INT		ii
DEC{2}	ldc_impack2,	ldc_impack3,	ldc_total,		ldc_impack,		ldc_impack_10,		ldc_receive,	ldc_card
DEC      ldc_impack1
  
dw_detail2.AcceptText()

ll_row1 = dw_detail2.RowCount()

ldc_impack = dw_cond.Object.amt5[1]
ldc_card   = dw_cond.Object.amt3[1]
//ldc_impack = DEC(as_data)										//카드 입력한 금액
ldc_impack_10 = ROUND(ldc_impack * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impack = 0 THEN
	RETURN -1
END IF

idc_impack = 0

FOR ii = 1 TO ll_row1
	ldc_impack1 = dw_detail2.Object.impack_card[ii]	
	IF IsNull(ldc_impack1) THEN ldc_impack1 = 0
	idc_impack  = idc_impack + ldc_impack1	
NEXT

IF idc_impack >= 0 THEN
	IF idc_impack < ldc_impack_10 THEN
		IF ldc_impack_10 - idc_impack > 0.02 THEN
			MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
			RETURN -1
		ELSE
			ldc_impack_10 = idc_impack
		END IF			
	END IF
ELSE
	IF idc_impack > ldc_impack_10 THEN
		IF idc_impack - ldc_impack_10 > 0.02 THEN
			MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 작습니다.")
			RETURN -1
		ELSE
			ldc_impack_10 = idc_impack
		END IF			
	END IF	
END IF

//ldc_total   = dw_cond.Object.total[1]
//ldc_receive = dw_cond.Object.cp_receive[1]

//dw_cond.Object.credit[1]	= ldc_total - ldc_impack_10
IF idc_impack <> 0 THEN
	dw_cond.Object.credit[1]	= ( ldc_card + ldc_impack ) - ldc_impack_10
ELSE
	dw_cond.Object.credit[1]	= 0
END IF

RETURN 0
end function

public subroutine wf_set_total ();dec{2} ldc_TOTAL

ldc_total = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total = dw_detail.GetItemNumber(dw_detail.RowCount(), "all_sum") 
END IF

dw_cond.Object.total[1] 		= ldc_total

F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

public function integer wf_split (date wfdt_paydt);Long		ll, 				ll_cnt,			ll_row
Integer 	li_pay_cnt, 	li_pp,			li_first,		li_paycnt, 	li_chk
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 		ldc_income,	ldc_receive, &
			ldc_total,		ldc_rem_prc, &
			ldc_receive_org,	ldc_total_prc
String 	ls_method,		ls_basecod, 	ls_customerid, ls_payid, 	ls_trcod, &
			ls_saletrcod, 	ls_req_trdt, 	ls_remark

li_pay_cnt 	= 1

dw_cond.AcceptText()
dw_detail2.SetSort("Priority A")
dw_detail2.Sort()

ls_remark						= dw_cond.object.remark[1]
IF ISNull(ls_remark) 		then 		ls_remark = ''

ldc_receive 	= dw_cond.object.cp_receive[1]
ldc_total 		= dw_cond.object.total[1]
ls_customerid 	= dw_cond.Object.customerid[1]
ls_payid 		= dw_cond.Object.customerid[1]
ldc_receive_org = ldc_receive

//입금처리방식 변경 --2007.01.23
//입금할 금액보다 과입금하는 경우 즉 Change 금액이 발생하는 경우
//입금할 금액 만큼만 처리하고 나머지는 처리하지 않는다.
//EX>50,10,20,10,10,-10,-10 일때 100을 입금한 경우 
//   80만큼만 처리하고 나머지는 나둔다.즉 50, 10, 20까지만 처리
//
//입금처리방식 변경 -- 2007.01.26
// 마이너스금액을 선 처리한다. 우선순위보다...
//
ldc_total_prc	 = 0
//customerm Search
select basecod INTO :ls_basecod from customerm  where customerid =  :ls_customerid ;

ll_cnt 				= dw_detail2.RowCount()
idc_income_tot 	= 0 // 전액을 입금하지 않을 경우에 대비 각 입금반영시 Add처리

FOR ll = 1 to ll_cnt
	ldc_tramt	= dw_detail2.object.cp_amt[ll]

	// 각 아이템의 입금완불이 안된 경우만 처리
	IF dw_detail2.object.COMPLETE_YN[ll] = 'N'  AND ldc_tramt <> 0 THEN
		ldc_income 		= 0
		li_first 		= 0
		li_chk 			= 0
		ls_req_trdt 	= dw_detail2.object.trdt[ll]
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		FOR li_pp =  li_pay_cnt to ii_method_cnt
			ls_method 	= is_method[li_pp]
			ls_trcod 	= is_trcod[li_pp]
			ldc_rem 		= idc_amt[li_pp]
			
			IF ldc_rem >= ldc_tramt THEN
				ldc_saleamt 	= ldc_tramt
				IF li_first =  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else 
					li_paycnt 	= 0
				END IF
				ldc_rem 			= ldc_rem - ldc_saleamt
				ldc_tramt 		= 0
			ELSE
				ldc_saleamt 	= ldc_rem
				ldc_tramt 		= ldc_tramt - ldc_rem
				ldc_rem 			= 0
				IF li_first =  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else
					li_paycnt 	= 0
				END IF
				li_pay_cnt		+= 1
			END IF
			ldc_income 		+= ldc_saleamt
	
			ll_row =  dw_split.InsertRow(0)
			//---------------------------------------
			dw_split.Object.paydt[ll_row] 		= wfdt_paydt
			dw_split.Object.shopid[ll_row] 		= gs_shopid
			dw_split.Object.operator[ll_row] 	= gs_user_id
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
			dw_split.Object.paymethod[ll_row] 	= ls_method
			dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
			dw_split.Object.payamt[ll_row] 		= ldc_saleamt
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
			dw_split.Object.dctype[ll_row] 		= 'D'
			dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
			dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]
			
			ldc_receive 								= ldc_receive - ldc_saleamt
			idc_income_tot 							+= ldc_saleamt
			ldc_total_prc 								+= ldc_saleamt
			
			IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
					li_chk = 1
					exit
			END IF
			IF li_pay_cnt > ii_method_cnt then exit
		NEXT
	
		IF ldc_rem > 0 THEN		idc_amt[li_pay_cnt] = ldc_rem
		
		IF li_chk =  1 then
			dw_detail2.object.chk[ll] 		= '1'
			dw_detail2.object.income[ll] 	= ldc_income
		else
			dw_detail2.object.chk[ll] 		= '2'
			dw_detail2.object.income[ll] 	= ldc_income
		end if
	END IF
	IF ldc_receive <= 0 then EXIT
NEXT

dw_cond.Object.total[1] =  idc_income_tot
dw_split.AcceptText()

return 0


//Long		ll, 				ll_cnt,			ll_row
//Integer 	li_pay_cnt, 	li_pp,			li_first,		li_paycnt, 	li_chk
//DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 		ldc_income,	ldc_receive, &
//			ldc_total,		ldc_total_prc
//String 	ls_method,		ls_basecod, 	ls_customerid, ls_payid, 	ls_trcod, &
//			ls_saletrcod, 	ls_req_trdt, 	ls_remark
//
//li_pay_cnt 	= 1
//
//dw_cond.AcceptText()
//dw_detail2.SetSort("Priority A")
//dw_detail2.Sort()
//
//ls_remark						= dw_cond.object.remark[1]
//IF ISNull(ls_remark) 		then 		ls_remark = ''
//
//ldc_receive 	= dw_cond.object.cp_receive[1]
//ldc_total 		= dw_cond.object.total[1]
//ldc_total_prc 	= 0 //입금할 금액만큼만 처리하기 위한....
//ls_customerid 	= dw_cond.Object.customerid[1]
//ls_payid 		= dw_cond.Object.customerid[1]
//
////입금처리방식 변경 --2007.01.23
////입금할 금액보다 과입금하는 경우 즉 Change 금액이 발생하는 경우
////입금할 금액 만큼만 처리하고 나머지는 처리하지 않는다.
////EX>50,10,20,10,10,-10,-10 일때 100을 입금한 경우 
////   80만큼만 처리하고 나머지는 나둔다.즉 50, 10, 20까지만 처리
//
//
//
////customerm Search
//select basecod INTO :ls_basecod from customerm  where customerid =  :ls_customerid ;
//
//ll_cnt 				= dw_detail2.RowCount()
//idc_income_tot 	= 0 // 전액을 입금하지 않을 경우에 대비 각 입금반영시 Add처리
//
//FOR ll = 1 to ll_cnt
//	ldc_tramt	= dw_detail2.object.cp_amt[ll]
//	// 각 아이템의 입금완불이 안된 경우만 처리
//	IF dw_detail2.object.COMPLETE_YN[ll] = 'N'  THEN
//	
//		ldc_income 		= 0
//		ls_req_trdt 	= dw_detail2.object.trdt[ll]
//		li_first 		= 0
//		li_chk 			= 0
//		//-------------------------------------------------------------------------
//		//입금내역 처리  Start........ 
//		//-------------------------------------------------------------------------
//		FOR li_pp =  li_pay_cnt to ii_method_cnt
//			ls_method 	= is_method[li_pp]
//			ls_trcod 	= is_trcod[li_pp]
//			ldc_rem 		= idc_amt[li_pp]
//		
//			IF ldc_rem >= ldc_tramt THEN
//				ldc_saleamt 	= ldc_tramt
//				ldc_income 		+= ldc_saleamt
//				IF li_first =  0 then
//					li_paycnt 	= 1
//					li_first 	= 1
//				else 
//					li_paycnt 	= 0
//				END IF
//				ldc_rem 			= ldc_rem - ldc_saleamt
//				ldc_tramt 		= 0
//				ldc_total_prc += ldc_saleamt
//			ELSE
//				ldc_saleamt 	= ldc_rem
//				ldc_income 		+= ldc_saleamt
//				ldc_tramt 		= ldc_tramt - ldc_rem
//				ldc_rem 			= 0
//				IF li_first =  0 then
//					li_paycnt 	= 1
//					li_first 	= 1
//				else
//					li_paycnt 	= 0
//				END IF
//				li_pay_cnt		+= 1
//				ldc_total_prc += ldc_saleamt
//			END IF
//	
//			ll_row =  dw_split.InsertRow(0)
//			//---------------------------------------
//			dw_split.Object.paydt[ll_row] 		= wfdt_paydt
//			dw_split.Object.shopid[ll_row] 		= gs_shopid
//			dw_split.Object.operator[ll_row] 	= gs_user_id
//			dw_split.Object.customerid[ll_row] 	= ls_customerid
//			dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
//			dw_split.Object.paymethod[ll_row] 	= ls_method
//			dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
//			dw_split.Object.payamt[ll_row] 		= ldc_saleamt
//			dw_split.Object.basecod[ll_row] 		= ls_basecod
//			dw_split.Object.paycnt[ll_row] 		= li_paycnt
//			dw_split.Object.payid[ll_row] 		= ls_payid
//			dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
//			dw_split.Object.dctype[ll_row] 		= 'D'
//			dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
//			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
//			dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]
//			
//			idc_total 									= idc_total - ldc_saleamt
//			idc_income_tot 							+= ldc_saleamt
//			
//			IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
//					li_chk = 1
//					exit
//			END IF
//			IF li_pay_cnt > ii_method_cnt then exit
//		NEXT
//	
//		IF ldc_rem > 0 THEN		idc_amt[li_pay_cnt] = ldc_rem
//		
//		IF li_chk =  1 then
//			dw_detail2.object.chk[ll] 		= '1'
//			dw_detail2.object.income[ll] 	= ldc_income
//		else
//			dw_detail2.object.chk[ll] 		= '2'
//			dw_detail2.object.income[ll] 	= ldc_income
//		end if
//	END IF
//	IF idc_total <= 0 then EXIT
//NEXT
//
//dw_cond.Object.total[1] =  idc_income_tot
//
//dw_split.AcceptText()
//
//return 0
end function

public function long wfi_call_proc ();String ls_errmsg, ls_pgm_id, ls_paytype, ls_payid
double lb_count , lb_seqno
Long   ll_return

dw_detail.AcceptText()
ls_errmsg 	= space(256)
ls_pgm_id 	= gs_pgm_id[gi_open_win_no]
ls_paytype 	= dw_cond.object.paycod[1]
ls_payid 	= trim(dw_cond.object.payid[1])
ll_return 	= -1

//처리부분...수동 입금 반영
//SQLCA.B5REQPAY2DTL(is_paycod, ib_seq, gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 
//SQLCA.B5REQPAY2DTL(is_paycod, gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 

//2007-7-27 Argument 변경 ==>  is_paytype 삭제 ...request : 장희찬&오지연 
//SQLCA.B5REQPAY2DTL(gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 
//2007-7-30 변경 
SQLCA.B5REQPAY2DTL_PAYID(ls_payid, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count) 

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return  -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	Return -1
Else				//성공
	Return 0
End If

Return 0

end function

public function integer wfi_get_payid (string as_payid, string as_memberid);String ls_payid, ls_paynm, ls_memberid

ls_payid 		= as_payid

IF ls_payID <> '' THEN
	Select Customernm, memberid  Into :ls_paynm, :ls_memberid  From Customerm
    Where customerid = :ls_payid;
ELSE
	Select CUSTOMERID, Customernm  Into :ls_payid, :ls_paynm  From Customerm
    Where MEMBERID = :as_memberid;
END IF

IF IsNull(ls_paynm) 		then ls_paynm 		= ''
IF IsNull(ls_payid) 		then ls_payid 		= ''
IF IsNull(ls_memberid) 	then ls_memberid 	= ''

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay ID(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return -1
End If

dw_cond.object.marknm[1] 			= ls_paynm
dw_cond.object.payid[1] 			= ls_payid
dw_cond.object.customerid[1] 		= ls_payid
dw_cond.object.memberid[1] 		= ls_memberid

Return 0

end function

public function integer wfi_get_paytype (string as_paytype);String ls_paycod, ls_paytype

SELECT substr(ref_content, 1, Instr(ref_content, ';') -1) 
INTO :is_paycod
FROM sysctl1t 
WHERE module = 'B5' 
AND ref_no = 'I101';

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Payment Method(wfi_get_paycode)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "입금유형이 없습니다.(B5:I101)")
	Return -1
End If

dw_cond.object.paycod[1] = is_paycod

Return 0 
end function

public function integer wf_split_new (date wfdt_paydt);Long		ll, 				ll_cnt,			ll_row
Integer 	li_pay_cnt, 	li_pp,			li_first,		li_paycnt, 	li_chk,	li_update
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 		ldc_income,	ldc_receive, &
			ldc_total,		ldc_rem_prc, &
			ldc_receive_org,	ldc_total_prc
String 	ls_method,		ls_basecod, 	ls_customerid, ls_payid, 	ls_trcod, &
			ls_saletrcod, 	ls_req_trdt, 	ls_remark,		ls_operator,		&
			ls_trcod_im,   ls_method0_im, ls_add, ls_end, ls_trcod_det, ls_itemcod
DEC{2}	ldc_impack,		ldc_amt0_im,	ldc_payamt, ldc_imnot, ldc_im, ldc_impack_in, ldc_vat, ldc_taxamt, ld_tax_rate
			
DATE		ldt_paydt

dec{3}   ldc_sale_dec, ldc_tax_dec
DEC{2}   ldc_taxrow_tot, ldc_tax_tot, ldc_vat_tot
integer li_tax_dec

li_pay_cnt 	= 1

dw_cond.AcceptText()

ls_remark 	= dw_cond.object.remark[1]
ls_operator = dw_cond.object.operator[1]
ldt_paydt	= dw_cond.object.paydt[1]
ldc_impack 	= dw_cond.object.amt5[1] 

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= dw_cond.object.trcode5[1]
	ls_method0_im	= dw_cond.object.paymethod5[1]	
	ldc_amt0_im		= dw_cond.object.amt5[1]			
END IF

IF ISNull(ls_remark)	then ls_remark = ''

ldc_receive 	= dw_cond.object.cp_receive[1]
ldc_total 		= dw_cond.object.total[1]
ls_customerid 	= dw_cond.Object.customerid[1]
ls_payid 		= dw_cond.Object.customerid[1]
ldc_receive_org = ldc_receive

IF ldc_total > 0 THEN
	dw_detail2.SetSort('priority A')
ELSE
	dw_detail2.SetSort('priority D')	
END IF

dw_detail2.Sort()

//입금처리방식 변경 --2007.01.23
//입금할 금액보다 과입금하는 경우 즉 Change 금액이 발생하는 경우
//입금할 금액 만큼만 처리하고 나머지는 처리하지 않는다.
//EX>50,10,20,10,10,-10,-10 일때 100을 입금한 경우 
//   80만큼만 처리하고 나머지는 나둔다.즉 50, 10, 20까지만 처리
//
//입금처리방식 변경 -- 2007.01.26
// 마이너스금액을 선 처리한다. 우선순위보다...
//
ldc_total_prc	 = 0
//customerm Search
select basecod INTO :ls_basecod from customerm  where customerid =  :ls_customerid ;

ll_cnt 				= dw_detail2.RowCount()
idc_income_tot 	= 0 // 전액을 입금하지 않을 경우에 대비 각 입금반영시 Add처리

ls_add = 'N'
ls_end = 'N'
ldc_vat_tot = 0
ldc_vat = 0

IF ll_cnt > 0 and ldc_total = 0 then
	//total = 0 인 경우 즉, (+, -) 값에 의해 항목들이 있으나 총계는 0인 경우 cash로 저장
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_detail2.object.cp_amt[ll]  //tramt + taxamt - payidamt
		ldc_vat		= dw_detail2.object.bil_taxamt[ll]
		ls_trcod_det	= dw_detail2.Object.trcod[ll]
		ls_itemcod = dw_detail2.Object.itemcod[ll]
		
		//---------------------------------------
		ll_row =  dw_split.InsertRow(0)
		//---------------------------------------
		dw_split.Object.paydt[ll_row] 		= ldt_paydt
		dw_split.Object.shopid[ll_row] 		= gs_shopid
		dw_split.Object.operator[ll_row] 	= ls_operator
		dw_split.Object.customerid[ll_row] 	= ls_customerid
		dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
		dw_split.Object.paymethod[ll_row] 	= '101'
		dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
		dw_split.Object.payamt[ll_row] 		= ldc_payamt - ldc_vat
		dw_split.Object.taxamt[ll_row] 		= ldc_vat
		dw_split.Object.basecod[ll_row] 		= ls_basecod
		dw_split.Object.paycnt[ll_row] 		= 1
		dw_split.Object.payid[ll_row] 		= ls_payid
		dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
		dw_split.Object.dctype[ll_row] 		= 'D'
		dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
		dw_split.Object.sale_trcod[ll_row] 	= ls_trcod_det
		dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]		
		
	NEXT
ELSE
	
	FOR ll = 1 to ll_cnt
		ls_itemcod = dw_detail2.Object.itemcod[ll]
		ldc_tramt	= dw_detail2.object.cp_amt[ll]   //tramt + taxamt - payidamt
		ldc_vat		= dw_detail2.object.bil_taxamt[ll]
		li_update 		= 0	
		// 각 아이템의 입금완불이 안된 경우만 처리
		IF dw_detail2.object.COMPLETE_YN[ll] = 'N'  AND ldc_tramt <> 0 THEN
			ldc_income 		= 0
			li_first 		= 0
			li_chk 			= 0
			ls_req_trdt 	= dw_detail2.object.trdt[ll]
			
			if ldc_vat <> 0 then
				ldc_vat_tot += ldc_vat//부가세 총합
			end if			
			//payid별 , 기간별, 아이템별 , 요율 가져온다. ex) 5월부터 부가세 적용이라, 5월 이전자료에는 부가세 0이 되어야 함..
			SELECT FNC_GET_TAXRATE(:ls_customerid, 'I', :ls_itemcod, to_date(:ls_req_trdt))  into  :ld_tax_rate from dual;
			if ld_tax_rate <> 0 then  
				//합계액으로 공급가액과 부가세를 나눠주는 공식임.
				ld_tax_rate = (100 / 100) + ( ld_tax_rate / 100)  //1.1
			else 
				// 0으로 나눠주면 에러남
				ld_tax_rate = 1	
			end if

			//-------------------------------------------------------------------------
			//입금내역 처리  Start........
			//-------------------------------------------------------------------------
			IF ls_end = 'N' THEN			
				FOR li_pp =  li_pay_cnt to ii_method_cnt
					ls_method 	= is_method[li_pp]
					ls_trcod 	= is_trcod[li_pp]
					ldc_rem 		= idc_amt[li_pp]
					
					IF li_first 	= 0  then
						li_paycnt 	= 1
						li_first 	= 1
					else
						li_paycnt 	= 0
					END IF
					
					IF ldc_rem > 0 THEN
						IF ldc_rem - ldc_tramt <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
//							ldc_saleamt  = round(ldc_rem /ld_tax_rate, 2)			//공급가액을 넣는다.
//							ldc_taxamt    = ldc_rem -  round(ldc_rem /ld_tax_rate, 2)	//부가세
//							ldc_tramt = ldc_tramt - ldc_rem	//loop 를 돌리기 위해서
							ldc_tax_dec = ldc_rem - ( ldc_rem/ld_tax_rate)
							li_tax_dec = integer(left(right(string(ldc_tax_dec),2),1))
							ldc_taxamt = truncate(round(ldc_tax_dec,3),2)	
//							if li_tax_dec > 5 then
//								ldc_taxamt =round(ldc_tax_dec,2) 
//							else
//								ldc_taxamt = truncate(round(ldc_tax_dec,3),2)												
//							end if
							ldc_taxrow_tot += ldc_taxamt
							ldc_saleamt = ldc_rem - ldc_taxamt
							ldc_tramt = ldc_tramt  - ldc_rem	//loop 를 돌리기 위해서
							IF li_pay_cnt = ii_method_cnt THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
								IF ldc_tramt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF	
							ldc_rem		 = 0								//수납금액을 0으로
							li_pay_cnt	+= 1		
						ELSE													//수납유형에 돈이 남아있으면...다음 아이템으로						
//							ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = round(ldc_tramt / ld_tax_rate,2) 				//품목금액을 넣는다.
//							ldc_taxamt 	 = ldc_tramt - ldc_saleamt    //부가세
//							ldc_tramt = 0								//loop 를 빼기 위해서!		
							ldc_rem		 = ldc_rem - (ldc_tramt)	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_tax_dec = ldc_tramt - ( ldc_tramt/ld_tax_rate)
							li_tax_dec =integer(left(right(string(ldc_tax_dec),2),1))
							ldc_taxamt = truncate(round(ldc_tax_dec,3),2)
//							if li_tax_dec > 5 then
//								ldc_taxamt =round(ldc_tax_dec,2) 
//							else
//								ldc_taxamt = truncate(round(ldc_tax_dec,3),2)												
//							end if
							ldc_taxrow_tot += ldc_taxamt
							ldc_saleamt = ldc_tramt - ldc_taxamt
							ldc_tramt = 0								//loop 를 빼기 위해서!	
						END IF
					ELSEIF ldc_rem < 0 THEN								//수납유형에 - 금액이면
						IF ldc_rem - ldc_tramt >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
//							ldc_saleamt	 = round(ldc_rem /ld_tax_rate, 2)	//품목금액을 넣는다.(공급가액)
//							ldc_taxamt    = ldc_rem -  round(ldc_rem /ld_tax_rate, 2)	//부가세
//							
//							ldc_tramt = ldc_tramt - ldc_rem	//loop 를 돌리기 위해서
							ldc_tax_dec = ldc_rem - ( ldc_rem/ld_tax_rate)
							li_tax_dec =integer(left(right(string(ldc_tax_dec),2),1))
							ldc_taxamt = truncate(round(ldc_tax_dec,3),2)
//							if li_tax_dec > 5 then
//								ldc_taxamt =round(ldc_tax_dec,2) 
//							else
//								ldc_taxamt = truncate(round(ldc_tax_dec,3),2)												
//							end if
							ldc_taxrow_tot += ldc_taxamt
							ldc_saleamt = ldc_rem - ldc_taxamt
							
							ldc_tramt = ldc_tramt - ldc_rem	//loop 를 돌리기 위해서
							IF li_pay_cnt = ii_method_cnt THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
								IF ldc_tramt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF
							ldc_rem		 = 0								//수납유형에 있는 금액에서 아이템 금액을 빼준다.													
							li_pay_cnt	+= 1												
						ELSE
//							ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = round(ldc_tramt / ld_tax_rate,2)			//품목금액을 넣는다.
//							ldc_taxamt 	 = ldc_tramt - ldc_saleamt    //부가세
//							ldc_tramt = 0								//loop 를 빼기 위해서!	
							ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_tax_dec = ldc_tramt - ( ldc_tramt/ld_tax_rate)
							li_tax_dec =integer(left(right(string(ldc_tax_dec),2),1))
							ldc_taxamt = truncate(round(ldc_tax_dec,3),2)	
//							if li_tax_dec > 5 then
//								ldc_taxamt =round(ldc_tax_dec,2) 
//							else
//								ldc_taxamt = truncate(round(ldc_tax_dec,3),2)												
//							end if
							ldc_taxrow_tot += ldc_taxamt
							ldc_saleamt = ldc_tramt - ldc_taxamt
							ldc_tramt = 0								//loop 를 빼기 위해서!
						END IF						
					ELSE														//아이템은 있는데 수납이 다 까졌을 때...
//						ldc_saleamt  = ldc_tramt	 - ldc_vat				//품목금액을 넣는다.
//						ldc_taxamt 	 =  ldc_vat    //부가세
						ldc_tax_dec = ldc_tramt - ( ldc_tramt /ld_tax_rate)
						li_tax_dec =integer(left(right(string(ldc_tax_dec),2),1))
						ldc_taxamt = truncate(round(ldc_tax_dec,3),2)		
//						if li_tax_dec > 5 then
//							ldc_taxamt =round(ldc_tax_dec,2) 
//						else
//							ldc_taxamt = truncate(round(ldc_tax_dec,3),2)												
//						end if
						ldc_taxrow_tot += ldc_taxamt
						ldc_saleamt = ldc_tramt - ldc_taxamt
						ldc_tramt = 0									//loop 를 빼기 위해서!
						ls_method = '101'								//cash
					END IF					
					ldc_income 		+= ldc_saleamt + ldc_taxamt
					
					//vat 총 합계 보정
//                                 	if  ls_end = 'Y' and ldc_tramt = 0 then //마지막반영이면						
//						 if ldc_vat_tot  - ldc_taxrow_tot <> 0 then
////							  if ldc_vat_tot  - ldc_taxrow_tot > 0 then 
////								ldc_taxamt -= ldc_vat_tot - ldc_taxrow_tot
////								ldc_saleamt += ldc_vat_tot - ldc_taxrow_tot
////							  else
////								ldc_taxamt += ldc_vat_tot - ldc_taxrow_tot
////								ldc_saleamt -= ldc_vat_tot - ldc_taxrow_tot
////							  end if
//							if ldc_vat_tot > ldc_taxrow_tot then
//								ldc_taxamt += abs(ldc_vat_tot - ldc_taxrow_tot)
//								ldc_saleamt -= abs(ldc_vat_tot - ldc_taxrow_tot)
//							else
//								ldc_taxamt -= abs(ldc_vat_tot - ldc_taxrow_tot)
//								ldc_saleamt += abs(ldc_vat_tot - ldc_taxrow_tot)
//							end if
//						 end if
//					end if
					//vat 총 합계 보정
			
					ll_row =  dw_split.InsertRow(0)
					//---------------------------------------
					dw_split.Object.paydt[ll_row] 		= ldt_paydt
					dw_split.Object.shopid[ll_row] 		= gs_shopid
					dw_split.Object.operator[ll_row] 	= ls_operator
					dw_split.Object.customerid[ll_row] 	= ls_customerid
					dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
					dw_split.Object.paymethod[ll_row] 	= ls_method
					dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
					dw_split.Object.payamt[ll_row] 		= ldc_saleamt
					dw_split.Object.taxamt[ll_row] 		= ldc_taxamt  //부가세
					dw_split.Object.basecod[ll_row] 		= ls_basecod
					dw_split.Object.paycnt[ll_row] 		= li_paycnt
					dw_split.Object.payid[ll_row] 		= ls_payid
					dw_split.Object.trdt[ll_row] 			= date(left(ls_req_trdt,4) +'/'+ mid(ls_req_trdt,5,2)+ '/' +right(ls_req_trdt,2))//idt_shop_closedt
					dw_split.Object.dctype[ll_row] 		= 'D'
					dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
					dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
					dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]
					
					IF ls_add = 'Y' THEN
//						ls_method = '101'
//						
//						ll_row =  dw_split.InsertRow(0)
//						//---------------------------------------
//						dw_split.Object.paydt[ll_row] 		= ldt_paydt
//						dw_split.Object.shopid[ll_row] 		= gs_shopid
//						dw_split.Object.operator[ll_row] 	= ls_operator
//						dw_split.Object.customerid[ll_row] 	= ls_customerid						
//						dw_split.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
//						dw_split.Object.paymethod[ll_row] 	= ls_method
//						dw_split.Object.regcod[ll_row] 		= dw_detail2.Object.regcod[ll]
//						dw_split.Object.payamt[ll_row] 		= ldc_saleamt
//						dw_split.Object.basecod[ll_row] 		= ls_basecod
//						dw_split.Object.paycnt[ll_row] 		= li_paycnt
//						dw_split.Object.payid[ll_row] 		= ls_payid
//						dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
//						dw_split.Object.dctype[ll_row] 		= 'D'
//						dw_split.Object.trcod[ll_row] 		= dw_detail2.Object.trcod[ll]
//						dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
//						dw_split.Object.req_trdt[ll_row] 	= dw_detail2.object.trdt[ll]
					END IF					
					
					ldc_receive 	 = ldc_receive - ldc_saleamt + ldc_taxamt
					idc_income_tot += ldc_saleamt + ldc_taxamt
					ldc_total_prc 	+= ldc_saleamt + ldc_taxamt
					
					idc_amt[li_pp]	= ldc_rem										
					IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
						li_chk = 1
						exit
					END IF					
					
					IF li_pay_cnt > ii_method_cnt then exit
				NEXT
					
				IF li_chk =  1 then
					dw_detail2.object.chk[ll] 		= '1'
					dw_detail2.object.income[ll] 	= ldc_income
				else
					dw_detail2.object.chk[ll] 		= '2'
					dw_detail2.object.income[ll] 	= ldc_income
				end if
			END IF
		END IF
		IF ldc_receive <= 0 then EXIT
		//IF ldc_receive = 0 then EXIT
	NEXT
END IF

dw_cond.Object.total[1] =  idc_income_tot
dw_split.AcceptText()

return 0


end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y);
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness);

of_RefreshBars();
end subroutine

event open;call super::open;Int 		li_rc
String 	ls_paytype,ls_msg
String 	ls_ref_desc, 	ls_paymethod, ls_payid

//m_mdi_main.m_start.TriggerEvent(Clicked!)
ls_payid  = gs_payid 
//ls_payid =  Message.StringParm	// payid 가져옴(b1w_reg_customer_d_v20_sams2 윈도우)
//messagebox("ls_msg", '/' + ls_payid + '/')
//if isnull(ls_payid) or trim(ls_payid) = '' then
//	
//else
//	gi_open_win_no ++ // service info 화면에서 넘어왔으면 변수 +1 증가
//end if
//messagebox("ls_msg", '/' + gs_payid + '/')




F_INIT_DSP(1,"","")
idt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)

//messagebox("this.title", '/' + this.title + '/')
// Set the Top, Bottom Controls
idrg_Top 		= dw_detail
idrg_Bottom 	= dw_detail2

//Change the back color so they cannot be seen.
ii_WindowTop 				= idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor 			= BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

//dw_cond.object.trdt.Protect 	= 1
li_rc 								= wfi_get_paytype(ls_paytype)
dw_cond.object.paydt[1] 		= f_find_shop_closedt(GS_SHOPID)


//dw_cond.object.payid[1] 		= ls_payid // b1w_reg_customer_v20_sams2에서 가져온 아규먼트
dw_cond.object.payid[1] 		= gs_payid // b1w_reg_customer_v20_sams2에서 가져온 아규먼트


//PayMethod101, 102, 103, 104, 105, 107
String ls_temp, ls_method[], ls_trcod[]
ls_temp 			= fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_method[])

dw_cond.object.paymethod1[1] 	= ls_method[1]
dw_cond.object.paymethod2[1] 	= ls_method[2]
dw_cond.object.paymethod3[1] 	= ls_method[3]
dw_cond.object.paymethod4[1] 	= ls_method[4]
dw_cond.object.paymethod5[1] 	= ls_method[5]
dw_cond.object.paymethod6[1] 	= ls_method[6]

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_trcod[])

dw_cond.object.trcode1[1] 	= ls_trcod[1]
dw_cond.object.trcode2[1] 	= ls_trcod[2]
dw_cond.object.trcode3[1] 	= ls_trcod[3]
dw_cond.object.trcode4[1] 	= ls_trcod[4]
dw_cond.object.trcode5[1] 	= ls_trcod[5]
dw_cond.object.trcode6[1] 	= ls_trcod[6]

//dw_cond.object.operator[1]	= gs_user_id


//Bill 마이너스 수납 권한자인지 확인, ii_bill_user
select count(*) into :ii_bill_user
from syscod2t
where grcode = 'BILL'
  and code = :gs_user_id
  and use_yn = 'Y';
  

p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")

dw_cond.SetFocus()
dw_cond.Setrow(1)
dw_cond.setColumn("payid")

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail2.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail2.Height = 0
  
	p_save.Y			= dw_detail2.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y		= dw_detail2.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y		= dw_detail2.Y + iu_cust_w_resize.ii_dw_button_space	
//	cb_contract.Y	= dw_detail2.Y + iu_cust_w_resize.ii_dw_button_space		
Else
	dw_detail2.Height = newheight - dw_detail2.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 

	p_save.Y			= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y		= newheight - iu_cust_w_resize.ii_button_space_1	
//	cb_contract.Y	= newheight - iu_cust_w_resize.ii_button_space_1		
End If

If newwidth < dw_detail2.X  Then
	dw_detail2.Width = 0
Else
	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event type integer ue_save_sql();call super::ue_save_sql;return 0
end event

event ue_ok;call super::ue_ok;DataWindowChild ldwc_trdt

String 	ls_payid, 	ls_where, 	ls_where2, ls_hotbillflag
Long   	ll_rc,		ll_cnt
Int 	 	li_rc2, 		li_exist
DEC{2}	ldc_summary, li_write_1, li_write_2, li_write

st_hotbill.text = ''

//JHCHOI 수정. 2010.01.07 Operator 없이 조회 가능하도록!
//Input Validation Check
//THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc2)
//
//IF li_rc2 <> 0 THEN
//	RETURN
//END IF

ls_payid	= Trim(dw_cond.object.payid[1])
If IsNull(ls_payid) Then ls_payid = ""

If ls_payid = "" Then
//	f_msg_usr_err(200, Title, "Pay ID")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("payid")
	Return
Else
   ll_rc = wfi_get_payid(ls_payid, "")  

   If ll_rc < 0 Then
		f_msg_usr_err(201, Title, "Payer")
		dw_cond.SetColumn("payid")
		Return
	End If
End If


//ls_where = ""
//If ls_payid <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += "A.PAYID = '" + ls_payid + "'"
//End If
//
//ls_where2 = ""
//If ls_payid <> "" Then
//	If ls_where2 <> "" Then ls_where2 += " AND "
//	ls_where2 += "A.PAYID = '" + ls_payid + "'"
//End If

//dw_detail.is_where 	= ls_where
ll_rc 					= dw_detail.Retrieve(ls_payid)
IF ll_rc > 0 THEN
	ldc_summary			= dw_detail.GetItemNumber(ll_rc, "all_sum")
ELSE
	f_msg_info(1000, Title , "")
	ldc_summary				= 0
	return 
END IF
//p_save.TriggerEvent("ue_disable")

//화면 리프레쉬 제한!
//dw_detail2.is_where 	= ls_where2
ll_rc = dw_detail2.Retrieve(ls_payid)

ll_rc = This.Trigger Event ue_retive()
If ll_rc < 0 Then			Return


// write off 금액 표시
select nvl(sum(tramt),0) tramt 
into :li_write_1 
from reqdtl 
where payid = :ls_payid 
and (mark is null or mark <> 'D') 
and (trcod = '940' or upper(remark) like '%W%R%I%T%E%O%F%F%');

select nvl(sum(tramt),0) tramt 
into :li_write_2 
from reqdtlh 
where payid = :ls_payid 
and (mark is null or mark <> 'D') 
and (trcod = '940' or upper(remark) like '%W%R%I%T%E%O%F%F%');

li_write = li_write_1 + li_write_2
dw_detail.object.write.text = String(li_write, '#,##0.00')

IF li_write_1 <> 0 OR li_write_2 <> 0 THEN
	dw_detail.Object.t_3.Color 				= RGB(255, 0, 0)
	dw_detail.Object.write.Color 				= RGB(255, 0, 0)
ELSE
	dw_detail.Object.t_3.Color 				= RGB(0, 0, 0)
	dw_detail.Object.write.Color 				= RGB(0, 0, 0)	
END IF

SELECT COUNT(*) INTO :ll_cnt
FROM   HOTREQDTL
WHERE  PAYID = :ls_payid;

IF ll_cnt > 0 THEN
	cb_2.Enabled = TRUE
ELSE
	cb_2.Enabled = FALSE
END IF

//IF ldc_summary =  0 then
//	p_save.TriggerEvent("ue_disable")
//ELSE
//	p_save.TriggerEvent("ue_enable")
//END IF
//
//

// 전체핫빌/부분핫빌 고객 체크
select hotbillflag
into :ls_hotbillflag
from customerm
where payid = :ls_payid;

if ls_hotbillflag = 'S' then // 전체핫빌
	st_hotbill.text = "전체 핫빌 완료"
	st_hotbill.backcolor=rgb(255, 255, 0)	// yellow
	st_hotbill.textcolor=rgb(255, 0, 0)    // red
	p_save.TriggerEvent("ue_disable")	
	st_hotbill.visible = true
elseif ls_hotbillflag = 'H' then // 부분핫빌
	st_hotbill.text = "부분 핫빌 완료"
	st_hotbill.backcolor=rgb(255, 255, 255) // white
	st_hotbill.textcolor=rgb(0, 0, 255) // blue
	p_save.TriggerEvent("ue_enable")	
	st_hotbill.visible = true
else
	st_hotbill.visible = false
	st_hotbill.text = ""
	st_hotbill.backcolor=rgb(255, 255, 255) // white
	st_hotbill.textcolor=rgb(255, 255, 255) // white
	p_save.TriggerEvent("ue_enable")	
end if

end event

on b5w_reg_mtr_inp_sams.create
int iCurrent
call super::create
this.st_horizontal=create st_horizontal
this.dw_detail2=create dw_detail2
this.dw_split=create dw_split
this.p_reset=create p_reset
this.cb_1=create cb_1
this.cb_contract=create cb_contract
this.cb_2=create cb_2
this.cb_close2=create cb_close2
this.st_hotbill=create st_hotbill
this.r_1=create r_1
this.r_2=create r_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_horizontal
this.Control[iCurrent+2]=this.dw_detail2
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.cb_1
this.Control[iCurrent+6]=this.cb_contract
this.Control[iCurrent+7]=this.cb_2
this.Control[iCurrent+8]=this.cb_close2
this.Control[iCurrent+9]=this.st_hotbill
this.Control[iCurrent+10]=this.r_1
this.Control[iCurrent+11]=this.r_2
end on

on b5w_reg_mtr_inp_sams.destroy
call super::destroy
destroy(this.st_horizontal)
destroy(this.dw_detail2)
destroy(this.dw_split)
destroy(this.p_reset)
destroy(this.cb_1)
destroy(this.cb_contract)
destroy(this.cb_2)
destroy(this.cb_close2)
destroy(this.st_hotbill)
destroy(this.r_1)
destroy(this.r_2)
end on

event ue_save;INTEGER 	li_return, 	li_rc, 		li_tmp,		li_rc2
STRING 	ls_tmp
DATE 		ld_tmp

//Input Validation Check
THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc2)

IF li_rc2 <> 0 THEN
	RETURN
END IF

//Process Validation Check
THIS.TRIGGER EVENT ue_processvalidcheck(li_rc2)

IF li_rc2 <> 0 THEN
	RETURN
END IF

li_return = THIS.TRIGGER EVENT ue_process()
CHOOSE CASE li_return
	CASE Is < -2
		dw_cond.SetFocus()
	CASE -2
		dw_cond.SetFocus()
	CASE -1
		//ROLLBACK
		iu_mdb_app.is_title 		= THIS.Title
		iu_mdb_app.is_caller 	= "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		IF iu_mdb_app.ii_rc = -1 THEN RETURN
		f_msg_info(3010, THIS.Title, "Save")
	CASE Is >= 0
		//성공적이면 commit
		iu_mdb_app.is_title 	= THIS.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		IF iu_mdb_app.ii_rc = -1 THEN RETURN
	
		//Error 
		IF li_rc < 0 THEN
			f_msg_info(3010, THIS.Title, "Save")
		ELSE	
		   f_msg_info(3000, THIS.Title, "Save")
		END IF
		//초기화
	   SetNull(ld_tmp)
		SetNull(li_tmp)
		SetNull(ls_tmp)

		dw_cond.object.paydt[1] 	= f_find_shop_closedt(GS_SHOPID)
		dw_cond.object.amt1[1] 	= 0
		dw_cond.object.amt2[1] 	= 0
		dw_cond.object.amt3[1] 	= 0
		dw_cond.object.amt4[1] 	= 0
		dw_cond.object.amt5[1] 	= 0
		dw_cond.object.amt6[1] 	= 0	
			
		dw_cond.object.payamt[1] 	= 0
		dw_cond.object.remark[1] 	= ls_tmp
		dw_cond.object.trdt[1] 		= ld_tmp
		dw_cond.object.trcod[1] 	= ls_tmp 
		
		dw_detail2.SetSort("trdt D, Priority D")
		dw_detail2.Sort()
		dw_detail2.GroupCalc()
		
		THIS.TriggerEvent("ue_ok")

		p_ok.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
END CHOOSE

F_INIT_DSP(1,"","")

end event

type dw_cond from w_a_reg_m_sql`dw_cond within b5w_reg_mtr_inp_sams
integer x = 46
integer y = 20
integer width = 2720
integer height = 532
string dataobject = "b5d_cnd_reg_mtr_inp_sams"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid
ldwo_payid = dw_cond.object.payid

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] 	= iu_cust_help.is_data[1]	//고객번호
			Object.marknm[row] 	= iu_cust_help.is_data[2]	//고객명
			Object.memberid[row] = iu_cust_help.is_data[4]	//memberid
			//Item Changed Event 발생
			dw_cond.Event ItemChanged(1,ldwo_payid ,iu_cust_help.is_data[1])
		End If		
End Choose

Return 0

end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldwc_trdt
String 	ls_payid,	ls_trcod,	ls_customeryn,		ls_filter,	&
			ls_paydt,	ls_paydt_1,	ls_sysdate,			ls_paydt_c,	&
			ls_empnm
Int   	li_rc,		li_rc2,		li_exist			
DEC{2}	ldc_100,		ldc_90
Date		ldt_paydt
Long		ll_return

Choose Case dwo.Name
	case 'memberid'
		ls_payid = Trim(dw_cond.object.memberid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid("", ls_payid)

		If li_rc < 0 Then
			dw_cond.object.memberid[1] 	= ""
			dw_cond.object.customerid[1] 	= ""
			dw_cond.object.payid[1] 		= ""
			dw_cond.object.marknm[1] 		= ""
			dw_cond.SetColumn("memberid")
			Return 0
		End IF
		
		li_rc2 = GetChild("trdt", ldwc_trdt)

		IF li_rc2 = -1 THEN
			MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
			Return 1
		End If
		ls_payid =  this.Object.payid[1]
      
		ldwc_trdt.SetTransObject(SQLCA)
		ls_filter = "payid = '" + ls_payid  + "' "
		ldwc_trdt.SetFilter(ls_filter)			//Filter정함
		ldwc_trdt.Filter()
		//선택할수 있게
		dw_cond.object.trdt.Protect = 0		
		
	Case "payid"
		ls_payid = Trim(dw_cond.object.payid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid, "")

		If li_rc < 0 Then
			dw_cond.object.payid[1] 		= ""
			dw_cond.object.memberid[1] 	= ""
			dw_cond.object.customerid[1] 	= ""
			dw_cond.object.marknm[1] 		= ""
			dw_cond.SetColumn("payid")
			Return 0
		End IF
		
		li_rc2 = GetChild("trdt", ldwc_trdt)

		IF li_rc2 = -1 THEN
			MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
			Return 1
		End If

		ldwc_trdt.SetTransObject(SQLCA)
		ls_filter = "payid = '" + data  + "' "
		ldwc_trdt.SetFilter(ls_filter)			//Filter정함
		ldwc_trdt.Filter()

//		li_exist = ldwc_trdt.Retrieve(data)
//		If li_exist < 0 Then
//		  f_msg_usr_err(2100, Title, "Retrieve()")
//		  Return 1  		//선택 취소 focus는 그곳에
//		End If  
		
		//선택할수 있게
		dw_cond.object.trdt.Protect = 0
	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
//		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impack(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
			END IF			
//		END IF		
		WF_SET_TOTAL()
		
	Case "paydt"
		ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
		ls_paydt  = String(ldt_paydt, 'yyyymmdd')
		
		SELECT TO_CHAR(TO_DATE(TO_CHAR(:ldt_paydt, 'yyyymmdd'), 'YYYYMMDD') + 1, 'YYYYMMDD'),
				 TO_CHAR(SYSDATE, 'YYYYMMDD'),
				 REPLACE(:data, '-', '') 
		INTO   :ls_paydt_1, :ls_sysdate, :ls_paydt_c
		FROM   DUAL;
		
		IF ls_paydt_c > ls_paydt_1 OR ls_paydt_c < ls_paydt THEN
			dw_cond.object.paydt[row]	= ldt_paydt
			f_msg_usr_err(9000, Title, "Pay Date 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.SetColumn("paydt")
			RETURN 2
		END IF
		
	case 'operator'
		SELECT EMPNM INTO :ls_empnm
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm		
		
	
End Choose

Return 0
end event

event dw_cond::ue_init();call super::ue_init;DataWindowChild ldwc_trdt
Int    li_rc2, li_exist
String ls_payid

//ls_payid = This.object.payid[1]

If IsNull(ls_payid) Then ls_payid = " "

li_rc2 = GetChild("trdt", ldwc_trdt)

IF li_rc2 = -1 THEN 
	MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
	Return
End If

//		ls_filter = "payid = '" + data 
//		ldwc_trdt.SetFilter(ls_filter)			//Filter정함
ldwc_trdt.SetTransObject(SQLCA)
li_exist = ldwc_trdt.Retrieve(ls_payid)
//		ldwc_trdt.Filter()
If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Retrieve()")
//  Return   		//선택 취소 focus는 그곳에
End If  
		
		//선택할수 있게
//		dw_cond.object.trdt.Protect = 0

This.idwo_help_col[1] 	= This.Object.payid
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.is_data[1] 			= "CloseWithReturn"




end event

event dw_cond::losefocus;call super::losefocus;AcceptText()
end event

type p_ok from w_a_reg_m_sql`p_ok within b5w_reg_mtr_inp_sams
integer x = 3118
integer y = 60
integer width = 274
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b5w_reg_mtr_inp_sams
integer x = 681
integer y = 1956
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b5w_reg_mtr_inp_sams
integer width = 3397
integer height = 560
integer taborder = 0
integer textsize = -5
end type

type p_save from w_a_reg_m_sql`p_save within b5w_reg_mtr_inp_sams
integer x = 27
integer y = 1956
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b5w_reg_mtr_inp_sams
integer x = 27
integer y = 572
integer width = 3401
integer height = 632
string dataobject = "b5d_reg_mtr_inp_sams"
boolean ib_sort_use = false
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event dw_detail::retrieveend;call super::retrieveend;wf_set_total()
end event

type st_horizontal from statictext within b5w_reg_mtr_inp_sams
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 27
integer y = 1204
integer width = 745
integer height = 32
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeNS!"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If

	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;// Hide the bar
BackColor = il_HiddenColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

type dw_detail2 from u_d_indicator within b5w_reg_mtr_inp_sams
event type integer ue_retrieve ( long al_select_row )
integer x = 27
integer y = 1220
integer width = 3397
integer height = 724
integer taborder = 30
boolean bringtotop = true
string dataobject = "b5d_reg_mtr_inp_list_sams"
borderstyle borderstyle = stylebox!
end type

event clicked;call super::clicked;//If row = 0 then Return
//
//If IsSelected( row ) then
////	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If
//
end event

event constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event ue_key;call super::ue_key;If keyflags = 0 Then
	If key = KeyEscape! Then
		Parent.TriggerEvent(is_close)
	End If
End If

end event

event retrieveend;call super::retrieveend;Long		ll,		ll_deposit_cnt
Integer 	li_seq
DEC{2}	ldc_bil_amt
STRING	ls_det_itemcod

li_seq = 0
IF RowCount = 0 then return
this.SetSort("cp_sort A, trdt A, Priority A")
this.Sort()

FOR ll =  1 to RowCount
	IF trim(this.Object.COMPLETE_YN[ll]) = 'N' then
		li_seq += 1
		this.Object.priority[ll] =  li_seq
	end if
	this.Object.chk[ll] =  '0'
	
	//impact card 금액계산
	ls_det_itemcod = trim(THIS.Object.itemcod[ll])
	ldc_bil_amt		= THIS.Object.bil_amt[ll]
	 
	SELECT COUNT(*) INTO :ll_deposit_cnt
	FROM   DEPOSIT_REFUND
	WHERE ( IN_ITEM = :ls_det_itemcod OR OUT_ITEM = :ls_det_itemcod );	

	IF ll_deposit_cnt <= 0 THEN
		THIS.Object.impack_card[ll] 	= Round(ldc_bil_amt * 0.1, 2)
		THIS.Object.impack_not[ll] 	= Round(ldc_bil_amt - ROUND(ldc_bil_amt * 0.1, 2), 2)
		THIS.Object.impack_check[ll] 	= 'A'	
	ELSE
		THIS.Object.impack_card[ll] 	= 0
		THIS.Object.impack_not[ll] 	= ldc_bil_amt
		THIS.Object.impack_check[ll] 	= 'B'		
	END IF
NEXT


this.SetSort("trdt D, Priority D")
this.Sort()
this.GroupCalc()

end event

event losefocus;call super::losefocus;AcceptText()
end event

type dw_split from datawindow within b5w_reg_mtr_inp_sams
boolean visible = false
integer x = 2848
integer y = 176
integer width = 411
integer height = 200
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean border = false
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type p_reset from u_p_reset within b5w_reg_mtr_inp_sams
integer x = 352
integer y = 1956
boolean bringtotop = true
boolean originalsize = false
end type

type cb_1 from commandbutton within b5w_reg_mtr_inp_sams
boolean visible = false
integer x = 3013
integer y = 244
integer width = 402
integer height = 112
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "call_wfi"
end type

event clicked;wfi_call_proc()
end event

type cb_contract from commandbutton within b5w_reg_mtr_inp_sams
integer x = 3017
integer y = 404
integer width = 375
integer height = 96
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Contract Info"
end type

event clicked;STRING	ls_payid

dw_cond.AcceptText()

ls_payid = dw_cond.Object.payid[1]


iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Contract Info"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_cond
iu_cust_msg.idw_data[2] = dw_detail
iu_cust_msg.is_data[1]  = ls_payid

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_contract_info, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0
end event

type cb_2 from commandbutton within b5w_reg_mtr_inp_sams
integer x = 3017
integer y = 280
integer width = 375
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
boolean enabled = false
string text = "HotBill Info"
end type

event clicked;STRING	ls_payid

dw_cond.AcceptText()

ls_payid = dw_cond.Object.payid[1]

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "HotBill Info"
iu_cust_msg.ib_data[1]  = FALSE
iu_cust_msg.is_data[1]  = ls_payid
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_cond

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_hotbill_info, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0
end event

type cb_close2 from commandbutton within b5w_reg_mtr_inp_sams
boolean visible = false
integer x = 1111
integer y = 1948
integer width = 402
integer height = 112
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "none"
end type

event clicked;close(parent)
end event

type st_hotbill from statictext within b5w_reg_mtr_inp_sams
boolean visible = false
integer x = 2117
integer y = 68
integer width = 553
integer height = 88
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 255
long backcolor = 16777215
alignment alignment = center!
boolean border = true
long bordercolor = 255
borderstyle borderstyle = styleshadowbox!
boolean focusrectangle = false
end type

type r_1 from rectangle within b5w_reg_mtr_inp_sams
integer linethickness = 1
long fillcolor = 16777215
integer x = 2094
integer y = 60
integer width = 229
integer height = 200
end type

type r_2 from rectangle within b5w_reg_mtr_inp_sams
integer linethickness = 1
long fillcolor = 16777215
integer x = 2117
integer y = 92
integer width = 229
integer height = 200
end type

