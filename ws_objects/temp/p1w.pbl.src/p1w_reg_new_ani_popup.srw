$PBExportHeader$p1w_reg_new_ani_popup.srw
$PBExportComments$[parkkh] ani# 등록popup
forward
global type p1w_reg_new_ani_popup from w_a_reg_m
end type
end forward

global type p1w_reg_new_ani_popup from w_a_reg_m
integer width = 2455
integer height = 796
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_change ( )
event ue_add ( )
end type
global p1w_reg_new_ani_popup p1w_reg_new_ani_popup

type variables
String is_ani_syscod[]

end variables

on p1w_reg_new_ani_popup.create
call super::create
end on

on p1w_reg_new_ani_popup.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: p1w_new_aninum_popop
	Desc	: Ani# 등록 (NEW)
	Ver	: 	1.0
	Date	: 	2003.08.22
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
long ll_i

f_center_window(p1w_reg_new_ani_popup)

//ani관리(pin필수여부;인증방법사용여부;인증방법;인증KEY개수)
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P001", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_ani_syscod[])   //ani관리 기본관리 셋팅코드

//dw_cond.insertrow(0)

dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())

//pin 필수여부
If is_ani_syscod[1] = 'Y' Then
	dw_cond.Object.pid.Protect = 0
	dw_cond.Object.pid.Background.Color = RGB(108, 147, 137)
	dw_cond.Object.pid.Color = RGB(255,255,255)
ElseIf is_ani_syscod[1] = 'N' Then
	dw_cond.Object.pid.Protect = 0
	dw_cond.Object.pid.Background.Color = RGB(255,255,255)
	dw_cond.Object.pid.Color =  RGB(0, 0, 0)
End If

//인증방법사용여부
If is_ani_syscod[2] = 'Y' Then
	dw_cond.Object.auth_method[1] = is_ani_syscod[3]
	dw_cond.Object.auth_method.Protect = 0
	dw_cond.Object.auth_method.Background.Color = RGB(108, 147, 137)
	dw_cond.Object.auth_method.Color = RGB(255,255,255)
ElseIf is_ani_syscod[2] = 'N' Then
	dw_cond.Object.auth_method.Protect = 1
	dw_cond.Object.auth_method.Background.Color = RGB(255, 251, 240)
	dw_cond.Object.auth_method.Color =  RGB(0, 0, 0)
End If

p_save.TriggerEvent("ue_enable")
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
lu_dbmgr.is_caller = "p1w_reg_new_ani_popup%save"    
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.is_data[1] = is_ani_syscod[1]              //pin필수여부
lu_dbmgr.is_data[2] = is_ani_syscod[2]				//인증방법사용여부
lu_dbmgr.is_data[3] = gs_pgm_id[gi_open_win_no]     //pgmid
lu_dbmgr.is_data[4] = is_ani_syscod[4]		        //인증Key갯수

lu_dbmgr.uf_prc_db()
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
//	f_msg_info(3010,This.Title,"서비스개통처리")
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
//	f_msg_info(3000,This.Title,"재개통처리")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within p1w_reg_new_ani_popup
integer x = 23
integer width = 2331
integer height = 424
integer taborder = 10
string dataobject = "p1dw_reg_new_ani_popup"
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

type p_ok from w_a_reg_m`p_ok within p1w_reg_new_ani_popup
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within p1w_reg_new_ani_popup
integer x = 2066
integer y = 520
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within p1w_reg_new_ani_popup
boolean visible = false
integer y = 24
integer width = 2528
integer height = 488
long backcolor = 15793151
borderstyle borderstyle = stylebox!
end type

type p_delete from w_a_reg_m`p_delete within p1w_reg_new_ani_popup
boolean visible = false
integer x = 50
integer y = 1432
boolean enabled = true
end type

type p_insert from w_a_reg_m`p_insert within p1w_reg_new_ani_popup
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within p1w_reg_new_ani_popup
integer x = 1733
integer y = 520
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within p1w_reg_new_ani_popup
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

type p_reset from w_a_reg_m`p_reset within p1w_reg_new_ani_popup
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

