$PBExportHeader$w_reg_code_detail2.srw
$PBExportComments$Different Code Table(from w_a_reg_m_m)
forward
global type w_reg_code_detail2 from w_a_reg_m_m
end type
end forward

global type w_reg_code_detail2 from w_a_reg_m_m
integer width = 3113
integer height = 2024
end type
global w_reg_code_detail2 w_reg_code_detail2

type variables

end variables

event ue_ok;call super::ue_ok;String ls_where, ls_where_tmp
Long ll_row
String ls_table, ls_table_name, ls_call_name
Int li_return

//입력 조건 처리 부분
ls_table = Trim(String(dw_cond.Object.table[1]))
ls_table_name = Trim(String(dw_cond.Object.table_name[1]))
ls_call_name = Trim(String(dw_cond.Object.call_name[1]))

//에레 처리부분

//Dynamic SQL 처리부분
If ls_table <> "" Then
	ls_where = "tbl like '" + ls_table + "%'"
End If

If ls_table_name <> "" Then
	ls_where_tmp = "tbl_nm like '" + ls_table_name + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

If ls_call_name <> "" Then
	ls_where_tmp = "call_nm like '" + ls_call_name + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

dw_master.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_row = dw_master.Retrieve()

If ll_row <= 0 Then
	Beep(1)

	If ll_row = 0 Then
		f_msg_info(1000, This.Title, '')
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, This.Title, "Retrieve()")
	End If

	dw_cond.SetFocus()
	dw_cond.SetColumn("table_name")

	Return
End If

end event

on w_reg_code_detail2.create
call super::create
end on

on w_reg_code_detail2.destroy
call super::destroy
end on

event ue_extra_insert;
	
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_code_detail2
integer x = 41
integer width = 2290
integer height = 224
string dataobject = "d_cnd_code_group2"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_code_detail2
integer x = 2441
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within w_reg_code_detail2
integer x = 2743
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_code_detail2
integer width = 2304
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_code_detail2
integer y = 324
integer height = 568
string dataobject = "d_sel_code_group2"
end type

event dw_master::constructor;call super::constructor;dwObject ldwo_sort

ldwo_sort = This.Object.tbl_nm_t

uf_init(ldwo_sort)

end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_code_detail2
integer x = 23
integer y = 932
integer height = 832
end type

event ue_retrieve;Long ll_row
String ls_call_name

ls_call_name = dw_master.Object.call_nm[al_select_row]
This.DataObject = ls_call_name
This.SetTransObject(SQLCA)

ll_row = This.Retrieve()
If ll_row = 0 Then
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If

Return 0

//Long ll_std_cnt, ll_real_cnt, ll_find_rc, ll_i
//String ls_userid, ls_find
//
//dw_detail.SetRedraw(False)
//
//ls_userid = dw_master.Object.emp_id[al_select_row]
//
//dw_detail.Reset()
//
//ll_std_cnt = ids_program.RowCount()
//ll_real_cnt = ids_grp_auth.Retrieve(ls_userid)
//
//For ll_i = 1 To ll_std_cnt
//	dw_detail.InsertRow(ll_std_cnt + 1)
//	dw_detail.Object.emp_id[ll_i] = ls_userid
//	dw_detail.Object.group_id[ll_i] = ids_program.Object.pgm_id[ll_i]
//
//	ls_find = "group_id = '" + String(ids_program.Object.pgm_id[ll_i]) + "'"
//	ll_find_rc = ids_grp_auth.Find(ls_find, 1, ll_real_cnt)
//	If ll_find_rc > 0 Then
//		dw_detail.Object.auth[ll_i] = ids_grp_auth.Object.auth[ll_find_rc]
//		dw_detail.SetItemStatus(ll_i, 0, Primary!, DataModified!)
//		dw_detail.SetItemStatus(ll_i, 0, Primary!, NotModified!)
//		
//		ids_grp_auth.SetItemStatus(ll_find_rc, 0, Primary!, DataModified!)
//	End If
//Next
//
//For ll_i = 1 To ll_real_cnt
//	If ids_grp_auth.GetItemStatus(ll_i, 0, Primary!) <> DataModified! Then
//		ids_grp_auth.DeleteRow(ll_i)
//		ll_i --
//		ll_real_cnt --
//	End If
//Next
//
//ids_grp_auth.Update()
//
//dw_detail.SetSort("group_id")
//dw_detail.Sort()
//
//dw_detail.SetRedraw(True)
end event

type p_insert from w_a_reg_m_m`p_insert within w_reg_code_detail2
integer y = 1788
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_code_detail2
integer y = 1788
end type

type p_save from w_a_reg_m_m`p_save within w_reg_code_detail2
integer y = 1788
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_code_detail2
integer x = 1362
integer y = 1788
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_code_detail2
integer y = 896
end type

