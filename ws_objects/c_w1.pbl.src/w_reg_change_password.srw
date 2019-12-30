$PBExportHeader$w_reg_change_password.srw
$PBExportComments$(jsj) Change Password
forward
global type w_reg_change_password from w_base
end type
type p_1 from u_p_ok within w_reg_change_password
end type
type p_2 from u_p_cancel within w_reg_change_password
end type
type st_1 from statictext within w_reg_change_password
end type
type st_2 from statictext within w_reg_change_password
end type
type st_3 from statictext within w_reg_change_password
end type
type st_4 from statictext within w_reg_change_password
end type
type sle_cur_pass from singlelineedit within w_reg_change_password
end type
type sle_new_pass from singlelineedit within w_reg_change_password
end type
type sle_ver_pass from singlelineedit within w_reg_change_password
end type
type st_userid from statictext within w_reg_change_password
end type
end forward

global type w_reg_change_password from w_base
integer x = 937
integer y = 788
integer width = 1655
integer height = 624
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowstate windowstate = normal!
event ue_ok ( )
event ue_cancel ( )
p_1 p_1
p_2 p_2
st_1 st_1
st_2 st_2
st_3 st_3
st_4 st_4
sle_cur_pass sle_cur_pass
sle_new_pass sle_new_pass
sle_ver_pass sle_ver_pass
st_userid st_userid
end type
global w_reg_change_password w_reg_change_password

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app
end variables

event ue_ok;call super::ue_ok;String ls_password,ls_new_pass,ls_ver_pass

ls_password = Trim(sle_cur_pass.text)

If IsNull(ls_password) or ls_password = "" Then
	Beep(1)
	f_msg_info_app(402,This.Title,"")
	sle_cur_pass.SetFocus()
	Return
End If

ls_new_pass = Trim(sle_new_pass.text)

If IsNull(ls_new_pass) or ls_new_pass = "" Then
	Beep(1)
	f_msg_info_app(403,This.Title,"")
	sle_new_pass.SetFocus()
	Return
End If

ls_ver_pass = Trim(sle_ver_pass.text)

If IsNull(ls_ver_pass) or ls_ver_pass = "" Then
	Beep(1)
	f_msg_info_app(404,This.Title,"")
	sle_ver_pass.SetFocus()
	Return
End If

If ls_new_pass <> ls_ver_pass Then
	Beep(1)
	f_msg_info_app(405,This.Title,"")
	sle_ver_pass.SetFocus()
	Return
End If

iu_cust_db_app.is_caller = "Get User's Authority"
iu_cust_db_app.is_title =  This.Title
iu_cust_db_app.is_data[1] = gs_user_id
iu_cust_db_app.is_data[2] = ls_password

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc =  -1 Then
	Beep(1)
	sle_cur_pass.SetFocus()
	Return
End If

If iu_cust_db_app.is_rc = 'NOTHING' Then
	Beep(1)
	f_msg_usr_err(1100,This.Title + '(Password Check)','Invalid Password')
	sle_cur_pass.SetFocus()
	Return
End If

//New Password Update
iu_cust_db_app.is_caller = "New User Password Update"
iu_cust_db_app.is_title =  This.Title
iu_cust_db_app.is_data[1] = gs_user_id
iu_cust_db_app.is_data[2] = ls_new_pass

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc =  -1 Then
	Beep(1)
		
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		sle_cur_pass.SetFocus()
		Return
	End If
	
	f_msg_info(3010,This.Title,"Save")
	Return
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		sle_cur_pass.SetFocus()
		Return
	End If
	f_msg_info(3000,This.Title,"Save")
End If
end event

event ue_cancel;call super::ue_cancel;Close(This)
end event

on w_reg_change_password.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_2=create p_2
this.st_1=create st_1
this.st_2=create st_2
this.st_3=create st_3
this.st_4=create st_4
this.sle_cur_pass=create sle_cur_pass
this.sle_new_pass=create sle_new_pass
this.sle_ver_pass=create sle_ver_pass
this.st_userid=create st_userid
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_2
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.st_2
this.Control[iCurrent+5]=this.st_3
this.Control[iCurrent+6]=this.st_4
this.Control[iCurrent+7]=this.sle_cur_pass
this.Control[iCurrent+8]=this.sle_new_pass
this.Control[iCurrent+9]=this.sle_ver_pass
this.Control[iCurrent+10]=this.st_userid
end on

on w_reg_change_password.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_2)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.st_4)
destroy(this.sle_cur_pass)
destroy(this.sle_new_pass)
destroy(this.sle_ver_pass)
destroy(this.st_userid)
end on

event open;call super::open;iu_cust_db_app = Create u_cust_db_app

st_userid.text = gs_user_id 
end event

event close;call super::close;Destroy iu_cust_db_app
end event

type p_1 from u_p_ok within w_reg_change_password
integer x = 1326
integer y = 68
end type

type p_2 from u_p_cancel within w_reg_change_password
integer x = 1326
integer y = 180
integer height = 96
end type

type st_1 from statictext within w_reg_change_password
integer x = 453
integer y = 64
integer width = 251
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "USER ID"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_2 from statictext within w_reg_change_password
integer x = 338
integer y = 172
integer width = 366
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "PASSWORD"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_3 from statictext within w_reg_change_password
integer x = 183
integer y = 276
integer width = 521
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "NEW PASSWORD"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_4 from statictext within w_reg_change_password
integer x = 110
integer y = 380
integer width = 594
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "VERIFY PASSWORD"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_cur_pass from singlelineedit within w_reg_change_password
integer x = 754
integer y = 172
integer width = 480
integer height = 76
integer taborder = 10
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 16777215
boolean autohscroll = false
boolean password = true
integer limit = 8
end type

type sle_new_pass from singlelineedit within w_reg_change_password
integer x = 754
integer y = 276
integer width = 480
integer height = 76
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 16777215
boolean autohscroll = false
boolean password = true
integer limit = 8
end type

type sle_ver_pass from singlelineedit within w_reg_change_password
integer x = 754
integer y = 380
integer width = 480
integer height = 76
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 16777215
boolean autohscroll = false
boolean password = true
integer limit = 8
end type

type st_userid from statictext within w_reg_change_password
integer x = 754
integer y = 64
integer width = 480
integer height = 76
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 12632256
boolean enabled = false
alignment alignment = center!
boolean border = true
borderstyle borderstyle = styleraised!
boolean focusrectangle = false
end type

