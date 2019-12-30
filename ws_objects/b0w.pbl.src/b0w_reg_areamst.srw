$PBExportHeader$b0w_reg_areamst.srw
$PBExportComments$[parkkh] 지역코드 등록
forward
global type b0w_reg_areamst from w_a_reg_m
end type
end forward

global type b0w_reg_areamst from w_a_reg_m
integer width = 3122
integer height = 1960
end type
global b0w_reg_areamst b0w_reg_areamst

on b0w_reg_areamst.create
call super::create
end on

on b0w_reg_areamst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where, ls_countrycod, ls_area_group, ls_areanm, ls_arecod

//조회 시 상단 대분류명 like 조회
ls_countrycod = Trim(dw_cond.Object.countrycod[1])
ls_area_group = Trim(dw_cond.Object.areagroup[1])
ls_areanm = Trim(dw_cond.Object.areanm[1])
ls_arecod = Trim(dw_cond.object.arecode[1])

If IsNull(ls_countrycod) Then ls_countrycod = ""
If IsNull(ls_area_group) Then ls_area_group = ""
If IsNull(ls_arecod) Then ls_arecod = ""
If IsNull(ls_areanm) Then ls_areanm = ""

ls_where = ""
If ls_countrycod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " countrycod Like '" + ls_countrycod + "' "	
End If

If ls_area_group <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " areagroup Like '" + ls_area_group + "' "	
End If

If ls_areanm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(areanm) Like '%" + Upper(ls_areanm) + "%' "	
End If

If ls_arecod<> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " areacod Like '" + ls_arecod + "%' "	
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_areacod, ls_areanm, ls_countrycod

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_areacod = Trim(dw_detail.Object.areacod[ll_i])
	ls_areanm = Trim(dw_detail.Object.areanm[ll_i])	
	ls_countrycod = Trim(dw_detail.Object.countrycod[ll_i])
	
	If IsNull(ls_areacod) Then ls_areacod = ""
	If IsNull(ls_areanm) Then ls_areanm = ""
	If IsNull(ls_countrycod) Then ls_countrycod = ""	
	
	If ls_areacod = "" Then 
		f_msg_usr_err(200, Title, "지역코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("areacod")
		Return -1
	End If
	If ls_areanm = "" Then 
		f_msg_usr_err(200, Title, "지역명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("areanm")
		Return -1
	End If
	If ls_countrycod = "" Then 
		f_msg_usr_err(200, Title, "국가")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("countrycod")
		Return -1
	End If
	
	//Update 한 Log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
   End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_zone
	Desc.	: 대역코드 등록
	Ver 	: 1.0
	Date	: 2002.09.25
	Progrmaer: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("countrycod")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_countrycod, ls_areagroup
Long ll_row

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("areacod")

//insert시 상단에 국가토드, 지역상위그룹이 존재하면 default로 뿌려줌!
ls_countrycod = Trim(dw_cond.Object.countrycod[1])
If IsNull(ls_countrycod) Then ls_countrycod = ""

ls_areagroup = Trim(dw_cond.Object.areagroup[1])
If IsNull(ls_areagroup) Then ls_areagroup = ""

If ls_countrycod <> "" Then 
	dw_detail.Object.countrycod[al_insert_row] = ls_countrycod
End If

If ls_areagroup <> "" Then 
	dw_detail.Object.areagroup[al_insert_row] = ls_areagroup
End If

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_areamst
integer x = 55
integer y = 52
integer width = 2240
integer height = 224
string dataobject = "b0dw_cnd_reg_areamst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_areamst
integer x = 2423
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b0w_reg_areamst
integer x = 2738
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_areamst
integer x = 37
integer width = 2286
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_areamst
integer y = 1716
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_areamst
integer y = 1716
end type

type p_save from w_a_reg_m`p_save within b0w_reg_areamst
integer x = 617
integer y = 1716
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_areamst
integer y = 304
integer width = 3035
integer height = 1388
string dataobject = "b0dw_reg_areamst"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_areamst
integer x = 1175
integer y = 1716
end type

