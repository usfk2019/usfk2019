$PBExportHeader$w_login.srw
$PBExportComments$Login 화면 (UserId & Password 받음)
forward
global type w_login from window
end type
type st_2 from statictext within w_login
end type
type st_1 from statictext within w_login
end type
type sle_password from singlelineedit within w_login
end type
type sle_user_id from singlelineedit within w_login
end type
type p_cancel from u_p_cancel within w_login
end type
type p_ok from u_p_ok within w_login
end type
type p_1 from picture within w_login
end type
end forward

global type w_login from window
integer x = 549
integer y = 236
integer width = 1874
integer height = 1436
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
long backcolor = 29478337
event ue_ok ( )
event ue_cancel ( )
st_2 st_2
st_1 st_1
sle_password sle_password
sle_user_id sle_user_id
p_cancel p_cancel
p_ok p_ok
p_1 p_1
end type
global w_login w_login

type variables
Private :
 Boolean ib_dbconnected = False //DB 접속 여부
 Boolean ib_exit = False                //Window종료여부

 u_cust_db_app iu_cust_db_app //db조작처리

end variables

event ue_ok();String ls_path, ls_user_id, ls_password
DateTime ldt_login
String ls_last_login, ls_last_logout

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
End If

//***** ini file일 존재하는 directory검색 *****
//ls_path = gs_ini_file
//If Not FileExists(ls_path) Then
//	f_msg_usr_err_app(610, This.Title, ls_path)
//	Return
//End If
//
//DATABASE ProfileString Setting
//gs_database = Upper(ProfileString(ls_path, "database", "database", "ORACLE"))

//***** check db is connected, If not, connect *****
//If NOT ib_dbconnected Then
//	//해당 DB로 Connect
//	iu_cust_db_app.is_caller = "CONNECT"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.is_data[2] = ""
//	iu_cust_db_app.is_data[1] = gs_database
//	iu_cust_db_app.is_data[2] = gs_ini_file
//
//	iu_cust_db_app.uf_prc_db()
//
//	If iu_cust_db_app.ii_rc = -1 Then
//		Return
//	ELSE
//		ib_dbconnected = TRUE
//	End If
//End If

// verify userid and password are accepted
iu_cust_db_app.is_caller = "Get User's Authority"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.is_data[1] = ls_user_id
iu_cust_db_app.is_data[2] = ls_password

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return

If iu_cust_db_app.is_rc <> "SOMETHING" Then
	f_msg_info_app(400, This.Title, "")
	sle_user_id.SetFocus()
	Return
End If

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
	iu_cust_db_app.is_title = This.Title

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

event ue_cancel;ib_exit = True
Close(This)

end event

on w_login.create
this.st_2=create st_2
this.st_1=create st_1
this.sle_password=create sle_password
this.sle_user_id=create sle_user_id
this.p_cancel=create p_cancel
this.p_ok=create p_ok
this.p_1=create p_1
this.Control[]={this.st_2,&
this.st_1,&
this.sle_password,&
this.sle_user_id,&
this.p_cancel,&
this.p_ok,&
this.p_1}
end on

on w_login.destroy
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

event open;iu_cust_db_app = Create u_cust_db_app

//Title 설정
This.Title = "LOGIN"

// Window를 화면 중앙에 ...
f_center_window(w_login)

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

type st_2 from statictext within w_login
integer x = 123
integer y = 1248
integer width = 443
integer height = 76
integer textsize = -11
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

type st_1 from statictext within w_login
integer x = 123
integer y = 1148
integer width = 443
integer height = 76
integer textsize = -11
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

type sle_password from singlelineedit within w_login
integer x = 599
integer y = 1236
integer width = 480
integer height = 92
integer taborder = 20
integer textsize = -12
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean autohscroll = false
boolean password = true
end type

type sle_user_id from singlelineedit within w_login
integer x = 599
integer y = 1132
integer width = 480
integer height = 92
integer taborder = 10
integer textsize = -12
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
boolean autohscroll = false
end type

type p_cancel from u_p_cancel within w_login
integer x = 1463
integer y = 1184
integer height = 96
end type

type p_ok from u_p_ok within w_login
integer x = 1161
integer y = 1184
boolean originalsize = false
end type

type p_1 from picture within w_login
integer x = 9
integer y = 8
integer width = 1847
integer height = 1108
boolean originalsize = true
string picturename = "login.jpg"
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

