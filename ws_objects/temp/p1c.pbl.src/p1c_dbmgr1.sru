$PBExportHeader$p1c_dbmgr1.sru
$PBExportComments$[jsha]
forward
global type p1c_dbmgr1 from u_cust_a_db
end type
end forward

global type p1c_dbmgr1 from u_cust_a_db
end type
global p1c_dbmgr1 p1c_dbmgr1

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_buffer, ls_serialno, ls_modelno, ls_makercd, ls_terminalid, ls_macaddress
String ls_E164, ls_H323ID, ls_partner
String ls_status, ls_actStatus, ls_ref_desc, ls_adtype, ls_invStatus, ls_svctype, ls_customerid, ls_svccod
String ls_temp, ls_result[], ls_pid, ls_card_status[], ls_priceplan
Integer li_filepointer, li_return
Long ll_fileread, ll_adcnt, ll_validcnt, ll_cardcnt, ll_contractseq
Constant Integer li_FILE_SIZE = 178

ii_rc = -1

Choose Case is_caller
	Case "p1w_reg_admst_temp_icn%fileread"
//		lu_dbmgr.is_title = This.title
//		lu_dbmgr.is_caller = "p1w_reg_admst_temp_icn%fileread"
//		lu_dbmgr.is_data[1] = ls_pathname
//		lu_dbmgr.is_data[2] = ls_filename
//		lu_dbmgr.is_data[3] = gs_user_id
//		lu_dbmgr.is_data[4] = gs_pgm_id[gi_open_win_no]
		
		li_filepointer = FileOpen(is_data[1], StreamMode!, Read!, LockRead!)
		
		If IsNull(li_filepointer) Then li_filepointer = -1
		If li_filepointer < 0 Then 
			f_msg_usr_err(9000, is_title, "File Open")
			FileClose(li_filepointer)
			Return
		End If
		
		// 개통신청상태
		ls_ref_desc = ""
		ls_status = fs_get_control("B0", "P220", ls_ref_desc)
		
		// 개통상태
		ls_ref_desc = ""
		ls_actStatus = fs_get_control("B0", "P223", ls_ref_desc)

		// 고객번호
		ls_ref_desc = ""
		ls_temp = fs_get_control("P0", "P000", ls_ref_desc)
		If ls_temp = "" Then Return
		li_return = fi_cut_string(ls_temp, ";", ls_result[])
		ls_customerid = ls_result[2]
		
		// 서비스코드
		ls_svccod = ls_result[3]
		
		// 서비스 type : 선불카드
		ls_svctype = ls_result[4]
				
		// 장비구분
		ls_ref_desc = ""
		ls_adtype = fs_get_control("E1", "A600", ls_ref_desc)
		
		// 재고상태
		ls_ref_desc = ""
		ls_invStatus = fs_get_control("E1", "A101", ls_ref_desc)
		
		// Card상태(발행;판매;사용;기간만료;잔액부족;일시정지;반품카드)
		ls_ref_desc = ""
		ls_temp = fs_get_control("P0", "P101", ls_Ref_desc)
		If ls_temp = "" Then Return
		li_return = fi_cut_string(ls_temp, ";", ls_card_status[])
		
		Do While(true)
			ll_fileread = FileRead(li_filepointer, ls_buffer)
			
			// 모두 읽었으면 Exit
			If ll_fileread < 0 Then Exit
			
			// File Pointer Move
			If ll_fileread > li_FILE_SIZE Then
				FileSeek(li_filepointer, li_FILE_SIZE - ll_fileread, FromEnd!)
			End If
			
			ls_buffer = MidA(ls_buffer, 1, li_FILE_SIZE)
			
			ls_serialno = Trim(MidA(ls_buffer, 1, 30))
			ls_modelno = Trim(MidA(ls_buffer, 32, 10))
			ls_makercd = Trim(MidA(ls_buffer, 43, 10))
			ls_terminalid = Trim(MidA(ls_buffer, 54, 20))
			ls_macaddress = Trim(MidA(ls_buffer, 75, 20))
			ls_E164 = Trim(MidA(ls_buffer, 96, 30))
			ls_H323ID = Trim(MidA(ls_buffer, 127, 20))
			ls_partner = Trim(MidA(ls_buffer, 148, 10))
			ls_pid = Trim(MidA(ls_buffer, 159, 20))
			
			// Reject Check
			SELECT count(*) 
			INTO :ll_adcnt
			FROM admst 
			WHERE serialno = :ls_serialno AND modelno = :ls_modelno;
			
			If SQLCA.SQLCODE < 0 Then
				FileClose(li_filepointer)
				f_msg_sql_err(is_title, "SELECT Error(admst)")
				Return
			End If
			
//			SELECT count(*)
//			INTO :ll_validcnt
//			FROM validinfo
//			WHERE validkey = :ls_E164 AND (status = :ls_status OR status = :ls_actStatus);

			ll_validcnt = 0
			select count(*)
		   into :ll_validcnt
		   from validinfo
   		where  ( (to_char(fromdt,'yyyymmdd') > to_char(sysdate,'yyyymmdd') ) Or
				  ( to_char(fromdt,'yyyymmdd') <= to_char(sysdate,'yyyymmdd') and
					to_char(sysdate,'yyyymmdd') <= nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_E164;
			
			If SQLCA.SQLCODE < 0 Then
				FileClose(li_filepointer)
				f_msg_sql_err(is_title, "SELECT Error(validinfo)")
				Return
			End If
			
			SELECT count(*) 
			INTO :ll_cardcnt
			FROM p_cardmst
			WHERE pid = :ls_pid AND (status = :ls_card_status[2] OR status = :ls_card_status[3]);

			If SQLCA.SQLCODE < 0 Then
				FileClose(li_filepointer)
				f_msg_sql_err(is_title, "SELECT Error(p_cardmst)")
				Return
			End If

			// PricePlan
			SELECT priceplan
			INTO :ls_priceplan
			FROM p_cardmst
			WHERE pid = :ls_pid;
			
			If SQLCA.SQLCODE < 0 Then
				FileClose(li_filepointer)
				f_msg_sql_err(is_title, "SELECT Error(priceplan From p_cardmst)")
				Return
			End If
			
			// Contractseq
			SELECT seq_contractseq.nextval
			INTO :ll_contractseq
			FROM dual;
			
			If ll_adcnt = 0 and ll_validcnt = 0 and ll_cardcnt <> 0 Then		// Reject되지 않은 경우.
				// ADMST INSERT
				INSERT INTO admst
					(adseq, serialno, adtype, dan_yn, makercd, modelno, status, use_yn, mv_partner,
					 saledt, pid, contractseq, shipno, crt_user, updt_user, crtdt, updtdt, pgm_id)					
				VALUES
					(seq_adseq.nextval, :ls_serialno, :ls_adtype, 'Y', :ls_makercd, :ls_modelno, :ls_invStatus,
					 'Y', :ls_partner, sysdate, :ls_E164, :ll_contractseq, :ls_H323ID, :is_data[3], :is_data[3],
					  sysdate, sysdate, :is_data[4]);
			   
				If SQLCA.SQLCODE < 0 Then
					FileClose(li_filepointer)
					f_msg_sql_err(is_title, "Insert Error(admst)")
					Rollback;
					Return
				End If
					
				// VALIDINFO INSERT 
				INSERT INTO validinfo
					(validkey, fromdt, status, use_yn, customerid, svccod, svctype, priceplan, auth_method, 
					 validitem3, contractseq, crt_user, crtdt, updt_user, updtdt, pgm_id)
				VALUES
					(:ls_E164, to_char(sysdate,'yyyymmdd'), :ls_actStatus, 'Y', :ls_customerid, :ls_svccod, :ls_svctype, :ls_priceplan,
					 'DYNIP_BOTH', :ls_H323ID, :ll_contractseq, :is_data[3], sysdate, :is_data[3], sysdate, :is_data[4]);
				
				If SQLCA.SQLCODE < 0 Then
					FileClose(li_filepointer)
					f_msg_sql_err(is_title, "Insert Error(validinfo)")
					Rollback;
					Return
				End If
				
				// ADMST_TEMP INSERT
				INSERT INTO admst_temp
					(seq, serialno, makercd, modelno, terminalid, macaddress, validkey, pid,
					 H323ID, partner, result_yn, contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
				VALUES
					(seq_adtempseq.nextval, :ls_serialno, :ls_makercd, :ls_modelno, :ls_terminalid,
					 :ls_macaddress, :ls_E164, :ls_pid, :ls_H323ID, :ls_partner, 'Y', :ll_contractseq, 
					 :is_data[3], :is_data[3], sysdate, sysdate, :is_data[4]);
					 
			   If SQLCA.SQLCODE < 0 Then
					FileClose(li_filepointer)
					f_msg_sql_err(is_title, "insert Error(admst_temp)")
					Rollback;
					Return
				End If
			Else		// Reject된 경우
				INSERT INTO admst_temp
					(seq, serialno, makercd, modelno, terminalid, macaddress, validkey, h323id, partner,
					 result_yn, contractseq, crt_user, updt_user, crtdt, updtdt, pgm_id)
				VALUES
					(SEQ_ADTEMPSEQ.nextval, :ls_serialno, :ls_makercd, :ls_modelno, :ls_terminalid, :ls_macaddress, :ls_E164,
					 :ls_H323ID, :ls_partner, 'N', :ll_contractseq, :is_data[3], :is_data[3], sysdate, sysdate, :is_data[4]);
					 
				If SQLCA.SQLCODE < 0 Then
					f_msg_sql_err(is_title, "Insert Error(admst_temp)")
					Rollback;
					Return
				End If
				
			End If
		Loop
		
		FileClose(li_filepointer)
				
	Commit;						
End Choose

ii_rc = 0

Return
					
					
end subroutine

on p1c_dbmgr1.create
call super::create
end on

on p1c_dbmgr1.destroy
call super::destroy
end on

