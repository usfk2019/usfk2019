﻿$PBExportHeader$w_reg_userid_log.srw
$PBExportComments$사용자계정 로그
forward
global type w_reg_userid_log from w_a_reg_m
end type
end forward

global type w_reg_userid_log from w_a_reg_m
integer width = 3497
integer height = 1920
end type
global w_reg_userid_log w_reg_userid_log

on w_reg_userid_log.create
call super::create
end on

on w_reg_userid_log.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where
String ls_userid, ls_empnm
Long ll_row

ls_userid = Trim(String(dw_cond.Object.sle_userid[1]))
ls_empnm = Trim(String(dw_cond.Object.empnm[1]))

If ls_userid <> "" Or Not ISNull(ls_userid) Then
	ls_where = "emp_id like '" + ls_userid + "%'"
End IF
If ls_empnm <> "" Or Not ISNull(ls_empnm) Then
	ls_where = "empnm like '" + ls_empnm + "%'"
End IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

end event

event ue_extra_save;Date ld_now
Long ll_mrow_cnt, ll_row_cnt, i, jj, ll_emp_auth
double ll_return
String ls_emp_auth, ls_passwd, ls_passwd_out, ls_errmsg, ls_emp_group
String ls_reg_action, ls_mod_action, ls_emp_id, ls_empnm, ls_emp_type
String ls_user_group, ls_email, ls_smsphone, ls_emp_no, ls_action
Datetime ldt_sysdate

ls_errmsg = space(256)
ls_passwd_out = space(32)
ll_row_cnt = dw_detail.RowCount()
If ll_row_cnt = 0 Then Return 0 

SELECT SYSDATE INTO :ldt_sysdate
FROM   DUAL;


//로그 행위(action)추출 - 등록
SELECT ref_content		INTO :ls_reg_action		FROM sysctl1t 
WHERE module = 'U4' AND ref_no = 'A100';	

//로그 행위(action)추출 - 변경
SELECT ref_content		INTO :ls_mod_action		FROM sysctl1t 
WHERE module = 'U4' AND ref_no = 'A101';	

For i = 1 To ll_row_cnt
	
  If dw_detail.GetItemStatus(i, 2, Primary!) = DataModified! then
	  
	
	//패스워드 암호화 20031110 choi bora
	ls_passwd = dw_detail.object.password[i]
	If LenA(ls_passwd) > 15 Then
		f_msg_usr_err(201, Title, "15자리 이하로 입력하세요.")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("password")
		Return -1
	End If
	
	ls_emp_group = dw_detail.Object.emp_group[i]
	If IsNull(ls_emp_group) Then ls_emp_group = ""
	If ls_emp_group = "" Then
		f_msg_usr_err(200, Title, "User Group")
		dw_detail.SetFocus()
		dw_detail.scrolltorow(i)
		dw_detail.SetColumn("emp_group")
		Return -2
	End If
	
	ls_emp_auth = String(dw_detail.object.emp_auth[i])
	If IsNull(ls_emp_auth) Then ls_emp_auth = ""
	If ls_emp_auth = "" Then
		f_msg_usr_err(200, Title, "Authority")
		dw_detail.SetFocus()
		dw_detail.scrolltorow(i)
		dw_detail.SetColumn("emp_auth")
		Return -2
	End If
	
	//PASSWORD_DESENCRYPT(string P_INPUT_PASS, ref string P_OUT_PASS, ref double P_RETURN,ref string P_ERR_MSG) 
   //SQLCA.PASSWORD_DESENCRYPT(ls_passwd, ls_passwd_out, ll_return, ls_errmsg)
	SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_passwd)					
		INTO   :ls_passwd_out					
		FROM   DUAL;		

	
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		ll_return = -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(This.Title, ls_errmsg)
	End If

	If ll_return <> 0 Then	//실패
		Return -1
	Else				//성공
		dw_detail.object.password[i] = ls_passwd_out
	End If
end If
	
Next

FOR jj=1 TO ll_row_cnt
	IF dw_detail.GetItemStatus(jj, 0, Primary!) = DataModified! OR dw_detail.GetItemStatus(jj, 0, Primary!) = NewModified! THEN
		ls_emp_id		= Trim(dw_detail.Object.emp_id[jj])
		ls_empnm			= Trim(dw_detail.Object.empnm[jj])
		ls_emp_group	= Trim(dw_detail.Object.emp_group[jj])
		ls_emp_type		= Trim(dw_detail.Object.emp_type[jj])
		ls_user_group	= Trim(dw_detail.Object.user_group_id[jj])
		ll_emp_auth		= dw_detail.Object.emp_auth[jj]
		ls_email			= Trim(dw_detail.Object.email[jj])
		ls_smsphone		= Trim(dw_detail.Object.smsphone[jj])
		ls_emp_no		= Trim(dw_detail.Object.emp_no[jj])
		
		
		IF dw_detail.GetItemStatus(jj, 0, Primary!) = DataModified! THEN
			ls_action = ls_mod_action
			dw_detail.object.updtdt[jj] = ldt_sysdate
			dw_detail.object.updt_user[jj] = gs_user_id
		ELSE
			ls_action = ls_reg_action
		     dw_detail.object.user_lock[jj] = 'N'
			dw_detail.object.crt_user[jj] = gs_user_id
			dw_detail.object.crtdt[jj] = ldt_sysdate
		END IF
		
		INSERT INTO SYSUSR_LOG
			( EMP_ID, SEQ, GUBUN, LOG_STATUS, EMPNM,
			  EMP_GROUP, EMP_TYPE, USER_GROUP_ID, EMP_AUTH, EMAIL,
			  SMSPHONE, EMP_NO, CRT_USER, CRTDT, PGM_ID )
		VALUES
			( :ls_emp_id, SEQ_SYSUSR.NEXTVAL, 'REG', :ls_action, :ls_empnm,
			  :ls_emp_group, :ls_emp_type, :ls_user_group, :ll_emp_auth, :ls_email,
			  :ls_smsphone, :ls_emp_no, :gs_user_id, SYSDATE, :gs_pgm_id[gi_open_win_no] );
		
		IF sqlca.sqlcode < 0 THEN
			ROLLBACK;			
			f_msg_usr_err(9000, Title, "Insert Error( SYSUSR_LOG ) ==> EMP_ID : " + ls_emp_id )
			RETURN -1
		END IF	
	END IF
NEXT
//***** Record when modified or created ****
//Read today & current time
iu_cust_db_app.is_caller = "NOW"
iu_cust_db_app.is_title = This.Title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then Return -1
ld_now = Date(iu_cust_db_app.idt_data[1])
//Record
ll_row_cnt = dw_detail.RowCount()
Do While ll_mrow_cnt <= ll_row_cnt
	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
	If ll_mrow_cnt > 0 Then
		dw_detail.Object.upd_dt[ll_mrow_cnt] = ld_now
	Else
		ll_mrow_cnt = ll_row_cnt + 1
	End If	
Loop

Return 0

end event

event ue_extra_delete;call super::ue_extra_delete;string ls_action, ls_emp_id, ls_empnm, ls_emp_group, ls_emp_type, ls_user_group, ls_email, ls_smsphone, ls_emp_no
long 	ll_emp_auth
integer jj

//로그 행위(action)추출 - 삭제
SELECT ref_content        INTO :ls_action        
FROM sysctl1t 
WHERE module = 'U4' AND ref_no = 'A102';    


jj = dw_detail.GetRow()

ls_emp_id		= Trim(dw_detail.Object.emp_id[jj])
ls_empnm			= Trim(dw_detail.Object.empnm[jj])
ls_emp_group	= Trim(dw_detail.Object.emp_group[jj])
ls_emp_type		= Trim(dw_detail.Object.emp_type[jj])
ls_user_group	= Trim(dw_detail.Object.user_group_id[jj])
ll_emp_auth		= dw_detail.Object.emp_auth[jj]
ls_email			= Trim(dw_detail.Object.email[jj])
ls_smsphone		= Trim(dw_detail.Object.smsphone[jj])
ls_emp_no		= Trim(dw_detail.Object.emp_no[jj])


INSERT INTO SYSUSR_LOG
	( EMP_ID, SEQ, GUBUN, LOG_STATUS, EMPNM,
	  EMP_GROUP, EMP_TYPE, USER_GROUP_ID, EMP_AUTH, EMAIL,
	  SMSPHONE, EMP_NO, CRT_USER, CRTDT, PGM_ID )
VALUES
	( :ls_emp_id, SEQ_SYSUSR.NEXTVAL, 'REG', :ls_action, :ls_empnm,
	  :ls_emp_group, :ls_emp_type, :ls_user_group, :ll_emp_auth, :ls_email,
	  :ls_smsphone, :ls_emp_no, :gs_user_id, SYSDATE, :gs_pgm_id[gi_open_win_no] );

IF sqlca.sqlcode < 0 THEN
	ROLLBACK;			
	f_msg_usr_err(9000, Title, "Insert Error( SYSUSR_LOG ) ==> EMP_ID : " + ls_emp_id )
	RETURN -1
END IF	

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_userid_log
integer y = 64
integer width = 1330
integer height = 212
string dataobject = "d_cnd_userid"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_userid_log
integer x = 1563
integer y = 44
end type

type p_close from w_a_reg_m`p_close within w_reg_userid_log
integer x = 1870
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_userid_log
integer width = 1422
end type

type p_delete from w_a_reg_m`p_delete within w_reg_userid_log
boolean visible = false
integer y = 1692
end type

type p_insert from w_a_reg_m`p_insert within w_reg_userid_log
boolean visible = false
integer y = 1692
end type

type p_save from w_a_reg_m`p_save within w_reg_userid_log
boolean visible = false
integer y = 1692
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_userid_log
integer y = 304
integer width = 3401
integer height = 1364
string dataobject = "d_reg_userid_log"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_userid_log
integer y = 1692
end type

