$PBExportHeader$b5w_reg_invoice_item_det.srw
$PBExportComments$[islim] 청구서항목내용 - invoice type 추가
forward
global type b5w_reg_invoice_item_det from w_a_reg_m_m
end type
end forward

global type b5w_reg_invoice_item_det from w_a_reg_m_m
integer width = 2286
integer height = 1764
end type
global b5w_reg_invoice_item_det b5w_reg_invoice_item_det

on b5w_reg_invoice_item_det.create
call super::create
end on

on b5w_reg_invoice_item_det.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_bilcod ,ls_inv_type

//입력 조건 처리 부분

ls_inv_type = Trim(dw_cond.object.inv_type[1])
ls_bilcod = Trim(dw_cond.Object.bilcod[1])


If IsNull(ls_inv_type) Then ls_inv_type = ""
If IsNull(ls_bilcod) Then ls_bilcod = ""

If ls_inv_type = "" Then
	f_msg_usr_err(200, Title, "청구서 유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("inv_type")
	Return 
End If

//Dynamic SQL 처리부분
ls_where = ""


If ls_bilcod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bilcod LIKE '" + ls_bilcod + "%'"
End If

If ls_inv_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "inv_type LIKE '%" + ls_inv_type+ "%'"
End If

//자료 읽기 및 관련 처리부분
dw_master.is_where = ls_where
ll_rows = dw_master.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If

end event

event type integer ue_extra_insert(long al_insert_row);//Log 정보
dw_detail.object.inv_type[al_insert_row] = dw_master.object.inv_type[dw_master.GetSelectedRow(0)]
dw_detail.Object.bilcod[al_insert_row] = dw_master.Object.bilcod[dw_master.GetSelectedRow(0)]
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row] = gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

//dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_rows
String ls_trcod
Int li_cnt

ll_rows = dw_detail.RowCount()
If ll_rows <= 0 Then Return 0

For li_cnt = 1 to ll_rows
	ls_trcod = dw_detail.object.trcod[li_cnt]
	
	If IsNull(ls_trcod) Then ls_trcod = ""
	
	If ls_trcod = "" Then
		f_msg_usr_err(200, Title, "거래유형")
		dw_detail.SetRow(li_cnt)
		dw_detail.SetColumn("trcod")
		dw_detail.SetFocus()
		Return - 2
	End If
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(li_cnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[li_cnt]	= gs_user_id
		dw_detail.Object.updtdt[li_cnt]		= fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[li_cnt]		= gs_pgm_id[gi_open_win_no]
	END IF
Next

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b5w_reg_invoice_item_det
integer x = 82
integer y = 52
integer width = 1294
integer height = 216
string dataobject = "b5d_cnd_reg_inv_item_det"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within b5w_reg_invoice_item_det
integer x = 1541
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b5w_reg_invoice_item_det
integer x = 1851
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b5w_reg_invoice_item_det
integer width = 1381
end type

type dw_master from w_a_reg_m_m`dw_master within b5w_reg_invoice_item_det
integer y = 316
integer width = 2176
integer height = 496
string dataobject = "b5dw_inq_reg_inv_item_det"
end type

event dw_master::constructor;call super::constructor;dwobject	ldwo_sort

ldwo_sort = Object.bilseq_t
uf_init(ldwo_sort)

end event

type dw_detail from w_a_reg_m_m`dw_detail within b5w_reg_invoice_item_det
integer y = 832
integer width = 2176
integer height = 612
string dataobject = "b5d_reg_inv_item_det"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);String	ls_bilcod, ls_inv_type

ls_inv_type = dw_master.object.inv_type[al_select_row]
ls_bilcod = dw_master.Object.bilcod[al_select_row]

dw_detail.is_where = "inv_type ='" + ls_inv_type + "'" +" And bilcod = '" + ls_bilcod + "'"
If dw_detail.Retrieve() < 0 Then
	Return -1
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;ib_downarrow = True
SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b5w_reg_invoice_item_det
integer x = 37
integer y = 1484
end type

type p_delete from w_a_reg_m_m`p_delete within b5w_reg_invoice_item_det
integer x = 361
integer y = 1484
end type

type p_save from w_a_reg_m_m`p_save within b5w_reg_invoice_item_det
integer x = 686
integer y = 1484
end type

type p_reset from w_a_reg_m_m`p_reset within b5w_reg_invoice_item_det
integer x = 1307
integer y = 1484
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b5w_reg_invoice_item_det
integer y = 796
end type

