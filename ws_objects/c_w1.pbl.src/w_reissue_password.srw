$PBExportHeader$w_reissue_password.srw
$PBExportComments$사용자 패스워드 재발급
forward
global type w_reissue_password from window
end type
type cb_1 from commandbutton within w_reissue_password
end type
type sle_userid from singlelineedit within w_reissue_password
end type
type sle_con_password from singlelineedit within w_reissue_password
end type
type sle_new_password from singlelineedit within w_reissue_password
end type
type sle_cur_password from singlelineedit within w_reissue_password
end type
type st_4 from statictext within w_reissue_password
end type
type st_3 from statictext within w_reissue_password
end type
type st_2 from statictext within w_reissue_password
end type
type st_1 from statictext within w_reissue_password
end type
type p_save from u_p_save within w_reissue_password
end type
type p_close from u_p_close within w_reissue_password
end type
type mle_1 from multilineedit within w_reissue_password
end type
type r_1 from rectangle within w_reissue_password
end type
end forward

global type w_reissue_password from window
integer width = 1797
integer height = 1132
boolean titlebar = true
string title = "Change Password"
boolean controlmenu = true
boolean minbox = true
long backcolor = 29478337
event ue_close ( )
event ue_save ( )
cb_1 cb_1
sle_userid sle_userid
sle_con_password sle_con_password
sle_new_password sle_new_password
sle_cur_password sle_cur_password
st_4 st_4
st_3 st_3
st_2 st_2
st_1 st_1
p_save p_save
p_close p_close
mle_1 mle_1
r_1 r_1
end type
global w_reissue_password w_reissue_password

type variables
String is_open
u_cust_db_app iu_cust_db_app   //db조작처리
end variables

forward prototypes
public function integer wf_password_validation (string as_userid, string as_password)
end prototypes

event ue_close();//Destroy iu_cust_db_app
Close(This)
end event

event ue_save();String ls_curr_password, ls_new_password, ls_con_password, ls_userid
String ls_passwd_out, ls_errmsg, ls_passwd_in, ls_path, ls_passwd_chk
String ls_period, ls_action
DATE	 ld_pwd_expdt
double ll_return
Boolean ib_dbconnected, ib_exist

ib_exist = False

iu_cust_db_app = Create u_cust_db_app
ls_errmsg = space(256)
ls_passwd_out = space(32)
ls_passwd_in = space(32)
ls_userid = sle_userid.Text
ls_curr_password = sle_cur_password.Text
ls_new_password = sle_new_password.Text
ls_con_password = sle_con_password.Text

If IsNull(ls_userid)  Then ls_userid = ""
If IsNull(ls_curr_password) Then ls_curr_password = ""
If IsNull(ls_new_password) Then ls_new_password = ""
If IsNull(ls_con_password) Then ls_con_password = ""

If ls_userid = "" Then
	f_msg_info(200, Title, "User ID")
	sle_userid.setFocus()
	Return
End If

If ls_curr_password = "" Then
	f_msg_info(200, Title, "인증번호")
	sle_cur_password.setFocus()
	Return
End If

If ls_new_password = "" Then
	f_msg_info(200, Title, "New Password")
	sle_new_password.setFocus()
	Return
Else
	If LenA(ls_new_password) > 15 Then
		f_msg_usr_err(201, Title, "15자리 이하로 입력하세요.")
		sle_new_password.setFocus()
	   Return
	End If		
End If

If ls_con_password = "" Then
	f_msg_info(200, Title, "Confirm Password")
	sle_con_password.setFocus()
	Return
Else
	If ls_new_password <> ls_con_password Then
		f_msg_usr_err(100, Title, " New Password <> Confirm Password")
		sle_con_password.setFocus()
		Return
   End If
End If

//IF ls_curr_password = ls_new_password THEN
//	f_msg_usr_err(201, Title, "새로운 비밀번호를 변경하세요")
//	sle_new_password.setFocus()
//	Return	
//END IF

if wf_password_validation(ls_userid, ls_new_password) < 0 then Return


SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_curr_password)					
INTO   :ls_passwd_in					
FROM   DUAL;		


SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_new_password)					
INTO   :ls_passwd_out					
FROM   DUAL;		

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

If ll_return <> 0 Then	//실패
	Return 
End If

//pw 변경 주기 - 3
SELECT ref_content		INTO :ls_period		FROM sysctl1t 
WHERE module = 'U6' AND ref_no = 'A100';	

//로그 상태값
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U4' AND ref_no = 'A106';	

SELECT ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), TO_NUMBER(:ls_period))
INTO	 :ld_pwd_expdt
FROM   DUAL;


SELECT PASSWORD into :ls_passwd_chk
FROM SYSUSR1T
WHERE EMP_ID =  :ls_userid;

IF ls_passwd_in <> ls_passwd_chk THEN
	Rollback;
	f_msg_info(200, Title, "인증번호가 일치하지 않습니다.")
	sle_cur_password.setFocus()
	Return 
END IF

//Upadate
Update sysusr1t
set      password = :ls_passwd_out,
		 pwd_expdt = :ld_pwd_expdt,
		 user_lock = 'N',
		 user_lock_type = null
where  emp_id = :ls_userid and password = :ls_passwd_in;


If SQLCA.SQLCode < 0 Then		//For Programer
	Rollback;
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	Return 
End IF

INSERT INTO SYSUSR_LOG
	( EMP_ID, SEQ, GUBUN, LOG_STATUS, TIMESTAMP,
	  CRT_USER, CRTDT, PGM_ID )
VALUES
	( :ls_userid, SEQ_SYSUSR.NEXTVAL, 'PWD', :ls_action, SYSDATE,
	  :ls_userid, SYSDATE, 'PASSWORD');

If SQLCA.SQLCode < 0 Then		//For Programer
	Rollback;
	MessageBox(This.Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	Return
End If

commit;
f_msg_info(3000,title,"Save")
//
////Disconnect from db
//iu_cust_db_app.is_caller = "DISCONNECT"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.uf_prc_db()
//






end event

public function integer wf_password_validation (string as_userid, string as_password);
integer i, j, li_seq1, li_seq2, li_char1_cnt, li_char2_cnt, li_char3_cnt
string ls_char1, ls_char2, ls_char3

//LOGIN ID와 동일한 비밀번호를 사용할 수 없다.
IF Match( as_password, as_userid) = True  THEN
	f_msg_usr_err(9000, '비밀번호변경', "User ID와 동일한 비밀번호를 사용할 수 없습니다.")	
 	return -1
END IF

//동일한 문자 혹은 숫자를 3회이상 연속하여 입력할 수 없다.  ( 예 : aaa, 222, …)
FOR i = 1 to len(as_password)
	  IF ASC(mid(as_password,i + 1,1)) - ASC(mid(as_password,i,1)) = 0 THEN
          li_seq1 = li_seq1 + 1
       END IF
       IF  li_seq1 >= 2 THEN
           f_msg_usr_err(9000, '비밀번호변경', "동일한 문자 혹은 숫자를 3회이상 연속하여 입력할 수 없습니다")	
      	  return -1
       END IF
NEXT


//연속된 숫자/문자 패턴을 가지는 비밀번호는 지정할 수 없다. ( 예 : 123, abc, …)
FOR i = 1 to len(as_password) 
       IF ASC(mid(as_password,i + 1,1)) - ASC(mid(as_password,i,1)) = 1 THEN
          li_seq2 = li_seq2 + 1
       END IF;
       IF  li_seq2 >= 2 THEN
           f_msg_usr_err(9000, '비밀번호변경', "3개이상의 연속된 숫자, 문자 패턴을 갖는 비밀번호는 지정할 수 없습니다.")	
      	  return -1
       END IF;
NEXT
 
//영문 대/소문자, 숫자, 특수문자를 조합하여 8자리 이상이어야 한다."
//숫자
FOR i  = 1 to len(as_password) 
       IF  Match( mid(as_password,i,1), "[0-9]") = True  THEN
          li_char1_cnt = li_char1_cnt + 1
       END IF
NEXT
	
 //영문자
  FOR i  = 1 to len(as_password) 
      // IF Match( mid(as_password,i,1), ls_char2) = True  THEN
		IF Match( mid(as_password,i,1), "[A-Za-z]") = True   THEN
          li_char2_cnt = li_char2_cnt + 1
       END IF
 NEXT
 
 
   //특수문자(한글포함)
	//[~!@#$%^&*()-_=+\|[]{};:',.<>/?\]
FOR i  = 1 to len(as_password) 
	 IF   Match( mid(as_password,i ,1), "[^0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]") = True THEN
		 li_char3_cnt = li_char3_cnt + 1;
	 END IF;
NEXT

//숫자+영문자+특수문자 : 8자리 이상
IF (li_char1_cnt > 0 AND li_char2_cnt > 0 AND li_char3_cnt > 0 AND len(as_password)  >= 8)  THEN
	
ELSE
	 f_msg_usr_err(9000, '비밀번호변경', "비밀번호는 영문 대소문자, 숫자, 특수문자를 조합하여 8자리 이상이어야 합니다..")	
     return -1
END IF


return 0
end function

on w_reissue_password.create
this.cb_1=create cb_1
this.sle_userid=create sle_userid
this.sle_con_password=create sle_con_password
this.sle_new_password=create sle_new_password
this.sle_cur_password=create sle_cur_password
this.st_4=create st_4
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.p_save=create p_save
this.p_close=create p_close
this.mle_1=create mle_1
this.r_1=create r_1
this.Control[]={this.cb_1,&
this.sle_userid,&
this.sle_con_password,&
this.sle_new_password,&
this.sle_cur_password,&
this.st_4,&
this.st_3,&
this.st_2,&
this.st_1,&
this.p_save,&
this.p_close,&
this.mle_1,&
this.r_1}
end on

on w_reissue_password.destroy
destroy(this.cb_1)
destroy(this.sle_userid)
destroy(this.sle_con_password)
destroy(this.sle_new_password)
destroy(this.sle_cur_password)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.p_save)
destroy(this.p_close)
destroy(this.mle_1)
destroy(this.r_1)
end on

event open;f_center_window(w_reissue_password)

sle_userid.text = Message.StringParm	
end event

type cb_1 from commandbutton within w_reissue_password
integer x = 1294
integer y = 320
integer width = 274
integer height = 84
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "SMS전송"
end type

event clicked;STRING ls_sms, ls_userid, ls_sms_text, ls_sms_no, ls_passwd_in, ls_sender

//유저아이디
ls_userid = sle_userid.text

//SMS 발신번호
SELECT REF_CONTENT INTO :ls_sender
FROM SYSCTL1T 
WHERE MODULE = 'U6'
    AND REF_NO = 'A300';

//핸드폰번호
SELECT SMSPHONE INTO :ls_sms 
FROM SYSUSR1T
WHERE EMP_ID = :ls_userid;

//인증번호 생성
SELECT  to_char(TRIM(LPAD(TRUNC(DBMS_RANDOM.VALUE(0,999999),0),6,0)))  INTO :ls_sms_no
FROM DUAL;

//인증번호 암호화
SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_sms_no)					
INTO   :ls_passwd_in					
FROM   DUAL;		

update sysusr1t set
    password = :ls_passwd_in
WHERE EMP_ID = :ls_userid;

ls_sms_text = '[UBS] 요청하신 SMS 인증번호입니다 :' + ls_sms_no

INSERT INTO SMS.SC_TRAN (TR_NUM, TR_SENDDATE, TR_SENDSTAT, TR_PHONE, TR_CALLBACK ,TR_MSG, TR_MSGTYPE)                       
		 VALUES (SMS.SC_SEQUENCE.NEXTVAL, SYSDATE, '0', :ls_sms, :ls_sender, :ls_sms_text, '0');
		 
commit;
end event

type sle_userid from singlelineedit within w_reissue_password
integer x = 814
integer y = 104
integer width = 613
integer height = 80
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean underline = true
long backcolor = 16777215
end type

type sle_con_password from singlelineedit within w_reissue_password
integer x = 681
integer y = 668
integer width = 736
integer height = 84
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
boolean password = true
end type

type sle_new_password from singlelineedit within w_reissue_password
integer x = 681
integer y = 568
integer width = 736
integer height = 84
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
boolean password = true
end type

type sle_cur_password from singlelineedit within w_reissue_password
integer x = 681
integer y = 468
integer width = 736
integer height = 84
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
end type

type st_4 from statictext within w_reissue_password
integer x = 178
integer y = 580
integer width = 453
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "New Password"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_3 from statictext within w_reissue_password
integer x = 178
integer y = 684
integer width = 453
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "Confirm Password"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_2 from statictext within w_reissue_password
integer x = 178
integer y = 484
integer width = 453
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "SMS 인증번호"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_1 from statictext within w_reissue_password
integer x = 87
integer y = 128
integer width = 645
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
boolean enabled = false
string text = "비밀번호 재발급 User ID"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_save from u_p_save within w_reissue_password
integer x = 1115
integer y = 880
end type

type p_close from u_p_close within w_reissue_password
integer x = 1417
integer y = 880
end type

type mle_1 from multilineedit within w_reissue_password
integer x = 201
integer y = 308
integer width = 1042
integer height = 116
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "전송 버튼을 클릭하신 후,  휴대폰으로 전송받은 인증번호를 입력하세요."
boolean border = false
end type

type r_1 from rectangle within w_reissue_password
integer linethickness = 1
long fillcolor = 29478337
integer x = 87
integer y = 232
integer width = 1609
integer height = 568
end type

