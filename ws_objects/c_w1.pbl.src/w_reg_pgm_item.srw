$PBExportHeader$w_reg_pgm_item.srw
$PBExportComments$Reg : Program item(from w_a_reg_m)
forward
global type w_reg_pgm_item from w_a_reg_m
end type
end forward

global type w_reg_pgm_item from w_a_reg_m
integer width = 3227
integer height = 2004
end type
global w_reg_pgm_item w_reg_pgm_item

type variables
//Menu Refresh
Boolean ib_menu_refresh = False

end variables

on w_reg_pgm_item.create
call super::create
end on

on w_reg_pgm_item.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;Integer li_return
Long ll_row
String ls_where
String ls_type, ls_id, ls_name, ls_parent

//입력 조건 처리 부분
ls_type = Trim(String(dw_cond.Object.item_type[1]))
If IsNull(ls_type) Then ls_type = ""
ls_id = Trim(String(dw_cond.Object.item_id[1]))
If IsNull(ls_id) Then ls_id = ""
ls_parent = Trim(String(dw_cond.Object.p_pgm_id[1]))
If IsNull(ls_parent) Then ls_parent = ""
ls_name = Trim(String(dw_cond.Object.item_name[1]))
If IsNull(ls_name) Then ls_name = ""

//에러 처리부분

//Dynamic SQL 처리부분
ls_where = ""
If ls_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "item_type = '" + ls_type + "'"
End If

If ls_id <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pgm_id like '" + ls_id + "%'"
End If

If ls_parent <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_pgm_id like '" + ls_parent + "%'"
End If

If ls_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pgm_nm like '%" + ls_name + "%'"
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_extra_save;Date ld_now
Long ll_mrow_cnt, ll_row_cnt

//***** Record when modified or created ****
//Read today & current time
iu_cust_db_app.is_caller = "NOW"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return -1

ld_now = Date(iu_cust_db_app.idt_data[1])

//Record
ll_row_cnt = dw_detail.RowCount()

Do While ll_mrow_cnt <= ll_row_cnt
	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
	If ll_mrow_cnt > 0 Then
		dw_detail.Object.reg_dt[ll_mrow_cnt] = ld_now
	Else
		ll_mrow_cnt = ll_row_cnt + 1
	End If
Loop

If dw_detail.ModifiedCount() > 0 Or dw_detail.DeletedCount() > 0 Then
	ib_menu_refresh = True
End If

Return 0

end event

event ue_save;// kenn : 1999-09-09 木*********************************
// Override Ancestor Script
// Menu Refresh 기능을 추가함
//******************************************************
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	Beep(1)
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	Beep(1)
	dw_detail.SetFocus()
	Return LI_ERROR
End If

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

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_pgm_item
integer x = 46
integer width = 1920
integer height = 280
string dataobject = "d_cnd_pgm_item"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_pgm_item
integer x = 2565
integer y = 44
end type

type p_close from w_a_reg_m`p_close within w_reg_pgm_item
integer x = 2866
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_pgm_item
integer height = 344
end type

type p_delete from w_a_reg_m`p_delete within w_reg_pgm_item
integer y = 1704
end type

type p_insert from w_a_reg_m`p_insert within w_reg_pgm_item
integer y = 1704
end type

type p_save from w_a_reg_m`p_save within w_reg_pgm_item
integer y = 1704
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_pgm_item
integer x = 27
integer y = 364
integer width = 3136
integer height = 1304
string dataobject = "d_reg_pgm_item"
end type

event dw_detail::constructor;call super::constructor;ib_downarrow = True
end event

type p_reset from w_a_reg_m`p_reset within w_reg_pgm_item
integer y = 1704
end type

