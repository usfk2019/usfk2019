$PBExportHeader$b5u_1_dbmgr.sru
$PBExportComments$[juede] autoever billing detail 파일처리
forward
global type b5u_1_dbmgr from u_cust_a_db
end type
end forward

global type b5u_1_dbmgr from u_cust_a_db
end type
global b5u_1_dbmgr b5u_1_dbmgr

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Integer li_FileNum
Long ll_bytes_read, ll_FLength
String ls_buffer, ls_recordtype
String ls_error_code, ls_file_name, ls_receiptdt, ls_prcno, ls_result_code
String ls_drawingresult, ls_drawingresults[]
String ls_temp, ls_ref_desc, ls_infotype[]
Integer li_return, li_cnt, li_errcnt_T, li_errcnt_P
String ls_erramt, ls_trdt
date ld_trdt
Dec lc_erramt, lc_erramt_T, lc_erramt_P

String ls_intotype[]  //항목type
String ls_delimiter  //구분자
Int li_fileld , i,n, li_read_bytes
Long ll_fileRows
String  ls_record_row[], ls_record_column[], ls_record_first[]
Integer  li_validkey_seq , li_billdate_seq, li_amt_seq
String ls_groupcode,ls_customerid, ls_payid
String ls_itemcod, ls_trcod
Long ll_count , ll_count_amt
Long ll_amt_seq_a[], ll_amt
String ls_itemcod_a[] , ls_trcod_a[], ls_filename
ii_rc = -1

Choose Case is_caller
	Case "b5w_1_reg_billing_receipt"
	//** is_data[1] : pathname, is_data[2] : filename, 
	//** is_data[3] : 신청 filename, is_data[4] : 신청접수일자 **//
	//lu_dbmgr.is_data[1] = ls_filename
	//lu_dbmgr.is_data[2] = Trim(String(ld_outdt, 'yyyymmdd'))
	//lu_dbmgr.is_data[3] = gs_user_id
		
		
//		Constant Integer file_Size = 100
         ls_filename = is_data[1]
		//1.Start File Read  
		li_FileNum = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기

		If IsNull(li_FileNum) Then li_FileNum=-1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filename)
			FileClose(li_FileNum)
			Return 
		End If				
		

		// info type : sysctl1t  => 인증키; 청구일자;청구금액 (100;200;300)
		ls_temp = fs_get_control("B9", "B100", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_infotype)

		// delimiter : sysctl1t
		ls_delimiter = fs_get_control("B9", "B110", ls_ref_desc)

		ls_buffer = ""

		DO UNTIL( FileRead(li_FileNum,ls_buffer) = -100 )
//		DO UNTIL( FileRead(li_FileNum,ls_buffer) = 0)
				
				IF(ls_buffer <> "") THEN
							
     				li_return =fi_cut_string(ls_buffer, ls_delimiter, ls_record_first)
					
					ls_groupcode = ls_record_first[1]
					

					SELECT seq
					  INTO :li_validkey_seq
					  FROM tr_mapping_info
					 WHERE to_char(fromdt,'yyyymmdd')<=sysdate 
						AND  info_type=:ls_infotype[1]
						AND  upper(groupcod) = upper(:ls_groupcode);
				
				  SELECT seq
					 INTO :li_billdate_seq
					 FROM tr_mapping_info
				   WHERE  to_char(fromdt,'yyyymmdd')<=sysdate 
					  AND  info_type=:ls_infotype[2]
					  AND  upper(groupcod) =upper(:ls_groupcode);						  					  

					EXIT					
				 End If
			LOOP			
			
	   FileClose(li_FileNum)

					 
        	//Data Record
	     ll_count = 0
		DECLARE cur_read_mapping_info CURSOR FOR
		SELECT seq, itemcod, trcod
		  FROM tr_mapping_info
         WHERE to_char(fromdt,'yyyymmdd') <=sysdate
		   AND   info_type = :ls_infotype[3]
		   AND   upper(groupcod) = upper(:ls_groupcode)
		Order by seq;
		
		OPEN cur_read_mapping_info;
		Do While (True)
			Fetch cur_read_mapping_info
			Into :li_amt_seq, :ls_itemcod, :ls_trcod;		
			
			If SQLCA.SQLCode < 0 Then
				Close cur_read_mapping_info;
				f_msg_sql_err(is_Title, "Select Error(mapping info amount)")
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
		   End If
		   ll_count ++
			
		   ll_amt_seq_a[ll_count] = li_amt_seq
		   ls_itemcod_a[ll_count] = ls_itemcod
		   ls_trcod_a[ll_count] = ls_trcod
			
		Loop
		Close cur_read_mapping_info;			


		//1.Start File Read  
		li_FileNum = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기

		If IsNull(li_FileNum) Then li_FileNum=-1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filename)
			FileClose(li_FileNum)
			Return 
		End If				
		
		DO UNTIL( FileRead(li_FileNum,ls_buffer) = -100)
			
			
			
			IF(ls_buffer <> "") THEN
						
				li_return =fi_cut_string(ls_buffer, ls_delimiter, ls_record_column)		
				
				 SELECT customerid
					 INTO  :ls_customerid
					FROM validinfo
				 WHERE validkey = :ls_record_column[li_validkey_seq]
				   AND to_char(fromdt,'yyyymmdd') <= :ls_record_column[li_billdate_seq]
					AND decode(to_char(todt,'yyyymmdd'),null, to_char(to_date(:ls_record_column[li_billdate_seq]-1)))< :ls_record_column[li_billdate_seq];
				 
				 SELECT payid
				      INTO :ls_payid
					 FROM customerm
				  WHERE customerid=:ls_customerid;


				For ll_count_amt=1  to ll_count
					ll_amt = ll_amt_seq_a[ll_count_amt]
				
					INSERT INTO billing_receipt_detail(seq, groupcod, validkey, customerid, payid,
										saledt, trcod,itemcod, tramt, proc_yn,
										crt_user, crtdt, updt_user, updtdt, pgm_id)
					Values
					(seq_billing_receipt_detail.nextval,:ls_groupcode, :ls_record_column[li_validkey_seq], :ls_customerid, :ls_payid,
					 to_date(:ls_record_column[li_billdate_seq],'yyyymmdd'),  :ls_trcod_a[ll_count_amt], :ls_itemcod_a[ll_count_amt],
					 :ls_record_column[ll_amt], 'N', :gs_user_id, sysdate, :gs_user_id, sysdate,:gs_pgm_id[1]);

					ii_rc ++
					If SQLCA.SQLCode < 0 Then
						FileClose(li_FileNum)
						f_msg_sql_err( is_title, is_caller + " Insert Error(Billing receipt detail)")
						Rollback;
						return 
					End If								
				Next								
			End If
		LOOP			
			
	   FileClose(li_FileNum)
			
commit;
				
End Choose

//ii_rc = 0


Return
end subroutine

on b5u_1_dbmgr.create
call super::create
end on

on b5u_1_dbmgr.destroy
call super::destroy
end on

