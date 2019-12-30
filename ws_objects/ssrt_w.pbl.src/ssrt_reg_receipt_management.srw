$PBExportHeader$ssrt_reg_receipt_management.srw
forward
global type ssrt_reg_receipt_management from w_a_reg_m_m3
end type
type dw_seq from datawindow within ssrt_reg_receipt_management
end type
type dw_itemlist from datawindow within ssrt_reg_receipt_management
end type
type cb_issue from commandbutton within ssrt_reg_receipt_management
end type
end forward

global type ssrt_reg_receipt_management from w_a_reg_m_m3
integer width = 4590
integer height = 2728
dw_seq dw_seq
dw_itemlist dw_itemlist
cb_issue cb_issue
end type
global ssrt_reg_receipt_management ssrt_reg_receipt_management

type variables
Long il_orderno, il_validkey_cnt, il_contractseq
String is_act_gu, is_cus_status, is_validkey_yn, is_svctype, is_svccode, is_type
String is_confirm_svccod[]
String is_langtype   //언어선택
String is_n_langtype, is_n_auth_method, is_n_validitem1, is_n_validitem2, is_n_validitem3
String is_validkey_type

//인증Key 관리
Integer ii_cnt
String  is_moveyn

//회선정산관련 추가
String is_in_svctype, is_out_svctype, is_validkey_msg, is_inout_svc_gu
String is_bonsa_partner
String is_hotbillflag   //고객hotbillflag
String is_validkeyloc, is_h323id[]
String is_reg_partner, is_priceplan, is_customerid

String is_callforward_code[], is_callforward_type, is_addition_itemcod

String is_partner_cus_yn, is_date_allow_yn

// 달력관련 추가-1hera
s_calendar_sams istr_cal
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function string wfs_get_control (string as_module, string as_ref_no, ref string as_ref_desc)
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public function integer wf_reprint (string ws_app_seq)
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

public function string wfs_get_control (string as_module, string as_ref_no, ref string as_ref_desc);String ls_return, ls_ref_content


SELECT ref_desc, ref_content
  INTO :as_ref_desc, :ls_ref_content
  FROM SYSCTL1T
 WHERE MODULE = :as_module
   AND REF_NO = :as_ref_no;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "System Control select error")
	ls_return = "0"
	Return ls_return
ElseIf SQLCA.SQLCode = 100 Then
	ls_return = "1"
	Return ls_return
Else
	ls_return = "2" + ls_ref_content
End If
	
Return ls_return
end function

public subroutine of_resizepanels ();//// parkkh modify 2004.04.27
//Long ll_Width, ll_Height, ll_long, ll_long_1, ll_long_2
//
//// Validate the controls.
//If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return
//
//ll_Width 	= WorkSpaceWidth()
//ll_Height 	= WorkspaceHeight()
//
//If il_validkey_cnt > 0 Then
//	// Middle processing
//	idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)
//	idrg_Middle.Resize(idrg_Middle.Width, st_horizontal.Y - st_horizontal2.Y - cii_BarThickness)
//	// Bottom Processing
//	idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//	idrg_Bottom.Resize(idrg_Middle.Width, p_insert.Y - st_horizontal.Y - cii_BarThickness * 2)	
//Else
//	// Middle processing
//	idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)
//	idrg_Middle.Resize(idrg_Middle.Width, p_insert.Y - st_horizontal2.Y - cii_BarThickness * 2)		
//End If
//
//dw_cond.SetFocus()
//dw_cond.Setrow(1)
//dw_cond.SetColumn("memberid")
end subroutine

public subroutine of_resizebars ();//// parkkh modify 2004.04.27
//st_horizontal2.Move(idrg_Middle.X, st_horizontal2.Y)
//st_horizontal2.Resize(idrg_Top.Width, cii_Barthickness)
//
//st_horizontal.Move(idrg_Middle.X, st_horizontal.Y)
//st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)
//
//of_RefreshBars()
//
//dw_cond.SetFocus()
//dw_cond.SetRow(1)
//dw_cond.SetColumn('memberid')
//
//
end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm, ls_payid, ls_partner, ls_customerid
Integer	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	Select customernm, status,  	 payid,	    partner
	  Into :ls_customernm,   :is_cus_status,    :ls_payid,   :ls_partner
	  From customerm
	 Where customerid = :as_customerid;
	 
	 ls_customerid = as_customerid
ELSE
	Select customerid, customernm, status, 	 payid,    partner
	  Into :ls_customerid,:ls_customernm,:is_cus_status,:ls_payid,:ls_partner
	  From customerm
	 Where memberid = :as_memberid;
END IF

If SQLCA.SQLCode = 100 Then		//Not Found
	IF li_sw = 1 THEN
   	f_msg_usr_err(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	f_msg_usr_err(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
dw_cond.object.customerid[1] = ls_customerid
Return 0

end function

public function integer wf_reprint (string ws_app_seq);Integer	li_rtn
String 	ls_seq, 				ls_appno, 			ls_memberid
Long 		ll_row, 				ll,					jj,				kk,	&
			ll_shopcount, 		ll_list_cnt, 		ll_seq, &
			ll_cnttotal,		ll_paycnt,			ll_keynum
DEC{2}	ldc_total, 			ldc_cash,			ldc_change,		ldc_paytotal, &
			ldc_amt[],			ldc_payamt,			ldc_tmp
dec		ldc_shopCount

String 	ls_lin1, 		ls_lin2, 		ls_lin3
String 	ls_empnm,		ls_partner,		ls_method[], ls_cdname[], ls_customerid, ls_payid
date 		ldt_workdt
String 	ls_temp, &
			ls_ref_desc, &
			ls_itemcod, 	ls_itemnm, &
			ls_paymethod, &
			ls_val, &
			ls_regcod, &
			ls_facnum
String	ls_app_no,		ls_pgm_id,		ls_bill_chk,		ls_trcod,		ls_trdt,	&
			ls_paid_trdt,  ls_dctype
			
Integer  li_cnt, li_refund_cnt			
Long     ll_account, 	   ll_totcnt_c
dec      ldec_payamt, 		ldec_totpayamt_c, 		ldec_totpayamt
String   ls_print_desc, 	ls_descript,				ls_concession   

// 2019.04.15 변수 추가 VAT 추가에 따른 Modified by Han
dec{2}   ld_taxamt, ldc_taxamt, ld_taxamt_tot
string   ls_surtaxyn
string   ls_approvalno
// 2019.04.22 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by Han

string ls_prnbuf, ls_name[]
long   ll_print_row
long   ll_prt_ln, ll_temp
string ls_normal = "~h1B" + "!" + "~h08" + "~h1B" + "E" + "~h00"  // Normal Character
String ls_Cut    = "~h1B" + "~h69"                                // Cut Paper
int li_handle

ls_temp 			= GS_PRN
IF IsNull(ls_temp) OR ls_temp = ''  then
	ls_temp = "COM1;6;8;2;0"
END IF	
fi_cut_string(ls_temp, ";", ls_name[])

li_handle = FileOpen(ls_name[1], StreamMode!, Write!)
		
IF li_handle < 1  THEN
	MessageBox('알 림', '프린터 오픈 에러입니다.')
	FileClose(li_handle)
	SetPointer(Arrow!)
//	Return
END IF

// Structure 초기화 
ll_print_row = gs_str_receipt_print.ll_line_num
if ll_print_row > 0 then
	for ll_print_row = 1 to gs_str_receipt_print.ll_line_num
		gs_str_receipt_print.ls_out[ll_print_row] = ""
	next
	gs_str_receipt_print.ll_line_num = 0
end if


//변수 Clear
FOR kk = 1 to 6
	ldc_amt[kk] = 0
NEXT
ls_bill_chk    = "N"
ll_seq 			= 0
ldc_paytotal 	= 0
ll_cnttotal 	= 0
ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ls_seq  = ws_app_seq //실 영수증 발행 번호 임.
ls_partner =  dw_cond.Object.partner[1]

SELECT shopcount, 		workdt, 			SUM(total), 	SUM(cash), 	sum(change), customerid    , approvalno
  INTO :ll_shopcount, 	:ldt_workdt,	:ldc_total,		:ldc_cash,	:ldc_change, :ls_customerid, :ls_approvalno
  FROM RECEIPTMST
 WHERE SEQ_APP = :ls_seq 
 Group By shopcount, workdt, customerid, approvalno  ;

 
IF sqlca.sqlcode < 0 then
		f_msg_INFO(9000, Title, "Receiptmst의 자료 합계오류.")
		dw_detail2.SetFocus()
		Return -1
END IF
//==================================================
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
// PayMethod Name
FOR ll = 1 to 6
	SELECT codenm INTO :ls_cdname[ll] from syscod2t
	 WHERE grcode = 'B310' 
	   AND code   = :ls_method[ll] ;
NEXT
//======================================================
ll_row = dw_seq.retrieve(ls_seq)

//2010.07.16 JHCHOI BILL 영수증인지 확인하는 쿼리.
ls_app_no = dw_seq.Object.approvalno[1]

SELECT PAYID, PGM_ID INTO :ls_payid, :ls_pgm_id
FROM   DAILYPAYMENT
WHERE  CUSTOMERID = :ls_customerid
AND    APPROVALNO = :ls_app_no
AND    ROWNUM = 1
GROUP BY PAYID, PGM_ID;

IF IsNull(ls_pgm_id) THEN ls_pgm_id = ""

IF ls_pgm_id = "BILL" THEN
	ls_bill_chk = "Y"
END IF

//total 계산

ldc_total 	=  dw_seq.GetItemNumber(dw_seq.RowCount(), "cp_total")
ldc_cash 	=  dw_seq.GetItemNumber(dw_seq.RowCount(), "cp_cash")
ldc_change 	=  dw_seq.GetItemNumber(dw_seq.RowCount(), "cp_change")

// PayMethod 별 total 계산.
FOR ll = 1 to ll_row
	ls_appno =  dw_seq.Object.Approvalno[ll]
	FOR jj =  1 to 6
//2019.04.15 결재수단별 VAT 금액 추가 Modified by Han
//		select SUM(payamt) INTO :ldc_tmp FROM dailypayment
//		 WHERE APPROVALNO = :ls_appno
//		   AND paymethod = :ls_method[jj];

		select SUM(payamt), nvl(SUM(taxamt),0) INTO :ldc_tmp, :ld_taxamt FROM dailypayment
		 WHERE APPROVALNO = :ls_appno
		   AND paymethod = :ls_method[jj] ;


		IF IsNULL(ldc_tmp) OR sqlca.sqlcode < 0 then ldc_tmp = 0
		
		ldc_amt[jj] += ldc_tmp + ld_taxamt
	NEXT
NEXT

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
li_rtn = f_pos_header_vat(ls_partner, 'R', ll_shopcount, 0)
/* 잠시막음 김선주  */
/* IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			PRN_ClosePort()
			return -9
END IF */
//======================================================================
//Item List 출력
//======================================================================
FOR ll = 1 to ll_row
	ls_appno = dw_seq.Object.approvalno[ll]
	ll_list_cnt =  dw_itemlist.REtrieve(ls_appno)
	
	For jj = 1 To ll_list_cnt
		
		ls_dctype = trim(dw_itemlist.Object.dctype[jj]);
		
	 If ls_dctype = 'D' Then /*2014.08.25 김선주 추가. 영수증에 Refund항목은 구분해서 찍기로 함으로써 추가함. */
		
		ll_seq += 1
		ls_temp 		= String(ll_seq, '000') + ' ' //순번
		ls_itemcod 	= trim(dw_itemlist.Object.itemcod[jj])
		ls_itemNM 	= trim(dw_itemlist.Object.itemNM[jj])
		ldc_payamt	= dw_itemlist.object.payamt[jj]
		ll_paycnt 	= dw_itemlist.object.paycnt[jj]
// 2019.04.15 taxamt, Surtaxyn 변수 저장 추가 Modified by Han
      ldc_taxamt  = dw_itemlist.Object.taxamt  [jj]
		ls_surtaxyn = dw_itemlist.Object.surtaxyn[jj]

		
		IF ls_bill_chk = "Y" THEN
			SELECT TRCOD INTO :ls_trcod
			FROM   ITEMMST
			WHERE  ITEMCOD = :ls_itemcod;
			
			SELECT TO_CHAR(TRDT, 'YYYYMM') INTO :ls_trdt
			FROM   REQPAY
			WHERE  PAYID = :ls_payid
			AND    APPROVALNO = :ls_appno
			AND    SALE_TRCOD = :ls_trcod
			GROUP BY TO_CHAR(TRDT, 'YYYYMM');
			
			ls_paid_trdt = MidA(ls_trdt, 5, 2) + '-' + MidA(ls_trdt, 1, 4) + ']'					//청구월
			
		END IF
		
		ldc_paytotal 	+= ldc_payamt
		ll_cnttotal 	+= ll_paycnt 
// 2019.05.15 taxamt Tot 추가 Modified by Han
		ld_taxamt_tot  += ldc_taxamt

		IF ls_bill_chk = "Y" THEN
			ls_temp 		+= LeftA(ls_paid_trdt + ls_itemnm + space(24), 24)  //아이템			
		ELSE				
			ls_temp 		+= LeftA(ls_itemnm + space(24), 24)  //아이템
		END IF			
		ls_temp 		+= Space(1) + RightA(Space(4) + String(ll_paycnt), 4) + ' '  //수량
//2019.04.15 iTEM별 금액에 VAT 금액 ADD. Modified by Han
//		ls_val 		= fs_convert_amt(ldc_payamt,  8)
		ls_val 		= fs_convert_amt(ldc_payamt + ldc_taxamt,  8)
		ls_temp 		+= ls_val //금액
		f_printpos_vat(' ' + ls_temp)	
	
		ls_regcod 	= trim(dw_itemlist.Object.regcod[jj])
		//regcode master read
		select keynum, 		trim(facnum)	INTO :ll_keynum,	:ls_facnum
	  	  FROM regcodmst
	 	 where regcod = :ls_regcod ;

		// Index Desciption 2010-08-20 jhchoi
		SELECT indexdesc
		INTO	 :ls_facnum
		FROM	 SHOP_REGIDX
		WHERE	 regcod = :ls_regcod
		AND	 shopid = :ls_partner;					  		  
	
		IF IsNull(ll_keynum) 	then ll_keynum 	= 0
		IF IsNull(ls_facnum) 	then ls_facnum 	= ""
		//2010.08.20 jhchoi 수정.
		//ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
// 2019.04.15 Surtaxyn 출력 추가 Modified by Han
//		ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")"
		ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" + ' ' + ls_surtaxyn		
		f_printpos_vat(' ' + ls_temp)
	 END IF 
	NEXT
NEXT
//===================//
//Item List 출력 END //
//===================//
f_printpos_vat(' ' + ls_lin1)

//2019.04.15 Total 만 출력에서 Net. Vat, Total순 출력 Modified by Han
//ls_val 	= fs_convert_sign(ldc_paytotal, 8)
//ls_temp 	= LeftA("Total" + space(32), 32) + ls_val

ls_val      = fs_convert_sign(ldc_paytotal, 8)
ls_temp 	= LeftA("Net" + space(33), 33) + ls_val
f_printpos_vat(' ' + ls_temp)

ls_val      = fs_convert_sign(ld_taxamt_tot, 8)
ls_temp 	= LeftA("Vat" + space(33), 33) + ls_val
f_printpos_vat(' ' + ls_temp)

f_printpos_vat(' ' + ls_lin1)

ls_val      = fs_convert_sign(ldc_paytotal + ld_taxamt_tot, 8)
ls_temp 	= LeftA("Total" + space(33), 33) + ls_val
f_printpos_vat(' ' + ls_temp)


f_printpos_vat(' ' + ls_lin2)


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
   AND ( A.PAYDT                              = :ldt_workdt )    
   AND ( A.DCTYPE                             = 'C'    )          
  /* AND ( B.REGTYPE                            = :ls_regtype         ) */
   AND ( A.CUSTOMERID                         = :ls_customerid ) ;
		

//2019.04.15 Vat관련 항목 값 초기화 Modified by Han
ld_taxamt     = 0
ldc_taxamt    = 0

If li_refund_cnt > 0 Then /*항목이 있을 때만 프린트 합니다 */
	
	f_printpos_vat(' ' + "Refund ********************")
	
FOR ll = 1 to ll_row
	
	ls_appno = dw_seq.Object.approvalno[ll]
	ll_list_cnt =  dw_itemlist.Retrieve(ls_appno)
	
	For jj = 1 To ll_list_cnt		
		
	ls_dctype 	= trim(dw_itemlist.Object.dctype[jj])
	
	If ls_dctype ='c' Or ls_dctype = 'C' Then 		
		
	   ldec_payamt	=  dw_itemlist.Object.payamt[jj]
		
		/*****출력***************/
		IF ldec_payamt <> 0 THEN			

			ll_account 			+= 1		
			ls_temp 				= String(ll_account, '000') 				+ ' '	//순번
			ls_trcod    		= trim(dw_itemlist.Object.trcod[jj])
			ls_itemcod 			= trim(dw_itemlist.Object.itemcod[jj])
			ls_itemnm 			= trim(dw_itemlist.Object.itemnm[jj])
			ls_regcod 			= trim(dw_itemlist.Object.regcod[jj])
				
			ldec_payamt			=  dw_itemlist.Object.payamt[jj]
//2019.04.15 taxamt, surtaxyn 변수 저장 Modified by Han
         ld_taxamt         = dw_itemlist.Object.taxamt  [jj]
			ls_surtaxyn       = dw_itemlist.Object.surtaxyn[jj]
			ld_taxamt_tot    += ld_taxamt
			ldc_taxamt       += ld_taxamt //Refund Item별 Vat

			ldec_totpayamt_c 	+= ldec_payamt

			ls_temp 				+= LeftA(ls_itemnm + space(24), 24) +  ' '   //아이템
			li_cnt 				=  1
			ll_totcnt_c       += li_cnt
			ls_temp 				+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량

// 2019.05.15 Item별 금액에 Vat 금액 포함 Modified by Han
//			ls_val 				=  fs_convert_amt(ldec_payamt,  8)
         ls_val 				=  fs_convert_amt(ldec_payamt + ld_taxamt,  8)
			ls_temp 				+= ls_val //금액			
								
			f_printpos_vat(' ' + ls_temp)				
			
			/* regcode master read */
			SELECT keynum, 	facnum,	trim(regdesc),    concession
			  INTO :ll_keynum, :ls_facnum, 	:ls_descript,		:ls_concession
			  FROM regcodmst
			 WHERE regcod = :ls_regcod;						
			 
			IF IsNull(ll_keynum) 		then ll_keynum 		= 0 ;

// 2019.04.15 surtaxyn 출력 추가 Modified by Han
//			ls_print_desc = "(Key#" + String(ll_keynum) + " " + ls_facnum + ")";
			SELECT indexdesc
			  INTO :ls_facnum
			  FROM SHOP_REGIDX
			 WHERE regcod = :ls_regcod
			   AND shopid = :GS_SHOPID;

			ls_print_desc = "(Key#" + String(ll_keynum) + " " + ls_facnum + ")" + ' ' + ls_surtaxyn
				
			ls_temp =  Space(4) + LeftA(ls_print_desc + space(24), 24)			
			
			f_printpos_vat(' ' + ls_temp)			
		END IF	
	 END IF
	NEXT	
NEXT

	f_printpos_vat(' ' + ls_lin1)
// 2019.04.15 Refund Total 출력을 Refund net, Refund vat Refund Total로 변경 modifid by Han
//	ls_temp =  	LeftA("Refund Total" + space(28), 28) + &
//					RightA(Space(3) + String(ll_totcnt_C), 3) + ' ' + & 
//					fs_convert_sign(ldec_totpayamt_c, 9)
//	f_printpos(ls_temp)

	ls_temp =  	LeftA("Refund Net" + space(32), 32) + &
					fs_convert_sign(ldec_totpayamt_c, 9)
	f_printpos_vat(' ' + ls_temp)

	ls_temp =  	LeftA("Refund Vat" + space(32), 32) + &
					fs_convert_sign(ldc_taxamt, 9)
	f_printpos_vat(' ' + ls_temp)

	f_printpos_vat(' ' + ls_lin1)

	ls_temp =  	LeftA("Refund Total" + space(28), 28) + &
					RightA(Space(3) + String(ll_totcnt_C), 3) + ' ' + & 
					fs_convert_sign(ldec_totpayamt_c + ldc_taxamt, 9)
	f_printpos_vat(' ' + ls_temp)


	f_printpos_vat(' ' + ls_lin2)

// 2019.04.15 Grand Total에 Vat 금액 포함 Modified by Han
//	ldec_totpayamt = ldec_totpayamt_c + ldc_paytotal
	ldec_totpayamt = ldec_totpayamt_c + ldc_paytotal + ld_taxamt_tot

	ls_val  = 	fs_convert_sign(ldec_totpayamt, 8)
	ls_temp =	LeftA("Grand Total" + space(33), 33) + ls_val

	f_printpos_vat(' ' + ls_temp)
	f_printpos_vat(' ' + ls_lin2) 
End if
/*********************************/ 
/*환불 영수증 by 김선주 END                */
/*********************************/			


//--------------------------------------------------------//
//결제수단별 입금액
//--------------------------------------------------------//
For kk = 1 To 6
	if ldc_amt[kk] <> 0 then
		ls_val 	= fs_convert_sign(ldc_amt[kk],  8)
//		IF kk = 1 THEN // 현금에 대해서는 receiptmst.cash 의 값을 사용
//			ls_temp = Left(ls_cdname[kk] + space(33),33) + fs_convert_sign(ldc_cash,8)
//		ELSE
		   ls_temp = LeftA(ls_cdname[kk] + space(33),33) + ls_val
//		END IF
		f_printpos_vat(' ' + ls_temp)
	END IF
NEXT
//거스름돈 처리
ls_val 	= fs_convert_sign(ldc_change,  8)
ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
f_printpos_vat(' ' + ls_temp)
f_printpos_vat(' ' + ls_lin1)

SELECT payid
  INTO :ls_payid
  FROM customerm
 WHERE customerid = :ls_customerid;

//ls_memberid = dw_cond.Object.memberid[1]
//F_POS_FOOTER2(ls_memberid, ls_seq, gs_user_id) original
//Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_seq,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 		
Fs_POS_FOOTER3_vat(ls_payid,ls_customerid,ls_approvalno,gs_user_id, string(ldt_workdt,'yyyymmdd')) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 		

for ll_prt_ln = 1 to gs_str_receipt_print.ll_line_num
	ls_prnbuf = ls_prnbuf + ls_normal + gs_str_receipt_print.ls_out[ll_prt_ln]
next

ls_prnbuf = ls_prnbuf + ls_cut

ll_temp = fileWrite(li_handle, ls_prnbuf)

if ll_temp = -1 then
	FileClose(li_handle)
//	return
end if

FileClose(li_handle)

return 0
end function

on ssrt_reg_receipt_management.create
int iCurrent
call super::create
this.dw_seq=create dw_seq
this.dw_itemlist=create dw_itemlist
this.cb_issue=create cb_issue
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_seq
this.Control[iCurrent+2]=this.dw_itemlist
this.Control[iCurrent+3]=this.cb_issue
end on

on ssrt_reg_receipt_management.destroy
call super::destroy
destroy(this.dw_seq)
destroy(this.dw_itemlist)
destroy(this.cb_issue)
end on

event open;/*------------------------------------------------------------------------
	Name	:	ssrt_reg_receipt_management
	Desc	: 	영수증 통합발행 및 재발행, 입금방법 변경 처리
	Ver.	:	2.0
	Date	:   2007.07.19.
	Programer : 1hera
-------------------------------------------------------------------------*/
call w_a_condition::open

String ls_ref_desc, ls_temp

iu_cust_db_app = Create u_cust_db_app

//// Set the TopLeft, TopRight, and Bottom Controls
idrg_Top 		= dw_master
idrg_Middle 	= dw_detail2
idrg_Bottom 	= dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop 					= idrg_Top.Y
ii_WindowMiddle 				= idrg_Middle.Y
st_horizontal.BackColor 	= BackColor
st_horizontal2.BackColor 	= BackColor
il_HiddenColor 				= BackColor

dw_detail.Enabled = True
dw_detail.visible = True

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)


//날짜 Setting
dw_cond.object.saledt_fr[1]			= Date(fdt_get_dbserver_now())
dw_cond.object.saledt_to[1] 			= date(fdt_get_dbserver_now())
dw_cond.object.partner[1] 				= GS_SHOPID


//PAYMETHOD
//ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
//If ls_temp 		= "" Then Return
//fi_cut_string(ls_temp, ";", is_method[])


cb_issue.Hide()
//PostEvent("resize")





end event

event ue_ok;call super::ue_ok;String 	ls_customerid, &
			ls_partner, 	&
			ls_where1, ls_where2, &
			ls_memberid, &
			ls_saledt_fr, ls_saledt_to, ls_sysdt, &
			ls_option, ls_approvalno
Long 		ll_row, 			ll_result

dw_cond.AcceptText()

ls_sysdt       = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_saledt_fr   = String(dw_cond.object.saledt_fr[1],'yyyymmdd')
ls_saledt_to   = String(dw_cond.object.saledt_to[1],'yyyymmdd')

ls_customerid  = Trim(dw_cond.object.customerid[1])
ls_memberid    = Trim(dw_cond.object.memberid[1])
ls_partner     = Trim(dw_cond.object.partner[1])
ls_approvalno  = Trim(dw_cond.object.approvalno[1])

If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_saledt_fr) 	Then ls_saledt_fr 	= ""
If IsNull(ls_saledt_to) 	Then ls_saledt_to 	= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
IF IsNull(ls_approvalno) 	then ls_approvalno 	= ""
//IF IsNull(ls_operator) 		then ls_operator 		= ""


If ls_customerid <> "" Then
	ll_row = wfi_get_customerid(ls_customerid, "")		//올바른 고객인지 확인
	If ll_row = -1 Then 
		dw_cond.SetFocus()
		dw_cond.SetColumn("customerid")
		Return
	END IF
End If

If ls_saledt_fr = "" Then
	f_msg_info(200, Title, "Sales Date - From")
	dw_cond.SetFocus()
	dw_cond.SetColumn("saledt_fr")
	Return
End If
If ls_saledt_to = "" Then
	f_msg_info(200, Title, "Sales Date - to")
	dw_cond.SetFocus()
	dw_cond.SetColumn("saledt_to")
	Return
End If
If ls_partner = "" Then
	f_msg_info(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

//필수항목 먼저 처리
ls_where1 = ""
ls_where2 = ""
ls_where1 += "shopid ='" + ls_partner + "' "
ls_where1 += "and to_char(trdt,'yyyymmdd') >='" + ls_saledt_fr + "' "
ls_where1 += "and to_char(trdt, 'yyyymmdd') <='" + ls_saledt_to + "' "

ls_where2 =  ls_where1

ls_where1 += "and prt_yn = '" + "Y" + "' "

If ls_approvalno <> "" Then
//	ls_where1 += "and seq_app = '" + ls_approvalno + "'"
// 2019.05.13 Where 절 변경 Modified by Han
	ls_where1 += "and approvalno = '" + ls_approvalno + "'"
End If
If ls_customerid <> "" Then
	ls_where1 += "and customerid = '" + ls_customerid + "'"
End If


dw_detail2.is_where = ls_where1
dw_detail2.Retrieve()
dw_detail.is_where = ls_where2
dw_detail.Retrieve()

ll_row  = dw_detail2.RowCount() + dw_detail.RowCount()

If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

//IF dw_detail.RowCount() = 0 then
//	cb_issue.Hide()
//ELSE
//	cb_issue.Show()
//END IF

SetRedraw(False)

If ll_row > 0 Then
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_disable")

	dw_detail2.SetFocus()
	dw_detail2.Enabled 	= True
	dw_cond.Enabled 		= False
else
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_Enable")
	dw_cond.Enabled 		= True
	dw_cond.SetFocus()
End If

st_horizontal.Visible = True

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event ue_reset();String ls_ref_desc, ls_temp
Int li_rc, li_ret

ii_error_chk = -1

//p_save.PictureName = "Active_e.gif"
//
dw_detail.AcceptText()

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = -1 
			li_ret = Event ue_save()
			If Isnull( li_ret ) or li_ret < 0 then return
		CASE 2

		CASE ELSE
			Return 
	END CHOOSE
		
end If
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("memberid")

ii_error_chk = 0


dw_cond.object.saledt_fr[1] 		= Date(fdt_get_dbserver_now())
dw_cond.object.saledt_to[1] 		= date(fdt_get_dbserver_now())
dw_cond.object.partner[1] 			= GS_SHOPID
SetRedraw(False)

//dw_detail.Enabled 		= False
//dw_detail.visible 		= False
//st_horizontal.Visible 	= False
//
//of_ResizeBars()
//of_ResizePanels()


SetRedraw(True)

end event

type dw_cond from w_a_reg_m_m3`dw_cond within ssrt_reg_receipt_management
integer x = 64
integer y = 60
integer width = 2290
integer height = 316
integer taborder = 10
string dataobject = "ssrt_cnd_reg_receipt_management"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;This.AcceptText()
Choose Case dwo.name
	Case "memberid" 
   	  wfi_get_customerid("", data)
	Case "customerid" 
   	  wfi_get_customerid(data, "")
End Choose	
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "ssrt_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"
dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('memberid')

end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			dw_cond.Object.customerid[row] = dw_cond.iu_cust_help.is_data[1]
			dw_cond.object.customernm[row] = dw_cond.iu_cust_help.is_data[2]
			is_cus_status = dw_cond.iu_cust_help.is_data[3]
			Object.memberid[1] =  iu_cust_help.is_data[4]
	
			IF wfi_get_customerid(dw_cond.iu_cust_help.is_data[1], "") = -1 Then
				return -1
			End IF
		End If

End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m3`p_ok within ssrt_reg_receipt_management
integer x = 2505
integer y = 36
end type

type p_close from w_a_reg_m_m3`p_close within ssrt_reg_receipt_management
integer x = 2848
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within ssrt_reg_receipt_management
integer x = 41
integer y = 4
integer width = 2377
integer height = 396
integer taborder = 0
end type

type dw_master from w_a_reg_m_m3`dw_master within ssrt_reg_receipt_management
boolean visible = false
integer x = 50
integer y = 320
integer width = 2368
integer height = 36
integer taborder = 0
end type

type dw_detail from w_a_reg_m_m3`dw_detail within ssrt_reg_receipt_management
boolean visible = false
integer x = 14
integer y = 1716
integer width = 2542
integer height = 112
integer taborder = 0
boolean enabled = false
string dataobject = "ssrt_reg_receipt_management_detail"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m3`p_insert within ssrt_reg_receipt_management
boolean visible = false
integer x = 55
integer y = 2468
end type

type p_delete from w_a_reg_m_m3`p_delete within ssrt_reg_receipt_management
boolean visible = false
integer x = 347
integer y = 2468
end type

type p_save from w_a_reg_m_m3`p_save within ssrt_reg_receipt_management
boolean visible = false
integer x = 1083
integer y = 2468
end type

type p_reset from w_a_reg_m_m3`p_reset within ssrt_reg_receipt_management
integer x = 1390
integer y = 2468
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within ssrt_reg_receipt_management
integer x = 41
integer y = 456
integer width = 2889
integer height = 1176
integer taborder = 0
string dataobject = "ssrt_reg_receipt_management_list"
end type

event dw_detail2::constructor;call super::constructor;dw_detail2.SetRowFocusIndicator(off!)
end event

event dw_detail2::itemchanged;call super::itemchanged;
//dw_detail Insert & delete 처리
If dwo.name = "chk" Then
	
End If


end event

event dw_detail2::buttonclicked;call super::buttonclicked;String ls_appno, ls_seq, &
			ls_customerid, ls_customernm, ls_partner
choose case dwo.name
	case "b_change"
		ls_customerid 	= dw_cond.Object.customerid[1]
		ls_customernm 	= dw_cond.Object.customernm[1]
		ls_partner 		= dw_cond.Object.partner[1]
		ls_seq 			=  this.Object.seq_app[row]
		iu_cust_msg 	= Create u_cust_a_msg
		
		iu_cust_msg.is_pgm_name = "영수증 변경"
		iu_cust_msg.is_grp_name = "Receipt Reissue"
		iu_cust_msg.is_data[1]  = ls_customerid
		iu_cust_msg.is_data[2]  = ls_customernm
		iu_cust_msg.is_data[3]  = ls_partner				//
		iu_cust_msg.is_data[4]  = ls_seq                //receiptmst.app_seq
		iu_cust_msg.is_data[5]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	 
 		OpenWithParm(ssrt_reg_receipt_reissue_pop_new, iu_cust_msg)
		Destroy iu_cust_msg
	case "b_reprint"
		ls_seq 			=  this.Object.seq_app[row]
		//영 수증 재 발행 처리 -----
		wf_reprint(ls_seq)
	case else
end choose

end event

event dw_detail2::doubleclicked;call super::doubleclicked;IF row > 0 THEN
	
END IF
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within ssrt_reg_receipt_management
integer x = 37
integer y = 416
integer height = 36
end type

event st_horizontal2::mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition


end event

type st_horizontal from w_a_reg_m_m3`st_horizontal within ssrt_reg_receipt_management
boolean visible = false
integer x = 14
integer y = 1656
integer height = 48
end type

type dw_seq from datawindow within ssrt_reg_receipt_management
boolean visible = false
integer x = 2537
integer y = 304
integer width = 713
integer height = 48
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_seq_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_itemlist from datawindow within ssrt_reg_receipt_management
boolean visible = false
integer x = 2537
integer y = 364
integer width = 1317
integer height = 232
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_receiptmst_item_list"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type cb_issue from commandbutton within ssrt_reg_receipt_management
boolean visible = false
integer x = 2519
integer y = 184
integer width = 626
integer height = 112
integer taborder = 20
boolean bringtotop = true
integer textsize = -12
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Issue"
end type

event clicked;INTEGER		li_rtn
Long	ll_cnt, ll, ll_chk, jj,		ll_shopcount,	ll_seq, ll_list_cnt, &
			ll_paycnt,		ll_keynum,	kk
String 	ls_lin1, 		ls_lin2, 		ls_lin3
sTRING 	ls_partner, ls_empnm,		ls_appno
dec		ldc_shopCount
date		ldt_shop_closedt
String 	ls_itemcod, ls_itemnm, ls_val, ls_regcod, ls_facnum,	ls_memberid
dec{2}	ldc_payamt, ldc_paytotal

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ll_chk = 0
ll_cnt = dw_detail.RowCount()
FOR ll =  1 to ll_cnt
	IF dw_detail.Object.chk[ll] = '1' THEN
		ll_chk += 1
	END IF
NEXT

If ll_chk = 0 Then
	F_MSG_INFO(9000, title, "발행할 영수증을 선택 하세요")
	dw_detail.SetFocus()
	Return -1
End If
//=========================================================================
String 	ls_seq, ls_method[], ls_cdname[], ls_temp, ls_ref_desc
dec{2} 	ldc_amt[], ldc_total, ldc_cash, ldc_change, &
			ldc_cal1, ldc_cal2, ldc_cal3


FOR ll = 1 to 5
	ldc_amt[ll] = 0
NEXT

ldc_total 		= 0
ldc_cash 		= 0
ldc_change 		= 0
//==================================================
//PayMethod101, 102, 103, 104, 105
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
// PayMethod Name
FOR ll = 1 to 5
	SELECT codenm INTO :ls_cdname[ll] from syscod2t
	 WHERE grcode = 'B310' 
	   AND code   = :ls_method[ll] ;
NEXT
//=======================================================
// 발행번호 부여
Select seq_app.nextval		  Into :ls_seq  From dual;
IF sqlca.sqlcode < 0 THEN
	RollBack;
	f_msg_sql_err(title, SQLCA.SQLErrText+ " Sequence Error(SEQ_APP)")
	Return -1
END IF

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
ls_partner 			= dw_cond.Object.partner[1]
ldt_shop_closedt 	= f_find_shop_closedt(ls_partner)

li_rtn = f_pos_header(ls_partner,  'A', ll_shopcount, 0 )
IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			PRN_ClosePort()
			return -9
END IF
//=============================================================================
//total 계산
//=============================================================================
FOR ll =  1 to ll_cnt
	IF dw_detail.Object.chk[ll] = '1' THEN
		ls_appno =  dw_detail.Object.approvalno[ll]
 		select SUM(total), 		SUM(cash), 		SUM(change)
   	  INTO :ldc_cal1,			:ldc_cal2,		:ldc_cal3
		  FROM RECEIPTMST
		 WHERE APPROVALNO = :ls_appno ;
		IF sqlca.sqlcode < 0 THEN
			RollBack;
			f_msg_sql_err(title, SQLCA.SQLErrText + " Summary Error(RECEIPTMST)")
			Return -1
		END IF
		ldc_total 	+= ldc_cal1
		ldc_cash 	+= ldc_cal2
		ldc_change 	+= ldc_cal3
	END IF
NEXT

//=============================================================================
//Method total 계산
//=============================================================================
FOR ll =  1 to ll_cnt
	IF dw_detail.Object.chk[ll] = '1' THEN
		ls_appno =  dw_detail.Object.approvalno[ll]
		FOR jj =	1 to 5
 			select SUM(PAYAMT)
   		  INTO :ldc_cal1
			  FROM DAILYPAYMENT
			 WHERE APPROVALNO = :ls_appno 
			   AND paymethod  = :ls_method[jj] ;
			
			IF IsNull(ldc_cal1) or SQLCA.SQLCODE < 0  then ldc_cal1 = 0
			ldc_amt[jj]  += ldc_cal1
		NEXT
	END IF
NEXT

//---------------------------------------------------------------------------------
//item  별 List 출력
//---------------------------------------------------------------------------------
ll_seq 			= 0
ldc_paytotal 	= 0

FOR ll = 1 to ll_cnt
	ls_appno 	= dw_detail.Object.approvalno[ll]

	IF dw_detail.object.chk[ll] = '1' THEN

		ll_list_cnt = dw_itemlist.REtrieve(ls_appno)
		// receiptmst Update
		Update receiptmst
			Set seq_app 	= :ls_seq,
			    prt_yn 		= 'Y'
			Where approvalno = :ls_appno ;
	
		For jj = 1 To ll_list_cnt
			ll_seq 		+= 1
			ls_temp 		= String(ll_seq, '000') + ' ' //순번
			ls_itemcod 	= trim(dw_itemlist.Object.itemcod[jj])
			ls_itemNM 	= trim(dw_itemlist.Object.itemNM[jj])
			ldc_payamt	= dw_itemlist.object.payamt[jj]
			ll_paycnt 	= dw_itemlist.object.paycnt[jj]
			ls_temp 		+= LeftA(ls_itemnm + space(24), 24) + ' '   //아이템
			ls_temp 		+= RightA(Space(4) + String(ll_paycnt), 4) + ' ' //수량
			ls_val 		= fs_convert_amt(ldc_payamt,  8)
			ldc_paytotal	+= ldc_payamt
			ls_temp 		+= ls_val //금액
			f_printpos(ls_temp)	
		
			ls_regcod 	= trim(dw_itemlist.Object.regcod[jj])
			//regcode master read
			SELECT keynum, 		trim(facnum)	 INTO :ll_keynum,	:ls_facnum
		  	  FROM regcodmst
		 	 WHERE regcod = :ls_regcod ;
		
			IF IsNull(ll_keynum) 	then ll_keynum 	= 0
			IF IsNull(ls_facnum) 	then ls_facnum 	= ""
			ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
			f_printpos(ls_temp)
		NEXT
	END IF
NEXT
//======================================================================
//Item List 출력 --END
f_printpos(ls_lin1)
ls_val 	= fs_convert_sign(ldc_paytotal, 8)
ls_temp 	= LeftA("Grand Total" + space(32), 32) + ls_val
f_printpos(ls_temp)
f_printpos(ls_lin1)

//--------------------------------------------------------
//결제수단별 입금액
For kk = 1 To 5
	if ldc_amt[kk] > 0 then
		ls_val 	= fs_convert_sign(ldc_amt[kk],  8)
		ls_temp 	= LeftA(ls_cdname[kk] + space(33), 33) + ls_val
		f_printpos(ls_temp)
	END IF
NEXT
//거스름돈 처리
ls_val 	= fs_convert_sign(ldc_change,  8)
ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
f_printpos(ls_temp)
f_printpos(ls_lin1)

ls_memberid = dw_cond.Object.memberid[1]
F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id )

return 0
end event

