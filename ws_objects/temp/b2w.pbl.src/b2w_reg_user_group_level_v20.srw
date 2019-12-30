$PBExportHeader$b2w_reg_user_group_level_v20.srw
$PBExportComments$[jsha] 대리점레벨별웹사용자그룹관리
forward
global type b2w_reg_user_group_level_v20 from w_a_reg_m_m
end type
end forward

global type b2w_reg_user_group_level_v20 from w_a_reg_m_m
integer width = 2071
integer height = 1416
end type
global b2w_reg_user_group_level_v20 b2w_reg_user_group_level_v20

on b2w_reg_user_group_level_v20.create
call super::create
end on

on b2w_reg_user_group_level_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_levelcod
Long ll_row

ls_levelcod = fs_snvl(dw_cond.Object.levelcod[1], "")
ls_where = ""
If ls_levelcod <> "" Then
	ls_where = " code = '" + ls_levelcod + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "")
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.Object.levelcod[al_insert_row] = &
 dw_master.Object.code[dw_master.GetSelectedRow(0)]

dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)
Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_user_group_level_v20
integer width = 1102
integer height = 136
string dataobject = "b2dw_cnd_reg_user_group_level_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_user_group_level_v20
integer x = 1271
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_user_group_level_v20
integer x = 1577
integer y = 44
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_user_group_level_v20
integer width = 1138
integer height = 200
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_user_group_level_v20
integer y = 224
integer width = 1915
string dataobject = "b2dw_m_reg_user_group_level_v20"
end type

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_user_group_level_v20
integer y = 668
integer width = 1929
integer height = 484
string dataobject = "b2dw_d_reg_user_group_level_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_levelcod, ls_where
Long ll_row

ls_levelcod = dw_master.Object.code[al_select_row]
ls_where = " levelcod = '" + ls_levelcod + "' "

This.is_where = ls_where
ll_row = This.Retrieve()

IF ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If

Return 0
end event

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_user_group_level_v20
integer y = 1180
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_user_group_level_v20
integer y = 1184
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_user_group_level_v20
integer y = 1184
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_user_group_level_v20
integer y = 1184
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_user_group_level_v20
integer y = 636
end type

