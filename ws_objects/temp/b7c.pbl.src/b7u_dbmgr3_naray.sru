$PBExportHeader$b7u_dbmgr3_naray.sru
$PBExportComments$[jwlee] 자동이체(EDI)처리_naray용
forward
global type b7u_dbmgr3_naray from u_cust_a_db
end type
end forward

global type b7u_dbmgr3_naray from u_cust_a_db
end type
global b7u_dbmgr3_naray b7u_dbmgr3_naray

type variables
String is_cmsacpdt, is_filename
end variables

forward prototypes
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_05 ()
end prototypes

public subroutine uf_prc_db_04 ();Integer li_FileNum
Long ll_bytes_read, ll_FLength
String ls_buffer, ls_recordtype
String ls_error_code, ls_file_name, ls_receiptdt, ls_prcno, ls_payid, ls_result_code
String ls_drawingresult, ls_drawingresults[]
String ls_temp, ls_ref_desc, ls_status[]
Integer li_return, li_cnt, li_errcnt_T, li_errcnt_P
String ls_trdt
date ld_trdt
Dec lc_erramt, lc_erramt_T, lc_erramt_P, lc_subamt

ii_rc = -1
Choose Case is_caller
 Case "GR24%FileRead"
	//** is_data[1] : pathname, is_data[2] : filename,
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
		
		Constant Integer GR24_SIZE = 150
	
		//출금이체신청처리상태
		ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
		
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(1001, is_Title, is_data[2])
			FileClose(li_filenum)
			Return
		End If
	
		Do While(True)
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > GR24_SIZE Then
				FileSeek(li_FileNum, GR24_SIZE - ll_bytes_read, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, GR24_SIZE)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case "12"  //Header
					ls_trdt = Trim(MidA(ls_buffer, 81, 8))      //납기일
				   ls_trdt = LeftA(ls_trdt,4)+'-'+MidA(ls_trdt,5,2) +'-' + RightA(ls_trdt,2)
					ld_trdt = date(ls_trdt)
					
				Case "22"
					//ls_result_code = Trim(Mid(ls_buffer, 67, 1))
					ls_payid = Trim(MidA(ls_buffer, 10, 20))      //납부자
					ls_error_code = Trim(MidA(ls_buffer, 91, 2))  //출금결과코드
				   lc_subamt = Dec(Trim(MidA(ls_buffer, 94, 11)))//부분출금금액
					If ls_error_code = "09" Then  //부분출금
						ls_result_code = 'P'
					Else
						ls_result_code = 'N'  
					End If
					
					// 에러인 고객 Update 
					Update banktext
					SET result_code = :ls_result_code, error_code = :ls_error_code,
					    bil_status = :ls_status[3], transdt = :ld_trdt,
						erramt = (reqamt - :lc_subamt)  //총금액 - 부분출금금액
					WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4]
					AND payid = :ls_payid;
					
					// Error
					If SQLCA.SQLCode < 0 Then
						FileClose(li_filenum)
						f_msg_sql_err(is_Title, " Update Error(banktext)")
						Rollback;
						return
					End If
					
			End Choose
					
		Loop
		
		FileClose(li_FileNum)
		//신청인것을 입금 확인으로
		Update banktext
		SET bil_status = :ls_status[3], transdt = :ld_trdt
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4]
		AND bil_status = :ls_status[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, " Update Error1(banktext)")
			Rollback;
			return
		End If

		// 전액출금불능건수, 전액출금불능금액
		SELECT count(*), sum(nvl(erramt,0))
		INTO :li_errcnt_t, :lc_erramt_t
		FROM banktext
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4] 
		AND result_code = 'N';
		
		// 부분출금불능건수, 부분출금불능금액
		SELECT count(*), sum(erramt)
		INTO :li_errcnt_P, :lc_erramt_P
		FROM banktext
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4] 
		AND result_code = 'P';
		
		// Update BankTextStatus
		UPDATE banktextstatus
		SET errcnt_t = :li_errcnt_t, erramt_t = :lc_erramt_t,
			errcnt_p = :li_errcnt_p, erramt_p = :lc_erramt_p,
			status = :ls_status[3], resultprcdt = sysdate, transdt = :ld_trdt, 
			updt_user = :is_data[5], updtdt = sysdate
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4];
		
		If SQLCA.SQLCode < 0 Then
			FileClose(li_filenum)
			f_msg_sql_err(is_Title, " Update Error1(banktextstatus)")
			Rollback;
			Return
		End If
		

 Case "GR25%FileRead"
	//** is_data[1] : pathname, is_data[2] : filename,
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
		
		Constant Integer GR25_SIZE = 150
			
		//출금이체신청처리상태
		ls_temp   = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
		
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(1001, is_Title, is_data[2])
			FileClose(li_filenum)
			Return
		End If
	
		Do While(True)
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > GR25_SIZE Then
				FileSeek(li_FileNum, GR25_SIZE - ll_bytes_read, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, GR25_SIZE)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case "13"  //Header
					ls_trdt = Trim(MidA(ls_buffer, 81, 8))      //납기일
				   ls_trdt = LeftA(ls_trdt,4)+'-'+MidA(ls_trdt,5,2) +'-' + RightA(ls_trdt,2)
					ld_trdt = date(ls_trdt)
					
				Case "23"
					//ls_result_code = Trim(Mid(ls_buffer, 67, 1))
					ls_payid      = Trim(MidA(ls_buffer, 10, 20))        //납부자
					ls_error_code = Trim(MidA(ls_buffer, 91, 2))         //출금결과코드
				   lc_subamt     = Dec(Trim(MidA(ls_buffer, 94, 11)))   //부분출금금액
					
										
					UPDATE banktext
					   SET erramt      = reqamt,
						    resule_code = 'N',
						    error_code  = :ls_error_code,
					       bil_status  = :ls_status[5]
					 WHERE file_name   = :is_data[3] 
					   AND to_char(outdt,'yyyymmdd') = :is_data[4]
					   AND payid       = :ls_payid;
						
					// Error
					If SQLCA.SQLCode < 0 Then
						FileClose(li_filenum)
						f_msg_sql_err(is_Title, " Update Error(banktext)")
						Rollback;
						return
					End If
					
			End Choose
					
		Loop
		
		FileClose(li_FileNum)
		
End Choose

Commit;

ii_rc = 0 
				
end subroutine

public subroutine uf_prc_db_06 ();Integer li_FileNum, ll_reqcnt, li_write_bytes
Long ll_bytes_read, ll_FLength, ll_seqno
String ls_buffer, ls_recordtype
String ls_error_code,ls_prcno, ls_payid, ls_resultcode, ls_errorcode, ls_reqdt, ls_reqtype
String ls_drawingtype, ls_drawingresult, ls_drawingresults[], ls_drawingreqdt, ls_bank, ls_acctno, ls_acct_ssno
String ls_temp, ls_ref_desc, ls_status[], ls_receiptcod, ls_name
String ls_cms, ls_giro, ls_paymethod, ls_receiptdt, ls_acct_owner, ls_bef_payid
Integer li_return

String ls_filename, ls_bankreq_fname, ls_prcno_22max, ls_worktype
Long ll_bytes,ll_bcancelcnt, ll_bnewcnt, ll_bchgcnt, ll_bchgcnt1, ll_bbcancelcnt,ll_bcancelcnt1, ll_errcnt
String ls_drawingtype_1, ls_outtype, ls_receiptcod_1, ls_bil_bilcycle
String  ls_bankcod[], ls_datacod[], ls_bil_pay_method, ls_result[]
String  ls_bil_payid, ls_bil_acctno, ls_bil_drawingtype, ls_bil_drawingresult
String ls_phone, ls_code
String ls_cmsacpdt //처리일자yyyymmdd
String ls_gr22_filename	//GR22파일이름
String ls_bilcycle_edi, ls_paymethod_edi, ls_bilcycle_cancel, ls_paymethod_cancel, ls_reqyn, ls_bilcycle
String ls_bank_code   //2004.06.28. khpark add
Boolean lb_reject
String ls_gr21max_prcno, ls_gr22max_prcno
Long   ll_gr21cnt,ll_gr22cnt
String ls_receiptno		////전자접수번호 2004.12.24 jjuhm add

ii_rc = -1
Choose Case is_caller
	Case "EDI GR21%Save%Write"
//lu_dbmgr.is_caller = "EDI GR21%Save%Write"
//lu_dbmgr.is_title = This.Title
//lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.is_data[1] = ls_pathname               //GR21파일에 Path    
//lu_dbmgr.is_data[2] = ls_filename               //GR21파일
//lu_dbmgr.is_data[3] = is_worktype[1]            //은행신청
//lu_dbmgr.is_data[4] = is_filepath			        //GR22생성할 path
//lu_dbmgr.is_data[5] = is_filenm			        //GR22생성할 파일 이름 Prefix
//lu_dbmgr.is_data[6] = ls_cmsacpdt			        //처리일자
//lu_dbmgr.is_data[7] = is_coid			           //기관식별코드(지로번호)
//lu_dbmgr.is_data[8] = is_coname                 //이용기간명 
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no] //pgmid
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no] //pgmid
		Constant Integer GR21_Size = 150
		Constant Integer GR22_Size = 150
		ll_errcnt = 0
		
		//1.GR21 Open
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(10001, is_Title, is_data[1])
			FileClose(li_filenum)
			ii_rc =-3
			Return
		End If

		// Status : sysctl1t 파일의 상태
		ls_temp   = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
//		ls_temp = fs_get_control("B7", "A300", ls_ref_desc)    //신청 접수처
//		li_return = fi_cut_string(ls_temp, ";", ls_receiptcod)
		ls_temp   = fs_get_control("B7", "A330", ls_ref_desc)    
		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults) //이체신청 결과 
		
		ls_giro   = fs_get_control("B0", "P129", ls_ref_desc)  //지로  
		ls_cms    = fs_get_control("B0", "P130", ls_ref_desc)  //자동이체
		
	   //은행신청 유형
		ls_temp   = fs_get_control("B7", "A608", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_bankcod[])
		
		//접수처 구분코드
//		ls_code = fs_get_control("B7", "A604", ls_ref_desc)
		
		//Data 구분코드
		ls_temp   = fs_get_control("B7", "A601", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_datacod[])
		
		//자동이체 신청시(청구주기;청구방법)
		ls_temp = fs_get_control("B7", "A612", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_result[])
		 ls_bilcycle_edi  = ls_result[1]
		 ls_paymethod_edi = ls_result[2]
		 
		If ls_bilcycle_edi = "" Or ls_paymethod_edi = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			Return
		End If
		 
		//자동이체 해지시(청구주기;청구방법)
		ls_temp = fs_get_control("B7", "A613", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_result[])
		 ls_bilcycle_cancel  = ls_result[1]
		 ls_paymethod_cancel = ls_result[2]
		 
		If ls_bilcycle_cancel = "" Or ls_paymethod_cancel = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			Return
		End If		
			
		//2.File 읽으면서 테이블에 Insert 한다.
		//GR22 파일로 생성한다. 파일처리상태 응답확인
		Do While(true)
			//File Read
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > GR21_Size Then
				FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
			End If
			
			//150Byte로 읽는다. 한줄 씩
			ls_buffer = MidA(ls_buffer, 1, GR21_Size)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case "51"
					ls_cmsacpdt = Trim(MidA(ls_buffer,44,8)) //처리일자
					ls_gr22_filename = is_data[5] + MidA(ls_cmsacpdt,5,4)
				Case "71"
					ll_reqcnt = Integer(Trim(MidA(ls_buffer,3,7))) //총 Record 수
			End Choose
		Loop
     //File Close
	 FileClose(li_FileNum)
	
	
	 li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
	 If IsNull(li_FileNum) Then li_FileNum = -1
	 If li_FileNum < 0 Then
		f_msg_usr_err(10001, is_Title, is_data[1])
		FileClose(li_filenum)
		Return
	End If
		
	 Do While(true)
		//File Read
		ls_buffer = ""
		ll_bytes_read = FileRead(li_FileNum, ls_buffer)
		
		If ll_bytes_read < 0 Then Exit
		// File Pointer Move
		If ll_bytes_read > GR21_Size Then
			FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
		End If
		
	   ls_buffer = MidA(ls_buffer, 1, GR21_Size)
		ls_recordtype = LeftA(ls_buffer, 2)
		
		
		//고객 상세
		If ls_recordtype = "61" Then

			ls_prcno        = Trim(MidA(ls_buffer,3,7))
			ls_drawingreqdt = Trim(MidA(ls_buffer,10,8))    //신청일자(고객이 신청한 날짜)
			ls_drawingtype  = Trim(MidA(ls_buffer, 18,2))   //신청 구분 코드
			ls_payid        = Trim(MidA(ls_buffer, 40 ,20)) //납부자 번호
//Start 2004.06.28. khpark modify 은행납부자계좌개설점코드(은행코드2자리 + 개설점코드4자리) 6자리 
			ls_bank         = Trim(MidA(ls_buffer, 64, 2) ) //은행코드(앞자리2자리)
			ls_bank_code    = Trim(MidA(ls_buffer, 64, 6) ) //은행+납부자계좌개설점코드
//End  2004.06.28.  khpark modify 
			ls_acctno       = Trim(MidA(ls_buffer, 70, 15)) //계좌번호
			ls_acct_ssno    = Trim(MidA(ls_buffer, 85, 13)) //주민등록 번호
			//Start 2005-10-11 kem modify 접수처구분코드(전자접수구분 관련)
			ls_errorcode    = Trim(MidA(ls_buffer, 115, 2)) //처리결과코드
			ls_receiptcod   = Trim(MidA(ls_buffer,121,1))   //접수처구분코드
			//End   2005-10-11 kem modify
			ls_receiptno    = Trim(MidA(ls_buffer,122,9))	  //전자접수번호 jjuhm add
			ls_name         = Trim(MidA(ls_buffer,131,16))
			
					
		  ls_bil_payid         = ""
		  ls_bil_drawingtype   = ""
		  ls_bil_acctno        = ""
		  ls_bil_drawingresult = ""
		 //결과코드 완성
		  Select customerid, 
					drawingtype, 
					pay_method, 
					bilcycle, 
					acctno, 
					drawingresult
			 into :ls_bil_payid, 
					:ls_bil_drawingtype, 
					:ls_bil_pay_method, 
					:ls_bil_bilcycle, 
					:ls_bil_acctno, 
					:ls_bil_drawingresult
			 from billinginfo 
			where customerid = :ls_payid;
			
			If SQLCA.SQLCode < 0 Then
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "Select Error(billinginfo)")
				Return 
			End If
		
			If IsNull(ls_bil_payid)         Then ls_bil_payid         = ""
			If IsNull(ls_bil_drawingtype)   Then ls_bil_drawingtype   = ""
			If IsNull(ls_bil_acctno)        Then ls_bil_acctno        = ""
			If IsNull(ls_bil_drawingresult) Then ls_bil_drawingresult = ""
					
//			lb_reject = False	//Init
//			Choose Case ls_receiptcod
//				//은행접수분
//				Case "4", "0"
//					ls_worktype = '0'
//					
//					If ls_bil_payid = "" Then
//						 ls_errorcode = '03'  //납부자 번호 없음
//						 lb_reject = True
//					//신청 내역이 없는데 변경, 해지가 들어온 경우
//					ElseIf ls_bil_drawingtype = ""  Then
//					//순서대로 해지(03),임의해지(04),변경(05),임의변경(07)
//						If ls_drawingtype = ls_bankcod[4] or &
//						   ls_drawingtype = ls_bankcod[5] or &
//							ls_drawingtype = ls_bankcod[2] or &
//							ls_drawingtype = ls_bankcod[3] or ls_bil_drawingtype = "0" Then 
//							ls_errorcode = '01'  //신청구분코드
//						   lb_reject = True
//						Else	
//							lb_reject   = False
//						End If
//					
//					ElseIf ls_drawingtype = ls_bankcod[1] THEN     //신규 신청시  
//					  //해당납부자번호의 청구유형이 기존에 자동이체가 아니어야 함 : 아니면 ls_errorcode = "05" -> Reject
//					  //또는 금결원과의 작업이 진행중인가를 Check...
//					  //현재 신청결과가(billinginfo.drawingresult) 이 0인 상태 : 아니면 ls_errorcode = "05" -> Reject
//					 	If (ls_bil_drawingresult <> "0" AND ls_bil_drawingresult <> "F" AND ls_bil_drawingresult <> "S") Then
//							ls_errorcode = "05"
//						   lb_reject = True
//						ElseIf ls_bil_pay_method = ls_cms AND ls_bil_drawingresult <> "0" Then
//							ls_errorcode = "05"
//						   lb_reject = True
//						Else	
//							lb_reject   = False
//						End If
//						//
//					ElseIf ls_drawingtype = ls_bankcod[2] or ls_drawingtype = ls_bankcod[3] THEN     //변경 신청시  
//					//변경인 경우(ls_drawingtype = "05", "07") **************************
//					  //해당납부자번호의 청구유형이 기존에 자동이체 : 아니면 ls_errorcode = "01" -> Reject
//					  //현재 신청결과가(billinginfo.drawingresult) 이 처리성공(S) : 아니면 ls_errorcode = "99" -> Reject	
//						If ls_bil_drawingresult <> "S" Then
//							ls_errorcode = "99"
//						   lb_reject = True
//						ElseIf ls_bil_pay_method <> ls_cms Then
//							ls_errorcode = "01"
//						   lb_reject = True
//						Else	
//							lb_reject   = False
//						End If                                               
//						
//					ElseIf ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] THEN     //해지 신청시                                                 
//
//					//해지인경우(ls_drawingtype = "03", "04") ***************************
//					  //해당납부자번호의 청구유형이 기존에 자동이체 : 아니면 ls_errorcode = "01" -> Reject
//					  //현재 신청결과가(billinginfo.drawingresult) 이 처리성공(S) : 아니면 ls_errorcode = "99" -> Reject
//					  //계좌번호가 일치할 것 : 아니면 ls_errorcode = "04" -> Reject
//					 	If ls_bil_drawingresult <> "S" Then
//							ls_errorcode = "99"
//						   lb_reject = True
//						ElseIf ls_bil_pay_method <> ls_cms Then
//							ls_errorcode = "01"
//						   lb_reject = True
//						ElseIf ls_bil_acctno <> ls_acctno Then
//							ls_errorcode = "04"	
//						   lb_reject = True	
//						Else	
//							lb_reject   = False
//						End If					                              
//					
//					ElseIf ls_drawingtype = ls_bankcod[1] or &
//						    ls_drawingtype = ls_bankcod[2] or &
//							 ls_drawingtype = ls_bankcod[3] or &
//							 ls_drawingtype = ls_bankcod[4] or &
//							 ls_drawingtype = ls_bankcod[5] Then
//						
//						//미처리(1), 처리중(2) 이거나
//						//신청코드가 같으면서 처리성공(S) 이면 이중신청
//						IF (ls_bil_drawingresult = ls_drawingresults[2]) OR &
//							(ls_bil_drawingresult = ls_drawingresults[3]) OR &
//							(ls_drawingtype = ls_bil_drawingtype AND ls_bil_drawingresult = ls_drawingresults[4]) THEN
//							ls_errorcode = '06' 	
//						   lb_reject = True
//						END IF
//					
//					End If
//					
//					
//					If ls_errorcode = "00" or ls_errorcode = "" Then 
//						ls_drawingresult = ls_drawingresults[4]
//						ls_resultcode = ""
//						ls_errorcode = "00"
//					Else
//						ls_drawingresult = ls_drawingresults[5]
//						ls_resultcode = 'N'
//						ll_errcnt ++
//					End IF
//					  //결과가 성공이면서 해지이면 결제방법을 지로로 변경한다.
//					If ls_errorcode = "00" Then
//						If ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] Then 
//							ls_paymethod = ls_giro
//						Else
//							ls_paymethod = ls_cms
//						End If
//					End If
//					
//					
//					//실패이면 update하지 않는다.
//					//Billing Update                                                         
//					//성공 실패여부
//					If Not lb_reject Then
//						Update billinginfo 
//							set bank          = :ls_bank, 
//								 receiptcod    = :ls_receiptcod, 
//								 acct_owner    = :ls_name, 
//								 acct_ssno     = :ls_acct_ssno,
//								 acctno        = :ls_acctno, 
//								 receiptdt     = to_date(:ls_cmsacpdt,'yyyy-mm-dd'), 
//								 pay_method    = nvl(:ls_paymethod,pay_method),
//								 drawingtype   = :ls_drawingtype, 
//								 drawingresult = :ls_drawingresult, 
//								 drawingreqdt  = to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
//								 updtdt        = sysdate, 
//								 updt_user     = :gs_user_id, 
//								 pgm_id        = :gs_pgm_id[1], 
//								 resultcod     = :ls_errorcode
//						 where customerid    = :ls_payid; 
//						
//						// Rollback
//						If SQLCA.SQLCode < 0 Then
//							FileClose(li_FileNum)						
//							f_msg_sql_err(is_Title, " Update Error(billinginfo)")
//							Rollback;
//							return 
//						End If
//					END IF
//				Case "5", "2"
//					ls_worktype = '1'
//					
//					If fs_snvl(ls_bil_payid,'') = '' Then
//						f_msg_usr_err(9000, is_title, "일치하는 자료가 없습니다. (납입자번호: " + ls_payid + ") ")
//						RollBack;
//						FileClose(li_filenum)						
//						Return						
//					End If									
//
//					//정상처리
//					If ls_errorcode   = "00" Then  				 
//						ls_reqyn       = "S" 	
//						ls_paymethod   = ls_paymethod_edi
//						ls_bilcycle    = ls_bilcycle_edi
//						lb_reject      = False		
//						
//						If ls_bil_drawingtype = "06" Then	//변경신청         
//						
//							UPDATE billinginfo 
//							   SET drawingresult = :ls_reqyn, 
//								    receiptdt     = :ls_cmsacpdt,
//								    pgm_id        = :is_data[9],
//								    udtd_user     = :gs_user_id
//							 WHERE receiptcod    = :ls_receiptcod
//							   AND payid         = :ls_payid ;
//							  
//							If SQLCA.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #2")
//								FileClose(li_filenum)								
//								Return
//							End If
//							
//						Else                      		//신규,해지신청
//							If ls_bil_drawingtype = "08" Then	//해지신청
//								ls_paymethod = ls_bil_pay_method
//								ls_bilcycle  = ls_bil_bilcycle
//							End If
//							
//							UPDATE billinginfo 
//							   SET pay_method    = :ls_paymethod, 
//								    bilcycle      = :ls_bilcycle, 
//								    drawingresult = :ls_reqyn, 
//								    receiptdt     = :ls_cmsacpdt,
//								    pgm_id        = :is_data[9],
//								    udtd_user     = :gs_user_id
//							 WHERE receiptcod    = :ls_receiptcod
//							   AND payid         = :ls_payid 
//							   AND drawingresult = '2' 
//							   AND acct_ssno     = :ls_acct_ssno
//							   AND acctno        = :ls_acctno ;
//							  
//							If SQLCA.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #3")
//								FileClose(li_filenum)								
//								Return
//							End If											  							  							  
//						End If
//					//Error 처리
//					Else									 
//						ls_reqyn       = "F"
//						lb_reject      = False			// paymst update 함
//						ls_paymethod   = ls_paymethod_cancel
//						ls_bilcycle    = ls_bilcycle_cancel
//							
//						If ls_bil_drawingtype = "06" Then	//변경신청
//							UPDATE billinginfo 
//							   SET pay_method    = :ls_paymethod, 
//								    bilcycle      = :ls_bilcycle, 
//							 	    drawingresult = :ls_reqyn, 
//								    receiptdt     = :ls_cmsacpdt,
//								    pgm_id        = :is_data[9],
//								    udtd_user     = :gs_user_id
//							 WHERE receiptcod    = :ls_receiptcod
//							   AND payid         = :ls_payid ;
//							  
//							If SQLCA.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #4")
//								FileClose(li_filenum)								
//								Return
//							End If
//											  							  							  
//						Else                   			//신규,해지신청
//							
//							If ls_bil_drawingtype = "02" Then 
//								UPDATE billinginfo 
//								   SET pay_method     = :ls_paymethod, 
//								       bilcycle       = :ls_bilcycle, 
//								       drawingresult  = :ls_reqyn, 
//									    receiptdt      = :ls_cmsacpdt,
//									    pgm_id         = :is_data[9],
//									    udtd_user      = :gs_user_id
//								 WHERE receiptcod     = :ls_receiptcod
//								   AND payid          = :ls_payid 
//								   AND drawingresult  = '2' ;
//							End If
//							  
//							If SQLCA.sqlcode < 0 Then
//								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #5")
//								FileClose(li_filenum)								
//								Return
//							End If											  					  							  							  
//						End If						
//					End If
//				Case "6"
//					//
//				Case Else
//					//기타 데이터 Error로 자료를 처리할 수 없을 때 
////					ls_result_code = "99"
//////					ls_reqyn = "1"
//////					ls_reqplace = "4"
//			End Choose
			
//			Select count(*), Max(prcno)
//			  Into :ll_gr21cnt, :ls_gr21max_prcno
//			  From bankreq
//			 Where file_name = :is_data[2];
//			
//			IF ll_gr21cnt > 0 Then
//				ls_prcno = fs_fill_zeroes(string(integer(ls_gr21max_prcno) + 1),-7)
//			END IF	
			//Bankreq Insert GR22 파일로 생성한다.
		  Insert into bankreq_20051110
		  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
			reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
			result_code, error_code, receiptno)
		  values
		  (:is_data[2], to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ls_prcno,
			:ls_worktype, to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
			:ls_drawingtype, :ls_drawingtype, :ls_payid, :ls_bank, :ls_acctno, :ls_name, :ls_acct_ssno, :ls_receiptcod,
			:ls_resultcode, :ls_errorcode, :ls_receiptno);
		  
			If SQLCA.SQLCode < 0 Then
				FileClose(li_FileNum)
				f_msg_sql_err(is_title, is_caller + " Insert Error(bankreq)")
				Rollback;
				return 
			End If
			
	  End If
  Loop
	 //File Close
	 FileClose(li_FileNum)
	  
			
	//3.bankreqstus Insert
	//파일상태는 응답확인 
//	IF ll_gr21cnt = 0 THEN
//	Insert into bankreqstatus
//	(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
//	crt_user, updt_user, crtdt, updtdt, pgm_id, resultprcdt, errcnt) 
//	VALUES
//	(:ls_worktype, :is_data[2], to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ll_reqcnt, :ls_status[3], sysdate,
//	 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[1], sysdate, :ll_errcnt);
//	// Rollback
//	If SQLCA.SQLCode < 0 Then
//		FileClose(li_FileNum)						
//		f_msg_sql_err(is_Title, " Insert Error(bankreqstatus)")
//		Rollback;
//		return 
//	End If
//	ELSE
//		Update bankreqstatus
//		   Set reqcnt    = :ll_reqcnt + nvl(reqcnt,0),
//			    errcnt    = :ll_errcnt + nvl(errcnt,0),
//				 crt_user  = :gs_user_id,
//				 updt_user = :gs_user_id,
//				 updtdt    = sysdate
//		 Where file_name = :is_data[2]
//		   And receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd');
//		// Rollback
//		If SQLCA.SQLCode < 0 Then
//			FileClose(li_FileNum)						
//			f_msg_sql_err(is_Title, " Update Error(bankreqstatus)")
//			Rollback;
//			return 
//		End If
//	END IF
				 
//	//------------------------------------------------------------------------------//
//   // GR21mmdd->GR22mmdd (파일명이 GR21mmdd이고 신청결과가 파일저장인 은행접수분)
//	//------------------------------------------------------------------------------//
//		DECLARE cur_read_bankreq1 CURSOR FOR 
//		 SELECT a.file_name, 
//		        a.prcno,
//			     a.payid
//		   FROM bankreq a, 
//			     bankreqstatus b
//		  WHERE a.file_name = b.file_name
//		    AND a.receiptdt = b.receiptdt
//		    AND b.status = '2'
//		    AND ( a.receiptcod = '4' OR a.receiptcod = '0' )
//		    AND a.file_name LIKE :is_data[2]
//		ORDER BY a.file_name, a.prcno;
//		  
//		OPEN cur_read_bankreq1;
//		Do While(True)
//			FETCH cur_read_bankreq1
//			INTO :ls_bankreq_fname, :ls_prcno, :ls_payid;
//			
//			If SQLCA.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller + ":cur_read_bankreq1")
//				CLOSE cur_read_bankreq1;
//				Return
//			ElseIf SQLCA.SQLCode = 100 Then
//				Exit
//			End If				
//			
//			Select count(*), Max(prcno)
//			  Into :ll_gr22cnt, :ls_gr22max_prcno
//			  From bankreq
//			 Where file_name = :ls_gr22_filename;
//			
//			IF ll_gr22cnt > 0 Then
//				ls_prcno_22max = fs_fill_zeroes(string(integer(ls_gr22max_prcno) + 1),-7)
//			
//				Insert into bankreq
//					  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
//						reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
//						result_code, error_code, receiptno)
//				SELECT :ls_gr22_filename, receiptdt, :ls_prcno_22max, worktype, drawingreqdt, drawingtype,
//						 reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
//						 result_code, error_code, receiptno
//				 FROM bankreq
//				WHERE ( receiptcod = '4' OR receiptcod = '0' )
//				  AND prcno     = :ls_prcno
//				  AND file_name = :is_data[2];
//		   ELSE
//				Insert into bankreq
//					  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
//						reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
//						result_code, error_code, receiptno)
//				SELECT :ls_gr22_filename, receiptdt, :ls_prcno, worktype, drawingreqdt, drawingtype,
//						 reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
//						 result_code, error_code, receiptno
//				 FROM bankreq
//				WHERE ( receiptcod = '4' OR receiptcod = '0' )
//				  AND prcno     = :ls_prcno
//				  AND file_name = :is_data[2];
//			END IF
//			
//			If SQLCA.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller + ":INSERT bankreq #5 - 고객번호 - " + ls_payid )
//				Rollback;
//				Return
//			End If
//			
//			//UPDATE payadd1 - 해당 payid의 신청유형을 '응답저장'으로 Update
//			Update billinginfo 
//				set drawingresult = '2',
//					 updtdt        = sysdate, 
//					 updt_user     = :gs_user_id, 
//					 pgm_id        = :gs_pgm_id[1]
//			 where customerid    = :ls_payid
//			   and ( receiptcod = '4' OR receiptcod = '0' ); 
//			  
//			If SQLCA.sqlcode < 0 Then
//				f_msg_sql_err(is_title, is_caller + ":UPDATE billinginfo #2")
//				Return
//			End If
//			 
//		Loop
//		CLOSE cur_read_bankreq1;
//		
////   IF ll_gr22cnt = 0 Then
//		Insert into bankreqstatus
//		(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
//		crt_user, updt_user, crtdt, updtdt, pgm_id, resultprcdt, errcnt) 
//		VALUES
//		(:ls_worktype, :ls_gr22_filename, to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ll_reqcnt, :ls_status[3], sysdate,
//		 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[1], sysdate, :ll_errcnt);
//			
////	ELSE
////		Update bankreqstatus
////		   Set reqcnt    = :ll_reqcnt + nvl(reqcnt,0),
////			    errcnt    = :ll_errcnt + nvl(errcnt,0),
////				 crt_user  = :gs_user_id,
////				 updt_user = :gs_user_id,
////				 updtdt    = sysdate
////		 Where file_name = :ls_gr22_filename
////		   And receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd');
////		// Rollback
////		If SQLCA.SQLCode < 0 Then
////			FileClose(li_FileNum)						
////			f_msg_sql_err(is_Title, " Update Error(bankreqstatus)")
////			Rollback;
////			return 
////		End If
////	END IF
//		
//	// Rollback
//	If SQLCA.SQLCode < 0 Then
//		FileClose(li_FileNum)						
//		f_msg_sql_err(is_Title, " Insert Error(bankreqstatus)")
//		Rollback;
//		return 
//	End If
//		
//	//-------------------------------------------------------------------------		
//	//4 파일 Write GR22
//	ll_bytes = 0
//	li_write_bytes = 0
//	ll_bchgcnt = 0
//	ll_bchgcnt1 = 0
//	ll_bnewcnt = 0
//	ll_bcancelcnt = 0 
//	ll_bcancelcnt1 = 0
//	ll_seqno = 0
//	ls_bef_payid = ""
//	//.Header Record
//	ls_buffer = ""
//	ls_buffer += ls_datacod[1]                     //Data구분 코드
//	ls_buffer += fs_fill_zeroes(is_data[7], 7)     //지로번호
//	ls_buffer += fs_fill_spaces(is_data[8], 34)    //이용기간명
//	ls_buffer += fs_fill_zeroes(ls_cmsacpdt, 8)    //신청접수일자
//	ls_buffer += Space(99)
//	
//	// File Open
//	ls_filename = is_data[4]+ls_gr22_filename
//	
//	li_filenum = FileOpen(ls_filename, StreamMode!, Write!, LockReadWrite!, Replace!)
//	
//	If IsNull(li_filenum) Then li_filenum = -1
//	If li_filenum < 0 Then 	
//		FileClose(li_filenum)
//		ii_rc = -3
//		Return 
//	End If
//	
//	li_write_bytes = FileWrite(li_filenum, ls_buffer)
//	If li_write_bytes < 0 Then 
//		FileClose(li_filenum)
//		ii_rc = -3			
//		Return 
//	End If
//
//		//kem Modify 2005-10-11 전자접수번호 받은걸로 데이타를 금결원에 보낸다.
//		//Data Record
//		DECLARE cur_read_bankreq CURSOR FOR
//		 SELECT to_char(a.receiptdt,'yyyymmdd'), 
//		        a.error_code,
//			     to_char(a.drawingreqdt,'yyyymmdd'), 
//				  a.drawingtype, 
//				  a.reqtype, 
//			     a.payid, 
//				  a.bank, 
//				  replace(a.acctno,'-',''), 
//				  a.acct_owner,
//				  a.acct_ssno, 
//				  a.receiptcod, 
//				  a.receiptno
//		   FROM bankreq a, 
//			     bankreqstatus b
//		  WHERE a.file_name = b.file_name
//		    AND a.receiptdt = b.receiptdt
//		    AND substr(b.file_name,1,4) = :is_data[5]
//		    AND to_char(b.receiptdt,'yyyymmdd') = :ls_cmsacpdt
//		    AND b.worktype  = :is_data[3]
//		    AND a.worktype  = :is_data[3]
//		    AND b.status    = :ls_status[3]   //응답확인
//		  //And a.result_code = 'N'
//		Order by 1,3;
//		
//		OPEN cur_read_bankreq;
//		Do While (True)
//			Fetch cur_read_bankreq
//			Into :ls_receiptdt, 
//			     :ls_errorcode,
//				  :ls_drawingreqdt, 
//				  :ls_drawingtype_1, 
//				  :ls_reqtype,
//				  :ls_payid, 
//				  :ls_bank, 
//				  :ls_acctno, 
//				  :ls_acct_owner,
//				  :ls_acct_ssno, 
//				  :ls_receiptcod, 
//				  :ls_receiptno;
//				 
//			If SQLCA.SQLCode < 0 Then
//				Close cur_read_bankreq;
//				FileClose(li_filenum)
//				f_msg_sql_err(is_Title, "Select Error(bankreq)")
//				Return 
//			ElseIf SQLCA.SQLCode = 100 Then
//				Exit
//		   End If
//		   
//			ll_seqno ++   //작성고객수
//			
//			ls_bef_payid = ""
//			
//			IF ls_reqtype = ls_bankcod[1] THEN     //신규
//				ll_bnewcnt++
//			ELSEIF ls_reqtype = ls_bankcod[2] Then //변경
//				ll_bchgcnt++
//				ls_bef_payid = ls_payid
//			ElseIF ls_reqtype = ls_bankcod[3] THEN 
//				ll_bchgcnt1++
//				ls_bef_payid = ls_payid
//			ELSEIF ls_reqtype = ls_bankcod[4] Then
//				ll_bcancelcnt++
//		   ElseIf ls_reqtype = ls_bankcod[5] THEN //해지
//				ll_bcancelcnt1++
//			END IF
//			
//			//Data Record
//			ls_buffer  = ls_datacod[2]                        //Data 구분 코드
//			ls_buffer += fs_fill_zeroes(String(ll_seqno), -7) //일련번호
////Start 2004.06.28. khpark modify 
////			ls_buffer += ls_receiptdt                         //신청일자
//			ls_buffer += ls_drawingreqdt                      //신청일자
////End 2004.06.28. khpark modify 			
//		   ls_buffer += ls_reqtype                           //신청 구분
//			ls_buffer += Space(20)                            //변경후 납부자 번호
//			ls_buffer += fs_fill_spaces(ls_payid, 20)         //납부자 번호
//			ls_buffer += '00'                                 //납부희망일
//			ls_buffer += '00'                                 //요금종류
//			ls_buffer += fs_fill_zeroes(ls_bank, 6)           //은행점 코드
//			ls_buffer += fs_fill_spaces(ls_acctno, 15)        //지정출금계좌번호
//			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)     //주민등번호
//			
//			Select replace(a.phone1,'-','') 
//			  into :ls_phone 
//			  from customerm a, 
//			       billinginfo b 
//			 where a.customerid = b.customerid
//			   and b.customerid = :ls_payid;
//			
//			ls_buffer += fs_fill_spaces(ls_phone, 11)         //전화번호
//			ls_buffer += fs_fill_zeroes(ls_bank, 6)           //신청접수처코드
//			ls_buffer += fs_fill_zeroes(ls_errorcode,2)       //결과코드
//			ls_buffer += "0000"                               //최초개시월일
////			ls_buffer += ls_code                              //접수처 구분코드
//			//kem Modify 접수처 구분 코드도 받은걸 다시 보낸다. 2005-10-11
//			ls_buffer += ls_receiptcod								  //접수처 구분코드
//			ls_buffer += fs_fill_zeroes(ls_receiptno,9)       //전자접수코드 --> jjuhm 수정
//			ls_buffer += fs_fill_spaces(ls_acct_owner, 16)    //예금주명
//			ls_buffer += Space(4)
//			
//			li_write_bytes = FileWrite(li_filenum, ls_buffer)
//			If li_write_bytes < 0 Then
//				FileClose(li_filenum)
//				Close cur_read_bankreq;
//				ii_rc = -3
//				Return 
//			End If
//			ll_bytes += li_write_bytes
//		 
//		Update billinginfo 
//			set drawingresult = 'S',
//				 updtdt        = sysdate, 
//				 updt_user     = :gs_user_id, 
//				 pgm_id        = :gs_pgm_id[1]
//		 where customerid    = :ls_payid; 
//		 
//		Loop
//		Close cur_read_bankreq;
//		
//		// Trailer Record
//		ls_buffer = ls_datacod[3]                               //Date 구분코드
//		ls_buffer += fs_fill_zeroes(String(ll_seqno)      , -7) //레코드수
//		ls_buffer += fs_fill_zeroes(String(ll_bnewcnt)    , -7) //은행접수
//		ls_buffer += fs_fill_zeroes(String(ll_bcancelcnt) , -7) //은행접수 해지
//		ls_buffer += fs_fill_zeroes(String(ll_bchgcnt)    , -7) //은행변경
//		ls_buffer += fs_fill_zeroes(String(ll_bcancelcnt1), -7) //은행임의 해지
//		ls_buffer += fs_fill_zeroes(String(ll_bchgcnt1)   , -7) //은행임의 변경
//		ls_buffer += fs_fill_zeroes("0", -7)      //신규
//		ls_buffer += fs_fill_zeroes("0", -7)      //해지
//		ls_buffer += fs_fill_zeroes("0", -7)      //해지임의
//		ls_buffer += fs_fill_zeroes("0", -7)      //신규
//		ls_buffer += Space(78)
//		
//		li_write_bytes = FileWrite(li_filenum, ls_buffer)
//		If li_write_bytes < 0 Then 
//			FileClose(li_filenum)
//			ii_rc = -3
//			Return
//		End If
//		FileClose(li_filenum)
//		
//	
//	  UPDATE bankreqstatus
//		SET status   = 'S',
//			crt_user  = :gs_user_id,
//			updt_user = :gs_user_id,
//			crtdt     = sysdate,
//			updtdt    = sysdate,
//			pgm_id    = :gs_pgm_id[1]	 
//		WHERE worktype  = :is_data[3]
//		  AND file_name = :ls_gr22_filename
//		  AND status    = '2';
//		
//		If SQLCA.sqlcode < 0 Then
//			ROLLBACK;
//			f_msg_sql_err(is_Title, "Update Error2(bankreqstatus)")
//			Return 
//		End If
//		
//		
//		ii_rc = ll_reqcnt  //총레코드 건수 넣음
//		commit;
//		
//		is_data[5] = ls_gr22_filename
//		is_cmsacpdt = ls_cmsacpdt
//		Return
End Choose
commit;
Return
ii_rc = 1
end subroutine

public subroutine uf_prc_db_02 ();Integer li_FileNum, li_read_bytes
Long ll_bytes_read, ll_FLength, ll_count
String ls_buffer, ls_recordtype, ls_filename, ls_filepath, ls_header, ls_detail, ls_trailer
String ls_error_code, ls_file_name, ls_receiptdt, ls_prcno, ls_payid, ls_result_code
String ls_drawingresult, ls_drawingresults[], ls_paymethod, ls_reqyn, ls_drawingtype
String ls_temp, ls_ref_desc, ls_status[], ls_chargedt_edi, ls_paymethod_edi, ls_chargedt_cancel, ls_paymethod_cancel
Integer li_return, li_cnt, li_errcnt_T, li_errcnt_P
String ls_erramt, ls_trdt, ls_result[], ls_data_kind, ls_girono, ls_office_name, ls_prcdt
date ld_trdt
Dec lc_erramt, lc_erramt_T, lc_erramt_P
boolean lb_reject
String ls_data_seq, ls_reqdt, ls_req_type, ls_payid_bef, ls_bank_code, ls_accountno, ls_busnum, ls_telno, ls_bank2, ls_openmmdd
String ls_reqplace, ls_contno, ls_chargedt, ls_name
ii_rc = -1

Constant Integer GR20_SIZE = 150

Choose Case is_caller
	Case "EDI GR20%FileRead"
		// 오류분 처리 => 결과처리의 Reject 처리와 같게 처리함(은행분 포함 안됨)
		//lu_dbmgr.is_title = Parent.Title
		//lu_dbmgr.is_caller = "INSERT INTO CMSREQ-GR20mmdd(ERROR)"
		//lu_dbmgr.is_data[1] = ls_filename
		//lu_dbmgr.is_data[2] = ls_filepath
		//lu_dbmgr.hpb_data[1] = hpb_1
		//
		//lu_dbmgr.uf_prc_db_01()
		//li_rc = lu_dbmgr.ii_rc  			
		//ls_prc_cnt = lu_dbmgr.is_data2[1]  //처리건수		
		is_data2[1] = "0"
		ls_filename = is_data[1]
		ls_filepath = is_data[2]
		ls_header   = "53"
		ls_detail   = "63"
		ls_trailer  = "73"
		
		//청구주기;청구방법;할인코드
		ls_temp   = fs_get_control("B7", "A612", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_result[])
		ls_chargedt_edi  = ls_result[1]
		ls_paymethod_edi = ls_result[2]
		If ls_paymethod_edi = "" Or ls_chargedt_edi = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			Return
		End If
		
		//해지시(청구주기;청구방법;할인코드)
		ls_temp = fs_get_control("B7", "A613", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_result[])
		ls_chargedt_cancel  = ls_result[1]
		ls_paymethod_cancel = ls_result[2]
		If ls_paymethod_cancel = "" Or ls_chargedt_cancel = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			Return
		End If		
		
		li_filenum = FileOpen(ls_filepath, StreamMode!)	//LineMode!, StreamMode!
		If IsNull(li_filenum) Then li_filenum = -1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filename)
			FileClose(li_filenum)
			ii_rc = -2
			Return
		End If
		
		ll_count = 0
		Do While (True)
			ls_buffer = ""
			li_read_bytes = FileRead(li_filenum, ls_buffer)
			If li_read_bytes < 0 Then Exit
			If li_read_bytes > GR20_SIZE Then
				FileSeek(li_filenum, GR20_SIZE - li_read_bytes, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, GR20_SIZE)
			ls_data_kind =   MidA(ls_buffer, 1, 2)
			
			If ls_data_kind = ls_header Then
				ls_girono = MidA(ls_buffer, 3, 7)
				ls_office_name = MidA(ls_buffer, 10, 34)
				ls_prcdt =  MidA(ls_buffer, 44, 8)
				//Filler(99)

				Continue
			ElseIf ls_data_kind  = ls_trailer Then
				Continue
			End If

			If ls_data_kind <> ls_detail Then
				f_msg_usr_err(9000, is_title, "결과파일 데이터 오류입니다.")
				FileClose(li_filenum)
				ii_rc = -2
				Return
			End If				
			
			ls_data_kind   = Trim(MidA(ls_buffer, 1, 2))	   //DATA 구분코드
			ls_data_seq    = Trim(MidA(ls_buffer, 3, 7))		//일련번호
			ls_reqdt       = Trim(MidA(ls_buffer, 10, 8))		//신청일자
			ls_req_type    = Trim(MidA(ls_buffer, 18, 2))		//신청구분
			ls_payid_bef   = Trim(MidA(ls_buffer, 20, 20))	//납부자번호(변경전)
			ls_payid       = Trim(MidA(ls_buffer, 40, 20))	//납부자번호
			//납부희망일(2), 요금종류(2) - seek. 60, 4
//			ls_bank_code = Mid(ls_buffer, 64, 6)				//고객계좌개설점코드
			ls_bank_code   = Trim(MidA(ls_buffer, 64, 2))		//고객계좌개설점코드	- 앞 두자리만 유효
			ls_accountno   = Trim(MidA(ls_buffer, 70, 15))	//출금계좌번호
			ls_busnum      = Trim(MidA(ls_buffer, 85, 13))	//주민(사업자)번호
			ls_telno       = Trim(MidA(ls_buffer, 98, 11))	//전화번호
//			ls_bank2 = 	Mid(ls_buffer, 109, 6)					//신청서접수점코드
			ls_bank2       = Trim(MidA(ls_buffer, 109, 2))	//신청서접수점코드 - 앞 두자리만 유효
			ls_result_code = Trim(MidA(ls_buffer, 115, 2))	//처리결과코드
			ls_openmmdd    = Trim(MidA(ls_buffer, 117, 4))	//최초개시월일
			ls_reqplace    = Trim(MidA(ls_buffer, 121, 1))	//접수처구분코드
			ls_contno      = Trim(MidA(ls_buffer, 122, 9))	//고객관리번호
			ls_name        = Trim(MidA(ls_buffer, 131, 20))	//고객명
			// Filler(20) - seek...  131, 20
			
			lb_reject = True	//Init
			Choose Case ls_reqplace
				//은행접수분의 Reject 처리
				Case "4", "0", "6"
					// 오류분에 포함 안됨

				//이용기관 접수분의 Reject 처리
				Case "5", "2"
					//납부자신청유형확인
					SELECT drawingtype 
					  INTO :ls_drawingtype 
					  FROM billinginfo
					 WHERE customerid = :ls_payid;
					 
					If SQLCA.sqlcode < 0 Then
						f_msg_sql_err(is_title, is_caller + ": SELECT drawingtype")
						FileClose(li_filenum)						
						Return
					End If			
					
					//일치하는 자료가 없을때
					If SQLCA.sqlnrows = 0 then
						f_msg_usr_err(9000, is_title, "일치하는 자료가 없습니다. (납입자번호: " + ls_payid + ") ")
						RollBack;
						FileClose(li_filenum)						
						Return						
					End If					

					ls_paymethod = ls_paymethod_cancel
					ls_chargedt  = ls_chargedt_cancel
					ls_reqyn     = "F"
					lb_reject    = False			// paymst update 함
				///////////////////////////////////////////////////////////updt까지		
					If ls_drawingtype = "06" Then	//변경신청
						UPDATE billinginfo 
						   SET drawingresult = :ls_reqyn, 
							    drawingreqdt  = :ls_prcdt,
							    pgm_id        = :is_pgm_id,
							    updt_user     = :gs_user_id
						 WHERE receiptcod    = :ls_reqplace
						   AND customerid    = :ls_payid ;
						If SQLCA.sqlcode < 0 Then
							f_msg_sql_err(is_title, is_caller + ": Update billinginfo #1")
							FileClose(li_filenum)
							Return
						End If											  							  							  
					Else                   			//신규,해지신청
						If ls_drawingtype = "08" Then lb_reject = True  //해지신청이 Reject난 경우: billinginfo update안함	
						UPDATE billinginfo 
						   SET drawingresult = :ls_reqyn, 
							    drawingreqdt  = :ls_prcdt,
							    pgm_id        = :is_pgm_id,
							    updt_user     = :gs_user_id
						 WHERE receiptcod    = :ls_reqplace
						   AND drawingresult = '2' 
						   AND customerid    = :ls_payid ;
						If SQLCA.sqlcode < 0 Then
							f_msg_sql_err(is_title, is_caller + ": Update billinginfo #2")
							FileClose(li_filenum)
							Return
						End If											  
					End If						
				
			End Choose
			
			If Not lb_reject Then
				//UPDATE billinginfo
				UPDATE billinginfo
				   SET bilcycle   = :ls_chargedt,
					    pay_method = :ls_paymethod,
					    pgm_id     = :is_pgm_id,
					    updt_user  = :gs_user_id
				 WHERE customerid = :ls_payid;
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #3")
					FileClose(li_filenum)				
					Return
				End If
			End If
			//INSERT INTO cmsreq
					 
			  Insert into bankreq
			  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
				reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
				result_code, error_code, receiptno)
			  values
			  (:ls_filename, to_date(:ls_reqdt,'yyyy-mm-dd'), :ls_data_seq, '1', to_date(:ls_reqdt,'yyyy-mm-dd'),
				:ls_req_type, :ls_req_type, :ls_payid, :ls_bank_code, :ls_accountno, 
				:ls_name, :ls_busnum, :ls_reqplace, 'N', :ls_result_code, :ls_contno);
					 
					 
			If SQLCA.sqlcode < 0 Then
				FileClose(li_FileNum)
				f_msg_sql_err(is_title, is_caller + " Insert Error(bankreq) #1")
			   ii_rc = -1
				return 
			End If											  							  					 

			ll_count++
		Loop
		FileClose(li_filenum)		

		is_data2[1] = String(ll_count)		
		
	//3.bankreqstus Insert
	//파일상태는 응답확인 
	Insert into bankreqstatus
	(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
	crt_user, updt_user, crtdt, updtdt, pgm_id, resultprcdt, errcnt) 
	VALUES
	('2', :ls_filename, to_date(:ls_reqdt,'yyyy-mm-dd'), :ll_count, 'S', sysdate,
	 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[1], sysdate, :ll_count);
End Choose

ii_rc = 0
			
			
//	//** is_data[1] : pathname, is_data[2] : filename, 
//	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
//		
//		Constant Integer EA20_Size = 150
//		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
//		
//		// fileopen error
//		If IsNull(li_FileNum) Then li_FileNum = -1
//		If li_FileNum < 0 Then
//			f_msg_usr_err(10001, is_Title, is_data[1])
//			FileClose(li_filenum)
//			Return
//		End If
//
//		// Status : sysctl1t
//		//자동이체 : 신청&이체파일상태(미처리;신청;응답확인;입금처리;ERROR)-->0;1;2;3;4
//		ls_temp   = fs_get_control("B7", "A510", ls_ref_desc)
//		li_return = fi_cut_string(ls_temp, ";", ls_status)
//		
//		//Billing 신청 결과 코드
//		//자동이체 : 이체신청결과(없음;신청(미처리);처리중;처리성공;처리실패)-->0;1;2;S;F
//		ls_temp   = fs_get_control("B7", "A330", ls_ref_desc)
//		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults[])
//		
//		
//				
//		Do While(true)
//			//File Read
//			ls_buffer = ""
//			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
//			
//			If ll_bytes_read < 0 Then Exit
//			// File Pointer Move
//			If ll_bytes_read > EA20_Size Then
//				FileSeek(li_FileNum, EA20_Size - ll_bytes_read, FromCurrent!)
//			End If
//			
//			ls_buffer = Mid(ls_buffer, 1, EA20_Size)
//			ls_recordtype = Left(ls_buffer, 2)
//			
//			Choose Case ls_recordtype
//				Case '63' 
//					ls_payid = Trim(Mid(ls_buffer, 40 ,20))
//               ls_error_code = Trim(Mid(ls_buffer, 115, 2))
//
//					// Update BankReq Of Error Case
//					Update bankreq
//					   SET result_code = 'N', 
//					       error_code  = :ls_error_code
//					 WHERE file_name   = :is_data[3] 
//					   AND to_char(receiptdt,'yyyymmdd') = :is_data[4]
//					   AND payid = :ls_payid;
//					
//					// Rollback
//					If SQLCA.SQLCode < 0 Then
//						FileClose(li_FileNum)						
//						f_msg_sql_err(is_Title, "Update Error(Bankreq)")
//						Rollback;
//						return 
//					End If
//										
//			End Choose
//		Loop
//		
//		//File Close
//		FileClose(li_FileNum)
//		
//		// Error Counts
//		SELECT count(*)
//		INTO :li_cnt
//		FROM bankreq
//		WHERE file_name = :is_data[3] 
//		AND to_char(receiptdt, 'yyyymmdd') = :is_data[4]
//		AND result_code = 'N';
//
//		// Update BankReqStatus
//		//신청을 응답확인으로 Update
//		Update bankreqstatus
//		SET status      = :ls_status[3],
//			 resultprcdt = sysdate, 
//			 errcnt      = :li_cnt, 
//			 updt_user   = :is_data[5], 
//			 updtdt      = sysdate
//		WHERE file_name = :is_data[3] 
//		  AND to_char(receiptdt,'yyyymmdd') = :is_data[4] 
//		  and status =:ls_status[2];
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(is_Title, " Update Error(BankReqStatus)")
//			Rollback;
//			Return
//		End If
//				 
//		//고객을 성공 실패 확정 짖는다.
//		DECLARE cur_bankreq CURSOR FOR
//		SELECT payid, result_code, error_code
//  		  FROM bankreq
//		 WHERE file_name = :is_data[3] 
//		   AND to_char(receiptdt,'yyyymmdd') = :is_data[4];
//		
//		OPEN cur_bankreq;
//		Do While (True)
//			FETCH cur_bankreq
//			INTO :ls_payid, :ls_result_code, :ls_error_code;
//			
//			If SQLCA.sqlcode < 0 Then
//				CLOSE cur_bankreq;				
//				f_msg_sql_err(is_title, "Cursor bankreq")
//				Return				
//			ElseIf SQLCA.SQLCode = 100 Then
//				Exit
//			End If
//			
//			If ls_result_code   = "N" Then 
//				ls_drawingresult = ls_drawingresults[5]	//실패 F
//			Else 
//				ls_drawingresult = ls_drawingresults[4]	//성공 S
//				ls_error_code    = '00'  //정상처리
//			End If
//		  
//		   //처리중인 고객을 처리성공, 실패로 Update
//			Update billinginfo
//			SET drawingresult = :ls_drawingresult, 
//			    resultcod     = :ls_error_code,
//			    updt_user     = :is_data[5], 
//				 updtdt        = sysdate, 
//				 pgm_id        = :gs_pgm_id[1]
//			WHERE drawingresult = :ls_drawingresults[3] 
//			  AND customerid    = :ls_payid;
//			
//			If SQLCA.SQLCode < 0 Then
//				CLOSE cur_bankreq;				
//				f_msg_sql_err(is_Title, "Update Error(Billinginfo)")
//				Rollback;
//				Return				
//			End If
//			
//			Update bankreq
//				SET error_code = :ls_error_code
//			 WHERE file_name  = :is_data[3] 
//				AND to_char(receiptdt,'yyyymmdd') = :is_data[4]
//				AND payid = :ls_payid;
//			
//		Loop
//		
//		CLOSE cur_bankreq;
//		
//		Commit;
//End Choose
//ii_rc = 0
Return
end subroutine

public subroutine uf_prc_db_03 ();// 작성자 : ceusee
// 작성일자 : 2003.11.19.
// 목  적 : 출금 의뢰 신청 저장/파일 생성

Long ll_rows, ll_newcnt, ll_cnt
String ls_file_name, ls_reqtype, ls_ref_desc, ls_temp
String ls_payid, ls_cmsacpdt
String  ls_acct_owner, ls_acct_ssno, ls_acctno,ls_bank_code

//"EDI GR23%Save"
String ls_outdt, ls_trcod[], ls_bankshop, ls_bank, ls_currency_type
String ls_data_seq, ls_sql
Long   ll_data_seq
decimal{0} ldc_sum_tramt, ldc_tramt

//"EDI GR23%FileWrite"
String ls_buffer, ls_filename, ls_validkey
Long ll_bytes, ll_cancelcnt,  ll_tramt
Int li_filenum, li_write_bytes, li_return
String ls_header, ls_seqno,  ls_filter, ls_reqamt, ls_remark
String ls_prcno, ls_jubank, ls_juacctno, ls_datacode[], ls_receptcod, ls_realcod[]
	
ii_rc = -1

//지로 처리된 파일을 해당 Table에 Insert 한다.
Choose Case is_caller
	Case "EDI GR23%Save"
//		lu_dbmgr.is_caller = "Bankreqga23%ue_save"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			        //filename
//		lu_dbmgr.is_data[2] = ls_outdt   			     //출금일자
//		lu_dbmgr.is_data[3] = ls_trdt   			        //입력한 청구기준일
//		lu_dbmgr.is_data[4] = ls_chargedt   			  //청구주기
//		lu_dbmgr.is_data[5] = is_remark		    		  //출금내역
//		lu_dbmgr.is_data[6] = is_outtype			        //출금형태
//		lu_dbmgr.is_data[7] = is_pay_type[3]           //입금유형(자동이체)
//		lu_dbmgr.is_data[8] = is_bankreqstatus[1]      //출금의뢰신청 작업상태(미처리)
	//lu_dbmgr.is_data[9] = is_mintramt				     //최소출금액
	//lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]//pgmid
	//lu_dbmgr.is_data[11] = is_pay_method            //결재방법(자동이체)
	//lu_dbmgr.is_data[12] = is_table 			        //reqinfo, reqinfoh (table명)

		ll_data_seq = 0
		ldc_sum_tramt = 0
		ll_cnt = 0
		ll_tramt = long(is_data[9])
		//File Name
		ls_file_name = is_data[1]
		//CMS 출금의뢰일
		ls_outdt  = is_data[2]
				
		//입금 거래유형
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B5", "I102", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_trcod[])


		//Data Record
		DECLARE cur_read_reqinfo CURSOR FOR
		
			SELECT b.bankshop,b.bank,b.acctno,b.acct_ssno,b.payid,b.currency_type, sum(a.tramt)
			  FROM reqdtl a, reqinfo b
			 WHERE a.payid = b.payid
				AND to_char(b.trdt,'yyyymmdd') = :is_data[3]
				AND b.chargedt = :is_data[4]
				AND b.pay_method = :is_data[11]
			GROUP BY b.payid, b.bankshop,b.bank,b.acctno,b.acct_ssno,b.payid,b.currency_type
			HAVING sum(a.tramt) >= :ll_tramt	;
			
		OPEN cur_read_reqinfo;
		Do While (True)
			Fetch cur_read_reqinfo
			Into :ls_bankshop, :ls_bank, :ls_acctno,
				 :ls_acct_ssno, :ls_payid, :ls_currency_type, :ldc_tramt;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_reqinfo;
				f_msg_sql_err(is_Title, " Select Error(reqinfo)")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		    End If
		   			   
			ll_data_seq = ll_data_seq + 1
			ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)
			
			//1.출금이체신청(BankReq) Table에 Insert
			//bil_status = 미처리
			INSERT INTO banktext
			(file_name, outdt, prcno, payid,
			 trdt, bankshop, bank, acctno,
			 reqamt, acct_ssno, out_type, remark,
			 currency_type, paytype, trcod, bil_status)
			VALUES
			(:ls_file_name,to_date(:ls_outdt,'yyyy-mm-dd'),:ls_data_seq,:ls_payid,
			 to_date(:is_data[3],'yyyy-mm-dd'),:ls_bankshop,:ls_bank,:ls_acctno,
			 :ldc_tramt,:ls_acct_ssno,:is_data[6],:is_data[5],
			 :ls_currency_type,:is_data[7], :ls_trcod[3], :is_data[8]);

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Insert Error(banktext)")
				ROLLBACK;
				Return
			End If

			ll_cnt ++ 
			ldc_sum_tramt += ldc_tramt			
			
		Loop
		Close cur_read_reqinfo;
			
		//2.출금의뢰신청처리상태(BankTextstatus) Table에 Insert
		//파일상태 미처리
		INSERT INTO banktextstatus
		(file_name,outdt,reqcnt,reqamt,status,reqprcdt, 
		 crt_user, updt_user, crtdt, updtdt, pgm_id) 
		VALUES
		(:ls_file_name,to_date(:ls_outdt,'yyyy-mm-dd'),:ll_cnt,:ldc_sum_tramt,:is_data[8],sysdate,
		 :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[10]);
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(bankreqstatus)")
			ROLLBACK;
			Return
		End If
		
	Case "GR23%FileWrite"		
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea21%ue_filewrite"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			          //filename
//		lu_dbmgr.is_data[2] = is_filepath			       //filepath
//		lu_dbmgr.is_data[3] = ls_outdt		    		    //출금의뢰일자
//		lu_dbmgr.is_data[4] = is_bank[1]			          //입금은행
//		lu_dbmgr.is_data[5] = is_bank[2]			          //입금계좌번호
//		lu_dbmgr.is_data[6] = is_coid			             //기관식별코드
//		lu_dbmgr.is_data[7] = is_bankreqstatus[1]        //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[8] = is_bankreqstatus[2]        //출금이체신청 작업상태(신청)
//		lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid
//    lu_dbmgr.is_data[10] = is_coname                 //이용기간명
//    lu_dbmgr.is_data[11] = is_name	                //예금주
//    lu_dbmgr.is_data[12] = is_outtype	             //출금형태
		Constant Integer	GR23_SIZE = 150
		
		ll_bytes = 0
		li_write_bytes = 0
		ll_cnt = 0
		
		//Data Record
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A602", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_datacode[])
		
		//접수처구분코드
		//ls_ref_desc = ""
		//ls_receptcod = fs_get_control("B7", "A604", ls_ref_desc)
		
		//실명확인 구분코드
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A611", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_realcod[])
		
		//1.Header Record
		ls_buffer = ""
		ls_buffer += ls_datacode[1]                         //Data Code
		ls_buffer += fs_fill_spaces(is_data[10], 34)        //이용기간명
		ls_buffer += fs_fill_zeroes(is_data[6], -7)         //지로번호
		ls_buffer += fs_fill_zeroes(is_data[4], 6)          //거래은행점별 코드
		ls_buffer += fs_fill_spaces(is_data[5], 15)	       //계좌번호
		ls_buffer += fs_fill_spaces(is_data[11], 16)	       //예금주명
		ls_buffer += fs_fill_zeroes(is_data[3], 8)          //납기일(출금일자)
		ls_buffer += fs_fill_spaces(is_data[12], 1)         //출금형태
		ls_buffer += Space(61)
		
		
		ls_file_name = is_data[1]
		
		// File Open
		ls_filename = is_data[2] + is_data[1]
		li_filenum = FileOpen(ls_filename, StreamMode!, Write!, LockReadWrite!, Replace!)	
		If IsNull(li_filenum) Then li_filenum = -1
		If li_filenum < 0 Then 	
			f_msg_usr_err(1001, is_Title, ls_file_name)			
			FileClose(li_filenum)
			ii_rc = -3
			Return 
		End If
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
			FileClose(li_filenum)
			ii_rc = -3			
			Return 
		End If
		ll_bytes += li_write_bytes		
		
		//Data Record
		DECLARE cur_read_banktext CURSOR FOR
		SELECT a.file_name, a.prcno, a.payid, 
			    a.bank, replace(a.acctno,'-',''), to_char(a.reqamt), 
			    a.acct_ssno, a.remark
		  FROM banktext a, banktextstatus b
		WHERE a.file_name = b.file_name
		  AND a.outdt = b.outdt
		  AND b.file_name = :is_data[1]
		  AND to_char(b.outdt,'yyyymmdd') = :is_data[3]
		  AND b.status = :is_data[7]
		Order by a.prcno;
		
		OPEN cur_read_banktext;
		Do While (True)
			Fetch cur_read_banktext
			Into :ls_file_name, :ls_prcno,  :ls_payid,
				  :ls_bank_code, :ls_acctno, :ls_reqamt,
				  :ls_acct_ssno, :ls_remark;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_banktext;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, " Select Error(banktext)")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   		
			//start-접수처 구분코드를 sysctl1t에서 가져오지 않고 billinginfo에서 찾아 오게 함. jwlee-2005.10.13
			SELECT receiptcod
			  INTO :ls_receptcod
			  FROM billinginfo
			 WHERE customerid = :ls_payid;
			 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_banktext;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, " Select Error(billinginfo-receiptcod)")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				ls_receptcod = ''
		   End If
			//end-jwlee-2005.10.13
			
			//Data Record
			ls_buffer = ls_datacode[2]                    //Data Record
			ls_buffer += fs_fill_zeroes(ls_prcno, -7)     //일련번호
			ls_buffer += fs_fill_spaces(ls_payid,20)      //납부자 번호
			ls_buffer += fs_fill_zeroes(ls_bank_code, 2)  //은행코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)    //계좌번호
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13) //주민등록번호
			ls_buffer += fs_fill_spaces(ls_remark, 20)    //출금내역
			ls_buffer += fs_fill_zeroes(ls_reqamt, -11)   //금액
		   ls_buffer += "00"                             //청구결과코드
			ls_buffer += fs_fill_zeroes(ls_receptcod,-1)  //접수처구분코드
			ls_buffer += fs_fill_zeroes("0", 11)          //부분출금금액
			ls_buffer += fs_fill_spaces(ls_realcod[2],1)  //실명확인 구분코드
			ls_buffer += Space(45)                    
		
			li_write_bytes = FileWrite(li_filenum, ls_buffer)
			If li_write_bytes < 0 Then
				FileClose(li_filenum)
				Close cur_read_banktext;
				f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
			ll_cnt++
			ldc_sum_tramt += Dec(ls_reqamt)
			
		Loop
		Close cur_read_banktext;
		
		// Trailer Record
		ls_buffer = ls_datacode[3]
		ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)      //총건수
		ls_buffer += fs_fill_zeroes(String(ldc_sum_tramt), -13)      //총청구금액
		ls_buffer += fs_fill_zeroes("0", 7)                         //전액출금건수
		ls_buffer += fs_fill_zeroes("0", 13)                        //전액출금금액
		ls_buffer += fs_fill_zeroes("0", 7)                         //출금불능건수
		ls_buffer += fs_fill_zeroes("0", 13)                        //출금불능금액
		ls_buffer += fs_fill_zeroes("0", 7)                         //부분출금건수
		ls_buffer += fs_fill_zeroes("0", 13)                        //부분출금금액
		ls_buffer += fs_fill_zeroes("0", 9)                         //수수료
		ls_buffer += fs_fill_zeroes("0", 13)                        //차감이체 금액
	   ls_buffer += space(36)                                      //filler
		ls_buffer += space(10)                                      //MAC 검증값
		
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Fail! (Trailer Record)")
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		ll_bytes += li_write_bytes

		FileClose(li_filenum)
		
		//미처리 파일은 신청으로
		UPDATE banktext
		   SET bil_status = :is_data[8]
		WHERE  file_name  = :is_data[1]
		  AND  to_char(outdt,'yyyymmdd') = :is_data[3]
		  AND  bil_status = :is_data[7];
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, " Update Error(banktext)")
			ii_rc = -1
			Return 
		End If
	
		//banktextstatus UPDATE
		UPDATE banktextstatus
 		  SET status    = :is_data[8],
			   crt_user  = :gs_user_id,
			   updt_user = :gs_user_id,
			   crtdt     = sysdate,
			   updtdt    = sysdate,
			   pgm_id    = :is_data[9]		 
		WHERE file_name = :is_data[1]
		  AND status    = :is_data[7];
		  
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, " Update Error(banktextstatus)")
			ii_rc = -1
			Return 
		End If
		
		ii_rc = ll_cnt		
		commit;
		Return 
End Choose

ii_rc = 0 

Return
end subroutine

public subroutine uf_prc_db_01 ();
//공통
Long ll_rows, ll_count
String ls_file_name, ls_reqtype, ls_ref_desc, ls_temp, ls_result[], ls_status[]
String ls_payid, ls_cmsacpdt, ls_gr_flnm
String  ls_acct_owner, ls_acct_ssno, ls_acctno,ls_bank_code

//"Bankreqgr22%ue_save"
String ls_reqdt
Long  ll_cancel, ll_change
String ls_data_seq
Long   ll_data_seq, ll_row


//"Bankreqgr22%ue_filewrite"
String ls_buffer, ls_filename
Long ll_bytes, ll_cnt, ll_cancelcnt, ll_newcnt, ll_chgcnt, ll_bcancelcnt, ll_b_cancelcnt, ll_b_newcnt, ll_b_chgcnt
Long ll_trailer[9] 
Int li_filenum, li_write_bytes, li_return, li_i
String ls_header, ls_seqno,  ls_filter, ls_bankreq_fname, ls_filename_prefix
String ls_prcno, ls_receiptdt, ls_drawingtype_1, ls_outtype
String ls_drawingreqdt, ls_receiptcod, ls_maincod[], ls_datacod[], ls_drawingtype[], ls_b_maincod[]
String ls_resultcod, ls_bil_payid, ls_bil_acctno, ls_bil_drawingtype, ls_bil_drawingresult, ls_bef_payid
String ls_phone, ls_code, ls_drawingresult
String ls_bef_bank, ls_bef_acctno, ls_bef_acct_owner, ls_bef_acct_ssno, ls_bef_drawingreqdt
String ls_bef_drawingtype, ls_bef_drawingresult, ls_bef_receiptdt, ls_bef_receiptcod, ls_bef_resultcod
	
ii_rc = -1

//지로 처리된 파일을 해당 Table에 Insert 한다.
Choose Case is_caller
	Case "EDI GR22%SAVE" 
//lu_dbmgr.is_caller = "EDI GR22%SAVE"
//lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.is_data[1] = is_filenm			        //filename
//lu_dbmgr.is_data[2] = is_filepath			        //filepath
//lu_dbmgr.is_data[3] = is_worktype[2]		        //Worktype(작업유형)
//lu_dbmgr.is_data[4] = ls_cmsacpdt			        //접수일자
//lu_dbmgr.is_data[5] = is_receiptcod[2]          //접수처
//lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//lu_dbmgr.is_data[7] = is_drawingresult[3]       //출금이체신청결과(처리중)
//lu_dbmgr.is_data[8] = is_coname                 //이용기간명
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid
//반환값 : il_data[1] = ll_data_seq //처리건수
		ll_data_seq = 0	
		il_data[1]  = 0
		
		//File Name
		ls_file_name = is_data[1]
		//CMS 신청접수일
		ls_cmsacpdt  = is_data[4]
				
		//자동이체 : 신청&이체파일상태(미처리;신청;응답확인;입금처리;ERROR)-->0;1;2;3;4
		ls_temp   = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
		
		ll_rows = idw_data[1].RowCount()
		For ll_row = 1 To ll_rows
			// CMS 신청 정보 Read
			ls_reqdt = string(idw_data[1].Object.drawingreqdt[ll_row],'yyyymmdd')  //이체 신청일자
			ls_reqtype = Trim(idw_data[1].Object.drawingtype[ll_row])              //이체신청유형
			If ls_reqtype = "" Then 
				ii_rc = -2
				Return
			End If
			
			
			ls_payid = Trim(idw_data[1].Object.customerid[ll_row])
			ls_bank_code = Trim(idw_data[1].Object.bank[ll_row])
			If IsNull(ls_bank_code) Then ls_bank_code = ""
			If ls_bank_code = "" Then 
				ii_rc = -2
				Return
			End If
			ls_acctno     = Trim(idw_data[1].Object.acctno[ll_row])
			ls_acct_owner = Trim(idw_data[1].Object.acct_owner[ll_row])
			ls_acct_ssno  = Trim(idw_data[1].Object.acct_ssno[ll_row])
			ls_receiptcod = Trim(idw_data[1].Object.receiptcod[ll_row])
			
			If ls_receiptcod = "4" Or ls_receiptcod = "0" Or ls_receiptcod = "6" Then Continue
			
			ll_data_seq   = ll_data_seq + 1
			ls_data_seq   = fs_fill_zeroes(String(ll_data_seq), -7)
			
			
			//###출금이체신청 Table에 추가
			//1.신규, 변경, 해지 신청 코드를 그대로 사용하면 된다.
//			INSERT INTO bankreq
//				(file_name,receiptdt,prcno,worktype,
//				 drawingreqdt,drawingtype,reqtype,payid,
//				 bank,acctno,acct_owner,acct_ssno,receiptcod)
//				VALUES
//				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
//				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_reqtype,:ls_payid,
//				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:is_data[5]);
//
//			If SQLCA.sqlcode < 0 Then
//				f_msg_sql_err(is_Title, " Insert Error(bankreq)")
//				ROLLBACK;
//				Return
//			End If
			//start-신청유형이 변경인 경우 해지후 신규신청 2005.11.02-jwlee
			
			If ls_reqtype = "06" Then
				//변경전 정보
				ls_bef_bank 		   = Trim(idw_data[1].Object.bef_bank[ll_row])
				ls_bef_acctno 		   = Trim(idw_data[1].Object.bef_acctno[ll_row])			
				ls_bef_acct_owner 	= Trim(idw_data[1].Object.bef_acct_owner[ll_row])
				ls_bef_acct_ssno 	   = Trim(idw_data[1].Object.bef_acct_ssno[ll_row])
				ls_bef_drawingreqdt 	= Trim(string(idw_data[1].Object.bef_drawingreqdt[ll_row],'yyyymmdd'))
				ls_bef_drawingtype   = Trim(idw_data[1].Object.bef_drawingtype[ll_row])
				ls_bef_drawingresult = Trim(idw_data[1].Object.bef_drawingresult[ll_row])
				ls_bef_receiptcod 	= Trim(idw_data[1].Object.bef_receiptcod[ll_row])
				ls_bef_receiptdt 		= Trim(string(idw_data[1].Object.bef_receiptdt[ll_row],'yyyymmdd'))
				ls_bef_resultcod 		= Trim(idw_data[1].Object.bef_resultcod[ll_row])
				
				//출금이체신청 Table에 추가 - 해지	
			   INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,'08',:ls_payid,
				 :ls_bef_bank,:ls_bef_acctno,:ls_bef_acct_owner,:ls_bef_acct_ssno,:ls_bef_receiptcod);
				 
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller + ":INSERT bankreq #1 - 고객번호번호 - " + ls_payid )
				   ROLLBACK;
				   ii_rc = -1
					Return
				End If				
					
				ll_data_seq = ll_data_seq + 1
				ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)	
					
				//출금이체신청 Table에 추가 - 신규
			   INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,'02',:ls_payid,
				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:ls_bef_receiptcod);
				 
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller + ":INSERT bankreq #2 - 고객번호번호 - " + ls_payid )
				   ROLLBACK;
				   ii_rc = -1
					Return
				End If				
			
			Else
				// 출금이체신청 Table에 추가
			   INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_reqtype,:ls_payid,
				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:ls_receiptcod);
				 
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller + ":INSERT bankreq #3 - 고객번호번호 - " + ls_payid )
				   ROLLBACK;
				   ii_rc = -1
					Return
				End If				
			End If
			//end jwlee
			
			//2.billinginfo 처리중 Update
			UPDATE billinginfo
			SET drawingresult = :is_data[7],
				receiptdt      = to_date(:ls_cmsacpdt,'yyyy-mm-dd'),
				updtdt         = sysdate,
				updt_user      = :gs_user_id,
				pgm_id         = :is_data[9]				
			WHERE customerid  = :ls_payid ;
			
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":UPDATE billinginfo #1")
				ROLLBACK;
				ii_rc = -1
				Return
			End If
		
		Next
		
		//GR21파일 - 은행접수분 응답파일
		ls_temp = fs_get_control("B7", "A605", ls_ref_desc)
		If ls_temp = "" Then Return
		li_return = fi_cut_string(ls_temp, ";", ls_result[])
		If li_return < 3 Then Return
		ls_gr_flnm = Trim(ls_result[1])
		
		ls_gr_flnm = ls_gr_flnm + "%"
				
		//은행접수분 파일처리를 따로 할때 SEQ 재지정
		If ll_data_seq = 0 Then
			SELECT nvl(MAX(prcno), 0)
			INTO :ll_data_seq
			FROM bankreq 
			WHERE file_name = :ls_file_name;
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":SELECT SEQ#")
				Rollback;
				ii_rc = -1
				Return
			End If		
		End If 
	//------------------------------------------------------------------------------//
   // GR21mmdd->GR22mmdd (파일명이 GR21mmdd이고 신청결과가 파일저장인 은행접수분)
	//------------------------------------------------------------------------------//
		DECLARE cur_read_bankreq1 CURSOR FOR 
		 SELECT a.file_name, 
		        a.prcno,
			     a.payid
		   FROM bankreq a, 
			     bankreqstatus b
		  WHERE a.file_name = b.file_name
		    AND a.receiptdt = b.receiptdt
		    AND b.status = '2'
		    AND ( a.receiptcod = '4' OR a.receiptcod = '0' OR a.receiptcod = '6' )
		    AND a.file_name LIKE :ls_gr_flnm
		ORDER BY a.file_name, a.prcno;
		  
		OPEN cur_read_bankreq1;
		Do While(True)
			FETCH cur_read_bankreq1
			INTO :ls_bankreq_fname, :ls_prcno, :ls_payid;
			
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":cur_read_bankreq1")
				CLOSE cur_read_bankreq1;
				Rollback;
				ii_rc = -1
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If				
			
         ll_data_seq = ll_data_seq + 1
			ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)		
			
			Insert into bankreq
				  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
					reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
					result_code, error_code, receiptno)
			SELECT :ls_file_name, a.receiptdt, :ls_data_seq, a.worktype, a.drawingreqdt, a.drawingtype,
					 a.reqtype,payid, a.bank, a.acctno, a.acct_owner, a.acct_ssno, a.receiptcod,
					 a.result_code, a.error_code, a.receiptno
		     FROM bankreq a, 
			       bankreqstatus b
		    WHERE a.file_name = b.file_name
		      AND a.receiptdt = b.receiptdt
			   AND a.prcno       = :ls_prcno
		      AND b.status      = '2'
			   AND a.file_name   = :ls_bankreq_fname;
			  
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":INSERT bankreq #2 - 고객번호 - " + ls_payid )
				Rollback;
				ii_rc = -1
				Return
			End If
			
			//UPDATE payadd1 - 해당 payid의 신청유형을 '응답저장'으로 Update
			Update billinginfo 
				set drawingresult = '2',
					 updtdt        = sysdate, 
					 updt_user     = :gs_user_id, 
					 pgm_id        = :gs_pgm_id[1]
			 where customerid    = :ls_payid
			   and ( receiptcod = '4' OR receiptcod = '0' OR receiptcod = '6' ); 
			  
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":UPDATE billinginfo #2")
				Rollback;
				ii_rc = -1
				Return
			End If
			 
		Loop
		CLOSE cur_read_bankreq1;

		//GR21도 'S'로 update
	  UPDATE bankreqstatus
		  SET status = 'S'
		WHERE status = '2';
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			ii_rc = -1
			f_msg_sql_err(is_Title, "Update Error1(bankreqstatus)")
			Return 
		End If
		//3.출금이체신청처리상태(BankReqstatus) Table에 Insert
		//미처리로 만든다.
		INSERT INTO bankreqstatus
		(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
		 crt_user, updt_user, crtdt, updtdt, pgm_id) 
		VALUES
		(:is_data[3],:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ll_data_seq,:is_data[7],sysdate,
		 :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[9]);
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(bankreqstatus)")
			ii_rc = -1
			ROLLBACK;
			Return
		End If
						
		il_data[1] = ll_data_seq
		ii_rc = ll_cnt	
	Case "EDI GR22%FilseWrite"	
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea13%ue_filewrite"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			       //filename
//		lu_dbmgr.is_data[2] = is_filepath			    //filepath
//		lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형)
//		lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
//		lu_dbmgr.is_data[5] = is_coid			          //기관식별코드
//		lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[7] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
//		lu_dbmgr.is_data[8] = is_coname                 //이용기간명
//                          is_bankreqstatus[3]
//		lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid

		For li_i = 1 To 9
			ll_trailer[li_i] = 0
		Next
		
		ll_bytes       = 0
		li_write_bytes = 0
		ll_cnt         = 0
		ll_chgcnt      = 0
		ll_newcnt      = 0
		ll_cancelcnt   = 0 
		ls_filename_prefix = LeftA(is_data[1], 4)		
		
		
		//이용기간 신청 유형
		ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_maincod[])
		
		//은행 신청 유형
		ls_temp = fs_get_control("B7", "A321", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_b_maincod[])
		
		//신청결과
      ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingtype[])
		
		//Data 구분코드
		ls_temp = fs_get_control("B7", "A601", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_datacod[])
		
		//접수처 구분코드
		ls_code = fs_get_control("B7", "A604", ls_ref_desc)
		
		//1.Header Record
		ls_buffer = ""
		ls_buffer += ls_datacod[1]                    //Data구분 코드
		ls_buffer += fs_fill_zeroes(is_data[5], 7)    //지로번호
      ls_buffer += fs_fill_spaces(is_data[8], 34)   //이용기간명
		ls_buffer += fs_fill_zeroes(is_data[4], 8)    //신청접수일자
		ls_buffer += Space(99)
		
		
		// File Open
		ls_filename = is_data[2] + is_data[1]
		li_filenum = FileOpen(ls_filename, StreamMode!, Write!, LockReadWrite!, Replace!)	
		If IsNull(li_filenum) Then li_filenum = -1
		If li_filenum < 0 Then 	
			FileClose(li_filenum)
			ii_rc = -3
			Return 
		End If
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			FileClose(li_filenum)
			ii_rc = -3			
			Return 
		End If

		//Data Record
		DECLARE cur_read_bankreq CURSOR FOR
		 SELECT a.file_name, to_char(a.receiptdt,'yyyymmdd'), a.prcno,
			     to_char(a.drawingreqdt,'yyyymmdd'), a.drawingtype, a.reqtype, 
			     a.payid, a.bank, replace(a.acctno,'-',''), a.acct_owner,
				  a.acct_ssno, a.receiptcod
		   FROM bankreq a, bankreqstatus b
		  WHERE a.file_name = b.file_name
		    AND SUBSTR(b.file_name, 1, 4) = :ls_filename_prefix
		    AND b.resultprcdt is null
	  Order by 1,2,3;
		
		OPEN cur_read_bankreq;
		Do While (True)
			Fetch cur_read_bankreq
			Into :ls_file_name, :ls_receiptdt, :ls_prcno,
				 :ls_drawingreqdt, :ls_drawingtype_1, :ls_reqtype,
				 :ls_payid, :ls_bank_code, :ls_acctno, :ls_acct_owner,
				 :ls_acct_ssno, :ls_receiptcod;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_bankreq;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "Select Error(bankreq)")
				Rollback;
			   ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   		  
		  //오류 파일만 보낸다. 
		  If ls_resultcod = "" Then 
			ll_cnt++
			
//			IF ls_reqtype = ls_maincod[2]  THEN                                      //이용기관신규
//				ll_newcnt++
//			ELSEIF ls_reqtype = ls_maincod[3] THEN                                   //이용기관변경
//			   ll_chgcnt++
//			ELSEIF ls_reqtype = ls_maincod[4] or ls_reqtype = ls_maincod[5] Then     //이용기관해지    
//				ll_cancelcnt++
//			ELSEIF ls_reqtype = ls_b_maincod[1]  THEN                                //은행신규
//				ll_b_newcnt++
//			ELSEIF ls_reqtype = ls_b_maincod[4] or ls_reqtype = ls_b_maincod[5] THEN //은행변경
//			   ll_b_chgcnt++
//			ELSEIF ls_reqtype = ls_b_maincod[2] or ls_reqtype = ls_b_maincod[3] Then //은행해지    
//				ll_b_cancelcnt++
//			END IF
		  
		  
			
			//Data Record
			ls_buffer  = ls_datacod[2]                        //Data 구분 코드
			ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)   //일련번호
			ls_buffer += ls_drawingreqdt                      //신청일자
		   ls_buffer += ls_reqtype                           //신청 구분
			//start-여기서 변경은 납부자 번호 변경이 아니라 자동이체 변경이다 그래서 변경전 납부자 번호는 
//			ls_buffer += fs_fill_spaces(ls_bef_payid,20)      //변경전 납부자 번호
			//공백처리함. - 2005.11.02 jwlee
			ls_buffer += Space(20)                            //변경전 납부자 번호
			//end
			ls_buffer += fs_fill_spaces(ls_payid, 20)         //납부자 번호
			ls_buffer += '00'                                 //납부희망일
			ls_buffer += '00'                                 //요금종류
			ls_buffer += fs_fill_zeroes(ls_bank_code, 6)      //은행점 코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)        //지정출금계좌번호
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)     //주민등번호
			
			Select replace(a.phone1,'-','') 
			  into :ls_phone 
			  from customerm a, 
			       billinginfo b 
			 where a.customerid = b.customerid
			   and b.customerid = :ls_payid;
			
			ls_buffer += fs_fill_spaces(ls_phone, 11)         //전화번호
			ls_buffer += fs_fill_zeroes(ls_bank_code, 6)      //신청접수처코드
			ls_buffer += fs_fill_zeroes(ls_resultcod,2)       //결과코드
			ls_buffer += "0000"                               //최초개시월일
//			ls_buffer += ls_code                              //접수처 구분코드
			//2005-10-12 Modify kem Start
			ls_buffer += ls_receiptcod                        //접수처 구분코드
			//kem End
			ls_buffer += fs_fill_zeroes("0",-9)               //전자접수코드
			ls_buffer += fs_fill_spaces(ls_acct_owner, 16)    //예금주명
			ls_buffer += Space(4)
			
			li_write_bytes = FileWrite(li_filenum, ls_buffer)
			If li_write_bytes < 0 Then
				FileClose(li_filenum)
				Close cur_read_bankreq;
				Rollback;
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
		  End IF
		  
			//trailer data
			Choose Case ls_reqtype
				Case "01"
					ll_trailer[1] += 1
				Case "02"
					ll_trailer[6] += 1
				Case "03"
					ll_trailer[2] += 1
				Case "04"
					ll_trailer[4] += 1
				Case "05"
					ll_trailer[3] += 1
				Case "06"
					ll_trailer[9] += 1
				Case "07"
					ll_trailer[5] += 1
				Case "08"
					ll_trailer[7] += 1
				Case "09"
					ll_trailer[8] += 1
			End Choose			
			
		Loop
		Close cur_read_bankreq;
		
		// Trailer Record
		ls_buffer = ls_datacod[3]                             //Date 구분코드
		ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)       //레코드수
//		ls_buffer += fs_fill_zeroes("0", -7)                  //은행접수
//		ls_buffer += fs_fill_zeroes("0", -7)                  //은행접수 해지
//		ls_buffer += fs_fill_zeroes("0", -7)                  //은행변경
//		ls_buffer += fs_fill_zeroes("0", -7)                  //은행임의 해지
//		ls_buffer += fs_fill_zeroes("0", -7)                  //은행임의 변경
//		ls_buffer += fs_fill_zeroes(String(ll_newcnt), -7)    //신규
//		ls_buffer += fs_fill_zeroes(String(ll_cancelcnt), -7) //해지
//		ls_buffer += fs_fill_zeroes("0", -7)                  //해지임의
//		ls_buffer += fs_fill_zeroes(String(ll_chgcnt), -7)    //신규
		For li_i = 1 To 9
			ls_buffer += fs_fill_zeroes(String(ll_trailer[li_i]), -7)
		Next
		ls_buffer += Space(78)
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		FileClose(li_filenum)
		
		//PAYADD1 update
		UPDATE billinginfo
		SET drawingresult = DECODE(receiptcod, '4', 'S', '0', 'S', '6', 'S', '5', '2', '2', '2'),
			 receiptdt     = :is_data[4],
			 pgm_id        = :is_data[10],
			 updt_user     = :gs_user_id
		WHERE (( receiptcod = '4' OR receiptcod = '0' OR receiptcod = '6' ) AND drawingresult = '2')
		   OR (( receiptcod = '5' OR receiptcod = '2' ) AND drawingresult = '1')
		  AND customerid in (SELECT rtrim(a.payid)
									  FROM bankreq a, bankreqstatus b
								    WHERE a.file_name = b.file_name
									   AND SUBSTR(b.file_name, 1, 4) = :ls_filename_prefix
									   AND b.resultprcdt is null);
		If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":UPDATE billinginfo #3")
				
			   ii_rc = -1
				Rollback;
				Return 
		End If
		
		//2.bankreqstatus UPDATE
	  UPDATE bankreqstatus
		  SET status      = 'S',
			   resultprcdt = :is_data[4],
			   crt_user    = :gs_user_id,
			   updt_user   = :gs_user_id,
			   crtdt       = sysdate,
			   updtdt      = sysdate,
			   pgm_id      = :is_data[10]		 
		WHERE file_name = :ls_file_name
		  AND resultprcdt is null;
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			ii_rc = -1
			f_msg_sql_err(is_Title, "Update Error3(bankreqstatus)")
			Return 
		End If
	
		ii_rc = ll_cnt	
End Choose

Return
end subroutine

public subroutine uf_prc_db ();Integer li_FileNum, ll_reqcnt, li_write_bytes
Long ll_bytes_read, ll_FLength, ll_seqno
String ls_buffer, ls_recordtype
String ls_error_code,ls_prcno, ls_payid, ls_resultcode, ls_errorcode, ls_reqdt, ls_reqtype
String ls_drawingtype, ls_drawingresult, ls_drawingresults[], ls_drawingreqdt, ls_bank, ls_acctno, ls_acct_ssno
String ls_temp, ls_ref_desc, ls_status[], ls_receiptcod, ls_name
String ls_cms, ls_giro, ls_paymethod, ls_receiptdt, ls_acct_owner, ls_bef_payid
Integer li_return

String ls_filename
Long ll_bytes,ll_bcancelcnt, ll_bnewcnt, ll_bchgcnt, ll_bchgcnt1, ll_bbcancelcnt,ll_bcancelcnt1, ll_errcnt
String ls_drawingtype_1, ls_outtype, ls_receiptcod_1
String  ls_bankcod[], ls_datacod[]
String  ls_bil_payid, ls_bil_acctno, ls_bil_drawingtype, ls_bil_drawingresult
String ls_phone, ls_code
String ls_cmsacpdt //처리일자yyyymmdd
String ls_gr22_filename	//GR22파일이름

String ls_bank_code   //2004.06.28. khpark add

String ls_receiptno		////전자접수번호 2004.12.24 jjuhm add

ii_rc = -1
Choose Case is_caller
	Case "EDI GR21%Save%Write"
//lu_dbmgr.is_caller = "EDI GR21%Save%Write"
//lu_dbmgr.is_title = This.Title
//lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.is_data[1] = ls_pathname              //GR21파일에 Path    
//lu_dbmgr.is_data[2] = ls_filename              //GR21파일
//lu_dbmgr.is_data[3] = is_worktype[1]           //은행신청
//lu_dbmgr.is_data[4] = is_filepath			     //GR22생성할 path
//lu_dbmgr.is_data[5] = is_filenm			        //GR22생성할 파일 이름 Prefix
//lu_dbmgr.is_data[6] = ls_cmsacpdt			     //처리일자
//lu_dbmgr.is_data[7] = is_coid			           //기관식별코드(지로번호)
//lu_dbmgr.is_data[8] = is_coname               //이용기간명 
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid

		Constant Integer GR21_Size = 150
		Constant Integer GR22_Size = 150
		ll_errcnt = 0
		
		//1.GR21 Open
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(10001, is_Title, is_data[1])
			FileClose(li_filenum)
			ii_rc =-3
			Return
		End If

		// Status : sysctl1t 파일의 상태
		ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
//		ls_temp = fs_get_control("B7", "A300", ls_ref_desc)    //신청 접수처
//		li_return = fi_cut_string(ls_temp, ";", ls_receiptcod)
		ls_temp = fs_get_control("B7", "A330", ls_ref_desc)    
		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults) //이체신청 결과 
		
		ls_giro = fs_get_control("B0", "P129", ls_ref_desc)  //지로  
		ls_cms = fs_get_control("B0", "P130", ls_ref_desc)  //자동이체
		
	   //은행신청 유형
		ls_temp = fs_get_control("B7", "A608", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_bankcod[])
		
		//접수처 구분코드
//		ls_code = fs_get_control("B7", "A604", ls_ref_desc)
		
		//Data 구분코드
		ls_temp = fs_get_control("B7", "A601", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_datacod[])
		
		
		//2.File 읽으면서 테이블에 Insert 한다.
		//GR22 파일로 생성한다. 파일처리상태 응답확인
		Do While(true)
			//File Read
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > GR21_Size Then
				FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
			End If
			
			//150Byte로 읽는다. 한줄 씩
			ls_buffer = MidA(ls_buffer, 1, GR21_Size)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case "51"
					ls_cmsacpdt = Trim(MidA(ls_buffer,44,8)) //처리일자
					ls_gr22_filename = is_data[5] + MidA(ls_cmsacpdt,5,4)
				Case "71"
					ll_reqcnt = Integer(Trim(MidA(ls_buffer,3,7))) //총 Record 수
			End Choose
		Loop
     //File Close
	 FileClose(li_FileNum)
	
	
	 li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
	 If IsNull(li_FileNum) Then li_FileNum = -1
	 If li_FileNum < 0 Then
		f_msg_usr_err(10001, is_Title, is_data[1])
		FileClose(li_filenum)
		Return
	End If
		
	 Do While(true)
		//File Read
		ls_buffer = ""
		ll_bytes_read = FileRead(li_FileNum, ls_buffer)
		
		If ll_bytes_read < 0 Then Exit
		// File Pointer Move
		If ll_bytes_read > GR21_Size Then
			FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
		End If
		
	   ls_buffer = MidA(ls_buffer, 1, GR21_Size)
		ls_recordtype = LeftA(ls_buffer, 2)
		
		
		//고객 상세
		If ls_recordtype = "61" Then

			ls_drawingreqdt = Trim(MidA(ls_buffer,10,8))     //신청일자(고객이 신청한 날짜)
			ls_drawingtype  = Trim(MidA(ls_buffer, 18,2))    //신청 구분 코드
			ls_payid        = Trim(MidA(ls_buffer, 40 ,20))  //납부자 번호
//Start 2004.06.28. khpark modify 은행납부자계좌개설점코드(은행코드2자리 + 개설점코드4자리) 6자리 
			ls_bank         = Trim(MidA(ls_buffer, 64, 2) )  //은행코드(앞자리2자리)
			ls_bank_code    = Trim(MidA(ls_buffer, 64, 6) )  //은행+납부자계좌개설점코드
//End  2004.06.28.  khpark modify 
			ls_acctno       = Trim(MidA(ls_buffer, 70, 15))  //계좌번호
			ls_acct_ssno    = Trim(MidA(ls_buffer, 85, 13))  //주민등록 번호
			ls_prcno        = Trim(MidA(ls_buffer,3,7))
			//Start 2005-10-11 kem modify 접수처구분코드(전자접수구분 관련)
			ls_receiptcod   = Trim(MidA(ls_buffer,121,1))    //접수처구분코드
			//End   2005-10-11 kem modify
			ls_receiptno    = Trim(MidA(ls_buffer,122,9))		//전자접수번호 jjuhm add
			ls_name         = Trim(MidA(ls_buffer,131,16))
			ls_errorcode    = ""
			
			  ls_bil_payid         = ""
			  ls_bil_drawingtype   = ""
			  ls_bil_acctno        = ""
			  ls_bil_drawingresult = ""
		    //결과코드 완성
     		  Select customerid, drawingtype, acctno, drawingresult
			  into  :ls_bil_payid, :ls_bil_drawingtype, :ls_bil_acctno, :ls_bil_drawingresult
			  from billinginfo where customerid = :ls_payid;
				
				If SQLCA.SQLCode < 0 Then
					FileClose(li_filenum)
					f_msg_sql_err(is_Title, "Select Error(billinginfo)")
					Return 
				End If
				
				If IsNull(ls_bil_payid) Then ls_bil_payid = ""
				If IsNull(ls_bil_drawingtype) Then ls_bil_drawingtype =""
				If IsNull(ls_bil_acctno) Then ls_bil_acctno =""
				If IsNull(ls_bil_drawingresult) Then ls_bil_drawingresult =""
				
				If ls_bil_payid = "" Then
					 ls_errorcode = '03'  //납부자 번호 없음
				//신청 내역이 업는데 변경, 해지가 들어온 경우
			    ElseIf ls_bil_drawingtype = ""  Then
			      If ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] or ls_drawingtype = ls_bankcod[2] or &
					   ls_drawingtype = ls_bankcod[3] or ls_drawingtype = "0" Then ls_errorcode = '01'  //신청구분코드
			   
			    ElseIf ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] THEN     //해지 신청시                                                 
				   
					If ls_bil_acctno <> ls_acctno Then ls_errorcode = '04'                                //계좌번호 없음
			   
			    ElseIf ls_drawingtype = ls_bankcod[1] or ls_drawingtype = ls_bankcod[2] or ls_drawingtype = ls_bankcod[3] or &
					    ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5]Then
				   
					//미처리(1), 처리중(2) 이거나
					//신청코드가 같으면서 처리성공(S) 이면 이중신청
	            IF (ls_bil_drawingresult = ls_drawingresults[2]) OR &
						(ls_bil_drawingresult = ls_drawingresults[3]) OR &
						(ls_drawingtype = ls_bil_drawingtype AND ls_bil_drawingresult = ls_drawingresults[4]) THEN
						ls_errorcode = '06' 
					END IF
				
				End If
		      
				
				If ls_errorcode = "00" or ls_errorcode = "" Then 
					ls_drawingresult = ls_drawingresults[4]
					ls_resultcode = ""
					ls_errorcode = "00"
			   Else
					ls_drawingresult = ls_drawingresults[5]
					ls_resultcode = 'N'
					ll_errcnt ++
				End IF
		  
		      //Bankreq Insert GR22 파일로 생성한다.
			  Insert into bankreq
			  (file_name, receiptdt,prcno, worktype, drawingreqdt, drawingtype,
				reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
				result_code, error_code, receiptno)
			  values
			  (:ls_gr22_filename, to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ls_prcno,
				:is_data[3], to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
				:ls_drawingtype, :ls_drawingtype, :ls_payid, :ls_bank_code, :ls_acctno, :ls_name, :ls_acct_ssno, :ls_receiptcod,
				:ls_resultcode, :ls_errorcode, :ls_receiptno);
			  
				If SQLCA.SQLCode < 0 Then
					FileClose(li_FileNum)
					f_msg_sql_err(is_title, is_caller + " Insert Error(bankreq)")
					Rollback;
					return 
				End If
				
				//결과가 성공이면 해지이면 결제방법을 지로로 변경한다.
				If ls_errorcode = "00" Then
					If ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] Then 
						ls_paymethod = ls_giro
					Else
						ls_paymethod = ls_cms
					End If
			   End If
				
				
				//미처리, 처리중, 처리성공 이중신청(ls_errorcode = '06' ) 인 경우를 제외하고			
				//Billing Update                                                         
				//성공 실패여부
				IF ls_errorcode <> '06' THEN
					Update billinginfo set bank = :ls_bank, receiptcod = :ls_receiptcod, acct_owner = :ls_name, acct_ssno = :ls_acct_ssno,
					acctno = :ls_acctno, receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd'), pay_method = :ls_paymethod,
					drawingtype = :ls_drawingtype, drawingresult = :ls_drawingresult, drawingreqdt = to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
					updtdt = sysdate, updt_user = :gs_user_id, pgm_id =:gs_pgm_id[1], resultcod =:ls_errorcode
					where customerid = :ls_payid; 
					
					// Rollback
					If SQLCA.SQLCode < 0 Then
						FileClose(li_FileNum)						
						f_msg_sql_err(is_Title, " Update Error(billinginfo)")
						Rollback;
						return 
					End If
			   END IF
			
	  End If
  Loop
	 //File Close
	 FileClose(li_FileNum)
	  
	//3.bankreqstus Insert
	//파일상태는 응답확인 
	Insert into bankreqstatus
	(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
	crt_user, updt_user, crtdt, updtdt, pgm_id, resultprcdt, errcnt) 
	VALUES
	(:is_data[3], :ls_gr22_filename, to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ll_reqcnt, :ls_status[3], sysdate,
	 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[1], sysdate, :ll_errcnt);
			
	// Rollback
	If SQLCA.SQLCode < 0 Then
		FileClose(li_FileNum)						
		f_msg_sql_err(is_Title, " Insert Error(bankreqstatus)")
		Rollback;
		return 
	End If
   
	//4 파일 Write GR22
	ll_bytes = 0
	li_write_bytes = 0
	ll_bchgcnt = 0
	ll_bchgcnt1 = 0
	ll_bnewcnt = 0
	ll_bcancelcnt = 0 
	ll_bcancelcnt1 = 0
	ll_seqno = 0
	ls_bef_payid = ""
	//.Header Record
	ls_buffer = ""
	ls_buffer += ls_datacod[1]                    //Data구분 코드
	ls_buffer += fs_fill_zeroes(is_data[7], 7)    //지로번호
	ls_buffer += fs_fill_spaces(is_data[8], 34)   //이용기간명
	ls_buffer += fs_fill_zeroes(ls_cmsacpdt, 8)    //신청접수일자
	ls_buffer += Space(99)
	
	// File Open
	ls_filename = is_data[4] + ls_gr22_filename
	li_filenum = FileOpen(ls_filename, StreamMode!, Write!, LockReadWrite!, Replace!)	
	If IsNull(li_filenum) Then li_filenum = -1
	If li_filenum < 0 Then 	
		FileClose(li_filenum)
		ii_rc = -3
		Return 
	End If
	
	li_write_bytes = FileWrite(li_filenum, ls_buffer)
	If li_write_bytes < 0 Then 
		FileClose(li_filenum)
		ii_rc = -3			
		Return 
	End If

		//kem Modify 2005-10-11 전자접수번호 받은걸로 데이타를 금결원에 보낸다.
		//Data Record
		DECLARE cur_read_bankreq CURSOR FOR
		 SELECT to_char(a.receiptdt,'yyyymmdd'), a.error_code,
			     to_char(a.drawingreqdt,'yyyymmdd'), a.drawingtype, a.reqtype, 
			     a.payid, a.bank, replace(a.acctno,'-',''), a.acct_owner,
				  a.acct_ssno, a.receiptcod, a.receiptno
		   FROM bankreq a, bankreqstatus b
		  WHERE a.file_name = b.file_name
		    AND a.receiptdt = b.receiptdt
		    AND b.file_name = :ls_gr22_filename
		    AND to_char(b.receiptdt,'yyyymmdd') = :ls_cmsacpdt
		    AND b.worktype = :is_data[3]
		    AND b.status = :ls_status[3]   //응답확인
		  //And a.result_code = 'N'
		Order by 1,3;
		
		OPEN cur_read_bankreq;
		Do While (True)
			Fetch cur_read_bankreq
			Into :ls_receiptdt, :ls_errorcode,
				  :ls_drawingreqdt, :ls_drawingtype_1, :ls_reqtype,
				  :ls_payid, :ls_bank, :ls_acctno, :ls_acct_owner,
				  :ls_acct_ssno, :ls_receiptcod, :ls_receiptno;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_bankreq;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "Select Error(bankreq)")
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   
			ll_seqno ++   //작성고객수
			
			ls_bef_payid = ""
			
			IF ls_reqtype = ls_bankcod[1] THEN     //신규
				ll_bnewcnt++
			ELSEIF ls_reqtype = ls_bankcod[2] Then //변경
				ll_bchgcnt++
				ls_bef_payid = ls_payid
			ElseIF  ls_reqtype = ls_bankcod[3] THEN 
				ll_bchgcnt1++
				ls_bef_payid = ls_payid
			ELSEIF ls_reqtype = ls_bankcod[4] Then
				ll_bcancelcnt++
		   ElseIf ls_reqtype = ls_bankcod[5] THEN //해지
				ll_bcancelcnt1++
			END IF
			
			//Data Record
			ls_buffer  = ls_datacod[2]                        //Data 구분 코드
			ls_buffer += fs_fill_zeroes(String(ll_seqno), -7) //일련번호
//Start 2004.06.28. khpark modify 
//			ls_buffer += ls_receiptdt                         //신청일자
			ls_buffer += ls_drawingreqdt                      //신청일자
//End 2004.06.28. khpark modify 			
		   ls_buffer += ls_reqtype                           //신청 구분
			ls_buffer += fs_fill_spaces(ls_bef_payid,20)      //변경전 납부자 번호
			ls_buffer += fs_fill_spaces(ls_bef_payid,20)      //변경후 납부자 번호
			ls_buffer += fs_fill_spaces(ls_payid, 20)         //납부자 번호
			ls_buffer += '00'                                 //납부희망일
			ls_buffer += '00'                                 //요금종류
			ls_buffer += fs_fill_zeroes(ls_bank, 6)           //은행점 코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)        //지정출금계좌번호
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)     //주민등번호
			
			Select replace(a.phone1,'-','') 
			  into :ls_phone 
			  from customerm a, 
			       billinginfo b 
			 where a.customerid = b.customerid
			   and b.customerid = :ls_payid;
			
			ls_buffer += fs_fill_spaces(ls_phone, 11)         //전화번호
			ls_buffer += fs_fill_zeroes(ls_bank, 6)           //신청접수처코드
			ls_buffer += fs_fill_zeroes(ls_errorcode,2)       //결과코드
			ls_buffer += "0000"                               //최초개시월일
//			ls_buffer += ls_code                              //접수처 구분코드
			//kem Modify 접수처 구분 코드도 받은걸 다시 보낸다. 2005-10-11
			ls_buffer += ls_receiptcod								  //접수처 구분코드
			ls_buffer += fs_fill_zeroes(ls_receiptno,9)       //전자접수코드 --> jjuhm 수정
			ls_buffer += fs_fill_spaces(ls_acct_owner, 16)    //예금주명
			ls_buffer += Space(4)
			
			li_write_bytes = FileWrite(li_filenum, ls_buffer)
			If li_write_bytes < 0 Then
				FileClose(li_filenum)
				Close cur_read_bankreq;
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
		 
		Loop
		Close cur_read_bankreq;
		
		// Trailer Record
		ls_buffer = ls_datacod[3]                               //Date 구분코드
		ls_buffer += fs_fill_zeroes(String(ll_seqno), -7)         //레코드수
		ls_buffer += fs_fill_zeroes(String(ll_bnewcnt), -7)     //은행접수
		ls_buffer += fs_fill_zeroes(String(ll_bcancelcnt), -7)  //은행접수 해지
		ls_buffer += fs_fill_zeroes(String(ll_bchgcnt), -7)     //은행변경
		ls_buffer += fs_fill_zeroes(String(ll_bcancelcnt1), -7) //은행임의 해지
		ls_buffer += fs_fill_zeroes(String(ll_bchgcnt1), -7)    //은행임의 변경
		ls_buffer += fs_fill_zeroes("0", -7)      //신규
		ls_buffer += fs_fill_zeroes("0", -7)    //해지
		ls_buffer += fs_fill_zeroes("0", -7)  //해지임의
		ls_buffer += fs_fill_zeroes("0", -7)      //신규
		ls_buffer += Space(78)
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		FileClose(li_filenum)
		
	
	
		ii_rc = ll_reqcnt  //총레코드 건수 넣음
		commit;
		
		is_data[5] = ls_gr22_filename
		is_cmsacpdt = ls_cmsacpdt
		Return
End Choose
ii_rc = 1
end subroutine

public subroutine uf_prc_db_05 ();Integer li_FileNum, ll_reqcnt, li_write_bytes
Long ll_bytes_read, ll_FLength, ll_seqno
String ls_buffer, ls_recordtype
String ls_error_code,ls_prcno, ls_payid, ls_resultcode, ls_errorcode, ls_reqdt, ls_reqtype
String ls_drawingtype, ls_drawingresult, ls_drawingresults[], ls_drawingreqdt, ls_bank, ls_acctno, ls_acct_ssno
String ls_temp, ls_ref_desc, ls_status[], ls_receiptcod, ls_name
String ls_cms, ls_giro, ls_paymethod, ls_receiptdt, ls_acct_owner, ls_bef_payid
Integer li_return

String ls_filename, ls_bankreq_fname
Long ll_bytes,ll_bcancelcnt, ll_bnewcnt, ll_bchgcnt, ll_bchgcnt1, ll_bbcancelcnt,ll_bcancelcnt1, ll_errcnt
String ls_drawingtype_1, ls_outtype, ls_receiptcod_1, ls_bil_bilcycle
String  ls_bankcod[], ls_datacod[], ls_bil_pay_method, ls_result[]
String  ls_bil_payid, ls_bil_acctno, ls_bil_drawingtype, ls_bil_drawingresult
String ls_phone, ls_code
String ls_cmsacpdt //처리일자yyyymmdd
String ls_gr22_filename	//GR22파일이름
String ls_bilcycle_edi, ls_paymethod_edi, ls_bilcycle_cancel, ls_paymethod_cancel, ls_reqyn, ls_bilcycle
String ls_bank_code   //2004.06.28. khpark add
Boolean lb_reject

String ls_receiptno		////전자접수번호 2004.12.24 jjuhm add

ii_rc = -1
Choose Case is_caller
	Case "EDI GR21%Save%Write"
//lu_dbmgr.is_caller = "EDI GR21%Save%Write"
//lu_dbmgr.is_title = This.Title
//lu_dbmgr.idw_data[1] = dw_detail
//lu_dbmgr.is_data[1] = ls_pathname               //GR21파일에 Path    
//lu_dbmgr.is_data[2] = ls_filename               //GR21파일
//lu_dbmgr.is_data[3] = is_worktype[1]            //은행신청
//lu_dbmgr.is_data[4] = is_filepath			        //GR22생성할 path
//lu_dbmgr.is_data[5] = is_filenm			        //GR22생성할 파일 이름 Prefix
//lu_dbmgr.is_data[6] = ls_cmsacpdt			        //처리일자
//lu_dbmgr.is_data[7] = is_coid			           //기관식별코드(지로번호)
//lu_dbmgr.is_data[8] = is_coname                 //이용기간명 
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no] //pgmid
//lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no] //pgmid
		Constant Integer GR21_Size = 150
		Constant Integer GR22_Size = 150
		ll_errcnt = 0
		
		//1.GR21 Open
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(10001, is_Title, is_data[1])
			FileClose(li_filenum)
			ii_rc =-3
			Return
		End If

		// Status : sysctl1t 파일의 상태
		//자동이체 : 신청&이체파일상태(미처리;신청;응답확인;입금처리;ERROR)-->0;1;2;3;4
		ls_temp   = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
//		ls_temp = fs_get_control("B7", "A300", ls_ref_desc)    //신청 접수처
//		li_return = fi_cut_string(ls_temp, ";", ls_receiptcod)
      //자동이체 : 이체신청결과(없음;신청(미처리);처리중;처리성공;처리실패)-->0;1;2;S;F
		ls_temp   = fs_get_control("B7", "A330", ls_ref_desc)    
		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults) //이체신청 결과 
		//결제방법 : 지로-->1
		ls_giro   = fs_get_control("B0", "P129", ls_ref_desc)  //지로  
		//결제방법 : 자동이체-->2
		ls_cms    = fs_get_control("B0", "P130", ls_ref_desc)  //자동이체
		
	   //은행신청 유형
		//자동이체(EDI):은행신청유형(신규;변경;변경(임의);해지;해지(임의))-->01;05;07;03;04
		ls_temp   = fs_get_control("B7", "A608", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_bankcod[])
		
		//접수처 구분코드
//		ls_code = fs_get_control("B7", "A604", ls_ref_desc)
		
		//Data 구분코드
		//자동이체(EDI):신청내역 Data 코드(Header,Data,Trailer)-->52;62;72
		ls_temp   = fs_get_control("B7", "A601", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_datacod[])
		
		//자동이체 신청시(청구주기;청구방법)
		//자동이체(EDI):자동이체신청시(청구주기;청구방법)-->2;2
		ls_temp = fs_get_control("B7", "A612", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_result[])
		 ls_bilcycle_edi  = ls_result[1]
		 ls_paymethod_edi = ls_result[2]
		 
		If ls_bilcycle_edi = "" Or ls_paymethod_edi = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			Return
		End If
		 
		//자동이체 해지시(청구주기;청구방법)
		//자동이체(EDI):자동이체해지시(청구주기;청구방법)-->1;1
		ls_temp = fs_get_control("B7", "A613", ls_ref_desc)
	    fi_cut_string(ls_temp, ";", ls_result[])
		 ls_bilcycle_cancel  = ls_result[1]
		 ls_paymethod_cancel = ls_result[2]
		 
		If ls_bilcycle_cancel = "" Or ls_paymethod_cancel = "" Then 
			f_msg_usr_err(9000, is_title, "자료항목이 부족합니다." + ls_ref_desc)
			ii_rc =-3
			Return
		End If
		
		//2.File 읽으면서 테이블에 Insert 한다.
		//GR22 파일로 생성한다. 파일처리상태 응답확인
		Do While(true)
			//File Read
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > GR21_Size Then
				FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
			End If
			
			//150Byte로 읽는다. 한줄 씩
			ls_buffer = MidA(ls_buffer, 1, GR21_Size)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case "51"
					ls_cmsacpdt = Trim(MidA(ls_buffer,44,8)) //처리일자
					ls_gr22_filename = is_data[5] + MidA(ls_cmsacpdt,5,4)
				Case "71"
					ll_reqcnt = Integer(Trim(MidA(ls_buffer,3,7))) //총 Record 수
			End Choose
		Loop
     //File Close
	 FileClose(li_FileNum)
	
	
	 li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
	 If IsNull(li_FileNum) Then li_FileNum = -1
	 If li_FileNum < 0 Then
		f_msg_usr_err(10001, is_Title, is_data[1])
		FileClose(li_filenum)
		Return
	End If
		
	 Do While(true)
		//File Read
		ls_buffer = ""
		ll_bytes_read = FileRead(li_FileNum, ls_buffer)
		
		If ll_bytes_read < 0 Then Exit
		// File Pointer Move
		If ll_bytes_read > GR21_Size Then
			FileSeek(li_FileNum, GR21_Size - ll_bytes_read, FromCurrent!)
		End If
		
	   ls_buffer = MidA(ls_buffer, 1, GR21_Size)
		ls_recordtype = LeftA(ls_buffer, 2)
		
		
		//고객 상세
		If ls_recordtype = "61" Then

			ls_prcno        = Trim(MidA(ls_buffer,3,7))
			ls_drawingreqdt = Trim(MidA(ls_buffer,10,8))    //신청일자(고객이 신청한 날짜)
			ls_drawingtype  = Trim(MidA(ls_buffer, 18,2))   //신청 구분 코드
			ls_payid        = Trim(MidA(ls_buffer, 40 ,20)) //납부자 번호
//Start 2004.06.28. khpark modify 은행납부자계좌개설점코드(은행코드2자리 + 개설점코드4자리) 6자리 
			ls_bank         = Trim(MidA(ls_buffer, 64, 2) ) //은행코드(앞자리2자리)
			ls_bank_code    = Trim(MidA(ls_buffer, 64, 6) ) //은행+납부자계좌개설점코드
//End  2004.06.28.  khpark modify 
			ls_acctno       = Trim(MidA(ls_buffer, 70, 15)) //계좌번호
			ls_acct_ssno    = Trim(MidA(ls_buffer, 85, 13)) //주민등록 번호
			//Start 2005-10-11 kem modify 접수처구분코드(전자접수구분 관련)
			ls_errorcode    = Trim(MidA(ls_buffer, 115, 2)) //처리결과코드
			ls_receiptcod   = Trim(MidA(ls_buffer,121,1))   //접수처구분코드
			//End   2005-10-11 kem modify
			ls_receiptno    = Trim(MidA(ls_buffer,122,9))	  //전자접수번호 jjuhm add
			ls_name         = Trim(MidA(ls_buffer,131,16))
			
					
		  ls_bil_payid         = ""
		  ls_bil_drawingtype   = ""
		  ls_bil_acctno        = ""
		  ls_bil_drawingresult = ""
		 //결과코드 완성
		  Select customerid, 
					drawingtype, 
					pay_method, 
					bilcycle, 
					acctno, 
					drawingresult
			 into :ls_bil_payid, 
					:ls_bil_drawingtype, 
					:ls_bil_pay_method, 
					:ls_bil_bilcycle, 
					:ls_bil_acctno, 
					:ls_bil_drawingresult
			 from billinginfo 
			where customerid = :ls_payid;
			
			If SQLCA.SQLCode < 0 Then
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "Select Error(billinginfo)")
			   ii_rc = -1
				Return 
			End If
		
			If IsNull(ls_bil_payid)         Then ls_bil_payid         = ""
			If IsNull(ls_bil_drawingtype)   Then ls_bil_drawingtype   = ""
			If IsNull(ls_bil_acctno)        Then ls_bil_acctno        = ""
			If IsNull(ls_bil_drawingresult) Then ls_bil_drawingresult = ""
					
			lb_reject = False	//Init
			Choose Case ls_receiptcod
				//은행접수분, 전자접수분
				Case "4", "0","6"
					If ls_bil_payid = "" Then
						 ls_errorcode = '03'  //납부자 번호 없음
						 lb_reject = True
					//신청 내역이 없는데 변경, 해지가 들어온 경우
					ElseIf ls_bil_drawingtype = ""  Then
					//순서대로 해지(03),임의해지(04),변경(05),임의변경(07)
						If ls_drawingtype = ls_bankcod[4] or &
						   ls_drawingtype = ls_bankcod[5] or &
							ls_drawingtype = ls_bankcod[2] or &
							ls_drawingtype = ls_bankcod[3] or ls_bil_drawingtype = "0" Then 
							ls_errorcode = '01'  //신청구분코드
						   lb_reject = True
						Else	
							lb_reject   = False
						End If
					
					ElseIf ls_drawingtype = ls_bankcod[1] THEN     //신규 신청시  
					  //해당납부자번호의 청구유형이 기존에 자동이체가 아니어야 함 : 아니면 ls_errorcode = "05" -> Reject
					  //또는 금결원과의 작업이 진행중인가를 Check...
					  //현재 신청결과가(billinginfo.drawingresult) 이 0인 상태 : 아니면 ls_errorcode = "05" -> Reject
					 	If (ls_bil_drawingresult <> "0" AND ls_bil_drawingresult <> "F" AND ls_bil_drawingresult <> "S") Then
							ls_errorcode = "05"
						   lb_reject = True
						ElseIf ls_bil_pay_method = ls_cms AND ls_bil_drawingresult <> "0" Then
							ls_errorcode = "05"
						   lb_reject = True
						Else	
							lb_reject   = False
						End If
						//
					ElseIf ls_drawingtype = ls_bankcod[2] or ls_drawingtype = ls_bankcod[3] THEN     //변경 신청시  
					//변경인 경우(ls_drawingtype = "05", "07") **************************
					  //해당납부자번호의 청구유형이 기존에 자동이체 : 아니면 ls_errorcode = "01" -> Reject
					  //현재 신청결과가(billinginfo.drawingresult) 이 처리성공(S) : 아니면 ls_errorcode = "99" -> Reject	
						If ls_bil_drawingresult <> "S" Then
							ls_errorcode = "99"
						   lb_reject = True
						ElseIf ls_bil_pay_method <> ls_cms Then
							ls_errorcode = "01"
						   lb_reject = True
						Else	
							lb_reject   = False
						End If                                               
						
					ElseIf ls_drawingtype = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] THEN     //해지 신청시                                                 

					//해지인경우(ls_drawingtype = "03", "04") ***************************
					  //해당납부자번호의 청구유형이 기존에 자동이체 : 아니면 ls_errorcode = "01" -> Reject
					  //현재 신청결과가(billinginfo.drawingresult) 이 처리성공(S) : 아니면 ls_errorcode = "99" -> Reject
					  //계좌번호가 일치할 것 : 아니면 ls_errorcode = "04" -> Reject
					 	If ls_bil_drawingresult <> "S" Then
							ls_errorcode = "99"
						   lb_reject = True
						ElseIf ls_bil_pay_method <> ls_cms Then
							ls_errorcode = "01"
						   lb_reject = True
						ElseIf ls_bil_acctno <> ls_acctno Then
							ls_errorcode = "04"	
						   lb_reject = True	
						Else	
							lb_reject   = False
						End If					                              
					
					ElseIf ls_drawingtype = ls_bankcod[1] or &
						    ls_drawingtype = ls_bankcod[2] or &
							 ls_drawingtype = ls_bankcod[3] or &
							 ls_drawingtype = ls_bankcod[4] or &
							 ls_drawingtype = ls_bankcod[5] Then
						
						//미처리(1), 처리중(2) 이거나
						//신청코드가 같으면서 처리성공(S) 이면 이중신청
						IF (ls_bil_drawingresult = ls_drawingresults[2]) OR &
							(ls_bil_drawingresult = ls_drawingresults[3]) OR &
							(ls_drawingtype = ls_bil_drawingtype AND ls_bil_drawingresult = ls_drawingresults[4]) THEN
							ls_errorcode = '06' 	
						   lb_reject = True
						END IF
					
					End If
					
					
					If ls_errorcode = "00" or ls_errorcode = "" Then 
						ls_drawingresult = ls_drawingresults[3]
						ls_resultcode = ""
						ls_errorcode = "00"
					Else
						ls_drawingresult = ls_drawingresults[3]
						ls_resultcode = 'N'
						ll_errcnt ++
					End IF
					  //결과가 성공이면서 해지이면 결제방법을 지로로 변경한다.
					If ls_errorcode = "00" or ls_errorcode = "" Then 
						If ls_drawingtype   = ls_bankcod[4] or ls_drawingtype = ls_bankcod[5] Then 
							ls_paymethod     = ls_giro
		               ls_bilcycle      = ls_bilcycle_cancel
							//GR22에서 조회가 될수있게 drawingresult를 바꾸지 않음
							//ls_drawingresult = ls_drawingresults[1]
						Else
							ls_paymethod = ls_cms
		               ls_bilcycle  = ls_bilcycle_edi
						End If
					End If
					
					
					//실패이면 update하지 않는다.
					//Billing Update                                                         
					//성공 실패여부
					If Not lb_reject Then
						
						Update billinginfo 
							set bank          = :ls_bank, 
								 receiptcod    = :ls_receiptcod, 
								 bilcycle      = :ls_bilcycle, 
								 acct_owner    = :ls_name, 
								 acct_ssno     = :ls_acct_ssno,
								 acctno        = :ls_acctno, 
								 receiptdt     = to_date(:ls_cmsacpdt,'yyyy-mm-dd'), 
								 pay_method    = nvl(:ls_paymethod,pay_method),
								 drawingtype   = :ls_drawingtype, 
								 drawingresult = :ls_drawingresult, 
								 drawingreqdt  = to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
								 updtdt        = sysdate, 
								 updt_user     = :gs_user_id, 
								 pgm_id        = :gs_pgm_id[1], 
								 resultcod     = :ls_errorcode
						 where customerid    = :ls_payid; 
						
						// Rollback
						If SQLCA.SQLCode < 0 Then
							FileClose(li_FileNum)						
								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #1")
			               ii_rc = -1
							return 
						End If
					END IF
				Case "5", "2"
					If fs_snvl(ls_bil_payid,'') = '' Then
						f_msg_usr_err(9000, is_title, "일치하는 자료가 없습니다. (납입자번호: " + ls_payid + ") ")
			         ii_rc = -1
						FileClose(li_filenum)						
						Return						
					End If									

					//정상처리
					If ls_errorcode   = "00" or ls_errorcode = "" Then   				 
						ls_reqyn       = "S" 	
						ls_paymethod   = ls_paymethod_edi
						ls_resultcode  = ""
						ls_bilcycle    = ls_bilcycle_edi
						lb_reject      = False		
						
						If ls_bil_drawingtype = "06" Then	//변경신청         
						
							UPDATE billinginfo 
							   SET pay_method    = :ls_paymethod, 
								    drawingresult = :ls_reqyn, 
								    receiptdt     = :ls_cmsacpdt,
								    bilcycle      = :ls_bilcycle, 
								    resultcod     = '00', 
								    pgm_id        = :is_data[9],
								    updt_user     = :gs_user_id
							 WHERE customerid    = :ls_payid ;
							  
							If SQLCA.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #2")
								FileClose(li_filenum)	
			               ii_rc = -1
								Return
							End If
							
						Else                      		//신규,해지신청
							If ls_bil_drawingtype = "08" Then	//해지신청
								ls_paymethod = ls_bil_pay_method
								ls_bilcycle  = ls_bil_bilcycle
							End If
							
							UPDATE billinginfo 
							   SET pay_method    = :ls_paymethod, 
								    bilcycle      = :ls_bilcycle, 
								    resultcod     = '00', 
								    drawingresult = :ls_reqyn, 
								    receiptdt     = :ls_cmsacpdt,
								    pgm_id        = :is_data[9],
								    updt_user     = :gs_user_id
							 WHERE customerid    = :ls_payid ;
							  
							If SQLCA.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #3")
								FileClose(li_filenum)	
			               ii_rc = -1
								Return
							End If											  							  							  
						End If
					//Error 처리
					Else									 
						ls_reqyn       = "F"
						lb_reject      = False			// paymst update 함
						ls_resultcode  = "N"
						ls_paymethod   = ls_paymethod_cancel
						ls_bilcycle    = ls_bilcycle_cancel
							
						If ls_bil_drawingtype = "06" Then	//변경신청
							UPDATE billinginfo 
							   SET pay_method    = :ls_paymethod, 
								    bilcycle      = :ls_bilcycle, 
							 	    drawingresult = :ls_reqyn, 
								    receiptdt     = :ls_cmsacpdt,
								    resultcod     = :ls_errorcode, 
								    pgm_id        = :is_data[9],
								    updt_user     = :gs_user_id
							 WHERE customerid    = :ls_payid  ;
							  
							If SQLCA.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #4")
								FileClose(li_filenum)	
			               ii_rc = -1			
								Return
							End If
											  							  							  
						Else                   			//신규,해지신청
							
							If ls_bil_drawingtype = "02" Then 
								UPDATE billinginfo 
								   SET pay_method     = :ls_paymethod, 
								       bilcycle       = :ls_bilcycle, 
								       drawingresult  = :ls_reqyn, 
								       resultcod      = :ls_errorcode, 
									    receiptdt      = :ls_cmsacpdt,
									    pgm_id         = :is_data[9],
									    updt_user      = :gs_user_id
								 WHERE customerid     = :ls_payid;
							End If
							  
							If SQLCA.sqlcode < 0 Then
								f_msg_sql_err(is_title, is_caller + ": UPDATE billinginfo #5")
								FileClose(li_filenum)	
			               ii_rc = -1			
								Return
							End If											  					  							  							  
						End If						
					End If
			End Choose
			
			//Bankreq Insert GR22 파일로 생성한다.
		  Insert into bankreq
		  (file_name, receiptdt, prcno, worktype, drawingreqdt, drawingtype,
			reqtype,payid, bank, acctno, acct_owner, acct_ssno, receiptcod,
			result_code, error_code, receiptno)
		  values
		  (:is_data[2], to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ls_prcno,
			:is_data[3], to_date(:ls_drawingreqdt,'yyyy-mm-dd'),
			:ls_drawingtype, :ls_drawingtype, :ls_payid, :ls_bank, :ls_acctno, :ls_name, :ls_acct_ssno, :ls_receiptcod,
			:ls_resultcode, :ls_errorcode, :ls_receiptno);
		  
			If SQLCA.SQLCode < 0 Then
				FileClose(li_FileNum)
				f_msg_sql_err(is_title, is_caller + " Insert Error(bankreq) #1")
			   ii_rc = -1
				return 
			End If
			
	  End If
  Loop
	 //File Close
	 FileClose(li_FileNum)
	  
			
	//3.bankreqstus Insert
	//파일상태는 응답확인 
	Insert into bankreqstatus
	(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
	crt_user, updt_user, crtdt, updtdt, pgm_id, resultprcdt, errcnt) 
	VALUES
	(:is_data[3], :is_data[2], to_date(:ls_cmsacpdt,'yyyy-mm-dd'), :ll_reqcnt, :ls_status[3], sysdate,
	 :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[1], sysdate, :ll_errcnt);
			
	// Rollback
	If SQLCA.SQLCode < 0 Then
		FileClose(li_FileNum)						
		f_msg_sql_err(is_Title, " Insert Error(bankreqstatus) #1")
	   ii_rc = -1
		return 
	End If
	
	ii_rc = ll_reqcnt  //총레코드 건수 넣음
	
End Choose
end subroutine

on b7u_dbmgr3_naray.create
call super::create
end on

on b7u_dbmgr3_naray.destroy
call super::destroy
end on

