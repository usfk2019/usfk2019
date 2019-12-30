$PBExportHeader$w_chg_password.srw
$PBExportComments$[ceusee] 사용자 패스워드 변경
forward
global type w_chg_password from window
end type
type sle_userid from singlelineedit within w_chg_password
end type
type sle_con_password from singlelineedit within w_chg_password
end type
type sle_new_password from singlelineedit within w_chg_password
end type
type sle_cur_password from singlelineedit within w_chg_password
end type
type st_4 from statictext within w_chg_password
end type
type st_3 from statictext within w_chg_password
end type
type st_2 from statictext within w_chg_password
end type
type st_1 from statictext within w_chg_password
end type
type p_save from u_p_save within w_chg_password
end type
type p_close from u_p_close within w_chg_password
end type
type mle_1 from multilineedit within w_chg_password
end type
type r_1 from rectangle within w_chg_password
end type
end forward

global type w_chg_password from window
integer width = 1568
integer height = 1008
boolean titlebar = true
string title = "Change Password"
boolean controlmenu = true
boolean minbox = true
long backcolor = 29478337
event ue_close ( )
event ue_save ( )
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
global w_chg_password w_chg_password

type variables
String is_open
u_cust_db_app iu_cust_db_app   //db조작처리
end variables

event ue_close();//Destroy iu_cust_db_app
Close(This)
end event

event ue_save;String ls_curr_password, ls_new_password, ls_con_password, ls_userid
String ls_passwd_out, ls_errmsg, ls_passwd_in, ls_path
String ls_period, ls_action
DATE	 ld_pwd_expdt
double ll_return
Boolean ib_dbconnected, ib_exist
//ib_dbconnected = False
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
	f_msg_info(200, Title, "Current Password")
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
		f_msg_usr_err(100, Title, "")
		sle_con_password.setFocus()
		Return
   End If
End If

IF ls_curr_password = ls_new_password THEN
	f_msg_usr_err(201, Title, "새로운 비밀번호를 변경하세요")
	sle_new_password.setFocus()
	Return	
END IF

////DB Connection
////***** ini file일 존재하는 directory검색 *****
//ls_path = gs_ini_file
//If Not FileExists(ls_path) Then
//	f_msg_usr_err_app(610, This.Title, ls_path)
//	Return
//End If
//
////DATABASE ProfileString Setting
//gs_database = Upper(ProfileString(ls_path, "database", "database", "ORACLE"))
//
////***** check db is connected, If not, connect *****
//If NOT ib_dbconnected Then
//	//해당 DB로 Connect
//	iu_cust_db_app.is_caller = "CONNECT"
//	iu_cust_db_app.is_title = This.Title
//   iu_cust_db_app.is_data[2] = ""
//	iu_cust_db_app.is_data[1] = gs_database
//	iu_cust_db_app.is_data[2] = gs_ini_file
//   iu_cust_db_app.uf_prc_db()
//
//	If iu_cust_db_app.ii_rc = -1 Then
//		Destroy iu_cust_db_app
//		Return
//	ELSE
//		ib_dbconnected = TRUE
//	End If
//End If


//입력한 Password를 변경
SQLCA.PASSWORD_DESENCRYPT(ls_curr_password, ls_passwd_in, ll_return, ls_errmsg)	

SQLCA.PASSWORD_DESENCRYPT(ls_new_password, ls_passwd_out, ll_return, ls_errmsg)	
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
WHERE module = 'U4' AND ref_no = 'A105';	

SELECT ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), TO_NUMBER(:ls_period))
INTO	 :ld_pwd_expdt
FROM   DUAL;

//Upadate
Update sysusr1t
set    password = :ls_passwd_out,
		 pwd_expdt = :ld_pwd_expdt
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

on w_chg_password.create
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
this.Control[]={this.sle_userid,&
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

on w_chg_password.destroy
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

event open;f_center_window(w_chg_password)

sle_userid.text = Message.StringParm	
end event

type sle_userid from singlelineedit within w_chg_password
integer x = 649
integer y = 260
integer width = 613
integer height = 84
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
end type

type sle_con_password from singlelineedit within w_chg_password
integer x = 649
integer y = 556
integer width = 613
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

type sle_new_password from singlelineedit within w_chg_password
integer x = 649
integer y = 456
integer width = 613
integer height = 84
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
boolean password = true
end type

type sle_cur_password from singlelineedit within w_chg_password
integer x = 649
integer y = 356
integer width = 613
integer height = 84
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 16777215
boolean password = true
end type

type st_4 from statictext within w_chg_password
integer x = 146
integer y = 468
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

type st_3 from statictext within w_chg_password
integer x = 146
integer y = 572
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

type st_2 from statictext within w_chg_password
integer x = 146
integer y = 372
integer width = 453
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "Current Password"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_1 from statictext within w_chg_password
integer x = 347
integer y = 268
integer width = 251
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "User ID"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_save from u_p_save within w_chg_password
integer x = 910
integer y = 768
end type

type p_close from u_p_close within w_chg_password
integer x = 1211
integer y = 768
end type

type mle_1 from multilineedit within w_chg_password
integer x = 110
integer y = 76
integer width = 1362
integer height = 156
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "비밀번호 도용을 방지하기 위하여 타인이 쉽게 유추 할 수 있는 생일, 전화번호등의 사용은 가급적 피해 주십시오. "
boolean border = false
end type

type r_1 from rectangle within w_chg_password
integer linethickness = 1
long fillcolor = 29478337
integer x = 55
integer y = 40
integer width = 1445
integer height = 668
end type

