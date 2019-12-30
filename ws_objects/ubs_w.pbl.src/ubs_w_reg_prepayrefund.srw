$PBExportHeader$ubs_w_reg_prepayrefund.srw
$PBExportComments$[jhchoi] 선수금 환불 - 2009.04.30
forward
global type ubs_w_reg_prepayrefund from w_a_hlp
end type
type dw_master from datawindow within ubs_w_reg_prepayrefund
end type
type p_save from u_p_save within ubs_w_reg_prepayrefund
end type
type dw_split from datawindow within ubs_w_reg_prepayrefund
end type
type gb_1 from groupbox within ubs_w_reg_prepayrefund
end type
type gb_2 from groupbox within ubs_w_reg_prepayrefund
end type
end forward

global type ubs_w_reg_prepayrefund from w_a_hlp
integer width = 3022
integer height = 1540
string title = ""
event ue_processvalidcheck ( ref integer ai_return )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
dw_master dw_master
p_save p_save
dw_split dw_split
gb_1 gb_1
gb_2 gb_2
end type
global ubs_w_reg_prepayrefund ubs_w_reg_prepayrefund

type variables
u_cust_db_app iu_cust_db_app

STRING 	is_print_check, 	is_amt_check, 	is_customerid, 	is_phone_type, 	&
       	is_paycod,			is_format,		is_reqdt,		 	is_method[], 		&
		   is_trcod[],			is_save_check
DATE 	 	idt_shop_closedt
DOUBLE	ib_seq
DEC{2} 	idc_amt[], 			idc_total, 		idc_income_tot
INTEGER 	ii_method_cnt


end variables

forward prototypes
public function integer wf_split (date paydt)
public function integer wf_split_new (date wfdt_paydt)
public subroutine wf_set_total ()
public function integer wf_set_impack (string as_data)
end prototypes

event ue_processvalidcheck;INTEGER 	li_return, 		li_rc, 					li_tmp
STRING 	ls_tmp,			ls_payid,				ls_method0[],			ls_trcod0[],		ls_operator,	&
			ls_paydt_c,		ls_sysdate,			 	ls_paydt_1,				ls_paydt,         ls_itemcod, ls_subitemcod
DATE 		ld_tmp, 			ldt_shop_closedt, 	ldt_paydt
DEC{2}	ldc_receive,	ldc_total,				ldc_card_total,		ldc_amt0[],			ldc_change,	&
			ldc_impack,		ldc_90,					ldc_card,				ldc_10,           ldc_currentpay, &
			ldc_amount, ldc_currentpay_m
LONG		li_method_cnt, li_lp,					ll_opr_cnt	


//입력 자료가 이상없는지 확인
If dw_hlp.AcceptText() < 1 Then
	F_MSG_USR_ERR(9000, Title, "입력자료에 이상이 있습니다.")	
	dw_hlp.SetFocus()
	ai_return = -1				
	Return
End If

ls_operator	= dw_master.Object.operator[1]

SELECT COUNT(*) 
INTO :ll_opr_cnt
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
ldc_card_total		= dw_hlp.Object.amt2[1] + dw_hlp.Object.amt3[1] + dw_hlp.Object.amt4[1] + dw_hlp.Object.amt5[1]
ls_itemcod        = dw_master.object.itemcod[1];
ldc_currentpay    = dw_master.object.currentpay[1];
ldc_amount        = dw_master.object.amount[1];

ldc_currentpay_m  	= dw_master.object.currentpay_m[1];
ls_subitemcod  	= dw_master.object.sub_itemcod[1];


//인터넷 이거나 모바일 지정품목이 없는경우
IF ((ls_itemcod = '048SSRT') OR (ls_itemcod = '049SSRT' AND ls_subitemcod = '' )) AND ldc_currentpay < ldc_amount THEN
	F_MSG_USR_ERR(9000, Title, "현재 선수금보다 환불 금액이 큽니다. 확인하세요.")
	dw_hlp.SetFocus()
	dw_hlp.SetRow(1)
	ai_return = -1
	RETURN	
END IF


// 모바일 지정품목이 있을때
IF ls_itemcod = '049SSRT' and ls_subitemcod <> '' THEN
	IF ldc_currentpay_m < ldc_amount THEN
		F_MSG_USR_ERR(9000, Title, "단말할부-현재 선수금보다 환불 금액이 큽니다. 확인하세요.")
		dw_hlp.SetFocus()
		dw_hlp.SetRow(1)
		ai_return = -1
	RETURN	
	END IF
END IF


							
//receive 금액 확인
IF ldc_receive <= 0 THEN
	F_MSG_USR_ERR(9000, Title, "입력한 금액이 적거나 마이너스입니다. 확인하세요.")
	dw_hlp.SetFocus()
	dw_hlp.SetRow(1)
	ai_return = -1
	RETURN
END IF

IF ldc_receive < ldc_total THEN
	F_MSG_USR_ERR(9000, Title, "받은 금액이 적습니다. 확인하세요.")
	dw_hlp.SetFocus()
	dw_hlp.SetRow(1)
	ai_return = -1
	RETURN	
END IF					

//messagebox("test", ls_subitemcod)
//ai_return = -1
//return


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
	//2013.03.25  RQ-UBS-201303-10 근거하여 수정 by hmk
	//dw_hlp.Object.amt5[1] = ldc_impack - ldc_90
	dw_hlp.Object.amt5[1] = ldc_10
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
SELECT COUNT(*) 
INTO :li_rc 
FROM CUSTOMERM 
WHERE CUSTOMERID = :ls_payid;

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
	IF ldc_amt0[li_lp] > 0 THEN
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

ll_row = dw_master.GetRow()

lb_check = fb_save_required(dw_master, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_process;STRING	ls_paydt,		ls_customerid,		ls_memberid,		ls_errmsg,		ls_appseq,		&
			ls_itemcod,		ls_paymethod,		ls_payamt,			ls_remark,		ls_operator, ls_sub_itemcod
INTEGER	li_rc,			li_cnt,				li_s
LONG		ll_return
DATE		ld_paydt
DEC{2}	ldc_payamt

dw_hlp.AcceptText()
dw_split.AcceptText()

ls_paydt			= String(dw_hlp.Object.paydt[1], '@@@@@@@@')
ld_paydt			= dw_hlp.Object.paydt[1]
ls_customerid	= dw_hlp.Object.customerid[1]
ls_memberid		= dw_hlp.Object.memberid[1]
ls_operator		= dw_master.Object.operator[1]

//영수증  번호 구하기...
SELECT SEQ_RECEIPT.NEXTVAL	
INTO :ls_appseq	
FROM DUAL;

IF SQLCA.SQLCODE < 0 THEN
	F_MSG_SQL_ERR(THIS.TITLE, " Sequence Error(seq_receipt)")
	ai_return = -1
	RETURN
END IF

li_cnt = dw_split.RowCount()

FOR li_s = 1 TO li_cnt
	ls_itemcod 		= dw_split.Object.itemcod[li_s]
	ls_paymethod 	= dw_split.Object.paymethod[li_s]
	ldc_payamt	 	= dw_split.Object.payamt[li_s]
	ls_remark	 	= String(dw_split.Object.remark[li_s])	
	ls_sub_itemcod = dw_master.object.sub_itemcod[1]  //지정반영품목(지정품목을 선택하면 청구반영시 해당품목으로만 차감한다.)
	
	ls_errmsg = space(1000)
	SQLCA.UBS_REG_PREPAYDET(gs_shopid,		ld_paydt,		ls_customerid,					ls_itemcod,		&
									ls_paymethod, 	ldc_payamt,		ls_remark, 						ls_appseq,		&
									ls_operator,   gs_user_id,		'PREPAY'   , ls_sub_itemcod ,	ll_return,	ls_errmsg ) // gs_pgm_id[gi_open_win_no]
									

	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		ai_return = -1		
		RETURN
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
		ai_return = -1		
		RETURN
	END IF
NEXT

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

lu_dbmgr.uf_prc_db_03()

li_rc	= lu_dbmgr.ii_rc

IF li_rc < 0 THEN
	DESTROY lu_dbmgr
	dw_hlp.SetColumn("amt1")
	RETURN
END IF

p_save.TriggerEvent("ue_disable")
dw_cond.Enabled = False
is_amt_check = 'Y'

DESTROY lu_dbmgr

ai_return = 0

RETURN
end event

public function integer wf_split (date paydt);LONG		ll, 				ll_cnt,			ll_row
INTEGER 	li_pay_cnt, 	li_pp,			li_first,			li_paycnt, 		li_chk
DEC{2}  	ldc_saleamt,	ldc_rem,			ldc_tramt, 			ldc_income,		ldc_receive, &
			ldc_total,		ldc_rem_prc, 	ldc_receive_org,	ldc_total_prc
STRING 	ls_method,		ls_basecod, 	ls_customerid,		ls_payid, 		ls_trcod, &
			ls_saletrcod, 	ls_remark

li_pay_cnt 	= 1

dw_hlp.AcceptText()
//dw_master.SetSort("Priority A")
//dw_master.Sort()

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
	ldc_tramt	= dw_master.object.amount[ll]

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
			dw_split.Object.remark[ll_row] 		= ls_remark
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

li_pay_cnt 	= 1

dw_hlp.AcceptText()
dw_master.AcceptText()

ls_remark 	= dw_hlp.object.remark[1]
ls_operator = dw_master.object.operator[1]
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
	dw_master.SetSort('priority A')
ELSE
	dw_master.SetSort('priority D')	
END IF

dw_master.Sort()

ldc_total_prc	 = 0

//customerm Search
select basecod 
INTO :ls_basecod 
from customerm  
where customerid =  :ls_customerid ;

ll_cnt 				= dw_master.RowCount()

ls_add = 'N'
ls_end = 'N'

IF ll_cnt > 0 and ldc_total = 0 then
	//total = 0 인 경우 즉, (+, -) 값에 의해 항목들이 있으나 총계는 0인 경우 cash로 저장
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_master.object.amount[ll]
		ls_trcod_det	= dw_master.Object.trcod[ll]
		
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
	NEXT
ELSE
	
	FOR ll = 1 TO ll_cnt
		ldc_tramt	= dw_master.object.amount[ll]
		ldc_income 	= 0
		li_first 	= 0
		li_update 	= 0				
		li_chk 		= 0

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
						ldc_saleamt	 = ldc_rem						//품목금액을 넣는다.
						ldc_tramt = ldc_tramt - ldc_rem	//loop 를 돌리기 위해서
						IF li_pay_cnt = ii_method_cnt THEN				//나누기 처리는 다 끝났다는 신호!
							ls_end = 'Y'								//나누기 처리 끝...
							IF ldc_tramt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
								ls_add = 'Y'
							END IF
						END IF	
						ldc_rem		 = 0								//수납금액을 0으로
						li_pay_cnt	+= 1		
					ELSE													//수납유형에 돈이 남아있으면...다음 아이템으로						
						ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
						ldc_saleamt	 = ldc_tramt				//품목금액을 넣는다.
						ldc_tramt = 0								//loop 를 빼기 위해서!		
					END IF
				ELSEIF ldc_rem < 0 THEN								//수납유형에 - 금액이면
					IF ldc_rem - ldc_tramt >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
						ldc_saleamt	 = ldc_rem						//품목금액을 넣는다.
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
						ldc_rem		 = ldc_rem - ldc_tramt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
						ldc_saleamt	 = ldc_tramt				//품목금액을 넣는다.
						ldc_tramt = 0								//loop 를 빼기 위해서!	
					END IF						
				ELSE														//아이템은 있는데 수납이 다 까졌을 때...
					ldc_saleamt  = ldc_tramt					//품목금액을 넣는다.
					ldc_tramt = 0									//loop 를 빼기 위해서!
					ls_method = '101'								//cash
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
				
				ldc_receive 	 = ldc_receive - ldc_saleamt
				
				idc_amt[li_pp]	= ldc_rem										
				IF ldc_tramt = 0 then  //해당품목이 완납인 경우 다음 품목 처리 
					li_chk = 1
					exit
				END IF					
				
				IF li_pay_cnt > ii_method_cnt then exit
			NEXT
		END IF
		IF ldc_receive <= 0 then EXIT		
	NEXT
END IF

dw_split.AcceptText()

return 0
end function

public subroutine wf_set_total ();DEC{2}	ldc_total

ldc_total = dw_master.Object.amount[1]

dw_hlp.Object.total[1] = ldc_total

F_INIT_DSP(2, "", String(ldc_total))

RETURN
end subroutine

public function integer wf_set_impack (string as_data);RETURN 0
end function

on ubs_w_reg_prepayrefund.create
int iCurrent
call super::create
this.dw_master=create dw_master
this.p_save=create p_save
this.dw_split=create dw_split
this.gb_1=create gb_1
this.gb_2=create gb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
this.Control[iCurrent+2]=this.p_save
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.gb_1
this.Control[iCurrent+5]=this.gb_2
end on

on ubs_w_reg_prepayrefund.destroy
call super::destroy
destroy(this.dw_master)
destroy(this.p_save)
destroy(this.dw_split)
destroy(this.gb_1)
destroy(this.gb_2)
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
Long   ll_row,      ll_item,  ll_priority
String ls_ref_desc, ls_temp, 	ls_method[], 	ls_trcod[], 	ls_customernm,		ls_memberid
Dec{2} ldc_prepay, ldc_mobile

iu_cust_db_app = Create u_cust_db_app

is_amt_check = 'N'    //amount check 값 기본 세팅!

//ubs_w_reg_prepay insert 버튼 클릭시 넘어오는 값
//iu_cust_msg 				= CREATE u_cust_a_msg
//iu_cust_msg.is_pgm_name = "Pre-Payment"
//iu_cust_msg.is_data[1]  = "CloseWithReturn"
//iu_cust_msg.il_data[1]  = ll_row  				//현재 row
//iu_cust_msg.idw_data[1] = dw_master
//iu_cust_msg.idw_data[2] = dw_detail
//iu_cust_msg.is_data[2]  = ls_payid
//iu_cust_msg.is_data[3]  = ls_customernm
//iu_cust_msg.is_data[4]  = ""						//이 화면에서는 사용 안함
//iu_cust_msg.is_data[5]  = ls_save_check
////품목넘김
//iu_cust_msg.il_data[2]  = 1			//item 갯수
//iu_cust_msg.is_data2[1] = "014SSRT" //기본으로 itemcod는 Pre-Payment Amount(INT)
//iu_cust_msg.ic_data[1]  = 0	   	//

dw_hlp.InsertRow(0)

is_customerid = iu_cust_help.is_data[2]
ls_customernm = iu_cust_help.is_data[3]
is_phone_type = iu_cust_help.is_data[4]
is_save_check = iu_cust_help.is_data[5]

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.Object.customerid[1] = is_customerid
dw_hlp.Object.customernm[1] = ls_customernm

IF ISNULL(is_customerid) THEN is_customerid = ""

IF is_customerid <> "" THEN
	SELECT MEMBERID INTO :ls_memberid
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :is_customerid;
	
	dw_hlp.Object.memberid[1] = ls_memberid
END IF

//FOR ll_item = 1 TO iu_cust_help.il_data[2]      //1번째 부터 itemcod 갯수만큼...
//	IF ISNULL(iu_cust_help.is_data2[ll_item]) = FALSE THEN
//		ll_row = dw_master.InsertRow(0)		
//		dw_master.Object.itemcod[ll_row]  = iu_cust_help.is_data2[ll_item]
//	ELSE
//		EXIT
//	END IF
//NEXT		

// current Pre-Payment 값 세팅!
ldc_prepay = 0
ldc_mobile = 0
SELECT PREPAY_AMT, MOBILE_AMT INTO :ldc_prepay, :ldc_mobile
FROM   PREPAYMST 
WHERE  PAYID = :is_customerid;

dw_master.Object.currentpay[1] = ldc_prepay
dw_master.Object.currentpay_m[1] = ldc_mobile

//ITEM CODE 가 다 표시 되었으면 SUM 금액을 dw_hlp.total 로 옮긴다.
wf_set_total()

//POS 관련
F_INIT_DSP(1,"","")
//SHOP CLOSEDT 가져오는 함수
idt_shop_closedt 	= f_find_shop_closedt(gs_shopid)

dw_hlp.object.paydt[1]	= idt_shop_closedt

//dw_hlp.PayMethod1 ~ 5 에 다음 값을 표시 한다. 101, 102, 103, 104, 105, 107
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

//dw_hlp.trcode1 ~ 5 에 다음 값을 표시 한다.
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

dw_master.SetFocus()
dw_master.setColumn("operator")

//IF is_save_check = 'Y' THEN   //이미 수납했다면 SAVE 버튼 비활성화
//	is_amt_check = 'Y'
//	p_save.TriggerEvent("ue_disable")
//END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_hlp.SetItemStatus(1, 0, Primary!, NotModified!)

end event

event ue_close();iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

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
end event

type p_1 from w_a_hlp`p_1 within ubs_w_reg_prepayrefund
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_reg_prepayrefund
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_reg_prepayrefund
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_reg_prepayrefund
integer x = 347
integer y = 1292
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_reg_prepayrefund
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_reg_prepayrefund
integer x = 1321
integer y = 36
integer width = 1655
integer height = 1188
string dataobject = "ubs_dw_reg_prepayrefund_mas"
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_hlp::itemchanged;DEC{2}	ldc_100, ldc_90, ldc_total, ldc_10, ldc_amount
LONG 		ll_row
//DEC{2}	ldc_total
STRING	ls_paydt_1, ls_sysdate, ls_paydt_c, ls_paydt
DATE		ldt_paydt

dw_hlp.AcceptText()

CHOOSE CASE dwo.Name
	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
		
		ldc_amount = dw_master.Object.amount[1]
		
		IF ldc_amount <= 0 THEN 
			f_msg_usr_err(9000, Title, "AMOUNT 금액이 없거나 마이너스 입니다. 확인 하세요.")
			IF dwo.Name = "amt1" THEN
				dw_hlp.Object.amt1[row] = 0
			ELSEIF dwo.Name = "amt2" THEN
				dw_hlp.Object.amt2[row] = 0
			ELSEIF dwo.Name = "amt3" THEN
				dw_hlp.Object.amt3[row] = 0
			ELSEIF dwo.Name = "amt4" THEN
				dw_hlp.Object.amt4[row] = 0
			ELSEIF dwo.Name = "amt5" THEN
				dw_hlp.Object.amt5[row] = 0
			ELSEIF dwo.Name = "amt6" THEN
				dw_hlp.Object.amt6[row] = 0
			END IF
				
			dw_master.SetFocus()
			dw_master.SetRow(row)
			dw_master.SetColumn("amount")				
			RETURN 2				
		END IF
		
		IF dwo.Name = "amt5" THEN
			//90%는 Credit card 로 표시해준다
			ll_row = row
			ldc_100 	 =  dw_hlp.Object.amt5[row]
			ldc_total =  dw_hlp.Object.total[row]
			
			IF ldc_100 > ldc_total THEN 
				f_msg_usr_err(9000, Title, "Impact Card 금액은 Total 금액보다 클 수 없습니다!")
				dw_hlp.Object.credit[1]	= 0
				dw_hlp.Object.amt5[1]	= 0				
				dw_hlp.SetFocus()
				dw_hlp.SetRow(row)
				dw_hlp.SetColumn("amt5")				
				RETURN 2				
			END IF

			IF IsNull(ldc_100) THEN ldc_100 = 0
			IF ldc_100 <> 0 THEN
				ldc_90	= Round(ldc_100 * 0.9, 2)
				ldc_10   = Round(ldc_100 * 0.1, 2)
				//dw_hlp.Object.credit[1]	= ldc_90
				dw_hlp.Object.credit[1] = ldc_total - ldc_10
			END IF				
		END IF
		
		wf_set_total()

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
END CHOOSE		
		
RETURN 0
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::ue_init();//
end event

event dw_hlp::clicked;//상속막음.
end event

type dw_master from datawindow within ubs_w_reg_prepayrefund
integer x = 27
integer y = 24
integer width = 1248
integer height = 1192
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_prepayrefund_det"
boolean border = false
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

event itemchanged;DEC{2}	ldc_total, ldc_amount
STRING	ls_paydt_1, 	ls_sysdate, 	ls_paydt_c,			ls_paydt, 		ls_empnm, 	&
			ls_itemnm, 		ls_regcod, 		ls_trcod_item,		ls_itemcod
DATE		ldt_paydt
LONG		ll_priority, ll_deposit_cnt
integer li_exist
datawindowchild ldc_sub_item

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "amount"
		ldc_total  = THIS.Object.amount[row]
		ls_itemcod = THIS.Object.itemcod[row]
		dw_hlp.Object.total[1] = ldc_total
	
		F_INIT_DSP(2, "", String(ldc_total))
		
		IF ldc_total <> 0 THEN
				
			SELECT COUNT(*) INTO :ll_deposit_cnt
			FROM   DEPOSIT_REFUND
			WHERE ( IN_ITEM  = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
						  
			IF ll_deposit_cnt <= 0 THEN			//DEPOSIT 이 아니라면
				THIS.Object.impack_card[row] 	= ROUND(ldc_total * 0.1, 2)
				THIS.Object.impack_not[row] 	= ROUND(ldc_total - ROUND( ldc_total * 0.1, 2 ), 2)
				THIS.Object.impack_check[row] = 'A'
			ELSE
				THIS.Object.impack_card[row] 	= 0
				THIS.Object.impack_not[row] 	= ldc_total
				THIS.Object.impack_check[row] 	= 'B'
			END IF
		END IF		
		THIS.AcceptText()
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
		
	CASE "itemcod"
		ldc_amount = THIS.Object.amount[row]
			
		SELECT ITEMNM, PRIORITY, REGCOD, TRCOD INTO :ls_itemnm, :ll_priority, :ls_regcod, :ls_trcod_item
		FROM   ITEMMST
		WHERE  ITEMCOD = :data;
				
		THIS.Object.itemnm[row]   = ls_itemnm		
		THIS.Object.priority[row] = ll_priority
		THIS.Object.regcod[row]   = ls_regcod
		THIS.Object.trcod[row] 	  = ls_trcod_item
		
		IF ldc_amount <> 0 THEN
				
			SELECT COUNT(*) INTO :ll_deposit_cnt
			FROM   DEPOSIT_REFUND
			WHERE ( IN_ITEM  = :data OR OUT_ITEM = :data );
						  
			IF ll_deposit_cnt <= 0 THEN			//DEPOSIT 이 아니라면
				THIS.Object.impack_card[row] 	= ROUND(ldc_amount * 0.1, 2)
				THIS.Object.impack_not[row] 	= ROUND(ldc_amount - Round( ldc_amount * 0.1, 2 ), 2)
				THIS.Object.impack_check[row] 	= 'A'
			ELSE
				THIS.Object.impack_card[row] 	= 0
				THIS.Object.impack_not[row] 	= ldc_amount
				THIS.Object.impack_check[row] 	= 'B'
			END IF
		END IF
		//sub item retrieve()
			li_exist 	= this.GetChild("sub_itemcod", ldc_sub_item)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() :sub_item")
			//ls_filter = "svccod = '" + data  + "' " 

         this.object.sub_itemcod[1] = ""
			
			ldc_sub_item.SetTransObject(SQLCA)
			li_exist =ldc_sub_item.Retrieve()
			//ldc_sub_item.SetFilter(ls_filter)			//Filter정함
			//ldc_sub_item.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  

		
		THIS.AcceptText()
END CHOOSE
end event

event losefocus;DEC{2}	ldc_total

THIS.AcceptText()

ldc_total = THIS.Object.amount[1]

IF ldc_total >= 0 THEN	
	dw_hlp.Object.total[1] = ldc_total
	F_INIT_DSP(2, "", String(ldc_total))
END IF

RETURN 0
end event

type p_save from u_p_save within ubs_w_reg_prepayrefund
integer x = 18
integer y = 1292
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Integer li_rc
Constant Int LI_ERROR = -1

//세이브 한번 했으면 리턴!
//IF is_save_check = 'Y' THEN 
//	is_amt_check = 'Y'
//	F_MSG_USR_ERR(9000, Title, "이미 수납하셨습니다.")	
//	RETURN -1
//END IF

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

type dw_split from datawindow within ubs_w_reg_prepayrefund
boolean visible = false
integer x = 1838
integer y = 1168
integer width = 969
integer height = 224
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type gb_1 from groupbox within ubs_w_reg_prepayrefund
integer x = 1298
integer y = 8
integer width = 1687
integer height = 1224
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

type gb_2 from groupbox within ubs_w_reg_prepayrefund
integer x = 18
integer y = 8
integer width = 1275
integer height = 1224
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

