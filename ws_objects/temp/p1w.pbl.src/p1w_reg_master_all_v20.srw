$PBExportHeader$p1w_reg_master_all_v20.srw
$PBExportComments$[ohj] Master 일괄 수정 v20
forward
global type p1w_reg_master_all_v20 from w_a_reg_m_sql
end type
end forward

global type p1w_reg_master_all_v20 from w_a_reg_m_sql
integer width = 2962
integer height = 2424
end type
global p1w_reg_master_all_v20 p1w_reg_master_all_v20

type variables
Long	il_row_before = 0

end variables

on p1w_reg_master_all_v20.create
call super::create
end on

on p1w_reg_master_all_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where
String ls_pid,ls_contno_fr, ls_contno_to, ls_lotno
Long ll_row
Dec lc_amt

ls_lotno  = Trim(dw_cond.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_pid  = Trim(dw_cond.object.pin[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contno_fr = trim(dw_cond.Object.contno_fr[1])
If IsNull(ls_contno_fr) Then ls_contno_fr = ""

ls_contno_to = trim(dw_cond.Object.contno_to[1])
If IsNull(ls_contno_to) Then ls_contno_to = ""

If ls_contno_fr = "" and ls_pid = "" and ls_lotno = "" Then
	f_msg_usr_err(200, Title, "관리번호 From, PIN# 혹은 Lot#를 입력하셔야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contno_fr")
	Return
End If

ls_where = ""

If ls_contno_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.contno >= '" + ls_contno_fr +"' "
End If

If ls_contno_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.contno <= '" + ls_contno_to + "' "
End If

If ls_lotno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.lotno = '" + ls_lotno + "' "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " p_cardmst.pid = '" + ls_pid + "' "
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve() Error")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
	Return
End If
end event

event type integer ue_save_sql();String ls_mflag, ls_salid, ls_markid, ls_enddt, ls_lotno, ls_pricemodel, &
			ls_card_maker, ls_wkflag1, ls_wkflag2
Long ll_row, ll_count, ll_srow_cnt, ll_srow, ll_selrow
Long ll_year, ll_month,ll_date
Date ld_enddt
Int li_return

dw_cond.AcceptText()

ls_mflag = Trim(dw_cond.Object.mflag[1])
If IsNull(ls_mflag) Then ls_mflag = ""

ls_lotno = Trim(dw_cond.Object.lotno_1[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_salid = Trim(dw_cond.Object.salid[1])
If IsNull(ls_salid) Then ls_salid = ""

ls_markid = Trim(dw_cond.Object.markid[1])
If IsNull(ls_markid) Then ls_markid = ""

ld_enddt = dw_cond.Object.enddt[1]
ls_enddt = String(ld_enddt, "yyyymmdd")
If IsNull(ld_enddt) Then ls_enddt = ""

ls_pricemodel = dw_cond.Object.pricemodel[1]
If IsNull(ls_pricemodel) Then ls_pricemodel = ""

ls_card_maker = dw_cond.Object.card_maker[1]
If IsNull(ls_card_maker) Then ls_card_maker = ""

ls_wkflag1 = dw_cond.Object.wkflag1[1]
If IsNull(ls_wkflag1) Then ls_wkflag1 = ""

ls_wkflag2 = dw_cond.Object.wkflag2[1]
If IsNull(ls_wkflag2) Then ls_wkflag2 = ""

ll_count = 0
ll_selrow = 0

Do While(True)
	ll_selrow = dw_detail.getSelectedRow(ll_selrow)
	
	If ll_selrow = 0 Then Exit
	
	If ls_mflag <> "" Then	dw_detail.Object.status[ll_selrow] = ls_mflag
	If ls_salid <> "" Then	dw_detail.Object.partner_prefix[ll_selrow] = ls_salid
	If ls_enddt <> "" Then	dw_detail.Object.enddt[ll_selrow] = DateTime(ld_enddt)
	If ls_markid <> "" Then	dw_detail.object.priceplan[ll_selrow] = ls_markid
	If ls_lotno <> "" Then	dw_detail.object.lotno[ll_selrow] = ls_lotno
	If ls_pricemodel <> "" Then dw_detail.Object.pricemodel[ll_selrow] = ls_pricemodel
	If ls_card_maker <> "" Then dw_detail.Object.card_marker[ll_selrow] = ls_card_maker
	If ls_wkflag1 <> "" Then dw_detail.Object.wkflag1[ll_selrow] = ls_wkflag1
	If ls_wkflag2 <> "" Then dw_detail.Object.wkflag2[ll_selrow] = ls_wkflag2
	
	ll_count ++
loop

If ll_count > 0 Then
	li_return = f_msg_ques_yesno(2050, Title, "")
	If li_return = 2 Then  // no인 경우		
		Trigger Event ue_ok()
		Return -2
	End If

	If dw_detail.Update() < 0 then
		Return -1
	End If
	
ElseIf ll_count = 0 Then
	f_msg_info(4000,title,"")
	Return -2
End IF

Return 0
end event

event ue_save();Integer li_return

If dw_cond.AcceptText() < 1 Then
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
		f_msg_info(3010, This.Title, "")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
End Choose


end event

event key;Choose Case key
	Case KeyEnter!
		This.TriggerEvent("ue_ok")
	Case KeyEscape!
//		This.TriggerEvent("ue_close")
//		Return
End Choose

end event

type dw_cond from w_a_reg_m_sql`dw_cond within p1w_reg_master_all_v20
integer x = 46
integer y = 44
integer width = 2226
integer height = 856
string dataobject = "p1dw_cnd_reg_master_all_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;Long   ll_row
String ls_filter, ls_markid, ls_svccod
DataWindowChild ldc_wkflag2
Choose Case dwo.name
	Case "markid" 

		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM PRICEPLANMST
		 WHERE PRICEPLAN = :data;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "SELECT SVCCOD from PRICEPLANMST")				
			Return 1
		End If
		
		//언어맨트 수정 07/11
		ll_row = This.GetChild("wkflag2", ldc_wkflag2)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
		ldc_wkflag2.Filter()
		ldc_wkflag2.SetTransObject(SQLCA)
		ll_row = ldc_wkflag2.Retrieve()
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
			Return -1
		End If
	Case "wkflag2"
		ls_markid = fs_snvl(This.object.markid[1], '')
		
		If ls_markid = '' Then
			f_msg_info(9000, title,  "가격정책을 먼저 선택하여 주십시오.")
			This.Object.wkflag2[1] = ""
			This.Setcolumn("markid")
			Return 2
		End If
End Choose
end event

type p_ok from w_a_reg_m_sql`p_ok within p1w_reg_master_all_v20
integer x = 2409
integer y = 44
end type

type p_close from w_a_reg_m_sql`p_close within p1w_reg_master_all_v20
integer x = 2409
integer y = 296
end type

type gb_cond from w_a_reg_m_sql`gb_cond within p1w_reg_master_all_v20
integer width = 2263
integer height = 912
end type

type p_save from w_a_reg_m_sql`p_save within p1w_reg_master_all_v20
integer x = 2409
integer y = 172
end type

type dw_detail from w_a_reg_m_sql`dw_detail within p1w_reg_master_all_v20
integer y = 928
integer width = 2862
integer height = 1340
string dataobject = "p1dw_reg_master_all_v20"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.connum_t
uf_init(ldwo_SORT)
end event

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

