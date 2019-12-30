$PBExportHeader$b7u_dbmgr.sru
$PBExportComments$[parkh] 출금이체/의뢰신청 dbmgr
forward
global type b7u_dbmgr from u_cust_a_db
end type
end forward

global type b7u_dbmgr from u_cust_a_db
end type
global b7u_dbmgr b7u_dbmgr

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();// 작성자 : parkkh
// 작성일자 : 2003.06.27.
// 목  적 : 출금 의뢰 신청 저장/파일 생성

Long ll_rows, ll_newcnt, ll_cnt
String ls_file_name, ls_reqtype, ls_ref_desc, ls_temp
String ls_payid, ls_cmsacpdt
String  ls_acct_owner, ls_acct_ssno, ls_acctno,ls_bank_code

//"Bankreqea21%ue_save"
String ls_outdt, ls_trcod[], ls_bankshop, ls_bank, ls_currency_type
String ls_data_seq, ls_sql
Long   ll_data_seq
decimal{0} ldc_sum_tramt, ldc_tramt

//"Bankreqea21%ue_filewrite"
String ls_buffer, ls_filename
Long ll_bytes, ll_cancelcnt
Int li_filenum, li_write_bytes, li_return
String ls_header, ls_seqno,  ls_filter, ls_reqamt, ls_outtype, ls_remark
String ls_prcno, ls_jubank, ls_juacctno
	
ii_rc = -1

//지로 처리된 파일을 해당 Table에 Insert 한다.
Choose Case is_caller
	Case "Bankreqea21%ue_save"
//		//출금의뢰신청처리
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea21%ue_save"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			        //filename
//		lu_dbmgr.is_data[2] = ls_outdt   			    //출금일자
//		lu_dbmgr.is_data[3] = ls_trdt   			    //입력한 청구기준일
//		lu_dbmgr.is_data[4] = ls_chargedt   			//청구주기
//		lu_dbmgr.is_data[5] = is_remark		    		//통장기재내용
//		lu_dbmgr.is_data[6] = is_outtype			    //출금형태
//		lu_dbmgr.is_data[7] = is_pay_type[3]            //입금유형(자동이체)
//		lu_dbmgr.is_data[8] = is_bankreqstatus[1]       //출금의뢰신청 작업상태(미처리)
//		lu_dbmgr.is_data[9] = is_mintramt				//최소출금액
//		lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid
//		lu_dbmgr.is_data[11] = is_pay_method            //결재방법(자동이체)
//		lu_dbmgr.is_data[12] = is_table 			    //reqinfo, reqinfoh (table명)

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

//동적으로 reqinfo  table이 바뀌는 script
//		ls_sql	= " SELECT bankshop,bank,acctno,acct_ssno,payid,currency_type " + &
//		          "  FROM " + is_data[12]  + &
//				  "	WHERE to_char(trdt,'yyyymmdd') = '"+ is_data[3] + "'" + &
//				  "   AND chargedt = '" + is_data[4] + "'" + &
//				  "	  AND pay_method = '" + is_data[11] + "'" + &
//				  "	ORDER BY payid "
//					 
//		DECLARE cur_read_reqinfo DYNAMIC CURSOR FOR SQLSA;
//		PREPARE SQLSA FROM :ls_sql;
//		OPEN DYNAMIC cur_read_reqinfo;
//		
//		If  sqlca.sqlcode = -1 Then
//			 clipboard(ls_sql)	 
//			 f_msg_sql_err(is_title, is_caller + " : cur_read_reqinfo")
//			 Close cur_read_reqinfo;
//			 Return 
//		End If
		
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
				f_msg_sql_err(is_Title, "select reqinfo")
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
				f_msg_sql_err(is_Title, "select sum(tramt) reqdtl")
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
				f_msg_sql_err(is_Title, "insert banktext")
				ROLLBACK;
				ii_rc = -1
				Return
			End If

			ll_cnt ++ 
			ldc_sum_tramt += ldc_tramt			
			
		Loop
		Close cur_read_reqinfo;
			
		//2.출금의뢰신청처리상태(BankTextstatus) Table에 Insert
		INSERT INTO banktextstatus
		(file_name,outdt,reqcnt,reqamt,status,reqprcdt, 
		 crt_user, updt_user, crtdt, updtdt, pgm_id) 
		VALUES
		(:ls_file_name,to_date(:ls_outdt,'yyyy-mm-dd'),:ll_cnt,:ldc_sum_tramt,:is_data[8],sysdate,
		 :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[10]);
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "insert bankreqstatus")
			ROLLBACK;
			ii_rc = -1
			Return
		End If
		
	Case "Bankreqea21%ue_filewrite"		
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

		Constant Integer	EA13_SIZE = 100
		
		ll_bytes = 0
		li_write_bytes = 0
		ll_cnt = 0
		
		//1.Header Record
		ls_header = "H"
		ls_seqno = "0000000"
		ls_file_name = is_data[1]
		ls_outdt = MidA(is_data[3], 3, 6)   //출금일자(yymmdd)
		ls_jubank = fs_fill_spaces(is_data[4], 6)
		ls_juacctno = fs_fill_spaces(is_data[5], 16)
		ls_filter = Space(66)
		
		ls_buffer  = ""
		ls_buffer += ls_header +  ls_seqno + is_data[6]
		ls_buffer += ls_file_name + ls_outdt 
		ls_buffer += ls_jubank + ls_juacctno + ls_filter
		
		// File Open
		ls_filename = is_data[2] + is_data[1]
		li_filenum = FileOpen(ls_filename, StreamMode!, Write!, LockReadWrite!, Replace!)	
		If IsNull(li_filenum) Then li_filenum = -1
		If li_filenum < 0 Then 	
			f_msg_usr_err(9000, is_Title, "File Open Failed!")			
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
			   a.acct_ssno, a.out_type, a.remark
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
				 :ls_acct_ssno, :ls_outtype, :ls_remark;
				 
			If SQLCA.SQLCode < 0 Then
				Close cur_read_banktext;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "select banktext")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   
			ls_buffer  = "R"
			ls_buffer += fs_fill_zeroes(ls_prcno, -7)
			ls_buffer += is_data[6]    
			ls_buffer += fs_fill_zeroes(ls_bank_code, 6)
			ls_buffer += fs_fill_spaces(ls_acctno, 16)
			ls_buffer += fs_fill_zeroes(ls_reqamt, -13)
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 13)
			ls_buffer += Space(1)
			ls_buffer += Space(4)
			ls_buffer += fs_fill_spaces(ls_remark, 16)
			ls_buffer += Space(2)
			ls_buffer += fs_fill_spaces(ls_payid, 20)
			ls_buffer += Space(5)
			ls_buffer += ls_outtype
			ls_buffer += Space(5) 
			
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
		ls_buffer = "T"
		ls_buffer += "9999999"
		ls_buffer += is_data[6]
		ls_buffer += ls_file_name
		ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)
		ls_buffer += fs_fill_zeroes(String(ll_cnt), -7)
		ls_buffer += fs_fill_zeroes(String(ldc_sum_tramt), -13)
		ls_buffer += "0000000"
		ls_buffer += "0000000000000"
		ls_buffer += Space(37)
		ls_buffer += Space(10)
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Fail! (Trailer Record)")
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		ll_bytes += li_write_bytes

		FileClose(li_filenum)
		
		UPDATE banktext
		   SET bil_status = :is_data[8]
		WHERE  file_name = :is_data[1]
		  AND to_char(outdt,'yyyymmdd') = :is_data[3]
		  AND bil_status = :is_data[7];
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, "update banktext (bil_status)")
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
			f_msg_sql_err(is_Title, "update banktextstatus")
			ii_rc = -1
			Return 
		End If
		
		ii_rc = ll_cnt		
		Return 
			
End Choose

ii_rc = 0 

Return
end subroutine

public subroutine uf_prc_db ();
// 작성자 : parkkh
// 작성일자 : 2003.06.24.
// 목  적 : 출금 이체 신청 저장  / 파일 생성
//			"Bankreqea13%ue_save"/"Bankreqea13%ue_save"

//공통
Long ll_rows, ll_newcnt
String ls_file_name, ls_reqtype, ls_ref_desc, ls_temp
String ls_payid, ls_cmsacpdt
String  ls_acct_owner, ls_acct_ssno, ls_acctno,ls_bank_code

//"Bankreqea13%ue_save"
String ls_reqdt
Long  ll_cancel1cnt
String ls_data_seq
Long   ll_data_seq, ll_row
String ls_bef_bank_code, ls_bef_acctno, ls_bef_acct_ssno, ls_bef_acct_owner
String ls_drawingtype[]

//"Bankreqea13%ue_save"
String ls_buffer, ls_filename
Long ll_bytes, ll_cnt, ll_cancelcnt
Int li_filenum, li_write_bytes, li_return
String ls_header, ls_seqno,  ls_filter
String ls_prcno, ls_receiptdt, ls_drawingtype_1, ls_outtype
String ls_drawingreqdt, ls_receiptcod, ls_drawingtype_cod[]
	
ii_rc = -1

//지로 처리된 파일을 해당 Table에 Insert 한다.
Choose Case is_caller
	Case "Bankreqea13%ue_save"
//		//출금이체신청처리
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea13%ue_save"
//		lu_dbmgr.idw_data[1] = idw_data[1]
//		lu_dbmgr.is_data[1] = is_filenm      			//filenm
//		lu_dbmgr.is_data[2] = is_filepath			    //filepath
//		lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형:이용기관)
//		lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
//		lu_dbmgr.is_data[5] = is_receiptcod[2]          //접수처
//		lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[7] = is_drawingresult[3]       //출금이체신청결과(처리중)
//		lu_dbmgr.is_data[8] = gs_pgm_id[gi_open_win_no]  //pgmid

		ll_newcnt = 0
		ll_cancel1cnt = 0
		ll_data_seq = 0
		
		//File Name
		ls_file_name = is_data[1]
		//CMS 신청접수일
		ls_cmsacpdt  = is_data[4]
				
		ll_rows = idw_data[1].RowCount()
			
		//출금이체 신청유형
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingtype[])

		For ll_row = 1 To ll_rows
			// CMS 신청 정보 Read
			ls_reqdt = string(idw_data[1].Object.drawingreqdt[ll_row],'yyyymmdd')
			ls_reqtype = Trim(idw_data[1].Object.drawingtype[ll_row])
			If ls_reqtype = "" Then 
				ii_rc = -2
				Return
			End If
			
			IF(ls_reqtype = ls_drawingtype[2]) THEN//신규
				ll_newcnt++
			ELSEIF(ls_reqtype = ls_drawingtype[4]) THEN//해지
				ll_cancel1cnt++
			ELSEIF(ls_reqtype = ls_drawingtype[3]) THEN//변경(해지+신규)
				ll_cancel1cnt++	
				ll_newcnt++
			END IF
			
			ls_payid = Trim(idw_data[1].Object.customerid[ll_row])
			ls_bank_code = Trim(idw_data[1].Object.bank[ll_row])
			If IsNull(ls_bank_code) Then ls_bank_code = ""
			If ls_bank_code = "" Then 
				f_msg_usr_err(1100, is_Title, "bank code 가 없는 고객이 있습니다. 다시 확인하시기 바랍니다.")
				ii_rc = -2
				Return
			End If
			ls_acctno = Trim(idw_data[1].Object.acctno[ll_row])
			ls_acct_owner = Trim(idw_data[1].Object.acct_owner[ll_row])
			ls_acct_ssno = Trim(idw_data[1].Object.acct_ssno[ll_row])
			ll_data_seq = ll_data_seq + 1
			ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)
			
			//###출금이체신청 Table에 추가
			//변경(해지+신규)신청
			IF(ls_reqtype = ls_drawingtype[3]) THEN
				//1.출금이체신청(BankReq) Table에 Insert
				
				//해지신청 정보
				SELECT bef_bank,bef_acctno,bef_acct_owner,bef_acct_ssno
				 INTO :ls_bef_bank_code,:ls_bef_acctno,:ls_bef_acct_owner,:ls_bef_acct_ssno
				 FROM billinginfo
				WHERE customerid = :ls_payid;
				
				//1.1해지정보 Insert
				INSERT INTO bankreq
				(file_name, receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name, to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_drawingtype[4],:ls_payid,
				 :ls_bef_bank_code,:ls_bef_acctno, :ls_bef_acct_owner,:ls_bef_acct_ssno,:is_data[5]);
				
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, "Insert bankreq (1-1)")
					ROLLBACK;
					ii_rc = -1
					Return
				End If
				
				ll_data_seq = ll_data_seq + 1
				ls_data_seq = fs_fill_zeroes(String(ll_data_seq), -7)
				
				//1.2신규정보 Insert
				INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_drawingtype[2],:ls_payid,
				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:is_data[5]);

			
				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, "insert bankreq (1-2)")
					ROLLBACK;
					ii_rc = -1
					Return
				End If
				
			//변경이외의 신청	
			ELSE
				//출금이체신청(BankReq) Table에 Insert
				INSERT INTO bankreq
				(file_name,receiptdt,prcno,worktype,
				 drawingreqdt,drawingtype,reqtype,payid,
				 bank,acctno,acct_owner,acct_ssno,receiptcod)
				VALUES
				(:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ls_data_seq,:is_data[3],
				 to_date(:ls_reqdt,'yyyy-mm-dd'),:ls_reqtype,:ls_reqtype,:ls_payid,
				 :ls_bank_code,:ls_acctno,:ls_acct_owner,:ls_acct_ssno,:is_data[5]);

				If SQLCA.sqlcode < 0 Then
					f_msg_sql_err(is_Title, "insert bankreq (2)")
					ROLLBACK;
					ii_rc = -1
					Return
				End If
			END IF
			
			//2.billinginfo 처리중 Update
			UPDATE billinginfo
			SET drawingresult = :is_data[7],
				receiptdt = to_date(:ls_cmsacpdt,'yyyy-mm-dd'),
				updtdt = sysdate,
				updt_user = :gs_user_id,
				pgm_id = :is_data[8]				
			WHERE customerid = :ls_payid ;
			
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_Title, "update billinginfo")
				ROLLBACK;
				ii_rc = -1
				Return
			End If
		
		Next
		
		//3.출금이체신청처리상태(BankReqstatus) Table에 Insert
		INSERT INTO bankreqstatus
		(worktype,file_name,receiptdt,reqcnt,status,reqprcdt,
		 crt_user, updt_user, crtdt, updtdt, pgm_id) 
		VALUES
		(:is_data[3],:ls_file_name,to_date(:ls_cmsacpdt,'yyyy-mm-dd'),:ll_data_seq,:is_data[6],sysdate,
		 :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[8]);
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_Title, "insert bankreqstatus")
			ROLLBACK;
			ii_rc = -1
			Return
		End If
		
	Case "Bankreqea13%ue_filewrite"		
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_caller = "Bankreqea13%ue_filewrite"
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_filenm			        //filename
//		lu_dbmgr.is_data[2] = is_filepath			    //filepath
//		lu_dbmgr.is_data[3] = is_worktype[2]		    //Worktype(작업유형)
//		lu_dbmgr.is_data[4] = ls_cmsacpdt			    //접수일자
//		lu_dbmgr.is_data[5] = is_coid			        //기관식별코드
//		lu_dbmgr.is_data[6] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
//		lu_dbmgr.is_data[7] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
//		lu_dbmgr.is_data[8] = gs_pgm_id[gi_open_win_no]  //pgmid		

		Constant Integer EA13_SIZE = 100
		
		ll_bytes = 0
		li_write_bytes = 0
		ll_cnt = 0
		
		//이체신청파일이름
		ls_ref_desc = ""
		ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then 
			ii_rc = -1
			Return 
		End if
		fi_cut_string(ls_temp, ";" , ls_drawingtype_cod[])

		//출금형태
		ls_ref_desc = ""
		ls_outtype = fs_get_control("B7", "A200", ls_ref_desc)
		If ls_outtype = "" Then 
			ii_rc = -1
			Return 
		End if
		
		//1.Header Record
		ls_header = "H"
		ls_seqno = "0000000"
		ls_cmsacpdt = MidA(is_data[4], 3, 6)   //신청접수일자(YYMMDD)
		ls_filter = Space(68)
		
		ls_buffer  = ""
		ls_buffer += ls_header +  ls_seqno + is_data[5]
		ls_buffer += is_data[1] + ls_cmsacpdt + ls_filter
		
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
		SELECT a.file_name, to_char(a.receiptdt,'yymmdd'), a.prcno,
			   to_char(a.drawingreqdt,'yymmdd'), a.drawingtype, a.reqtype, 
			   a.payid, a.bank, replace(a.acctno,'-',''), a.acct_owner, a.acct_ssno, a.receiptcod
		  FROM bankreq a, bankreqstatus b
		WHERE a.file_name = b.file_name
		  AND a.receiptdt = b.receiptdt
		  AND b.file_name = :is_data[1]
		  AND to_char(b.receiptdt,'yyyymmdd') = :is_data[4]
		  AND b.worktype = :is_data[3]
		  AND b.status = :is_data[6]
		Order by a.prcno;
		
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
				f_msg_sql_err(is_Title, "select bankreq")
				ii_rc = -1
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   
			IF(ls_reqtype = ls_drawingtype_cod[2]) THEN//신규
				ll_newcnt++
			ELSEIF(ls_reqtype = ls_drawingtype_cod[4]) THEN//해지
				ll_cancelcnt++
			END IF
			
			ls_buffer  = "R"
			ls_buffer += fs_fill_zeroes(ls_prcno, -7)
			ls_buffer += is_data[5]
			ls_buffer += ls_drawingreqdt
			ls_buffer += ls_reqtype
			ls_buffer += fs_fill_spaces(ls_payid, 20)
			ls_buffer += fs_fill_zeroes(ls_bank_code, 6)
			ls_buffer += fs_fill_spaces(ls_acctno, 16)
			ls_buffer += fs_fill_spaces(ls_acct_ssno, 16)
			ls_buffer += Space(4)
			ls_buffer += Space(2)
			ls_buffer += Space(1) + Space(4) + Space(6)
			
			li_write_bytes = FileWrite(li_filenum, ls_buffer)
			If li_write_bytes < 0 Then
				FileClose(li_filenum)
				Close cur_read_bankreq;
				ii_rc = -3
				Return 
			End If
			ll_bytes += li_write_bytes
			ll_cnt++
			
		Loop
		Close cur_read_bankreq;
		
		// Trailer Record
		ls_buffer = "T"
		ls_buffer += "9999999"
		ls_buffer += is_data[5]
		ls_buffer += is_data[1]
		ls_buffer += fs_fill_zeroes(string(ll_cnt), -7)      //총dtat record 수
		ls_buffer += fs_fill_zeroes(string(ll_newcnt), -7)   //신규건수
		ls_buffer += "0000000"				   //변경건
		ls_buffer += fs_fill_zeroes(string(ll_cancelcnt), -7)  //해지건수
		ls_buffer += "0000000"                //임의해지
		ls_buffer += Space(29)
		ls_buffer += Space(10)                //MAC 검증값
		
		li_write_bytes = FileWrite(li_filenum, ls_buffer)
		If li_write_bytes < 0 Then 
			FileClose(li_filenum)
			ii_rc = -3
			Return
		End If
		FileClose(li_filenum)
		
		//1.bankreqstatus UPDATE
		UPDATE bankreqstatus
		SET status = :is_data[7],
			crt_user = :gs_user_id,
			updt_user = :gs_user_id,
			crtdt = sysdate,
			updtdt = sysdate,
			pgm_id = :is_data[8]		 
		WHERE worktype = :is_data[3]
		  AND file_name= :is_data[1]
		  AND status = :is_data[6];
		
		If SQLCA.sqlcode < 0 Then
			ROLLBACK;
			f_msg_sql_err(is_Title, "update bankreqstatus")
			ii_rc = -1
			Return 
		End If
		
		ii_rc = ll_cnt		
		Return 
			
End Choose

ii_rc = 0 

Return
end subroutine

on b7u_dbmgr.create
call super::create
end on

on b7u_dbmgr.destroy
call super::destroy
end on

