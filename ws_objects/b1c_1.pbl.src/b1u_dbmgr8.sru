$PBExportHeader$b1u_dbmgr8.sru
$PBExportComments$[islim] 인증Key 생성 DB
forward
global type b1u_dbmgr8 from u_cust_a_db
end type
end forward

global type b1u_dbmgr8 from u_cust_a_db
end type
global b1u_dbmgr8 b1u_dbmgr8

type variables
String is_filename
end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Long li_FileNum, li_write_bytes, li_len, ll_count, ll_seq
String ls_telno, ls_buffer, ls_sysdt
DateTime ldt_from_prcdt, ldt_to_prcdt

Long		ll_rows, ll_rowcnt

Long		ll_iseqno   		//인증키등록 seq
String	ls_validkey			//validkey
String	ls_validkey_type	//인증Key Type
String	ls_status			//개통상태
String   ls_sale_flag 		//재고구분
String   ls_remark, ls_idate
DATETIME ld_idate				//생성일자
String	ls_partner 			//할당대리점
String	ls_partner_prefix //할당대리점Prefix
Long     ll_iqty
String   ls_tmp, ls_name[],ls_ref_desc
decimal{0} ldc_sum_tramt, ldc_tramt
String  ls_filename, ls_file_name
Long ll_bytes, ll_cancelcnt, ll_cnt
Int   li_return
String ls_header, ls_seqno,  ls_filter, ls_reqamt
String ls_prcno, ls_jubank, ls_juacctno, ls_datacode[], ls_receptcod, ls_realcod[]
	
ii_rc = -1

Choose Case is_caller
	Case "b1w_reg_validkey_crt%save"
			//lu_dbmgr.is_caller = "b1w_reg_validkey_crt%save"
			//lu_dbmgr.is_title  = Title
			//lu_dbmgr.idw_data[1] = dw_detail
			//lu_dbmgr.idw_data[2] = dw_master
			//lu_dbmgr.il_data[1] = ll_iseqno
			//lu_dbmgr.il_data[2] = ll_iqty 
			//lu_dbmgr.id_data[1] = ld_idate
			//lu_dbmgr.is_data[1] = ls_validkey_type 
			//lu_dbmgr.is_data[2] = ls_remark

			ll_iseqno = il_data[1]
			ll_iqty   = il_data[2]
			ld_idate  = idt_data[1]
			ls_validkey_type = is_data[1]
			ls_remark = is_data[2]
			
			//상태			
			ls_tmp = fs_get_control("B1", "P400", ls_ref_desc)
			fi_cut_string(ls_tmp, ";", ls_name[])
			ls_status = ls_name[1]
			
			//할당대리점		
			ls_tmp = fs_get_control("A1", "C102", ls_ref_desc)
			ls_partner = ls_tmp			
			
			

			//할당대리점Prefix			
			ls_tmp = fs_get_control("A1", "C101", ls_ref_desc)
			ls_partner_prefix = ls_tmp			


			ls_sale_flag = "0"   //재고구분
			
			ll_rows	= idw_data[1].RowCount()
			
			//dw_master의 생성수량을 실제 입력된 row수로 정정한다.
			idw_data[2].Object.iqty[1] = ll_rows
			
			//validkey crt 에 Insert	
			INSERT INTO validkey_crt
			(iseqno, idate, validkey_type, iqty, remark, crt_user, crtdt, updt_user, updtdt, pgm_id)
			VALUES(:ll_iseqno,:ld_idate,:ls_validkey_type,:ll_iqty,:ls_remark,:gs_user_id,sysdate,:gs_user_id, sysdate,:gs_pgm_id[gi_open_win_no]);
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_Title, "Insert Error(validkey crt)")
				RollBack;
				Return
			End If
		
		
		
			FOR ll_rowcnt=1 TO ll_rows
				ls_validkey	= Trim(idw_data[1].Object.validkey[ll_rowcnt])
				IF IsNull(ls_validkey) THEN ls_validkey = ""
			
				//validkey 체크
				IF ls_validkey = "" THEN
					f_msg_usr_err(200, is_Title, String(ll_rowcnt) + "번 인증Key.")
					idw_data[1].setColumn("validkey")
					idw_data[1].setRow(ll_rowcnt)
					idw_data[1].scrollToRow(ll_rowcnt)
					idw_data[1].setFocus()
					RETURN
				END IF
				

				Int li_cnt
				
				SELECT count(*)
				INTO :li_cnt
				FROM validkeymst
				WHERE validkey = :ls_validkey;
			
				
				IF li_cnt > 0 THEN
					f_msg_usr_err(201, is_Title, String(ll_rowcnt) + "번 인증Key.[" + ls_validkey + "]는 이미 생성된 Key입니다.")
					idw_data[1].setColumn("validkey")
					idw_data[1].setRow(ll_rowcnt)
					idw_data[1].scrollToRow(ll_rowcnt)
					idw_data[1].setFocus()
					RETURN
				END IF
				
		
				//validkeymst  Insert	
				INSERT INTO validkeymst
				(validkey, validkey_type, status, sale_flag, idate, iseqno, partner, partner_prefix, 
				 remark, crt_user, crtdt, updt_user, updtdt, pgm_id)
				VALUES(:ls_validkey,:ls_validkey_type,:ls_status,:ls_sale_flag,:ld_idate,:ll_iseqno,:ls_partner,
				:ls_partner_prefix,:ls_remark,:gs_user_id, sysdate,:gs_user_id, sysdate,:gs_pgm_id[gi_open_win_no]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Insert Error(validkeymst)")
					RollBack;
					Return
				End If
				
				
				//validkeymst_log
				
				INSERT INTO validkeymst_log
				(validkey, seq, status, actdt, partner, crt_user, crtdt, pgm_id)
				VALUES(:ls_validkey, seq_validkeymstlog.nextval ,:ls_status, :ld_idate,:ls_partner,
				:gs_user_id,sysdate,:gs_pgm_id[gi_open_win_no]);
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_Title, "Insert Error(validkeymst_log)")
					RollBack;
					Return
				End If

         NEXT
	
	Case "validkey%Write"
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
			
//			ls_todate = string(today(),'yymmdd')
			
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
			ls_validkey = ls_head + ls_cent + ls_tail + is_data[6] + is_data[5]
			
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

on b1u_dbmgr8.create
call super::create
end on

on b1u_dbmgr8.destroy
call super::destroy
end on

