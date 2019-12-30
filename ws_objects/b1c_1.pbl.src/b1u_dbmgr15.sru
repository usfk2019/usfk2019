$PBExportHeader$b1u_dbmgr15.sru
$PBExportComments$[kem] 고객정보수신 DB
forward
global type b1u_dbmgr15 from u_cust_a_db
end type
end forward

global type b1u_dbmgr15 from u_cust_a_db
end type
global b1u_dbmgr15 b1u_dbmgr15

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_01 ();// 공통 변수
String ls_sql

//file read-write
String ls_result[],ls_marknm
Long ll_count = 0
String ls_filenm, ls_codenm, ls_file
Int  li_rc
Long ll_filelen, ll_bytes = 0, ll_seq
Dec  lc_dong,lc_ho
//read
String ls_telno, ls_mannum, ls_reggu, ls_post, &
		 ls_addr, ls_addr2, ls_prcdt, ls_prcyn, &
		 ls_file_read,ls_result2, ls_temp, ls_ref_desc, &
		 ls_name[], ls_man, ls_bus, ls_comcd, ls_workmm, ls_accept
Integer li_filenum, li_read_bytes
Date ld_crtdt
DateTime ldt_from_prcdt

ii_rc = -1

Choose Case is_caller
	Case "FILE READ"
		// 작성자 : 2004년 03월 06일 김은미
		// 목  적 : 파일 읽어서 DB(reqtelmst)에 저장
		// 인  자 : is_title  = This.Title
		//			   is_caller = "FILE READ"	
		//				is_data[1] : 파일명(FULL PATH)
		// 반환값 : is_data2[1] ==> 작업한 열의 수
		
		ls_filenm = is_data[1]   //파일명(경로포함)
		ls_workmm = is_data[2]   //발생년월
		ls_comcd  = is_data[3]   //사업자
		ls_accept = is_data[4]   //파일수신상태
		ls_file   = is_data[5]   //파일명만
		
		ls_man  = fs_get_control("B0", "P111", ls_ref_desc)   //개인
		ls_temp = fs_get_control("B0", "P110", ls_ref_desc)   //법인
		fi_cut_string(ls_temp, ";", ls_name[])		
		ls_bus  = ls_name[1]
		
		ldt_from_prcdt = fdt_get_dbserver_now()
		
		//1.Start File Read  
		ll_filelen = FileLength(ls_filenm)
		li_filenum = FileOpen(ls_filenm, LineMode!)
		
		If li_filenum < 0 Then
			f_msg_usr_err(201, is_title, "File을 Open 할 수 없습니다.")
			ii_rc = -1
			Return
		End If
		
		//처리seq
		SELECT seq_reqtelworklog.nextval
		INTO   :ll_seq
		FROM   dual;
		
		
		ls_file_read = ""
		Do While (True)
			li_read_bytes = FileRead(li_filenum, ls_file_read)   //리턴값이 들어간 경우(TXT파일)
			If li_read_bytes < 0 Then Exit
			ll_bytes += li_read_bytes
			ls_result[1] = '';
			ls_result[2] = '';
			ls_result[3] = '';
			ls_result[4] = '';
			ls_result[5] = '';
			ls_result[6] = '';
			ls_result[7] = '';
			ls_result[8] = '';
			ls_result[9] = '';
			ls_result[10] = '';
			ls_result[11] = '';
			ls_result[12] = '';
			ls_result[13] = '';
			ls_result[14] = '';
			ls_result[15] = '';
			ls_result[16] = '';
			ls_result[17] = '';
			ls_result[18] = '';
			ls_result[19] = '';
			ls_result[20] = '';
			ls_result[21] = '';
			ls_result[22] = '';
			ls_result[23] = '';
			ls_result[24] = '';
			
			li_rc = fi_cut_string(ls_file_read, ";", ls_result[])
			If li_rc < 6 Then 
				f_msg_usr_err(201, is_title, "File 내용을 확인하십시오.")
				ii_rc = -1
				Return
			End If
			
			/*****************************************/
			
			// File Format에 따라 변경 		
			//지역번호처리
			If trim(ls_result[1]) = '0002' Then 
				ls_result[1] =  MidA(trim(ls_result[1]),3,2)
			Else
				ls_result[1] =  MidA(trim(ls_result[1]),2,4)
			End If	
			//국번호처리
			If MidA(trim(ls_result[2]),1,2) = '00' Then
				ls_result2 = MidA(trim(ls_result[2]),3,2) 
			ElseIf MidA(trim(ls_result[2]),1,1) = '0' Then
				ls_result2 = MidA(trim(ls_result[2]),2,3) 	
			Else	
			   ls_result2 = MidA(trim(ls_result[2]),1,4) 	
			End If	

		
			
			//지역정보
			SELECT nvl(codenm,'X')
			INTO   :ls_codenm
			FROM SYSCOD2T
			WHERE GRCODE = 'K200' AND CODE = :ls_result[1];
			
			//동호를 number로 바꾸어서 zero 로 바꾼다
		   lc_dong = dec(trim(ls_result[8]))
		   lc_ho = dec(trim(ls_result[9]))
		   ls_result[8] = string(lc_dong)
		   ls_result[9] = string(lc_ho)
		  
		  
			If lc_dong = 0 Then
				ls_result[8] = ''
			Else  
				ls_result[8] = string(lc_dong)
			End If	  
			
			If lc_ho = 0 Then
				ls_result[9] = ''
			Else  
				ls_result[9] = '-' + string(lc_ho)
			End If	  
			
			
			ls_telno  = trim(ls_result[1])+ls_result2+MidA(trim(ls_result[3]),1,4)
			ls_marknm = trim(ls_result[5])
			ls_addr   =   ls_codenm+' '+trim(ls_result[6])
			ls_addr2  =  ' '+trim(ls_result[8])+trim(ls_result[9])+' '+trim(ls_result[10])
			
			ls_post     = trim(ls_result[11])+trim(ls_result[12])
			ls_mannum   = trim(ls_result[21])+trim(ls_result[22])+trim(ls_result[23])+trim(ls_result[24])
			
			If LenA(ls_mannum) = 10 Then
				ls_reggu  = ls_bus
			Else
				ls_reggu  = ls_man
			End If
				
						
			UPDATE reqtelmst
			SET    status     = :ls_accept,
			       acceptdt   = sysdate,
					 customernm = :ls_marknm,
					 reggu      = :ls_reggu,
					 regno      = :ls_mannum,
					 zipcod     = :ls_post,
					 addr1      = :ls_addr,
					 addr2      = :ls_addr2,
					 prcseq     = :ll_seq,
					 updt_user  = :gs_user_Id,
					 updtdt     = sysdate
			WHERE  telno      = :ls_telno
			AND    workmm     = :ls_workmm;
					 
					 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller)
				FileClose(li_filenum)
				Return
			End If

			ll_count++
			
		Loop
		
		INSERT INTO reqtelworklog
			 (seq, file_name, workmm, status, prcdt, prccnt, from_prcdt, to_prcdt, comcd, crt_user, pgm_id)
			VALUES
			 (:ll_seq,:ls_file,:ls_workmm,:ls_accept,sysdate,:ll_count,:ldt_from_prcdt,sysdate,:ls_comcd, 
			 :gs_user_id,:gs_pgm_id[gi_open_win_no]);
			 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			FileClose(li_filenum)
			Return
		End If
		Commit; 
			 
		FileClose(li_filenum)
		
		is_data2[1] = String(ll_count)
		
		
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0


end subroutine

public subroutine uf_prc_db_02 ();Long li_FileNum, li_write_bytes, li_len, ll_count, ll_seq
String ls_telno, ls_buffer, ls_sysdt
DateTime ldt_from_prcdt, ldt_to_prcdt
ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_reqfile%File Save"
	//lu_dbmgr.is_caller = "b1w_reg_reqfile%File Save"
	//lu_dbmgr.is_title = Title
	//lu_dbmgr.is_data[1] = is_noprce
	//lu_dbmgr.is_data[2] = is_prce
	//lu_dbmgr.is_data[3] = ls_workmm
	//lu_dbmgr.is_data[4] = ls_pathname
	//lu_dbmgr.is_data[5] = ls_filename
	
   ldt_from_prcdt = fdt_get_dbserver_now()
	ls_sysdt = String(ldt_from_prcdt, 'yymm')
	
	ll_count = 0
	
	//1 File Open
	li_filenum = FileOpen(is_data[4], Linemode!, Write!, LockReadWrite!, Replace!)
	If IsNull(li_filenum) Then li_filenum = -1
	
	If li_filenum < 0 Then 	
		FileClose(li_filenum)
		ii_rc = -3
		Return 
	End If
	
	//2. Select
	DECLARE cur_reqtel CURSOR FOR
	select distinct decode(substr(telno, 1,2), '02', '00' || telno, '0', telno)
	from reqtelmst
   where workmm = :is_data[3] and status  = :is_data[1]  and comcd = :is_data[6]
	order by 1;
	
	OPEN cur_reqtel;
	 Do While (True)
	 Fetch cur_reqtel
	 Into :ls_telno;
	 
	 If SQLCA.SQLCode < 0 Then
				Close cur_reqtel;
				FileClose(li_filenum)
				f_msg_sql_err(is_Title, "Select Error(reqtelmst)")
				Return 
	 ElseIf SQLCA.SQLCode = 100 Then
				Exit
    End If
	 
	 //3. Write
	 li_len = LenA(MidA(ls_telno, 5,8))
	 If li_len < 8  Then
		ls_buffer = FillA('0', 8 -li_len)
	 Else
		ls_buffer = ''
	 End If
	
	 ls_buffer = MidA(ls_telno, 1,4) + ls_buffer + MidA(ls_telno, 5, li_len) + ls_sysdt + '00335'
	 li_write_bytes = FileWrite(li_filenum, ls_buffer)
	 ll_count ++
	 
	Loop
	Close cur_reqtel;
	
	FileClose(li_filenum)
	
	//4. 해당 자료 Update
	Select seq_reqtelworklog.nextval into :ll_seq from dual;
	
	INSERT INTO  TNCBIL.REQTELWORKLOG
      ( SEQ , FILE_NAME , WORKMM , STATUS , PRCDT , PRCCNT , FROM_PRCDT , TO_PRCDT , COMCD , CRT_USER , PGM_ID )
	Values
	( :ll_seq, :is_data[5], :is_data[3], :is_data[2], sysdate, :ll_count,:ldt_from_prcdt, sysdate,
	  :is_data[6], :gs_user_id, :gs_pgm_id[gi_open_win_no]);
	 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(is_Title, "Insert Error(reqtelworklog)")
		RollBack;
		Return
	End If
	
	Update reqtelmst 
	set status = :is_data[2],
	    reqdt = :ldt_from_prcdt,
		 prcseq = :ll_seq,
		 updt_user = :gs_user_id,
		 updtdt = sysdate,
		 pgm_id = :gs_pgm_id[gi_open_win_no]
   where workmm = :is_data[3] and status  = :is_data[1]  and comcd = :is_data[6];
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(is_Title, "Update Error(reqtelworklog)")
		RollBack;
		Return
	End If
	
	
	
End Choose

ii_rc = 0
Return

end subroutine

on b1u_dbmgr15.create
call super::create
end on

on b1u_dbmgr15.destroy
call super::destroy
end on

