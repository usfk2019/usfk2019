$PBExportHeader$p0w_reg_return_card.srw
$PBExportComments$[jykim]선불카드 반품처리
forward
global type p0w_reg_return_card from w_a_reg_m_sql
end type
end forward

global type p0w_reg_return_card from w_a_reg_m_sql
integer width = 3392
integer height = 2288
end type
global p0w_reg_return_card p0w_reg_return_card

type variables
Long	il_row_before = 0
String  is_hand_refill, is_reward_refill , is_return_status    	//수동충전, 보상충전
String is_lflag
String is_return_dt
end variables

on p0w_reg_return_card.create
call super::create
end on

on p0w_reg_return_card.destroy
call super::destroy
end on

event open;call super::open;
String ls_ref_desc, ls_temp, ls_result[]

dw_cond.Object.return_dt[1] = fdt_get_dbserver_now()
dw_cond.SetFocus()
dw_cond.SetColumn("pid")//???

//카드상태
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P101", ls_ref_desc)
If ls_temp = "" Then Return -1
fi_cut_string(ls_temp, ";" , ls_result[])

//반품카드상태
is_return_status = ls_result[7]

//반품 카드 충전 이력에 이력받음
is_lflag = fs_get_control("P0", "P104", ls_ref_desc)

end event

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc , ls_temp, ls_result[]
String ls_pid,ls_contno_fr, ls_contno_to, ls_sale_can
Long li_index
Long ll_row
Dec lc_amt
Long i

//ls_anino = trim(dw_cond.Object.anino[1])
//If IsNull(ls_anino) Then ls_anino = ""

ls_pid = trim(dw_cond.Object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contno_fr = trim(dw_cond.Object.contno_fr[1])
If IsNull(ls_contno_fr) Then ls_contno_fr = ""

ls_contno_to = trim(dw_cond.Object.contno_to[1])
If IsNull(ls_contno_to) Then ls_contno_to = ""

If ls_pid = "" and ls_contno_fr = "" and ls_contno_to = "" Then
	f_msg_usr_err(200, Title, " PIN# 또는 관리번호 중 하나는 필수 입력")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pid")
	Return
End If

ls_where = ""

//If ls_anino <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += "p_cardmst.pid in (select pid from p_anipin where anino ='" + ls_anino + "')"
//End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.pid like '" + ls_pid + "%' "
End If

If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.contno >= '" + ls_contno_fr +"' "
End If

If ls_contno_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.contno <= '" + ls_contno_to + "' "
End If

//카드 Type
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P105", ls_ref_desc)
If ls_temp = "" Then Return 
li_index = fi_cut_string(ls_temp, ";" , ls_result[])

If ls_where <> "" Then ls_where += " AND "
For  i = 1 To li_index
	If i = 1 Then ls_where += "( " 
	ls_where += "p_cardmst.status = '" + ls_result[i] + "' "
	If i = li_index Then 
		ls_where += " )"
   Else 
		ls_where += "OR "
	End If
Next
		
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve Error (OK) ")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(9000, This.Title, "자료가 없습니다.")
	Return
End If
end event

event ue_save();Integer li_return

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If


li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "반품카드처리")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "반품처리완료")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
End Choose


end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_where
Long ll_row, ll_count, ll_srow, i
String ls_return_type, ls_remark, ls_pid, ls_contno , ls_partner_prefix
String ls_tmp, ls_ref_desc, ls_result[], ls_sale_flag, ls_partner, ls_priceplan
String ls_opendt
Integer li_return, li_ret, li_rc
Dec{4} lc_balance

ls_return_type = dw_cond.Object.return_type[1]
ls_remark = dw_cond.Object.remark[1]

If IsNull(is_return_dt) Then is_return_dt = ""
If IsNull(ls_return_type) Then ls_return_type = ""
If IsNull(ls_remark) Then ls_remark = ""

is_return_dt = String(dw_cond.Object.return_dt[1],'yyyymmdd')

ls_tmp = fs_get_control('P0', 'P112', ls_ref_desc)
If ls_tmp = "" Then Return -1
		
li_ret = fi_cut_string(ls_tmp, ";", ls_result[])
If li_ret <= 0 Then Return -1
ls_sale_flag = ls_result[4]		//반품

If is_return_dt = "" Then
	f_msg_usr_err(200, Title, "반품일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("return_dt")
	Return -2
Else
	If is_return_dt < String(fdt_get_dbserver_now(), 'yyyymmdd') Then
		f_msg_info(100, This.Title, "반품일자 >= 현재일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("return_dt")
	   Return -2
	End If
End If

If ls_return_type = "" Then
	f_msg_usr_err(200, Title, "반품사유")
	dw_cond.SetFocus()
	dw_cond.SetColumn("return_type")
	Return -2
End If

ll_count = 0
ll_srow = 0

For i = 1 To dw_detail.RowCount()
	If dw_detail.IsSelected(i) Then ll_count ++
Next

If ll_count = 0 Then
	Return -2
Else 
	li_return = f_msg_ques_yesno(9000, Title, String(ll_count) +" 건을 반품하시겠습니까?")
	If li_return = 2 Then 	 // no인 경우	
		Return -2
	End If
End If

//***** 처리부분 *****
p0c_dbmgr2 iu_db

iu_db = Create p0c_dbmgr2

iu_db.is_title = Title
//iu_db.is_caller = "p0w_reg_return_up%save"

iu_db.is_data[1] = ls_return_type	//반품유형
iu_db.is_data[2] = ls_remark	   	//비고
iu_db.is_data[3] = is_return_dt		//반품일자
iu_db.is_data[4] = ls_sale_flag		//재고
iu_db.is_data[5] = is_return_status	//상태
iu_db.is_data[6] = is_lflag			//반품 이력
iu_db.is_data[7] = title
iu_db.is_data[8] = gs_user_id

iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_01()
li_rc	= iu_db.ii_rc

If dw_detail.Update(True,False) < 0 then
	//ROLLBACK와 동일한 기능
	iu_mdb_app.is_caller = "ROLLBACK"
	iu_mdb_app.is_title = "반품카드처리"
	iu_mdb_app.uf_prc_db()
	If iu_mdb_app.ii_rc = -1 Then
	  dw_detail.SetFocus()
	  Return -1
	End If
	
	Return -1
End If

Destroy iu_db
Return li_rc

end event

type dw_cond from w_a_reg_m_sql`dw_cond within p0w_reg_return_card
integer x = 55
integer y = 76
integer width = 2235
integer height = 680
string dataobject = "p0dw_cnd_reg_return_card"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Choose Case dwo.name
Case "contno_fr" 
	This.Object.contno_to[1] = data;
End Choose

If dwo.Name = "lflag" Then
	If is_reward_refill = data Then
		This.Object.sale_amt[1] = 0	
	End If
End If

Return 0

end event

type p_ok from w_a_reg_m_sql`p_ok within p0w_reg_return_card
integer x = 2427
integer y = 100
end type

type p_close from w_a_reg_m_sql`p_close within p0w_reg_return_card
integer x = 3026
integer y = 100
end type

type gb_cond from w_a_reg_m_sql`gb_cond within p0w_reg_return_card
integer y = 12
integer width = 2295
integer height = 764
end type

type p_save from w_a_reg_m_sql`p_save within p0w_reg_return_card
integer x = 2725
integer y = 100
end type

type dw_detail from w_a_reg_m_sql`dw_detail within p0w_reg_return_card
integer x = 27
integer y = 784
integer width = 3150
string dataobject = "p0dw_reg_return_card"
end type

event dw_detail::buttonclicked;call super::buttonclicked;Choose Case dwo.Name
	Case "b_select_all"
		SelectRow(0, True)
//		p_save.TriggerEvent('ue_enable') 
//		p_delete.TriggerEvent('ue_enable') 
//	Case "b_select_nono"
//		SelectRow(0, False)
End Choose	
end event

event dw_detail::clicked;call super::clicked;Long	ll_start, ll_end

//file manager functionality ... turn off all rows then select new range
If row <= 0 Then Return

//SetRedraw(False)

If il_row_before = 0 Then
	il_row_before = row

	If KeyDown(KeyControl!) Then
		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(row, True)
		End If
	Else
		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(0, False)
			SelectRow(row, True)
		End If
	End If
Else
	If KeyDown(KeyControl!) Then
		il_row_before = row

		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(row, True)
			il_row_before = row
		End If
	ElseIf KeyDown(KeyShift!) Then
		If il_row_before >= row Then
			ll_start = row
			ll_end = il_row_before
		ElseIf il_row_before < row Then
			ll_start = il_row_before
			ll_end = row
		End If

		SelectRow(0, False)
		Do While ( ll_start <= ll_end )
			SelectRow( ll_start, True)
			ll_start += 1
		Loop
	Else
		il_row_before = row

		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(0, False)
			SelectRow(row, True)
			il_row_before = row
		End If
	End If
End If
end event

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)
end event

