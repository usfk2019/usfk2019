$PBExportHeader$p1w_reg_change_ani_popup.srw
$PBExportComments$[parkkh] ani# 변경popup
forward
global type p1w_reg_change_ani_popup from w_a_reg_m
end type
type st_anino from statictext within p1w_reg_change_ani_popup
end type
type st_1 from statictext within p1w_reg_change_ani_popup
end type
type ln_3 from line within p1w_reg_change_ani_popup
end type
end forward

global type p1w_reg_change_ani_popup from w_a_reg_m
integer width = 2455
integer height = 884
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_change ( )
event ue_add ( )
st_anino st_anino
st_1 st_1
ln_3 ln_3
end type
global p1w_reg_change_ani_popup p1w_reg_change_ani_popup

type variables
String is_ani_syscod[], is_fromdt, is_anino, is_pgm_id
String is_pid_ori


end variables

on p1w_reg_change_ani_popup.create
int iCurrent
call super::create
this.st_anino=create st_anino
this.st_1=create st_1
this.ln_3=create ln_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_anino
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.ln_3
end on

on p1w_reg_change_ani_popup.destroy
call super::destroy
destroy(this.st_anino)
destroy(this.st_1)
destroy(this.ln_3)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: p1w_reg_term_ani_popop
	Desc	: Ani# 등록 (TERM)
	Ver	: 	1.0
	Date	: 	2003.08.22
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
long ll_i

f_center_window(p1w_reg_change_ani_popup)
is_anino = ""
is_fromdt = ""

//iu_cust_msg.is_data[1] = ls_anino	     //validkey
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = is_fromdt           //fromdt

iu_cust_msg = Message.PowerObjectParm
is_anino = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]

st_anino.Text = is_anino

//ani관리(pin필수여부;인증방법사용여부;인증방법;인증KEY개수)
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P001", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_ani_syscod[])   //ani관리 기본관리 셋팅코드

If is_anino <> "" Then
	Post Event ue_ok()
End If
end event

event resize;call super::resize;//변경 추가 버튼 위치 자동조정 추가
If sizetype = 1 Then Return

SetRedraw(False)

p_close.Y	= p_save.Y


SetRedraw(True)
end event

event key;Choose Case key
	Case KeyEscape!
		This.TriggerEvent(is_close)
End Choose

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row
Integer li_rc
p1u_dbmgr1 	lu_dbmgr

ll_row  = dw_cond.RowCount()
If ll_row = 0 Then Return 0

//저장
lu_dbmgr = Create p1u_dbmgr1
lu_dbmgr.is_caller = "p1w_reg_change_ani_popup%save"    
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.is_data[1] = is_anino				//ani#(인증Key)
lu_dbmgr.is_data[2] = is_fromdt				//fromdt
lu_dbmgr.is_data[3] = is_pgm_id				//pgmid
lu_dbmgr.is_data[4] = is_ani_syscod[1]      //pid 사용여부
lu_dbmgr.is_data[5] = is_ani_syscod[2]		//인증Key 사용여부
lu_dbmgr.is_data[6] = is_ani_syscod[4]      //인증Key 갯수
lu_dbmgr.is_data[7] = is_pid_ori            //pin# original

lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1  or li_rc = -2 Then
	Destroy lu_dbmgr
	Return -1
End If

Destroy lu_dbmgr

P_save.TriggerEvent("ue_disable")

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
long li_rc

If dw_cond.AcceptText() < 0 Then
	dw_cond.SetFocus()
	Return LI_ERROR
End If

li_rc = This.Trigger Event ue_extra_save()

If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	Return LI_ERROR

ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

Return 0
end event

event ue_ok();call super::ue_ok;Long ll_row 
String ls_where
//조회

ls_where = " validkey = '" + is_anino + "' AND to_char(fromdt,'yyyymmdd') = '" + is_fromdt + "'"

dw_cond.is_where = ls_where
ll_row = dw_cond.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

is_pid_ori = dw_cond.object.pid[1]

//pin 필수여부
If is_ani_syscod[1] = 'Y' Then
	dw_cond.Object.pid.Protect = 0
	dw_cond.Object.pid.Background.Color = RGB(108, 147, 137)
	dw_cond.Object.pid.Color = RGB(255,255,255)
ElseIf is_ani_syscod[1] = 'N' Then
	dw_cond.Object.pid.Protect = 0
	dw_cond.Object.pid.Color =  RGB(0, 0, 0)
	dw_cond.Object.pid.Background.Color = RGB(255,255,255)
End If

//인증방법사용여부
If is_ani_syscod[2] = 'Y' Then
	dw_cond.Object.auth_method.Protect = 0
	dw_cond.Object.auth_method.Background.Color = RGB(108, 147, 137)
	dw_cond.Object.auth_method.Color = RGB(255,255,255)
ElseIf is_ani_syscod[2] = 'N' Then
	dw_cond.Object.auth_method.Protect = 1
	dw_cond.Object.auth_method.Background.Color = RGB(255, 251, 240)
	dw_cond.Object.auth_method.Color =  RGB(0, 0, 0)
End If

P_save.TriggerEvent("ue_enable")
end event

type dw_cond from w_a_reg_m`dw_cond within p1w_reg_change_ani_popup
integer x = 23
integer y = 160
integer width = 2331
integer height = 392
integer taborder = 10
string dataobject = "p1dw_reg_change_ani_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = true
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "pid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.pid[row] =  &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.pid
This.is_help_win[1] = "p1w_hlp_p_cardmst"
This.is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m`p_ok within p1w_reg_change_ani_popup
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within p1w_reg_change_ani_popup
integer x = 2066
integer y = 620
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within p1w_reg_change_ani_popup
boolean visible = false
integer y = 24
integer width = 2528
integer height = 488
long backcolor = 15793151
borderstyle borderstyle = stylebox!
end type

type p_delete from w_a_reg_m`p_delete within p1w_reg_change_ani_popup
boolean visible = false
integer x = 50
integer y = 1432
boolean enabled = true
end type

type p_insert from w_a_reg_m`p_insert within p1w_reg_change_ani_popup
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within p1w_reg_change_ani_popup
integer x = 1733
integer y = 620
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within p1w_reg_change_ani_popup
boolean visible = false
integer y = 52
integer width = 1257
integer height = 280
integer taborder = 20
string dataobject = "b1dw_reg_validkey_update"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;IF dwo.name= "auth_method" Then
	
	If LeftA(data, 1) = 'D' Then This.object.validitem2[1] = ""

	If MidA(data, 7,1) = 'E' Then This.object.validitem3[1]= ""
	
End If
end event

type p_reset from w_a_reg_m`p_reset within p1w_reg_change_ani_popup
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type st_anino from statictext within p1w_reg_change_ani_popup
integer x = 370
integer y = 64
integer width = 741
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_1 from statictext within p1w_reg_change_ani_popup
integer x = 73
integer y = 64
integer width = 288
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "Ani # : "
alignment alignment = right!
boolean focusrectangle = false
end type

type ln_3 from line within p1w_reg_change_ani_popup
long linecolor = 27306400
integer linethickness = 1
integer beginx = 375
integer beginy = 136
integer endx = 1093
integer endy = 136
end type

