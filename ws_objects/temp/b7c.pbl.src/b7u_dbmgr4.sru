$PBExportHeader$b7u_dbmgr4.sru
$PBExportComments$[islim] 지로입금 .kilt
forward
global type b7u_dbmgr4 from u_cust_a_db
end type
end forward

global type b7u_dbmgr4 from u_cust_a_db
end type
global b7u_dbmgr4 b7u_dbmgr4

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db ();//Giro File
String  ls_file, ls_file_read, ls_codemode, ls_prcno, ls_takedt
String  ls_payid
String  ls_inqnum, ls_reqnum, ls_takeamt, ls_giro_type, ls_transdt
String  ls_taketype, ls_filenm, ls_check
String  ls_filepath, ls_file_name
String  ls_workdt
String  ls_trdt
String  ls_bil_status
Integer li_filenum, li_read_bytes
Long	  ll_prcno, ll_takeamt, ll_tmp, ll_count
Integer li_payid_begin, li_payid_length
Integer li_reqnum_begin, li_reqnum_length
Integer li_adjust
String  ls_tmp, ls_desc
String  ls_user_id, ls_pgm_id
Integer li_tmp
String  ls_control[]
String  ls_takecnt
String  ls_takeamt_total
Dec	  ld_takecnt
Dec	  ld_takeamt_total
String  ls_status
String  ls_commamt
Dec	  ld_commamt		//지로 수수료
Dec     ld_commamt_sum  //지로 수수료 합계

ii_rc = -2

Choose Case is_caller
	Case "b7w_reg_girotext_kilt%ue_fileread"
		// WINDOW : b7w_reg_girotext
		// 작성자 : 2003년 08월 06일 추윤식 T&C Technology
		// 목  적 : 파일을  읽어서 DB에 저장
		// 인  자 : 
		//	lu_dbmgr2.is_caller = "b7w_reg_girotext%ue_fileread"
		//	lu_dbmgr2.is_Title = This.Title
		//	lu_dbmgr2.is_data[1] = ls_pathname	// 파일명
		//	lu_dbmgr2.is_data[2] = ls_file_name
		//	lu_dbmgr2.is_data[3] = gs_user_id
		//	lu_dbmgr2.is_data[4] = gs_pgm_id[gi_open_win_no]
		//				is_data[1] : (FULL PATH)Trim(dw_input.Object.filenm[1]) // 파일명
		// 반환값 : is_data2[1] ==> 작업한 열의 수
			
		ld_commamt_sum = 0
			
		ls_filepath = is_data[1]
		ls_file_name = is_data[2]
		ls_user_id = is_data[3]
		ls_pgm_id = is_data[4]
		
		
		//지로파일의 Data Record 길이
		String ls_record_size
		ls_record_size = fs_get_control("B7","B140",ls_desc)
		//li_tmp = Integer(ls_record_size)
		
		//Constant Int li_record_size = Integer(ls_record_size)
		//Integer li_record_size = Integer(ls_record_size)
		Constant Int li_record_size = 82
		
		//지로고객조회번호구성(payid시작;길이;trdt시작;길이)
		ls_tmp = fs_get_control("B7","B120",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		li_payid_begin = Integer(ls_control[1])
		li_payid_length = Integer(ls_control[2])
		li_reqnum_begin = Integer(ls_control[3])
		li_reqnum_length = Integer(ls_control[4])
		//li_adjust = 20 - li_payid_length - li_reqnum_length
		
		//빌링처리상태
		ls_tmp = fs_get_control("B7","B110",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_bil_status = ls_control[1]
		
		//지로결제작업상태
		ls_tmp = fs_get_control("B7","B100",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_status = ls_control[1]
		
		//1.Start File Read  
		li_filenum = FileOpen(ls_filepath, StreamMode!)
		If IsNull(li_filenum) Then li_filenum=-1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filepath)
			FileClose(li_filenum)
			Return 
		End If		
		
		ls_file_read = ""
		Do While (True)
			li_read_bytes = FileRead(li_filenum, ls_file_read)   //리턴값이 들어간 경우(TXT파일)
			If li_read_bytes <= 0 Then Exit
			If li_read_bytes > li_record_size Then 
				FileSeek(li_filenum, li_record_size - li_read_bytes, FromCurrent!)
			End If	
			
			ls_codemode = MidA(ls_file_read,1,2)  // Header, Data, Trailer 구분코드

			If IsNull(ls_codemode) Then ls_codemode = ""
			If ls_codemode = "" Then
				f_msg_usr_err(201, is_Title, "자료가 잘못 되었습니다.")
				fileClose(li_filenum)
				Return
			End If
			
			
			// Header Record(구분코드 "11")
			IF ls_codemode = "11" THEN
				ls_workdt = MidA(ls_file_read,10,6)	//수취일자 YYMMDD
				ls_workdt = "20" + ls_workdt			//수취일자 YYYYMMDD
				
			// Data Record(구분코드 "22")
			ElseIf ls_codemode = "22" Then 
				ls_prcno = MidA(ls_file_read,3,7)       	// 일련번호 
				ls_takedt = MidA(ls_file_read,10,6)		// 수납일자 "000627" 조건을 2000년으로 해준다..
				ls_takedt = "20" + ls_takedt   			// 수납일자 20000627
				ls_inqnum = MidA(ls_file_read,22,20)  	// 고객조회번호
				
			
				
				//CVNET 고객실별번호인 경우
				//IF Mid(ls_inqnum,1,6) = "000000" THEN
				//	
				//	ls_payid  = Mid(ls_inqnum, 13, 7)	//고객번호추출
				//	ls_trdt = Mid(ls_inqnum,7 ,6 ) + "01" // 청구기준일
				//
				////TNC 고객식별번호인 경우
				//ELSE
				//	
				//	ls_payid  = Mid(ls_inqnum, li_payid_begin+li_adjust, li_payid_length)	//고객번호추출
				//	ls_trdt = Mid(ls_inqnum, li_reqnum_begin+li_adjust, li_reqnum_length) // 청구기준일
				//	
				//END IF
				
				ls_trdt = MidA(ls_inqnum, li_reqnum_begin, li_reqnum_length)
				ls_payid = MidA(ls_inqnum, li_payid_begin, li_payid_length)
				
				//고객조회번호없음(이미지장표)인 경우,
				//청구기준일이 잘못들어간 경우,
				//청구기준일을 임시로 넣는다.
				//IF ls_inqnum = "00000000000000000000" or IsDate(ls_trdt) THEN
				IF ls_inqnum = "00000000000000000000" THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				ls_takeamt  = MidA(ls_file_read, 42, 10)  // 입금액
				ll_takeamt = Long(ls_takeamt)
				ls_taketype = MidA(ls_file_read, 57, 1)   // 수납구분
				If Trim(ls_taketype) = "" Then ls_taketype = "N"	//빈칸을 "N"으로 대체한다.
				ls_giro_type = MidA(ls_file_read, 58, 1) // 장표처리구분
				If Trim(ls_giro_type) = "" Then ls_giro_type = "N"	//빈칸을 "N"으로 대체한다.
				ls_transdt = MidA(ls_file_read, 59,6) // 이체일자 "000630" 조건을 2000년으로 해준다..
				ls_transdt = "20" + ls_transdt // 이체일자 20000630
				ls_commamt = MidA(ls_file_read, 65,4) //지로 수수료
				ld_commamt = Dec(ls_commamt)	//지로 수수료
				ld_commamt_sum = ld_commamt_sum + ld_commamt //지로 수수료합계
				
				
				//날짜형식을 체크한다.
				//날짜가 잘못들어간 경우,
				//날짜를 임시로 넣는다.
				
				IF not fb_chk_stringdate(ls_trdt) THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF				
				
				IF not fb_chk_stringdate(ls_transdt) THEN
					ls_transdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				IF not fb_chk_stringdate(ls_takedt) THEN
					ls_takedt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				SELECT Count(*)
				INTO :ll_tmp
				FROM GIROTEXT
				WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, "GIROTEXT SELECT error ")
					FileClose(li_filenum)
					RollBack;
					Return
				End If
				
				If ll_tmp = 0 Then
					INSERT INTO GIROTEXT(file_name,workdt,prcno,payid,takedt,takeamt,reqnum,trdt,taketype,giro_type,transdt,inqnum,bil_status,commamt)
					VALUES(:ls_file_name,:ls_workdt,:ls_prcno,:ls_payid,:ls_takedt,:ll_takeamt,null,:ls_trdt,:ls_taketype,:ls_giro_type,:ls_transdt,:ls_inqnum,:ls_bil_status,:ld_commamt);
					If SQLCA.SQLCode < 0 Then
						MessageBox(is_title, "파일형식이 잘못되었습니다. 고객식별번호:"+ ls_inqnum)
						FileClose(li_filenum)
						RollBack;
						Return
					End If
				Else
					FileClose(li_filenum)
					RollBack;
					Return
//					UPDATE GIROTEXT 
//					SET  takedt = :ls_takedt, payid = :ls_payid, takeamt = :ll_takeamt, &
//						giro_type = :ls_giro_type, taketype = :ls_taketype 
//					WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, "GIROTEXT UPDATE error ")
//						FileClose(li_filenum)
//						RollBack;
//						Return
//					End If
				End If

			ll_count++
			
			// Trailder Record(구분코드 "33")
			ElseIf ls_codemode = "33" Then
				ls_takecnt = MidA(ls_file_read,60,7)				//총수납건수
				ld_takecnt = Dec(ls_takecnt)
				ls_takeamt_total = MidA(ls_file_read,68,12)		//총수납금액
				ld_takeamt_total = Dec(ls_takeamt_total)
				
			//파일에러
			Else	
				f_msg_sql_err(is_title, "파일의 형식이 올바르지 않습니다.")
				FileClose(li_filenum)
				RollBack;
				Return
			End If
		
		Loop
		
		FileClose(li_filenum)
		
		
		SELECT Count(*)
		INTO :ll_tmp
		FROM GIROTEXTSTATUS
		WHERE workdt = :ls_workdt AND file_name = :ls_file_name;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS SELECT error ")
			RollBack;
			Return
		End If
				
		IF ll_tmp = 0 THEN
					
			//Insert into GIROTEXTSTATUS
			INSERT INTO girotextstatus
			(file_name,workdt,takecnt,takeamt,status,resultprcdt,commamt,
			crt_user,updt_user,crtdt,updtdt,pgm_id)
			VALUES
			(:ls_file_name,:ls_workdt,:ld_takecnt,:ld_takeamt_total,:ls_status,sysdate,:ld_commamt_sum,
			:ls_user_id,:ls_user_id,sysdate,sysdate,:ls_pgm_id);
			
		ELSE
			RollBack;
			Return
		END IF
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS INSERT error ")
			RollBack;
			Return
		End If
		
		is_data2[1] = String(ll_count)
		is_data2[2] = ls_workdt
	
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", "Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

public subroutine uf_prc_db_01 ();//Giro File
String  ls_file, ls_file_read, ls_codemode, ls_prcno, ls_takedt
String  ls_payid
String  ls_inqnum, ls_reqnum, ls_takeamt, ls_giro_type, ls_transdt
String  ls_taketype, ls_filenm, ls_check
String  ls_filepath, ls_file_name
String  ls_workdt
String  ls_trdt
String  ls_bil_status
Integer li_filenum, li_read_bytes
Long	  ll_prcno, ll_takeamt, ll_tmp, ll_count
Integer li_payid_begin, li_payid_length
Integer li_reqnum_begin, li_reqnum_length
Integer li_adjust
String  ls_tmp, ls_desc
String  ls_user_id, ls_pgm_id
Integer li_tmp
String  ls_control[]
String  ls_takecnt
String  ls_takeamt_total
Dec	  ld_takecnt
Dec	  ld_takeamt_total
String  ls_status
String  ls_commamt
Dec	  ld_commamt		//지로 수수료
Dec     ld_commamt_sum  //지로 수수료 합계

ii_rc = -2

Choose Case is_caller
	Case "b7w_reg_girotext_cv%ue_fileread"
		// WINDOW : b7w_reg_girotext
		// 작성자 : 2003년 08월 06일 추윤식 T&C Technology
		// 목  적 : 파일을  읽어서 DB에 저장
		// 인  자 : 
		//	lu_dbmgr2.is_caller = "b7w_reg_girotext%ue_fileread"
		//	lu_dbmgr2.is_Title = This.Title
		//	lu_dbmgr2.is_data[1] = ls_pathname	// 파일명
		//	lu_dbmgr2.is_data[2] = ls_file_name
		//	lu_dbmgr2.is_data[3] = gs_user_id
		//	lu_dbmgr2.is_data[4] = gs_pgm_id[gi_open_win_no]
		//				is_data[1] : (FULL PATH)Trim(dw_input.Object.filenm[1]) // 파일명
		// 반환값 : is_data2[1] ==> 작업한 열의 수
			
		ld_commamt_sum = 0
			
		ls_filepath = is_data[1]
		ls_file_name = is_data[2]
		ls_user_id = is_data[3]
		ls_pgm_id = is_data[4]
		
		
		//지로파일의 Data Record 길이
		String ls_record_size
		ls_record_size = fs_get_control("B7","B140",ls_desc)
		//li_tmp = Integer(ls_record_size)
		
		//Constant Int li_record_size = Integer(ls_record_size)
		//Integer li_record_size = Integer(ls_record_size)
		Constant Int li_record_size = 82
		
		//지로고객조회번호구성(payid시작;길이;trdt시작;길이)
		ls_tmp = fs_get_control("B7","B120",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		li_payid_begin = Integer(ls_control[1])
		li_payid_length = Integer(ls_control[2])
		li_reqnum_begin = Integer(ls_control[3])
		li_reqnum_length = Integer(ls_control[4])
		li_adjust = 20 - li_payid_length - li_reqnum_length
		
		//빌링처리상태
		ls_tmp = fs_get_control("B7","B110",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_bil_status = ls_control[1]
		
		//지로결제작업상태
		ls_tmp = fs_get_control("B7","B100",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_status = ls_control[1]
		
		//1.Start File Read  
		li_filenum = FileOpen(ls_filepath, StreamMode!)
		If IsNull(li_filenum) Then li_filenum=-1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filepath)
			FileClose(li_filenum)
			Return 
		End If		
		
		ls_file_read = ""
		Do While (True)
			li_read_bytes = FileRead(li_filenum, ls_file_read)   //리턴값이 들어간 경우(TXT파일)
			If li_read_bytes <= 0 Then Exit
			If li_read_bytes > li_record_size Then 
				FileSeek(li_filenum, li_record_size - li_read_bytes, FromCurrent!)
			End If	
			
			ls_codemode = MidA(ls_file_read,1,2)  // Header, Data, Trailer 구분코드

			If IsNull(ls_codemode) Then ls_codemode = ""
			If ls_codemode = "" Then
				f_msg_usr_err(201, is_Title, "자료가 잘못 되었습니다.")
				fileClose(li_filenum)
				Return
			End If
			
			
			// Header Record(구분코드 "11")
			IF ls_codemode = "11" THEN
				ls_workdt = MidA(ls_file_read,10,6)	//수취일자 YYMMDD
				ls_workdt = "20" + ls_workdt			//수취일자 YYYYMMDD
				
			// Data Record(구분코드 "22")
			ElseIf ls_codemode = "22" Then 
				ls_prcno = MidA(ls_file_read,3,7)       	// 일련번호 
				ls_takedt = MidA(ls_file_read,10,6)		// 수납일자 "000627" 조건을 2000년으로 해준다..
				ls_takedt = "20" + ls_takedt   			// 수납일자 20000627
				ls_inqnum = MidA(ls_file_read,22,20)  	// 고객조회번호
				
			
				
				//CVNET 고객실별번호인 경우
				IF MidA(ls_inqnum,1,6) = "000000" THEN
					
					ls_payid  = MidA(ls_inqnum, 13, 7)	//고객번호추출
					ls_trdt = MidA(ls_inqnum,7 ,6 ) + "01" // 청구기준일

				//TNC 고객식별번호인 경우
				ELSE
					
					ls_payid  = MidA(ls_inqnum, li_payid_begin+li_adjust, li_payid_length)	//고객번호추출
					ls_trdt = MidA(ls_inqnum, li_reqnum_begin+li_adjust, li_reqnum_length) // 청구기준일
					
				END IF
				
				
				//고객조회번호없음(이미지장표)인 경우,
				//청구기준일이 잘못들어간 경우,
				//청구기준일을 임시로 넣는다.
				//IF ls_inqnum = "00000000000000000000" or IsDate(ls_trdt) THEN
				IF ls_inqnum = "00000000000000000000" THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				ls_takeamt  = MidA(ls_file_read, 42, 10)  // 입금액
				ll_takeamt = Long(ls_takeamt)
				ls_taketype = MidA(ls_file_read, 57, 1)   // 수납구분
				If Trim(ls_taketype) = "" Then ls_taketype = "N"	//빈칸을 "N"으로 대체한다.
				ls_giro_type = MidA(ls_file_read, 58, 1) // 장표처리구분
				If Trim(ls_giro_type) = "" Then ls_giro_type = "N"	//빈칸을 "N"으로 대체한다.
				ls_transdt = MidA(ls_file_read, 59,6) // 이체일자 "000630" 조건을 2000년으로 해준다..
				ls_transdt = "20" + ls_transdt // 이체일자 20000630
				ls_commamt = MidA(ls_file_read, 65,4) //지로 수수료
				ld_commamt = Dec(ls_commamt)	//지로 수수료
				ld_commamt_sum = ld_commamt_sum + ld_commamt //지로 수수료합계
				
				
				//날짜형식을 체크한다.
				//날짜가 잘못들어간 경우,
				//날짜를 임시로 넣는다.
				
				IF not fb_chk_stringdate(ls_trdt) THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF				
				
				IF not fb_chk_stringdate(ls_transdt) THEN
					ls_transdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				IF not fb_chk_stringdate(ls_takedt) THEN
					ls_takedt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				SELECT Count(*)
				INTO :ll_tmp
				FROM GIROTEXT
				WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, "GIROTEXT SELECT error ")
					FileClose(li_filenum)
					RollBack;
					Return
				End If
				
				If ll_tmp = 0 Then
					INSERT INTO GIROTEXT(file_name,workdt,prcno,payid,takedt,takeamt,reqnum,trdt,taketype,giro_type,transdt,inqnum,bil_status,commamt)
					VALUES(:ls_file_name,:ls_workdt,:ls_prcno,:ls_payid,:ls_takedt,:ll_takeamt,null,:ls_trdt,:ls_taketype,:ls_giro_type,:ls_transdt,:ls_inqnum,:ls_bil_status,:ld_commamt);
					If SQLCA.SQLCode < 0 Then
						MessageBox(is_title, "파일형식이 잘못되었습니다. 고객식별번호:"+ ls_inqnum)
						FileClose(li_filenum)
						RollBack;
						Return
					End If
				Else
					FileClose(li_filenum)
					RollBack;
					Return
//					UPDATE GIROTEXT 
//					SET  takedt = :ls_takedt, payid = :ls_payid, takeamt = :ll_takeamt, &
//						giro_type = :ls_giro_type, taketype = :ls_taketype 
//					WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, "GIROTEXT UPDATE error ")
//						FileClose(li_filenum)
//						RollBack;
//						Return
//					End If
				End If

			ll_count++
			
			// Trailder Record(구분코드 "33")
			ElseIf ls_codemode = "33" Then
				ls_takecnt = MidA(ls_file_read,60,7)				//총수납건수
				ld_takecnt = Dec(ls_takecnt)
				ls_takeamt_total = MidA(ls_file_read,68,12)		//총수납금액
				ld_takeamt_total = Dec(ls_takeamt_total)
				
			//파일에러
			Else	
				f_msg_sql_err(is_title, "파일의 형식이 올바르지 않습니다.")
				FileClose(li_filenum)
				RollBack;
				Return
			End If
		
		Loop
		
		FileClose(li_filenum)
		
		
		SELECT Count(*)
		INTO :ll_tmp
		FROM GIROTEXTSTATUS
		WHERE workdt = :ls_workdt AND file_name = :ls_file_name;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS SELECT error ")
			RollBack;
			Return
		End If
				
		IF ll_tmp = 0 THEN
					
			//Insert into GIROTEXTSTATUS
			INSERT INTO girotextstatus
			(file_name,workdt,takecnt,takeamt,status,resultprcdt,commamt,
			crt_user,updt_user,crtdt,updtdt,pgm_id)
			VALUES
			(:ls_file_name,:ls_workdt,:ld_takecnt,:ld_takeamt_total,:ls_status,sysdate,:ld_commamt_sum,
			:ls_user_id,:ls_user_id,sysdate,sysdate,:ls_pgm_id);
			
		ELSE
			RollBack;
			Return
		END IF
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS INSERT error ")
			RollBack;
			Return
		End If
		
		is_data2[1] = String(ll_count)
		is_data2[2] = ls_workdt
	
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", "Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

public subroutine uf_prc_db_02 ();//Giro File
String  ls_file, ls_file_read, ls_codemode, ls_prcno, ls_takedt
String  ls_payid
String  ls_inqnum, ls_reqnum, ls_takeamt, ls_giro_type, ls_transdt
String  ls_taketype, ls_filenm, ls_check
String  ls_filepath, ls_file_name
String  ls_workdt
String  ls_trdt
String  ls_bil_status
Integer li_filenum, li_read_bytes
Long	  ll_prcno, ll_takeamt, ll_tmp, ll_count
Integer li_payid_begin, li_payid_length
Integer li_reqnum_begin, li_reqnum_length
Integer li_adjust
String  ls_tmp, ls_desc
String  ls_user_id, ls_pgm_id
Integer li_tmp
String  ls_control[]
String  ls_takecnt
String  ls_takeamt_total
Dec	  ld_takecnt
Dec	  ld_takeamt_total
String  ls_status
String  ls_commamt
Dec	  ld_commamt		//지로 수수료
Dec     ld_commamt_sum  //지로 수수료 합계

Long ll_length

ii_rc = -2

Choose Case is_caller
	Case "b7w_reg_girotext_kilt_gr15%ue_fileread"
		// WINDOW : b7w_reg_girotext_kilt_gr15
		// 작성자 : 2005년 04월 14일 juede
		// 목  적 : 파일을  읽어서 DB에 저장
		// 인  자 : 
		//	lu_dbmgr2.is_caller = "b7w_reg_girotext_kilt_gr15%ue_fileread"
		//	lu_dbmgr2.is_Title = This.Title
		//	lu_dbmgr2.is_data[1] = ls_pathname	// 파일명
		//	lu_dbmgr2.is_data[2] = ls_file_name
		//	lu_dbmgr2.is_data[3] = gs_user_id
		//	lu_dbmgr2.is_data[4] = gs_pgm_id[gi_open_win_no]
		//				is_data[1] : (FULL PATH)Trim(dw_input.Object.filenm[1]) // 파일명
		// 반환값 : is_data2[1] ==> 작업한 열의 수
			
		ld_commamt_sum = 0
			
		ls_filepath = is_data[1]
		ls_file_name = is_data[2]
		ls_user_id = is_data[3]
		ls_pgm_id = is_data[4]
		
		
		//지로파일의 Data Record 길이  2005.04.14 juede Record length add
		//String ls_record_size
		//ls_record_size = fs_get_control("B7","B141",ls_desc)  //sysctl add 2005.04.14
		//li_tmp = Integer(ls_record_size)
		
		//Constant Int li_record_size = Integer(ls_record_size)
		//Integer li_record_size = Integer(ls_record_size)
		//Constant Int li_record_size = Integer(ls_record_size)   //120bytes
		
		Constant Int li_record_size = 120
		
		//지로고객조회번호구성(payid시작;길이;trdt시작;길이)
		ls_tmp = fs_get_control("B7","B120",ls_desc)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		li_payid_begin = Integer(ls_control[1])   //9
		li_payid_length = Integer(ls_control[2])  //8
		li_reqnum_begin = Integer(ls_control[3])  //1
		li_reqnum_length = Integer(ls_control[4]) //8
		//li_adjust = 20 - li_payid_length - li_reqnum_length
		
		//빌링처리상태
		ls_tmp = fs_get_control("B7","B110",ls_desc)  //0;1;2  빌링처리상태(수납파일;입금정상;입금에러)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_bil_status = ls_control[1]
		
		//지로결제작업상태
		ls_tmp = fs_get_control("B7","B100",ls_desc)  //0;1;2  작업상태(수납파일;표준입금;TR입금)
		li_tmp = fi_cut_string(ls_tmp,";",ls_control)
		
		ls_status = ls_control[1]
		
		//1.Start File Read  
		ll_length = FileLength(ls_filepath)
//		li_filenum = FileOpen(ls_filepath, StreamMode!)
		li_filenum = FileOpen(ls_filepath, LineMode!)  //LineMode 로 변경 2005.04.14
					
		If IsNull(li_filenum) Then li_filenum=-1
		If li_filenum < 0 Then
			f_msg_usr_err(9000, is_Title, "Error>> 파일열기 " + ls_filepath)
			FileClose(li_filenum)
			Return 
		End If		
		
		ls_file_read = ""
		Do While (True)
 
			li_read_bytes = FileRead(li_filenum, ls_file_read)   //리턴값이 들어간 경우(TXT파일)
			If li_read_bytes <= 0 Then Exit
			If li_read_bytes > li_record_size Then 
				FileSeek(li_filenum, li_record_size - li_read_bytes, FromCurrent!)
			End If	

									
			//ls_codemode = Mid(ls_file_read,1,2)  // Header(11), Data(22), Trailer(33) 구분코드
         ls_codemode = MidA(trim(ls_file_read),1, 2)
			MessageBox("test",ls_codemode)
			
			If IsNull(ls_codemode) Then ls_codemode = ""
			If ls_codemode = "" Then
				f_msg_usr_err(201, is_Title, "자료가 잘못 되었습니다.")
				fileClose(li_filenum)
				Return
			End If
			
			
			// Header Record(구분코드 "11")
			IF ls_codemode = "11" THEN
				ls_workdt = MidA(ls_file_read,18,8)	//수취일자 YYYYMMDD  - 변경됨
				
			// Data Record(구분코드 "22")
			ElseIf ls_codemode = "22" Then 
				ls_prcno = MidA(ls_file_read,3,7)       // 일련번호 
				ls_takedt = MidA(ls_file_read,10,8)		// 수납일자 변경됨. YYYYMMDD
				ls_transdt = MidA(ls_file_read, 18,8)   // 이체일자 YYYYMMDD				
				ls_inqnum = MidA(ls_file_read,50,20)  	// 고객조회번호 
				
			
				
				//CVNET 고객실별번호인 경우
				//IF Mid(ls_inqnum,1,6) = "000000" THEN
				//	
				//	ls_payid  = Mid(ls_inqnum, 13, 7)	//고객번호추출
				//	ls_trdt = Mid(ls_inqnum,7 ,6 ) + "01" // 청구기준일
				//
				////TNC 고객식별번호인 경우
				//ELSE
				//	
				//	ls_payid  = Mid(ls_inqnum, li_payid_begin+li_adjust, li_payid_length)	//고객번호추출
				//	ls_trdt = Mid(ls_inqnum, li_reqnum_begin+li_adjust, li_reqnum_length) // 청구기준일
				//	
				//END IF
				
				ls_trdt = MidA(ls_inqnum, li_reqnum_begin, li_reqnum_length)
				ls_payid = MidA(ls_inqnum, li_payid_begin, li_payid_length)
				
				//고객조회번호없음(이미지장표)인 경우,
				//청구기준일이 잘못들어간 경우,
				//청구기준일을 임시로 넣는다.
				//IF ls_inqnum = "00000000000000000000" or IsDate(ls_trdt) THEN
				IF ls_inqnum = "00000000000000000000" THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				ls_takeamt  = MidA(ls_file_read, 70, 13)  // 입금액 .변경
				ll_takeamt = Long(ls_takeamt)
				ls_taketype = MidA(ls_file_read, 83, 1)   // 수납구분. 변경				
				If Trim(ls_taketype) = "" Then ls_taketype = "N"	//빈칸을 "N"으로 대체한다.
				ls_commamt = MidA(ls_file_read, 84,4) //지로 수수료
				ld_commamt = Dec(ls_commamt)	//지로 수수료
				ld_commamt_sum = ld_commamt_sum + ld_commamt //지로 수수료합계				
				ls_giro_type = MidA(ls_file_read, 88, 1) // 장표처리구분
				If Trim(ls_giro_type) = "" Then ls_giro_type = "N"	//빈칸을 "N"으로 대체한다.

				
				
				//날짜형식을 체크한다.
				//날짜가 잘못들어간 경우,
				//날짜를 임시로 넣는다.
				
				IF not fb_chk_stringdate(ls_trdt) THEN
					ls_trdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF				
				
				IF not fb_chk_stringdate(ls_transdt) THEN
					ls_transdt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				IF not fb_chk_stringdate(ls_takedt) THEN
					ls_takedt = String(fdt_get_dbserver_now(),"YYYYMM") + "01"
				END IF
				
				
				SELECT Count(*)
				INTO :ll_tmp
				FROM GIROTEXT
				WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, "GIROTEXT SELECT error ")
					FileClose(li_filenum)
					RollBack;
					Return
				End If
				
				If ll_tmp = 0 Then
					INSERT INTO GIROTEXT(file_name,workdt,prcno,payid,takedt,takeamt,reqnum,trdt,taketype,giro_type,transdt,inqnum,bil_status,commamt)
					VALUES(:ls_file_name,:ls_workdt,:ls_prcno,:ls_payid,:ls_takedt,:ll_takeamt,null,:ls_trdt,:ls_taketype,:ls_giro_type,:ls_transdt,:ls_inqnum,:ls_bil_status,:ld_commamt);
					If SQLCA.SQLCode < 0 Then
						MessageBox(is_title, "파일형식이 잘못되었습니다. 고객식별번호:"+ ls_inqnum)
						FileClose(li_filenum)
						RollBack;
						Return
					End If
				Else
					FileClose(li_filenum)
					RollBack;
					Return
//					UPDATE GIROTEXT 
//					SET  takedt = :ls_takedt, payid = :ls_payid, takeamt = :ll_takeamt, &
//						giro_type = :ls_giro_type, taketype = :ls_taketype 
//					WHERE prcno = :ls_prcno AND workdt = :ls_workdt AND file_name = :ls_file_name;
//					If SQLCA.SQLCode < 0 Then
//						f_msg_sql_err(is_title, "GIROTEXT UPDATE error ")
//						FileClose(li_filenum)
//						RollBack;
//						Return
//					End If
				End If

			ll_count++
			
			// Trailder Record(구분코드 "33")
			ElseIf ls_codemode = "33" Then
				ls_takecnt = MidA(ls_file_read,10,7)				//총수납건수
				ld_takecnt = Dec(ls_takecnt)
				ls_takeamt_total = MidA(ls_file_read,17,14)		//총수납금액
				ld_takeamt_total = Dec(ls_takeamt_total)
				
			//파일에러
			Else	
				f_msg_sql_err(is_title, "파일의 형식이 올바르지 않습니다.")
				FileClose(li_filenum)
				RollBack;
				Return
			End If
		
		ls_file_read = ""
		Loop
		
		FileClose(li_filenum)
		
		
		SELECT Count(*)
		INTO :ll_tmp
		FROM GIROTEXTSTATUS
		WHERE workdt = :ls_workdt AND file_name = :ls_file_name;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS SELECT error ")
			RollBack;
			Return
		End If
				
		IF ll_tmp = 0 THEN
					
			//Insert into GIROTEXTSTATUS
			INSERT INTO girotextstatus
			(file_name,workdt,takecnt,takeamt,status,resultprcdt,commamt,
			crt_user,updt_user,crtdt,updtdt,pgm_id)
			VALUES
			(:ls_file_name,:ls_workdt,:ld_takecnt,:ld_takeamt_total,:ls_status,sysdate,:ld_commamt_sum,
			:ls_user_id,:ls_user_id,sysdate,sysdate,:ls_pgm_id);
			
		ELSE
			RollBack;
			Return
		END IF
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "GIROTEXTSTATUS INSERT error ")
			RollBack;
			Return
		End If
		
		is_data2[1] = String(ll_count)
		is_data2[2] = ls_workdt
	
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", "Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

on b7u_dbmgr4.create
call super::create
end on

on b7u_dbmgr4.destroy
call super::destroy
end on

