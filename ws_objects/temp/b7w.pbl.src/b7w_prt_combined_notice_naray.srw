$PBExportHeader$b7w_prt_combined_notice_naray.srw
$PBExportComments$[ohj]통합지로청구서_naray
forward
global type b7w_prt_combined_notice_naray from w_a_print
end type
type cb_shift_r from commandbutton within b7w_prt_combined_notice_naray
end type
type cb_shift_l from commandbutton within b7w_prt_combined_notice_naray
end type
type dw_select2 from u_d_external within b7w_prt_combined_notice_naray
end type
type dw_select1 from u_d_sgl_sel within b7w_prt_combined_notice_naray
end type
type cb_shift_r_all from commandbutton within b7w_prt_combined_notice_naray
end type
type cb_shift_l_all from commandbutton within b7w_prt_combined_notice_naray
end type
end forward

global type b7w_prt_combined_notice_naray from w_a_print
integer width = 3493
integer height = 2192
cb_shift_r cb_shift_r
cb_shift_l cb_shift_l
dw_select2 dw_select2
dw_select1 dw_select1
cb_shift_r_all cb_shift_r_all
cb_shift_l_all cb_shift_l_all
end type
global b7w_prt_combined_notice_naray b7w_prt_combined_notice_naray

type variables
//SUBMST.subkind->SUBID/ANI#
String	is_chargedt, is_reqdt, is_subkind, is_pay_method_2, is_surtax
Date id_reqdt, id_inputclosedt
String is_manager_tel, is_editdt, is_ctype_10, is_ctype_20, is_method[]


end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
protected function integer wf_receipt_naray_old (string as_bil_type, string as_payid, string as_trdt, string as_pay_method, string as_chargedt, string as_ctype_20, string as_pay_method_2)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm

Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("payid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0

end function

protected function integer wf_receipt_naray_old (string as_bil_type, string as_payid, string as_trdt, string as_pay_method, string as_chargedt, string as_ctype_20, string as_pay_method_2);Integer li_rc, i = 1 //return -1 error 0 no data 1 ok
Long    ll_tramt, ll_tramtb[], ll_retramtb[], j, p, ll_trmattotal = 0, &
        ll_supplyamt, ll_surtax
String  ls_bil_code, ls_bil_nm, ls_bil_codeb[], ls_bil_nmb[], ls_code, &
        ls_payid, ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_cregno, &
        ls_ctype2, ls_customernm, ls_codeb[], ls_bilcycle, ls_pay_method, &
		  ls_bank, ls_owner, ls_account
		 

li_rc = -1  
//select 고객별 청구유형의 청구항목 select
DECLARE invoice_item_seq_cu CURSOR FOR
	select c.code
		  , c.codenm
	  from billinginfo      a
		  , invoice_item_seq b
		  , syscod2t         c
	 where a.inv_type   = b.inv_type
		and b.bilcod     = c.code
		and c.grcode     = 'B530'
		and a.customerid = :as_payid
 order by c.code		;

	OPEN invoice_item_seq_cu;
			
	DO WHILE (True)
		
		Fetch invoice_item_seq_cu
		Into :ls_bil_code, :ls_bil_nm;
			
		If SQLCA.SQLCode < 0 Then
			Return li_rc
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If	
		
		ls_bil_codeb[i] = ls_bil_code
		ls_bil_nmb[i]   = ls_bil_nm
		i ++
	Loop
Close invoice_item_seq_cu;	

If as_bil_type = '5' Then	
  // billinginfo 랑 join해야 할것이 아니고 reqinfo랑 해야하지만...
  //나래 구데이타가 reqinfo에 없기 때문에..reqinfoh도 없고.. 해서 
  //고객을 조회 할라니 billinginfo로 해야했음
	SELECT PAYID
	     , BIL_ZIPCOD
	     , BIL_ADDR1
	     , BIL_ADDR2
	     , CREGNO
	     , CTYPE2
	     , CUSTOMERNM
	  INTO :ls_payid
	     , :ls_bil_zipcod
		  , :ls_bil_addr1
		  , :ls_bil_addr2
		  , :ls_cregno
		  , :ls_ctype2
		  , :ls_customernm	    
	  FROM (
        	  SELECT DISTINCT 
                  A.PAYID
					 , TRANSLATE(B.BIL_ZIPCOD, 'T-', 'T')  BIL_ZIPCOD
					 , B.BIL_ADDR1
					 , B.BIL_ADDR2
					 , DECODE(F.CTYPE2, :as_ctype_20, F.CREGNO, '**********')   CREGNO 
					 , F.CTYPE2
					 , F.CUSTOMERNM
				 FROM REQDTL           A
					 , BILLINGINFO      B
					 , TRCODE           C
					 , INVOICE_ITEM_DET D
					 , SYSCOD2T         E
					 , CUSTOMERM        F
			   WHERE A.PAYID      = B.CUSTOMERID
			     AND A.TRCOD      = C.TRCOD
			     AND B.INV_TYPE   = D.INV_TYPE
			     AND A.TRCOD      = D.TRCOD  
			     AND D.BILCOD     = E.CODE 
			     AND A.PAYID      = F.PAYID
			     AND E.GRCODE     = 'B530'
			     AND A.PAYID      = :as_payid
			     AND TO_CHAR(A.TRDT,'YYYYMMDD' )= :as_trdt
     			  AND B.PAY_METHOD = :as_pay_method
     			  AND B.BILCYCLE   = :as_chargedt   
        UNION ALL
       	  SELECT DISTINCT 
                  A.PAYID
					 , TRANSLATE(B.BIL_ZIPCOD, 'T-', 'T')  BIL_ZIPCOD
					 , B.BIL_ADDR1
					 , B.BIL_ADDR2
					 , DECODE(F.CTYPE2, :as_ctype_20, F.CREGNO, '**********')   CREGNO 
					 , F.CTYPE2
					 , F.CUSTOMERNM
				 FROM REQDTLH          A
					 , BILLINGINFO      B
					 , TRCODE           C
					 , INVOICE_ITEM_DET D
					 , SYSCOD2T         E
					 , CUSTOMERM        F
			   WHERE A.PAYID      = B.CUSTOMERID
			     AND A.TRCOD      = C.TRCOD
			     AND B.INV_TYPE   = D.INV_TYPE
			     AND A.TRCOD      = D.TRCOD  
			     AND D.BILCOD     = E.CODE 
			     AND A.PAYID      = F.PAYID
			     AND E.GRCODE     = 'B530'
			     AND A.PAYID      = :as_payid
			     AND TO_CHAR(A.TRDT,'YYYYMMDD' )= :as_trdt
     		 	  AND B.PAY_METHOD = :as_pay_method
     		 	  AND B.BILCYCLE   = :as_chargedt    );
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select REQDTL Table")		
		Return li_rc
	ElseIf SQLCA.SQLCode = 100 Then
		f_msg_info(9000, is_title, "Select REQDTL Table")
		li_rc = 0
		Return li_rc
	End If  
	i = 1
	DECLARE v_bill_tramt_cu CURSOR FOR
		select bilcod
		     , tramt
		  from v_bil_tramt
		 where payid      = :as_payid
		   and to_char(trdt,'YYYYMMDD') = :as_trdt
		   and pay_method = :as_pay_method
		   and bilcycle   = :as_chargedt
	 order by bilcod		              ;
	
		OPEN v_bill_tramt_cu;				
		DO WHILE (True)
			
			Fetch v_bill_tramt_cu
			Into :ls_code, :ll_tramt;
				
			If SQLCA.SQLCode < 0 Then
				Return li_rc
				Exit
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If	
			
			ls_codeb[i]  = ls_code
			ll_tramtb[i] = ll_tramt
			
			//cur_balance 구하기/공급가액구하기
			If ls_code <> 'SUPPLY' Then
				ll_trmattotal = ll_trmattotal + ll_tramt
			else
				ll_supplyamt = ll_tramt
			End If
			
			//부가세 구하기
			If ls_codeb[i] = is_surtax Then
				ll_surtax = ll_tramt
			End If
			i ++
		Loop
	Close v_bill_tramt_cu;		
		
	For j = 1 To UpperBound(ls_bil_codeb)
		For p = 1 To UpperBound(ls_codeb)
			If ls_bil_codeb[j] = ls_codeb[p] Then
				ll_retramtb[j] = ll_tramtb[p]
				exit
			else
				ll_retramtb[j] = 0
			end If
		Next
	Next		
	// 그외 나머지
	dw_list.Object.customernm[1] = ls_customernm	
	dw_list.Object.bil_addr1[1]  = ls_bil_addr1
	dw_list.Object.bil_addr2[1]  = ls_bil_addr2	
	dw_list.Object.bil_zipcod[1]  = ls_bil_zipcod	
	dw_list.Object.cur_balance[1]  = ll_trmattotal
	dw_list.Object.pre_balance[1]  = 0
	dw_list.Object.cregno[1]       = ls_cregno	
	dw_list.Object.ctype2[1]       = ls_ctype2	
	dw_list.Object.payamt[1]       = 0
	dw_list.Object.payid[1]        = ls_payid
   dw_list.Object.supplyamt[1]    = ll_supplyamt
	dw_list.Object.surtax[1]       = ll_surtax	

ElseIf as_bil_type = '6' Then	
        SELECT PAYID
              , bilcycle
              , BIL_ZIPCOD
              , BIL_ADDR1
              , BIL_ADDR2
              , CREGNO
              , CTYPE2
              , CUSTOMERNM
              , PAY_METHOD
              , bank
              , owner
              , account
           INTO :ls_payid
			     , :ls_bilcycle
              , :ls_bil_zipcod
              , :ls_bil_addr1
              , :ls_bil_addr2
              , :ls_cregno
              , :ls_ctype2
              , :ls_customernm
				  , :ls_pay_method
				  , :ls_bank
				  , :ls_owner
				  , :ls_account
           FROM (
                    SELECT DISTINCT
                           A.PAYID
                         , B.bilcycle
                         , TRANSLATE(B.BIL_ZIPCOD, 'T-', 'T')  BIL_ZIPCOD
                         , B.BIL_ADDR1
                         , B.BIL_ADDR2
                         , DECODE(F.CTYPE2, :as_ctype_20, F.CREGNO, '**********')   CREGNO
                         , F.CTYPE2
                         , F.CUSTOMERNM
                         , B.PAY_METHOD
                         , DECODE(B.PAY_METHOD, :as_pay_method_2, B.BANK      , B.CARD_TYPE      ) bank
                         , DECODE(B.PAY_METHOD, :as_pay_method_2, B.ACCT_OWNER, B.CARD_HOLDER    ) owner
                         , DECODE(B.PAY_METHOD, :as_pay_method_2, TRANSLATE(B.ACCTNO , 'T-', 'T')
                                                                , TRANSLATE(B.CARD_NO, 'T-', 'T')) account
                      FROM REQDTL           A
                         , BILLINGINFO      B
                         , TRCODE           C
                         , INVOICE_ITEM_DET D
                         , SYSCOD2T         E
                         , CUSTOMERM        F
                   WHERE A.PAYID      = B.CUSTOMERID
                     AND A.TRCOD      = C.TRCOD
                     AND B.INV_TYPE   = D.INV_TYPE
                     AND A.TRCOD      = D.TRCOD
                     AND D.BILCOD     = E.CODE
                     AND A.PAYID      = F.PAYID
                     AND E.GRCODE     = 'B530'
                     AND A.PAYID      = :as_payid
                     AND TO_CHAR(A.TRDT,'YYYYMMDD' )= :as_trdt
                     AND B.PAY_METHOD = :as_pay_method
                     AND B.BILCYCLE   = :as_chargedt
               UNION ALL
                  SELECT DISTINCT
                         A.PAYID
                       , B.bilcycle
                       , TRANSLATE(B.BIL_ZIPCOD, 'T-', 'T')  BIL_ZIPCOD
                       , B.BIL_ADDR1
                       , B.BIL_ADDR2
                       , DECODE(F.CTYPE2, :as_ctype_20, F.CREGNO, '**********')   CREGNO
                       , F.CTYPE2
                       , F.CUSTOMERNM
                       , B.PAY_METHOD
                       , DECODE(B.PAY_METHOD, :as_pay_method_2, B.BANK      , B.CARD_TYPE      ) bank
                       , DECODE(B.PAY_METHOD, :as_pay_method_2, B.ACCT_OWNER, B.CARD_HOLDER    ) owner
                       , DECODE(B.PAY_METHOD, :as_pay_method_2, TRANSLATE(B.ACCTNO , 'T-', 'T')
                                                              , TRANSLATE(B.CARD_NO, 'T-', 'T')) account
                    FROM REQDTLH          A
                       , BILLINGINFO      B
                       , TRCODE           C
                       , INVOICE_ITEM_DET D
                       , SYSCOD2T         E
                       , CUSTOMERM        F
                   WHERE A.PAYID      = B.CUSTOMERID
                     AND A.TRCOD      = C.TRCOD
                     AND B.INV_TYPE   = D.INV_TYPE
                     AND A.TRCOD      = D.TRCOD
                     AND D.BILCOD     = E.CODE
                     AND A.PAYID      = F.PAYID
                     AND E.GRCODE     = 'B530'
                     AND A.PAYID      = :as_payid
                     AND TO_CHAR(A.TRDT,'YYYYMMDD' )= :as_trdt
                     AND B.PAY_METHOD = :as_pay_method
                     AND B.BILCYCLE   = :as_chargedt                      );
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select REQDTL Table")		
		Return li_rc
	ElseIf SQLCA.SQLCode = 100 Then
		f_msg_info(9000, is_title, "Select REQDTL Table")
		li_rc = 0
		Return li_rc
	End If 
	
	i = 1
	DECLARE v_bill_tramt_cu1 CURSOR FOR
		select bilcod
		     , tramt
		  from v_bil_tramt
		 where payid      = :as_payid
		   and to_char(trdt,'YYYYMMDD') = :as_trdt
		   and pay_method = :as_pay_method
		   and bilcycle   = :as_chargedt
	 order by bilcod		              ;
	
		OPEN v_bill_tramt_cu1;				
		DO WHILE (True)
			
			Fetch v_bill_tramt_cu1
			Into :ls_code, :ll_tramt;
				
			If SQLCA.SQLCode < 0 Then
				Return li_rc
				Exit
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If	
			
			ls_codeb[i]  = ls_code
			ll_tramtb[i] = ll_tramt
			
			//cur_balance 구하기/공급가액구하기
			If ls_code <> 'SUPPLY' Then
				ll_trmattotal = ll_trmattotal + ll_tramt
			else
				ll_supplyamt = ll_tramt
			End If
			
			//부가세 구하기
			If ls_codeb[i] = is_surtax Then
				ll_surtax = ll_tramt
			End If
			i ++
		Loop
	Close v_bill_tramt_cu1;		
		
	For j = 1 To UpperBound(ls_bil_codeb)
		For p = 1 To UpperBound(ls_codeb)
			If ls_bil_codeb[j] = ls_codeb[p] Then
				ll_retramtb[j] = ll_tramtb[p]
				exit
			else
				ll_retramtb[j] = 0
			end If
		Next
	Next		
	// 그외 나머지
	dw_list.Object.customernm[1]  = ls_customernm	
	dw_list.Object.bil_addr1[1]   = ls_bil_addr1
	dw_list.Object.bil_addr2[1]   = ls_bil_addr2	
	dw_list.Object.bil_zipcod[1]  = ls_bil_zipcod	
	dw_list.Object.cur_balance[1] = ll_trmattotal
	dw_list.Object.pre_balance[1] = 0
	dw_list.Object.cregno[1]      = ls_cregno	
	dw_list.Object.ctype2[1]      = ls_ctype2	
	dw_list.Object.payamt[1]      = 0
	dw_list.Object.payid[1]       = ls_payid
   dw_list.Object.supplyamt[1]   = ll_supplyamt
	dw_list.Object.surtax[1]      = ll_surtax	
	dw_list.Object.account[1]     = ls_account	
	dw_list.Object.bank[1]        = ls_bank	
	dw_list.Object.owner[1]       = ls_owner	
	dw_list.Object.chargedt[1]    = ls_bilcycle		
	dw_list.Object.pay_method[1]  = ls_pay_method	
Else
	li_rc = -1  
End If

//항목 setting
Choose Case UpperBound(ls_bil_codeb)
	Case 7
		dw_list.Object.btrdesc01[1] = ls_bil_nmb[1]
		dw_list.Object.btramt01[1]  = ll_retramtb[1]
		dw_list.Object.btrdesc02[1] = ls_bil_nmb[2]
		dw_list.Object.btramt02[1]  = ll_retramtb[2]		
		dw_list.Object.btrdesc03[1] = ls_bil_nmb[3]
		dw_list.Object.btramt03[1]  = ll_retramtb[3]	
		dw_list.Object.btrdesc04[1] = ls_bil_nmb[4]
		dw_list.Object.btramt04[1]  = ll_retramtb[4]	
		dw_list.Object.btrdesc05[1] = ls_bil_nmb[5]
		dw_list.Object.btramt05[1]  = ll_retramtb[5]
		dw_list.Object.btrdesc06[1] = ls_bil_nmb[6]
		dw_list.Object.btramt06[1]  = ll_retramtb[6]
		dw_list.Object.btrdesc07[1] = ls_bil_nmb[7]
		dw_list.Object.btramt07[1]  = ll_retramtb[7]
		
	Case 8
		dw_list.Object.btrdesc01[1] = ls_bil_nmb[1]
		dw_list.Object.btramt01[1]  = ll_retramtb[1]
		dw_list.Object.btrdesc02[1] = ls_bil_nmb[2]
		dw_list.Object.btramt02[1]  = ll_retramtb[2]		
		dw_list.Object.btrdesc03[1] = ls_bil_nmb[3]
		dw_list.Object.btramt03[1]  = ll_retramtb[3]	
		dw_list.Object.btrdesc04[1] = ls_bil_nmb[4]
		dw_list.Object.btramt04[1]  = ll_retramtb[4]	
		dw_list.Object.btrdesc05[1] = ls_bil_nmb[5]
		dw_list.Object.btramt05[1]  = ll_retramtb[5]
		dw_list.Object.btrdesc06[1] = ls_bil_nmb[6]
		dw_list.Object.btramt06[1]  = ll_retramtb[6]
		dw_list.Object.btrdesc07[1] = ls_bil_nmb[7]
		dw_list.Object.btramt07[1]  = ll_retramtb[7]
		dw_list.Object.btrdesc08[1] = ls_bil_nmb[8]
		dw_list.Object.btramt08[1]  = ll_retramtb[8]			
	Case 9
		dw_list.Object.btrdesc01[1] = ls_bil_nmb[1]
		dw_list.Object.btramt01[1]  = ll_retramtb[1]
		dw_list.Object.btrdesc02[1] = ls_bil_nmb[2]
		dw_list.Object.btramt02[1]  = ll_retramtb[2]		
		dw_list.Object.btrdesc03[1] = ls_bil_nmb[3]
		dw_list.Object.btramt03[1]  = ll_retramtb[3]	
		dw_list.Object.btrdesc04[1] = ls_bil_nmb[4]
		dw_list.Object.btramt04[1]  = ll_retramtb[4]	
		dw_list.Object.btrdesc05[1] = ls_bil_nmb[5]
		dw_list.Object.btramt05[1]  = ll_retramtb[5]
		dw_list.Object.btrdesc06[1] = ls_bil_nmb[6]
		dw_list.Object.btramt06[1]  = ll_retramtb[6]
		dw_list.Object.btrdesc07[1] = ls_bil_nmb[7]
		dw_list.Object.btramt07[1]  = ll_retramtb[7]
		dw_list.Object.btrdesc08[1] = ls_bil_nmb[8]
		dw_list.Object.btramt08[1]  = ll_retramtb[8]
		dw_list.Object.btrdesc09[1] = ls_bil_nmb[9]
		dw_list.Object.btramt09[1]  = ll_retramtb[9]
	Case 10
		dw_list.Object.btrdesc01[1] = ls_bil_nmb[1]
		dw_list.Object.btramt01[1]  = ll_retramtb[1]
		dw_list.Object.btrdesc02[1] = ls_bil_nmb[2]
		dw_list.Object.btramt02[1]  = ll_retramtb[2]		
		dw_list.Object.btrdesc03[1] = ls_bil_nmb[3]
		dw_list.Object.btramt03[1]  = ll_retramtb[3]	
		dw_list.Object.btrdesc04[1] = ls_bil_nmb[4]
		dw_list.Object.btramt04[1]  = ll_retramtb[4]	
		dw_list.Object.btrdesc05[1] = ls_bil_nmb[5]
		dw_list.Object.btramt05[1]  = ll_retramtb[5]
		dw_list.Object.btrdesc06[1] = ls_bil_nmb[6]
		dw_list.Object.btramt06[1]  = ll_retramtb[6]
		dw_list.Object.btrdesc07[1] = ls_bil_nmb[7]
		dw_list.Object.btramt07[1]  = ll_retramtb[7]
		dw_list.Object.btrdesc08[1] = ls_bil_nmb[8]
		dw_list.Object.btramt08[1]  = ll_retramtb[8]
		dw_list.Object.btrdesc09[1] = ls_bil_nmb[9]
		dw_list.Object.btramt09[1]  = ll_retramtb[9]
		dw_list.Object.btrdesc10[1] = ls_bil_nmb[10]
		dw_list.Object.btramt10[1]  = ll_retramtb[10]
	Case else
		f_msg_info(9000, is_title, "목록이 정의 되어 있지 않습니다.!")
		return li_rc
End Choose

li_rc = 1
return li_rc
end function

on b7w_prt_combined_notice_naray.create
int iCurrent
call super::create
this.cb_shift_r=create cb_shift_r
this.cb_shift_l=create cb_shift_l
this.dw_select2=create dw_select2
this.dw_select1=create dw_select1
this.cb_shift_r_all=create cb_shift_r_all
this.cb_shift_l_all=create cb_shift_l_all
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_shift_r
this.Control[iCurrent+2]=this.cb_shift_l
this.Control[iCurrent+3]=this.dw_select2
this.Control[iCurrent+4]=this.dw_select1
this.Control[iCurrent+5]=this.cb_shift_r_all
this.Control[iCurrent+6]=this.cb_shift_l_all
end on

on b7w_prt_combined_notice_naray.destroy
call super::destroy
destroy(this.cb_shift_r)
destroy(this.cb_shift_l)
destroy(this.dw_select2)
destroy(this.dw_select1)
destroy(this.cb_shift_r_all)
destroy(this.cb_shift_l_all)
end on

event ue_ok();call super::ue_ok;Integer li_rc, li_return
Long   ll_rows, ll_lower_amt, ll_payidRows, ll_curRow
String ls_where, ls_where_payid, ls_bill_type
String ls_chargedt, ls_trdt, ls_paydt, ls_usedt_fr, ls_usedt_to, ls_editdt
String ls_payid, ls_selectPayid[], ls_busyn, ls_lastbal, ls_dly_mfr, ls_dly_mto
String ls_ref_desc, ls_ref_content, ls_result[], ls_kind, ls_customernm
String ls_pay_method, ls_recyn

dw_cond.AcceptText()

ls_chargedt   = Trim(dw_cond.Object.chargedt[1])
ls_trdt       = String(dw_cond.Object.trdt[1], "yyyymmdd")
ls_pay_method = Trim(dw_cond.Object.pay_method[1])
ls_usedt_fr   = String(dw_cond.Object.usedt_fr[1], "yyyymmdd")
ls_usedt_to   = String(dw_cond.Object.usedt_to[1], "yyyymmdd")
ls_paydt      = String(dw_cond.Object.paydt[1], "yyyymmdd")
ls_editdt     = String(dw_cond.Object.editdt[1], "yyyymmdd")
ls_payid      = Trim(dw_cond.Object.payid[1])
ls_busyn      = Trim(dw_cond.Object.bus_yn[1])  //공급받는자표시  
ls_customernm = Trim(dw_cond.Object.customernm[1])
ls_bill_type  = Trim(dw_cond.Object.bill_type[1])
ls_kind       = Trim(dw_cond.Object.kind[1])

//ls_lastbal = String(dw_cond.Object.lastbal[1])
//ls_dly_mfr = String(dw_cond.Object.dly_mfr[1])
//ls_dly_mto = String(dw_cond.Object.dly_mto[1])

If IsNull(ls_chargedt)   Then ls_chargedt = ""
If IsNull(ls_payid)      Then ls_payid = ""
If IsNull(ls_busyn)      Then ls_busyn = "N"
If IsNull(ls_customernm) Then ls_customernm = ""
If IsNull(ls_kind)       Then ls_kind = "1"

//If IsNull(ls_lastbal) Then ls_lastbal = ""
//If IsNull(ls_dly_mfr) Then ls_dly_mfr = ""
//If IsNull(ls_dly_mto) Then ls_dly_mto = ""

//
//dw_select2.AcceptText()
//ll_payidRows = dw_select2.RowCount()
//For ll_curRow = 1 To ll_payidRows
//	ls_selectPayid[ll_curRow] = Trim(dw_select2.Object.payid[ll_curRow])
//	If IsNull(ls_selectPayid[ll_curRow]) Then ls_selectPayid[ll_curRow] = ""
//Next

////청구최저금액
//ls_ref_content = fs_get_control("B7", "11", ls_ref_desc)
//If IsNull(ls_ref_content) Then Return
//li_return = fi_cut_string(ls_ref_content, ";", ls_result[])
//If li_return < 3 Then Return
//ll_lower_amt = Long(Trim(ls_result[3]))

If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "청구주기")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End If

If ls_pay_method = "" Then
	f_msg_usr_err(200, Title, "납입방법")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pay_method")
	Return
End If

If ls_paydt = "" Then
	f_msg_usr_err(200, Title, "이체일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("paydt")
	Return
End If

If ls_editdt = "" Then
	f_msg_usr_err(200, Title, "작성일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("editdt")
	Return
End If

If ls_trdt = "" Or ls_usedt_fr = "" Or ls_usedt_to = "" Then
	f_msg_usr_err(200, Title, "청구주기컨트롤의 내용을 확인후 실행하십시오!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("chargedt")
	Return
End If

If ls_customernm = "" Then
	f_msg_usr_err(200, Title, "고객명")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customernm")
	Return
End If

If ls_bill_type = '1' Then  //통합지로 - 청구/영수구분 없음 ls_recyn = "" 
	If ls_pay_method = is_method[1] Then
		dw_list.DataObject = "b7dw_prt_giromonth_notice_naray"
	Else
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If
	ls_recyn = "" 
	
ElseIf ls_bill_type = '2' Then	//월별지로
	If ls_pay_method = is_method[1] Then
		If ls_kind = "1" Then //청구용
			dw_list.DataObject = "b7d_prt_giro_month_bill_naray"
			ls_recyn = ""
		Else
			dw_list.DataObject = "b7d_prt_giro_month_receipt_naray"
			ls_recyn = "REC"
		End If
	Else		
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If
	
ElseIf ls_bill_type = '3' Then //통합자동이체
	If ls_pay_method = is_method[2] OR ls_pay_method = is_method[3] Then
		dw_list.DataObject = "b7dw_prt_cmsmonth_notice_naray"
	Else
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If
	ls_recyn = "" 
ElseIf ls_bill_type = '4' Then	//월별자동이체
	If ls_pay_method = is_method[2] OR ls_pay_method = is_method[3] Then
		If ls_kind = "1" Then
			dw_list.DataObject = "b7dw_prt_cms_month_bill_naray"
			ls_recyn = ""
		Else
			dw_list.DataObject = "b7dw_prt_cms_month_receipt_naray"
			ls_recyn = "REC"
		End If
	Else
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If	
	
ElseIf ls_bill_type = '5' Then	//월별지로old
	If ls_pay_method = is_method[1] Then
		If ls_kind = "1" Then
			dw_list.DataObject = "b7d_prt_giro_month_bill_naray_old"
			ls_recyn = ""
		Else
			dw_list.DataObject = "b7d_prt_giro_month_receipt_naray_old"
			ls_recyn = "REC"
		End If
		
	Else		
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If	
ElseIf ls_bill_type = '6' Then	//월별자동이체old
	If ls_pay_method = is_method[2] OR ls_pay_method = is_method[3] Then		
		If ls_kind = "1" Then
			dw_list.DataObject = "b7dw_prt_cms_month_bill_naray_old"
			ls_recyn = ""
		Else
			dw_list.DataObject = "b7dw_prt_cms_month_receipt_naray_old"
			ls_recyn = "REC"
		End If		
	Else		
		f_msg_usr_err(200, Title, "납입방법이 잘못되었습니다. 확인하세요!")
		Return
	End If	
End If

dw_list.SetTransObject(SQLCA)
	
ls_where = ""

//If ll_payidRows < 1 Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " info.payid = '" + ls_payid + "' "
////   ls_where_payid = ls_payid
//Else
//	ls_where_payid = ""
//	For ll_curRow = 1 To ll_payidRows
//		If ls_where_payid <> "" Then ls_where_payid += ", "
//		ls_where_payid += "'" + ls_selectPayid[ll_curRow] + "'"
//	Next
//	
//	If ls_where_payid <> "" Then
//		If ls_where <> "" Then ls_where += " AND "
//		ls_where += " info.payid in (" + ls_where_payid + ") "		
//	End If
//End If

dw_list.is_where = ls_where
//dw_list.setredraw(False)
If ls_bill_type <> '5' and  ls_bill_type <> '6'  Then

	If ls_pay_method = is_method[1] Then
		ll_rows = dw_list.Retrieve(ls_payid, ls_trdt, ls_pay_method, ls_chargedt, is_ctype_20)
	Else
		ll_rows = dw_list.Retrieve(ls_payid, ls_trdt, ls_pay_method, ls_chargedt, is_ctype_20, is_pay_method_2)
	End If
	If ll_rows < 0 Then 
		f_msg_usr_err(2100, Title, "Retrieve()")
		//dw_list.setredraw(True)
		Return
	ElseIf ll_rows = 0 Then
		f_msg_usr_err(1100, Title, "")
		//dw_list.setredraw(True)
		Return
	End If	
Else
	ll_rows = wf_receipt_naray_old(ls_bill_type, ls_payid, ls_trdt, ls_pay_method, ls_chargedt, is_ctype_20, is_pay_method_2)
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		//dw_list.setredraw(True)
		Return
	ElseIf ll_rows = 0 Then		
		f_msg_usr_err(1100, Title, "")
		//dw_list.setredraw(True)
		Return
	else
//		dw_list.insertrow(0)
//		dw_list.setredraw(True)
	End If 	
End If

b7u_dbmgr_2 lu_dbmgr
lu_dbmgr = Create b7u_dbmgr_2

If ls_pay_method = is_method[1] Then  //지로
	lu_dbmgr.is_title = This.Title
	lu_dbmgr.is_caller = "b7w_prt_giro_notice_naray%ue_ok"
	lu_dbmgr.is_data[1] = ls_busyn//공급받는자표시 
	lu_dbmgr.is_data[2] = ls_recyn//청구 '' / 영수 rec 구분
	lu_dbmgr.is_data2[1] = ls_trdt
	lu_dbmgr.is_data2[2] = ls_usedt_fr
	lu_dbmgr.is_data2[3] = ls_usedt_to
	lu_dbmgr.is_data2[4] = ls_paydt
	lu_dbmgr.is_data2[5] = ls_editdt
	lu_dbmgr.is_data2[6] = ls_payid
	lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.idw_data[2] = dw_select2
	
	SetPointer(HourGlass!)
	SetRedraw(False)
	lu_dbmgr.uf_prc_db_06()
	SetRedraw(True)
	SetPointer(Arrow!)
	
	li_rc = lu_dbmgr.ii_rc
	Destroy lu_dbmgr	
	
ElseIf ls_pay_method = is_method[2] OR ls_pay_method = is_method[3] Then	//자동이체/card
	lu_dbmgr.is_title = This.Title
	lu_dbmgr.is_caller = "b7w_prt_cms_notice_naray%ue_ok"
	lu_dbmgr.is_data[1] = ls_busyn //공급받는자표시 
	lu_dbmgr.is_data[2] = ls_recyn //청구 '' / 영수 rec 구분  
	lu_dbmgr.is_data2[1] = ls_trdt
	lu_dbmgr.is_data2[2] = ls_usedt_fr
	lu_dbmgr.is_data2[3] = ls_usedt_to
	lu_dbmgr.is_data2[4] = ls_paydt
	lu_dbmgr.is_data2[5] = ls_editdt
	lu_dbmgr.is_data2[6] = ls_payid
	lu_dbmgr.idw_data[1] = dw_list
	
	SetPointer(HourGlass!)
	SetRedraw(False)
	lu_dbmgr.uf_prc_db_06()
	SetRedraw(True)
	SetPointer(Arrow!)
	li_rc = lu_dbmgr.ii_rc
	Destroy lu_dbmgr
End If

//dw_cond.Enabled = False
//dw_select1.Enabled = False
//dw_select2.Enabled = False
//cb_shift_r.Enabled = False
//cb_shift_l.Enabled = False

end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_header_set = False
ib_margin = True
end event

event ue_reset;call super::ue_reset;//dw_cond.Enabled = True
//dw_select1.Enabled = True
//dw_select2.Enabled = True
//cb_shift_r.Enabled = True
//cb_shift_l.Enabled = True

dw_select1.Reset()
dw_select2.Reset()
end event

event open;call super::open;String	ls_result[], ls_ref_desc, ls_temp

//관리점 전화번호
//is_manager_tel = fs_get_control("B0","A104", ls_ref_desc) 

//개인
is_ctype_10 = fs_get_control("B0", "P111", ls_ref_desc)
//부가세 청구코드 1015
is_surtax   = fs_get_control("P1", "A107", ls_ref_desc)
//법인
ls_temp	= fs_get_control("B0", "P110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
is_ctype_20    = ls_result[1]

//자동이체 
is_pay_method_2    = fs_get_control("B0", "P130", ls_ref_desc)

//지로; 은행; 카드 //  1;2;3
ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , is_method[])
End If


dw_cond.object.editdt[1] =  fdt_get_dbserver_now()
end event

event ue_set_header();If  ib_header_set Then 
	dw_list.setRedraw( False )
	
	dw_list.object.company_name.alignment = 0
	dw_list.object.company_name.width = LenA( is_company_name ) * 40
	dw_list.object.company_name.text = is_company_name
	
	IF	 is_pgm_id1 <> '' Then
		string ls_pgm_id
//		ls_pgm_id  = 'PGM ID : ' + is_pgm_id1
//		dw_list.object.pgm_id1.alignment = 0
//		dw_list.object.pgm_id1.width = len( ls_pgm_id ) * 40
//		dw_list.object.pgm_id1.text = ls_pgm_id
	End If		
	
//****kenn Modify 1998-12-04 Fri****
//**이유 : Title이 긴 출력물에서는 빈종이가 한장 더 출력 된다.
//**조치 : date_time과 title Text Object의 X, Width를 조정하지 못하게 한다.
//	dw_list.object.date_time.x = &
//		long( dw_list.object.date_time.x ) - &
//		( (len( is_date_time ) * 30  ) -Long( dw_list.object.date_time.width)  )
//	dw_list.object.date_time.width = len( is_date_time ) * 30
//****kenn****
	dw_list.object.date_time.alignment = 1
	dw_list.object.date_time.text = is_date_time
	
//	dw_list.object.title.x = &
//		long( dw_list.object.title.x ) - &
//		long( (  ( len( is_title ) * 60  ) - Long( dw_list.object.title.width)   ) / 2    )
//	dw_list.object.title.width = len( is_title ) * 60
	dw_list.object.title.alignment = 2
	dw_list.object.title.text = is_title
	
	If Not Isnull( is_condition ) Then
		If is_condition <> '' Then
			dw_list.object.condition.alignment = 2
//			dw_list.object.condition.x = &
//				long( dw_list.object.condition.x ) - &
//				Long( (len( is_condition ) * 30  ) -Long( dw_list.object.condition.width)/2  )
//			dw_list.object.condition.width = len( is_condition ) * 35
			dw_list.object.condition.text = is_condition
		End If			
	End If		

	dw_list.setRedraw( True )	
End If

/*
Constant Integer lic_prt_height = 132
Integer	li_ori_height, li_title_width, li_title_x
String	ls_request, ls_describe, ls_modify
String	ls_ref_content, ls_ref_desc
String	ls_message

If Not ib_footer_set Then Return

ls_request = "p_logprt.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "p_logprt" Then Return

dw_list.SetRedraw(False)

ls_request = "datawindow.footer.height"
ls_describe = dw_list.Describe(ls_request)
li_ori_height = Integer(ls_describe)

//Title
ls_request = "title.name"
ls_describe = dw_list.Describe(ls_request)
If Lower(Trim(ls_describe)) = "title" Then
	ls_request = "title.X title.Width"
	ls_describe = dw_list.Describe(ls_request)
	li_title_x = Integer(Mid(ls_describe, 1, Pos(ls_describe, "~n") - 1))
	li_title_width = Integer(Mid(ls_describe, Pos(ls_describe, "~n") + 1))
Else
	li_title_x = 5
	li_title_width = 2745
End If

ls_modify = "datawindow.footer.height=" + String(li_ori_height + lic_prt_height)
dw_list.Modify(ls_modify)

ls_ref_content = fs_get_control("B0", "PRT1", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
ls_message = ls_ref_content
ls_ref_content = fs_get_control("B0", "PRT2", ls_ref_desc)
If IsNull(ls_ref_content) Then ls_ref_content = ""
If ib_footer_line Then
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += "~r~n"
Else
	If ls_message <> "" And ls_ref_content <> "" Then ls_message += " "
End If
ls_message += ls_ref_content
ls_modify = "create text(band=footer alignment=~"2~" text=~"" + ls_message + "~" border=~"0~" color=~"0~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height + 24) + "~" height=~"104~" width=~"" + String(li_title_width) + "~" name=t_logprt  font.face=~"굴림체~" font.height=~"-8~" font.weight=~"400~"  font.family=~"1~" font.pitch=~"1~" font.charset=~"129~" background.mode=~"1~" background.color=~"553648127~" )"
dw_list.Modify(ls_modify)

ls_modify = "create bitmap(band=footer filename=~"logprt.jpg~" x=~"" + String(li_title_x) + "~" y=~"" + String(li_ori_height) + "~" height=~"128~" width=~"704~" border=~"0~" name=p_logprt )"
dw_list.Modify(ls_modify)

dw_list.SetRedraw(True)
*/

end event

type dw_cond from w_a_print`dw_cond within b7w_prt_combined_notice_naray
integer x = 119
integer y = 56
integer width = 2793
integer height = 352
string dataobject = "b7dw_cnd_combined_naray"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;
Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]			//고객번호
			Object.customernm[row] = iu_cust_help.is_data[2]		//고객명
		End If
End Choose




end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
//iu_cust_help.ib_data[1] = False

is_help_win[1] = "b1w_hlp_payid"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;Long ll_year, ll_mon, ll_last_day, ll_return, ll_reqcycle = 0, ll_temp_year,ll_temp_month ,ll_temp_day
String ls_usedt_fr, ls_usedt_to, ls_useddt, ls_trdt, ls_bill_type, &
       ls_day = '', ls_unitcycle = '', ls_chargedt
Date ld_trdt, ld_useddt, ld_use_fr, ld_use_to

dw_cond.AcceptText()

ls_bill_type = This.object.bill_type[1]

Choose Case dwo.Name
	Case "payid"
		wfi_get_customerid(data)
			
	Case "chargedt"
		//청구기준일 구하기
		Select reqdt
		     , ADD_MONTHS( INPUTCLOSEDT, 1)
			  , useddt_fr
			  , useddt_to 
		  Into :id_reqdt
			  , :id_inputclosedt
			  , :ld_use_fr
			  , :ld_use_to
		  From reqconf 
		 Where to_char(chargedt) = :data;
	
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Select Error(REQCONF)")
			Return 
		End If		
		
		//청구기준일
		//is_reqdt = String(id_reqdt, 'yyyy-mm')
		This.object.trdt[1] = id_reqdt
		is_chargedt = data
		
		//사용기간 시작일
		//ld_use_fr = fd_pre_month(id_reqdt, 1)
		//사용기간 종료일
		//ld_use_to = fd_date_pre(id_reqdt, 1)		

		dw_cond.Object.usedt_fr[1] = ld_use_fr
		dw_cond.Object.usedt_to[1] = ld_use_to
		
		// 납입일구하기
//		Select inputclosedt
//		Into :id_inputclosedt
//		From reqconf 
//		Where to_char(chargedt) = :data;	
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(title, "Select Error(REQCONF)")
//			Return 
//		End If				

		dw_cond.Object.paydt[1] = id_inputclosedt	
		
	Case "trdt"      
		If ls_day =  '' Then			
			ls_chargedt = This.Object.chargedt[1]
			
			Select to_char(reqdt, 'dd')
				  , unitcycle
				  , reqcycle
			  Into :ls_day
				  , :ls_unitcycle
				  , :ll_reqcycle
			  From reqconf 
			 Where to_char(chargedt) = :ls_chargedt;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "Select Error(REQCONF)")
				Return 
			End If
		End If
		
		ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm") + ls_day
		ld_trdt = Date(String(ls_trdt, "@@@@/@@/@@"))

		IF ls_unitcycle = 'M' Then  
			//사용기간 시작일
			ld_use_fr = fd_month_pre(ld_trdt, ll_reqcycle)
		ElseIF ls_unitcycle = 'D' Then
			//사용기간 시작일
			ld_use_fr = relativedate(ld_trdt, -ll_reqcycle)
		End IF
		//사용기간 종료일
		ld_use_to = relativedate(ld_trdt, -1)	
		
		dw_cond.Object.usedt_fr[1] = datetime(ld_use_fr)
		dw_cond.Object.usedt_to[1] = ld_use_to
		
//		//청구년월
//		ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm")
//		ld_trdt = Date(String(ls_trdt, "@@@@/@@/01"))
//		//사용기간
//		ld_useddt = fd_pre_month(ld_trdt, 0)
//		ls_useddt = String(ld_useddt, "yyyymmdd")
//		ll_year = Long(Mid(ls_useddt, 1, 4))
//		ll_mon = Long(Mid(ls_useddt, 5, 2))
//		ll_last_day = fl_date_count_in_month(ll_year, ll_mon)
//		ls_usedt_fr = Mid(ls_useddt, 1, 6) + "01"
//		ls_usedt_to = Mid(ls_useddt, 1, 6) + String(ll_last_day)		
//		
//		dw_cond.Object.usedt_fr[1] = Date(String(ls_usedt_fr, "@@@@/@@/@@"))
//		dw_cond.Object.usedt_to[1] = Date(String(ls_usedt_to, "@@@@/@@/@@"))
//		

End Choose
end event

event dw_cond::buttonclicking;call super::buttonclicking;Long ll_rows, ll_insRow
String ls_where
String ls_chargedt, ls_payid, ls_lastbal, ls_dly_mfr, ls_dly_mto
Date ld_trdt
String ls_trdt, ls_pay_method

Choose Case dwo.Name
	Case "b_select"
		dw_select1.Reset()
		dw_select2.Reset()
		dw_cond.AcceptText()
		
		ls_chargedt = Trim(dw_cond.Object.chargedt[1])
		ls_payid = Trim(dw_cond.Object.payid[1])
		ls_pay_method = Trim(dw_cond.Object.pay_method[1])
		ld_trdt  = dw_cond.Object.trdt[1]
		ls_trdt = String(ld_trdt,'yyyymmdd')

		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_chargedt) Then ls_chargedt = ""
		If IsNull(ls_trdt) Then ls_trdt = ""
		If IsNull(ls_pay_method) Then ls_pay_method = ""		

		
		If ls_trdt = "" Then
			f_msg_usr_err(200, Title, "청구년월")
			dw_cond.SetFocus()
			dw_cond.SetColumn("trdt")
			Return
		End If
			
		If ls_chargedt = "" Then
			f_msg_usr_err(200, Title, "청구주기")
			dw_cond.SetFocus()
			dw_cond.SetColumn("chargedt")
			Return
		End If
		
		If ls_pay_method = "" Then
			f_msg_usr_err(200, Title, "납입방법")
			dw_cond.SetFocus()
			dw_cond.SetColumn("pay_method")
			Return
		End If		

//		ls_where = ""		
//
//		If ls_chargedt <> "" Then
//			If ls_where <> "" Then ls_where += " AND "			
//			ls_where += "  reqamtinfo.chargedt = '" + ls_chargedt + "' "
//		End If
//		
//		If ls_pay_method <> "" Then
//			If ls_where <> "" Then ls_where += " AND "			
//			ls_where += "  reqinfo.pay_method = '" + ls_pay_method + "' "
//		End If		
//		
//		If ls_trdt <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += "reqamtinfo.trdt = to_date('" + ls_trdt + "','yyyymmdd') "
//		End If
//		
//		If ls_payid <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += " reqamtinfo.payid like '" + ls_payid + "%' "
//		End If

      If ls_payid ="" Then
			ls_payid ="%"
		End If
		
		ll_rows = dw_select1.Retrieve(ls_trdt, ls_pay_method, ls_chargedt,ls_payid)
		
//		dw_select1.is_where = ls_where
//		ll_rows = dw_select1.Retrieve()
//		
		If Not ll_rows > 0 Then 
			ll_insRow = dw_select1.InsertRow(0)
			dw_select1.Object.payid[ll_insRow] = "NON"
			dw_select1.Enabled = False
			cb_shift_r.Enabled = False
			Return
		End If
		dw_select1.Enabled = True
		cb_shift_r.Enabled = True
End Choose
		
end event

type p_ok from w_a_print`p_ok within b7w_prt_combined_notice_naray
integer x = 3109
integer y = 68
end type

type p_close from w_a_print`p_close within b7w_prt_combined_notice_naray
integer x = 3109
integer y = 172
end type

type dw_list from w_a_print`dw_list within b7w_prt_combined_notice_naray
integer x = 32
integer y = 448
integer width = 3397
integer height = 1372
string dataobject = "b7dw_prt_giromonth_notice_naray"
end type

type p_1 from w_a_print`p_1 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_2 from w_a_print`p_2 within b7w_prt_combined_notice_naray
integer y = 1872
end type

type p_3 from w_a_print`p_3 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_5 from w_a_print`p_5 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_6 from w_a_print`p_6 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_7 from w_a_print`p_7 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_8 from w_a_print`p_8 within b7w_prt_combined_notice_naray
integer y = 1880
end type

type p_9 from w_a_print`p_9 within b7w_prt_combined_notice_naray
integer y = 1872
end type

type p_4 from w_a_print`p_4 within b7w_prt_combined_notice_naray
integer y = 1872
end type

type gb_1 from w_a_print`gb_1 within b7w_prt_combined_notice_naray
integer y = 1836
end type

type p_port from w_a_print`p_port within b7w_prt_combined_notice_naray
integer y = 1892
end type

type p_land from w_a_print`p_land within b7w_prt_combined_notice_naray
integer y = 1904
end type

type gb_cond from w_a_print`gb_cond within b7w_prt_combined_notice_naray
integer width = 2949
integer height = 436
end type

type p_saveas from w_a_print`p_saveas within b7w_prt_combined_notice_naray
integer y = 1884
end type

type cb_shift_r from commandbutton within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 2313
integer y = 20
integer width = 91
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = ">"
end type

event clicked;Long ll_curRow, ll_insRow
String ls_payid, ls_subid, ls_keysubid, ls_customernm

ll_curRow = dw_select1.GetSelectedRow(0)
If ll_curRow < 1 Then Return

ls_payid = Trim(dw_select1.Object.payid[ll_curRow])
ls_customernm = Trim(dw_select1.Object.customernm[ll_curRow])
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_customernm) Then ls_customernm = ""


dw_select2.SetRedraw(False)
ll_insRow = dw_select2.InsertRow(0)
dw_select2.Object.payid[ll_insRow] = ls_payid
dw_select2.Object.customernm[ll_insRow] = ls_customernm
dw_select2.SetRedraw(True)
end event

type cb_shift_l from commandbutton within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 2313
integer y = 380
integer width = 91
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "<<"
end type

event clicked;Long ll_curRow, ll_insRow
Long ll_rows
String ls_payid

ll_rows = dw_select1.RowCount()
If ll_Rows < 1 Then Return

dw_select2.SetRedraw(False)
FOR ll_curRow = ll_rows TO  0 STEP -1
	dw_select2.DeleteRow(ll_curRow)
NEXT

dw_select2.SetRedraw(True)


end event

type dw_select2 from u_d_external within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 2414
integer y = 20
integer width = 882
integer height = 472
integer taborder = 11
boolean bringtotop = true
string dataobject = "b7d_prt_notice_selectpayid2"
boolean hscrollbar = false
end type

event constructor;//Override
end event

event clicked;call super::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

event doubleclicked;//Override
Long ll_curRow, ll_insRow, ll_rows
String ls_payid
		
Choose Case dwo.Name
	Case "payid"
		ll_curRow = dw_select2.GetSelectedRow(0)
		If ll_curRow < 1 Then Return
		
		dw_select2.SetRedraw(False)
		dw_select2.DeleteRow(ll_curRow)
		ll_rows = dw_select2.RowCount()
		If ll_curRow > 0 Then 
			If ll_rows > ll_curRow Then
				dw_select2.SelectRow( ll_curRow , TRUE )
			Else
				dw_select2.SelectRow( ll_rows , TRUE )
			End If
		End If		
		dw_select2.SetRedraw(True)
End Choose
end event

type dw_select1 from u_d_sgl_sel within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 1467
integer y = 20
integer width = 832
integer height = 472
integer taborder = 11
boolean bringtotop = true
string dataobject = "b7dw_prt_notice_selectpayid1"
end type

event ue_init;call super::ue_init;//dwObject ldwo_sort
//
ib_sort_use = False
//
//ldwo_sort = Object.reqinfo_payid_t
//uf_init(ldwo_sort)
//
end event

event doubleclicked;Long ll_curRow, ll_insRow
String ls_payid

ll_curRow = dw_select1.GetSelectedRow(0)
If ll_curRow < 1 Then Return

ls_payid = Trim(dw_select1.Object.reqinfo_payid[ll_curRow])
If IsNull(ls_payid) Then ls_payid = ""

dw_select2.SetRedraw(False)
ll_insRow = dw_select2.InsertRow(0)
dw_select2.Object.payid[ll_insRow] = ls_payid
dw_select2.SetRedraw(True)
end event

type cb_shift_r_all from commandbutton within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 2313
integer y = 260
integer width = 91
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = ">>"
end type

event clicked;Long ll_curRow, ll_insRow, ll_row, ll_row_start
String ls_payid, ls_subid, ls_keysubid, ls_customernm
ll_row_start =1

ll_row = dw_select1.RowCount()
If ll_Row < 1 Then Return

dw_select2.SetRedraw(False)

FOR ll_row_start = 1 TO ll_row STEP 1
	ls_payid = Trim(dw_select1.Object.payid[ll_row_start])
	ls_customernm = Trim(dw_select1.Object.customernm[ll_row_start])
	If IsNull(ls_payid) Then ls_payid = ""
	If IsNull(ls_customernm) Then ls_customernm = ""
	ll_row_start = dw_select2.InsertRow(0)
	dw_select2.Object.payid[ll_row_start] = ls_payid
	dw_select2.Object.customernm[ll_row_start] = ls_customernm	
NEXT

dw_select2.SetRedraw(True)
end event

type cb_shift_l_all from commandbutton within b7w_prt_combined_notice_naray
boolean visible = false
integer x = 2313
integer y = 140
integer width = 91
integer height = 96
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "<"
end type

event clicked;Long ll_curRow, ll_insRow
Long ll_rows
String ls_payid

ll_curRow = dw_select2.GetSelectedRow(0)
If ll_curRow < 1 Then Return

dw_select2.SetRedraw(False)
dw_select2.DeleteRow(ll_curRow)
ll_rows = dw_select2.RowCount()
If ll_curRow > 0 Then 
	If ll_rows > ll_curRow Then
		dw_select2.SelectRow( ll_curRow , TRUE )
	Else
		dw_select2.SelectRow( ll_rows , TRUE )
	End If
End If
dw_select2.SetRedraw(True)
end event

