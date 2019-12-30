$PBExportHeader$w_reg_user_group.srw
$PBExportComments$[jsha] 웹사용자그룹관리
forward
global type w_reg_user_group from w_a_reg_m
end type
end forward

global type w_reg_user_group from w_a_reg_m
integer width = 2277
end type
global w_reg_user_group w_reg_user_group

on w_reg_user_group.create
call super::create
end on

on w_reg_user_group.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_user_group_id, ls_name
Long ll_row

ls_user_group_id = fs_snvl(dw_cond.Object.user_group_id[1], "")
ls_name = fs_snvl(dw_cond.Object.name[1], "")

ls_where = ""
If ls_user_group_id <> "" Then
	ls_where = " user_group_id = '" + ls_user_Group_id + "' "
End If

If ls_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " name LIKE '%"  + ls_name + "%' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
	p_insert.TriggerEvent('ue_enable')
	p_delete.TriggerEvent('ue_enable')
	p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_user_group_id

SELECT seq_user_group.nextval
INTO	:ls_user_group_id
FROM	dual;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "SEQ_USER_GROUP ERROR")
	Return -2
End If

dw_detail.Object.user_group_id[al_insert_row] = ls_user_group_id

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_user_group
integer width = 1339
integer height = 248
string dataobject = "d_cnd_reg_user_group"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_user_group
integer x = 1600
integer y = 52
end type

type p_close from w_a_reg_m`p_close within w_reg_user_group
integer x = 1906
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_user_group
integer width = 1449
integer height = 332
end type

type p_delete from w_a_reg_m`p_delete within w_reg_user_group
end type

type p_insert from w_a_reg_m`p_insert within w_reg_user_group
end type

type p_save from w_a_reg_m`p_save within w_reg_user_group
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_user_group
integer y = 348
integer width = 2071
integer height = 1224
string dataobject = "d_reg_user_group"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_user_group
end type

