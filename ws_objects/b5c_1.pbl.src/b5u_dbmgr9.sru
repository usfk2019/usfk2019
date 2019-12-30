$PBExportHeader$b5u_dbmgr9.sru
$PBExportComments$[ohj]대리점 인증key 할당 db
forward
global type b5u_dbmgr9 from u_cust_a_db
end type
end forward

global type b5u_dbmgr9 from u_cust_a_db
end type
global b5u_dbmgr9 b5u_dbmgr9

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_04 ()
end prototypes

public subroutine uf_prc_db_01 ();String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay, ls_user_id, ls_pgm_id, &
		  ls_header[], ls_data[], ls_data_detail[], ls_trailer[], ls_temp, ls_ref_desc, &
		  ls_payid, ls_chargedt, ls_reqnum, ls_customernm, ls_lastname, &
		  ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_acctno, ls_acct_owner, ls_result[], &
		  ls_itemtype, ls_itemkey_property, ls_item_value, ls_pad_type, ls_pad_value, &
		  ls_company, ls_companynm, ls_check, ls_record, ls_pay_method, ls_corpnm, &
		  ls_bank, ls_bankshop, ls_accowner, ls_bank_dealer, ls_acct_item, ls_bank_name, &
		  ls_bank_dealer_nm, ls_btrdesc[], ls_payid_amt, ls_chargedt_amt, ls_reqnum_amt, &
		  ls_trail, ls_trail_pnt, ls_property, ls_comma = '"', ls_shim  = ',', ls_head, &
		  ls_da, ls_resultt[], ls_resulttt[],  ls_resultttt[], ls_property_d, ls_da_t, &
		  ls_status = ''
Long	  ll_code = 1, ll_seqno, ll_maxlength, i, li_write_bytes, ll_customer_sum, &
        ll_btramt[], j, ll_count = 0, ll_amt_total = 0, ll_gubun = 0, t
Date    ld_workdt, ld_inputclosedt, ld_cnd_trdt, ld_inputclosedtcur, ld_trdt, ld_trdt_amt

//iu_db.is_title = Title//
ls_cnd_invf_type  = is_data[1]
ls_cnd_pay_method = is_data[2]
ls_cnd_inv_type   = is_data[3]
ls_cnd_chargedt   = is_data[4]	  //주기			
ls_cnd_bankpay    = is_data[5]
ls_cnd_creditpay  = is_data[6]
ls_cnd_etcpay     = is_data[7]
ls_user_id        = is_data[8]
ls_pgm_id         = is_data[9]

ld_workdt	      = id_data[1]
ld_inputclosedt   = id_data[2]
ld_cnd_trdt       = id_data[3] // 기준일

ii_rc = -1

//If IsNull(ls_cnd_creditpay) Then ls_cnd_creditpay = ''
//If IsNull(ls_cnd_etcpay)    Then ls_cnd_etcpay    = ''
//If IsNull(ls_cnd_inv_type)  Then ls_cnd_inv_type  = ''

Constant Integer li_MAX_DIR = 255, li_MAX_FILES = 4097
string ls_currentdir, ls_pathname

u_api lu_api
lu_api = Create u_api

//ls_currentdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_currentdir)
ls_currentdir = Trim(ls_currentdir)

//ls_pathname = ""
//ls_file_name = ""
//ls_extension = ""
//ls_filter = " Files (*.*), *.*, All Files (*.*),*.*"
//li_return = GetFileOpenName(title, ls_pathname, ls_file_name, ls_extension, ls_filter)
//
//If li_return <> 1 Then
//	If Len(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
//	Destroy lu_api
//	f_msg_usr_err(9000, Title, "File 정보가 없습니다.")
//	Return
//End If
//
//SetPointer(HourGlass!)
//
////ls_prc_filename = ls_file_prefix + ls_workdt_mmdd
////
////If ls_file_name <> ls_prc_filename Then
////	f_msg_usr_err(9000, Title,"'"+ ls_prc_filename + "' File을 선택하셔야 합니다.")
////	return 
////End if
//
//
//If Len(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api

//ls_pathname = Upper(ls_pathname)

//위탁회사 ls_result[1] = 은행코드 , ls_result[2] = 은행계좌번호
ls_temp = fs_get_control("B7","A110", ls_ref_desc)
		
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

// 예금주
ls_accowner  = fs_get_control("B7", "A120", ls_ref_desc)
//지점코드
ls_bank_dealer = fs_get_control("B7", "A140", ls_ref_desc)
//예금과목
ls_acct_item   = fs_get_control("B7", "A160", ls_ref_desc)
//은행명
ls_bank_name = fs_get_control("B7", "A130", ls_ref_desc)
//지점명
ls_bank_dealer_nm = fs_get_control("B7", "A150", ls_ref_desc)

//위탁회사 코드
ls_company   = fs_get_control("B7", "A100", ls_ref_desc)
//회사명
ls_companynm = fs_get_control("B7", "A600", ls_ref_desc)

DECLARE invf_recorddet_cu CURSOR FOR
	SELECT RECORD
	     , SEQNO
	     , ITEMTYPE
	     , ITEMKEY_PROPERTY
		  , ITEM_VALUE
		  , MAXLENGTH
		  , PAD_TYPE
		  , PAD_VALUE
	  FROM INVF_RECORDDET 
	 WHERE INVF_TYPE = :ls_cnd_invf_type   ;
//		AND RECORD    = 'H'                     ;
		
	OPEN invf_recorddet_cu;
	
	DO WHILE (True)
	
		Fetch invf_recorddet_cu
		Into :ls_record, :ll_seqno, :ls_itemtype, :ls_itemkey_property, :ls_item_value, :ll_maxlength
		   , :ls_pad_type, :ls_pad_value;

		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		If ls_record = 'H' Then
				
			If ls_itemtype = 'V' Then
				ls_header[ll_seqno] = ls_item_value
			Else
	
				If ll_seqno = 3 Then
					ls_header[ll_seqno] = fs_fill_pad(ls_company, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_company
					
				ElseIf ll_seqno = 4 Then
					ls_header[ll_seqno] = fs_fill_pad(ls_companynm, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_companynm
					
				Else
					ls_header[ll_seqno] = string(ld_workdt, 'yyyymmdd')
				End If
				
				If LenA(ls_check) > ll_maxlength Then
					f_msg_usr_err(2100, is_Title, "header의" + string(ll_seqno)+ "의 값이 설정된 max값보다 큼니다.")
					ll_code = 0
					Exit
				End If
			End IF
			
		ElseIf ls_record = 'D' Then
			If ls_itemtype = 'V' Then
				ls_data[ll_seqno] = ls_item_value
			End If
			
		ElseIf ls_record = 'R' Then
			If ls_itemtype = 'V' Then
				ls_data_detail[ll_seqno] = ls_item_value
			End If
			
		ElseIf ls_record = 'T' Then
			If ls_itemtype = 'V' Then
				ls_trailer[ll_seqno] = ls_item_value
			End If
		End If
		
	LOOP

	If ll_code = 0 Then
		CLOSE invf_recorddet_cu;
		rollback;
		ls_status = 'failiure'
		Goto NextStep
//		Return
	End If
	
CLOSE invf_recorddet_cu;	


Integer li_FileNum
String  ls_filename

ls_filename = ls_currentdir + string(ld_workdt, 'yyyymmdd') + '.txt'

li_FileNum = FileOpen(ls_filename, LineMode!, Write!, LockWrite!, Append!)
If IsNull(li_filenum) Then li_filenum = -1

If li_filenum < 0 Then
	f_msg_usr_err(9000, is_Title, "File Open Failed!")
	FileClose(li_filenum)			
	ls_status = 'failiure'
	Goto NextStep
	//Return
End If

//item_key property 'c' 이면 " " 붙이기. 및 콤마 붙이기
//header
ls_property = fs_itemkey_property(ls_cnd_invf_type, 'H')

If ls_property <> "" Then
	fi_cut_string(ls_property, ";" , ls_resultt[])
End if

ll_gubun = 0
For j = 1 To UpperBound(ls_header)
	For i = 1 To UpperBound(ls_resultt)
		If j =  integer(ls_resultt[i]) Then
			If ls_header[j] = '' Then
				ls_head += ls_shim
			Else
				ls_head += ls_comma + ls_header[j] + ls_comma + ls_shim
			End If
			ll_gubun = j
			Exit
		End If
	Next
	
	IF ll_gubun <> j  Then
		If ls_header[j] = '' Then
			ls_head += ls_shim
		Else
			ls_head += ls_header[j] + ls_shim
		End If
	End IF
Next

ls_trail_pnt = ls_head // mid(ls_head, 1, Len(ls_head) - 1)
// 여기까지..

//For i = 1 To UpperBound(ls_header)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)

	If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
			FileClose(li_filenum)
			ls_status = 'failiure'
			Goto NextStep
			//Return 
	End If
//Next
ls_trail_pnt = ''

//data 
ls_property = fs_itemkey_property(ls_cnd_invf_type, 'D')

If ls_property <> "" Then
	fi_cut_string(ls_property, ";" , ls_resulttt[])
End if

//data- detail
ls_property_d = fs_itemkey_property(ls_cnd_invf_type, 'R')

If ls_property_d <> "" Then
	fi_cut_string(ls_property_d, ";" , ls_resultttt[])
End if

DECLARE reqinfo_cu CURSOR FOR
	SELECT PAYID		//고객번호
	     , TRDT			//청구기준일
		  , CHARGEDT	//청구주기
		  , REQNUM		//청구번호
		  , CUSTOMERNM	//고객명
		  , LASTNAME	//고객명()
		  , BIL_ZIPCOD	//우편번호
		  , BIL_ADDR1	//주소
		  , BIL_ADDR2 	//주소
		  , CORPNM		//법인명
		  , BANK 	 	//은행코드
		  , BANKSHOP	//은행
		  , ACCTNO		
		  , ACCT_OWNER
		  , INPUTCLOSEDTCUR	//입금마감일
		  , PAY_METHOD     	//결제채널 '1' 지로, '2' 자동이체
	  FROM REQINFO
	 WHERE TRDT = :ld_cnd_trdt
	   AND PAY_METHOD IN (:ls_cnd_pay_method, :ls_cnd_bankpay); //, :ls_cnd_creditpay) ;
	 
	OPEN reqinfo_cu;
	
	DO WHILE (True)
		
		Fetch reqinfo_cu
		Into :ls_payid   , :ld_trdt, :ls_chargedt, :ls_reqnum, :ls_customernm
	      , :ls_lastname, :ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_corpnm
			, :ls_bank    , :ls_bankshop, :ls_acctno, :ls_acct_owner, :ld_inputclosedtcur
			, :ls_pay_method                                                               ;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		SELECT SUM( NVL(BTRAMT01, 0) + NVL(BTRAMT02, 0) + NVL(BTRAMT03, 0) + NVL(BTRAMT04, 0) + NVL(BTRAMT05, 0) + 
		            NVL(BTRAMT06, 0) + NVL(BTRAMT07, 0) + NVL(BTRAMT08, 0) + NVL(BTRAMT09, 0) + NVL(BTRAMT10, 0) +
					   NVL(BTRAMT11, 0) + NVL(BTRAMT12, 0) + NVL(BTRAMT13, 0) + NVL(BTRAMT14, 0) + NVL(BTRAMT15, 0) +
					   NVL(BTRAMT16, 0) + NVL(BTRAMT17, 0) + NVL(BTRAMT18, 0) + NVL(BTRAMT19, 0) + NVL(BTRAMT20, 0) +
						NVL(BTRAMT21, 0) + NVL(BTRAMT22, 0) + NVL(BTRAMT23, 0) + NVL(BTRAMT24, 0) + NVL(BTRAMT25, 0) +
						NVL(BTRAMT26, 0) + NVL(BTRAMT27, 0) + NVL(BTRAMT28, 0) + NVL(BTRAMT29, 0) + NVL(BTRAMT30, 0) )   
		 INTO :ll_customer_sum
		 FROM REQAMTINFO
		WHERE PAYID = :ls_payid
		  AND TRDT  = :ld_trdt  ;
		  
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If  
			
		//1레코드구분
		//2데이타 처리구분		
		ls_data[3] = ls_company  //위탁회사 코드
		ls_data[4] = fs_fill_pad(ls_payid , 15, '1', '0')	//고객코드
		ls_data[5] = fs_fill_pad(ls_reqnum, 10, '1', '0')	//청구서 번호
		//6 명세서 번호 '00000'
		ls_data[7] = ls_customernm
		ls_data[8] = '' //ls_lastname
		ls_data[9] = ls_bil_zipcod
		If LenA(ls_bil_addr1) > 30 Then
			ls_data[10] = ''
			ls_data[11] = ''
			ls_data[12] = ''
			ls_data[13] = ls_bil_addr1 + ' ' + ls_bil_addr2
		Else
			ls_data[10] = ls_bil_addr1
			ls_data[11] = ls_bil_addr2
			ls_data[12] = ''
			ls_data[13] = ''
		End If
		
		ls_data[14] = ls_corpnm   //법인명
		ls_data[15] = '' //ls_lastname  //법인명() 일단 고객
		If ls_data[16] = 'null' Then   //부과명
			ls_data[16] = ''
		End IF
		//17경칭종류 '0'
		ls_data[18] = string(ld_workdt, 'yyyymmdd')
		ls_data[19] = string(ll_customer_sum)  //청구금액
		
		//giro
		If ls_pay_method = '1' Then
			ls_data[20] = '1' //결제채널
			ls_data[21] = '1' //지로이면 '1' 청구서 종류
			//22 지로이면 전용 계좌번호 지정  '0'
			//23 전용 계좌 인자 우선 '0'
			ls_data[24] = ls_accowner  //예금주
			ls_data[25] = ls_result[1] //은행코드
			ls_data[26] = ls_bank_name  //은행명
			ls_data[27] = ls_bank_dealer //지점코드
			ls_data[28] = ls_bank_dealer_nm //지점명
			ls_data[29] = ls_acct_item  //예금과목
			ls_data[30] = ls_result[2] // 은행계좌번호
			ls_data[31] = ''
			ls_data[32] = ''
			ls_data[33] = ''
			ls_data[34] = ''
			ls_data[35] = ''
			ls_data[36] = ''
			ls_data[37] = ''
			ls_data[38] = ''
			ls_data[39] = ''
			ls_data[40] = ''
			ls_data[41] = ''
			ls_data[42] = ''
			ls_data[43] = ''
			ls_data[44] = ''
			ls_data[45] = ''
			ls_data[46] = ''
			ls_data[47] = ''
			ls_data[48] = ''
			//고객은행정보  지로일때는 null
			ls_data[49] = ''
			ls_data[50] = ''
			ls_data[51] = ''
			If ls_data[52] = 'null' Then //지점명
				ls_data[52] = ''
			End If
			ls_data[53] = ''
			ls_data[54] = ''
			ls_data[55] = ''
			
		// 자동이체	
		ElseIf ls_pay_method = '2' Then
			ls_data[20] = '2' //결제채널
			ls_data[21] = '2' //지로이면 '1' 청구서 종류
			//22 지로이면 전용 계좌번호 지정  '0'
			ls_data[22] = '1'
			//23 전용 계좌 인자 우선 '0'
			ls_data[23] = '1'
			ls_data[24] = ''  //예금주
			ls_data[25] = '' 	//은행코드
			ls_data[26] = ''  //은행명
			ls_data[27] = '' 	//지점코드
			ls_data[28] = '' 	//지점명
			ls_data[29] = ''  //예금과목
			ls_data[30] = '' 	// 은행계좌번호
			ls_data[31] = ''
			ls_data[32] = ''
			ls_data[33] = ''
			ls_data[34] = ''
			ls_data[35] = ''
			ls_data[36] = ''
			ls_data[37] = ''
			ls_data[38] = ''
			ls_data[39] = ''
			ls_data[40] = ''
			ls_data[41] = ''
			ls_data[42] = ''
			ls_data[43] = ''
			ls_data[44] = ''
			ls_data[45] = ''
			ls_data[46] = ''
			ls_data[47] = ''
			ls_data[48] = ''
			//고객은행정보  지로일때는 null
			ls_data[49] = ls_bank
			ls_data[50] = ls_bankshop  	//은행명??
			//ls_data[51] = ''  				//지점코드
			If ls_data[52] = 'null' Then 	//지점명
				ls_data[52] = ''
			End If
			//ls_data[53] = '' 예금과목
			ls_data[54] = ls_acctno
			ls_data[55] = ls_acct_owner			
		End If
		//56 신규코드 '1'
		//57 재청구 '0'
		ls_data[58] = string(ld_inputclosedtcur) //입금마감일
		//안내문
		ls_data[59] = ''
		ls_data[60] = ''
		ls_data[61] = ''
		ls_data[62] = ''
		ls_data[63] = ''
		ls_data[64] = ''
		ls_data[65] = ''
		ls_data[66] = ''
		ls_data[67] = ''
		ls_data[68] = ''
		ls_data[69] = ''
		ls_data[70] = ''
		ls_data[71] = ''
		ls_data[72] = ''
		
		ll_gubun = 0
		For j = 1 To UpperBound(ls_data)
			
			For i = 1 To UpperBound(ls_resulttt)
				If j =  integer(ls_resulttt[i]) Then
					If ls_data[j] = '' Then// Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_shim
					Else
						ls_da += ls_comma + ls_data[j] + ls_comma + ls_shim
					End If
					
					ll_gubun = j
					Exit
				End If
			Next
			
			IF ll_gubun <> j  Then
				If ls_data[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
					ls_da += ls_shim
				Else
					ls_da += ls_data[j] + ls_shim
				End If
			End IF
		Next
		
		ls_trail_pnt = ls_da // mid(ls_head, 1, Len(ls_head) - 1)	
		
		//For i = 1 To UpperBound(ls_data)
			li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
			If li_write_bytes < 0 Then 
				f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
				FileClose(li_filenum)
				ls_status = 'failiure'
				Goto NextStep
				//Return 
			End If
		//Next
		ls_trail_pnt = ''
		ls_da        = ''

		//상세항목
		DECLARE reqamtinfo_cu CURSOR FOR
			SELECT PAYID		//고객번호
				  , TRDT			//청구기준일
				  , CHARGEDT	//청구주기
				  , REQNUM		//청구번호
//				  , SUPPLYAMT  //공급가액
//				  , SURTAX 		//부과세
				  , NVL(BTRAMT01, 0), NVL(BTRAMT02, 0), NVL(BTRAMT03, 0), NVL(BTRAMT04, 0) 
				  , NVL(BTRAMT05, 0), NVL(BTRAMT06, 0), NVL(BTRAMT07, 0), NVL(BTRAMT08, 0) 
				  , NVL(BTRAMT09, 0), NVL(BTRAMT10, 0), NVL(BTRAMT11, 0), NVL(BTRAMT12, 0) 
				  , NVL(BTRAMT13, 0), NVL(BTRAMT14, 0), NVL(BTRAMT15, 0), NVL(BTRAMT16, 0) 
				  , NVL(BTRAMT17, 0), NVL(BTRAMT18, 0), NVL(BTRAMT09, 0), NVL(BTRAMT20, 0)	
				  , NVL(BTRAMT21, 0), NVL(BTRAMT22, 0), NVL(BTRAMT23, 0), NVL(BTRAMT24, 0) 
				  , NVL(BTRAMT25, 0), NVL(BTRAMT26, 0), NVL(BTRAMT27, 0), NVL(BTRAMT28, 0) 
				  , NVL(BTRAMT29, 0), NVL(BTRAMT30, 0)				  
				  , NVL(BTRDESC01,''), NVL(BTRDESC02,''), NVL(BTRDESC03,'')
				  , NVL(BTRDESC04,''), NVL(BTRDESC05,''), NVL(BTRDESC06,'')
				  , NVL(BTRDESC07,''), NVL(BTRDESC08,''), NVL(BTRDESC09,'')
				  , NVL(BTRDESC10,''), NVL(BTRDESC11,''), NVL(BTRDESC12,'')
				  , NVL(BTRDESC13,''), NVL(BTRDESC14,''), NVL(BTRDESC15,'')
				  , NVL(BTRDESC16,''), NVL(BTRDESC17,''), NVL(BTRDESC18,'')
				  , NVL(BTRDESC19,''), NVL(BTRDESC20,''), NVL(BTRDESC21,'')
				  , NVL(BTRDESC22,''), NVL(BTRDESC23,''), NVL(BTRDESC24,'')
				  , NVL(BTRDESC25,''), NVL(BTRDESC26,''), NVL(BTRDESC27,'')
				  , NVL(BTRDESC28,''), NVL(BTRDESC29,''), NVL(BTRDESC30,'')
			  FROM REQAMTINFO
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ld_cnd_trdt  ;
			 
			OPEN reqamtinfo_cu;
			
			DO WHILE (True)
				
				Fetch reqamtinfo_cu
				Into :ls_payid_amt, :ld_trdt_amt, :ls_chargedt_amt, :ls_reqnum_amt
				   , :ll_btramt[1], :ll_btramt[2], :ll_btramt[3], :ll_btramt[4], :ll_btramt[5]
				   , :ll_btramt[6], :ll_btramt[7], :ll_btramt[8], :ll_btramt[9], :ll_btramt[10]
				   , :ll_btramt[11], :ll_btramt[12], :ll_btramt[13], :ll_btramt[14], :ll_btramt[15]
				   , :ll_btramt[16], :ll_btramt[17], :ll_btramt[18], :ll_btramt[19], :ll_btramt[20]
				   , :ll_btramt[21], :ll_btramt[22], :ll_btramt[23], :ll_btramt[24], :ll_btramt[25]
				   , :ll_btramt[26], :ll_btramt[27], :ll_btramt[28], :ll_btramt[29], :ll_btramt[30]					
					, :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5]
					, :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10] 
					, :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15]
					, :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 
					, :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25]
					, :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30]  ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				For i = 1 To UpperBound(ls_btrdesc)
					If ls_btrdesc[i] = 'null' Or IsNull(ls_btrdesc[i]) Then
						ls_btrdesc[i] = ''
					End If
				Next
				
				//1 레코드구분 3
				//2 데이타처리구분 1			
				ls_data_detail[3] = ls_company //위탁회사 코드
				ls_data_detail[4] = fs_fill_pad(ls_payid_amt, 15, '1', '0') // 고객no
				ls_data_detail[5] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0') //청구번호
				ls_data_detail[7] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
				ls_data_detail[10] = ''
				ls_data_detail[11] = ''
				ls_data_detail[12] = ''					
				ls_data_detail[13] = ''
				ls_data_detail[14] = ''
				ls_data_detail[15] = ''
				ls_data_detail[16] = ''	
				
				ls_data_detail[18] = ''	
				ls_data_detail[19] = ''	
				ls_data_detail[20] = ''	
				ls_data_detail[21] = ''	
				ls_data_detail[22] = ''	
				ls_data_detail[23] = ''	
				ls_data_detail[24] = ''	
				ls_data_detail[25] = ''	
				ls_data_detail[26] = ''	
					
				For i = 1 To UpperBound(ls_btrdesc)
					If IsNull(ls_btrdesc[i]) Or ls_btrdesc[i] = '' Then Continue
				
					ls_data_detail[6]  = FillA('0', 5 - LenA(string(i))) + string(i)  //6 명세서 번호 '0001'
					ls_data_detail[8]  = string(i) + FillA('0', 3 - LenA(string(i))) 
					ls_data_detail[9]  = ls_btrdesc[i]
					ls_data_detail[17] = string(ll_btramt[i])
					
					ll_amt_total = ll_amt_total + ll_btramt[i]
					ll_count ++
					
					ll_gubun = 0
					For j = 1 To UpperBound(ls_data_detail)
					
						For t = 1 To UpperBound(ls_resultttt)
							If j =  integer(ls_resultttt[t]) Then
								If ls_data_detail[j] = '' Then
									ls_da_t += ls_shim
								Else
									ls_da_t += ls_comma + ls_data_detail[j] + ls_comma + ls_shim
								End If
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_data_detail[j] = '' Then
								ls_da_t += ls_shim
							Else
								ls_da_t += ls_data_detail[j] + ls_shim
							End If
						End IF
					Next
					
					ls_trail_pnt = ls_da_t // mid(ls_head, 1, Len(ls_head) - 1)	
				
					//For j = 1 To UpperBound(ls_data_detail)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data-detail Record)")
							FileClose(li_filenum)
							ls_status = 'failiure'
							Goto NextStep
							//Return 
						End If
					//Next
					ls_trail_pnt = ''
					ls_da_t = ''
				Next
				
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqamtinfo_cu;		

	LOOP

	If ll_code = 0 Then
		FileClose(li_FileNum)
		rollback;
		ls_status = 'failiure'
		Goto NextStep
		//Return
	End If
	
CLOSE reqinfo_cu;

//trailer
ls_trailer[3] = ls_company
ls_trailer[4] = string(ll_count)
ls_trailer[5] = string(ll_amt_total)

ls_property = fs_itemkey_property(ls_cnd_invf_type, 'T')

If ls_property <> "" Then
	fi_cut_string(ls_property, ";" , ls_result[])
End if

ll_gubun = 0
For j = 1 To UpperBound(ls_trailer)
	For i = 1 To UpperBound(ls_result)
		If j =  integer(ls_result[i]) Then
			If ls_trailer[j] = '' Then
				ls_trail += ls_shim
			Else
				ls_trail += ls_comma + ls_trailer[j] + ls_comma + ls_shim
			End If
			
			ll_gubun = j
			Exit
		End If
	Next
	
	IF ll_gubun <> j  Then
		If ls_trailer[j] = '' Then
			ls_trail += ls_shim
		Else
			ls_trail += ls_trailer[j] + ls_shim
		End If
	End IF
Next

ls_trail_pnt = MidA(ls_trail, 1, LenA(ls_trail) - 1)

//For j = 1 To UpperBound(ls_trailer)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (trailer Record)")
		FileClose(li_filenum)
		ls_status = 'failiure'
		Goto NextStep
		//Return 
	End If
//Next

FileClose(li_FileNum)

ls_status = 'Complete'

ls_filename = MidA(ls_filename, 4)
//li_tab      = Pos(ls_filename, "\")
ls_filename = MidA(ls_filename, PosA(ls_filename, "\") + 1)

NextStep :

//log 생성
INSERT INTO INVF_WORKLOG
			 ( SEQNO
			 , FILEW_DIR
			 , FILEW_NAME
			 , FILEW_STATUS
			 , FILEW_COUNT
			 , FILEW_INVAMT
          , CND_INVF_TYPE
			 , CND_INV_TYPE
			 , CND_WORKDT
			 , CND_INPUTCLOSEDT
			 , CND_TRDT
			 , CND_CHARGEDT
			 , CND_PAY_METHOD
			 , CND_BANKPAY
			 , CND_CREDITPAY
			 , CND_ETCPAY
			 , CRT_USER
			 , CRTDT
			 , PGM_ID )
     VALUES
		    ( seq_invf_worklog.nextval
			 , :ls_currentdir
			 , :ls_filename
			 , :ls_status
			 , :ll_count
			 , :ll_amt_total
			 , :ls_cnd_invf_type
			 , :ls_cnd_inv_type
			 , :ld_workdt
			 , :ld_inputclosedt
			 , :ls_cnd_chargedt
			 , :ld_cnd_trdt
			 , :ls_cnd_pay_method
			 , :ls_cnd_bankpay
			 , :ls_cnd_creditpay
			 , :ls_cnd_etcpay
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id           );
			 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(INVF_WORKLOG)")
	RollBack;
	Return		
End If		

ii_rc = 0

Return
end subroutine

public subroutine uf_prc_db_06 ();String  ls_temp, ls_ref_desc, &
		  ls_payid, ls_chargedt, ls_reqnum, ls_customernm, ls_lastname, ls_corpnm_2, &
		  ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_acctno, ls_acct_owner, ls_result[], &
		  ls_itemtype, ls_itemkey_property, ls_item_value, ls_pad_type, ls_pad_value, &
		  ls_company, ls_companynm, ls_check, ls_record, ls_pay_method, ls_corpnm, ls_py, &
		  ls_bank, ls_bankshop, ls_accowner, ls_bank_dealer, ls_acct_item, ls_bank_name, &
		  ls_bank_dealer_nm, ls_btrdesc[], ls_payid_amt, ls_chargedt_amt, ls_reqnum_amt, &
		  ls_trail, ls_trail_pnt, ls_property, ls_comma = '"', ls_shim  = ',', ls_head, &
		  ls_da, ls_resultt[], ls_resulttt[],  ls_resultttt[], ls_property_d, ls_da_t, &
		  ls_status = ''
Long	  ll_code = 1, ll_seqno, ll_maxlength, i, li_write_bytes, ll_customer_sum, &
        ll_btramt[], j, ll_count = 0, ll_amt_total = 0, ll_gubun = 0, t, p, cnt = 0
Date    ld_workdt, ld_inputclosedt, ld_cnd_trdt, ld_inputclosedtcur, ld_trdt, ld_trdt_amt

		  
String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay, ls_user_id, ls_pgm_id, &
		  ls_header[], ls_data[], ls_data_detail[], ls_trailer[], ls_etc, &
		  ls_itemkey, ls_itemkey_header[], ls_itemkey_data[], ls_itemkey_data_detail[], &
		  ls_itemkey_Trailer[], ls_seqno_header, ls_seqno_data, ls_seqno_data_detail, &
		  ls_seqno_trailer, ls_seq_header[], ls_seq_data[], ls_seq_data_detail[], &
		  ls_seq_trailer[], ls_item_delimit, ls_record_delimit, ls_item_header_gu, &
		  ls_record_header_gu, ls_item_data_gu, ls_record_data_gu, ls_item_data_detail_gu, &
		  ls_record_data_detail_gu, ls_item_trailer_gu, ls_record_trailer_gu, ls_method[]
Long    ll_itemkey

//iu_db.is_title = Title//
ls_cnd_invf_type  = is_data[1]
ls_cnd_pay_method = is_data[2]		//지로
ls_cnd_inv_type   = is_data[3]
ls_cnd_chargedt   = is_data[4]	  	//주기			
ls_cnd_bankpay    = is_data[5]		//자동이체
ls_cnd_creditpay  = is_data[6]		//카드
ls_cnd_etcpay     = is_data[7]		//기타
ls_user_id        = is_data[8]
ls_pgm_id         = is_data[9]

ld_workdt	      = id_data[1]
ld_inputclosedt   = id_data[2]
ld_cnd_trdt       = id_data[3] 		// 기준일

If isnull(ls_cnd_etcpay) Then ls_cnd_etcpay = ''

ii_rc = -1

//Constant Integer li_MAX_DIR = 255, li_MAX_FILES = 4097
string ls_currentdir, ls_pathname
//
//u_api lu_api
//lu_api = Create u_api
//
//lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_currentdir)
//ls_currentdir = Trim(ls_currentdir)
//
//Destroy lu_api

//위탁회사 ls_result[1] = 은행코드 , ls_result[2] = 은행계좌번호
ls_temp = fs_get_control("B7","A110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
// 예금주
ls_accowner  = fs_get_control("B7", "A120", ls_ref_desc)
//지점코드
ls_bank_dealer = fs_get_control("B7", "A140", ls_ref_desc)
//예금과목
ls_acct_item   = fs_get_control("B7", "A160", ls_ref_desc)
//은행명
ls_bank_name = fs_get_control("B7", "A130", ls_ref_desc)
//지점명
ls_bank_dealer_nm = fs_get_control("B7", "A150", ls_ref_desc)
//위탁회사 코드
ls_company   = fs_get_control("B7", "A100", ls_ref_desc)
//회사명
ls_companynm = fs_get_control("B7", "A600", ls_ref_desc)

ls_currentdir= fs_get_control("B7", "D100", ls_ref_desc)

ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_method[])
End If

If ls_cnd_pay_method = 'Y' Then
	ls_cnd_pay_method = ls_method[1]
Else 
	ls_cnd_pay_method = ''
End If	

If ls_cnd_bankpay = 'Y' Then
	ls_cnd_bankpay = ls_method[2]
Else 
	ls_cnd_bankpay = ''
End If

If ls_cnd_creditpay = 'Y' Then
	ls_cnd_creditpay = ls_method[3]
Else 
	ls_cnd_creditpay = ''
End If	

If ls_cnd_etcpay = 'Y' Then
	For p = 4 To UpperBound(ls_method)
		ls_etc += ls_method[p] + ','
		cnt ++
	Next
	ls_etc = MidA(ls_etc, 1, LenA(ls_etc) - 1)
Else 
	ls_cnd_etcpay = ''
	ls_etc = ''
End If

//header record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'H')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_header[])
End if

//Data record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data[])
End if

//Data Detail record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'R')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data_detail[])
End if

//Trailer record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'T')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_Trailer[])
End if

//value값 구하기
DECLARE invf_recorddet_cu CURSOR FOR
	SELECT A.RECORD
	     , A.SEQNO
		  , A.ITEMKEY
	     , A.ITEMKEY_PROPERTY
	     , A.ITEMTYPE		  
		  , A.ITEM_VALUE
		  , A.MAXLENGTH
		  , A.PAD_TYPE
		  , A.PAD_VALUE
		  , B.ITEM_DELIMIT
		  , B.RECORD_DELIMIT
	  FROM INVF_RECORDDET A
	     , INVF_RECORDMST B
	 WHERE A.INVF_TYPE = B.INVF_TYPE
	   AND A.RECORD    = B.RECORD
	   AND A.INVF_TYPE = :ls_cnd_invf_type
 ORDER BY A.INVF_TYPE, A.RECORD, A.SEQNO            ;
//		AND RECORD    = 'H'                     ;
		
	OPEN invf_recorddet_cu;
	
	DO WHILE (True)
	
		Fetch invf_recorddet_cu
		Into :ls_record, :ll_seqno, :ll_itemkey, :ls_itemkey_property, :ls_itemtype, :ls_item_value, :ll_maxlength
		   , :ls_pad_type, :ls_pad_value, :ls_item_delimit, :ls_record_delimit;

		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		If isnull(Trim(ls_item_value)) Then ls_item_value = ''
		
		ls_check = ''
		//header 부분
		If ls_record = 'H' Then
			If ls_itemtype = 'V' Then
				ls_header[ll_seqno] = ls_item_value
			Else
				If ll_itemkey = 10000 Then  //위탁회사 코드
					ls_header[ll_seqno] = ls_company //fs_fill_pad(ls_company, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_company
					
				ElseIf ll_itemkey = 10001 Then //위탁회사명
					ls_header[ll_seqno] = ls_companynm //fs_fill_pad(ls_companynm, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_companynm
					
				ElseIf ll_itemkey = 10002 Then // 작업일자
					ls_header[ll_seqno] = string(ld_workdt, 'yyyymmdd')
				End If
				
				If LenA(ls_check) > ll_maxlength Then
					f_msg_usr_err(2100, is_Title, "header의" + string(ll_seqno)+ "의 값이 설정된 max값보다 큼니다.")
					ll_code = 0
					Exit
				End If
			End IF
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_header += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_header_gu   = ls_item_delimit
			ls_record_header_gu = ls_record_delimit
			
		//Data 부분	
		ElseIf ls_record = 'D' Then
			If ls_itemtype = 'V' Then
				ls_data[ll_seqno] = ls_item_value
			Else
				ls_data[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_gu   = ls_item_delimit
			ls_record_data_gu = ls_record_delimit
			
		//Data Detail 부분
		ElseIf ls_record = 'R' Then
			If ls_itemtype = 'V' Then
				ls_data_detail[ll_seqno] = ls_item_value
			Else
				ls_data_detail[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data_detail += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_detail_gu   = ls_item_delimit
			ls_record_data_detail_gu = ls_record_delimit
			
		//trailer 부분
		ElseIf ls_record = 'T' Then
			If ls_itemtype = 'V' Then
				ls_trailer[ll_seqno] = ls_item_value
			Else
				ls_trailer[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_trailer += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_trailer_gu   = ls_item_delimit
			ls_record_trailer_gu = ls_record_delimit
			
		End If
		
	LOOP

	If ll_code = 0 Then
		CLOSE invf_recorddet_cu;
		rollback;
		ls_status = 'failiure'
		Goto NextStep
//		Return
	End If
	
CLOSE invf_recorddet_cu;	


//item_key property 'c' 이면 " " 붙이기. 및 콤마 붙이기

//header
ls_seqno_header = MidA(ls_seqno_header, 1, LenA(ls_seqno_header) - 1)
If ls_seqno_header <> "" Then
	fi_cut_string(ls_seqno_header, ";" , ls_seq_header[])
End If

//Data
ls_seqno_data = MidA(ls_seqno_data, 1, LenA(ls_seqno_data) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data[])
End If

//Data Detail
ls_seqno_data_detail = MidA(ls_seqno_data_detail, 1, LenA(ls_seqno_data_detail) - 1)
If ls_seqno_data_detail <> "" Then
	fi_cut_string(ls_seqno_data_detail, ";" , ls_seq_data_detail[])
End If

//trailer
ls_seqno_trailer = MidA(ls_seqno_trailer, 1, LenA(ls_seqno_trailer) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_trailer, ";" , ls_seq_trailer[])
End If

//File open
Integer li_FileNum
String  ls_filename

//ls_filename = ls_currentdir + string(ld_workdt, 'yyyymmdd') + '.csv'

ls_filename =ls_currentdir + string(ld_workdt, 'yyyymmdd') + '.CSV'

li_FileNum = FileOpen(ls_filename, LineMode!, Write!, LockWrite!, Replace!)
If IsNull(li_filenum) Then li_filenum = -1

If li_filenum < 0 Then
	f_msg_usr_err(9000, is_Title, "File Open Failed!")
	FileClose(li_filenum)			
	ls_status = 'failiure'
	Goto NextStep
	//Return
End If

//header 찍기
ll_gubun = 0
For j = 1 To UpperBound(ls_header)
	For i = 1 To UpperBound(ls_seq_header)
		If j =  integer(ls_seq_header[i]) Then
			If isnull(ls_header[j]) or ls_header[j] = '' Then
				ls_head += ls_item_header_gu
			Else
				ls_head += ls_comma + ls_header[j] + ls_comma + ls_item_header_gu
			End If
			ll_gubun = j
			Exit
		End If
	Next
	
	IF ll_gubun <> j  Then
		If ls_header[j] = '' Then
			ls_head += ls_item_header_gu
		Else
			ls_head += ls_header[j] + ls_item_header_gu
		End If
	End IF
Next

ls_trail_pnt = MidA(ls_head, 1, LenA(ls_head) - 1)// + ls_record_header_gu
// 여기까지..

//For i = 1 To UpperBound(ls_header)
li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)

If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
		FileClose(li_filenum)
		ls_status = 'failiure'
		Goto NextStep
		//Return 
End If
//Next

ls_trail_pnt = ''

////data 
//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'D')
//
//If ls_property <> "" Then
//	fi_cut_string(ls_property, ";" , ls_resulttt[])
//End if
//
////data- detail
//ls_property_d = fs_itemkey_property(ls_cnd_invf_type, 'R')
//
//If ls_property_d <> "" Then
//	fi_cut_string(ls_property_d, ";" , ls_resultttt[])
//End if

DECLARE reqinfo_cu CURSOR FOR
	SELECT PAYID				//고객번호
	     , TRDT					//청구기준일
		  , CHARGEDT			//청구주기
		  , REQNUM				//청구번호
		  , CUSTOMERNM			//고객명
		  , LASTNAME			//고객명()
		  , BIL_ZIPCOD			//우편번호
		  , BIL_ADDR1			//주소
		  , BIL_ADDR2 			//주소
		  , CORPNM				//법인명
		  , CORPNM_2   		//법인명		  
		  , BANK 	 			//은행코드
		  , BANKSHOP			//은행
		  , ACCTNO		
		  , ACCT_OWNER
		  , INPUTCLOSEDTCUR	//입금마감일
		  , PAY_METHOD     	//결제채널 '1' 지로, '2' 자동이체
	  FROM REQINFO
	 WHERE TRDT       = :ld_cnd_trdt
	   AND PAY_METHOD IN (:ls_cnd_pay_method, :ls_cnd_bankpay, :ls_cnd_creditpay, :ls_etc)
		AND INV_TYPE   = NVL(:ls_cnd_inv_type, INV_TYPE)
		AND INV_YN     = 'Y'
 ORDER BY PAYID ;
	 
	OPEN reqinfo_cu;
	
	DO WHILE (True)
		
		Fetch reqinfo_cu
		Into :ls_payid   , :ld_trdt, :ls_chargedt, :ls_reqnum, :ls_customernm
	      , :ls_lastname, :ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_corpnm, :ls_corpnm_2
			, :ls_bank    , :ls_bankshop, :ls_acctno, :ls_acct_owner, :ld_inputclosedtcur
			, :ls_pay_method                                                               ;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//고객별 청구금액
		SELECT PAYID 
		     , SUM( NVL(BTRAMT01, 0) + NVL(BTRAMT02, 0) + NVL(BTRAMT03, 0) + NVL(BTRAMT04, 0) + NVL(BTRAMT05, 0) + 
		            NVL(BTRAMT06, 0) + NVL(BTRAMT07, 0) + NVL(BTRAMT08, 0) + NVL(BTRAMT09, 0) + NVL(BTRAMT10, 0) +
					   NVL(BTRAMT11, 0) + NVL(BTRAMT12, 0) + NVL(BTRAMT13, 0) + NVL(BTRAMT14, 0) + NVL(BTRAMT15, 0) +
					   NVL(BTRAMT16, 0) + NVL(BTRAMT17, 0) + NVL(BTRAMT18, 0) + NVL(BTRAMT19, 0) + NVL(BTRAMT20, 0) +
						NVL(BTRAMT21, 0) + NVL(BTRAMT22, 0) + NVL(BTRAMT23, 0) + NVL(BTRAMT24, 0) + NVL(BTRAMT25, 0) +
						NVL(BTRAMT26, 0) + NVL(BTRAMT27, 0) + NVL(BTRAMT28, 0) + NVL(BTRAMT29, 0) + NVL(BTRAMT30, 0) )   
		 INTO :ls_py
		    , :ll_customer_sum
		 FROM REQAMTINFO
		WHERE PAYID = :ls_payid
		  AND TRDT  = :ld_trdt 
	GROUP BY PAYID;
		  
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			CONTINUE
   	End If  
		
		If ll_customer_sum = 0 Then Continue
		
		Long tt
		For tt = 1 To UpperBound(ls_itemkey_data)
			Choose Case ls_itemkey_data[tt]
				Case '10000'
					ls_data[tt] = ls_company
				Case '10003'
					ls_data[tt] = fs_fill_pad(ls_payid , 15, '1', '0')//고객코드
				Case '10004'
					ls_data[tt] = fs_fill_pad(ls_reqnum, 10, '1', '0')//청구서 번호
				Case '10005'
					ls_data[tt] = ls_customernm
				Case '10006'  //반각
					ls_data[tt] = ls_lastname
				Case '10007'
					ls_data[tt] = ls_bil_zipcod
				Case '10008'
					If LenA(ls_bil_addr1) <= 30 Then
						ls_data[tt] = ls_bil_addr1
					Else
						ls_data[tt] = ''					
					End If
				Case '10009'
					If LenA(ls_bil_addr1) <= 30 Then
						ls_data[tt] = ls_bil_addr2
					Else
						ls_data[tt] = ''
					End If
				Case '10010'
					ls_data[tt] = ''
				Case '10011'
					If LenA(ls_bil_addr1) > 30 Then
						ls_data[tt] = ls_bil_addr1 + ' ' + ls_bil_addr2
					Else
						ls_data[tt] = ''
					End If			
				Case '10012'	//법인명
					ls_data[tt] = ls_corpnm   
				Case '10013'	//법인명() 
					ls_data[tt] = ls_corpnm_2 
				Case '10094'	//부과명
					ls_data[tt] = ''
				Case '10014'	//청구서 발행일
					ls_data[tt] = string(ld_workdt, 'yyyymmdd')  
				Case '10066' 	//청구액합계
					ls_data[tt] = string(ll_customer_sum)
				Case '10015'	//결제채널
					ls_data[tt] = ls_pay_method 
				Case '10067'	//청구서 종류  결제채널이 '2'면 2...
					If ls_pay_method = '2' Then
						ls_data[tt] = '1'
					Else
						ls_data[tt] = '2'
					End If
				Case '10068'	//전용계좌번호지정
					If ls_pay_method = '1' Then
						ls_data[tt] = '1'
					ElseIf ls_pay_method = '2' Then
						ls_data[tt] = '0'
					Else
						ls_data[tt] = '0'
					End If
				Case '10069'	//전용계좌인자우선
					If ls_data[tt - 1] = '1' Then
						ls_data[tt] = '1'						
					ElseIf ls_data[tt - 1] = '2' Then
						ls_data[tt] = '0'
					Else
						ls_data[tt] = '0'
					End If
				Case '10016' 	//예금주
					If ls_pay_method = '1' Then
						ls_data[tt] = ls_accowner 
					Else
						ls_data[tt] = ''
					End If
				Case '10017' 	//은행코드
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_result[1]
//					Else
						ls_data[tt] = ''
//					End If					
				Case '10018'	//은행명
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_bank_name
//					Else
						ls_data[tt] = ''
//					End If
				Case '10019' //지점코드
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_bank_dealer
//					Else
						ls_data[tt] = ''
//					End If			
				Case '10020' //지점명
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_bank_dealer_nm
//					Else
						ls_data[tt] = ''
//					End If				
				Case '10021'  //예금과목
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_acct_item
//					Else
						ls_data[tt] = ''
//					End If				
				Case '10022'	// 은행계좌번호
//					If ls_pay_method = '1' Then
//						ls_data[tt] = ls_result[2]
//					Else
						ls_data[tt] = ''
//					End If			
				Case '10023' 	//고객은행코드
					If ls_pay_method = '2' Then
						ls_data[tt] = ls_bank
					Else
						ls_data[tt] = ''
					End If
				Case '10024' 	//고객은행
					If ls_pay_method = '2' Then
						ls_data[tt] = ls_bankshop
					Else
						ls_data[tt] = ''
					End If
				Case '10088'	//지점코드
					If ls_pay_method = '2' Then
						ls_data[tt] = '000'
					Else
						ls_data[tt] = ''
					End If
				Case '10089'	//지점명
					If ls_pay_method = '2' Then
						ls_data[tt] = ''
					Else
						ls_data[tt] = ''
					End If		
				Case '10093'	//예금과목
					If ls_pay_method = '2' Then
						ls_data[tt] = '1'
					Else
						ls_data[tt] = ''
					End If							
				Case '10025'
					If ls_pay_method = '2' Then
						ls_data[tt] = ls_acctno
					Else
						ls_data[tt] = ''
					End If	
				Case '10026'
					If ls_pay_method = '2' Then
						ls_data[tt] = ls_acct_owner
					Else
						ls_data[tt] = ''
					End If	
				Case '10027'	//입금마감일
					ls_data[tt] = string(ld_inputclosedtcur, 'yyyymmdd') 
				Case '10095'	//신규코드
					If ls_pay_method = '1' Then
						ls_data[tt] = ''
					Else
						ls_data[tt] = '1'
					End If	
					
				Case Else
					If MidA(ls_itemkey_data[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
						ls_data[tt] = ''
					End If
			End Choose
			
		Next

		//안내문  59~ 72  = ''
		ll_count ++
		ll_gubun = 0

		For j = 1 To UpperBound(ls_data)
			
			For i = 1 To UpperBound(ls_seq_data)
				If j =  integer(ls_seq_data[i]) Then
					If isnull(ls_data[j]) or ls_data[j] = '' Then
						ls_da += ls_item_data_gu
					Else
						ls_da += ls_comma + ls_data[j] + ls_comma + ls_item_data_gu
					End If
					
					ll_gubun = j
					Exit
				End If
			Next
			
			IF ll_gubun <> j  Then
				If ls_data[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
					ls_da += ls_item_data_gu
				Else
					ls_da += ls_data[j] + ls_item_data_gu
				End If
			End IF
			
		Next
				
		ls_trail_pnt = MidA(ls_da, 1, LenA(ls_da) - 1) + ls_record_data_gu
				
		//For i = 1 To UpperBound(ls_data)
			li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
			If li_write_bytes < 0 Then 
				f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record)")
				FileClose(li_filenum)
				ls_status = 'failiure'
				Goto NextStep
				//Return 
			End If
		//Next
		
		ls_trail_pnt = ''
		ls_da        = ''
    
		//상세항목
		DECLARE reqamtinfo_cu CURSOR FOR
			SELECT PAYID		//고객번호
				  , TRDT			//청구기준일
				  , CHARGEDT	//청구주기
				  , REQNUM		//청구번호
//				  , SUPPLYAMT  //공급가액
//				  , SURTAX 		//부과세
				  , NVL(BTRAMT01, 0), NVL(BTRAMT02, 0), NVL(BTRAMT03, 0), NVL(BTRAMT04, 0) 
				  , NVL(BTRAMT05, 0), NVL(BTRAMT06, 0), NVL(BTRAMT07, 0), NVL(BTRAMT08, 0) 
				  , NVL(BTRAMT09, 0), NVL(BTRAMT10, 0), NVL(BTRAMT11, 0), NVL(BTRAMT12, 0) 
				  , NVL(BTRAMT13, 0), NVL(BTRAMT14, 0), NVL(BTRAMT15, 0), NVL(BTRAMT16, 0) 
				  , NVL(BTRAMT17, 0), NVL(BTRAMT18, 0), NVL(BTRAMT09, 0), NVL(BTRAMT20, 0)	
				  , NVL(BTRAMT21, 0), NVL(BTRAMT22, 0), NVL(BTRAMT23, 0), NVL(BTRAMT24, 0) 
				  , NVL(BTRAMT25, 0), NVL(BTRAMT26, 0), NVL(BTRAMT27, 0), NVL(BTRAMT28, 0) 
				  , NVL(BTRAMT29, 0), NVL(BTRAMT30, 0)				  
				  , NVL(BTRDESC01,''), NVL(BTRDESC02,''), NVL(BTRDESC03,'')
				  , NVL(BTRDESC04,''), NVL(BTRDESC05,''), NVL(BTRDESC06,'')
				  , NVL(BTRDESC07,''), NVL(BTRDESC08,''), NVL(BTRDESC09,'')
				  , NVL(BTRDESC10,''), NVL(BTRDESC11,''), NVL(BTRDESC12,'')
				  , NVL(BTRDESC13,''), NVL(BTRDESC14,''), NVL(BTRDESC15,'')
				  , NVL(BTRDESC16,''), NVL(BTRDESC17,''), NVL(BTRDESC18,'')
				  , NVL(BTRDESC19,''), NVL(BTRDESC20,''), NVL(BTRDESC21,'')
				  , NVL(BTRDESC22,''), NVL(BTRDESC23,''), NVL(BTRDESC24,'')
				  , NVL(BTRDESC25,''), NVL(BTRDESC26,''), NVL(BTRDESC27,'')
				  , NVL(BTRDESC28,''), NVL(BTRDESC29,''), NVL(BTRDESC30,'')
			  FROM REQAMTINFO
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ld_cnd_trdt  ;
			 
			OPEN reqamtinfo_cu;
			
			DO WHILE (True)
				
				Fetch reqamtinfo_cu
				Into :ls_payid_amt, :ld_trdt_amt, :ls_chargedt_amt, :ls_reqnum_amt
				   , :ll_btramt[1], :ll_btramt[2], :ll_btramt[3], :ll_btramt[4], :ll_btramt[5]
				   , :ll_btramt[6], :ll_btramt[7], :ll_btramt[8], :ll_btramt[9], :ll_btramt[10]
				   , :ll_btramt[11], :ll_btramt[12], :ll_btramt[13], :ll_btramt[14], :ll_btramt[15]
				   , :ll_btramt[16], :ll_btramt[17], :ll_btramt[18], :ll_btramt[19], :ll_btramt[20]
				   , :ll_btramt[21], :ll_btramt[22], :ll_btramt[23], :ll_btramt[24], :ll_btramt[25]
				   , :ll_btramt[26], :ll_btramt[27], :ll_btramt[28], :ll_btramt[29], :ll_btramt[30]					
					, :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5]
					, :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10] 
					, :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15]
					, :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 
					, :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25]
					, :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30]  ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				For i = 1 To UpperBound(ls_btrdesc)
					If ls_btrdesc[i] = 'null' Or IsNull(ls_btrdesc[i]) Then
						ls_btrdesc[i] = ''
					End If
				Next

				Long pp
		
//				For pp = 1 To UpperBound(ls_itemkey_data_detail)
//					Choose Case ls_itemkey_data_detail[pp]
//						Case '10000'	//위탁회사 코드
//							ls_data_detail[pp] = ls_company
//						Case '10003'	//고객번호
//							ls_data_detail[pp] = fs_fill_pad(ls_payid_amt, 15, '1', '0')
//						Case '10004' 	//청구번호
//							ls_data_detail[pp] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0')
//						Case '10042'	//명세부분 프리 레이아웃지역1-1  
//							ls_data_detail[pp] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
//						Case Else
//							ls_data_detail[pp] = ''
//					End Choose
//				Next
				
				For i = 1 To UpperBound(ls_btrdesc)
					If IsNull(ls_btrdesc[i]) Or ls_btrdesc[i] = '' Then Continue
					
					For pp = 1 To UpperBound(ls_itemkey_data_detail)
						Choose Case ls_itemkey_data_detail[pp]
							Case '10000'	//위탁회사 코드
								ls_data_detail[pp] = ls_company
							Case '10003'	//고객번호
								ls_data_detail[pp] = fs_fill_pad(ls_payid_amt, 15, '1', '0')
							Case '10004' 	//청구번호
								ls_data_detail[pp] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0')
							Case '10042'	//명세부분 프리 레이아웃지역1-1  
								ls_data_detail[pp] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
							Case '10090' 	//청구명세서 번호
								ls_data_detail[pp] = FillA('0', 5 - LenA(string(i))) + string(i) //6 명세서 번호 '0001'
							Case '10043'
								ls_data_detail[pp] = string(i) + FillA('0', 3 - LenA(string(i))) 
							Case '10044'
								ls_data_detail[pp] = ls_btrdesc[i]
							Case '10052'
								ls_data_detail[pp] = string(ll_btramt[i])
							Case Else
								If MidA(ls_itemkey_data_detail[pp], 1, 1) <> '2' Then
									ls_data_detail[pp] = ''
								End If								
								
						End Choose
					Next
					
					//청구대상 고객들의 총 청구금액 sum, count
					ll_amt_total = ll_amt_total + ll_btramt[i]
					ll_count ++
					ll_gubun = 0
					For j = 1 To UpperBound(ls_data_detail)
					
						For t = 1 To UpperBound(ls_seq_data_detail)
							If j =  integer(ls_seq_data_detail[t]) Then
								If isnull(ls_data_detail[j]) or ls_data_detail[j] = '' Then
									ls_da_t += ls_item_data_detail_gu
								Else
									ls_da_t += ls_comma + ls_data_detail[j] + ls_comma + ls_item_data_detail_gu
								End If
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_data_detail[j] = '' Then
								ls_da_t += ls_item_data_detail_gu
							Else
								ls_da_t += ls_data_detail[j] + ls_item_data_detail_gu
							End If
						End IF
					Next

					ls_trail_pnt = MidA(ls_da_t, 1, LenA(ls_da_t) - 1) + ls_record_data_detail_gu
				
					//For j = 1 To UpperBound(ls_data_detail)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data-detail Record)")
							FileClose(li_filenum)
							ls_status = 'failiure'
							Goto NextStep
							//Return 
						End If
					//Next
					ls_trail_pnt = ''
					ls_da_t = ''
				Next
				
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqamtinfo_cu;		

	LOOP

	If ll_code = 0 Then
		FileClose(li_FileNum)
		rollback;
		ls_status = 'failiure'
		Goto NextStep
		//Return
	End If
	
CLOSE reqinfo_cu;

If ll_count = 0 Then
	FileClose(li_FileNum)
	rollback;
	ls_status = 'failiure'
	Goto NextStep
End IF

long gg
//trailer
For gg = 1 To UpperBound(ls_itemkey_trailer)
	Choose Case ls_itemkey_trailer[gg]
		Case '10000'	//위탁회사 코드
			ls_trailer[gg] = ls_company
		Case '10091' 	//합계건수
			ls_trailer[gg] = string(ll_count)
		Case '10092'	//합계금액
			ls_trailer[gg] = string(ll_amt_total)
		Case Else
			If MidA(ls_itemkey_trailer[gg], 1, 1) <> '2' Then
				ls_trailer[gg] = ''
			End If				
			
	End Choose
Next

//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'T')
//
//If ls_property <> "" Then
//	fi_cut_string(ls_property, ";" , ls_result[])
//End if

ll_gubun = 0
For j = 1 To UpperBound(ls_trailer)
	For i = 1 To UpperBound(ls_seq_trailer)
		If j =  integer(ls_seq_trailer[i]) Then
			If ls_trailer[j] = '' Then
				ls_trail += ls_item_trailer_gu
			Else
				ls_trail += ls_comma + ls_trailer[j] + ls_comma + ls_item_trailer_gu
			End If
			
			ll_gubun = j
			Exit
		End If
	Next
	
	IF ll_gubun <> j  Then
		If ls_trailer[j] = '' Then
			ls_trail += ls_item_trailer_gu
		Else
			ls_trail += ls_trailer[j] + ls_item_trailer_gu
		End If
	End IF
Next

ls_trail_pnt = MidA(ls_trail, 1, LenA(ls_trail) - 1)

//For j = 1 To UpperBound(ls_trailer)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
	If li_write_bytes < 0 Then 
		f_msg_usr_err(9000, is_Title, "File Write Failed! (trailer Record)")
		FileClose(li_filenum)
		ls_status = 'failiure'
		Goto NextStep
		//Return 
	End If
//Next

FileClose(li_FileNum)

ls_status = 'Complete'

ls_filename = MidA(ls_filename, 4)
//li_tab      = Pos(ls_filename, "\")
ls_filename = MidA(ls_filename, PosA(ls_filename, "\") + 1)

NextStep :

//log 생성
INSERT INTO INVF_WORKLOG
			 ( SEQNO
			 , FILEW_DIR
			 , FILEW_NAME
			 , FILEW_STATUS
			 , FILEW_COUNT
			 , FILEW_INVAMT
          , CND_INVF_TYPE
			 , CND_INV_TYPE
			 , CND_WORKDT
			 , CND_INPUTCLOSEDT
			 , CND_TRDT
			 , CND_CHARGEDT
			 , CND_PAY_METHOD
			 , CND_BANKPAY
			 , CND_CREDITPAY
			 , CND_ETCPAY
			 , CRT_USER
			 , CRTDT
			 , PGM_ID )
     VALUES
		    ( seq_invf_worklog.nextval
			 , :ls_currentdir
			 , :ls_filename
			 , :ls_status
			 , :ll_count
			 , :ll_amt_total
			 , :ls_cnd_invf_type
			 , :ls_cnd_inv_type
			 , :ld_workdt
			 , :ld_inputclosedt
			 , :ls_cnd_chargedt
			 , :ld_cnd_trdt
			 , :ls_cnd_pay_method
			 , :ls_cnd_bankpay
			 , :ls_cnd_creditpay
			 , :ls_cnd_etcpay
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id           );
			 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(INVF_WORKLOG)")
	RollBack;
	Return		
End If		

ii_rc = 0

Return
end subroutine

public subroutine uf_prc_db_02 ();//00321지로
String  ls_temp, ls_ref_desc, &
		  ls_payid, ls_chargedt, ls_reqnum, ls_customernm, ls_lastname, ls_corpnm_2, &
		  ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_acctno, ls_acct_owner, ls_result[], &
		  ls_itemtype, ls_itemkey_property, ls_item_value, ls_pad_type, ls_pad_value, &
		  ls_company, ls_companynm, ls_check, ls_record, ls_pay_method, ls_corpnm, ls_py, &
		  ls_bank, ls_bankshop, ls_accowner, ls_bank_dealer, ls_acct_item, ls_bank_name, &
		  ls_bank_dealer_nm, ls_btrdesc[], ls_payid_amt, ls_chargedt_amt, ls_reqnum_amt, &
		  ls_trail, ls_trail_pnt, ls_property, ls_comma = '"', ls_shim  = ',', ls_head, &
		  ls_da, ls_resultt[], ls_resulttt[],  ls_resultttt[], ls_property_d, ls_da_t, &
		  ls_status = ''
Long	  ll_code = 1, ll_seqno, ll_maxlength, i, li_write_bytes, ll_customer_sum, &
        ll_btramt[], j, ll_count = 0, ll_amt_total = 0, ll_gubun = 0, t, p, cnt = 0
Date    ld_workdt, ld_inputclosedt, ld_cnd_trdt, ld_inputclosedtcur, ld_trdt, ld_trdt_amt

		  
String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay, ls_user_id, ls_pgm_id, &
		  ls_header[], ls_data[], ls_data_detail[], ls_trailer[], ls_etc, &
		  ls_itemkey, ls_itemkey_header[], ls_itemkey_data[], ls_itemkey_data_detail[], &
		  ls_itemkey_Trailer[], ls_seqno_header, ls_seqno_data, ls_seqno_data_detail, &
		  ls_seqno_trailer, ls_seq_header[], ls_seq_data[], ls_seq_data_detail[], &
		  ls_seq_trailer[], ls_item_delimit, ls_record_delimit, ls_item_header_gu, &
		  ls_record_header_gu, ls_item_data_gu, ls_record_data_gu, ls_item_data_detail_gu, &
		  ls_record_data_detail_gu, ls_item_trailer_gu, ls_record_trailer_gu, ls_method[]
Long    ll_itemkey
String  ls_itemkey_data1[], ls_itemkey_data2[], ls_itemkey_data3[], ls_data1[], ls_data2[], &
        ls_data3[], ls_seqno_data1, ls_item_data1_gu, ls_record_data1_gu, ls_seqno_data2, &
		  ls_item_data2_gu, ls_record_data2_gu,ls_seqno_data3, ls_item_data3_gu, ls_record_data3_gu, &
		  ls_cdr[], ls_seqno_cdr, ls_item_cdr_gu, ls_record_cdr_gu, ls_seq_data1[], ls_seq_data2[], &
		  ls_seq_data3[], ls_seq_cdr[], ls_pathname, ls_itemkey_cdr[], ls_trdt, ls_inputclosedt, &
		  ls_filename, ls_currentdir, ls_gubun, ls_cregno, ls_validkey, ls_countrynm, ls_countrycod, &
		  ls_stime, ls_rtelnum, ls_space = '', ls_ctype_10, ls_ctype_20, ls_type, ls_ctype2, &
		  ls_useddt_fr, ls_useddt_to
Long    ll_header, ll_itemkey_data, ll_cur_balance, ll_pre_balance, ll_supplyamt, ll_surtax, ll_no, &
        ll_biltime, ll_bilamt
		  
//iu_db.is_title = Title//
ls_cnd_invf_type  = is_data[1]   // 파일타입
ls_trdt           = is_data[2]  // 청구주기
ls_pathname       = is_data[3]  // 경로
ls_filename       = is_data[4]  // 파일명
ls_ctype2         = is_data[5]  // 개인 10 법인 20
ls_gubun          = is_data[6]  // 정상(0, 2), 연체(1, 3)
ls_cnd_inv_type   = is_data[7]

//청구발송여부에 따라 파일생성여부 체크?, 고객type에 따라? 100 프리고객, 컨트리코드로 명 찾았을때 nodata이면?
/*
ls_cnd_pay_method = is_data[2]		//지로
ls_cnd_inv_type   = is_data[3]
ls_cnd_chargedt   = is_data[4]	  	//주기			
ls_cnd_bankpay    = is_data[5]		//자동이체
ls_cnd_creditpay  = is_data[6]		//카드
ls_cnd_etcpay     = is_data[7]		//기타
ls_user_id        = is_data[8]
ls_pgm_id         = is_data[9]
ls_pathname       = is_data[10]
ls_trdt           = is_data[11]

ld_workdt	      = id_data[1]
ld_inputclosedt   = id_data[2]
ld_cnd_trdt       = id_data[3] 		// 기준일
*/

ii_rc = -1

//위탁회사 ls_result[1] = 은행코드 , ls_result[2] = 은행계좌번호
ls_temp = fs_get_control("B7","A110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

//개인
ls_ctype_10    = fs_get_control("B0", "P111", ls_ref_desc)

//법인
ls_temp	= fs_get_control("B0", "P110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
ls_ctype_20    = ls_result[1]

// 예금주
ls_accowner       = fs_get_control("B7", "A120", ls_ref_desc)
//지점코드
ls_bank_dealer    = fs_get_control("B7", "A140", ls_ref_desc)
//예금과목
ls_acct_item      = fs_get_control("B7", "A160", ls_ref_desc)
//은행명
ls_bank_name      = fs_get_control("B7", "A130", ls_ref_desc)
//지점명
ls_bank_dealer_nm = fs_get_control("B7", "A150", ls_ref_desc)
//위탁회사 코드
ls_company        = fs_get_control("B7", "A100", ls_ref_desc)
//회사명
ls_companynm      = fs_get_control("B7", "A600", ls_ref_desc)

//ls_currentdir     = fs_get_control("B7", "D100", ls_ref_desc)

ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_method[])
End If

If ls_cnd_pay_method = 'Y' Then
	ls_cnd_pay_method = ls_method[1]
Else 
	ls_cnd_pay_method = ''
End If	

If ls_cnd_bankpay = 'Y' Then
	ls_cnd_bankpay = ls_method[2]
Else 
	ls_cnd_bankpay = ''
End If

If ls_cnd_creditpay = 'Y' Then
	ls_cnd_creditpay = ls_method[3]
Else 
	ls_cnd_creditpay = ''
End If	

If ls_cnd_etcpay = 'Y' Then
	For p = 4 To UpperBound(ls_method)
		ls_etc += ls_method[p] + ','
		cnt ++
	Next
	ls_etc = MidA(ls_etc, 1, LenA(ls_etc) - 1)
Else 
	ls_cnd_etcpay = ''
	ls_etc = ''
End If

If ls_gubun <= '4' Then //지로
	ls_cnd_pay_method =  ls_method[1]
Else //자동이체
	ls_cnd_bankpay = ls_method[2]
End If
//header record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'H')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_header[])
End if

//Data record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data[])
End if
//Data record1 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D1')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data1[])
End if

//Data record2 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D2')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data2[])
End if
//Data record3 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D3')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data3[])
End if

//Data Detail record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'R')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data_detail[])
End if

//Trailer record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'T')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_Trailer[])
End if

//CDR record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'C')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_cdr[])
End if

//value값 구하기
DECLARE invf_recorddet_cu CURSOR FOR
	SELECT A.RECORD
	     , A.SEQNO
		  , A.ITEMKEY
	     , A.ITEMKEY_PROPERTY
	     , A.ITEMTYPE		  
		  , A.ITEM_VALUE
		  , A.MAXLENGTH
		  , A.PAD_TYPE
		  , A.PAD_VALUE
		  , B.ITEM_DELIMIT
		  , B.RECORD_DELIMIT
	  FROM INVF_RECORDDET A
	     , INVF_RECORDMST B
	 WHERE A.INVF_TYPE = B.INVF_TYPE
	   AND A.RECORD    = B.RECORD
	   AND A.INVF_TYPE = :ls_cnd_invf_type
 ORDER BY A.INVF_TYPE, A.RECORD, A.SEQNO            ;
//		AND RECORD    = 'H'                     ;
		
	OPEN invf_recorddet_cu;
	
	DO WHILE (True)
	
		Fetch invf_recorddet_cu
		Into :ls_record, :ll_seqno, :ll_itemkey, :ls_itemkey_property, :ls_itemtype, :ls_item_value, :ll_maxlength
		   , :ls_pad_type, :ls_pad_value, :ls_item_delimit, :ls_record_delimit;

		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		If isnull(Trim(ls_item_value)) Then ls_item_value = ''
		
		ls_check = ''
		//header 부분
		If ls_record = 'H' Then
			If ls_itemtype = 'V' Then
				ls_header[ll_seqno] = ls_item_value
			Else
				If ll_itemkey = 10000 Then  //위탁회사 코드
					ls_header[ll_seqno] = ls_company //fs_fill_pad(ls_company, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_company
					
				ElseIf ll_itemkey = 10001 Then //위탁회사명
					ls_header[ll_seqno] = ls_companynm //fs_fill_pad(ls_companynm, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_companynm
					
				ElseIf ll_itemkey = 10002 Then // 작업일자
					ls_header[ll_seqno] = string(ld_workdt, 'yyyymmdd')
				End If
				
				If LenA(ls_check) > ll_maxlength Then
					f_msg_usr_err(2100, is_Title, "header의" + string(ll_seqno)+ "의 값이 설정된 max값보다 큼니다.")
					ll_code = 0
					Exit
				End If
			End IF
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_header += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_header_gu   = ls_item_delimit
			ls_record_header_gu = ls_record_delimit
			
		//Data 부분	
		ElseIf ls_record = 'D' Then
			If ls_itemtype = 'V' Then
				ls_data[ll_seqno] = ls_item_value
			Else
				ls_data[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_gu   = ls_item_delimit
			ls_record_data_gu = ls_record_delimit
		//Data1 부분		
		ElseIf ls_record = 'D1' Then
			If ls_itemtype = 'V' Then
				ls_data1[ll_seqno] = ls_item_value
			Else
				ls_data1[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data1 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data1_gu   = ls_item_delimit
			ls_record_data1_gu = ls_record_delimit
			
		//Data2 부분		
		ElseIf ls_record = 'D2' Then
			If ls_itemtype = 'V' Then
				ls_data2[ll_seqno] = ls_item_value
			Else
				ls_data2[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data2 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data2_gu   = ls_item_delimit
			ls_record_data2_gu = ls_record_delimit	

		//Data3 부분		
		ElseIf ls_record = 'D3' Then
			If ls_itemtype = 'V' Then
				ls_data3[ll_seqno] = ls_item_value
			Else
				ls_data3[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data3 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data3_gu   = ls_item_delimit
			ls_record_data3_gu = ls_record_delimit	
			
		//Data Detail 부분
		ElseIf ls_record = 'R' Then
			If ls_itemtype = 'V' Then
				ls_data_detail[ll_seqno] = ls_item_value
			Else
				ls_data_detail[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data_detail += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_detail_gu   = ls_item_delimit
			ls_record_data_detail_gu = ls_record_delimit
			
		//trailer 부분
		ElseIf ls_record = 'T' Then
			If ls_itemtype = 'V' Then
				ls_trailer[ll_seqno] = ls_item_value
			Else
				ls_trailer[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_trailer += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_trailer_gu   = ls_item_delimit
			ls_record_trailer_gu = ls_record_delimit
		
		//cdr 부분
		ElseIf ls_record = 'C' Then
			If ls_itemtype = 'V' Then
				ls_cdr[ll_seqno] = ls_item_value
			Else
				ls_cdr[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_cdr += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_cdr_gu   = ls_item_delimit
			ls_record_cdr_gu = ls_record_delimit			
		End If
		
	LOOP

	If ll_code = 0 Then
		CLOSE invf_recorddet_cu;
		rollback;
		ls_status = 'failiure'
		Goto NextStep
//		Return
	End If
	
CLOSE invf_recorddet_cu;	

//item_key property 'c' 이면 " " 붙이기. 및 콤마 붙이기

//header
ls_seqno_header = MidA(ls_seqno_header, 1, LenA(ls_seqno_header) - 1)
If ls_seqno_header <> "" Then
	fi_cut_string(ls_seqno_header, ";" , ls_seq_header[])
End If

//Data
ls_seqno_data = MidA(ls_seqno_data, 1, LenA(ls_seqno_data) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data[])
End If
//Data1
ls_seqno_data = MidA(ls_seqno_data1, 1, LenA(ls_seqno_data1) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data1[])
End If
//Data2
ls_seqno_data = MidA(ls_seqno_data2, 1, LenA(ls_seqno_data2) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data2[])
End If
//Data3
ls_seqno_data = MidA(ls_seqno_data3, 1, LenA(ls_seqno_data3) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data3[])
End If

//Data Detail
ls_seqno_data_detail = MidA(ls_seqno_data_detail, 1, LenA(ls_seqno_data_detail) - 1)
If ls_seqno_data_detail <> "" Then
	fi_cut_string(ls_seqno_data_detail, ";" , ls_seq_data_detail[])
End If

//trailer
ls_seqno_trailer = MidA(ls_seqno_trailer, 1, LenA(ls_seqno_trailer) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_trailer, ";" , ls_seq_trailer[])
End If

//cdr
ls_seqno_cdr = MidA(ls_seqno_cdr, 1, LenA(ls_seqno_cdr) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_cdr, ";" , ls_seq_cdr[])
End If

//파일명 생성을 위해...., 청구주기별 사용기간 
select to_char(inputclosedt, 'yyyymmdd')
     , to_char(useddt_fr, 'yyyymmdd')
	  , to_char(useddt_to, 'yyyymmdd')
  into :ls_inputclosedt
     , :ls_useddt_fr
	  , :ls_useddt_to
  from reqconf
 where reqdt = to_date(:ls_trdt, 'yyyy-mm-dd');
 
 ls_filename += "." + MidA(ls_inputclosedt, 3, 6)
 
//File open
Integer li_FileNum

li_filenum = FileOpen(ls_pathname+"\"+ls_filename, LineMode!, Write!, LockReadWrite!, Replace!)

If IsNull(li_filenum) Then li_filenum = -1

If li_filenum < 0 Then
	f_msg_usr_err(9000, is_Title, "File Open Failed!")
	FileClose(li_filenum)			
	ls_status = 'failiure_file_open'
	Goto NextStep
	//Return
End If

//header 찍기
ll_gubun  = 0
ll_header = 0
ll_header = UpperBound(ls_header)

If Isnull(ll_header) Then ll_header = 0

If ll_header > 0 Then
	For j = 1 To UpperBound(ls_header)
		For i = 1 To UpperBound(ls_seq_header)
			If j =  integer(ls_seq_header[i]) Then
				If isnull(ls_header[j]) or ls_header[j] = '' Then
					ls_head += ls_item_header_gu
				Else
					ls_head += ls_comma + ls_header[j] + ls_comma + ls_item_header_gu
				End If
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_header[j] = '' Then
				ls_head += ls_item_header_gu
			Else
				ls_head += ls_header[j] + ls_item_header_gu
			End If
		End IF
	Next
	
	ls_trail_pnt = MidA(ls_head, 1, LenA(ls_head) - 1)// + ls_record_header_gu
	// 여기까지..
	
	//For i = 1 To UpperBound(ls_header)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
	
	If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
			FileClose(li_filenum)
			ls_status = 'failiure_heard_write'
			Goto NextStep
			//Return 
	End If
	//Next
End If
ls_trail_pnt = ''

////data 
//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'D')
//
//If ls_property <> "" Then
//	fi_cut_string(ls_property, ";" , ls_resulttt[])
//End if
//
////data- detail
//ls_property_d = fs_itemkey_property(ls_cnd_invf_type, 'R')
//
//If ls_property_d <> "" Then
//	fi_cut_string(ls_property_d, ";" , ls_resultttt[])
//End if

DECLARE reqinfo_cu CURSOR FOR
	SELECT PAYID				//고객번호
	     , TRDT					//청구기준일
		  , CHARGEDT			//청구주기
		  , REQNUM				//청구번호
		  , CUSTOMERNM			//고객명
		  , LASTNAME			//고객명()
		  , BIL_ZIPCOD			//우편번호
		  , BIL_ADDR1			//주소
		  , BIL_ADDR2 			//주소
		  , CORPNM				//법인명
		  , CORPNM_2   		//법인명		  
		  , BANK 	 			//은행코드
		  , BANKSHOP			//은행
		  , ACCTNO		
		  , ACCT_OWNER
		  , INPUTCLOSEDTCUR	//입금마감일
		  , PAY_METHOD     	//결제채널 '1' 지로, '2' 자동이체
		  , Nvl(CREGNO, '**********')   CREGNO //사업자 등록번호
	  FROM REQINFO
	 WHERE TRDT       = to_date(:ls_trdt, 'yyyy-mm-dd')
	   AND PAY_METHOD IN (:ls_cnd_pay_method, :ls_cnd_bankpay, :ls_cnd_creditpay, :ls_etc)
		//AND INV_TYPE   = NVL(:ls_cnd_inv_type, INV_TYPE)
		AND INV_YN     = 'Y'
		AND CTYPE2     = :ls_ctype2
 ORDER BY PAYID ;
	 
	OPEN reqinfo_cu;
	
	DO WHILE (True)
		
		Fetch reqinfo_cu
		Into :ls_payid   , :ld_trdt, :ls_chargedt, :ls_reqnum, :ls_customernm
	      , :ls_lastname, :ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_corpnm, :ls_corpnm_2
			, :ls_bank    , :ls_bankshop, :ls_acctno, :ls_acct_owner, :ld_inputclosedtcur
			, :ls_pay_method, :ls_cregno                                                         ;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//고객별 청구금액
		SELECT PAYID 
		     , CUR_BALANCE
			  , PRE_BALANCE
			  , SUPPLYAMT
			  , SURTAX
//		     , SUM( NVL(BTRAMT01, 0) + NVL(BTRAMT02, 0) + NVL(BTRAMT03, 0) + NVL(BTRAMT04, 0) + NVL(BTRAMT05, 0) + 
//		            NVL(BTRAMT06, 0) + NVL(BTRAMT07, 0) + NVL(BTRAMT08, 0) + NVL(BTRAMT09, 0) + NVL(BTRAMT10, 0) +
//					   NVL(BTRAMT11, 0) + NVL(BTRAMT12, 0) + NVL(BTRAMT13, 0) + NVL(BTRAMT14, 0) + NVL(BTRAMT15, 0) +
//					   NVL(BTRAMT16, 0) + NVL(BTRAMT17, 0) + NVL(BTRAMT18, 0) + NVL(BTRAMT19, 0) + NVL(BTRAMT20, 0) +
//						NVL(BTRAMT21, 0) + NVL(BTRAMT22, 0) + NVL(BTRAMT23, 0) + NVL(BTRAMT24, 0) + NVL(BTRAMT25, 0) +
//						NVL(BTRAMT26, 0) + NVL(BTRAMT27, 0) + NVL(BTRAMT28, 0) + NVL(BTRAMT29, 0) + NVL(BTRAMT30, 0) )   
		 INTO :ls_py
		    , :ll_cur_balance
			 , :ll_pre_balance
			 , :ll_supplyamt
			 , :ll_surtax 
//		    , :ll_customer_sum
		 FROM REQAMTINFO
		WHERE PAYID = :ls_payid
		  AND TRDT  = :ld_trdt ;
//	GROUP BY PAYID;
		  
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			CONTINUE
   	End If  
		
//		If ll_customer_sum = 0 Then Continue
      //개인구분
		If ls_ctype2 = ls_ctype_10 Then            
		   //정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance <> 0 Then  
					continue
				Else		
					ls_type = '00N'
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance = 0 Then //정상이므로 continue
					continue
				Else
					ls_type = '12N'
				End If
			End If
		//법인
		Else
			//정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance <> 0 Then  
					continue
				Else		
					ls_type = '20N'
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance = 0 Then //정상이므로 continue
					continue
				Else
					ls_type = '32N'
				End If
			End If			
		End If
		
		Long tt
		ll_itemkey_data = UpperBound(ls_itemkey_data)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data)
				Choose Case ls_itemkey_data[tt]
					Case '10000'
						ls_data[tt] = ls_company
					Case '10003'
						ls_data[tt] = fs_fill_pad(ls_payid , 15, '1', '0')//고객코드
					Case '10004'
						ls_data[tt] = fs_fill_pad(ls_reqnum, 10, '1', '0')//청구서 번호
					Case '10005'
						ls_data[tt] = ls_customernm
					Case '10006'  //반각
						ls_data[tt] = ls_lastname
					Case '10007'
						ls_data[tt] = ls_bil_zipcod
					Case '10008'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr1
						Else
							ls_data[tt] = ''					
						End If
					Case '10009'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If
					Case '10010'
						ls_data[tt] = ''
					Case '10011'
						If LenA(ls_bil_addr1) > 30 Then
							ls_data[tt] = ls_bil_addr1 + ' ' + ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If			
					Case '10012'	//법인명
						ls_data[tt] = ls_corpnm   
					Case '10013'	//법인명() 
						ls_data[tt] = ls_corpnm_2 
					Case '10094'	//부과명
						ls_data[tt] = ''
					Case '10014'	//청구서 발행일
						ls_data[tt] = string(ld_workdt, 'yyyymmdd')  
					Case '10066' 	//청구액합계
						ls_data[tt] = string(ll_customer_sum)
					Case '10015'	//결제채널
						ls_data[tt] = ls_pay_method 
					Case '10067'	//청구서 종류  결제채널이 '2'면 2...
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = '2'
						End If
					Case '10068'	//전용계좌번호지정
						If ls_pay_method = '1' Then
							ls_data[tt] = '1'
						ElseIf ls_pay_method = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10069'	//전용계좌인자우선
						If ls_data[tt - 1] = '1' Then
							ls_data[tt] = '1'						
						ElseIf ls_data[tt - 1] = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10016' 	//예금주
						If ls_pay_method = '1' Then
							ls_data[tt] = ls_accowner 
						Else
							ls_data[tt] = ''
						End If
					Case '10017' 	//은행코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[1]
	//					Else
							ls_data[tt] = ''
	//					End If					
					Case '10018'	//은행명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_name
	//					Else
							ls_data[tt] = ''
	//					End If
					Case '10019' //지점코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10020' //지점명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer_nm
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10021'  //예금과목
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_acct_item
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10022'	// 은행계좌번호
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[2]
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10023' 	//고객은행코드
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bank
						Else
							ls_data[tt] = ''
						End If
					Case '10024' 	//고객은행
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bankshop
						Else
							ls_data[tt] = ''
						End If
					Case '10088'	//지점코드
						If ls_pay_method = '2' Then
							ls_data[tt] = '000'
						Else
							ls_data[tt] = ''
						End If
					Case '10089'	//지점명
						If ls_pay_method = '2' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = ''
						End If		
					Case '10093'	//예금과목
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = ''
						End If							
					Case '10025'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acctno
						Else
							ls_data[tt] = ''
						End If	
					Case '10026'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acct_owner
						Else
							ls_data[tt] = ''
						End If	
					Case '10027'	//입금마감일
						ls_data[tt] = string(ld_inputclosedtcur, 'yyyymmdd') 
					Case '10095'	//신규코드
						If ls_pay_method = '1' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = '1'
						End If							
					Case Else
						If MidA(ls_itemkey_data[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data)
				
				For i = 1 To UpperBound(ls_seq_data)
					If j =  integer(ls_seq_data[i]) Then
						If isnull(ls_data[j]) or ls_data[j] = '' Then
							ls_da += ls_item_data_gu
						Else
							ls_da += ls_comma + ls_data[j] + ls_comma + ls_item_data_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data_gu
					Else
						ls_da += ls_data[j] + ls_item_data_gu
					End If
				End IF
				
			Next
					
			ls_trail_pnt = MidA(ls_da, 1, LenA(ls_da) - 1) + ls_record_data_gu
					
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) d")
					FileClose(li_filenum)
					ls_status = 'failiure_d_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D1
      ll_itemkey_data = UpperBound(ls_itemkey_data1)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data1)
				Choose Case ls_itemkey_data1[tt]
					Case '10003'
						ls_data1[tt] = ls_payid								//고객코드
					Case '10095'
						ls_data1[tt] = MidA(ls_trdt, 1, 6)  				//청구년월
					Case '10096'
						ls_data1[tt] = fs_fill_pad('', 6, '1', '0')	//인증키 총갯수
					Case '10097'
						ls_data1[tt] = fs_fill_pad('', 14, '2', '0')	//대표 인증key
					Case '10027'
					   ls_data1[tt] = string(ld_inputclosedtcur, 'yyyymmdd')//입금마감일
					Case '10002'
						ls_data1[tt] = '20051001'  //작업일  -  구빌링의 girobase생성일인거 같음. ㅎ drawupdt
					Case '10005'
						ls_data1[tt] = fs_fill_pad(ls_customernm, 50, '2', ' ')	//고객명
					Case '10098'
						ls_data1[tt] = ls_useddt_fr+ls_useddt_to //사용기간
					Case '10116'
						ls_data1[tt] = ls_type 
					Case '10115'  //space
						ls_data1[tt] = fs_fill_pad(ls_space, 7, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data1[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data1[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data1)
				
				For i = 1 To UpperBound(ls_seq_data1)
					If j =  integer(ls_seq_data1[i]) Then
						If isnull(ls_data1[j]) or ls_data1[j] = '' Then
							ls_da += ls_item_data1_gu
						Else
							ls_da += ls_comma + ls_data1[j] + ls_comma + ls_item_data1_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
								
				IF ll_gubun <> j  Then
					If ls_data1[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data1_gu
					Else
						ls_da += ls_data1[j] //+ ls_item_data1_gu
					End If
				End IF
				
			Next
					
//			ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data1_gu
			ls_trail_pnt = ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D1")
					FileClose(li_filenum)
					ls_status = 'failiure_d1_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D2
		ll_itemkey_data = UpperBound(ls_itemkey_data2)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data2)
				Choose Case ls_itemkey_data2[tt]
					Case '10007'
						ls_data2[tt] = fs_fill_pad(ls_bil_zipcod, 6, '2', ' ')	//우편번호
					Case '10099'
  					   ls_data2[tt] = fs_fill_pad(ls_bil_addr1, 60, '2', ' ') //주소
					Case '10100'
						ls_data2[tt] = fs_fill_pad(ls_bil_addr2, 50, '2', ' ') //주소
               Case '10115'  //space
						ls_data2[tt] = fs_fill_pad(ls_space, 17, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data2[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data2[tt] = ''
						End If						
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data2)
				
				For i = 1 To UpperBound(ls_seq_data2)
					If j =  integer(ls_seq_data2[i]) Then
						If isnull(ls_data2[j]) or ls_data2[j] = '' Then
							ls_da += ls_item_data2_gu
						Else
							ls_da += ls_comma + ls_data2[j] + ls_comma + ls_item_data2_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data2[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data2_gu
					Else
						ls_da += ls_data2[j] //+ ls_item_data2_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data2_gu
			ls_trail_pnt =ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D2")
					FileClose(li_filenum)
					ls_status = 'failiure_d2_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D3
		ll_itemkey_data = UpperBound(ls_itemkey_data3)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data3)
				Choose Case ls_itemkey_data3[tt]
					Case '10066'
						If ll_cur_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_cur_balance)), 9, '1', '0') 	//청구서합계
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_cur_balance), 10, '1', '0') 	//청구서합계
						End If
					Case '10101' 					   
						If ll_pre_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_pre_balance)), 9, '1', '0') 	//미납액
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_pre_balance), 10, '1', '0') 	//미납액
						End If		
					Case '10102'
  					   ls_data3[tt] = fs_fill_pad(string(ll_supplyamt), 10, '1', '0') 	//공급가액
					Case '10103'	
  					   ls_data3[tt] = fs_fill_pad(string(ll_surtax), 10, '1', '0') 		//부가세 
					Case '10104'	
  					   ls_data3[tt] = fs_fill_pad(ls_cregno, 13, '2', ' ') 					//사업자등록번호
					Case '10105'
						ls_data3[tt] = fs_fill_pad(ls_payid, 10, '1', '0')+fs_fill_pad(ls_trdt, 8, '1', '0')+'0' //고객조회번호
					Case '10115'  //space
						ls_data3[tt] = fs_fill_pad(ls_space, 61, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data3[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data3[tt] = ''
						End If				
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data3)
				
				For i = 1 To UpperBound(ls_seq_data3)
					If j =  integer(ls_seq_data3[i]) Then
						If isnull(ls_data3[j]) or ls_data3[j] = '' Then
							ls_da += ls_item_data3_gu
						Else
							ls_da += ls_comma + ls_data3[j] + ls_comma + ls_item_data3_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data3[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data3_gu
					Else
						ls_da += ls_data3[j] //+ ls_item_data3_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data3_gu
			ls_trail_pnt = ls_da		
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D3")
					FileClose(li_filenum)
					ls_status = 'failiure_d3_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//상세항목
		DECLARE reqamtinfo_cu CURSOR FOR
			SELECT PAYID		//고객번호
				  , TRDT			//청구기준일
				  , CHARGEDT	//청구주기
				  , REQNUM		//청구번호
//				  , SUPPLYAMT  //공급가액
//				  , SURTAX 		//부과세
				  , NVL(BTRAMT01, 0), NVL(BTRAMT02, 0), NVL(BTRAMT03, 0), NVL(BTRAMT04, 0) 
				  , NVL(BTRAMT05, 0), NVL(BTRAMT06, 0), NVL(BTRAMT07, 0), NVL(BTRAMT08, 0) 
				  , NVL(BTRAMT09, 0), NVL(BTRAMT10, 0), NVL(BTRAMT11, 0), NVL(BTRAMT12, 0) 
				  , NVL(BTRAMT13, 0), NVL(BTRAMT14, 0), NVL(BTRAMT15, 0), NVL(BTRAMT16, 0) 
				  , NVL(BTRAMT17, 0), NVL(BTRAMT18, 0), NVL(BTRAMT09, 0), NVL(BTRAMT20, 0)	
				  , NVL(BTRAMT21, 0), NVL(BTRAMT22, 0), NVL(BTRAMT23, 0), NVL(BTRAMT24, 0) 
				  , NVL(BTRAMT25, 0), NVL(BTRAMT26, 0), NVL(BTRAMT27, 0), NVL(BTRAMT28, 0) 
				  , NVL(BTRAMT29, 0), NVL(BTRAMT30, 0)				  
				  , NVL(BTRDESC01,''), NVL(BTRDESC02,''), NVL(BTRDESC03,'')
				  , NVL(BTRDESC04,''), NVL(BTRDESC05,''), NVL(BTRDESC06,'')
				  , NVL(BTRDESC07,''), NVL(BTRDESC08,''), NVL(BTRDESC09,'')
				  , NVL(BTRDESC10,''), NVL(BTRDESC11,''), NVL(BTRDESC12,'')
				  , NVL(BTRDESC13,''), NVL(BTRDESC14,''), NVL(BTRDESC15,'')
				  , NVL(BTRDESC16,''), NVL(BTRDESC17,''), NVL(BTRDESC18,'')
				  , NVL(BTRDESC19,''), NVL(BTRDESC20,''), NVL(BTRDESC21,'')
				  , NVL(BTRDESC22,''), NVL(BTRDESC23,''), NVL(BTRDESC24,'')
				  , NVL(BTRDESC25,''), NVL(BTRDESC26,''), NVL(BTRDESC27,'')
				  , NVL(BTRDESC28,''), NVL(BTRDESC29,''), NVL(BTRDESC30,'')
			  FROM REQAMTINFO
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ls_trdt  ;
			 
			OPEN reqamtinfo_cu;
			
			DO WHILE (True)
				
				Fetch reqamtinfo_cu
				Into :ls_payid_amt, :ld_trdt_amt, :ls_chargedt_amt, :ls_reqnum_amt
				   , :ll_btramt[1], :ll_btramt[2], :ll_btramt[3], :ll_btramt[4], :ll_btramt[5]
				   , :ll_btramt[6], :ll_btramt[7], :ll_btramt[8], :ll_btramt[9], :ll_btramt[10]
				   , :ll_btramt[11], :ll_btramt[12], :ll_btramt[13], :ll_btramt[14], :ll_btramt[15]
				   , :ll_btramt[16], :ll_btramt[17], :ll_btramt[18], :ll_btramt[19], :ll_btramt[20]
				   , :ll_btramt[21], :ll_btramt[22], :ll_btramt[23], :ll_btramt[24], :ll_btramt[25]
				   , :ll_btramt[26], :ll_btramt[27], :ll_btramt[28], :ll_btramt[29], :ll_btramt[30]					
					, :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5]
					, :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10] 
					, :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15]
					, :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 
					, :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25]
					, :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30]  ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				For i = 1 To UpperBound(ls_btrdesc)
					If ls_btrdesc[i] = 'null' Or IsNull(ls_btrdesc[i]) Then
						ls_btrdesc[i] = ''
					End If
				Next

				Long pp
		
//				For pp = 1 To UpperBound(ls_itemkey_data_detail)
//					Choose Case ls_itemkey_data_detail[pp]
//						Case '10000'	//위탁회사 코드
//							ls_data_detail[pp] = ls_company
//						Case '10003'	//고객번호
//							ls_data_detail[pp] = fs_fill_pad(ls_payid_amt, 15, '1', '0')
//						Case '10004' 	//청구번호
//							ls_data_detail[pp] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0')
//						Case '10042'	//명세부분 프리 레이아웃지역1-1  
//							ls_data_detail[pp] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
//						Case Else
//							ls_data_detail[pp] = ''
//					End Choose
//				Next
				
				For i = 1 To UpperBound(ls_btrdesc)
					If IsNull(ls_btrdesc[i]) Or ls_btrdesc[i] = '' Then Continue
					
					For pp = 1 To UpperBound(ls_itemkey_data_detail)
						Choose Case ls_itemkey_data_detail[pp]
							Case '10106'
								ls_data_detail[pp] = fs_fill_pad(ls_btrdesc[i], 30, '2', ' ')			// 항목
							Case '10107'
								If ll_btramt[i] < 0 Then
									ls_data_detail[pp] = '-'
								   ls_data_detail[pp] += fs_fill_pad(string(abs(ll_btramt[i])), 9, '1', '0')	// 금액
								Else
									ls_data_detail[pp] = fs_fill_pad(string(ll_btramt[i]), 10, '1', '0')
								End If
							Case '10115'  //space
						   	ls_data_detail[pp] = fs_fill_pad(ls_space, 93, '1', ' ')
							Case Else
								If MidA(ls_itemkey_data_detail[pp], 1, 1) <> '2' Then
									ls_data_detail[pp] = ''
								End If								
								
						End Choose
					Next
					
					//청구대상 고객들의 총 청구금액 sum, count
					ll_amt_total = ll_amt_total + ll_btramt[i]
					ll_count ++
					ll_gubun = 0
					For j = 1 To UpperBound(ls_data_detail)
					
						For t = 1 To UpperBound(ls_seq_data_detail)
							If j =  integer(ls_seq_data_detail[t]) Then
								If isnull(ls_data_detail[j]) or ls_data_detail[j] = '' Then
									ls_da_t += ls_item_data_detail_gu
								Else
									ls_da_t += ls_comma + ls_data_detail[j] + ls_comma + ls_item_data_detail_gu
								End If
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_data_detail[j] = '' Then
								ls_da_t += ls_item_data_detail_gu
							Else
								ls_da_t += ls_data_detail[j] //+ ls_item_data_detail_gu
							End If
						End IF
					Next

					//ls_trail_pnt = mid(ls_da_t, 1, Len(ls_da_t) - 1) + ls_record_data_detail_gu
				   ls_trail_pnt = ls_da_t
					//For j = 1 To UpperBound(ls_data_detail)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data-detail Record) detail")
							FileClose(li_filenum)
							ls_status = 'failiure_amtinfo_write'
							Goto NextStep
							//Return 
						End If
					//Next
					ls_trail_pnt = ''
					ls_da_t = ''
				Next
				
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_amtinfo'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqamtinfo_cu;		
      
		ll_no = 0
		//cdr 상세
		DECLARE cdr_detail CURSOR FOR
			SELECT VALIDKEY
			     , TO_CHAR(STIME, 'yyyymmddhh24miss') STIME 
				  , BILTIME
				  , COUNTRYCOD
				  , RTELNUM
				  , BILAMT
			  FROM POST_BILCDR
  		    WHERE CUSTOMERID = :ls_payid
 		 ORDER BY STIME; 
			 
			OPEN cdr_detail;
			
			DO WHILE (True)
				
				Fetch cdr_detail
				Into :ls_validkey, :ls_stime, :ll_biltime, :ls_countrycod, :ls_rtelnum, :ll_bilamt ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				SELECT COUNTRYNM
				  INTO :ls_countrynm 
				  FROM COUNTRY 
				 WHERE COUNTRYCOD = :ls_countrycod;
				 
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					ll_code = 0
					Exit
				End If			
				
				ll_no = ll_no + 1
				
				ll_itemkey_data = UpperBound(ls_itemkey_cdr)
				If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
				
				If ll_itemkey_data > 0 Then
					For tt = 1 To UpperBound(ls_itemkey_cdr)
						Choose Case ls_itemkey_cdr[tt]
							Case '10108'
								ls_cdr[tt] = fs_fill_pad(string(ll_no), 10, '1', '0') //seqno 
							Case '10109'
								ls_cdr[tt] = fs_fill_pad(ls_validkey, 14, '2', ' ')   //인증키
							Case '10110'
								ls_cdr[tt] = ls_stime                                 //통화시작시간
							Case '10112'
								ls_cdr[tt] = fs_fill_pad(string(ll_biltime), 6, '1', '0')  //사용시간
							Case '10111'
								ls_cdr[tt] = fs_fill_pad(ls_countrynm, 30, '2', ' ')  //국가명
							Case '10113'
								ls_cdr[tt] = fs_fill_pad(ls_rtelnum, 30, '2', ' ')  //착신번호
							Case '10114'
								ls_cdr[tt] = fs_fill_pad(string(ll_bilamt), 10, '1', '0')  //통화금액	
							Case '10115'  //space
						   	ls_cdr[tt] = fs_fill_pad(ls_space, 19, '1', ' ')
							Case Else
								If MidA(ls_itemkey_cdr[tt], 1, 1) <> '2' Then
									ls_cdr[tt] = ''
								End If								
						End Choose				
					Next
			
					//안내문  59~ 72  = ''
					ll_count ++
					ll_gubun = 0
			
					For j = 1 To UpperBound(ls_cdr)
						
						For i = 1 To UpperBound(ls_seq_cdr)
							If j =  integer(ls_seq_cdr[i]) Then
								If isnull(ls_cdr[j]) or ls_cdr[j] = '' Then
									ls_da += ls_item_cdr_gu
								Else
									ls_da += ls_comma + ls_cdr[j] + ls_comma + ls_item_cdr_gu
								End If
								
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_cdr[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
								ls_da += ls_item_cdr_gu
							Else
								ls_da += ls_cdr[j]// + ls_item_cdr_gu
							End If
						End IF
						
					Next
							
					//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_cdr_gu
					ls_trail_pnt =ls_da
					//For i = 1 To UpperBound(ls_data)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) cdr")
							FileClose(li_filenum)
							ls_status = 'failiure_cdr_write'
							Goto NextStep
							//Return 
						End If
					//Next
				End If		
				ls_trail_pnt = ''
				ls_da        = ''
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_cdr'
				Goto NextStep				
				//Return
			End If
			
		CLOSE cdr_detail;			
	LOOP   
	
	If ll_code = 0 Then
		FileClose(li_FileNum)
		rollback;
		ls_status = 'failiure_reqinfo'
		Goto NextStep
		//Return
	End If
	
CLOSE reqinfo_cu;

If ll_count = 0 Then
	FileClose(li_FileNum)
	rollback;
	ls_status = 'failiure'
	Goto NextStep
End IF

long gg
//trailer
ll_itemkey_data = UpperBound(ls_itemkey_trailer)
If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0

If ll_itemkey_data > 0 Then
	For gg = 1 To UpperBound(ls_itemkey_trailer)
		Choose Case ls_itemkey_trailer[gg]
			Case '10000'	//위탁회사 코드
				ls_trailer[gg] = ls_company
			Case '10091' 	//합계건수
				ls_trailer[gg] = string(ll_count)
			Case '10092'	//합계금액
				ls_trailer[gg] = string(ll_amt_total)
			Case Else
				If MidA(ls_itemkey_trailer[gg], 1, 1) <> '2' Then
					ls_trailer[gg] = ''
				End If				
				
		End Choose
	Next
	
	//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'T')
	//
	//If ls_property <> "" Then
	//	fi_cut_string(ls_property, ";" , ls_result[])
	//End if
	
	ll_gubun = 0
	For j = 1 To UpperBound(ls_trailer)
		For i = 1 To UpperBound(ls_seq_trailer)
			If j =  integer(ls_seq_trailer[i]) Then
				If ls_trailer[j] = '' Then
					ls_trail += ls_item_trailer_gu
				Else
					ls_trail += ls_comma + ls_trailer[j] + ls_comma + ls_item_trailer_gu
				End If
				
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_trailer[j] = '' Then
				ls_trail += ls_item_trailer_gu
			Else
				ls_trail += ls_trailer[j] //+ ls_item_trailer_gu
			End If
		End IF
	Next
	
	//ls_trail_pnt = mid(ls_trail, 1, Len(ls_trail) - 1)
	ls_trail_pnt = ls_trail
	//For j = 1 To UpperBound(ls_trailer)
		li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (trailer Record)")
			FileClose(li_filenum)
			ls_status = 'failiure'
			Goto NextStep
			//Return 
		End If
	//Next
End If
FileClose(li_FileNum)

ls_status = 'Complete'

//ls_filename = Mid(ls_filename, 4)
////li_tab      = Pos(ls_filename, "\")
//ls_filename = Mid(ls_filename, Pos(ls_filename, "\") + 1)
//
NextStep :

//log 생성
INSERT INTO INVF_WORKLOG
			 ( SEQNO
			 , FILEW_DIR
			 , FILEW_NAME
			 , FILEW_STATUS
			 , FILEW_COUNT
			 , FILEW_INVAMT
          , CND_INVF_TYPE
			 , CND_INV_TYPE
			 , CND_WORKDT
			 , CND_INPUTCLOSEDT
			 , CND_TRDT
			 , CND_CHARGEDT
			 , CND_PAY_METHOD
			 , CND_BANKPAY
			 , CND_CREDITPAY
			 , CND_ETCPAY
			 , CRT_USER
			 , CRTDT
			 , PGM_ID )
     VALUES
		    ( seq_invf_worklog.nextval
			 , :ls_pathname
			 , :ls_filename
			 , :ls_status
			 , :ll_count
			 , :ll_amt_total
			 , :ls_cnd_invf_type
			 , :ls_cnd_inv_type
			 , sysdate //:ld_workdt
			 , to_date(:ls_inputclosedt, 'yyyymmdd')
			 , :ls_cnd_chargedt
			 , to_date(:ls_trdt, 'yyyymmdd')
			 , :ls_cnd_pay_method
			 , :ls_cnd_bankpay
			 , :ls_cnd_creditpay
			 , :ls_cnd_etcpay
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id           );
			 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(INVF_WORKLOG)")
	RollBack;
	Return		
End If		
commit;
ii_rc = 0

Return
end subroutine

public subroutine uf_prc_db_03 ();//00321자동이체
String  ls_temp, ls_ref_desc, &
		  ls_payid, ls_chargedt, ls_reqnum, ls_customernm, ls_lastname, ls_corpnm_2, &
		  ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_acctno, ls_acct_owner,  &
		  ls_itemtype, ls_itemkey_property, ls_item_value, ls_pad_type, ls_pad_value, &
		  ls_company, ls_companynm, ls_check, ls_record, ls_pay_method, ls_corpnm, ls_py, &
		  ls_bank, ls_bankshop, ls_accowner, ls_bank_dealer, ls_acct_item, ls_bank_name, &
		  ls_bank_dealer_nm, ls_btrdesc[], ls_payid_amt, ls_chargedt_amt, ls_reqnum_amt, &
		  ls_trail, ls_trail_pnt, ls_property, ls_comma = '"', ls_shim  = ',', ls_head, &
		  ls_da, ls_resultt[], ls_resulttt[],  ls_resultttt[], ls_property_d, ls_da_t, &
		  ls_status = ''
Long	  ll_code = 1, ll_seqno, ll_maxlength, i, li_write_bytes, ll_customer_sum, &
        ll_btramt[], j, ll_count = 0, ll_amt_total = 0, ll_gubun = 0, t, p, cnt = 0
Date    ld_workdt, ld_inputclosedt, ld_cnd_trdt, ld_inputclosedtcur, ld_trdt, ld_trdt_amt

		  
String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay, ls_user_id, ls_pgm_id, &
		  ls_header[], ls_data[], ls_data_detail[], ls_trailer[], ls_etc, &
		  ls_itemkey, ls_itemkey_header[], ls_itemkey_data[], ls_itemkey_data_detail[], &
		  ls_itemkey_Trailer[], ls_seqno_header, ls_seqno_data, ls_seqno_data_detail, &
		  ls_seqno_trailer, ls_seq_header[], ls_seq_data[], ls_seq_data_detail[], &
		  ls_seq_trailer[], ls_item_delimit, ls_record_delimit, ls_item_header_gu, &
		  ls_record_header_gu, ls_item_data_gu, ls_record_data_gu, ls_item_data_detail_gu, &
		  ls_record_data_detail_gu, ls_item_trailer_gu, ls_record_trailer_gu, ls_method[]
Long    ll_itemkey
String  ls_itemkey_data1[], ls_itemkey_data2[], ls_itemkey_data3[], ls_data1[], ls_data2[], &
        ls_data3[], ls_seqno_data1, ls_item_data1_gu, ls_record_data1_gu, ls_seqno_data2, &
		  ls_item_data2_gu, ls_record_data2_gu,ls_seqno_data3, ls_item_data3_gu, ls_record_data3_gu, &
		  ls_cdr[], ls_seqno_cdr, ls_item_cdr_gu, ls_record_cdr_gu, ls_seq_data1[], ls_seq_data2[], &
		  ls_seq_data3[], ls_seq_cdr[], ls_pathname, ls_itemkey_cdr[], ls_trdt, ls_inputclosedt, &
		  ls_filename, ls_currentdir, ls_gubun, ls_cregno, ls_validkey, ls_countrynm, ls_countrycod, &
		  ls_stime, ls_rtelnum, ls_space = '', ls_ctype_10, ls_ctype_20, ls_type, ls_ctype2, &
		  ls_useddt_fr, ls_useddt_to, ls_acctno_bef1[], ls_acct_type_bef1[], ls_acctno_bef, ls_acct_type_bef, &
		  ls_paydt1[], ls_paydt, ls_itemkey_data4[], ls_data4[], ls_seqno_data4, ls_item_data4_gu, &
		  ls_record_data4_gu, ls_seq_data4[], ls_result[], ls_workdt, ls_banknm, ls_biltime
Long    ll_header, ll_itemkey_data, ll_cur_balance, ll_pre_balance, ll_supplyamt, ll_surtax, ll_no, &
        ll_biltime, ll_bilamt, ll_payamt1[], ll_payamt, ll_hh, ll_mi, ll_ss
		  
//iu_db.is_title = Title//
ls_cnd_invf_type  = is_data[1]   // 파일타입
ls_trdt           = is_data[2]  // 청구주기
ls_pathname       = is_data[3]  // 경로
ls_filename       = is_data[4]  // 파일명
ls_ctype2         = is_data[5]  // 개인 10 법인 20
ls_gubun          = is_data[6]  // 정상(0, 2), 연체(1, 3)
ls_cnd_inv_type   = is_data[7]  // 청구유형구분(개인고객, 법인고객,... 등등)
ls_workdt         = is_data[8]  // 작업일자
//청구발송여부에 따라 파일생성여부 체크?,  컨트리코드로 명 찾았을때 nodata이면? 현재는 리턴...
//reqinfo에만 있고 reqamtinfo는 없는경우는 현재는 안찍음
/*
ls_cnd_pay_method = is_data[2]		//지로
ls_cnd_inv_type   = is_data[3]
ls_cnd_chargedt   = is_data[4]	  	//주기			
ls_cnd_bankpay    = is_data[5]		//자동이체
ls_cnd_creditpay  = is_data[6]		//카드
ls_cnd_etcpay     = is_data[7]		//기타
ls_user_id        = is_data[8]
ls_pgm_id         = is_data[9]
ls_pathname       = is_data[10]
ls_trdt           = is_data[11]

ld_workdt	      = id_data[1]
ld_inputclosedt   = id_data[2]
ld_cnd_trdt       = id_data[3] 		// 기준일
*/

ii_rc = -1

//위탁회사 ls_result[1] = 은행코드 , ls_result[2] = 은행계좌번호
ls_temp = fs_get_control("B7","A110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

//개인
ls_ctype_10    = fs_get_control("B0", "P111", ls_ref_desc)

//법인
ls_temp	= fs_get_control("B0", "P110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
ls_ctype_20    = ls_result[1]

// 예금주
ls_accowner       = fs_get_control("B7", "A120", ls_ref_desc)
//지점코드
ls_bank_dealer    = fs_get_control("B7", "A140", ls_ref_desc)
//예금과목
ls_acct_item      = fs_get_control("B7", "A160", ls_ref_desc)
//은행명
ls_bank_name      = fs_get_control("B7", "A130", ls_ref_desc)
//지점명
ls_bank_dealer_nm = fs_get_control("B7", "A150", ls_ref_desc)
//위탁회사 코드
ls_company        = fs_get_control("B7", "A100", ls_ref_desc)
//회사명
ls_companynm      = fs_get_control("B7", "A600", ls_ref_desc)

//ls_currentdir     = fs_get_control("B7", "D100", ls_ref_desc)

ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_method[])
End If

// 지로,자동이체청구파일유형
ls_temp =  fs_get_control("B7", "C600", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";", ls_result[])
End If


If ls_cnd_pay_method = 'Y' Then
	ls_cnd_pay_method = ls_method[1]
Else 
	ls_cnd_pay_method = ''
End If	

If ls_cnd_bankpay = 'Y' Then
	ls_cnd_bankpay = ls_method[2]
Else 
	ls_cnd_bankpay = ''
End If

If ls_cnd_creditpay = 'Y' Then
	ls_cnd_creditpay = ls_method[3]
Else 
	ls_cnd_creditpay = ''
End If	

If ls_cnd_etcpay = 'Y' Then
	For p = 4 To UpperBound(ls_method)
		ls_etc += ls_method[p] + ','
		cnt ++
	Next
	ls_etc = MidA(ls_etc, 1, LenA(ls_etc) - 1)
Else 
	ls_cnd_etcpay = ''
	ls_etc = ''
End If

If ls_cnd_invf_type = ls_result[1] Then //지로
	ls_cnd_pay_method =  ls_method[1]
Else //자동이체
	ls_cnd_bankpay = ls_method[2]
End If
//header record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'H')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_header[])
End if

//Data record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data[])
End if
//Data record1 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D1')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data1[])
End if

//Data record2 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D2')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data2[])
End if
//Data record3 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D3')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data3[])
End if

//Data record4 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D4')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data4[])
End if

//Data Detail record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'R')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data_detail[])
End if

//Trailer record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'T')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_Trailer[])
End if

//CDR record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'C')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_cdr[])
End if

//value값 구하기
DECLARE invf_recorddet_cu CURSOR FOR
	SELECT A.RECORD
	     , A.SEQNO
		  , A.ITEMKEY
	     , A.ITEMKEY_PROPERTY
	     , A.ITEMTYPE		  
		  , A.ITEM_VALUE
		  , A.MAXLENGTH
		  , A.PAD_TYPE
		  , A.PAD_VALUE
		  , B.ITEM_DELIMIT
		  , B.RECORD_DELIMIT
	  FROM INVF_RECORDDET A
	     , INVF_RECORDMST B
	 WHERE A.INVF_TYPE = B.INVF_TYPE
	   AND A.RECORD    = B.RECORD
	   AND A.INVF_TYPE = :ls_cnd_invf_type
 ORDER BY A.INVF_TYPE, A.RECORD, A.SEQNO            ;
//		AND RECORD    = 'H'                     ;
		
	OPEN invf_recorddet_cu;
	
	DO WHILE (True)
	
		Fetch invf_recorddet_cu
		Into :ls_record, :ll_seqno, :ll_itemkey, :ls_itemkey_property, :ls_itemtype, :ls_item_value, :ll_maxlength
		   , :ls_pad_type, :ls_pad_value, :ls_item_delimit, :ls_record_delimit;

		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		If isnull(Trim(ls_item_value)) Then ls_item_value = ''
		
		ls_check = ''
		//header 부분
		If ls_record = 'H' Then
			If ls_itemtype = 'V' Then
				ls_header[ll_seqno] = ls_item_value
			Else
				If ll_itemkey = 10000 Then  //위탁회사 코드
					ls_header[ll_seqno] = ls_company //fs_fill_pad(ls_company, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_company
					
				ElseIf ll_itemkey = 10001 Then //위탁회사명
					ls_header[ll_seqno] = ls_companynm //fs_fill_pad(ls_companynm, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_companynm
					
				ElseIf ll_itemkey = 10002 Then // 작업일자
					ls_header[ll_seqno] = string(ld_workdt, 'yyyymmdd')
				End If
				
				If LenA(ls_check) > ll_maxlength Then
					f_msg_usr_err(2100, is_Title, "header의" + string(ll_seqno)+ "의 값이 설정된 max값보다 큼니다.")
					ll_code = 0
					Exit
				End If
			End IF
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_header += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_header_gu   = ls_item_delimit
			ls_record_header_gu = ls_record_delimit
			
		//Data 부분	
		ElseIf ls_record = 'D' Then
			If ls_itemtype = 'V' Then
				ls_data[ll_seqno] = ls_item_value
			Else
				ls_data[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_gu   = ls_item_delimit
			ls_record_data_gu = ls_record_delimit
		//Data1 부분		
		ElseIf ls_record = 'D1' Then
			If ls_itemtype = 'V' Then
				ls_data1[ll_seqno] = ls_item_value
			Else
				ls_data1[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data1 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data1_gu   = ls_item_delimit
			ls_record_data1_gu = ls_record_delimit
			
		//Data2 부분		
		ElseIf ls_record = 'D2' Then
			If ls_itemtype = 'V' Then
				ls_data2[ll_seqno] = ls_item_value
			Else
				ls_data2[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data2 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data2_gu   = ls_item_delimit
			ls_record_data2_gu = ls_record_delimit	

		//Data3 부분		
		ElseIf ls_record = 'D3' Then
			If ls_itemtype = 'V' Then
				ls_data3[ll_seqno] = ls_item_value
			Else
				ls_data3[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data3 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data3_gu   = ls_item_delimit
			ls_record_data3_gu = ls_record_delimit	
			
		//Data4 부분		
		ElseIf ls_record = 'D4' Then
			If ls_itemtype = 'V' Then
				ls_data4[ll_seqno] = ls_item_value
			Else
				ls_data4[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data4 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data4_gu   = ls_item_delimit
			ls_record_data4_gu = ls_record_delimit	
			
		//Data Detail 부분
		ElseIf ls_record = 'R' Then
			If ls_itemtype = 'V' Then
				ls_data_detail[ll_seqno] = ls_item_value
			Else
				ls_data_detail[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data_detail += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_detail_gu   = ls_item_delimit
			ls_record_data_detail_gu = ls_record_delimit
			
		//trailer 부분
		ElseIf ls_record = 'T' Then
			If ls_itemtype = 'V' Then
				ls_trailer[ll_seqno] = ls_item_value
			Else
				ls_trailer[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_trailer += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_trailer_gu   = ls_item_delimit
			ls_record_trailer_gu = ls_record_delimit
		
		//cdr 부분
		ElseIf ls_record = 'C' Then
			If ls_itemtype = 'V' Then
				ls_cdr[ll_seqno] = ls_item_value
			Else
				ls_cdr[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_cdr += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_cdr_gu   = ls_item_delimit
			ls_record_cdr_gu = ls_record_delimit			
		End If
		
	LOOP

	If ll_code = 0 Then
		CLOSE invf_recorddet_cu;
		rollback;
		ls_status = 'failiure'
		Goto NextStep
//		Return
	End If
	
CLOSE invf_recorddet_cu;	

//item_key property 'c' 이면 " " 붙이기. 및 콤마 붙이기

//header
ls_seqno_header = MidA(ls_seqno_header, 1, LenA(ls_seqno_header) - 1)
If ls_seqno_header <> "" Then
	fi_cut_string(ls_seqno_header, ";" , ls_seq_header[])
End If

//Data
ls_seqno_data = MidA(ls_seqno_data, 1, LenA(ls_seqno_data) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data[])
End If
//Data1
ls_seqno_data = MidA(ls_seqno_data1, 1, LenA(ls_seqno_data1) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data1[])
End If
//Data2
ls_seqno_data = MidA(ls_seqno_data2, 1, LenA(ls_seqno_data2) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data2[])
End If
//Data3
ls_seqno_data = MidA(ls_seqno_data3, 1, LenA(ls_seqno_data3) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data3[])
End If
//Data4
ls_seqno_data = MidA(ls_seqno_data4, 1, LenA(ls_seqno_data4) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data4[])
End If
//Data Detail
ls_seqno_data_detail = MidA(ls_seqno_data_detail, 1, LenA(ls_seqno_data_detail) - 1)
If ls_seqno_data_detail <> "" Then
	fi_cut_string(ls_seqno_data_detail, ";" , ls_seq_data_detail[])
End If

//trailer
ls_seqno_trailer = MidA(ls_seqno_trailer, 1, LenA(ls_seqno_trailer) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_trailer, ";" , ls_seq_trailer[])
End If

//cdr
ls_seqno_cdr = MidA(ls_seqno_cdr, 1, LenA(ls_seqno_cdr) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_cdr, ";" , ls_seq_cdr[])
End If

//파일명 생성을 위해...., 청구주기별 사용기간 
select to_char(inputclosedt, 'yyyymmdd')
     , to_char(useddt_fr, 'yyyymmdd')
	  , to_char(useddt_to, 'yyyymmdd')
  into :ls_inputclosedt
     , :ls_useddt_fr
	  , :ls_useddt_to
  from reqconf
 where reqdt = to_date(:ls_trdt, 'yyyy-mm-dd');
 
 ls_filename += "." + MidA(ls_inputclosedt, 3, 6)
 
//File open
Integer li_FileNum

li_filenum = FileOpen(ls_pathname+"\"+ls_filename, LineMode!, Write!, LockReadWrite!, Replace!)

If IsNull(li_filenum) Then li_filenum = -1

If li_filenum < 0 Then
	f_msg_usr_err(9000, is_Title, "File Open Failed!")
	FileClose(li_filenum)			
	ls_status = 'failiure_file_open'
	Goto NextStep
	//Return
End If

//header 찍기
ll_gubun  = 0
ll_header = 0
ll_header = UpperBound(ls_header)

If Isnull(ll_header) Then ll_header = 0

If ll_header > 0 Then
	For j = 1 To UpperBound(ls_header)
		For i = 1 To UpperBound(ls_seq_header)
			If j =  integer(ls_seq_header[i]) Then
				If isnull(ls_header[j]) or ls_header[j] = '' Then
					ls_head += ls_item_header_gu
				Else
					ls_head += ls_comma + ls_header[j] + ls_comma + ls_item_header_gu
				End If
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_header[j] = '' Then
				ls_head += ls_item_header_gu
			Else
				ls_head += ls_header[j] + ls_item_header_gu
			End If
		End IF
	Next
	
	ls_trail_pnt = MidA(ls_head, 1, LenA(ls_head) - 1)// + ls_record_header_gu
	// 여기까지..
	
	//For i = 1 To UpperBound(ls_header)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
	
	If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
			FileClose(li_filenum)
			ls_status = 'failiure_heard_write'
			Goto NextStep
			//Return 
	End If
	//Next
End If
ls_trail_pnt = ''

////data 
//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'D')
//
//If ls_property <> "" Then
//	fi_cut_string(ls_property, ";" , ls_resulttt[])
//End if
//
////data- detail
//ls_property_d = fs_itemkey_property(ls_cnd_invf_type, 'R')
//
//If ls_property_d <> "" Then
//	fi_cut_string(ls_property_d, ";" , ls_resultttt[])
//End if

DECLARE reqinfo_cu CURSOR FOR
	SELECT PAYID				//고객번호
	     , TRDT					//청구기준일
		  , CHARGEDT			//청구주기
		  , REQNUM				//청구번호
		  , CUSTOMERNM			//고객명
		  , LASTNAME			//고객명()
		  , BIL_ZIPCOD			//우편번호
		  , BIL_ADDR1			//주소
		  , BIL_ADDR2 			//주소
		  , CORPNM				//법인명
		  , CORPNM_2   		//법인명		  
		  , BANK 	 			//은행코드
		  , BANKSHOP			//은행
		  , ACCTNO		
		  , ACCT_OWNER
		  , INPUTCLOSEDTCUR	//입금마감일
		  , PAY_METHOD     	//결제채널 '1' 지로, '2' 자동이체
		  , Nvl(CREGNO, '**********')   CREGNO //사업자 등록번호
	  FROM REQINFO
	 WHERE TRDT       = to_date(:ls_trdt, 'yyyy-mm-dd')
	   AND PAY_METHOD IN (:ls_cnd_pay_method, :ls_cnd_bankpay, :ls_cnd_creditpay, :ls_etc)
		//AND INV_TYPE   = NVL(:ls_cnd_inv_type, INV_TYPE)
		AND INV_YN     = 'Y'    
		AND CTYPE2     = :ls_ctype2
 ORDER BY PAYID ;
	 
	OPEN reqinfo_cu;
	
	DO WHILE (True)
		
		Fetch reqinfo_cu
		Into :ls_payid   , :ld_trdt, :ls_chargedt, :ls_reqnum, :ls_customernm
	      , :ls_lastname, :ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_corpnm, :ls_corpnm_2
			, :ls_bank    , :ls_bankshop, :ls_acctno, :ls_acct_owner, :ld_inputclosedtcur
			, :ls_pay_method, :ls_cregno                                                         ;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//고객별 청구금액
		SELECT PAYID 
		     , CUR_BALANCE
			  , PRE_BALANCE
			  , SUPPLYAMT
			  , SURTAX
//		     , SUM( NVL(BTRAMT01, 0) + NVL(BTRAMT02, 0) + NVL(BTRAMT03, 0) + NVL(BTRAMT04, 0) + NVL(BTRAMT05, 0) + 
//		            NVL(BTRAMT06, 0) + NVL(BTRAMT07, 0) + NVL(BTRAMT08, 0) + NVL(BTRAMT09, 0) + NVL(BTRAMT10, 0) +
//					   NVL(BTRAMT11, 0) + NVL(BTRAMT12, 0) + NVL(BTRAMT13, 0) + NVL(BTRAMT14, 0) + NVL(BTRAMT15, 0) +
//					   NVL(BTRAMT16, 0) + NVL(BTRAMT17, 0) + NVL(BTRAMT18, 0) + NVL(BTRAMT19, 0) + NVL(BTRAMT20, 0) +
//						NVL(BTRAMT21, 0) + NVL(BTRAMT22, 0) + NVL(BTRAMT23, 0) + NVL(BTRAMT24, 0) + NVL(BTRAMT25, 0) +
//						NVL(BTRAMT26, 0) + NVL(BTRAMT27, 0) + NVL(BTRAMT28, 0) + NVL(BTRAMT29, 0) + NVL(BTRAMT30, 0) )   
		 INTO :ls_py
		    , :ll_cur_balance
			 , :ll_pre_balance
			 , :ll_supplyamt
			 , :ll_surtax 
//		    , :ll_customer_sum
		 FROM REQAMTINFO
		WHERE PAYID = :ls_payid
		  AND TRDT  = :ld_trdt ;
//	GROUP BY PAYID;
		  
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			CONTINUE
   	End If  
		
//		If ll_customer_sum = 0 Then Continue
      //개인구분
		If ls_ctype2 = ls_ctype_10 Then            
		   //정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance <> 0 Then  
					continue
				Else		
					ls_type = '00N'
					ll_count ++
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance = 0 Then //정상이므로 continue
					continue
				Else
					ls_type = '12N'
					ll_count ++
				End If
			End If
		//법인
		Else
			//정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance <> 0 Then  
					continue
				Else		
					ls_type = '20N'
					ll_count ++
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance = 0 Then //정상이므로 continue
					continue
				Else
					ls_type = '32N'
					ll_count ++
				End If
			End If			
		End If
		
		//은행명 가져오기..
		select codenm 
		  into :ls_banknm
		  from syscod2t 
		 where grcode = 'B400' 
			and code   = :ls_bank;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			ls_banknm = ''
			CONTINUE
   	End If 			
	
		Long tt
		ll_itemkey_data = UpperBound(ls_itemkey_data)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data)
				Choose Case ls_itemkey_data[tt]
					Case '10000'
						ls_data[tt] = ls_company
					Case '10003'
						ls_data[tt] = fs_fill_pad(ls_payid , 15, '1', '0')//고객코드
					Case '10004'
						ls_data[tt] = fs_fill_pad(ls_reqnum, 10, '1', '0')//청구서 번호
					Case '10005'
						ls_data[tt] = ls_customernm
					Case '10006'  //반각
						ls_data[tt] = ls_lastname
					Case '10007'
						ls_data[tt] = ls_bil_zipcod
					Case '10008'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr1
						Else
							ls_data[tt] = ''					
						End If
					Case '10009'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If
					Case '10010'
						ls_data[tt] = ''
					Case '10011'
						If LenA(ls_bil_addr1) > 30 Then
							ls_data[tt] = ls_bil_addr1 + ' ' + ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If			
					Case '10012'	//법인명
						ls_data[tt] = ls_corpnm   
					Case '10013'	//법인명() 
						ls_data[tt] = ls_corpnm_2 
					Case '10094'	//부과명
						ls_data[tt] = ''
					Case '10014'	//청구서 발행일
						ls_data[tt] = string(ld_workdt, 'yyyymmdd')  
					Case '10066' 	//청구액합계
						ls_data[tt] = string(ll_customer_sum)
					Case '10015'	//결제채널
						ls_data[tt] = ls_pay_method 
					Case '10067'	//청구서 종류  결제채널이 '2'면 2...
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = '2'
						End If
					Case '10068'	//전용계좌번호지정
						If ls_pay_method = '1' Then
							ls_data[tt] = '1'
						ElseIf ls_pay_method = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10069'	//전용계좌인자우선
						If ls_data[tt - 1] = '1' Then
							ls_data[tt] = '1'						
						ElseIf ls_data[tt - 1] = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10016' 	//예금주
						If ls_pay_method = '1' Then
							ls_data[tt] = ls_accowner 
						Else
							ls_data[tt] = ''
						End If
					Case '10017' 	//은행코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[1]
	//					Else
							ls_data[tt] = ''
	//					End If					
					Case '10018'	//은행명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_name
	//					Else
							ls_data[tt] = ''
	//					End If
					Case '10019' //지점코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10020' //지점명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer_nm
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10021'  //예금과목
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_acct_item
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10022'	// 은행계좌번호
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[2]
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10023' 	//고객은행코드
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bank
						Else
							ls_data[tt] = ''
						End If
					Case '10024' 	//고객은행
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bankshop
						Else
							ls_data[tt] = ''
						End If
					Case '10088'	//지점코드
						If ls_pay_method = '2' Then
							ls_data[tt] = '000'
						Else
							ls_data[tt] = ''
						End If
					Case '10089'	//지점명
						If ls_pay_method = '2' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = ''
						End If		
					Case '10093'	//예금과목
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = ''
						End If							
					Case '10025'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acctno
						Else
							ls_data[tt] = ''
						End If	
					Case '10026'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acct_owner
						Else
							ls_data[tt] = ''
						End If	
					Case '10027'	//입금마감일
						ls_data[tt] = string(ld_inputclosedtcur, 'yyyymmdd') 
					Case '10095'	//신규코드
						If ls_pay_method = '1' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = '1'
						End If							
					Case Else
						If MidA(ls_itemkey_data[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data)
				
				For i = 1 To UpperBound(ls_seq_data)
					If j =  integer(ls_seq_data[i]) Then
						If isnull(ls_data[j]) or ls_data[j] = '' Then
							ls_da += ls_item_data_gu
						Else
							ls_da += ls_comma + ls_data[j] + ls_comma + ls_item_data_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data_gu
					Else
						ls_da += ls_data[j] + ls_item_data_gu
					End If
				End IF
				
			Next
					
			ls_trail_pnt = MidA(ls_da, 1, LenA(ls_da) - 1) + ls_record_data_gu
					
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) d")
					FileClose(li_filenum)
					ls_status = 'failiure_d_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D1
      ll_itemkey_data = UpperBound(ls_itemkey_data1)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data1)
				Choose Case ls_itemkey_data1[tt]
					Case '10003'
						ls_data1[tt] = ls_payid								//고객코드
					Case '10095'
						ls_data1[tt] = MidA(ls_trdt, 1, 6)  				//청구년월
					Case '10096'
						ls_data1[tt] = fs_fill_pad('', 6, '1', '0')	//인증키 총갯수
					Case '10097'
						ls_data1[tt] = fs_fill_pad('', 14, '2', '0')	//대표 인증key
					Case '10027'
					   ls_data1[tt] = string(ld_inputclosedtcur, 'yyyymmdd')//입금마감일
					Case '10002'
						ls_data1[tt] = ls_workdt  //작업일  -  구빌링의 girobase생성일인거 같음. ㅎ drawupdt
					Case '10005'
						ls_data1[tt] = fs_fill_pad(ls_customernm, 50, '2', ' ')	//고객명
					Case '10098'
						ls_data1[tt] = ls_useddt_fr+ls_useddt_to //사용기간
					Case '10116'
						ls_data1[tt] = ls_type 
					Case '10115'  //space
						ls_data1[tt] = fs_fill_pad(ls_space, 7, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data1[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data1[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data1)
				
				For i = 1 To UpperBound(ls_seq_data1)
					If j =  integer(ls_seq_data1[i]) Then
						If isnull(ls_data1[j]) or ls_data1[j] = '' Then
							ls_da += ls_item_data1_gu
						Else
							ls_da += ls_comma + ls_data1[j] + ls_comma + ls_item_data1_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
								
				IF ll_gubun <> j  Then
					If ls_data1[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data1_gu
					Else
						ls_da += ls_data1[j] //+ ls_item_data1_gu
					End If
				End IF
				
			Next
					
//			ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data1_gu
			ls_trail_pnt = ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D1")
					FileClose(li_filenum)
					ls_status = 'failiure_d1_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D2
		ll_itemkey_data = UpperBound(ls_itemkey_data2)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data2)
				Choose Case ls_itemkey_data2[tt]
					Case '10007'
						ls_data2[tt] = fs_fill_pad(ls_bil_zipcod, 6, '2', ' ')//우편번호
					Case '10099'
  					   ls_data2[tt] = fs_fill_pad(ls_bil_addr1, 60, '2', ' ') //주소
					Case '10100'
						ls_data2[tt] = fs_fill_pad(ls_bil_addr2, 50, '2', ' ') //주소
               Case '10115'  //space
						ls_data2[tt] = fs_fill_pad(ls_space, 17, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data2[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data2[tt] = ''
						End If						
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data2)
				
				For i = 1 To UpperBound(ls_seq_data2)
					If j =  integer(ls_seq_data2[i]) Then
						If isnull(ls_data2[j]) or ls_data2[j] = '' Then
							ls_da += ls_item_data2_gu
						Else
							ls_da += ls_comma + ls_data2[j] + ls_comma + ls_item_data2_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data2[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data2_gu
					Else
						ls_da += ls_data2[j] //+ ls_item_data2_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data2_gu
			ls_trail_pnt =ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D2")
					FileClose(li_filenum)
					ls_status = 'failiure_d2_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D3
		ll_itemkey_data = UpperBound(ls_itemkey_data3)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data3)
				Choose Case ls_itemkey_data3[tt]
					Case '10066'
						If ll_cur_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_cur_balance)), 9, '1', '0') 	//청구서합계
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_cur_balance), 10, '1', '0') 	//청구서합계
						End If
					Case '10101' 					   
						If ll_pre_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_pre_balance)), 9, '1', '0') 	//미납액
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_pre_balance), 10, '1', '0') 	//미납액
						End If		
					Case '10102'
  					   ls_data3[tt] = fs_fill_pad(string(ll_supplyamt), 10, '1', '0') 	//공급가액
					Case '10103'	
  					   ls_data3[tt] = fs_fill_pad(string(ll_surtax), 10, '1', '0') 		//부가세 
					Case '10104'	
  					   ls_data3[tt] = fs_fill_pad(ls_cregno, 13, '2', ' ') 					//사업자등록번호
					Case '10117'
						ls_data3[tt] = fs_fill_pad(ls_acctno, 20, '2', ' ')               //고객 계좌번호
					Case '10118'
						ls_data3[tt] = fs_fill_pad(ls_banknm, 30, '2', ' ')               //은행명
					Case '10119'
						ls_data3[tt] = fs_fill_pad(ls_acct_owner, 30, '2', ' ')               //예금주
					Case '10105'
						ls_data3[tt] = fs_fill_pad(ls_payid, 10, '1', '0')+fs_fill_pad(ls_trdt, 8, '1', '0')+'0' //고객조회번호
					Case '10115'  //space
						ls_data3[tt] = fs_fill_pad(ls_space, 61, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data3[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data3[tt] = ''
						End If				
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data3)
				
				For i = 1 To UpperBound(ls_seq_data3)
					If j =  integer(ls_seq_data3[i]) Then
						If isnull(ls_data3[j]) or ls_data3[j] = '' Then
							ls_da += ls_item_data3_gu
						Else
							ls_da += ls_comma + ls_data3[j] + ls_comma + ls_item_data3_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data3[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data3_gu
					Else
						ls_da += ls_data3[j] //+ ls_item_data3_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data3_gu
			ls_trail_pnt = ls_da		
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D3")
					FileClose(li_filenum)
					ls_status = 'failiure_d3_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D4
		For i = 1 To 2
			ls_acctno_bef1[i]    = ''
			ls_acct_type_bef1[i] = ''
			ls_paydt1[i]         = ''
			ll_payamt1[i]        = 0
		Next
		i = 1
		DECLARE reqreceipt_cu CURSOR FOR
			SELECT ACCT_NO    //계좌번호
			     , ACCT_TYPE  //은행명
				  , to_char(PAYDT, 'yyyymmdd')  PAYDT     //전월 출금일
				  , PAYAMT   	//전월 출금액
			  FROM REQRECEIPT
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ld_trdt 
				AND ROWNUM <= 2;
			 
			OPEN reqreceipt_cu;
			
			DO WHILE (True)
				
				Fetch reqreceipt_cu
				Into :ls_acctno_bef, :ls_acct_type_bef, :ls_paydt, :ll_payamt;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				ls_acctno_bef1[i]  = ls_acctno_bef
				ls_acct_type_bef1[i] = ls_acctno_bef
				ls_paydt1[i]  = ls_paydt
				ll_payamt1[i] = ll_payamt
				i ++						
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_reqreceipt_cu'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqreceipt_cu;
		
		ll_itemkey_data = UpperBound(ls_itemkey_data4)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data4)
				Choose Case ls_itemkey_data4[tt]
					Case '10120'
						ls_data4[tt] = fs_fill_pad(ls_acctno_bef1[1], 20, '2', ' ')
					Case '10121'
						ls_data4[tt] = fs_fill_pad(ls_acct_type_bef1[1], 30, '2', ' ')
					Case '10122'
						ls_data4[tt] = fs_fill_pad('', 30, '2', ' ')
					Case '10123'
						ls_data4[tt] = fs_fill_pad(ls_paydt1[1], 8, '2', ' ')
					Case '10124'
						ls_data4[tt] = fs_fill_pad(string(ll_payamt1[1]), 10, '1', '0')
					Case '10125'	
						ls_data4[tt] = fs_fill_pad(ls_paydt1[2], 8, '2', ' ')
					Case '10126'							
						ls_data4[tt] = fs_fill_pad(string(ll_payamt1[2]), 10, '1', '0')
					Case '10115'  //space
						ls_data4[tt] = fs_fill_pad(ls_space, 17, '1', ' ')
					Case Else
						If MidA(ls_itemkey_data4[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data4[tt] = ''
						End If				
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data4)
				
				For i = 1 To UpperBound(ls_seq_data4)
					If j =  integer(ls_seq_data4[i]) Then
						If isnull(ls_data4[j]) or ls_data4[j] = '' Then
							ls_da += ls_item_data4_gu
						Else
							ls_da += ls_comma + ls_data4[j] + ls_comma + ls_item_data4_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data4[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data4_gu
					Else
						ls_da += ls_data4[j] //+ ls_item_data3_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data3_gu
			ls_trail_pnt = ls_da		
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D4")
					FileClose(li_filenum)
					ls_status = 'failiure_d4_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//상세항목
		DECLARE reqamtinfo_cu CURSOR FOR
			SELECT PAYID		//고객번호
				  , TRDT			//청구기준일
				  , CHARGEDT	//청구주기
				  , REQNUM		//청구번호
//				  , SUPPLYAMT  //공급가액
//				  , SURTAX 		//부과세
				  , NVL(BTRAMT01, 0), NVL(BTRAMT02, 0), NVL(BTRAMT03, 0), NVL(BTRAMT04, 0) 
				  , NVL(BTRAMT05, 0), NVL(BTRAMT06, 0), NVL(BTRAMT07, 0), NVL(BTRAMT08, 0) 
				  , NVL(BTRAMT09, 0), NVL(BTRAMT10, 0), NVL(BTRAMT11, 0), NVL(BTRAMT12, 0) 
				  , NVL(BTRAMT13, 0), NVL(BTRAMT14, 0), NVL(BTRAMT15, 0), NVL(BTRAMT16, 0) 
				  , NVL(BTRAMT17, 0), NVL(BTRAMT18, 0), NVL(BTRAMT09, 0), NVL(BTRAMT20, 0)	
				  , NVL(BTRAMT21, 0), NVL(BTRAMT22, 0), NVL(BTRAMT23, 0), NVL(BTRAMT24, 0) 
				  , NVL(BTRAMT25, 0), NVL(BTRAMT26, 0), NVL(BTRAMT27, 0), NVL(BTRAMT28, 0) 
				  , NVL(BTRAMT29, 0), NVL(BTRAMT30, 0)				  
				  , NVL(BTRDESC01,''), NVL(BTRDESC02,''), NVL(BTRDESC03,'')
				  , NVL(BTRDESC04,''), NVL(BTRDESC05,''), NVL(BTRDESC06,'')
				  , NVL(BTRDESC07,''), NVL(BTRDESC08,''), NVL(BTRDESC09,'')
				  , NVL(BTRDESC10,''), NVL(BTRDESC11,''), NVL(BTRDESC12,'')
				  , NVL(BTRDESC13,''), NVL(BTRDESC14,''), NVL(BTRDESC15,'')
				  , NVL(BTRDESC16,''), NVL(BTRDESC17,''), NVL(BTRDESC18,'')
				  , NVL(BTRDESC19,''), NVL(BTRDESC20,''), NVL(BTRDESC21,'')
				  , NVL(BTRDESC22,''), NVL(BTRDESC23,''), NVL(BTRDESC24,'')
				  , NVL(BTRDESC25,''), NVL(BTRDESC26,''), NVL(BTRDESC27,'')
				  , NVL(BTRDESC28,''), NVL(BTRDESC29,''), NVL(BTRDESC30,'')
			  FROM REQAMTINFO
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ld_trdt  ;
			 
			OPEN reqamtinfo_cu;
			
			DO WHILE (True)
				
				Fetch reqamtinfo_cu
				Into :ls_payid_amt, :ld_trdt_amt, :ls_chargedt_amt, :ls_reqnum_amt
				   , :ll_btramt[1], :ll_btramt[2], :ll_btramt[3], :ll_btramt[4], :ll_btramt[5]
				   , :ll_btramt[6], :ll_btramt[7], :ll_btramt[8], :ll_btramt[9], :ll_btramt[10]
				   , :ll_btramt[11], :ll_btramt[12], :ll_btramt[13], :ll_btramt[14], :ll_btramt[15]
				   , :ll_btramt[16], :ll_btramt[17], :ll_btramt[18], :ll_btramt[19], :ll_btramt[20]
				   , :ll_btramt[21], :ll_btramt[22], :ll_btramt[23], :ll_btramt[24], :ll_btramt[25]
				   , :ll_btramt[26], :ll_btramt[27], :ll_btramt[28], :ll_btramt[29], :ll_btramt[30]					
					, :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5]
					, :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10] 
					, :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15]
					, :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 
					, :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25]
					, :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30]  ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				For i = 1 To UpperBound(ls_btrdesc)
					If ls_btrdesc[i] = 'null' Or IsNull(ls_btrdesc[i]) Then
						ls_btrdesc[i] = ''
					End If
				Next

				Long pp
		
//				For pp = 1 To UpperBound(ls_itemkey_data_detail)
//					Choose Case ls_itemkey_data_detail[pp]
//						Case '10000'	//위탁회사 코드
//							ls_data_detail[pp] = ls_company
//						Case '10003'	//고객번호
//							ls_data_detail[pp] = fs_fill_pad(ls_payid_amt, 15, '1', '0')
//						Case '10004' 	//청구번호
//							ls_data_detail[pp] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0')
//						Case '10042'	//명세부분 프리 레이아웃지역1-1  
//							ls_data_detail[pp] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
//						Case Else
//							ls_data_detail[pp] = ''
//					End Choose
//				Next
				
				For i = 1 To UpperBound(ls_btrdesc)
					If IsNull(ls_btrdesc[i]) Or ls_btrdesc[i] = '' Then Continue
					
					For pp = 1 To UpperBound(ls_itemkey_data_detail)
						Choose Case ls_itemkey_data_detail[pp]
							Case '10106'
								ls_data_detail[pp] = fs_fill_pad(ls_btrdesc[i], 30, '2', ' ')			// 항목
							Case '10107'
								If ll_btramt[i] < 0 Then
									ls_data_detail[pp] = '-'
								   ls_data_detail[pp] += fs_fill_pad(string(abs(ll_btramt[i])), 9, '1', '0')	// 금액
								Else
									ls_data_detail[pp] = fs_fill_pad(string(ll_btramt[i]), 10, '1', '0')
								End If
							Case '10115'  //space
						   	ls_data_detail[pp] = fs_fill_pad(ls_space, 93, '1', ' ')
							Case Else
								If MidA(ls_itemkey_data_detail[pp], 1, 1) <> '2' Then
									ls_data_detail[pp] = ''
								End If								
								
						End Choose
					Next
					
					//청구대상 고객들의 총 청구금액 sum, count
					ll_amt_total = ll_amt_total + ll_btramt[i]
					//ll_count ++
					ll_gubun = 0
					For j = 1 To UpperBound(ls_data_detail)
					
						For t = 1 To UpperBound(ls_seq_data_detail)
							If j =  integer(ls_seq_data_detail[t]) Then
								If isnull(ls_data_detail[j]) or ls_data_detail[j] = '' Then
									ls_da_t += ls_item_data_detail_gu
								Else
									ls_da_t += ls_comma + ls_data_detail[j] + ls_comma + ls_item_data_detail_gu
								End If
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_data_detail[j] = '' Then
								ls_da_t += ls_item_data_detail_gu
							Else
								ls_da_t += ls_data_detail[j] //+ ls_item_data_detail_gu
							End If
						End IF
					Next

					//ls_trail_pnt = mid(ls_da_t, 1, Len(ls_da_t) - 1) + ls_record_data_detail_gu
				   ls_trail_pnt = ls_da_t
					//For j = 1 To UpperBound(ls_data_detail)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data-detail Record) detail")
							FileClose(li_filenum)
							ls_status = 'failiure_amtinfo_write'
							Goto NextStep
							//Return 
						End If
					//Next
					ls_trail_pnt = ''
					ls_da_t = ''
				Next
				
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_amtinfo'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqamtinfo_cu;		
      
		ll_no = 0
		//cdr 상세
		DECLARE cdr_detail CURSOR FOR
			SELECT VALIDKEY
			     , TO_CHAR(STIME, 'yyyymmddhh24miss') STIME 
				  , BILTIME
				  , COUNTRYCOD
				  , RTELNUM
				  , BILAMT
			  FROM POST_BILCDR
  		    WHERE PAYID = :ls_payid				
 		 ORDER BY STIME; 
			 
			OPEN cdr_detail;
			
			DO WHILE (True)
				
				Fetch cdr_detail
				Into :ls_validkey, :ls_stime, :ll_biltime, :ls_countrycod, :ls_rtelnum, :ll_bilamt ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				SELECT COUNTRYNM
				  INTO :ls_countrynm 
				  FROM COUNTRY 
				 WHERE COUNTRYCOD = :ls_countrycod;
				 
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
//					ll_code = 0
//					Exit
               ls_countrynm = 'NoDefine'
				End If			
				
				If ll_biltime = 0 Then
					ls_biltime = '000000'
				End If
				ll_hh      = Truncate(ll_biltime/3600, 0)
				ll_mi      = Truncate((ll_biltime - (ll_hh * 3600))/60, 0)
				ll_ss      = ll_biltime - ((ll_hh * 3600) + (ll_mi * 60))
				ls_biltime = fs_fill_pad(string(ll_hh), 2, '1', '0')+fs_fill_pad(string(ll_mi), 2, '1', '0')+fs_fill_pad(string(ll_ss), 2, '1', '0')
    				
				ll_no = ll_no + 1
				
				ll_itemkey_data = UpperBound(ls_itemkey_cdr)
				If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
				
				If ll_itemkey_data > 0 Then
					For tt = 1 To UpperBound(ls_itemkey_cdr)
						Choose Case ls_itemkey_cdr[tt]
							Case '10108'
								ls_cdr[tt] = fs_fill_pad(string(ll_no), 10, '1', '0') //seqno 
							Case '10109'
								ls_cdr[tt] = fs_fill_pad(ls_validkey, 14, '2', ' ')   //인증키
							Case '10110'
								ls_cdr[tt] = ls_stime                                 //통화시작시간
							Case '10112'
								ls_cdr[tt] = fs_fill_pad(ls_biltime, 6, '1', '0')  //사용시간(시분초)
							Case '10111'
								ls_cdr[tt] = fs_fill_pad(ls_countrynm, 30, '2', ' ')  //국가명
							Case '10113'
								ls_cdr[tt] = fs_fill_pad(ls_rtelnum, 30, '2', ' ')  //착신번호
							Case '10114'
								ls_cdr[tt] = fs_fill_pad(string(ll_bilamt), 10, '1', '0')  //통화금액	
							Case '10115'  //space
						   	ls_cdr[tt] = fs_fill_pad(ls_space, 19, '1', ' ')
							Case Else
								If MidA(ls_itemkey_cdr[tt], 1, 1) <> '2' Then
									ls_cdr[tt] = ''
								End If								
						End Choose				
					Next
			
					//안내문  59~ 72  = ''
					//ll_count ++
					ll_gubun = 0
			
					For j = 1 To UpperBound(ls_cdr)
						
						For i = 1 To UpperBound(ls_seq_cdr)
							If j =  integer(ls_seq_cdr[i]) Then
								If isnull(ls_cdr[j]) or ls_cdr[j] = '' Then
									ls_da += ls_item_cdr_gu
								Else
									ls_da += ls_comma + ls_cdr[j] + ls_comma + ls_item_cdr_gu
								End If
								
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_cdr[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
								ls_da += ls_item_cdr_gu
							Else
								ls_da += ls_cdr[j]// + ls_item_cdr_gu
							End If
						End IF
						
					Next
							
					//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_cdr_gu
					ls_trail_pnt =ls_da
					//For i = 1 To UpperBound(ls_data)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) cdr")
							FileClose(li_filenum)
							ls_status = 'failiure_cdr_write'
							Goto NextStep
							//Return 
						End If
					//Next
				End If		
				ls_trail_pnt = ''
				ls_da        = ''
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_cdr'
				Goto NextStep				
				//Return
			End If
			
		CLOSE cdr_detail;			
	LOOP   
	
	If ll_code = 0 Then
		FileClose(li_FileNum)
		rollback;
		ls_status = 'failiure_reqinfo'
		Goto NextStep
		//Return
	End If
	
CLOSE reqinfo_cu;

If ll_count = 0 Then
	FileClose(li_FileNum)
	rollback;
	ls_status = 'failiure'
	Goto NextStep
End IF

long gg
//trailer
ll_itemkey_data = UpperBound(ls_itemkey_trailer)
If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0

If ll_itemkey_data > 0 Then
	For gg = 1 To UpperBound(ls_itemkey_trailer)
		Choose Case ls_itemkey_trailer[gg]
			Case '10000'	//위탁회사 코드
				ls_trailer[gg] = ls_company
			Case '10091' 	//합계건수
				ls_trailer[gg] = string(ll_count)
			Case '10092'	//합계금액
				ls_trailer[gg] = string(ll_amt_total)
			Case Else
				If MidA(ls_itemkey_trailer[gg], 1, 1) <> '2' Then
					ls_trailer[gg] = ''
				End If				
				
		End Choose
	Next
	
	//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'T')
	//
	//If ls_property <> "" Then
	//	fi_cut_string(ls_property, ";" , ls_result[])
	//End if
	
	ll_gubun = 0
	For j = 1 To UpperBound(ls_trailer)
		For i = 1 To UpperBound(ls_seq_trailer)
			If j =  integer(ls_seq_trailer[i]) Then
				If ls_trailer[j] = '' Then
					ls_trail += ls_item_trailer_gu
				Else
					ls_trail += ls_comma + ls_trailer[j] + ls_comma + ls_item_trailer_gu
				End If
				
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_trailer[j] = '' Then
				ls_trail += ls_item_trailer_gu
			Else
				ls_trail += ls_trailer[j] //+ ls_item_trailer_gu
			End If
		End IF
	Next
	
	//ls_trail_pnt = mid(ls_trail, 1, Len(ls_trail) - 1)
	ls_trail_pnt = ls_trail
	//For j = 1 To UpperBound(ls_trailer)
		li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (trailer Record)")
			FileClose(li_filenum)
			ls_status = 'failiure'
			Goto NextStep
			//Return 
		End If
	//Next
End If
FileClose(li_FileNum)

ls_status = 'Complete'

//ls_filename = Mid(ls_filename, 4)
////li_tab      = Pos(ls_filename, "\")
//ls_filename = Mid(ls_filename, Pos(ls_filename, "\") + 1)
//
NextStep :

//log 생성
INSERT INTO INVF_WORKLOG
			 ( SEQNO
			 , FILEW_DIR
			 , FILEW_NAME
			 , FILEW_STATUS
			 , FILEW_COUNT
			 , FILEW_INVAMT
          , CND_INVF_TYPE
			 , CND_INV_TYPE
			 , CND_WORKDT
			 , CND_INPUTCLOSEDT
			 , CND_TRDT
			 , CND_CHARGEDT
			 , CND_PAY_METHOD
			 , CND_BANKPAY
			 , CND_CREDITPAY
			 , CND_ETCPAY
			 , CRT_USER
			 , CRTDT
			 , PGM_ID )
     VALUES
		    ( seq_invf_worklog.nextval
			 , :ls_pathname
			 , :ls_filename
			 , :ls_status
			 , :ll_count
          , :ll_amt_total
			 , :ls_cnd_invf_type
			 , :ls_cnd_inv_type
			 , to_date(:ls_workdt, 'yyyymmdd')
			 , to_date(:ls_inputclosedt, 'yyyymmdd')
			 , :ls_cnd_chargedt
			 , to_date(:ls_trdt, 'yyyymmdd')
			 , :ls_cnd_pay_method
			 , :ls_cnd_bankpay
			 , :ls_cnd_creditpay
			 , :ls_cnd_etcpay
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id           );
			 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(INVF_WORKLOG)")
	RollBack;
	Return		
End If		
commit;
ii_rc = 0

Return
end subroutine

public subroutine uf_prc_db_04 ();//세이버 giro
String  ls_temp, ls_ref_desc, &
		  ls_payid, ls_chargedt, ls_reqnum, ls_customernm, ls_lastname, ls_corpnm_2, &
		  ls_bil_zipcod, ls_bil_addr1, ls_bil_addr2, ls_acctno, ls_acct_owner, &
		  ls_itemtype, ls_itemkey_property, ls_item_value, ls_pad_type, ls_pad_value, &
		  ls_company, ls_companynm, ls_check, ls_record, ls_pay_method, ls_corpnm, ls_py, &
		  ls_bank, ls_bankshop, ls_accowner, ls_bank_dealer, ls_acct_item, ls_bank_name, &
		  ls_bank_dealer_nm, ls_btrdesc[], ls_payid_amt, ls_chargedt_amt, ls_reqnum_amt, &
		  ls_trail, ls_trail_pnt, ls_property, ls_comma = '"', ls_shim  = ',', ls_head, &
		  ls_da, ls_resultt[], ls_resulttt[],  ls_resultttt[], ls_property_d, ls_da_t, &
		  ls_status = ''
Long	  ll_code = 1, ll_seqno, ll_maxlength, i, li_write_bytes, ll_customer_sum, &
        ll_btramt[], j, ll_count = 0, ll_amt_total = 0, ll_gubun = 0, t, p, cnt = 0
Date    ld_workdt, ld_inputclosedt, ld_cnd_trdt, ld_inputclosedtcur, ld_trdt, ld_trdt_amt

String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay, ls_user_id, ls_pgm_id, &
		  ls_header[], ls_data[], ls_data_detail[], ls_trailer[], ls_etc, &
		  ls_itemkey, ls_itemkey_header[], ls_itemkey_data[], ls_itemkey_data_detail[], &
		  ls_itemkey_Trailer[], ls_seqno_header, ls_seqno_data, ls_seqno_data_detail, &
		  ls_seqno_trailer, ls_seq_header[], ls_seq_data[], ls_seq_data_detail[], &
		  ls_seq_trailer[], ls_item_delimit, ls_record_delimit, ls_item_header_gu, &
		  ls_record_header_gu, ls_item_data_gu, ls_record_data_gu, ls_item_data_detail_gu, &
		  ls_record_data_detail_gu, ls_item_trailer_gu, ls_record_trailer_gu, ls_method[]
Long    ll_itemkey
String  ls_itemkey_data1[], ls_itemkey_data2[], ls_itemkey_data3[], ls_data1[], ls_data2[], &
        ls_data3[], ls_seqno_data1, ls_item_data1_gu, ls_record_data1_gu, ls_seqno_data2, &
		  ls_item_data2_gu, ls_record_data2_gu,ls_seqno_data3, ls_item_data3_gu, ls_record_data3_gu, &
		  ls_cdr[], ls_seqno_cdr, ls_item_cdr_gu, ls_record_cdr_gu, ls_seq_data1[], ls_seq_data2[], &
		  ls_seq_data3[], ls_seq_cdr[], ls_pathname, ls_itemkey_cdr[], ls_trdt, ls_inputclosedt, &
		  ls_filename, ls_currentdir, ls_gubun, ls_cregno, ls_validkey, ls_countrynm, ls_countrycod, &
		  ls_stime, ls_rtelnum, ls_space = '', ls_ctype_10, ls_ctype_20, ls_type, ls_ctype2, &
		  ls_useddt_fr, ls_useddt_to, ls_acctno_bef1[], ls_acct_type_bef1[], ls_acctno_bef, ls_acct_type_bef, &
		  ls_paydt1[], ls_paydt, ls_itemkey_data4[], ls_data4[], ls_seqno_data4, ls_item_data4_gu, &
		  ls_record_data4_gu, ls_seq_data4[], ls_result[], ls_workdt, ls_banknm, ls_biltime, &
		  ls_card_type, ls_card_no, ls_card_holder, ls_cardnm, ls_pay_method_bef, ls_acct_owner_bef1[], &
		  ls_acct_owner_bef, ls_groupnm, ls_limit_amt[], ls_invdetail_yn//, ls_s_bilamt
Long    ll_header, ll_itemkey_data, ll_cur_balance, ll_pre_balance, ll_supplyamt, ll_surtax, ll_no, &
        ll_biltime, ll_payamt1[], ll_payamt, ll_hh, ll_mi, ll_ss, ll_limit, ll_bilamt	
Dec     ld_biltime	  
//iu_db.is_title = Title//
ls_cnd_invf_type  = is_data[1]   // 파일타입
ls_trdt           = is_data[2]  // 청구주기
ls_pathname       = is_data[3]  // 경로
ls_filename       = is_data[4]  // 파일명
ls_ctype2         = is_data[5]  // 개인 10 법인 20
ls_gubun          = is_data[6]  // 정상(0, 2), 연체(1, 3)
ls_cnd_inv_type   = is_data[7]  // 청구유형구분(개인고객, 법인고객,... 등등)
ls_workdt         = is_data[8]  // 작업일자
ls_cnd_chargedt   = is_data[9]
ls_inputclosedt   = is_data[10] 

//청구발송여부에 따라 파일생성여부 체크?,  컨트리코드로 명 찾았을때 nodata이면? 현재는 'NoDefine'  그대로 진행......
//은행명 못찾으면 현재 NoDefine 그대로 진행
//reqinfo에만 있고 reqamtinfo는 없는경우는 현재는 안찍음
// CDR 찍을때  전월소유주 정보 없음
//작업일  -  구빌링의 girobase생성일인거 같음. ㅎ drawupdt <- b
/*
ls_cnd_pay_method = is_data[2]		//지로
ls_cnd_inv_type   = is_data[3]
ls_cnd_chargedt   = is_data[4]	  	//주기			
ls_cnd_bankpay    = is_data[5]		//자동이체
ls_cnd_creditpay  = is_data[6]		//카드
ls_cnd_etcpay     = is_data[7]		//기타
ls_user_id        = is_data[8]
ls_pgm_id         = is_data[9]
ls_pathname       = is_data[10]
ls_trdt           = is_data[11]

ld_workdt	      = id_data[1]
ld_inputclosedt   = id_data[2]
ld_cnd_trdt       = id_data[3] 		// 기준일
*/

ii_rc = -1

//위탁회사 ls_result[1] = 은행코드 , ls_result[2] = 은행계좌번호
ls_temp = fs_get_control("B7","A110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

//개인
ls_ctype_10    = fs_get_control("B0", "P111", ls_ref_desc)

//법인
ls_temp	= fs_get_control("B0", "P110", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if
ls_ctype_20    = ls_result[1]

// 예금주
ls_accowner       = fs_get_control("B7", "A120", ls_ref_desc)
//지점코드
ls_bank_dealer    = fs_get_control("B7", "A140", ls_ref_desc)
//예금과목
ls_acct_item      = fs_get_control("B7", "A160", ls_ref_desc)
//은행명
ls_bank_name      = fs_get_control("B7", "A130", ls_ref_desc)
//지점명
ls_bank_dealer_nm = fs_get_control("B7", "A150", ls_ref_desc)
//위탁회사 코드
ls_company        = fs_get_control("B7", "A100", ls_ref_desc)
//회사명
ls_companynm      = fs_get_control("B7", "A600", ls_ref_desc)

//ls_currentdir     = fs_get_control("B7", "D100", ls_ref_desc)

ls_temp = fs_get_control("B0","P133", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_method[])
End If

// 지로,자동이체청구파일유형
ls_temp =  fs_get_control("B7", "C600", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";", ls_result[])
End If

// 지로,자동이체, 신용카드 최소 청구액  이 금액보다 작으면 청구서 발송 안함..
ls_temp =  fs_get_control("B5", "B103", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";", ls_limit_amt[])
End If

If ls_cnd_pay_method = 'Y' Then
	ls_cnd_pay_method = ls_method[1]
Else 
	ls_cnd_pay_method = ''
End If	

If ls_cnd_bankpay = 'Y' Then
	ls_cnd_bankpay = ls_method[2]
Else 
	ls_cnd_bankpay = ''
End If

If ls_cnd_creditpay = 'Y' Then
	ls_cnd_creditpay = ls_method[3]
Else 
	ls_cnd_creditpay = ''
End If	

If ls_cnd_etcpay = 'Y' Then
	For p = 4 To UpperBound(ls_method)
		ls_etc += ls_method[p] + ','
		cnt ++
	Next
	ls_etc = MidA(ls_etc, 1, LenA(ls_etc) - 1)
Else 
	ls_cnd_etcpay = ''
	ls_etc = ''
End If

//청구파일유형	별 지로, 자동이체 구분
If ls_cnd_invf_type = ls_result[1] OR ls_cnd_invf_type = ls_result[3] Or ls_cnd_invf_type = ls_result[5] Then //지로
	ls_cnd_pay_method =  ls_method[1]
Else //자동이체 나래는 자동이체에 카드까지 포함...
	ls_cnd_bankpay   = ls_method[2]
	ls_cnd_creditpay = ls_method[3]
End If

//header record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'H')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_header[])
End if

//Data record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data[])
End if
//Data record1 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D1')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data1[])
End if

//Data record2 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D2')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data2[])
End if
//Data record3 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D3')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data3[])
End if

//Data record4 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'D4')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data4[])
End if

//Data Detail record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'R')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_data_detail[])
End if

//Trailer record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'T')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_Trailer[])
End if

//CDR record 가져오기....
ls_itemkey = fs_itemkey(ls_cnd_invf_type, 'C')

If ls_itemkey <> "" Then
	fi_cut_string(ls_itemkey, ";" , ls_itemkey_cdr[])
End if

//value값 구하기
DECLARE invf_recorddet_cu CURSOR FOR
	SELECT A.RECORD
	     , A.SEQNO
		  , A.ITEMKEY
	     , A.ITEMKEY_PROPERTY
	     , A.ITEMTYPE		  
		  , A.ITEM_VALUE
		  , A.MAXLENGTH
		  , A.PAD_TYPE
		  , A.PAD_VALUE
		  , B.ITEM_DELIMIT
		  , B.RECORD_DELIMIT
	  FROM INVF_RECORDDET A
	     , INVF_RECORDMST B
	 WHERE A.INVF_TYPE = B.INVF_TYPE
	   AND A.RECORD    = B.RECORD
	   AND A.INVF_TYPE = :ls_cnd_invf_type
 ORDER BY A.INVF_TYPE, A.RECORD, A.SEQNO            ;
//		AND RECORD    = 'H'                     ;
		
	OPEN invf_recorddet_cu;
	
	DO WHILE (True)
	
		Fetch invf_recorddet_cu
		Into :ls_record, :ll_seqno, :ll_itemkey, :ls_itemkey_property, :ls_itemtype, :ls_item_value, :ll_maxlength
		   , :ls_pad_type, :ls_pad_value, :ls_item_delimit, :ls_record_delimit;

		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		If isnull(Trim(ls_item_value)) Then ls_item_value = ''
		
		ls_check = ''
		//header 부분
		If ls_record = 'H' Then
			If ls_itemtype = 'V' Then
				ls_header[ll_seqno] = ls_item_value
			Else
				If ll_itemkey = 10000 Then  //위탁회사 코드
					ls_header[ll_seqno] = ls_company //fs_fill_pad(ls_company, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_company
					
				ElseIf ll_itemkey = 10001 Then //위탁회사명
					ls_header[ll_seqno] = ls_companynm //fs_fill_pad(ls_companynm, ll_maxlength, ls_pad_type, ls_pad_value)
					ls_check = ls_companynm
					
				ElseIf ll_itemkey = 10002 Then // 작업일자
					ls_header[ll_seqno] = string(ld_workdt, 'yyyymmdd')
				End If
				
				If LenA(ls_check) > ll_maxlength Then
					f_msg_usr_err(2100, is_Title, "header의" + string(ll_seqno)+ "의 값이 설정된 max값보다 큼니다.")
					ll_code = 0
					Exit
				End If
			End IF
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_header += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_header_gu   = ls_item_delimit
			ls_record_header_gu = ls_record_delimit
			
		//Data 부분	
		ElseIf ls_record = 'D' Then
			If ls_itemtype = 'V' Then
				ls_data[ll_seqno] = ls_item_value
			Else
				ls_data[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_gu   = ls_item_delimit
			ls_record_data_gu = ls_record_delimit
		//Data1 부분		
		ElseIf ls_record = 'D1' Then
			If ls_itemtype = 'V' Then
				ls_data1[ll_seqno] = ls_item_value
			Else
				ls_data1[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data1 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data1_gu   = ls_item_delimit
			ls_record_data1_gu = ls_record_delimit
			
		//Data2 부분		
		ElseIf ls_record = 'D2' Then
			If ls_itemtype = 'V' Then
				ls_data2[ll_seqno] = ls_item_value
			Else
				ls_data2[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data2 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data2_gu   = ls_item_delimit
			ls_record_data2_gu = ls_record_delimit	

		//Data3 부분		
		ElseIf ls_record = 'D3' Then
			If ls_itemtype = 'V' Then
				ls_data3[ll_seqno] = ls_item_value
			Else
				ls_data3[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data3 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data3_gu   = ls_item_delimit
			ls_record_data3_gu = ls_record_delimit	
			
		//Data4 부분		
		ElseIf ls_record = 'D4' Then
			If ls_itemtype = 'V' Then
				ls_data4[ll_seqno] = ls_item_value
			Else
				ls_data4[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data4 += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data4_gu   = ls_item_delimit
			ls_record_data4_gu = ls_record_delimit	
			
		//Data Detail 부분
		ElseIf ls_record = 'R' Then
			If ls_itemtype = 'V' Then
				ls_data_detail[ll_seqno] = ls_item_value
			Else
				ls_data_detail[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_data_detail += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_data_detail_gu   = ls_item_delimit
			ls_record_data_detail_gu = ls_record_delimit
			
		//trailer 부분
		ElseIf ls_record = 'T' Then
			If ls_itemtype = 'V' Then
				ls_trailer[ll_seqno] = ls_item_value
			Else
				ls_trailer[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_trailer += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_trailer_gu   = ls_item_delimit
			ls_record_trailer_gu = ls_record_delimit
		
		//cdr 부분
		ElseIf ls_record = 'C' Then
			If ls_itemtype = 'V' Then
				ls_cdr[ll_seqno] = ls_item_value
			Else
				ls_cdr[ll_seqno] = ''
			End If
			// char type인경우 "" 붙여주기 위해
			If ls_itemkey_property = 'C' Then
				ls_seqno_cdr += string(ll_seqno) + ';'
			End If
			//구분자...
			ls_item_cdr_gu   = ls_item_delimit
			ls_record_cdr_gu = ls_record_delimit			
		End If
		
	LOOP

	If ll_code = 0 Then
		CLOSE invf_recorddet_cu;
		rollback;
		ls_status = 'failiure1'
		Goto NextStep
//		Return
	End If
	
CLOSE invf_recorddet_cu;	

//item_key property 'c' 이면 " " 붙이기. 및 콤마 붙이기

//header
ls_seqno_header = MidA(ls_seqno_header, 1, LenA(ls_seqno_header) - 1)
If ls_seqno_header <> "" Then
	fi_cut_string(ls_seqno_header, ";" , ls_seq_header[])
End If

//Data
ls_seqno_data = MidA(ls_seqno_data, 1, LenA(ls_seqno_data) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data[])
End If
//Data1
ls_seqno_data = MidA(ls_seqno_data1, 1, LenA(ls_seqno_data1) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data1[])
End If
//Data2
ls_seqno_data = MidA(ls_seqno_data2, 1, LenA(ls_seqno_data2) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data2[])
End If
//Data3
ls_seqno_data = MidA(ls_seqno_data3, 1, LenA(ls_seqno_data3) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data3[])
End If
//Data4
ls_seqno_data = MidA(ls_seqno_data4, 1, LenA(ls_seqno_data4) - 1)
If ls_seqno_data <> "" Then
	fi_cut_string(ls_seqno_data, ";" , ls_seq_data4[])
End If
//Data Detail
ls_seqno_data_detail = MidA(ls_seqno_data_detail, 1, LenA(ls_seqno_data_detail) - 1)
If ls_seqno_data_detail <> "" Then
	fi_cut_string(ls_seqno_data_detail, ";" , ls_seq_data_detail[])
End If

//trailer
ls_seqno_trailer = MidA(ls_seqno_trailer, 1, LenA(ls_seqno_trailer) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_trailer, ";" , ls_seq_trailer[])
End If

//cdr
ls_seqno_cdr = MidA(ls_seqno_cdr, 1, LenA(ls_seqno_cdr) - 1)
If ls_seqno_trailer <> "" Then
	fi_cut_string(ls_seqno_cdr, ";" , ls_seq_cdr[])
End If

//파일명 생성을 위해...., 청구주기별 사용기간 
select to_char(useddt_fr, 'yyyymmdd')
	  , to_char(useddt_to, 'yyyymmdd')
  into :ls_useddt_fr
	  , :ls_useddt_to
  from reqconf
 where CHARGEDT = :ls_cnd_chargedt;
 
 ls_filename += "." + MidA(ls_inputclosedt, 3, 6)
 
//File open
Integer li_FileNum

li_filenum = FileOpen(ls_pathname+"\"+ls_filename, LineMode!, Write!, LockReadWrite!, Replace!)

If IsNull(li_filenum) Then li_filenum = -1

If li_filenum < 0 Then
	f_msg_usr_err(9000, is_Title, "File Open Failed!")
	FileClose(li_filenum)			
	ls_status = 'failiure_file_open'
	Goto NextStep
	//Return
End If

//header 찍기
ll_gubun  = 0
ll_header = 0
ll_header = UpperBound(ls_header)

If Isnull(ll_header) Then ll_header = 0

If ll_header > 0 Then
	For j = 1 To UpperBound(ls_header)
		For i = 1 To UpperBound(ls_seq_header)
			If j =  integer(ls_seq_header[i]) Then
				If isnull(ls_header[j]) or ls_header[j] = '' Then
					ls_head += ls_item_header_gu
				Else
					ls_head += ls_comma + ls_header[j] + ls_comma + ls_item_header_gu
				End If
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_header[j] = '' Then
				ls_head += ls_item_header_gu
			Else
				ls_head += ls_header[j] + ls_item_header_gu
			End If
		End IF
	Next
	
	ls_trail_pnt = MidA(ls_head, 1, LenA(ls_head) - 1)// + ls_record_header_gu
	// 여기까지..
	
	//For i = 1 To UpperBound(ls_header)
	li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
	
	If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (Header Record)")
			FileClose(li_filenum)
			ls_status = 'failiure_heard_write'
			Goto NextStep
			//Return 
	End If
	//Next
End If
ls_trail_pnt = ''

////data 
//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'D')
//
//If ls_property <> "" Then
//	fi_cut_string(ls_property, ";" , ls_resulttt[])
//End if
//
////data- detail
//ls_property_d = fs_itemkey_property(ls_cnd_invf_type, 'R')
//
//If ls_property_d <> "" Then
//	fi_cut_string(ls_property_d, ";" , ls_resultttt[])
//End if

DECLARE reqinfo_cu CURSOR FOR
	SELECT PAYID				//고객번호
	     , TRDT					//청구기준일
		  , CHARGEDT			//청구주기
		  , REQNUM				//청구번호
		  , CUSTOMERNM			//고객명
		  , LASTNAME			//고객명()
		  , TRANSLATE(BIL_ZIPCOD, 'T-', 'T')  BIL_ZIPCOD			//우편번호
		  , BIL_ADDR1			//주소
		  , BIL_ADDR2 			//주소
		  , CORPNM				//법인명
		  , CORPNM_2   		//법인명		  
		  , BANK 	 			//은행코드
		  , BANKSHOP			//은행
		  , TRANSLATE(ACCTNO, 'T-', 'T')  ACCTNO
		  , ACCT_OWNER
		  , INPUTCLOSEDTCUR	//입금마감일
		  , PAY_METHOD     	                       //결제채널 '1' 지로, '2' 자동이체
		  , DECODE(CTYPE2, :ls_ctype_20, CREGNO, '**********')   CREGNO      //사업자 등록번호개인이면  **********
		  , CARD_TYPE                               //카드사코드
		  , TRANSLATE(CARD_NO, 'T-', 'T')  CARD_NO  //카드사
		  , CARD_HOLDER                             //카드소유인
		  , NVL(INVDETAIL_YN, 'Y') INVDETAIL_YN    // 청구서 CDR 출력여부
	  FROM REQINFO
	 WHERE TRDT        = to_date(:ls_trdt, 'yyyy-mm-dd')
	   AND CHARGEDT    = :ls_cnd_chargedt
	   AND PAY_METHOD IN (:ls_cnd_pay_method, :ls_cnd_bankpay, :ls_cnd_creditpay, :ls_etc)
//		AND INV_TYPE    = NVL(:ls_cnd_inv_type, INV_TYPE)
		AND INV_YN      = 'Y'    
		AND CTYPE2      = :ls_ctype2
 ORDER BY PAYID ;
	 
	OPEN reqinfo_cu;
	
	DO WHILE (True)
		
		Fetch reqinfo_cu
		Into :ls_payid   , :ld_trdt, :ls_chargedt, :ls_reqnum, :ls_customernm
	      , :ls_lastname, :ls_bil_zipcod, :ls_bil_addr1, :ls_bil_addr2, :ls_corpnm, :ls_corpnm_2
			, :ls_bank    , :ls_bankshop, :ls_acctno, :ls_acct_owner, :ld_inputclosedtcur
			, :ls_pay_method, :ls_cregno, :ls_card_type, :ls_card_no, :ls_card_holder   , :ls_invdetail_yn        ;
		
		If SQLCA.SQLCode < 0 Then
			messagebox('', sqlca.sqlerrtext)
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//고객별 청구금액
		SELECT PAYID 
		     , CUR_BALANCE
			  , PRE_BALANCE
			  , SUPPLYAMT
			  , SURTAX
//		     , SUM( NVL(BTRAMT01, 0) + NVL(BTRAMT02, 0) + NVL(BTRAMT03, 0) + NVL(BTRAMT04, 0) + NVL(BTRAMT05, 0) + 
//		            NVL(BTRAMT06, 0) + NVL(BTRAMT07, 0) + NVL(BTRAMT08, 0) + NVL(BTRAMT09, 0) + NVL(BTRAMT10, 0) +
//					   NVL(BTRAMT11, 0) + NVL(BTRAMT12, 0) + NVL(BTRAMT13, 0) + NVL(BTRAMT14, 0) + NVL(BTRAMT15, 0) +
//					   NVL(BTRAMT16, 0) + NVL(BTRAMT17, 0) + NVL(BTRAMT18, 0) + NVL(BTRAMT19, 0) + NVL(BTRAMT20, 0) +
//						NVL(BTRAMT21, 0) + NVL(BTRAMT22, 0) + NVL(BTRAMT23, 0) + NVL(BTRAMT24, 0) + NVL(BTRAMT25, 0) +
//						NVL(BTRAMT26, 0) + NVL(BTRAMT27, 0) + NVL(BTRAMT28, 0) + NVL(BTRAMT29, 0) + NVL(BTRAMT30, 0) )   
		 INTO :ls_py
		    , :ll_cur_balance
			 , :ll_pre_balance
			 , :ll_supplyamt
			 , :ll_surtax 
//		    , :ll_customer_sum
		 FROM REQAMTINFO
		WHERE PAYID    = :ls_payid
		  AND TRDT     = :ld_trdt 
		  AND CHARGEDT = :ls_chargedt;
//	GROUP BY PAYID;
		  
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		//REQAMTINFO NODATA 이면 청구파일 생성 안함..
		ElseIf SQLCA.SQLCode = 100 Then  
			CONTINUE
   	End If  
		
//		If ll_customer_sum = 0 Then Continue

      //지로 최소청구금액
		If ls_pay_method = ls_method[1] Then
			ll_limit = long(ls_limit_amt[1])
		//자동이체 최소청구금액	
		ElseIf ls_pay_method = ls_method[2] Then
			ll_limit = long(ls_limit_amt[2])
		//신용카드 최소청구금액
		ElseIf ls_pay_method = ls_method[3] Then
			ll_limit = long(ls_limit_amt[3])
		Else
			ll_limit = 0
		End If
		
		//당월 청구금액 + 전월청구금액이 최소 청구금액보다 작으면 청구발송안함...
		If ll_cur_balance + ll_pre_balance  < ll_limit Then
			CONTINUE
   	End If  

      //개인구분
		If ls_ctype2 = ls_ctype_10 Then            
		   //정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance >= ll_limit Then  
					continue
				Else		
					ls_type = '00N'
					ll_count ++
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance < ll_limit Then //정상이므로 continue
					continue
				Else
					ls_type = '12N'
					ll_count ++
				End If
			End If
		//법인
		Else
			//정상구분
			If ls_gubun = '0' Or ls_gubun = '2' Then 
				//  <> 0 continue
				If ll_pre_balance >= ll_limit Then  
					continue
				Else		
					ls_type = '20N'
					ll_count ++
				End If
			//연체	
			Else  
				//0 이면 continue
				If ll_pre_balance < ll_limit Then //정상이므로 continue
					continue
				Else
					ls_type = '32N'
					ll_count ++
				End If
			End If			
		End If
		
		If isnull(ls_card_no) Then ls_card_no = ''
		If isnull(ls_acctno)  Then ls_acctno = ''
		
		If ls_card_no <> '' Then
			ls_card_no = LeftA(ls_card_no, 6) + FillA("*", LenA(ls_card_no) - 6)
		End If
		
		If ls_acctno <> '' Then
			ls_acctno  = LeftA(ls_acctno , 6) + FillA("*", LenA(ls_acctno ) - 6)
		End If
			
		//은행명 가져오기..
		select codenm 
		  into :ls_banknm
		  from syscod2t 
		 where grcode = 'B400' 
			and code   = :ls_bank;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			ls_banknm = 'NoDefine'
//			CONTINUE
   	End If 			
		
	   //카드사명 가져오기..
		select codenm 
		  into :ls_cardnm
		  from syscod2t 
		 where grcode = 'B450' 
			and code   = :ls_card_type;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			ls_cardnm = 'NoDefine'
//			CONTINUE
   	End If 			
		
		Long tt
		ll_itemkey_data = UpperBound(ls_itemkey_data)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data)
				Choose Case ls_itemkey_data[tt]
					Case '10000'
						ls_data[tt] = ls_company
					Case '10003'
						ls_data[tt] = fs_fill_pad(ls_payid , 15, '1', '0')//고객코드
					Case '10004'
						ls_data[tt] = fs_fill_pad(ls_reqnum, 10, '1', '0')//청구서 번호
					Case '10005'
						ls_data[tt] = ls_customernm
					Case '10006'  //반각
						ls_data[tt] = ls_lastname
					Case '10007'
						ls_data[tt] = ls_bil_zipcod
					Case '10008'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr1
						Else
							ls_data[tt] = ''					
						End If
					Case '10009'
						If LenA(ls_bil_addr1) <= 30 Then
							ls_data[tt] = ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If
					Case '10010'
						ls_data[tt] = ''
					Case '10011'
						If LenA(ls_bil_addr1) > 30 Then
							ls_data[tt] = ls_bil_addr1 + ' ' + ls_bil_addr2
						Else
							ls_data[tt] = ''
						End If			
					Case '10012'	//법인명
						ls_data[tt] = ls_corpnm   
					Case '10013'	//법인명() 
						ls_data[tt] = ls_corpnm_2 
					Case '10094'	//부과명
						ls_data[tt] = ''
					Case '10014'	//청구서 발행일
						ls_data[tt] = string(ld_workdt, 'yyyymmdd')  
					Case '10066' 	//청구액합계
						ls_data[tt] = string(ll_customer_sum)
					Case '10015'	//결제채널
						ls_data[tt] = ls_pay_method 
					Case '10067'	//청구서 종류  결제채널이 '2'면 2...
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = '2'
						End If
					Case '10068'	//전용계좌번호지정
						If ls_pay_method = '1' Then
							ls_data[tt] = '1'
						ElseIf ls_pay_method = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10069'	//전용계좌인자우선
						If ls_data[tt - 1] = '1' Then
							ls_data[tt] = '1'						
						ElseIf ls_data[tt - 1] = '2' Then
							ls_data[tt] = '0'
						Else
							ls_data[tt] = '0'
						End If
					Case '10016' 	//예금주
						If ls_pay_method = '1' Then
							ls_data[tt] = ls_accowner 
						Else
							ls_data[tt] = ''
						End If
					Case '10017' 	//은행코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[1]
	//					Else
							ls_data[tt] = ''
	//					End If					
					Case '10018'	//은행명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_name
	//					Else
							ls_data[tt] = ''
	//					End If
					Case '10019' //지점코드
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10020' //지점명
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_bank_dealer_nm
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10021'  //예금과목
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_acct_item
	//					Else
							ls_data[tt] = ''
	//					End If				
					Case '10022'	// 은행계좌번호
	//					If ls_pay_method = '1' Then
	//						ls_data[tt] = ls_result[2]
	//					Else
							ls_data[tt] = ''
	//					End If			
					Case '10023' 	//고객은행코드
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bank
						Else
							ls_data[tt] = ''
						End If
					Case '10024' 	//고객은행
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_bankshop
						Else
							ls_data[tt] = ''
						End If
					Case '10088'	//지점코드
						If ls_pay_method = '2' Then
							ls_data[tt] = '000'
						Else
							ls_data[tt] = ''
						End If
					Case '10089'	//지점명
						If ls_pay_method = '2' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = ''
						End If		
					Case '10093'	//예금과목
						If ls_pay_method = '2' Then
							ls_data[tt] = '1'
						Else
							ls_data[tt] = ''
						End If							
					Case '10025'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acctno
						Else
							ls_data[tt] = ''
						End If	
					Case '10026'
						If ls_pay_method = '2' Then
							ls_data[tt] = ls_acct_owner
						Else
							ls_data[tt] = ''
						End If	
					Case '10027'	//입금마감일
						ls_data[tt] = ls_inputclosedt 
					Case '10095'	//신규코드
						If ls_pay_method = '1' Then
							ls_data[tt] = ''
						Else
							ls_data[tt] = '1'
						End If							
					Case Else
						If MidA(ls_itemkey_data[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data)
				
				For i = 1 To UpperBound(ls_seq_data)
					If j =  integer(ls_seq_data[i]) Then
						If isnull(ls_data[j]) or ls_data[j] = '' Then
							ls_da += ls_item_data_gu
						Else
							ls_da += ls_comma + ls_data[j] + ls_comma + ls_item_data_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data_gu
					Else
						ls_da += ls_data[j] + ls_item_data_gu
					End If
				End IF
				
			Next
					
			ls_trail_pnt = MidA(ls_da, 1, LenA(ls_da) - 1) + ls_record_data_gu
					
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) d")
					FileClose(li_filenum)
					ls_status = 'failiure_d_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D1
      ll_itemkey_data = UpperBound(ls_itemkey_data1)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data1)
				Choose Case ls_itemkey_data1[tt]
					Case '10003'
						ls_data1[tt] = ls_payid								//고객코드
					Case '10095'
						ls_data1[tt] = MidA(ls_trdt, 1, 6)  				//청구년월
					Case '10096'
						ls_data1[tt] = fs_fill_pad('', 6, '1', '0')	//인증키 총갯수
					Case '10097'
						ls_data1[tt] = fs_fill_pad('', 14, '2', '0')	//대표 인증key
					Case '10027'
					   ls_data1[tt] = ls_inputclosedt               //입금마감일
					Case '10002'
						ls_data1[tt] = ls_workdt  //작업일  -  구빌링의 girobase생성일인거 같음. ㅎ drawupdt
					Case '10005'
						ls_data1[tt] = fs_fill_pad(ls_customernm, 50, '2', ' ')	//고객명
					Case '10098'
						ls_data1[tt] = ls_useddt_fr+ls_useddt_to //사용기간
					Case '10116'
						ls_data1[tt] = ls_type 
					Case '10115'  //space
						ls_data1[tt] = fs_fill_pad(ls_space, 7, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data1[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data1[tt] = ''
						End If
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data1)
				
				For i = 1 To UpperBound(ls_seq_data1)
					If j =  integer(ls_seq_data1[i]) Then
						If isnull(ls_data1[j]) or ls_data1[j] = '' Then
							ls_da += ls_item_data1_gu
						Else
							ls_da += ls_comma + ls_data1[j] + ls_comma + ls_item_data1_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
								
				IF ll_gubun <> j  Then
					If ls_data1[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data1_gu
					Else
						ls_da += ls_data1[j] //+ ls_item_data1_gu
					End If
				End IF
				
			Next
					
//			ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data1_gu
			ls_trail_pnt = ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D1")
					FileClose(li_filenum)
					ls_status = 'failiure_d1_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D2
		ll_itemkey_data = UpperBound(ls_itemkey_data2)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data2)
				Choose Case ls_itemkey_data2[tt]
					Case '10007'
						ls_data2[tt] = fs_fill_pad(ls_bil_zipcod, 6, '2', ' ')//우편번호
					Case '10099'
  					   ls_data2[tt] = fs_fill_pad(ls_bil_addr1, 60, '2', ' ') //주소
					Case '10100'
						ls_data2[tt] = fs_fill_pad(ls_bil_addr2, 50, '2', ' ') //주소
               Case '10115'  //space
						ls_data2[tt] = fs_fill_pad(ls_space, 17, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data2[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data2[tt] = ''
						End If						
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data2)
				
				For i = 1 To UpperBound(ls_seq_data2)
					If j =  integer(ls_seq_data2[i]) Then
						If isnull(ls_data2[j]) or ls_data2[j] = '' Then
							ls_da += ls_item_data2_gu
						Else
							ls_da += ls_comma + ls_data2[j] + ls_comma + ls_item_data2_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data2[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data2_gu
					Else
						ls_da += ls_data2[j] //+ ls_item_data2_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data2_gu
			ls_trail_pnt =ls_da
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D2")
					FileClose(li_filenum)
					ls_status = 'failiure_d2_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D3
		ll_itemkey_data = UpperBound(ls_itemkey_data3)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data3)
				Choose Case ls_itemkey_data3[tt]
					Case '10066'
						If ll_cur_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_cur_balance)), 9, '1', '0') 	//청구서합계
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_cur_balance), 10, '1', '0') 	//청구서합계
						End If
					Case '10101' 					   
						If ll_pre_balance < 0 Then
							ls_data3[tt] = '-'
							ls_data3[tt] += fs_fill_pad(string(abs(ll_pre_balance)), 9, '1', '0') 	//미납액
						Else
							ls_data3[tt] = fs_fill_pad(string(ll_pre_balance), 10, '1', '0') 	//미납액
						End If		
					Case '10102'
  					   ls_data3[tt] = fs_fill_pad(string(ll_supplyamt), 10, '1', '0') 	//공급가액
					Case '10103'	
  					   ls_data3[tt] = fs_fill_pad(string(ll_surtax), 10, '1', '0') 		//부가세 
					Case '10104'	
  					   ls_data3[tt] = fs_fill_pad(ls_cregno, 13, '2', ' ') 					//사업자등록번호
					Case '10117'
						If ls_pay_method = ls_method[3] Then  //카드
                     ls_data3[tt] = fs_fill_pad(ls_card_no, 20, '2', ' ') 
						Else							
							ls_data3[tt] = fs_fill_pad(ls_acctno, 20, '2', ' ')               //고객 계좌번호/카드번호
						End If
					Case '10118'
						If ls_pay_method = ls_method[3] Then  //카드
						   ls_data3[tt] = fs_fill_pad(ls_cardnm, 30, '2', ' ') 
						Else
							ls_data3[tt] = fs_fill_pad(ls_banknm, 30, '2', ' ')               //은행명/카드사명
						End If						
					Case '10119'
						If ls_pay_method = ls_method[3] Then  //카드
						   ls_data3[tt] = fs_fill_pad(ls_card_holder, 30, '2', ' ')
						Else
							ls_data3[tt] = fs_fill_pad(ls_acct_owner, 30, '2', ' ')               //예금주/카드소유주
						End If						
					Case '10105'
						ls_data3[tt] = fs_fill_pad(ls_payid, 10, '1', '0')+fs_fill_pad(ls_trdt, 8, '1', '0')+'0' //고객조회번호
					Case '10115'  //space
						ls_data3[tt] = fs_fill_pad(ls_space, 61, '1', ' ')						
					Case Else
						If MidA(ls_itemkey_data3[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data3[tt] = ''
						End If				
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data3)
				
				For i = 1 To UpperBound(ls_seq_data3)
					If j =  integer(ls_seq_data3[i]) Then
						If isnull(ls_data3[j]) or ls_data3[j] = '' Then
							ls_da += ls_item_data3_gu
						Else
							ls_da += ls_comma + ls_data3[j] + ls_comma + ls_item_data3_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data3[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data3_gu
					Else
						ls_da += ls_data3[j] //+ ls_item_data3_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data3_gu
			ls_trail_pnt = ls_da		
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D3")
					FileClose(li_filenum)
					ls_status = 'failiure_d3_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//D4
		For i = 1 To 2
			ls_acctno_bef1[i]    = ''
			ls_acct_type_bef1[i] = ''
			ls_acct_owner_bef1[i] = ''
			ls_paydt1[i]         = ''
			ll_payamt1[i]        = 0
		Next
		i = 1
		DECLARE reqreceipt_cu CURSOR FOR
			SELECT ACCT_NO    //계좌번호,카드번호
			     , ACCT_TYPE  //은행code,카드코드
				  , ACCT_OWNER //예금주OR소유주
				  , to_char(PAYDT, 'yyyymmdd')  PAYDT     //전월 출금일
				  , pay_method
				  , PAYAMT   	//전월 출금액
			  FROM REQRECEIPT
  		    WHERE PAYID = :ls_payid
				AND TRDT  = :ld_trdt 				
            AND ROWNUM <= 2
       ORDER BY PAYDT ;
			 
			OPEN reqreceipt_cu;
			
			DO WHILE (True)
				
				Fetch reqreceipt_cu
				Into :ls_acctno_bef, :ls_acct_type_bef, :ls_acct_owner_bef, :ls_paydt, :ls_pay_method_bef, :ll_payamt;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				If isnull(ls_acctno_bef) Then ls_acctno_bef = ''
				
				If ls_acctno_bef <> ''  Then
					ls_acctno_bef = LeftA(ls_acctno_bef, 6) + FillA("*", LenA(ls_acctno_bef) - 6)
				End If	
				
				If ls_pay_method_bef = ls_method[3] Then  //카드
					//카드사명 가져오기..
					select codenm 
					  into :ls_cardnm
					  from syscod2t 
					 where grcode = 'B450' 
						and code   = :ls_acct_type_bef;
					
					If SQLCA.SQLCode < 0 Then
						ll_code = 0
						Exit
					ElseIf SQLCA.SQLCode = 100 Then
						ls_cardnm = 'NoDefine'
			//			CONTINUE
					End If 	
					
					ls_acctno_bef1[i]    = ls_acctno_bef
					ls_acct_type_bef1[i] = ls_cardnm
					ls_acct_owner_bef1[i] = ls_acct_owner_bef
					ls_paydt1[i]         = ls_paydt
					ll_payamt1[i]        = ll_payamt					
					
				Else						
					//은행명 가져오기..
					select codenm 
					  into :ls_banknm
					  from syscod2t 
					 where grcode = 'B400' 
						and code   = :ls_acct_type_bef;
					
					If SQLCA.SQLCode < 0 Then
						ll_code = 0
						Exit
					ElseIf SQLCA.SQLCode = 100 Then
						ls_banknm = 'NoDefine'
			//			CONTINUE
					End If 			
					
					ls_acctno_bef1[i]    = ls_acctno_bef
					ls_acct_type_bef1[i] = ls_banknm
					ls_acct_owner_bef1[i] = ls_acct_owner_bef
					ls_paydt1[i]         = ls_paydt
					ll_payamt1[i]        = ll_payamt					
				End If	
				i ++						
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_reqreceipt_cu'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqreceipt_cu;
		
		ll_itemkey_data = UpperBound(ls_itemkey_data4)
		If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
		
		If ll_itemkey_data > 0 Then
			For tt = 1 To UpperBound(ls_itemkey_data4)
				Choose Case ls_itemkey_data4[tt]
					Case '10120'
						ls_data4[tt] = fs_fill_pad(ls_acctno_bef1[1], 20, '2', ' ')    //전월계좌
					Case '10121'
						ls_data4[tt] = fs_fill_pad(ls_acct_type_bef1[1], 30, '2', ' ')//전월은행
					Case '10122'
						ls_data4[tt] = fs_fill_pad(ls_acct_owner_bef1[1], 30, '2', ' ')//전월소유주
					Case '10123'
						ls_data4[tt] = fs_fill_pad(ls_paydt1[1], 8, '2', ' ')   //전월입금일
					Case '10124'
						ls_data4[tt] = fs_fill_pad(string(ll_payamt1[1]), 10, '1', '0')//전월 입금액
					Case '10125'	
						ls_data4[tt] = fs_fill_pad(ls_paydt1[2], 8, '2', ' ')//전월입금일2
					Case '10126'							
						ls_data4[tt] = fs_fill_pad(string(ll_payamt1[2]), 10, '1', '0')//전월입금액2
					Case '10115'  //space
						ls_data4[tt] = fs_fill_pad(ls_space, 17, '1', ' ')
					Case Else
						If MidA(ls_itemkey_data4[tt], 1, 1) <> '2' Then  //정의된 값이 아니면..
							ls_data4[tt] = ''
						End If				
				End Choose				
			Next
	
			//안내문  59~ 72  = ''
			//ll_count ++
			ll_gubun = 0
	
			For j = 1 To UpperBound(ls_data4)
				
				For i = 1 To UpperBound(ls_seq_data4)
					If j =  integer(ls_seq_data4[i]) Then
						If isnull(ls_data4[j]) or ls_data4[j] = '' Then
							ls_da += ls_item_data4_gu
						Else
							ls_da += ls_comma + ls_data4[j] + ls_comma + ls_item_data4_gu
						End If
						
						ll_gubun = j
						Exit
					End If
				Next
				
				IF ll_gubun <> j  Then
					If ls_data4[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
						ls_da += ls_item_data4_gu
					Else
						ls_da += ls_data4[j] //+ ls_item_data3_gu
					End If
				End IF
				
			Next
					
			//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_data3_gu
			ls_trail_pnt = ls_da		
			//For i = 1 To UpperBound(ls_data)
				li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
				If li_write_bytes < 0 Then 
					f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) D4")
					FileClose(li_filenum)
					ls_status = 'failiure_d4_write'
					Goto NextStep
					//Return 
				End If
			//Next
		End If		
		ls_trail_pnt = ''
		ls_da        = ''
		
		//상세항목
		DECLARE reqamtinfo_cu CURSOR FOR
			SELECT PAYID		//고객번호
				  , TRDT			//청구기준일
				  , CHARGEDT	//청구주기
				  , REQNUM		//청구번호
//				  , SUPPLYAMT  //공급가액
//				  , SURTAX 		//부과세
				  , NVL(BTRAMT01, 0), NVL(BTRAMT02, 0), NVL(BTRAMT03, 0), NVL(BTRAMT04, 0) 
				  , NVL(BTRAMT05, 0), NVL(BTRAMT06, 0), NVL(BTRAMT07, 0), NVL(BTRAMT08, 0) 
				  , NVL(BTRAMT09, 0), NVL(BTRAMT10, 0), NVL(BTRAMT11, 0), NVL(BTRAMT12, 0) 
				  , NVL(BTRAMT13, 0), NVL(BTRAMT14, 0), NVL(BTRAMT15, 0), NVL(BTRAMT16, 0) 
				  , NVL(BTRAMT17, 0), NVL(BTRAMT18, 0), NVL(BTRAMT09, 0), NVL(BTRAMT20, 0)	
				  , NVL(BTRAMT21, 0), NVL(BTRAMT22, 0), NVL(BTRAMT23, 0), NVL(BTRAMT24, 0) 
				  , NVL(BTRAMT25, 0), NVL(BTRAMT26, 0), NVL(BTRAMT27, 0), NVL(BTRAMT28, 0) 
				  , NVL(BTRAMT29, 0), NVL(BTRAMT30, 0)				  
				  , NVL(BTRDESC01,''), NVL(BTRDESC02,''), NVL(BTRDESC03,'')
				  , NVL(BTRDESC04,''), NVL(BTRDESC05,''), NVL(BTRDESC06,'')
				  , NVL(BTRDESC07,''), NVL(BTRDESC08,''), NVL(BTRDESC09,'')
				  , NVL(BTRDESC10,''), NVL(BTRDESC11,''), NVL(BTRDESC12,'')
				  , NVL(BTRDESC13,''), NVL(BTRDESC14,''), NVL(BTRDESC15,'')
				  , NVL(BTRDESC16,''), NVL(BTRDESC17,''), NVL(BTRDESC18,'')
				  , NVL(BTRDESC19,''), NVL(BTRDESC20,''), NVL(BTRDESC21,'')
				  , NVL(BTRDESC22,''), NVL(BTRDESC23,''), NVL(BTRDESC24,'')
				  , NVL(BTRDESC25,''), NVL(BTRDESC26,''), NVL(BTRDESC27,'')
				  , NVL(BTRDESC28,''), NVL(BTRDESC29,''), NVL(BTRDESC30,'')
			  FROM REQAMTINFO
  		    WHERE PAYID    = :ls_payid
				AND TRDT     = :ld_trdt  
				AND CHARGEDT = :ls_chargedt;
			 
			OPEN reqamtinfo_cu;
			
			DO WHILE (True)
				
				Fetch reqamtinfo_cu
				Into :ls_payid_amt, :ld_trdt_amt, :ls_chargedt_amt, :ls_reqnum_amt
				   , :ll_btramt[1], :ll_btramt[2], :ll_btramt[3], :ll_btramt[4], :ll_btramt[5]
				   , :ll_btramt[6], :ll_btramt[7], :ll_btramt[8], :ll_btramt[9], :ll_btramt[10]
				   , :ll_btramt[11], :ll_btramt[12], :ll_btramt[13], :ll_btramt[14], :ll_btramt[15]
				   , :ll_btramt[16], :ll_btramt[17], :ll_btramt[18], :ll_btramt[19], :ll_btramt[20]
				   , :ll_btramt[21], :ll_btramt[22], :ll_btramt[23], :ll_btramt[24], :ll_btramt[25]
				   , :ll_btramt[26], :ll_btramt[27], :ll_btramt[28], :ll_btramt[29], :ll_btramt[30]					
					, :ls_btrdesc[1], :ls_btrdesc[2], :ls_btrdesc[3], :ls_btrdesc[4], :ls_btrdesc[5]
					, :ls_btrdesc[6], :ls_btrdesc[7], :ls_btrdesc[8], :ls_btrdesc[9], :ls_btrdesc[10] 
					, :ls_btrdesc[11], :ls_btrdesc[12], :ls_btrdesc[13], :ls_btrdesc[14], :ls_btrdesc[15]
					, :ls_btrdesc[16], :ls_btrdesc[17], :ls_btrdesc[18], :ls_btrdesc[19], :ls_btrdesc[20] 
					, :ls_btrdesc[21], :ls_btrdesc[22], :ls_btrdesc[23], :ls_btrdesc[24], :ls_btrdesc[25]
					, :ls_btrdesc[26], :ls_btrdesc[27], :ls_btrdesc[28], :ls_btrdesc[29], :ls_btrdesc[30]  ;
					
				If SQLCA.SQLCode < 0 Then
					ll_code = 0
					Exit
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
				
				For i = 1 To UpperBound(ls_btrdesc)
					If ls_btrdesc[i] = 'null' Or IsNull(ls_btrdesc[i]) Then
						ls_btrdesc[i] = ''
					End If
				Next

				Long pp
		
//				For pp = 1 To UpperBound(ls_itemkey_data_detail)
//					Choose Case ls_itemkey_data_detail[pp]
//						Case '10000'	//위탁회사 코드
//							ls_data_detail[pp] = ls_company
//						Case '10003'	//고객번호
//							ls_data_detail[pp] = fs_fill_pad(ls_payid_amt, 15, '1', '0')
//						Case '10004' 	//청구번호
//							ls_data_detail[pp] = fs_fill_pad(ls_reqnum_amt, 10, '1', '0')
//						Case '10042'	//명세부분 프리 레이아웃지역1-1  
//							ls_data_detail[pp] = string(ld_trdt_amt, 'mm') + '/' + string(ld_trdt_amt, 'dd')
//						Case Else
//							ls_data_detail[pp] = ''
//					End Choose
//				Next
				
				For i = 1 To UpperBound(ls_btrdesc)
					If IsNull(ls_btrdesc[i]) Or ls_btrdesc[i] = '' Then Continue
					
					For pp = 1 To UpperBound(ls_itemkey_data_detail)
						Choose Case ls_itemkey_data_detail[pp]
							Case '10106'
								ls_data_detail[pp] = fs_fill_pad(ls_btrdesc[i], 30, '2', ' ')			// 항목
							Case '10107'
								If ll_btramt[i] < 0 Then
									ls_data_detail[pp] = '-'
								   ls_data_detail[pp] += fs_fill_pad(string(abs(ll_btramt[i])), 9, '1', '0')	// 금액
								Else
									ls_data_detail[pp] = fs_fill_pad(string(ll_btramt[i]), 10, '1', '0')
								End If
							Case '10115'  //space
						   	ls_data_detail[pp] = fs_fill_pad(ls_space, 93, '1', ' ')
							Case Else
								If MidA(ls_itemkey_data_detail[pp], 1, 1) <> '2' Then
									ls_data_detail[pp] = ''
								End If								
								
						End Choose
					Next
					
					//청구대상 고객들의 총 청구금액 sum, count
					ll_amt_total = ll_amt_total + ll_btramt[i]
					//ll_count ++
					ll_gubun = 0
					For j = 1 To UpperBound(ls_data_detail)
					
						For t = 1 To UpperBound(ls_seq_data_detail)
							If j =  integer(ls_seq_data_detail[t]) Then
								If isnull(ls_data_detail[j]) or ls_data_detail[j] = '' Then
									ls_da_t += ls_item_data_detail_gu
								Else
									ls_da_t += ls_comma + ls_data_detail[j] + ls_comma + ls_item_data_detail_gu
								End If
								ll_gubun = j
								Exit
							End If
						Next
						
						IF ll_gubun <> j  Then
							If ls_data_detail[j] = '' Then
								ls_da_t += ls_item_data_detail_gu
							Else
								ls_da_t += ls_data_detail[j] //+ ls_item_data_detail_gu
							End If
						End IF
					Next

					//ls_trail_pnt = mid(ls_da_t, 1, Len(ls_da_t) - 1) + ls_record_data_detail_gu
				   ls_trail_pnt = ls_da_t
					//For j = 1 To UpperBound(ls_data_detail)
						li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
						If li_write_bytes < 0 Then 
							f_msg_usr_err(9000, is_Title, "File Write Failed! (Data-detail Record) detail")
							FileClose(li_filenum)
							ls_status = 'failiure_amtinfo_write'
							Goto NextStep
							//Return 
						End If
					//Next
					ls_trail_pnt = ''
					ls_da_t = ''
				Next
				
			LOOP

			If ll_code = 0 Then
				FileClose(li_FileNum)
				rollback;
				ls_status = 'failiure_amtinfo'
				Goto NextStep				
				//Return
			End If
			
		CLOSE reqamtinfo_cu;	
		
		If ls_invdetail_yn = 'Y' Then
			ll_no = 0
			//00321지로, 자동이체....
			If ls_cnd_invf_type = ls_result[1] Or ls_cnd_invf_type = ls_result[2] Then			
				//cdr 상세
				DECLARE cdr_detail CURSOR FOR
					SELECT VALIDKEY
						  , TO_CHAR(STIME, 'yyyymmddhh24miss') STIME 
						  , BILTIME
						  , COUNTRYCOD
						  , RTELNUM
						  , ROUND(BILAMT, 0) BILAMT
						 // , trim(TO_char(BILAMT, '9999999999.9')) S_BILAMT
					  FROM POST_BILCDR
					 WHERE PAYID = :ls_payid
						AND TO_CHAR(STIME, 'YYYYMMDD') < :ls_trdt  
						AND BILAMT > 0
				 ORDER BY STIME ASC ; 
					 
					OPEN cdr_detail;
					
					DO WHILE (True)
						
						Fetch cdr_detail
						Into :ls_validkey, :ls_stime, :ll_biltime, :ls_countrycod, :ls_rtelnum, :ll_bilamt;//, :ls_s_bilamt ;
							
						If SQLCA.SQLCode < 0 Then
							ll_code = 0
							Exit
						ElseIf SQLCA.SQLCode = 100 Then
							Exit
						End If
						
						SELECT COUNTRYNM
						  INTO :ls_countrynm 
						  FROM COUNTRY 
						 WHERE COUNTRYCOD = :ls_countrycod;
						 
						If SQLCA.SQLCode < 0 Then
							ll_code = 0
							Exit
						ElseIf SQLCA.SQLCode = 100 Then
		//					ll_code = 0
		//					Exit
							ls_countrynm = 'NoDefine'
						End If			
						
						If ll_biltime = 0 Then
							ls_biltime = '000000'
						End If
						ll_hh      = Truncate(ll_biltime/3600, 0)
						ll_mi      = Truncate((ll_biltime - (ll_hh * 3600))/60, 0)
						ll_ss      = ll_biltime - ((ll_hh * 3600) + (ll_mi * 60))
						ls_biltime = fs_fill_pad(string(ll_hh), 2, '1', '0')+fs_fill_pad(string(ll_mi), 2, '1', '0')+fs_fill_pad(string(ll_ss), 2, '1', '0')
						
						ld_biltime  = round(ll_biltime / 60, 2)
						
						ll_no = ll_no + 1
						
						ll_itemkey_data = UpperBound(ls_itemkey_cdr)
						If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
						
						If ll_itemkey_data > 0 Then
							For tt = 1 To UpperBound(ls_itemkey_cdr)
								Choose Case ls_itemkey_cdr[tt]
									Case '10108'
										ls_cdr[tt] = fs_fill_pad(string(ll_no), 10, '1', '0') //seqno 
									Case '10109'
										ls_cdr[tt] = fs_fill_pad(ls_validkey, 14, '2', ' ')   //인증키
									Case '10110'
										ls_cdr[tt] = ls_stime                                 //통화시작시간
									Case '10112'
										ls_cdr[tt] = fs_fill_pad(ls_biltime, 6, '1', '0')  //사용시간(시분초)
									Case '10111'
										ls_cdr[tt] = fs_fill_pad(ls_countrynm, 30, '2', ' ')  //국가명
									Case '10113'
										ls_cdr[tt] = fs_fill_pad(ls_rtelnum, 30, '2', ' ')  //착신번호
									Case '10114'
										ls_cdr[tt] = fs_fill_pad(string(ll_bilamt), 10, '1', '0')  //통화금액	
									Case '10129'
										ls_cdr[tt] = fs_fill_pad(ls_groupnm, 60, '2', ' ')  //그룹명
									Case '10128'
										ls_cdr[tt] = fs_fill_pad(string(ll_biltime), 10, '1', '0')  //사용시간 (초)
									Case '10127'
										ls_cdr[tt] = fs_fill_pad(string(ld_biltime), 10, '1', '0')  //사용시간 (분)
									Case '10115'  //space
										ls_cdr[tt] = fs_fill_pad(ls_space, 19, '1', ' ')
									Case '10130'  //space2
										ls_cdr[tt] = fs_fill_pad(ls_space, 33, '1', ' ')	
									Case Else
										If MidA(ls_itemkey_cdr[tt], 1, 1) <> '2' Then
											ls_cdr[tt] = ''
										End If								
								End Choose				
							Next
					
							//안내문  59~ 72  = ''
							//ll_count ++
							ll_gubun = 0
					
							For j = 1 To UpperBound(ls_cdr)
								
								For i = 1 To UpperBound(ls_seq_cdr)
									If j =  integer(ls_seq_cdr[i]) Then
										If isnull(ls_cdr[j]) or ls_cdr[j] = '' Then
											ls_da += ls_item_cdr_gu
										Else
											ls_da += ls_comma + ls_cdr[j] + ls_comma + ls_item_cdr_gu
										End If
										
										ll_gubun = j
										Exit
									End If
								Next
								
								IF ll_gubun <> j  Then
									If ls_cdr[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
										ls_da += ls_item_cdr_gu
									Else
										ls_da += ls_cdr[j]// + ls_item_cdr_gu
									End If
								End IF
								
							Next
									
							//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_cdr_gu
							ls_trail_pnt =ls_da
							//For i = 1 To UpperBound(ls_data)
								li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
								If li_write_bytes < 0 Then 
									f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) cdr")
									FileClose(li_filenum)
									ls_status = 'failiure_cdr_write'
									Goto NextStep
									//Return 
								End If
							//Next
						End If		
						ls_trail_pnt = ''
						ls_da        = ''
					LOOP
		
					If ll_code = 0 Then
						FileClose(li_FileNum)
						rollback;
						ls_status = 'failiure_cdr'
						Goto NextStep				
						//Return
					End If				
				CLOSE cdr_detail;	
				
			//SAVER, ROAM
			Else  
				//cdr 상세
				DECLARE cdr_detail_1 CURSOR FOR
					SELECT COUNTRYNM
						  , BILTIME
						  , ROUND(BILCOST, 0) BILCOST
					  FROM REQ_CDRSUM_TEMP
					 WHERE PAYID    = :ls_payid
						AND TRDT     = :ld_trdt
						AND CHARGEDT = :ls_chargedt 
				 order by areagroup
						  , sortno
						  , countrynm                 ;
					 
					OPEN cdr_detail_1;
					
					DO WHILE (True)
						
						Fetch cdr_detail_1
						Into :ls_groupnm, :ll_biltime, :ll_bilamt;//, :ls_s_bilamt;
							
						If SQLCA.SQLCode < 0 Then
							ll_code = 0
							Exit
						ElseIf SQLCA.SQLCode = 100 Then
							Exit
						End If
						
						If ll_biltime = 0 Then
							ls_biltime = '000000'
						End If
						ll_hh      = Truncate(ll_biltime/3600, 0)
						ll_mi      = Truncate((ll_biltime - (ll_hh * 3600))/60, 0)
						ll_ss      = ll_biltime - ((ll_hh * 3600) + (ll_mi * 60))
						ls_biltime = fs_fill_pad(string(ll_hh), 2, '1', '0')+fs_fill_pad(string(ll_mi), 2, '1', '0')+fs_fill_pad(string(ll_ss), 2, '1', '0')
						
						//사용시간 (분)
						ld_biltime  = round(ll_biltime / 60, 2)
						
						ll_no = ll_no + 1
						
						ll_itemkey_data = UpperBound(ls_itemkey_cdr)
						If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0
						
						If ll_itemkey_data > 0 Then
							For tt = 1 To UpperBound(ls_itemkey_cdr)
								Choose Case ls_itemkey_cdr[tt]
									Case '10108'
										ls_cdr[tt] = fs_fill_pad(string(ll_no), 10, '1', '0') //seqno 
									Case '10109'
										ls_cdr[tt] = fs_fill_pad(ls_validkey, 14, '2', ' ')   //인증키
									Case '10110'
										ls_cdr[tt] = ls_stime                                 //통화시작시간
									Case '10112'
										ls_cdr[tt] = fs_fill_pad(ls_biltime, 6, '1', '0')  //사용시간(시분초)
									Case '10111'
										ls_cdr[tt] = fs_fill_pad(ls_countrynm, 30, '2', ' ')  //국가명
									Case '10113'
										ls_cdr[tt] = fs_fill_pad(ls_rtelnum, 30, '2', ' ')  //착신번호
									Case '10114'
										ls_cdr[tt] = fs_fill_pad(string(ll_bilamt), 10, '1', '0')  //통화금액	
									Case '10129'
										ls_cdr[tt] = fs_fill_pad(ls_groupnm, 60, '2', ' ')  //그룹명
									Case '10128'
										ls_cdr[tt] = fs_fill_pad(string(ll_biltime), 10, '1', '0')  //사용시간 (초)
									Case '10127'
										ls_cdr[tt] = fs_fill_pad(string(ld_biltime), 10, '1', '0')  //사용시간 (분)
									Case '10115'  //space
										ls_cdr[tt] = fs_fill_pad(ls_space, 19, '1', ' ')
									Case '10130'  //space2
										ls_cdr[tt] = fs_fill_pad(ls_space, 33, '1', ' ')	
									Case Else
										If MidA(ls_itemkey_cdr[tt], 1, 1) <> '2' Then
											ls_cdr[tt] = ''
										End If								
								End Choose				
							Next
					
							//안내문  59~ 72  = ''
							//ll_count ++
							ll_gubun = 0
					
							For j = 1 To UpperBound(ls_cdr)
								
								For i = 1 To UpperBound(ls_seq_cdr)
									If j =  integer(ls_seq_cdr[i]) Then
										If isnull(ls_cdr[j]) or ls_cdr[j] = '' Then
											ls_da += ls_item_cdr_gu
										Else
											ls_da += ls_comma + ls_cdr[j] + ls_comma + ls_item_cdr_gu
										End If
										
										ll_gubun = j
										Exit
									End If
								Next
								
								IF ll_gubun <> j  Then
									If ls_cdr[j] = '' Then	//Or IsNull(ls_data[j]) Or ls_data[j] = " " Then
										ls_da += ls_item_cdr_gu
									Else
										ls_da += ls_cdr[j]// + ls_item_cdr_gu
									End If
								End IF
								
							Next
									
							//ls_trail_pnt = mid(ls_da, 1, Len(ls_da) - 1) + ls_record_cdr_gu
							ls_trail_pnt =ls_da
							//For i = 1 To UpperBound(ls_data)
								li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
								If li_write_bytes < 0 Then 
									f_msg_usr_err(9000, is_Title, "File Write Failed! (Data Record) cdr")
									FileClose(li_filenum)
									ls_status = 'failiure_cdr_write'
									Goto NextStep
									//Return 
								End If
							//Next
						End If		
						ls_trail_pnt = ''
						ls_da        = ''
					LOOP
		
					If ll_code = 0 Then
						FileClose(li_FileNum)
						rollback;
						ls_status = 'failiure_cdr'
						Goto NextStep				
						//Return
					End If
					
				CLOSE cdr_detail_1;	
			End If
		End If
	LOOP   
	
	If ll_code = 0 Then
		FileClose(li_FileNum)
		rollback;
		ls_status = 'failiure_reqinfo'
		Goto NextStep
		//Return
	End If
	
CLOSE reqinfo_cu;

If ll_count = 0 Then
	FileClose(li_FileNum)
	rollback;
	ls_status = 'reqinfono_data'
	Goto NextStep
End IF

long gg
//trailer
ll_itemkey_data = UpperBound(ls_itemkey_trailer)
If Isnull(ll_itemkey_data) Then ll_itemkey_data = 0

If ll_itemkey_data > 0 Then
	For gg = 1 To UpperBound(ls_itemkey_trailer)
		Choose Case ls_itemkey_trailer[gg]
			Case '10000'	//위탁회사 코드
				ls_trailer[gg] = ls_company
			Case '10091' 	//합계건수
				ls_trailer[gg] = string(ll_count)
			Case '10092'	//합계금액
				ls_trailer[gg] = string(ll_amt_total)
			Case Else
				If MidA(ls_itemkey_trailer[gg], 1, 1) <> '2' Then
					ls_trailer[gg] = ''
				End If				
				
		End Choose
	Next
	
	//ls_property = fs_itemkey_property(ls_cnd_invf_type, 'T')
	//
	//If ls_property <> "" Then
	//	fi_cut_string(ls_property, ";" , ls_result[])
	//End if
	
	ll_gubun = 0
	For j = 1 To UpperBound(ls_trailer)
		For i = 1 To UpperBound(ls_seq_trailer)
			If j =  integer(ls_seq_trailer[i]) Then
				If ls_trailer[j] = '' Then
					ls_trail += ls_item_trailer_gu
				Else
					ls_trail += ls_comma + ls_trailer[j] + ls_comma + ls_item_trailer_gu
				End If
				
				ll_gubun = j
				Exit
			End If
		Next
		
		IF ll_gubun <> j  Then
			If ls_trailer[j] = '' Then
				ls_trail += ls_item_trailer_gu
			Else
				ls_trail += ls_trailer[j] //+ ls_item_trailer_gu
			End If
		End IF
	Next
	
	//ls_trail_pnt = mid(ls_trail, 1, Len(ls_trail) - 1)
	ls_trail_pnt = ls_trail
	//For j = 1 To UpperBound(ls_trailer)
		li_write_bytes = FileWrite(li_FileNum, ls_trail_pnt)
		If li_write_bytes < 0 Then 
			f_msg_usr_err(9000, is_Title, "File Write Failed! (trailer Record)")
			FileClose(li_filenum)
			ls_status = 'failiure3'
			Goto NextStep
			//Return 
		End If
	//Next
End If
FileClose(li_FileNum)

ls_status = 'Complete'

//ls_filename = Mid(ls_filename, 4)
////li_tab      = Pos(ls_filename, "\")
//ls_filename = Mid(ls_filename, Pos(ls_filename, "\") + 1)
//
NextStep :

//log 생성
INSERT INTO INVF_WORKLOG
			 ( SEQNO
			 , FILEW_DIR
			 , FILEW_NAME
			 , FILEW_STATUS
			 , FILEW_COUNT
			 , FILEW_INVAMT
          , CND_INVF_TYPE
			 , CND_INV_TYPE
			 , CND_WORKDT
			 , CND_INPUTCLOSEDT
			 , CND_TRDT
			 , CND_CHARGEDT
			 , CND_PAY_METHOD
			 , CND_BANKPAY
			 , CND_CREDITPAY
			 , CND_ETCPAY
			 , CRT_USER
			 , CRTDT
			 , PGM_ID )
     VALUES
		    ( seq_invf_worklog.nextval
			 , :ls_pathname
			 , :ls_filename
			 , :ls_status
			 , :ll_count
          , :ll_amt_total
			 , :ls_cnd_invf_type
			 , :ls_cnd_inv_type
			 , to_date(:ls_workdt, 'yyyymmdd')
			 , to_date(:ls_inputclosedt, 'yyyymmdd')
			 , to_date(:ls_trdt, 'yyyymmdd')
			 , :ls_cnd_chargedt			 
			 , :ls_cnd_pay_method
			 , :ls_cnd_bankpay
			 , :ls_cnd_creditpay
			 , :ls_cnd_etcpay
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id           );
			 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(INVF_WORKLOG)")
	RollBack;
	Return		
End If		
commit;
ii_rc = 0

Return
end subroutine

on b5u_dbmgr9.create
call super::create
end on

on b5u_dbmgr9.destroy
call super::destroy
end on

