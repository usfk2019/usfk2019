$PBExportHeader$b1u_check_sc.sru
$PBExportComments$[ceusee] Check Object
forward
global type b1u_check_sc from u_cust_a_check
end type
end forward

global type b1u_check_sc from u_cust_a_check
end type
global b1u_check_sc b1u_check_sc

forward prototypes
public function integer uf_prc_date_range (string as_old_start, string as_old_end, string as_start, string as_end)
public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt)
public subroutine uf_prc_check_1 ()
public subroutine uf_prc_check_10 ()
public subroutine uf_prc_check_11 ()
public subroutine uf_prc_check_2 ()
public subroutine uf_prc_check_9 ()
public subroutine uf_prc_check_4 ()
public subroutine uf_prc_check_06 ()
public subroutine uf_prc_check ()
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

public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt);/*------------------------------------------------------------------------
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

public subroutine uf_prc_check_1 ();
end subroutine

public subroutine uf_prc_check_10 ();
end subroutine

public subroutine uf_prc_check_11 ();
end subroutine

public subroutine uf_prc_check_2 ();
end subroutine

public subroutine uf_prc_check_9 ();
end subroutine

public subroutine uf_prc_check_4 ();
end subroutine

public subroutine uf_prc_check_06 ();
end subroutine

public subroutine uf_prc_check ();//b1w_reg_customer%new_customer
String ls_customerid, ls_module, ls_ref_no, ls_ref_desc, ls_reqnum_dw
String ls_name[], ls_data
Integer li_tab, i,li_cnt, li_pre_cnt, li_old_cnt

//b1w_reg_customer%inq_customer
Boolean lb_check, lb_check1

//"b1w_reg_customer%save_check"
String ls_customernm, ls_payid, logid, ls_password, ls_status, ls_ctype2, ls_holder_ssno
String ls_ssno, ls_logid, ls_zipcod, ls_addr1, ls_addr2, ls_phone1
String ls_corpnm, ls_corpno, ls_cregno, ls_representative, ls_businesstype, ls_businessitem
String ls_location, ls_buildingno, ls_roomno

String ls_currency_type, ls_taxtype
String ls_email_yn, ls_sms_yn, ls_email1, ls_smsphone

String ls_passportno

//2005.07.01 juede
String ls_question_pwd, ls_answer_pwd


ii_rc = -2
Choose Case is_caller
 Case	"b1w_reg_customer_c%save_tab1"
	//lu_check.ii_data[1] = li_tab
	//lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
    //lu_check.is_title = Title
	//lu_check.ii_data[1] = li_tab
    //lu_check.ib_data[1] = ib_new
	//lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
		
		//필수 Check
		ls_customerid = Trim(idw_data[1].object.customerid[1])
		ls_payid = Trim(idw_data[1].object.payid[1])
		ls_customernm = Trim(idw_data[1].object.customernm[1])
		ls_logid = Trim(idw_data[1].object.logid[1])
		ls_password = Trim(idw_data[1].object.password[1])
		//ls_question_pwd = Trim(idw_data[1].object.question_pwd[1])
		//ls_answer_pwd = Trim(idw_data[1].object.answer_pwd[1])
		ls_ctype2 = Trim(idw_data[1].object.ctype2[1])
		//ls_holder_ssno = Trim(idw_data[1].object.holder_ssno[1])
		ls_zipcod = Trim(idw_data[1].object.zipcod[1])
		ls_addr1 = Trim(idw_data[1].object.addr1[1])
		ls_addr2 = Trim(idw_data[1].object.addr2[1])
		ls_phone1 = Trim(idw_data[1].object.phone1[1])
		ls_email_yn = Trim(idw_data[1].object.email_yn[1])
		ls_sms_yn = Trim(idw_data[1].object.sms_yn[1])
		ls_email1 = Trim(idw_data[1].object.email1[1])
		ls_smsphone = Trim(idw_data[1].object.sms_phone[1])
		
		//ls_passportno = Trim(idw_data[1].object.passportno[1])
		
		If IsNull(ls_customerid) Then ls_customerid = ""
		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_customernm) Then ls_customernm = ""
		If IsNull(ls_logid) Then ls_logid = ""
		If IsNull(ls_password) Then ls_password = ""
		If IsNull(ls_ctype2) Then ls_ctype2 = ""
		//If IsNull(ls_holder_ssno) Then ls_holder_ssno = ""
		If IsNull(ls_zipcod) Then ls_zipcod = ""
		If IsNull(ls_addr1) Then ls_addr1 = ""
		If IsNull(ls_addr2) Then ls_addr2 = ""
		If IsNull(ls_phone1) Then ls_phone1 = ""
		If IsNull(ls_email_yn) Then ls_email_yn = ""
		If IsNull(ls_sms_yn) Then ls_sms_yn = ""
		If IsNull(ls_email1) Then ls_email1 = ""
		If IsNull(ls_smsphone) Then ls_smsphone = ""	
		
		//If IsNull(ls_passportno) Then ls_passportno =""

		// default setting : billinginfo(통화유형, taxtype)
		/* 2005.07.01 juede
		ls_ref_desc = ""
		ls_currency_type = fs_get_control("B0", "P105", ls_ref_desc)
		ls_ref_desc = ""
		ls_taxtype = fs_get_control("B5", "T101", ls_ref_desc)
		*/
		If ls_customernm = "" Then
			f_msg_usr_err(200, is_title, "고객명")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("customernm")
			Return 
		End If
		
		
		If ib_data[1] or idw_data[1].GetItemStatus(1,"logid", Primary!) = DataModified! THEN
			
			If ls_logid <> "" Then
				
				Select count(*)
				Into :li_cnt
				From customerm
				Where customerid <> :ls_customerid and logid = :ls_logid;
				
				//사용자WEB이 들어가면 pre_svcorder Check 한다.
				/* 2005.07.01 juede
				Select count(*)
				 Into :li_pre_cnt
				 From pre_svcorder
				 Where logid = :ls_logid;
		       */

					
				//If li_cnt <> 0 or li_pre_cnt <> 0 or li_old_cnt <> 0 Then    2005.07.01 juede
				If li_cnt <> 0 Then
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
		
		//개인
		b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check)
		If lb_check Then
			ls_ssno = Trim(idw_data[1].object.ssno[1])
			If IsNull(ls_ssno) Then ls_ssno = ""
			If ls_ssno = "" Then
				f_msg_usr_err(200, is_title, "주민등록번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("ssno")
				Return 
			End If
			
			//주민번호 Check
			If fi_check_juminnum(ls_ssno) = -1 Then
				f_msg_usr_err(201, is_title, "주민등록번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("ssno")
				Return
			End If
		End If
	
		//개인*************************************************************************/
		/* 2005.07.07 juede comment
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
				
				//주민번호 Check
				If fi_check_juminnum(ls_ssno) = -1 Then
					f_msg_usr_err(201, is_title, "주민등록번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ssno")
					Return
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
		*/
		/*************************************************************************/
	
	    //SMS여부 = 'Y' 일때 smsphone 필수
		If ls_sms_yn= 'Y' Then
			If ls_smsphone = "" Then
				f_msg_usr_err(200, is_title, "SMS수신전화번호")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("sms_phone")
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
			

		End If
		
	
		
End Choose
ii_rc = 0
end subroutine

on b1u_check_sc.create
call super::create
end on

on b1u_check_sc.destroy
call super::destroy
end on

