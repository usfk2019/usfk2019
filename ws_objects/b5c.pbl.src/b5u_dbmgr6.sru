$PBExportHeader$b5u_dbmgr6.sru
$PBExportComments$[ceusee] 청구자료 대행업체에 보내기
forward
global type b5u_dbmgr6 from u_cust_a_db
end type
end forward

global type b5u_dbmgr6 from u_cust_a_db
end type
global b5u_dbmgr6 b5u_dbmgr6

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_cms_file, ls_giro_file, ls_day,ls_ref_desc, ls_giro, ls_cms, ls_use_from, ls_use_to
String ls_buffer, ls_tmp, ls_name[], ls_null, ls_code, ls_code1, ls_person, ls_code_pos[]
String ls_payid, ls_inputclosedt, ls_customernm, ls_addr1, ls_addr2, ls_zipcod, ls_location, ls_buildingno, ls_ctype2, ls_cregno
String ls_roomno, ls_supplyamt, ls_pre_balance, ls_cur_balance, ls_trdt, ls_btramt[], ls_totamt, ls_use_month, ls_surtax
String ls_line, ls_itemcod, ls_aptid, ls_buildingid, ls_houseid, ls_user_name, ls_id_name, ls_memberid, ls_locationnm
String ls_acct_owner, ls_bank
String ls_inputdeadline

Dec lc_totamt_de, lc_rate, lc_dealy_amt
long ll_format, ll_count, ll_contractseq, i, ll_line, ll_user_count, ll_totline
Int li_write_bytes, li_filenum, li_pos

 	String ls_outdt
	String ls_bank_name
	
	String ls_trdt_prev
	String ls_acct_owner_receipt
	String ls_acct_no_receipt
	String ls_bank_receipt
	String ls_bank_name_receipt
	String ls_amt_receipt
	String ls_transdt_receipt
	String ls_usage_receipt
	
Long ll_amt_receipt

ii_rc = -1
Choose Case is_caller
	Case "Create Invoice"
//		lu_dbmgr.is_caller = "Create Invoice"
//		lu_dbmgr.is_data[1] = is_chargedt
//		lu_dbmgr.is_data[2] = is_trdt
//		lu_dbmgr.is_data[3] = is_giro_yn
//		lu_dbmgr.is_data[4] = is_cms_yn
//      lu_dbmgr.is_data[5] = is_giro_file
//      lu_dbmgr.is_data[6] = is_cms_file


//날짜 읽어온다.
ls_giro_file = is_data[5]
ls_cms_file = is_data[6]
ls_day = fs_get_control("B5","P103", ls_ref_desc)
//Paymethod
ls_giro = fs_get_control("B0", "P129", ls_ref_desc)
ls_cms = fs_get_control("B0", "P130", ls_ref_desc)
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
ls_tmp= fs_get_control("B5", "T110", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_code_pos[])

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
//	Select info.payid, to_char(info.inputclosedtcur, 'yyyymmdd'),info.customernm,info.bil_addr1, info.bil_addr2,
//			 info.bil_zipcod, loc.locationnm, cus.buildingno, cus.roomno,to_char(nvl(amt.supplyamt,0)),to_char(nvl(amt.pre_balance,0)),
//			 to_char(info.trdt, 'yyyymmdd'),to_char(nvl(amt.btramt01,0)), to_char(nvl(amt.btramt02,0)), to_char(nvl(amt.btramt03,0)),
//			 to_char(amt.cur_balance + amt.pre_balance), to_char(add_months(info.trdt,-1), 'yyyymm'), to_char(nvl(amt.surtax,0))
//	from reqinfo info, reqamtinfo amt, customerm cus, locmst loc
//	where info.payid = amt.payid and info.payid = cus.customerid  and loc.location = cus.location
//	and to_char(info.trdt, 'yyyymmdd') = :is_data[2] and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
//	and info.chargedt =:is_data[1] and amt.chargedt = :is_data[1] and info.pay_method = :ls_giro
   Select info.payid, to_char(info.inputclosedtcur, 'yyyymmdd'),info.customernm,info.bil_addr1, info.bil_addr2, info.ctype2, info.cregno,
			 info.bil_zipcod, cus.location,loc.locationnm, cus.buildingno, cus.roomno,to_char(nvl(amt.supplyamt,0)),to_char(nvl(amt.pre_balance,0)),to_char(nvl(amt.cur_balance,0)),
			 to_char(info.trdt, 'yyyymmdd'),
			 to_char(amt.cur_balance + amt.pre_balance), to_char(add_months(info.trdt,-1), 'yyyymm'), to_char(nvl(amt.surtax,0)),
			 to_char(nvl(amt.btramt01,0)),
			 to_char(nvl(amt.btramt02,0)),
			 to_char(nvl(amt.btramt03,0)),
			 to_char(nvl(amt.btramt04,0)),
			 to_char(nvl(amt.btramt05,0)),
			 to_char(nvl(amt.btramt06,0)),
			 to_char(nvl(amt.btramt07,0)),
			 to_char(nvl(amt.btramt08,0)),
			 to_char(nvl(amt.btramt09,0)),
			 to_char(nvl(amt.btramt10,0))
	from reqinfo info, reqamtinfo amt, customerm cus, locmst loc
	where info.payid = amt.payid and info.payid = cus.customerid  and loc.location = cus.location
	and to_char(info.trdt, 'yyyymmdd') = :is_data[2] and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
	and info.chargedt =:is_data[1] and amt.chargedt = :is_data[1] and info.pay_method = :ls_giro
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
		INTO :ls_payid, :ls_inputclosedt, :ls_customernm, :ls_addr1, :ls_addr2, :ls_ctype2, :ls_cregno,
			  :ls_zipcod, :ls_location,:ls_locationnm, :ls_buildingno, :ls_roomno, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
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
			  :ls_btramt[10];
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo")
		CLOSE cur_get_reqinfo;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	//입금마감일(매월말일)
	ls_inputdeadline = String( &
								f_mon_last_date(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 				Integer(MidA(ls_trdt, 5, 2)), &
						 				Integer(MidA(ls_trdt, 7, 2)) &
										 )) &
								,"yyyymmdd" &
							)
	
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
							 
	//계약 번호
	DECLARE cur_get CURSOR FOR
	Select contractseq
	from contractmst
	where customerid = :ls_payid and  (change_flag <> 'C'or change_flag is null)
	and to_char(bil_fromdt, 'yyyymmdd') <= :ls_use_from
	and to_char(nvl(bil_todt,sysdate), 'yyyymmdd') >=  :ls_use_to;
	
   OPEN cur_get;
   Do While(True)
	FETCH cur_get
	Into :ll_contractseq;

   If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(contractmst)")
	  Return
   ElseIf SQLCA.sqlcode  = 100 Then
	  Exit
   End If
	
		If ll_contractseq <> 0 Then
		  //계약 품목가져오기
		  DECLARE cur_get_contractseq CURSOR FOR
				select itemcod 
				From contractdet where contractseq = :ll_contractseq;
		  OPEN cur_get_contractseq;
		  Do While(True)
			FETCH cur_get_contractseq
			INTO :ls_itemcod;
		
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, ":cur_get_contractseq")
				CLOSE cur_get_contractseq;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			select itemcnt into :ll_line from itemmst where itemcod = :ls_itemcod;
			ll_totline += ll_line
			
		  Loop
		  ls_line = fs_fill_zeroes(String(ll_totline), -2)
		  CLOSE cur_get_contractseq;
	    End If
		 
	 Loop
	 CLOSE cur_get;

  //회원수, 이름(ID)
//  select aptid, buildingid, houseid
//  into :ls_aptid, :ls_buildingid, :ls_houseid
//  From member
//  where userid = :ls_payid;
  
//   If SQLCA.sqlcode < 0 Then
//	  f_msg_sql_err(is_caller, "Select Error(member)")
//	  Return
//   ElseIf SQLCA.sqlcode  = 100 Then
//	  ls_aptid = ""
//	  ls_buildingid = ""
//	  ls_houseid = ""
//   End If
  
  
  
//  If ls_aptid <> "" Then
	
//	 DECLARE cur_get_aptid CURSOR FOR
//	 select memberid, name from member where aptid = :ls_location and buildingid = :ls_buildingno
//	                                         and houseid = :ls_roomno;
//	 OPEN cur_get_aptid;
//	 Do While(True)
//		FETCH cur_get_aptid
//		INTO :ls_memberid, :ls_user_name;
//		If SQLCA.sqlcode < 0 Then
//			f_msg_sql_err(is_Title, ":cur_get_contractseq")
//			CLOSE cur_get_aptid;
//			Return
//		ElseIf SQLCA.SQLCode = 100 Then
//			Exit
//		End If
//
//		ll_user_count += 1  //회원수
//		If Len(ls_user_name + "(" + ls_memberid + ")") > 22 Then Left(ls_user_name + "(" + ls_memberid + ")", 22)
//		ls_id_name += fs_fill_spaces(ls_user_name + "(" + ls_memberid + ")", 22)
//	Loop
//	CLOSE cur_get_aptid;
 // end If
  
 	
	
	//버퍼에 자료 생성
	ls_buffer += "1"                                             //RECORD1
	ls_buffer += ls_use_month                                    //사용월
//	ls_buffer += ls_inputclosedt                     				 //납기기한
	ls_buffer += ls_inputdeadline                     				 //납기기한
	If LenA(ls_payid) > 7 Then LeftA(ls_payid,7)
	ls_buffer += fs_fill_zeroes(ls_payid, -7)                    //고객번호 앞에 0체움
	If LenA(ls_customernm) > 20 Then LeftA(ls_customernm, 20)
	ls_buffer += fs_fill_spaces(ls_customernm, 20)               //고객이름
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   //주소1
	If LenA(ls_addr2) > 80 Then LeftA(ls_addr2, 80)
	ls_buffer += fs_fill_spaces(ls_addr2, 80)                    //주소2
	If LenA(ls_locationnm) > 40 Then LeftA(ls_locationnm,40)
	ls_buffer += fs_fill_spaces(ls_locationnm, 40)               //APT
	If LenA(ls_buildingno) > 6 Then LeftA(ls_buildingno,6)
	ls_buffer += fs_fill_spaces(ls_buildingno, -6)               //동 앞에 spaces
	If LenA(ls_roomno) > 6 Then LeftA(ls_roomno,6)
	ls_buffer += fs_fill_spaces(ls_roomno, -6)                   //호 앞에 spaces
	If LenA(ls_zipcod) > 6 Then LeftA(ls_zipcod,6)
	ls_buffer += fs_fill_spaces(ls_zipcod, 6)                    //우편번호
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,10)
		ls_buffer += fs_fill_spaces(ls_cregno, 10)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 10)
	END IF
	ls_buffer += fs_fill_zeroes(ls_supplyamt, -6)                //공급가액
	ls_buffer += fs_fill_zeroes(ls_surtax, -6)                   //세액
	ls_buffer += fs_fill_zeroes(ls_pre_balance, -6)               //미납금액
	
	ls_buffer += fs_fill_zeroes(ls_btramt[dec(ls_code_pos[1])], -6)//연체료
	ls_buffer += fs_fill_zeroes(ls_btramt[dec(ls_code_pos[2])], -6)//절사액
	
	
	
	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       //작성일자
	
	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo;
		ii_rc = -2
		Return 
	End If
	
	ls_buffer = ""
	
	ls_buffer += "2"                                             //RECORD2
	//If ll_user_count > 100 Then ll_user_count = 99
	//ls_buffer += fs_fill_zeroes( String(ll_user_count) , -2)     //회원수
	//ls_buffer += fs_fill_spaces(ls_id_name, 132)                 //회원ID
	
	ls_buffer += fs_fill_zeroes(ls_line, -2)                      //회선수
	
	If Dec(ls_pre_balance) <> 0 Then 
		ls_code += "99"                                           //미납금액
		ls_code1 += fs_fill_zeroes(ls_pre_balance, -11)           
	End IF
	
	FOR li_pos = 1 to 10
		IF ls_btramt[li_pos] <> '0' THEN
			ls_code += fs_fill_zeroes(string(li_pos), -2)                                        //이용금액
			ls_code1 += fs_fill_zeroes(ls_btramt[li_pos], -11)          
		END IF
	NEXT

	ls_buffer += fs_fill_zeroes(ls_code, 22)                      //이용내역 Code
	ls_buffer += fs_fill_zeroes(ls_code1,121)                     //이용요금
	ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //청구금액
	ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //납기내 금액
	ls_buffer += fs_fill_zeroes(String(lc_totamt_de), -11)       //납기후 금액
	ls_buffer += Space(78)
	
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

//자동이체 파일 생성
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
//	Select info.payid, to_char(info.inputclosedtcur, 'yyyymmdd'),info.customernm,info.bil_addr1, info.bil_addr2,
//			 info.bil_zipcod, loc.locationnm, cus.buildingno, cus.roomno,to_char(nvl(amt.supplyamt,0)),to_char(nvl(amt.pre_balance,0)),
//			 to_char(info.trdt, 'yyyymmdd'),to_char(nvl(amt.btramt01,0)), to_char(nvl(amt.btramt02,0)), to_char(nvl(amt.btramt03,0)),
//			 to_char(amt.cur_balance + amt.pre_balance), to_char(add_months(info.trdt,-1), 'yyyymm'), to_char(nvl(amt.surtax,0))
//	from reqinfo info, reqamtinfo amt, customerm cus, locmst loc
//	where info.payid = amt.payid and info.payid = cus.customerid  and loc.location = cus.location
//	and to_char(info.trdt, 'yyyymmdd') = :is_data[2] and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
//	and info.chargedt =:is_data[1] and amt.chargedt = :is_data[1] and info.pay_method = :ls_giro
   Select info.payid, to_char(info.inputclosedtcur, 'yyyymmdd'),info.customernm,info.bil_addr1, info.bil_addr2, info.ctype2, info.cregno,
			 info.acct_owner, info.bank,
			 info.acctno,
			 info.bil_zipcod, cus.location,loc.locationnm, cus.buildingno, cus.roomno,to_char(nvl(amt.supplyamt,0)),to_char(nvl(amt.pre_balance,0)),to_char(nvl(amt.cur_balance,0)),
			 to_char(info.trdt, 'yyyymmdd'),
			 to_char(amt.cur_balance + amt.pre_balance), to_char(add_months(info.trdt,-1), 'yyyymm'), to_char(nvl(amt.surtax,0)),
			 to_char(nvl(amt.btramt01,0)),
			 to_char(nvl(amt.btramt02,0)),
			 to_char(nvl(amt.btramt03,0)),
			 to_char(nvl(amt.btramt04,0)),
			 to_char(nvl(amt.btramt05,0)),
			 to_char(nvl(amt.btramt06,0)),
			 to_char(nvl(amt.btramt07,0)),
			 to_char(nvl(amt.btramt08,0)),
			 to_char(nvl(amt.btramt09,0)),
			 to_char(nvl(amt.btramt10,0))
	from reqinfo info, reqamtinfo amt, customerm cus, locmst loc
	where info.payid = amt.payid and info.payid = cus.customerid  and loc.location = cus.location
	and to_char(info.trdt, 'yyyymmdd') = :is_data[2] and to_char(amt.trdt, 'yyyymmdd') = :is_data[2]
	and info.chargedt =:is_data[1] and amt.chargedt = :is_data[1] and info.pay_method = :ls_cms
	and info.inv_yn = 'Y'	
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
			  :ls_acct_owner, :ls_bank,
			  :ls_acct_no_receipt,
			  :ls_zipcod, :ls_location,:ls_locationnm, :ls_buildingno, :ls_roomno, :ls_supplyamt, :ls_pre_balance, :ls_cur_balance,
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
			  :ls_btramt[10];
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_Title, ":cur_get_reqinfo")
		CLOSE cur_get_reqinfo2;
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	//전월청구일
	ls_trdt_prev = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
	
	//연체금액 계산
	lc_dealy_amt = Truncate((Dec(ls_cur_balance) * (lc_rate/100)) ,ll_format);  
	lc_totamt_de = lc_dealy_amt + Dec(ls_totamt)
	
	//회선수 구하기
	ls_use_from = String(fd_pre_month(Date(Integer(MidA(ls_trdt, 1, 4)), &
						 Integer(MidA(ls_trdt, 5, 2)), &
						 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")

	//전일구하기(현월청구주기마지막일)
	ls_use_to = String(fd_date_pre(Date(Integer(MidA(ls_trdt, 1, 4)), &
							 Integer(MidA(ls_trdt, 5, 2)), &
							 Integer(MidA(ls_trdt, 7, 2))), 1), "yyyymmdd")
							 
	//계약 번호
	DECLARE cur_get2 CURSOR FOR
	Select contractseq
	from contractmst
	where customerid = :ls_payid and  (change_flag <> 'C'or change_flag is null)
	and to_char(bil_fromdt, 'yyyymmdd') <= :ls_use_from
	and to_char(nvl(bil_todt,sysdate), 'yyyymmdd') >=  :ls_use_to;
	
   OPEN cur_get2;
   Do While(True)
	FETCH cur_get2
	Into :ll_contractseq;

   If SQLCA.sqlcode < 0 Then
	  f_msg_sql_err(is_caller, "Select Error(contractmst)")
	  Return
   ElseIf SQLCA.sqlcode  = 100 Then
	  Exit
   End If
	
		If ll_contractseq <> 0 Then
		  //계약 품목가져오기
		  DECLARE cur_get_contractseq2 CURSOR FOR
				select itemcod 
				From contractdet where contractseq = :ll_contractseq;
		  OPEN cur_get_contractseq2;
		  Do While(True)
			FETCH cur_get_contractseq2
			INTO :ls_itemcod;
		
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, ":cur_get_contractseq")
				CLOSE cur_get_contractseq2;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			select itemcnt into :ll_line from itemmst where itemcod = :ls_itemcod;
			ll_totline += ll_line
			
		  Loop
		  ls_line = fs_fill_zeroes(String(ll_totline), -2)
		  CLOSE cur_get_contractseq2;
	    End If
		 
	 Loop
	 CLOSE cur_get2;

  //회원수, 이름(ID)
//  select aptid, buildingid, houseid
//  into :ls_aptid, :ls_buildingid, :ls_houseid
//  From member
//  where userid = :ls_payid;
  
//   If SQLCA.sqlcode < 0 Then
//	  f_msg_sql_err(is_caller, "Select Error(member)")
//	  Return
//   ElseIf SQLCA.sqlcode  = 100 Then
//	  ls_aptid = ""
//	  ls_buildingid = ""
//	  ls_houseid = ""
//   End If
  
  
  
//  If ls_aptid <> "" Then
	
//	 DECLARE cur_get_aptid CURSOR FOR
//	 select memberid, name from member where aptid = :ls_location and buildingid = :ls_buildingno
//	                                         and houseid = :ls_roomno;
//	 OPEN cur_get_aptid;
//	 Do While(True)
//		FETCH cur_get_aptid
//		INTO :ls_memberid, :ls_user_name;
//		If SQLCA.sqlcode < 0 Then
//			f_msg_sql_err(is_Title, ":cur_get_contractseq")
//			CLOSE cur_get_aptid;
//			Return
//		ElseIf SQLCA.SQLCode = 100 Then
//			Exit
//		End If
//
//		ll_user_count += 1  //회원수
//		If Len(ls_user_name + "(" + ls_memberid + ")") > 22 Then Left(ls_user_name + "(" + ls_memberid + ")", 22)
//		ls_id_name += fs_fill_spaces(ls_user_name + "(" + ls_memberid + ")", 22)
//	Loop
//	CLOSE cur_get_aptid;
 // end If
 
 //출금예정일(매월25일)
 ls_outdt = String( &
								Date(Integer(MidA(ls_trdt, 1, 4)), &
						 				Integer(MidA(ls_trdt, 5, 2)), &
						 				25) &
								,"yyyymmdd" &
							)
	SELECT codenm
	INTO :ls_bank_name
	FROM syscod2t
	WHERE grcode = 'B400'
	AND code = :ls_bank;
	
	IF SQLCA.sqlcode = 0 THEN
	//	ls_bank_name = ""
	END IF
	
	
	//########영수증(지난달청구 및 입금내역)
	ls_acct_owner_receipt = ""         //예금주명(영수증)
	ls_acct_no_receipt = ""            //계좌번호(영수증)
	ls_bank_name_receipt = ""          //거래은행(영수증)
	ls_usage_receipt = ""              //영수요금사용월(영수증)
	
	ls_amt_receipt = ""                //영수금액(영수증)
	ls_transdt_receipt = ""		        //출금(이체)일(영수증)
	
	//영수금액 및 출금일자
	SELECT (sum(nvl(reqamt,0))-sum(nvl(erramt,0))) payamt, max(to_char(outdt,'yyyymmdd')) outdt
	INTO :ll_amt_receipt, :ls_transdt_receipt
	FROM banktext
	WHERE bil_status = '3'  
	AND to_char(trdt,'yyyymmdd') = :ls_trdt_prev
	AND payid = :ls_payid
	GROUP BY payid;
	
	//Error
	IF SQLCA.sqlcode = -1 THEN
		ls_transdt_receipt = ""
	//No Result
	ELSEIF SQLCA.sqlcode = 100 THEN
		ls_transdt_receipt = ""
	//OK
	ELSE
		ls_amt_receipt = String(ll_amt_receipt)              //영수금액(영수증)
		ls_transdt_receipt = ls_transdt_receipt		        //출금(이체)일(영수증)
		
		//계좌번호, 거래은행
		SELECT acctno, bank
		INTO :ls_acct_no_receipt, :ls_bank_receipt
		FROM banktext
		WHERE bil_status = '3'  
		AND to_char(trdt,'yyyymmdd') = :ls_trdt_prev
		AND payid = :ls_payid
		AND rownum = 1;
		
		//Error
		IF SQLCA.sqlcode = -1 THEN
			ls_acct_no_receipt = ""
		//No Result
		ELSEIF SQLCA.sqlcode = 100 THEN
			ls_acct_no_receipt = ""
		//OK
		ELSE
			//예금주명
			SELECT acct_owner
			INTO :ls_acct_owner_receipt
			FROM billinginfo
			WHERE customerid = :ls_payid;
			
			IF SQLCA.sqlcode = 100 THEN
				ls_acct_owner_receipt = ls_acct_owner
			ELSEIF SQLCA.sqlcode < 0 THEN
				ls_acct_owner_receipt = ls_acct_owner
			END IF
			
			
			//거래은행명
			SELECT codenm
			INTO :ls_bank_name_receipt
			FROM syscod2t
			WHERE grcode = 'B400'
			AND code = :ls_bank_receipt;
			
			IF SQLCA.sqlcode = 100 THEN
				ls_bank_name_receipt = ls_bank_name
			ELSEIF SQLCA.sqlcode < 0 THEN
				ls_bank_name_receipt = ls_bank_name
			END IF
		
		
			//영수요금사용월
			ls_usage_receipt = String(fd_pre_month(Date(Integer(MidA(ls_use_from, 1, 4)), &
						 Integer(MidA(ls_use_from, 5, 2)), &
						 1),1), "yyyymm")
		END IF
		
	END IF




	//버퍼에 자료 생성
	ls_buffer += "1"                                             //RECORD1
	ls_buffer += ls_use_month                                    //사용월
	ls_buffer += ls_outdt                     						 //출금예정일
	If LenA(ls_payid) > 7 Then LeftA(ls_payid,7)
	ls_buffer += fs_fill_zeroes(ls_payid, -7)                    //고객번호 앞에 0체움
	If LenA(ls_customernm) > 20 Then LeftA(ls_customernm, 20)
	ls_buffer += fs_fill_spaces(ls_customernm, 20)               //고객이름
	If LenA(ls_addr1) > 100 Then LeftA(ls_addr1, 100)
	ls_buffer += fs_fill_spaces(ls_addr1, 100)                   //주소1
	If LenA(ls_addr2) > 80 Then LeftA(ls_addr2, 80)
	ls_buffer += fs_fill_spaces(ls_addr2, 80)                    //주소2
	If LenA(ls_locationnm) > 40 Then LeftA(ls_locationnm,40)
	ls_buffer += fs_fill_spaces(ls_locationnm, 40)               //APT
	If LenA(ls_buildingno) > 6 Then LeftA(ls_buildingno,6)
	ls_buffer += fs_fill_spaces(ls_buildingno, -6)               //동 앞에 spaces
	If LenA(ls_roomno) > 6 Then LeftA(ls_roomno,6)
	ls_buffer += fs_fill_spaces(ls_roomno, -6)                   //호 앞에 spaces
	If LenA(ls_zipcod) > 6 Then LeftA(ls_zipcod,6)
	ls_buffer += fs_fill_spaces(ls_zipcod, 6)                    //우편번호
	If LenA(ls_acct_owner) > 20 Then LeftA(ls_acct_owner,20)
	ls_buffer += fs_fill_spaces(ls_acct_owner, 20)               //예금주명
	ls_buffer += fs_fill_zeroes(ls_totamt,-6)                    //이용요금	
	If LenA(ls_bank_name) > 20 Then LeftA(ls_bank_name,20)
	ls_buffer += fs_fill_spaces(ls_bank_name, 20)               //거래은행
	ls_buffer += fs_fill_zeroes(ls_pre_balance, -6)               //미납금액
	//개인고객이 아닌경우 공급받는자 등록번호(사업자등록번호)
	//법인
	IF ls_ctype2 <> ls_person THEN
		If LenA(ls_cregno) > 10 Then LeftA(ls_cregno,10)
		ls_buffer += fs_fill_spaces(ls_cregno, 10)
	//개인
	ELSE
		ls_buffer += fs_fill_spaces("", 10)
	END IF
	ls_buffer += fs_fill_zeroes(ls_supplyamt, -6)                //공급가액
	ls_buffer += fs_fill_zeroes(ls_surtax, -6)                   //세액
	ls_buffer += fs_fill_zeroes(ls_btramt[dec(ls_code_pos[2])], -6)//절사액
//	ls_buffer += fs_fill_zeroes(ls_btramt[dec(ls_code_pos[1])], -6)//연체료
	
	ls_buffer += MidA(ls_trdt,1,6) + ls_day                       //작성일자
	//영수증(지난달청구 및 입금내역)
	ls_buffer += fs_fill_spaces(ls_acct_owner_receipt, 20)      //예금주명(영수증)
	ls_buffer += fs_fill_spaces(ls_acct_no_receipt, 20)         //계좌번호(영수증)
	ls_buffer += fs_fill_spaces(ls_bank_name_receipt, 20)       //거래은행(영수증)
	ls_buffer += fs_fill_zeroes(ls_amt_receipt, -6)             //영수금액(영수증)
	ls_buffer += fs_fill_spaces(ls_transdt_receipt, 8)			//출금(이체)일(영수증)
	ls_buffer += fs_fill_spaces(ls_usage_receipt, 6)           //영수요금사용월(영수증)
	
	
	
	
	//Record 1 Write
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
		FileClose(li_filenum)
		Close cur_get_reqinfo2;
		ii_rc = -2
		Return 
	End If
	
	ls_buffer = ""
	
	ls_buffer += "2"                                             //RECORD2
	//If ll_user_count > 100 Then ll_user_count = 99
	//ls_buffer += fs_fill_zeroes( String(ll_user_count) , -2)     //회원수
	//ls_buffer += fs_fill_spaces(ls_id_name, 132)                 //회원ID
	
	ls_buffer += fs_fill_zeroes(ls_line, -2)                      //회선수
	
	If Dec(ls_pre_balance) <> 0 Then 
		ls_code += "99"                                           //미납금액
		ls_code1 += fs_fill_zeroes(ls_pre_balance, -11)           
	End IF
	
	FOR li_pos = 1 to 10
		IF ls_btramt[li_pos] <> '0' THEN
			ls_code += fs_fill_zeroes(string(li_pos), -2)                                        //이용금액
			ls_code1 += fs_fill_zeroes(ls_btramt[li_pos], -11)          
		END IF
	NEXT

	ls_buffer += fs_fill_zeroes(ls_code, 22)                      //이용내역 Code
	ls_buffer += fs_fill_zeroes(ls_code1,121)                     //이용요금
	ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //청구금액
	ls_buffer += fs_fill_zeroes(ls_totamt,-11)                   //납기내 금액
	ls_buffer += fs_fill_zeroes(String(lc_totamt_de), -11)       //납기후 금액
	ls_buffer += Space(78)
	
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

on b5u_dbmgr6.create
call super::create
end on

on b5u_dbmgr6.destroy
call super::destroy
end on

