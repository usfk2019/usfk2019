$PBExportHeader$b5u_dbmgr_v20.sru
$PBExportComments$[homy]
forward
global type b5u_dbmgr_v20 from u_cust_a_db
end type
end forward

global type b5u_dbmgr_v20 from u_cust_a_db
end type
global b5u_dbmgr_v20 b5u_dbmgr_v20

type prototypes

end prototypes

forward prototypes
public function integer uf_sel_trcode (string as_trcode)
public subroutine uf_prc_db ()
end prototypes

public function integer uf_sel_trcode (string as_trcode);return 0

end function

public subroutine uf_prc_db ();String ls_temp, ls_module, ls_ref_no, ls_ref_desc, ls_result[], ls_ref_content
String ls_MAX_NUMBER, ls_check, ls_dynamic_sql, ls_where , ls_currency_type
Long ll_temp, ll_temp1, ll_temp2
Int li_return, li_tmp
//kwon
string ls_bilcod, ls_bilcodnm, lc_milseq, lc_bilseq,ls_cust
dec{0} ldc_btramt[]
int   li_milseq, li_bilseq,li_bill
// oHcHungHwan
String ls_reqnum, ls_payid, ls_reqdt, ls_reqdt_fr, ls_reqdt_to,ls_pgm_id,ls_chargedt
String ls_reqnum_before, ls_trdt_before, ls_chargeby, ls_userid
Int li_cnt_item, li_cnt_trcod, li_st_item, li_st_trcod
Date ld_reqdt, ld_trdt
Dec lc_amt[15], lc_remain
// KeNN
Boolean lb_update
Long ll_row, ll_rows
String ls_trcod, ls_yn, ls_dc, ls_trdt, ls_paydt, ls_sysdt, ls_summary
String ls_date
Dec{0} lc0_seq, lc0_trcnt, lc0_seq_old
Dec lc_tramt = 0
dwItemStatus ldwis_row
// hhm
String ls_parent
Long ll_cnt
// Call Detail Record
String ls_pid, ls_zonecod, ls_zonenm, ls_stime, ls_biltime 
String ls_rtelnum1, ls_choice, ls_filenm, ls_file, ls_from
String ls_filewrite, ls_subtype, ls_status
Long   ll_filelen
Int    li_filenum, li_read_bytes
Dec{0} lc0_zonecod, lc0_bilamt, lc0_intamt, lc0_pstnamt
// Voucher(거래명세서)
String ls_billdt, ls_closedt, ls_marknm, ls_trcodnm, ls_use
// Tax Bill(세금계산서)
String ls_busnum, ls_chief, ls_addr, ls_bustype, ls_buskind
String ls_busnum_s, ls_addr_s, ls_yy, ls_mm, ls_dd, ls_content
Dec{0} lc0_supply, lc0_tax, lc0_tramt
Int    li_count
Long ll_insrow

// fILE UPDATE 'VGENE'
String ls_file_read, ls_codemode, ls_seq, ls_takedt, ls_reqnum_first, ls_reqnum_last
String ls_amt , ls_giro_type, ls_transdt, ls_inqnum
Long ll_bytes, ll_count, ll_seq, ll_amt, ll_tmp
Dec lc_seq

//parkkh
String ls_btrdesc[]
String ls_desc, ls_tmp
String ls_num_by_ctype

ii_rc = -1

Choose Case is_caller

    Case "CHECK INV MENU"
		// 작성자 : 2005년 05월 16일 박경해 T&C Technology
		// 목  적 : 청구절차메뉴를 check해서 변경된것이 있나 없나를 return한다.
		// 인  자 : is_title = This.Title
		// 		    is_caller = "b5w_prc_reqpgm"
		//		    is_data[1] = ls_chargedt : 청구주기
	
		ls_chargedt = is_data[1]
		
		SELECT count(chargedt)
		INTO :ll_cnt
		FROM reqpgmbase
		WHERE chargedt = :ls_chargedt;
		
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT Error 1(Reqpgmbase): " + is_caller)
			Return			
		End If
		
		If ll_cnt = 0 Then
			ii_rc = 3
			Return
		End If	
		
		SELECT count(chargedt)
		INTO :ll_cnt
		FROM reqpgm
		WHERE chargedt = :ls_chargedt
		  AND pgm_id||call_nm1||to_char(seq) 
				NOT IN ( SELECT  b.pgm_id||b.call_nm1||to_char(b.seq) FROM reqpgmbase a, reqprocmenu b
				          WHERE a.pgm_id = b.pgm_id and a.chargedt = :ls_chargedt);
						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT Error 2(Reqpgm): " + is_caller)
			Return			
		End If
		
		If ll_cnt > 0 Then
			ii_rc = 1
			Return
		End If	
		
		SELECT count(a.chargedt)
		INTO :ll_cnt
		FROM reqpgmbase a, reqprocmenu b
		WHERE a.pgm_id = b.pgm_id
		  AND a.chargedt = :ls_chargedt
		  AND b.pgm_id||b.call_nm1||to_char(b.seq) 
				NOT IN (SELECT  pgm_id||call_nm1||to_char(seq) FROM reqpgm
				WHERE chargedt = :ls_chargedt);
						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT error 3 : " + is_caller)
			Return
		End If	
		If ll_cnt > 0 Then
			ii_rc = 2
			Return
		End If	
		
   Case "REPLACE INV MENU"
		// 작성자 : 2005년 05월 16일 박경해 T&C Technology
		// 목  적 : 청구절차메뉴재구성
		// 인  자 : is_title = This.Title
		// 		   is_caller = "b5w_prc_reqpgm"
		//		   is_data[1] = ls_chargedt : 청구주기
				
		ls_chargedt = is_data[1]
		
		DELETE FROM reqpgm WHERE chargedt = :ls_chargedt;
		
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL DELETE error : " + is_caller)
			Return			
		End If
		
		INSERT INTO reqpgm(chargedt,pgm_id,seq,pgm_nm,call_nm1,close_yn)		
		SELECT  :ls_chargedt,b.pgm_id,b.seq,b.pgm_nm,b.call_nm1,'N' FROM reqpgmbase a, reqprocmenu b
         WHERE a.pgm_id = b.pgm_id
		   and a.chargedt = :ls_chargedt;						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL INSERT error : " + is_caller)
			Return			
		End If
		
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 							"Matching statement Not found.(" + String(is_caller) + ")")
									 
End Choose

ii_rc = 0
end subroutine

on b5u_dbmgr_v20.create
call super::create
end on

on b5u_dbmgr_v20.destroy
call super::destroy
end on

