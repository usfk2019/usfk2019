﻿$PBExportHeader$b7u_dbmgr_2_mh.sru
$PBExportComments$[jybaek]
forward
global type b7u_dbmgr_2_mh from u_cust_a_db
end type
end forward

global type b7u_dbmgr_2_mh from u_cust_a_db
end type
global b7u_dbmgr_2_mh b7u_dbmgr_2_mh

type prototypes

end prototypes

type variables
HProgressBar  hpb_data[]

end variables

forward prototypes
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_02 ();
String	ls_null

//System Control Parameter
String	ls_ref_content, ls_ref_desc

//청구주기 컨트롤 일자 Setting
Long		ll_year, ll_mon, ll_last_day
String	ls_reqdt, ls_paydt, ls_trdt, ls_useddt, ls_usedt_fr, ls_usedt_to
Date		ld_trdt, ld_useddt

//지로 (통합/월별)청구서
Long		ll_rows, ll_currow, ll_selrows, ll_findrow
Long		ll_subcnt
String	ls_payid, ls_reqnum, ls_req_month, ls_editdt, ls_busyn, ls_giro_no
String	ls_ocr_left, ls_ocr_right, ls_markid, ls_subid
String	ls_subkind, ls_keysubid
Decimal{0} lc0_curbal, lc0_lastbal, lc0_totamt

//자동이체/카드 
Integer	li_count
String	ls_chargeby
Decimal{0} lc0_amt

//자동이체/카드 수정분 추가
String	ls_trdt_bf, ls_outdt, ls_bankbef, ls_accountbef, ls_ownerbef
String	ls_bank, ls_account, ls_bankcode, ls_banknm, ls_cardname
Decimal{0} lc0_outamt

String ls_validkey_min,ls_receipt_acctowner
int li_validkey_cnt, li_amt_row, li_amt_row2
DEC ldc_receipt_payamt, ldc_btramt[]
String ls_receipt_payid, ls_receipt_customernm, ls_receipt_acctno, ls_receipt_paydt, ls_receipt_banknm
String ls_btrdesc[], ls_desc[], ls_admin_tel,ls_amt[]
String ls_culumn_nm, ls_surtax, ls_pay_method, ls_customernm, ls_used_month
int li_column_cnt

Dec ldc_surtax, ldc_curbalance


SetNull(ls_null)

ii_rc = -1

Choose Case is_caller
	Case "b7w_prt_notice_used_list%ue_ok"
	//jybaek: 자동이체/카드 
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_caller = "b7w_prt_cms_notice%ue_ok"
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.idw_data[2] = dw_select2
	//lu_dbmgr.is_data2[6] = is_manager_tel
	
//		ls_busyn = is_data[1]
		ls_trdt = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_pay_method=is_data2[4]
		
//		ls_paydt  = is_data2[4]
//		ls_editdt = is_data2[5]
//		ls_admin_tel = is_data2[6]
//
		//납입자번호를 DW에서 선택해서 조회한 경우에만 처리한다.
		ll_selrows = idw_data[2].RowCount()
		
		ll_rows = idw_data[1].RowCount()
		For ll_curRow = 1 To ll_rows
//			ls_payid = Trim(idw_data[1].Object.reqinfo_payid[ll_curRow])
//			
//			SELECT customernm
//			  INTO :ls_customernm
//			  FROM  customerm
//			  WHERE customerid= :ls_payid;
//			If SQLCA.sqlcode < 0 Then
//				f_msg_sql_err(is_Title, "Select customerm")
//				Return
//			ElseIf SQLCA.SQLCode = 100 Then
//				Exit
//			End If	
//			idw_data[1].Object.customernm[ll_curRow]    = ls_customernm
//			ls_used_month= mid(ls_usedt_fr,1,4)+'-'+ mid(ls_usedt_fr,5,2)
//			idw_data[1].Object.sale_month[ll_curRow]    = ls_used_month   

		Next		
		

	Case Else
		f_msg_info_app(9000, "b7u_dbmgr_2.uf_prc_db_02()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")
		Return

End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_01 ();String	ls_null

//System Control Parameter
String	ls_ref_content, ls_ref_desc

//청구주기 컨트롤 일자 Setting
Long		ll_year, ll_mon, ll_last_day
String	ls_reqdt, ls_paydt, ls_trdt, ls_useddt, ls_usedt_fr, ls_usedt_to
Date		ld_trdt, ld_useddt

//지로 (통합/월별)청구서
Long		ll_rows, ll_currow, ll_selrows, ll_findrow
Long		ll_subcnt
String	ls_payid, ls_reqnum, ls_req_month, ls_editdt, ls_busyn, ls_giro_no
String	ls_ocr_left, ls_ocr_right, ls_markid, ls_subid
String	ls_subkind, ls_keysubid
Decimal{0} lc0_curbal, lc0_lastbal, lc0_totamt

//자동이체/카드 
Integer	li_count
String	ls_chargeby
Decimal{0} lc0_amt

//자동이체/카드 수정분 추가
String	ls_trdt_bf, ls_outdt, ls_bankbef, ls_accountbef, ls_ownerbef
String	ls_bank, ls_account, ls_bankcode, ls_banknm, ls_cardname
Decimal{0} lc0_outamt

String ls_validkey_min,ls_receipt_acctowner
int li_validkey_cnt, li_amt_row, li_amt_row2
DEC ldc_receipt_payamt, ldc_btramt[]
String ls_receipt_payid, ls_receipt_customernm, ls_receipt_acctno, ls_receipt_paydt, ls_receipt_banknm
String ls_btrdesc[], ls_desc[], ls_admin_tel,ls_amt[], ls_receipt_trdt
String ls_culumn_nm, ls_surtax
int li_column_cnt

Dec ldc_surtax, ldc_curbalance, ldc_pre_balance

String ls_addr1, ls_addr2, ls_zipcode, ls_msg_fromdt
String ls_msg1, ls_msg2, ls_msg3, ls_msg4, ls_msg5, ls_pay_method
int li_temp_cnt 

SetNull(ls_null)

ii_rc = -1

Choose Case is_caller
	Case "b7w_prt_cms_notice_mh%ue_ok"
	//jybaek: 자동이체/카드 
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_caller = "b7w_prt_cms_notice%ue_ok"
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.idw_data[2] = dw_select2
	//lu_dbmgr.is_data2[6] = is_manager_tel
	
		ls_trdt = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_paydt  = is_data2[4]
		ls_editdt = is_data2[5]
		ls_admin_tel = is_data2[6]
		ls_pay_method = is_data2[7]
		
	  SELECT to_char(max(fromdt),'yyyymmdd')
	  INTO :ls_msg_fromdt
	  FROM invoicemsg
	  WHERE pay_method=:ls_pay_method;
	  
	  If SQLCA.sqlcode < 0 Then
		  f_msg_sql_err(is_Title, "Select invoicemsg")
		  Return
	  End If	
	  
	  If ls_msg_fromdt = ls_trdt Then
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_trdt;
		Else
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_msg_fromdt;				
		End If

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select invoicemsg")
			Return
		ElseIf SQLCA.SQLCode = 100 Then 
			ls_msg1 = ""
			ls_msg2 = ""
			ls_msg3 = ""
			ls_msg4 = ""
			ls_msg5 = ""
		End If			


		//납입자번호를 DW에서 선택해서 조회한 경우에만 처리한다.
		ll_selrows = idw_data[2].RowCount()
		
		ll_rows = idw_data[1].RowCount()
		For ll_curRow = 1 To ll_rows
			li_temp_cnt = 0
			li_column_cnt =0
			
			ls_payid = Trim(idw_data[1].Object.reqinfo_payid[ll_curRow])
			idw_data[1].Object.issuedt[ll_curRow]			= ls_editdt  		//작성일
			//idw_data[1].Object.admin_tel[ll_curRow]   = ls_admin_tel
			idw_data[1].Object.usedt[ll_curRow] = ls_usedt_fr + '~~' + ls_usedt_to
			idw_data[1].Object.seqno[ll_curRow] = String(ll_curRow)
			
			idw_data[1].object.msg1[ll_curRow] = ls_msg1
			idw_data[1].object.msg2[ll_curRow] = ls_msg2
			idw_data[1].object.msg3[ll_curRow] = ls_msg3
			idw_data[1].object.msg4[ll_curRow] = ls_msg4			
			idw_data[1].object.msg5[ll_curRow] = ls_msg5						
			
			If IsNull(ls_msg1) or ls_msg1="" Then idw_data[1].Object.msg_tag1[ll_curRow]=""
			If IsNull(ls_msg2) or ls_msg2=""  Then idw_data[1].Object.msg_tag2[ll_curRow]=""
			If IsNull(ls_msg3) or ls_msg3=""  Then idw_data[1].Object.msg_tag3[ll_curRow]=""
			If IsNull(ls_msg4) or ls_msg4=""  Then idw_data[1].Object.msg_tag4[ll_curRow]=""
			If IsNull(ls_msg5) or ls_msg5=""  Then idw_data[1].Object.msg_tag5[ll_curRow]=""			
				
         ls_btrdesc[1]=idw_data[1].Object.btrdesc01[ll_curRow]
         ls_btrdesc[2]=idw_data[1].Object.btrdesc02[ll_curRow]
         ls_btrdesc[3]=idw_data[1].Object.btrdesc03[ll_curRow]
         ls_btrdesc[4]=idw_data[1].Object.btrdesc04[ll_curRow]
         ls_btrdesc[5]=idw_data[1].Object.btrdesc05[ll_curRow]
         ls_btrdesc[6]=idw_data[1].Object.btrdesc06[ll_curRow]
         ls_btrdesc[7]=idw_data[1].Object.btrdesc07[ll_curRow]
         ls_btrdesc[8]=idw_data[1].Object.btrdesc08[ll_curRow]
         ls_btrdesc[9]=idw_data[1].Object.btrdesc09[ll_curRow]
         ls_btrdesc[10]=idw_data[1].Object.btrdesc10[ll_curRow]
         ls_btrdesc[11]=idw_data[1].Object.btrdesc11[ll_curRow]
         ls_btrdesc[12]=idw_data[1].Object.btrdesc12[ll_curRow]
         ls_btrdesc[13]=idw_data[1].Object.btrdesc13[ll_curRow]
         ls_btrdesc[14]=idw_data[1].Object.btrdesc14[ll_curRow]
         ls_btrdesc[15]=idw_data[1].Object.btrdesc15[ll_curRow]
         ls_btrdesc[16]=idw_data[1].Object.btrdesc16[ll_curRow]
         ls_btrdesc[17]=idw_data[1].Object.btrdesc17[ll_curRow]			
         ls_btrdesc[18]=idw_data[1].Object.btrdesc18[ll_curRow]
         ls_btrdesc[19]=idw_data[1].Object.btrdesc19[ll_curRow]
         ls_btrdesc[20]=idw_data[1].Object.btrdesc20[ll_curRow]
			
         ldc_btramt[1]=idw_data[1].Object.btramt01[ll_curRow]
         ldc_btramt[2]=idw_data[1].Object.btramt02[ll_curRow]
         ldc_btramt[3]=idw_data[1].Object.btramt03[ll_curRow]
         ldc_btramt[4]=idw_data[1].Object.btramt04[ll_curRow]
         ldc_btramt[5]=idw_data[1].Object.btramt05[ll_curRow]
         ldc_btramt[6]=idw_data[1].Object.btramt06[ll_curRow]
         ldc_btramt[7]=idw_data[1].Object.btramt07[ll_curRow]
         ldc_btramt[8]=idw_data[1].Object.btramt08[ll_curRow]
         ldc_btramt[9]=idw_data[1].Object.btramt09[ll_curRow]
         ldc_btramt[10]=idw_data[1].Object.btramt10[ll_curRow]
         ldc_btramt[11]=idw_data[1].Object.btramt11[ll_curRow]
         ldc_btramt[12]=idw_data[1].Object.btramt12[ll_curRow]
         ldc_btramt[13]=idw_data[1].Object.btramt13[ll_curRow]
         ldc_btramt[14]=idw_data[1].Object.btramt14[ll_curRow]
         ldc_btramt[15]=idw_data[1].Object.btramt15[ll_curRow]
         ldc_btramt[16]=idw_data[1].Object.btramt16[ll_curRow]
         ldc_btramt[17]=idw_data[1].Object.btramt17[ll_curRow]			
         ldc_btramt[18]=idw_data[1].Object.btramt18[ll_curRow]			
         ldc_btramt[19]=idw_data[1].Object.btramt19[ll_curRow]
         ldc_btramt[20]=idw_data[1].Object.btramt20[ll_curRow]			
				
			ldc_surtax = idw_data[1].object.surtax[ll_curRow]
			ldc_curbalance= idw_data[1].object.cur_balance[ll_curRow]
			ldc_pre_balance = idw_data[1].object.pre_balance[ll_curRow]
						
			SELECT min(validkey), Nvl(count(validkey),0)	
			  INTO :ls_validkey_min, :li_validkey_cnt
			  FROM validinfo
			 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
				 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
					to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
				AND status <> '10' 
				AND svctype = '1'
				AND customerid =:ls_payid;

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select validinfo")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If				
			
			idw_data[1].Object.validkey[ll_curRow] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 

			//자동이체전월영수금액					
	
		     SELECT  cus.customernm, a.total_amt, a.payid, infoh.acct_owner,
				       substr(a.acct_no, 1, 5)||rpad(nvl(null, '*'), length(substr(a.acct_no, 6, 15)), '*'),
						 to_char(a.paydt,'yyyy-mm-dd'),
						 bank.codenm, to_char(add_months(a.trdt,-1),'yyyymmdd')
				 INTO   :ls_receipt_customernm,
						  :ldc_receipt_payamt, 
						  :ls_receipt_payid,
						  :ls_receipt_acctowner,
						  :ls_receipt_acctno,
						  :ls_receipt_paydt,
						  :ls_receipt_banknm,
						  :ls_receipt_trdt
 			    FROM 	
  			   (SELECT  payid, sum(nvl(receipt.payamt,0)) total_amt, trdt, max(paydt) paydt, acct_no, acct_type
				   FROM  reqreceipt receipt 
				  WHERE  to_char(receipt.trdt,'yyyymmdd') = :ls_trdt
			     GROUP BY  payid,trdt, acct_no, acct_type) a, customerm cus, reqinfoh infoh,
    		  (SELECT code,codenm from syscod2t where grcode='B400' and use_yn='Y') bank
	     		WHERE   a.payid = :ls_payid
				  AND   to_char(a.trdt,'yyyymmdd') = :ls_trdt
				  AND   a.payid = cus.customerid
				  And   a.payid = infoh.payid
				  and   to_char(infoh.trdt,'yyyymmdd') =add_months(to_date(:ls_trdt,'yyyymmdd'),-1)
				  AND   a.acct_type = bank.code(+)
				  AND   a.payid(+) = infoh.payid;
				  
			  
			  
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select receipt")
				Return
			ElseIf SQLCA.SQLCode = 100 Then 
				idw_data[1].Object.receipt_payamt[ll_curRow] = ""
				idw_data[1].Object.receipt_payid[ll_curRow] = ""
				idw_data[1].Object.receipt_acct_owner[ll_curRow] = ""
				idw_data[1].Object.receipt_bank[ll_curRow] = ""
				idw_data[1].Object.receipt_paydt[ll_curRow] = ""
				idw_data[1].Object.receipt_acct_no[ll_curRow] = ""
				idw_data[1].Object.receipt_customernm[ll_curRow] = ""
				idw_data[1].Object.receipt_trdtyyyy[ll_curRow] = ""
				idw_data[1].Object.receipt_trdtmm[ll_curRow] = ""
				idw_data[1].Object.receipt_usedt[ll_curRow] = ""
			End If	
			
			If ldc_receipt_payamt > 0 Then
				idw_data[1].Object.receipt_payamt[ll_curRow] = String(ldc_receipt_payamt,'#,##0')
			End If
			idw_data[1].Object.receipt_payid[ll_curRow] = ls_receipt_payid
			idw_data[1].Object.receipt_acct_owner[ll_curRow] = ls_receipt_acctowner
			idw_data[1].Object.receipt_bank[ll_curRow] = ls_receipt_banknm	
			idw_data[1].Object.receipt_paydt[ll_curRow] = ls_receipt_paydt
			idw_data[1].Object.receipt_acct_no[ll_curRow] = ls_receipt_acctno
			idw_data[1].Object.receipt_customernm[ll_curRow] = ls_receipt_customernm
			idw_data[1].Object.receipt_trdtyyyy[ll_curRow] = MidA(ls_receipt_trdt,1,4)
			idw_data[1].Object.receipt_trdtmm[ll_curRow] = MidA(ls_receipt_trdt,5,2)
			idw_data[1].Object.receipt_usedt[ll_curRow] = MidA(ls_receipt_trdt,1,4) + '년 ' + MidA(ls_receipt_trdt,5,2) + '월' 

			FOR li_amt_row =1 TO 15 STEP 1				
				ls_desc[li_amt_row] = ""	
				ls_amt[li_amt_row] = ""
			Next
			
		   li_amt_row2 = 1
			FOR li_amt_row =1 TO 20 STEP 1
				IF (ldc_btramt[li_amt_row] > 0 or ldc_btramt[li_amt_row] < 0) THEN
					 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
					 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
	 				 li_amt_row2 +=1								
				End If
			NEXT
			
			FOR li_amt_row = 1 TO 15 STEP 1
				If Trim(ls_desc[li_amt_row])="" Then
					li_column_cnt = li_amt_row
					li_amt_row=15
				End If
			Next		
			
			li_temp_cnt = li_column_cnt -1
						
			If li_temp_cnt > 0 Then
				If Trim(ls_desc[li_temp_cnt]) = "원단위절사" Then
					ls_desc[li_column_cnt] ="당월요금계"
					If ldc_pre_balance > 0 or ldc_pre_balance < 0 Then						
						ls_desc[li_column_cnt+1] ="전월미납액"
						ls_amt[li_column_cnt+1] = String(ldc_pre_balance,"#,##0")							
					End if
					ls_amt[li_column_cnt] =""
					ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")					
						
				Else
					ls_desc[li_column_cnt] ="원단위절사"
					ls_desc[li_column_cnt+1] ="당월요금계"
					If ldc_pre_balance >0 or ldc_pre_balance < 0 Then						
						ls_desc[li_column_cnt+2] ="전월미납액"
						ls_amt[li_column_cnt+2] = String(ldc_pre_balance,"#,##0")														
					End If
					ls_amt[li_column_cnt]="0"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")			
	
				End If
			Else
					ls_desc[li_column_cnt] = "전월미납액"				
					ls_amt[li_column_cnt] = String(ldc_pre_balance,"#,##0")	
			End If
				
			
			idw_data[1].Object.DESC1[ll_curRow] = ls_desc[1]
			idw_data[1].Object.DESC2[ll_curRow] = ls_desc[2]
			idw_data[1].Object.DESC3[ll_curRow] = ls_desc[3]
			idw_data[1].Object.DESC4[ll_curRow] = ls_desc[4]
			idw_data[1].Object.DESC5[ll_curRow] = ls_desc[5]
			idw_data[1].Object.DESC6[ll_curRow] = ls_desc[6]
			idw_data[1].Object.desc7[ll_curRow] = ls_desc[7]
			idw_data[1].Object.desc8[ll_curRow] = ls_desc[8]
			idw_data[1].Object.desc9[ll_curRow] = ls_desc[9]
			idw_data[1].Object.desc10[ll_curRow] = ls_desc[10]			
			idw_data[1].Object.desc11[ll_curRow] = ls_desc[11]
			idw_data[1].Object.desc12[ll_curRow] = ls_desc[12]
			idw_data[1].Object.desc13[ll_curRow] = ls_desc[13]
			idw_data[1].Object.desc14[ll_curRow] = ls_desc[14]
			idw_data[1].Object.desc15[ll_curRow] = ls_desc[15]		

		   idw_data[1].Object.AMT1[ll_curRow] = ls_amt[1]
			idw_data[1].Object.AMT2[ll_curRow] = ls_amt[2]
			idw_data[1].Object.AMT3[ll_curRow] = ls_amt[3]
			idw_data[1].Object.AMT4[ll_curRow] = ls_amt[4]
			idw_data[1].Object.AMT5[ll_curRow] = ls_amt[5]
			idw_data[1].Object.AMT6[ll_curRow] = ls_amt[6]
			idw_data[1].Object.AMT7[ll_curRow] = ls_amt[7]
			idw_data[1].Object.AMT8[ll_curRow] = ls_amt[8]
			idw_data[1].Object.AMT9[ll_curRow] = ls_amt[9]
			idw_data[1].Object.AMT10[ll_curRow] = ls_amt[10]			
			idw_data[1].Object.AMT11[ll_curRow] = ls_amt[11]
			idw_data[1].Object.AMT12[ll_curRow] = ls_amt[12]
			idw_data[1].Object.AMT13[ll_curRow] = ls_amt[13]
			idw_data[1].Object.AMT14[ll_curRow] = ls_amt[14]
			idw_data[1].Object.AMT15[ll_curRow] = ls_amt[15]					

			ls_receipt_customernm = ""
			ldc_receipt_payamt= 0
			ls_receipt_payid=""
			ls_receipt_acctowner=""
			ls_receipt_acctno=""
			ls_receipt_paydt=""
			ls_receipt_banknm=""

		Next		
		
		
	Case "b7w_prt_kt_notice_v%ue_ok"
	//jybaek: 자동이체/카드 
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_caller = "b7w_prt_cms_notice%ue_ok"
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.idw_data[2] = dw_select2

	
//		ls_busyn = is_data[1]
		ls_trdt = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_paydt  = is_data2[4]
		ls_editdt = is_data2[5]


		//납입자번호를 DW에서 선택해서 조회한 경우에만 처리한다.
		ll_selrows = idw_data[2].RowCount()
		
		ll_rows = idw_data[1].RowCount()

		For ll_curRow = 1 To ll_rows
			
			ls_payid = Trim(idw_data[1].Object.reqinfo_payid[ll_curRow])
						
			idw_data[1].object.issuedt[ll_curRow]	= ls_editdt  		//작성일
			idw_data[1].object.seqno[ll_curRow] = String(ll_curRow)
			
			ls_addr1 = Trim(idw_data[1].object.bil_addr1[ll_curRow])
			ls_addr2 = Trim(idw_data[1].object.bil_addr2[ll_curRow])
			ls_zipcode = Trim(idw_data[1].object.zipcode[ll_curRow])			
			
			If IsNull(ls_addr1) Then ls_addr1=""
			If IsNull(ls_addr2) Then ls_addr2=""
			If IsNull(ls_zipcode) Then ls_zipcode=""			
			
			If ls_addr1="" Then
				idw_data[1].object.bil_addr1[ll_curRow] = "실사용자의 고객정보를 확인하여 변경해 주세요..."
				idw_data[1].object.zipcode[ll_curRow] ="111-111"
			End If
				
         ls_btrdesc[1]=idw_data[1].Object.btrdesc01[ll_curRow]
         ls_btrdesc[2]=idw_data[1].Object.btrdesc02[ll_curRow]
         ls_btrdesc[3]=idw_data[1].Object.btrdesc03[ll_curRow]
         ls_btrdesc[4]=idw_data[1].Object.btrdesc04[ll_curRow]
         ls_btrdesc[5]=idw_data[1].Object.btrdesc05[ll_curRow]
         ls_btrdesc[6]=idw_data[1].Object.btrdesc06[ll_curRow]
         ls_btrdesc[7]=idw_data[1].Object.btrdesc07[ll_curRow]
         ls_btrdesc[8]=idw_data[1].Object.btrdesc08[ll_curRow]
         ls_btrdesc[9]=idw_data[1].Object.btrdesc09[ll_curRow]
         ls_btrdesc[10]=idw_data[1].Object.btrdesc10[ll_curRow]
         ls_btrdesc[11]=idw_data[1].Object.btrdesc11[ll_curRow]
         ls_btrdesc[12]=idw_data[1].Object.btrdesc12[ll_curRow]
         ls_btrdesc[13]=idw_data[1].Object.btrdesc13[ll_curRow]
         ls_btrdesc[14]=idw_data[1].Object.btrdesc14[ll_curRow]
         ls_btrdesc[15]=idw_data[1].Object.btrdesc15[ll_curRow]
         ls_btrdesc[16]=idw_data[1].Object.btrdesc16[ll_curRow]
         ls_btrdesc[17]=idw_data[1].Object.btrdesc17[ll_curRow]			
         ls_btrdesc[18]=idw_data[1].Object.btrdesc18[ll_curRow]
         ls_btrdesc[19]=idw_data[1].Object.btrdesc19[ll_curRow]
         ls_btrdesc[20]=idw_data[1].Object.btrdesc20[ll_curRow]
			
         ldc_btramt[1]=idw_data[1].Object.btramt01[ll_curRow]
         ldc_btramt[2]=idw_data[1].Object.btramt02[ll_curRow]
         ldc_btramt[3]=idw_data[1].Object.btramt03[ll_curRow]
         ldc_btramt[4]=idw_data[1].Object.btramt04[ll_curRow]
         ldc_btramt[5]=idw_data[1].Object.btramt05[ll_curRow]
         ldc_btramt[6]=idw_data[1].Object.btramt06[ll_curRow]
         ldc_btramt[7]=idw_data[1].Object.btramt07[ll_curRow]
         ldc_btramt[8]=idw_data[1].Object.btramt08[ll_curRow]
         ldc_btramt[9]=idw_data[1].Object.btramt09[ll_curRow]
         ldc_btramt[10]=idw_data[1].Object.btramt10[ll_curRow]
         ldc_btramt[11]=idw_data[1].Object.btramt11[ll_curRow]
         ldc_btramt[12]=idw_data[1].Object.btramt12[ll_curRow]
         ldc_btramt[13]=idw_data[1].Object.btramt13[ll_curRow]
         ldc_btramt[14]=idw_data[1].Object.btramt14[ll_curRow]
         ldc_btramt[15]=idw_data[1].Object.btramt15[ll_curRow]
         ldc_btramt[16]=idw_data[1].Object.btramt16[ll_curRow]
         ldc_btramt[17]=idw_data[1].Object.btramt17[ll_curRow]			
         ldc_btramt[18]=idw_data[1].Object.btramt18[ll_curRow]			
         ldc_btramt[19]=idw_data[1].Object.btramt19[ll_curRow]
         ldc_btramt[20]=idw_data[1].Object.btramt20[ll_curRow]			
				
			ldc_surtax = idw_data[1].object.surtax[ll_curRow]
			ldc_curbalance= idw_data[1].object.cur_balance[ll_curRow]
			
			SELECT min(validkey), Nvl(count(validkey),0)	
			  INTO :ls_validkey_min, :li_validkey_cnt
			  FROM validinfo
			 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
				 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
					to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
				AND status <> '10' 
				AND svctype = '1'
				AND customerid =:ls_payid;

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select validinfo")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If				
			
			idw_data[1].Object.validkey[ll_curRow] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 


			FOR li_amt_row =1 TO 15 STEP 1				
				ls_desc[li_amt_row] = ""	
				ls_amt[li_amt_row] = ""
			Next
			
		   li_amt_row2 = 1
			FOR li_amt_row =1 TO 20 STEP 1
				IF (ldc_btramt[li_amt_row] > 0 or ldc_btramt[li_amt_row] < 0) THEN
					 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
					 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
	 				 li_amt_row2 +=1								
				End If
			NEXT
			
			FOR li_amt_row = 1 TO 15 STEP 1
				If Trim(ls_desc[li_amt_row])="" Then
					li_column_cnt = li_amt_row
					li_amt_row=15
				End If
			Next		
			
			li_temp_cnt = li_column_cnt -1										
					
			If li_temp_cnt > 0 Then
				If Trim(ls_desc[li_temp_cnt]) = "원단위절사" Then
					ls_desc[li_column_cnt] ="당월요금계"
					ls_amt[li_column_cnt] =""
					ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")	
					If ldc_pre_balance > 0 or ldc_pre_balance < 0 Then						
						ls_desc[li_column_cnt+1] ="전월미납액"
						ls_amt[li_column_cnt+1] = String(ldc_pre_balance,"#,##0")	
						ls_desc[li_column_cnt+2] ="청 구 요 금"
						ls_amt[li_column_cnt+2] = String(ldc_curbalance+ldc_pre_balance,"#,##0")						
					End if
					ls_desc[li_column_cnt+1] ="청 구 요 금"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance+ldc_pre_balance,"#,##0")
						
				Else
					ls_desc[li_column_cnt] ="원단위절사"
					ls_desc[li_column_cnt+1] ="당월요금계"
					ls_amt[li_column_cnt]="0"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")								
					If ldc_pre_balance >0 or ldc_pre_balance < 0 Then						
						ls_desc[li_column_cnt+2] ="전월미납액"
						ls_amt[li_column_cnt+2] = String(ldc_pre_balance,"#,##0")
						ls_desc[li_column_cnt+3] ="청 구 요 금"
						ls_amt[li_column_cnt+3] = String(ldc_curbalance+ldc_pre_balance,"#,##0")						
					Else 
						ls_desc[li_column_cnt+2]="청 구 요 금"
						ls_amt[li_column_cnt+2] = String(ldc_curbalance+ldc_pre_balance,"#,##0")
					End If			
			
				End If
			Else
					ls_desc[li_column_cnt] = "전월미납액"				
					ls_amt[li_column_cnt] = String(ldc_pre_balance,"#,##0")	
					ls_desc[li_column_cnt+1]="청 구 요 금"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance+ldc_pre_balance,"#,##0")
					
			End If

			idw_data[1].Object.DESC1[ll_curRow] = ls_desc[1]
			idw_data[1].Object.DESC2[ll_curRow] = ls_desc[2]
			idw_data[1].Object.DESC3[ll_curRow] = ls_desc[3]
			idw_data[1].Object.DESC4[ll_curRow] = ls_desc[4]
			idw_data[1].Object.DESC5[ll_curRow] = ls_desc[5]
			idw_data[1].Object.DESC6[ll_curRow] = ls_desc[6]
			idw_data[1].Object.desc7[ll_curRow] = ls_desc[7]
			idw_data[1].Object.desc8[ll_curRow] = ls_desc[8]
			idw_data[1].Object.desc9[ll_curRow] = ls_desc[9]
			idw_data[1].Object.desc10[ll_curRow] = ls_desc[10]			
			idw_data[1].Object.desc11[ll_curRow] = ls_desc[11]
			idw_data[1].Object.desc12[ll_curRow] = ls_desc[12]
			idw_data[1].Object.desc13[ll_curRow] = ls_desc[13]
			idw_data[1].Object.desc14[ll_curRow] = ls_desc[14]
			idw_data[1].Object.desc15[ll_curRow] = ls_desc[15]		

		   idw_data[1].Object.AMT1[ll_curRow] = ls_amt[1]
			idw_data[1].Object.AMT2[ll_curRow] = ls_amt[2]
			idw_data[1].Object.AMT3[ll_curRow] = ls_amt[3]
			idw_data[1].Object.AMT4[ll_curRow] = ls_amt[4]
			idw_data[1].Object.AMT5[ll_curRow] = ls_amt[5]
			idw_data[1].Object.AMT6[ll_curRow] = ls_amt[6]
			idw_data[1].Object.AMT7[ll_curRow] = ls_amt[7]
			idw_data[1].Object.AMT8[ll_curRow] = ls_amt[8]
			idw_data[1].Object.AMT9[ll_curRow] = ls_amt[9]
			idw_data[1].Object.AMT10[ll_curRow] = ls_amt[10]			
			idw_data[1].Object.AMT11[ll_curRow] = ls_amt[11]
			idw_data[1].Object.AMT12[ll_curRow] = ls_amt[12]
			idw_data[1].Object.AMT13[ll_curRow] = ls_amt[13]
			idw_data[1].Object.AMT14[ll_curRow] = ls_amt[14]
			idw_data[1].Object.AMT15[ll_curRow] = ls_amt[15]	

			If ls_desc[1] = "" or IsNull(ls_desc[1]) Then
				idw_data[1].Object.desc_t1[ll_curRow]=""
			End If
			If ls_desc[2] = "" or IsNull(ls_desc[2]) Then
				idw_data[1].Object.desc_t2[ll_curRow]=""
			End If
			If ls_desc[3] = "" or IsNull(ls_desc[3]) Then
				idw_data[1].Object.desc_t3[ll_curRow]=""
			End If
			If ls_desc[4] = "" or IsNull(ls_desc[4]) Then
				idw_data[1].Object.desc_t4[ll_curRow]=""
			End If
			If ls_desc[5] = "" or IsNull(ls_desc[5]) Then
				idw_data[1].Object.desc_t5[ll_curRow]=""
			End If
			If ls_desc[6] = "" or IsNull(ls_desc[6]) Then
				idw_data[1].Object.desc_t6[ll_curRow]=""
			End If
			If ls_desc[7] = "" or IsNull(ls_desc[7]) Then
				idw_data[1].Object.desc_t7[ll_curRow]=""
			End If
			If ls_desc[8] = "" or IsNull(ls_desc[8]) Then
				idw_data[1].Object.desc_t8[ll_curRow]=""
			End If
			If ls_desc[9] = "" or IsNull(ls_desc[9]) Then
				idw_data[1].Object.desc_t9[ll_curRow]=""
			End If
			If ls_desc[10] = "" or IsNull(ls_desc[10]) Then
				idw_data[1].Object.desc_t10[ll_curRow]=""
			End If
			If ls_desc[11] = "" or IsNull(ls_desc[11]) Then
				idw_data[1].Object.desc_t11[ll_curRow]=""
			End If
			If ls_desc[12] = "" or IsNull(ls_desc[12]) Then
				idw_data[1].Object.desc_t12[ll_curRow]=""
			End If
			If ls_desc[13] = "" or IsNull(ls_desc[13]) Then
				idw_data[1].Object.desc_t13[ll_curRow]=""
			End If
			If ls_desc[14] = "" or IsNull(ls_desc[14]) Then
				idw_data[1].Object.desc_t14[ll_curRow]=""
			End If
			If ls_desc[15] = "" or IsNull(ls_desc[15]) Then
				idw_data[1].Object.desc_t15[ll_curRow]=""
			End If			
					
		Next				
			
	Case Else
		f_msg_info_app(9000, "b7u_dbmgr_2.uf_prc_db_01()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")
		Return

End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_03 ();/**********************************************************
 * 2005.12.01 kem
 * 1)"b7w_prt_giro_notice_mh%ue_ok"
    : 무한넷코리아 지로 출력 
 * 2)"b7w_prt_giro_notice_v_modify%ue_ok" 
    : 브이텔레콤 지로 납부 고객중 주소 수정
 *********************************************************/
String	ls_null

//System Control Parameter
String	ls_ref_content, ls_ref_desc

//청구주기 컨트롤 일자 Setting
Long		ll_year, ll_mon, ll_last_day
String	ls_reqdt, ls_paydt, ls_trdt, ls_useddt, ls_usedt_fr, ls_usedt_to
Date		ld_trdt, ld_useddt

//지로 (통합/월별)청구서
Long		ll_rows, ll_currow, ll_selrows, ll_findrow
Long		ll_subcnt
String	ls_payid, ls_reqnum, ls_req_month, ls_editdt, ls_busyn, ls_giro_no
String	ls_ocr_left, ls_ocr_right, ls_markid, ls_subid
String	ls_subkind, ls_keysubid
Decimal{0} lc0_curbal, lc0_lastbal, lc0_totamt

//자동이체/카드 
Integer	li_count
String	ls_chargeby
Decimal{0} lc0_amt

//자동이체/카드 수정분 추가
String	ls_trdt_bf, ls_outdt, ls_bankbef, ls_accountbef, ls_ownerbef
String	ls_bank, ls_account, ls_bankcode, ls_banknm, ls_cardname
Decimal{0} lc0_outamt

String ls_validkey_min,ls_receipt_acctowner
int li_validkey_cnt, li_amt_row, li_amt_row2
DEC ldc_receipt_payamt, ldc_btramt[]
String ls_receipt_payid, ls_receipt_customernm, ls_receipt_acctno, ls_receipt_paydt, ls_receipt_banknm
String ls_btrdesc[], ls_desc[], ls_admin_tel,ls_amt[]
String ls_culumn_nm, ls_surtax
int li_column_cnt

Dec{0} ldc_surtax, ldc_curbalance, ldc_prebalance

String ls_addr1, ls_addr2, ls_zipcode
String ls_customernm_m

//giro
String ls_giro_customer_no_left, ls_giro_customer_no_right
String ls_delay_start_trdt
String ls_msg1, ls_msg2, ls_msg3, ls_msg4, ls_msg5, ls_pay_method, ls_msg_fromdt
int li_delay_cnt,li_temp_cnt

SetNull(ls_null)

ii_rc = -1

Choose Case is_caller
	Case "b7w_prt_giro_notice_mh%ue_ok"
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.idw_data[2] = dw_select2

	
		ls_trdt = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_paydt  = is_data2[4]
		ls_editdt = is_data2[5]
		ls_pay_method = is_data2[6]


		//납입자번호를 DW에서 선택해서 조회한 경우에만 처리한다.
		ll_selrows = idw_data[2].RowCount()		
		ll_rows = idw_data[1].RowCount()
		//Message Box check =======================================================>
		SELECT to_char(max(fromdt),'yyyymmdd')
		INTO :ls_msg_fromdt
		FROM invoicemsg
		WHERe pay_method = :ls_pay_method;
		
		If SQLCA.sqlcode < 0 Then
		  f_msg_sql_err(is_Title, "Select invoicemsg")
		  Return
		End If	
		
		If ls_msg_fromdt = ls_trdt Then
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_trdt;
		Else
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_msg_fromdt;				
		End If
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select invoicemsg")
			Return
		ElseIf SQLCA.SQLCode = 100 Then 
			ls_msg1 = ""
			ls_msg2 = ""
			ls_msg3 = ""
			ls_msg4 = ""
			ls_msg5 = ""
		End If					
		//Message Box check END====================================================>		
		For ll_curRow = 1 To ll_rows
			ls_payid = Trim(idw_data[1].Object.reqinfo_payid[ll_curRow])

			idw_data[1].Object.issuedt[ll_curRow] = MidA(ls_editdt,1,4) + '   ' + MidA(ls_editdt,6,2) + '   ' + MidA(ls_editdt,9,2)  		//작성일
			idw_data[1].Object.useddt_fr[ll_curRow] = MidA(ls_usedt_fr,1,4) + '   ' + MidA(ls_usedt_fr,5,2) + '   ' + MidA(ls_usedt_fr,7,2)
			idw_data[1].Object.useddt_to[ll_curRow] = MidA(ls_usedt_to,1,4) + '   ' + MidA(ls_usedt_to,5,2) + '   ' + MidA(ls_usedt_to,7,2)
			idw_data[1].Object.useddt_fr_1[ll_curRow] = MidA(ls_usedt_fr,1,4) + '   ' + MidA(ls_usedt_fr,5,2) + '   ' + MidA(ls_usedt_fr,7,2)
			idw_data[1].Object.useddt_to_1[ll_curRow] = MidA(ls_usedt_to,1,4) + '   ' + MidA(ls_usedt_to,5,2) + '   ' + MidA(ls_usedt_to,7,2)


			idw_data[1].object.msg1[ll_curRow] = ls_msg1
			idw_data[1].object.msg2[ll_curRow] = ls_msg2
			idw_data[1].object.msg3[ll_curRow] = ls_msg3
			idw_data[1].object.msg4[ll_curRow] = ls_msg4			
			idw_data[1].object.msg5[ll_curRow] = ls_msg5									
				
         ls_btrdesc[1]=idw_data[1].Object.btrdesc01[ll_curRow]
         ls_btrdesc[2]=idw_data[1].Object.btrdesc02[ll_curRow]
         ls_btrdesc[3]=idw_data[1].Object.btrdesc03[ll_curRow]
         ls_btrdesc[4]=idw_data[1].Object.btrdesc04[ll_curRow]
         ls_btrdesc[5]=idw_data[1].Object.btrdesc05[ll_curRow]
         ls_btrdesc[6]=idw_data[1].Object.btrdesc06[ll_curRow]
         ls_btrdesc[7]=idw_data[1].Object.btrdesc07[ll_curRow]
         ls_btrdesc[8]=idw_data[1].Object.btrdesc08[ll_curRow]
         ls_btrdesc[9]=idw_data[1].Object.btrdesc09[ll_curRow]
         ls_btrdesc[10]=idw_data[1].Object.btrdesc10[ll_curRow]
         ls_btrdesc[11]=idw_data[1].Object.btrdesc11[ll_curRow]
         ls_btrdesc[12]=idw_data[1].Object.btrdesc12[ll_curRow]
         ls_btrdesc[13]=idw_data[1].Object.btrdesc13[ll_curRow]
         ls_btrdesc[14]=idw_data[1].Object.btrdesc14[ll_curRow]
         ls_btrdesc[15]=idw_data[1].Object.btrdesc15[ll_curRow]
         ls_btrdesc[16]=idw_data[1].Object.btrdesc16[ll_curRow]
         ls_btrdesc[17]=idw_data[1].Object.btrdesc17[ll_curRow]			
         ls_btrdesc[18]=idw_data[1].Object.btrdesc18[ll_curRow]
         ls_btrdesc[19]=idw_data[1].Object.btrdesc19[ll_curRow]
         ls_btrdesc[20]=idw_data[1].Object.btrdesc20[ll_curRow]
			
         ldc_btramt[1]=idw_data[1].Object.btramt01[ll_curRow]
         ldc_btramt[2]=idw_data[1].Object.btramt02[ll_curRow]
         ldc_btramt[3]=idw_data[1].Object.btramt03[ll_curRow]
         ldc_btramt[4]=idw_data[1].Object.btramt04[ll_curRow]
         ldc_btramt[5]=idw_data[1].Object.btramt05[ll_curRow]
         ldc_btramt[6]=idw_data[1].Object.btramt06[ll_curRow]
         ldc_btramt[7]=idw_data[1].Object.btramt07[ll_curRow]
         ldc_btramt[8]=idw_data[1].Object.btramt08[ll_curRow]
         ldc_btramt[9]=idw_data[1].Object.btramt09[ll_curRow]
         ldc_btramt[10]=idw_data[1].Object.btramt10[ll_curRow]
         ldc_btramt[11]=idw_data[1].Object.btramt11[ll_curRow]
         ldc_btramt[12]=idw_data[1].Object.btramt12[ll_curRow]
         ldc_btramt[13]=idw_data[1].Object.btramt13[ll_curRow]
         ldc_btramt[14]=idw_data[1].Object.btramt14[ll_curRow]
         ldc_btramt[15]=idw_data[1].Object.btramt15[ll_curRow]
         ldc_btramt[16]=idw_data[1].Object.btramt16[ll_curRow]
         ldc_btramt[17]=idw_data[1].Object.btramt17[ll_curRow]			
         ldc_btramt[18]=idw_data[1].Object.btramt18[ll_curRow]			
         ldc_btramt[19]=idw_data[1].Object.btramt19[ll_curRow]
         ldc_btramt[20]=idw_data[1].Object.btramt20[ll_curRow]			
				
			ldc_surtax = idw_data[1].object.surtax[ll_curRow]
			ldc_curbalance= idw_data[1].object.cur_balance[ll_curRow]
			ldc_prebalance= idw_data[1].object.pre_balance[ll_curRow]
			
			SELECT min(validkey), Nvl(count(validkey),0)	
			  INTO :ls_validkey_min, :li_validkey_cnt
			  FROM validinfo
			 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
				 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
					to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
				AND status <> '10' 
				AND svctype = '1'
				AND customerid =:ls_payid;

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select validinfo")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If				
			
			idw_data[1].Object.validkey[ll_curRow] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 


			FOR li_amt_row =1 TO 20 STEP 1				
				ls_desc[li_amt_row] = ""	
				ls_amt[li_amt_row] = ""
			Next
			
		   li_amt_row2 = 1
			FOR li_amt_row =1 TO 20 STEP 1
				IF (ldc_btramt[li_amt_row] > 0 or ldc_btramt[li_amt_row] < 0) THEN
					 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
					 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
	 				 li_amt_row2 +=1								
				End If
			NEXT
			
			FOR li_amt_row = 1 TO 20 STEP 1
				If Trim(ls_desc[li_amt_row])="" Then
					li_column_cnt = li_amt_row
					li_amt_row=20
				End If
			Next			
			
						
			li_temp_cnt = li_column_cnt -1
						
			If li_temp_cnt > 0 Then
				If Trim(ls_desc[li_temp_cnt]) = "원단위절사" Then
					ls_desc[li_column_cnt] ="당월요금계"
					If ldc_prebalance > 0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+1] ="전월미납액"
						ls_amt[li_column_cnt+1] = String(ldc_prebalance,"#,##0")							
					End if
					ls_amt[li_column_cnt] =""
					ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")					
						
				Else
					ls_desc[li_column_cnt] ="원단위절사"
					ls_desc[li_column_cnt+1] ="당월요금계"
					If ldc_prebalance >0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+2] ="전월미납액"
						ls_amt[li_column_cnt+2] = String(ldc_prebalance,"#,##0")														
					End If
					ls_amt[li_column_cnt]="0"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")			
	
				End If
			Else
					ls_desc[li_column_cnt] = "전월미납액"				
					ls_amt[li_column_cnt] = String(ldc_prebalance,"#,##0")	
			End If
			
			idw_data[1].Object.DESC1[ll_curRow] = ls_desc[1]
			idw_data[1].Object.DESC2[ll_curRow] = ls_desc[2]
			idw_data[1].Object.DESC3[ll_curRow] = ls_desc[3]
			idw_data[1].Object.DESC4[ll_curRow] = ls_desc[4]
			idw_data[1].Object.DESC5[ll_curRow] = ls_desc[5]
			idw_data[1].Object.DESC6[ll_curRow] = ls_desc[6]
			idw_data[1].Object.DESC7[ll_curRow] = ls_desc[7]
			idw_data[1].Object.DESC8[ll_curRow] = ls_desc[8]
			idw_data[1].Object.DESC9[ll_curRow] = ls_desc[9]
			idw_data[1].Object.DESC10[ll_curRow] = ls_desc[10]			
			idw_data[1].Object.DESC11[ll_curRow] = ls_desc[11]
			idw_data[1].Object.DESC12[ll_curRow] = ls_desc[12]
			idw_data[1].Object.DESC13[ll_curRow] = ls_desc[13]
			idw_data[1].Object.DESC14[ll_curRow] = ls_desc[14]
			idw_data[1].Object.DESC15[ll_curRow] = ls_desc[15]	
			idw_data[1].Object.DESC16[ll_curRow] = ls_desc[16]	
			idw_data[1].Object.DESC17[ll_curRow] = ls_desc[17]	
			idw_data[1].Object.DESC18[ll_curRow] = ls_desc[18]	
			idw_data[1].Object.DESC19[ll_curRow] = ls_desc[19]	
			idw_data[1].Object.DESC20[ll_curRow] = ls_desc[20]	
			

		   idw_data[1].Object.AMT1[ll_curRow] = ls_amt[1]
			idw_data[1].Object.AMT2[ll_curRow] = ls_amt[2]
			idw_data[1].Object.AMT3[ll_curRow] = ls_amt[3]
			idw_data[1].Object.AMT4[ll_curRow] = ls_amt[4]
			idw_data[1].Object.AMT5[ll_curRow] = ls_amt[5]
			idw_data[1].Object.AMT6[ll_curRow] = ls_amt[6]
			idw_data[1].Object.AMT7[ll_curRow] = ls_amt[7]
			idw_data[1].Object.AMT8[ll_curRow] = ls_amt[8]
			idw_data[1].Object.AMT9[ll_curRow] = ls_amt[9]
			idw_data[1].Object.AMT10[ll_curRow] = ls_amt[10]			
			idw_data[1].Object.AMT11[ll_curRow] = ls_amt[11]
			idw_data[1].Object.AMT12[ll_curRow] = ls_amt[12]
			idw_data[1].Object.AMT13[ll_curRow] = ls_amt[13]
			idw_data[1].Object.AMT14[ll_curRow] = ls_amt[14]
			idw_data[1].Object.AMT15[ll_curRow] = ls_amt[15]	
			idw_data[1].Object.AMT16[ll_curRow] = ls_amt[16]
			idw_data[1].Object.AMT17[ll_curRow] = ls_amt[17]
			idw_data[1].Object.AMT18[ll_curRow] = ls_amt[18]
			idw_data[1].Object.AMT19[ll_curRow] = ls_amt[19]
			idw_data[1].Object.AMT20[ll_curRow] = ls_amt[20]

				
//			SELECT a.reqnum, to_char(to_date(a.trdt,'yyyymmdd'),'yyyymm'), months_between(to_date(:ls_trdt,'yyyymmdd'),to_date(a.trdt,'yyyymmdd'))
//			 INTO  :ls_reqnum, :ls_delay_start_trdt, :li_delay_cnt
//			 FROM (   SELECT   a.reqnum reqnum, to_char(min(trdt),'yyyymmdd') trdt 
//							FROM   reqdtl a
//						  WHERE   0 < ( SELECT sum(tramt) FROM reqdtl WHERE payid=a.payid AND reqnum = a.reqnum) 
//							 AND   ( mark IS NULL  OR mark <> 'D')
//							 AND   payid =:ls_payid
//							 AND   to_char(trdt,'yyyymmdd') <=:ls_trdt
//					  GROUP BY   a.reqnum) a
//			WHERE rownum=1;

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select delay count")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If						

          //지로고객조회번호left
			ls_giro_customer_no_left = fs_giro_band_left_mh(ls_payid, ls_trdt)
			idw_data[1].Object.gironum_left[ll_curRow] = ls_giro_customer_no_left

         //지로고객조회번호 right
			ls_giro_customer_no_right = fs_giro_band_right_mh(ldc_curbalance+ldc_prebalance) 
			idw_data[1].Object.gironum_right[ll_curRow] = ls_giro_customer_no_right
			
				

		Next		
		
Case "b7w_prt_giro_notice_v_modify%ue_ok"
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.is_data2[6] = ls_zipcode
	//lu_dbmgr.is_data2[7] = ls_addr1
	//lu_dbmgr.is_data2[8] = ls_addr2	
	//lu_dbmgr.is_data2[9] = ls_customernm_m
	//lu_dbmgr.idw_data[1] = dw_list

	
		ls_trdt          = is_data2[1]
		ls_usedt_fr      = is_data2[2]
		ls_usedt_to      = is_data2[3]
		ls_paydt         = is_data2[4]
		ls_editdt        = is_data2[5]
		ls_zipcode       = is_data2[6]		
		ls_addr1         = is_data2[7]
		ls_addr2         = is_data2[8]		
		ls_customernm_m  = is_data2[9]
		ls_pay_method    = is_data2[10]


		ls_payid = Trim(idw_data[1].Object.reqinfo_payid[1])
		
		If  ls_customernm_m <>"" Then
			idw_data[1].Object.customernm[1] = ls_customernm_m
		End If		

		idw_data[1].Object.issuedt[1]			= ls_editdt  		//작성일
		idw_data[1].Object.bil_addr1[1]     = ls_addr1
		idw_data[1].Object.bil_addr2[1]     = ls_addr2
		idw_data[1].Object.zipcode[1]     = String(ls_zipcode,"@@@-@@@")
		
		//Message Box check =======================================================>
		SELECT to_char(max(fromdt),'yyyymmdd')
		INTO :ls_msg_fromdt
		FROM invoicemsg
		WHeRE pay_method =:ls_pay_method;
		
		If SQLCA.sqlcode < 0 Then
		  f_msg_sql_err(is_Title, "Select invoicemsg")
		  Return
		End If	
		
		If ls_msg_fromdt = ls_trdt Then
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_trdt;
		Else
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_msg_fromdt;				
		End If
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select invoicemsg")
			Return
		ElseIf SQLCA.SQLCode = 100 Then 
			ls_msg1 = ""
			ls_msg2 = ""
			ls_msg3 = ""
			ls_msg4 = ""
			ls_msg5 = ""
		End If					
		idw_data[1].object.msg1[1] = ls_msg1
		idw_data[1].object.msg2[1] = ls_msg2
		idw_data[1].object.msg3[1] = ls_msg3
		idw_data[1].object.msg4[1] = ls_msg4			
		idw_data[1].object.msg5[1] = ls_msg5					
		//Message Box check END====================================================>			
		ls_btrdesc[1]=idw_data[1].Object.btrdesc01[1]			
		ls_btrdesc[2]=idw_data[1].Object.btrdesc02[1]
		ls_btrdesc[3]=idw_data[1].Object.btrdesc03[1]
		ls_btrdesc[4]=idw_data[1].Object.btrdesc04[1]
		ls_btrdesc[5]=idw_data[1].Object.btrdesc05[1]
		ls_btrdesc[6]=idw_data[1].Object.btrdesc06[1]
		ls_btrdesc[7]=idw_data[1].Object.btrdesc07[1]
		ls_btrdesc[8]=idw_data[1].Object.btrdesc08[1]
		ls_btrdesc[9]=idw_data[1].Object.btrdesc09[1]
		ls_btrdesc[10]=idw_data[1].Object.btrdesc10[1]
		ls_btrdesc[11]=idw_data[1].Object.btrdesc11[1]
		ls_btrdesc[12]=idw_data[1].Object.btrdesc12[1]
		ls_btrdesc[13]=idw_data[1].Object.btrdesc13[1]
		ls_btrdesc[14]=idw_data[1].Object.btrdesc14[1]
		ls_btrdesc[15]=idw_data[1].Object.btrdesc15[1]
		ls_btrdesc[16]=idw_data[1].Object.btrdesc16[1]
		ls_btrdesc[17]=idw_data[1].Object.btrdesc17[1]			
		ls_btrdesc[18]=idw_data[1].Object.btrdesc18[1]
		ls_btrdesc[19]=idw_data[1].Object.btrdesc19[1]
		ls_btrdesc[20]=idw_data[1].Object.btrdesc20[1]
		
		ldc_btramt[1]=idw_data[1].Object.btramt01[1]
		ldc_btramt[2]=idw_data[1].Object.btramt02[1]
		ldc_btramt[3]=idw_data[1].Object.btramt03[1]
		ldc_btramt[4]=idw_data[1].Object.btramt04[1]
		ldc_btramt[5]=idw_data[1].Object.btramt05[1]
		ldc_btramt[6]=idw_data[1].Object.btramt06[1]
		ldc_btramt[7]=idw_data[1].Object.btramt07[1]
		ldc_btramt[8]=idw_data[1].Object.btramt08[1]
		ldc_btramt[9]=idw_data[1].Object.btramt09[1]
		ldc_btramt[10]=idw_data[1].Object.btramt10[1]
		ldc_btramt[11]=idw_data[1].Object.btramt11[1]
		ldc_btramt[12]=idw_data[1].Object.btramt12[1]
		ldc_btramt[13]=idw_data[1].Object.btramt13[1]
		ldc_btramt[14]=idw_data[1].Object.btramt14[1]
		ldc_btramt[15]=idw_data[1].Object.btramt15[1]
		ldc_btramt[16]=idw_data[1].Object.btramt16[1]
		ldc_btramt[17]=idw_data[1].Object.btramt17[1]			
		ldc_btramt[18]=idw_data[1].Object.btramt18[1]			
		ldc_btramt[19]=idw_data[1].Object.btramt19[1]
		ldc_btramt[20]=idw_data[1].Object.btramt20[1]			
			
		ldc_surtax = idw_data[1].object.surtax[1]
		ldc_curbalance= idw_data[1].object.cur_balance[1]
		ldc_prebalance= idw_data[1].object.pre_balance[1]
		
		SELECT min(validkey), Nvl(count(validkey),0)	
		  INTO :ls_validkey_min, :li_validkey_cnt
		  FROM validinfo
		 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
			 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
				to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
			AND status <> '10' 
			AND svctype = '1'
			AND customerid =:ls_payid;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select validinfo")
			Return
		End If				
		
		idw_data[1].Object.validkey[1] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 


			FOR li_amt_row =1 TO 20 STEP 1				
				ls_desc[li_amt_row] = ""	
				ls_amt[li_amt_row] = ""
			Next
			
		   li_amt_row2 = 1
			FOR li_amt_row =1 TO 20 STEP 1
				IF (ldc_btramt[li_amt_row] > 0 or ldc_btramt[li_amt_row] < 0) THEN
					 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
					 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
	 				 li_amt_row2 +=1								
				End If
			NEXT
			
			FOR li_amt_row = 1 TO 15 STEP 1
				If Trim(ls_desc[li_amt_row])="" Then
					li_column_cnt = li_amt_row
					li_amt_row=15
				End If
			Next			

			li_temp_cnt =0
			li_temp_cnt = li_column_cnt -1
						
			If li_temp_cnt > 0 Then
				If Trim(ls_desc[li_temp_cnt]) = "원단위절사" Then
					ls_desc[li_column_cnt] ="당월요금계"
					If ldc_prebalance > 0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+1] ="전월미납액"
						ls_amt[li_column_cnt+1] = String(ldc_prebalance,"#,##0")							
					End if
					ls_amt[li_column_cnt] =""
					ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")					
						
				Else
					ls_desc[li_column_cnt] ="원단위절사"
					ls_desc[li_column_cnt+1] ="당월요금계"
					If ldc_prebalance >0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+2] ="전월미납액"
						ls_amt[li_column_cnt+2] = String(ldc_prebalance,"#,##0")														
					End If
					ls_amt[li_column_cnt]="0"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")			
	
				End If
			Else
					ls_desc[li_column_cnt] = "전월미납액"				
					ls_amt[li_column_cnt] = String(ldc_prebalance,"#,##0")	
			End If			
						

		
		idw_data[1].Object.DESC1[1] = ls_desc[1]
		idw_data[1].Object.DESC2[1] = ls_desc[2]
		idw_data[1].Object.DESC3[1] = ls_desc[3]
		idw_data[1].Object.DESC4[1] = ls_desc[4]
		idw_data[1].Object.DESC5[1] = ls_desc[5]
		idw_data[1].Object.DESC6[1] = ls_desc[6]
		idw_data[1].Object.desc7[1] = ls_desc[7]
		idw_data[1].Object.desc8[1] = ls_desc[8]
		idw_data[1].Object.desc9[1] = ls_desc[9]
		idw_data[1].Object.desc10[1] = ls_desc[10]			
		idw_data[1].Object.desc11[1] = ls_desc[11]
		idw_data[1].Object.desc12[1] = ls_desc[12]
		idw_data[1].Object.desc13[1] = ls_desc[13]
		idw_data[1].Object.desc14[1] = ls_desc[14]
		idw_data[1].Object.desc15[1] = ls_desc[15]		

		idw_data[1].Object.AMT1[1] = ls_amt[1]
		idw_data[1].Object.AMT2[1] = ls_amt[2]
		idw_data[1].Object.AMT3[1] = ls_amt[3]
		idw_data[1].Object.AMT4[1] = ls_amt[4]
		idw_data[1].Object.AMT5[1] = ls_amt[5]
		idw_data[1].Object.AMT6[1] = ls_amt[6]
		idw_data[1].Object.AMT7[1] = ls_amt[7]
		idw_data[1].Object.AMT8[1] = ls_amt[8]
		idw_data[1].Object.AMT9[1] = ls_amt[9]
		idw_data[1].Object.AMT10[1] = ls_amt[10]			
		idw_data[1].Object.AMT11[1] = ls_amt[11]
		idw_data[1].Object.AMT12[1] = ls_amt[12]
		idw_data[1].Object.AMT13[1] = ls_amt[13]
		idw_data[1].Object.AMT14[1] = ls_amt[14]
		idw_data[1].Object.AMT15[1] = ls_amt[15]					

			
		SELECT a.reqnum, to_char(to_date(a.trdt,'yyyymmdd'),'yyyymm'), months_between(to_date(:ls_trdt,'yyyymmdd'),to_date(a.trdt,'yyyymmdd'))
		 INTO  :ls_reqnum, :ls_delay_start_trdt, :li_delay_cnt
		 FROM (   SELECT   a.reqnum reqnum, to_char(min(trdt),'yyyymmdd') trdt 
						FROM   reqdtl a
					  WHERE   0 < ( SELECT sum(tramt) FROM reqdtl WHERE payid=a.payid AND reqnum = a.reqnum) 
						 AND   ( mark IS NULL  OR mark <> 'D')
						 AND   payid =:ls_payid
						 AND   to_char(trdt,'yyyymmdd') <=:ls_trdt
				  GROUP BY   a.reqnum) a
		WHERE rownum=1;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select delay count")
			Return
		End If						

		 //지로고객조회번호left
		ls_giro_customer_no_left = fs_giro_band_left(ls_payid, ls_trdt, li_delay_cnt , ls_delay_start_trdt)
		idw_data[1].Object.gironum_left[1] = ls_giro_customer_no_left

		//지로고객조회번호 right
		ls_giro_customer_no_right = fs_giro_band_right(ldc_curbalance+ldc_prebalance) 
		idw_data[1].Object.gironum_right[1] = ls_giro_customer_no_right
					
		
	Case Else
		f_msg_info_app(9000, "b7u_dbmgr_2.uf_prc_db_01()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")
		Return

End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_04 ();/*********************************************
 *  2005.09.22  juede
 *  Vtelecom 청구서 재발행시 이름&주소수정
 ********************************************/

String	ls_null

//System Control Parameter
String	ls_ref_content, ls_ref_desc

//청구주기 컨트롤 일자 Setting
Long		ll_year, ll_mon, ll_last_day
String	ls_reqdt, ls_paydt, ls_trdt, ls_useddt, ls_usedt_fr, ls_usedt_to
Date		ld_trdt, ld_useddt

//지로 (통합/월별)청구서
Long		ll_rows, ll_selrows, ll_findrow
Long		ll_subcnt
String	ls_payid, ls_reqnum, ls_req_month, ls_editdt, ls_busyn, ls_giro_no
String	ls_ocr_left, ls_ocr_right, ls_markid, ls_subid
String	ls_subkind, ls_keysubid
Decimal{0} lc0_curbal, lc0_lastbal, lc0_totamt

//자동이체/카드 
Integer	li_count
String	ls_chargeby
Decimal{0} lc0_amt

//자동이체/카드 수정분 추가
String	ls_trdt_bf, ls_outdt, ls_bankbef, ls_accountbef, ls_ownerbef
String	ls_bank, ls_account, ls_bankcode, ls_banknm, ls_cardname
Decimal{0} lc0_outamt

String ls_validkey_min,ls_receipt_acctowner
int li_validkey_cnt, li_amt_row, li_amt_row2
DEC ldc_receipt_payamt, ldc_btramt[]
String ls_receipt_payid, ls_receipt_customernm, ls_receipt_acctno, ls_receipt_paydt, ls_receipt_banknm
String ls_btrdesc[], ls_desc[], ls_admin_tel,ls_amt[]
String ls_culumn_nm, ls_surtax
int li_column_cnt

Dec ldc_surtax, ldc_curbalance, ldc_prebalance

String ls_addr1, ls_addr2, ls_zipcode
String ls_customernm_m

//giro
String ls_giro_customer_no_left, ls_giro_customer_no_right
String ls_delay_start_trdt, ls_msg_fromdt
String ls_msg1, ls_msg2, ls_msg3, ls_msg4, ls_msg5, ls_pay_method
int li_delay_cnt, li_temp_cnt

SetNull(ls_null)

ii_rc = -1

Choose Case is_caller
	Case "b7w_prt_cms_notice_v_modify%ue_ok"
	//jybaek: 자동이체/카드 
	//lu_dbmgr.is_title = This.Title
	//lu_dbmgr.is_data2[1] = ls_trdt
	//lu_dbmgr.is_data2[2] = ls_usedt_fr
	//lu_dbmgr.is_data2[3] = ls_usedt_to
	//lu_dbmgr.is_data2[4] = ls_paydt
	//lu_dbmgr.is_data2[5] = ls_editdt
	//lu_dbmgr.is_data2[7] = ls_zipcode
	//lu_dbmgr.is_data2[8] = ls_addr1
	//lu_dbmgr.is_data2[9] = ls_addr2	
	//lu_dbmgr.is_data2[10] = ls_customernm_m
	//lu_dbmgr.idw_data[1] = dw_list
	//lu_dbmgr.is_data2[6] = is_manager_tel
	
		ls_trdt         = is_data2[1]
		ls_usedt_fr     = is_data2[2]
		ls_usedt_to     = is_data2[3]
		ls_paydt        = is_data2[4]
		ls_editdt       = is_data2[5]
		ls_admin_tel    = is_data2[6]
		ls_zipcode      = is_data2[7]
		ls_addr1        = is_data2[8]
		ls_addr2        = is_data2[9]
		ls_customernm_m = is_data2[10]
		ls_pay_method   = is_data2[11]


	
		ls_payid = Trim(idw_data[1].Object.reqinfo_payid[1])
					
		idw_data[1].Object.issuedt[1]			= ls_editdt  		//작성일
		idw_data[1].Object.admin_tel[1]     = ls_admin_tel
		idw_data[1].Object.seqno[1]         = String(1)
		
		If ls_customernm_m <>"" Then
			idw_data[1].Object.customernm[1] = ls_customernm_m
		End If
		
		idw_data[1].Object.bil_addr1[1] = ls_addr1
		idw_data[1].Object.bil_addr2[1] = ls_addr2
		idw_data[1].Object.zipcode[1]   = String(ls_zipcode,"@@@-@@@")
		//Message box check start ================================================>
		SELECT to_char(max(fromdt),'yyyymmdd')
		INTO :ls_msg_fromdt
		FROM invoicemsg
		WHERE pay_method = :ls_pay_method;
		
		If SQLCA.sqlcode < 0 Then
		  f_msg_sql_err(is_Title, "Select invoicemsg")
		  Return
		End If	
		
		If ls_msg_fromdt = ls_trdt Then
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_trdt;
		Else
			SELECT msg_1, msg_2, msg_3, msg_4, msg_5
			  INTO :ls_msg1, :ls_msg2, :ls_msg3, :ls_msg4, :ls_msg5		
			  FROM invoicemsg msg
			 WHERE msg.pay_method =:ls_pay_method
				AND msg.fromdt = :ls_msg_fromdt;				
		End If
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select invoicemsg")
			Return
		ElseIf SQLCA.SQLCode = 100 Then 
			ls_msg1 = ""
			ls_msg2 = ""
			ls_msg3 = ""
			ls_msg4 = ""
			ls_msg5 = ""
		End If					
		
		idw_data[1].object.msg1[1] = ls_msg1
		idw_data[1].object.msg2[1] = ls_msg2
		idw_data[1].object.msg3[1] = ls_msg3
		idw_data[1].object.msg4[1] = ls_msg4			
		idw_data[1].object.msg5[1] = ls_msg5						
		
		If IsNull(ls_msg1) or ls_msg1=""  Then idw_data[1].Object.msg_tag1[1]=""
		If IsNull(ls_msg2) or ls_msg2=""  Then idw_data[1].Object.msg_tag2[1]=""
		If IsNull(ls_msg3) or ls_msg3=""  Then idw_data[1].Object.msg_tag3[1]=""
		If IsNull(ls_msg4) or ls_msg4=""  Then idw_data[1].Object.msg_tag4[1]=""
		If IsNull(ls_msg5) or ls_msg5=""  Then idw_data[1].Object.msg_tag5[1]=""				
		//Message Box check End ========================================================>

		ls_btrdesc[1]=idw_data[1].Object.btrdesc01[1]
		ls_btrdesc[2]=idw_data[1].Object.btrdesc02[1]
		ls_btrdesc[3]=idw_data[1].Object.btrdesc03[1]
		ls_btrdesc[4]=idw_data[1].Object.btrdesc04[1]
		ls_btrdesc[5]=idw_data[1].Object.btrdesc05[1]
		ls_btrdesc[6]=idw_data[1].Object.btrdesc06[1]
		ls_btrdesc[7]=idw_data[1].Object.btrdesc07[1]
		ls_btrdesc[8]=idw_data[1].Object.btrdesc08[1]
		ls_btrdesc[9]=idw_data[1].Object.btrdesc09[1]
		ls_btrdesc[10]=idw_data[1].Object.btrdesc10[1]
		ls_btrdesc[11]=idw_data[1].Object.btrdesc11[1]
		ls_btrdesc[12]=idw_data[1].Object.btrdesc12[1]
		ls_btrdesc[13]=idw_data[1].Object.btrdesc13[1]
		ls_btrdesc[14]=idw_data[1].Object.btrdesc14[1]
		ls_btrdesc[15]=idw_data[1].Object.btrdesc15[1]
		ls_btrdesc[16]=idw_data[1].Object.btrdesc16[1]
		ls_btrdesc[17]=idw_data[1].Object.btrdesc17[1]			
		ls_btrdesc[18]=idw_data[1].Object.btrdesc18[1]
		ls_btrdesc[19]=idw_data[1].Object.btrdesc19[1]
		ls_btrdesc[20]=idw_data[1].Object.btrdesc20[1]
		
		ldc_btramt[1]=idw_data[1].Object.btramt01[1]
		ldc_btramt[2]=idw_data[1].Object.btramt02[1]
		ldc_btramt[3]=idw_data[1].Object.btramt03[1]
		ldc_btramt[4]=idw_data[1].Object.btramt04[1]
		ldc_btramt[5]=idw_data[1].Object.btramt05[1]
		ldc_btramt[6]=idw_data[1].Object.btramt06[1]
		ldc_btramt[7]=idw_data[1].Object.btramt07[1]
		ldc_btramt[8]=idw_data[1].Object.btramt08[1]
		ldc_btramt[9]=idw_data[1].Object.btramt09[1]
		ldc_btramt[10]=idw_data[1].Object.btramt10[1]
		ldc_btramt[11]=idw_data[1].Object.btramt11[1]
		ldc_btramt[12]=idw_data[1].Object.btramt12[1]
		ldc_btramt[13]=idw_data[1].Object.btramt13[1]
		ldc_btramt[14]=idw_data[1].Object.btramt14[1]
		ldc_btramt[15]=idw_data[1].Object.btramt15[1]
		ldc_btramt[16]=idw_data[1].Object.btramt16[1]
		ldc_btramt[17]=idw_data[1].Object.btramt17[1]			
		ldc_btramt[18]=idw_data[1].Object.btramt18[1]			
		ldc_btramt[19]=idw_data[1].Object.btramt19[1]
		ldc_btramt[20]=idw_data[1].Object.btramt20[1]			
			
		ldc_surtax = idw_data[1].object.surtax[1]
		ldc_curbalance= idw_data[1].object.cur_balance[1]
		
		SELECT min(validkey), Nvl(count(validkey),0)	
		  INTO :ls_validkey_min, :li_validkey_cnt
		  FROM validinfo
		 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
			 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
				to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
			AND status <> '10' 
			AND svctype = '1'
			AND customerid =:ls_payid;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select validinfo")
			Return
		End If				
		
		idw_data[1].Object.validkey[1] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 

		//자동이체전월영수금액					
	
		     SELECT  cus.customernm, a.total_amt, a.payid, infoh.acct_owner,
				       substr(a.acct_no, 1, 5)||rpad(nvl(null, '*'), length(substr(a.acct_no, 6, 15)), '*'),
						 to_char(a.paydt,'yyyy-mm-dd'),
						 bank.codenm
				 INTO   :ls_receipt_customernm,
						  :ldc_receipt_payamt, 
						  :ls_receipt_payid,
						  :ls_receipt_acctowner,
						  :ls_receipt_acctno,
						  :ls_receipt_paydt,
						  :ls_receipt_banknm					
 			    FROM 	
  			   (SELECT  payid, sum(nvl(receipt.payamt,0)) total_amt, trdt, max(paydt) paydt, acct_no, acct_type
				   FROM  reqreceipt receipt 
				  WHERE  to_char(receipt.trdt,'yyyymmdd') =  :ls_trdt 
			     GROUP BY  payid,trdt, acct_no, acct_type) a, customerm cus, reqinfoh infoh,
    		  (SELECT code,codenm from syscod2t where grcode='B400' and use_yn='Y') bank
	     		WHERE   a.payid = :ls_payid
				  AND   to_char(a.trdt,'yyyymmdd') = :ls_trdt
				  AND   a.payid = cus.customerid
				  And   a.payid = infoh.payid
				  and   to_char(infoh.trdt,'yyyymmdd') =add_months(to_date(:ls_trdt,'yyyymmdd'),-1)
				  AND   a.acct_type = bank.code(+)
				  AND   a.payid(+) = infoh.payid;
		  
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select receipt")
			Return
		ElseIf SQLCA.SQLCode = 100 Then 
			idw_data[1].Object.receipt_payamt[1] = ""
			idw_data[1].Object.receipt_acct_owner[1] = ""
			idw_data[1].Object.receipt_bank[1] = ""
			idw_data[1].Object.receipt_paydt[1] = ""
			idw_data[1].Object.receipt_acct_no[1] = ""
			idw_data[1].Object.receipt_customernm[1] = ""
		End If	
		
		If ldc_receipt_payamt > 0 Then
			idw_data[1].Object.receipt_payamt[1] = String(ldc_receipt_payamt,'#,##0')
		End If
		idw_data[1].Object.receipt_acct_owner[1] = ls_receipt_acctowner
		idw_data[1].Object.receipt_bank[1] = ls_receipt_banknm	
		idw_data[1].Object.receipt_paydt[1] = ls_receipt_paydt
		idw_data[1].Object.receipt_acct_no[1] = ls_receipt_acctno
		idw_data[1].Object.receipt_customernm[1] = ls_receipt_customernm

			FOR li_amt_row =1 TO 15 STEP 1				
				ls_desc[li_amt_row] = ""	
				ls_amt[li_amt_row] = ""
			Next
			
		   li_amt_row2 = 1
			FOR li_amt_row =1 TO 20 STEP 1
				IF (ldc_btramt[li_amt_row] > 0 or ldc_btramt[li_amt_row] < 0) THEN
					 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
					 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
	 				 li_amt_row2 +=1								
				End If
			NEXT
			
			FOR li_amt_row = 1 TO 15 STEP 1
				If Trim(ls_desc[li_amt_row])="" Then
					li_column_cnt = li_amt_row
					li_amt_row=15
				End If
			Next			
			
			li_temp_cnt = li_column_cnt -1			
						
			If li_temp_cnt > 0 Then
				If Trim(ls_desc[li_temp_cnt]) = "절사액" Then
					ls_desc[li_column_cnt] ="당월요금계"
					If ldc_prebalance > 0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+1] ="전월미납액"
						ls_amt[li_column_cnt+1] = String(ldc_prebalance,"#,##0")							
					End if
					ls_amt[li_column_cnt] =""
					ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")					
						
				Else
					ls_desc[li_column_cnt] ="절사액"
					ls_desc[li_column_cnt+1] ="당월요금계"
					If ldc_prebalance >0 or ldc_prebalance < 0 Then						
						ls_desc[li_column_cnt+2] ="전월미납액"
						ls_amt[li_column_cnt+2] = String(ldc_prebalance,"#,##0")														
					End If
					ls_amt[li_column_cnt]="0"
					ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")			
	
				End If
			Else
					ls_desc[li_column_cnt] = "전월미납액"				
					ls_amt[li_column_cnt] = String(ldc_prebalance,"#,##0")	
			End If
		
		idw_data[1].Object.DESC1[1] = ls_desc[1]
		idw_data[1].Object.DESC2[1] = ls_desc[2]
		idw_data[1].Object.DESC3[1] = ls_desc[3]
		idw_data[1].Object.DESC4[1] = ls_desc[4]
		idw_data[1].Object.DESC5[1] = ls_desc[5]
		idw_data[1].Object.DESC6[1] = ls_desc[6]
		idw_data[1].Object.desc7[1] = ls_desc[7]
		idw_data[1].Object.desc8[1] = ls_desc[8]
		idw_data[1].Object.desc9[1] = ls_desc[9]
		idw_data[1].Object.desc10[1] = ls_desc[10]			
		idw_data[1].Object.desc11[1] = ls_desc[11]
		idw_data[1].Object.desc12[1] = ls_desc[12]
		idw_data[1].Object.desc13[1] = ls_desc[13]
		idw_data[1].Object.desc14[1] = ls_desc[14]
		idw_data[1].Object.desc15[1] = ls_desc[15]		

		idw_data[1].Object.AMT1[1] = ls_amt[1]
		idw_data[1].Object.AMT2[1] = ls_amt[2]
		idw_data[1].Object.AMT3[1] = ls_amt[3]
		idw_data[1].Object.AMT4[1] = ls_amt[4]
		idw_data[1].Object.AMT5[1] = ls_amt[5]
		idw_data[1].Object.AMT6[1] = ls_amt[6]
		idw_data[1].Object.AMT7[1] = ls_amt[7]
		idw_data[1].Object.AMT8[1] = ls_amt[8]
		idw_data[1].Object.AMT9[1] = ls_amt[9]
		idw_data[1].Object.AMT10[1] = ls_amt[10]			
		idw_data[1].Object.AMT11[1] = ls_amt[11]
		idw_data[1].Object.AMT12[1] = ls_amt[12]
		idw_data[1].Object.AMT13[1] = ls_amt[13]
		idw_data[1].Object.AMT14[1] = ls_amt[14]
		idw_data[1].Object.AMT15[1] = ls_amt[15]					

		
	Case "b7w_prt_kt_notice_v_modify%ue_ok"  //KT 통합
		//lu_dbmgr.is_title = This.Title
		//lu_dbmgr.is_data2[1] = ls_trdt
		//lu_dbmgr.is_data2[2] = ls_usedt_fr
		//lu_dbmgr.is_data2[3] = ls_usedt_to
		//lu_dbmgr.is_data2[4] = ls_paydt
		//lu_dbmgr.is_data2[5] = ls_editdt
		//lu_dbmgr.is_data2[6] = ls_zipcode
		//lu_dbmgr.is_data2[7] = ls_addr1
		//lu_dbmgr.is_data2[8] = ls_addr2		
		//lu_dbmgr.is_data2[9] = ls_customernm_m
		//lu_dbmgr.idw_data[1] = dw_list

		ls_trdt         = is_data2[1]
		ls_usedt_fr     = is_data2[2]
		ls_usedt_to     = is_data2[3]
		ls_paydt        = is_data2[4]
		ls_editdt       = is_data2[5]
		ls_zipcode      = is_data2[6]
		ls_addr1        = is_data2[7]
		ls_addr2        = is_data2[8]
		ls_customernm_m = is_data2[9]
		
		ls_payid = Trim(idw_data[1].Object.reqinfo_payid[1])
		
		If ls_customernm_m <>"" Then
			idw_data[1].Object.customernm[1] = ls_customernm_m
		End If		
					
		idw_data[1].object.issuedt[1]	= ls_editdt  		//작성일
      idw_data[1].Object.bil_addr1[1] = ls_addr1
		idw_data[1].Object.bil_addr2[1] = ls_addr2
		idw_data[1].Object.zipcode[1] = String(ls_zipcode,"@@@-@@@")
	
		idw_data[1].object.seqno[1] = String(1)
		
		ls_addr1 = Trim(idw_data[1].object.bil_addr1[1])
		ls_addr2 = Trim(idw_data[1].object.bil_addr2[1])
		ls_zipcode = Trim(idw_data[1].object.zipcode[1])			
		
			
		ls_btrdesc[1]=idw_data[1].Object.btrdesc01[1]
		ls_btrdesc[2]=idw_data[1].Object.btrdesc02[1]
		ls_btrdesc[3]=idw_data[1].Object.btrdesc03[1]
		ls_btrdesc[4]=idw_data[1].Object.btrdesc04[1]
		ls_btrdesc[5]=idw_data[1].Object.btrdesc05[1]
		ls_btrdesc[6]=idw_data[1].Object.btrdesc06[1]
		ls_btrdesc[7]=idw_data[1].Object.btrdesc07[1]
		ls_btrdesc[8]=idw_data[1].Object.btrdesc08[1]
		ls_btrdesc[9]=idw_data[1].Object.btrdesc09[1]
		ls_btrdesc[10]=idw_data[1].Object.btrdesc10[1]
		ls_btrdesc[11]=idw_data[1].Object.btrdesc11[1]
		ls_btrdesc[12]=idw_data[1].Object.btrdesc12[1]
		ls_btrdesc[13]=idw_data[1].Object.btrdesc13[1]
		ls_btrdesc[14]=idw_data[1].Object.btrdesc14[1]
		ls_btrdesc[15]=idw_data[1].Object.btrdesc15[1]
		ls_btrdesc[16]=idw_data[1].Object.btrdesc16[1]
		ls_btrdesc[17]=idw_data[1].Object.btrdesc17[1]			
		ls_btrdesc[18]=idw_data[1].Object.btrdesc18[1]
		ls_btrdesc[19]=idw_data[1].Object.btrdesc19[1]
		ls_btrdesc[20]=idw_data[1].Object.btrdesc20[1]
		
		ldc_btramt[1]=idw_data[1].Object.btramt01[1]
		ldc_btramt[2]=idw_data[1].Object.btramt02[1]
		ldc_btramt[3]=idw_data[1].Object.btramt03[1]
		ldc_btramt[4]=idw_data[1].Object.btramt04[1]
		ldc_btramt[5]=idw_data[1].Object.btramt05[1]
		ldc_btramt[6]=idw_data[1].Object.btramt06[1]
		ldc_btramt[7]=idw_data[1].Object.btramt07[1]
		ldc_btramt[8]=idw_data[1].Object.btramt08[1]
		ldc_btramt[9]=idw_data[1].Object.btramt09[1]
		ldc_btramt[10]=idw_data[1].Object.btramt10[1]
		ldc_btramt[11]=idw_data[1].Object.btramt11[1]
		ldc_btramt[12]=idw_data[1].Object.btramt12[1]
		ldc_btramt[13]=idw_data[1].Object.btramt13[1]
		ldc_btramt[14]=idw_data[1].Object.btramt14[1]
		ldc_btramt[15]=idw_data[1].Object.btramt15[1]
		ldc_btramt[16]=idw_data[1].Object.btramt16[1]
		ldc_btramt[17]=idw_data[1].Object.btramt17[1]			
		ldc_btramt[18]=idw_data[1].Object.btramt18[1]			
		ldc_btramt[19]=idw_data[1].Object.btramt19[1]
		ldc_btramt[20]=idw_data[1].Object.btramt20[1]			
			
		ldc_surtax = idw_data[1].object.surtax[1]
		ldc_curbalance= idw_data[1].object.cur_balance[1]
		
		SELECT min(validkey), Nvl(count(validkey),0)	
		  INTO :ls_validkey_min, :li_validkey_cnt
		  FROM validinfo
		 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
			 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
				to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
			AND status <> '10' 
			AND svctype = '1'
			AND customerid =:ls_payid;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select validinfo")
			Return
		End If				
		
		idw_data[1].Object.validkey[1] = ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' 


		FOR li_amt_row =1 TO 15 STEP 1				
			ls_desc[li_amt_row] = ""	
			ls_amt[li_amt_row] = ""
		Next
		
		li_amt_row2 = 1
		FOR li_amt_row =1 TO 20 STEP 1
			IF (ldc_btramt[li_amt_row] > 0) THEN
				 ls_desc[li_amt_row2]= ls_btrdesc[li_amt_row]
				 ls_amt[li_amt_row2] = String(ldc_btramt[li_amt_row],"#,##0")
				 li_amt_row2 +=1								
			End If
		NEXT
		
		FOR li_amt_row = 1 TO 15 STEP 1
			If Trim(ls_desc[li_amt_row])="" Then
				li_column_cnt = li_amt_row
				li_amt_row=15
			End If
		Next
		
		
		li_temp_cnt = li_column_cnt -1										
				
		If li_temp_cnt > 0 Then
			If Trim(ls_desc[li_temp_cnt]) = "원단위절사" Then
				ls_desc[li_column_cnt] ="당월요금계"
				ls_amt[li_column_cnt] =""
				ls_amt[li_column_cnt] = String(ldc_curbalance,"#,##0")	
				If ldc_prebalance > 0 or ldc_prebalance < 0 Then						
					ls_desc[li_column_cnt+1] ="전월미납액"
					ls_amt[li_column_cnt+1] = String(ldc_prebalance,"#,##0")	
					ls_desc[li_column_cnt+2] ="청 구 요 금"
					ls_amt[li_column_cnt+2] = String(ldc_curbalance+ldc_prebalance,"#,##0")						
				End if
				ls_desc[li_column_cnt+1] ="청 구 요 금"
				ls_amt[li_column_cnt+1] = String(ldc_curbalance+ldc_prebalance,"#,##0")
					
			Else
				ls_desc[li_column_cnt] ="원단위절사"
				ls_desc[li_column_cnt+1] ="당월요금계"
				ls_amt[li_column_cnt]="0"
				ls_amt[li_column_cnt+1] = String(ldc_curbalance,"#,##0")								
				If ldc_prebalance >0 or ldc_prebalance < 0 Then						
					ls_desc[li_column_cnt+2] ="전월미납액"
					ls_amt[li_column_cnt+2] = String(ldc_prebalance,"#,##0")
					ls_desc[li_column_cnt+3] ="청 구 요 금"
					ls_amt[li_column_cnt+3] = String(ldc_curbalance+ldc_prebalance,"#,##0")						
				Else 
					ls_desc[li_column_cnt+2]="청 구 요 금"
					ls_amt[li_column_cnt+2] = String(ldc_curbalance+ldc_prebalance,"#,##0")
				End If			
		
			End If
		Else
				ls_desc[li_column_cnt] = "전월미납액"				
				ls_amt[li_column_cnt] = String(ldc_prebalance,"#,##0")	
				ls_desc[li_column_cnt+1]="청 구 요 금"
				ls_amt[li_column_cnt+1] = String(ldc_curbalance+ldc_prebalance,"#,##0")
				
		End If
		
		idw_data[1].Object.DESC1[1] = ls_desc[1]
		idw_data[1].Object.DESC2[1] = ls_desc[2]
		idw_data[1].Object.DESC3[1] = ls_desc[3]
		idw_data[1].Object.DESC4[1] = ls_desc[4]
		idw_data[1].Object.DESC5[1] = ls_desc[5]
		idw_data[1].Object.DESC6[1] = ls_desc[6]
		idw_data[1].Object.desc7[1] = ls_desc[7]
		idw_data[1].Object.desc8[1] = ls_desc[8]
		idw_data[1].Object.desc9[1] = ls_desc[9]
		idw_data[1].Object.desc10[1] = ls_desc[10]			
		idw_data[1].Object.desc11[1] = ls_desc[11]
		idw_data[1].Object.desc12[1] = ls_desc[12]
		idw_data[1].Object.desc13[1] = ls_desc[13]
		idw_data[1].Object.desc14[1] = ls_desc[14]
		idw_data[1].Object.desc15[1] = ls_desc[15]		

		idw_data[1].Object.AMT1[1] = ls_amt[1]
		idw_data[1].Object.AMT2[1] = ls_amt[2]
		idw_data[1].Object.AMT3[1] = ls_amt[3]
		idw_data[1].Object.AMT4[1] = ls_amt[4]
		idw_data[1].Object.AMT5[1] = ls_amt[5]
		idw_data[1].Object.AMT6[1] = ls_amt[6]
		idw_data[1].Object.AMT7[1] = ls_amt[7]
		idw_data[1].Object.AMT8[1] = ls_amt[8]
		idw_data[1].Object.AMT9[1] = ls_amt[9]
		idw_data[1].Object.AMT10[1] = ls_amt[10]			
		idw_data[1].Object.AMT11[1] = ls_amt[11]
		idw_data[1].Object.AMT12[1] = ls_amt[12]
		idw_data[1].Object.AMT13[1] = ls_amt[13]
		idw_data[1].Object.AMT14[1] = ls_amt[14]
		idw_data[1].Object.AMT15[1] = ls_amt[15]	

		If ls_desc[1] = "" or IsNull(ls_desc[1]) Then
			idw_data[1].Object.desc_t1[1]=""
		End If
		If ls_desc[2] = "" or IsNull(ls_desc[2]) Then
			idw_data[1].Object.desc_t2[1]=""
		End If
		If ls_desc[3] = "" or IsNull(ls_desc[3]) Then
			idw_data[1].Object.desc_t3[1]=""
		End If
		If ls_desc[4] = "" or IsNull(ls_desc[4]) Then
			idw_data[1].Object.desc_t4[1]=""
		End If
		If ls_desc[5] = "" or IsNull(ls_desc[5]) Then
			idw_data[1].Object.desc_t5[1]=""
		End If
		If ls_desc[6] = "" or IsNull(ls_desc[6]) Then
			idw_data[1].Object.desc_t6[1] = ""
		End If
		If ls_desc[7] = "" or IsNull(ls_desc[7]) Then
			idw_data[1].Object.desc_t7[1]=""
		End If
		If ls_desc[8] = "" or IsNull(ls_desc[8]) Then
			idw_data[1].Object.desc_t8[1]=""
		End If
		If ls_desc[9] = "" or IsNull(ls_desc[9]) Then
			idw_data[1].Object.desc_t9[1]=""
		End If
		If ls_desc[10] = "" or IsNull(ls_desc[10]) Then
			idw_data[1].Object.desc_t10[1]=""
		End If
		If ls_desc[11] = "" or IsNull(ls_desc[11]) Then
			idw_data[1].Object.desc_t11[1]=""
		End If
		If ls_desc[12] = "" or IsNull(ls_desc[12]) Then
			idw_data[1].Object.desc_t12[1]=""
		End If
		If ls_desc[13] = "" or IsNull(ls_desc[13]) Then
			idw_data[1].Object.desc_t13[1]=""
		End If
		If ls_desc[14] = "" or IsNull(ls_desc[14]) Then
			idw_data[1].Object.desc_t14[1]=""
		End If
		If ls_desc[15] = "" or IsNull(ls_desc[15]) Then
			idw_data[1].Object.desc_t15[1]=""
		End If			
								
	Case Else
		f_msg_info_app(9000, "b7u_dbmgr_2.uf_prc_db_01()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")
		Return

End Choose

ii_rc = 0
end subroutine

on b7u_dbmgr_2_mh.create
call super::create
end on

on b7u_dbmgr_2_mh.destroy
call super::destroy
end on

