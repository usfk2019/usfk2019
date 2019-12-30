$PBExportHeader$b7u_dbmgr_2.sru
$PBExportComments$[jybaek]
forward
global type b7u_dbmgr_2 from u_cust_a_db
end type
end forward

global type b7u_dbmgr_2 from u_cust_a_db
end type
global b7u_dbmgr_2 b7u_dbmgr_2

type prototypes

end prototypes

type variables
HProgressBar  hpb_data[]

end variables

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_04 ()
end prototypes

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
String ls_btrdesc[], ls_desc[], ls_admin_tel,ls_amt[]
String ls_culumn_nm, ls_surtax
int li_column_cnt

Dec ldc_surtax, ldc_curbalance, ldc_pre_balance

String ls_addr1, ls_addr2, ls_zipcode, ls_msg_fromdt
String ls_msg1, ls_msg2, ls_msg3, ls_msg4, ls_msg5, ls_pay_method
int li_temp_cnt 

SetNull(ls_null)

ii_rc = -1

Choose Case is_caller
	Case "b7w_prt_cms_notice_v%ue_ok"
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
			idw_data[1].Object.admin_tel[ll_curRow]   = ls_admin_tel
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
				idw_data[1].Object.receipt_acct_owner[ll_curRow] = ""
				idw_data[1].Object.receipt_bank[ll_curRow] = ""
				idw_data[1].Object.receipt_paydt[ll_curRow] = ""
				idw_data[1].Object.receipt_acct_no[ll_curRow] = ""
				idw_data[1].Object.receipt_customernm[ll_curRow] = ""
			End If	
			
			If ldc_receipt_payamt > 0 Then
				idw_data[1].Object.receipt_payamt[ll_curRow] = String(ldc_receipt_payamt,'#,##0')
			End If
			idw_data[1].Object.receipt_acct_owner[ll_curRow] = ls_receipt_acctowner
			idw_data[1].Object.receipt_bank[ll_curRow] = ls_receipt_banknm	
			idw_data[1].Object.receipt_paydt[ll_curRow] = ls_receipt_paydt
			idw_data[1].Object.receipt_acct_no[ll_curRow] = ls_receipt_acctno
			idw_data[1].Object.receipt_customernm[ll_curRow] = ls_receipt_customernm

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
 * 2005.09.22 juede
 * 1)"b7w_prt_giro_notice_v%ue_ok"
    : 브이텔레콤 지로 출력 
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
	Case "b7w_prt_giro_notice_v%ue_ok"
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

			idw_data[1].Object.issuedt[ll_curRow]			= ls_editdt  		//작성일

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
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If						

          //지로고객조회번호left
			ls_giro_customer_no_left = fs_giro_band_left(ls_payid, ls_trdt, li_delay_cnt , ls_delay_start_trdt)
			idw_data[1].Object.gironum_left[ll_curRow] = ls_giro_customer_no_left

         //지로고객조회번호 right
			ls_giro_customer_no_right = fs_giro_band_right(ldc_curbalance+ldc_prebalance) 
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

public subroutine uf_prc_db_06 ();String ls_ctype_10, ls_ctype_20, ls_result[], ls_temp, ls_recyn, ls_ctype2, ls_chargedt, ls_ref_desc, &
       ls_null, ls_busyn, ls_trdt, ls_usedt_fr, ls_usedt_to, ls_paydt, ls_editdt, ls_payid, ls_method[], &
		 ls_ocr_left, ls_ocr_right, ls_validkey_min, ls_bank, ls_account, ls_pay_method, ls_paydtbef, &
		 ls_acctno_bef1[], ls_acct_type_bef1[], ls_acct_owner_bef1[], ls_paydt1[], ls_cardnm, ls_banknm, &
		 ls_acctno_bef, ls_acct_type_bef, ls_acct_owner_bef, ls_pay_method_bef, ls_gubun
Long   ll_tot_amt, ll_supplyamt, ll_surtax, ll_curbalance, ll_prebalance, ll_payamt1[], ll_payamt
Int    li_validkey_cnt, i, ll_check

//개인
ls_ctype_10    = fs_get_control("B0", "P111", ls_ref_desc)
//법인
ls_temp	= fs_get_control("B0", "P110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
ls_ctype_20    = ls_result[1]

//지로, 자동이체,카드
ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_method[])
End If

SetNull(ls_null)
ii_rc = -1

Choose Case is_caller
	//통합지로
	Case "b7w_prt_giro_notice_naray%ue_ok"
		ls_busyn    = is_data[1]  //공급자표시구분 
		ls_recyn    = is_data[2]  //청구용/영수용  (영수용이면'rec' 청구용이면null)
		ls_trdt     = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_paydt    = is_data2[4]
		ls_editdt   = is_data2[5]		
		ls_payid    = is_data2[6]		
		
		ll_supplyamt = idw_data[1].object.supplyamt[1]		
		ll_surtax    = idw_data[1].object.surtax[1]
		ll_curbalance= idw_data[1].object.cur_balance[1]
		ll_prebalance= idw_data[1].object.pre_balance[1]
		ls_ctype2     = idw_data[1].object.ctype2[1]     // 법인구분
		
		If ls_recyn = 'REC' Then  //영수용
			ll_tot_amt = 0
		Else
			ll_tot_amt = ll_curbalance + ll_prebalance  
		End If
	
		ls_ocr_left  = b7fs_giro_band_left(ls_trdt, ls_payid)
		ls_ocr_right = b7fs_giro_band_right(ll_tot_amt)	
	/*  이게 몰까????
			//사용자번호 설정
			//2002-04-23 by kEnn 조건화면에서 사용자가 직접입력
			//2002-07-01 by kEnn SUBMST.subkind->SUBID/ANI#
			ll_findrow = idw_data[2].Find("payid = '" + ls_payid + "'", 1, ll_selrows)
			If ll_findrow > 0 Then
				ls_subid = idw_data[2].Object.subid[ll_findrow]
				ls_keysubid = ls_subid
			Else
				ls_subid = idw_data[1].Object.subcount_subid[ll_curRow]

				SELECT DECODE(s.subkind, :ls_subkind, a.anino, s.subid)
				INTO   :ls_keysubid
				FROM   SUBMST s, ANID a
				WHERE  s.subid = a.pid(+) AND s.subid = :ls_subid;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + ": SELECT FROM submst, anid")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					ls_keysubid = ls_subid
				End If
			End If
			
			*/ 
		SELECT min(validkey), Nvl(count(validkey),0)	
		  INTO :ls_validkey_min, :li_validkey_cnt
		  FROM validinfo
		 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
			 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
			 	 to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
			AND status     <> '10' 
			AND svctype    = '1'
			AND customerid = :ls_payid;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select validinfo")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			ls_validkey_min = '0'
			li_validkey_cnt = 0
		End If				
		
		idw_data[1].Object.workdt[1]       = ls_editdt  		//작성일
		idw_data[1].Object.trdt[1] 	     = ls_trdt			   //청구월(년월일)
//		idw_data[1].Object.reqdt[1] 	     = ls_editdt		   //청구일
		idw_data[1].Object.inputclosedt[1] = ls_paydt      	//납입기간
//		idw_data[1].Object.editdt[1] 	     = ls_editdt  		//작성일
		idw_data[1].Object.usedt_fr[1]     = ls_usedt_fr		//사용일
		idw_data[1].Object.usedt_to[1]     = ls_usedt_to		//사용일
		idw_data[1].Object.ocr_left[1]     = ls_ocr_left		//OCR1
		idw_data[1].Object.ocr_right[1]    = ls_ocr_right		//OCR2	
		idw_data[1].Object.validkey[1]     = fs_fill_pad(ls_validkey_min, 14, '2', ' ')	
		idw_data[1].Object.validcnt[1]     = fs_fill_pad(string(li_validkey_cnt), 6, '1', '0')
		
		//이게 모지???
		//idw_data[1].Object.ssubid[ll_curRow] 		= ls_keysubid	//사용자번호
		
		If ls_ctype2 = ls_ctype_20 Then //법인이면 사업자번호 찍어줌.... 
			If ls_busyn = "N" Then
				idw_data[1].Object.cregno[1] = "**********"
			End If
		Else
			idw_data[1].Object.cregno[1] = ls_null
			idw_data[1].Object.supplyamt[1] = Long(ls_null)
			idw_data[1].Object.surtax[1] = Long(ls_null)
		End If	
		If ls_recyn = 'REC' Then
			select sum(tramt) * -1
			  into :ll_payamt
			  from reqdtl a 
				  , trcode b       
			 where a.trcod = b.trcod
				and a.payid = :ls_payid
				and a.trdt  = :ls_trdt
				and b.in_yn = 'Y';
				
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select reqdtl")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				select sum(tramt) * -1
			     into :ll_payamt
				  from reqdtlh a 
					  , trcode b       
				 where a.trcod = b.trcod
					and a.payid = :ls_payid
					and a.trdt  = :ls_trdt
					and b.in_yn = 'Y';
//				SELECT NVL(sum(PAYAMT),0)
//				  into :ll_payamt
//				  FROM REQRECEIPT
//             where payid = :ls_payid
//               and trdt  = :ls_trdt ;
//				If SQLCA.sqlcode < 0 Then
//					f_msg_sql_err(is_Title, "Select reqdtl")
//					Return
//				ElseIf SQLCA.SQLCode = 100 Then	
//					SELECT NVL(sum(PAYAMT),0)
//					  into :ll_payamt
//				     FROM REQRECEIPTH
//                where payid = :ls_payid
//                  and trdt  = :ls_trdt ;
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, "Select reqdtlh")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						ll_payamt = 0
					End If
				//End If
			End If
			idw_data[1].Object.payamt[1] 	     = ll_payamt
		End If
		
	Case "b7w_prt_cms_notice_naray%ue_ok" //자동이체/카드
		
		ls_busyn    = is_data[1]  //공급자표시구분 
		ls_recyn    = is_data[2]  //청구용/영수용  (영수용이면'rec' 청구용이면null)
		ls_trdt     = is_data2[1]
		ls_usedt_fr = is_data2[2]
		ls_usedt_to = is_data2[3]
		ls_paydt    = is_data2[4]
		ls_editdt   = is_data2[5]		
		ls_payid    = is_data2[6]
		
		ls_chargedt = Trim(idw_data[1].Object.chargedt[1])
		ls_bank     = idw_data[1].Object.bank[1]
		ls_account  = idw_data[1].Object.account[1]
		ls_pay_method = idw_data[1].Object.pay_method[1]
		ls_ctype2     = idw_data[1].object.ctype2[1]     // 법인구분
		
      If IsNull(ls_bank)      Then ls_bank      = ""
		If IsNull(ls_account)   Then ls_account   = ""
		
		ls_account = LeftA(ls_account, 6) + FillA("*", LenA(ls_account) - 6)
			
		SELECT min(validkey), Nvl(count(validkey),0)	
		  INTO :ls_validkey_min, :li_validkey_cnt
		  FROM validinfo
		 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
			 OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
			 	 to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
			AND status     <> '10' 
			AND svctype    = '1'
			AND customerid = :ls_payid;

		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Select validinfo")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			ls_validkey_min = '0'
			li_validkey_cnt = 0
		End If				
		
		idw_data[1].Object.workdt[1]       = ls_editdt  		//작성일
		idw_data[1].Object.trdt[1] 	     = ls_trdt			   //청구월(년월일)
		idw_data[1].Object.inputclosedt[1] = ls_paydt      	//납입기간
		idw_data[1].Object.usedt_fr[1]     = ls_usedt_fr		//사용일
		idw_data[1].Object.usedt_to[1]     = ls_usedt_to		//사용일
		idw_data[1].Object.account[1]       = ls_account
		idw_data[1].Object.validkey[1]     = fs_fill_pad(ls_validkey_min, 14, '2', ' ')	
		idw_data[1].Object.validcnt[1]     = fs_fill_pad(string(li_validkey_cnt), 6, '1', '0')
		
		If ls_ctype2 = ls_ctype_20 Then //법인이면 사업자번호 찍어줌.... 
			If ls_busyn = "N" Then
				idw_data[1].Object.cregno[1] = "**********"
			End If
			idw_data[1].Object.sur_workdt[1] = ls_editdt
		Else
			idw_data[1].Object.cregno[1] = ls_null
			idw_data[1].Object.supplyamt[1] = Long(ls_null)
			idw_data[1].Object.surtax[1] = Long(ls_null)
			idw_data[1].Object.sur_workdt[1] = ls_null
		End If	
		
		For i = 1 To 2
			ls_acctno_bef1[i]    = ''
			ls_acct_type_bef1[i] = ''
			ls_acct_owner_bef1[i] = ''
			ls_paydt1[i]         = ''
			ll_payamt1[i]        = 0
		Next
		
		SELECT COUNT(PAYID)
		  INTO :ll_check
		  FROM REQRECEIPT
		 WHERE PAYID                      = :ls_payid
			AND to_char(TRDT, 'yyyymmdd')  = :ls_trdt  ;
		If ll_check = 0 Then
			SELECT COUNT(PAYID)
			  INTO :ll_check
			  FROM REQRECEIPTh
			 WHERE PAYID                      = :ls_payid
				AND to_char(TRDT, 'yyyymmdd')  = :ls_trdt  ;
			If ll_check = 0 Then
				ls_gubun = '0'
			Else//전월
				ls_gubun = '2'
			End If	
		Else //당월
			ls_gubun = '1'
		End If
		
		i = 1
		//당월
		If ls_gubun = '1' Then	
			DECLARE reqreceipt_cu CURSOR FOR
				SELECT ACCT_NO    //계좌번호,카드번호
					  , ACCT_TYPE  //은행code,카드코드
					  , ACCT_OWNER //예금주OR소유주
					  , to_char(PAYDT, 'yyyymmdd')  PAYDT     //전월 출금일
					  , pay_method
					  , PAYAMT   	//전월 출금액
				  FROM REQRECEIPT
				 WHERE PAYID                      = :ls_payid
					AND to_char(TRDT, 'yyyymmdd')  = :ls_trdt 				
					AND ROWNUM                    <= 2
			 ORDER BY PAYDT ;		
				OPEN reqreceipt_cu;
				
				DO WHILE (True)
					
					Fetch reqreceipt_cu
					Into :ls_acctno_bef, :ls_acct_type_bef, :ls_acct_owner_bef, :ls_paydtbef, :ls_pay_method_bef, :ll_payamt;
						
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Select REQRECEIPT Error")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
					
					If isnull(ls_acctno_bef) Then ls_acctno_bef = ''
					
					If ls_acctno_bef <> ''  Then
						ls_acctno_bef = LeftA(ls_acctno_bef, 6) + FillA("*", LenA(ls_acctno_bef) - 6)
					End If	
					
					If ls_pay_method_bef = ls_method[3] Then  //카드
						//카드사명 가져오기..
						select codenm 
						  into :ls_cardnm
						  from syscod2t 
						 where grcode = 'B450' 
							and code   = :ls_acct_type_bef;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' Error")
							CLOSE reqreceipt_cu;
							Return
						ElseIf SQLCA.SQLCode = 100 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' no data")
							CLOSE reqreceipt_cu;
							Return	
						End If 	
						
						ls_acctno_bef1[i]    = ls_acctno_bef
						ls_acct_type_bef1[i] = ls_cardnm
						ls_acct_owner_bef1[i] = ls_acct_owner_bef
						ls_paydt1[i]         = ls_paydtbef
						ll_payamt1[i]        = ll_payamt					
						
					Else						
						//은행명 가져오기..
						select codenm 
						  into :ls_banknm
						  from syscod2t 
						 where grcode = 'B400' 
							and code   = :ls_acct_type_bef;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' Error")
							CLOSE reqreceipt_cu;
							Return
						ElseIf SQLCA.SQLCode = 100 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' no data")
							CLOSE reqreceipt_cu;
							Return
						End If 			
						
						ls_acctno_bef1[i]    = ls_acctno_bef
						ls_acct_type_bef1[i] = ls_banknm
						ls_acct_owner_bef1[i] = ls_acct_owner_bef
						ls_paydt1[i]         = ls_paydtbef
						ll_payamt1[i]        = ll_payamt					
					End If	
					i ++						
				LOOP			
			CLOSE reqreceipt_cu;
		//전달 
		ElseIf ls_gubun = '2' Then		
			DECLARE reqreceipt_cu1 CURSOR FOR
				SELECT ACCT_NO    //계좌번호,카드번호
					  , ACCT_TYPE  //은행code,카드코드
					  , ACCT_OWNER //예금주OR소유주
					  , to_char(PAYDT, 'yyyymmdd')  PAYDT     //전월 출금일
					  , pay_method
					  , PAYAMT   	//전월 출금액
				  FROM REQRECEIPTh
				 WHERE PAYID                      = :ls_payid
					AND to_char(TRDT, 'yyyymmdd')  = :ls_trdt 				
					AND ROWNUM                    <= 2
			 ORDER BY PAYDT ;		
				OPEN reqreceipt_cu1;
				
				DO WHILE (True)
					
					Fetch reqreceipt_cu1
					Into :ls_acctno_bef, :ls_acct_type_bef, :ls_acct_owner_bef, :ls_paydtbef, :ls_pay_method_bef, :ll_payamt;
						
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_Title, "Select REQRECEIPT Error")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
					
					If isnull(ls_acctno_bef) Then ls_acctno_bef = ''
					
					If ls_acctno_bef <> ''  Then
						ls_acctno_bef = LeftA(ls_acctno_bef, 6) + FillA("*", LenA(ls_acctno_bef) - 6)
					End If	
					
					If ls_pay_method_bef = ls_method[3] Then  //카드
						//카드사명 가져오기..
						select codenm 
						  into :ls_cardnm
						  from syscod2t 
						 where grcode = 'B450' 
							and code   = :ls_acct_type_bef;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' Error")
							CLOSE reqreceipt_cu1;
							Return
						ElseIf SQLCA.SQLCode = 100 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' no data")
							CLOSE reqreceipt_cu1;
							Return	
						End If 	
						
						ls_acctno_bef1[i]    = ls_acctno_bef
						ls_acct_type_bef1[i] = ls_cardnm
						ls_acct_owner_bef1[i] = ls_acct_owner_bef
						ls_paydt1[i]         = ls_paydtbef
						ll_payamt1[i]        = ll_payamt					
						
					Else						
						//은행명 가져오기..
						select codenm 
						  into :ls_banknm
						  from syscod2t 
						 where grcode = 'B400' 
							and code   = :ls_acct_type_bef;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' Error")
							CLOSE reqreceipt_cu1;
							Return
						ElseIf SQLCA.SQLCode = 100 Then
							f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' no data")
							CLOSE reqreceipt_cu1;
							Return
						End If 			
						
						ls_acctno_bef1[i]    = ls_acctno_bef
						ls_acct_type_bef1[i] = ls_banknm
						ls_acct_owner_bef1[i] = ls_acct_owner_bef
						ls_paydt1[i]         = ls_paydtbef
						ll_payamt1[i]        = ll_payamt					
					End If	
					i ++						
				LOOP			
			CLOSE reqreceipt_cu1;
		End If
		
		idw_data[1].Object.accountbef[1] = ls_acctno_bef
		idw_data[1].Object.bankbef[1]    = ls_acct_type_bef1[1]
		idw_data[1].Object.ownerbef[1]   = ls_acct_owner_bef
		
		
		idw_data[1].Object.paydt1[1]  = ls_paydt1[1] 
		idw_data[1].Object.outamt1[1] = String(ll_payamt1[1], "#,##0")
		
		idw_data[1].Object.paydt2[1]  = ls_paydt1[2]
		idw_data[1].Object.outamt2[1] = String(ll_payamt1[2], "#,##0")
		
		If ll_payamt1[1] = 0 Then
			idw_data[1].Object.outamt1[1] = ls_null
			idw_data[1].Object.paydt1[1]  = ls_null
		End If
		If ll_payamt1[2] = 0 Then
			idw_data[1].Object.outamt2[1] = ls_null
			idw_data[1].Object.paydt2[1]  = ls_null
		End If
		
		If ls_pay_method =  ls_method[3] Then  //카드
			//카드사명 가져오기..
			select codenm 
			  into :ls_cardnm
			  from syscod2t 
			 where grcode = 'B450' 
				and code   = :ls_bank;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' Error")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B450' no data")
				Return	
			End If 	
			idw_data[1].Object.bank[1] = ls_cardnm
		Else
			//은행명 가져오기..
			select codenm 
			  into :ls_banknm
			  from syscod2t 
			 where grcode = 'B400' 
				and code   = :ls_bank;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' Error")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_sql_err(is_Title, "Select syscod2t grcode : 'B400' no data")
				Return
			End If 	
			idw_data[1].Object.bank[1] = ls_banknm
		End If	
		//영수용일때
		If ls_recyn = 'REC' Then
			select sum(tramt) * -1
			  into :ll_payamt
			  from reqdtl a 
				  , trcode b       
			 where a.trcod = b.trcod
				and a.payid = :ls_payid
				and a.trdt  = :ls_trdt
				and b.in_yn = 'Y';
				
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Select reqdtl")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				select sum(tramt) * -1
			     into :ll_payamt
				  from reqdtlh a 
					  , trcode b       
				 where a.trcod = b.trcod
					and a.payid = :ls_payid
					and a.trdt  = :ls_trdt
					and b.in_yn = 'Y';
//				SELECT NVL(sum(PAYAMT),0)
//				  into :ll_payamt
//				  FROM REQRECEIPT
//             where payid = :ls_payid
//               and trdt  = :ls_trdt ;
//				If SQLCA.sqlcode < 0 Then
//					f_msg_sql_err(is_Title, "Select reqdtl")
//					Return
//				ElseIf SQLCA.SQLCode = 100 Then	
//					SELECT NVL(sum(PAYAMT),0)
//					  into :ll_payamt
//				     FROM REQRECEIPTH
//                where payid = :ls_payid
//                  and trdt  = :ls_trdt ;
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, "Select reqdtlh")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						ll_payamt = 0
					End If
				//End If
			End If
			idw_data[1].Object.payamt[1] 	     = ll_payamt
		End If
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

on b7u_dbmgr_2.create
call super::create
end on

on b7u_dbmgr_2.destroy
call super::destroy
end on

