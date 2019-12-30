$PBExportHeader$ubs_w_reg_hotreqdtl_new.srw
$PBExportComments$[jhchoi]  Hot Bill 계산 ( 부분핫빌 가능 ) - 2009.06.28
forward
global type ubs_w_reg_hotreqdtl_new from w_a_reg_s
end type
type p_cancel from u_p_cancel within ubs_w_reg_hotreqdtl_new
end type
type cb_hotbill from commandbutton within ubs_w_reg_hotreqdtl_new
end type
type dw_split from datawindow within ubs_w_reg_hotreqdtl_new
end type
type hpb_1 from hprogressbar within ubs_w_reg_hotreqdtl_new
end type
type cb_1 from commandbutton within ubs_w_reg_hotreqdtl_new
end type
type p_1 from picture within ubs_w_reg_hotreqdtl_new
end type
type gb_3 from groupbox within ubs_w_reg_hotreqdtl_new
end type
end forward

global type ubs_w_reg_hotreqdtl_new from w_a_reg_s
integer width = 2981
integer height = 2108
event type integer ue_cancel ( )
p_cancel p_cancel
cb_hotbill cb_hotbill
dw_split dw_split
hpb_1 hpb_1
cb_1 cb_1
p_1 p_1
gb_3 gb_3
end type
global ubs_w_reg_hotreqdtl_new ubs_w_reg_hotreqdtl_new

type variables
String is_start[], is_hotflag, is_payid, is_termdt, is_method[], &
		is_trcod[], is_seq_app, is_reqnum
DEC{2} idc_total, idc_receive, idc_change, idc_refund, idc_amt[], idc_preamt, idc_impack
Boolean ib_save
Integer il_cnt, ii_method_cnt
end variables

forward prototypes
public subroutine wf_set_total ()
public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt)
public function integer wfi_preamt_chk (ref long al_preamt)
public function integer wf_split (date wfdt_paydt)
public function integer wf_set_impack (string as_data)
public function integer wf_split_new (date wfdt_paydt)
public subroutine wf_progress (integer wfi_cnt)
public function integer wf_refund (long wfl_row, date wfd_reqdt_next)
end prototypes

event type integer ue_cancel();Integer li_return, i
Long ll_return
String ls_errmsg

ll_return = -1
ls_errmsg = space(256)
F_INIT_DSP(1,"","")

SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
   Return -1
End If 

f_msg_info(3000, Title, "HotBilling Cancel")

For i =1 To dw_detail.RowCount()
   dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

ib_save = true

TriggerEvent("ue_reset")  //리셋한다.

Return 0
end event

public subroutine wf_set_total ();dec{2} ldc_TOTAL

ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_total")
dw_cond.Object.total[1] =  ldc_total

F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

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
  
SELECT count(distinct a.contractseq)
 INTO  :al_cnt
 FROM  contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
 AND  a.svccod = c.svccod          
 AND  c.svctype <> '9' 
 AND  b.payid = :is_payid	 
 AND  A.Status <> :ls_term_status
 AND  a.contractseq not in (select distinct ref_contractseq
                            from svcorder 
									 where customerid = a.customerid
									   and ( status = :ls_term_status or status = :ls_req_status)) ;
										
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 1)")
	Return -1
End If	

SELECT to_char(nvl(max(a.bil_todt),sysdate),'yyyymmdd')
 INTO  :as_bil_todt
 FROM  contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
 AND  a.svccod = c.svccod          
 AND  c.svctype <> :ls_non_svctype    
 AND  b.payid = :is_payid	 
 AND  a.status = :ls_term_status;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 2)")
	Return -1
End If	

 
return 0
end function

public function integer wfi_preamt_chk (ref long al_preamt);String  ls_chargedt, ls_trdt

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
				ls_temp 		+= LeftA(ls_itemnm + space(24), 24) +  ' '   //아이템
				li_cnt 		=  1
				ls_temp 		+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
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
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
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
				  
				ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
				f_printpos(ls_temp)
			EnD IF
		NEXT
		ls_val 	= fs_convert_sign(ldc_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
//		F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id) original
		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_seq,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 				
//NEXT  영수증 한장만 출력하도록 변경 2007-08-13 hcjung		
PRN_ClosePort()
RETURN 0
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

public function integer wf_split_new (date wfdt_paydt);//해지 화면..변경용... impact card 때문에 변경함...
Long		ll, 					ll_cnt,			ll_row, 		ll_seq, 	ll_reqnum
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
//추가
STRING	ls_trcod_im,		ls_method0_im,	ls_end,				ls_add
DEC{2}	ldc_imnot,			ldc_im,			ldc_impack_in,		ldc_amt0_im
INT		li_update

dw_cond.AcceptText()
dw_detail.AcceptText()
//--------------------------------------------------------------------
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ldt_paydt 			= dw_cond.Object.paydt[1]
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
	IF ldc_impack > 0 THEN
		dw_detail.SetSort('impack_check A, impack_card A, tramt A')
	ELSEIF ldc_impack < 0 THEN
		dw_detail.SetSort('impack_check A, impack_card D, tramt A')
	ELSE
		dw_detail.SetSort('tramt A')
	END IF
ELSE
	IF ldc_impack < 0 THEN
		dw_detail.SetSort('impack_check A, impack_card D, tramt D')
	ELSEIF ldc_impack > 0 THEN
		dw_detail.SetSort('impack_check A, impack_card A, tramt D')
	ELSE
		dw_detail.SetSort('tramt D')
	END IF				
END IF

dw_detail.Sort()


select memberid INTO :ls_memberid from customerm where customerid = :ls_customerid ;

IF IsNull(ls_memberid) then ls_memberid = ''

ls_payid 			= dw_cond.Object.payid[1]

ldc_amt0[1] 		= dw_cond.object.amt3[1] 
ldc_amt0[2] 		= dw_cond.object.amt2[1] 
ldc_amt0[3] 		= dw_cond.object.amt4[1] 
ldc_amt0[4] 		= dw_cond.object.amt1[1]
	
ls_method0[1] 		= dw_cond.object.method3[1]
ls_method0[2] 		= dw_cond.object.method2[1]
ls_method0[3] 		= dw_cond.object.method4[1]
ls_method0[4] 		= dw_cond.object.method1[1]
	
ls_trcod0[1] 		= dw_cond.object.trcod3[1]
ls_trcod0[2] 		= dw_cond.object.trcod2[1]
ls_trcod0[3] 		= dw_cond.object.trcod4[1]
ls_trcod0[4] 		= dw_cond.object.trcod1[1]

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= dw_cond.object.trcod5[1]
	ls_method0_im	= dw_cond.object.method5[1]	
	ldc_amt0_im		= dw_cond.object.amt5[1]			
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
FOR li_lp = 1 to 4
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

ll_cnt 		= dw_detail.RowCount()

ls_add = 'N'
ls_end = 'N'

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
		li_update		= 0			
		li_chk 			= 0
		ls_ok				= 'N'
		
		IF ldc_impack <> 0 THEN
			ldc_imnot 		= dw_detail.object.impack_not[ll]
			ldc_im			= dw_detail.object.impack_card[ll]
		END IF
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		IF ldc_impack > 0 THEN
			IF ldc_im > 0 THEN
				IF li_first 	=  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else
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
				IF li_first 	=  0 then
					li_paycnt 	= 1
					li_first 	= 1
				else
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
			
			ls_trcod =  dw_detail.Object.trcod[ll]
			
			select itemcod, regcod, priority INTO :ls_itemcod, :ls_regcod, :ll_priority FROM itemmst
			 WHERE trcod = :ls_trcod ;
			
			dw_split.Object.itemcod[ll_row] 		= ls_itemcod
			dw_split.Object.paymethod[ll_row] 	= ls_method0_im
			dw_split.Object.regcod[ll_row] 		= ls_regcod
			dw_split.Object.payamt[ll_row] 		= ldc_impack_in
			dw_split.Object.basecod[ll_row] 		= ls_basecod
			dw_split.Object.paycnt[ll_row] 		= li_paycnt
			dw_split.Object.payid[ll_row] 		= ls_payid
			dw_split.Object.trdt[ll_row] 			= ldt_termdt
			dw_split.Object.dctype[ll_row] 		= ls_dctype
			dw_split.Object.trcod[ll_row] 		= ls_trcod_im
			dw_split.Object.sale_trcod[ll_row] 	= ls_trcod_im
			dw_split.Object.req_trdt[ll_row] 	= ls_req_trdt
		END IF
			
		IF ls_end = 'N' THEN
			FOR li_pp =  li_pay_cnt to ii_method_cnt
				ls_method 		= is_method[li_pp]
				ls_saletrcod 	= is_trcod[li_pp]
				ldc_rem 			= idc_amt[li_pp]

				IF li_first 	=  0 then
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
			   ( :ll_payseq, 	:ldt_paydt, 	
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
				ls_temp 		+= LeftA(ls_itemnm + space(24), 24) +  ' '   //아이템
				li_cnt 		=  1
				ls_temp 		+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
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
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
		//결제 수단별 금액 처리
		For li_lp = 1 To 4
			IF li_lp = 1 THEN
				IF ldc_amt0_im <> 0 THEN
					ls_val 	= fs_convert_sign(ldc_amt0_im,  8)
					ls_code	= ls_method0_im
					select codenm INTO :ls_codenm from syscod2t
					where grcode = 'B310' 
					  and use_yn = 'Y'
					  AND code = :ls_code ;
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
					f_printpos(ls_temp)						
				END IF
			END IF			
			
			ldc_cash 	= ldc_amt0[li_lp]
			ls_code 		= ls_method0[li_lp]			
			
			IF ldc_cash <> 0 then
				ls_val 	= fs_convert_sign(ldc_cash,  8)
				SELECT codenm 		INTO :ls_codenm 		FROM syscod2t
				 WHERE grcode 		= 'B310' 
				   AND code 		= :ls_code ;
				  
				ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
				f_printpos(ls_temp)
			EnD IF
		NEXT
		ls_val 	= fs_convert_sign(ldc_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
		f_printpos(ls_temp)
		f_printpos(ls_lin1)
//		F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id) original
		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_seq,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 				
//NEXT  영수증 한장만 출력하도록 변경 2007-08-13 hcjung		
PRN_ClosePort()
RETURN 0
end function

public subroutine wf_progress (integer wfi_cnt);INTEGER li_pcc

li_pcc =  Truncate(wfi_cnt/14 * 100 , 0)
IF li_pcc > 100 then li_pcc = 100
hpb_1.Position = li_pcc
Yield()
return
end subroutine

public function integer wf_refund (long wfl_row, date wfd_reqdt_next);String 	ls_paydt,		ls_trdt, &
			ls_in_item, 	ls_out_item, &
			ls_itemnm, 		ls_regcod, 		ls_trcod, &
			ls_regtype,		ls_contractseq,	ls_contractseq_term[],		&
			ls_activedt,	ls_priceplan
date		ldt_paydt,		ldt_trdt
Long		ll_row,			ll_max_seq,		ll_count = 0,		ll_last_cont, ll_term_cnt,	&
			ll_cnt,			ll_det_cnt
DEC{2}	ldc_in_amt,		ldc_in_amtH, &
			ldc_out_amt,	ldc_out_amtH, &
			ldc_deposit, ldc_refund, ldc_remaind, ldc_unitamt, ldc_det_item
INT		i		

ll_row 		=  wfl_row

ls_paydt 	= String(dw_cond.object.paydt[1], 'yyyymmdd')
ldt_paydt 	= dw_cond.object.paydt[1]
If IsNull(ls_paydt) Then ls_paydt = ""		

//마지막 계약인지 확인 - CJH
SELECT COUNT(*) INTO :ll_last_cont
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;

//해지즉시불 돌린 CONTRACTSEQ 찾기 - CJH
SELECT COUNT(*) INTO :ll_term_cnt
FROM ( SELECT CONTRACTSEQ
		 FROM   HOTSALE
		 WHERE  PAYID = :is_payid
		 AND    SALETODT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD')
		 GROUP BY CONTRACTSEQ );		 
		 
IF ll_term_cnt > 1 THEN				//건수가 1개 이상이면 ARRAY 에 CONTRACTSEQ 집어 넣는다.
		 
	DECLARE CONTRACTSEQ_cur CURSOR FOR
		SELECT CONTRACTSEQ
		FROM   HOTSALE
		WHERE  PAYID = :is_payid
		AND    SALETODT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD')
		GROUP BY CONTRACTSEQ;
		
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
	FROM   HOTSALE
	WHERE  PAYID = :is_payid
	AND    SALETODT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD')
	GROUP BY CONTRACTSEQ;	
	
	ls_contractseq_term[1] = ls_contractseq
END IF
	
IF ll_row = 0 THEN
		ls_trdt 		= String(wfd_reqdt_next, 'yyyymmdd')
		ldt_trdt 	= wfd_reqdt_next
		SELECT  to_char(seq_reqnum.nextval)		INTO  :is_reqnum 	FROM    dual; 
		ll_max_seq = 0	
ELSE
		ls_trdt 		= String(dw_detail.object.trdt[1], 'yyyymmdd')
		ldt_trdt 	= date(dw_detail.object.trdt[1])
		is_reqnum 	=  dw_detail.Object.reqnum[ll_row]
		
		Select Max(seq)	  Into :ll_max_seq	  from hotreqdtl 
	    where payid 							= :is_payid 
 	      and to_char(trdt, 'yyyymmdd') = :ls_trdt
	      and reqnum 							= :is_reqnum ;
END IF
	
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
//1 보증금 처리
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
IF ll_last_cont = 0 THEN				//마지막 고객이면 전체 처리...
 	DECLARE READ_DEPOSIT_ITEM CURSOR FOR  
	SELECT  IN_ITEM, OUT_ITEM
   FROM 	  DEPOSIT_REFUND 
	ORDER BY IN_ITEM, OUT_ITEM;
	
	OPEN READ_DEPOSIT_ITEM ;
	FETCH READ_DEPOSIT_ITEM INTO :ls_in_item, :ls_out_item ;	
	
	DO WHILE sqlca.sqlcode = 0 
		 
		SELECT SUM(A.PAYAMT) INTO :ldc_in_amt FROM DAILYPAYMENT A
		WHERE  A.PAYID 	= :is_payid 
		AND    A.ITEMCOD 	= :ls_in_item;
		
		SELECT SUM(A.PAYAMT) INTO :ldc_in_amtH FROM DAILYPAYMENTH A
		WHERE  A.PAYID 	= :is_payid
		AND    A.ITEMCOD 	= :ls_in_item;

		IF IsNull(ldc_in_amt) 	then ldc_in_amt = 0
		IF IsNull(ldc_in_amtH) 	then ldc_in_amtH = 0
		
		ldc_deposit 	=  ldc_in_amt + ldc_in_amtH
		//------------------------------------------------
		// 입금액이 있으면 출금액도 계산한다--해당 out_item으로.
		// ldc_refund
		//------------------------------------------------
		IF ldc_deposit <> 0 then
			SELECT itemnm, 		regcod, 		trcod 
			INTO   :ls_itemnm, 	:ls_regcod, :ls_trcod
			FROM   ITEMMST
			WHERE  ITEMCOD = :ls_out_item ;
		 
			SELECT SUM(A.PAYAMT)   INTO :ldc_out_amt FROM DAILYPAYMENT A
			WHERE  A.PAYID 	= :is_payid
			AND    A.ITEMCOD 	= :ls_out_item;
		
			SELECT SUM(A.PAYAMT)   INTO :ldc_out_amtH FROM DAILYPAYMENTH A
			WHERE  A.PayID 	= :is_payid
			AND    A.ITEMCOD 	= :ls_out_item;
			
			IF IsNull(ldc_out_amt) 		then ldc_out_amt = 0
			IF IsNull(ldc_out_amtH) 	then ldc_out_amtH = 0
			ldc_refund 	=  ldc_out_amt + ldc_out_amtH
			
			ldc_remaind = ldc_deposit + ldc_refund
		
			IF ldc_remaind <> 0 THEN
				ll_count += 1
				ldc_remaind	= ldc_remaind * -1	
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

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
					gb_3.Hide()
					hpb_1.Hide()
					ROLLBACK;
					Return -1
				End If	
			END IF
		END IF
		FETCH READ_DEPOSIT_ITEM INTO :ls_in_item, :ls_out_item ;	
	LOOP
	CLOSE READ_DEPOSIT_ITEM ;
	COMMIT ;
ELSE		//마지막이 아니면...아이템별로 뒤진다...
 	DECLARE READ_DEPOSIT_ITEM2 CURSOR FOR  
	SELECT  IN_ITEM, OUT_ITEM
   FROM 	  DEPOSIT_REFUND 
	ORDER BY IN_ITEM, OUT_ITEM;
	
	OPEN READ_DEPOSIT_ITEM2 ;
	FETCH READ_DEPOSIT_ITEM2 INTO :ls_in_item, :ls_out_item ;	
	
	DO WHILE sqlca.sqlcode = 0 
		 
		SELECT SUM(A.PAYAMT) INTO :ldc_in_amt FROM DAILYPAYMENT A
		WHERE  A.PAYID 	= :is_payid 
		AND    A.ITEMCOD 	= :ls_in_item;
		
		SELECT SUM(A.PAYAMT) INTO :ldc_in_amtH FROM DAILYPAYMENTH A
		WHERE  A.PAYID 	= :is_payid
		AND    A.ITEMCOD 	= :ls_in_item;

		IF IsNull(ldc_in_amt) 	then ldc_in_amt = 0
		IF IsNull(ldc_in_amtH) 	then ldc_in_amtH = 0
		
		ldc_deposit 	=  ldc_in_amt + ldc_in_amtH	
	
		IF ldc_deposit <> 0 then
			SELECT itemnm, 		regcod, 		trcod 
			INTO   :ls_itemnm, 	:ls_regcod, :ls_trcod
			FROM   ITEMMST
			WHERE  ITEMCOD = :ls_out_item ;
		 
			SELECT SUM(A.PAYAMT)   INTO :ldc_out_amt FROM DAILYPAYMENT A
			WHERE  A.PAYID 	= :is_payid
			AND    A.ITEMCOD 	= :ls_out_item;
		
			SELECT SUM(A.PAYAMT)   INTO :ldc_out_amtH FROM DAILYPAYMENTH A
			WHERE  A.PayID 	= :is_payid
			AND    A.ITEMCOD 	= :ls_out_item;
			
			IF IsNull(ldc_out_amt) 		then ldc_out_amt = 0
			IF IsNull(ldc_out_amtH) 	then ldc_out_amtH = 0
			ldc_refund 	=  ldc_out_amt + ldc_out_amtH
			
			ldc_remaind  = ldc_deposit + ldc_refund				//IN ITEM 값 + OUT ITEM 값
			ldc_det_item = 0												//실제 돌려줘야할 값을 초기화
			i = 1

			FOR i = 1 TO ll_term_cnt								//핫빌 돌린 contract 만큼 루프 돌면서 deposit 찾기
				
				IF ldc_remaind = 0 THEN EXIT						//이미 다 돌려줬다면 루프를 빠져라
				
				//아이템이 계약에 있는지 없는지 체크				
				SELECT COUNT(*) INTO :ll_det_cnt
				FROM   CONTRACTDET
				WHERE  CONTRACTSEQ = :ls_contractseq_term[i]
				AND    ITEMCOD     = :ls_in_item;
				
				IF ll_det_cnt > 0 THEN					//아이템이 존재하면
					
					//계약당시의 item 가격을 뽑기 위해서 시작일자, 가격정책을 뽑는다.
					SELECT TO_CHAR(ACTIVEDT, 'YYYYMMDD'), PRICEPLAN
					INTO   :ls_activedt,	:ls_priceplan
					FROM   CONTRACTMST
					WHERE  CONTRACTSEQ = :ls_contractseq_term[i];
					
					//계약당시의 item 가격을 뽑아온다.
					select unitcharge  INto :ldc_unitamt
			  		from   priceplan_rate2
			 		where  priceplan = :ls_priceplan
				   AND    itemcod   = :ls_in_item
  		 			AND    to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
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
						:ls_trcod, 	:ldc_remaind,	0, 			:is_termdt,
				  		sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 		:gs_pgm_id[gi_open_win_no] );

				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
					gb_3.Hide()
					hpb_1.Hide()
					ROLLBACK;
					Return -1
				End If	
			END IF			
		END IF
		FETCH READ_DEPOSIT_ITEM2 INTO :ls_in_item, :ls_out_item ;	
	LOOP
	CLOSE READ_DEPOSIT_ITEM2 ;
	COMMIT ;		
END IF

//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
//2 선수금 처리
//-=-=-=-=-=-=-=-=-=-=-	=-=-=-=-=-=-=-=-=-=- =-=-=-=-=-=-=-=-=-=-
// 2009.06.10 선수금은 현재 잔액을 인터넷용 선수금으로 반환함.
IF ll_last_cont = 0 THEN				//마지막 고객
	SELECT OUT_ITEM
	INTO   :ls_out_item
   FROM   PREPAY_REFUND 
   WHERE  REGTYPE = '01';
	 
	SELECT SUM(TRAMT) INTO :ldc_in_amt FROM PREPAYDET
	WHERE  PAYID 	 = :is_payid;

	IF IsNull(ldc_in_amt) 	then ldc_in_amt = 0;
   ldc_remaind = ldc_in_amt;
	
	IF ldc_remaind <> 0 then
		SELECT itemnm, 		regcod, 		trcod 
		INTO   :ls_itemnm, 	:ls_regcod, :ls_trcod
		FROM   ITEMMST
		WHERE  ITEMCOD = :ls_out_item ;
		 
		ll_count += 1
		ldc_remaind	= ldc_remaind * -1	
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
			f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
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

on ubs_w_reg_hotreqdtl_new.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
this.cb_hotbill=create cb_hotbill
this.dw_split=create dw_split
this.hpb_1=create hpb_1
this.cb_1=create cb_1
this.p_1=create p_1
this.gb_3=create gb_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
this.Control[iCurrent+2]=this.cb_hotbill
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.hpb_1
this.Control[iCurrent+5]=this.cb_1
this.Control[iCurrent+6]=this.p_1
this.Control[iCurrent+7]=this.gb_3
end on

on ubs_w_reg_hotreqdtl_new.destroy
call super::destroy
destroy(this.p_cancel)
destroy(this.cb_hotbill)
destroy(this.dw_split)
destroy(this.hpb_1)
destroy(this.cb_1)
destroy(this.p_1)
destroy(this.gb_3)
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
	p_1.Enabled = True
Else
	p_1.Enabled = False
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

dw_cond.object.trcod1[1] 	= is_trcod[1]
dw_cond.object.trcod2[1] 	= is_trcod[2]
dw_cond.object.trcod3[1] 	= is_trcod[3]
dw_cond.object.trcod4[1] 	= is_trcod[4]
dw_cond.object.trcod5[1] 	= is_trcod[5]



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


dw_cond.object.termdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.paydt[1] = f_find_shop_closedt(gs_shopid)

dw_cond.object.method1[1] = is_method[1] 
dw_cond.object.method2[1] = is_method[2] 
dw_cond.object.method3[1] = is_method[3] 
dw_cond.object.method4[1] = is_method[4] 
dw_cond.object.method5[1] = is_method[5] 

dw_cond.object.trcod1[1] 	= is_trcod[1]
dw_cond.object.trcod2[1] 	= is_trcod[2]
dw_cond.object.trcod3[1] 	= is_trcod[3]
dw_cond.object.trcod4[1] 	= is_trcod[4]
dw_cond.object.trcod5[1] 	= is_trcod[5]

idc_impack = 0

p_cancel.TriggerEvent("ue_disable")
p_1.Enabled = True

Return 0
end event

event ue_extra_save;String 	ls_paymethod, 	ls_paydt, 	ls_sysdate,			ls_nextdate
String 	ls_trdt, 		ls_reqnum, 	ls_cus_bil_todt
Long 		i, 				ll_seq, 		ll_max_seq, 		ll_cnt, ll
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

idc_amt[1] =  dw_cond.Object.amt3[1]
idc_amt[2] =  dw_cond.Object.amt2[1]
idc_amt[3] =  dw_cond.Object.amt5[1]
idc_amt[4] =  dw_cond.Object.amt4[1]
idc_amt[5] =  dw_cond.Object.amt1[1]

idc_total  =  dw_cond.Object.total[1]

idc_receive = dw_cond.Object.cp_receive[1]
idc_change 	= dw_cond.Object.cp_change[1]
idc_refund  = dw_cond.Object.refund[1]

IF IsNull(idc_receive) 	then idc_receive = 0
IF IsNull(idc_change) 	then idc_change = 0
IF IsNull(idc_refund) 	then idc_refund = 0

li_method_cnt	= 0
FOR ll = 1 to 5
	IF idc_amt[ll] <> 0 THEN	li_method_cnt += 1
NEXT

ls_paydt = String(dw_cond.object.paydt[1], 'yyyymmdd')
ls_trdt 	= String(dw_detail.object.trdt[1], 'yyyymmdd')

ldt_paydt = dw_cond.object.paydt[1]
ldt_trdt = date(dw_detail.object.trdt[1])

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
		dw_detail.SetFocus()
		dw_detail.SetColumn("amt1")
		Return -1
END IF

If ls_paydt = "" Then
		f_msg_info(200, Title, "지불일자")
		dw_detail.SetFocus()
		dw_detail.SetColumn("paydt")
		Return -1
End If

ls_nextdate = string(relativedate(date(fdt_get_dbserver_now()),1),'yyyymmdd')	
If ls_nextdate < is_termdt Then
	f_msg_usr_err(212,Title + "today:" +  MidA(ls_nextdate, 1,4) + "-" + &
										  MidA(ls_nextdate,5,2) + "-" + &
										  MidA(ls_nextdate,7,2),"해지요청일")

	Return -1	
End IF

//2009.06.30 부분핫빌 - CJH
////해당납입고객으로 해지처리 안된 고객이 있는지 Check 한다.
//li_return = wfi_contract_staus_chk(ll_cnt, ls_cus_bil_todt)
//
//IF li_return = 0 Then
//    IF ll_cnt > 0 Then
//     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
//		return -1
//	End IF
//
//    If ls_sysdate < ls_cus_bil_todt Then
//		f_msg_usr_err(212,Title + "today:" +  Mid(ls_sysdate, 1,4) + "-" + &
//											  Mid(ls_sysdate,5,2) + "-" + &
//											  Mid(ls_sysdate,7,2)," 과금종료일")
//
//		Return -1	
//	End IF
//	
//ElseIf li_return = -1 Then
//	return li_return
//End IF
//2009.06.30---------------------------------------END

F_INIT_DSP(3, String(idc_receive), String(idc_change))

//2009.06.10 추가
IF ldc_impack <> 0 THEN
	Dec{2} 	ldc_90
	ldc_90   = dw_cond.Object.credit[1]
	ldc_card = dw_cond.Object.amt3[1]	
	dw_cond.Object.amt5[1] = idc_total - ldc_90
	dw_cond.Object.amt3[1] = ldc_card + (ldc_impack - (idc_total - ldc_90))
END IF

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


For i = 1 To dw_detail.Rowcount()
	ldc_adjamt 	= dw_detail.object.adjamt[i]
    ll_seq 		= dw_detail.object.seq[i]
    ls_reqnum 	= dw_detail.object.reqnum[i]
		
	//조정 금액 Update
	Update hotreqdtl 
	   set adjamt 	= :ldc_adjamt, 
		    remark 	= :is_termdt,
			 SEQ_APP = :is_seq_app
	 where payid 	= :is_payid 
	   and to_char(trdt, 'yyyymmdd') = :ls_trdt 
		and reqnum 		= :ls_reqnum 
		and seq 			= :ll_seq;
		
    If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Update Error(HOTREQDTL)")
		Return -1
	End If	

Next

//IF idc_change < 0 THEN
//If ls_paymethod <> "" Then   //지불을 하지 않으면 수동입금처리로 하도록 하기 위해 핫빌링에서는 처리 안한다.

//paymethod별 Insert
idc_amt[1] =  dw_cond.Object.amt1[1]
idc_amt[2] =  dw_cond.Object.amt2[1]
idc_amt[3] =  dw_cond.Object.amt3[1]
idc_amt[4] =  dw_cond.Object.amt4[1]
idc_amt[5] =  dw_cond.Object.amt5[1]

is_trcod[1] =  dw_cond.Object.trcod1[1]
is_trcod[2] =  dw_cond.Object.trcod2[1]
is_trcod[3] =  dw_cond.Object.trcod3[1]
is_trcod[4] =  dw_cond.Object.trcod4[1]
is_trcod[5] =  dw_cond.Object.trcod5[1]


FOR i =  1 to 5
IF idc_amt[i] <> 0 THEN
	Select Max(seq) + 1
	  Into :ll_max_seq
	  from hotreqdtl 
	 where payid 							= :is_payid 
	   and to_char(trdt, 'yyyymmdd') = :ls_trdt
	   and reqnum 							= :is_reqnum ;
	
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
		Return -1
	End If	
End IF
NEXT

//2009.06.30 부분 핫빌 때문에 추가함. CJH
//상태 Update
//Update customerm set hotbillflag = 'S' where customerid = :is_payid ;	

SELECT COUNT(*) INTO :ll_cnt
FROM   CONTRACTMST
WHERE  CUSTOMERID = :is_payid
AND    BILL_HOTBILLFLAG IS NOT NULL;

IF ll_cnt = 0 THEN			//전체 해지즉시불 처리!
	UPDATE CUSTOMERM
	SET    HOTBILLFLAG = "S"
	WHERE  CUSTOMERID = :is_payid;
ELSE
	UPDATE CUSTOMERM
	SET    HOTBILLFLAG = "H"
	WHERE  CUSTOMERID = :is_payid;
END IF

UPDATE CONTRACTMST
SET	 BILL_HOTBILLFLAG = "H"
WHERE  PAYID = :is_payid
AND    BILL_HOTBILLFLAG IS NOT NULL;
//2009.06.30------------------------------END

//
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


F_INIT_DSP(1,"","")

Return 0
end event

event resize;call super::resize;If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space

Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space	

End If
end event

event type integer ue_save();Constant Int LI_ERROR = -1
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

If ib_save = False Then
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) or (dw_detail.RowCount() > 0 ) Then
		li_rc = MessageBox(This.Title, "HotBill을 취소 하시겠습니까?",&
			Question!, YesNo!)
		If li_rc =1 Then
			
			ll_return = -1
			ls_errmsg = space(256)
			
			SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				Return 1
				
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				Return 1
			End If 
			
			Close(this)
		Else
			Return 1
		End If
	End If
Else
		Close(This)	
End If
end event

event close;call super::close;F_INIT_DSP(1,"","")
end event

type dw_cond from w_a_reg_s`dw_cond within ubs_w_reg_hotreqdtl_new
integer width = 2455
integer height = 536
string dataobject = "ubs_dw_reg_hotbill_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
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
LONG		ll_return

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
	case 'amt1', 'amt2', 'amt3', 'amt4', 'amt5'
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

type p_ok from w_a_reg_s`p_ok within ubs_w_reg_hotreqdtl_new
boolean visible = false
integer x = 2619
integer y = 252
end type

type p_close from w_a_reg_s`p_close within ubs_w_reg_hotreqdtl_new
integer x = 969
integer y = 1852
boolean originalsize = false
end type

type gb_cond from w_a_reg_s`gb_cond within ubs_w_reg_hotreqdtl_new
integer width = 2478
integer height = 588
end type

type dw_detail from w_a_reg_s`dw_detail within ubs_w_reg_hotreqdtl_new
integer x = 50
integer y = 608
integer width = 2455
integer height = 1196
string dataobject = "ubs_dw_reg_hotbill_det"
end type

event dw_detail::retrieveend;Int li_return
Long ll_preamt

If rowcount > 0 Then
	p_1.Enabled = False
	p_save.TriggerEvent("ue_enable")
	p_cancel.TriggerEvent("ue_enable")
    p_reset.TriggerEvent("ue_enable")	
	This.object.t_termdt.Text = MidA(is_termdt, 1,4) + "-" + MidA(is_termdt, 5,2) + "-" + MidA(is_termdt, 7,2)
Else
	p_1.Enabled = True
	p_save.TriggerEvent("ue_disable")
	p_cancel.TriggerEvent("ue_disable")
	li_return = wfi_preamt_chk(ll_preamt)
	IF li_return = 0 Then
		IF ll_preamt > 0 or ll_preamt < 0 Then
         	f_msg_info(9000, parent.Title, "당월 청구자료가 없습니다.~r~n현재미납액은 "+string(ll_preamt,'#,##0')+"입니다.~r~n수동입금처리로 확인하세요.")
		End IF	
	End IF	
End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;wf_set_total()

end event

type p_delete from w_a_reg_s`p_delete within ubs_w_reg_hotreqdtl_new
boolean visible = false
integer x = 416
integer y = 1848
end type

type p_insert from w_a_reg_s`p_insert within ubs_w_reg_hotreqdtl_new
boolean visible = false
integer x = 123
integer y = 1848
end type

type p_save from w_a_reg_s`p_save within ubs_w_reg_hotreqdtl_new
integer x = 50
integer y = 1852
end type

type p_reset from w_a_reg_s`p_reset within ubs_w_reg_hotreqdtl_new
integer x = 663
integer y = 1852
end type

type p_cancel from u_p_cancel within ubs_w_reg_hotreqdtl_new
integer x = 357
integer y = 1852
integer height = 92
boolean bringtotop = true
end type

type cb_hotbill from commandbutton within ubs_w_reg_hotreqdtl_new
boolean visible = false
integer x = 2578
integer y = 236
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
ld_reqdt_next 	= fd_next_month(ld_reqdt, Integer(MidA(ls_reqdt, 7, 2)))
ls_reqdt_add 	= String(ld_reqdt_next, 'yyyymmdd')

//해지일이 더 작으면
If ls_reqdt > is_termdt Then
	f_msg_usr_err(212, title+ "today:" +  MidA(ls_reqdt, 1,4)+ "-" + &
	 MidA(ls_reqdt, 5,2)+ "-" + MidA(ls_reqdt, 7,2), "Desired Termination Date")
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

type dw_split from datawindow within ubs_w_reg_hotreqdtl_new
boolean visible = false
integer x = 2542
integer y = 368
integer width = 306
integer height = 212
integer taborder = 22
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_hotbill_split"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type hpb_1 from hprogressbar within ubs_w_reg_hotreqdtl_new
integer x = 18
integer y = 628
integer width = 2779
integer height = 64
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 50
integer setstep = 10
end type

type cb_1 from commandbutton within ubs_w_reg_hotreqdtl_new
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

type p_1 from picture within ubs_w_reg_hotreqdtl_new
integer x = 2583
integer y = 88
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = true
string picturename = "HOTBILL_e.gif"
boolean focusrectangle = false
end type

event clicked;SetPointer(HourGlass!)

//Hotbill 프로시저를 실행시킨다.
Integer 	i,				li_error,		li_chk_cnt1, 	li_chk_cnt2
String 	ls_errmsg,	ls_pgm_id,		ls_chargedt, 	ls_hotbillingflag
String 	ls_reqdt, 	ls_where, 		ls_reqdt_add
Date 		ld_reqdt, 	ld_reqdt_next, ldt_trdt
integer 	li_day,		li_progress
Long 		ll_return, 	ll_row,			LL,		ll_cnt,	ll_deposit_cnt, ll_last_cont

String 	ls_user_id, 	ls_regcod,		ls_tmp, 	ls_ref_desc, ls_refund[]
String 	ls_itemcod, ls_itemnm, 	ls_trcod,	ls_trcodnm,		ls_process
DEC{2}  	ldc_tot,		ldc_refund, ldc_refundH,	ldc_tramt,	ldc_tramt2


ls_user_id = gs_user_id

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
ld_reqdt_next 	= fd_next_month(ld_reqdt, Integer(MidA(ls_reqdt, 7, 2)))
ls_reqdt_add 	= String(ld_reqdt_next, 'yyyymmdd')

//해지일이 더 작으면
If ls_reqdt > is_termdt Then
	f_msg_usr_err(212, title+ "today:" +  MidA(ls_reqdt, 1,4)+ "-" + &
	 MidA(ls_reqdt, 5,2)+ "-" + MidA(ls_reqdt, 7,2), "Desired Termination Date")
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
	gb_3.text = "Process : " +  'Refund...'
	
	//=========================================================7
	// Refund 금액 계산 -- &&& 선수금 처리
	//Refund itemcod;trcod [HR001;RE999]
	//=========================================================7
	IF WF_REFUND(ll_row, ld_reqdt_next) = -1 THEN
		return -1
	END IF
	ls_process = 'REFUND'
	ib_save 			= False
	li_progress 	+= 1
	wf_progress(li_progress)
	gb_3.text 		= "Process : " +  ls_process
	
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
SELECT COUNT(*) INTO :ll_last_cont
FROM   CUSTOMERM A, CONTRACTMST B
WHERE  A.PAYID = :is_payid
AND    A.CUSTOMERID = B.CUSTOMERID
AND    B.STATUS <> '99'
AND    B.BILL_HOTBILLFLAG IS NULL;

IF ll_last_cont = 0 THEN		//마지막 계약이면
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
			gb_3.Hide()
			hpb_1.Hide()
	
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
		END IF
	Loop
	CLOSE read_minap ;
	li_progress += 1
	wf_progress(li_progress)
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

type gb_3 from groupbox within ubs_w_reg_hotreqdtl_new
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

