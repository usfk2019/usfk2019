$PBExportHeader$ssrt_reg_basecod.srw
$PBExportComments$[parkkh] 품목 대분류등록
forward
global type ssrt_reg_basecod from w_a_reg_m
end type
end forward

global type ssrt_reg_basecod from w_a_reg_m
integer width = 3950
integer height = 2016
end type
global ssrt_reg_basecod ssrt_reg_basecod

on ssrt_reg_basecod.create
call super::create
end on

on ssrt_reg_basecod.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_category_b, ls_basenm

//조회 시 상단 대분류명 like 조회
ls_basenm = Trim(dw_cond.Object.basenm[1])

If IsNull(ls_basenm) Then ls_basenm = ""

ls_where = ""
If ls_basenm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(basenm) Like '%" + Upper(ls_basenm) + "%' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event ue_extra_save;call super::ue_extra_save;Long ll_row, ll_i
String ls_basecod, ls_basenm

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_basecod = Trim(dw_detail.Object.basecod[ll_i])
	ls_basenm = Trim(dw_detail.Object.basenm[ll_i])	
	
	If IsNull(ls_basecod) Then ls_basecod = ""
	If IsNull(ls_basenm) Then ls_basenm = ""
	
	If ls_basecod = "" Then 
		f_msg_usr_err(200, Title, "Base Code")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("basecod")
		Return -1
	End If
	If ls_basenm = "" Then 
		f_msg_usr_err(200, Title, "Base Name")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("basenm")
		Return -1
	End If
	
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
	//	dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
   End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_categoryC
	Desc.	: 품목 대분류 등록
	Ver 	: 1.0
	Date	: 2002.09.24
	Progrmaer: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event ue_reset;call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("basenm")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event ue_extra_insert;call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("basecod")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_basecod
integer x = 41
integer y = 52
integer width = 1381
integer height = 140
string dataobject = "ssrt_dw_cnd_reg_basecod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt_reg_basecod
integer x = 1499
integer y = 36
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_basecod
integer x = 1801
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_basecod
integer x = 18
integer width = 1454
integer height = 212
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_basecod
integer x = 315
integer y = 1768
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_basecod
integer x = 23
integer y = 1768
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_basecod
integer x = 608
integer y = 1768
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_basecod
integer x = 18
integer y = 240
integer width = 3849
integer height = 1476
string dataobject = "ssrt_dw_reg_basecod"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_basecod
integer x = 1179
integer y = 1768
end type

