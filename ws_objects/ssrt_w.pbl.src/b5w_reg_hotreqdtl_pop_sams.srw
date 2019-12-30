$PBExportHeader$b5w_reg_hotreqdtl_pop_sams.srw
$PBExportComments$Hot Bill 계산
forward
global type b5w_reg_hotreqdtl_pop_sams from w_a_reg_s
end type
type gb_3 from groupbox within b5w_reg_hotreqdtl_pop_sams
end type
type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_pop_sams
end type
type cb_hotbill from commandbutton within b5w_reg_hotreqdtl_pop_sams
end type
type dw_split from datawindow within b5w_reg_hotreqdtl_pop_sams
end type
type hpb_1 from hprogressbar within b5w_reg_hotreqdtl_pop_sams
end type
end forward

global type b5w_reg_hotreqdtl_pop_sams from w_a_reg_s
integer width = 2926
boolean resizable = false
windowtype windowtype = popup!
windowstate windowstate = normal!
event type integer ue_cancel ( )
gb_3 gb_3
p_cancel p_cancel
cb_hotbill cb_hotbill
dw_split dw_split
hpb_1 hpb_1
end type
global b5w_reg_hotreqdtl_pop_sams b5w_reg_hotreqdtl_pop_sams

type variables
String is_start[], is_hotflag, is_payid, is_termdt, is_method[], &
		is_trcod[], is_customerid, is_seq_app,			is_reqnum
DEC{2} idc_total, idc_receive, idc_change, idc_refund, idc_amt[], idc_preamt
Boolean ib_save
Integer il_cnt, ii_method_cnt

end variables

forward prototypes
public function integer wfi_preamt_chk (ref long al_preamt)
public subroutine wf_set_total ()
public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt)
public subroutine wf_progress (integer wfi_cnt)
public function integer wf_split (date wfdt_paydt)
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
 AND  ( a.status = '20' or a.status = '40' or a.status = '45' )
 AND  A.Status <> :ls_term_status
 AND  a.contractseq not in (select distinct ref_contractseq
                              from svcorder 
                             where customerid = a.customerid
                               and ( status = :ls_term_status or status = :ls_req_status )) ;
 
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

public subroutine wf_progress (integer wfi_cnt);INTEGER li_pcc

li_pcc =  Truncate(wfi_cnt/14 * 100 , 0)
IF li_pcc > 100 then li_pcc = 100
hpb_1.Position = li_pcc
Yield()
return
end subroutine

public function integer wf_split (date wfdt_paydt);Long		ll, 					ll_cnt,			ll_row, 		ll_seq
Integer 	li_pay_cnt, 		li_pp,			li_first,	li_paycnt, li_chk
DEC{2}  	ldc_saleamt,		ldc_rem,			ldc_tramt, 	ldc_intot,	ldc_outtot, &
			ldc_amt0[], 		ldc_payamt, &
			ldc_total, &
			ldc_receive, &
			ldc_change

String 	ls_method,			ls_basecod, 	ls_customerid, ls_payid, ls_trcod, ls_saletrcod, &
			ls_req_trdt, 		ls_dctype,		ls_ok,	&
			ls_method0[], 		ls_trcod0[], 	&
			ls_itemcod, 		ls_code, 				ls_codenm,		ls_memberid
date		ldt_trdt, 			ldt_shop_closedt, 	ldt_termdt, ldt_paydt
Integer  li_method_cnt, 	li_lp
Integer 	li_rtn
String 	ls_appseq, 			ls_seq, 					ls_prt, ls_regcod
Long		ll_shopcount


//--------------------------------------------------------------------
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
ldt_paydt 			= dw_cond.Object.paydt[1]
ldt_termdt 			= dw_cond.Object.termdt[1]
li_method_cnt 		= 0
ls_customerid 		= dw_cond.Object.payid[1]


select memberid INTO :ls_memberid from customerm where customerid = :ls_customerid ;

IF IsNull(ls_memberid) then ls_memberid = ''

ls_payid 			= dw_cond.Object.payid[1]

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

dw_detail.SetSort('ss A, cp_amt A')
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
		dw_split.Object.operator[ll_row] 	= gs_user_id
		dw_split.Object.customerid[ll_row] 	= ls_customerid
			
		select itemcod, regcod INTO :ls_itemcod, :ls_regcod FROM itemmst
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
			dw_split.Object.operator[ll_row] 	= gs_user_id
			dw_split.Object.customerid[ll_row] 	= ls_customerid
			
			ls_trcod =  dw_detail.Object.trcod[ll]
			select itemcod, regcod INTO :ls_itemcod, :ls_regcod FROM itemmst
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
	  :ls_memberid,	:GS_USER_ID,			:ldc_total,
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
				  :GS_SHOPID, 	:GS_USER_ID, 	:ls_payid,
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
//	FOR jj = 1  to 2
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
//	next 영수증 한장만 출력하도록 변경 2007-08-13 hcjung	
PRN_ClosePort()
RETURN 0
end function

on b5w_reg_hotreqdtl_pop_sams.create
int iCurrent
call super::create
this.gb_3=create gb_3
this.p_cancel=create p_cancel
this.cb_hotbill=create cb_hotbill
this.dw_split=create dw_split
this.hpb_1=create hpb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_3
this.Control[iCurrent+2]=this.p_cancel
this.Control[iCurrent+3]=this.cb_hotbill
this.Control[iCurrent+4]=this.dw_split
this.Control[iCurrent+5]=this.hpb_1
end on

on b5w_reg_hotreqdtl_pop_sams.destroy
call super::destroy
destroy(this.gb_3)
destroy(this.p_cancel)
destroy(this.cb_hotbill)
destroy(this.dw_split)
destroy(this.hpb_1)
end on

event open;call super::open;String ls_format, ls_ref_desc, ls_tmp, ls_useyn, &
			ls_trcod[]

//window 중앙에
f_center_window(this)

F_INIT_DSP(1,"","")
gb_3.Hide()
hpb_1.Hide()
//dw_msg_processing.Hide()


//Data 받아오기
is_payid     				= iu_cust_msg.is_data[2]
dw_cond.Object.payid[1] = is_payid

//
//ls_format = fs_get_control("B5", "H200", ls_ref_desc)
//If ls_format = "1" Then
//	dw_detail.object.tramt.Format = "#,##0.0"
//	dw_detail.object.adjamt.Format = "#,##0.0"
//	dw_detail.object.preamt.Format = "#,##0.0"	
//	dw_detail.object.balance.Format = "#,##0.0"	
//	dw_detail.object.totamt.Format = "#,##0.0"	
//	dw_detail.object.sum_amt.Format = "#,##0.0"	
//ElseIf ls_format = "2" Then
//	dw_detail.object.tramt.Format = "#,##0.00"
//	dw_detail.object.adjamt.Format = "#,##0.00"
//	dw_detail.object.preamt.Format = "#,##0.00"	
//	dw_detail.object.balance.Format = "#,##0.00"	
//	dw_detail.object.totamt.Format = "#,##0.00"	
//	dw_detail.object.sum_amt.Format = "#,##0.0"	
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

dw_cond.object.paydt[1] = f_find_shop_closedt(GS_SHOPID)
//PayMethod101, 102, 103, 104, 105
ls_tmp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_tmp 		= "" Then Return
fi_cut_string(ls_tmp, ";", is_method[])

//trcode
ls_tmp 			= fs_get_control("B5", "I102", ls_ref_desc)
If ls_tmp 		= "" Then Return
fi_cut_string(ls_tmp, ";", ls_trcod[])


dw_cond.object.method1[1] = is_method[1] 
dw_cond.object.method2[1] = is_method[2] 
dw_cond.object.method3[1] = is_method[3] 
dw_cond.object.method4[1] = is_method[4] 
dw_cond.object.method5[1] = is_method[5] 

dw_cond.object.trcod1[1] 	= ls_trcod[1]
dw_cond.object.trcod2[1] 	= ls_trcod[2]
dw_cond.object.trcod3[1] 	= ls_trcod[3]
dw_cond.object.trcod4[1] 	= ls_trcod[4]
dw_cond.object.trcod5[1] 	= ls_trcod[5]



ib_save = False
end event

event type integer ue_reset();Constant Int LI_ERROR = -1

Int li_rc

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


dw_cond.object.termdt[1] 	= date(fdt_get_dbserver_now())
dw_cond.object.paydt[1] 	= F_FIND_SHOP_CLOSEDT(GS_SHOPID)
p_cancel.TriggerEvent("ue_disable")
cb_hotbill.Enabled = True

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String 	ls_paymethod, 	ls_paydt, 	ls_sysdate,			ls_nextdate
String 	ls_trdt, 		ls_reqnum, 	ls_cus_bil_todt
Long 		i, 				ll_seq, 		ll_max_seq, 		ll_cnt, ll
Dec 		ldc_totamt, 	ldc_adjamt
int 		li_return, 		li_message,		li_method_cnt
date 		ldt_paydt, 		ldt_trdt, 	ldt_shop_closedt

dw_detail.AcceptText()
ls_sysdate 			= String(fdt_get_dbserver_now(), 'yyyymmdd')
ldt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)
ldc_totamt 			= dw_detail.object.totamt[1]
ls_paymethod 		= dw_cond.object.pay_method[1]

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

//해당납입고객으로 해지처리 안된 고객이 있는지 Check 한다.
li_return = wfi_contract_staus_chk(ll_cnt, ls_cus_bil_todt)

IF li_return = 0 Then
    IF ll_cnt > 0 Then
     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
		return -1
	End IF

    If ls_sysdate < ls_cus_bil_todt Then
		f_msg_usr_err(212,Title + "today:" +  MidA(ls_sysdate, 1,4) + "-" + &
											  MidA(ls_sysdate,5,2) + "-" + &
											  MidA(ls_sysdate,7,2)," 과금종료일")

		Return -1	
	End IF
	
ElseIf li_return = -1 Then
	return li_return
End IF

F_INIT_DSP(3, String(idc_receive), String(idc_change))

//-3006-8-19 add ------------------------------------------------------------------
//Impact Card로 결제 하는 경우 
//10%는 Impact 90%는 Credit card 로 분할 처리
Dec{2} 	ldc_10, ldc_90, ldc_100, ldc_card

ldc_100 =  dw_cond.Object.amt5[1]
If IsNull(ldc_100) then ldc_100 = 0

IF ldc_100 <> 0 then
	ldc_10 						= Round(ldc_100 * 0.1, 2)
	ldc_90 						= ldc_100 - ldc_10
	
	ldc_card = dw_cond.Object.amt3[1]
	If IsNull(ldc_card) then ldc_card = 0
	
	dw_cond.Object.amt5[1]	= ldc_10
	dw_cond.Object.amt3[1]	= ldc_card + ldc_90
END IF
dw_cond.Accepttext()


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


//상태 Update
Update customerm set hotbillflag = 'S' where customerid = :is_payid ;	

//daily payment 처리 부분 반영--- Sequence Change
IF wf_split(ldt_paydt) < 0 then
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

event resize;call super::resize;//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	dw_detail.Height = 0
//
//	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//
//Else
//	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
//
//	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space
//
//End If
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, i, li_rc

date		ldt_shop_closedt, ldt_paydt
String 	ls_payid

ldt_paydt 			= dw_cond.Object.paydt[1]
ls_payid 			= Trim(dw_cond.Object.payid[1])
ldt_shop_closedt 	= f_find_shop_closedt(gs_shopid)
if ldt_paydt <> ldt_shop_closedt then
		f_msg_usr_err(9000, Title, "Shop 마감일이 변경되었습니다. 확인 하세요. ")
		dw_cond.SetFocus()
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

event closequery;Int li_rc
Long ll_return
String ls_errmsg

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

type dw_cond from w_a_reg_s`dw_cond within b5w_reg_hotreqdtl_pop_sams
integer x = 46
integer width = 2409
integer height = 492
string dataobject = "b5dw_cnd_reg_hotbill_sams"
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
		
			Object.payid[row] = iu_cust_help.is_data2[1]		//고객번호

		End If		
End Choose



Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;DEC{2} ldc_tot, ldc_refund
choose case dwo.name
	case 'payid'
			This.object.payid_1[row] = data
	case 'refund'
			ldc_refund 	= this.Object.refund[1]
			ldc_tot 		= dw_detail.GetItemNumber(dw_detail.RowCount(), "totamt")
			dw_cond.Object.total[1] =  ldc_tot + ldc_refund
			wf_set_total()
	case 'atm1', 'atm2', 'atm3', 'atm4', 'atm5'
			wf_set_total()
			
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

type p_ok from w_a_reg_s`p_ok within b5w_reg_hotreqdtl_pop_sams
boolean visible = false
integer x = 2080
integer y = 256
end type

type p_close from w_a_reg_s`p_close within b5w_reg_hotreqdtl_pop_sams
integer x = 2501
integer y = 24
end type

type gb_cond from w_a_reg_s`gb_cond within b5w_reg_hotreqdtl_pop_sams
integer width = 2432
integer height = 552
end type

type dw_detail from w_a_reg_s`dw_detail within b5w_reg_hotreqdtl_pop_sams
integer y = 572
integer width = 2432
integer height = 1064
string dataobject = "b5dw_reg_hotbill_SAMS"
end type

event dw_detail::retrieveend;Int li_return
Long ll_preamt

If rowcount > 0 Then
	cb_hotbill.Enabled = False
	p_save.TriggerEvent("ue_enable")
	p_cancel.TriggerEvent("ue_enable")
    p_reset.TriggerEvent("ue_enable")	
	This.object.t_termdt.Text = MidA(is_termdt, 1,4) + "-" + MidA(is_termdt, 5,2) + "-" + MidA(is_termdt, 7,2)
Else
	cb_hotbill.Enabled = True
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

event dw_detail::itemchanged;call super::itemchanged;this.AcceptText()
wf_set_total()

end event

type p_delete from w_a_reg_s`p_delete within b5w_reg_hotreqdtl_pop_sams
boolean visible = false
end type

type p_insert from w_a_reg_s`p_insert within b5w_reg_hotreqdtl_pop_sams
boolean visible = false
integer x = 1993
integer y = 1632
end type

type p_save from w_a_reg_s`p_save within b5w_reg_hotreqdtl_pop_sams
integer x = 658
integer y = 1640
end type

type p_reset from w_a_reg_s`p_reset within b5w_reg_hotreqdtl_pop_sams
integer x = 1234
integer y = 1640
end type

type gb_3 from groupbox within b5w_reg_hotreqdtl_pop_sams
integer x = 9
integer y = 572
integer width = 2862
integer height = 228
integer taborder = 12
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 27306400
string text = "Progress"
borderstyle borderstyle = stylelowered!
end type

type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_pop_sams
integer x = 946
integer y = 1640
integer height = 92
boolean bringtotop = true
end type

type cb_hotbill from commandbutton within b5w_reg_hotreqdtl_pop_sams
integer x = 2501
integer y = 220
integer width = 297
integer height = 92
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&HotBill"
end type

event clicked;SetPointer(HourGlass!)

//Hotbill 프로시저를 실행시킨다.
Integer 	i,				li_error
String 	ls_errmsg,	ls_pgm_id,		ls_chargedt, 	ls_hotbillingflag
String 	ls_reqdt, 	ls_where, 		ls_reqdt_add
Date 		ld_reqdt, 	ld_reqdt_next, ldt_trdt
integer 	li_day,		li_progress
Long 		ll_return, 	ll_row,			LL,		ll_cnt

String 	ls_user_id, 	ls_regcod,		ls_tmp, 	ls_ref_desc, ls_refund[]
String 	ls_itemcod, ls_itemnm, 	ls_trcod,	ls_trcodnm,		ls_process
DEC{2}  	ldc_tot,		ldc_refund, ldc_refundH,	ldc_tramt


ls_user_id = gs_user_id

//  =========================================================================================
//  2008-03-18 hcjung   
//  핫빌 버튼 누르자마자 disable 시키기
//  =========================================================================================
cb_hotbill.Enabled = False

dw_cond.AcceptText( )
ll_return 		= -1
ls_errmsg 		= space(256)

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
If ls_hotbillingflag <> "" THEN
	f_msg_info(100, title, "이미 해지즉시불처리된 납입자 입니다.")
	Return -1
End If

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
	If ll_row = 0 Then
		f_msg_info(1000, title, "")
		ib_save = False
		gb_3.Hide()
		hpb_1.Hide()
		
		return 0
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, title, "Retrieve()")
		gb_3.Hide()
		hpb_1.Hide()

		Return -1
	End If
	//=========================================================7
	// Refund 금액 계산 --
	//Refund itemcod;trcod [HR001;RE999]
	//=========================================================7
	ls_tmp 			= fs_get_control("Y1", "Z100", ls_ref_desc)
	fi_cut_string(ls_tmp, ";", ls_refund[])

	 SELECT trcodnm	INTO :ls_trcodnm 	FROM trcode
	  WHERE trcod 	=  :ls_refund[2] ;
	 IF IsNull(ls_trcodnm) then ls_trcodnm = ''
 
	 SELECT regcod	INTO :ls_regcod FROM itemmst
	  WHERE itemcod 	=  :ls_refund[1] ;
	 IF IsNull(ls_regcod) then ls_regcod = ''

	SELECT SUM(PAYAMT)   INTO :ldc_refund FROM DailyPayment
	 WHERE ( PayID 	= :is_payid ) 
	   AND ( REGCOD = '008' OR RegCod = '010' ) ;
	SELECT SUM(PAYAMT)   INTO :ldc_refundH FROM DailyPaymentH
	 WHERE ( PayID 	= :is_payid ) 
	   AND ( REGCOD = '008' OR RegCod = '010' ) ;

	IF IsNull(ldc_refund) then ldc_refund = 0
	IF IsNull(ldc_refundH) then ldc_refundH = 0
	ldc_refund =  ldc_refund + ldc_refundH
	
	ldc_refund =  ldc_refund * -1	
//	IF ldc_refund <> 0 then
	Long	ll_max_seq
	String ls_trdt, ls_reqnum, ls_paydt
	date	ldt_paydt
		
	is_reqnum =  dw_detail.Object.reqnum[ll_row]
	ls_paydt = String(dw_cond.object.paydt[1], 'yyyymmdd')
	ls_trdt 	= String(dw_detail.object.trdt[1], 'yyyymmdd')

	ldt_paydt = dw_cond.object.paydt[1]
	ldt_trdt = date(dw_detail.object.trdt[1])

	If IsNull(ls_paydt) Then ls_paydt = ""		

	Select Max(seq) + 1	  Into :ll_max_seq	  from hotreqdtl 
	 where payid 							= :is_payid 
	   and to_char(trdt, 'yyyymmdd') = :ls_trdt
	   and reqnum 							= :is_reqnum ;
	
	Insert Into Hotreqdtl (
					reqnum, 		seq, 				payid, 		trdt, 			
					paydt,											transdt,		
					trcod, 											tramt, 					adjamt, remark,
					crtdt, 		crt_user, 		updtdt, 		updt_user, 				pgm_id)
	   Values(	:is_reqnum, :ll_max_seq, 	:is_payid, 	to_date(:ls_trdt, 'yyyymmdd'), 
					to_date(:ls_paydt, 'yyyymmdd'),			to_date(:ls_paydt, 'yyyymmdd'), 
					:ls_refund[2], 								:ldc_refund,			0, :is_termdt,
			  		sysdate, 	:gs_user_id,	 sysdate, 	:gs_user_id, 			:gs_pgm_id[gi_open_win_no]);
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
		gb_3.Hide()
		hpb_1.Hide()
		Return -1
	else
		commit ;
	End If	
	ib_save 		= False
	li_progress += 1
	wf_progress(li_progress)
	gb_3.text = "Process : " +  ls_process
End If
ll_row 	= dw_detail.Retrieve(is_payid)
FOR ll =  1 to ll_row
	ls_trcod =  dw_detail.Object.trcod[ll]
	IF ls_trcod = ls_refund[2] then
		dw_detail.Object.ss[ll] 		= -1
		dw_detail.Object.dctype[ll] 	= 'C'
	else
		dw_detail.Object.ss[ll] 		= ll
		dw_detail.Object.dctype[ll] 	= 'D'
	end if
	dw_detail.Object.chk[ll_row] 		=  '0'
NEXT
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


ll_cnt = dw_detail.Rowcount()
//====================================================
FOR ll = 1 to ll_cnt
	ls_trcod 	= trim(dw_detail.Object.trcod[ll])
		
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
	 
NEXT

//---------------------------------------------------------------------
IF ll_cnt > 0 THEN
	ldc_tot 	=  dw_detail.GetItemNumber(ll_cnt, "cp_total")
	dw_cond.Object.total[1] =  ldc_tot
	wf_set_total()
END IF
SetPointer(Arrow!)
gb_3.Hide()
hpb_1.Hide()

Return 0
end event

type dw_split from datawindow within b5w_reg_hotreqdtl_pop_sams
boolean visible = false
integer x = 2542
integer y = 416
integer width = 306
integer height = 212
integer taborder = 12
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type hpb_1 from hprogressbar within b5w_reg_hotreqdtl_pop_sams
integer x = 50
integer y = 684
integer width = 2779
integer height = 64
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 50
integer setstep = 10
end type

