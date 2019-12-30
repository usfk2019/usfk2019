$PBExportHeader$b5w_1_reg_tr_mapping_info.srw
$PBExportComments$[juede] 청구정보 mapping
forward
global type b5w_1_reg_tr_mapping_info from w_a_reg_m
end type
end forward

global type b5w_1_reg_tr_mapping_info from w_a_reg_m
integer width = 3063
integer height = 1864
end type
global b5w_1_reg_tr_mapping_info b5w_1_reg_tr_mapping_info

on b5w_1_reg_tr_mapping_info.create
call super::create
end on

on b5w_1_reg_tr_mapping_info.destroy
call super::destroy
end on

event ue_ok();Long ll_row
String ls_where, ls_groupcod,ls_fromdt
Date ld_fromdt
//조회 시 상단 대분류명 like 조회
ls_groupcod = Trim(dw_cond.Object.groupcod[1])
ls_fromdt =String( dw_cond.Object.fromdt[1])

If IsNull(ls_groupcod) Then ls_groupcod = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""

If ls_groupcod = "" Then
	f_msg_usr_err(200, Title, "Group name")
	dw_detail.SetRow(1)
	dw_detail.SetColumn("groupcod")
	dw_detail.SetFocus()
	Return 
End If


ls_where = ""
If ls_groupcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " groupcod ='" + ls_groupcod + "' "	
End If

If ls_fromdt <>"" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(fromdt ,''yyyymmdd'')='" +ls_fromdt + "' "	
End If	

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
	p_insert.TriggerEvent("ue_enable")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;
Long ll_row, ll_i, ll_rows2, ll_rows1
String ls_info_type, ls_sort, ls_groupcod
Date ld_fromdt , ld_fromdt1, ld_fromdt2
Int li_seq , li_seq1, li_seq2

dw_detail.SetRedraw(True)
ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row

	ld_fromdt = Date(dw_detail.Object.fromdt[ll_i])
	li_seq = dw_detail.Object.seq[ll_i]
	ls_info_type = dw_detail.Object.info_type[ll_i]
	ls_groupcod=dw_cond.object.groupcod[1]
	dw_detail.Object.groupcod[ll_i] = ls_groupcod
	

	If IsNull(ls_info_type) Then ls_info_type = ""	
	
	If IsNull(String(ld_fromdt)) Then 
		f_msg_usr_err(200, Title, "적용기준일")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If
	
	If IsNull(String(li_seq)) Then 
		f_msg_usr_err(200, Title, "항목순서")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("seq")
		Return -1
	End If
	
	If ls_info_type = "" Then 
		f_msg_usr_err(200, Title, "항목Type")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("info_type")
		Return -1
	End If
	
	//log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
	//	dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
	End If
	
	

Next


ls_sort = "fromdt,seq"
dw_detail.SetSort(ls_sort)
dw_detail.Sort()
dw_detail.SetRedraw(True)

For ll_rows1 = 1 To dw_detail.RowCount()
	ld_fromdt1= Date(dw_detail.object.fromdt[ll_rows1])
	li_seq1 = dw_detail.object.seq[ll_rows1]
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 -1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		ld_fromdt2 =Date(dw_detail.object.fromdt[ll_rows1])
		li_seq2 = dw_detail.object.seq[ll_rows2]
		
		If (ld_fromdt1 = ld_fromdt2) And (li_seq1 = li_seq2)Then
			 f_msg_info(9000, Title, "적용기준일[ " + String(ld_fromdt1,'yyyymmdd') + " ]에 항목순서 [" +String(li_seq)+" ]이 중복됩니다. ")
	 		dw_detail.SetRow(ll_rows2)
    		dw_detail.ScrollToRow(ll_rows2)
		   dw_detail.SetColumn("seq")

   		Return -2
		End If		
	Next	
Next
Return 0
	
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("groupcod")

//p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("fromdt")

dw_detail.object.fromdt[al_insert_row] =  Date(fdt_get_dbserver_now())
//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_1_reg_tr_mapping_info
integer x = 41
integer y = 44
integer width = 1947
integer height = 140
string dataobject = "b5dw_1_cnd_tr_mapping_info_autoever"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_1_reg_tr_mapping_info
integer x = 2126
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b5w_1_reg_tr_mapping_info
integer x = 2423
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_1_reg_tr_mapping_info
integer x = 23
integer width = 1998
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b5w_1_reg_tr_mapping_info
integer x = 315
integer y = 1612
end type

type p_insert from w_a_reg_m`p_insert within b5w_1_reg_tr_mapping_info
integer x = 23
integer y = 1612
end type

type p_save from w_a_reg_m`p_save within b5w_1_reg_tr_mapping_info
integer x = 608
integer y = 1612
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_1_reg_tr_mapping_info
integer x = 23
integer y = 220
integer width = 2981
integer height = 1348
string dataobject = "b5dw_1_reg_det_tr_mapping_info_autoever"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::editchanged;call super::editchanged;//Update log
//dw_detail.object.updt_user[row] = gs_user_id
//dw_detail.object.updtdt[row] = fdt_get_dbserver_now()
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

event dw_detail::itemchanged;call super::itemchanged;Long ll_row
String ls_filter
DataWindowChild ldc_trcod
String ls_trcod


Choose Case dwo.name
	Case "itemcod"
		
		SELECT trcod
		INTO :ls_trcod
		FROM itemmst
		WHERE itemcod=:data;
		
		If SQLCA.sqlcode  = 100 Then
			ls_trcod=""
		End If
		
		dw_detail.Object.trcod[row] = ls_trcod
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b5w_1_reg_tr_mapping_info
integer x = 1193
integer y = 1612
end type

