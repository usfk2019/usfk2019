$PBExportHeader$b5u_dbmgr_ssrt.sru
$PBExportComments$[1hera]
forward
global type b5u_dbmgr_ssrt from u_cust_a_db
end type
end forward

global type b5u_dbmgr_ssrt from u_cust_a_db
end type
global b5u_dbmgr_ssrt b5u_dbmgr_ssrt

type prototypes

end prototypes

forward prototypes
public function integer uf_sel_trcode (string as_trcode)
public subroutine uf_prc_db ()
public subroutine uf_dacom_if ()
end prototypes

public function integer uf_sel_trcode (string as_trcode);//거래코드가 부가세 대상인지 확인
String ls_return
ls_return = ""

SELECT nvl(surtaxyn,'')
INTO :is_data2[1]
FROM TRCODE 
WHERE trcod = :as_trcode;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_title, is_caller + ":TRCODE.SURTAXYN")
	Return -2
ElseIf SQLCA.SQLCode = 100 Then
	f_msg_usr_err(201, is_title, "거래코드에 대한 정보가 없습니다.(" + as_trcode + ")")
	Return -2
End If

Return 0
end function

public subroutine uf_prc_db ();String ls_temp, ls_module, ls_ref_no, ls_ref_desc, ls_result[], ls_ref_content
String ls_MAX_NUMBER, ls_check, ls_dynamic_sql, ls_where , ls_currency_type
Long ll_temp, ll_temp1, ll_temp2
Int li_return, li_tmp
//kwon
string ls_bilcod, ls_bilcodnm, lc_milseq, lc_bilseq,ls_cust
dec{2} ldc_btramt[]
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
String ls_btrdesc[], ls_desc, ls_tmp, ls_num_by_ctype
ii_rc = -1

//1hera add & 
//F_setitem() -->> ssrt_c.pbl
String 	ls_name[]
DEC{2} 	ldc_amt[]
Long		ll_jj, 	ll_col_cnt

Choose Case is_caller
		Case "CUSTOMER REG"
		// 작성자 : 2002년 10월 22일 kwon T&C Technology
		// 목  적 : 고객번호 표시?
		// 인  자 : is_title = This.Title
		// 		   is_caller = "CREATE REQNUM"
		// 반환값 : is_data2[1] ==> 청구번호에 대한 최종 일련번호
		
		ls_temp = fs_get_control("B5", "R102", ls_ref_desc)
		If ls_temp = "" Then Return 
		ls_cust = Trim(ls_temp)
		if ls_cust= 'Y' Then
			idw_data[1].Object.l_4.Visible 			= 1
			idw_data[1].Object.userid_t.Visible 	= 1
			idw_data[1].Object.customerid.Visible 	= 1
			idw_data[1].Object.customernm.Visible	= 1
		Else
			
		End If			
		
		Case "REQAMTINFO BILL"
		// Modify -- 1hera [2007.1.10 ]
		////사업자(주민)번호 구하기(B0:P111)
		//개인고객
		ls_tmp = fs_get_control("B0","P111",ls_desc)
	
		ls_payid = is_data[1]
		idw_data[1].Reset()
		
 		SELECT REQNUM, 
		       BTRAMT01, BTRAMT02, BTRAMT03, BTRAMT04, BTRAMT05,
		       BTRAMT06, BTRAMT07, BTRAMT08, BTRAMT09, BTRAMT10, 
 			    BTRAMT11, BTRAMT12, BTRAMT13, BTRAMT14, BTRAMT15, 
			    BTRAMT16, BTRAMT17, BTRAMT18, BTRAMT19, BTRAMT20, 
			    BTRAMT21, BTRAMT22, BTRAMT23, BTRAMT24, BTRAMT25, 
			    BTRAMT26, BTRAMT27, BTRAMT28, BTRAMT29, BTRAMT30, 
			    nvl(BTRDESC01,''), nvl(BTRDESC02,''), nvl(BTRDESC03,''), nvl(BTRDESC04,''), nvl(BTRDESC05,''),
		       nvl(BTRDESC06,''), nvl(BTRDESC07,''), nvl(BTRDESC08,''), nvl(BTRDESC09,''), nvl(BTRDESC10,''), 
			    nvl(BTRDESC11,''), nvl(BTRDESC12,''), nvl(BTRDESC13,''), nvl(BTRDESC14,''), nvl(BTRDESC15,''),
			    nvl(BTRDESC16,''), nvl(BTRDESC17,''), nvl(BTRDESC18,''), nvl(BTRDESC19,''), nvl(BTRDESC20,''),
			    nvl(BTRDESC21,''), nvl(BTRDESC22,''), nvl(BTRDESC23,''), nvl(BTRDESC24,''), nvl(BTRDESC25,''),
			    nvl(BTRDESC26,''), nvl(BTRDESC27,''), nvl(BTRDESC28,''), nvl(BTRDESC29,''), nvl(BTRDESC30,'')
        into :ls_reqnum, 
		       :ldc_BTRAMT[1],  :ldc_BTRAMT[2],  :ldc_BTRAMT[3],  :ldc_BTRAMT[4],  :ldc_BTRAMT[5],
		       :ldc_BTRAMT[6],  :ldc_BTRAMT[7],  :ldc_BTRAMT[8],  :ldc_BTRAMT[9],  :ldc_BTRAMT[10], 
			    :ldc_BTRAMT[11], :ldc_BTRAMT[12], :ldc_BTRAMT[13], :ldc_BTRAMT[14], :ldc_BTRAMT[15],
			    :ldc_BTRAMT[16], :ldc_BTRAMT[17], :ldc_BTRAMT[18], :ldc_BTRAMT[19], :ldc_BTRAMT[20],
			    :ldc_BTRAMT[21], :ldc_BTRAMT[22], :ldc_BTRAMT[23], :ldc_BTRAMT[24], :ldc_BTRAMT[25],
			    :ldc_BTRAMT[26], :ldc_BTRAMT[27], :ldc_BTRAMT[28], :ldc_BTRAMT[29], :ldc_BTRAMT[30],
			    :ls_btrdesc[1],  :ls_btrdesc[2],  :ls_btrdesc[3],  :ls_btrdesc[4],  :ls_btrdesc[5],
		       :ls_btrdesc[6],  :ls_btrdesc[7],  :ls_btrdesc[8],  :ls_btrdesc[9],  :ls_btrdesc[10], 
			    :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15],
		       :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20], 
			    :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25],
		       :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30] 
	     FROM ( select REQNUM,
		                BTRAMT01,  BTRAMT02,  BTRAMT03,  BTRAMT04,  BTRAMT05,
		       		    BTRAMT06,  BTRAMT07,  BTRAMT08,  BTRAMT09,  BTRAMT10,
    				       BTRAMT11,  BTRAMT12,  BTRAMT13,  BTRAMT14,  BTRAMT15,
		       		    BTRAMT16,  BTRAMT17,  BTRAMT18,  BTRAMT19,  BTRAMT20,
    				       BTRAMT21,  BTRAMT22,  BTRAMT23,  BTRAMT24,  BTRAMT25,
		       		    BTRAMT26,  BTRAMT27,  BTRAMT28,  BTRAMT29,  BTRAMT30,
					   	 BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05,
					   	 BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
					   	 BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15,
					   	 BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20, 
					   	 BTRDESC21, BTRDESC22, BTRDESC23, BTRDESC24, BTRDESC25,
					   	 BTRDESC26, BTRDESC27, BTRDESC28, BTRDESC29, BTRDESC30
			    from REQAMTINFO
			  WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]
			 union all
			   select REQNUM,
				       BTRAMT01,  BTRAMT02,  BTRAMT03,  BTRAMT04,  BTRAMT05,
	       		    BTRAMT06,  BTRAMT07,  BTRAMT08,  BTRAMT09,  BTRAMT10,
  				       BTRAMT11,  BTRAMT12,  BTRAMT13,  BTRAMT14,  BTRAMT15,
	       		    BTRAMT16,  BTRAMT17,  BTRAMT18,  BTRAMT19,  BTRAMT20,
  				       BTRAMT21,  BTRAMT22,  BTRAMT23,  BTRAMT24,  BTRAMT25,
	       		    BTRAMT26,  BTRAMT27,  BTRAMT28,  BTRAMT29,  BTRAMT30,
				   	 BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05,
				   	 BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
				   	 BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15,
				   	 BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20, 
				   	 BTRDESC21, BTRDESC22, BTRDESC23, BTRDESC24, BTRDESC25,
				   	 BTRDESC26, BTRDESC27, BTRDESC28, BTRDESC29, BTRDESC30
				from REQAMTINFOH
			  WHERE PAYID = :is_data[1]
				AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]);
		
		select currency_type, no
		Into :ls_currency_type, :ls_num_by_ctype
		from (select currency_type, DECODE(ctype2,:ls_tmp,ssno,cregno) no from reqinfo  WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]
				union all
				select currency_type, DECODE(ctype2,:ls_tmp,ssno,cregno) no from reqinfoh WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]);
					
		idw_data[1].object.currency_type[1] = ls_currency_type

		is_data[3] = ls_num_by_ctype
		IF LEN(ls_num_by_ctype) = 13 THEN
			is_data[3] = MID(ls_num_by_ctype,1,6) + "-" + MID(ls_num_by_ctype,7,7)
		ELSEIF LEN(ls_num_by_ctype) = 10 THEN
			is_data[3] = MID(ls_num_by_ctype,1,3) + "-" + MID(ls_num_by_ctype,4,2) + "-" + MID(ls_num_by_ctype,6,5)
		END IF
		
		idw_data[1].Modify("t_no.text= '" + is_data[3] + "'" )
		idw_data[1].Object.reqnum[1] = ls_reqnum
		ll_col_cnt = 0
		FOR ll_jj =  1 to 30
			ls_name[ll_jj] = ''
			ldc_amt[ll_jj] = 0
 		NEXT
		FOR ll_jj =  1 to 30
			IF ldc_BTRAMT[ll_jj] <> 0 then
				ll_col_cnt += 1
				ls_name[ll_col_cnt] = ls_btrdesc[ll_jj]
				ldc_amt[ll_col_cnt] = ldc_BTRAMT[ll_jj]
			END IF
 		NEXT
		f_setitem(idw_data[1], "amt_1",  "amtnm_1",  ls_name[1],  ldc_AMT[1] )
		f_setitem(idw_data[1], "amt_2",  "amtnm_2",  ls_name[2],  ldc_AMT[2] )
		f_setitem(idw_data[1], "amt_3",  "amtnm_3",  ls_name[3],  ldc_AMT[3] )
		f_setitem(idw_data[1], "amt_4",  "amtnm_4",  ls_name[4],  ldc_AMT[4] )
		f_setitem(idw_data[1], "amt_5",  "amtnm_5",  ls_name[5],  ldc_AMT[5] )
		f_setitem(idw_data[1], "amt_6",  "amtnm_6",  ls_name[6],  ldc_AMT[6] )
		f_setitem(idw_data[1], "amt_7",  "amtnm_7",  ls_name[7],  ldc_AMT[7] )
		f_setitem(idw_data[1], "amt_8",  "amtnm_8",  ls_name[8],  ldc_AMT[8] )
		f_setitem(idw_data[1], "amt_9",  "amtnm_9",  ls_name[9],  ldc_AMT[9] )
		f_setitem(idw_data[1], "amt_10", "amtnm_10", ls_name[10], ldc_AMT[10] )
		f_setitem(idw_data[1], "amt_11", "amtnm_11", ls_name[11], ldc_AMT[11] )
		f_setitem(idw_data[1], "amt_12", "amtnm_12", ls_name[12], ldc_AMT[12] )
		f_setitem(idw_data[1], "amt_13", "amtnm_13", ls_name[13], ldc_AMT[13] )
		f_setitem(idw_data[1], "amt_14", "amtnm_14", ls_name[14], ldc_AMT[14] )
		f_setitem(idw_data[1], "amt_15", "amtnm_15", ls_name[15], ldc_AMT[15] )
		
		f_setitem(idw_data[1], "amt_21", "amtnm_21", ls_name[16], ldc_AMT[16] )
		f_setitem(idw_data[1], "amt_22", "amtnm_22", ls_name[17], ldc_AMT[17] )
		f_setitem(idw_data[1], "amt_23", "amtnm_23", ls_name[18], ldc_AMT[18] )
		f_setitem(idw_data[1], "amt_24", "amtnm_24", ls_name[19], ldc_AMT[19] )
		f_setitem(idw_data[1], "amt_25", "amtnm_25", ls_name[20], ldc_AMT[20] )
		f_setitem(idw_data[1], "amt_26", "amtnm_26", ls_name[21], ldc_AMT[21] )
		f_setitem(idw_data[1], "amt_27", "amtnm_27", ls_name[22], ldc_AMT[22] )
		f_setitem(idw_data[1], "amt_28", "amtnm_28", ls_name[23], ldc_AMT[23] )
		f_setitem(idw_data[1], "amt_29", "amtnm_29", ls_name[24], ldc_AMT[24] )
		f_setitem(idw_data[1], "amt_30", "amtnm_30", ls_name[25], ldc_AMT[25] )
		f_setitem(idw_data[1], "amt_31", "amtnm_31", ls_name[26], ldc_AMT[26] )
		f_setitem(idw_data[1], "amt_32", "amtnm_32", ls_name[27], ldc_AMT[27] )
		f_setitem(idw_data[1], "amt_33", "amtnm_33", ls_name[28], ldc_AMT[28] )
		f_setitem(idw_data[1], "amt_34", "amtnm_34", ls_name[29], ldc_AMT[29] )
		f_setitem(idw_data[1], "amt_35", "amtnm_35", ls_name[30], ldc_AMT[30] )

	Case "REQAMTINFO BILL 2"
		// WINDOW : b5w_inq_reqinfo_bill.dw_master.clicked
		// 작성자 :  2002년 10월 01일 kwon T&C Technology
		// 목  적 : 청구서 내역 조회
		
		////사업자(주민)번호 구하기(B0:P111)
		//개인고객
		ls_tmp = fs_get_control("B0","P111",ls_desc)
		
		ls_payid = is_data[1]
		idw_data[1].Reset()
		
 		SELECT BTRAMT01, BTRAMT02, BTRAMT03, BTRAMT04, BTRAMT05,
		       BTRAMT06, BTRAMT07, BTRAMT08, BTRAMT09, BTRAMT10, 
			   BTRAMT11, BTRAMT12, BTRAMT13, BTRAMT14, BTRAMT15, 
				BTRAMT16, BTRAMT17, BTRAMT18, BTRAMT19, BTRAMT20, 
			   nvl(BTRDESC01,''), nvl(BTRDESC02,''), nvl(BTRDESC03,''), nvl(BTRDESC04,''), nvl(BTRDESC05,''),
		       nvl(BTRDESC06,''), nvl(BTRDESC07,''), nvl(BTRDESC08,''), nvl(BTRDESC09,''), nvl(BTRDESC10,''), 
			   nvl(BTRDESC11,''), nvl(BTRDESC12,''), nvl(BTRDESC13,''), nvl(BTRDESC14,''), nvl(BTRDESC15,''),
  	         nvl(BTRDESC16,''), nvl(BTRDESC17,''), nvl(BTRDESC18,''), nvl(BTRDESC19,''), nvl(BTRDESC20,'')
        into :ldc_BTRAMT[1], :ldc_BTRAMT[2], :ldc_BTRAMT[3], :ldc_BTRAMT[4], :ldc_BTRAMT[5],
		       :ldc_BTRAMT[6], :ldc_BTRAMT[7], :ldc_BTRAMT[8], :ldc_BTRAMT[9], :ldc_BTRAMT[10], 				 
			   :ldc_BTRAMT[11], :ldc_BTRAMT[12], :ldc_BTRAMT[13], :ldc_BTRAMT[14], :ldc_BTRAMT[15],
		       :ldc_BTRAMT[16], :ldc_BTRAMT[17], :ldc_BTRAMT[18], :ldc_BTRAMT[19], :ldc_BTRAMT[20], 				
			   :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5],
		       :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10], 
			   :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15],
		       :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 				
	     FROM ( select BTRAMT01, BTRAMT02, BTRAMT03, BTRAMT04, BTRAMT05,
		       		   BTRAMT06, BTRAMT07, BTRAMT08, BTRAMT09, BTRAMT10,
    				   BTRAMT11, BTRAMT12, BTRAMT13, BTRAMT14, BTRAMT15,
    				   BTRAMT16, BTRAMT17, BTRAMT18, BTRAMT19, BTRAMT20,						 
					   BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05,
					   BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
					   BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15,
					   BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20						
			    from REQAMTINFO
			  WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]
			 union all
			   select BTRAMT01, BTRAMT02, BTRAMT03, BTRAMT04, BTRAMT05,
				      BTRAMT06, BTRAMT07, BTRAMT08, BTRAMT09, BTRAMT10,
    				  BTRAMT11, BTRAMT12, BTRAMT13, BTRAMT14, BTRAMT15,
    				   BTRAMT16, BTRAMT17, BTRAMT18, BTRAMT19, BTRAMT20,						
					   BTRDESC01, BTRDESC02, BTRDESC03, BTRDESC04, BTRDESC05,
					   BTRDESC06, BTRDESC07, BTRDESC08, BTRDESC09, BTRDESC10, 
					   BTRDESC11, BTRDESC12, BTRDESC13, BTRDESC14, BTRDESC15,
					   BTRDESC16, BTRDESC17, BTRDESC18, BTRDESC19, BTRDESC20								
				from REQAMTINFOH
			  WHERE PAYID = :is_data[1]
				AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]);
		
		select currency_type, no
		Into :ls_currency_type, :ls_num_by_ctype
		from (select currency_type, DECODE(ctype2,:ls_tmp,ssno,cregno) no from reqinfo  WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]
				union all
				select currency_type, DECODE(ctype2,:ls_tmp,ssno,cregno) no from reqinfoh WHERE PAYID = :is_data[1]
		   		AND TO_CHAR(TRDT,'yyyymmdd') = :is_data[2]);
					
		idw_data[1].object.currency_type[1] = ls_currency_type

		is_data[3] = ls_num_by_ctype
		IF LEN(ls_num_by_ctype) = 13 THEN
			is_data[3] = MID(ls_num_by_ctype,1,6) + "-" + MID(ls_num_by_ctype,7,7)
		ELSEIF LEN(ls_num_by_ctype) = 10 THEN
			is_data[3] = MID(ls_num_by_ctype,1,3) + "-" + MID(ls_num_by_ctype,4,2) + "-" + MID(ls_num_by_ctype,6,5)
		END IF
		
		idw_data[1].Modify("t_no.text= '" + is_data[3] + "'" )
		f_setitem(idw_data[1], "amt_1",  "amtnm_1",  ls_btrdesc[1],  ldc_BTRAMT[1] )
		f_setitem(idw_data[1], "amt_2",  "amtnm_2",  ls_btrdesc[2],  ldc_BTRAMT[2] )
		f_setitem(idw_data[1], "amt_3",  "amtnm_3",  ls_btrdesc[3],  ldc_BTRAMT[3] )
		f_setitem(idw_data[1], "amt_4",  "amtnm_4",  ls_btrdesc[4],  ldc_BTRAMT[4] )
		f_setitem(idw_data[1], "amt_5",  "amtnm_5",  ls_btrdesc[5],  ldc_BTRAMT[5] )
		f_setitem(idw_data[1], "amt_6",  "amtnm_6",  ls_btrdesc[6],  ldc_BTRAMT[6] )
		f_setitem(idw_data[1], "amt_7",  "amtnm_7",  ls_btrdesc[7],  ldc_BTRAMT[7] )
		f_setitem(idw_data[1], "amt_8",  "amtnm_8",  ls_btrdesc[8],  ldc_BTRAMT[8] )
		f_setitem(idw_data[1], "amt_9",  "amtnm_9",  ls_btrdesc[9],  ldc_BTRAMT[9] )
		f_setitem(idw_data[1], "amt_10", "amtnm_10", ls_btrdesc[10], ldc_BTRAMT[10] )
		f_setitem(idw_data[1], "amt_11", "amtnm_11", ls_btrdesc[11], ldc_BTRAMT[11] )
		f_setitem(idw_data[1], "amt_12", "amtnm_12", ls_btrdesc[12], ldc_BTRAMT[12] )
		f_setitem(idw_data[1], "amt_13", "amtnm_13", ls_btrdesc[13], ldc_BTRAMT[13] )
		f_setitem(idw_data[1], "amt_14", "amtnm_14", ls_btrdesc[14], ldc_BTRAMT[14] )
		f_setitem(idw_data[1], "amt_15", "amtnm_15", ls_btrdesc[15], ldc_BTRAMT[15] )

		f_setitem(idw_data[1], "amt_21", "amtnm_21", ls_btrdesc[16], ldc_BTRAMT[16] )
		f_setitem(idw_data[1], "amt_22", "amtnm_22", ls_btrdesc[17], ldc_BTRAMT[17] )
		f_setitem(idw_data[1], "amt_23", "amtnm_23", ls_btrdesc[18], ldc_BTRAMT[18] )
		f_setitem(idw_data[1], "amt_24", "amtnm_24", ls_btrdesc[19], ldc_BTRAMT[19] )
		f_setitem(idw_data[1], "amt_25", "amtnm_25", ls_btrdesc[20], ldc_BTRAMT[20] )
	Case "MAX SEQUENCE"
		// 작성자 : 1999년 10월 5일 오충환 T&C Technology
		// 목  적 : 청구번호의 최종 일련번호 
		// 인  자 : is_title = This.Title
		// 		   is_caller = "MAX SEQUENCE"
		//		      is_data[1] = ls_reqnum  : 청구번호
		//
		// 반환값 : il_data[1] ==> 청구번호에 대한 최종 일련번호
		
		ls_reqnum = is_data[1]
		SELECT max(seq)
		INTO :il_data[1]
		FROM reqdtl
		WHERE reqnum = :ls_reqnum;
		If SQLCA.SQLCode < 0 Then
			MessageBox(is_title, "SQL SELECT error : " + is_caller)
			Return
		End If
		
	Case "CREATE REQNUM"
		// 작성자 : 1999년 10월 6일 오충환 T&C Technology
		// 목  적 : 새로운 청구번호 만들기
		// 인  자 : is_title = This.Title
		// 		   is_caller = "CREATE REQNUM"
		//
		// 반환값 : is_data2[1] ==> 청구번호에 대한 최종 일련번호
		
		// SYSCTL1T의 마지막 청구번호 
		ls_module = "B5"
		ls_ref_no = "R101"
		ls_ref_desc = ""
		ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result[])
		ls_reqnum = ls_result[1]
		
		ls_MAX_NUMBER = "9999999"	
		If Dec(ls_reqnum) >= Dec(ls_MAX_NUMBER) Then
			MessageBox(is_title, "청구번호를 더이상 생성 할 수 없습니다." + &
			                     "~r~n(관리자에게 문의 바랍니다.)")
			Return							
		End If
		
		ls_temp = String(Dec(ls_reqnum) + 1, "###0")
		ls_reqnum = fs_fill_zeroes(ls_temp, -7)
		is_data2[1] = ls_reqnum
		
		//최종 청구번호를 저장
		ls_module = "B5"
		ls_ref_no = "C101"
		ls_ref_content = ls_reqnum
		li_return = -1
		li_return = fi_set_control(ls_module, ls_ref_no, ls_ref_content)
		If li_return <> 0 Then Return
		
	Case "MARK NAME"
		// 작성자 : 1999년 10월 6일 오충환 T&C Technology
		// 목  적 : 납입자명 읽기
		// 인  자 : is_title = This.Title
		// 		   is_caller = "MARK NAME"
		//				is_data[1] = ls_payid_fr
		//
		// 반환값 : is_data2[1] ==> 납입자명
		
		ls_payid = is_data[1]
		
		SELECT marknm
		INTO :ls_temp
		FROM paymst
		WHERE payid = :ls_payid;
		If SQLCA.SQLCode <> 0 Then Return
		is_data2[1] = ls_temp	
		
	Case "BILL CYCLE"
		// 작성자 : 1999년 10월 6일 오충환 T&C Technology
		// 목  적 : 청구 주기 
		// 인  자 : is_title = Parent.Title
		// 		   is_caller = "BILL CYCLE"
		//				is_data[1] = ls_payid_fr
		//
		// 반환값 : is_data2[1] ==> 청구주기 시작일
 		//				is_data2[2] ==> 청구주기 종료일
		
		ls_payid = is_data[1]
		
		// 당월 청구 주기 
		SELECT reqconf.reqdt
		INTO  :ls_reqdt
		FROM  reqconf, paymst
		WHERE paymst.payid = :ls_payid
		AND   reqconf.chargedt = paymst.chargedt;
		If SQLCA.SQLCode <> 0 Then Return
		
		// 이전월(청구주기 시작일)
		ls_temp = Mid(ls_reqdt, 1, 4) + "-" + Mid(ls_reqdt, 5, 2) + "-" + Mid(ls_reqdt, 7, 2)
		//ls_temp = String(ls_reqdt,"yyyy-mm-dd")
		ld_reqdt = fd_pre_month(Date(ls_temp),1)
		ls_reqdt_fr = String(ld_reqdt,"yyyymmdd")
		ll_temp1 = Long(Mid(ls_reqdt_fr,1,4))
		ll_temp2 = Long(Mid(ls_reqdt_fr,5,2))
		// 지정월의 마지막일 
		ll_temp = fl_date_count_in_month(ll_temp1, ll_temp2)
		// 청구주기 종료일
		ll_temp = ll_temp - 1
      ld_reqdt = fd_date_next(ld_reqdt, ll_temp)
		ls_reqdt_to = String(ld_reqdt,"yyyymmdd")
		
		is_data2[1] = ls_reqdt_fr
		is_data2[2] = ls_reqdt_to

	//**** kenn : 1999-10-11 월 **************************************************
	Case "Create Transaction By Manually Operated"
		//ii_data[1]  : 1;신규당월/2;기존당월/3;기존기타
		//is_data[1]  : 고객번호
		//is_data[2]  : Master DW에서 선택된 청구번호/신규청구번호
		//is_data[3]  : Master DW에서 선택된 청구년월/신규청구년월
		//ic_data[1]  : 마지막 SEQ#
		//idw_data[1] : Detail DW
		lb_update = False
		
		//일련번호
		lc0_seq = ic_data[1]
		ls_payid = is_data[1]
		
		//현재일자
		ls_sysdt = String(fdt_get_dbserver_now(), "yyyymmdd")

		ll_rows = idw_data[1].RowCount()
		For ll_row = 1 To ll_rows
			ldwis_row = idw_data[1].GetItemStatus(ll_row, 0, Primary!)
			Choose Case ldwis_row
				Case NotModified!		//할일없슴
				Case New!				//먼저 확인하므로 발생안한다.
				Case DataModified!
					//삭제 Routine
					lc0_seq_old = idw_data[1].Object.seq[ll_row]
					ls_userid = Trim(idw_data[1].Object.userid[ll_row])
					ls_trcod = Trim(idw_data[1].Object.trcod[ll_row])
					lc_tramt = idw_data[1].Object.tramt[ll_row]
					ls_trdt = Trim(idw_data[1].Object.trdt[ll_row])
					ls_paydt = Trim(idw_data[1].Object.paydt[ll_row])
					lc0_trcnt = idw_data[1].Object.trcnt[ll_row]
					ls_summary = "청구번호" + is_data[2] + ", " + "일련번호" + String(lc0_seq_old, "###0") + "(으)로부터 이관"

					If IsNull(ls_userid) Then ls_userid = ""
					If IsNull(ls_trcod) Then ls_trcod = ""
					If IsNull(lc_tramt) Then lc_tramt = 0
					If IsNull(ls_trdt) Then ls_trdt = ""
					If IsNull(ls_paydt) Then ls_paydt = ""
					If IsNull(lc0_trcnt) Then lc0_trcnt = 0
					If IsNull(ls_summary) Then ls_summary = ""

					//반대거래이므로 * -1
					lc_tramt *= -1

					//원시자료의 삭제표시
					UPDATE REQDTL SET mark = 'D' WHERE seq = :lc0_seq_old AND reqnum = :is_data[2];
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + "UPDATE:REQDTL 1")
						Return
					End If

					//마지막 SEQ# 증가
					lc0_seq += 1

					//SQL
					INSERT INTO REQDTL(reqnum, seq, payid, userid, trdt, paydt, sysdt, trcod, tramt, trcnt, summary, mark)
					VALUES(:is_data[2], :lc0_seq, :ls_payid, :ls_userid, :ls_trdt, :ls_paydt, :ls_sysdt, :ls_trcod, :lc_tramt, :lc0_trcnt, :ls_summary, 'D');
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + ":INSERT REQDTL 2")
						Return
					End If
					
					li_return = uf_sel_trcode(ls_trcod)
					If li_return < 0 Then Return
					//부가세 대상 거래의 경우만 공급가,부가세 수정
					If is_data2[1] = "Y" Then
						SELECT supplyamt INTO :lc0_supply 
						FROM reqinfo WHERE payid = :ls_payid and trdt = :ls_trdt;
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + ":SELECT REQINFO 3")
							Return
						End If
						lc0_supply = lc0_supply - lc_tramt
						lc0_tax = lc0_supply / 10
						
						UPDATE reqinfo SET supplyamt = :lc0_supply, surtax = :lc0_tax 
						WHERE payid = :ls_payid and trdt = :ls_trdt;
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + ":UPDATE REQINFO 4")
							Return
						End If
					End If
						
					lb_update = True

				Case NewModified!
					//추가 Routine
					ls_userid = Trim(idw_data[1].Object.userid[ll_row])
					ls_trcod = Trim(idw_data[1].Object.trcod[ll_row])
					lc_tramt = idw_data[1].Object.tramt[ll_row]
					ls_paydt = Trim(idw_data[1].Object.paydt[ll_row])
					lc0_trcnt = idw_data[1].Object.trcnt[ll_row]
					ls_summary = Trim(idw_data[1].Object.summary[ll_row])

					If IsNull(ls_userid) Then ls_userid = ""
					If IsNull(ls_trcod) Then ls_trcod = ""
					If IsNull(lc_tramt) Then lc_tramt = 0
					If IsNull(ls_paydt) Then ls_paydt = ""
					If IsNull(lc0_trcnt) Then lc0_trcnt = 0
					If IsNull(ls_summary) Then ls_summary = ""

					//거래코드의 DC_TYPE, 입금코드인지 확인
					SELECT nvl(in_yn, ''), nvl(dctype, '') INTO :ls_yn, :ls_dc FROM TRCODE WHERE trcod = :ls_trcod;
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + ":TRCODE.IN_YN,DCTYPE 5")
						Return
					ElseIf SQLCA.SQLCode = 100 Then
						f_msg_usr_err(201, is_title, "거래코드에 대한 정보가 없습니다.(" + ls_trcod + ")")
						Return
					End If
					ls_trdt = is_data[3]
					If Upper(ls_yn) <> "Y" Then ls_paydt = ls_trdt
					If Upper(ls_dc) = "C" Then lc_tramt *= -1

					//마지막 SEQ# 증가
					lc0_seq += 1

					//SQL
					INSERT INTO REQDTL(reqnum, seq, payid, userid, trdt, paydt, sysdt, trcod, tramt, trcnt, summary)
					VALUES(:is_data[2], :lc0_seq, :ls_payid, :ls_userid, :ls_trdt, :ls_paydt, sysdate, :ls_trcod, :lc_tramt, :lc0_trcnt, :ls_summary);
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + ":INSERT REQDTL 6")
						Return
					End If
					
					li_return = uf_sel_trcode(ls_trcod)
					If li_return < 0 Then Return
					// REQINFO에 자료 있는지 확인(연체자의 경우 당월 청구자료 없어도 세금계산서 자료는 존재)
					SELECT count(*) INTO :li_count FROM reqinfo WhERE payid = :ls_payid AND trdt = :ls_trdt;
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + ":SELECT REQINFO 7")
						Return
					End If
					
					//신규 거래
					If li_count = 0 Then
						//부가세 대상 거래 경우 
						If is_data2[1] = "Y" Then
							lc0_supply = lc_tramt
							lc0_tax = lc0_supply / 10
						Else 
							lc0_supply = 0
							lc0_tax = 0
						End If
						
						SELECT chargeby, chargedt INTO :ls_chargeby, :ls_chargedt FROM paymst WHERE payid = :ls_payid;
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + ":SELECT PAYMST 8")
							Return
						End If
						
						INSERT INTO reqinfo
						 (payid, chargedt, trdt, reqnum, supplyamt, surtax)
						VALUES (:ls_payid, :ls_chargedt, :ls_trdt, :is_data[2], :lc0_supply, :lc0_tax);
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + ":INSERT REQINFO 9")
							Return
						End If
						
						UPDATE reqinfo 
						SET (CHARGEDT,MARKNM,MARKID,MANNUM,BUSNUM,CHIEF,BUSTYPE,BUSKIND, 
							  POST, ADDR, ADDR2, DEPT, MAN, CHARGEBY,INV_SEND, DCCOD, FAX, EMAIL, BIL_YN) = 
							 (SELECT chargedt,marknm,comtype,mannum,busnum,partner_chief,bustype,buskind,
										post,addr,addr2,DEPT,MAN,chargeby,INV_SEND,DCCODE,FAX,EMAIL,bil_yn
							  FROM paymst WHERE payid = :ls_payid)
						WHERE payid = :ls_payid and trdt = :ls_trdt;
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + ":UPDATE REQINFO 10")
							Return
						End If
						
						If ls_chargeby <> "1" Then
							UPDATE reqinfo 
							SET (ACC_MANNUM, BANK, ACCOUNT, OWNER, CMSREQTYPE, CMSREQYN, CARDTAG, CARDTYPE, CARDNM, ENDDT, ENGMAN) = 
								 (SELECT mannum,bank,account,owner,cmsreqtype,cmsreqyn,cardtag,cardtype,cardnm,enddt,engman
								  FROM payadd1 WHERE payid = :ls_payid)
							WHERE payid = :ls_payid and trdt = :ls_trdt;
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + ":UPDATE REQINFO 11")
								Return
							End If
						End If
					Else
						//부가세 대상 거래  경우만 공급가,부가세 수정 
						If is_data2[1] = "Y" Then
							SELECT supplyamt INTO :lc0_supply 
							FROM reqinfo WHERE payid = :ls_payid and trdt = :ls_trdt;
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + ":SELECT REQINFO 12")
								Return
							End If
							lc0_supply = lc0_supply + lc_tramt
							lc0_tax = lc0_supply / 10
													
							UPDATE reqinfo SET supplyamt = :lc0_supply, surtax = :lc0_tax 
							WHERE payid = :ls_payid and trdt = :ls_trdt;
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + ":UPDATE REQINFO 13")
								Return
							End If
						End If
					End If
					
					lb_update = True
			End Choose
		Next
		
		//최종 청구번호를 저장
		If lb_update And ii_data[1] = 1 Then
			ls_module = "B5"
			ls_ref_no = "R101"
			ls_ref_desc = ""
			ls_ref_content = is_data[2]
			li_return = fi_set_control(ls_module, ls_ref_no, ls_ref_content)
			If li_return <> 0 Then Return
		End If
	//****************************************************************************
			
	Case "Check ReqProcess close_yn"
		// 작성자 : 1999년 10월 12일 황현미 T&C Technology
		// 목  적 : 각단계별 청구Process 작업완료여부 CHECK 
		// 인  자 : is_title = This.Title
		// 		   is_caller = "Check ReqProcess close_yn"
		//		      is_data[1] = ls_pgm_id : 청구process pgm_id
		//          is_data[2] = ls_chargedt :청구주기
		// 반환값 : is_data[3] ==> 작업이미완료여부check 
		
		ls_pgm_id = is_data[1]
		ls_chargedt = is_data[2]
		
		SELECT close_yn
		INTO :is_data[3]
		FROM reqpgm
		WHERE chargedt = :ls_chargedt AND
		      pgm_id = :ls_pgm_id;
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT error : " + is_caller)
			Return
		End If
		
	Case "CHECK INV MENU"
		// 작성자 : 1999년 11월 09일 황현미 T&C Technology
		// 목  적 : 청구절차메뉴를 check해서 변경된것이 있나 없나를 return한다.
		// 인  자 : is_title = This.Title
		// 		   is_caller = "b5w_prc_reqpgm"
		//		      is_data[1] = ls_chargedt : 청구주기
		//          is_data[2] = ls_parent :청구절차메뉴들의 parent id
		//          is_data[3] = ls_pgmid:청구절차수집pgm menu 
	
		
		ls_chargedt = is_data[1]
		ls_parent = is_data[2]
		ls_pgm_id = is_data[3]
		
		SELECT count(*)
		INTO :ll_cnt
		FROM reqpgm
		WHERE chargedt = :ls_chargedt AND
		      pgm_id||call_nm1||to_char(seq) 
				NOT IN(SELECT  pgm_id||call_nm1||to_char(seq) FROM SYSPGM1T 
				       WHERE p_pgm_id = :ls_parent and pgm_id <> :ls_pgm_id);
						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT error : " + is_caller)
			Return			
		End If
		
		If ll_cnt > 0 Then
			ii_rc = 1
			Return
		End If	
		
		SELECT count(*)
		INTO :ll_cnt
		FROM syspgm1t
		WHERE p_pgm_id = :ls_parent and pgm_id <> :ls_pgm_id and
		      pgm_id||call_nm1||to_char(seq) 
				NOT IN(SELECT  pgm_id||call_nm1||to_char(seq) FROM reqpgm
				WHERE chargedt = :ls_chargedt);
						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL SELECT error : " + is_caller)
			Return
		End If	
		If ll_cnt > 0 Then
			ii_rc = 2
			Return
		End If	
		
   Case "REPLACE INV MENU"
		// 작성자 : 1999년 11월 15일 황현미 T&C Technology
		// 목  적 : 청구절차메뉴재구성
		// 인  자 : is_title = This.Title
		// 		   is_caller = "b5w_prc_reqpgm"
		//		      is_data[1] = ls_chargedt : 청구주기
		//          is_data[2] = ls_parent :청구절차메뉴들의 parent id
		//          is_data[3] = ls_pgmid:청구절차수집pgm menu 
				
		ls_chargedt = is_data[1]
		ls_parent = is_data[2]
		ls_pgm_id = is_data[3]
		
		DELETE FROM reqpgm WHERE chargedt = :ls_chargedt;
		
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL DELETE error : " + is_caller)
			Return			
		End If
		
		INSERT INTO reqpgm(chargedt,pgm_id,seq,pgm_nm,call_nm1,close_yn)		
		SELECT  :ls_chargedt,pgm_id,seq,pgm_nm,call_nm1,'N' FROM SYSPGM1T 
				       WHERE p_pgm_id = :ls_parent and pgm_id <> :ls_pgm_id;
						 
				
		If SQLCA.SQLCode <> 0 Then
			MessageBox(is_title, "SQL INSERT error : " + is_caller)
			Return			
		End If
		
	Case "SAVE TO FILE" 
		// 작성자 : 2000년 01월 04일 오충환 T&C Technology
		// WINDOW : b5w_prt_cdr_list	
		// 목  적 : 가입자(SUBMST)파일 읽어서 DB(SUBMST)에 저장
		// 인  자 : is_title  = This.Title
		//			   is_caller = "SAVE TO FILE" 
		//	   		is_data[1] : ls_where
		//				is_data[2] : choice (either bilcdr Or bilcdrh)
		//				is_data[3] : 파일명(FULL PATH)
		// 반환값 : is_data2[1] ==> 작업한 열의 수
		ls_where  = is_data[1]
		ls_choice = is_data[2]
		ls_filenm = is_data[3]
		If ls_choice = "C" Then
			ls_from = "bilcdr"
		ElseIf ls_choice = "H" Then
			ls_from = "bilcdrh"
		End If
		
		//1.Start File Read  
		ll_filelen = FileLength(ls_filenm)
		li_filenum = FileOpen(ls_filenm, LineMode!, Write!, LockWrite!, Replace!)
      
		ls_filewrite  = "사업자고객번호" + ";" + "가입자ID" + ";" + "대역" + ";" + "대역명" 
		ls_filewrite += ";" + "통화시작" + ";" + "통화시간(초)" + ";" + "착신전화번호" 
      ls_filewrite += ";" + "시외료" + ";" + "국제료" + ";" + "접속료"
		li_read_bytes = FileWrite(li_filenum, ls_filewrite)
		
		//2.DATA Read 위해서 Dynamic Cursor 이용
		Declare cur_read_bilcdr Dynamic Cursor For Sqlsa;
		ls_dynamic_sql = "SELECT PAYID, PID, ZONECOD, ZONENM, to_char(STIME1, 'yyyy-mm-dd hh24:mi:ss'), BILTIME, " + &
		                 "       RTELNUM1, BILAMT, INTAMT, PSTNAMT " 
		ls_dynamic_sql += " FROM " + ls_from  
		
		If ls_where <> "" Then
			ls_dynamic_sql += " Where " + ls_where
		End If
		ls_dynamic_sql += " ORDER BY PAYID ASC, ZONECOD ASC, STIME1 ASC "  
		
		Prepare SQLSA From :ls_dynamic_sql;
		Open Dynamic cur_read_bilcdr;
		Do While (True)
			Fetch cur_read_bilcdr 
			Into :ls_payid, :ls_pid, :lc0_zonecod, :ls_zonenm, :ls_stime, :ls_biltime,  
		        :ls_rtelnum1, :lc0_bilamt, :lc0_intamt, :lc0_pstnamt ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_adtrcod")
				Close cur_read_bilcdr;
				FileClose(li_filenum)
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ls_filewrite  = ""
			
			If Not IsNull(ls_payid) Then ls_filewrite += ls_payid
			ls_filewrite += " ;"
			If Not IsNull(ls_pid) Then ls_filewrite += ls_pid 
			ls_filewrite += ";"
			If Not IsNull(lc0_zonecod) Then ls_filewrite += String(lc0_zonecod) 
			ls_filewrite += ";"
			If Not IsNull(ls_zonenm) Then ls_filewrite += ls_zonenm
			ls_filewrite += ";"
			If Not IsNull(ls_stime) Then ls_filewrite += ls_stime
			ls_filewrite += ";"
			If Not IsNull(ls_biltime) Then ls_filewrite += ls_biltime
			ls_filewrite += ";"
			If Not IsNull(ls_rtelnum1) Then ls_filewrite += ls_rtelnum1
			ls_filewrite += ";"
			If Not IsNull(lc0_bilamt) Then ls_filewrite += String(lc0_bilamt)
			ls_filewrite += ";"
			If Not IsNull(lc0_intamt) Then ls_filewrite += String(lc0_intamt)
			ls_filewrite += ";"
			If Not IsNull(lc0_pstnamt) Then ls_filewrite += String(lc0_pstnamt)
			
			li_read_bytes = FileWrite(li_filenum, ls_filewrite)
			ll_cnt++
		Loop
		FileClose(li_filenum)
		is_data2[1] = String(ll_cnt)	
		
		Close cur_read_bilcdr;
	Case "VOUCHER PRINT"
		// 작성자 : 2000년 01월 05일 오충환 T&C Technology
		// WINDOW : b5w_prt_voucher.ue_ok
		// 목  적 : 거래 명세서(external) - 전월미납액계산 
		// 인  자 : is_title  = This.Title
		//			   is_caller = "VOUCHER PRINT"
		//				is_data[1]  : 청구일
		//				is_data[2]  : 납기일
		//				is_data[3]  : 청구주기
		//				is_data[4]  : 사업자고객번호
		//				is_data[5]  : 청구월
		//				is_data[6]  : 이용기간
		//          idw_data[1] : dw_list
		ls_billdt = is_data[1]  
		ls_closedt = is_data[2]
		ls_chargedt = is_data[3]
		ls_payid = is_data[4]
		ls_trdt = is_data[5]
		ls_use  = is_data[6]
		ll_rows = idw_data[1].RowCount()
		
		// 청구일과 납기일 세팅
		idw_data[1].Object.jemok.Text = Mid(ls_billdt,1,4) + "년" + Mid(ls_billdt,6,2) + "월 청구세부내역"   
		idw_data[1].Object.billdt.Text = ls_billdt
		idw_data[1].Object.closedt.Text = ls_closedt
		idw_data[1].Object.using_t.Text = ls_use
		
		// 현월 청구고객이 아닌데 이전월에 미납액이 존재하는 고객의 거래명세서 
		DECLARE cur_reqdtl_voucher CURSOR FOR
		SELECT REQDTL.PAYID, PAYMST.MARKNM, NVL(sum(REQDTL.TRAMT), 0) 
      FROM   REQDTL, PAYMST, TRCODE  
      WHERE ( PAYMST.CHARGEDT = :ls_chargedt) and
				( REQDTL.PAYID = PAYMST.PAYID )   and  
				( REQDTL.mark is null )           and 
			   ( REQDTL.PAYID NOT IN ( SELECT  REQDTL.PAYID
			 	   							FROM    REQDTL, PAYMST
											   WHERE ( REQDTL.PAYID = PAYMST.PAYID ) and  
                                          ( substr(REQDTL.TRDT,1,6) >= :ls_trdt ) ) )   
		GROUP BY REQDTL.PAYID, PAYMST.MARKNM
      ORDER BY REQDTL.PAYID;

		OPEN cur_reqdtl_voucher; 
		Do While (True)
			Fetch cur_reqdtl_voucher
			Into :ls_payid, :ls_marknm, :lc_tramt;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_reqdtl_voucher")
				Close cur_reqdtl_voucher;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			If lc_tramt > 0 Then 
				ll_rows++
				idw_data[1].InsertRow(ll_rows)
				idw_data[1].Object.reqdtl_payid[ll_rows] = ls_payid
				idw_data[1].Object.paymst_marknm[ll_rows] = ls_marknm
			End If
		Loop
		Close cur_reqdtl_voucher;
		
						
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 							"Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0

end subroutine

public subroutine uf_dacom_if ();String	ls_serialno, ls_cardno, ls_data_status, ls_anino, ls_result, ls_contno, ls_pid
DEC	is_seq
DEC{2}	ldc_balance

SetNull(ls_cardno)


//2013.02.11 PCMS연동 규격 변동으로 인해, 아래와 같이 수정함. 기존 로직은 그 아래에 COMMENT처리함. 

If is_caller = 'inquery_serial' Then 	
	ls_serialno	   	= is_data[1]
Elseif is_caller = 'inquery_ani' Then
	ls_anino	   	= Trim(is_data[1])
End if	
	
				
// SSRTPPCIF 테이블 Sequence 가져오기
SELECT seq_ssrtppcif.nextval INTO :is_seq FROM dual;

If is_caller = 'inquery_serial' Then	
	INSERT INTO ssrtppcif 
	(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
	VALUES (:is_seq, 'PCM21010T1', 'Balance Check', '0', :ls_serialno, 0, 0, sysdate, :gs_user_id, 'USSRT2');
End if 

If is_caller = 'inquery_ani' Then
	INSERT INTO ssrtppcif 
	(seqno, msgcode, work_type, data_status, anino, crtdt, crt_user, usercode)
	VALUES (:is_seq, 'PCM21010T1', 'Balance Check', '0', :ls_anino, sysdate, :gs_user_id, 'USSRT2');
end if	
				
IF SQLCA.SQLCode < 0 THEN
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcif)")
	ROLLBACK;
	RETURN 
END IF
				
COMMIT;
	
Sleep(4000)
							
	
// 히스토리에서 결과 조회하기 
SELECT seqno, data_status, result, cardno, balance
  INTO :is_seq, :ls_data_status, :ls_result, :ls_cardno, :ldc_balance
  FROM ssrtppcifh
 WHERE seqno = :is_seq;
				
				
				
IF SQLCA.SQLCode < 0 THEN
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcifh)")
	ROLLBACK;
	RETURN 
ELSEIF SQLCA.SQLCode = 100 THEN
	f_msg_usr_err(201,is_title,"Failed. Please try again. If this message contiunes to appear, contact main office/Department.")
	RETURN
END IF	
				
SELECT contno, pid INTO :ls_contno, :ls_pid FROM admst
 WHERE serialno = :ls_cardno;
				
IF SQLCA.SQLCode < 0 THEN
	ii_rc = -1			
	f_msg_usr_err(201,is_title,"Invalid Card Number / Unable to find Card Information")
	//ROLLBACK; 2013.02.18 SunZu Kim  Comment처리
	//RETURN  2013.02.18 Sunzu Kim Comment처리 
ELSEIF SQLCA.SQLCode = 100 THEN
	f_msg_usr_err(201,is_title,"Invalid Card Number / Unable to find Card Information")
	//RETURN	2013.02.13 Sunzu Kim Comment처리 									
END IF

 //2013.02.04 코드별로 자세한 응답처리받을 수 있도록 로직 추가 Sunzu Kim add.	
IF ls_result = '2001' THEN
	f_msg_usr_err(201,is_title,"카드정보가 없습니다. 잔액 : "+' '+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '2002' THEN
	f_msg_usr_err(201,is_title,"예외사항이 발생했습니다. 잔액 : "+' '+string(round((ldc_balance/100),2))+''+" 불")	
ELSEIF ls_result = '2004' THEN	
	f_msg_usr_err(201,is_title,"통화중입니다. 잔액 : "+' '+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '2006' THEN
	f_msg_usr_err(201,is_title,"기간만료 카드입니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '2007' THEN
	f_msg_usr_err(201,is_title,"발신번호 정보가 없습니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")	
ELSEIF ls_result = '2009' THEN	
	f_msg_usr_err(201,is_title,"일시정지된 카드입니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '3002' THEN
	f_msg_usr_err(201,is_title,"카드잔액이 부족합니다. 잔액 ( "+''+string((ldc_balance/100))+''+" 불")		
ELSEIF ls_result = '4001' THEN	
	f_msg_usr_err(201,is_title,"개통가능금액 부족합니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '4002' THEN
	f_msg_usr_err(201,is_title,"충전한도금액이 초과했습니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")	
ELSEIF ls_result = '4003' THEN	
	f_msg_usr_err(201,is_title,"온라인 충전 불가카드입니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")
ELSEIF ls_result = '4004' THEN
	f_msg_usr_err(201,is_title,"개별충전 불가카드입니다. 잔액 : "+''+string(round((ldc_balance/100),2))+''+" 불")
END IF;					
				
 //Balance를 보여준다. 
idw_data[1].object.balance[1] = ldc_balance/100
	
// 카드 정보를 보여준다.
idw_data[1].object.serialno[1] = ls_cardno
idw_data[1].object.pid[1]		 = ls_pid
idw_data[1].object.controlno[1]   = ls_contno
ii_rc = 1
RETURN
				


//2012.02.11 Sunzu Kim 막음. 연동규격 변동으로 인해 위와 같이 수정함. 
//Choose Case is_caller
//		case "inquery_serial"
//				ls_serialno	   	= is_data[1]
//				
//				// SSRTPPCIF 테이블 Sequence 가져오기
//				SELECT seq_ssrtppcif.nextval INTO :is_seq FROM dual;
//				
//				// 연동 데이터 입력
//				INSERT INTO ssrtppcif 
//								(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
//				VALUES (:is_seq, 'PCM21010T0', 'Balance Check', '0', :ls_serialno, 0, 0, sysdate, :gs_user_id, 'USSRT2');
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcif)")
//					ROLLBACK;
//					RETURN 
//				END IF
//				
//				COMMIT;
//				
//				Sleep(4000)
//				
//				// 히스토리에서 결과 조회하기 
//				SELECT seqno, data_status, result, cardno, balance 
//				  INTO :is_seq, :ls_data_status, :ls_result, :ls_cardno, :ldc_balance
//				  FROM ssrtppcifh
//				 WHERE seqno = :is_seq;
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcifh)")
//					ROLLBACK;
//					RETURN 
//				ELSEIF SQLCA.SQLCode = 100 THEN
//					f_msg_usr_err(201,is_title,"Failed. Please try again. If this message contiunes to appear, contact main office/Department.")
//					RETURN
//				ELSEIF ls_result <> '0000' THEN
//					f_msg_usr_err(201,is_title,"Expiry date has passed or Balance has been transferred to another card.")
//					RETURN
//				END IF
//				
//				// 데이터가 있으면 잔액을 보여준다.
//				idw_data[1].object.balance[1] = ldc_balance/100
//				ii_rc = 1
//				RETURN
//				
//		CASE 'inquery_ani'
//				ls_anino	   	= is_data[1]
//				
//				// SSRTPPCIF 테이블 Sequence 가져오기
//				SELECT seq_ssrtppcif.nextval INTO :is_seq FROM dual;
//				
//				// ANI 번호를 이용해서 Serial No를 확인한다.
//				// 연동 데이터 입력
//				INSERT INTO ssrtppcif 
//								(seqno, msgcode, work_type, data_status, anino, crtdt, crt_user, usercode)
//				VALUES (:is_seq, 'PCM21010T1', 'Card No. Check', '0', :ls_anino, sysdate, :gs_user_id, 'USSRT2');
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcif)")
//					ROLLBACK;
//					RETURN 				
//				END IF
//				
//				COMMIT;
//				
//				Sleep(4000)
//				
//				// 히스토리에서 카드조회 결과 조회하기 
//				SELECT seqno, data_status, result, cardno, balance 
//				  INTO :is_seq, :ls_data_status, :ls_result, :ls_cardno, :ldc_balance
//				  FROM ssrtppcifh
//				 WHERE seqno = :is_seq;
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcifh)")
//					ROLLBACK;
//					RETURN 
//				ELSEIF IsNull(ls_cardno) THEN
//					f_msg_usr_err(201,is_title,"Unable Phone Number")
//					ROLLBACK;
//					RETURN 
//				ELSEIF SQLCA.SQLCode = 100 THEN
//					f_msg_usr_err(201,is_title,"Failed. Please try again. If this message contiunes to appear, contact main office/Department.")
//					RETURN					
//				ELSEIF ls_result <> '0000' THEN 
//					f_msg_usr_err(201,is_title,"Expiry date has passed or Balance has been transferred to another card.")
//					RETURN						
//				END IF
//
//				// 데이터가 있으면 해당 카드정보를 수집한다.
//				SELECT contno, pid INTO :ls_contno, :ls_pid FROM admst
//				WHERE serialno = :ls_cardno;
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_usr_err(201,is_title,"Invalid Card Number / Unable to find Card Information")
//					ROLLBACK;
//					RETURN 
//				ELSEIF SQLCA.SQLCode = 100 THEN
//					f_msg_usr_err(201,is_title,"Invalid Card Number / Unable to find Card Information")
//					RETURN										
//				END IF
//
//				// 카드 정보를 보여준다.
//				idw_data[1].object.serialno[1] = ls_cardno
//				idw_data[1].object.pid[1]		 = ls_pid
//				idw_data[1].object.controlno[1]   = ls_contno
//
//				// SSRTPPCIF 테이블 Sequence 가져오기
//				SELECT seq_ssrtppcif.nextval INTO :is_seq FROM dual;
//				
//				// SerialNo를 이용해서 Balance를 확인한다. 
//				// 연동 데이터 입력
//				INSERT INTO ssrtppcif 
//								(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
//				VALUES (:is_seq, 'PCM21010T0', 'Balance Check', '0', :ls_cardno, 0, 0, sysdate, :gs_user_id, 'USSRT2');
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcif)")
//					ROLLBACK;
//					RETURN 					
//				END IF
//				
//				COMMIT;
//				
//				Sleep(4000)
//				
//				// 히스토리에서 결과 조회하기 
//				SELECT seqno, data_status, result, cardno, balance 
//				  INTO :is_seq, :ls_data_status, :ls_result, :ls_cardno, :ldc_balance
//				  FROM ssrtppcifh
//				 WHERE seqno = :is_seq;
//				
//				IF SQLCA.SQLCode < 0 THEN
//					ii_rc = -1			
//					f_msg_sql_err(is_title, is_caller + " Data Error(ssrtppcifh)")
//					ROLLBACK;
//					RETURN 
//				ELSEIF SQLCA.SQLCode = 100 THEN
//					f_msg_usr_err(201,is_title,"Failed. Please try again. If this message contiunes to appear, contact main office/Department.")
//					RETURN					
//				ELSEIF ls_result <> '0000' THEN
//					f_msg_usr_err(201,is_title,"Expiry date has passed or Balance has been transferred to another card.")
//					RETURN						
//				END IF
//								
//				// 데이터가 있으면 잔액을 보여준다.
//				idw_data[1].object.balance[1] = ldc_balance/100
//				ii_rc = 1
//				RETURN	
//		CASE ELSE
//
//End Choose
//Return 
end subroutine

on b5u_dbmgr_ssrt.create
call super::create
end on

on b5u_dbmgr_ssrt.destroy
call super::destroy
end on

