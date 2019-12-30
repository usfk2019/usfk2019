$PBExportHeader$ubs_w_reg_hotbill_contract_new_bac.srw
$PBExportComments$[jhchoi]  Hot Bill 계산 ( 부분핫빌 가능 ) - 2009.06.28
forward
global type ubs_w_reg_hotbill_contract_new_bac from w_a_reg_s
end type
type gb_3 from groupbox within ubs_w_reg_hotbill_contract_new_bac
end type
type p_cancel from u_p_cancel within ubs_w_reg_hotbill_contract_new_bac
end type
type cb_hotbill from commandbutton within ubs_w_reg_hotbill_contract_new_bac
end type
type dw_split from datawindow within ubs_w_reg_hotbill_contract_new_bac
end type
type hpb_1 from hprogressbar within ubs_w_reg_hotbill_contract_new_bac
end type
type cb_1 from commandbutton within ubs_w_reg_hotbill_contract_new_bac
end type
type dw_others from datawindow within ubs_w_reg_hotbill_contract_new_bac
end type
type p_1 from picture within ubs_w_reg_hotbill_contract_new_bac
end type
type cb_deposit from commandbutton within ubs_w_reg_hotbill_contract_new_bac
end type
end forward

global type ubs_w_reg_hotbill_contract_new_bac from w_a_reg_s
integer width = 5088
integer height = 2032
event type integer ue_cancel ( )
gb_3 gb_3
p_cancel p_cancel
cb_hotbill cb_hotbill
dw_split dw_split
hpb_1 hpb_1
cb_1 cb_1
dw_others dw_others
p_1 p_1
cb_deposit cb_deposit
end type
global ubs_w_reg_hotbill_contract_new_bac ubs_w_reg_hotbill_contract_new_bac

type variables
String	is_start[], 	is_hotflag, 	is_payid,	 	is_termdt, 		is_method[],	&
			is_trcod[], 	is_seq_app, 	is_reqnum,		is_save_check,	is_chargedt
DEC{2}	idc_total, 		idc_receive, 	idc_change, 	idc_refund, 	idc_amt[],		&
			idc_preamt,		idc_impack
Boolean	ib_save
Integer	il_cnt, 			ii_method_cnt
DATE		id_reqdt_next
end variables

forward prototypes
public subroutine wf_set_total ()
public function integer wf_split (date wfdt_paydt)
public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt)
public function integer wf_set_impack (string as_data)
public function integer wfi_preamt_chk (ref decimal al_preamt)
public subroutine wf_progress (integer wfi_cnt)
public function integer wf_split_new (date wfdt_paydt)
public function integer wf_non_payment ()
public function integer wf_refund (long wfl_row, date wfd_reqdt_next)
public subroutine wf_deposit_log ()
end prototypes

event ue_cancel;Integer li_return, i
Long ll_return
String ls_errmsg

ll_return = -1
ls_errmsg = space(256)
F_INIT_DSP(1,"","")


//UPDATE CONTRACTMST
//SET	 BILL_HOTBILLFLAG = NULL
//WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
//								FROM   CUSTOMERM A, CONTRACTMST B
//								WHERE  A.PAYID = :is_payid
//								AND    A.CUSTOMERID = B.CUSTOMERID
//								AND    B.BILL_HOTBILLFLAG = 'P' )
//AND    BILL_HOTBILLFLAG = 'P';

//당일 핫빌했다가 취소한 고객에 대해서 정리할 것...
UPDATE CONTRACTMST
SET	 BILL_HOTBILLFLAG = NULL
WHERE  CONTRACTSEQ IN ( SELECT CONTRACTSEQ
								FROM   HOTCONTRACT
								WHERE  PAYID = :is_payid 
								AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
AND	 BILL_HOTBILLFLAG IN ('P', 'R');

If SQLCA.SQLCode <> 0 Then		//For Programer
	MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ROLLBACK;
   Return -1
End If

SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ROLLBACK;	
   Return -1	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
	ROLLBACK;	
   Return -1
End If 

COMMIT;
f_msg_info(3000, Title, "HotBilling Cancel")

For i =1 To dw_detail.RowCount()
   dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

ib_save = true

TriggerEvent("ue_reset")  //리셋한다.

Return 0
end event

public subroutine wf_set_total ();dec{2} ldc_TOTAL

ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_total") +  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_vat")
dw_cond.Object.total[1] =  ldc_total

F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

public function integer wf_split (date wfdt_paydt);Long		ll, 					ll_cnt,			ll_row, 		ll_seq, 	ll_reqnum
Integer 	li_pay_cnt, 		li_pp,			li_first,	li_paycnt, li_chk
DEC{2}  	ldc_saleamt,		ldc_rem,			ldc_tramt, 	ldc_intot,	ldc_outtot, &
			ldc_amt0[], 		ldc_payamt, 	ldc_total, 	ldc_receive, &
			ldc_change, 		ldc_impack
String 	ls_method,			ls_basecod, 	ls_customerid, ls_payid, ls_trcod, ls_saletrcod, &
			ls_req_trdt, 		ls_dctype,		ls_ok,	&
			ls_method0[], 		ls_trcod0[], 	&
			ls_itemcod, 		ls_code, 		ls_codenm,		ls_memberid
date		ldt_trdt, 			ldt_shop_closedt, 	ldt_termdt, ldt_paydt
Integer  li_method_cnt, 	li_lp
Integer 	li_rtn
String 	ls_appseq, 			ls_seq, 					ls_prt, ls_regcod, ls_prepay, &
			ls_regtype,			ls_operator
Long		ll_shopcount,		ll_priority


//--------------------------------------------------------------------
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ldt_paydt 			= dw_cond.Object.paydt[1]
ldt_termdt 			= dw_cond.Object.termdt[1]
li_method_cnt 		= 0
ls_customerid 		= dw_cond.Object.payid[1]
ldc_impack 			= dw_cond.object.amt5[1] 
ls_operator			= dw_cond.object.operator[1] 


select memberid INTO :ls_memberid from customerm where customerid = :ls_customerid ;

IF IsNull(ls_memberid) then ls_memberid = ''

ls_payid 			= dw_cond.Object.payid[1]

IF ldc_impack = 0 THEN

	ldc_amt0[1] 		= dw_cond.object.amt3[1] 
	ldc_amt0[2] 		= dw_cond.object.amt2[1] 
	ldc_amt0[3] 		= dw_cond.object.amt5[1] 
	ldc_amt0[4] 		= dw_cond.object.amt4[1] 
	ldc_amt0[5] 		= dw_cond.object.amt1[1]
	
	ls_method0[1] 		= dw_cond.object.method3[1]
	ls_method0[2] 		= dw_cond.object.method2[1]
	ls_method0[3] 		= dw_cond.object.method5[1]
	ls_method0[4] 		= dw_cond.object.method4[1]
	ls_method0[5] 		= dw_cond.object.method1[1]
	
	ls_trcod0[1] 		= dw_cond.object.trcod3[1]
	ls_trcod0[2] 		= dw_cond.object.trcod2[1]
	ls_trcod0[3] 		= dw_cond.object.trcod5[1]
	ls_trcod0[4] 		= dw_cond.object.trcod4[1]
	ls_trcod0[5] 		= dw_cond.object.trcod1[1]
ELSE
	ldc_amt0[1] 		= dw_cond.object.amt5[1] 
	ldc_amt0[2] 		= dw_cond.object.amt3[1] 
	ldc_amt0[3] 		= dw_cond.object.amt2[1] 
	ldc_amt0[4] 		= dw_cond.object.amt4[1] 
	ldc_amt0[5] 		= dw_cond.object.amt1[1]
	
	ls_method0[1] 		= dw_cond.object.method5[1]
	ls_method0[2] 		= dw_cond.object.method3[1]
	ls_method0[3] 		= dw_cond.object.method2[1]
	ls_method0[4] 		= dw_cond.object.method4[1]
	ls_method0[5] 		= dw_cond.object.method1[1]
	
	ls_trcod0[1] 		= dw_cond.object.trcod5[1]
	ls_trcod0[2] 		= dw_cond.object.trcod3[1]
	ls_trcod0[3] 		= dw_cond.object.trcod2[1]
	ls_trcod0[4] 		= dw_cond.object.trcod4[1]
	ls_trcod0[5] 		= dw_cond.object.trcod1[1]
END IF
	
ii_method_cnt 		= 0 
ldc_payamt 			= 0
idc_total 			= 0
//-----------------------------------------------------
//customerm Search
select basecod INTO :ls_basecod from customerm
 where customerid =  :ls_customerid ;
 
//ll_cnt = dw_detail.RowCount()
dw_split.Reset()
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
// 입금종류 수 처리
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
FOR li_lp = 1 to 5
	IF ldc_amt0[li_lp] <> 0 then
		idc_total 						+= ldc_amt0[li_lp]
		ldc_payamt 						+= ldc_amt0[li_lp]
		ii_method_cnt 					+= 1
		idc_amt[ii_method_cnt] 		= ldc_amt0[li_lp]
		is_method[ii_method_cnt] 	= ls_method0[li_lp]
		is_trcod[ii_method_cnt] 	= ls_trcod0[li_lp]
	END IF
NEXT
li_pay_cnt = 1
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
dw_detail.AcceptText()

IF ldc_impack = 0 THEN
	dw_detail.SetSort('ss A, cp_amt A')
ELSE
	dw_detail.SetSort('priority A')
END IF
dw_detail.Sort()

ll_cnt 		= dw_detail.RowCount()
ldc_total 	= dw_cond.Object.total[1]
ldc_receive = dw_cond.Object.cp_receive[1]
IF ll_cnt > 0 and ldc_total = 0 then
	//total = 0 인 경우 즉, (+, -) 값에 의해 항목들이 있으나 총계는 0인 경우 cash로 저장
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_detail.object.cp_amt[ll]
		ls_dctype 		= trim(dw_detail.object.dctype[ll])
		ldc_tramt		= dw_detail.object.cp_amt[ll]
		ls_req_trdt  	= String(dw_detail.object.trdt[ll], 'yyyymmdd')
		ls_trcod 		=  dw_detail.Object.trcod[ll]
		ll_row 			=  dw_split.InsertRow(0)
		//---------------------------------------
		dw_split.Object.paydt[ll_row] 		= ldt_shop_closedt
		dw_split.Object.shopid[ll_row] 		= gs_shopid
		dw_split.Object.operator[ll_row] 	= ls_operator
		dw_split.Object.customerid[ll_row] 	= ls_customerid
			
		select itemcod, regcod, priority INTO :ls_itemcod, :ls_regcod, :ll_priority FROM itemmst
		 WHERE trcod = :ls_trcod ;
			
		dw_split.Object.itemcod[ll_row] 		= ls_itemcod
		dw_split.Object.paymethod[ll_row] 	= '101'
		dw_split.Object.sale_trcod[ll_row] 	= '900'
		dw_split.Object.paycnt[ll_row] 		= 1
		dw_split.Object.regcod[ll_row] 		= ls_regcod
		dw_split.Object.payamt[ll_row] 		= ldc_tramt
		dw_split.Object.basecod[ll_row] 		= ls_basecod //고객 base
		dw_split.Object.payid[ll_row] 		= ls_payid //고객
		dw_split.Object.trdt[ll_row] 			= ldt_termdt //요청일
		dw_split.Object.dctype[ll_row] 		= ls_dctype
		dw_split.Object.trcod[ll_row] 		= ls_trcod
		dw_split.Object.req_trdt[ll_row] 	= ls_req_trdt

	NEXT
ELSE
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_detail.object.cp_amt[ll]
		ldc_outtot 		+= ldc_payamt
		ls_dctype 		= trim(dw_detail.object.dctype[ll])
		ldc_tramt		= dw_detail.object.cp_amt[ll]
		ls_req_trdt  	= String(dw_detail.object.trdt[ll], 'yyyymmdd')
		li_first 		= 0
		li_chk 			= 0
		ls_ok				= 'N'
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		FOR li_pp =  li_pay_cnt to ii_method_cnt
				ls_method 		= is_method[li_pp]
				ls_saletrcod 	= is_trcod[li_pp]
				ldc_rem 			= idc_amt[li_pp]
	IF ldc_receive > 0 THEN
				IF ldc_rem >= ldc_tramt THEN
					ldc_saleamt 	=  ldc_tramt
					IF li_first 	=  0 then
						li_paycnt 	= 1
						li_first 	= 1
					else
						li_paycnt 	= 0
					END IF
					ldc_rem 			=  ldc_rem -  ldc_saleamt
					ldc_tramt 		= 0
				ELSE
					ldc_saleamt 	= ldc_rem
					ldc_tramt 		= ldc_tramt - ldc_rem
					ldc_rem			= 0
					IF li_first =  0 then
						li_paycnt 	= 1
						li_first 	= 1
					else
						li_paycnt 	= 0
					END IF
				END IF
	ELSE
				IF ldc_rem >= ldc_tramt THEN
					ldc_saleamt 	=  ldc_tramt
					IF li_first 	=  0 then
						li_paycnt 	= 1
						li_first 	= 1
					else 
						li_paycnt 	= 0
					END IF
					ldc_rem 			=  ldc_rem -  ldc_saleamt
					ldc_tramt 		= 0
				ELSE
					IF ldc_rem < 0 then
						ldc_saleamt 	= ldc_tramt
						ldc_rem			= ldc_rem - ldc_saleamt
						ldc_tramt		= 0
					ELSE
						ldc_saleamt 	= ldc_rem
						ldc_tramt 		= ldc_tramt - ldc_rem
						ldc_rem			= 0
					END IF
					IF li_first =  0 then
						li_paycnt 	= 1
						li_first 	= 1
					else
						li_paycnt 	= 0
					END IF
				END IF
	END IF
			ll_row =  dw_split.InsertRow(0)
			//---------------------------------------
			dw_split.Object.paydt[ll_row] 		= ldt_shop_closedt
			dw_split.Object.shopid[ll_row] 		= gs_shopid
			dw_split.Object.operator[ll_row] 	= ls_operator
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			
			ls_trcod =  dw_detail.Object.trcod[ll]
			select itemcod, regcod, priority INTO :ls_itemcod, :ls_regcod, :ll_priority FROM itemmst
			 WHERE trcod = :ls_trcod ;
			
			dw_split.Object.itemcod[ll_row] 		= ls_itemcod
			dw_split.Object.paymethod[ll_row] 	= ls_method
			dw_split.Object.regcod[ll_row] 		= ls_regcod
			dw_split.Object.payamt[ll_row] 		= ldc_saleamt
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= ldt_termdt
			dw_split.Object.dctype[ll_row] 		= ls_dctype
			dw_split.Object.trcod[ll_row] 		= ls_trcod
			dw_split.Object.sale_trcod[ll_row] 	= ls_saletrcod
			dw_split.Object.req_trdt[ll_row] 	= ls_req_trdt

			idc_total = idc_total - ldc_saleamt
			IF ldc_tramt = 0 then 
				li_chk = 1
				exit
			ELSE
				li_pay_cnt += 1
			END IF
			IF li_pay_cnt > ii_method_cnt then exit
		NEXT
		IF ldc_rem <> 0 THEN
			idc_amt[li_pay_cnt] = ldc_rem
		END IF
	NEXT
END IF

//li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
li_rtn = 1
//-------------------------------------------------------------
//2. 양수증발행정보 Insert ( RECEIPTMST)
//SEQ 

Select seq_receipt.nextval		  Into :ls_appseq						  From dual;

//SHOP COUNT
Select shopcount	    Into :ll_shopcount	  From partnermst
 WHERE partner = :GS_SHOPID ;
		
IF IsNull(ll_shopcount) THEN ll_shopcount = 0
If SQLCA.SQLCode < 0 Then
		RollBack;
		f_msg_sql_err(title, " Update Error(PARTNERMST)")
		Return -1
End If			
		
ll_shopcount += 1
IF li_rtn =  1 then
	//실 영수증 번호임.
	ls_prt = 'Y'
	Select seq_app.nextval		  Into :ls_seq						  From dual;
	If SQLCA.SQLCode < 0 Then
		RollBack;
		f_msg_sql_err(title,  " Sequence Error(seq_app)")
		Return -1
	End If
	is_seq_app = ls_seq
ELSE 
	ls_prt = 'N'
	ls_seq = ""
END IF
	
ldc_total 		= dw_cond.Object.total[1]
ldc_receive 	= dw_cond.Object.cp_receive[1]
ldc_change 		= dw_cond.Object.cp_change[1]

//--------------------------------------------
insert into RECEIPTMST
	( approvalno,		shopcount,				receipttype,	shopid,			posno,
	  workdt,			trdt,						
	  memberid,			operator,				total,
	  cash,				change, 
	  seq_app,			customerid,				prt_yn)
values 
   ( :ls_appseq, 		:ll_shopcount,			'100', 			:GS_SHOPID,		NULL,
	  :ldt_paydt,		:ldt_shop_closedt,	
	  :ls_memberid,	:ls_operator,			:ldc_total,
	  :ldc_receive, 	:ldc_change,
	  :ls_seq,			:ls_payid,				:ls_prt)	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
				RollBack;
				f_msg_sql_err(title, " Insert Error(RECEIPTMST)")
				Return -1
End If			
		
//ShopCount ADD 1
UPDATE partnermst
	SET shopcount 	= :ll_shopcount
 WHERE partner  	= :GS_SHOPID ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	RollBack;
	f_msg_sql_err(title, " Update  Error(PARTNERMST)")
	Return -1
End If		
//--------------------------------------------------
//3. Insert ( DAILYPAYMENT)
//--------------------------------------------------
Long		ll_payseq
Long 		ll_paycnt
date 		ldt_saledt


FOR li_lp =  1 to dw_split.RowCount()
	Select seq_dailypayment.nextval		  Into :ll_payseq  From dual;
	
	IF sqlca.sqlcode < 0 THEN
		f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
		RollBack;
		Return -1 
	END IF
	
	ls_itemcod 	= dw_split.Object.itemcod[li_lp]
	ls_method  	= dw_split.Object.paymethod[li_lp]
	ls_regcod  	= dw_split.Object.regcod[li_lp]
	ls_basecod  = dw_split.Object.basecod[li_lp]
	ldc_saleamt = dw_split.Object.payamt[li_lp]
	ldt_saledt  = date(dw_split.Object.paydt[li_lp])
	ldt_trdt  	= date(dw_split.Object.trdt[li_lp])
	ls_dctype 	= Trim(dw_split.Object.dctype[li_lp])
	dw_split.Object.payseq[li_lp] = ll_payseq
	
	insert into dailypayment
				( payseq,		paydt,			
				  shopid,		operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user, 
				  manual_yn,	PGM_ID)
	values 
			   ( :ll_payseq, 	:ldt_shop_closedt, 	
				  :GS_SHOPID, 	:ls_operator, 	:ls_payid,
				  :ls_itemcod,	:ls_method,		:ls_regcod,		:ldc_saleamt,	:ls_basecod,
				  1,				:ls_payid,		NULL,				:ldt_trdt,		NULL,
				  NULL,			:ls_dctype,		:ls_appseq,		sysdate,			sysdate,		:gs_user_id,
				  'N',			'HOTBILL' )	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
		RollBack;
		Return -1
	End If	
NEXT

String 	ls_lin1, ls_lin2, ls_lin3
String 	ls_empnm
DEC	 	ldc_shopCount
dec{2} 	ldc_cash
Integer 	jj
String 	ls_temp, ls_itemnm, ls_val
Integer 	li_cnt
Long		ll_keynum
String	ls_facnum, ls_chk
String 	ls_methodnm

ls_lin1 	= '------------------------------------------'
ls_lin2 	= '=========================================='
ls_lin3 	= '******************************************'

dw_detail.SetSort('itemcod A')
dw_detail.Sort()
//-------------------------------------------------------------
//IF ls_prt = 'Y' THEN
ldc_change = dw_cond.Object.cp_change[1]
//------------------------------------------------------------
//4. 영수증 발행
//마지막으로 영수증 출력........
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//FOR jj = 1  to 2
//		IF jj = 1 then 
			ldc_shopCount = f_pos_header(GS_SHOPID, 'A', LL_SHOPCOUNT, 1 )
//		ELSE 
//			ldc_shopCount = f_pos_header(GS_SHOPID,  'Z', LL_SHOPCOUNT, 0 )
//		END IF
		IF ldc_shopCount < 0 then
			Rollback ;
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			PRN_ClosePort()
			return  -1
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		ldc_total 	= 0
		ll_seq 		= 0
		FOR li_lp = 1 to dw_detail.RowCount()
				ll_seq 		+= 1
				ls_temp 		= String(li_lp, '000') + ' ' //순번
				ls_trcod 	= trim(dw_detail.Object.trcod[li_lp])
				ls_itemcod 	= trim(dw_detail.Object.itemcod[li_lp])
				ls_itemnm 	= trim(dw_detail.Object.itemnm[li_lp])
				ls_regcod 	= trim(dw_detail.Object.regcod[li_lp])
				
				ldc_saleamt	=  dw_detail.Object.cp_amt[li_lp]	
				ldc_total 	+= ldc_saleamt 
				ls_temp 		+= Left(ls_itemnm + space(24), 24) +  ' '   //아이템
				li_cnt 		=  1
				ls_temp 		+= Right(Space(4) + String(li_cnt), 4) + ' ' //수량
				ls_val 		=  fs_convert_amt(ldc_saleamt,  8)
				ls_temp 		+= ls_val //금액
				f_printpos(ls_temp)	
		
				//regcode master read
				SELECT keynum, 		trim(facnum)
				  INTO :ll_keynum,	:ls_facnum
				  FROM regcodmst
				 WHERE regcod 			= :ls_regcod ;
		
				IF IsNull(ll_keynum) or SQLCA.SQLCODE < 0 	then ll_keynum 	= 0
				IF IsNull(ls_facnum) or SQLCA.SQLCODE < 0  	then ls_facnum 	= ""
				ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
				f_printpos(ls_temp)
		NEXT
		f_printpos(ls_lin1)

		ls_val 	= fs_convert_sign(ldc_total, 8)
		ls_temp 	= Left("Grand Total" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
		//결제 수단별 금액 처리
		For li_lp = 1 To 5
			ldc_cash 	= ldc_amt0[li_lp]
			ls_code 		= ls_method0[li_lp]
			IF ldc_cash <> 0 then
				ls_val 	= fs_convert_sign(ldc_cash,  8)
				SELECT codenm 		INTO :ls_codenm 		FROM syscod2t
				 WHERE grcode 		= 'B310' 
				   AND code 		= :ls_code ;
				  
				ls_temp 	= Left(ls_codenm + space(33), 33) + ls_val
				f_printpos(ls_temp)
			EnD IF
		NEXT
		ls_val 	= fs_convert_sign(ldc_change,  8)
		ls_temp 	= Left("Changed" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
//		F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id) original
		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_seq,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 				
//NEXT  영수증 한장만 출력하도록 변경 2007-08-13 hcjung		
PRN_ClosePort()
RETURN 0
end function

public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt);String ls_non_svctype, ls_term_status, ls_ref_desc, ls_status, ls_name[], ls_req_status

//해지 상태코드 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
ls_term_status = ls_name[2]
ls_req_status 	= ls_name[1]

//비과금서비스type 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P103", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
ls_non_svctype = ls_name[1]

//선택한 계약중에 해지안된게 있는지 확인   AND  A.BILL_HOTBILLFLAG = 'P' 추가   
SELECT count(distinct a.contractseq)
INTO   :al_cnt
FROM   contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
AND    a.svccod = c.svccod          
AND    c.svctype <> '9' 
AND    b.payid = :is_payid	 
AND    A.BILL_HOTBILLFLAG = 'P'
AND    A.Status <> :ls_term_status
AND    a.contractseq not in (select distinct ref_contractseq
                             from   svcorder 
									  where  customerid = a.customerid
									  and  ( status = :ls_term_status or status = :ls_req_status)) ;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 1)")
	Return -1
End If	

SELECT to_char(nvl(max(a.bil_todt),sysdate),'yyyymmdd')
INTO   :as_bil_todt
FROM   contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
AND    a.svccod = c.svccod  
AND    A.BILL_HOTBILLFLAG = 'P'
AND    c.svctype <> :ls_non_svctype    
AND    b.payid = :is_payid	 
AND    a.status = :ls_term_status;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 2)")
	Return -1
End If	
 
return 0
end function

public function integer wf_set_impack (string as_data);LONG		ll_row1
INT		ii
DEC{2}	ldc_impack2,	ldc_impack3,	ldc_total,		ldc_impack,		ldc_impack_10
DEC      ldc_impack1
  
dw_detail.AcceptText()

ll_row1 = dw_detail.RowCount()

ldc_impack = DEC(as_data)										//카드 입력한 금액
ldc_impack_10 = ROUND(ldc_impack * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impack = 0 THEN
	RETURN -1
END IF

idc_impack = 0

FOR ii = 1 TO ll_row1
	ldc_impack1 = dw_detail.Object.impack_card[ii]	
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

ldc_total = dw_cond.Object.total[1]
dw_cond.Object.credit[1]	= ldc_total - ldc_impack_10

RETURN 0


end function

public function integer wfi_preamt_chk (ref decimal al_preamt);String  ls_chargedt, ls_trdt

//해당납입자 청구주기
SELECT BILCYCLE
  INTO :ls_chargedt
 FROM  billinginfo
WHERE customerid = :is_payid;	

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select billinginfo Error)")
	Return -1
End If	

//해당청구주기의 Hotbilling 해당 청구기준일
SELECT to_char(add_months(reqdt,1),'yyyymmdd')
  Into :ls_trdt
 FROM reqconf
WHERE chargedt = :ls_chargedt;	

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select reqconf Error)")
	Return -1
End If	

//전월미납액이 존재 하는지 check
SELECT nvl(sum(tramt),0)
  INTO :al_Preamt
  FROM reqdtl
 WHERE TO_CHAR(trdt,'yyyymmdd') < :ls_trdt
   AND payid = :is_payid ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select reqdtl Error)")
	Return -1
End If	
  
Return 0
end function

public subroutine wf_progress (integer wfi_cnt);INTEGER li_pcc

li_pcc =  Truncate(wfi_cnt/14 * 100 , 0)
IF li_pcc > 100 then li_pcc = 100
hpb_1.Position = li_pcc
Yield()
return
end subroutine

public function integer wf_split_new (date wfdt_paydt);//해지 화면..변경용... impact card 때문에 변경함...
Long		ll, 					ll_cnt,			ll_row, 		ll_seq, 	ll_reqnum, ll_contractseq, ll_log_cnt, ll_log_cnt1
string   ls_contractseq_bef , ls_contractseq
Integer 	li_pay_cnt, 		li_pp,			li_first,	li_paycnt, li_chk
dec      ldc_contractseq
DEC{2}  	ldc_saleamt,		ldc_rem,			ldc_tramt, 	ldc_intot,	ldc_outtot, &
			ldc_amt0[], 		ldc_payamt, 	ldc_total, 	ldc_receive, &
			ldc_change, 		ldc_impack
String 	ls_method,			ls_basecod, 	ls_customerid, ls_payid, ls_trcod, ls_saletrcod
string	ls_req_trdt, 		ls_dctype,		ls_ok,	ls_method0[], 		ls_trcod0[], 	ls_remark
string	ls_itemcod, 		ls_code, 		ls_codenm,		ls_memberid
date		ldt_trdt, 			ldt_shop_closedt, 	ldt_termdt, ldt_paydt
Integer  li_method_cnt, 	li_lp
Integer 	li_rtn
String 	ls_appseq, 			ls_seq, 					ls_prt, ls_regcod, ls_prepay, &
			ls_regtype,			ls_operator
Long		ll_shopcount,		ll_priority
//추가
STRING		ls_end,				ls_add  //ls_trcod_im,		ls_method0_im,
DEC{2}				ldc_impack_in//,		ldc_amt0_im, 	ldc_imnot,			ldc_im,
INT		li_update

Long     ll_cnt2, ll_totcnt_c, ll_acount,ll_totcnt_d, ll_totcnt 
Integer  li_reg_cnt, li_refund_cnt
String   ls_descript, ls_concession, ls_print_desc, ls_paydt, ls_item_name, ls_itemnm1, ls_itemnm2
Dec{2}   ldec_payamt, ldec_payamt2 , ldec_totpayamt_c,ldec_totpayamt_D, ldec_totpayamt
DEC{2}  ldc_vat, ldc_vat_in, ldc_taxamt, ld_tax_rate

//추가 2019.04.03 modified by Han
String   ls_surtaxyn, ls_cp_tot, ls_vat_tot
DEC{2}   ldc_cp_tot, ldc_vat_tot

//추가 2019.04.05 modified by Han
String   ls_mmyyyy

dw_cond.AcceptText()
dw_detail.AcceptText()
//--------------------------------------------------------------------
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ldt_paydt 			= dw_cond.Object.paydt[1]
ls_paydt          = string(dw_cond.Object.paydt[1],'YYYYMMDD') /*2014.08.21  김선주 ADD*/
ldt_termdt 			= dw_cond.Object.termdt[1]
li_method_cnt 		= 0
ls_customerid 		= dw_cond.Object.payid[1]
ldc_impack 			= dw_cond.object.amt5[1] 
ls_operator			= dw_cond.object.operator[1] 
//정렬 순서 조정. 토탈이 - 일경우 + 금액부터, +금액일 경우 - 금액부터
ldc_total 			= dw_cond.Object.total[1]
ldc_receive 		= dw_cond.Object.cp_receive[1]

//정렬순서 조정.
IF ldc_total > 0 THEN
//	IF ldc_impack > 0 THEN
////    핫빌시 임팩카드가 들어오면 세팅이 이상하게 꼬여서 정렬 순서 변경함. 2011.02.15 jhchoi		
////		dw_detail.SetSort('impack_check A, impack_card A, tramt A')
//		dw_detail.SetSort('tramt A')
//	ELSEIF ldc_impack < 0 THEN
//		dw_detail.SetSort('impack_check A, impack_card D, tramt A')
//	ELSE
		dw_detail.SetSort('tramt A')
//	END IF
ELSE
//	IF ldc_impack < 0 THEN
//		dw_detail.SetSort('impack_check A, impack_card D, tramt D')
//	ELSEIF ldc_impack > 0 THEN
//		dw_detail.SetSort('impack_check A, impack_card A, tramt D')
//	ELSE
		dw_detail.SetSort('tramt D')
//	END IF				
END IF

dw_detail.Sort()

select memberid INTO :ls_memberid from customerm where customerid = :ls_customerid ;

IF IsNull(ls_memberid) then ls_memberid = ''

ls_payid 			= dw_cond.Object.payid[1]

ldc_amt0[1] 		= dw_cond.object.amt3[1] 
ldc_amt0[2] 		= dw_cond.object.amt2[1] 
ldc_amt0[3] 		= dw_cond.object.amt4[1] 
ldc_amt0[4] 		= dw_cond.object.amt1[1]
ldc_amt0[5] 		= dw_cond.object.amt6[1]
	
ls_method0[1] 		= dw_cond.object.method3[1] 
ls_method0[2] 		= dw_cond.object.method2[1]
ls_method0[3] 		= dw_cond.object.method4[1]
ls_method0[4] 		= dw_cond.object.method1[1]
ls_method0[5] 		= dw_cond.object.method6[1]
	
ls_trcod0[1] 		= dw_cond.object.trcod3[1]  //credit card
ls_trcod0[2] 		= dw_cond.object.trcod2[1]  //check
ls_trcod0[3] 		= dw_cond.object.trcod4[1]  //milstar
ls_trcod0[4] 		= dw_cond.object.trcod1[1]  //cash
ls_trcod0[5] 		= dw_cond.object.trcod6[1]  //gift card

//IF ldc_impack <> 0 THEN 		
//	ls_trcod_im		= dw_cond.object.trcod5[1]
//	ls_method0_im	= dw_cond.object.method5[1]	
//	ldc_amt0_im		= dw_cond.object.amt5[1]			
//END IF
	
ii_method_cnt 		= 0 
ldc_payamt 			= 0
idc_total 			= 0
//-----------------------------------------------------
//customerm Search
select basecod INTO :ls_basecod from customerm
 where customerid =  :ls_customerid ;
 
//ll_cnt = dw_detail.RowCount()
dw_split.Reset()
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
// 입금종류 수 처리
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
FOR li_lp = 1 to 5
	IF ldc_amt0[li_lp] <> 0 then
		idc_total 						+= ldc_amt0[li_lp]
		ldc_payamt 						+= ldc_amt0[li_lp]
		ii_method_cnt 					+= 1
		idc_amt[ii_method_cnt] 		= ldc_amt0[li_lp]
		is_method[ii_method_cnt] 	= ls_method0[li_lp]
		is_trcod[ii_method_cnt] 	= ls_trcod0[li_lp]
	END IF
NEXT
li_pay_cnt = 1
//------------------=-=-=-=-=-=-=-=-=-=-----------------------------------
dw_detail.AcceptText()

ll_cnt = dw_detail.RowCount()

ls_add = 'N'
ls_end = 'N'

IF ll_cnt > 0 and ldc_total = 0 then
	//total = 0 인 경우 즉, (+, -) 값에 의해 항목들이 있으나 총계는 0인 경우 cash로 저장
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_detail.object.cp_amt[ll]  
		ls_dctype 		= trim(dw_detail.object.dctype[ll])  
		ldc_tramt		= dw_detail.object.cp_amt[ll]   //공급가
		ldc_vat		= dw_detail.object.taxamt[ll]   //부가세
		ls_req_trdt  	= String(dw_detail.object.trdt[ll], 'yyyymmdd')
		
		ls_trcod 		= dw_detail.Object.trcod[ll]
		ls_remark		= dw_detail.Object.remark[ll]
		ll_row 			= dw_split.InsertRow(0)
		//---------------------------------------
		dw_split.Object.paydt[ll_row] 		= ldt_shop_closedt
		dw_split.Object.shopid[ll_row] 		= gs_shopid
		dw_split.Object.operator[ll_row] 	= ls_operator
		dw_split.Object.customerid[ll_row] 	= ls_customerid
			
		select itemcod, regcod, priority 
		INTO :ls_itemcod, :ls_regcod, :ll_priority 
		FROM itemmst
		 WHERE trcod = :ls_trcod ;
			
		select contractseq
		into :ls_contractseq_bef
		from hotsale
		where to_char(crtdt, 'yyyymmdd') =  to_char(:ldt_termdt, 'yyyymmdd')
		and itemcod = :ls_itemcod
		and payid   = :ls_customerid ;
		
		dw_split.Object.itemcod[ll_row] 		= ls_itemcod
		dw_split.Object.paymethod[ll_row] 	= '101'
		dw_split.Object.sale_trcod[ll_row] 	= '900'
		dw_split.Object.paycnt[ll_row] 		= 1
		dw_split.Object.regcod[ll_row] 		= ls_regcod
		dw_split.Object.payamt[ll_row] 		= ldc_tramt
		dw_split.Object.taxamt[ll_row] 		= ldc_vat
		dw_split.Object.basecod[ll_row] 		= ls_basecod //고객 base
		dw_split.Object.payid[ll_row] 			= ls_payid //고객
		dw_split.Object.trdt[ll_row] 			= date(left(ls_req_trdt,4) +'/'+ mid(ls_req_trdt,5,2)+ '/' +right(ls_req_trdt,2)) //ldt_termdt //요청일
		dw_split.Object.dctype[ll_row] 		= ls_dctype
		dw_split.Object.trcod[ll_row] 		= ls_trcod
		dw_split.Object.req_trdt[ll_row] 	= ls_req_trdt
		dw_split.Object.remark[ll_row] 		= ls_remark
		
		dw_split.Object.contractseq[ll_row]	= dec(ls_contractseq_bef)

	NEXT
ELSE
	FOR ll = 1 to ll_cnt
		ldc_payamt 		= dw_detail.object.cp_amt[ll]
		ldc_outtot 		+= ldc_payamt
		ls_dctype 		= trim(dw_detail.object.dctype[ll])
		ldc_tramt		= dw_detail.object.cp_amt[ll] +  dw_detail.object.taxamt[ll]  // 공급가액과 부가세를 합한값
		ldc_vat			= dw_detail.object.taxamt[ll]
		ls_req_trdt  	= String(dw_detail.object.trdt[ll], 'yyyymmdd')
		ls_remark		= dw_detail.object.remark[ll]
		li_first 		= 0
		li_update		= 0			
		li_chk 			= 0
		ls_ok				= 'N'
		ls_trcod 		= dw_detail.Object.trcod[ll]
		
		//payid별 , 기간별, 아이템별 , 요율 가져온다.  ex) 5월부터 부가세 적용이라, 5월 이전자료에는 부가세 0이 되어야 함..
		SELECT FNC_GET_TAXRATE(:ls_customerid, 'T', :ls_trcod, to_date(:ls_req_trdt))  into  :ld_tax_rate from dual;
		if ld_tax_rate <> 0 then  
			//합계액으로 공급가액과 부가세를 나눠주는 공식임.
			ld_tax_rate = (100 / 100) + ( ld_tax_rate / 100)
		else 
			// 0으로 나눠주면 에러남
		    	ld_tax_rate = 1	
		end if
		
		IF ls_end = 'N' THEN
			FOR li_pp =  li_pay_cnt to ii_method_cnt
				ls_method 		= is_method[li_pp]
				ls_saletrcod 		= is_trcod[li_pp]
				ldc_rem 			= idc_amt[li_pp]

				IF li_first 	=  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else
					li_paycnt 	= 0
				END IF
	
				IF ldc_rem > 0 THEN
					IF ldc_rem - (ldc_tramt) <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
						ldc_saleamt	 = round(ldc_rem /ld_tax_rate, 2)						// //공급가액을 넣는다.
						ldc_taxamt    = ldc_rem -  round(ldc_rem /ld_tax_rate, 2)	//부가세
						
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
						ldc_rem		 = ldc_rem - (ldc_tramt)	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
						ldc_saleamt	 = ldc_tramt - ldc_vat	 //공급가액을 넣는다.
						ldc_taxamt 	 =  ldc_vat    //부가세
						ldc_tramt = 0								//loop 를 빼기 위해서!		
					END IF
				ELSEIF ldc_rem < 0 THEN								//수납유형에 - 금액이면
					IF ldc_rem - (ldc_tramt) >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
						ldc_saleamt	 = round(ldc_rem /ld_tax_rate, 2)						//품목금액을 넣는다.
						ldc_taxamt    = ldc_rem -  round(ldc_rem /ld_tax_rate, 2)	//부가세
						
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
						ldc_saleamt	 = ldc_tramt -	ldc_vat			//품목금액을 넣는다.
						ldc_taxamt 	 =  ldc_vat    //부가세
						ldc_tramt = 0								//loop 를 빼기 위해서!	
					END IF						
				ELSE														//아이템은 있는데 수납이 다 까졌을 때...
					ldc_saleamt  = ldc_tramt	 - ldc_vat				//품목금액을 넣는다.
					ldc_taxamt 	 =  ldc_vat    //부가세
					ldc_tramt = 0									//loop 를 빼기 위해서!
					ls_method = '101'								//cash
				END IF					


				ll_row =  dw_split.InsertRow(0)
				//---------------------------------------
				dw_split.Object.paydt[ll_row] 		= ldt_paydt
				dw_split.Object.shopid[ll_row] 		= gs_shopid
				dw_split.Object.operator[ll_row] 	= ls_operator
				dw_split.Object.customerid[ll_row] 	= ls_customerid
				
				ls_trcod =  dw_detail.Object.trcod[ll]
				select itemcod, regcod, priority 
				INTO :ls_itemcod, :ls_regcod, :ll_priority 
				FROM itemmst
				 WHERE trcod = :ls_trcod ;

				select contractseq
				into :ls_contractseq_bef
				from hotsale
			   where to_char(crtdt, 'yyyymmdd') =  to_char(:ldt_termdt, 'yyyymmdd')
				and itemcod = :ls_itemcod
				and payid   = :ls_customerid ;


				dw_split.Object.itemcod[ll_row] 		= ls_itemcod
				dw_split.Object.paymethod[ll_row] 	= ls_method
				dw_split.Object.regcod[ll_row] 		= ls_regcod
				dw_split.Object.payamt[ll_row] 		= ldc_saleamt
				dw_split.Object.taxamt[ll_row] 		= ldc_taxamt
				dw_split.Object.basecod[ll_row] 		= ls_basecod
				dw_split.Object.paycnt[ll_row] 		= li_paycnt
				dw_split.Object.payid[ll_row] 			= ls_payid
				dw_split.Object.trdt[ll_row] 			=  date(left(ls_req_trdt,4) +'/'+ mid(ls_req_trdt,5,2)+ '/' +right(ls_req_trdt,2))//ldt_termdt
				dw_split.Object.dctype[ll_row] 		= ls_dctype
				dw_split.Object.trcod[ll_row] 			= ls_trcod
				dw_split.Object.sale_trcod[ll_row] 		= ls_saletrcod
				dw_split.Object.req_trdt[ll_row] 		= ls_req_trdt
				dw_split.Object.remark[ll_row] 		= ls_remark
				
				dw_split.Object.contractseq[ll_row]	= dec(ls_contractseq_bef)
				
				IF ls_add = 'Y' THEN
//					ls_method = '101'
//					
//					ll_row =  dw_split.InsertRow(0)
//					//---------------------------------------
//					dw_split.Object.paydt[ll_row] 		= ldt_paydt
//					dw_split.Object.shopid[ll_row] 		= gs_shopid
//					dw_split.Object.operator[ll_row] 	= ls_operator
//					dw_split.Object.customerid[ll_row] 	= ls_customerid
//					
//					dw_split.Object.itemcod[ll_row] 		= ls_itemcod
//					dw_split.Object.paymethod[ll_row] 	= ls_method
//					dw_split.Object.regcod[ll_row] 		= ls_regcod
//					dw_split.Object.payamt[ll_row] 		= ldc_saleamt
//					dw_split.Object.basecod[ll_row] 		= ls_basecod
//					dw_split.Object.paycnt[ll_row] 		= li_paycnt
//					dw_split.Object.payid[ll_row] 		= ls_payid
//					dw_split.Object.trdt[ll_row] 			= ldt_termdt
//					dw_split.Object.dctype[ll_row] 		= ls_dctype
//					dw_split.Object.trcod[ll_row] 		= ls_trcod
//					dw_split.Object.sale_trcod[ll_row] 	= ls_saletrcod
//					dw_split.Object.req_trdt[ll_row] 	= ls_req_trdt	
				END IF
				
				idc_amt[li_pp]	= ldc_rem					
				IF ldc_tramt = 0 then exit		
			NEXT
		END IF
	NEXT
END IF

//li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
li_rtn = 1
//-------------------------------------------------------------
//2. 영수증발행정보 Insert ( RECEIPTMST)
//SEQ 

Select seq_receipt.nextval		  
Into :ls_appseq						  
From dual;

//SHOP COUNT
Select shopcount	    
Into :ll_shopcount	  
From partnermst
 WHERE partner = :GS_SHOPID ;
		
IF IsNull(ll_shopcount) THEN ll_shopcount = 0
If SQLCA.SQLCode < 0 Then
		RollBack;
		f_msg_sql_err(title, " Update Error(PARTNERMST)")
		Return -1
End If			
		
ll_shopcount += 1
IF li_rtn =  1 then
	//실 영수증 번호임.
	ls_prt = 'Y'
	Select seq_app.nextval		  
	Into :ls_seq						  
	From dual;
	
	If SQLCA.SQLCode < 0 Then
		RollBack;
		f_msg_sql_err(title,  " Sequence Error(seq_app)")
		Return -1
	End If
	is_seq_app = ls_seq
ELSE 
	ls_prt = 'N'
	ls_seq = ""
END IF
	
ldc_total 		= dw_cond.Object.total[1]
ldc_receive 	= dw_cond.Object.cp_receive[1]
ldc_change 		= dw_cond.Object.cp_change[1]

//--------------------------------------------
insert into RECEIPTMST
	( approvalno,		shopcount,				receipttype,	shopid,			posno,
	  workdt,			trdt,						
	  memberid,			operator,				total,
	  cash,				change, 
	  seq_app,			customerid,				prt_yn)
values 
   ( :ls_appseq, 		:ll_shopcount,			'100', 			:GS_SHOPID,		NULL,
	  :ldt_paydt,		:ldt_shop_closedt,	
	  :ls_memberid,	:ls_operator,			:ldc_total,
	  :ldc_receive, 	:ldc_change,
	  :ls_seq,			:ls_payid,				:ls_prt)	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
				RollBack;
				f_msg_sql_err(title, " Insert Error(RECEIPTMST)")
				Return -1
End If			
		
//ShopCount ADD 1
UPDATE partnermst
	SET shopcount 	= :ll_shopcount
 WHERE partner  	= :GS_SHOPID ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	RollBack;
	f_msg_sql_err(title, " Update  Error(PARTNERMST)")
	Return -1
End If		
//--------------------------------------------------
//3. Insert ( DAILYPAYMENT)
//--------------------------------------------------
Long		ll_payseq
Long 		ll_paycnt
date 		ldt_saledt


FOR li_lp =  1 to dw_split.RowCount()
	Select seq_dailypayment.nextval		  
	Into :ll_payseq  
	From dual;
	
	IF sqlca.sqlcode < 0 THEN
		f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
		RollBack;
		Return -1 
	END IF
	
	ls_itemcod 	= dw_split.Object.itemcod[li_lp]
	ls_method  	= dw_split.Object.paymethod[li_lp]
	ls_regcod  	= dw_split.Object.regcod[li_lp]
	ls_basecod  = dw_split.Object.basecod[li_lp]
	ldc_saleamt = dw_split.Object.payamt[li_lp]
	ldc_taxamt = dw_split.Object.taxamt[li_lp]
	ldt_saledt  = date(dw_split.Object.paydt[li_lp])
	ldt_trdt  	= date(dw_split.Object.trdt[li_lp])
	ls_dctype 	= Trim(dw_split.Object.dctype[li_lp])
	//messagebox("ls_dctype5", ls_dctype)
	ls_remark 	= dw_split.Object.remark[li_lp]
	
	ldc_contractseq	= dw_split.Object.contractseq[li_lp]	 // 계약번호
	//ll_contractseq = dec(ls_contractseq)
	ls_customerid 	= dw_split.Object.customerid[li_lp]	 // CID
	dw_split.Object.payseq[li_lp] = ll_payseq
	
	insert into dailypayment
      ( payseq,		paydt,			
        shopid,		operator,		customerid,
        itemcod,		paymethod,		regcod,			payamt,			basecod,
        paycnt,		payid,			remark,			trdt,				mark,
        auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user, 
        manual_yn,	PGM_ID, taxamt)
	values 
      ( :ll_payseq,  :ldt_paydt, 	
        :GS_SHOPID, 	:ls_operator, 	:ls_payid,
        :ls_itemcod,	:ls_method,		:ls_regcod,		:ldc_saleamt,	:ls_basecod,
        1,				:ls_payid,		:ls_remark,		:ldt_trdt,		NULL,
        NULL,			:ls_dctype,		:ls_appseq,		sysdate,			sysdate,		:gs_user_id,
        'N',			'HOTBILL' , :ldc_taxamt)	 ;
				   
	//저장 실패 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
		RollBack;
		Return -1
	End If	

		select count(*)  , max(d.contractseq)
		INTO :ll_log_cnt , :ldc_contractseq
		FROM   DEPOSIT_LOG A, DEPOSIT_REFUND B,DAILYPAYMENT C , HOTCONTRACT D
		WHERE  A.PAYID       = :ls_customerid      // '7062311' -- 
//		AND    A.CONTRACTSEQ = :ldc_contractseq    // '10192478' -- 
		AND    A.ITEMCOD     = B.IN_ITEM
		and    A.pay_type    = 'I'                 // IN_ITEM
		AND    B.OUT_ITEM    = C.ITEMCOD
		and    C.itemcod     = :ls_itemcod
		AND    A.payid       = C.customerid
		AND    A.payid       = D.payid 
		and    C.payseq      = :ll_payseq		
		AND    to_char(D.hotdt, 'yyyymmdd') = to_char(sysdate, 'yyyymmdd')
		AND    A.contractseq = D.contractseq;		

		if ll_log_cnt > 0 then  // IN-OUT이 일치하면 insert(그 때의 itemcod)
			insert into DEPOSIT_LOG
				( payseq      , pay_type        , paydt       , shopid     , operator     ,
				  customerid  , contractseq     , itemcod     , paymethod  , regcod       ,
				  payamt      , basecod         , paycnt      , payid      , remark       ,
				  trdt        , mark            , auto_chk    , approvalno , crtdt        ,
				  crt_user    , dctype          , manual_yn   , pgm_id     , remark2      , orderno  )
			values 
				( :ll_payseq  , 'O'             , :ldt_paydt  , :gs_shopid , :ls_operator , 
				  :ls_payid   , :ldc_contractseq, :ls_itemcod , :ls_method , :ls_regcod   ,
				  :ldc_saleamt, :ls_basecod     ,	1         , :ls_payid  , :ls_remark   ,
				  :ldt_trdt   , null            , null        , :ls_appseq , sysdate      ,
				  :gs_user_id , :ls_dctype      , 'N'         , 'HOTBILL'  , null         , null     );
		   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DEPOSIT_LOG)")
				RollBack;
				Return -1
			End If	
		end if

        SELECT COUNT(*)
        INTO   :ll_log_cnt1
        FROM   PREPAY_REFUND A,DAILYPAYMENT B
        WHERE  B.PAYID       = :ls_customerid     // '7062311' -- 
        AND    A.OUT_ITEM    = B.ITEMCOD
        and    B.itemcod     = :ls_itemcod        // 049SSRT, 048SSRT
        and    B.payseq      = :ll_payseq         // 13077633
        AND    to_char(B.paydt, 'yyyymmdd') = to_char(sysdate, 'yyyymmdd'); // '20120709'


		if ll_log_cnt1 > 0 then  // IN-OUT이 일치하면 insert(그 때의 itemcod)
          SELECT I.TRCOD, R.REGTYPE
          INTO :ls_trcod, :ls_regtype
          FROM ITEMMST I, REGCODMST R
          WHERE I.ITEMCOD  = :ls_itemcod
          AND   I.REGCOD   = R.REGCOD;

		
			insert into PREPAYDET
				( payid          , seq                  , rectype     , workdt     , trdt         ,
				  trcod          , tramt                , manual_yn   , note       , itemcod      ,
				  refno          , crtdt                , crt_user    , updtdt     , updt_user    ,
				  pgm_id         , regtype      )
			values 
				( :ls_customerid , seq_prepaydet.nextval, 'O'         , :ldt_paydt , :ldt_trdt    , 
				  :ls_trcod      , :ldc_saleamt + :ldc_vat        , 'N'         , null       , :ls_itemcod  ,
				  :ll_payseq     , sysdate              ,	:gs_shopid  , null       , null         ,
				  'HOTBILL'      , :ls_regtype  );
		   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(PREPAYDET)")
				RollBack;
				Return -1
			End If	
		end if
	
NEXT

//COMMIT; // 일단 COMMIT으로 처리함(영수증 발행시 오류 때문)

String 	ls_lin1, ls_lin2, ls_lin3
String 	ls_empnm
DEC	 	ldc_shopCount
dec{2} 	ldc_cash
Integer 	jj
String 	ls_temp, ls_itemnm, ls_val
Integer 	li_cnt
Long		ll_keynum
String	ls_facnum, ls_chk
String 	ls_methodnm

ls_lin1 	= '------------------------------------------'
ls_lin2 	= '=========================================='
ls_lin3 	= '******************************************'

dw_detail.SetSort('itemcod A')
dw_detail.Sort()
//-------------------------------------------------------------
//IF ls_prt = 'Y' THEN
ldc_change = dw_cond.Object.cp_change[1]
//------------------------------------------------------------
//4. 영수증 발행
//마지막으로 영수증 출력........
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//FOR jj = 1  to 2
//		IF jj = 1 then 
			ldc_shopCount = f_pos_header(GS_SHOPID, 'A', LL_SHOPCOUNT, 1 )
//		ELSE 
//			ldc_shopCount = f_pos_header(GS_SHOPID,  'Z', LL_SHOPCOUNT, 0 )
//		END IF

//		IF ldc_shopCount < 0 then
//			Rollback ;
//			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
//			PRN_ClosePort()
//			return  -1
//		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		ldc_total 	= 0
		ll_seq 		= 0
		ll_totcnt_d = 0
		
		FOR li_lp = 1 to dw_detail.RowCount()			
			   ls_dctype 	= trim(dw_detail.Object.dctype[li_lp])
				if ls_dctype = 'D' Then  /*2014.08.22 김선주 추가. Refund를 따로 찍기로 함으로써, + 구분해서 찍어주기 위한 조건추가 */
							
				ll_seq 		+= 1
				/*ls_temp 		= String(li_lp, '000') + ' ' //순번  2014.08.22 김선주 막음 */
				ls_temp 		= String(ll_seq, '000') + ' ' //순번
				ls_trcod 	= trim(dw_detail.Object.trcod[li_lp])
				ls_itemcod 	= trim(dw_detail.Object.itemcod[li_lp])
				ls_itemnm 	= trim(dw_detail.Object.itemnm[li_lp])
				ls_regcod 	= trim(dw_detail.Object.regcod[li_lp])
				
				ls_surtaxyn = trim(dw_detail.Object.surtaxyn[li_lp]) // 2019.04.03 부가세가 아닌 경우 '*'표시 Modified by Han
				
				ls_mmyyyy   = string(dw_detail.Object.trdt[li_lp],'MM-YYYY') + ']'// 2019.04.05 청구일을 mmyyyy로 변환 Modified by Han
				
//				ldc_saleamt	=  dw_detail.Object.cp_amt[li_lp]	
// 2019.04.08 item별 금액은 net + vet로 변경 처리 Modified by Han
				ldc_saleamt	=  dw_detail.Object.cp_amt[li_lp] + dw_detail.Object.taxamt[li_lp]
//				ldc_total 	+= ldc_saleamt 2019.04.03 변수 변경 Modified by Han
				ldc_cp_tot  += dw_detail.Object.cp_amt[li_lp]	

// 2019.04.03 부가세 합계 추가 Modified by Han
				ldc_vat_tot += dw_detail.Object.taxamt[li_lp]


//				ls_temp 		+= Left(ls_itemnm + space(24), 24) +  ' '   //아이템 mmyyyy 출력 추가에 따른 수정 2019.04.05 Modified by Han
				ls_temp 		+= Left((ls_mmyyyy + ' ' + ls_itemnm) + space(24), 24) +  ' '   //청구년월, 아이템
				li_cnt 		=  1
				ls_temp 		+= Right(Space(4) + String(li_cnt), 4) + ' ' //수량
				ls_val 		=  fs_convert_amt(ldc_saleamt,  8)
				ls_temp 		+= ls_val //금액	
								
				f_printpos(ls_temp)	
		
				//regcode master read
				SELECT keynum, 		trim(facnum)
				  INTO :ll_keynum,	:ls_facnum
				  FROM regcodmst
				 WHERE regcod 			= :ls_regcod ;
				 
				 
				// Index Desciption 
				SELECT Trim(indexdesc)
				INTO	 :ls_facnum
				FROM	 SHOP_REGIDX
				WHERE	 regcod = :ls_regcod
				AND	 shopid = :gs_shopid;
				
								
				IF IsNull(ll_keynum) or SQLCA.SQLCODE < 0 	then ll_keynum 	= 0
				IF IsNull(ls_facnum) or SQLCA.SQLCODE < 0  	then ls_facnum 	= ""
				
//				ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" 2019.04.03 부가세 표시 추가 Modified by Han
				ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" + " " + ls_surtaxyn
										
				f_printpos(ls_temp)
			End if	
		NEXT
	   f_printpos(ls_lin1)

/*********************************************************
		2019.04.03 Modified by Han
		공급가와 Vat 별도 출력을 위해서 막음.
		ls_val 	= fs_convert_sign(ldc_total, 8)
		ls_temp 	= Left("Total" + space(33), 33) + ls_val
*********************************************************/
		ls_cp_tot  = fs_convert_sign(ldc_cp_tot, 8)
		ls_temp    = Left("Net" + space(33), 33) + ls_cp_tot

		f_printpos(ls_temp);

		ls_vat_tot = fs_convert_sign(ldc_vat_tot, 8)
		ls_temp    = Left("VAT" + space(33), 33) + ls_vat_tot

		f_printpos(ls_temp);

	   f_printpos(ls_lin1)

		ls_val 	= fs_convert_sign((ldc_cp_tot + ldc_vat_tot), 8)
		ls_temp 	= Left("Total" + space(33), 33) + ls_val

		f_printpos(ls_temp);

		f_printpos(ls_lin2);
		
/************************************************************************************/
/* From. 2014.08.13 김선주  개별 영수증에도, REFUND내역이 따로 찍히도록 로직 추가   */ 
/************************************************************************************/

/***********************/
/*환불 영수증 처리     */
/***********************/
ldec_totpayamt_c = 0;
ldec_totpayamt = 0;
li_refund_cnt = 0;

/* Refund 항목이 있는지 체크 */
Select Nvl(Count(A.payseq),0) INTO :li_refund_cnt  
  From DAILYPAYMENT A, REGCODMST B 
 Where ( A.REGCOD                             = B.REGCOD )
   AND ( A.SHOPID                             = :gs_shopid        )
   AND ( A.PAYDT                              = TO_DATE(:ls_paydt, 'YYYYMMDD') )    
   AND ( A.DCTYPE                             = 'C'    )          
  /* AND ( B.REGTYPE                            = :ls_regtype         ) */
   AND ( A.CUSTOMERID                         = :ls_customerid ) ;
		

If li_refund_cnt > 0 Then /*항목이 있을 때만 프린트 합니다 */
	
	f_printpos("Refund ********************")

 FOR li_lp = 1 to dw_detail.RowCount()	
		
	ls_dctype 	= trim(dw_detail.Object.dctype[li_lp])
	
	If ls_dctype ='c' Or ls_dctype = 'C' Then 		
		
	   ldec_payamt	=  dw_detail.Object.cp_amt[li_lp]
		
		/*****출력***************/
		IF ldec_payamt <> 0 THEN			

			ll_acount 			+= 1		
			ls_temp 				= String(ll_acount, '000') 				+ ' '	//순번
			ls_trcod    		= trim(dw_detail.Object.trcod[li_lp])
			ls_itemcod 			= trim(dw_detail.Object.itemcod[li_lp])
			ls_itemnm 			= trim(dw_detail.Object.itemnm[li_lp])
			ls_regcod 			= trim(dw_detail.Object.regcod[li_lp])

			ls_surtaxyn = trim(dw_detail.Object.surtaxyn[li_lp]) // 2019.04.03 부가세가 아닌 경우 '*'표시 Modified by Han
			
//			ls_mmyyyy   = string(dw_detail.Object.trdt[li_lp],'MM-YYYY') + ']' // 2019.04.05 청구일을 mmyyyy로 변환 Modified by Han


//			ldec_payamt			=  dw_detail.Object.cp_amt[li_lp]
// 2019.04.08 Refund금액도 net + vat로 변경 modified by han
			ldec_payamt			=  dw_detail.Object.cp_amt[li_lp] + dw_detail.Object.taxamt[li_lp]

			ldec_totpayamt_c 	+= dw_detail.Object.cp_amt[li_lp]
			
			ls_temp 				+= Left(ls_itemnm + space(24), 24) +  ' '   //아이템
			li_cnt 				=  1
			ll_totcnt_c       += li_cnt
			ls_temp 				+= Right(Space(4) + String(li_cnt), 4) + ' ' //수량
			ls_val 				=  fs_convert_amt(ldec_payamt,  8)
			ls_temp 				+= ls_val //금액			
								
			f_printpos(ls_temp)				
			
			/* regcode master read */
			SELECT keynum, 	facnum,	trim(regdesc),    concession
			  INTO :ll_keynum, :ls_facnum, 	:ls_descript,		:ls_concession
			  FROM regcodmst
			 WHERE regcod = :ls_regcod;						

			// Index Desciption 
				SELECT Trim(indexdesc)
				INTO	 :ls_facnum
				FROM	 SHOP_REGIDX
				WHERE	 regcod = :ls_regcod
				AND	 shopid = :gs_shopid;

			IF IsNull(ll_keynum) 		then ll_keynum 		= 0 ;
				
			ls_print_desc = "(Key#" + String(ll_keynum) + " " + ls_facnum + ")";
				
//			ls_temp =  Space(4) + Left(ls_print_desc + space(24), 24) // 면세의 경우 '*' 출력 추가ㅣ
			ls_temp =  Space(4) + Left(ls_print_desc + ' ' + ls_surtaxyn + space(24), 24)
			
			f_printpos(ls_temp)
		END IF	
	 END IF
	NEXT	
	
	f_printpos(ls_lin1)
	ls_temp =  	Left("Refund Total" + space(28), 28) + &
					Right(Space(3) + String(ll_totcnt_C), 3) + ' ' + & 
					fs_convert_sign(ldec_totpayamt_c, 9)
	f_printpos(ls_temp)
	f_printpos(ls_lin2)		

/*******  Grand ToTal 수정. Refund + Net + Vat 2019.04.04 Modified by han
	ldec_totpayamt = ldec_totpayamt_c + ldc_total
************************************************************************/
	ldec_totpayamt = ldec_totpayamt_c + ldc_cp_tot + ldc_vat_tot

	ls_val  = 	fs_convert_sign(ldec_totpayamt, 8)
	ls_temp =	Left("Grand Total" + space(33), 33) + ls_val

	f_printpos(ls_temp)
	f_printpos(ls_lin2) 
End if
/*********************************/ 
/*환불 영수증 by 김선주 END                */
/*********************************/				
		
/**************************************************/		
//결제 수단별 금액 처리
/**************************************************/		
		For li_lp = 1 To 5
//			IF li_lp = 1 THEN
//				IF ldc_amt0_im <> 0 THEN
//					ls_val 	= fs_convert_sign(ldc_amt0_im,  8)
//					ls_code	= ls_method0_im
//					select codenm 
//					INTO :ls_codenm 
//					from syscod2t
//					where grcode = 'B310' 
//					  and use_yn = 'Y'
//					  AND code = :ls_code ;
//					ls_temp 	= Left(ls_codenm + space(33), 33) + ls_val
//					f_printpos(ls_temp)						
//				END IF
//			END IF			
			
			ldc_cash 	= ldc_amt0[li_lp]
			ls_code 		= ls_method0[li_lp]			
			
			IF ldc_cash <> 0 then
				ls_val 	= fs_convert_sign(ldc_cash,  8)
				SELECT codenm 		
				INTO :ls_codenm 		
				FROM syscod2t
				WHERE grcode = 'B310' 
				AND   code 	 = :ls_code ;
				  
				ls_temp 	= Left(ls_codenm + space(33), 33) + ls_val
				f_printpos(ls_temp)
			EnD IF
		NEXT
		ls_val 	= fs_convert_sign(ldc_change,  8)
		ls_temp 	= Left("Changed" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
//		F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id) original
//		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_seq,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록
//		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_appseq,gs_user_id) // 2019.04.08 Approval No 수정 modified by Han
		Fs_POS_FOOTER3(ls_payid,ls_customerid,ls_appseq,gs_user_id, ls_paydt) // 2019.04.08 Approval No 수정 및 Pay Date Arg 추가 modified by Han

//NEXT  영수증 한장만 출력하도록 변경 2007-08-13 hcjung		
PRN_ClosePort()
RETURN 0



end function

public function integer wf_non_payment ();STRING	ls_trcod,	ls_trcodnm, ls_itemcod, ls_itemnm, ls_regcod
DATE		ldt_trdt
DEC{2}	ldc_tramt
LONG		ll_row,		ll_last_cont

//마지막 계약여부를 확인하기 위하여!유후~
SELECT COUNT(*) INTO :ll_last_cont
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;

IF ll_last_cont = 0 THEN
	//--------------------------------------------------------------------------
	// 전월미납액 항목 Check - --
	//--------------------------------------------------------------------------
	DECLARE read_minap CURSOR FOR  
	 SELECT a.trdt, a.trcod, b.trcodnm, (tramt -  payidamt ) tramt
		FROM reqdtl a, trcode b
	  WHERE a.trcod 							=  b.trcod
		 AND a.complete_yn 					= 'N'
		 AND TO_CHAR(a.trdt,'yyyymmdd') 	<= :is_termdt
		 AND a.payid 							= :is_payid;
	
	OPEN read_minap ;
	DO WHILE(TRUE)
		FETCH read_minap INTO :ldt_trdt, :ls_trcod, :ls_trcodnm, :ldc_tramt ;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, " Select Error(refund)")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If
		IF ldc_tramt <> 0 then
			ll_row 									= dw_detail.InsertRow(0)
			dw_detail.Object.trdt[ll_row] 	=  ldt_trdt
			dw_detail.Object.trcod[ll_row] 	=  ls_trcod
			dw_detail.Object.trcodnm[ll_row] =  ls_trcodnm
			dw_detail.Object.tramt[ll_row] 	=  ldc_tramt
			dw_detail.Object.dctype[ll_row] 	=  'D'
			dw_detail.Object.adjamt[ll_row] 	=  0
			dw_detail.Object.ss[ll_row] 		=  ll_row
			dw_detail.Object.chk[ll_row] 		=  '1'
			dw_detail.Object.remark[ll_row]  =  is_termdt			
					
         SELECT itemcod, 		itemnm, 		regcod 
         INTO   :ls_itemcod, 	:ls_itemnm, :ls_regcod
	      FROM   itemmst
	      WHERE  trcod = :ls_trcod ;

       	IF IsNull(ls_itemcod) OR sqlca.sqlcode < 0 THEN ls_itemcod 	= ''
         IF IsNull(ls_itemnm)  OR sqlca.sqlcode < 0 THEN ls_itemnm 	= ''
         IF IsNull(ls_regcod)  OR sqlca.sqlcode < 0 THEN ls_regcod 	= ''
	 
	      dw_detail.Object.itemcod[ll_row] 	= ls_itemcod
         dw_detail.Object.itemnm[ll_row] 	= ls_itemnm
         dw_detail.Object.regcod[ll_row] 	= ls_regcod			
			
		END IF
	LOOP
	CLOSE read_minap ;
END IF

RETURN 0

end function

public function integer wf_refund (long wfl_row, date wfd_reqdt_next);String 	ls_paydt,		ls_trdt,				ls_in_item, 				ls_out_item,	&
			ls_itemnm, 		ls_regcod, 			ls_trcod,					ls_itemcod,		&
			ls_regtype,		ls_contractseq,	ls_contractseq_term[],	ls_activedt,	&
			ls_priceplan,	ls_out_item_mob
date		ldt_paydt,		ldt_trdt
Long		ll_row,			ll_max_seq,			ll_count = 0,				ll_last_cont,	&
			ll_term_cnt,	ll_cnt,				ll_det_cnt,					ll_in_cnt, ll_daily_cnt
DEC{2}	ldc_in_amt,		ldc_in_amtH, 		ldc_out_amt,				ldc_out_amtH,	&
			ldc_deposit, 	ldc_refund, 		ldc_remaind, 				ldc_unitamt,	&
			ldc_det_item,	ldc_in_amt_mob,	ldc_remaind_mob
INT		i

ll_row 		=  wfl_row

ls_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_paydt 	= dw_cond.object.paydt[1]
If IsNull(ls_paydt) Then ls_paydt = ""		

//DAILYPAYMENT 보증금 건 중 CONTRACSEQ가 없는 건을 ORDERNO를 기준으로 하여 UPDATE 한다 BYHMK 2016/06/10 START
   UPDATE DAILYPAYMENT A SET
            CONTRACTSEQ = (SELECT X.REF_CONTRACTSEQ FROM SVCORDER X WHERE X.ORDERNO = A.ORDERNO),
				MARK = 'H' //핫빌(의미는 없고 업데이트 건 추적하기 위해)
   WHERE  PAYID  = :is_payid
     	 AND ITEMCOD IN (SELECT IN_ITEM FROM DEPOSIT_REFUND 
                     	UNION 
                       SELECT OUT_ITEM FROM DEPOSIT_REFUND)
       AND CONTRACTSEQ IS NULL
       AND ORDERNO IS NOT NULL
       AND ORDERNO IN (SELECT ORDERNO FROM SVCORDER);       
//DAILYPAYMENT 보증금 건 중 CONTRACSEQ가 없는 건을 ORDERNO를 기준으로 하여 UPDATE 한다 BYHMK 2016/06/10 END

//마지막 계약인지 확인 - CJH
SELECT COUNT(*) INTO :ll_last_cont
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;


SELECT COUNT(*) INTO :ll_term_cnt
FROM   HOTCONTRACT
WHERE  PAYID = :is_payid
AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');
		 
IF ll_term_cnt > 1 THEN				//건수가 1개 이상이면 ARRAY 에 CONTRACTSEQ 집어 넣는다.
		 
	DECLARE CONTRACTSEQ_cur CURSOR FOR
		SELECT CONTRACTSEQ
		FROM   HOTCONTRACT
		WHERE  PAYID = :is_payid
		AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');		
	
	OPEN CONTRACTSEQ_cur;
	
	DO WHILE SQLCA.SQLCODE = 0
		
		FETCH CONTRACTSEQ_cur 
		INTO  :ls_contractseq;
				 
		IF sqlca.sqlcode <> 0 THEN
			EXIT;
		END IF
		
		ll_cnt ++
	
		ls_contractseq_term[ll_cnt] = ls_contractseq
	
	LOOP 		 
	CLOSE CONTRACTSEQ_cur;		 
ELSEIF ll_term_cnt = 1 THEN				//건수가 1나면 그냥 집어 넣는다.
	
	SELECT CONTRACTSEQ INTO :ls_contractseq
	FROM   HOTCONTRACT
	WHERE  PAYID = :is_payid
	AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');	
	
	ls_contractseq_term[1] = ls_contractseq
END IF
	
IF ll_row = 0 THEN
		ls_trdt 		= String(wfd_reqdt_next, 'yyyymmdd')
		ldt_trdt 	= wfd_reqdt_next
		
		SELECT MAX(REQNUM), MAX(SEQ) INTO :is_reqnum, :ll_max_seq
		FROM   HOTREQDTL
		WHERE  PAYID = :is_payid
		AND    TRDT  <= TO_DATE(:ls_trdt, 'YYYYMMDD');
		
		IF IsNull(is_reqnum) OR is_reqnum = "" THEN
			SELECT  to_char(seq_reqnum.nextval)		INTO  :is_reqnum 	FROM    dual; 
			ll_max_seq = 0
		END IF
ELSE
		ls_trdt 		= String(dw_detail.object.trdt[1], 'yyyymmdd')
		ldt_trdt 	= date(dw_detail.object.trdt[1])
		is_reqnum 	=  dw_detail.Object.reqnum[ll_row]
		
		Select Max(seq)	  Into :ll_max_seq	  from hotreqdtl 
	    where payid 							= :is_payid 
 	      and to_char(trdt, 'yyyymmdd') <= :ls_trdt
	      and reqnum 							= :is_reqnum ;
END IF
	
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
//1 보증금 처리 - NEW  : 2009.08.11
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
IF ll_last_cont = 0 THEN				//마지막 고객이면 전체 처리...
	SELECT SUM(IN_CNT) AS IN_CNT INTO :ll_in_cnt
	FROM ( SELECT COUNT(*) AS IN_CNT
			 FROM   DAILYPAYMENT
			 WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
			 AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND )
			 UNION ALL
			 SELECT COUNT(*)
			 FROM   DAILYPAYMENTH
			 WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
			 AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND ) );
			 
	IF ll_in_cnt > 0 THEN
		Insert Into Hotreqdtl (	seq,			reqnum, 			payid, 		trdt, 			
										paydt,											transdt,		
										trcod, 		tramt, 			adjamt, 		remark,
										crtdt, 		crt_user, 		updtdt, 		updt_user, 			pgm_id)	
		SELECT ROWNUM + :ll_max_seq,				:is_reqnum,							:is_payid,			to_date(:ls_trdt, 'yyyymmdd'), 
				 to_date(:ls_paydt, 'yyyymmdd'),																	to_date(:ls_paydt, 'yyyymmdd'),
				 X.TRCOD,								(X.PAYAMT + X.OUT_AMT) * -1,	0,						:is_termdt,
				 SYSDATE, 								:gs_user_id,	 					SYSDATE, 			:gs_user_id, 							:gs_pgm_id[gi_open_win_no]
		FROM ( SELECT A.ITEMCOD, B.IN_ITEM, B.OUT_ITEM, SUM(A.PAYAMT) AS PAYAMT, E.TRCOD,
						  SUM(NVL((SELECT SUM(C.PAYAMT) 
									  FROM   DAILYPAYMENT C     
									  WHERE  C.CUSTOMERID = A.CUSTOMERID
									  AND    C.ITEMCOD = B.OUT_ITEM ), 0)) +
						  SUM(NVL((SELECT SUM(D.PAYAMT) 
									  FROM   DAILYPAYMENTH D     
									  WHERE  D.CUSTOMERID = A.CUSTOMERID
									  AND    D.ITEMCOD = B.OUT_ITEM ), 0)) AS OUT_AMT             
				 FROM ( SELECT CUSTOMERID, ITEMCOD, SUM(PAYAMT) AS PAYAMT
				 		  FROM ( SELECT CUSTOMERID, ITEMCOD, PAYAMT
								   FROM   DAILYPAYMENT
								   WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
								   UNION ALL
								   SELECT CUSTOMERID, ITEMCOD, PAYAMT
								   FROM   DAILYPAYMENTH
								   WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid ) )
						  GROUP BY CUSTOMERID, ITEMCOD ) A, DEPOSIT_REFUND B, ITEMMST E 
				 WHERE  A.ITEMCOD = B.IN_ITEM
				 AND    B.OUT_ITEM = E.ITEMCOD
				 GROUP BY A.ITEMCOD, B.IN_ITEM, B.OUT_ITEM, E.TRCOD ) X
		WHERE  X.PAYAMT <> 0
		AND    X.PAYAMT + X.OUT_AMT <> 0;
		
		IF SQLCA.SQLCODE < 0 THEN
			f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
			gb_3.Hide()
			hpb_1.Hide()
			RETURN -1
		END IF
		
		COMMIT ;
	END IF
ELSE
//RQ-UBS-201407-13 HOTBILL처리시 계약번호별 보증금계산하여 처리되도록 START by HMK 2014-07-21

		DECLARE READ_DEPOSIT_ITEM2 CURSOR FOR  	
		SELECT X.ITEMCOD, X.IN_ITEM, X.OUT_ITEM, X.PAYAMT, X.TRCOD, X.OUT_AMT
		FROM ( SELECT A.ITEMCOD, B.IN_ITEM, B.OUT_ITEM, SUM(A.PAYAMT) AS PAYAMT, E.TRCOD,
						  SUM(NVL((SELECT SUM(C.PAYAMT) 
									  FROM   DAILYPAYMENT C     
									  WHERE  C.CUSTOMERID = A.CUSTOMERID
									  AND CONTRACTSEQ in (SELECT CONTRACTSEQ 
                                                                    FROM   HOTCONTRACT
                                                                    WHERE  PAYID =  :is_payid
                                                                    AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
									  AND    C.ITEMCOD = B.OUT_ITEM ), 0)) +
						  SUM(NVL((SELECT SUM(D.PAYAMT) 
									  FROM   DAILYPAYMENTH D     
									  WHERE  D.CUSTOMERID = A.CUSTOMERID
									  AND CONTRACTSEQ in (SELECT CONTRACTSEQ 
                                                                    FROM   HOTCONTRACT
                                                                    WHERE  PAYID =  :is_payid
                                                                    AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
									  AND    D.ITEMCOD = B.OUT_ITEM ), 0)) AS OUT_AMT
				 FROM ( SELECT CUSTOMERID, ITEMCOD, SUM(PAYAMT) AS PAYAMT
				 		  FROM ( SELECT CUSTOMERID, ITEMCOD, PAYAMT
								   FROM   DAILYPAYMENT
								   WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
										AND CONTRACTSEQ in (SELECT CONTRACTSEQ 
																	FROM   HOTCONTRACT
																	WHERE  PAYID = :is_payid
																	AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
									UNION ALL
								   SELECT CUSTOMERID, ITEMCOD, PAYAMT
								   FROM   DAILYPAYMENTH
								   WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
										AND CONTRACTSEQ  in (SELECT CONTRACTSEQ 
																	FROM   HOTCONTRACT
																	WHERE  PAYID = :is_payid
																	AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
								 )
						  GROUP BY CUSTOMERID, ITEMCOD ) A, DEPOSIT_REFUND B, ITEMMST E 
				 WHERE  A.ITEMCOD = B.IN_ITEM
				 AND    B.OUT_ITEM = E.ITEMCOD
				 GROUP BY A.ITEMCOD, B.IN_ITEM, B.OUT_ITEM, E.TRCOD ) X
		WHERE  X.PAYAMT <> 0
		AND    X.PAYAMT + X.OUT_AMT <> 0;
	//RQ-UBS-201407-13 HOTBILL처리시 계약번호별 보증금계산하여 처리되도록 END by HMK 2014-07-21
	
	OPEN READ_DEPOSIT_ITEM2 ;
	
	FETCH READ_DEPOSIT_ITEM2 INTO :ls_itemcod, :ls_in_item, :ls_out_item, :ldc_in_amt, :ls_trcod, :ldc_out_amt ;	
	
	DO WHILE sqlca.sqlcode = 0

		ldc_remaind  = ldc_in_amt + ldc_out_amt			//IN ITEM 값 + OUT ITEM 값
		ldc_det_item = 0											//실제 돌려줘야할 값을 초기화
		i = 1

		FOR i = 1 TO ll_term_cnt								//핫빌 돌린 contract 만큼 루프 돌면서 deposit 찾기
				
			IF ldc_remaind = 0 THEN EXIT						//이미 다 돌려줬다면 루프를 빠져라
				
			//아이템이 계약에 있는지 없는지 체크				
			SELECT COUNT(*) INTO :ll_det_cnt
			FROM   CONTRACTDET
			WHERE  CONTRACTSEQ = :ls_contractseq_term[i]
			AND    ITEMCOD     = :ls_in_item;
			
			//2014.06.13 추가 START
			//WAM:8253  모바일 보증금 품목 핫빌 내역에 반영 요청 
			//부분핫빌시에도 DEPOSIT_REFUND에 해당 계약건에 대한 맵핑 품목이 존재하면 반영되도록 처리
			//선행조건 Dailypayment.contractseq가 미리 세팅되어 있어야 한다.
			SELECT COUNT(*) INTO :ll_daily_cnt
			FROM DAILYPAYMENT
			WHERE PAYID = :is_payid
			//  AND CUSTOMERID = :is_payid  //payid <> customerid 다른 경우가 존재함.
			  AND ITEMCOD = :ls_in_item
			  AND CONTRACTSEQ = :ls_contractseq_term[i];
			
				
			//IF ll_det_cnt > 0 THEN					//아이템이 존재하면
			//2014.06.13 추가  END
			
			IF ll_det_cnt > 0 or ll_daily_cnt > 0 THEN			//아이템이 존재하면
					
				//계약당시의 item 가격을 뽑기 위해서 시작일자, 가격정책을 뽑는다.
				SELECT TO_CHAR(ACTIVEDT, 'YYYYMMDD'), PRICEPLAN
				INTO   :ls_activedt,	:ls_priceplan
				FROM   CONTRACTMST
				WHERE  CONTRACTSEQ = :ls_contractseq_term[i];
					
				//계약당시의 item 가격을 뽑아온다.
				SELECT unitcharge  INTO :ldc_unitamt
		  		FROM   priceplan_rate2
		 		WHERE  priceplan = :ls_priceplan
			   AND    itemcod   = :ls_in_item
	 			AND    to_char(fromdt, 'yyyymmdd') = ( SELECT MAX(to_char(fromdt, 'yyyymmdd'))
   	                                   		   	FROM   priceplan_rate2
													 			   WHERE  priceplan = :ls_priceplan
													   		   AND    itemcod	  = :ls_in_item
													   		   AND    to_char(fromdt, 'yyyymmdd') <= :ls_activedt );
					
				IF IsNull(ldc_unitamt) THEN ldc_unitamt = 0			//못 찾으면 0
					
				IF ldc_unitamt < ldc_remaind THEN						//계약당시 금액이 총수납 금액보다 작으면 
					ldc_det_item = ldc_det_item + ldc_unitamt				//돌려줘야할 금액에 계약당시 금액을 +
					ldc_remaind  = ldc_remaind - ldc_unitamt				//총수납금액은 - 차감... 왜나면...다음 계약금액을 찾아야 하니깐...
				ELSEIF ldc_unitamt = ldc_remaind THEN					//계약당시 금액과 총수납이 일치하면 
					ldc_det_item = ldc_det_item + ldc_unitamt				//돌려줘야할 금액에 계약당시 금액을 +
					ldc_remaind  = 0												//총수납금액은 0 처리
					EXIT																//루프 빠짐
				ELSE																//계약당시 금액이 크다면...
					ldc_det_item = ldc_det_item + ldc_remaind				//돌려줘야할 금액에 총수납금액을 더한다.
					ldc_remaind  = 0												//총수납금액은 0 처리	
					EXIT																//루프 빠짐
				END IF
			END IF
		NEXT
					
		IF ldc_det_item <> 0 THEN											//돌려줘야할 금액 0이 아니면
			ll_count += 1
			ldc_det_item = ldc_det_item * -1	
			ll_max_seq += 1
	
			Insert Into Hotreqdtl (
					reqnum, 		seq, 				payid, 		trdt, 			
					paydt,											transdt,		
					trcod, 		tramt, 			adjamt, 		remark,
					crtdt, 		crt_user, 		updtdt, 		updt_user, 			pgm_id)
		  	Values(
					:is_reqnum, :ll_max_seq, 	:is_payid, 	to_date(:ls_trdt, 'yyyymmdd'), 
					to_date(:ls_paydt, 'yyyymmdd'),			to_date(:ls_paydt, 'yyyymmdd'), 
					:ls_trcod, 	:ldc_det_item,	0, 			:is_termdt,
			  		sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 		:gs_pgm_id[gi_open_win_no] );

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
				gb_3.Hide()
				hpb_1.Hide()
				ROLLBACK;
				Return -1
			End If	
		END IF	
		FETCH READ_DEPOSIT_ITEM2 INTO :ls_itemcod, :ls_in_item, :ls_out_item, :ldc_in_amt, :ls_trcod, :ldc_out_amt;	
	LOOP
	CLOSE READ_DEPOSIT_ITEM2 ;
	
	COMMIT ;	
END IF
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
//1 보증금 처리 - NEW END  : 2009.08.11
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-

//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
//2 선수금 처리
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
// 2009.06.10 선수금은 현재 잔액을 인터넷용 선수금으로 반환함.
IF ll_last_cont = 0 THEN				//마지막 고객
	SELECT OUT_ITEM
	INTO   :ls_out_item
   FROM   PREPAY_REFUND 
   WHERE  REGTYPE = '01';
	
	//	SELECT SUM(TRAMT) INTO :ldc_in_amt FROM PREPAYDET
	//	WHERE  PAYID 	 = :is_payid;
	
	SELECT OUT_ITEM
	INTO   :ls_out_item_mob
   FROM   PREPAY_REFUND 
   WHERE  REGTYPE = '02';
	 
   SELECT SUM(DECODE(SUB_ITEMCOD, NULL, TRAMT,0)), SUM(DECODE(SUB_ITEMCOD, NULL, 0,TRAMT))
    INTO :ldc_in_amt, :ldc_in_amt_mob
     FROM PREPAYDET
    WHERE  PAYID   =  :is_payid;
	 
	IF IsNull(ldc_in_amt) 	then ldc_in_amt = 0;
   ldc_remaind = ldc_in_amt;
	
	
	IF ldc_remaind <> 0 then
		SELECT itemnm, 		regcod, 		trcod 
		INTO   :ls_itemnm, 	:ls_regcod, :ls_trcod
		FROM   ITEMMST
		WHERE  ITEMCOD = :ls_out_item ;
		 
		ll_count += 1
		ldc_remaind	= ldc_remaind * -1	
	
		//보증금 리펀 때문에 변경함.
		Select NVL(Max(seq), 0)	  Into :ll_max_seq	  from hotreqdtl 
	    where payid 							= :is_payid 
 	      and to_char(trdt, 'yyyymmdd') = :ls_trdt
	      and reqnum 							= :is_reqnum ;
			
		ll_max_seq += 1					
	
		Insert Into Hotreqdtl (
						reqnum, 		seq, 				payid, 		trdt, 			
						paydt,											transdt,		
						trcod, 		tramt, 			adjamt, 		remark,
						crtdt, 		crt_user, 		updtdt, 		updt_user, 			pgm_id)
	   Values(
						:is_reqnum, :ll_max_seq, 	:is_payid, 	to_date(:ls_trdt, 'yyyymmdd'), 
						to_date(:ls_paydt, 'yyyymmdd'),			to_date(:ls_paydt, 'yyyymmdd'), 
						:ls_trcod, 	:ldc_remaind,	0, 			:is_termdt,
				  		sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 		:gs_pgm_id[gi_open_win_no] );

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(Title, "Insert Error(HOTREQDTL_prepay)")
			gb_3.Hide()
			hpb_1.Hide()
			ROLLBACK;
			RETURN -1
		END IF
	END IF
	
	IF IsNull(ldc_in_amt_mob) 	then ldc_in_amt_mob = 0;
   ldc_remaind_mob = ldc_in_amt_mob;
		
	IF ldc_remaind_mob <> 0 then
		SELECT itemnm, 		regcod, 		trcod 
		INTO   :ls_itemnm, 	:ls_regcod, :ls_trcod
		FROM   ITEMMST
		WHERE  ITEMCOD = :ls_out_item_mob ;
		 
		ll_count += 1
		ldc_remaind_mob	= ldc_remaind_mob * -1	
	
		//보증금 리펀 때문에 변경함.
		Select NVL(Max(seq), 0)	  Into :ll_max_seq	  from hotreqdtl 
	    where payid 							= :is_payid 
 	      and to_char(trdt, 'yyyymmdd') = :ls_trdt
	      and reqnum 							= :is_reqnum ;
			
		ll_max_seq += 1					
	
		Insert Into Hotreqdtl (
						reqnum, 		seq, 				payid, 		trdt, 			
						paydt,											transdt,		
						trcod, 		tramt, 			adjamt, 		remark,
						crtdt, 		crt_user, 		updtdt, 		updt_user, 			pgm_id)
	   Values(
						:is_reqnum, :ll_max_seq, 	:is_payid, 	to_date(:ls_trdt, 'yyyymmdd'), 
						to_date(:ls_paydt, 'yyyymmdd'),			to_date(:ls_paydt, 'yyyymmdd'), 
						:ls_trcod, 	:ldc_remaind_mob,	0, 			:is_termdt,
				  		sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 		:gs_pgm_id[gi_open_win_no] );

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(Title, "Insert Error(HOTREQDTL_prepay_mob)")
			gb_3.Hide()
			hpb_1.Hide()
			ROLLBACK;
			RETURN -1
		END IF
	END IF
END IF

COMMIT ;

Return ll_count
end function

public subroutine wf_deposit_log ();String 	ls_paydt,		ls_contractseq,	ls_contractseq_term[],		ls_custid,		&
			ls_item,			ls_outitem
date		ldt_paydt
Long		ll_term_cnt,	ll_cnt,				ll_contseq,						ll_log_cnt
DEC{2}	ldc_payamt
INT		i

ls_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_paydt 	= dw_cond.object.paydt[1]
If IsNull(ls_paydt) Then ls_paydt = ""		

//계약인지 확인 - CJH
SELECT COUNT(*) INTO :ll_term_cnt
FROM   HOTCONTRACT
WHERE  PAYID = :is_payid
AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');
		 
IF ll_term_cnt > 0 THEN	

	DECLARE CONTRACTSEQ_cur CURSOR FOR
		SELECT CONTRACTSEQ
		FROM   HOTCONTRACT
		WHERE  PAYID = :is_payid
		AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');		
	
	OPEN CONTRACTSEQ_cur;
	
	DO WHILE SQLCA.SQLCODE = 0
		
		FETCH CONTRACTSEQ_cur 
		INTO  :ls_contractseq;
				 
		IF sqlca.sqlcode <> 0 THEN
			EXIT;
		END IF
		
		ll_cnt ++
	
		ls_contractseq_term[ll_cnt] = ls_contractseq
		
		SELECT COUNT(*) INTO :ll_log_cnt
		FROM   DEPOSIT_LOG
		WHERE  PAYID = :is_payid
		AND    CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
		AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND );
		
		IF ll_log_cnt > 0 THEN
			DECLARE DAILYCHECK_cur CURSOR FOR
				SELECT A.CUSTOMERID, A.CONTRACTSEQ, A.ITEMCOD, B.OUT_ITEM, SUM(A.PAYAMT) AS PAYAMT
				FROM   DEPOSIT_LOG A, DEPOSIT_REFUND B
				WHERE  A.PAYID = :is_payid
				AND    A.CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
				AND    A.ITEMCOD = B.IN_ITEM
				GROUP BY A.CUSTOMERID, A.CONTRACTSEQ, A.ITEMCOD, B.OUT_ITEM
				HAVING SUM(A.PAYAMT) > 0;
				
			OPEN DAILYCHECK_cur	;			
			
			DO WHILE SQLCA.SQLCODE = 0
		
				FETCH DAILYCHECK_cur
				INTO  :ls_custid, :ll_contseq, :ls_item, :ls_outitem, :ldc_payamt;
					 
				IF sqlca.sqlcode <> 0 THEN
					EXIT;
				END IF
			
				INSERT INTO DEPOSIT_LOG
					( PAYSEQ, PAY_TYPE, PAYDT, SHOPID, OPERATOR,
					  CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
					  PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
					  TRDT, MARK, AUTO_CHK, APPROVALNO, CRTDT,
					  CRT_USER, DCTYPE, MANUAL_YN, PGM_ID, REMARK2,
					  ORDERNO )
				SELECT PAYSEQ, 'O', PAYDT, SHOPID, OPERATOR,
						 CUSTOMERID, :ll_contseq, ITEMCOD, PAYMETHOD, REGCOD,
						 CASE WHEN PAYAMT <= (:ldc_payamt * -1) THEN (:ldc_payamt * -1 )
							   ELSE PAYAMT END PAYAMT,
						 BASECOD, PAYCNT, PAYID, REMARK,
						 TRDT, MARK, AUTO_CHK, APPROVALNO, SYSDATE,
						 :gs_user_id, DCTYPE, MANUAL_YN, 'HOTBILL', REMARK2,
						 ORDERNO
				FROM   DAILYPAYMENT
				WHERE  CUSTOMERID = :ls_custid
				AND    PAYDT      = TO_DATE(:ls_paydt, 'YYYYMMDD')
				AND    ITEMCOD = :ls_outitem
				AND    PGM_ID = 'HOTBILL';
			
				IF SQLCA.SQLCODE < 0 THEN
					f_msg_sql_err(Title, "Insert Error(DEPOSIT_LOG)")
					ROLLBACK;
					gb_3.Hide()
					hpb_1.Hide()
					RETURN
				END IF
			LOOP
			CLOSE DAILYCHECK_cur;	
		END IF			
	LOOP 		 
	CLOSE CONTRACTSEQ_cur;
END IF	
	
COMMIT ;

Return
end subroutine

on ubs_w_reg_hotbill_contract_new_bac.create
int iCurrent
call super::create
this.gb_3=create gb_3
this.p_cancel=create p_cancel
this.cb_hotbill=create cb_hotbill
this.dw_split=create dw_split
this.hpb_1=create hpb_1
this.cb_1=create cb_1
this.dw_others=create dw_others
this.p_1=create p_1
this.cb_deposit=create cb_deposit
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_3
this.Control[iCurrent+2]=this.p_cancel
this.Control[iCurrent+3]=this.cb_hotbill
this.Control[iCurrent+4]=this.dw_split
this.Control[iCurrent+5]=this.hpb_1
this.Control[iCurrent+6]=this.cb_1
this.Control[iCurrent+7]=this.dw_others
this.Control[iCurrent+8]=this.p_1
this.Control[iCurrent+9]=this.cb_deposit
end on

on ubs_w_reg_hotbill_contract_new_bac.destroy
call super::destroy
destroy(this.gb_3)
destroy(this.p_cancel)
destroy(this.cb_hotbill)
destroy(this.dw_split)
destroy(this.hpb_1)
destroy(this.cb_1)
destroy(this.dw_others)
destroy(this.p_1)
destroy(this.cb_deposit)
end on

event open;call super::open;String ls_format, ls_ref_desc, ls_tmp, ls_useyn, &
			ls_trcod[]

F_INIT_DSP(1,"","")
gb_3.Hide()
hpb_1.Hide()

//ls_format = fs_get_control("B5", "H200", ls_ref_desc)
//If ls_format = "1" Then
//	dw_detail.object.tramt.Format 	= "#,##0.0"
//	dw_detail.object.adjamt.Format 	= "#,##0.0"
//	dw_detail.object.preamt.Format 	= "#,##0.0"	
//	dw_detail.object.balance.Format 	= "#,##0.0"	
//	dw_detail.object.totamt.Format 	= "#,##0.0"	
//	dw_detail.object.sum_amt.Format 	= "#,##0.0"	
//ElseIf ls_format = "2" Then
//	dw_detail.object.tramt.Format 	= "#,##0.00"
//	dw_detail.object.adjamt.Format 	= "#,##0.00"
//	dw_detail.object.preamt.Format 	= "#,##0.00"	
//	dw_detail.object.balance.Format 	= "#,##0.00"	
//	dw_detail.object.totamt.Format 	= "#,##0.00"	
//	dw_detail.object.sum_amt.Format 	= "#,##0.00"	
//Else
//	dw_detail.object.tramt.Format = "#,##0"
//	dw_detail.object.adjamt.Format = "#,##0"
//	dw_detail.object.preamt.Format = "#,##0"	
//	dw_detail.object.balance.Format = "#,##0"	
//	dw_detail.object.totamt.Format = "#,##0"	
//	dw_detail.object.sum_amt.Format = "#,##0"
//End If

//Hotbill 관리 여부 
ls_useyn = fs_get_control("H0", "H101", ls_ref_desc)
If ls_useyn = "Y" Then
	cb_hotbill.Enabled = True
Else
    cb_hotbill.Enabled = False
End If

//HotBill 순서 가져오기
ls_tmp = fs_get_control("H0", "H100", ls_ref_desc)
il_cnt= fi_cut_string(ls_tmp, ";", is_start[])

dw_cond.object.paydt[1] = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
//PayMethod101, 102, 103, 104, 105
ls_tmp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_tmp 		= "" Then Return
fi_cut_string(ls_tmp, ";", is_method[])

//trcode
ls_tmp 			= fs_get_control("B5", "I102", ls_ref_desc)
If ls_tmp 		= "" Then Return
fi_cut_string(ls_tmp, ";", is_trcod[])

dw_cond.object.method1[1] = is_method[1] 
dw_cond.object.method2[1] = is_method[2] 
dw_cond.object.method3[1] = is_method[3] 
dw_cond.object.method4[1] = is_method[4] 
dw_cond.object.method5[1] = is_method[5] 
dw_cond.object.method6[1] = is_method[6] 

dw_cond.object.trcod1[1] 	= is_trcod[1]
dw_cond.object.trcod2[1] 	= is_trcod[2]
dw_cond.object.trcod3[1] 	= is_trcod[3]
dw_cond.object.trcod4[1] 	= is_trcod[4]
dw_cond.object.trcod5[1] 	= is_trcod[5]
dw_cond.object.trcod6[1] 	= is_trcod[6]

ib_save = False

end event

event ue_reset;Constant Int LI_ERROR = -1

Int li_rc
String ls_tmp, ls_ref_desc
//PayMethod101, 102, 103, 104, 105
ls_tmp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_tmp, ";", is_method[])

//trcode
ls_tmp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_tmp, ";", is_trcod[])

dw_detail.AcceptText() 

If ib_save = False Then 
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0)  or dw_detail.Rowcount() > 0 Then
		li_rc = MessageBox(This.Title, "Hotbill 처리하시거나 취소하십시오.")
		Return 0
	End If
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_others.Reset()

dw_cond.object.termdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.paydt[1] = f_find_shop_closedt(gs_shopid)

dw_cond.object.method1[1] = is_method[1] 
dw_cond.object.method2[1] = is_method[2] 
dw_cond.object.method3[1] = is_method[3] 
dw_cond.object.method4[1] = is_method[4] 
dw_cond.object.method5[1] = is_method[5] 
dw_cond.object.method6[1] = is_method[6] 

dw_cond.object.trcod1[1] 	= is_trcod[1]
dw_cond.object.trcod2[1] 	= is_trcod[2]
dw_cond.object.trcod3[1] 	= is_trcod[3]
dw_cond.object.trcod4[1] 	= is_trcod[4]
dw_cond.object.trcod5[1] 	= is_trcod[5]
dw_cond.object.trcod6[1] 	= is_trcod[6]

idc_impack = 0

p_cancel.TriggerEvent("ue_disable")
p_1.Enabled = True

Return 0
end event

event ue_extra_save;String 	ls_paymethod, 	ls_paydt, 	ls_sysdate,			ls_nextdate
String 	ls_trdt, 		ls_reqnum, 	ls_cus_bil_todt,	ls_remark,		ls_reqdt
Long 		i, 				ll_seq, 		ll_max_seq, 		ll_cnt, ll,		ll_svc_chk
Dec 		ldc_totamt, 	ldc_adjamt,	ldc_impack,			ldc_card
int 		li_return, 		li_message,		li_method_cnt
date 		ldt_paydt, 		ldt_trdt, 	ldt_shop_closedt

dw_detail.AcceptText()
ls_sysdate 			= String(fdt_get_dbserver_now(), 'yyyymmdd')
ldt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)
ldc_totamt 			= dw_detail.object.totamt[1]
ls_paymethod 		= dw_cond.object.pay_method[1]
ldc_impack			= dw_cond.Object.amt5[1]

//카드입금액이 총 판매액보다 크면 처리 못함....
DEC{2}	ldc_total,	ldc_card_total

ldc_total 		= 	dw_cond.Object.total[1]
ldc_card_total = 	dw_cond.Object.amt2[1] + &
						dw_cond.Object.amt4[1] + &
						dw_cond.Object.amt3[1] + &
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

idc_amt[1] =  dw_cond.Object.amt3[1]
idc_amt[2] =  dw_cond.Object.amt2[1]
idc_amt[3] =  dw_cond.Object.amt5[1]
idc_amt[4] =  dw_cond.Object.amt4[1]
idc_amt[5] =  dw_cond.Object.amt1[1]
idc_amt[6] =  dw_cond.Object.amt6[1]

idc_total  =  dw_cond.Object.total[1]

idc_receive = dw_cond.Object.cp_receive[1]
idc_change 	= dw_cond.Object.cp_change[1]
idc_refund  = dw_cond.Object.refund[1]

IF IsNull(idc_receive) 	then idc_receive = 0
IF IsNull(idc_change) 	then idc_change = 0
IF IsNull(idc_refund) 	then idc_refund = 0

li_method_cnt	= 0
FOR ll = 1 to 6
	IF idc_amt[ll] <> 0 THEN	li_method_cnt += 1
NEXT

//결제 금액 확인 로직. TOTAL이 -인데 RECEIVE 는 + 인경우 잡기...2009.09.21 JHCHOI
IF idc_total < 0 THEN			//TOTAL - 인경우
	IF idc_receive > 0 THEN		//RECEIVE 는 + 인경우
		f_msg_info(9000, title,"결제 내용을 확인하세요!" )
		dw_cond.SetFocus()
		dw_cond.SetColumn("amt1")
		Return -1
	END IF
ELSE
	IF idc_receive < 0 THEN	
		f_msg_info(9000, title,"결제 내용을 확인하세요!" )
		dw_cond.SetFocus()
		dw_cond.SetColumn("amt1")
		Return -1
	END IF
END IF
//2009.09.21 JHCHOI END

ls_paydt = String(dw_cond.object.paydt[1], 'yyyymmdd')
ls_trdt 	= String(dw_detail.object.trdt[1], 'yyyymmdd')

ldt_paydt = dw_cond.object.paydt[1]
ldt_trdt = date(dw_detail.object.trdt[1])

SELECT TO_CHAR(ADD_MONTHS(REQDT, 1), 'YYYYMMDD') INTO :ls_reqdt FROM REQCONF
 WHERE CHARGEDT = :is_chargedt;

IF ls_trdt <> ls_reqdt THEN
	ls_trdt = ls_reqdt
END IF

If IsNull(ls_paymethod) Then ls_paymethod = ""
If IsNull(ls_paydt) Then ls_paydt = ""

If li_method_cnt = 0 and idc_total <> 0  Then
	f_msg_info(9000, title,"지불방법을 입력하지 않았습니다. " )
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -1
End If

IF idc_receive = 0 AND idc_total <> 0 then
		f_msg_info(200, Title, "입금액")
		dw_cond.SetFocus()
		dw_cond.SetColumn("amt1")
		Return -1
END IF

IF idc_total >= 0 THEN
	IF idc_receive < idc_total then
			f_msg_info(200, Title, "입금액이 수납금액보다 작습니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("amt1")
			Return -1
	END IF
ELSE
	IF idc_receive > idc_total then
			f_msg_info(200, Title, "입금액이 수납금액보다 작습니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("amt1")
			Return -1
	END IF
END IF	

If ls_paydt = "" Then
		f_msg_info(200, Title, "지불일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paydt")
		Return -1
End If

ls_nextdate = string(relativedate(date(fdt_get_dbserver_now()),1),'yyyymmdd')	
If ls_nextdate < is_termdt Then
	f_msg_usr_err(212,Title + "today:" +  Mid(ls_nextdate, 1,4) + "-" + &
										  Mid(ls_nextdate,5,2) + "-" + &
										  Mid(ls_nextdate,7,2),"해지요청일")

	Return -1	
End IF

//2009.06.30 부분핫빌 - CJH
//해당납입고객으로 해지처리 안된 고객이 있는지 Check 한다.
li_return = wfi_contract_staus_chk(ll_cnt, ls_cus_bil_todt)

IF li_return = 0 Then
	IF ll_cnt > 0 Then
     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
		return -1
	End IF

   If ls_sysdate < ls_cus_bil_todt Then
		f_msg_usr_err(212,Title + "today:" +  Mid(ls_sysdate, 1,4) + "-" + &
											  Mid(ls_sysdate,5,2) + "-" + &
											  Mid(ls_sysdate,7,2)," 과금종료일")

		Return -1	
	End IF
	
ElseIf li_return = -1 Then
	return li_return
End IF
//2009.06.30---------------------------------------END

F_INIT_DSP(3, String(idc_receive), String(idc_change))

//2009.06.10 추가
//IF ldc_impack <> 0 THEN
//	Dec{2} 	ldc_90
//	ldc_90   = dw_cond.Object.credit[1]
//	ldc_card = dw_cond.Object.amt3[1]	
//	dw_cond.Object.amt5[1] = idc_total - ldc_90
//	dw_cond.Object.amt3[1] = ldc_card + (ldc_impack - (idc_total - ldc_90))
//END IF

//2009.06.10 추가
//2009.06.10 제거
//-3006-8-19 add ------------------------------------------------------------------
////Impact Card로 결제 하는 경우 
////10%는 Impact 90%는 Credit card 로 분할 처리
//Dec{2} 	ldc_10, ldc_90, ldc_100, ldc_card
//
//ldc_100 =  dw_cond.Object.amt5[1]
//If IsNull(ldc_100) then ldc_100 = 0
//
//IF ldc_100 <> 0 then
//	ldc_10 						= Round(ldc_100 * 0.1, 2)
//	ldc_90 						= ldc_100 - ldc_10
//	
//	ldc_card = dw_cond.Object.amt3[1]
//	If IsNull(ldc_card) then ldc_card = 0
//	
//	dw_cond.Object.amt5[1]	= ldc_10
//	dw_cond.Object.amt3[1]	= ldc_card + ldc_90
//END IF
dw_cond.Accepttext()
//2009.06.10 제거------------------------------end


////daily payment 처리 부분 반영
//IF wf_split(ldt_paydt) < 0 then
//		Return -1
//END IF


// #5238 HOTREQDTL의 SEQ_APP칼럼 데이터 이상 현상 문의
// hotbil 화면에서 여러고객을 처리할 경우, 다음 고객에게 최초고객의 is_seq_app 가 들어가는 현상 해결위해, 초기화
is_seq_app = ''
// #5238 END


For i = 1 To dw_detail.Rowcount()
	ldc_adjamt 	= dw_detail.object.adjamt[i]
    ll_seq 		= dw_detail.object.seq[i]
    ls_reqnum 	= dw_detail.object.reqnum[i]
	 ls_remark  = dw_detail.object.remark[i]
		
	//조정 금액 Update
	Update hotreqdtl 
	   set adjamt 	= :ldc_adjamt, 
		    remark 	= :ls_remark,
			 SEQ_APP = :is_seq_app
	 where payid 	= :is_payid 
	   and to_char(trdt, 'yyyymmdd') = :ls_trdt 
		and reqnum 		= :ls_reqnum 
		and seq 			= :ll_seq;
		
    If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Update Error(HOTREQDTL)")
		Rollback ;		
		Return -1
	End If	

Next

//IF idc_change < 0 THEN
//If ls_paymethod <> "" Then   //지불을 하지 않으면 수동입금처리로 하도록 하기 위해 핫빌링에서는 처리 안한다.

//paymethod별 Insert
idc_amt[1] =  dw_cond.Object.amt1[1]				//cash
idc_amt[2] =  dw_cond.Object.amt2[1]				//check
idc_amt[3] =  dw_cond.Object.amt3[1]				//credit card
idc_amt[4] =  dw_cond.Object.amt4[1]				//DPP
idc_amt[5] =  dw_cond.Object.amt5[1]				//Impact Card
idc_amt[6] =  dw_cond.Object.amt6[1]				//Gift Card

is_trcod[1] =  dw_cond.Object.trcod1[1]
is_trcod[2] =  dw_cond.Object.trcod2[1]
is_trcod[3] =  dw_cond.Object.trcod3[1]
is_trcod[4] =  dw_cond.Object.trcod4[1]
is_trcod[5] =  dw_cond.Object.trcod5[1]
is_trcod[6] =  dw_cond.Object.trcod6[1]

//이 부분 문제 있다. 입력한 금액을 그대로 hotreqdtl 로 만들어 버림. 잔돈 돌려줘야 할 경우에는?
//2009.09.21 JHCHOI 수정.
FOR i =  1 to 6
IF idc_amt[i] <> 0 THEN
	SELECT MAX(SEQ) + 1
	INTO	 :ll_max_seq
	FROM 	 HOTREQDTL
	WHERE  PAYID							= :is_payid 
	AND	 TO_CHAR(TRDT, 'YYYYMMDD') = :ls_trdt
	AND	 REQNUM							= :is_reqnum ;

	//CASH 일때 잔돈이 있으면 CASH 에서 빼자...2009.09.21 JHCHOI
	IF i = 1 THEN
		IF idc_change <> 0 THEN
			idc_amt[i] = idc_amt[i] - idc_change
		END IF
	ELSEIF i = 6 THEN   //GIFT CARD 일때 잔돈 빼고 처리...2011.02.15 JHCHOI
		IF idc_change <> 0 THEN
			IF idc_amt[1] = 0 THEN
				idc_amt[i] = idc_amt[i] - idc_change
			END IF
		END IF
	END IF	
	//2009.09.21 JHCHOI	END..
	
	Insert Into Hotreqdtl (
						reqnum, 			seq, 				payid, 			
						trdt, 			
						paydt,											
						transdt,		
						trcod, 			tramt, 								adjamt,			
						remark,			crtdt, 			crt_user, 		updtdt, 		updt_user, 				
						pgm_id, 													seq_app )
	   Values(		:is_reqnum, 	:ll_max_seq, 	:is_payid, 		
						to_date(:ls_trdt, 'yyyymmdd'), 
						to_date(:ls_paydt, 'yyyymmdd'),			
						to_date(:ls_paydt, 'yyyymmdd'), 
						:is_trcod[i], 	(:idc_amt[i] * -1),				0,
						:is_termdt,		sysdate, 		:gs_user_id,	sysdate, 	:gs_user_id, 			
						:gs_pgm_id[gi_open_win_no], 						:is_seq_app );
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
		Rollback ;
		Return -1
	End If	
End IF
NEXT

// 핫빌 총합이 0 (deposit, refund 포함해서) 이면  2014-04-26 Start by HMK
/* 이 경우에도 수납액을 0으로 생성해 줘야, 청구시 청구자료 collection 단계 (B5ITEMSALECLOSE) 에서 
   reqdtl에 수납반영을 시키는 근거자료가 된다.*/
DEC{2} ldc_tr_tot

if li_method_cnt = 0 then //입금액 입력하지 않았고..
   
   SELECT SUM(TRAMT)  INTO :ldc_tr_tot
         FROM HOTREQDTL
        WHERE PAYID =   :is_payid 
          AND REQNUM = :is_reqnum ;
	
	if ldc_tr_tot = 0 then
		
		SELECT MAX(SEQ) + 1
		INTO	 :ll_max_seq
		FROM 	 HOTREQDTL
		WHERE  PAYID							= :is_payid 
		AND	 TO_CHAR(TRDT, 'YYYYMMDD') = :ls_trdt
		AND	 REQNUM							= :is_reqnum ;
	
		Insert Into Hotreqdtl (
								reqnum, 			seq, 				payid, 			
								trdt, 			
								paydt,											
								transdt,		
								trcod, 			tramt, 								adjamt,			
								remark,			crtdt, 			crt_user, 		updtdt, 		updt_user, 				
								pgm_id, 													seq_app )
				Values(		:is_reqnum, 	:ll_max_seq, 	:is_payid, 		
								to_date(:ls_trdt, 'yyyymmdd'), 
								to_date(:ls_paydt, 'yyyymmdd'),			
								to_date(:ls_paydt, 'yyyymmdd'), 
								'900', 	0,				0,
								:is_termdt,		sysdate, 		:gs_user_id,	sysdate, 	:gs_user_id, 			
								:gs_pgm_id[gi_open_win_no], 						:is_seq_app );
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
				Rollback ;
				Return -1
			End If	
			
	end if		
	
end if
/* 핫빌 총합이 0인경우 2014-04-29 by HMK*/


//2009.06.30 부분 핫빌 때문에 추가함. CJH
//상태 Update
//Update customerm set hotbillflag = 'S' where customerid = :is_payid ;	

SELECT COUNT(*) INTO :ll_cnt
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;

IF ll_cnt = 0 THEN			//전체 해지즉시불 처리!

	//2010.08.20 JHCHOI수정. 전체핫빌인 경우 해당 PAYID 로 SVCORDER 를 다 뒤져서 신청건이 있는 지 확인한다.
	SELECT COUNT(*)
	INTO	 :ll_svc_chk
	FROM   SVCORDER
	WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
	AND    STATUS IN ( '10', '30', '50', '80' );

// 김선주 
//	IF ll_svc_chk > 0 THEN
//     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
//		ROLLBACK;		  
//		return -1
//	END IF	
	
	UPDATE CUSTOMERM
	SET    HOTBILLFLAG = 'S'
	WHERE  PAYID = :is_payid;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, SQLCA.SQLErrText)
		Rollback ;
		Return -1
	End If		
	
	UPDATE CONTRACTMST
	SET	 BILL_HOTBILLFLAG = 'S'
	WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
									FROM   CUSTOMERM A, CONTRACTMST B
									WHERE  A.PAYID = :is_payid
									AND    A.CUSTOMERID = B.CUSTOMERID
									AND    B.BILL_HOTBILLFLAG = 'P' )
	AND    BILL_HOTBILLFLAG = 'P';
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, SQLCA.SQLErrText)
		Rollback ;
		Return -1
	End If			
	
ELSE
	
	//2010.08.20 JHCHOI수정. 전체핫빌인 경우 해당 PAYID 로 SVCORDER 를 다 뒤져서 신청건이 있는 지 확인한다.
	SELECT COUNT(*)
	INTO	 :ll_svc_chk
	FROM   SVCORDER
	WHERE  CUSTOMERID IN ( SELECT CUSTOMERID FROM CUSTOMERM WHERE PAYID = :is_payid )
	AND    REF_CONTRACTSEQ IN ( SELECT CONTRACTSEQ FROM HOTCONTRACT
										 WHERE  PAYID = :is_payid
										 AND    HOTDT = TO_DATE(:ls_paydt, 'YYYYMMDD'))
	AND    STATUS IN ( '10', '30', '50', '80' );
	
// 김선주 	
//	IF ll_svc_chk > 0 THEN
//     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
//		ROLLBACK;		  
//		return -1
//	END IF	
	
	UPDATE CUSTOMERM
	SET    HOTBILLFLAG = 'H'
	WHERE  PAYID = :is_payid;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, SQLCA.SQLErrText)
		Rollback ;
		Return -1
	End If	
	
	UPDATE CONTRACTMST
	SET	 BILL_HOTBILLFLAG = 'H'
	WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
									FROM   CUSTOMERM A, CONTRACTMST B
									WHERE  A.PAYID = :is_payid
									AND    A.CUSTOMERID = B.CUSTOMERID
									AND    B.BILL_HOTBILLFLAG = 'P' )
	AND    BILL_HOTBILLFLAG = 'P';
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, SQLCA.SQLErrText)
		Rollback ;
		Return -1
	End If				
END IF
//2009.06.30------------------------------END
//R로 되어있는 놈들 클리어 시키기...
UPDATE CONTRACTMST
SET	 BILL_HOTBILLFLAG = NULL
WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
								FROM   CUSTOMERM A, CONTRACTMST B
								WHERE  A.PAYID = :is_payid
								AND    A.CUSTOMERID = B.CUSTOMERID
								AND    B.BILL_HOTBILLFLAG = 'R' )
AND    BILL_HOTBILLFLAG = 'R';

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, SQLCA.SQLErrText)
	Rollback ;
	Return -1
End If			

//idc_amt[1] =  dw_cond.Object.amt3[1]
//idc_amt[2] =  dw_cond.Object.amt2[1]
//idc_amt[3] =  dw_cond.Object.amt5[1]
//idc_amt[4] =  dw_cond.Object.amt4[1]
//idc_amt[5] =  dw_cond.Object.amt1[1]
////
//is_trcod[1] =  dw_cond.Object.trcod3[1]
//is_trcod[2] =  dw_cond.Object.trcod2[1]
//is_trcod[3] =  dw_cond.Object.trcod5[1]
//is_trcod[4] =  dw_cond.Object.trcod4[1]
//is_trcod[5] =  dw_cond.Object.trcod1[1]
//
//is_method[1] =  dw_cond.Object.method3[1]
//is_method[2] =  dw_cond.Object.method2[1]
//is_method[3] =  dw_cond.Object.method5[1]
//is_method[4] =  dw_cond.Object.method4[1]
//is_method[5] =  dw_cond.Object.method1[1]

//daily payment 처리 부분 반영--- Sequence Change
//IF wf_split(ldt_paydt) < 0 then
//		Return -1
//END IF

//2009.06.16 추가
IF wf_split_new(ldt_paydt) < 0 then
		Return -1
END IF
//======================================================
// SEQ_APP Update
//======================================================
For i = 1 To dw_detail.Rowcount()
    ll_seq 		= dw_detail.object.seq[i]
    ls_reqnum 	= dw_detail.object.reqnum[i]
		
	//조정 금액 Update
	Update hotreqdtl 
	   set SEQ_APP = :is_seq_app
	 where payid 	= :is_payid 
		and reqnum	= :ls_reqnum 
		and seq 		= :ll_seq;
		
    If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Update Error(HOTREQDTL.SEQ_APP)")
		Rollback ;
		Return -1
	End If	
Next

//2011.03.06 deposit log 남기기...
//wf_deposit_log()

COMMIT;  

F_INIT_DSP(1,"","")

Return 0
end event

event resize;LONG	ll_dwsize,		ll_2

ll_dwsize  = 40   //그룹박스와 dw사이 간격!

//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	//dw_detail.Height = 0

	p_insert.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
	p_cancel.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
	p_delete.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
	cb_deposit.Y = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	ll_2 			= round((newheight - dw_others.Y - dw_others.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 2, 1)
	
	dw_detail.Height = dw_detail.Height + ll_2
	dw_others.y		  = dw_detail.y + dw_detail.Height + ll_dwsize
	dw_others.Height = dw_others.Height + ll_2
	
	p_insert.Y	 = newheight  - iu_cust_w_resize.ii_button_space
	p_cancel.Y	 = newheight  - iu_cust_w_resize.ii_button_space	
	p_delete.Y	 = newheight  - iu_cust_w_resize.ii_button_space
	p_save.Y		 = newheight  - iu_cust_w_resize.ii_button_space
	p_reset.Y	 = newheight  - iu_cust_w_resize.ii_button_space
	p_close.Y	 = newheight  - iu_cust_w_resize.ii_button_space
	cb_deposit.Y = newheight  - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
	dw_others.Width = 0	
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
	dw_others.Width = newwidth - dw_others.X - iu_cust_w_resize.ii_dw_button_space	
	
End If

SetRedraw(True)


//LONG	ll_dwsize,		ll_2
//
//ll_dwsize  = 40   //그룹박스와 dw사이 간격!
//
////2000-06-28 by kEnn
////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
////
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	//dw_detail.Height = 0
//
//	p_insert.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
//	p_cancel.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
//	p_delete.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
//	p_save.Y		 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
//	p_reset.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space
//	p_close.Y	 = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
//	cb_deposit.Y = dw_others.Y + iu_cust_w_resize.ii_dw_button_space	
//Else
//	//ll_2 			= round((newheight - dw_others.Y - dw_others.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 2, 1)
//	ll_2 			= round((newheight - dw_others.Y - dw_others.Height - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 2, 1)
//	
//	dw_detail.Height = dw_detail.Height + ll_2
//	dw_others.y		  = dw_detail.y + dw_detail.Height + ll_dwsize
//	dw_others.Height = dw_others.Height + ll_2
//	dw_detail1.Height = dw_detail1.Height + ll_2
//	dw_detail1.y		  = dw_others.y + dw_others.Height + ll_dwsize
//	
//	p_insert.Y	 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	p_cancel.Y	 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space	
//	p_delete.Y	 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	p_save.Y		 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	p_reset.Y	 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	p_close.Y	 = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	cb_deposit.Y = newheight - dw_detail1.y - dw_detail1.Height - iu_cust_w_resize.ii_button_space
//	
//End If
//
//If newwidth < dw_detail.X  Then
//	dw_detail.Width = 0
//	dw_others.Width = 0	
//Else
//	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
//	dw_others.Width = newwidth - dw_others.X - iu_cust_w_resize.ii_dw_button_space	
//	dw_detail1.Width = newwidth - dw_detail1.X - iu_cust_w_resize.ii_dw_button_space	
//End If
//
//SetRedraw(True)
//
end event

event ue_save;Constant Int LI_ERROR = -1
Integer li_return, i, li_rc

date		ldt_paydt
String 	ls_payid,			ls_operator

dw_cond.AcceptText()

ldt_paydt 			= dw_cond.Object.paydt[1]
ls_payid 			= Trim(dw_cond.Object.payid[1])
ls_operator			= dw_cond.Object.operator[1]

IF IsNull(ls_operator) THEN ls_operator = ""
IF IsNull(ls_payid) THEN ls_payid = ""

IF ls_operator = "" then
	f_msg_usr_err(9000, Title, "Operator를 입력하세요")
	dw_cond.SetFocus()
	dw_cond.SetColumn("operator")
	dw_cond.SetRow(1)	
	Return -1	
END IF

Select Count(*)  Into :li_rc  From Customerm  Where customerid = :ls_payid;
If SQLCA.SQLCode <> 0 Then
		f_msg_usr_err(9000, Title, "Payer가 존재하지 않습니다. 확인 하세요. ")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		Return -1 
End If

li_return = This.Trigger Event ue_extra_save()

If li_return  < 0 Then
	ROLLBACK;
	dw_cond.SetFocus()
	Return LI_ERROR

Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000, Title, "HotBilling")
	//저장 안되었다고 표시
	For i =1 To dw_detail.RowCount()
		 dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
	Next
	
    p_cancel.triggerevent("ue_disable")
    p_save.triggerevent("ue_disable")
	 p_insert.triggerevent("ue_disable")
    p_reset.triggerevent("ue_enable")
    ib_save = True
	
End if

Return 0
end event

event closequery;Int 		li_rc
Long 		ll_return
String 	ls_errmsg

dw_detail.AcceptText()
ll_return = -1
ls_errmsg = space(256)

IF IsNull(is_payid) OR is_payid = '' THEN
	is_payid = dw_cond.Object.payid[1]
END IF

If ib_save = False Then
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) or (dw_detail.RowCount() > 0 ) Then
		li_rc = MessageBox(This.Title, "HotBill을 취소 하시겠습니까?",&
			Question!, YesNo!)
		If li_rc =1 Then
			
			UPDATE CONTRACTMST
			SET	 BILL_HOTBILLFLAG = NULL
			WHERE  CONTRACTSEQ IN ( SELECT CONTRACTSEQ
											FROM   HOTCONTRACT
											WHERE  PAYID = :is_payid 
											AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
			AND	 BILL_HOTBILLFLAG IN ('P', 'R');			
			
//			UPDATE CONTRACTMST
//			SET	 BILL_HOTBILLFLAG = NULL
//			WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
//											FROM   CUSTOMERM A, CONTRACTMST B
//											WHERE  A.PAYID = :is_payid
//											AND    A.CUSTOMERID = B.CUSTOMERID
//											AND    B.BILL_HOTBILLFLAG = 'P' )
//			AND    BILL_HOTBILLFLAG = 'P';
			
			If SQLCA.SQLCode <> 0 Then		//For Programer
				MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				ROLLBACK;
				Return 1	
			End If 
			
			ll_return = -1
			ls_errmsg = space(256)
			
			SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				ROLLBACK;				
				Return 1
				
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				ROLLBACK;				
				Return 1
			End If 
			
			COMMIT;
			
			Close(this)
		Else
			Return 1
		End If
	Else
		//아무짓도 안하고 창 닫을 경우에. CJH 2009.07.24
//		UPDATE CONTRACTMST
//		SET	 BILL_HOTBILLFLAG = NULL
//		WHERE  CONTRACTSEQ IN ( SELECT B.CONTRACTSEQ
//										FROM   CUSTOMERM A, CONTRACTMST B
//										WHERE  A.PAYID = :is_payid
//										AND    A.CUSTOMERID = B.CUSTOMERID
//										AND    B.BILL_HOTBILLFLAG = 'R' )
//		AND    BILL_HOTBILLFLAG = 'R';
		
		UPDATE CONTRACTMST
		SET	 BILL_HOTBILLFLAG = NULL
		WHERE  CONTRACTSEQ IN ( SELECT CONTRACTSEQ
										FROM   HOTCONTRACT
										WHERE  PAYID = :is_payid 
										AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'))
		AND	 BILL_HOTBILLFLAG IN ('P', 'R');
		
		If SQLCA.SQLCode <> 0 Then		//For Programer
			MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			ROLLBACK;
			Return 1	
		End If 
		
		DELETE FROM HOTCONTRACT
		WHERE  PAYID = :is_payid
		AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');
		
		If SQLCA.SQLCode <> 0 Then		//For Programer
			MessageBox(Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			ROLLBACK;
			Return 1
		End If 		
		
		COMMIT;
		
		CLOSE(THIS)
	End If
Else
	Close(This)	
End If
end event

event close;call super::close;F_INIT_DSP(1,"","")
end event

event ue_insert;Constant Int LI_ERROR = -1

Long ll_row

ll_row = dw_others.InsertRow(dw_others.GetRow()+1)

dw_others.ScrollToRow(ll_row)
dw_others.SetRow(ll_row)
dw_others.SetFocus()

Return 0

end event

type dw_cond from w_a_reg_s`dw_cond within ubs_w_reg_hotbill_contract_new_bac
integer width = 2455
integer height = 452
string dataobject = "ubs_dw_reg_hotbill_cont_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid


Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
		
			Object.payid[row]      = iu_cust_help.is_data2[1]		//고객번호
			Object.customernm[row] = iu_cust_help.is_data2[2]		//고객명

		End If		
End Choose



Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;DEC{2} 	ldc_tot, ldc_refund, ldc_90
STRING	ls_customernm, ls_paydt, ls_paydt_1, ls_sysdate, ls_paydt_c
STRING   ls_empnm	
DATE		ldt_paydt
LONG		ll_return, ll_reqno, ll_row

choose case dwo.name
	case 'payid'
//			This.object.payid_1[row] = data
			SELECT CUSTOMERNM INTO :ls_customernm
			FROM   CUSTOMERM
			WHERE  CUSTOMERID = :data;
			
			IF SQLCA.SQLCODE <> 0 THEN
				f_msg_info(200, Title, "Record Not Found!")
				SetFocus()
				SetColumn("payid")
				Object.payid[row]		  = ""
				Object.customernm[row] = ""				
				return 2
			END IF
			
			Object.customernm[row] = ls_customernm 
			
			

	case 'refund'
			ldc_refund 	= this.Object.refund[1]
			ldc_tot 		= dw_detail.GetItemNumber(dw_detail.RowCount(), "totamt")
			dw_cond.Object.total[1] =  ldc_tot + ldc_refund
	case 'amt1', 'amt2', 'amt3', 'amt4', 'amt5', 'amt6'
		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impack(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
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
			dw_cond.object.paydt[row]	= ldt_paydt
			f_msg_usr_err(9000, Title, "Pay Date 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.SetColumn("paydt")
			RETURN 2
		END IF
		
	CASE "operator"
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
end choose

Return 0
end event

event dw_cond::ue_key;//조회가 없으므로 막아야 한다.
Choose Case key
//	Case KeyEnter!
//		Parent.TriggerEvent(is_default)
	Case KeyEscape!
		Parent.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

event dw_cond::losefocus;call super::losefocus;ACCEPTTEXT()
end event

event dw_cond::buttonclicked;STRING	ls_payid

dw_cond.AcceptText()

ls_payid = dw_cond.Object.payid[1]

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Contract Info"
iu_cust_msg.ib_data[1]  = FALSE
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_cond
iu_cust_msg.is_data[2]  = ls_payid

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_contract_info2, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0
end event

type p_ok from w_a_reg_s`p_ok within ubs_w_reg_hotbill_contract_new_bac
boolean visible = false
integer x = 2619
integer y = 252
end type

type p_close from w_a_reg_s`p_close within ubs_w_reg_hotbill_contract_new_bac
integer x = 1271
integer y = 1788
boolean originalsize = false
end type

type gb_cond from w_a_reg_s`gb_cond within ubs_w_reg_hotbill_contract_new_bac
integer width = 2478
integer height = 516
end type

type dw_detail from w_a_reg_s`dw_detail within ubs_w_reg_hotbill_contract_new_bac
integer x = 50
integer y = 528
integer width = 2455
integer height = 832
string dataobject = "ubs_dw_reg_hotbill_cont_det"
boolean livescroll = false
end type

event dw_detail::retrieveend;Int li_return
Long ll_preamt
Dec  ldc_preamt

If rowcount > 0 Then
	cb_hotbill.Enabled = False
	p_insert.TriggerEvent("ue_enable")	
	p_save.TriggerEvent("ue_enable")
	p_cancel.TriggerEvent("ue_enable")
    p_reset.TriggerEvent("ue_enable")	
	This.object.t_termdt.Text = Mid(is_termdt, 1,4) + "-" + Mid(is_termdt, 5,2) + "-" + Mid(is_termdt, 7,2)
Else
	cb_hotbill.Enabled = True
//	p_insert.TriggerEvent("ue_enable")		
	p_insert.TriggerEvent("ue_disable")	
	p_save.TriggerEvent("ue_disable")
	p_cancel.TriggerEvent("ue_disable")
   p_reset.TriggerEvent("ue_enable")		
	li_return = wfi_preamt_chk(ldc_preamt)
	IF li_return = 0 Then
		IF ldc_preamt > 0 or ldc_preamt < 0 Then
         	f_msg_info(9000, parent.Title, "당월 청구자료가 없습니다.~r~n현재미납액은 "+string(ldc_preamt,'#,##0.00')+"입니다.~r~확인하시고 수납처리하시기 바랍니다.")
		End IF	
	End IF	
End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;wf_set_total()

end event

type p_delete from w_a_reg_s`p_delete within ubs_w_reg_hotbill_contract_new_bac
boolean visible = false
integer x = 471
integer y = 1792
end type

type p_insert from w_a_reg_s`p_insert within ubs_w_reg_hotbill_contract_new_bac
integer x = 50
integer y = 1788
end type

type p_save from w_a_reg_s`p_save within ubs_w_reg_hotbill_contract_new_bac
integer x = 352
integer y = 1788
end type

type p_reset from w_a_reg_s`p_reset within ubs_w_reg_hotbill_contract_new_bac
integer x = 965
integer y = 1788
end type

type gb_3 from groupbox within ubs_w_reg_hotbill_contract_new_bac
integer x = 55
integer y = 524
integer width = 2862
integer height = 228
integer taborder = 22
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 27306400
string text = "Progress"
borderstyle borderstyle = styleraised!
end type

type p_cancel from u_p_cancel within ubs_w_reg_hotbill_contract_new_bac
integer x = 658
integer y = 1788
integer height = 92
boolean bringtotop = true
end type

type cb_hotbill from commandbutton within ubs_w_reg_hotbill_contract_new_bac
boolean visible = false
integer x = 2578
integer y = 208
integer width = 297
integer height = 92
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&HotBill"
end type

event clicked;SetPointer(HourGlass!)

//Hotbill 프로시저를 실행시킨다.
Integer 	i,				li_error,		li_chk_cnt1, 	li_chk_cnt2
String 	ls_errmsg,	ls_pgm_id,		ls_chargedt, 	ls_hotbillingflag
String 	ls_reqdt, 	ls_where, 		ls_reqdt_add
Date 		ld_reqdt, 	ld_reqdt_next, ldt_trdt
integer 	li_day,		li_progress
Long 		ll_return, 	ll_row,			LL,		ll_cnt,	ll_deposit_cnt

String 	ls_user_id, 	ls_regcod,		ls_tmp, 	ls_ref_desc, ls_refund[]
String 	ls_itemcod, ls_itemnm, 	ls_trcod,	ls_trcodnm,		ls_process
DEC{2}  	ldc_tot,		ldc_refund, ldc_refundH,	ldc_tramt,	ldc_tramt2


ls_user_id = gs_user_id

//  =========================================================================================
//  2008-03-18 hcjung   
//  핫빌 버튼 누르자마자 disable 시키기
//  =========================================================================================
cb_hotbill.Enabled = False

dw_cond.AcceptText( )
ll_return = -1
ls_errmsg = space(256)

//---------------------------------------------------------
// 필수조건 항목 : PAYID, TERMDT
//---------------------------------------------------------
//해당 고객의 청구 주기 
is_payid 			= Trim(dw_cond.object.payid[1])
If IsNull(is_payid) Then 	is_payid = ""
If is_payid 	= "" Then
	f_msg_info(200, Title, "Payer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	Return -1
End If

is_termdt 	= String(dw_cond.object.termdt[1], 'yyyymmdd')
If IsNull(is_termdt) Then is_termdt = ""
If is_termdt = "" Then
	f_msg_info(200, Title, "Desired Termination Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	Return -1
End If
//----필수항목 CHECK END....---------------------------------------------

//HotBil 사용 가능 여부, 청구주기
SELECT B.BILCYCLE, 		A.HOTBILLFLAG 
  INTO :ls_chargedt, 	:ls_hotbillingflag
  FROM CUSTOMERM A, 		BILLINGINFO B
 WHERE A.CUSTOMERID 		= B.CUSTOMERID
   AND A.CUSTOMERID 		= :is_payid;

IF IsNull(ls_hotbillingflag) then ls_hotbillingflag = ''
//If ls_hotbillingflag <> "" THEN
//	f_msg_info(100, title, "이미 해지즉시불처리된 납입자 입니다.")
//	Return -1
//End If
IF ls_hotbillingflag = "E" OR ls_hotbillingflag = "S" THEN
	f_msg_info(100, title, "이미 해지즉시불처리된 납입자 입니다.")
	RETURN -1
END IF

SELECT REQDT INTO :ld_reqdt FROM REQCONF
 WHERE CHARGEDT = :ls_chargedt;

ls_reqdt 		= String(ld_reqdt, 'yyyymmdd')
ld_reqdt_next 	= fd_next_month(ld_reqdt, Integer(Mid(ls_reqdt, 7, 2)))
ls_reqdt_add 	= String(ld_reqdt_next, 'yyyymmdd')

//해지일이 더 작으면
If ls_reqdt > is_termdt Then
	f_msg_usr_err(212, title+ "today:" +  Mid(ls_reqdt, 1,4)+ "-" + &
	 Mid(ls_reqdt, 5,2)+ "-" + Mid(ls_reqdt, 7,2), "Desired Termination Date")
	Return -1
End IF

li_progress = 0

gb_3.Show()
hpb_1.Show()
hpb_1.Position = 0 
Yield()

//Web에서 이상한 오류로 인해 삭제하고 시작 한다.
gb_3.text = 'Process Name : HOTCLEAR --> Starting....'
SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	gb_3.Hide()
   hpb_1.Hide()

   Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
	gb_3.Hide()
	hpb_1.Hide()
	
   Return -1
End If
li_progress += 1
wf_progress(li_progress)
gb_3.text = 'Process Name : HOTCLEAR'

//----------------------------------------------------------------------------
//il_cnt = HotBil 할 COUNT =====> 'H0', 'H100'
//----------------------------------------------------------------------------
For i = 1 To il_cnt
	Choose Case is_start[i]
		Case "1"
			//정액 상품
			ls_errmsg = space(256)
			ls_process = 'HOTITEMSALE_M'
		   SQLCA.HOTITEMSALE_M(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			   li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		case '2'
		   ls_errmsg = space(256)
			ls_process = 'HOTAPPENDPOST_BILCDR_V2'
			SQLCA.HOTAPPENDPOST_BILCDR_V2(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"2 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "2 "+ls_errmsg)
				li_error = -1
				Exit;
			End If
	   Case "3"
			//통화 상품
		   ls_errmsg = space(256)
			ls_process = 'HOTITEMSALE_POSTV'
			SQLCA.HOTITEMSALE_POSTV(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"3 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "3 "+ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "4"
			//할인 대상자 선정
			ls_errmsg = space(256)
			ls_process = 'HOTDISCOUNT_CUSTOMER'
			SQLCA.HOTDISCOUNT_CUSTOMER(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
			  MessageBox(Title+'~r~n'+ "4 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "4 " + ls_errmsg)
				
            li_error = -1
				Exit;
			End If
		Case "5"
			//판매 품목 할인
			ls_errmsg = space(256)
			ls_process = 'HOTCALCITEMDISCOUNT'
			SQLCA.HOTCALCITEMDISCOUNT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programe
				MessageBox(Title+'~r~n'+"5 "+ ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "5 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		
		Case "6"
			//청구 Collection
			ls_errmsg = space(256)
			ls_process = 'HOTSALECLOSE'
			SQLCA.HOTSALECLOSE(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For P
				MessageBox(Title+'~r~n'+"6 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	    //For User
				MessageBox(Title, "6 " + ls_errmsg)
				li_error = -1
				Exit;
			ElseIF ll_return = 2 Then   //2005.01.10. khpart modify 청구자료collection에서 당월청구내역없으면 
				li_error = 2             //hotbilling처리 안한다. 밑단 프로시저 발생 안시킨다.
				Exit;				          //2005.01.10. khpart modify end
			End If
		Case "7"
			//청구 품목 할인
			ls_errmsg = space(256)
			ls_process = 'HOTCALCINVDISCOUNT'
			SQLCA.HOTCALCINVDISCOUNT(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"7 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "7 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "8"
			//연체료
			ls_errmsg = space(256)
			ls_process = 'HOTDELAYFEE'
			SQLCA.HOTDELAYFEE(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"8 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "8 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "9"
			//기입금 차감액
			ls_errmsg = space(256)
			ls_process = 'HOTMINUSINPUT'
			SQLCA.HOTMINUSINPUT(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"9 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "9 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "10"
			//세금액
			ls_errmsg = space(256)
			ls_Process = 'HOTCALCTAX'
			SQLCA.HOTCALCTAX(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"10 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "10 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "11"
			//절삭액
			ls_errmsg = space(256)
			ls_process = 'HOTCALCTRUNK'
			SQLCA.HOTCALCTRUNK(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"11 "+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title,"11 "+ ls_errmsg)
				li_error = -1
				Exit;
			End If
	End Choose
	li_progress += 1
	wf_progress(li_progress)
	gb_3.text = "Process : " +  ls_process

Next
//------END...........-------------------------------------------------------------
If li_error 	= -1  Then
	ll_return 	= -1
	ls_errmsg 	= space(256)
	
	SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		gb_3.Hide()
		hpb_1.Hide()
		Return -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(Title, "1 " + ls_errmsg)
		gb_3.Hide()
		hpb_1.Hide()
		Return -1
	End IF
	
Else
	If li_error = 2 Then   // 2005.01.10.  khpark modify start 청구내역자료collection에 return = 2 추가  
		ll_return = -1
		ls_errmsg = space(256)
		
		SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			gb_3.Hide()
			hpb_1.Hide()
			Return -1
		ElseIf ll_return < 0 Then	//For User
			MessageBox(Title, "1 " + ls_errmsg)
			gb_3.Hide()
			hpb_1.Hide()
			Return -1
		End IF
   End IF                // 2005.01.10.  khpark modify end 청구내역자료collection에 return = 2 추가        
	
	//-------------------------------------
	ll_row 	= dw_detail.Retrieve(is_payid)
//	gb_3.text = "Process : " +  'Refund...'
//	
//	//=========================================================7
//	// Refund 금액 계산 -- &&& 선수금 처리
//	//Refund itemcod;trcod [HR001;RE999]
//	//=========================================================7
//	IF WF_REFUND(ll_row, ld_reqdt_next) = -1 THEN
//		return -1
//	END IF
//	ls_process = 'REFUND'
//	ib_save 			= False
//	li_progress 	+= 1
//	wf_progress(li_progress)
//	gb_3.text 		= "Process : " +  ls_process
	
End If

ll_row 	= dw_detail.Retrieve(is_payid)
FOR ll =  1 to ll_row
	ls_itemcod 		=  dw_detail.Object.itemmst_itemcod[ll]
	SELECT Count(*) INTO :li_chk_cnt1 FROM DEPOSIT_REFUND
	 WHERE OUT_ITEM =  :ls_itemcod ;
	IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt1) THEN li_chk_cnt1 = 0
	
	SELECT Count(*) INTO :li_chk_cnt2 FROM PREPAY_REFUND
	 WHERE OUT_ITEM =  :ls_itemcod ;
	IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt2) THEN li_chk_cnt2 = 0
	
	IF ( li_chk_cnt1 + li_chk_cnt2 ) > 0 THEN
		dw_detail.Object.ss[ll] 		= -1
		dw_detail.Object.dctype[ll] 	= 'C'
	else
		dw_detail.Object.ss[ll] 		= ll
		dw_detail.Object.dctype[ll] 	= 'D'
	end if
	dw_detail.Object.chk[ll_row] 		=  '0'
NEXT

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// 선수금 처리 
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//--------------------------------------------------------------------------
// 전월미납액 항목 Check - --
//--------------------------------------------------------------------------
//DECLARE read_minap CURSOR FOR  
// SELECT a.trdt, a.trcod, b.trcodnm, (tramt -  payidamt ) tramt
//   FROM reqdtl a, trcode b
//  WHERE a.trcod 							=  b.trcod
//    AND a.complete_yn 					= 'N'
//    AND TO_CHAR(a.trdt,'yyyymmdd') 	<= :is_termdt
//	 AND a.payid 							= :is_payid;
//
//OPEN read_minap ;
//DO WHILE(TRUE)
//	FETCH read_minap INTO :ldt_trdt, :ls_trcod, :ls_trcodnm, :ldc_tramt ;
//	If SQLCA.SQLCode < 0 Then
//		f_msg_sql_err(title, " Select Error(refund)")
//		gb_3.Hide()
//		hpb_1.Hide()
//
//		Return -1
//	ElseIf SQLCA.SQLCode = 100 Then
//		Exit
//	End If
//	IF ldc_tramt <> 0 then
//		ll_row 									= dw_detail.InsertRow(0)
//		dw_detail.Object.trdt[ll_row] 	=  ldt_trdt
//		dw_detail.Object.trcod[ll_row] 	=  ls_trcod
//		dw_detail.Object.trcodnm[ll_row] =  ls_trcodnm
//		dw_detail.Object.tramt[ll_row] 	=  ldc_tramt
//		dw_detail.Object.dctype[ll_row] 	=  'D'
//		dw_detail.Object.adjamt[ll_row] 	=  0
//		dw_detail.Object.ss[ll_row] 		=  ll_row
//		dw_detail.Object.chk[ll_row] 		=  '1'
//	END IF
//Loop
//CLOSE read_minap ;
//li_progress += 1
//wf_progress(li_progress)


ll_cnt = dw_detail.Rowcount()
//====================================================
FOR ll = 1 to ll_cnt
	ls_trcod 	= trim(dw_detail.Object.trcod[ll])
	ldc_tramt2	= dw_detail.Object.tramt[ll]
		
	SELECT itemcod, 		itemnm, 		regcod 
	  INTO :ls_itemcod, 	:ls_itemnm, :ls_regcod
	  FROM itemmst
	 WHERE trcod 		= :ls_trcod ;

 	If IsNull(ls_itemcod) or sqlca.sqlcode < 0	then ls_itemcod 	= ''
 	If IsNull(ls_itemnm) or sqlca.sqlcode < 0		then ls_itemnm 	= ''
 	If IsNull(ls_regcod) or sqlca.sqlcode < 0		then ls_regcod 	= ''
	 
	 
	dw_detail.Object.itemcod[ll] 	= ls_itemcod
	dw_detail.Object.itemnm[ll] 	= ls_itemnm
	dw_detail.Object.regcod[ll] 	= ls_regcod
	
	SELECT COUNT(*) INTO :ll_deposit_cnt
	FROM   DEPOSIT_REFUND
	WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );	

	IF ll_deposit_cnt <= 0 THEN
		dw_detail.Object.impack_card[ll] 	= Round(ldc_tramt2 * 0.1, 2)
		dw_detail.Object.impack_not[ll] 		= Round(ldc_tramt2 - Round(ldc_tramt2 * 0.1, 2), 2)
		dw_detail.Object.impack_check[ll] 	= 'A'	
		
	ELSE
		dw_detail.Object.impack_card[ll] 	= 0
		dw_detail.Object.impack_not[ll] 	= ldc_tramt2
		dw_detail.Object.impack_check[ll] 	= 'B'		
	END IF	
	 
NEXT

//---------------------------------------------------------------------
IF ll_cnt > 0 THEN
	ldc_tot 	=  dw_detail.GetItemNumber(ll_cnt, "cp_total")
	idc_total = ldc_tot
	dw_cond.Object.total[1] =  ldc_tot
	wf_set_total()
END IF

//dw_detail.SetSort('priority A')

SetPointer(Arrow!)
gb_3.Hide()
hpb_1.Hide()


Return 0
end event

type dw_split from datawindow within ubs_w_reg_hotbill_contract_new_bac
boolean visible = false
integer x = 2665
integer y = 368
integer width = 265
integer height = 692
integer taborder = 22
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_hotbill_cont_split"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type hpb_1 from hprogressbar within ubs_w_reg_hotbill_contract_new_bac
integer x = 73
integer y = 620
integer width = 2779
integer height = 64
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 50
integer setstep = 10
end type

type cb_1 from commandbutton within ubs_w_reg_hotbill_contract_new_bac
boolean visible = false
integer x = 2578
integer y = 200
integer width = 297
integer height = 92
integer taborder = 21
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Others"
end type

event clicked;//화면띄워주기 위해 강제로 코딩!!! - 2009.06.03 최재혁
String ls_pgm_id, ls_pgm_name, ls_call_type, ls_call_name[4], ls_pgm_type, ls_p_pgm_id, ls_p_pgm_name
String ls_customerid
Dec{0} lc_upd_auth
Long ll_cnt
u_cust_a_msg lu_cust_msg
Window lw_temp
Any la_open
Int li_i

SetPointer(HourGlass!)

SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
FROM   SYSPGM1T
WHERE  PGM_NM = 'Sales(PPC/ACC/ETC)';

//ls_pgm_id = '9622000'
//ls_pgm_name = 'Sales(PPC/ACC/ETC)'

//같은 프로그램 작동 중인지를 검사
For li_i = 1 To gi_open_win_no
	If gs_pgm_id[li_i] = ls_pgm_id Then
		f_msg_usr_err_app(504, Parent.Title, ls_pgm_name)
		Return
	End If
Next

//Window가 Max값 이상 열려있닌지 비교
If gi_open_win_no + 1 > gi_max_win_no Then
	f_msg_usr_err_app(505, Parent.Title, "")
	Return -1
End If

//Clicked TreeViewItem의 상위 TreeViewItem 정보 
//ls_p_pgm_id = '15000000'

SELECT PGM_NM INTO :ls_p_pgm_name
FROM   SYSPGM1T
WHERE  PGM_ID = :ls_p_pgm_id;

//*** 메세지 전달 객체에 자료 저장 ***
lu_cust_msg = Create u_cust_a_msg

lu_cust_msg.is_pgm_id   	 = ls_pgm_id
lu_cust_msg.is_grp_name 	 = ls_p_pgm_name
lu_cust_msg.is_pgm_name	    = ls_pgm_name
lu_cust_msg.is_call_name[1] = ls_call_name[1]
lu_cust_msg.is_pgm_type 	 = ls_pgm_type

If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
	f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
	Return -1
End If

Return 0




end event

type dw_others from datawindow within ubs_w_reg_hotbill_contract_new_bac
integer x = 50
integer y = 1364
integer width = 2455
integer height = 388
integer taborder = 12
boolean bringtotop = true
string title = "[Others]"
string dataobject = "ubs_dw_reg_hotbill_others"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = styleraised!
end type

event constructor;SetTransObject(SQLCA)
end event

event itemchanged;STRING	ls_trcod,		ls_regcod,			ls_itemnm,		ls_itemcod,		ls_codenm
LONG		ll_priority,	ll_deposit_cnt
dec 		ld_tax_rate
THIS.Accepttext()

CHOOSE CASE dwo.name
	CASE 'itemcod'
		
		SELECT TRCOD, REGCOD, ITEMNM, PRIORITY
		INTO   :ls_trcod, :ls_regcod, :ls_itemnm, :ll_priority
		FROM   ITEMMST
		WHERE  ITEMCOD = :data;
		
		Object.trcod[row] 	 = ls_trcod
		Object.regcod[row]	 = ls_regcod
		Object.itemnm[row]	 = ls_itemnm
		Object.priority[row]  = ll_priority
		Object.manual_yn[row] = 'N'
		Object.sale_amt[row]  = 0
		Object.taxamt[row]  = 0
		
	CASE 'sale_amt'
		
		ls_itemcod = Object.itemcod[row]
		
		SELECT CODENM INTO :ls_codenm
		FROM   SYSCOD2T
		WHERE  GRCODE = 'UBS12'
		AND    USE_YN = 'Y'
		AND    CODE   = :ls_itemcod;
		
		IF ls_codenm = "PLUS" THEN
			IF DEC(data) < 0 THEN
				f_msg_usr_err(9000, Title, "+ 금액을 입력하세요")
				Object.sale_amt[row] = 0 
				RETURN 2
			END IF
		ELSEIF ls_codenm = "MINUS" THEN
			IF DEC(data) > 0 THEN
				f_msg_usr_err(9000, Title, "- 금액을 입력하세요")
				Object.sale_amt[row] = 0 							
				RETURN 2
			END IF
		END IF		
                 //ld_tax_rate = f_get_taxrate( ls_taxcode, ls_date)
                 object.taxamt[row] = truncate(dec(data) * 0.1, 2) //부가세금액
					  
	CASE ELSE
END CHOOSE

end event

event buttonclicked;INT 		li_i,					li_chk_cnt1,	li_chk_cnt2
STRING 	ls_type,				ls_name,			ls_paydt,		ls_payid,		ls_trcod,		ls_trdt,		&
			ls_itemcod,			ls_itemnm,		ls_regcod,		ls_remark
LONG		ll_row,				ll_check,		ll_max_seq,		ll_ret_row,		ll_ret_cnt,		ll,			&
			ll_deposit_cnt
DATE		ldt_paydt,			ldt_trdt
DEC{2}	ldc_sale_amt,		ldc_tramt,		ldc_tot, ldc_sum_tramt, ldc_taxamt
Window 	lw_help

CHOOSE CASE dwo.name
	CASE 'b_rate'
		OpenWithParm(ssrt_exchange_rate_pop, iu_cust_msg)
	CASE 'b_add'
		
		THIS.Accepttext()
		
		ls_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
		ldt_paydt 	= dw_cond.object.paydt[1]
		IF IsNull(ls_paydt) THEN ls_paydt = ""	
		
		ll_check = MessageBox("확인", "Hot Bill에 반영후 취소하려면 전체취소 하셔야 됩니다. 반영하시겠습니까?", Question!, YesNo!, 1)
		
		IF ll_check = 1 THEN
		
			ll_row = dw_detail.RowCount()
			
			IF ll_row = 0 THEN
				ls_trdt 		= String(id_reqdt_next, 'yyyymmdd')
				ldt_trdt 	= id_reqdt_next
				SELECT  to_char(seq_reqnum.nextval)		INTO  :is_reqnum 	FROM    dual; 
				ll_max_seq = 0	
			ELSE
				ls_trdt 		= String(dw_detail.object.trdt[1], 'yyyymmdd')
				ldt_trdt 	= date(dw_detail.object.trdt[1])
				is_reqnum 	= dw_detail.Object.reqnum[1]
				
				IF IsNull(is_reqnum) OR is_reqnum = "" THEN
					SELECT REQNUM, TO_CHAR(TRDT, 'YYYYMMDD'), TRDT
					INTO   :is_reqnum, :ls_trdt, :ldt_trdt
					FROM   HOTREQDTL
					WHERE  PAYID = :is_payid
					 AND TO_CHAR(trdt,'yyyymmdd') 	<=  :is_termdt;
					//AND    TRCOD IS NULL;
				END IF	
					
				SELECT Max(seq) INTO :ll_max_seq
				FROM   HOTREQDTL
				WHERE  PAYID							= :is_payid
				AND	 TO_CHAR(TRDT, 'yyyymmdd') = :ls_trdt
				AND	 REQNUM 							= :is_reqnum ;
			END IF		
			
			ls_trcod		  = THIS.Object.trcod[row]
			ldc_sale_amt  = THIS.Object.sale_amt[row]
			ls_remark	  = THIS.Object.remark[row]
			ldc_taxamt = THIS.object.taxamt[row]
			ll_max_seq += 1
					
			IF IsNull(ldc_sale_amt) THEN ldc_sale_amt = 0 
			
			IF ldc_sale_amt = 0 THEN RETURN -1				
			
			//HOTREQDTL 에 넣기!
			Insert Into Hotreqdtl (
					reqnum, 		seq, 				payid, 		trdt, 			
					paydt,											transdt,		
					trcod, 		tramt, 			adjamt, 		remark,
					crtdt, 		crt_user, 		updtdt, 		updt_user, 			pgm_id, taxamt)
			Values(
					:is_reqnum, :ll_max_seq, 	:is_payid, 	to_date(:ls_trdt, 'yyyymmdd'), 
					to_date(:ls_paydt, 'yyyymmdd'),			to_date(:ls_paydt, 'yyyymmdd'), 
					:ls_trcod, 	:ldc_sale_amt,	0, 			:ls_remark,
					sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 		:gs_pgm_id[gi_open_win_no] , :ldc_taxamt);
	
			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(Title, "Insert Error(HOTREQDTL) - Others")
				ROLLBACK;
				Return -1
			End If	
			
			COMMIT;
			
			ll_ret_row = dw_detail.Retrieve(is_payid)
			
			//전월 미납액 다시 계산...
			//wf_non_payment()
			
			ll_ret_cnt = dw_detail.Rowcount()

			FOR ll =  1 to ll_ret_cnt
				ls_itemcod 	= dw_detail.Object.itemcod[ll]
				ldc_tramt 	= dw_detail.Object.tramt[ll]				
				
				SELECT Count(*) INTO :li_chk_cnt1 FROM DEPOSIT_REFUND
				WHERE  OUT_ITEM = :ls_itemcod ;
			
				IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt1) THEN li_chk_cnt1 = 0
	
				SELECT Count(*) INTO :li_chk_cnt2 FROM PREPAY_REFUND
				WHERE  OUT_ITEM = :ls_itemcod ;
	
				IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt2) THEN li_chk_cnt2 = 0
	
				IF ( li_chk_cnt1 + li_chk_cnt2 ) > 0 THEN
					dw_detail.Object.ss[ll] 		= -1
					dw_detail.Object.dctype[ll] 	= 'C'
				else
					dw_detail.Object.ss[ll] 		= ll
					dw_detail.Object.dctype[ll] 	= 'D'
				end if
				dw_detail.Object.chk[ll] 		=  '0'
				
				SELECT ITEMNM, REGCOD
			   INTO   :ls_itemnm, :ls_regcod
		  	   FROM   ITEMMST
				WHERE  ITEMCOD = :ls_itemcod;

 				If IsNull(ls_itemnm) or sqlca.sqlcode < 0		then ls_itemnm 	= ''
			 	If IsNull(ls_regcod) or sqlca.sqlcode < 0		then ls_regcod 	= ''
	 
	 
				dw_detail.Object.itemcod[ll] 	= ls_itemcod
				dw_detail.Object.itemnm[ll] 	= ls_itemnm
				dw_detail.Object.regcod[ll] 	= ls_regcod
	
				SELECT COUNT(*) INTO :ll_deposit_cnt
				FROM   DEPOSIT_REFUND
				WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );	

				IF ll_deposit_cnt <= 0 THEN
					dw_detail.Object.impack_card[ll] 	= Round(ldc_tramt * 0.1, 2)
					dw_detail.Object.impack_not[ll] 		= Round(ldc_tramt - Round(ldc_tramt * 0.1, 2), 2)
					dw_detail.Object.impack_check[ll] 	= 'A'	
				ELSE
					dw_detail.Object.impack_card[ll] 	= 0
					dw_detail.Object.impack_not[ll] 		= ldc_tramt
					dw_detail.Object.impack_check[ll] 	= 'B'		
				END IF					
			NEXT
			
			IF ll_ret_cnt > 0 THEN
				ldc_tot 	=  dw_detail.GetItemNumber(ll_ret_cnt, "cp_total")
				idc_total = ldc_tot
				dw_cond.Object.total[1] =  ldc_tot
				wf_set_total()
			END IF
			
			Object.add_check[row] = 'Y'
			

			
		END IF
	case else
end choose

Return 0
end event

type p_1 from picture within ubs_w_reg_hotbill_contract_new_bac
integer x = 2583
integer y = 64
integer width = 283
integer height = 96
boolean bringtotop = true
string picturename = "HOTBILL_e.gif"
boolean focusrectangle = false
end type

event clicked;//Hotbill 프로시저를 실행시킨다.

Integer 	i,				li_error,		li_chk_cnt1, 	li_chk_cnt2
String 	ls_errmsg,	ls_pgm_id,		ls_chargedt, 	ls_hotbillingflag
String 	ls_reqdt, 	ls_where, 		ls_reqdt_add
Date 		ld_reqdt, 	ld_reqdt_next, ldt_trdt
integer 	li_day,		li_progress
Long 		ll_return, 	ll_row,			LL,			ll_cnt,			ll_deposit_cnt,		ll_r_cnt,	&
			ll_last_cont, ll_bill_cnt,	ll_detail,	ll_minap_cnt

String 	ls_user_id, 	ls_regcod,		ls_tmp, 	ls_ref_desc, ls_refund[]
String 	ls_itemcod, ls_itemnm, 	ls_trcod,	ls_trcodnm,		ls_process
DEC{2}  	ldc_tot,		ldc_refund, ldc_refundH,	ldc_tramt,	ldc_tramt2,		ldc_tramt3

SetPointer(HourGlass!)

ls_user_id = gs_user_id
ib_save 	  = False
is_payid   = Trim(dw_cond.object.payid[1])

// 핫빌 대상 계약 조사 ----------------------------------------------------------------------------
SELECT COUNT(*) INTO :ll_r_cnt
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.BILL_HOTBILLFLAG = 'R';

IF ll_r_cnt <= 0 THEN
	f_msg_info(200, Title, "선택된 계약이 없습니다. 계약을 선택하세요!")
	Return -1
END IF
//-------------------------------------------------------------------------------------------------

// 중복 핫빌 조사 ---------------------------------------------------------------------------------
//SELECT COUNT(*) INTO :ll_bill_cnt
//FROM   HOTREQDTL
//WHERE  PAYID = :is_payid
//AND    TRDT  = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD'), 1);
//
//IF ll_bill_cnt > 0 THEN
//	f_msg_info(200, Title, "이번달에 핫빌한 이력이 있습니다. 취소하시고 다시작업하세요!")
//	Return -1
//END IF	
//test 후 원복  by hmk
SELECT COUNT(*) INTO :ll_bill_cnt
FROM   HOTREQDTL
WHERE  PAYID = :is_payid
AND    TRDT  = ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD'), 2);

IF ll_bill_cnt > 0 THEN
	f_msg_info(200, Title, "이번달에 핫빌한 이력이 있습니다. 취소하시고 다시작업하세요!")
	Return -1
END IF	
//-------------------------------------------------------------------------------------------------

// 최종 계약이 아닌 부분 계약 핫빌인 경우 미납을 먼저 정산 ----------------------------------------
SELECT COUNT(*) 
INTO   :ll_last_cont
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID      = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS     <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;

IF ll_last_cont > 0 THEN
	//미납금이 있는지 확인하자...
	SELECT SUM(TRAMT) + SUM(NVL(TAXAMT,0))
	INTO   :ldc_tramt3
	FROM   REQDTL
	WHERE  PAYID = :is_payid;
	
	IF ldc_tramt3 <> 0 THEN
		f_msg_info(200, Title, "미납액이 존재합니다. 빌에 있는 미납액을 꼭 먼저 정산하세요.")
	END IF
END IF
//-------------------------------------------------------------------------------------------------

//  =========================================================================================
//  2008-03-18 hcjung   
//  핫빌 버튼 누르자마자 disable 시키기
//  =========================================================================================
p_1.Enabled = False

dw_cond.AcceptText( )
ll_return = -1
ls_errmsg = space(256)

//---------------------------------------------------------
// 필수조건 항목 : PAYID, TERMDT
//---------------------------------------------------------
//해당 고객의 청구 주기 
If IsNull(is_payid) Then 	is_payid = ""
If is_payid 	= "" Then
	f_msg_info(200, Title, "Payer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	Return -1
End If

is_termdt 	= String(dw_cond.object.termdt[1], 'yyyymmdd')
If IsNull(is_termdt) Then is_termdt = ""
If is_termdt = "" Then
	f_msg_info(200, Title, "Desired Termination Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	Return -1
End If
//----필수항목 CHECK END....---------------------------------------------

//HotBil 사용 가능 여부, 청구주기
SELECT B.BILCYCLE, 		A.HOTBILLFLAG
  INTO :ls_chargedt, 	:ls_hotbillingflag
  FROM CUSTOMERM A, 		BILLINGINFO B
 WHERE A.CUSTOMERID 		= B.CUSTOMERID
   AND A.CUSTOMERID 		= :is_payid;

IF IsNull(ls_hotbillingflag) then ls_hotbillingflag = ''

IF ls_hotbillingflag = "E" OR ls_hotbillingflag = "S" THEN
	f_msg_info(100, title, "이미 해지즉시불처리된 납입자 입니다.")
	RETURN -1
END IF

SELECT REQDT INTO :ld_reqdt FROM REQCONF
 WHERE CHARGEDT = :ls_chargedt;
 
is_chargedt = ls_chargedt

ls_reqdt 		= String(ld_reqdt, 'yyyymmdd')
ld_reqdt_next 	= fd_next_month(ld_reqdt, Integer(Mid(ls_reqdt, 7, 2)))
id_reqdt_next  = ld_reqdt_next
ls_reqdt_add 	= String(ld_reqdt_next, 'yyyymmdd')

//해지일이 더 작으면
If ls_reqdt > is_termdt Then
	f_msg_usr_err(212, title+ "today:" +  Mid(ls_reqdt, 1,4)+ "-" + &
	 Mid(ls_reqdt, 5,2)+ "-" + Mid(ls_reqdt, 7,2), "Desired Termination Date")
	Return -1
End IF

li_progress = 0

gb_3.Show()
hpb_1.Show()
hpb_1.Position = 0 
Yield()

//Web에서 이상한 오류로 인해 삭제하고 시작 한다.
gb_3.text = 'Process Name : HOTCLEAR --> Starting....'
//클리어 할때 start 를 줘서 선택한 계약 정보가 없어지지 않도록 한다.
SQLCA.HOTCLEAR(is_payid, 'START', ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	gb_3.Hide()
   hpb_1.Hide()

   Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
	gb_3.Hide()
	hpb_1.Hide()
	
   Return -1
End If
li_progress += 1
wf_progress(li_progress)
gb_3.text = 'Process Name : HOTCLEAR'

//----------------------------------------------------------------------------
//il_cnt = HotBil 할 COUNT =====> 'H0', 'H100'
//----------------------------------------------------------------------------
For i = 1 To il_cnt
	Choose Case is_start[i]
		Case "1"
			//정액 상품
			ls_errmsg = space(256)
			ls_process = 'HOTITEMSALE_M_CONT'
		   SQLCA.HOTITEMSALE_M_CONT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			   li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		case '2'
		   ls_errmsg = space(256)
			ls_process = 'HOTAPPENDPOST_BILCDR_V2_CONT'
			SQLCA.HOTAPPENDPOST_BILCDR_V2_CONT(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"2 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "2 "+ls_errmsg)
				li_error = -1
				Exit;
			End If
	   Case "3"
			//통화 상품
		   ls_errmsg = space(256)
			ls_process = 'HOTITEMSALE_POSTV'
			SQLCA.HOTITEMSALE_POSTV_CONT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"3 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "3 "+ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "4"
			//할인 대상자 선정
			ls_errmsg = space(256)
			ls_process = 'HOTDISCOUNT_CUSTOMER'
			SQLCA.HOTDISCOUNT_CUSTOMER_CONT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
			  MessageBox(Title+'~r~n'+ "4 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "4 " + ls_errmsg)
				
            li_error = -1
				Exit;
			End If
		Case "5"
			//판매 품목 할인
			ls_errmsg = space(256)
			ls_process = 'HOTCALCITEMDISCOUNT'
			SQLCA.HOTCALCITEMDISCOUNT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programe
				MessageBox(Title+'~r~n'+"5 "+ ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "5 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
//		Case "6"
//			//위약금계산  2016/01/25 정책 변경으로 위약금계산 막음
//			ls_errmsg = space(256)
//			ls_process = 'HOTITEMSALEPENALTY'
//			SQLCA.HOTITEMSALE_PENALTY(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
//			If SQLCA.SQLCode < 0 Then		//For Programe
//				MessageBox(Title+'~r~n'+"6 "+ ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//				li_error = -1
//				Exit;
//			ElseIf ll_return < 0 Then	//For User
//				MessageBox(Title, "6 " + ls_errmsg)
//				li_error = -1
//				Exit;
//			End If
		Case "6"
			//청구 Collection
			ls_errmsg = space(256)
			ls_process = 'HOTSALECLOSE'
			SQLCA.HOTSALECLOSE_CONT(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For P
				MessageBox(Title+'~r~n'+"6 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	    //For User
				MessageBox(Title, "6 " + ls_errmsg)
				li_error = -1
				Exit;
			ElseIF ll_return = 2 Then   //2005.01.10. khpart modify 청구자료collection에서 당월청구내역없으면 
				li_error = 2             //hotbilling처리 안한다. 밑단 프로시저 발생 안시킨다.
				Exit;				          //2005.01.10. khpart modify end
			End If
		Case "7"
			//청구 품목 할인
			ls_errmsg = space(256)
			ls_process = 'HOTCALCINVDISCOUNT'
			SQLCA.HOTCALCINVDISCOUNT(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"7 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "7 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "8"
			//연체료
			ls_errmsg = space(256)
			ls_process = 'HOTDELAYFEE'
			SQLCA.HOTDELAYFEE(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"8 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "8 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "9"
			//기입금 차감액
			ls_errmsg = space(256)
			ls_process = 'HOTMINUSINPUT'
			SQLCA.HOTMINUSINPUT(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"9 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "9 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "10"
			//세금액
			ls_errmsg = space(256)
			ls_Process = 'HotCalcVAT'
			SQLCA.HotCalcVAT(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"10 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "10 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "11"
			//절삭액
			ls_errmsg = space(256)
			ls_process = 'HOTCALCTRUNK'
			SQLCA.HOTCALCTRUNK(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"11 "+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title,"11 "+ ls_errmsg)
				li_error = -1
				Exit;
			End If
	End Choose
	li_progress += 1
	wf_progress(li_progress)
	gb_3.text = "Process : " +  ls_process

Next
//------END...........-------------------------------------------------------------

If li_error 	= -1  Then
	ll_return 	= -1
	ls_errmsg 	= space(256)
	
	SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		gb_3.Hide()
		hpb_1.Hide()
		rollback;		
		Return -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(Title, "1 " + ls_errmsg)
		gb_3.Hide()
		hpb_1.Hide()
		rollback;		
		Return -1
	End IF
	
Else
	If li_error = 2 Then   // 2005.01.10.  khpark modify start 청구내역자료collection에 return = 2 추가  
		ll_return = -1
		ls_errmsg = space(256)
		
		SQLCA.HOTCLEAR(is_payid, 'START', ll_return, ls_errmsg)
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			gb_3.Hide()
			hpb_1.Hide()
			rollback;
			Return -1
		ElseIf ll_return < 0 Then	//For User
			MessageBox(Title, "1 " + ls_errmsg)
			gb_3.Hide()
			hpb_1.Hide()
			rollback;			
			Return -1
		End IF
   End IF                // 2005.01.10.  khpark modify end 청구내역자료collection에 return = 2 추가        
	
	//-------------------------------------
	ll_row 	= dw_detail.Retrieve(is_payid)
	gb_3.text = "Process : " +  'Refund...'
	
	//=========================================================7
	// Refund 금액 계산 -- &&& 선수금 처리
	//Refund itemcod;trcod [HR001;RE999]
	//=========================================================7
	IF wf_refund(ll_row, ld_reqdt_next) = -1 THEN
		rollback;
		return -1
	END IF
	ls_process = 'REFUND'
	ib_save 			= False
	li_progress 	+= 1
	wf_progress(li_progress)
	gb_3.text 		= "Process : " +  ls_process
	
End If

ll_row 	 = dw_detail.Retrieve(is_payid)
ll_detail = ll_row
FOR ll =  1 to ll_row
	ls_itemcod 		=  dw_detail.Object.itemcod[ll]
	SELECT Count(*) 
	INTO :li_chk_cnt1 
	FROM DEPOSIT_REFUND
	WHERE OUT_ITEM =  :ls_itemcod ;
	
	IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt1) THEN li_chk_cnt1 = 0
	
	SELECT Count(*) 
	INTO :li_chk_cnt2 
	FROM PREPAY_REFUND
	WHERE OUT_ITEM =  :ls_itemcod ;
	
	IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt2) THEN li_chk_cnt2 = 0
	
	IF ( li_chk_cnt1 + li_chk_cnt2 ) > 0 THEN
		dw_detail.Object.ss[ll] 		= -1
		dw_detail.Object.dctype[ll] 	= 'C'
	else
		dw_detail.Object.ss[ll] 		= ll
		dw_detail.Object.dctype[ll] 	= 'D'
	end if
	dw_detail.Object.chk[ll_row] 		=  '0'
NEXT

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// 선수금 처리 
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


IF ll_last_cont = 0 THEN		//마지막 계약이면
//--------------------------------------------------------------------------
// 전월미납액 항목 Check - --
//--------------------------------------------------------------------------
//	DECLARE read_minap CURSOR FOR  
//	 SELECT a.trdt, a.trcod, b.trcodnm, (tramt -  payidamt ) tramt
//		FROM reqdtl a, trcode b
//	  WHERE a.trcod 							=  b.trcod
//		 AND a.complete_yn 					= 'N'
//		 AND TO_CHAR(a.trdt,'yyyymmdd') 	<= :is_termdt
//		 AND a.payid 							= :is_payid
//		 AND a.trcod    NOT IN ('B01', 'B02');
//	
//	OPEN read_minap ;
//	DO WHILE(TRUE)
//		FETCH read_minap INTO :ldt_trdt, :ls_trcod, :ls_trcodnm, :ldc_tramt ;
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(title, " Select Error(refund)")
//			gb_3.Hide()
//			hpb_1.Hide()
//	
//			Return -1
//		ElseIf SQLCA.SQLCode = 100 Then
//			Exit
//		End If
//		IF ldc_tramt <> 0 then
//			ll_row 									= dw_detail.InsertRow(0)
//			dw_detail.Object.trdt[ll_row] 	=  ldt_trdt
//			dw_detail.Object.trcod[ll_row] 	=  ls_trcod
//			dw_detail.Object.trcodnm[ll_row] =  ls_trcodnm
//			dw_detail.Object.tramt[ll_row] 	=  ldc_tramt
//			dw_detail.Object.dctype[ll_row] 	=  'D'
//			dw_detail.Object.adjamt[ll_row] 	=  0
//			dw_detail.Object.ss[ll_row] 		=  ll_row
//			dw_detail.Object.chk[ll_row] 		=  '1'
//			dw_detail.Object.remark[ll_row]  =  is_termdt
//			ll_minap_cnt = ll_minap_cnt + 1
//		END IF
//	Loop
//	CLOSE read_minap ;
//	li_progress += 1
//	wf_progress(li_progress)
//	
//	//dw_detail 조회된 건수가 없고 전월미납금이 있을 경우에는 save버튼 활성화 해야한단다.
//	IF ll_detail <= 0 THEN
//		IF ll_minap_cnt > 0 THEN
//			cb_hotbill.Enabled = False
//			p_insert.TriggerEvent("ue_enable")	
//			p_save.TriggerEvent("ue_enable")
//			p_cancel.TriggerEvent("ue_enable")
//		   p_reset.TriggerEvent("ue_enable")	
//		END IF
//	END IF
END IF

ll_cnt = dw_detail.Rowcount()
//====================================================
FOR ll = 1 to ll_cnt
	ls_trcod 	= trim(dw_detail.Object.trcod[ll])
	ldc_tramt2	= dw_detail.Object.tramt[ll]
		
	SELECT itemcod, 		itemnm, 		regcod 
	  INTO :ls_itemcod, 	:ls_itemnm, :ls_regcod
	  FROM itemmst
	 WHERE trcod 		= :ls_trcod ;

 	If IsNull(ls_itemcod) or sqlca.sqlcode < 0	then ls_itemcod 	= ''
 	If IsNull(ls_itemnm) or sqlca.sqlcode < 0		then ls_itemnm 	= ''
 	If IsNull(ls_regcod) or sqlca.sqlcode < 0		then ls_regcod 	= ''
	 
	 
	dw_detail.Object.itemcod[ll] 	= ls_itemcod
	dw_detail.Object.itemnm[ll] 	= ls_itemnm
	dw_detail.Object.regcod[ll] 	= ls_regcod
	
	SELECT COUNT(*) INTO :ll_deposit_cnt
	FROM   DEPOSIT_REFUND
	WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );	

	IF ll_deposit_cnt <= 0 THEN
		dw_detail.Object.impack_card[ll] 	= Round(ldc_tramt2 * 0.1, 2)
		dw_detail.Object.impack_not[ll] 		= Round(ldc_tramt2 - Round(ldc_tramt2 * 0.1, 2), 2)
		dw_detail.Object.impack_check[ll] 	= 'A'	
		
	ELSE
		dw_detail.Object.impack_card[ll] 	= 0
		dw_detail.Object.impack_not[ll] 	= ldc_tramt2
		dw_detail.Object.impack_check[ll] 	= 'B'		
	END IF	
	 
NEXT

//---------------------------------------------------------------------
IF ll_cnt > 0 THEN
	ldc_tot 	=  dw_detail.GetItemNumber(ll_cnt, "cp_total") +  dw_detail.GetItemNumber(ll_cnt, "cp_vat")	 	
	idc_total = ldc_tot
	dw_cond.Object.total[1] =  ldc_tot
	wf_set_total()
END IF

//dw_detail.SetSort('priority A')
COMMIT;
SetPointer(Arrow!)
gb_3.Hide()
hpb_1.Hide()

Return 0
end event

type cb_deposit from commandbutton within ubs_w_reg_hotbill_contract_new_bac
integer x = 1911
integer y = 1784
integer width = 357
integer height = 96
integer taborder = 22
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Deposit Log"
end type

event clicked;INTEGER	li_rc
STRING	ls_payid

dw_cond.AcceptText()

ls_payid = dw_cond.Object.payid[1]

IF IsNull(ls_payid) THEN ls_payid = ""

IF ls_payid = "" THEN
	RETURN -1
END IF

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Sales Log(Deposit)"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_detail
iu_cust_msg.is_data[2]  = ls_payid

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_hotbill_deposit, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0


end event

