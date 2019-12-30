$PBExportHeader$b7u_dbmgr3.sru
$PBExportComments$[ceusee] 자동이체(EDI)처리
forward
global type b7u_dbmgr3 from u_cust_a_db
end type
end forward

global type b7u_dbmgr3 from u_cust_a_db
end type
global b7u_dbmgr3 b7u_dbmgr3

type variables
String is_cmsacpdt, is_filename
end variables

forward prototypes
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db ()
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

		Commit;
End Choose
ii_rc = 0 
				
end subroutine

public subroutine uf_prc_db_02 ();Integer li_FileNum
Long ll_bytes_read, ll_FLength
String ls_buffer, ls_recordtype
String ls_error_code, ls_file_name, ls_receiptdt, ls_prcno, ls_payid, ls_result_code
String ls_drawingresult, ls_drawingresults[]
String ls_temp, ls_ref_desc, ls_status[]
Integer li_return, li_cnt, li_errcnt_T, li_errcnt_P
String ls_erramt, ls_trdt
date ld_trdt
Dec lc_erramt, lc_erramt_T, lc_erramt_P

ii_rc = -1

Choose Case is_caller
	Case "EDI GR20%FileRead"
	//** is_data[1] : pathname, is_data[2] : filename, 
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
		
		Constant Integer EA20_Size = 150
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(10001, is_Title, is_data[1])
			FileClose(li_filenum)
			Return
		End If

		// Status : sysctl1t
		ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
		
		//Billing 신청 결과 코드
		ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults[])
		
		
				
		Do While(true)
			//File Read
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > EA20_Size Then
				FileSeek(li_FileNum, EA20_Size - ll_bytes_read, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, EA20_Size)
			ls_recordtype = LeftA(ls_buffer, 2)
			
			Choose Case ls_recordtype
				Case '63' 
					ls_payid = Trim(MidA(ls_buffer, 40 ,20))
               ls_error_code = Trim(MidA(ls_buffer, 115, 2))

					// Update BankReq Of Error Case
					Update bankreq
					SET result_code = 'N', error_code = :ls_error_code
					WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4]
					AND payid = :ls_payid;
					
					// Rollback
					If SQLCA.SQLCode < 0 Then
						FileClose(li_FileNum)						
						f_msg_sql_err(is_Title, "Update Error(Bankreq)")
						Rollback;
						return 
					End If
					
			End Choose
		Loop
		
		//File Close
		FileClose(li_FileNum)
		
		// Error Counts
		SELECT count(*)
		INTO :li_cnt
		FROM bankreq
		WHERE file_name = :is_data[3] AND to_char(receiptdt, 'yyyymmdd') = :is_data[4]
		AND result_code = 'N';

		// Update BankReqStatus
		//신청을 응답확인으로 Update
		Update bankreqstatus
		SET status = :ls_status[3],
			 resultprcdt = sysdate, errcnt = :li_cnt, updt_user = :is_data[5], updtdt = sysdate
		WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4] and status =:ls_status[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, " Update Error(BankReqStatus)")
			Rollback;
			Return
		End If
				 
		//고객을 성공 실패 확정 짖는다.
		DECLARE cur_bankreq CURSOR FOR
		SELECT payid, result_code, error_code
  		 FROM bankreq
		WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4];
		
		OPEN cur_bankreq;
		Do While (True)
			FETCH cur_bankreq
			INTO :ls_payid, :ls_result_code, :ls_error_code;
			
			If SQLCA.sqlcode < 0 Then
				CLOSE cur_bankreq;				
				f_msg_sql_err(is_title, "Cursor bankreq")
				Return				
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			If ls_result_code = "N" Then 
				ls_drawingresult = ls_drawingresults[5]	//실패
			Else 
				ls_drawingresult = ls_drawingresults[4]	//성공
				ls_error_code = '00'  //정상처리
			End If
		  
		   //처리중인 고객을 처리성공, 실패로 Update
			Update billinginfo
			SET drawingresult = :ls_drawingresult, resultcod = :ls_error_code,
			    updt_user = :is_data[5], updtdt = sysdate, pgm_id =:gs_pgm_id[1]
			WHERE drawingresult = :ls_drawingresults[3] AND customerid = :ls_payid;
			
			If SQLCA.SQLCode < 0 Then
				CLOSE cur_bankreq;				
				f_msg_sql_err(is_Title, "Update Error(Billinginfo)")
				Rollback;
				Return				
			End If
			
			Update bankreq
				SET error_code = :ls_error_code
			   WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4]
				AND payid = :ls_payid;
			
		Loop
		
		CLOSE cur_bankreq;
		
		Commit;
End Choose
ii_rc = 0
Return
end subroutine

public subroutine uf_prc_db_01 ();
//공통
Long ll_rows
String ls_file_name, ls_reqtype, ls_ref_desc, ls_temp
String ls_payid, ls_cmsacpdt
String  ls_acct_owner, ls_acct_ssno, ls_acctno,ls_bank_code

//"Bankreqgr22%ue_save"
String ls_reqdt
Long  ll_cancel, ll_change
String ls_data_seq
Long   ll_data_seq, ll_row


//"Bankreqgr22%ue_filewrite"
String ls_buffer, ls_filename
Long ll_bytes, ll_cnt, ll_cancelcnt, ll_newcnt, ll_chgcnt, ll_bcancelcnt
Int li_filenum, li_write_bytes, li_return
String ls_header, ls_seqno,  ls_filter
String ls_prcno, ls_receiptdt, ls_drawingtype_1, ls_outtype
String ls_drawingreqdt, ls_receiptcod, ls_maincod[], ls_datacod[], ls_drawingtype[]
String ls_resultcod, ls_bil_payid, ls_bil_acctno, ls_bil_drawingtype, ls_bil_drawingresult, ls_bef_payid
String ls_phone, ls_code, ls_drawingresult, ls_result

	
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
//
		ll_data_seq = 0	
		
		//File Name
		ls_file_name = is_data[1]
		//CMS 신청접수일
		ls_cmsacpdt  = is_data[4]
				
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
			ls_acctno = Trim(idw_data[1].Object.acctno[ll_row])
			ls_acct_owner = Trim(idw_data[1].Object.acct_owner[ll_row])
			ls_acct_ssno = Trim(idw_data[1].Object.acct_ssno[ll_row])
			ll_data_seq = ll_data_seq + 1
			ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)
			
			
			//###출금이체신청 Table에 추가
			//1.신규, 변경, 해지 신청 코드를 그대로 사용하면 된다.
			INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_reqtype,:ls_payid,
				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:is_data[5]);

			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, " Insert Error(bankreq)")
				ROLLBACK;
				Return
			End If
			
			
			//2.billinginfo 처리중 Update
			UPDATE billinginfo
			SET drawingresult = :is_data[7],
				receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd'),
				updtdt = sysdate,
				updt_user = :gs_user_id,
				pgm_id = :is_data[9]				
			WHERE customerid = :ls_payid ;
			
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "Update Error(billinginfo)")
				ROLLBACK;
				Return
			End If
		
		Next
		
		//3.출금이체신청처리상태(BankReqstatus) Table에 Insert
		//미처리로 만든다.
		INSERT INTO bankreqstatus
		(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
		 crt_user, updt_user, crtdt, updtdt, pgm_id) 
		VALUES
		(:is_data[3],:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ll_data_seq,:is_data[6],sysdate,
		 :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[9]);
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(bankreqstatus)")
			ROLLBACK;
			Return
		End If
		
	Case "EDI GR22%FilseWrite"	
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea13%ue_filewrite"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			        //filename
//		lu_dbmgr.is_data[2] = is_filepath			    //filepath
//		lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형)
//		lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
//		lu_dbmgr.is_data[5] = is_coid			          //기관식별코드
//		lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[7] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
//		lu_dbmgr.is_data[8] = is_coname                 //이용기간명
//                          is_bankreqstatus[3]
//		lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid

		ll_bytes = 0
		li_write_bytes = 0
		ll_cnt = 0
		ll_chgcnt = 0
		ll_newcnt = 0
		ll_cancelcnt = 0 
		
		
		//이용기간 신청 유형
		ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_maincod[])
		
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
		  AND a.receiptdt = b.receiptdt
		  AND b.file_name = :is_data[1]
		  AND to_char(b.receiptdt,'yyyymmdd') = :is_data[4]
		  AND b.worktype = :is_data[3]
		  AND b.status = :is_data[6]   //미처리인 작업상태
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
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   
			//변경이면
			If ls_reqtype = ls_maincod[3] Then
					  ls_bef_payid = ls_payid
			Else
					  ls_bef_payid = ""
			End If
			
		  
		  //오류 파일만 보낸다. 
		  If ls_resultcod = "" Then 
			ll_cnt++
			
			IF ls_reqtype = ls_maincod[2]  THEN                                   //신규
				ll_newcnt++
			ELSEIF ls_reqtype = ls_maincod[3] THEN  //변경
			   ll_chgcnt++
			ELSEIF ls_reqtype = ls_maincod[4] or ls_reqtype = ls_maincod[5] Then                                    //해지
				ll_cancelcnt++
			END IF
		  
		  
			
			//Data Record
			ls_buffer  = ls_datacod[2]                        //Data 구분 코드
			ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)   //일련번호
			ls_buffer += ls_drawingreqdt                      //신청일자
		   ls_buffer += ls_reqtype                           //신청 구분
			ls_buffer += fs_fill_spaces(ls_bef_payid,20)       //변경전 납부자 번호
			ls_buffer += fs_fill_spaces(ls_payid, 20)         //납부자 번호
			ls_buffer += '00'                                 //납부희망일
			ls_buffer += '00'                                 //요금종류
			ls_buffer += fs_fill_zeroes(ls_bank_code, 6)      //은행점 코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)        //지정출금계좌번호
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)     //주민등번호
			
			Select replace(a.phone1,'-','') into :ls_phone from customerm a, billinginfo b where a.customerid = b.customerid
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
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
		  End IF
		Loop
		Close cur_read_bankreq;
		
		// Trailer Record
		ls_buffer = ls_datacod[3]                             //Date 구분코드
		ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)       //레코드수
		ls_buffer += fs_fill_zeroes("0", -7)                  //은행접수
		ls_buffer += fs_fill_zeroes("0", -7)                  //은행접수 해지
		ls_buffer += fs_fill_zeroes("0", -7)                  //은행변경
		ls_buffer += fs_fill_zeroes("0", -7)                  //은행임의 해지
		ls_buffer += fs_fill_zeroes("0", -7)                  //은행임의 변경
		ls_buffer += fs_fill_zeroes(String(ll_newcnt), -7)    //신규
		ls_buffer += fs_fill_zeroes(String(ll_cancelcnt), -7) //해지
		ls_buffer += fs_fill_zeroes("0", -7)                  //해지임의
		ls_buffer += fs_fill_zeroes(String(ll_chgcnt), -7)    //신규
		ls_buffer += Space(78)
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		FileClose(li_filenum)
		
		//1.bankreqstatus UPDATE
		//GR22
	  UPDATE bankreqstatus
		SET status = :is_data[7],
			crt_user = :gs_user_id,
			updt_user = :gs_user_id,
			crtdt = sysdate,
			updtdt = sysdate,
			pgm_id = :is_data[10]		 
		WHERE worktype = :is_data[3]
		  AND file_name= :is_data[1]
		  AND status = :is_data[6];
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, "Update Error2(bankreqstatus)")
			Return 
		End If
	
		ii_rc = ll_cnt	
		commit;
		Return
End Choose


ii_rc = 0 

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
Long ll_bytes, ll_cancelcnt
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
	//lu_dbmgr.is_data[9] = is_mintramt				//최소출금액
	//lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid
	//lu_dbmgr.is_data[11] = is_pay_method            //결재방법(자동이체)
	//lu_dbmgr.is_data[12] = is_table 			    //reqinfo, reqinfoh (table명)

		ll_data_seq = 0
		ldc_sum_tramt = 0
		ll_cnt = 0
		
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
		SELECT bankshop,bank,acctno,acct_ssno,payid,currency_type
		  FROM reqinfo
		WHERE to_char(trdt,'yyyymmdd') = :is_data[3]
		  AND chargedt = :is_data[4]
		  AND pay_method = :is_data[11]
		ORDER BY payid;
		
		OPEN cur_read_reqinfo;
		Do While (True)
			Fetch cur_read_reqinfo
			Into :ls_bankshop, :ls_bank, :ls_acctno,
				 :ls_acct_ssno, :ls_payid, :ls_currency_type;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_reqinfo;
				f_msg_sql_err(is_Title, " Select Error(reqinfo)")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		    End If
		   
		    ldc_tramt = 0
			
			Select nvl(sum(nvl(tramt,0)),0)
			  into :ldc_tramt
			 From reqdtl
			Where to_char(trdt,'yyyymmdd') <= :is_data[3]
			  And payid = :ls_payid;	  
			   
			If SQLCA.SQLCode < 0 Then
				Close cur_read_reqinfo;
				f_msg_sql_err(is_Title, " Select Error(reqdtl)")
				ii_rc = -1
				Return 
			ElseIf sqlca.sqlcode = 100 Then
				continue
			End If
			   
			//최소의뢰금액보다 작으면 의뢰처리 않는다.   
		 If ldc_tramt < dec(is_data[9]) Then continue
			   
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
//		lu_dbmgr.is_data[1] = is_filenm			        //filename
//		lu_dbmgr.is_data[2] = is_filepath			    //filepath
//		lu_dbmgr.is_data[3] = ls_outdt		    		//출금의뢰일자
//		lu_dbmgr.is_data[4] = is_bank[1]			    //입금은행
//		lu_dbmgr.is_data[5] = is_bank[2]			    //입금계좌번호
//		lu_dbmgr.is_data[6] = is_coid			        //기관식별코드
//		lu_dbmgr.is_data[7] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[8] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
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
		ls_ref_desc = ""
		ls_receptcod = fs_get_control("B7", "A604", ls_ref_desc)
		
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
			Into :ls_file_name, :ls_prcno, :ls_payid,
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
		   
			//Data Record
			ls_buffer = ls_datacode[2]                   //Data Record
			ls_buffer += fs_fill_zeroes(ls_prcno, -7)    //일련번호
			ls_buffer += fs_fill_spaces(ls_payid,20)     //납부자 번호
			ls_buffer += fs_fill_zeroes(ls_bank_code, 2) //은행코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)   //계좌번호
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
		WHERE  file_name = :is_data[1]
		  AND to_char(outdt,'yyyymmdd') = :is_data[3]
		  AND bil_status = :is_data[7];
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, " Update Error(banktext)")
			ii_rc = -1
			Return 
		End If
	
		//banktextstatus UPDATE
		UPDATE banktextstatus
 		 SET status = :is_data[8],
			 crt_user = :gs_user_id,
			 updt_user = :gs_user_id,
			 crtdt = sysdate,
			 updtdt = sysdate,
			 pgm_id = :is_data[9]		 
		WHERE file_name= :is_data[1]
		  AND status = :is_data[7];
		  
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, " Update Error(banktextstatus)")
			ii_rc = -1
			Return 
		End If
		
		ii_rc = ll_cnt		
		commit;
		Return 
	Case "GR24%FileWrite"
		Constant Integer	GR24_SIZE = 150
		String   ls_todate, ls_head, ls_cent, ls_tail
		ll_bytes = 0
		li_write_bytes = 0
		ll_cnt = 0
		
		ll_bytes += li_write_bytes		
		
		// File Open
	   ls_filename = is_data[1] + is_data[2]+'.TXT'
		li_filenum = FileOpen(ls_filename, LineMode!, Write!, LockReadWrite!, Replace!)	
		If IsNull(li_filenum) Then li_filenum = -1
		If li_filenum < 0 Then 	
			f_msg_usr_err(1001, is_Title, ls_file_name)			
			FileClose(li_filenum)
			ii_rc = -3
			Return 
		End If
		
		//Data Record
		DECLARE cur_read_VALIDKEY CURSOR FOR
			SELECT VALIDKEY
			  FROM CUSTOMERINFO_REQ
			 WHERE LINKPARTNER = :is_data[3]
			   AND WORKNO      = :is_data[4]
			Order by VALIDKEY;
			
		OPEN cur_read_VALIDKEY;
		Do While (True)
			Fetch cur_read_VALIDKEY
			Into :ls_validkey;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_VALIDKEY;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, " Select Error(CUSTOMERINFO_REQ)")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
			
			ls_todate = string(today(),'yymmdd')
			
//		   IF left(ls_validkey,2) = '02' THEN
//				If len(ls_validkey) = 9 Then
//					ls_validkey = '00020'+mid(ls_validkey,3,7)+ls_todate+is_data[5]
//				Else
//					ls_validkey = '0002'+mid(ls_validkey,3,8)+ls_todate+is_data[5]
//				End If
//			ELSE
//				If len(ls_validkey) = 10 Then
//					ls_validkey = '0'+left(ls_validkey,3)+'0'+mid(ls_validkey,4,7)+ls_todate+is_data[5]
//				Else
//					ls_validkey = '0'+left(ls_validkey,3)+mid(ls_validkey,4,8)+ls_todate+is_data[5]
//				End If
//			END IF
			
		   IF LeftA(ls_validkey,2) = '02' THEN
				ls_head = '0002'
			   ls_cent = fs_fill_zeroes(MidA(ls_validkey,3,LenA(ls_validkey) - 6),-4)
			Else
				ls_head = '0'+LeftA(ls_validkey,3)
			   ls_cent = fs_fill_zeroes(MidA(ls_validkey,4,LenA(ls_validkey) - 7),-4)
			End If
			ls_tail = RightA(ls_validkey,4)
			ls_validkey = ls_head + ls_cent + ls_tail + ls_todate + is_data[5]
			
			//Data Record
			ls_buffer = ''                   //Data Record
			ls_buffer += ls_validkey    //ls_validkey
					
			li_write_bytes = FileWrite(li_filenum, ls_buffer)   
			If li_write_bytes < 0 Then
				FileClose(li_filenum)
				Close cur_read_VALIDKEY;
				f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
			ll_cnt++
			ldc_sum_tramt += Dec(ls_reqamt)
			
		Loop
		Close cur_read_VALIDKEY;
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Fail! (Trailer Record)")
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		ll_bytes += li_write_bytes

		FileClose(li_filenum)
      is_filename = ls_filename
		ii_rc = ll_cnt		
		commit;
		Return 
			
End Choose

ii_rc = 0 

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

			ls_drawingreqdt = Trim(MidA(ls_buffer,10,8))  //신청일자(고객이 신청한 날짜)
			ls_drawingtype = Trim(MidA(ls_buffer, 18,2))  //신청 구분 코드
			ls_payid = Trim(MidA(ls_buffer, 40 ,20))      //납부자 번호
//Start 2004.06.28. khpark modify 은행납부자계좌개설점코드(은행코드2자리 + 개설점코드4자리) 6자리 
			ls_bank = Trim(MidA(ls_buffer, 64, 2) )       //은행코드(앞자리2자리)
			ls_bank_code = Trim(MidA(ls_buffer, 64, 6) )  //은행+납부자계좌개설점코드
//End  2004.06.28.  khpark modify 
			ls_acctno = Trim(MidA(ls_buffer, 70, 15))     //계좌번호
			ls_acct_ssno = Trim(MidA(ls_buffer, 85, 13))  //주민등록 번호
			ls_prcno = Trim(MidA(ls_buffer,3,7))
			//Start 2005-10-11 kem modify 접수처구분코드(전자접수구분 관련)
			ls_receiptcod = Trim(MidA(ls_buffer,121,1))         //접수처구분코드
			//End   2005-10-11 kem modify
			ls_receiptno = Trim(MidA(ls_buffer,122,9))		//전자접수번호 jjuhm add
			ls_name = Trim(MidA(ls_buffer,131,16))
			ls_errorcode = ""
			
			  ls_bil_payid = ""
			  ls_bil_drawingtype = ""
			  ls_bil_acctno = ""
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
					acctno = :ls_acctno, receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd'), pay_method = nvl(:ls_paymethod,pay_method),
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
			ls_buffer += fs_fill_spaces(ls_payid, 20)         //납부자 번호
			ls_buffer += '00'                                 //납부희망일
			ls_buffer += '00'                                 //요금종류
			ls_buffer += fs_fill_zeroes(ls_bank, 6)           //은행점 코드
			ls_buffer += fs_fill_spaces(ls_acctno, 15)        //지정출금계좌번호
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)     //주민등번호
			
			Select replace(a.phone1,'-','') into :ls_phone from customerm a, billinginfo b where a.customerid = b.customerid
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

on b7u_dbmgr3.create
call super::create
end on

on b7u_dbmgr3.destroy
call super::destroy
end on

