$PBExportHeader$b5w_reg_invoice_item_seq.srw
$PBExportComments$[islim] 청구서항목 - invoice  type 추가
forward
global type b5w_reg_invoice_item_seq from w_a_reg_m
end type
end forward

global type b5w_reg_invoice_item_seq from w_a_reg_m
integer width = 2386
integer height = 2040
end type
global b5w_reg_invoice_item_seq b5w_reg_invoice_item_seq

on b5w_reg_invoice_item_seq.create
call super::create
end on

on b5w_reg_invoice_item_seq.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_bilcod ,  ls_inv_type

//입력 조건 처리 부분
ls_bilcod = Trim(dw_cond.Object.bilcod[1])
ls_inv_type = Trim(dw_cond.Object.inv_type[1])
If IsNull(ls_bilcod) Then ls_bilcod = ""
If IsNull(ls_inv_type) Then ls_inv_type = ""

If ls_inv_type = "" Then
	f_msg_usr_err(200, Title, "청구서 유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("inv_type")
	Return 
End If

//Dynamic SQL 처리부분
ls_where = ""
If ls_inv_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "inv_type LIKE '%" + ls_inv_type + "%'"
End If

If ls_bilcod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bilcod LIKE '" + ls_bilcod + "%'"
End If

//자료 읽기 및 관련 처리부분
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If

//dw_detail의 rowcount하고 상관없이 처리한다.
p_ok.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = False

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("bilcod")

//Setting
dw_detail.object.inv_type[al_insert_row] = Trim(dw_cond.object.inv_type[1])

//Log
dw_detail.object.crt_user[al_insert_row]  = gs_user_id
dw_detail.object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row]    = fdt_get_dbserver_now()

Return 0
end event

event open;call super::open;//dw_detail의 rowcount하고 상관없이 처리한다.
p_ok.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
dw_cond.Enabled = True

end event

event type integer ue_extra_save();call super::ue_extra_save;// ****************************************************************************
// BILCOD가 동일하면, BILSEQ들은 동일하고
// BILSEQ는 Null도 가능하다. => 청구서에 출력하지 않는다.
// ****************************************************************************
Integer	li_rc

b5u_check lu_check
lu_check = Create b5u_check

lu_check.is_title = Title
lu_check.is_caller = "b5w_reg_inv_item_seq%1"
lu_check.idw_data[1] = dw_detail
lu_check.uf_prc_check()
li_rc = lu_check.ii_rc
Destroy lu_check
If li_rc < 0 Then
	dw_detail.SetFocus()
End If

Return li_rc
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_invoice_item_seq
integer x = 82
integer y = 56
integer width = 1230
integer height = 216
string dataobject = "b5d_cnd_reg_inv_item_seq"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_invoice_item_seq
integer x = 1513
integer y = 112
end type

type p_close from w_a_reg_m`p_close within b5w_reg_invoice_item_seq
integer x = 1861
integer y = 112
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_invoice_item_seq
integer y = 12
integer width = 1394
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_invoice_item_seq
integer x = 334
integer y = 1712
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_invoice_item_seq
integer x = 23
integer y = 1712
end type

type p_save from w_a_reg_m`p_save within b5w_reg_invoice_item_seq
integer x = 645
integer y = 1712
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_invoice_item_seq
integer x = 23
integer y = 316
integer width = 2277
integer height = 1360
string dataobject = "b5d_reg_inv_item_seq"
end type

type p_reset from w_a_reg_m`p_reset within b5w_reg_invoice_item_seq
integer x = 1225
integer y = 1712
end type

