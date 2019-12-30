$PBExportHeader$b7u_dbmgr1.sru
$PBExportComments$[jsha]
forward
global type b7u_dbmgr1 from u_cust_a_db
end type
end forward

global type b7u_dbmgr1 from u_cust_a_db
end type
global b7u_dbmgr1 b7u_dbmgr1

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Integer li_FileNum
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
	Case "b7w_reg_bankreq_ea14"
	//** is_data[1] : pathname, is_data[2] : filename, 
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
		
		Constant Integer EA14_Size = 100
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + is_data[1])
			FileClose(li_filenum)
			Return
		End If

		// Status : sysctl1t
		ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
				
		Do While(true)
			//File Read
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > EA14_SIZE Then
				FileSeek(li_FileNum, EA14_SIZE - ll_bytes_read, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, EA14_SIZE)
			ls_recordtype = LeftA(ls_buffer, 1)
			
			Choose Case ls_recordtype
				Case 'R'
					ls_error_code = Trim(MidA(ls_buffer, 91, 4))
					ls_prcno = Trim(MidA(ls_buffer, 2, 7))
					ls_payid = Trim(MidA(ls_buffer, 26 ,20))
					ls_result_code = Trim(MidA(ls_buffer, 90, 1))
									
					// Update BankReq Of Error Case
					Update bankreq
					SET result_code = 'N', error_code = :ls_error_code
					WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4]
					AND prcno = :ls_prcno AND payid = :ls_payid;
					
					// Rollback
					If SQLCA.SQLCode < 0 Then
						FileClose(li_FileNum)						
						f_msg_sql_err(is_Title, "ea14 : UPDATE bankreq : 2")
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
		Update bankreqstatus
		SET status = :ls_status[3],
			 resultprcdt = sysdate, errcnt = :li_cnt, updt_user = :is_data[5], updtdt = sysdate
		WHERE file_name = :is_data[3] AND to_char(receiptdt,'yyyymmdd') = :is_data[4];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "ea14 : UPDATE bankreqstatus : 1")
			Rollback;
			Return
		End If
						 
		// Update BillingInfo
		ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_drawingresults[])
		
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
			End If
		
			Update billinginfo
			SET drawingresult = :ls_drawingresult, resultcod = :ls_error_code,
			    updt_user = :is_data[5], updtdt = sysdate
			WHERE drawingresult = :ls_drawingresults[3] AND customerid = :ls_payid;
			
			If SQLCA.SQLCode < 0 Then
				CLOSE cur_bankreq;				
				f_msg_sql_err(is_Title, "ea14 : UPDATE billinginfo : 2")
				Rollback;
				Return				
			End If
		Loop
		
		CLOSE cur_bankreq;
		
		Commit;
	
	Case "b7w_reg_edigr22"
	//** is_data[1] : pathname, is_data[2] : filename,
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
		
		Constant Integer EA22_SIZE = 120
	
		//출금이체신청처리상태
		ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_status)
		
		li_FileNum = FileOpen(is_data[1], StreamMode!, Read!)
		// fileopen error
		If IsNull(li_FileNum) Then li_FileNum = -1
		If li_FileNum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + is_data[2])
			FileClose(li_filenum)
			Return
		End If
	
		Do While(True)
			ls_buffer = ""
			ll_bytes_read = FileRead(li_FileNum, ls_buffer)
			
			If ll_bytes_read < 0 Then Exit
			// File Pointer Move
			If ll_bytes_read > EA22_SIZE Then
				FileSeek(li_FileNum, EA22_SIZE - ll_bytes_read, FromCurrent!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, EA22_SIZE)
			ls_recordtype = LeftA(ls_buffer, 1)
			
			Choose Case ls_recordtype
				Case "H"
					ls_trdt = Trim(MidA(ls_buffer, 27, 6))
				    ls_trdt = LeftA(ls_trdt,2)+'-'+MidA(ls_trdt,3,2) +'-' + RightA(ls_trdt,2)
					ld_trdt = date(ls_trdt)
					
				Case "R"
					ls_result_code = Trim(MidA(ls_buffer, 67, 1))
					ls_error_code = Trim(MidA(ls_buffer, 68, 4))
					lc_erramt = Dec(Trim(MidA(ls_buffer, 41, 13)))
					ls_prcno = Trim(MidA(ls_buffer, 2, 7))
					ls_payid = Trim(MidA(ls_buffer, 89, 20))
					
					// Update BankText
					Update banktext
					SET result_code = :ls_result_code, error_code = :ls_error_code,
					    bil_status = :ls_status[3], transdt = :ld_trdt,
						erramt = :lc_erramt
					WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4]
					AND prcno = :ls_prcno AND payid = :ls_payid;
					
					// Error
					If SQLCA.SQLCode < 0 Then
						FileClose(li_filenum)
						f_msg_sql_err(is_Title, "EA22 ")
						Rollback;
						return
					End If
					
			End Choose
					
		Loop
		
		FileClose(li_FileNum)
		
		Update banktext
		SET bil_status = :ls_status[3], transdt = :ld_trdt
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4]
		AND bil_status = :ls_status[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "update banktext- bil_status")
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
			status = :ls_status[3], resultprcdt = sysdate, 
			updt_user = :is_data[5], updtdt = sysdate
		WHERE file_name = :is_data[3] AND to_char(outdt,'yyyymmdd') = :is_data[4];
		
		If SQLCA.SQLCode < 0 Then
			FileClose(li_filenum)
			f_msg_sql_err(is_Title, "EA22 ")
			Rollback;
			Return
		End If

		Commit;
				
End Choose

ii_rc = 0

Return
end subroutine

on b7u_dbmgr1.create
call super::create
end on

on b7u_dbmgr1.destroy
call super::destroy
end on

