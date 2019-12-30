$PBExportHeader$w_login_1.srw
$PBExportComments$[ceusee] 암호화된 Login
forward
global type w_login_1 from window
end type
type ddlb_shop from dropdownlistbox within w_login_1
end type
type st_shop from statictext within w_login_1
end type
type p_2 from u_p_change within w_login_1
end type
type st_2 from statictext within w_login_1
end type
type st_1 from statictext within w_login_1
end type
type sle_password from singlelineedit within w_login_1
end type
type sle_user_id from singlelineedit within w_login_1
end type
type p_cancel from u_p_cancel within w_login_1
end type
type p_ok from u_p_ok within w_login_1
end type
type p_1 from picture within w_login_1
end type
end forward

global type w_login_1 from window
integer x = 549
integer y = 236
integer width = 1883
integer height = 1600
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
long backcolor = 29478337
event ue_ok ( )
event ue_cancel ( )
event ue_change ( )
ddlb_shop ddlb_shop
st_shop st_shop
p_2 p_2
st_2 st_2
st_1 st_1
sle_password sle_password
sle_user_id sle_user_id
p_cancel p_cancel
p_ok p_ok
p_1 p_1
end type
global w_login_1 w_login_1

type variables
Private :
 Boolean ib_dbconnected = False //DB 접속 여부
 Boolean ib_exit = False       //Window종료여부

 u_cust_db_app iu_cust_db_app //db조작처리
 Boolean ib_open = False

end variables

event ue_ok();String ls_path, ls_user_id, ls_password, ls_pwd_expdt
DateTime ldt_login
String ls_last_login, ls_last_logout
double ll_return
String ls_passwd_out, ls_errmsg, ls_userlock
Long	 ll_days

IF GS_SHOPID = '' THEN
	f_msg_usr_err(9000, Title, "Shop을 선택 하세요.")
	ddlb_shop.SetFocus()
	return
END IF

ls_errmsg = space(256)
ls_passwd_out = space(32)

//***** Setting Mouse Cursor to HourGlass *****
SetPointer(HourGlass!)

//***** check userid and password are typed in *****
ls_user_id = Trim(sle_user_id.Text)
ls_password = Trim(sle_password.Text)

If Trim(ls_user_id) = "" Then
	f_msg_info_app(401, This.Title, "")
	sle_user_id.SetFocus()
	Return
ElseIf Trim(ls_password) = "" Then
	f_msg_info_app(402, This.Title, "")
	sle_password.SetFocus()
	Return
ElseIf Trim(ls_password) <> "" Then
	If LenA(ls_password) > 15  or LenA(ls_password) < 8  Then
		f_msg_usr_err(201, Title, "비밀번호는 8자리 이상 15자리 이하로 입력하세요.")
		sle_password.SetFocus()
		Return
	End If
End If

////***** ini file일 존재하는 directory검색 *****
ls_path = gs_ini_file
If Not FileExists(ls_path) Then
	f_msg_usr_err_app(610, This.Title, ls_path)
	Return
End If
//
////DATABASE ProfileString Setting
//gs_database = Upper(ProfileString(ls_path, "database", "database", "ORACLE"))
//GS_PRN 		= Upper(ProfileString(ls_path, "POS", 		"PRN", "COM1;6;2;0"))
//GS_DSP 		= Upper(ProfileString(ls_path, "POS", 		"DSP", "COM2;6;2;0"))
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
//		Return
//	ELSE
//		ib_dbconnected = TRUE
//	End If
//End If
//
//암호화된 Password를 넘겨야 한다. 20031110 choi bora
//SQLCA.PASSWORD_DESENCRYPT(ls_password, ls_passwd_out, ll_return, ls_errmsg)
//
//clipboard(ls_passwd_out)
//


		
Blob lblb_data
Blob lblb_sha512


lblb_data = Blob(ls_password, EncodingANSI! )

CrypterObject lnv_CrypterObject
lnv_CrypterObject = Create CrypterObject

// Encrypt with SHA
lblb_sha512= lnv_CrypterObject.SHA(SHA512!, lblb_data)
	
CoderObject lnv_CoderObject
lnv_CoderObject = Create CoderObject

ls_passwd_out = lower(lnv_CoderObject.HexEncode(lblb_sha512))


//clipboard(ls_passwd_out)
//messagebox("ls_passwd_out", ls_passwd_out) 
//return
	
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

If ll_return <> 0 Then	//실패
	Return 
End If




// verify userid and password are accepted
iu_cust_db_app.is_caller = "Get User's Authority"
iu_cust_db_app.is_title = This.Title 
iu_cust_db_app.is_data[1] = ls_user_id
iu_cust_db_app.is_data[2] = trim(ls_passwd_out) //암호화된 Password
iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return
If iu_cust_db_app.is_rc <> "SOMETHING" Then
	f_msg_info_app(400, This.Title, "")
	sle_user_id.SetFocus()
	Return
End If

SELECT USER_LOCK  INTO :ls_userlock
FROM SYSUSR1T
WHERE EMP_ID = :ls_user_id;

IF ls_userlock = 'Y' THEN
	MessageBox("계정잠금", "CHANGE 버튼을 눌러 비밀번후 재발급 후 로그인 하시기 바랍니다.")	
	Return
END IF

SELECT PWD_EXPDT - TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),
		 TO_CHAR(PWD_EXPDT, 'YYYYMMDD')
INTO   :ll_days, :ls_pwd_expdt
FROM   SYSUSR1T
WHERE  EMP_ID = :ls_user_id;

IF ll_days >= 0 AND ll_days <= 10 THEN
	MessageBox("PASSWORD", "비밀번호 만료일은 " + MidA(ls_pwd_expdt, 5, 2) + '-' + MidA(ls_pwd_expdt, 7, 2) + '-' + MidA(ls_pwd_expdt, 1, 4) + " 입니다." )
ELSEIF ll_days < 0 THEN	
	MessageBox("PASSWORD", "비밀번호 변경후 로그인 하시기 바랍니다.")	
	Return
END IF	

gs_user_id = Trim(ls_user_id)

//Read last logout time
iu_cust_db_app.is_caller = "Read Logout & Login-Time"
iu_cust_db_app.is_title = This.Title 
iu_cust_db_app.is_data[1] = ls_user_id
iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return

If IsNull(iu_cust_db_app.idt_data[1]) Then
	ls_last_login = "Nothing"
Else
	ls_last_login = String(iu_cust_db_app.idt_data[1])
End If

If IsNull(iu_cust_db_app.idt_data[2]) Then
	ls_last_logout = "Nothing"
Else
	ls_last_logout = String(iu_cust_db_app.idt_data[2])
End If

//Read today & current time
iu_cust_db_app.is_caller = "NOW"
iu_cust_db_app.is_title = This.Title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then Return
ldt_login = iu_cust_db_app.idt_data[1]

//Record login time
iu_cust_db_app.is_caller = "Record Login-Time"
iu_cust_db_app.is_title = This.Title  

iu_cust_db_app.is_data[1] = ls_user_id
iu_cust_db_app.idt_data[1] = ldt_login

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title =  This.Title 

	iu_cust_db_app.uf_prc_db()

	Return
Else
	//COMMIT;와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		Return
	End If
End If

//Messageing db-connected, login-time, logout-time
//f_msg_info_app(700, This.Title, SQLCA.DataBase)
//f_msg_info_app(9000, This.Title, SQLCA.DataBase + " connected. ~r~n" + &
// "~r~n" + &
// "Employee ID : " + ls_user_id + "~r~n" + &
// "~r~n" + &
// "Last Login time    : " + ls_last_login + "~r~n" + &
// "Last Logout time   : " + ls_last_logout + "~r~n" + &
// "Current login-time : " + String(ldt_login))
//
//read user's information(department, cost center)
//iu_cust_db_app.is_caller = "Read User's Information"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.is_data[1] = ls_user_id
//
//iu_cust_db_app.uf_prc_db()
//
//If iu_cust_db_app.ii_rc = -1 Then Return

// create w_main window, menu etc... 
// this is called here for the user-friendlyness
If f_cre_w_main(ls_path)  <> 0 Then
	//해당 DB로 Disconnect
	iu_cust_db_app.is_caller = "DISCONNECT"
	iu_cust_db_app.is_title = This.Title 

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then Return

//	wf_CloseWithReturn(-1)
	Return
End If


Close(This)

end event

event ue_cancel();ib_exit = True
If ib_open = True then
	Close(w_chg_password)
end If
Close(This)

end event

event ue_change();String ls_userid
ls_userid = sle_user_id.text
ib_open = True
//Openwithparm(w_chg_password, ls_userid)

Openwithparm(w_select_pwd_work, ls_userid)


end event

on w_login_1.create
this.ddlb_shop=create ddlb_shop
this.st_shop=create st_shop
this.p_2=create p_2
this.st_2=create st_2
this.st_1=create st_1
this.sle_password=create sle_password
this.sle_user_id=create sle_user_id
this.p_cancel=create p_cancel
this.p_ok=create p_ok
this.p_1=create p_1
this.Control[]={this.ddlb_shop,&
this.st_shop,&
this.p_2,&
this.st_2,&
this.st_1,&
this.sle_password,&
this.sle_user_id,&
this.p_cancel,&
this.p_ok,&
this.p_1}
end on

on w_login_1.destroy
destroy(this.ddlb_shop)
destroy(this.st_shop)
destroy(this.p_2)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.sle_password)
destroy(this.sle_user_id)
destroy(this.p_cancel)
destroy(this.p_ok)
destroy(this.p_1)
end on

event closequery;//If Not ib_exit Then Return 1
If ib_exit And ib_dbconnected Then
	iu_cust_db_app.is_caller = "DISCONNECT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		Return 1
	End If
End If

end event

event open;string ls_path
Int		li_sw = 0

iu_cust_db_app = Create u_cust_db_app

//Title 설정
This.Title = "LOGIN"

// Window를 화면 중앙에 ...
f_center_window(w_login_1)


//***** ini file일 존재하는 directory검색 *****
ls_path = gs_ini_file
If Not FileExists(ls_path) Then
	f_msg_usr_err_app(610, This.Title, ls_path)
	Return
End If

//DATABASE ProfileString Setting
gs_database = Upper(ProfileString(ls_path, "database", "database", "ORACLE"))
GS_PRN 		= Upper(ProfileString(ls_path, "POS", 		"PRN", "COM1;6;2;0"))
GS_DSP 		= Upper(ProfileString(ls_path, "POS", 		"DSP", "COM2;6;2;0"))

//***** check db is connected, If not, connect ***** db download 방식 적용하면 comment 처리할것 mkhan 2019/10/30
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
//		Return
//	ELSE
//		ib_dbconnected = TRUE
//	End If
//End If

String ls_id, ls_shopID, ls_ShopNM, ls_list

DECLARE read_batch CURSOR FOR  
 select trim(partner),  trim(partnernm)  from partnermst
  ORDER BY partnernm asc ;

open read_batch;
fetch read_batch into :ls_shopid, :ls_shopnm;

do while sqlca.sqlcode = 0 
	ls_list =  LeftA(ls_shopnm + space(60), 60) + LeftA(ls_shopid + Space(10), 10)
	ddlb_shop.additem(ls_list)
	fetch read_batch into :ls_shopid, :ls_shopnm;
loop
close read_batch;


end event

event key;Choose Case key
	Case KeyEnter!
		TriggerEvent("ue_ok")
	Case KeyEscape!
		TriggerEvent("ue_cancel")
End Choose
end event

event close;Destroy iu_cust_db_app

end event

type ddlb_shop from dropdownlistbox within w_login_1
integer x = 398
integer y = 1364
integer width = 800
integer height = 504
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "none"
boolean sorted = false
boolean vscrollbar = true
end type

event selectionchanged;

GS_SHOPNM  = trim(LeftA(this.text, 60))
GS_SHOPID =  Trim(MidA(this.text, 61, 10))
end event

type st_shop from statictext within w_login_1
integer x = 46
integer y = 1360
integer width = 315
integer height = 76
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
boolean enabled = false
string text = "Shop"
alignment alignment = right!
boolean focusrectangle = false
end type

type p_2 from u_p_change within w_login_1
integer x = 1221
integer y = 1200
end type

type st_2 from statictext within w_login_1
integer x = 46
integer y = 1268
integer width = 315
integer height = 76
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
boolean enabled = false
string text = "Password"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_1 from statictext within w_login_1
integer x = 46
integer y = 1168
integer width = 315
integer height = 76
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
boolean enabled = false
string text = "User ID"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_password from singlelineedit within w_login_1
integer x = 398
integer y = 1256
integer width = 448
integer height = 92
integer taborder = 20
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean autohscroll = false
boolean password = true
end type

type sle_user_id from singlelineedit within w_login_1
integer x = 398
integer y = 1152
integer width = 448
integer height = 92
integer taborder = 10
integer textsize = -11
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean autohscroll = false
end type

event modified;String ls_id, ls_shopID, ls_ShopNM, ls_list, ls_list0
Long		ll_pos

ls_id = trim(this.text)
select emp_group   into :ls_ShopId from sysusr1t 
 where emp_id =  :ls_id ;
//
IF IsNull(ls_ShopID) then ls_ShopID = ''

IF ls_ShopID <> '' then
	select partnernm   INTO :ls_ShopNM 	  FROM partnermst
	 WHERE partner = :ls_ShopID    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(ls_ShopNM) then ls_ShopNM = ''
EnD IF
ls_list0 		=  LeftA(ls_shopnm + space(60), 60) + LeftA(ls_shopid + Space(10), 10)
ll_pos = ddlb_shop.FindItem (ls_list0, 0 )
ddlb_shop.Selectitem(ll_pos)

GS_SHOPNM  = trim(LeftA(ddlb_Shop.text, 60))
GS_SHOPID =  Trim(MidA(ddlb_Shop.text, 61, 10))


end event

type p_cancel from u_p_cancel within w_login_1
integer x = 1518
integer y = 1200
integer height = 96
end type

type p_ok from u_p_ok within w_login_1
integer x = 919
integer y = 1200
boolean originalsize = false
end type

type p_1 from picture within w_login_1
integer x = 18
integer y = 8
integer width = 1847
integer height = 1108
boolean originalsize = true
string picturename = "login.jpg"
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

