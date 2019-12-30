$PBExportHeader$b5u_dbmgr7_vtel.sru
$PBExportComments$[islim] 청구자료 대행업체에 보내기
forward
global type b5u_dbmgr7_vtel from u_cust_a_db
end type
end forward

global type b5u_dbmgr7_vtel from u_cust_a_db
end type
global b5u_dbmgr7_vtel b5u_dbmgr7_vtel

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
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

public subroutine uf_prc_db_02 ();/*
String ls_cms_file, ls_giro_file, ls_day,ls_ref_desc, ls_giro, ls_cms, ls_use_from, ls_use_to
String ls_buffer, ls_tmp, ls_name[], ls_null, ls_code, ls_code1, ls_person, ls_code_pos[]
String ls_payid, ls_inputclosedt, ls_customernm, ls_addr1, ls_addr2, ls_zipcod, ls_location, ls_buildingno, ls_ctype2, ls_cregno
String ls_roomno, ls_supplyamt, ls_pre_balance, ls_cur_balance, ls_trdt, ls_btramt[], ls_totamt, ls_use_month, ls_surtax
String ls_line, ls_itemcod, ls_aptid, ls_buildingid, ls_houseid, ls_user_name, ls_id_name, ls_memberid, ls_locationnm
String ls_acct_owner, ls_bank
String ls_inputdeadline
*/

//추가
/*String ls_phone1, ls_use_year, ls_use_day, ls_card , ls_girono, ls_qnacenterp, ls_qnacenterf, ls_custom_no
String ls_pre_desc, ls_btrdesc[], ls_paymethod, ls_cardno
String ls_paydt, ls_payamt  , ls_this_amt
*/
/******************************************************
*		2005.08.31 juede
*		Vtelecom 청구서 파일 생성
*		1. DM_vtbil : 지로 청구고객 청구서
*		2. DM_vttel : 지로 청구고객 전화번호별 요금
*		3. DM_vtdet : 지로 청구고객 국제상세내역
********************************************************/

String ls_buffer
String ls_payid, ls_inputclosedt, ls_customernm,ls_zipcod, ls_ctype2, ls_cregno
String ls_ref_desc, ls_id_name, ls_itemcod, ls_code, ls_code1,ls_trdt, ls_line, ls_use_month

String ls_phone1, ls_use_year, ls_use_day, ls_card , ls_girono, ls_qnacenterp, ls_qnacenterf, ls_custom_no
String ls_paymethod, ls_cardno
String ls_paydt, ls_payamt  , ls_this_amt


/*전월영수증
String ls_re_paymethod, ls_re_acct_type , ls_acct_no
String ls_re_customernm, ls_re_phone1, ls_re_acct_owner, ls_re_card_holder, ls_acct_type
String ls_re_totpayamt, ls_re_paydt
String ls_payid_t
*/

Dec lc_totamt_de, lc_rate, lc_dealy_amt, lc_this_amt
long ll_format, ll_count, ll_contractseq, i, ll_line, ll_user_count, ll_totline
Int li_write_bytes, li_filenum, li_pos , li_lencount

//vtel add
String ls_validkey, ls_start_date, ls_start_time
String ls_rtelnum, ls_countrynm
Dec{1} ld_biltime
Dec{1} ldc_bilamt
String ls_pipe, ls_biltime, ls_bilamt
String ls_manager_tel, ls_giro, ls_addr, ls_giro_file
String ls_email,ls_adding_type, ls_adding_key, ls_holder, ls_used_dt
int li_bil_cnt=0, li_validkey_cnt=0, li_bil_seq=0
String ls_validkey_min, ls_trcodnm
Dec ldc_bilamt_sub[], ldc_bilamt0, ldc_bilamt_sum, ldc_btramt[]
String ls_btrdesc[]
Dec  ldc_supplyamt, ldc_pre_balance, ldc_cur_balance, ldc_surtax
int li_delay_cnt  //미납개월수
String ls_reqnum, ls_delay_start_trdt  //연체시작청구일자
String ls_trdt_month, ls_giro_customer_no_left,ls_giro_customer_no_right


ls_pipe='|'

ii_rc = -1
Choose Case is_caller
	Case "Create Invoice vtel giro"
			//lu_dbmgr.is_data[1] = is_chargedt
			//lu_dbmgr.is_data[2] = is_trdt
			//lu_dbmgr.is_data[3] = is_inv_class
			//lu_dbmgr.is_data[4] = is_giro_file
			//lu_dbmgr.is_data[5] = is_manager_tel
			//lu_dbmgr.is_data[6] = is_issue_dt  청구서 발행일자.

			ls_giro_file = is_data[4] + is_data[3]

			//Paymethod
			ls_giro = fs_get_control("B0", "P129", ls_ref_desc)   //vtel giro 1
//ls_giro = fs_get_control("B0", "P130", ls_ref_desc)   //자동이체 - 2			

			//지로청구고객 국제상세내역
			If is_data[3] = 'vtdet' Then
				
				//File Open
				li_filenum = FileOpen(ls_giro_file, LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			
				
			   //지로고객별 국제전화 사용내역 
				DECLARE cur_get_reqinfo_vtdet CURSOR FOR
					SELECT info.PAYID,p.validkey,
							 to_char(p.stime,'yyyy-mm-dd'),
							 to_char(p.stime,'hh24:mi:ss') ,
							 p.biltime, (p.bilamt-p.dcbilamt) balance, p.rtelnum, c.countrynm
					FROM reqinfo info,  post_bilcdr p, country c 
					WHERE to_char(info.trdt, 'yyyymmdd') = :is_data[2]
					AND info.chargedt = :is_data[1]
					AND info.pay_method = :ls_giro
					AND info.inv_yn = 'Y'					
					AND p.payid = INFO.PAYID
					and p.trdt = info.trdt
					AND p.zoncod LIKE 'ZC%'
					AND p.countrycod = c.countrycod
					AND (nvl(bilamt,0)- nvl(dcbilamt,0))> 0
					ORDER BY info.payid,p.validkey; 
			
			
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo_vtdet")
					Return
				End If	
									
				//커서 Open
				OPEN cur_get_reqinfo_vtdet;
				Do While(True)
					FETCH cur_get_reqinfo_vtdet
					INTO 	:ls_payid,
							:ls_validkey,
							:ls_start_date,
							:ls_start_time ,
							:ld_biltime,
							:ldc_bilamt,
							:ls_rtelnum,
							:ls_countrynm;
				
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, ":cur_get_reqinfo_vtdet")
						CLOSE cur_get_reqinfo_vtdet;
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
						
					

				//버퍼에 자료 생성
				ls_buffer += ls_payid +ls_pipe                            	 //고객번호
				ls_buffer += ls_validkey +ls_pipe                            //인증키
				ls_buffer += ls_start_date +ls_pipe                          //통화일자
				ls_buffer += ls_start_time +ls_pipe                          //시작시간
				ls_buffer += String(ld_biltime, '#0.0') +ls_pipe                     //통화시간
				ls_buffer += String(ldc_bilamt,'#0.0') +ls_pipe                     //통화료
				ls_buffer += ls_rtelnum +ls_pipe                             //상대방전화번호
				ls_buffer += ls_countrynm +ls_pipe                           //국가번호
			
				
				
				//Record 1 Write
				li_write_bytes = FileWrite(li_filenum, ls_buffer)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
					FileClose(li_filenum)
					Close cur_get_reqinfo_vtdet;
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
				CLOSE cur_get_reqinfo_vtdet;
	
				//File Close
				If ll_count <= 0 Then
					ii_rc = -2
					FileClose(li_filenum)
					Return
				End If
					
				FileClose(li_filenum)
				ls_giro_file = ""

         //지로전화번호별 요금********************************************************************************
			ElseIf is_data[3] = 'vttel' Then   
				//File Open
				li_filenum = FileOpen(ls_giro_file , LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			   
				li_bil_cnt =0
				
			   //지로고객별 전화번호별 사용내역
				
				DECLARE cursor_get_vttel_data CURSOR FOR
	
					SELECT info.payid, p.validkey,
							 SUM(DECODE(i.trcod,'120',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt1,
							 SUM(DECODE(i.trcod,'130',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt2,
							 SUM(DECODE(i.trcod,'140',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt3,
							 SUM(DECODE(i.trcod,'160',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt4,
							 SUM(DECODE(i.trcod,'180',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt5,
							 SUM(nvl(p.bilamt0,0)) amt6
							FROM reqinfo info, post_bilcdr p, trcode t, itemmst i
						  WHERE  to_char(info.trdt, 'yyyymmdd') = :is_data[2]
							 AND info.chargedt =:is_data[1]
							 AND info.inv_yn = 'Y'
							 AND info.pay_method =:ls_giro
							 AND p.payid = info.payid
							 AND p.trdt = info.trdt
							 AND p.itemcod = i.itemcod
							 AND i.trcod = t.trcod
						GROUP BY INFO.PAYID, P.VALIDKEY;


				//커서 Open cursor
				open cursor_get_vttel_data;
				DO WHILE(TRUE)
					FETCH cursor_get_vttel_data 
					INTO :ls_payid, :ls_validkey, :ldc_bilamt_sub[1], :ldc_bilamt_sub[2],
					     :ldc_bilamt_sub[3], :ldc_bilamt_sub[4], :ldc_bilamt_sub[5],
						  :ldc_bilamt0 ;
				
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, ":cur_get_vttel")
						CLOSE cursor_get_vttel_data;
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
						
               ldc_bilamt_sum = ldc_bilamt_sub[1]+ldc_bilamt_sub[2]+ldc_bilamt_sub[3]+ldc_bilamt_sub[4]+ldc_bilamt_sub[5]					
					
					//If ldc_bilamt_sum =0 Then
					//	continue
					//End If

					//버퍼에 자료 생성
					ls_buffer =""
					ls_buffer += ls_payid +ls_pipe                            	 //고객번호
					ls_buffer += ls_validkey +ls_pipe                            //인증키
					ls_buffer += String(ldc_bilamt_sub[1],'#0.0') +ls_pipe       //시내통화료
					ls_buffer += String(ldc_bilamt_sub[2],'#0.0')  +ls_pipe      //인접통화료
					ls_buffer += String(ldc_bilamt_sub[3],'#0.0')  +ls_pipe      //시외통화료
					ls_buffer += String(ldc_bilamt_sub[4],'#0.0')  +ls_pipe      //이동통화료
					ls_buffer += String(ldc_bilamt_sub[5],'#0.0')  +ls_pipe      //국제통화						
					ls_buffer += String(ldc_bilamt_sum, '#0.0') +ls_pipe
					ls_buffer += String(ldc_bilamt0,'#0.0') +ls_pipe              //할인전요금
				
					
					
					//Record 1 Write
					li_write_bytes = FileWrite(li_filenum, ls_buffer)
					If li_write_bytes < 0 Then 
						f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
						FileClose(li_filenum)
						Close cursor_get_vttel_data;
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
				CLOSE cursor_get_vttel_data;
	
				//File Close
				If ll_count <= 0 Then
					ii_rc = -2
					FileClose(li_filenum)
					Return
				End If
					
				FileClose(li_filenum)
				ls_giro_file = ""				

//지로 청구고객 청구서 ********************************************************************************
			ElseIf is_data[3] = 'vtbill' Then   
				//File Open
				li_filenum = FileOpen(ls_giro_file, LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			   
				DECLARE cur_get_reqinfo CURSOR FOR
				  Select info.payid, 									 
							info.customernm,  							 
							concat(info.bil_addr1, info.bil_addr2) bill_addr  ,							 			 
							decode(info.ctype2,'10','************',info.cregno),      							 
					      substr(info.bil_zipcod,1,3)||'-'|| substr(info.bil_zipcod,4,6) ,	
							cus.phone1,
							info.bil_email,
							info.adding_type,
							info.adding_key,
							info.HOLDER,
							to_char(add_months(amt.trdt,-1),'yyyy.mm.dd')||' ~ '|| to_char(to_date(:ls_trdt,'yyyymmdd') - 1,'yyyy.mm.dd'),
            			to_char(info.inputclosedtcur, 'yyyy-mm-dd'),   //입금마감일 							
							nvl(amt.supplyamt,0),nvl(amt.surtax,0),               
							nvl(amt.pre_balance,0),             
							nvl(amt.cur_balance,0),             
							to_char(info.trdt, 'yyyymmdd'),              
							to_char(add_months(info.trdt,-1), 'yyyy-mm'), 
							nvl(amt.surtax,0), 							
							nvl(amt.btramt01,0),                
							nvl(amt.btramt02,0),
							nvl(amt.btramt03,0),
							nvl(amt.btramt04,0),
							nvl(amt.btramt05,0),
							nvl(amt.btramt06,0),
							nvl(amt.btramt07,0),
							nvl(amt.btramt08,0),
							nvl(amt.btramt09,0),
							nvl(amt.btramt10,0),
							nvl(amt.btramt11,0),              
							nvl(amt.btramt12,0),
							nvl(amt.btramt13,0),
							nvl(amt.btramt14,0),
							nvl(amt.btramt15,0),
							nvl(amt.btramt16,0),
							nvl(amt.btramt17,0),					
							nvl(amt.btramt18,0),	
							nvl(amt.btramt19,0),	
							nvl(amt.btramt20,0),
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
							amt.btrdesc17,					
							amt.btrdesc18,	
							amt.btrdesc19,	
							amt.btrdesc20							
				from reqinfo info, reqamtinfo amt, customerm cus
				where info.payid = amt.payid 
						 and info.payid = cus.customerid  
						 and to_char(info.trdt, 'yyyymmdd') =  :is_data[2] 
						 and to_char(amt.trdt, 'yyyymmdd') =  :is_data[2] 
						 and info.chargedt =:is_data[1]  //청구주기 
						 and amt.chargedt = :is_data[1]  //청구주기 
						 and info.pay_method =  :ls_giro  //납입방법 
						 and info.inv_yn = 'Y'     
				order by info.payid;
				
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
					Return
				End If
				
			
									
				//커서 Open
				OPEN cur_get_reqinfo;
				Do While(True)
					FETCH cur_get_reqinfo				
					INTO :ls_payid, :ls_customernm, :ls_addr, :ls_cregno,
						  :ls_zipcod, :ls_phone1, :ls_email,
						  :ls_adding_type, :ls_adding_key, :ls_holder,
						  :ls_used_dt, :ls_inputclosedt,
						  :ldc_supplyamt,:ldc_surtax, :ldc_pre_balance, :ldc_cur_balance,
						  :ls_trdt, :ls_use_month, :ldc_surtax,
						  :ldc_btramt[1],
						  :ldc_btramt[2],
						  :ldc_btramt[3],
						  :ldc_btramt[4],
						  :ldc_btramt[5],
						  :ldc_btramt[6],
						  :ldc_btramt[7],
						  :ldc_btramt[8],
						  :ldc_btramt[9],
						  :ldc_btramt[10],
						  :ldc_btramt[11],
						  :ldc_btramt[12],
						  :ldc_btramt[13],
						  :ldc_btramt[14],
						  :ldc_btramt[15],
						  :ldc_btramt[16],
						  :ldc_btramt[17],			  
						  :ldc_btramt[18],
						  :ldc_btramt[19],
						  :ldc_btramt[20],
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
						  :ls_btrdesc[17],
						  :ls_btrdesc[18],
						  :ls_btrdesc[19],
						  :ls_btrdesc[20];
										  

				
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":cur_get_reqinfo")
					CLOSE cur_get_reqinfo;
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If		

				SELECT min(validkey), Nvl(count(validkey),0)
				  INTO :ls_validkey_min, :li_validkey_cnt
				  FROM validinfo
				 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd'))
				    OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
						to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
					AND status <> '10' 
					AND svctype = '1'
					AND customerid = :ls_payid;
 
 				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, "Select validinfo")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If	
				
				
				li_bil_seq +=1
			   ls_buffer =""
			   //버퍼에 자료 생성
				ls_buffer += ls_use_month +ls_pipe                       //청구년월
				ls_buffer += String(li_bil_seq) +ls_pipe                 //seq
				ls_buffer += ls_payid +ls_pipe                           //고객번호
				ls_buffer += ls_customernm +ls_pipe                      //고객이름
				ls_buffer += ls_cregno +ls_pipe                          //등록번호
				ls_buffer += ls_zipcod +ls_pipe                          //우편번호
				ls_buffer += ls_addr +ls_pipe                            //주소			
				If IsNull(ls_adding_key) Then ls_adding_key=""
				ls_buffer += ls_adding_key+ls_pipe                       //담당전화???				
	         ls_buffer += is_data[5]+ls_pipe                          //관리점전화??		
				If IsNull(ls_email) Then ls_email =""
				ls_buffer += ls_email + ls_pipe									 //이메일
				
				FOR li_bil_cnt = 1 TO 20
					If IsNull(ls_btrdesc[li_bil_cnt]) Then
						exit
					End If					
				   //If ls_btrdesc[li_bil_cnt] ="부가세" Then
					If ls_btrdesc[li_bil_cnt] ="연체료" Then
						ls_buffer += String(ldc_supplyamt,'#0.0') +ls_pipe
						ls_buffer += String(ldc_surtax,'#0.0') + ls_pipe						
						ls_buffer += String(ldc_btramt[li_bil_cnt],'#0.0') +ls_pipe
						continue
					End If					
					ls_buffer += String(ldc_btramt[li_bil_cnt],'#0.0') + ls_pipe
				NEXT
				
				ls_buffer += String(ldc_cur_balance,'#0.0') + ls_pipe			//당월청구액
				ls_buffer += String (ldc_pre_balance,'#0.0') + ls_pipe //전월미납액
				ls_buffer += String(ldc_cur_balance+ldc_pre_balance,'#0.0') + ls_pipe			//총청구액
				
				If li_validkey_cnt > 1 Then
					ls_buffer += ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' + ls_pipe  //발신번호
				Else
					ls_buffer += ls_validkey_min + ls_pipe
				End If

				ls_buffer += ls_used_dt + ls_pipe								//사용기간
				ls_buffer += is_data[6] + ls_pipe								//발행일자
				If IsNull(ls_holder) Then ls_holder =""
				ls_buffer += ls_inputclosedt + ls_pipe									//납입일자
				
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
				
				ls_buffer += String(li_delay_cnt) + ls_pipe              //미납월수
				
				ls_trdt_month = MidA(ls_trdt,1,4) +'.'+MidA(ls_trdt,5,2)   //청구년월
				
				If li_delay_cnt > 0 Then
					ls_buffer += MidA(ls_delay_start_trdt,1,4)+'.'+MidA(ls_delay_start_trdt,5,2) +'~~'+ ls_trdt_month +ls_pipe
				Else
					ls_buffer +=ls_pipe
				End If
				
				ls_giro_customer_no_left = fs_giro_band_left(ls_payid, ls_trdt, li_delay_cnt , ls_delay_start_trdt)

				ls_buffer += ls_giro_customer_no_left		   //지로고객조회번호left

				ls_giro_customer_no_right = fs_giro_band_right(ldc_cur_balance+ldc_pre_balance) //지로고객조회번호 right
				
				ls_buffer += FillA(" ",5) 
				ls_buffer +=ls_giro_customer_no_right + ls_pipe   //지로고객조회번호 right
				
				//Record 1 Write
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

End Choose

ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_db_01 ();/******************************************************
*		2005.08.31 juede
*		Vtelecom 청구서 파일 생성
*		1. DM_ktbil : KT 청구고객 청구서
*		2. DM_kttel : KT 청구고객 전화번호별 요금
*		3. DM_ktdet : KT 청구고객 국제상세내역
********************************************************/

String ls_buffer
String ls_payid, ls_inputclosedt, ls_customernm,ls_zipcod, ls_ctype2, ls_cregno
String ls_ref_desc, ls_id_name, ls_itemcod, ls_code, ls_code1,ls_trdt, ls_line, ls_use_month

String ls_phone1, ls_use_year, ls_use_day, ls_card , ls_girono, ls_qnacenterp, ls_qnacenterf, ls_custom_no
String ls_paymethod, ls_cardno
String ls_paydt, ls_payamt  , ls_this_amt

/*전월영수증
String ls_re_paymethod, ls_re_acct_type , ls_acct_no
String ls_re_customernm, ls_re_phone1, ls_re_acct_owner, ls_re_card_holder, ls_acct_type
String ls_re_totpayamt, ls_re_paydt
String ls_payid_t
*/

Dec lc_totamt_de, lc_rate, lc_dealy_amt, lc_this_amt
long ll_format, ll_count, ll_contractseq, i, ll_line, ll_user_count, ll_totline
Int li_write_bytes, li_filenum, li_pos , li_lencount

//vtel add
String ls_validkey, ls_start_date, ls_start_time
String ls_rtelnum, ls_countrynm
Dec{1} ld_biltime
Dec{1} ldc_bilamt
String ls_pipe, ls_biltime, ls_bilamt
String ls_manager_tel, ls_kt, ls_addr, ls_kt_file
String ls_email,ls_adding_type, ls_adding_key, ls_holder, ls_used_dt
int li_bil_cnt=0, li_validkey_cnt=0, li_bil_seq=0
String ls_validkey_min, ls_trcodnm
Dec ldc_bilamt_sub[], ldc_bilamt0, ldc_bilamt_sum, ldc_btramt[]
String ls_btrdesc[]
Dec  ldc_supplyamt, ldc_pre_balance, ldc_cur_balance, ldc_surtax


ls_pipe='|'


ii_rc = -1
Choose Case is_caller
	Case "Create Invoice vtel kt"
			//lu_dbmgr.is_data[1] = is_chargedt
			//lu_dbmgr.is_data[2] = is_trdt
			//lu_dbmgr.is_data[3] = is_inv_class
			//lu_dbmgr.is_data[4] = is_kt_file
			//lu_dbmgr.is_data[5] = is_manager_tel
			//lu_dbmgr.is_data[6] = is_issue_dt  청구서 발행일자.

			ls_kt_file = is_data[4] +is_data[3]

			//Paymethod
			//ls_cms = fs_get_control("B0", "P130", ls_ref_desc)   //자동이체 - 2
			//ls_kt = fs_get_control("B0", "P130", ls_ref_desc)   //KT 합산 -4  B0, P135
			ls_kt = fs_get_control("B0", "P135", ls_ref_desc)   //KT 합산 -4  B0, P135			

			//Kt 자동이체 국제상세내역
			If is_data[3] = 'ktdet' Then
				
				//File Open
				li_filenum = FileOpen(ls_kt_file, LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			
				
			   //KT고객별 국제전화 사용내역 
				DECLARE cur_get_reqinfo_ktdet CURSOR FOR
					SELECT info.PAYID,p.validkey,
							 to_char(p.stime,'yyyy-mm-dd'),
							 to_char(p.stime,'hh24:mi:ss') ,
							 p.biltime, (p.bilamt-p.dcbilamt) balance, p.rtelnum, c.countrynm
					FROM reqinfo info,  post_bilcdr p, country c 
					WHERE to_char(info.trdt, 'yyyymmdd') = :is_data[2]
					AND info.chargedt = :is_data[1]
					AND info.pay_method = :ls_kt
					AND info.inv_yn = 'Y'					
					AND p.payid = INFO.PAYID
					and p.trdt = info.trdt
					AND p.zoncod LIKE 'ZC%'
					AND p.countrycod = c.countrycod
					AND (nvl(bilamt,0)- nvl(dcbilamt,0)) > 0
					ORDER BY info.payid,p.validkey; 
			
			
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo_ktdet")
					Return
				End If	
									
				//커서 Open
				OPEN cur_get_reqinfo_ktdet;
				Do While(True)
					FETCH cur_get_reqinfo_ktdet
					INTO 	:ls_payid,
							:ls_validkey,
							:ls_start_date,
							:ls_start_time ,
							:ld_biltime,
							:ldc_bilamt,
							:ls_rtelnum,
							:ls_countrynm;
				
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, ":cur_get_reqinfo_customer")
						CLOSE cur_get_reqinfo_ktdet;
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
						
					

				//버퍼에 자료 생성
				ls_buffer += ls_payid +ls_pipe                            	 //고객번호
				ls_buffer += ls_validkey +ls_pipe                            //인증키
				ls_buffer += ls_start_date +ls_pipe                          //통화일자
				ls_buffer += ls_start_time +ls_pipe                          //시작시간
				ls_buffer += String(ld_biltime, '#0.0') +ls_pipe                     //통화시간
				ls_buffer += String(ldc_bilamt,'#0.0') +ls_pipe                     //통화료
				ls_buffer += ls_rtelnum +ls_pipe                             //상대방전화번호
				ls_buffer += ls_countrynm +ls_pipe                           //국가번호
			
				
				
				//Record 1 Write
				li_write_bytes = FileWrite(li_filenum, ls_buffer)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
					FileClose(li_filenum)
					Close cur_get_reqinfo_ktdet;
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
				CLOSE cur_get_reqinfo_ktdet;
	
				//File Close
				If ll_count <= 0 Then
					ii_rc = -2
					FileClose(li_filenum)
					Return
				End If
					
				FileClose(li_filenum)
				ls_kt_file = ""

         //KT 전화번호별 요금********************************************************************************
			ElseIf is_data[3] = 'kttel' Then   
				//File Open
				li_filenum = FileOpen(ls_kt_file , LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			   
				li_bil_cnt =0
				
			   //KT고객별 전화번호별 사용내역
				
				DECLARE cursor_get_kttel_data CURSOR FOR
	
					SELECT info.payid, p.validkey,
							 SUM(DECODE(i.trcod,'120',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt1,
							 SUM(DECODE(i.trcod,'130',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt2,
							 SUM(DECODE(i.trcod,'140',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt3,
							 SUM(DECODE(i.trcod,'160',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt4,
							 SUM(DECODE(i.trcod,'180',nvl(p.bilamt,0)-nvl(p.dcbilamt,0),0)) amt5,
									 SUM(nvl(p.bilamt0,0)) amt6
							FROM reqinfo info, post_bilcdr p, trcode t, itemmst i
						  WHERE  to_char(info.trdt, 'yyyymmdd') =:is_data[2]
							 AND info.chargedt =:is_data[1]
							 AND info.inv_yn = 'Y'
							 AND info.pay_method =:ls_kt
							 AND p.payid = info.payid
							 AND p.trdt = info.trdt
							 AND p.itemcod = i.itemcod
							 AND i.trcod = t.trcod
						GROUP BY INFO.PAYID, P.VALIDKEY;


				//커서 Open cursor
				open cursor_get_kttel_data;
				DO WHILE(TRUE)
					FETCH cursor_get_kttel_data 
					INTO :ls_payid, :ls_validkey, :ldc_bilamt_sub[1], :ldc_bilamt_sub[2],
					     :ldc_bilamt_sub[3], :ldc_bilamt_sub[4], :ldc_bilamt_sub[5],
						  :ldc_bilamt0 ;
				
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_Title, ":cur_get_kttel")
						CLOSE cursor_get_kttel_data;
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						Exit
					End If
						
               ldc_bilamt_sum = ldc_bilamt_sub[1]+ldc_bilamt_sub[2]+ldc_bilamt_sub[3]+ldc_bilamt_sub[4]+ldc_bilamt_sub[5]					
					
					//If ldc_bilamt_sum =0 Then
					//	continue
					//End If

					//버퍼에 자료 생성
					ls_buffer =""
					ls_buffer += ls_payid +ls_pipe                            	 //고객번호
					ls_buffer += ls_validkey +ls_pipe                            //인증키
					ls_buffer += String(ldc_bilamt_sub[1],'#0.0') +ls_pipe       //시내통화료
					ls_buffer += String(ldc_bilamt_sub[2],'#0.0')  +ls_pipe      //인접통화료
					ls_buffer += String(ldc_bilamt_sub[3],'#0.0')  +ls_pipe      //시외통화료
					ls_buffer += String(ldc_bilamt_sub[4],'#0.0')  +ls_pipe      //이동통화료
					ls_buffer += String(ldc_bilamt_sub[5],'#0.0')  +ls_pipe      //국제통화						
					ls_buffer += String(ldc_bilamt_sum, '#0.0') +ls_pipe
					ls_buffer += String(ldc_bilamt0,'#0.0') +ls_pipe              //할인전요금
				
					
					
					//Record 1 Write
					li_write_bytes = FileWrite(li_filenum, ls_buffer)
					If li_write_bytes < 0 Then 
						f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
						FileClose(li_filenum)
						Close cursor_get_kttel_data;
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
				CLOSE cursor_get_kttel_data;
	
				//File Close
				If ll_count <= 0 Then
					ii_rc = -2
					FileClose(li_filenum)
					Return
				End If
					
				FileClose(li_filenum)
				ls_kt_file = ""				

//KT 청구고객 청구서 ********************************************************************************
			ElseIf is_data[3] = 'ktbill' Then   
				//File Open
				li_filenum = FileOpen(ls_kt_file, LineMode!, Write!, LockReadWrite!, Replace!)	
				If IsNull(li_filenum) Then li_filenum = -1
				If li_filenum < 0 Then
					f_msg_usr_err(9000, is_Title, "File Open Failed!")
					FileClose(li_filenum)			
					Return
				End If
			   
				DECLARE cur_get_reqinfo CURSOR FOR
				  Select info.payid, 									 
							info.customernm,  							 
							concat(info.bil_addr1, info.bil_addr2) bill_addr  ,							 			 
							decode(info.ctype2,'10','************',info.cregno),      							 
					      substr(info.bil_zipcod,1,3)||'-'|| substr(info.bil_zipcod,4,6) ,	
							cus.phone1,
							info.bil_email,
							info.adding_type,
							info.adding_key,
							info.HOLDER,
							to_char(add_months(amt.trdt,-1),'yyyy.mm.dd')||' ~ '|| to_char(to_date(:ls_trdt,'yyyymmdd') - 1,'yyyy.mm.dd'),
							nvl(amt.supplyamt,0),
							nvl(amt.surtax,0),
							nvl(amt.pre_balance,0),             
							nvl(amt.cur_balance,0),             
							to_char(info.trdt, 'yyyymmdd'),              
							to_char(add_months(info.trdt,-1), 'yyyy-mm'), 
							nvl(amt.surtax,0), 							
							nvl(amt.btramt01,0),                
							nvl(amt.btramt02,0),
							nvl(amt.btramt03,0),
							nvl(amt.btramt04,0),
							nvl(amt.btramt05,0),
							nvl(amt.btramt06,0),
							nvl(amt.btramt07,0),
							nvl(amt.btramt08,0),
							nvl(amt.btramt09,0),
							nvl(amt.btramt10,0),
							nvl(amt.btramt11,0),              
							nvl(amt.btramt12,0),
							nvl(amt.btramt13,0),
							nvl(amt.btramt14,0),
							nvl(amt.btramt15,0),
							nvl(amt.btramt16,0),
							nvl(amt.btramt17,0),					
							nvl(amt.btramt18,0),	
							nvl(amt.btramt19,0),	
							nvl(amt.btramt20,0),
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
							amt.btrdesc17,					
							amt.btrdesc18,	
							amt.btrdesc19,	
							amt.btrdesc20							
				from reqinfo info, reqamtinfo amt, customerm cus
				where info.payid = amt.payid 
						 and info.payid = cus.customerid  
						 and to_char(info.trdt, 'yyyymmdd') =  :is_data[2] 
						 and to_char(amt.trdt, 'yyyymmdd') =  :is_data[2] 
						 and info.chargedt =:is_data[1]  //청구주기 
						 and amt.chargedt = :is_data[1]  //청구주기 
						 and info.pay_method =  :ls_kt  //납입방법 
						 and info.inv_yn = 'Y'     
				order by info.payid;
				
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":CURSOR cur_get_reqinfo")
					Return
				End If
				
			
									
				//커서 Open
				OPEN cur_get_reqinfo;
				Do While(True)
					FETCH cur_get_reqinfo				
					INTO :ls_payid, :ls_customernm, :ls_addr, :ls_cregno,
						  :ls_zipcod, :ls_phone1, :ls_email,
						  :ls_adding_type, :ls_adding_key, :ls_holder,
						  :ls_used_dt,
						  :ldc_supplyamt, :ldc_surtax, :ldc_pre_balance, :ldc_cur_balance,
						  :ls_trdt, :ls_use_month, :ldc_surtax,
						  :ldc_btramt[1],
						  :ldc_btramt[2],
						  :ldc_btramt[3],
						  :ldc_btramt[4],
						  :ldc_btramt[5],
						  :ldc_btramt[6],
						  :ldc_btramt[7],
						  :ldc_btramt[8],
						  :ldc_btramt[9],
						  :ldc_btramt[10],
						  :ldc_btramt[11],
						  :ldc_btramt[12],
						  :ldc_btramt[13],
						  :ldc_btramt[14],
						  :ldc_btramt[15],
						  :ldc_btramt[16],
						  :ldc_btramt[17],			  
						  :ldc_btramt[18],
						  :ldc_btramt[19],
						  :ldc_btramt[20],
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
						  :ls_btrdesc[17],
						  :ls_btrdesc[18],
						  :ls_btrdesc[19],
						  :ls_btrdesc[20];
										  

				
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, ":cur_get_reqinfo")
					CLOSE cur_get_reqinfo;
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If		

				SELECT min(validkey), Nvl(count(validkey),0)
				  INTO :ls_validkey_min, :li_validkey_cnt
				  FROM validinfo
				 WHERE ((to_char(fromdt,'yyyymmdd') >= to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') )
				    OR (to_char(fromdt,'yyyymmdd') < to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd')  AND
						to_char(add_months(to_date(:ls_trdt,'yyyymmdd'),-1),'yyyymmdd') < nvl(to_char(todt,'yyyymmdd'),'99991231')))
					AND status <> '10' 
					AND svctype = '1'
					AND customerid = :ls_payid;
 
 				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, "Select validinfo")
					Return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If	
				
				
				li_bil_seq +=1
			   ls_buffer =""
			   //버퍼에 자료 생성
				ls_buffer += ls_use_month +ls_pipe                       //청구년월
				ls_buffer += String(li_bil_seq) +ls_pipe                 //seq
				ls_buffer += ls_payid +ls_pipe                           //고객번호
				ls_buffer += ls_customernm +ls_pipe                      //고객이름
				ls_buffer += ls_cregno +ls_pipe                          //등록번호
				ls_buffer += ls_zipcod +ls_pipe                          //우편번호
				ls_buffer += ls_addr +ls_pipe                            //주소			
				If IsNull(ls_adding_key) Then ls_adding_key=""
				ls_buffer += ls_adding_key+ls_pipe                       //담당전화???				
	         ls_buffer += is_data[5]+ls_pipe                          //관리점전화??		
				If IsNull(ls_email) Then ls_email =""
				ls_buffer += ls_email + ls_pipe									 //이메일
				
				FOR li_bil_cnt = 1 TO 20
					If IsNull(ls_btrdesc[li_bil_cnt]) Then
						exit
					End If					
				   If ls_btrdesc[li_bil_cnt] ="연체료" Then
						ls_buffer += String(ldc_supplyamt,'#0.0') +ls_pipe
						ls_buffer += String(ldc_surtax,'#0.0') +ls_pipe
						ls_buffer += String(ldc_btramt[li_bil_cnt],'#0.0') +ls_pipe
						continue
					End If					
					ls_buffer += String(ldc_btramt[li_bil_cnt],'#0.0') + ls_pipe
				NEXT
				
				ls_buffer += String(ldc_cur_balance+ldc_pre_balance,'#0.0') + ls_pipe	 	        //청구액
				If li_validkey_cnt > 1 Then
					ls_buffer += ls_validkey_min +'외 '+ String(li_validkey_cnt) +'회선' + ls_pipe  //발신번호
				Else
					ls_buffer += ls_validkey_min + ls_pipe
				End If

				ls_buffer += ls_used_dt + ls_pipe								//사용기간
				ls_buffer += is_data[6] + ls_pipe								//발행일자
				If IsNull(ls_holder) Then ls_holder =""
				ls_buffer += ls_holder + ls_pipe									//KT 고객명
				If IsNull(ls_adding_key) Then ls_adding_key=""
				ls_buffer += ls_adding_key + ls_pipe							//KT 전화번호


				//Record 1 Write
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
				ls_kt_file = ""	
				
			End If

End Choose

ii_rc = 0
Return 
end subroutine

on b5u_dbmgr7_vtel.create
call super::create
end on

on b5u_dbmgr7_vtel.destroy
call super::destroy
end on

