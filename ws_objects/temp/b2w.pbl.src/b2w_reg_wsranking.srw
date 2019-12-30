$PBExportHeader$b2w_reg_wsranking.srw
$PBExportComments$[jsha] 출중계호우선순위관리
forward
global type b2w_reg_wsranking from w_a_reg_m
end type
type cb_create from commandbutton within b2w_reg_wsranking
end type
end forward

global type b2w_reg_wsranking from w_a_reg_m
event ue_create ( )
cb_create cb_create
end type
global b2w_reg_wsranking b2w_reg_wsranking

event ue_create();DateTime ldt_yyyymmddhh
Long ll_sec
String ls_yyyymmddhh, ls_sec
Int li_rc
b2u_dbmgr2 lu_dbmgr

dw_cond.AcceptText()

ldt_yyyymmddhh = dw_cond.Object.yyyymmddhh[1]
ls_yyyymmddhh = String(ldt_yyyymmddhh, 'yyyymmddhh')
ll_sec = dw_cond.Object.sec[1]
ls_sec = String(ll_sec)

If IsNull(ls_yyyymmddhh) Then ls_yyyymmddhh = ""
If IsNull(ls_sec) Then ls_sec = ""

If ls_yyyymmddhh = "" Then
	f_msg_usr_err(200, This.Title, "작업기준시간")
	dw_cond.SetColumn("yyyymmddhh")
	dw_cond.SetFocus()
	Return
End If
If ls_sec = "" OR ls_sec = "0" Then
	f_msg_usr_err(200, This.Title, "사용단위")
	dw_cond.SetColumn("sec")
	dw_cond.SetFocus()
	Return
End If

lu_dbmgr = Create b2u_dbmgr2
lu_dbmgr.is_caller = "b2w_inq_wsranking%ue_create()"
lu_dbmgr.is_title = This.Title
lu_dbmgr.idt_data[1] = ldt_yyyymmddhh
lu_dbmgr.il_data[1] = ll_sec
lu_dbmgr.is_data[1] = gs_user_id
lu_dbmgr.is_data[2] = gs_pgm_id[gi_max_win_no]

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	f_msg_info(3010, This.Title, "자료생성")
	Destroy lu_dbmgr
	return
End If

Destroy lu_dbmgr

f_msg_info(3000, This.Title, "자료생성")

This.TriggerEvent("ue_reset")
This.TriggerEvent("ue_ok")
end event

on b2w_reg_wsranking.create
int iCurrent
call super::create
this.cb_create=create cb_create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_create
end on

on b2w_reg_wsranking.destroy
call super::destroy
destroy(this.cb_create)
end on

event ue_ok();call super::ue_ok;String ls_zoncod, ls_where
Long ll_row

ls_zoncod = dw_cond.Object.zoncod[1]
If IsNull(ls_zoncod) Then ls_zoncod = ""

ls_where = ""

If ls_zoncod <> "" Then
	ls_where += " zoncod = '" + ls_zoncod + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

//cb_create.enabled = false

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If
end event

event type integer ue_reset();call super::ue_reset;cb_create.enabled = true

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_wsranking
integer width = 1659
integer height = 288
string dataobject = "b2dw_cnd_inq_wsranking"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_wsranking
integer x = 1865
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b2w_reg_wsranking
integer x = 2171
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_wsranking
integer width = 1705
integer height = 356
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_wsranking
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_wsranking
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b2w_reg_wsranking
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_wsranking
integer y = 396
integer height = 1164
string dataobject = "b2dw_inq_wsranking"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;If rowcount > 0 Then
	//p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	//dw_cond.Enabled = False
End If

end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_wsranking
end type

type cb_create from commandbutton within b2w_reg_wsranking
integer x = 1865
integer y = 212
integer width = 402
integer height = 96
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "자료생성"
end type

event clicked;Parent.TriggerEvent('ue_create')
end event

