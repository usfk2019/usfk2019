$PBExportHeader$w_reg_code_group1.srw
$PBExportComments$(jsj) Group code 등록 (from w_a_reg_m)
forward
global type w_reg_code_group1 from w_a_reg_m
end type
type gb_1 from groupbox within w_reg_code_group1
end type
end forward

global type w_reg_code_group1 from w_a_reg_m
integer width = 2903
integer height = 1780
gb_1 gb_1
end type
global w_reg_code_group1 w_reg_code_group1

on w_reg_code_group1.create
int iCurrent
call super::create
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_1
end on

on w_reg_code_group1.destroy
call super::destroy
destroy(this.gb_1)
end on

event ue_ok;call super::ue_ok;Long ll_row,ll_i
String ls_code,ls_desc,ls_where

ls_code = dw_cond.Object.sle_code[1]

If ls_code <> '' and Not IsNull(ls_code) Then
	ls_where = ls_where + "grcode like '" + ls_code + "%" + "'"
End If

ls_desc = dw_cond.Object.sle_desc[1]

If ls_desc <> '' and Not IsNull(ls_desc) Then
	If ls_where <> "" Then
		ls_where = ls_where + " and "
	End If
	ls_where = ls_where + "grcodenm like '" + ls_desc + "%" + "'"
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()


If ll_row = 0 Then
	f_msg_usr_err(1100,This.Title,"CODE OR DESC")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100,This.Title,"DATAWINDOW RETRIEVE()")
	Return
End if
	
dw_cond.SetFocus()
dw_cond.SetColumn("sle_code")	

p_ok.TriggerEvent('ue_disable')
p_insert.TriggerEvent('ue_enable')
p_delete.TriggerEvent('ue_enable')
p_save.TriggerEvent('ue_enable')
p_reset.TriggerEvent('ue_enable')
dw_cond.Enabled = False
dw_detail.SetFocus()

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_code_group1
integer x = 64
integer y = 64
integer width = 2002
integer height = 108
string dataobject = "d_cnd_code_desc"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_code_group1
integer x = 2208
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within w_reg_code_group1
integer x = 2514
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_code_group1
integer width = 2085
integer height = 208
end type

type p_delete from w_a_reg_m`p_delete within w_reg_code_group1
integer x = 334
integer y = 1532
end type

type p_insert from w_a_reg_m`p_insert within w_reg_code_group1
integer x = 41
integer y = 1532
string pointer = "harrow.cur"
end type

type p_save from w_a_reg_m`p_save within w_reg_code_group1
integer x = 631
integer y = 1532
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_code_group1
integer y = 232
integer width = 2793
integer height = 1276
string dataobject = "d_reg_code_group"
end type

event dw_detail::constructor;call super::constructor;ib_downarrow = True
end event

type p_reset from w_a_reg_m`p_reset within w_reg_code_group1
integer x = 1042
integer y = 1536
end type

type gb_1 from groupbox within w_reg_code_group1
integer x = 37
integer y = 4
integer width = 2057
integer height = 184
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 29478337
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

