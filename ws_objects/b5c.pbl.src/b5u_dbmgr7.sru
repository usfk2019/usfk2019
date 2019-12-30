$PBExportHeader$b5u_dbmgr7.sru
$PBExportComments$[islim] 청구자료 대행업체에 보내기
forward
global type b5u_dbmgr7 from u_cust_a_db
end type
end forward

global type b5u_dbmgr7 from u_cust_a_db
end type
global b5u_dbmgr7 b5u_dbmgr7

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();String ls_cms_file, ls_giro_file, ls_day,ls_ref_desc, ls_giro, ls_cms, ls_use_from, ls_use_to
String ls_buffer, ls_tmp, ls_name[], ls_null, ls_code, ls_code1, ls_person, ls_code_pos[]
String ls_payid, ls_inputclosedt, ls_customernm, ls_addr1, ls_addr2, ls_zipcod, ls_location, ls_buildingno, ls_ctype2, ls_cregno
String ls_roomno, ls_supplyamt, ls_pre_balance, ls_cur_balance, ls_trdt, ls_btramt[], ls_totamt, ls_use_month, ls_surtax
String ls_line, ls_itemcod, ls_aptid, ls_buildingid, ls_houseid, ls_user_name, ls_id_name, ls_memberid, ls_locationnm
String ls_acct_owner, ls_bank
String ls_inputdeadline

//추가
String ls_phone1, ls_use_year, ls_use_day, ls_card , ls_girono, ls_qnacenterp, ls_qnacenterf, ls_custom_no
String ls_pre_desc, ls_btrdesc[], ls_paymethod, ls_cardno
String ls_paydt, ls_payamt  , ls_this_amt
//전월영수증
String ls_re_paymethod, ls_re_acct_type , ls_acct_no
String ls_re_customernm, ls_re_phone1, ls_re_acct_owner, ls_re_card_holder, ls_acct_type
String ls_re_totpayamt, ls_re_paydt
String ls_payid_t

Dec lc_totamt_de, lc_rate, lc_dealy_amt, lc_this_amt
long ll_format, ll_count, ll_contractseq, i, ll_line, ll_user_count, ll_totline
Int li_write_bytes, li_filenum, li_pos , li_lencount

 	String ls_outdt
	String ls_bank_name
	
	String ls_trdt_prev
	String ls_acct_owner_receipt
	String ls_acct_no_receipt
	String ls_bank_receipt
	String ls_bank_name_receipt , ls_card_name_receipt
	String ls_amt_receipt
	String ls_transdt_receipt
	String ls_usage_receipt
	
Long ll_amt_receipt

ii_rc = -1
Choose Case is_caller
	Case "Create Invoice Kilt"
//		lu_dbmgr.is_caller = "Create Invoice"
//		lu_dbmgr.is_data[1] = is_chargedt
//		lu_dbmgr.is_data[2] = is_trdt
//		lu_dbmgr.is_data[3] = is_giro_yn
//		lu_dbmgr.is_data[4] = is_cms_yn
//    lu_dbmgr.is_data[5] = is_giro_file
//    lu_dbmgr.is_data[6] = is_cms_file
//    lu_dbmgr.is_data[7] = is_qnacenterp
//    lu_dbmgr.is_data[8] = is_qnacenterf
//		lu_dbmgr.is_data[9] = is_pre_desc


//날짜 읽어온다.
ls_giro_file = is_data[5]
ls_cms_file = is_data[6]
ls_qnacenterp=is_data[7]
ls_qnacenterf=is_data[8]
ls_pre_desc = is_data[9]

ls_day = fs_get_control("B5","P103", ls_ref_desc)

//Paymethod
ls_giro = fs_get_control("B0", "P129", ls_ref_desc)  //지로 - 1
ls_cms = fs_get_control("B0", "P130", ls_ref_desc)   //자동이체 - 2
ls_card = fs_get_control("B0", "P131", ls_ref_desc)  //카드 -3

//연체요율
ls_tmp= fs_get_control("B5", "T105", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
lc_rate = Long(ls_name[2]) //연체율(%)
//소수점 자릿수
ll_format = Long(fs_get_control("B5", "H200", ls_ref_desc))
ll_count = 0 
ll_line = 0
ll_user_count = 0
ll_totline = 0
ls_id_name  = ""
ls_itemcod = ""
ls_line = ""
//개인고객코드
ls_person = fs_get_control("B0", "P111", ls_ref_desc)

//연체료, 절사액 Index
//ls_tmp= fs_get_control("B5", "T110", ls_ref_desc)
//fi_cut_string(ls_tmp, ";", ls_code_pos[])
//지로번호
ls_girono = fs_get_control("B5", "B104", ls_ref_desc)

//지로 파일 생성
If is_data[3] = 'Y' Then
	
	//File Open
	li_filenum = FileOpen(ls_giro_file, LineMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then
		f_msg_usr_err(9000, is_Title, "File Open Failed!")
		FileClose(li_filenum)			
		Return
	End If
	
	//Reqinfo Table Select 고객의 정보를 Select
	DECLARE cur_get_reqinfo CURSOR FOR
		  Select info.payid, 											//납입자 ID 
					to_char(info.inputclosedtcur, 'yyyymmdd'),   //입금마감일 
					info.customernm,  									//고객이름 
					info.bil_addr1,   									//청구지주소 
					info.bil_addr2,   									//청구지주소 
					info.ctype2,      									//개인법인구분 
					info.cregno,      									//사업자번호 
					info.bil_zipcod,  									//청구지우편번호 
					cus.phone1,       									//고객전화번호 
					to_char(nvl(amt.supplyamt,0)),               //공급가액 
					to_char(nvl(amt.pre_balance,0)),             //전월Balance 
					to_char(nvl(amt.cur_balance,0)),             //당월Balance 
					to_char(info.trdt, 'yyyymmdd'),              //청구기준일 
					to_char(amt.cur_balance + amt.pre_balance),  // 총 Balance 
					to_char(add_months(info.trdt,-1), 'yyyymm'), // 청구년월 
					to_char(nvl(amt.surtax,0)),                    //부가세 
					to_char(nvl(amt.btramt01,0)),                  //청구금액 
					to_char(nvl(amt.btramt02,0)),
					to_char(nvl(amt.btramt03,0)),
					to_char(nvl(amt.btramt04,0)),
					to_char(nvl(amt.btramt05,0)),
					to_char(nvl(amt.btramt06,0)),
					to_char(nvl(amt.btramt07,0)),
					to_char(nvl(amt.btramt08,0)),
					to_char(nvl(amt.btramt09,0)),
					to_char(nvl(amt.btramt10,0)),
					to_char(nvl(amt.btramt11,0)),                  //청구금액 
					to_char(nvl(amt.btramt12,0)),
					to_char(nvl(amt.btramt13,0)),
					to_char(nvl(amt.btramt14,0)),
					to_char(nvl(amt.btramt15,0)),
					to_char(nvl(amt.btramt16,0)),
					to_char(nvl(amt.btramt17,0)),					
					amt.btrdesc01,                 
					amt.btrdesc02,
					amt.btrdesc03,
					amt.btrdesc04,
					amt.btrdesc05,
					amt.btrdesc06,
					amt.btrdesc07,
					amt.btrdesc08,
					amt.btrdesc09,
					amt.btrdesc10,
					amt.btrdesc11,
					amt.btrdesc12,
					amt.btrdesc13,
					amt.btrdesc14,
					amt.btrdesc15,
					amt.btrdesc16,
					amt.btrdesc17
		from reqinfo info, reqamtinfo amt, customerm cus
		where info.payid = amt.payid 
				 and info.payid = cus.customerid  
				 and to_char(info.trdt, 'yyyymmdd') = :is_data[2] 
				 and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
				 and info.chargedt =:is_data[1]  //청구주기 
				 and amt.chargedt = :is_data[1]  // 청구주기 
				 and info.pay_method = :ls_giro  //납입방법 
				 and info.inv_yn = 'Y'    //청구서 발송여부 
		order by info.payid;
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
		Return
	End If
	

    					
	//커서 Open
	OPEN cur_get_reqinfo;
	Do While(True)
		FETCH cur_get_reqinfo
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_phone1, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
			  :ls_trdt, :ls_totamt, :ls_use_month, :ls_surtax,
			  :ls_btramt[1],
			  :ls_btramt[2],
			  :ls_btramt[3],
			  :ls_btramt[4],
			  :ls_btramt[5],
			  :ls_btramt[6],
			  :ls_btramt[7],
			  :ls_btramt[8],
			  :ls_btramt[9],
			  :ls_btramt[10],
			  :ls_btramt[11],
			  :ls_btramt[12],
			  :ls_btramt[13],
			  :ls_btramt[14],
			  :ls_btramt[15],
			  :ls_btramt[16],
			  :ls_btramt[17],			  
  			  :ls_btrdesc[1],
			  :ls_btrdesc[2],
			  :ls_btrdesc[3],
			  :ls_btrdesc[4],
			  :ls_btrdesc[5],
			  :ls_btrdesc[6],
			  :ls_btrdesc[7],
			  :ls_btrdesc[8],
			  :ls_btrdesc[9],
			  :ls_btrdesc[10],
  			  :ls_btrdesc[11],
			  :ls_btrdesc[12],
			  :ls_btrdesc[13],
			  :ls_btrdesc[14],
			  :ls_btrdesc[15],
			  :ls_btrdesc[16],
			  :ls_btrdesc[17];
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo")
		CLOSE cur_get_reqinfo;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	//입금마감일(매월말일)
//	ls_inputdeadline = String( &
//								f_mon_last_date(Date(Integer(Mid(ls_trdt, 1, 4)), &
//						 				Integer(Mid(ls_trdt, 5, 2)), &
//						 				Integer(Mid(ls_trdt, 7, 2)) &
//										 )) &
//								,"yyyymmdd" &
//							)
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	
	//사용시작일 구하기
	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
							 
	ls_use_year = LeftA(ls_use_month,4)
	ls_use_day = RightA(ls_use_month,2)
	
	//고객조회번호
	ls_custom_no = ls_trdt + ls_payid + "000"
							 

	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "01"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                              	  //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	If LenA(ls_phone1) >20 Then LeftA(ls_phone1, 20)
	ls_buffer += fs_fill_spaces(ls_phone1,20)				 				//전화번호
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   	//주소1
	If LenA(ls_addr2) > 100 Then LeftA(ls_addr2, 100)
	ls_buffer += fs_fill_spaces(ls_addr2, 100)                    	//주소2
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//고객이름
	If LenA(ls_zipcod) > 8 Then LeftA(ls_zipcod,8)
	ls_buffer += LeftA(ls_zipcod,3)
	ls_buffer += "-"
	ls_buffer += MidA(ls_zipcod,4,3)
	//ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer +=Space(1)
	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       	//작성일자(작성기준일?)	
	
	If LenA(ls_qnacenterp)>20 Then LeftA(ls_qnacenterp,20)   			//고객센터전화
	ls_buffer +=fs_fill_spaces(ls_qnacenterp, 20)
	If LenA(ls_qnacenterf)>20 Then LeftA(ls_qnacenterf,20)
	ls_buffer +=fs_fill_spaces(ls_qnacenterf, 20)
	ls_buffer += "OC"																//지로
	ls_buffer += LeftA(ls_trdt,4)   									   	//청구년도
	ls_buffer += MidA(ls_trdt,5,2)									   	   //청구월
   ls_buffer +=ls_use_from
   ls_buffer +=ls_use_to
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//납부자이름

	ls_buffer += fs_fill_spaces(ls_inputclosedt, 8) 				 	//납기기한

	ls_buffer += fs_fill_spaces("",30)      								//계좌번호
	ls_buffer += fs_fill_spaces(ls_supplyamt, -10)                	//공급가액
	ls_buffer += fs_fill_spaces(ls_surtax, -10)                   	//세액
	ls_buffer += ls_custom_no											      //고객조회번호
	ls_buffer += ls_girono                                         //girono
	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   	//청구금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,20)
		ls_buffer += fs_fill_spaces(ls_cregno, 20)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 20)
	END IF
	ls_buffer += Space(67)	

	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo;
		ii_rc = -2
		Return 
	End If
		//최기화
	ls_buffer = ""

	
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "02"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                 //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
		
	If Dec(ls_pre_balance) <> 0 Then 
		ls_buffer+= fs_fill_spaces(ls_pre_desc, 20)                //미납금액
		ls_buffer+= fs_fill_spaces(ls_pre_balance, -10)           
		li_lencount +=30
	End IF
	
	FOR li_pos = 1 to 17
		IF ls_btrdesc[li_pos] <> "" THEN
			ls_buffer += fs_fill_spaces(ls_btrdesc[li_pos], 20)      //이용금액
			ls_buffer += fs_fill_spaces(ls_btramt[li_pos], -10)
			li_lencount+=30
		END IF
	NEXT
	
	If li_lencount < 510 Then
		ls_buffer+=Space(510 - li_lencount)
	End if


	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   //청구금액
	
	If Dec(ls_pre_balance) <>0 Then									    //전월미납액
		ls_buffer+=fs_fill_spaces(ls_pre_balance, -10)
	Else
		ls_buffer+=Space(10)
	End If
	
   lc_this_amt = Dec(ls_totamt) - Dec(ls_pre_balance)
	

	ls_buffer +=fs_fill_spaces(String(lc_this_amt), -10)   //당월금액
	
	
	//ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //납기내 금액
	//ls_buffer += fs_fill_zeroes(String(lc_totamt_de), -11)       //납기후 금액
	//	ls_buffer += fs_fill_zeroes(ls_code, 22)                      //이용내역 Code
	//	ls_buffer += fs_fill_zeroes(ls_code1,121)                     //이용요금

	ls_buffer += Space(41)
	//ls_buffer +='~n'
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo;
		ii_rc = -2
		Return 
	End If
   
	ll_count += 1
	//최기화
	ls_buffer = ""
	ll_line = 0
	ll_user_count = 0
	ll_totline = 0
	ls_id_name  = ""
	ls_itemcod = ""
	ls_line = ""
	ls_code = ""
	ls_code1 = ""
	li_lencount= 0
	il_data[1] = ll_count
	Loop
	CLOSE cur_get_reqinfo;
	
	//File Close
	If ll_count <= 0 Then
	   ii_rc = -2
		FileClose(li_filenum)
		Return
	End If
		
	FileClose(li_filenum)
	ls_giro_file = ""
End If




//자동이체 파일 생성================================================================================
If is_data[4] = 'Y' Then
	
	//File Open
	li_filenum = FileOpen(ls_cms_file, LineMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then
		f_msg_usr_err(9000, is_Title, "File Open Failed!")
		FileClose(li_filenum)			
		Return
	End If

	//Reqinfo Table Select 고객의 정보를 Select
	DECLARE cur_get_reqinfo2 CURSOR FOR	
	  Select info.payid, 											//납입자 ID 
					to_char(info.inputclosedtcur, 'yyyymmdd'),   //입금마감일 
					info.customernm,  									//고객이름 
					info.bil_addr1,   									//청구지주소 
					info.bil_addr2,   									//청구지주소 
					info.ctype2,      									//개인법인구분 
					info.cregno,      									//사업자번호 
					info.bil_zipcod,  									//청구지우편번호 
					info.pay_method,										//납부방법
					cus.phone1,       									//고객전화번호 
					to_char(nvl(amt.supplyamt,0)),               //공급가액 
					to_char(nvl(amt.pre_balance,0)),             //전월Balance 
					to_char(nvl(amt.cur_balance,0)),             //당월Balance 
					to_char(info.trdt, 'yyyymmdd'),              //청구기준일 
					to_char(amt.cur_balance + amt.pre_balance),  // 총 Balance 
					to_char(add_months(info.trdt,-1), 'yyyymm'), // 청구년월 
					to_char(nvl(amt.surtax,0)),                    //부가세 
					to_char(nvl(amt.btramt01,0)),                  //청구금액 
					to_char(nvl(amt.btramt02,0)),
					to_char(nvl(amt.btramt03,0)),
					to_char(nvl(amt.btramt04,0)),
					to_char(nvl(amt.btramt05,0)),
					to_char(nvl(amt.btramt06,0)),
					to_char(nvl(amt.btramt07,0)),
					to_char(nvl(amt.btramt08,0)),
					to_char(nvl(amt.btramt09,0)),
					to_char(nvl(amt.btramt10,0)),
					to_char(nvl(amt.btramt11,0)),                  //청구금액 
					to_char(nvl(amt.btramt12,0)),
					to_char(nvl(amt.btramt13,0)),
					to_char(nvl(amt.btramt14,0)),
					to_char(nvl(amt.btramt15,0)),
					to_char(nvl(amt.btramt16,0)),
					to_char(nvl(amt.btramt17,0)),					
					amt.btrdesc01,                 
					amt.btrdesc02,
					amt.btrdesc03,
					amt.btrdesc04,
					amt.btrdesc05,
					amt.btrdesc06,
					amt.btrdesc07,
					amt.btrdesc08,
					amt.btrdesc09,
					amt.btrdesc10,
					amt.btrdesc11,
					amt.btrdesc12,
					amt.btrdesc13,
					amt.btrdesc14,
					amt.btrdesc15,
					amt.btrdesc16,
					amt.btrdesc17
		from reqinfo info, reqamtinfo amt, customerm cus
		where info.payid = amt.payid 
				 and info.payid = cus.customerid  
				 and to_char(info.trdt, 'yyyymmdd') = :is_data[2] 
				 and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
				 and info.chargedt =:is_data[1]  //청구주기 
				 and amt.chargedt = :is_data[1]  // 청구주기 
			    and (info.pay_method = :ls_cms  or info.pay_method = :ls_card)  //납입방법 
				 and info.inv_yn = 'Y'    //청구서 발송여부 
		order by info.payid;
			
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
		Return
	End If
	
	

	//커서 Open
	OPEN cur_get_reqinfo2;
	Do While(True)
		FETCH cur_get_reqinfo2
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_paymethod,:ls_phone1, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
			  :ls_trdt, :ls_totamt, :ls_use_month, :ls_surtax,
			  :ls_btramt[1],
			  :ls_btramt[2],
			  :ls_btramt[3],
			  :ls_btramt[4],
			  :ls_btramt[5],
			  :ls_btramt[6],
			  :ls_btramt[7],
			  :ls_btramt[8],
			  :ls_btramt[9],
			  :ls_btramt[10],
			  :ls_btramt[11],
			  :ls_btramt[12],
			  :ls_btramt[13],
			  :ls_btramt[14],
			  :ls_btramt[15],
			  :ls_btramt[16],
			  :ls_btramt[17],			  
  			  :ls_btrdesc[1],
			  :ls_btrdesc[2],
			  :ls_btrdesc[3],
			  :ls_btrdesc[4],
			  :ls_btrdesc[5],
			  :ls_btrdesc[6],
			  :ls_btrdesc[7],
			  :ls_btrdesc[8],
			  :ls_btrdesc[9],
			  :ls_btrdesc[10],
  			  :ls_btrdesc[11],
			  :ls_btrdesc[12],
			  :ls_btrdesc[13],
			  :ls_btrdesc[14],
			  :ls_btrdesc[15],
			  :ls_btrdesc[16],
			  :ls_btrdesc[17];
			  
			  
			  
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo2")
		CLOSE cur_get_reqinfo2;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	
	
	//입금마감일(매월말일)
//	ls_inputdeadline = String( &
//								f_mon_last_date(Date(Integer(Mid(ls_trdt, 1, 4)), &
//						 				Integer(Mid(ls_trdt, 5, 2)), &
//						 				Integer(Mid(ls_trdt, 7, 2)) &
//										 )) &
//								,"yyyymmdd" &
//							)
							
	//전월청구일
	ls_trdt_prev = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	

	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	ls_use_year = LeftA(ls_use_month,4)
	ls_use_day = RightA(ls_use_month,2)
							 
	//고객조회번호
	ls_custom_no = ls_trdt + ls_payid + "000"

	//전월영수금액, 납부일자 가져오기
    select  sum(nvl(payamt,0)), to_char(max(paydt),'yyyy/mm/dd')
	 INTO :ls_re_totpayamt, :ls_re_paydt
    from reqreceipt
		  where payid=:ls_payid
		  	and  to_char(trdt,'yyyymmdd') =:ls_trdt_prev
			and  pay_method <> :ls_giro;
			
	//Error
	If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(reqreceipt_amt)")
	  Return
	//No Result
   ElseIf SQLCA.sqlcode  = 100 Then
	  ls_re_totpayamt="0"
	  ls_re_paydt=""
   End If


   SELECT distinct(re.payid), cus.phone1, cus.customernm, re.pay_method, re.acct_type, re.acct_no,
          info.acct_owner, info.card_holder
	INTO :ls_payid_t,:ls_re_phone1, :ls_re_customernm, :ls_re_paymethod, :ls_acct_type,
		  :ls_acct_no, :ls_re_acct_owner,:ls_re_card_holder
   FROM reqinfoh info, reqreceipt re, customerm cus
   WHERE re.payid = :ls_payid 
    and  info.payid = :ls_payid
    and  cus.customerid = :ls_payid
    and  to_char(re.trdt,'yyyymmdd') = :ls_trdt_prev
    and  to_char(info.trdt,'yyyymmdd') = :ls_trdt_prev;
	
	
	 //Error
	If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(reqreceipt_info)")
	  Return
	//No Result
   ElseIf SQLCA.sqlcode  = 100 Then
	  ls_re_phone1=""
	  ls_re_customernm=""
	  ls_re_paymethod=""
	  ls_acct_type=""
	  ls_acct_no=""
	  ls_re_acct_owner=""
	  ls_re_card_holder=""
   End If


	
	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "01"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	If LenA(ls_phone1) >20 Then LeftA(ls_phone1, 20)
	ls_buffer += fs_fill_spaces(ls_phone1,20)				 				//전화번호
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   	//주소1
	If LenA(ls_addr2) > 100 Then LeftA(ls_addr2, 100)
	ls_buffer += fs_fill_spaces(ls_addr2, 100)                    	//주소2
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//고객이름
	If LenA(ls_zipcod) > 8 Then LeftA(ls_zipcod,8)
//	ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer += LeftA(ls_zipcod,3)
	ls_buffer += "-"
	ls_buffer += MidA(ls_zipcod,4,3)
	//ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer +=Space(1)

	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       	//작성일자(작성기준일?)	
	
	If LenA(ls_qnacenterp)>20 Then LeftA(ls_qnacenterp,20)   			//고객센터전화
	ls_buffer +=fs_fill_spaces(ls_qnacenterp, 20)
	If LenA(ls_qnacenterf)>20 Then LeftA(ls_qnacenterf,20)
	ls_buffer +=fs_fill_spaces(ls_qnacenterf, 20)
	
	If ls_paymethod = ls_card Then
		ls_buffer += "CT"															//카드이체
	ElseIf ls_paymethod = ls_cms Then
		ls_buffer +="AT"															//계좌이체
	End IF							
	
	ls_buffer += LeftA(ls_trdt,4)   									   	//청구년도
	ls_buffer += MidA(ls_trdt,5,2)									   	   //청구월
   ls_buffer +=ls_use_from
   ls_buffer +=ls_use_to
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//납부자이름

	
	ls_buffer += fs_fill_spaces(ls_inputclosedt, 8) 				 	//납기기한
	
	If ls_paymethod = ls_cms Then
		If LenA(ls_acct_no_receipt)>30 Then LeftA(ls_acct_no_receipt,30)
		ls_buffer += fs_fill_spaces(ls_acct_no_receipt,30)      			//계좌번호
	ElseIf ls_paymethod = ls_card Then
		If LenA(ls_cardno) > 30 Then LeftA(ls_cardno,30)
		ls_buffer += fs_fill_spaces(ls_cardno, 30)							//카드번호
	Else
		ls_buffer += fs_fill_spaces("",30)     
	End If
	
	ls_buffer += fs_fill_spaces(ls_supplyamt, -10)                	//공급가액
	ls_buffer += fs_fill_spaces(ls_surtax, -10)                   	//세액
	ls_buffer += ls_custom_no													//고객조회번호
	ls_buffer += ls_girono                                         //girono
	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   	//청구금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,20)
		ls_buffer += fs_fill_spaces(ls_cregno, 20)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 20)
	END IF
	
	ls_buffer += Space(67)
	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If
	ls_buffer=""
	

	
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "02"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
		
	If Dec(ls_pre_balance) <> 0 Then 
		ls_buffer += fs_fill_spaces(ls_pre_desc, 20)                //미납금액
		ls_buffer += fs_fill_spaces(ls_pre_balance, -10)   
		li_lencount+=30
	End IF
	
	FOR li_pos = 1 to 17
		IF ls_btrdesc[li_pos] <> "" THEN
			ls_buffer += fs_fill_spaces(ls_btrdesc[li_pos], 20)      //이용금액
			ls_buffer += fs_fill_spaces(ls_btramt[li_pos], -10)          
			li_lencount+=30
		END IF
	NEXT


	If li_lencount < 510 Then
		ls_buffer+=Space(510 - li_lencount)
	End if


	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   //청구금액
	
	If Dec(ls_pre_balance) <>0 Then									    //전월미납액
		ls_buffer+=fs_fill_spaces(ls_pre_balance, -10)
	Else
		ls_buffer+=Space(10)
	End If
	
	
   lc_this_amt = Dec(ls_totamt) - Dec(ls_pre_balance)
	

	ls_buffer +=fs_fill_spaces(String(lc_this_amt), -10)   //당월금액

	ls_buffer += Space(41)
	
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If
	
	ls_buffer = ""
	li_lencount=0
	
	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "05"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호

	ls_buffer += fs_fill_spaces(ls_re_phone1, 13)
	ls_buffer += fs_fill_spaces(ls_re_customernm, 50)
	
	If ls_re_paymethod = ls_cms Then
		ls_buffer += fs_fill_spaces("계좌이체", 20)
		//거래은행명
		SELECT codenm
		INTO :ls_bank_name_receipt
		FROM syscod2t
		WHERE grcode = 'B400'
		AND code = :ls_acct_type;
		ls_buffer += fs_fill_spaces(ls_bank_name_receipt, 40)
	   ls_buffer += fs_fill_spaces(ls_re_acct_owner, 50)
		ls_buffer += fs_fill_spaces(ls_acct_no, 20)
	ElseIf ls_re_paymethod = ls_card Then
		ls_buffer += fs_fill_spaces("카드이체", 20)
		//거래카드명
		SELECT codenm
		INTO :ls_card_name_receipt
		FROM syscod2t
		WHERE grcode = 'B450'
		AND code = :ls_acct_type;
		ls_buffer += fs_fill_spaces(ls_card_name_receipt, 40)
	   ls_buffer += fs_fill_spaces(ls_re_card_holder, 50)		
		ls_buffer += fs_fill_spaces(ls_acct_no, 20)		
	Else
		ls_buffer += fs_fill_spaces("",20)	
		ls_buffer += fs_fill_spaces("", 40)
	   ls_buffer += fs_fill_spaces("", 50)		
		ls_buffer += fs_fill_spaces("", 20)		

	End If



	ls_buffer += fs_fill_spaces(ls_re_paydt,10)
	ls_buffer += fs_fill_spaces(ls_re_totpayamt, -10)
	ls_buffer += Space(368)
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If


   
	ll_count += 1
	//최기화
	ls_buffer = ""
	ll_line = 0
	ll_user_count = 0
	ll_totline = 0
	ls_id_name  = ""
	ls_itemcod = ""
	ls_line = ""
	ls_code = ""
	ls_code1 = ""
	il_data[1] = ll_count
	li_lencount= 0
	Loop
	CLOSE cur_get_reqinfo2;
	
	//File Close
	If ll_count <= 0 Then
	   ii_rc = -2
		FileClose(li_filenum)
		Return
	End If
		
	FileClose(li_filenum)
	ls_cms_file = ""
End If

End Choose

ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_01 ();String ls_cms_file, ls_giro_file, ls_day,ls_ref_desc, ls_giro, ls_cms, ls_use_from, ls_use_to
String ls_buffer, ls_tmp, ls_name[], ls_null, ls_code, ls_code1, ls_person, ls_code_pos[]
String ls_payid, ls_inputclosedt, ls_customernm, ls_addr1, ls_addr2, ls_zipcod, ls_location, ls_buildingno, ls_ctype2, ls_cregno
String ls_roomno, ls_supplyamt, ls_pre_balance, ls_cur_balance, ls_trdt, ls_btramt[], ls_totamt, ls_use_month, ls_surtax
String ls_line, ls_itemcod, ls_aptid, ls_buildingid, ls_houseid, ls_user_name, ls_id_name, ls_memberid, ls_locationnm
String ls_acct_owner, ls_bank
String ls_inputdeadline

//추가
String ls_phone1, ls_use_year, ls_use_day, ls_card , ls_girono, ls_qnacenterp, ls_qnacenterf, ls_custom_no
String ls_pre_desc, ls_btrdesc[], ls_paymethod, ls_cardno
String ls_paydt, ls_payamt  , ls_this_amt
//전월영수증
String ls_re_paymethod, ls_re_acct_type , ls_acct_no
String ls_re_customernm, ls_re_phone1, ls_re_acct_owner, ls_re_card_holder, ls_acct_type
String ls_re_totpayamt, ls_re_paydt
String ls_payid_t

Dec lc_totamt_de, lc_rate, lc_dealy_amt, lc_this_amt
long ll_format, ll_count, ll_contractseq, i, ll_line, ll_user_count, ll_totline
Int li_write_bytes, li_filenum, li_pos , li_lencount

String ls_outdt
String ls_bank_name

String ls_trdt_prev
String ls_acct_owner_receipt
String ls_acct_no_receipt
String ls_bank_receipt
String ls_bank_name_receipt , ls_card_name_receipt
String ls_amt_receipt
String ls_transdt_receipt
String ls_usage_receipt

String ls_giro_delay_file
	
Long ll_amt_receipt

ii_rc = -1
Choose Case is_caller
	Case "Create Invoice Kilt 2"
//		lu_dbmgr.is_caller = "Create Invoice"
//		lu_dbmgr.is_data[1] = is_chargedt
//		lu_dbmgr.is_data[2] = is_trdt
//		lu_dbmgr.is_data[3] = is_giro_yn
//		lu_dbmgr.is_data[4] = is_cms_yn
//    lu_dbmgr.is_data[5] = is_giro_file
//    lu_dbmgr.is_data[6] = is_cms_file
//    lu_dbmgr.is_data[7] = is_qnacenterp
//    lu_dbmgr.is_data[8] = is_qnacenterf
//		lu_dbmgr.is_data[9] = is_pre_desc
//    lu_dbmgr.is_data[10] = is_giro_file_delay
//    lu_dbmgr.is_data[11] = is_giro_delay_yn


//날짜 읽어온다.
ls_giro_file = is_data[5]
ls_cms_file = is_data[6]
ls_qnacenterp=is_data[7]
ls_qnacenterf=is_data[8]
ls_pre_desc = is_data[9]
ls_giro_delay_file = is_data[10]


ls_day = fs_get_control("B5","P103", ls_ref_desc)

//Paymethod
ls_giro = fs_get_control("B0", "P129", ls_ref_desc)  //지로 - 1
ls_cms = fs_get_control("B0", "P130", ls_ref_desc)   //자동이체 - 2
ls_card = fs_get_control("B0", "P131", ls_ref_desc)  //카드 -3

//연체요율
ls_tmp= fs_get_control("B5", "T105", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
lc_rate = Long(ls_name[2]) //연체율(%)
//소수점 자릿수
ll_format = Long(fs_get_control("B5", "H200", ls_ref_desc))
ll_count = 0 
ll_line = 0
ll_user_count = 0
ll_totline = 0
ls_id_name  = ""
ls_itemcod = ""
ls_line = ""
//개인고객코드
ls_person = fs_get_control("B0", "P111", ls_ref_desc)

//연체료, 절사액 Index
//ls_tmp= fs_get_control("B5", "T110", ls_ref_desc)
//fi_cut_string(ls_tmp, ";", ls_code_pos[])
//지로번호
ls_girono = fs_get_control("B5", "B104", ls_ref_desc)

//지로 파일 생성
If is_data[3] = 'Y' Then
	
	
	//File Open
	li_filenum = FileOpen(ls_giro_file, LineMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then
		f_msg_usr_err(9000, is_Title, "File Open Failed!")
		FileClose(li_filenum)			
		Return
	End If

	
	//Reqinfo Table Select 고객의 정보를 Select
	DECLARE cur_get_reqinfo CURSOR FOR
		  Select info.payid, 											//납입자 ID 
					to_char(info.inputclosedtcur, 'yyyymmdd'),   //입금마감일 
					info.customernm,  									//고객이름 
					info.bil_addr1,   									//청구지주소 
					info.bil_addr2,   									//청구지주소 
					info.ctype2,      									//개인법인구분 
					info.cregno,      									//사업자번호 
					info.bil_zipcod,  									//청구지우편번호 
					cus.phone1,       									//고객전화번호 
					to_char(nvl(amt.supplyamt,0)),               //공급가액 
					to_char(nvl(amt.pre_balance,0)),             //전월Balance 
					to_char(nvl(amt.cur_balance,0)),             //당월Balance 
					to_char(info.trdt, 'yyyymmdd'),              //청구기준일 
					to_char(amt.cur_balance + amt.pre_balance),  // 총 Balance 
					to_char(add_months(info.trdt,-1), 'yyyymm'), // 청구년월 
					to_char(nvl(amt.surtax,0)),                    //부가세 
					to_char(nvl(amt.btramt01,0)),                  //청구금액 
					to_char(nvl(amt.btramt02,0)),
					to_char(nvl(amt.btramt03,0)),
					to_char(nvl(amt.btramt04,0)),
					to_char(nvl(amt.btramt05,0)),
					to_char(nvl(amt.btramt06,0)),
					to_char(nvl(amt.btramt07,0)),
					to_char(nvl(amt.btramt08,0)),
					to_char(nvl(amt.btramt09,0)),
					to_char(nvl(amt.btramt10,0)),
					to_char(nvl(amt.btramt11,0)),                  //청구금액 
					to_char(nvl(amt.btramt12,0)),
					to_char(nvl(amt.btramt13,0)),
					to_char(nvl(amt.btramt14,0)),
					to_char(nvl(amt.btramt15,0)),
					to_char(nvl(amt.btramt16,0)),
					to_char(nvl(amt.btramt17,0)),					
					amt.btrdesc01,                 
					amt.btrdesc02,
					amt.btrdesc03,
					amt.btrdesc04,
					amt.btrdesc05,
					amt.btrdesc06,
					amt.btrdesc07,
					amt.btrdesc08,
					amt.btrdesc09,
					amt.btrdesc10,
					amt.btrdesc11,
					amt.btrdesc12,
					amt.btrdesc13,
					amt.btrdesc14,
					amt.btrdesc15,
					amt.btrdesc16,
					amt.btrdesc17
		from reqinfo info, reqamtinfo amt, customerm cus
		where info.payid = amt.payid 
				 and info.payid = cus.customerid  
				 and to_char(info.trdt, 'yyyymmdd') = :is_data[2] 
				 and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
				 and info.chargedt =:is_data[1]  //청구주기 
				 and amt.chargedt = :is_data[1]  // 청구주기 
				 and info.pay_method = :ls_giro  //납입방법 
				 and info.inv_yn = 'Y'    //청구서 발송여부 
				 and to_char(nvl(amt.pre_balance,0))=0  //전월미납액이 0
		order by info.payid;
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
		Return
	End If
	

    					
	//커서 Open
	OPEN cur_get_reqinfo;
	Do While(True)
		FETCH cur_get_reqinfo
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_phone1, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
			  :ls_trdt, :ls_totamt, :ls_use_month, :ls_surtax,
			  :ls_btramt[1],
			  :ls_btramt[2],
			  :ls_btramt[3],
			  :ls_btramt[4],
			  :ls_btramt[5],
			  :ls_btramt[6],
			  :ls_btramt[7],
			  :ls_btramt[8],
			  :ls_btramt[9],
			  :ls_btramt[10],
			  :ls_btramt[11],
			  :ls_btramt[12],
			  :ls_btramt[13],
			  :ls_btramt[14],
			  :ls_btramt[15],
			  :ls_btramt[16],
			  :ls_btramt[17],			  
  			  :ls_btrdesc[1],
			  :ls_btrdesc[2],
			  :ls_btrdesc[3],
			  :ls_btrdesc[4],
			  :ls_btrdesc[5],
			  :ls_btrdesc[6],
			  :ls_btrdesc[7],
			  :ls_btrdesc[8],
			  :ls_btrdesc[9],
			  :ls_btrdesc[10],
  			  :ls_btrdesc[11],
			  :ls_btrdesc[12],
			  :ls_btrdesc[13],
			  :ls_btrdesc[14],
			  :ls_btrdesc[15],
			  :ls_btrdesc[16],
			  :ls_btrdesc[17];
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo")
		CLOSE cur_get_reqinfo;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	//입금마감일(매월말일)
//	ls_inputdeadline = String( &
//								f_mon_last_date(Date(Integer(Mid(ls_trdt, 1, 4)), &
//						 				Integer(Mid(ls_trdt, 5, 2)), &
//						 				Integer(Mid(ls_trdt, 7, 2)) &
//										 )) &
//								,"yyyymmdd" &
//							)
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	
	//사용시작일 구하기
	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
							 
	ls_use_year = LeftA(ls_use_month,4)
	ls_use_day = RightA(ls_use_month,2)
	
	//고객조회번호
	ls_custom_no = ls_trdt + ls_payid + "000"

	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "01"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                              	  //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	If LenA(ls_phone1) >20 Then LeftA(ls_phone1, 20)
	ls_buffer += fs_fill_spaces(ls_phone1,20)				 				//전화번호
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   	//주소1
	If LenA(ls_addr2) > 100 Then LeftA(ls_addr2, 100)
	ls_buffer += fs_fill_spaces(ls_addr2, 100)                    	//주소2
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//고객이름
	If LenA(ls_zipcod) > 8 Then LeftA(ls_zipcod,8)
	ls_buffer += LeftA(ls_zipcod,3)
	ls_buffer += "-"
	ls_buffer += MidA(ls_zipcod,4,3)
	//ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer +=Space(1)
	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       	//작성일자(작성기준일?)	
	
	If LenA(ls_qnacenterp)>20 Then LeftA(ls_qnacenterp,20)   			//고객센터전화
	ls_buffer +=fs_fill_spaces(ls_qnacenterp, 20)
	If LenA(ls_qnacenterf)>20 Then LeftA(ls_qnacenterf,20)
	ls_buffer +=fs_fill_spaces(ls_qnacenterf, 20)
	ls_buffer += "OC"																//지로
	ls_buffer += LeftA(ls_trdt,4)   									   	//청구년도
	ls_buffer += MidA(ls_trdt,5,2)									   	   //청구월
   ls_buffer +=ls_use_from
   ls_buffer +=ls_use_to
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//납부자이름

	ls_buffer += fs_fill_spaces(ls_inputclosedt, 8) 				 	//납기기한

	ls_buffer += fs_fill_spaces("",30)      								//계좌번호
	ls_buffer += fs_fill_spaces(ls_supplyamt, -10)                	//공급가액
	ls_buffer += fs_fill_spaces(ls_surtax, -10)                   	//세액
	ls_buffer += ls_custom_no											      //고객조회번호
	ls_buffer += ls_girono                                         //girono
	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   	//청구금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,20)
		ls_buffer += fs_fill_spaces(ls_cregno, 20)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 20)
	END IF
	ls_buffer += Space(67)	

	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo;
		ii_rc = -2
		Return 
	End If
		//최기화
	ls_buffer = ""

	
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "02"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                 //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
		
	If Dec(ls_pre_balance) <> 0 Then 
		ls_buffer+= fs_fill_spaces(ls_pre_desc, 20)                //미납금액
		ls_buffer+= fs_fill_spaces(ls_pre_balance, -10)           
		li_lencount +=30
	End IF
	
	FOR li_pos = 1 to 17
		IF ls_btrdesc[li_pos] <> "" THEN
			ls_buffer += fs_fill_spaces(ls_btrdesc[li_pos], 20)      //이용금액
			ls_buffer += fs_fill_spaces(ls_btramt[li_pos], -10)
			li_lencount+=30
		END IF
	NEXT
	
	If li_lencount < 510 Then
		ls_buffer+=Space(510 - li_lencount)
	End if


	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   //청구금액
	
	If Dec(ls_pre_balance) <>0 Then									    //전월미납액
		ls_buffer+=fs_fill_spaces(ls_pre_balance, -10)
	Else
		ls_buffer+=Space(10)
	End If
	
   lc_this_amt = Dec(ls_totamt) - Dec(ls_pre_balance)
	

	ls_buffer +=fs_fill_spaces(String(lc_this_amt), -10)   //당월금액
	
	
	//ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //납기내 금액
	//ls_buffer += fs_fill_zeroes(String(lc_totamt_de), -11)       //납기후 금액
	//	ls_buffer += fs_fill_zeroes(ls_code, 22)                      //이용내역 Code
	//	ls_buffer += fs_fill_zeroes(ls_code1,121)                     //이용요금

	ls_buffer += Space(41)
	//ls_buffer +='~n'
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo;
		ii_rc = -2
		Return 
	End If
   
	ll_count += 1
	//최기화
	ls_buffer = ""
	ll_line = 0
	ll_user_count = 0
	ll_totline = 0
	ls_id_name  = ""
	ls_itemcod = ""
	ls_line = ""
	ls_code = ""
	ls_code1 = ""
	li_lencount= 0
	il_data[1] = ll_count
	Loop
	CLOSE cur_get_reqinfo;
	
	//File Close
	If ll_count <= 0 Then
	   ii_rc = -2
		FileClose(li_filenum)
		Return
	End If
		
	FileClose(li_filenum)
	ls_giro_file = ""
End If

//지로 미납액  파일 생성 (2004.07.02)****************************************************************
If is_data[11] = 'Y' Then
	
	
	//File Open
	li_filenum = FileOpen(ls_giro_delay_file, LineMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then
		f_msg_usr_err(9000, is_Title, "File Open Failed!")
		FileClose(li_filenum)			
		Return
	End If

	
	//Reqinfo Table Select 고객의 정보를 Select
	DECLARE cur_get_reqinfo_delay CURSOR FOR
		  Select info.payid, 											//납입자 ID 
					to_char(info.inputclosedtcur, 'yyyymmdd'),   //입금마감일 
					info.customernm,  									//고객이름 
					info.bil_addr1,   									//청구지주소 
					info.bil_addr2,   									//청구지주소 
					info.ctype2,      									//개인법인구분 
					info.cregno,      									//사업자번호 
					info.bil_zipcod,  									//청구지우편번호 
					cus.phone1,       									//고객전화번호 
					to_char(nvl(amt.supplyamt,0)),               //공급가액 
					to_char(nvl(amt.pre_balance,0)),             //전월Balance 
					to_char(nvl(amt.cur_balance,0)),             //당월Balance 
					to_char(info.trdt, 'yyyymmdd'),              //청구기준일 
					to_char(amt.cur_balance + amt.pre_balance),  // 총 Balance 
					to_char(add_months(info.trdt,-1), 'yyyymm'), // 청구년월 
					to_char(nvl(amt.surtax,0)),                    //부가세 
					to_char(nvl(amt.btramt01,0)),                  //청구금액 
					to_char(nvl(amt.btramt02,0)),
					to_char(nvl(amt.btramt03,0)),
					to_char(nvl(amt.btramt04,0)),
					to_char(nvl(amt.btramt05,0)),
					to_char(nvl(amt.btramt06,0)),
					to_char(nvl(amt.btramt07,0)),
					to_char(nvl(amt.btramt08,0)),
					to_char(nvl(amt.btramt09,0)),
					to_char(nvl(amt.btramt10,0)),
					to_char(nvl(amt.btramt11,0)),                  //청구금액 
					to_char(nvl(amt.btramt12,0)),
					to_char(nvl(amt.btramt13,0)),
					to_char(nvl(amt.btramt14,0)),
					to_char(nvl(amt.btramt15,0)),
					to_char(nvl(amt.btramt16,0)),
					to_char(nvl(amt.btramt17,0)),					
					amt.btrdesc01,                 
					amt.btrdesc02,
					amt.btrdesc03,
					amt.btrdesc04,
					amt.btrdesc05,
					amt.btrdesc06,
					amt.btrdesc07,
					amt.btrdesc08,
					amt.btrdesc09,
					amt.btrdesc10,
					amt.btrdesc11,
					amt.btrdesc12,
					amt.btrdesc13,
					amt.btrdesc14,
					amt.btrdesc15,
					amt.btrdesc16,
					amt.btrdesc17
		from reqinfo info, reqamtinfo amt, customerm cus
		where info.payid = amt.payid 
				 and info.payid = cus.customerid  
				 and to_char(info.trdt, 'yyyymmdd') = :is_data[2] 
				 and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
				 and info.chargedt =:is_data[1]  //청구주기 
				 and amt.chargedt = :is_data[1]  // 청구주기 
				 and info.pay_method = :ls_giro  //납입방법 
				 and info.inv_yn = 'Y'    //청구서 발송여부 
				 and to_char(nvl(amt.pre_balance,0))>0  //전월미납액이 0
		order by info.payid;
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
		Return
	End If
	

    					
	//커서 Open
	OPEN cur_get_reqinfo_delay;
	Do While(True)
		FETCH cur_get_reqinfo_delay
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_phone1, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
			  :ls_trdt, :ls_totamt, :ls_use_month, :ls_surtax,
			  :ls_btramt[1],
			  :ls_btramt[2],
			  :ls_btramt[3],
			  :ls_btramt[4],
			  :ls_btramt[5],
			  :ls_btramt[6],
			  :ls_btramt[7],
			  :ls_btramt[8],
			  :ls_btramt[9],
			  :ls_btramt[10],
			  :ls_btramt[11],
			  :ls_btramt[12],
			  :ls_btramt[13],
			  :ls_btramt[14],
			  :ls_btramt[15],
			  :ls_btramt[16],
			  :ls_btramt[17],			  
  			  :ls_btrdesc[1],
			  :ls_btrdesc[2],
			  :ls_btrdesc[3],
			  :ls_btrdesc[4],
			  :ls_btrdesc[5],
			  :ls_btrdesc[6],
			  :ls_btrdesc[7],
			  :ls_btrdesc[8],
			  :ls_btrdesc[9],
			  :ls_btrdesc[10],
  			  :ls_btrdesc[11],
			  :ls_btrdesc[12],
			  :ls_btrdesc[13],
			  :ls_btrdesc[14],
			  :ls_btrdesc[15],
			  :ls_btrdesc[16],
			  :ls_btrdesc[17];
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo_delay")
		CLOSE cur_get_reqinfo_delay;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	//입금마감일(매월말일)
//	ls_inputdeadline = String( &
//								f_mon_last_date(Date(Integer(Mid(ls_trdt, 1, 4)), &
//						 				Integer(Mid(ls_trdt, 5, 2)), &
//						 				Integer(Mid(ls_trdt, 7, 2)) &
//										 )) &
//								,"yyyymmdd" &
//							)
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	
	//사용시작일 구하기
	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
							 
	ls_use_year = LeftA(ls_use_month,4)
	ls_use_day = RightA(ls_use_month,2)
	
	//고객조회번호
	ls_custom_no = ls_trdt + ls_payid + "000"
							 
	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "01"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                              	  //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	If LenA(ls_phone1) >20 Then LeftA(ls_phone1, 20)
	ls_buffer += fs_fill_spaces(ls_phone1,20)				 				//전화번호
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   	//주소1
	If LenA(ls_addr2) > 100 Then LeftA(ls_addr2, 100)
	ls_buffer += fs_fill_spaces(ls_addr2, 100)                    	//주소2
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//고객이름
	If LenA(ls_zipcod) > 8 Then LeftA(ls_zipcod,8)
	ls_buffer += LeftA(ls_zipcod,3)
	ls_buffer += "-"
	ls_buffer += MidA(ls_zipcod,4,3)
	//ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer +=Space(1)
	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       	//작성일자(작성기준일?)	
	
	If LenA(ls_qnacenterp)>20 Then LeftA(ls_qnacenterp,20)   			//고객센터전화
	ls_buffer +=fs_fill_spaces(ls_qnacenterp, 20)
	If LenA(ls_qnacenterf)>20 Then LeftA(ls_qnacenterf,20)
	ls_buffer +=fs_fill_spaces(ls_qnacenterf, 20)
	ls_buffer += "OC"																//지로
	ls_buffer += LeftA(ls_trdt,4)   									   	//청구년도
	ls_buffer += MidA(ls_trdt,5,2)									   	   //청구월
   ls_buffer +=ls_use_from
   ls_buffer +=ls_use_to
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//납부자이름

	ls_buffer += fs_fill_spaces(ls_inputclosedt, 8) 				 	//납기기한

	ls_buffer += fs_fill_spaces("",30)      								//계좌번호
	ls_buffer += fs_fill_spaces(ls_supplyamt, -10)                	//공급가액
	ls_buffer += fs_fill_spaces(ls_surtax, -10)                   	//세액
	ls_buffer += ls_custom_no											      //고객조회번호
	ls_buffer += ls_girono                                         //girono
	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   	//청구금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,20)
		ls_buffer += fs_fill_spaces(ls_cregno, 20)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 20)
	END IF
	ls_buffer += Space(67)	

	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo_delay;
		ii_rc = -2
		Return 
	End If
		//최기화
	ls_buffer = ""

	
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "02"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                 //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
		
//	If Dec(ls_pre_balance) <> 0 Then 
//		ls_buffer+= fs_fill_spaces(ls_pre_desc, 20)                //미납금액
//		ls_buffer+= fs_fill_spaces(ls_pre_balance, -10)           
//		li_lencount +=30
//	End IF

	
	FOR li_pos = 1 to 17
		IF ls_btrdesc[li_pos] <> "" THEN
			ls_buffer += fs_fill_spaces(ls_btrdesc[li_pos], 20)      //이용금액
			ls_buffer += fs_fill_spaces(ls_btramt[li_pos], -10)
			li_lencount+=30
		END IF
	NEXT
	
	If li_lencount < 510 Then
		ls_buffer+=Space(510 - li_lencount)
	End if


	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   //청구금액
	
	If Dec(ls_pre_balance) <>0 Then									    //전월미납액
		ls_buffer+=fs_fill_spaces(ls_pre_balance, -10)
	Else
		ls_buffer+=Space(10)
	End If
	
   lc_this_amt = Dec(ls_totamt) - Dec(ls_pre_balance)
	

	ls_buffer +=fs_fill_spaces(String(lc_this_amt), -10)   //당월금액
	
	
	//ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //납기내 금액
	//ls_buffer += fs_fill_zeroes(String(lc_totamt_de), -11)       //납기후 금액
	//	ls_buffer += fs_fill_zeroes(ls_code, 22)                      //이용내역 Code
	//	ls_buffer += fs_fill_zeroes(ls_code1,121)                     //이용요금

	ls_buffer += Space(41)
	//ls_buffer +='~n'
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo_delay;
		ii_rc = -2
		Return 
	End If

   ls_buffer = ""
	/*************************************
	 * 지로 + 미납액 
	 *************************************/
	String ls_delay_dt[], ls_delay_amt[]
	Integer li_delay_count , li_delay_len_count
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "03"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                 //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	ls_buffer += ls_custom_no											      //고객조회번호
	ls_buffer += ls_girono                                         //girono
	

	DECLARE cur_get_delay_amt CURSOR FOR	
				SELECT substr(to_char(trdt,'yyyymmdd'),1,6), sum(tramt)
					  FROM reqdtl
				where payid= :ls_payid
					  GROUP BY trdt;

	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_delay_amt")
		Return
	End If

	//커서 Open*********************************************************** error
	i = 1
	OPEN cur_get_delay_amt;
		Do While(true)
			FETCH cur_get_delay_amt	
			INTO :ls_delay_dt[i], :ls_delay_amt[i];
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, ":cur_get_delay_amt")
				CLOSE cur_get_delay_amt;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
		   i++
	   LOOP
	CLOSE cur_get_delay_amt;
	
	
	FOR li_delay_count = 1 to 10
		If ls_delay_dt[li_delay_count]<>"" and ls_delay_dt[li_delay_count] <> LeftA(ls_trdt,6) Then
			ls_buffer += LeftA(ls_delay_dt[li_delay_count],4)                //청구년도
			ls_buffer += "/"
			ls_buffer += MidA(ls_delay_dt[li_delay_count],5,2)               //청구월
			ls_buffer += fs_fill_spaces(ls_delay_amt[li_delay_count], -10)  //청구금액
			li_delay_len_count+=17
		Else
			Exit
		End if
	NEXT

	If li_delay_len_count < 170 Then
		ls_buffer+=Space(170 - li_delay_len_count)
	End if
		
	ls_buffer+= fs_fill_spaces(ls_pre_balance, -10)           //미납금액합계
	
	ls_buffer += Space(375)
	//ls_buffer +='~n'
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo_delay;
		ii_rc = -2
		Return 
	End If
   
	li_delay_len_count=0

	ll_count += 1
	//최기화
	ls_buffer = ""
	ll_line = 0
	ll_user_count = 0
	ll_totline = 0
	ls_id_name  = ""
	ls_itemcod = ""
	ls_line = ""
	ls_code = ""
	ls_code1 = ""
	li_lencount= 0
//	li_delay_count=0
//	i=0
	il_data[1] = ll_count
	Loop
	CLOSE cur_get_reqinfo_delay;
	
	//File Close
	If ll_count <= 0 Then
	   ii_rc = -2
		FileClose(li_filenum)
		Return
	End If
		
	FileClose(li_filenum)
	ls_giro_delay_file = ""
End If
//**************************************************************************************************

//자동이체 파일 생성================================================================================
If is_data[4] = 'Y' Then
	
	//File Open
	li_filenum = FileOpen(ls_cms_file, LineMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then
		f_msg_usr_err(9000, is_Title, "File Open Failed!")
		FileClose(li_filenum)			
		Return
	End If

	//Reqinfo Table Select 고객의 정보를 Select
	DECLARE cur_get_reqinfo2 CURSOR FOR	
	  Select info.payid, 											//납입자 ID 
					to_char(info.inputclosedtcur, 'yyyymmdd'),   //입금마감일 
					info.customernm,  									//고객이름 
					info.bil_addr1,   									//청구지주소 
					info.bil_addr2,   									//청구지주소 
					info.ctype2,      									//개인법인구분 
					info.cregno,      									//사업자번호 
					info.bil_zipcod,  									//청구지우편번호 
					info.pay_method,										//납부방법
					cus.phone1,       									//고객전화번호 
					to_char(nvl(amt.supplyamt,0)),               //공급가액 
					to_char(nvl(amt.pre_balance,0)),             //전월Balance 
					to_char(nvl(amt.cur_balance,0)),             //당월Balance 
					to_char(info.trdt, 'yyyymmdd'),              //청구기준일 
					to_char(amt.cur_balance + amt.pre_balance),  // 총 Balance 
					to_char(add_months(info.trdt,-1), 'yyyymm'), // 청구년월 
					to_char(nvl(amt.surtax,0)),                    //부가세 
					to_char(nvl(amt.btramt01,0)),                  //청구금액 
					to_char(nvl(amt.btramt02,0)),
					to_char(nvl(amt.btramt03,0)),
					to_char(nvl(amt.btramt04,0)),
					to_char(nvl(amt.btramt05,0)),
					to_char(nvl(amt.btramt06,0)),
					to_char(nvl(amt.btramt07,0)),
					to_char(nvl(amt.btramt08,0)),
					to_char(nvl(amt.btramt09,0)),
					to_char(nvl(amt.btramt10,0)),
					to_char(nvl(amt.btramt11,0)),                  //청구금액 
					to_char(nvl(amt.btramt12,0)),
					to_char(nvl(amt.btramt13,0)),
					to_char(nvl(amt.btramt14,0)),
					to_char(nvl(amt.btramt15,0)),
					to_char(nvl(amt.btramt16,0)),
					to_char(nvl(amt.btramt17,0)),					
					amt.btrdesc01,                 
					amt.btrdesc02,
					amt.btrdesc03,
					amt.btrdesc04,
					amt.btrdesc05,
					amt.btrdesc06,
					amt.btrdesc07,
					amt.btrdesc08,
					amt.btrdesc09,
					amt.btrdesc10,
					amt.btrdesc11,
					amt.btrdesc12,
					amt.btrdesc13,
					amt.btrdesc14,
					amt.btrdesc15,
					amt.btrdesc16,
					amt.btrdesc17
		from reqinfo info, reqamtinfo amt, customerm cus
		where info.payid = amt.payid 
				 and info.payid = cus.customerid  
				 and to_char(info.trdt, 'yyyymmdd') = :is_data[2] 
				 and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
				 and info.chargedt =:is_data[1]  //청구주기 
				 and amt.chargedt = :is_data[1]  // 청구주기 
			    and (info.pay_method = :ls_cms  or info.pay_method = :ls_card)  //납입방법 
				 and info.inv_yn = 'Y'    //청구서 발송여부 
		order by info.payid;
			
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
		Return
	End If
	
	

	//커서 Open
	OPEN cur_get_reqinfo2;
	Do While(True)
		FETCH cur_get_reqinfo2
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_paymethod,:ls_phone1, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
			  :ls_trdt, :ls_totamt, :ls_use_month, :ls_surtax,
			  :ls_btramt[1],
			  :ls_btramt[2],
			  :ls_btramt[3],
			  :ls_btramt[4],
			  :ls_btramt[5],
			  :ls_btramt[6],
			  :ls_btramt[7],
			  :ls_btramt[8],
			  :ls_btramt[9],
			  :ls_btramt[10],
			  :ls_btramt[11],
			  :ls_btramt[12],
			  :ls_btramt[13],
			  :ls_btramt[14],
			  :ls_btramt[15],
			  :ls_btramt[16],
			  :ls_btramt[17],			  
  			  :ls_btrdesc[1],
			  :ls_btrdesc[2],
			  :ls_btrdesc[3],
			  :ls_btrdesc[4],
			  :ls_btrdesc[5],
			  :ls_btrdesc[6],
			  :ls_btrdesc[7],
			  :ls_btrdesc[8],
			  :ls_btrdesc[9],
			  :ls_btrdesc[10],
  			  :ls_btrdesc[11],
			  :ls_btrdesc[12],
			  :ls_btrdesc[13],
			  :ls_btrdesc[14],
			  :ls_btrdesc[15],
			  :ls_btrdesc[16],
			  :ls_btrdesc[17];
			  
			  
			  
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo2")
		CLOSE cur_get_reqinfo2;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	
	
	//입금마감일(매월말일)
//	ls_inputdeadline = String( &
//								f_mon_last_date(Date(Integer(Mid(ls_trdt, 1, 4)), &
//						 				Integer(Mid(ls_trdt, 5, 2)), &
//						 				Integer(Mid(ls_trdt, 7, 2)) &
//										 )) &
//								,"yyyymmdd" &
//							)
							
	//전월청구일
	ls_trdt_prev = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	

	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	ls_use_year = LeftA(ls_use_month,4)
	ls_use_day = RightA(ls_use_month,2)
							 
	//고객조회번호
	ls_custom_no = ls_trdt + ls_payid + "000"

	//전월영수금액, 납부일자 가져오기
    select  sum(nvl(payamt,0)), to_char(max(paydt),'yyyy/mm/dd')
	 INTO :ls_re_totpayamt, :ls_re_paydt
    from reqreceipt
		  where payid=:ls_payid
		  	and  to_char(trdt,'yyyymmdd') =:ls_trdt_prev
			and  pay_method <> :ls_giro;
			
	//Error
	If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(reqreceipt_amt)")
	  Return
	//No Result
   ElseIf SQLCA.sqlcode  = 100 Then
	  ls_re_totpayamt="0"
	  ls_re_paydt=""
   End If


   SELECT distinct(re.payid), cus.phone1, cus.customernm, re.pay_method, re.acct_type, re.acct_no,
          info.acct_owner, info.card_holder
	INTO :ls_payid_t,:ls_re_phone1, :ls_re_customernm, :ls_re_paymethod, :ls_acct_type,
		  :ls_acct_no, :ls_re_acct_owner,:ls_re_card_holder
   FROM reqinfoh info, reqreceipt re, customerm cus
   WHERE re.payid = :ls_payid 
    and  info.payid = :ls_payid
    and  cus.customerid = :ls_payid
    and  to_char(re.trdt,'yyyymmdd') = :ls_trdt_prev
    and  to_char(info.trdt,'yyyymmdd') = :ls_trdt_prev;
	
	
	 //Error
	If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(reqreceipt_info)")
	  Return
	//No Result
   ElseIf SQLCA.sqlcode  = 100 Then
	  ls_re_phone1=""
	  ls_re_customernm=""
	  ls_re_paymethod=""
	  ls_acct_type=""
	  ls_acct_no=""
	  ls_re_acct_owner=""
	  ls_re_card_holder=""
   End If


	
	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "01"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
	If LenA(ls_phone1) >20 Then LeftA(ls_phone1, 20)
	ls_buffer += fs_fill_spaces(ls_phone1,20)				 				//전화번호
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   	//주소1
	If LenA(ls_addr2) > 100 Then LeftA(ls_addr2, 100)
	ls_buffer += fs_fill_spaces(ls_addr2, 100)                    	//주소2
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//고객이름
	If LenA(ls_zipcod) > 8 Then LeftA(ls_zipcod,8)
//	ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer += LeftA(ls_zipcod,3)
	ls_buffer += "-"
	ls_buffer += MidA(ls_zipcod,4,3)
	//ls_buffer += fs_fill_spaces(ls_zipcod, 8)                    	//우편번호
	ls_buffer +=Space(1)

	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       	//작성일자(작성기준일?)	
	
	If LenA(ls_qnacenterp)>20 Then LeftA(ls_qnacenterp,20)   			//고객센터전화
	ls_buffer +=fs_fill_spaces(ls_qnacenterp, 20)
	If LenA(ls_qnacenterf)>20 Then LeftA(ls_qnacenterf,20)
	ls_buffer +=fs_fill_spaces(ls_qnacenterf, 20)
	
	If ls_paymethod = ls_card Then
		ls_buffer += "CT"															//카드이체
	ElseIf ls_paymethod = ls_cms Then
		ls_buffer +="AT"															//계좌이체
	End IF							
	
	ls_buffer += LeftA(ls_trdt,4)   									   	//청구년도
	ls_buffer += MidA(ls_trdt,5,2)									   	   //청구월
   ls_buffer +=ls_use_from
   ls_buffer +=ls_use_to
	If LenA(ls_customernm) > 50 Then LeftA(ls_customernm, 50)
	ls_buffer += fs_fill_spaces(ls_customernm, 50)               	//납부자이름

	
	ls_buffer += fs_fill_spaces(ls_inputclosedt, 8) 				 	//납기기한
	
	If ls_paymethod = ls_cms Then
		If LenA(ls_acct_no_receipt)>30 Then LeftA(ls_acct_no_receipt,30)
		ls_buffer += fs_fill_spaces(ls_acct_no_receipt,30)      			//계좌번호
	ElseIf ls_paymethod = ls_card Then
		If LenA(ls_cardno) > 30 Then LeftA(ls_cardno,30)
		ls_buffer += fs_fill_spaces(ls_cardno, 30)							//카드번호
	Else
		ls_buffer += fs_fill_spaces("",30)     
	End If
	
	ls_buffer += fs_fill_spaces(ls_supplyamt, -10)                	//공급가액
	ls_buffer += fs_fill_spaces(ls_surtax, -10)                   	//세액
	ls_buffer += ls_custom_no													//고객조회번호
	ls_buffer += ls_girono                                         //girono
	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   	//청구금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,20)
		ls_buffer += fs_fill_spaces(ls_cregno, 20)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 20)
	END IF
	
	ls_buffer += Space(67)
	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If
	ls_buffer=""
	

	
	//RECORD2
	ls_buffer += "D"															 //RECORD Type
	ls_buffer += "02"                                            //RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호
		
	If Dec(ls_pre_balance) <> 0 Then 
		ls_buffer += fs_fill_spaces(ls_pre_desc, 20)                //미납금액
		ls_buffer += fs_fill_spaces(ls_pre_balance, -10)   
		li_lencount+=30
	End IF
	
	FOR li_pos = 1 to 17
		IF ls_btrdesc[li_pos] <> "" THEN
			ls_buffer += fs_fill_spaces(ls_btrdesc[li_pos], 20)      //이용금액
			ls_buffer += fs_fill_spaces(ls_btramt[li_pos], -10)          
			li_lencount+=30
		END IF
	NEXT


	If li_lencount < 510 Then
		ls_buffer+=Space(510 - li_lencount)
	End if


	ls_buffer += fs_fill_spaces(ls_totamt,-10)                   //청구금액
	
	If Dec(ls_pre_balance) <>0 Then									    //전월미납액
		ls_buffer+=fs_fill_spaces(ls_pre_balance, -10)
	Else
		ls_buffer+=Space(10)
	End If
	
	
   lc_this_amt = Dec(ls_totamt) - Dec(ls_pre_balance)
	

	ls_buffer +=fs_fill_spaces(String(lc_this_amt), -10)   //당월금액

	ls_buffer += Space(41)
	
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If
	
	ls_buffer = ""
	li_lencount=0
	
	
	//버퍼에 자료 생성
	ls_buffer += "D"															 	//RECORD Type
	ls_buffer += "05"                                             	//RECORD NO
	ls_buffer += LeftA(ls_trdt,6)                                   //청구년월
	ls_buffer += fs_fill_spaces(ls_payid, 10)								//고객번호

	ls_buffer += fs_fill_spaces(ls_re_phone1, 13)
	ls_buffer += fs_fill_spaces(ls_re_customernm, 50)
	
	If ls_re_paymethod = ls_cms Then
		ls_buffer += fs_fill_spaces("계좌이체", 20)
		//거래은행명
		SELECT codenm
		INTO :ls_bank_name_receipt
		FROM syscod2t
		WHERE grcode = 'B400'
		AND code = :ls_acct_type;
		ls_buffer += fs_fill_spaces(ls_bank_name_receipt, 40)
	   ls_buffer += fs_fill_spaces(ls_re_acct_owner, 50)
		ls_buffer += fs_fill_spaces(ls_acct_no, 20)
	ElseIf ls_re_paymethod = ls_card Then
		ls_buffer += fs_fill_spaces("카드이체", 20)
		//거래카드명
		SELECT codenm
		INTO :ls_card_name_receipt
		FROM syscod2t
		WHERE grcode = 'B450'
		AND code = :ls_acct_type;
		ls_buffer += fs_fill_spaces(ls_card_name_receipt, 40)
	   ls_buffer += fs_fill_spaces(ls_re_card_holder, 50)		
		ls_buffer += fs_fill_spaces(ls_acct_no, 20)		
	Else
		ls_buffer += fs_fill_spaces("",20)	
		ls_buffer += fs_fill_spaces("", 40)
	   ls_buffer += fs_fill_spaces("", 50)		
		ls_buffer += fs_fill_spaces("", 20)		

	End If



	ls_buffer += fs_fill_spaces(ls_re_paydt,10)
	ls_buffer += fs_fill_spaces(ls_re_totpayamt, -10)
	ls_buffer += Space(368)
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If


   
	ll_count += 1
	//최기화
	ls_buffer = ""
	ll_line = 0
	ll_user_count = 0
	ll_totline = 0
	ls_id_name  = ""
	ls_itemcod = ""
	ls_line = ""
	ls_code = ""
	ls_code1 = ""
	il_data[1] = ll_count
	li_lencount= 0
	Loop
	CLOSE cur_get_reqinfo2;
	
	//File Close
	If ll_count <= 0 Then
	   ii_rc = -2
		FileClose(li_filenum)
		Return
	End If
		
	FileClose(li_filenum)
	ls_cms_file = ""
End If

End Choose

ii_rc = 0
Return 
end subroutine

on b5u_dbmgr7.create
call super::create
end on

on b5u_dbmgr7.destroy
call super::destroy
end on

