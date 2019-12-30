$PBExportHeader$b5u_check.sru
$PBExportComments$[kwon] Check
forward
global type b5u_check from u_cust_a_check
end type
end forward

global type b5u_check from u_cust_a_check
end type
global b5u_check b5u_check

forward prototypes
public subroutine uf_prc_check ()
end prototypes

public subroutine uf_prc_check ();String ls_module, ls_ref_no, ls_ref_desc 
Long ll_row, ll_rows
String ls_date

String ls_chargedt, ls_reqterm, ls_reqdt_fr, ls_reqdt_to, ls_reqdt_dw, ls_reqnum_dw
String ls_trcod, ls_yn, ls_salesyn, ls_useryn, ls_extraflag
String ls_trdt, ls_paydt, ls_reqdt, ls_transdt
String ls_payid, ls_userid
Integer li_count
Datetime ldt_reqdt
Dec lc_tramt
Dec{0} lc0_seq
dwItemStatus ldwis_row
//vgene : 2000-06-24
String ls_busnum, ls_mannum, ls_markid

//Case "b5w_reg_trprtc%1"
//Long		ll_row, ll_rows
String	ls_sort
String	ls_bilcod, ls_bilcodnm
Integer	li_milseq, li_bilseq
String	ls_old1
Integer	li_old1, li_old2


ii_rc = -1

Choose Case is_caller
	//**** vgene : 2000-06-24  **************************************************		
	Case "modification taxdata"
		// WINDOW : b5w_reg_taxdata_modification
		// 작성자 : 2000년 6월 24일 조윤행 T&C Technology
		// 목  적 : 세금계산서 수정 (개인/법인에따른 주민번호입력/사업자등록번호 체크 )
		// 인  자 : is_title = This.Title
		// 		   is_caller = "b5w_reg_taxdata_modification"
		//				idw_data[1] = dw_detail
		 
		ls_busnum = idw_data[1].Object.cregno[1]
		If IsNull(ls_busnum) Then ls_busnum = ""
		ls_mannum = idw_data[1].Object.ssno[1]
		If IsNull(ls_mannum) Then ls_mannum = ""
		ls_markid = idw_data[1].Object.ctype2[1]
		If IsNull(ls_markid) Then ls_markid = ""
		
		Choose Case ls_markid
			Case "10"
				If LenA(ls_mannum) < 13 Then 
					f_msg_usr_err(201, is_Title, "주민등록번호재입력")
					idw_data[1].SetColumn("ssno")
					Return 
				End If
//			Case "11"
//				If len(ls_mannum) < 13 Then 
//					f_msg_usr_err(201, is_Title, "주민등록번호재입력")
//					idw_data[1].SetColumn("ssno")
//					Return 
//				End If
			
			Case "20"
				If LenA(ls_busnum) < 10 Then 
					f_msg_usr_err(201, is_Title, "사업자등록번호 재입력")
					idw_data[1].SetColumn("cregno")
					Return 
				End If
		End Choose					
					
	//**** kenn : 1999-10-11 월 **************************************************
	Case "b5w_reg_mtr_by_payid%1"		//수동거래등록
		//is_data[1]  : 고객번호
		//is_data[2]  : Master DW에서 선택된 청구번호

		ii_rc = -2
		ii_data[1] = 0

		//1.당월청구번호/당월청구년월
		SELECT nvl(chargedt, '') INTO :ls_chargedt FROM PAYMST WHERE payid = :is_data[1];
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + ":CUSTOMERM.CHARGEDT")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_usr_err(9000, is_title, "고객에 대한 정보가 없습니다.(" + is_data[1] + ")")
			Return
		End If
	
		ls_reqterm = b5fs_reqterm(ls_chargedt, "")
		If ls_reqterm = "" Then
			Return
		End If
	
		ls_reqdt_fr = MidA(ls_reqterm, 1, 8)
		ls_reqdt_to = MidA(ls_reqterm, 9, 8)
		//ls_reqdt_dw = ls_reqdt_to  /*hhm*/
 		ls_reqdt_dw = ls_reqdt_fr    /*hhm*/

		//당월청구번호를 확인한다.
		SELECT max(nvl(reqnum, '')) INTO :ls_reqnum_dw FROM REQDTL
		WHERE (trdt >= :ls_reqdt_fr AND trdt <= :ls_reqdt_to) AND payid = :is_data[1];
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + ":REQINFO.REQNUM")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			ls_reqnum_dw = ""
		End If

		//Master에서 선택한 청구번호가 존재?
		If is_data[2] = "" Then
			//선택한 청구번호가 없다.=>신규당월 청구번호가 없어야 생성 가능
			If ls_reqnum_dw <> "" Then
				f_msg_usr_err(9000, is_title, "당월 청구번호가 이미 존재합니다." + "(" + ls_reqnum_dw + ")")
				Return
			Else
				ii_data[1] = 1
			End If
		Else
			If is_data[2] = ls_reqnum_dw Then
				ii_data[1] = 2
			Else
				ii_data[1] = 3
			End If
		End If

		ll_rows = idw_data[1].RowCount()
		For ll_row = 1 To ll_rows
			ldwis_row = idw_data[1].GetItemStatus(ll_row, 0, Primary!)
			If Not(ldwis_row = New! Or ldwis_row = NewModified!) Then Continue

			//필수항목확인
			//거래코드/거래금액 : 입금거래면 입금일자도 필수
			ls_trcod = Trim(idw_data[1].Object.trcod[ll_row])
			lc_tramt = idw_data[1].Object.tramt[ll_row]
			If IsNull(ls_trcod) Then ls_trcod = ""
			If IsNull(lc_tramt) Then lc_tramt = 0

			If ls_trcod = "" Then
				f_msg_usr_err(200, is_title, "거래코드")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("trcod")
				Return
			End If
			ls_paydt = Trim(idw_data[1].Object.paydt[ll_row])
			If IsNull(ls_paydt) Then ls_paydt = ""
			If ls_paydt = "" Then
				f_msg_usr_err(200, is_title, "거래일자")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("paydt")
				Return
			Else
				ls_date = MidA(ls_paydt, 1, 4) + "-" + MidA(ls_paydt, 5, 2) + "-" + MidA(ls_paydt, 7, 2)
				If Not IsDate(ls_date) Then
					f_msg_usr_err(210, is_title, "거래일자")
					idw_data[1].SetRow(ll_row)
					idw_data[1].SetColumn("paydt")
					Return
				End If
			End If
			If lc_tramt = 0 Then
				f_msg_usr_err(200, is_title, "거래금액")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("tramt")
				Return
			End If

			//거래코드가 입금/수수료발생여부 인지 확인
			SELECT nvl(in_yn, ''), nvl(salesyn, ''), nvl(useryn,''), nvl(extraflag, '')
			INTO :ls_yn, :ls_salesyn, :ls_useryn, :ls_extraflag
			FROM TRCODE WHERE trcod = :ls_trcod;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":TRCODE.TRCOD")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("trcod")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_usr_err(201, is_title, "거래코드에 대한 정보가 없습니다.(" + ls_trcod + ")")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("trcod")
				Return
			End If
			
			If ls_extraflag = "Y" Then
				f_msg_info(9000, is_title, "입력 하신 거래는 수동 등록 하실 수 없습니다.(" + ls_trcod + ")")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("trcod")
				Return
			End If
				
			If Upper(ls_yn) = "Y" Then
				//입금 거래코드인 경우
				ls_transdt = Trim(idw_data[1].Object.transdt[ll_row])
				If IsNull(ls_transdt) Then ls_transdt = ""
				If ls_transdt = "" Then
					f_msg_usr_err(200, is_title, "이체일자")
					idw_data[1].SetRow(ll_row)
					idw_data[1].SetColumn("transdt")
					Return
				Else
					ls_date = MidA(ls_transdt, 1, 4) + "-" + MidA(ls_transdt, 5, 2) + "-" + MidA(ls_transdt, 7, 2)
					If Not IsDate(ls_date) Then
						f_msg_usr_err(210, is_title, "이체일자")
						idw_data[1].SetRow(ll_row)
						idw_data[1].SetColumn("transdt")
						Return
					End If
				End If
				
			Else
				//입금 거래코드가 아닌 경우
				If ii_data[1] = 3 Then
					f_msg_usr_err(9000, is_title, "당월전의 청구번호에 대해서는 입금 거래만 추가할 수 있습니다.")
					idw_data[1].SetRow(ll_row)
					idw_data[1].SetColumn("trcod")
					Return
				End If
			End If
			
			// userid 별로 생성 되는 거래코드
			ls_userid = Trim(idw_data[1].Object.userid[ll_row])
			If IsNull(ls_userid) Then ls_userid = ""
			If Upper(ls_useryn) = "Y" And ls_userid = "" Then
				f_msg_usr_err(200, is_title, "가입자 고객")
				idw_data[1].SetRow(ll_row)
				idw_data[1].SetColumn("userid")
				Return
			End If			
			
		Next

		If ii_data[1] = 1 Then
			//SYSCTL1T의 청구주기 Control Read
			ls_module = "B5"
			ls_ref_no = "C101"
			ls_ref_desc = ""
			ls_reqnum_dw = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

			//신규당월청구번호
			If Dec(ls_reqnum_dw) >= 9999999 Then
				f_msg_usr_err(9000, is_title, "더 이상 청구번호를 생성 할 수 없습니다.~r~n관리자에게 문의 바랍니다.")
				Return
			End If
		
			ls_reqnum_dw = fs_fill_zeroes(String(Dec(ls_reqnum_dw) + 1), -7)
			//ls_reqdt_dw는 위에서 구한것을 그냥 사용
		Else
			SELECT nvl(max(trdt), '') INTO :ls_trdt FROM REQDTL WHERE reqnum = :is_data[2];
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":REQDTL.TRDT")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				ls_trdt = ls_reqdt_dw
			End If

			ls_reqnum_dw = is_data[2]
			ls_reqdt_dw = ls_trdt
		End If

		SELECT nvl(max(seq), 0) INTO :lc0_seq FROM REQDTL WHERE reqnum = :is_data[2];
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + ":REQDTL.SEQ")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			lc0_seq = 0
		End If

		//확인한 정보
		is_data2[1] = ls_reqnum_dw
		is_data2[2] = ls_reqdt_dw
		ic_data[1] = lc0_seq
		
	Case "b5w_reg_mtr_by_payid%2"
		// WINDOW : b5w_reg_mtr_by_payid.ue_extra_delete
		// 작성자 : 1999년 11월 25일 오충환 T&C Technology
		// 목  적 : 수동거래등록-삭제조건(당월이전청구는 입금인경우만삭제가능)
		// 인  자 : is_title = This.Title
		// 		   is_caller = "b5w_reg_mtr_by_payid%2"
		//				is_data[1] = ls_trcod
		//				is_data[2] = ls_payid
		//				is_data[3] = ls_trdt
		
		ls_trcod = is_data[1]
		ls_payid = is_data[2]
		ls_trdt  = MidA(is_data[3], 1,6)
		
		// 청구이전월인지 확인  
		SELECT add_months(to_date(reqdt,'yyyymmdd'),-1) INTO :ldt_reqdt 
		FROM reqconf 
		WHERE chargedt = ( SELECT chargedt FROM paymst WHERE payid = :ls_payid);
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + ":reqconf.reqdt")
			Return
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_usr_err(201, is_title, "청구년월에 대한 정보가 없습니다.(" + ls_payid + ")")
			Return
		End If
		ls_reqdt = String(ldt_reqdt, "yyyymm") 
		If ls_trdt < ls_reqdt Then
			//거래코드가 입금인지 확인
			SELECT nvl(in_yn, '') INTO :ls_yn FROM TRCODE WHERE trcod = :ls_trcod;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + ":TRCODE.TRCOD")
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_usr_err(201, is_title, "거래코드에 대한 정보가 없습니다.(" + ls_trcod + ")")
				Return
			End If
			If Upper(ls_yn) = "N" Then
				//입금 거래코드가 아닌 경우
				f_msg_usr_err(9000, is_title, "당월전의 청구번호에 대해서는 입금 거래만 삭제할 수 있습니다.")
				Return
			End If
		End If
	
	Case "REQPGM COUNT"
		// WINDOW : b5w_prc_reqpgm.wf_settargetterm
		// 작성자 : 1999년 11월 25일 오충환 T&C Technology
		// 목  적 : REQPGM close_yn = 'Y' 건수
		// 인  자 : is_title = This.Title
		// 		   is_caller = "REQPGM COUNT"
		//				is_data[1] = ls_chargedt
		// RETURN : ii_data[1]   
		ls_chargedt = is_data[1]
		
		SELECT count(*) 
		INTO :ii_data[1]
		FROM   reqpgm
		WHERE  upper(close_yn) = 'Y'
		AND  chargedt = :ls_chargedt;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller)
			Return
		End If


//**** kEnn : 2002-10-01 ******************************************************
	Case "b5w_reg_trprtc%1"
		// WINDOW : b5w_reg_trprtc
		// 작성자 : kEnn 2002-09-28
		// 목  적 : 항목 검사(필수)
		// 인  자 : idw_data[1] = dw_detail

		//항목 Check
		ls_sort = "bilseq, bilcod desc"
		idw_data[1].SetSort(ls_sort)
		idw_data[1].Sort()
		
		ls_old1 = ""
		li_old1 = 0
		li_old2 = 0
		ll_rows = idw_data[1].RowCount()
		For ll_row = 1 To ll_rows
			ls_bilcod = Trim(idw_data[1].Object.bilcod[ll_row])
			ls_bilcodnm = Trim(idw_data[1].Object.bilcodnm[ll_row])
			li_bilseq = idw_data[1].Object.bilseq[ll_row]
			If IsNull(ls_bilcod) Then ls_bilcod= ""
			If IsNull(ls_bilcodnm) Then ls_bilcodnm = ""
			If IsNull(li_bilseq) Then li_bilseq = 0

			//필수검사
			If ls_bilcod = "" Then
				f_msg_usr_err(200, is_title, "청구서항목코드")
				idw_data[1].SetColumn("bilcod")
				Return
			End If

			If ls_bilcodnm = "" Then
				f_msg_usr_err(200, is_title, "청구서항목명")
				idw_data[1].SetColumn("bilcodnm")
				Return
			End If

			If li_bilseq = 0 Then
				f_msg_usr_err(200, is_title, "출력순서")
				idw_data[1].SetColumn("bilseq")
				Return
			End If

//			If li_bilseq <> 0 Then
//				If li_bilseq > 30 Or li_bilseq < 0 Then
//					f_msg_usr_err(201, is_title, "출력번호(유효범위)")
//					idw_data[1].SetColumn("bilseq")
//					Return
//				End If
//			End If

			//기타검사
			If li_old2 = li_bilseq Then
				f_msg_usr_err(201, is_title, "청구서항목과 출력순서는 1:1 관계입니다.")
				Return
			End If

			//업데이트 처리
			IF idw_data[1].GetItemStatus(ll_row,0,Primary!) = DataModified! THEN
				idw_data[1].Object.updt_user[ll_row]	= gs_user_id
				idw_data[1].Object.updtdt[ll_row]		= fdt_get_dbserver_now()
				idw_data[1].Object.pgm_id[ll_row]		= gs_pgm_id[gi_open_win_no]
			END IF

			//save before row infomation
			li_old2 = li_bilseq
		Next

//**** islim : 2004-08-25******************************************************
	Case "b5w_reg_inv_item_seq%1"
		// WINDOW : b5w_reg_inv_item_seq
		// 작성자 : islim 2004-08-25
		// 목  적 : 항목 검사(필수)
		// 인  자 : idw_data[1] = dw_detail

		//항목 Check
		ls_sort = "bilseq, bilcod desc"
		idw_data[1].SetSort(ls_sort)
		idw_data[1].Sort()
		
		ls_old1 = ""
		li_old1 = 0
		li_old2 = 0
		ll_rows = idw_data[1].RowCount()
		For ll_row = 1 To ll_rows
			ls_bilcod = Trim(idw_data[1].Object.bilcod[ll_row])
			li_bilseq = idw_data[1].Object.bilseq[ll_row]
			If IsNull(ls_bilcod) Then ls_bilcod= ""
			If IsNull(li_bilseq) Then li_bilseq = 0

			//필수검사
			If ls_bilcod = "" Then
				f_msg_usr_err(200, is_title, "청구서항목코드")
				idw_data[1].SetColumn("bilcod")
				Return
			End If

			If li_bilseq = 0 Then
				f_msg_usr_err(200, is_title, "출력순서")
				idw_data[1].SetColumn("bilseq")
				Return
			End If

//			If li_bilseq <> 0 Then
//				If li_bilseq > 30 Or li_bilseq < 0 Then
//					f_msg_usr_err(201, is_title, "출력번호(유효범위)")
//					idw_data[1].SetColumn("bilseq")
//					Return
//				End If
//			End If

			//기타검사
			If li_old2 = li_bilseq Then
				f_msg_usr_err(201, is_title, "청구서항목과 출력순서는 1:1 관계입니다.")
				Return
			End If

			//업데이트 처리
			IF idw_data[1].GetItemStatus(ll_row,0,Primary!) = DataModified! THEN
				idw_data[1].Object.updt_user[ll_row]	= gs_user_id
				idw_data[1].Object.updtdt[ll_row]		= fdt_get_dbserver_now()
				idw_data[1].Object.pgm_id[ll_row]		= gs_pgm_id[gi_open_win_no]
			END IF

			//save before row infomation
			li_old2 = li_bilseq
		Next
	Case Else
		f_msg_info_app(9000, "b5u_check.uf_prc_check()", &
							"Matching statement Not found.(" + String(is_caller) + ")")
End Choose

ii_rc = 0

end subroutine

on b5u_check.create
call super::create
end on

on b5u_check.destroy
call super::destroy
end on

