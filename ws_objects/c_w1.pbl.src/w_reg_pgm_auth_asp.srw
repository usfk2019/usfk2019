$PBExportHeader$w_reg_pgm_auth_asp.srw
$PBExportComments$Reg : Program authority(from w_a_reg_m_m)
forward
global type w_reg_pgm_auth_asp from w_a_reg_m_m
end type
end forward

global type w_reg_pgm_auth_asp from w_a_reg_m_m
integer height = 2000
end type
global w_reg_pgm_auth_asp w_reg_pgm_auth_asp

type variables
//Menu Refresh
Boolean ib_menu_refresh = False

end variables

event ue_ok();call super::ue_ok;String ls_where, ls_where_tmp
Long ll_row
String ls_userid
Int li_return

//입력 조건 처리 부분
ls_userid = Trim(String(dw_cond.Object.sle_userid[1]))

//에레 처리부분

//Dynamic SQL 처리부분
If ls_userid <> "" Then
	ls_where = "emp_id like '" + ls_userid + "%'"
End If

If ls_where <> "" Then
	ls_where = " And asp_id = (select asp_id from sysusr1t where emp_id = '" + gs_user_id + "' ) "
Else
	ls_where = " asp_id = (select asp_id from sysusr1t where emp_id = '" + gs_user_id + "' ) "
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
	dw_cond.SetColumn("sle_userid")

	Return
End If

end event

on w_reg_pgm_auth_asp.create
call super::create
end on

on w_reg_pgm_auth_asp.destroy
call super::destroy
end on

event ue_extra_insert;dw_detail.Object.emp_id[al_insert_row] = &
 dw_master.Object.emp_id[dw_master.GetSelectedRow(0)]

//Set dataWindow's inserted row status to New
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, New!)

Return 0

end event

event ue_extra_save;If dw_detail.ModifiedCount() > 0 Or dw_detail.DeletedCount() > 0 Then
	ib_menu_refresh = True
End If

Return 0

end event

event ue_save;// kenn : 1999-09-09 木*********************************
// Override Ancestor Script
// Menu Refresh 기능을 추가함
//******************************************************
Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	Beep(1)
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	Beep(1)
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	Beep(1)
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	If ib_menu_refresh Then fi_refresh_menu()
	f_msg_info(3000,This.Title,"Save")
End If

//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_pgm_auth_asp
integer width = 1307
integer height = 188
string dataobject = "d_cnd_userid"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_pgm_auth_asp
integer x = 1719
integer y = 48
end type

type p_close from w_a_reg_m_m`p_close within w_reg_pgm_auth_asp
integer x = 2030
integer y = 48
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_pgm_auth_asp
integer width = 1563
integer height = 256
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_pgm_auth_asp
integer y = 268
integer height = 544
string dataobject = "d_sel_userid"
end type

event dw_master::constructor;call super::constructor;dwObject ldwo_sort

ldwo_sort = This.Object.emp_id_t

uf_init(ldwo_sort)

end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_pgm_auth_asp
integer y = 848
string dataobject = "d_reg_pgm_auth"
end type

event ue_retrieve;Long ll_row

ll_row = This.Retrieve(String(dw_master.Object.emp_id[al_select_row]))
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

event dw_detail::ue_init;call super::ue_init;is_help_win = {"w_hlp_pgm_id"}
idwo_help_col = {This.Object.pgm_id}
end event

type p_insert from w_a_reg_m_m`p_insert within w_reg_pgm_auth_asp
integer y = 1732
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_pgm_auth_asp
integer y = 1736
end type

type p_save from w_a_reg_m_m`p_save within w_reg_pgm_auth_asp
integer y = 1736
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_pgm_auth_asp
integer y = 1736
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_pgm_auth_asp
integer x = 32
integer y = 816
end type

