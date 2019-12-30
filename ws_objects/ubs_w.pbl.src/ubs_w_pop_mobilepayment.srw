$PBExportHeader$ubs_w_pop_mobilepayment.srw
$PBExportComments$[jhchoi] 모바일 신규 신청 수납 팝업 - 2009.03.20
forward
global type ubs_w_pop_mobilepayment from w_a_hlp
end type
type dw_master from datawindow within ubs_w_pop_mobilepayment
end type
type p_save from u_p_save within ubs_w_pop_mobilepayment
end type
type dw_split from datawindow within ubs_w_pop_mobilepayment
end type
type gb_1 from groupbox within ubs_w_pop_mobilepayment
end type
end forward

global type ubs_w_pop_mobilepayment from w_a_hlp
integer width = 3461
integer height = 1368
string title = ""
event ue_processvalidcheck ( ref integer ai_return )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
dw_master dw_master
p_save p_save
dw_split dw_split
gb_1 gb_1
end type
global ubs_w_pop_mobilepayment ubs_w_pop_mobilepayment

type variables
u_cust_db_app iu_cust_db_app

STRING 	is_print_check, 	is_amt_check, 	is_customerid, 	is_phone_type, 	&
       	is_paycod,			is_format,		is_reqdt,		 	is_method[], 		&
		   is_trcod[],			is_save_check,	is_paydt,			is_minus_check,	&
			is_deposit_chk,	is_appseq
DATE 	 	idt_shop_closedt
DOUBLE	ib_seq
DEC{2} 	idc_amt[], 			idc_total, 		idc_income_tot, 	idc_impack
INTEGER 	ii_method_cnt


end variables

forward prototypes
public subroutine wf_set_total ()
public function integer wf_split (date paydt)
public function integer wf_set_impack (string as_data)
public function integer wf_split_new (date wfdt_paydt)
end prototypes

event ue_processvalidcheck;INTEGER 	li_return, 		li_rc, 					li_tmp
STRING 	ls_tmp,			ls_payid,				ls_method0[],			ls_trcod0[],	ls_operator,	&
			ls_paydt_c,		ls_sysdate,			 	ls_paydt_1,				ls_paydt
DATE 		ld_tmp, 			ldt_shop_closedt, 	ldt_paydt
DEC{2}	ldc_receive,	ldc_total,				ldc_card_total,		ldc_amt0[],		ldc_change,		&
			ldc_impack,		ldc_90,					ldc_card,				ldc_10
LONG		li_method_cnt, li_lp,					ll_opr_cnt						

//입력 자료가 이상없는지 확인
If dw_hlp.AcceptText() < 1 Then
	F_MSG_USR_ERR(9000, Title, "입력자료에 이상이 있습니다.")	
	dw_hlp.SetFocus()
	ai_return = -1				
	Return
End If

ls_operator	= dw_hlp.Object.operator[1]

SELECT COUNT(*) INTO :ll_opr_cnt
FROM   SYSUSR1T
WHERE  EMP_NO = :ls_operator;

IF ll_opr_cnt <= 0 THEN
	F_MSG_USR_ERR(9000, Title, "Error! Operator ID!")
	dw_master.SetFocus()
	ai_return = -1				
	Return
END IF

//변수 선언
ls_payid 			= trim(dw_hlp.Object.customerid[1])
ldc_receive 		= dw_hlp.Object.cp_receive[1]
ldc_change 			= dw_hlp.object.cp_change[1]
ldt_paydt 			= dw_hlp.Object.paydt[1]
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ldc_impack			= dw_hlp.Object.amt5[1]
ldc_total 			= dw_hlp.Object.total[1]
ldc_card_total		= dw_hlp.Object.amt2[1] + &
						  dw_hlp.Object.amt3[1] + &
						  dw_hlp.Object.amt4[1] + &
						  dw_hlp.Object.amt5[1]
						  
//receive 금액 확인
IF is_minus_check = 'N' THEN
	IF ldc_receive<= 0 THEN
		F_MSG_USR_ERR(9000, Title, "입력된 금액이 없습니다. 확인하세요.")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		ai_return = -1
		RETURN
	END IF
END IF

IF ldc_receive < ldc_total THEN
	F_MSG_USR_ERR(9000, Title, "받은 금액이 적습니다. 확인하세요.")
	dw_hlp.SetFocus()
	dw_hlp.SetRow(1)
	ai_return = -1
	RETURN	
END IF	

IF ldc_total < 0 THEN
	IF ldc_receive >= 0 THEN
		F_MSG_USR_ERR(9000, Title, "금액을 확인하세요.")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		ai_return = -1
		RETURN
	ELSE
		IF ldc_total <> ldc_receive THEN
			F_MSG_USR_ERR(9000, Title, "금액을 확인하세요.")
			dw_hlp.SetFocus()
			dw_hlp.SetRow(1)
			ai_return = -1
			RETURN			
		END IF			
	END IF
ELSE
	IF ldc_receive < 0 THEN
		F_MSG_USR_ERR(9000, Title, "금액을 확인하세요.")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		ai_return = -1
		RETURN
	END IF	
END IF

//2009.06.10 추가
//IF ldc_impack <> 0 THEN
//	ldc_90 = dw_hlp.Object.credit[1]
//	ldc_card = dw_hlp.Object.amt3[1]
//	dw_hlp.Object.amt5[1] = ldc_total - ldc_90
//	dw_hlp.Object.amt3[1] = ldc_card + (ldc_impack - (ldc_total - ldc_90))
//END IF	
//2011.02.28 수정...
IF ldc_impack <> 0 THEN
	ldc_90	= Round(ldc_impack * 0.9, 2)
	ldc_10   = Round(ldc_impack * 0.1, 2)
	ldc_card = dw_hlp.Object.amt3[1]
	dw_hlp.Object.amt5[1] = ldc_impack - ldc_90
	dw_hlp.Object.amt3[1] = ldc_card + (ldc_impack - ldc_10)
END IF		

dw_hlp.Accepttext()
						
li_method_cnt 		= 0
ldc_amt0[1] 		= dw_hlp.object.amt3[1] 
ldc_amt0[2] 		= dw_hlp.object.amt2[1] 
ldc_amt0[3] 		= dw_hlp.object.amt4[1] 
ldc_amt0[4] 		= dw_hlp.object.amt1[1]
ldc_amt0[5] 		= dw_hlp.object.amt6[1]

ls_method0[1] 		= dw_hlp.object.paymethod3[1]
ls_method0[2] 		= dw_hlp.object.paymethod2[1]
ls_method0[3] 		= dw_hlp.object.paymethod4[1]
ls_method0[4] 		= dw_hlp.object.paymethod1[1]
ls_method0[5] 		= dw_hlp.object.paymethod6[1]

ls_trcod0[1] 		= dw_hlp.object.trcode3[1]
ls_trcod0[2] 		= dw_hlp.object.trcode2[1]
ls_trcod0[3] 		= dw_hlp.object.trcode4[1]
ls_trcod0[4] 		= dw_hlp.object.trcode1[1]
ls_trcod0[5] 		= dw_hlp.object.trcode6[1]

ii_method_cnt 	= 0 
idc_total 		= 0

IF IsNull(ls_payid)  THEN ls_payid = ''
IF ISNULL(ldc_total) THEN ldc_total = 0

//pay dt 와 shop 마감일 확인
IF ldt_paydt <> idt_shop_closedt THEN
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
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		dw_hlp.SetColumn("paydt")
		ai_return = -1	
		RETURN
	END IF
END IF

//customer id ( pay id ) 확인
SELECT COUNT(*) INTO :li_rc FROM CUSTOMERM WHERE CUSTOMERID = :ls_payid;

IF IsNull(li_rc) OR SQLCA.SQLCODE <> 0	THEN li_rc = 0

IF li_rc = 0 THEN
	F_MSG_USR_ERR(9000, Title, "PayID를 확인하세요.")
	dw_hlp.SetFocus()
	dw_hlp.SetRow(1)
	ai_return = -1			
	RETURN
END IF

//카드입금액이 총판매액보다 크면...
IF ldc_total > 0 THEN
	IF ldc_card_total > ldc_total THEN
		F_MSG_USR_ERR(9000, Title, "결제 내용을 확인하세요!")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		dw_hlp.SetColumn("amt1")
		ai_return = -1					
		RETURN
	END IF
ELSE
	IF ldc_card_total < ldc_total THEN
		F_MSG_USR_ERR(9000, Title, "결제 내용을 확인하세요!")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		dw_hlp.SetColumn("amt1")
		ai_return = -1							
		RETURN
	END IF
END IF

//총합이 0 인지 확인
IF ldc_total  = 0 THEN
	F_MSG_USR_ERR(200, Title, "Total -- Zero")
	dw_hlp.Setfocus()
	ai_return = -1							
	RETURN
END IF

//수납 METHOD 가 0 이상이어야 함.
FOR li_lp = 1 TO 5
	IF ldc_amt0[li_lp] <> 0 THEN
		idc_total 						+= ldc_amt0[li_lp]
		ii_method_cnt 					+= 1
		idc_amt[ii_method_cnt] 		= ldc_amt0[li_lp]
		is_method[ii_method_cnt] 	= ls_method0[li_lp]
		is_trcod[ii_method_cnt] 	= ls_trcod0[li_lp]
	END IF
NEXT

IF ii_method_cnt  = 0 THEN
	F_MSG_USR_ERR(200, Title, "Amount")
	dw_hlp.SetColumn("amt1")
	ai_return = -1	
	RETURN
END IF

//POS 영수증 세팅
F_INIT_DSP(3, String(ldc_receive), String(ldc_change))

//수납금액을 ITEM 에 맞춰서 나누는 함수
//wf_split(ldt_paydt)
wf_split_new(ldt_paydt)

ai_return = 0

RETURN
end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN lb_check
LONG    ll_row

ll_row = dw_hlp.GetRow()

lb_check = fb_save_required(dw_hlp, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_process(ref integer ai_return);STRING	ls_paydt,		ls_customerid,		ls_memberid,		ls_errmsg,		ls_appseq,		&
			ls_itemcod,		ls_paymethod,		ls_payamt,			ls_remark,	ls_operator		
INTEGER	li_rc,			li_cnt,				li_s
LONG		ll_return,		ll_paycnt
DATE		ld_paydt

string   ls_taxamt

dw_hlp.AcceptText()
dw_split.AcceptText()

ls_paydt			= String(dw_hlp.Object.paydt[1], 'yyyymmdd')
ld_paydt			= dw_hlp.Object.paydt[1]
ls_customerid	= dw_hlp.Object.customerid[1]
ls_memberid		= dw_hlp.Object.memberid[1]

ls_operator	= dw_hlp.Object.operator[1]  // gs_userid 대신 ls_operator 로 dailypayment에 보내주자 [RQ-YJ-UBS-201703-02]

is_paydt = ls_paydt

//영수증  번호 구하기...
SELECT SEQ_RECEIPT.NEXTVAL	INTO :ls_appseq	FROM DUAL;

IF SQLCA.SQLCODE < 0 THEN
	F_MSG_SQL_ERR(THIS.TITLE, " Sequence Error(seq_receipt)")
	ai_return = -1
	RETURN
END IF

is_appseq = ls_appseq

//프로시저 처리
li_cnt = dw_split.RowCount()

FOR li_s = 1 TO li_cnt
	ls_itemcod 		= dw_split.Object.itemcod[li_s]
	ls_paymethod 	= dw_split.Object.paymethod[li_s]
	ls_payamt	 	= String(dw_split.Object.payamt[li_s])
	ls_taxamt	 	= String(dw_split.Object.taxamt[li_s])
	ls_remark	 	= String(dw_split.Object.remark[li_s])	
	ll_paycnt		= dw_split.Object.paycnt[li_s]
	
	ls_errmsg = space(1000)
	SQLCA.REG_DAILYPAYMENT(gs_shopid,		ld_paydt,		ls_customerid,		ls_itemcod,		&
										ls_paymethod, 	ls_payamt, 		ls_taxamt    ,    ls_remark, 			ld_paydt, 0, ls_appseq,		&
										ls_operator,		'SALE',			ll_paycnt,			ll_return,			ls_errmsg)
										

	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
		ai_return = -1		
		RETURN
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
		ai_return = -1		
		RETURN
	END IF
NEXT

//영수증 출력...
ubs_dbmgr_receiptmst	lu_dbmgr
lu_dbmgr = CREATE ubs_dbmgr_receiptmst

lu_dbmgr.is_caller   = "usb_w_pop_mobilepayment%direct"
lu_dbmgr.is_title	   = Title
lu_dbmgr.is_data[1]  = ls_customerid
lu_dbmgr.is_data[2]  = ls_paydt
lu_dbmgr.is_data[3]  = gs_shopid
lu_dbmgr.is_data[4]  = gs_user_id
lu_dbmgr.is_data[5]  = 'Y'
lu_dbmgr.is_data[6]  = ls_memberid
lu_dbmgr.is_data[7]  = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[8]  = ls_appseq
lu_dbmgr.idw_data[1] = dw_hlp
lu_dbmgr.idw_data[2] = dw_split
lu_dbmgr.idw_data[3] = dw_master

lu_dbmgr.uf_prc_db()

li_rc		 = lu_dbmgr.ii_rc
ls_appseq = lu_dbmgr.is_appseq

IF li_rc < 0 THEN
	DESTROY lu_dbmgr
	dw_hlp.SetColumn("amt1")
	ai_return = -1
	RETURN
END IF

p_save.TriggerEvent("ue_disable")
dw_cond.Enabled = False
is_amt_check = 'Y'

DESTROY lu_dbmgr

ai_return = 0

RETURN
end event

public subroutine wf_set_total ();DEC{2}	ldc_TOTAL

ldc_total = 0

IF dw_master.RowCount() > 0 THEN
	ldc_total = dw_master.GetItemNumber(dw_master.RowCount(), "all_sum") 
END IF

dw_hlp.Object.total[1] 		= ldc_total

//
F_INIT_DSP(2, "", String(ldc_total))

RETURN
end subroutine

public function integer wf_split (date paydt);LONG		ll, 				ll_cnt,			ll_row
INTEGER 	li_pay_cnt, 	li_pp,			li_first,			li_paycnt, 		li_chk
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 			ldc_income,		ldc_receive, &
			ldc_total,		ldc_rem_prc, 	ldc_receive_org,	ldc_total_prc
STRING 	ls_method,		ls_basecod, 	ls_customerid,		ls_payid, 		ls_trcod, &
			ls_saletrcod, 	ls_remark

li_pay_cnt 	= 1

dw_hlp.AcceptText()
dw_master.SetSort("Priority A")
dw_master.Sort()

ls_remark = dw_hlp.object.remark[1]

IF ISNull(ls_remark) THEN 		ls_remark = ''

ldc_receive 	 = dw_hlp.object.cp_receive[1]
ldc_total 		 = dw_hlp.object.total[1]
ls_customerid 	 = dw_hlp.Object.customerid[1]
ls_payid 		 = dw_hlp.Object.customerid[1]
ldc_receive_org = ldc_receive

//입금처리방식 변경 --2007.01.23
//입금할 금액보다 과입금하는 경우 즉 Change 금액이 발생하는 경우
//입금할 금액 만큼만 처리하고 나머지는 처리하지 않는다.
//EX>50,10,20,10,10,-10,-10 일때 100을 입금한 경우 
//   80만큼만 처리하고 나머지는 나둔다.즉 50, 10, 20까지만 처리
//
//입금처리방식 변경 -- 2007.01.26
// 마이너스금액을 선 처리한다. 우선순위보다...

ldc_total_prc	 = 0

//customerm Search
SELECT BASECOD INTO :ls_basecod FROM CUSTOMERM WHERE CUSTOMERID = :ls_customerid;

ll_cnt 				= dw_master.RowCount()
idc_income_tot 	= 0        // 전액을 입금하지 않을 경우에 대비 각 입금반영시 Add처리

FOR ll = 1 TO ll_cnt
	ldc_tramt	= dw_master.object.bill_amt[ll]

	// 각 아이템의 bill_amt 가 0이 아닌경우만 처리
	IF ldc_tramt <> 0 THEN
		ldc_income 		= 0
		li_first 		= 0
		li_chk 			= 0
		//입금내역 처리  Start........ 
		FOR li_pp =  li_pay_cnt TO ii_method_cnt
			ls_method 	= is_method[li_pp]
			ls_trcod 	= is_trcod[li_pp]
			ldc_rem 		= idc_amt[li_pp]
			
			IF ldc_rem >= ldc_tramt THEN
				ldc_saleamt 	= ldc_tramt
				IF li_first =  0 THEN
					li_paycnt 	= 1
					li_first 	= 1
				ELSE
					li_paycnt 	= 0
				END IF
				ldc_rem 			= ldc_rem - ldc_saleamt
				ldc_tramt 		= 0
			ELSE
				ldc_saleamt 	= ldc_rem
				ldc_tramt 		= ldc_tramt - ldc_rem
				ldc_rem 			= 0
				IF li_first =  0 THEN
					li_paycnt 	= 1
					li_first 	= 1
				ELSE
					li_paycnt 	= 0
				END IF
				li_pay_cnt		+= 1
			END IF
			ldc_income 		+= ldc_saleamt
	
			ll_row =  dw_split.InsertRow(0)

			dw_split.Object.paydt[ll_row] 		= paydt
			dw_split.Object.shopid[ll_row] 		= gs_shopid
			dw_split.Object.operator[ll_row] 	= gs_user_id
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			dw_split.Object.itemcod[ll_row] 		= dw_master.Object.itemcod[ll]
			dw_split.Object.paymethod[ll_row] 	= ls_method
			dw_split.Object.regcod[ll_row] 		= dw_master.Object.regcod[ll]
			dw_split.Object.payamt[ll_row] 		= ldc_saleamt
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
			dw_split.Object.dctype[ll_row] 		= 'D'
			dw_split.Object.trcod[ll_row] 		= ls_trcod
			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
			//dw_split.Object.req_trdt[ll_row] 	= idt_shop_closedt
			
			ldc_receive 								= ldc_receive - ldc_saleamt
			idc_income_tot 							+= ldc_saleamt
			ldc_total_prc 								+= ldc_saleamt
			
			IF ldc_tramt = 0 THEN  //해당품목이 완납인 경우 다음 품목 처리 
					li_chk = 1
					EXIT
			END IF
			IF li_pay_cnt > ii_method_cnt THEN EXIT
		NEXT
	
		IF ldc_rem > 0 THEN		idc_amt[li_pay_cnt] = ldc_rem
	END IF
	IF ldc_receive <= 0 THEN EXIT
NEXT

dw_hlp.Object.total[1] =  idc_income_tot
dw_split.AcceptText()

RETURN 0
end function

public function integer wf_set_impack (string as_data);LONG		ll_row1
INT		ii
DEC{2}	ldc_impack2,	ldc_impack3,	ldc_total,		ldc_impack,		ldc_impack_10
DEC      ldc_impack1
  
dw_master.AcceptText()

ll_row1 = dw_master.RowCount()

ldc_impack = DEC(as_data)										//카드 입력한 금액
ldc_impack_10 = ROUND(ldc_impack * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impack = 0 THEN
	RETURN -1
END IF

idc_impack = 0

FOR ii = 1 TO ll_row1
	ldc_impack1 = dw_master.object.impack_card[ii]	
	IF IsNull(ldc_impack1) THEN ldc_impack1 = 0
	idc_impack  = idc_impack + ldc_impack1	
NEXT

IF idc_impack >= 0 THEN
	IF idc_impack < ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF
ELSE
	IF idc_impack > ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF	
END IF

ldc_total = dw_hlp.Object.total[1]
IF idc_impack <> 0 THEN
	dw_hlp.Object.credit[1]	= ldc_total - ldc_impack_10
ELSE
	dw_hlp.Object.credit[1]	= 0
END IF

RETURN 0


end function

public function integer wf_split_new (date wfdt_paydt);Long		ll, 				ll_cnt,			ll_row
Integer 	li_pay_cnt, 	li_pp,			li_first,		li_paycnt, 	li_chk,	li_update
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 		ldc_income,	ldc_receive, &
			ldc_total,		ldc_rem_prc, &
			ldc_receive_org,	ldc_total_prc
String 	ls_method,		ls_basecod, 	ls_customerid, ls_payid, 	ls_trcod, &
			ls_saletrcod, 	ls_req_trdt, 	ls_remark,		ls_operator,		&
			ls_trcod_im,   ls_method0_im, ls_add, ls_end, ls_trcod_det
DEC{2}	ldc_impack,		ldc_amt0_im,	ldc_payamt, ldc_imnot, ldc_im, ldc_impack_in
			
DATE		ldt_paydt

// 2019.04.25 VAT 처리에 따른 변수 추가 Modified by Han
string   ls_surtaxyn,   ls_itemcod
dec{2}   ld_taxrate,    ld_sale_tot, ld_taxamt, ld_vat

li_pay_cnt 	= 1

dw_hlp.AcceptText()
dw_master.AcceptText()

ls_remark 	= dw_hlp.object.remark[1]
ls_operator = dw_hlp.object.operator[1]
ldt_paydt	= dw_hlp.object.paydt[1]
ldc_impack 	= dw_hlp.object.amt5[1]

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= dw_hlp.object.trcode5[1]
	ls_method0_im	= dw_hlp.object.paymethod5[1]	
	ldc_amt0_im		= dw_hlp.object.amt5[1]			
END IF

IF ISNull(ls_remark)	then ls_remark = ''

ldc_receive 	= dw_hlp.object.cp_receive[1]
ldc_total 		= dw_hlp.object.total[1]
ls_customerid 	= dw_hlp.Object.customerid[1]
ls_payid 		= dw_hlp.Object.customerid[1]
ldc_receive_org = ldc_receive

IF ldc_total > 0 THEN
	dw_master.SetSort('bill_amt A')
ELSE
	dw_master.SetSort('bill_amt D')	
END IF

dw_master.Sort()

ldc_total_prc	 = 0

//customerm Search
select basecod INTO :ls_basecod from customerm  where customerid =  :ls_customerid ;

ll_cnt 				= dw_master.RowCount()

ls_add = 'N'
ls_end = 'N'

IF ll_cnt > 0 and ldc_total = 0 then
	//total = 0 인 경우 즉, (+, -) 값에 의해 항목들이 있으나 총계는 0인 경우 cash로 저장
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_master.object.bill_amt[ll]
		ls_trcod_det	= dw_master.Object.trcod[ll]
// 2019.04.25 Vat 금액 추가 Modified by Han
		ld_taxamt      = dw_master.Object.vat_amt[ll]
		
		//---------------------------------------
		ll_row =  dw_split.InsertRow(0)
		//---------------------------------------
		dw_split.Object.paydt[ll_row] 		= ldt_paydt
		dw_split.Object.shopid[ll_row] 		= gs_shopid
		dw_split.Object.operator[ll_row] 	= ls_operator
		dw_split.Object.customerid[ll_row] 	= ls_customerid
		dw_split.Object.itemcod[ll_row] 		= dw_master.Object.itemcod[ll]
		dw_split.Object.paymethod[ll_row] 	= '101'
		dw_split.Object.regcod[ll_row] 		= dw_master.Object.regcod[ll]
		dw_split.Object.payamt[ll_row] 		= ldc_payamt
		dw_split.Object.basecod[ll_row] 		= ls_basecod
		dw_split.Object.paycnt[ll_row] 		= 1
		dw_split.Object.payid[ll_row] 		= ls_payid
		dw_split.Object.trdt[ll_row] 			= ldt_paydt
		dw_split.Object.dctype[ll_row] 		= 'D'
		dw_split.Object.trcod[ll_row] 		= ls_trcod_det
		dw_split.Object.sale_trcod[ll_row] 	= ls_trcod_det
		dw_split.Object.remark[ll_row] 		= ls_remark
		dw_split.Object.taxamt[ll_row]      = ld_taxamt
		
	NEXT
ELSE
	
	FOR ll = 1 TO ll_cnt
		ldc_tramt	= dw_master.object.bill_amt[ll]
// 2019.04.25 Vat 추가		
		ld_sale_tot = dw_master.Object.bill_amt[ll] + dw_master.Object.vat_amt[ll]
		ld_vat      = dw_master.Object.vat_amt[ll]
		ldc_saleamt = dw_master.object.bill_amt[ll]

		ldc_income 	= 0
		li_first 	= 0
		li_chk 		= 0
		li_update 	= 0

		IF ldc_impack <> 0 THEN
			ldc_imnot = dw_master.object.impack_not[ll]
			ldc_im	 = dw_master.object.impack_card[ll]
		END IF		
			
		IF ldc_impack > 0 THEN
			IF ldc_im > 0 THEN
				IF li_first 	= 0 THEN
					li_paycnt 	= 1
					li_first 	= 1
				ELSE
					li_paycnt 	= 0
				END IF				
		
				IF ldc_impack - ldc_im < 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
					ldc_tramt = ldc_tramt - ldc_impack				//IMPACK 카드 금액을 제외하기 위하여
					ldc_impack_in = ldc_impack
					ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
				ELSE
					ldc_impack = ldc_impack - ldc_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
					ldc_tramt  = ldc_imnot							//IMPACK 카드 금액을 제외하기 위하여
					ldc_impack_in = ldc_im									
				END IF

				li_update = 1		
			END IF
		ELSEIF ldc_impack < 0 THEN
			IF ldc_im <> 0 THEN			
				IF li_first 	=  0 THEN
					li_paycnt 	= 1
					li_first 	= 1
				ELSE
					li_paycnt 	= 0
				END IF			

				IF ldc_impack - ldc_im > 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
					ldc_tramt = ldc_tramt - ldc_impack		//IMPACK 카드 금액을 제외하기 위하여
					ldc_impack_in = ldc_impack
					ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
				ELSE
					ldc_impack = ldc_impack - ldc_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
					ldc_tramt  = ldc_imnot							//IMPACK 카드 금액을 제외하기 위하여
					ldc_impack_in = ldc_im
				END IF
				
				li_update = 1
			END IF
		END IF
			
		IF li_update = 1 THEN
			ll_row =  dw_split.InsertRow(0)
			//---------------------------------------
			dw_split.Object.paydt[ll_row] 		= ldt_paydt
			dw_split.Object.shopid[ll_row] 		= gs_shopid
			dw_split.Object.operator[ll_row] 	= ls_operator
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			dw_split.Object.itemcod[ll_row] 		= dw_master.Object.itemcod[ll]				
			dw_split.Object.paymethod[ll_row] 	= ls_method0_im
			dw_split.Object.regcod[ll_row] 		= dw_master.Object.regcod[ll]
			dw_split.Object.payamt[ll_row] 		= ldc_impack_in
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
			dw_split.Object.dctype[ll_row] 		= 'D'
			dw_split.Object.trcod[ll_row] 		= ls_trcod_im
			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod_im
			dw_split.Object.remark[ll_row] 		= ls_remark	
			
			ldc_receive 	 = ldc_receive - ldc_impack_in			
		END IF	
			//-------------------------------------------------------------------------
			//입금내역 처리  Start........
			//-------------------------------------------------------------------------

// 2019.04.24 Item별 taxrate를 가져온다 Modified by Han
			ls_itemcod = dw_master.Object.itemcod[ll]
			SELECT FNC_GET_TAXRATE(:ls_customerid, 'I', :ls_itemcod, :ldt_paydt)
			  INTO :ld_taxrate
			  FROM DUAL;

			IF ld_taxrate <> 0 then
				//합계액으로 공급가액과 부가세를 나눠주는 공식임.
				ld_taxrate = 1 + ( ld_taxrate / 100)
			ELSE
				// 0으로 나눠주면 에러남
				ld_taxrate = 1
			END IF

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
//					IF ldc_rem - ldc_tramt <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
					IF ldc_rem - ld_sale_tot <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
//						ldc_saleamt	 = ldc_rem						//품목금액을 넣는다.
//						ldc_tramt = ldc_tramt - ldc_rem	//loop 를 돌리기 위해서
// 2019.04.24 Vat 처리 추가
							ldc_saleamt	 = round(ldc_rem / ld_taxrate, 2) // 품목공급금액을 넣는다.
							ld_taxamt    = ldc_rem - ldc_saleamt          // 부가세
							ld_sale_tot  = ld_sale_tot - ldc_rem	       // loop 를 돌리기 위해서

						IF li_pay_cnt = ii_method_cnt THEN				//나누기 처리는 다 끝났다는 신호!
							ls_end = 'Y'								//나누기 처리 끝...
							IF ld_sale_tot <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
								ls_add = 'Y'
							END IF
						END IF	
						ldc_rem		 = 0								//수납금액을 0으로
						li_pay_cnt	+= 1		
					ELSE													//수납유형에 돈이 남아있으면...다음 아이템으로						
//						ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//						ldc_saleamt	 = ldc_tramt				//품목금액을 넣는다.
//						ldc_tramt = 0								//loop 를 빼기 위해서!		
						ldc_rem		 = ldc_rem - ld_sale_tot	       // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
						ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
						ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
						ld_sale_tot  = 0				                   // loop 를 빼기 위해서!		
					END IF
				ELSEIF ldc_rem < 0 THEN								//수납유형에 - 금액이면
					IF ldc_rem - ld_sale_tot >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
						ldc_saleamt	 = round(ldc_rem / ld_taxrate, 2) // 품목금액을 넣는다.
						ld_taxamt    = ldc_rem - ldc_saleamt           // 부가세
						ld_sale_tot  = ld_sale_tot - ldc_rem          // loop 를 돌리기 위해서

						IF li_pay_cnt = ii_method_cnt THEN				//나누기 처리는 다 끝났다는 신호!
							ls_end = 'Y'								//나누기 처리 끝...
							IF ld_sale_tot <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
								ls_add = 'Y'
							END IF
						END IF
						ldc_rem		 = 0								//수납유형에 있는 금액에서 아이템 금액을 빼준다.													
						li_pay_cnt	+= 1												
					ELSE
//						ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//						ldc_saleamt	 = ldc_tramt				//품목금액을 넣는다.
//						ldc_tramt = 0								//loop 를 빼기 위해서!	
						ldc_rem		 = ldc_rem - ld_sale_tot          // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
						ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
						ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
						ld_sale_tot  = 0                              // loop 를 빼기 위해서!	
					END IF						
				ELSE														//아이템은 있는데 수납이 다 까졌을 때...
					ldc_saleamt  = ld_sale_tot - ld_vat              // 품목금액을 넣는다.
					ld_taxamt    = ld_vat                            //부가세
					ld_sale_tot  = 0									       //loop 를 빼기 위해서!
					ls_method    = '101'								       //cash
				END IF					
		
				ll_row =  dw_split.InsertRow(0)
				//---------------------------------------
				dw_split.Object.paydt[ll_row] 		= ldt_paydt
				dw_split.Object.shopid[ll_row] 		= gs_shopid
				dw_split.Object.operator[ll_row] 	= ls_operator
				dw_split.Object.customerid[ll_row] 	= ls_customerid
				dw_split.Object.itemcod[ll_row] 		= dw_master.Object.itemcod[ll]
				dw_split.Object.paymethod[ll_row] 	= ls_method
				dw_split.Object.regcod[ll_row] 		= dw_master.Object.regcod[ll]
				dw_split.Object.payamt[ll_row] 		= ldc_saleamt
				dw_split.Object.basecod[ll_row] 		= ls_basecod
				dw_split.Object.paycnt[ll_row] 		= li_paycnt
				dw_split.Object.payid[ll_row] 		= ls_payid
				dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
				dw_split.Object.dctype[ll_row] 		= 'D'
				dw_split.Object.trcod[ll_row] 		= ls_trcod
				dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
				dw_split.Object.remark[ll_row] 		= ls_remark
				dw_split.Object.taxamt[ll_row]      = ld_taxamt
				
				IF ls_add = 'Y' THEN
//					ls_method = '101'
//					ll_row =  dw_split.InsertRow(0)
//					//---------------------------------------
//					dw_split.Object.paydt[ll_row] 		= ldt_paydt
//					dw_split.Object.shopid[ll_row] 		= gs_shopid
//					dw_split.Object.operator[ll_row] 	= ls_operator
//					dw_split.Object.customerid[ll_row] 	= ls_customerid						
//					dw_split.Object.itemcod[ll_row] 		= dw_master.Object.itemcod[ll]
//					dw_split.Object.paymethod[ll_row] 	= ls_method
//					dw_split.Object.regcod[ll_row] 		= dw_master.Object.regcod[ll]
//					dw_split.Object.payamt[ll_row] 		= ldc_saleamt
//					dw_split.Object.basecod[ll_row] 		= ls_basecod
//					dw_split.Object.paycnt[ll_row] 		= li_paycnt
//					dw_split.Object.payid[ll_row] 		= ls_payid
//					dw_split.Object.trdt[ll_row] 			= idt_shop_closedt
//					dw_split.Object.dctype[ll_row] 		= 'D'
//					dw_split.Object.trcod[ll_row] 		= ls_trcod
//					dw_split.Object.sale_trcod[ll_row] 	= ls_trcod
//					dw_split.Object.remark[ll_row] 		= ls_remark					
				END IF					
				
				ldc_receive 	 = ldc_receive - ld_sale_tot
				
				idc_amt[li_pp]	= ldc_rem										
				IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
					li_chk = 1
					exit
				END IF					
				
				IF li_pay_cnt > ii_method_cnt then exit
			NEXT
		END IF
		IF	ldc_total >= 0 THEN
			IF ldc_receive <= 0 then EXIT		
		ELSE
			IF ldc_receive >= 0 then EXIT
		END IF
	NEXT
END IF

dw_split.AcceptText()

return 0
end function

on ubs_w_pop_mobilepayment.create
int iCurrent
call super::create
this.dw_master=create dw_master
this.p_save=create p_save
this.dw_split=create dw_split
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
this.Control[iCurrent+2]=this.p_save
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.gb_1
end on

on ubs_w_pop_mobilepayment.destroy
call super::destroy
destroy(this.dw_master)
destroy(this.p_save)
destroy(this.dw_split)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 신규, 기기변경 수납 팝업            //
// Name       : ubs_w_pop_mobilepayment                    //
// contents   : 신규, 기기변경시 수납을 입력할 수 있다.    //
// call Window: ubs_w_reg_mobileorder                      // 
// 작성일자   : 2009.03.20                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

datawindow ldw_data[]
Long   	ll_row,      		ll_item, 		 ll_priority,		ll_deposit_cnt, ll_item_cnt
String 	ls_ref_desc, 		ls_temp, 		 ls_method[],		ls_trcod[],	 	ls_customernm,		&
		 	ls_memberid,	   ls_itemnm,	  	 ls_regcod,			ls_itemcod,    ls_trcod_item
DEC{2}	ldc_bilamt

// 2019.04.25 Vat 처리에 따른 변수 추가 Modified by Han
string   ls_surtaxyn
dec{2}   ld_vat_amt

iu_cust_db_app = Create u_cust_db_app

is_amt_check = 'N'    //amount check 값 기본 세팅!

//ubs_w_shop_reg_mobileorder payment 버튼 클릭시 넘어오는 값
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = "Mobile Contract Payment"
////iu_cust_msg.is_grp_name = ""
//iu_cust_msg.is_data[1] = "CloseWithReturn"
//iu_cust_msg.il_data[1] = 1  		//현재 row
//iu_cust_msg.il_data[2] = 1  		//item 갯수
//iu_cust_msg.idw_data[1] = dw_master
//iu_cust_msg.is_data[2] = ls_customerid
//iu_cust_msg.is_data[3] = ls_customernm
//iu_cust_msg.is_data[4] = ls_phone_type
//iu_cust_msg.is_data[5] = ls_save_check		//save 횟수 제한
//iu_cust_msg.is_data2[1] = ls_itemcod[1]  //item 값을 갯수만큼 배열로 넘김
//iu_cust_msg.ic_data[1] = lc_billamt[1]  //item 값을 갯수만큼 배열로 넘김

dw_hlp.InsertRow(0)

is_customerid = iu_cust_help.is_data[2]
ls_customernm = iu_cust_help.is_data[3]
is_phone_type = iu_cust_help.is_data[4]
is_save_check = iu_cust_help.is_data[5]

This.Title =  iu_cust_help.is_pgm_name 

IF iu_cust_help.is_pgm_name = 'Payment_Refund' THEN
	is_minus_check = 'Y'
ELSE
	is_minus_check = 'N'
END IF

dw_hlp.Object.customerid[1] = is_customerid
dw_hlp.Object.customernm[1] = ls_customernm

IF ISNULL(is_customerid) THEN is_customerid = ""

IF is_customerid <> "" THEN
	SELECT MEMBERID INTO :ls_memberid
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :is_customerid;
	
	dw_hlp.Object.memberid[1] = ls_memberid
END IF

ll_item_cnt = iu_cust_help.il_data[2] 
FOR ll_item = 1 TO iu_cust_help.il_data[2]      //1번째 부터 itemcod 갯수만큼...
	IF ISNULL(iu_cust_help.is_data2[ll_item]) = FALSE THEN
		ll_row = dw_master.InsertRow(0)
		
		ls_itemcod = iu_cust_help.is_data2[ll_item]		
		ldc_bilamt = iu_cust_help.ic_data[ll_item]
// 2019.04.25 Vat 항목 추가 modified by Han 
//////////////////////////////////////////////////////
//      For 문을 돌리는 이유가 전혀 없어 보임. 
//      해당 화면 호출시 1건만 넘겨주고 있슴
//////////////////////////////////////////////////////
		ld_vat_amt = iu_cust_help.ic_data[ll_item +ll_item_cnt]

		dw_master.Object.itemcod[ll_row]  = ls_itemcod
		dw_master.Object.bill_amt[ll_row] = ldc_bilamt
// 2019.04.25 Vat 항목 추가 Modified by Han
		dw_master.Object.vat_amt [ll_row ] = ld_vat_amt
		
		
		SELECT ITEMNM, PRIORITY, REGCOD, TRCOD INTO :ls_itemnm, :ll_priority, :ls_regcod, :ls_trcod_item
		FROM   ITEMMST
		WHERE  ITEMCOD = :ls_itemcod;
		
		dw_master.Object.itemnm[ll_row] 	 = ls_itemnm		
		dw_master.Object.priority[ll_row] = ll_priority
		dw_master.Object.regcod[ll_row] 	 = ls_regcod
		dw_master.Object.trcod[ll_row] 	 = ls_trcod_item
		
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM  = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
				  
		IF ll_deposit_cnt <= 0 THEN			//DEPOSIT 이 아니라면
			dw_master.Object.impack_card[ll_row] 	= ROUND(ldc_bilamt * 0.1, 2)
			dw_master.Object.impack_not[ll_row] 	= ROUND(ldc_bilamt - ROUND( ldc_bilamt * 0.1, 2 ), 2)
			dw_master.Object.impack_check[ll_row] 	= 'A'
		ELSE
			dw_master.Object.impack_card[ll_row] 	= 0
			dw_master.Object.impack_not[ll_row] 	= ldc_bilamt
			dw_master.Object.impack_check[ll_row] 	= 'B'
		END IF
	ELSE
		EXIT
	END IF
NEXT		
//ITEM CODE 가 다 표시 되었으면 SUM 금액을 dw_hlp.total 로 옮긴다.
wf_set_total()

//POS 관련
F_INIT_DSP(1,"","")
//SHOP CLOSEDT 가져오는 함수
idt_shop_closedt 	= f_find_shop_closedt(gs_shopid)

dw_hlp.object.paydt[1]	= idt_shop_closedt

SELECT TO_CHAR(:idt_shop_closedt, 'YYYYMMDD') INTO :is_paydt
FROM   DUAL;

//dw_hlp.PayMethod1 ~ 6 에 다음 값을 표시 한다. 101, 102, 103, 104, 105, 107
ls_ref_desc = ""
ls_temp     = fs_get_control("B5", "I101", ls_ref_desc)

IF ls_temp  = "" THEN RETURN

fi_cut_string(ls_temp, ";", ls_method[])

dw_hlp.object.paymethod1[1] = ls_method[1]
dw_hlp.object.paymethod2[1] = ls_method[2]
dw_hlp.object.paymethod3[1] = ls_method[3]
dw_hlp.object.paymethod4[1] = ls_method[4]
dw_hlp.object.paymethod5[1] = ls_method[5]
dw_hlp.object.paymethod6[1] = ls_method[6]

//dw_hlp.trcode1 ~ 6 에 다음 값을 표시 한다.
ls_ref_desc = ""
ls_temp  	= fs_get_control("B5", "I102", ls_ref_desc)

IF ls_temp  = "" THEN RETURN

fi_cut_string(ls_temp, ";", ls_trcod[])

dw_hlp.object.trcode1[1] = ls_trcod[1]
dw_hlp.object.trcode2[1] = ls_trcod[2]
dw_hlp.object.trcode3[1] = ls_trcod[3]
dw_hlp.object.trcode4[1] = ls_trcod[4]
dw_hlp.object.trcode5[1] = ls_trcod[5]
dw_hlp.object.trcode6[1] = ls_trcod[6]

dw_hlp.SetFocus()
dw_hlp.setColumn("amt1")

IF is_save_check = 'Y' THEN   //이미 수납했다면 SAVE 버튼 비활성화
	is_amt_check = 'Y'
	p_save.TriggerEvent("ue_disable")
END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_hlp.SetItemStatus(1, 0, Primary!, NotModified!)

end event

event ue_close();iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김
iu_cust_help.is_data[2] = is_paydt

Destroy iu_cust_db_app

Close( This )
end event

event closequery;call super::closequery;Int li_rc

dw_hlp.AcceptText()

If (dw_hlp.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

event close;call super::close;iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김
iu_cust_help.is_data[2] = is_paydt
iu_cust_help.is_data[3] = is_appseq
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_mobilepayment
boolean visible = false
integer x = 2258
integer y = 1644
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_mobilepayment
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_mobilepayment
boolean visible = false
integer x = 2574
integer y = 1644
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_mobilepayment
integer x = 347
integer y = 1160
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_mobilepayment
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_mobilepayment
integer x = 41
integer y = 36
integer width = 1655
integer height = 1084
string dataobject = "ubs_dw_pop_mobilepayment_mas"
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_hlp::itemchanged;DEC{2}	ldc_100, 	ldc_90,			ldc_total
LONG 		ll_row,		ll_return
STRING	ls_paydt, 	ls_paydt_1,		ls_sysdate,		ls_paydt_c,		ls_empnm
DATE		ldt_paydt

dw_hlp.AcceptText()

CHOOSE CASE dwo.Name
	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impack(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
			END IF			
			wf_set_total()
		END IF
	CASE "paydt"
		ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
		ls_paydt  = String(ldt_paydt, 'yyyymmdd')
		
		SELECT TO_CHAR(TO_DATE(TO_CHAR(:ldt_paydt, 'yyyymmdd'), 'YYYYMMDD') + 1, 'YYYYMMDD'),
				 TO_CHAR(SYSDATE, 'YYYYMMDD'),
				 REPLACE(:data, '-', '') 
		INTO   :ls_paydt_1, :ls_sysdate, :ls_paydt_c
		FROM   DUAL;
		
		IF ls_paydt_c > ls_paydt_1 OR ls_paydt_c < ls_paydt THEN
			dw_hlp.object.paydt[row]	= ldt_paydt
			f_msg_usr_err(9000, Title, "Pay Date 를 확인하세요!")
			dw_hlp.SetFocus()
			dw_hlp.SetRow(row)
			dw_hlp.SetColumn("paydt")
			RETURN 2
		END IF	
		
		is_paydt = ls_paydt_c

	CASE "operator"
		SELECT EMPNM INTO :ls_empnm
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			THIS.SetFocus()
			THIS.SetRow(row)
			THIS.object.operator[row]		= ""
			THIS.object.operatornm[row]	= ""
			THIS.SetColumn("operator")
			RETURN 2			
		END IF
		
		THIS.object.operatornm[row] = ls_empnm		
		
END CHOOSE

RETURN 0
end event

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::ue_init();//
end event

type dw_master from datawindow within ubs_w_pop_mobilepayment
integer x = 1714
integer y = 20
integer width = 1669
integer height = 1120
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_mobilepayment_det"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type p_save from u_p_save within ubs_w_pop_mobilepayment
integer x = 18
integer y = 1160
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Integer li_rc
Constant Int LI_ERROR = -1

//세이브 한번 했으면 리턴!
IF is_save_check = 'Y' THEN 
	is_amt_check = 'Y'
	F_MSG_USR_ERR(9000, Title, "이미 수납하셨습니다.")	
	RETURN -1
END IF

// 필수 입력값 체크 
PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3010, PARENT.Title, "Save")	
	RETURN LI_ERROR
ELSEIF li_rc = 0 THEN
		
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3000, PARENT.Title, "Save")	
END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_hlp.SetItemStatus(1, 0, Primary!, NotModified!)

PARENT.TRIGGEREVENT('ue_close')
end event

type dw_split from datawindow within ubs_w_pop_mobilepayment
boolean visible = false
integer x = 1842
integer y = 1068
integer width = 969
integer height = 148
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type gb_1 from groupbox within ubs_w_pop_mobilepayment
integer x = 18
integer y = 12
integer width = 1687
integer height = 1124
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

