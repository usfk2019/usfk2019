$PBExportHeader$b4w_reg_svcpromise.srw
$PBExportComments$[parkkh] 약정유형등록
forward
global type b4w_reg_svcpromise from w_a_reg_m
end type
end forward

global type b4w_reg_svcpromise from w_a_reg_m
integer width = 3241
integer height = 1860
end type
global b4w_reg_svcpromise b4w_reg_svcpromise

on b4w_reg_svcpromise.create
call super::create
end on

on b4w_reg_svcpromise.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b4w_reg_svcpromise
	Desc.	: 약정유형등록
	Ver.	: 1.0
	Date	: 2002.09.26
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/
end event

event ue_ok();call super::ue_ok;String ls_prmnm, ls_svccod, ls_where
Long ll_row

ls_prmnm = Trim(dw_cond.object.prmnm[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
If IsNull(ls_prmnm) Then ls_prmnm = ""
If IsNull(ls_svccod) Then ls_svccod = ""

ls_where = ""
If ls_prmnm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(prmnm) like '%" + Upper(ls_prmnm) + "%' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " svccod = '" + ls_svccod + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title , "Retrieve()")
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 
String ls_svccod
ls_svccod = Trim(dw_cond.object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""
If ls_svccod <> "" Then
	dw_detail.object.svccod[al_insert_row] = ls_svccod
End If

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("prmtype")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0 
end event

event type integer ue_extra_save();call super::ue_extra_save;
String ls_prmtype, ls_prmnm, ls_months, ls_penalty, ls_svccod, ls_itemcod
Long ll_row, i

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

For i = 1 To ll_row

	ls_prmtype = dw_detail.object.prmtype[i]
	If IsNull(ls_prmtype) Then ls_prmtype = ""
	If ls_prmtype = "" Then
		f_msg_usr_err(200, Title, "약정유형코드")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("prmtype")
		Return -1
	End If
	
	ls_prmnm = dw_detail.object.prmnm[i]
	If IsNull(ls_prmnm) Then ls_prmnm = ""
	If ls_prmnm = "" Then
		f_msg_usr_err(200, Title, "약정유형명")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("prmnm")
		Return -1
	End If

	ls_months = String(dw_detail.object.prm_months[i])
	If IsNull(ls_months) Then ls_months = ""
	If ls_months = "" Then
		f_msg_usr_err(200, Title, "약정월수")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("prm_months")
		Return -1
	End If
	
	ls_penalty = String(dw_detail.object.prm_penalty[i])
	If IsNull(ls_penalty) Then ls_penalty = ""
	If ls_penalty = "" Then
		f_msg_usr_err(200, Title, "위약금(월정액)")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("prm_penalty")
		Return -1
	End If

	ls_svccod = dw_detail.object.svccod[i]
	If IsNull(ls_svccod) Then ls_svccod= ""
	If ls_svccod = "" Then
		f_msg_usr_err(200, Title, "적용서비스")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("svccod")
		Return -1
	End If

	ls_itemcod = dw_detail.object.itemcod[i]
	If IsNull(ls_itemcod) Then ls_itemcod= ""
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title, "위약금품목")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("itemcod")
		Return -1
	End If
	
	//log 정보
   If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
   End If
Next

Return 0
end event

event type integer ue_reset();call super::ue_reset;//dw_cond.object.originnum[1] = ""
//dw_cond.object.name[1] = ""
dw_cond.SetColumn("prmnm")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b4w_reg_svcpromise
integer x = 41
integer y = 60
integer width = 1317
integer height = 224
integer taborder = 10
string dataobject = "b4dw_cnd_reg_svcpromise"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b4w_reg_svcpromise
integer x = 1504
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b4w_reg_svcpromise
integer x = 1819
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b4w_reg_svcpromise
integer width = 1367
end type

type p_delete from w_a_reg_m`p_delete within b4w_reg_svcpromise
integer y = 1632
end type

type p_insert from w_a_reg_m`p_insert within b4w_reg_svcpromise
integer y = 1632
end type

type p_save from w_a_reg_m`p_save within b4w_reg_svcpromise
integer y = 1632
end type

type dw_detail from w_a_reg_m`dw_detail within b4w_reg_svcpromise
integer x = 23
integer width = 3141
integer height = 1264
integer taborder = 20
string dataobject = "b4dw_reg_svcpromise"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력했을시 버튼 활성화
If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.SetFocus()   //데이터 없을경우 다시 조회 할 수있도록 
End If
end event

type p_reset from w_a_reg_m`p_reset within b4w_reg_svcpromise
integer y = 1632
end type

