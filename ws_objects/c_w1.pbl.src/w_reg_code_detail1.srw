$PBExportHeader$w_reg_code_detail1.srw
$PBExportComments$(jsj) code 등록 ( from w_a_reg_m_m)
forward
global type w_reg_code_detail1 from w_a_reg_m_m
end type
end forward

global type w_reg_code_detail1 from w_a_reg_m_m
integer width = 3090
integer height = 2044
end type
global w_reg_code_detail1 w_reg_code_detail1

on w_reg_code_detail1.create
call super::create
end on

on w_reg_code_detail1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
Int li_return
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
	ls_where = ls_where + "grcodenm like '%" + ls_desc + "%" + "'"
End If

dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

If ll_row <= 0 Then
	Beep(1)
	
	If ll_row = 0 Then
		f_msg_usr_err(1100,This.Title,"CODE OR DESC")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100,This.Title,"DATAWINDOW RETRIEVE()")
	End if
	
	dw_cond.SetFocus()
	dw_cond.SetColumn("sle_code")
	Return
End if


end event

event ue_extra_insert;dw_detail.Object.grcode[al_insert_row] = &
 dw_master.Object.grcode[dw_master.GetSelectedRow(0)]

dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)
Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_code_detail1
integer x = 59
integer y = 88
integer width = 2126
integer height = 132
string dataobject = "d_cnd_code_desc"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_code_detail1
integer x = 2309
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within w_reg_code_detail1
integer x = 2606
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_code_detail1
integer width = 2194
integer height = 260
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_code_detail1
integer y = 280
integer width = 2999
integer height = 496
string dataobject = "d_inq_group_code1"
end type

event dw_master::constructor;call super::constructor;dwobject ldwo_sort

ldwo_sort = This.Object.grcode_t

This.uf_init(ldwo_sort)//,"a",RGB(255,255,255))
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_code_detail1
integer y = 820
integer width = 2999
integer height = 936
string dataobject = "d_reg_code_detail1"
end type

event ue_retrieve;String ls_grcode

ls_grcode = dw_master.Object.grcode[al_select_row]

dw_detail.is_where = "grcode  = '" + ls_grcode + "'"

If dw_detail.Retrieve() < 0 Then
	Return -1
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;ib_downarrow = True
end event

type p_insert from w_a_reg_m_m`p_insert within w_reg_code_detail1
integer x = 37
integer y = 1784
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_code_detail1
integer x = 329
integer y = 1784
end type

type p_save from w_a_reg_m_m`p_save within w_reg_code_detail1
integer x = 631
integer y = 1784
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_code_detail1
integer x = 1367
integer y = 1784
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_code_detail1
integer y = 780
end type

