$PBExportHeader$b1u_check.sru
$PBExportComments$[ceusee] Check Object
forward
global type b1u_check from u_cust_a_check
end type
end forward

global type b1u_check from u_cust_a_check
end type
global b1u_check b1u_check

type variables

end variables

forward prototypes
public function integer uf_prc_date_range (string as_old_start, string as_old_end, string as_start, string as_end)
public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt)
public subroutine uf_prc_check_10 ()
public subroutine uf_prc_check_9 ()
public subroutine uf_prc_check_4 ()
public subroutine uf_prc_check_1 ()
public subroutine uf_prc_check_2 ()
public subroutine uf_prc_check_06 ()
public subroutine uf_prc_check ()
public subroutine uf_prc_check_11 ()
end prototypes

public function integer uf_prc_date_range (string as_old_start, string as_old_end, string as_start, string as_end);/*-------------------------------------------------------------------------
	name	: uf_prc_date_range()
	desc.	: 날짜의  범위가 곂치지 않게 하기 위해
	ver.	: 1.0
	arg.	: string
				- as_old_start : 기준 시작 날짜
				- as_old_end : 기준 종료 날짜
				- as_start : 시작 날짜
				- as_end   : 종료 되는 날짜
				
	return  : integer
				 - -1 실패  시작
				 - -2 실패 	끝 
				 -  0 성공
	date 	: 2002.09.29
	programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
if as_start = "" Then Return -1
If as_end = "" Then as_end = "29991231"		//임의 의 값 
If as_old_end = "" Then as_old_end = "29991231"

 
If ( as_old_start <= as_start and as_old_end >= as_start ) Or &
( as_old_start <= as_end   and as_old_end >= as_end )Then Return -1
Return 0
end function

public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt);
/*------------------------------------------------------------------------
	Name	:	ufi_other_validinfo
	Desc	:	같은 기간에 다른 고객과 인증 key가 겹치면 안된다.
	Arg.	:	string as_customerid
				string as_fromdt	as_todt
	Reg.	:  0 성공
				-1 중복 있음
				-2 Error
--------------------------------------------------------------------------*/
String ls_other_fromdt, ls_other_todt
Integer li_return

DECLARE validinfo CURSOR FOR
Select to_char(fromdt, 'yyyymmdd'), to_char(todt, 'yyyymmdd')
From validinfo
Where customerid <> :as_customerid and validkey = :as_validkey;

OPEN validinfo;
Do While(True)
	FETCH validinfo
	INTO :ls_other_fromdt, :ls_other_todt;
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_title, "Cursor validinfo")
		CLOSE validinfo;
		Return -2
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	li_return = uf_prc_date_range(ls_other_fromdt, ls_other_todt, as_fromdt, as_todt)
	If li_return = - 1 Then
		CLOSE validinfo;
		Return -1
	End If	
	
Loop
CLOSE validinfo;
	

Return 0 
end function

public subroutine uf_prc_check_10 ();//SAVE check
Long ll_row, ll_rows, ll_findrow, i
long ll_i, ll_zoncodcnt
String ls_zoncod, ls_tmcod, ls_opendt, ls_frpoint, ls_areanum, ls_priceplan, ls_parttype, ls_itemcod
String ls_date, ls_sort
Dec lc_data, lc_frpoint, lc_Ofrpoint

String ls_filter, ls_Ozoncod, ls_Otmcod, ls_Oopendt
Integer li_i, li_tmcodcnt, li_return, li_rtmcnt, li_cnt_tmkind
String ls_tmcodX, ls_tmkind[100,2], ls_arezoncod[]
Boolean lb_addX, lb_notExist
Constant Integer li_MAXTMKIND = 3

ii_rc = -1
Choose Case is_caller
   Case "b1w_reg_customer%save_tab10"
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		
		For i = 1  To ll_row
			ls_zoncod   = Trim(idw_data[1].object.zoncod[i])
			ls_opendt   = String(idw_data[1].object.opendt[i])
			ls_tmcod    = Trim(idw_data[1].object.tmcod[i])
			ls_frpoint  = String(idw_data[1].object.frpoint[i])
			ls_areanum  = Trim(idw_data[1].object.areanum[i])
			ls_itemcod  = String(idw_data[1].object.itemcod[i])
			
			
			If IsNull(ls_zoncod) Then ls_zoncod = ""
			If IsNull(ls_opendt) Then ls_opendt = ""
			If IsNull(ls_tmcod) Then ls_tmcod = ""
			If IsNull(ls_frpoint) Then ls_frpoint = ""
			If IsNull(ls_areanum) Then ls_areanum = ""
			If IsNull(ls_itemcod) Then ls_itemcod = ""
						
			If ls_zoncod = "" Then
				f_msg_usr_err(200, is_title, "대역")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("countrycod")
				ii_rc  = -2
				Return
			ElseIf ls_zoncod = "ALL" Then
				If ls_areanum = "" Then
					f_msg_usr_err(200, is_title, "대역이 ALL일 경우 착신지번호 필수입력")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("areanum")
					ii_rc  = -2
					Return
				End If
			End If
			
			If ls_opendt = ""  Then
				f_msg_usr_err(200, is_title, "적용개시일")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("opendt")
				ii_rc  = -2
				Return
			End If
			
			If ls_tmcod = "" Then
				f_msg_usr_err(200, is_title, "시간대")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("tmcod")
				ii_rc  = -2
				Return
			End If
			
			If ls_frpoint = "" Then
				f_msg_usr_err(200, is_title, "사용범위")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("frpoint")
				ii_rc  = -2
				Return
			End If
			
			If ls_areanum = "" Then
				f_msg_usr_err(200, is_title, "착신지번호")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("areanum")
				ii_rc  = -2
				Return
			Else
				If ls_areanum = "ALL" Then
					If ls_zoncod = "ALL" Then
						f_msg_usr_err(200, is_title, "착신지번호가 ALL이면 대역은 ALL을 허용하지 않는다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("areanum")
						ii_rc  = -2
						Return
					End If
				Else
					If ls_zoncod <> "ALL" Then
						f_msg_usr_err(200, is_title, "착신지번호가 ALL이 아니면 대역은 ALL 이어야 한다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("areanum")
						ii_rc  = -2
						Return
					End If
				End If
			End If
			
			If ls_itemcod = "" Then
				f_msg_usr_err(200, is_title, "품목")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("itemcod")
				ii_rc  = -2
				Return
			End If
			
			If idw_data[1].object.unitsec[i] = 0 Then
				f_msg_usr_err(200, is_title, "기본시간")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("unitsec")
				ii_rc  = -2
				Return
			End If
			
			If idw_data[1].object.unitfee[i] < 0 Then
				f_msg_usr_err(200, is_title, "기본료")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("unitfee")
				ii_rc  = -2
				Return
			End If
			
			If idw_data[1].object.munitsec[i] = 0 Then
				f_msg_usr_err(200, is_title, "기본시간(멘트)")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("munitsec")
				idw_data[1].Object.DataWindow.HorizontalScrollPosition='10000'
				ii_rc  = -2
				Return
			End If
			
			If idw_data[1].object.munitfee[i] < 0 Then
				f_msg_usr_err(200, is_title, "기본료(멘트)")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("munitfee")
				idw_data[1].Object.DataWindow.HorizontalScrollPosition='10000'
				ii_rc  = -2
				Return
			End If
			
	Next
	
End Choose

ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_check_9 ();Long ll_row, i, j, ll_date_range
String ls_countrycod, ls_dcrate, ls_fromdt, ls_todt


ii_rc = -1
Choose Case is_caller
   Case "b1w_reg_customer%save_tab9"
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		
		For i = 1  To ll_row
			ls_countrycod = Trim(idw_data[1].object.countrycod[i])
			ls_fromdt = String(idw_data[1].object.fromdt[i],'yyyymmdd')
			ls_todt = String(idw_data[1].object.todt[i],'yyyymmdd')
			ls_dcrate = String(idw_data[1].object.dcrate[i])
			If IsNull(ls_countrycod) Then ls_countrycod = ""
			If IsNull(ls_fromdt) Then ls_fromdt = ""
			If IsNull(ls_dcrate) Then ls_dcrate = ""
			
			If ls_countrycod = "" Then
				f_msg_usr_err(200, is_title, "국가")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("countrycod")
				ii_rc  = -2
				Return
			End If
			
			If ls_dcrate = ""  Then
				f_msg_usr_err(200, is_title, "D/C백분율")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("dcrate")
				ii_rc  = -2
				Return
			End If
			
			If ls_fromdt = "" Then
				f_msg_usr_err(200, is_title, "적용개시일")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("fromdt")
				ii_rc  = -2
				Return
			End If
		Next
End Choose

ii_rc = 0
Return 
end subroutine

public subroutine uf_prc_check_4 ();Long ll_hwseq, ll_row, i, ll_cnt, ll_valid_cnt
String ls_adtype, ls_sale_flag, ls_seq
String ls_validkey, ls_serialno


ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_customer%new_hw"
		Select seq_adseq.nextval
		Into :ll_hwseq
		From dual;
		ll_row = il_data[1]
	   idw_data[1].object.hwseq[ll_row] = ll_hwseq
   Case "b1w_reg_customer%save_tab4"
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		For i = 1 To ll_row
			ls_adtype = Trim(idw_data[1].object.adtype[1])
			ls_sale_flag = Trim(idw_data[1].object.sale_flag[1])
			If IsNull(ls_adtype) Then ls_adtype = ""
			If IsNull(ls_sale_flag) Then ls_sale_flag = ""
			
			If ls_adtype = "" Then
				f_msg_usr_err(200, is_title, "H/W 구분")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("adtype")
				ii_rc = -2
				Return 
			End If
			
			If ls_sale_flag = "" Then
				f_msg_usr_err(200, is_title, "판매/임대 구분")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("sale_flag")
				ii_rc = -2
				Return 
			End If
			
			ls_seq = String(idw_data[1].object.hwseq[i])
			If IsNull(ls_seq) Then ls_seq = ""
			
			If ls_seq = "" Then
				Select seq_customerhwno.nextval
				Into :ll_hwseq
				From dual;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "Sequence Error")
					RollBack;
					Return 
				End If				
				idw_data[1].object.hwseq[i] = ll_hwseq
			End If
			
	 Next
	 
	 Case "b1w_reg_customer_d_aun%save_tab4"
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		For i = 1 To ll_row
			ls_adtype = Trim(idw_data[1].object.adtype[i])
			ls_sale_flag = Trim(idw_data[1].object.sale_flag[i])
			If IsNull(ls_adtype) Then ls_adtype = ""
			If IsNull(ls_sale_flag) Then ls_sale_flag = ""
			
			If ls_adtype = "" Then
				f_msg_usr_err(200, is_title, "H/W 구분")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("adtype")
				ii_rc = -2
				Return 
			End If
			
			If ls_sale_flag = "" Then
				f_msg_usr_err(200, is_title, "판매/임대 구분")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("sale_flag")
				ii_rc = -2
				Return 
			End If
			
			ls_seq = String(idw_data[1].object.hwseq[i])
			If IsNull(ls_seq) Then ls_seq = ""
			
			If ls_seq = "" Then
				Select seq_customerhwno.nextval
				Into :ll_hwseq
				From dual;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "Sequence Error")
					RollBack;
					Return 
				End If				
				idw_data[1].object.hwseq[i] = ll_hwseq
			End If
			
		
			ls_serialno = Trim(idw_data[1].Object.serialno[i])
			
			SELECT COUNT(*), NVL(REMARK, 'NULL')
			INTO   :ll_cnt, :ls_validkey
			FROM   CUSTOMER_HW
			WHERE  SERIALNO = :ls_serialno
			GROUP BY REMARK;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_caller, "SELECT ERROR (CUSTOMER_HW)")
				RollBack;
				Return 
			End If
			
			If ll_cnt > 0 Then
				
				If ls_validkey <> 'NULL' Then
					
					SELECT COUNT(*)
					INTO   :ll_valid_cnt
					FROM   VALIDINFO
					WHERE  ( (TO_CHAR(FROMDT,'YYYYMMDD') > TO_CHAR(SYSDATE,'YYYYMMDD') )
					OR	    ( TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
					AND     TO_CHAR(SYSDATE,'YYYYMMDD') < NVL(TO_CHAR(TODT,'YYYYMMDD'),'99991231')) )
					AND     VALIDKEY = :ls_validkey;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_caller, "SELECT ERROR (VALIDINFO)")
						RollBack;
						Return 
					End If
					
					If ll_valid_cnt > 0 Then
						f_msg_usr_err(9000, is_title, '인증Key : ' + ls_validkey + '로 Serial No 가 중복됩니다.')
						RollBack;
						Return
					End If
					
				End If
				
			End If
			
	 Next
		
	
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_check_1 ();
//"b1w_reg_customer%save_tab2"
String ls_receiptcod, ls_receiptdt, ls_resultcod, ls_card_type, ls_card_no, ls_card_expdt
String ls_card_holder, ls_card_ssno, ls_card_renark1, ls_bill_cycle, ls_bill_zipcod
String ls_inv_yn, ls_inv_method, ls_pay_method, ls_bill_addr2, ls_bill_addr1, ls_card_remark1
String ls_bank, ls_acctno, ls_acct_owner, ls_acct_ssno, ls_drawingreqdt
String ls_bil_email, ls_taxtype, ls_ctype2, ls_currency_type
boolean lb_check1, lb_check2

String ls_drawingtype[], ls_drawingresult[], ls_ref_desc, ls_temp, ls_name[]
string ls_drawing_type, ls_drawing_result, ls_edi_drawingtype[]

Integer li_count

ii_rc = -2
Choose Case is_caller
	Case "b1w_reg_customer%save_tab2"


		ls_bill_cycle = Trim(idw_data[1].object.bilcycle[1])
		ls_inv_yn = Trim(idw_data[1].object.inv_yn[1])
		ls_inv_method = Trim(idw_data[1].object.inv_method[1])
		ls_pay_method = Trim(idw_data[1].object.pay_method[1])
		ls_bill_zipcod = Trim(idw_data[1].object.bil_zipcod[1])
		ls_bill_addr1 = Trim(idw_data[1].object.bil_addr1[1])
		ls_bill_addr2 = Trim(idw_data[1].object.bil_addr2[1])
		ls_taxtype = Trim(idw_data[1].object.taxtype[1])
		ls_currency_type = Trim(idw_data[1].object.billinginfo_currency_type[1])
	
		If IsNull(ls_inv_yn) Then ls_inv_yn = ""
		If IsNull(ls_inv_method) Then ls_inv_method = ""
		If IsNull(ls_pay_method) Then ls_pay_method = ""
		If IsNull(ls_bill_zipcod) Then ls_bill_zipcod = ""
		If IsNull(ls_bill_addr1) Then ls_bill_addr1 = ""
		If IsNull(ls_bill_addr2) Then ls_bill_addr2 = ""
		If IsNull(ls_bill_cycle) then ls_bill_cycle = ""
		If IsNull(ls_taxtype) then ls_taxtype = ""	
		If IsNull(ls_currency_type) Then ls_currency_type = ""
				
		//필수 Check
		If  ls_bill_cycle= "" Then
			f_msg_usr_err(200, is_title, "청구주기")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bilcycle")
			Return 
		End If
		
		If ls_inv_yn = "" Then
			f_msg_usr_err(200, is_title, "청구서발송여부")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("inv_yn")
			Return 
		End If
			
		If ls_inv_method = "" Then
			f_msg_usr_err(200, is_title, "청구서발송방법")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("inv_method")
			Return 
		End If
		
		//화폐 단위
		If ls_currency_type = "" Then
			f_msg_usr_err(200, is_title, "통화 유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("billinginfo_currency_type")
			Return
		End If
		
		If ls_pay_method = "" Then
			f_msg_usr_err(200, is_title, "결제방법")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("pay_method")
			Return 
		End If
		
		If ls_taxtype = "" Then
			f_msg_usr_err(200, is_title, "TAX적용유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("taxtype")
			Return 
		End If
		
		//청구서 발송 방법이 email 이면
		If ls_inv_method = is_data[3] Then
			ls_bil_email = Trim(idw_data[1].object.bil_email[1])
			If IsNull(ls_bil_email) Then ls_bil_email = ""
			If ls_bil_email = "" Then
				f_msg_usr_err(200, is_title, "청구 Email")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("bil_email")
				Return 
			End If
			
			If pos(ls_bil_email, "@") = 0 Then
					f_msg_info(100, is_title, "청구 Email")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("bil_email")
				   Return 
			End If
		End If
		
		If ls_bill_zipcod = "" Then
			f_msg_usr_err(200, is_title, "우편번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_zipcod")
			Return 
		End If
		
		If ls_bill_addr1 = "" Then
			f_msg_usr_err(200, is_title, "주소 1")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_addr1")
			Return 
		End If
		
		If ls_bill_addr2 = "" Then
			f_msg_usr_err(200, is_title, "주소 2")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_addr2")
			Return 
		End If

	    //자동이체
		If is_data[1] = Trim(idw_data[1].object.pay_method[1]) Then
			ls_bank = Trim(idw_data[1].object.bank[1])
			ls_acctno = Trim(idw_data[1].object.acctno[1])
			ls_acct_owner = Trim(idw_data[1].object.acct_owner[1]) 
			ls_acct_ssno = Trim(idw_data[1].object.acct_ssno[1])
			If IsNull(ls_bank) Then ls_bank = ""
			If IsNull(ls_acctno) Then ls_acctno = ""
			If IsNull(ls_acct_owner) Then ls_acct_owner = ""
			If IsNull(ls_acct_ssno) Then ls_acct_ssno = ""
			
			If ls_bank = "" Then
				f_msg_usr_err(200, is_title, "은행")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("bank")
				Return 
			End If
			
			If ls_acctno = "" Then
				f_msg_usr_err(200, is_title, "계좌번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acctno")
				Return 
			End If
			
			If ls_acct_owner = "" Then
				f_msg_usr_err(200, is_title, "예금주명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acct_owner")
				Return 
			End If
			
			If ls_acct_ssno = "" Then
				f_msg_usr_err(200, is_title, "예금주 주민번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acct_ssno")
				Return 
			End If
			

			
		End If
		
		//신용카드
		If is_data[2] = Trim(idw_data[1].object.pay_method[1]) Then
			ls_card_type = Trim(idw_data[1].object.card_type[1])
			ls_card_no = Trim(idw_data[1].object.card_no[1])
			ls_card_expdt = String(idw_data[1].object.card_expdt[1],'yyyymmdd')
			ls_card_holder = Trim(idw_data[1].object.card_holder[1])
			ls_card_ssno = Trim(idw_data[1].object.card_ssno[1])
			ls_card_remark1 = Trim(idw_data[1].object.card_remark1[1])
			If IsNull(ls_card_type) Then ls_card_type = ""
			If IsNull(ls_card_no) Then ls_card_no = ""
			If IsNull(ls_card_expdt) Then ls_card_expdt = ""
			If IsNull(ls_card_holder) Then ls_card_holder = ""
			If IsNull(ls_card_ssno) Then ls_card_ssno = ""
			If IsNull(ls_card_remark1) Then ls_card_remark1 = ""
			
			If ls_card_type = "" Then
				f_msg_usr_err(200, is_title, "신용카드 종류")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_type")
				Return 
			End If
			
			If ls_card_no = "" Then
				f_msg_usr_err(200, is_title, "신용카드 번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_no")
				Return 
			End If
			
			If ls_card_expdt = "" Then
				f_msg_usr_err(200, is_title, "신용카드 유효기간")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_expdt")
				Return 
			End If
			
			If ls_card_holder = "" Then
				f_msg_usr_err(200, is_title, "카드회원명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_holder")
				Return 
			End If
			
			If ls_card_ssno = "" Then
				f_msg_usr_err(200, is_title, "카드회원 주민번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_ssno")
				Return 
			End If
			
			If ls_card_remark1 = "" Then
				f_msg_usr_err(200, is_title, "신용카드유형")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_remark1")
				Return 
			End If
		End If

	Case "b1w_reg_customer%inq_customer_tab2"
		
		idw_data[1].Setredraw(False)
		
		
		//합산 청구지 정보 Check 2004.03.06 C.bora Modify
		Select count(*) into :li_count from syscod2t where grcode = 'B320' and use_yn = 'Y';
		
		If li_count > 0 Then
			idw_data[1].Object.adding_type.visible = True
			idw_data[1].Object.adding_key.visible = True
			idw_data[1].Object.adding_type_t.visible = True
			idw_data[1].Object.adding_key_t.visible = True
	   Else
			idw_data[1].Object.adding_type_t.visible = False
			idw_data[1].Object.adding_key_t.visible = False
			idw_data[1].Object.adding_type.visible = False
			idw_data[1].Object.adding_key.visible = False
		End If
		
		
		//출금이체 신청유형(1.없음(0);2.신규(1);3.변경(2);4.해지(3);5.임의해지(7))
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingtype[])
		
		//EDI은행신청유형(1.신규(01);2.변경(05);3.변경(임의)(07);4.해지(03);5.해지(임의)(04))
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A608", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_edi_drawingtype[])
		
		//출금이체 신청결과(1.없음(0);2.신청(1);3.처리중(2);4.처리성공(S);5.처리실패(F))
		ls_ref_desc = ""
		ls_temp = ""
		ls_temp = fs_get_control("B7", "A330", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingresult[])
		
		//자동이체 처리 쪽  user 수정 불가 - Display column
		idw_data[1].Object.drawingreqdt.Color = RGB(0, 0, 0)		
		idw_data[1].Object.drawingreqdt.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.drawingtype.Color = RGB(0, 0, 0)		
		idw_data[1].Object.drawingtype.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.drawingresult.Color = RGB(0, 0, 0)		
		idw_data[1].Object.drawingresult.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.receiptcod.Color = RGB(0, 0, 0)		
		idw_data[1].Object.receiptcod.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.receiptdt.Color = RGB(0, 0, 0)		
		idw_data[1].Object.receiptdt.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.resultcod.Color = RGB(0, 0, 0)		
		idw_data[1].Object.resultcod.Background.Color = RGB(255, 251, 240)
		idw_data[1].Object.drawingreqdt.Protect =1
		idw_data[1].Object.drawingtype.Protect = 1
		idw_data[1].Object.drawingresult.Protect =1
		idw_data[1].Object.receiptcod.Protect =1
		idw_data[1].Object.receiptdt.Protect =1
		idw_data[1].Object.resultcod.Protect =1
		
		//결제정보 변경여부
		If	is_data[4] = 'N' Then 		//수정불가
			idw_data[1].Object.pay_method.Color = RGB(0, 0, 0)		
			idw_data[1].Object.pay_method.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.pay_method.Protect = 1
		Else      			//수정가능
		 	idw_data[1].Object.pay_method.Color = RGB(255, 255, 255)			
			idw_data[1].Object.pay_method.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.pay_method.Protect = 0
		End If
			
		If is_data[2] = Trim(idw_data[1].object.pay_method[1]) Then		//신용카드 결제
			idw_data[1].Object.card_type.Color = RGB(255, 255, 255)		
			idw_data[1].Object.card_type.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_no.Color = RGB(255, 255, 255)		
			idw_data[1].Object.card_no.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_expdt.Color = RGB(255, 255, 255)		
			idw_data[1].Object.card_expdt.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_holder.Color = RGB(255, 255, 255)		
			idw_data[1].Object.card_holder.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_ssno.Color = RGB(255, 255, 255)		
			idw_data[1].Object.card_ssno.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_remark1.Color = RGB(255, 255, 255)	
			idw_data[1].Object.card_remark1.Background.Color = RGB(108, 147, 137)
			idw_data[1].Object.card_type.Protect = 0
			idw_data[1].Object.card_no.Protect = 0
			idw_data[1].Object.card_expdt.Protect = 0
			idw_data[1].Object.card_holder.Protect = 0
			idw_data[1].Object.card_ssno.Protect = 0
			idw_data[1].Object.card_remark1.Protect = 0
			idw_data[1].Object.creditreqdt.Protect = 0
			idw_data[1].Object.creditreqdt.Color = RGB(0,0,0)	
			idw_data[1].Object.creditreqdt.Background.Color = RGB(255, 255, 255)
			idw_data[1].Object.card_authyn.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_authyn.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_group1.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_group1.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_authyn.Protect = 1
			idw_data[1].Object.card_group1.Protect = 1
		Else 			//신용카드가 아닐경우
			idw_data[1].Object.card_type.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_type.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_no.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_no.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_expdt.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_expdt.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_holder.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_holder.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_ssno.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_ssno.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_remark1.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_remark1.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_authyn.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_authyn.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.card_group1.Color = RGB(0, 0, 0)		
			idw_data[1].Object.card_group1.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.creditreqdt.Color = RGB(0, 0, 0)		
			idw_data[1].Object.creditreqdt.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.creditreqdt.Protect = 1
			idw_data[1].Object.card_type.Protect = 1
			idw_data[1].Object.card_no.Protect = 1
			idw_data[1].Object.card_expdt.Protect = 1
			idw_data[1].Object.card_holder.Protect = 1
			idw_data[1].Object.card_ssno.Protect = 1
			idw_data[1].Object.card_remark1.Protect = 1
			idw_data[1].Object.card_authyn.Protect = 1
			idw_data[1].Object.card_group1.Protect = 1
		End If
		
		//자동이체일경우 
		If is_data[1] = Trim(idw_data[1].object.pay_method[1]) Then
			
			ls_drawing_type = idw_data[1].Object.drawingtype[1]
			ls_drawing_result = idw_data[1].Object.drawingresult[1] 
		
			//신청결과 =미처리 & 신청유형 <> 변경
			If ( ls_drawing_result = ls_drawingresult[2] ) and &
				 ls_drawing_type <> ls_drawingtype[3] Then
			
				idw_data[1].Object.bank.Color = RGB(255, 255, 255)		
				idw_data[1].Object.bank.Background.Color = RGB(108, 147, 137)
				idw_data[1].Object.acctno.Color = RGB(255, 255, 255)		
				idw_data[1].Object.acctno.Background.Color = RGB(108, 147, 137)
				idw_data[1].Object.acct_owner.Color = RGB(255, 255, 255)	
				idw_data[1].Object.acct_owner.Background.Color = RGB(108, 147, 137)
				idw_data[1].Object.acct_ssno.Color = RGB(255, 255, 255)
				idw_data[1].Object.acct_ssno.Background.Color = RGB(108, 147, 137)
				idw_data[1].Object.bank_chg.Color = RGB(0, 0, 0)		
				idw_data[1].Object.bank_chg.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.bank.Protect = 0
				idw_data[1].Object.acctno.Protect = 0
				idw_data[1].Object.drawingresult.Protect =0
				idw_data[1].Object.acct_owner.Protect =0
				idw_data[1].Object.acct_ssno.Protect =0
				idw_data[1].Object.bank_chg.Protect =1		

     		  //( 신청결과 = 성공 &, 신청유형 = 신규,변경,edi신규,edi변경,edi변경(임의) )   // EDI 신청유형추가...
			  //     or ( 신청유형 = 변경 & 신청결과 = 미처리)
			ElseIf ( ls_drawing_result = ls_drawingresult[4] and &
				     ( ls_drawing_type = ls_drawingtype[2] or ls_drawing_type = ls_drawingtype[3] or &
					   ls_drawing_type = ls_edi_drawingtype[1] or ls_drawing_type = ls_edi_drawingtype[2] or ls_drawing_type = ls_edi_drawingtype[3] ) ) or &
				  ( ls_drawing_type = ls_drawingtype[3] and & 
				    ls_drawing_result = ls_drawingresult[2] ) Then
					 
				idw_data[1].Object.bank.Color = RGB(0, 0, 0)		
				idw_data[1].Object.bank.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acctno.Color = RGB(0, 0, 0)		
				idw_data[1].Object.acctno.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acct_owner.Color = RGB(0, 0, 0)	
				idw_data[1].Object.acct_owner.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acct_ssno.Color = RGB(0, 0, 0)
				idw_data[1].Object.acct_ssno.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.bank_chg.Color = RGB(0, 0, 0)		
				idw_data[1].Object.bank_chg.Background.Color = RGB(255, 255, 255)
				idw_data[1].Object.bank.Protect =1
				idw_data[1].Object.acctno.Protect = 1
				idw_data[1].Object.drawingresult.Protect =1
				idw_data[1].Object.acct_owner.Protect =1
				idw_data[1].Object.acct_ssno.Protect =1
				idw_data[1].Object.bank_chg.Protect = 0
			Else
				idw_data[1].Object.bank.Color = RGB(0, 0, 0)		
				idw_data[1].Object.bank.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acctno.Color = RGB(0, 0, 0)		
				idw_data[1].Object.acctno.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acct_owner.Color = RGB(0, 0, 0)		
				idw_data[1].Object.acct_owner.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.acct_ssno.Color = RGB(0, 0, 0)		
				idw_data[1].Object.acct_ssno.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.bank_chg.Color = RGB(0, 0, 0)		
				idw_data[1].Object.bank_chg.Background.Color = RGB(255, 251, 240)
				idw_data[1].Object.bank.Protect =1
				idw_data[1].Object.acctno.Protect = 1
				idw_data[1].Object.drawingresult.Protect =1
				idw_data[1].Object.acct_owner.Protect =1
				idw_data[1].Object.acct_ssno.Protect =1
				idw_data[1].Object.bank_chg.Protect =1
			End IF				
			
		Else   //자동이체가 아닐경우
			idw_data[1].Object.bank.Color = RGB(0, 0, 0)		
			idw_data[1].Object.bank.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.acctno.Color = RGB(0, 0, 0)		
			idw_data[1].Object.acctno.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.acct_owner.Color = RGB(0, 0, 0)	
			idw_data[1].Object.acct_owner.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.acct_ssno.Color = RGB(0, 0, 0)		
			idw_data[1].Object.acct_ssno.Background.Color = RGB(255, 251, 240)
			idw_data[1].Object.bank.Protect =1
			idw_data[1].Object.acctno.Protect = 1
			idw_data[1].Object.drawingresult.Protect =1
			idw_data[1].Object.acct_owner.Protect =1
			idw_data[1].Object.acct_ssno.Protect =1
			idw_data[1].Object.bank_chg.Protect =1
		End If
		
		//Email 청구이면
		If is_data[3] = idw_data[1].object.inv_method[1] Then			
			idw_data[1].Object.bil_email.Color = RGB(255, 255, 255)		
			idw_data[1].Object.bil_email.Background.Color = RGB(108, 147, 137)
		Else
			idw_data[1].Object.bil_email.Color = RGB(0, 0, 0)		
			idw_data[1].Object.bil_email.Background.Color = RGB(255, 255, 255)
		End If
		
		idw_data[1].Setredraw(True)		
		
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_check_2 ();
String ls_validkey, ls_fromdt, ls_todt, ls_svccod, ls_status
String ls_old_validkey, ls_old_fromdt, ls_old_todt, ls_priceplan
String ls_pricemodel, ls_customerid
String ls_svctype 		//선후불 서비스 구분
String ls_inv_yn, ls_inv_method, ls_pay_method, ls_bill_cycle, ls_bill_zipcod, ls_bill_addr1, &
       ls_bill_addr2, ls_bill_province, ls_bill_citycod, ls_taxtype, ls_currency_type, ls_invtype, &
		 ls_bil_email, ls_bank, ls_acctno, ls_acct_owner, ls_acct_ssno, ls_card_type, ls_card_no, &
		 ls_card_expdt, ls_card_holder, ls_card_ssno, ls_card_remark1
Integer li_cnt
Long ll_row, i, j,ll_date_range, ll_cnt
ii_rc = -2
Choose Case is_caller
	Case "b1w_reg_customer%save_tab3"

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		ls_old_validkey = ""
		ls_old_fromdt = ""
		ls_old_todt = ""
		For i =1 To ll_row
			ls_customerid = Trim(idw_data[1].object.customerid[i])
			ls_validkey = Trim(idw_data[1].object.validkey[i])
			ls_fromdt = String(idw_data[1].object.fromdt[i],'yyyymmdd')
			ls_svccod = Trim(idw_data[1].object.svccod[i])
			ls_priceplan = Trim(idw_data[1].object.priceplan[i])
			ls_status = Trim(idw_data[1].object.status[i])
			ls_pricemodel = Trim(idw_data[1].object.pricemodel[i])
			If IsNull(ls_validkey) Then ls_validkey = ""
			If IsNull(ls_fromdt) Then ls_fromdt = ""
			If IsNull(ls_todt) Then ls_todt = ""
			If IsNull(ls_svccod) Then ls_svccod = ""
			If IsNull(ls_priceplan) Then ls_priceplan = ""
			If IsNull(ls_pricemodel) Then ls_pricemodel = ""
			
			If ls_validkey= "" Then
				f_msg_usr_err(200, is_title, "인증 Key")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("validkey")
				Return 
			End If
			
			If ls_fromdt= "" Then
				f_msg_usr_err(200, is_title, "적용시작일")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("fromdt")
				Return 
			End If
			
			Select svctype
				Into :ls_svctype
				From svcmst
				Where svccod = :ls_svccod;
			
			//신청일때만
 
				If ls_svccod= "" Then
					f_msg_usr_err(200, is_title, "서비스")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("svccod")
					Return 
				End If
				
				If ls_priceplan = "" Then
					f_msg_usr_err(200, is_title, "가격정책")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("priceplan")
					Return 
				End If
				
				If ls_svctype = "0" Then
				
					If ls_pricemodel = "" Then
						f_msg_usr_err(200, is_title, "모델")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("pricemodel")
						Return 
					End If
			  End If 
				//Service 유형에 따라서.
				idw_data[1].object.svctype[i] = ls_svctype
				
				//해당 서비스의 가격 정책이 맞는지 확인
				Select count(*)
				Into :li_cnt
				From priceplanmst
				Where svccod = :ls_svccod and priceplan = :ls_priceplan;
				
				If li_cnt = 0 Then
					f_msg_usr_err(201, is_title, "가격정책")
					ii_rc = -2
				   Return
				End If
				
//			End If
			
			//다른 고객이 사용하고 있는 인증 키를 사용 하면 안됨
			If ufi_other_validinfo(ls_customerid, ls_validkey, ls_fromdt, ls_todt) < 0 Then
				f_msg_usr_err(9000, is_title, "사용 중입니다.")
				idw_data[1].SetRow(j)
				idw_data[1].ScrollToRow(j)
				idw_data[1].SetColumn("validkey")
				Return
			End If
			
		Next
		
		For i = 1 To ll_row
			For j =1 To ll_row
				If i = j Then Continue
					//Select
					ls_old_todt = String(idw_data[1].object.todt[i],'yyyymmdd')
					ls_old_validkey = Trim(idw_data[1].object.validkey[i])
					ls_old_fromdt = String(idw_data[1].object.fromdt[i],'yyyymmdd')
					
					ls_todt = String(idw_data[1].object.todt[j],'yyyymmdd')
					ls_validkey = Trim(idw_data[1].object.validkey[j])
					ls_fromdt = String(idw_data[1].object.fromdt[j],'yyyymmdd')
					
					//같은 인증Key는 기간이 겹칠 수 없다.  
					If ls_old_validkey = ls_validkey Then
						ll_date_range = uf_prc_date_range(ls_old_fromdt, ls_old_todt, ls_fromdt, ls_todt)
						If ll_date_range  = -1 Then		//시작 시간 잘못
							f_msg_usr_err(9000, is_title, "동일한 인증 Key에 대해 적용 기간이 중복 되었습니다.")
							idw_data[1].SetRow(j)
							idw_data[1].ScrollToRow(j)
							idw_data[1].SetColumn("fromdt")
							Return
						End If
					End If
				Next
			Next
	Case "b1w_reg_customer_d%save_tab2"


		ls_bill_cycle = Trim(idw_data[1].object.bilcycle[1])
		ls_inv_yn = Trim(idw_data[1].object.inv_yn[1])
		ls_inv_method = Trim(idw_data[1].object.inv_method[1])
		ls_pay_method = Trim(idw_data[1].object.pay_method[1])
		ls_bill_zipcod = Trim(idw_data[1].object.bil_zipcod[1])
		ls_bill_addr1 = Trim(idw_data[1].object.bil_addr1[1])
		ls_bill_addr2 = Trim(idw_data[1].object.bil_addr2[1])
		ls_taxtype = Trim(idw_data[1].object.taxtype[1])
		ls_currency_type = Trim(idw_data[1].object.billinginfo_currency_type[1])
		ls_invtype = Trim(idw_data[1].Object.inv_type[1])


		If IsNull(ls_inv_yn) Then ls_inv_yn = ""
		If IsNull(ls_inv_method) Then ls_inv_method = ""
		If IsNull(ls_pay_method) Then ls_pay_method = ""
		If IsNull(ls_bill_zipcod) Then ls_bill_zipcod = ""
		If IsNull(ls_bill_addr1) Then ls_bill_addr1 = ""
		If IsNull(ls_bill_addr2) Then ls_bill_addr2 = ""
		If IsNull(ls_bill_cycle) then ls_bill_cycle = ""
		If IsNull(ls_taxtype) then ls_taxtype = ""	
		If IsNull(ls_currency_type) Then ls_currency_type = ""
		If IsNull(ls_invtype) Then ls_invtype = ""

		
		//필수 Check
		If ls_invtype= "" Then
			f_msg_usr_err(200, is_title, "청구서유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("inv_type")
			Return 
		End If
		
		If  ls_bill_cycle= "" Then
			f_msg_usr_err(200, is_title, "청구주기")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bilcycle")
			Return 
		End If
		
		If ls_inv_yn = "" Then
			f_msg_usr_err(200, is_title, "청구서발송여부")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("inv_yn")
			Return 
		End If
			
		If ls_inv_method = "" Then
			f_msg_usr_err(200, is_title, "청구서발송방법")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("inv_method")
			Return 
		End If
		
		//화폐 단위
		If ls_currency_type = "" Then
			f_msg_usr_err(200, is_title, "통화 유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("billinginfo_currency_type")
			Return
		End If
		
		If ls_pay_method = "" Then
			f_msg_usr_err(200, is_title, "결제방법")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("pay_method")
			Return 
		End If
		
		If ls_taxtype = "" Then
			f_msg_usr_err(200, is_title, "TAX적용유형")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("taxtype")
			Return 
		End If
		
		//청구서 발송 방법이 email 이면
		If ls_inv_method = is_data[3] Then
			ls_bil_email = Trim(idw_data[1].object.bil_email[1])
			If IsNull(ls_bil_email) Then ls_bil_email = ""
			If ls_bil_email = "" Then
				f_msg_usr_err(200, is_title, "청구 Email")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("bil_email")
				Return 
			End If
			
			If pos(ls_bil_email, "@") = 0 Then
					f_msg_info(100, is_title, "청구 Email")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("bil_email")
				   Return 
			End If
		End If
		
		If ls_bill_zipcod = "" Then
			f_msg_usr_err(200, is_title, "우편번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_zipcod")
			Return 
		End If
		
		If ls_bill_addr1 = "" Then
			f_msg_usr_err(200, is_title, "주소 1")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_addr1")
			Return 
		End If
		
		If ls_bill_addr2 = "" Then
			f_msg_usr_err(200, is_title, "주소 2")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("bil_addr2")
			Return 
		End If

	    //자동이체
		If is_data[1] = Trim(idw_data[1].object.pay_method[1]) Then
			ls_bank = Trim(idw_data[1].object.bank[1])
			ls_acctno = Trim(idw_data[1].object.acctno[1])
			ls_acct_owner = Trim(idw_data[1].object.acct_owner[1]) 
			ls_acct_ssno = Trim(idw_data[1].object.acct_ssno[1])
			If IsNull(ls_bank) Then ls_bank = ""
			If IsNull(ls_acctno) Then ls_acctno = ""
			If IsNull(ls_acct_owner) Then ls_acct_owner = ""
			If IsNull(ls_acct_ssno) Then ls_acct_ssno = ""
			
			If ls_bank = "" Then
				f_msg_usr_err(200, is_title, "은행")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("bank")
				Return 
			End If
			
			If ls_acctno = "" Then
				f_msg_usr_err(200, is_title, "계좌번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acctno")
				Return 
			End If
			
			If ls_acct_owner = "" Then
				f_msg_usr_err(200, is_title, "예금주명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acct_owner")
				Return 
			End If
			
			If ls_acct_ssno = "" Then
				f_msg_usr_err(200, is_title, "예금주 주민번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("acct_ssno")
				Return 
			End If
			
		
			
		End If
		
		//신용카드
		If is_data[2] = Trim(idw_data[1].object.pay_method[1]) Then
			ls_card_type = Trim(idw_data[1].object.card_type[1])
			ls_card_no = Trim(idw_data[1].object.card_no[1])
			ls_card_expdt = String(idw_data[1].object.card_expdt[1],'yyyymmdd')
			ls_card_holder = Trim(idw_data[1].object.card_holder[1])
			ls_card_ssno = Trim(idw_data[1].object.card_ssno[1])
			ls_card_remark1 = Trim(idw_data[1].object.card_remark1[1])
			If IsNull(ls_card_type) Then ls_card_type = ""
			If IsNull(ls_card_no) Then ls_card_no = ""
			If IsNull(ls_card_expdt) Then ls_card_expdt = ""
			If IsNull(ls_card_holder) Then ls_card_holder = ""
			If IsNull(ls_card_ssno) Then ls_card_ssno = ""
			If IsNull(ls_card_remark1) Then ls_card_remark1 = ""
			
			If ls_card_type = "" Then
				f_msg_usr_err(200, is_title, "카드사")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_type")
				Return 
			End If
			
			If ls_card_no = "" Then
				f_msg_usr_err(200, is_title, "신용카드 번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_no")
				Return 
			End If
			
			If ls_card_expdt = "" Then
				f_msg_usr_err(200, is_title, "신용카드 유효기간")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_expdt")
				Return 
			End If
			
			If ls_card_holder = "" Then
				f_msg_usr_err(200, is_title, "카드회원명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_holder")
				Return 
			End If
			
			If ls_card_ssno = "" Then
				f_msg_usr_err(200, is_title, "카드회원 주민번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_ssno")
				Return 
			End If
			
			If ls_card_remark1 = "" Then
				f_msg_usr_err(200, is_title, "신용카드유형")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("card_remark1")
				Return 
			End If
		End If
			
			
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_check_06 ();//b1w_reg_customer%new_customer
String ls_customerid, ls_module, ls_ref_no, ls_ref_desc, ls_reqnum_dw
String ls_name[], ls_data, ls_ssn_check
Integer li_tab, i,li_cnt, li_pre_cnt, li_old_cnt

//b1w_reg_customer%inq_customer
Boolean lb_check, lb_check1

//"b1w_reg_customer%save_check"
String ls_customernm, ls_payid, logid, ls_password, ls_status, ls_ctype2, ls_holder_ssno
String ls_ssno, ls_logid, ls_zipcod, ls_addr1, ls_addr2, ls_phone1
String ls_corpnm, ls_corpno, ls_cregno, ls_representative, ls_businesstype, ls_businessitem
String ls_location, ls_buildingno, ls_roomno

String ls_currency_type, ls_taxtype
String ls_email_yn, ls_sms_yn, ls_email1, ls_smsphone, ls_partner

String ls_passportno

ii_rc = -2
Choose Case is_caller
 Case	"b1w_reg_customer_c%save_tab1"
	
		
		//필수 Check
		ls_customerid = Trim(idw_data[1].object.customerid[1])
		ls_payid = Trim(idw_data[1].object.payid[1])
		ls_customernm = Trim(idw_data[1].object.customernm[1])
		ls_logid = Trim(idw_data[1].object.logid[1])
		ls_password = Trim(idw_data[1].object.password[1])
		ls_ctype2 = Trim(idw_data[1].object.ctype2[1])
		ls_holder_ssno = Trim(idw_data[1].object.holder_ssno[1])
		ls_zipcod = Trim(idw_data[1].object.zipcod[1])
		ls_addr1 = Trim(idw_data[1].object.addr1[1])
		ls_addr2 = Trim(idw_data[1].object.addr2[1])
		ls_phone1 = Trim(idw_data[1].object.phone1[1])
		ls_email_yn = Trim(idw_data[1].object.email_yn[1])
		ls_sms_yn = Trim(idw_data[1].object.sms_yn[1])
		ls_email1 = Trim(idw_data[1].object.email1[1])
		ls_smsphone = Trim(idw_data[1].object.smsphone[1])		
		ls_passportno = Trim(idw_data[1].object.passportno[1])
				
		If IsNull(ls_customerid) Then ls_customerid = ""
		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_customernm) Then ls_customernm = ""
		If IsNull(ls_logid) Then ls_logid = ""
		If IsNull(ls_password) Then ls_password = ""
		If IsNull(ls_ctype2) Then ls_ctype2 = ""
		If IsNull(ls_holder_ssno) Then ls_holder_ssno = ""
		If IsNull(ls_zipcod) Then ls_zipcod = ""
		If IsNull(ls_addr1) Then ls_addr1 = ""
		If IsNull(ls_addr2) Then ls_addr2 = ""
		If IsNull(ls_phone1) Then ls_phone1 = ""
		If IsNull(ls_email_yn) Then ls_email_yn = ""
		If IsNull(ls_sms_yn) Then ls_sms_yn = ""
		If IsNull(ls_email1) Then ls_email1 = ""
		If IsNull(ls_smsphone) Then ls_smsphone = ""	
		
		If IsNull(ls_passportno) Then ls_passportno =""

		// default setting : billinginfo(통화유형, taxtype)
		ls_ref_desc = ""
		ls_currency_type = fs_get_control("B0", "P105", ls_ref_desc)
		ls_ref_desc = ""
		ls_taxtype = fs_get_control("B5", "T101", ls_ref_desc)
		
		//주민등록번호 CHECK 2005.07.15 OHJ
		ls_ref_desc  = ""
		ls_ssn_check = fs_get_control("00", "Z920", ls_ref_desc)
			
		If ls_customernm = "" Then
			f_msg_usr_err(200, is_title, "고객명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("customernm")
			Return 
		End If
		
		
		If ib_data[1]  or idw_data[1].GetItemStatus(1,"logid", Primary!) = DataModified! THEN
			
			If ls_logid <> "" Then
				
				Select count(*)
				Into :li_cnt
				From customerm
				Where customerid <> :ls_customerid and logid = :ls_logid;
				
				//사용자WEB이 들어가면 pre_svcorder Check 한다.
				Select count(*)
				 Into :li_pre_cnt
				 From pre_svcorder
				 Where logid = :ls_logid;
		

					
				If li_cnt <> 0 or li_pre_cnt <> 0 THEN //or li_old_cnt <> 0 Then
					f_msg_usr_err(9000, is_title, "이미 존재하는 ID 입니다.")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("logid")
					Return
				End If
				
				If ls_password = "" Then
					f_msg_usr_err(200, is_title, "Password")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("password")
					Return 
				End If
			
			End If
		End IF
	
		If ls_ctype2 = "" Then
			f_msg_usr_err(200, is_title, "개인/법인구분")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("ctype2")
			Return 
		End If
		

	
		//개인*************************************************************************/
		b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check)
		If lb_check Then
			ls_ssno = Trim(idw_data[1].object.ssno[1])
			If IsNull(ls_ssno) Then ls_ssno = ""
			ls_passportno = Trim(idw_data[1].object.passportno[1])
			If IsNull(ls_passportno) Then ls_passportno = ""
			
			If ls_ssno = "" AND ls_passportno = "" Then
					f_msg_usr_err(200, is_title, "주민등록번호 또는 여권번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ssno")
					Return 
			End If
			
			//개인
			IF ls_ssno <> "" THEN
				
				If ls_ssn_check = 'Y' Then
					//주민번호 Check
					If fi_check_juminnum(ls_ssno) = -1 Then
						f_msg_usr_err(201, is_title, "주민등록번호")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("ssno")
						Return
					End If
				End If
			
				//주민번호 중복체크
				IF ls_customerid <> "" THEN
				
					SELECT COUNT(*)
					INTO :li_cnt
					FROM customerm
					WHERE ssno = :ls_ssno
					AND customerid <> :ls_customerid;
					
				ELSE
					
					SELECT COUNT(*)
					INTO :li_cnt
					FROM customerm
					WHERE ssno = :ls_ssno;
					
				END IF
				
				IF li_cnt <> 0 THEN
					f_msg_usr_err(9000, is_title, "이미 등록된 주민등록번호 입니다.")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ssno")
					Return
				END IF
			
			//외국인
			ELSE
				//여권번호 중복체크
				IF ls_customerid <> "" THEN
				
					SELECT COUNT(*)
					INTO :li_cnt
					FROM customerm
					WHERE passportno = :ls_passportno
					AND customerid <> :ls_customerid;
					
				ELSE
					
					SELECT COUNT(*)
					INTO :li_cnt
					FROM customerm
					WHERE passportno = :ls_passportno;
					
				END IF
				
				IF li_cnt <> 0 THEN
					f_msg_usr_err(9000, is_title, "이미 등록된 여권번호 입니다.")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("passportno")
					Return
				END IF
			End If
	   
		END IF
		
		/*************************************************************************/
	
	    //SMS여부 = 'Y' 일때 smsphone 필수
		If ls_sms_yn= 'Y' Then
			If ls_smsphone = "" Then
				f_msg_usr_err(200, is_title, "SMS수신전화번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("smsphone")
				Return 
			End IF				
		End IF
		
		//법인
		b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check)
		If lb_check Then
			ls_corpnm = Trim(idw_data[1].object.corpnm[1])
			ls_corpno = Trim(idw_data[1].object.corpno[1])
			ls_cregno = Trim(idw_data[1].object.cregno[1])
			ls_representative = Trim(idw_data[1].object.representative[1])
			ls_businesstype = Trim(idw_data[1].object.businesstype[1])
			ls_businessitem = Trim(idw_data[1].object.businessitem[1])
			
				
			If IsNull(ls_corpnm) Then ls_corpnm = ""
			If IsNull(ls_corpno) Then ls_corpno = ""
			If IsNull(ls_cregno) Then ls_cregno = ""
			If IsNull(ls_representative) Then ls_representative = ""
			If IsNull(ls_businesstype) Then ls_businesstype = ""
			If IsNull(ls_businessitem) Then ls_businessitem = ""
			
		
			If ls_corpnm = "" Then
				f_msg_usr_err(200, is_title, "법인명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("corpnm")
				Return 
			End If
		
			If ls_corpno = "" Then
				f_msg_usr_err(200, is_title, "법인등록번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("corpno")
				Return 
			End If
		
			If ls_cregno = "" Then
				f_msg_usr_err(200, is_title, "사업자등록번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("cregno")
				Return 
			End If
			
			If ls_representative = "" Then
				f_msg_usr_err(200, is_title, "대표자성명")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("representative")
				Return 
			End If
		
			If ls_businesstype = "" Then
				f_msg_usr_err(200, is_title, "업태")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("businesstype")
				Return 
			End If
			
			If ls_businessitem = "" Then
				f_msg_usr_err(200, is_title, "종목")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("businessitem")
				Return 
			End If
		
		End If
		
		If ls_ssn_check = 'Y' Then
			b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check)
			If lb_check Then
				If ls_holder_ssno <> "" Then
					If fi_check_juminnum(ls_holder_ssno) = -1 Then
						f_msg_usr_err(9000, is_title, "올바르지 않은 주민등록번호입니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("holder_ssno")
						Return
					End If
				End If
			End IF
		End If 
		
		If ls_zipcod = "" Then
			f_msg_usr_err(200, is_title, "우편번호")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("zipcod")
			Return 
		End If
		
		If ls_addr1 = "" Then
			f_msg_usr_err(200, is_title, "주소")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("addr1")
			Return 
		End If
			
		If ls_addr2 = "" Then
			f_msg_usr_err(200, is_title, "주소")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("addr2")
			Return 
		End If
		
		If ls_phone1 = "" Then
			f_msg_usr_err(200, is_title, "전화번호1")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("phone1")
			Return 
		End If
		
	    //email여부 = 'Y' 일때 email1 필수
		If ls_email_yn= 'Y' Then
			If ls_email1 = "" Then
				f_msg_usr_err(200, is_title, "Email1")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("email1")
				Return 
			End IF				
		End IF
		
		If ib_data[1] Then		//신규
			idw_data[1].AcceptText()
		   If ls_customerid = "" Then
				//customerid
				Select to_char(seq_customerid.nextval) 
				Into :ls_customerid
				From dual;
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Sequence Error")
					Return 
				End If				
				idw_data[1].object.customerid[1] = ls_customerid
			End IF
			
			If ls_payid = "" Then
		  		idw_data[1].object.payid[1] = ls_customerid
		  		ls_payid = ls_customerid
	 		End If
			
			
			//납입자랑 가입자가 같을때
			If ls_payid = ls_customerid Then
				
				//결재방법, 청구주기, 청구서, 청구서유형 발송방법 구하기
				ls_data = fs_get_control("B0", "P141", ls_ref_desc)
				fi_cut_string(ls_data, ";" , ls_name[])
				
				Insert Into billinginfo (customerid, bilcycle, pay_method, inv_yn, inv_method, overdue_yn,
												 bil_zipcod, bil_addr1, bil_addr2, currency_type, taxtype, bil_email,
												 crtdt, crt_user, pgm_id,inv_type)
				Values (:ls_payid, :ls_name[2], :ls_name[1], 'Y', :ls_name[3], 'Y', 
							:ls_zipcod, :ls_addr1, :ls_addr2, :ls_currency_type, :ls_taxtype, :ls_email1, 
							sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no], :ls_name[4]);
				
				//Error
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, "Insert Error (BILLINGINFO)")
					Return
				End If
			End If	
		End If
		
		//조건 Check
		//납입자 정보가 있는지 확인
		Select Count(*)
		Into :li_cnt
		From billinginfo
		Where customerid = :ls_payid;
		
		//Error
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, "Select Error (BILLINGINFO)")
			Return
		End If
		
		If ls_customerid <> ls_payid Then
			If li_cnt = 0 Then
				f_msg_usr_err(9000, is_title, "납입자 청구정보가 존재하지 않습니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("payid")
				Return
			End If
		Else 
			If li_cnt = 0 Then 
				ii_rc = -3				//Billing Info 청구정보 등록하게 해야 함
				Return
			End If
		End If
		
End Choose
ii_rc = 0
end subroutine

public subroutine uf_prc_check_11 ();
String ls_receiptcod, ls_receiptdt, ls_resultcod, ls_card_type, ls_card_no, ls_card_expdt
String ls_card_holder, ls_card_ssno, ls_card_renark1, ls_bill_cycle, ls_bill_zipcod
String ls_inv_yn, ls_inv_method, ls_pay_method, ls_bill_addr2, ls_bill_addr1, ls_card_remark1
String ls_bank, ls_acctno, ls_acct_owner, ls_acct_ssno, ls_drawingreqdt
String ls_bil_email, ls_taxtype, ls_ctype2, ls_currency_type, ls_card_prefix_yn
boolean lb_check1, lb_check2

String ls_drawingtype[], ls_drawingresult[], ls_ref_desc, ls_temp, ls_name[]
string ls_drawing_type, ls_drawing_result, ls_edi_drawingtype[]

Integer li_count

Long ll_hwseq, ll_row, i
String ls_areanum, ls_opendt

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_customer%save_tab11"
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		For i = 1 To ll_row
			ls_areanum 	= Trim(idw_data[1].object.areanum[1])
			ls_opendt	= String(idw_data[1].object.opendt[1], 'YYYYMMDD')
			
			If IsNull(ls_areanum) Then ls_areanum = ""
			If IsNull(ls_opendt) Then ls_opendt = ""
			
			If ls_areanum = "" Then
				f_msg_usr_err(200, is_title, "제한번호")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("areanum")
				ii_rc = -2
				Return 
			End If
			
			If ls_opendt = "" Then
				f_msg_usr_err(200, is_title, "적용개시일")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("opendt")
				ii_rc = -2
				Return 
			End If
			
	 Next
	 
	Case "b1w_reg_customer_d_v20%inq_customer_tab2"
		idw_data[1].Setredraw(False)
		//합산 청구지 정보 Check 2004.03.06 C.bora Modify
		Select count(grcode) into :li_count from syscod2t where grcode = 'B320' and use_yn = 'Y';
		
		If li_count > 0 Then
			idw_data[1].Object.adding_type.visible 	= True
			idw_data[1].Object.adding_key.visible 		= True
			idw_data[1].Object.adding_type_t.visible 	= True
			idw_data[1].Object.adding_key_t.visible 	= True
	   Else
			idw_data[1].Object.adding_type_t.visible 	= False
			idw_data[1].Object.adding_key_t.visible 	= False
			idw_data[1].Object.adding_type.visible 	= False
			idw_data[1].Object.adding_key.visible 		= False
		End If
		
		
		//출금이체 신청유형(1.없음(0);2.신규(1);3.변경(2);4.해지(3);5.임의해지(7))
		ls_ref_desc = ""
		ls_temp 		= ""
		ls_temp 		= fs_get_control("B7", "A320", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingtype[])
		
		//EDI은행신청유형(1.신규(01);2.변경(05);3.변경(임의)(07);4.해지(03);5.해지(임의)(04))
		ls_ref_desc 	= ""
		ls_temp 			= ""
		ls_temp 			= fs_get_control("B7", "A608", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_edi_drawingtype[])
		
		//출금이체 신청결과(1.없음(0);2.신청(1);3.처리중(2);4.처리성공(S);5.처리실패(F))
		ls_ref_desc 	= ""
		ls_temp 			= ""
		ls_temp 			= fs_get_control("B7", "A330", ls_ref_desc)
		If ls_temp = "" Then Return
		fi_cut_string(ls_temp, ";", ls_drawingresult[])
		
		//신용카드자동setting 여부 ohj 2005.07.18
		ls_ref_desc 		= ""
		ls_card_prefix_yn = fs_get_control("00", "Z930", ls_ref_desc)	
		
		//자동이체 처리 쪽  user 수정 불가 - Display column
		idw_data[1].Object.drawingreqdt.Color 					= BLACK		
		idw_data[1].Object.drawingreqdt.Background.Color 	= RGB(255, 251, 240)
		idw_data[1].Object.drawingtype.Color 					= BLACK
		idw_data[1].Object.drawingtype.Background.Color 	= RGB(255, 251, 240)
		idw_data[1].Object.drawingresult.Color 				= BLACK
		idw_data[1].Object.drawingresult.Background.Color 	= RGB(255, 251, 240)
		idw_data[1].Object.receiptcod.Color 					= BLACK
		idw_data[1].Object.receiptcod.Background.Color 		= RGB(255, 251, 240)
		idw_data[1].Object.receiptdt.Color 						= BLACK
		idw_data[1].Object.receiptdt.Background.Color 		= RGB(255, 251, 240)
		idw_data[1].Object.resultcod.Color 						= BLACK
		idw_data[1].Object.resultcod.Background.Color 		= RGB(255, 251, 240)
		idw_data[1].Object.drawingreqdt.Protect 				= 1
		idw_data[1].Object.drawingtype.Protect 				= 1
		idw_data[1].Object.drawingresult.Protect 				= 1
		idw_data[1].Object.receiptcod.Protect 					= 1
		idw_data[1].Object.receiptdt.Protect 					= 1
		idw_data[1].Object.resultcod.Protect 					= 1
		
		//결제정보 변경여부
		If	is_data[4] = 'N' Then 		//수정불가
			idw_data[1].Object.pay_method.Color 				= RGB(0, 0, 0)		
			idw_data[1].Object.pay_method.Background.Color 	= RGB(255, 251, 240)
			idw_data[1].Object.pay_method.Protect 				= 1
		Else      			//수정가능
		 	idw_data[1].Object.pay_method.Color 				= RGB(255, 255, 255)			
			idw_data[1].Object.pay_method.Background.Color 	= RGB(108, 147, 137)
			idw_data[1].Object.pay_method.Protect 				= 0
		End If

		
		//자동이체일경우 
		If is_data[1] = Trim(idw_data[1].object.pay_method[1]) Then
			
			ls_drawing_type 	= idw_data[1].Object.drawingtype[1]
			ls_drawing_result = idw_data[1].Object.drawingresult[1] 
		
			//신청결과 =미처리 & 신청유형 <> 변경
			If ( ls_drawing_result = ls_drawingresult[2] ) and &
				 ls_drawing_type <> ls_drawingtype[3] Then
			


     		  //( 신청결과 = 성공 &, 신청유형 = 신규,변경,edi신규,edi변경,edi변경(임의) )   // EDI 신청유형추가...
			  //     or ( 신청유형 = 변경 & 신청결과 = 미처리)
			ElseIf ( ls_drawing_result = ls_drawingresult[4] 			and &
				     ( ls_drawing_type = ls_drawingtype[2] 		or &
					  	 ls_drawing_type = ls_drawingtype[3] 		or &
					    ls_drawing_type = ls_edi_drawingtype[1] 	or &
						 ls_drawing_type = ls_edi_drawingtype[2] 	or &
						 ls_drawing_type = ls_edi_drawingtype[3] )  ) 	or &
				   ( 	 ls_drawing_type = ls_drawingtype[3] 		and & 
				       ls_drawing_result = ls_drawingresult[2] 	  ) 			Then

			Else

			End IF				
			
		Else   //자동이체가 아닐경우

		End If
		
		//Email 청구이면
		If is_data[3] = idw_data[1].object.inv_method[1] Then			
			idw_data[1].Object.bil_email_T.Color 				= navy
			idw_data[1].Object.bil_email_T.Background.Color	= WHITE
		Else
			idw_data[1].Object.bil_email_T.Color 					= BLACK
			idw_data[1].Object.bil_email_T.Background.Color 	= WHITE
		End If
		
		
		idw_data[1].Setredraw(True)			
	
End Choose
ii_rc = 0
end subroutine

on b1u_check.create
call super::create
end on

on b1u_check.destroy
call super::destroy
end on

