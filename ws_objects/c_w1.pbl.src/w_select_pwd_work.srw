$PBExportHeader$w_select_pwd_work.srw
$PBExportComments$[ceusee] 사용자 패스워드 변경
forward
global type w_select_pwd_work from window
end type
type st_6 from statictext within w_select_pwd_work
end type
type st_5 from statictext within w_select_pwd_work
end type
type st_4 from statictext within w_select_pwd_work
end type
type st_3 from statictext within w_select_pwd_work
end type
type sle_userid from singlelineedit within w_select_pwd_work
end type
type st_1 from statictext within w_select_pwd_work
end type
type cb_2 from commandbutton within w_select_pwd_work
end type
type cb_1 from commandbutton within w_select_pwd_work
end type
type gb_1 from groupbox within w_select_pwd_work
end type
type r_1 from rectangle within w_select_pwd_work
end type
end forward

global type w_select_pwd_work from window
integer width = 1705
integer height = 1060
boolean titlebar = true
string title = "Change Password"
boolean controlmenu = true
boolean minbox = true
long backcolor = 29478337
event ue_close ( )
event ue_save ( )
st_6 st_6
st_5 st_5
st_4 st_4
st_3 st_3
sle_userid sle_userid
st_1 st_1
cb_2 cb_2
cb_1 cb_1
gb_1 gb_1
r_1 r_1
end type
global w_select_pwd_work w_select_pwd_work

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

event ue_save();//String ls_curr_password, ls_new_password, ls_con_password, ls_userid
//String ls_passwd_out, ls_errmsg, ls_passwd_in, ls_path
//String ls_period, ls_action
//DATE	 ld_pwd_expdt
//double ll_return
//Boolean ib_dbconnected, ib_exist
//
//ib_exist = False
//
//iu_cust_db_app = Create u_cust_db_app
//ls_errmsg = space(256)
//ls_passwd_out = space(32)
//ls_passwd_in = space(32)
//ls_userid = sle_userid.Text
//ls_curr_password = sle_cur_password.Text
//ls_new_password = sle_new_password.Text
//ls_con_password = sle_con_password.Text
//
//If IsNull(ls_userid)  Then ls_userid = ""
//If IsNull(ls_curr_password) Then ls_curr_password = ""
//If IsNull(ls_new_password) Then ls_new_password = ""
//If IsNull(ls_con_password) Then ls_con_password = ""
//
//If ls_userid = "" Then
//	f_msg_info(200, Title, "User ID")
//	sle_userid.setFocus()
//	Return
//End If
//
//If ls_curr_password = "" Then
//	f_msg_info(200, Title, "Current Password")
//	sle_cur_password.setFocus()
//	Return
//End If
//
//If ls_new_password = "" Then
//	f_msg_info(200, Title, "New Password")
//	sle_new_password.setFocus()
//	Return
//Else
//	If LenA(ls_new_password) > 15 Then
//		f_msg_usr_err(201, Title, "15자리 이하로 입력하세요.")
//		sle_new_password.setFocus()
//	   Return
//	End If		
//End If
//
//If ls_con_password = "" Then
//	f_msg_info(200, Title, "Confirm Password")
//	sle_con_password.setFocus()
//	Return
//Else
//	If ls_new_password <> ls_con_password Then
//		f_msg_usr_err(100, Title, " New Password <> Confirm Password")
//		sle_con_password.setFocus()
//		Return
//   End If
//End If
//
//IF ls_curr_password = ls_new_password THEN
//	f_msg_usr_err(201, Title, "새로운 비밀번호를 변경하세요")
//	sle_new_password.setFocus()
//	Return	
//END IF
//
//if wf_password_validation(ls_userid, ls_new_password) < 0 then Return
//
////입력한 Password를 변경
////SQLCA.PASSWORD_DESENCRYPT(ls_curr_password, ls_passwd_in, ll_return, ls_errmsg)	
////
////SQLCA.PASSWORD_DESENCRYPT(ls_new_password, ls_passwd_out, ll_return, ls_errmsg)	
////If SQLCA.SQLCode < 0 Then		//For Programer
////	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
////	ll_return = -1
////ElseIf ll_return < 0 Then	//For User
////	MessageBox(This.Title, ls_errmsg)
////End If
////
//SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_curr_password)					
//INTO   :ls_passwd_in					
//FROM   DUAL;		
//
//
//SELECT TPKG_CRYPTO.FNC_HASH_SHA512(:ls_new_password)					
//INTO   :ls_passwd_out					
//FROM   DUAL;		
//
//If SQLCA.SQLCode < 0 Then		//For Programer
//	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//	ll_return = -1
//ElseIf ll_return < 0 Then	//For User
//	MessageBox(This.Title, ls_errmsg)
//End If
//
//If ll_return <> 0 Then	//실패
//	Return 
//End If
//
////pw 변경 주기 - 3
//SELECT ref_content		INTO :ls_period		FROM sysctl1t 
//WHERE module = 'U6' AND ref_no = 'A100';	
//
////로그 상태값
//SELECT ref_content		INTO :ls_action		FROM sysctl1t 
//WHERE module = 'U4' AND ref_no = 'A105';	
//
//SELECT ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), TO_NUMBER(:ls_period))
//INTO	 :ld_pwd_expdt
//FROM   DUAL;
//
////Upadate
//Update sysusr1t
//set    password = :ls_passwd_out,
//		 pwd_expdt = :ld_pwd_expdt
//where  emp_id = :ls_userid and password = :ls_passwd_in;
//
//
//If SQLCA.SQLCode < 0 Then		//For Programer
//	Rollback;
//	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//	Return 
//End IF
//
//INSERT INTO SYSUSR_LOG
//	( EMP_ID, SEQ, GUBUN, LOG_STATUS, TIMESTAMP,
//	  CRT_USER, CRTDT, PGM_ID )
//VALUES
//	( :ls_userid, SEQ_SYSUSR.NEXTVAL, 'PWD', :ls_action, SYSDATE,
//	  :ls_userid, SYSDATE, 'PASSWORD');
//
//If SQLCA.SQLCode < 0 Then		//For Programer
//	Rollback;
//	MessageBox(This.Title, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//	Return
//End If
//
//commit;
//f_msg_info(3000,title,"Save")
////
//////Disconnect from db
////iu_cust_db_app.is_caller = "DISCONNECT"
////iu_cust_db_app.is_title = This.Title
////
////iu_cust_db_app.uf_prc_db()
////
//
//
//
//
//
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

on w_select_pwd_work.create
this.st_6=create st_6
this.st_5=create st_5
this.st_4=create st_4
this.st_3=create st_3
this.sle_userid=create sle_userid
this.st_1=create st_1
this.cb_2=create cb_2
this.cb_1=create cb_1
this.gb_1=create gb_1
this.r_1=create r_1
this.Control[]={this.st_6,&
this.st_5,&
this.st_4,&
this.st_3,&
this.sle_userid,&
this.st_1,&
this.cb_2,&
this.cb_1,&
this.gb_1,&
this.r_1}
end on

on w_select_pwd_work.destroy
destroy(this.st_6)
destroy(this.st_5)
destroy(this.st_4)
destroy(this.st_3)
destroy(this.sle_userid)
destroy(this.st_1)
destroy(this.cb_2)
destroy(this.cb_1)
destroy(this.gb_1)
destroy(this.r_1)
end on

event open;f_center_window(w_select_pwd_work)

sle_userid.text = Message.StringParm	
end event

type st_6 from statictext within w_select_pwd_work
integer x = 87
integer y = 812
integer width = 1531
integer height = 48
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "• 영문 대/소문자, 숫자, 특수문자를 조합하여 8자리 이상"
boolean focusrectangle = false
end type

type st_5 from statictext within w_select_pwd_work
integer x = 87
integer y = 736
integer width = 1536
integer height = 48
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "• 연속된 숫자/문자 패턴 입력불가 ( 예 : 123, abc)"
boolean focusrectangle = false
end type

type st_4 from statictext within w_select_pwd_work
integer x = 87
integer y = 660
integer width = 1531
integer height = 48
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "• 동일문자/숫자 3회이상 연속 입력불가 ( 예 : aaa, 222)"
boolean focusrectangle = false
end type

type st_3 from statictext within w_select_pwd_work
integer x = 87
integer y = 580
integer width = 1083
integer height = 48
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "• LOGIN ID와 동일한 비밀번호 사용불가"
boolean focusrectangle = false
end type

type sle_userid from singlelineedit within w_select_pwd_work
integer x = 859
integer y = 1120
integer width = 402
integer height = 84
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean underline = true
long backcolor = 16777215
string text = "none"
end type

type st_1 from statictext within w_select_pwd_work
integer x = 270
integer y = 148
integer width = 1198
integer height = 88
integer textsize = -11
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean underline = true
long textcolor = 134217856
long backcolor = 29478337
string text = "※ 작업할 항목을 선택하세요 ※"
boolean focusrectangle = false
end type

type cb_2 from commandbutton within w_select_pwd_work
integer x = 850
integer y = 244
integer width = 480
integer height = 128
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "비밀번호 재발급"
end type

event clicked;string ls_userid

ls_userid = sle_userid.text

Openwithparm(w_reissue_password , ls_userid)

Close(parent)

end event

type cb_1 from commandbutton within w_select_pwd_work
integer x = 375
integer y = 244
integer width = 480
integer height = 128
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "비밀번호 변경"
end type

event clicked;string ls_userid

ls_userid = sle_userid.text

Openwithparm(w_chg_password_ver2, ls_userid)

Close(parent)
end event

type gb_1 from groupbox within w_select_pwd_work
integer x = 37
integer y = 484
integer width = 1605
integer height = 452
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 134217856
long backcolor = 29478337
string text = "※ 비밀번호 변경 규칙 ※"
borderstyle borderstyle = stylebox!
end type

type r_1 from rectangle within w_select_pwd_work
integer linethickness = 4
long fillcolor = 29478337
integer x = 50
integer y = 64
integer width = 1586
integer height = 372
end type

