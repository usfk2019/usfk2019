$PBExportHeader$b5w_reg_trprtt.srw
$PBExportComments$[kEnn-backgu] 청구서항목내용
forward
global type b5w_reg_trprtt from w_a_reg_m_m
end type
end forward

global type b5w_reg_trprtt from w_a_reg_m_m
integer width = 2286
integer height = 1764
end type
global b5w_reg_trprtt b5w_reg_trprtt

on b5w_reg_trprtt.create
call super::create
end on

on b5w_reg_trprtt.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_bilcod , ls_bilcodnm

//입력 조건 처리 부분
ls_bilcod = Trim(dw_cond.Object.bilcod[1])
ls_bilcodnm = Trim(dw_cond.Object.bilcodnm[1])
If IsNull(ls_bilcod) Then ls_bilcod = ""
If IsNull(ls_bilcodnm) Then ls_bilcodnm = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_bilcodnm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bilcodnm LIKE '%" + ls_bilcodnm + "%'"
End If

If ls_bilcod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bilcod LIKE '" + ls_bilcod + "%'"
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
		f_msg_usr_err(200, Title, "Transaction")
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

type dw_cond from w_a_reg_m_m`dw_cond within b5w_reg_trprtt
integer x = 55
integer width = 1294
integer height = 216
string dataobject = "b5d_cnd_reg_trprtt"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within b5w_reg_trprtt
integer x = 1541
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b5w_reg_trprtt
integer x = 1851
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b5w_reg_trprtt
integer width = 1381
end type

type dw_master from w_a_reg_m_m`dw_master within b5w_reg_trprtt
integer y = 316
integer width = 2176
integer height = 496
string dataobject = "b5dw_inq_reg_trprtt"
end type

event dw_master::constructor;call super::constructor;dwobject	ldwo_sort

ldwo_sort = Object.bilseq_t
uf_init(ldwo_sort)

end event

type dw_detail from w_a_reg_m_m`dw_detail within b5w_reg_trprtt
integer y = 832
integer width = 2171
integer height = 612
string dataobject = "b5d_reg_trprtt_dtl"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);String	ls_bilcod

ls_bilcod = dw_master.Object.bilcod[al_select_row]
dw_detail.is_where = "bilcod = '" + ls_bilcod + "'"
If dw_detail.Retrieve() < 0 Then
	Return -1
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;ib_downarrow = True
SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b5w_reg_trprtt
integer x = 37
integer y = 1484
end type

type p_delete from w_a_reg_m_m`p_delete within b5w_reg_trprtt
integer x = 361
integer y = 1484
end type

type p_save from w_a_reg_m_m`p_save within b5w_reg_trprtt
integer x = 686
integer y = 1484
end type

type p_reset from w_a_reg_m_m`p_reset within b5w_reg_trprtt
integer x = 1307
integer y = 1484
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b5w_reg_trprtt
integer y = 796
end type

