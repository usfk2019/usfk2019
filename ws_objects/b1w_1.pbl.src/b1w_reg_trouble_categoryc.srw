$PBExportHeader$b1w_reg_trouble_categoryc.srw
$PBExportComments$[chooys] 민원유형 대분류등록
forward
global type b1w_reg_trouble_categoryc from w_a_reg_m
end type
end forward

global type b1w_reg_trouble_categoryc from w_a_reg_m
integer width = 2185
integer height = 2016
end type
global b1w_reg_trouble_categoryc b1w_reg_trouble_categoryc

on b1w_reg_trouble_categoryc.create
call super::create
end on

on b1w_reg_trouble_categoryc.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_category_b, ls_category_cnm

//조회 시 상단 대분류명 like 조회
ls_category_cnm = Trim(dw_cond.Object.categorycnm[1])

If IsNull(ls_category_cnm) Then ls_category_cnm = ""

ls_where = ""
If ls_category_cnm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(troubletypecnm) Like '%" + Upper(ls_category_cnm) + "%' "	
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

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_category_c, ls_category_cnm

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_category_c = Trim(dw_detail.Object.troubletypec[ll_i])
	ls_category_cnm = Trim(dw_detail.Object.troubletypecnm[ll_i])	
	
	If IsNull(ls_category_c) Then ls_category_c = ""
	If IsNull(ls_category_cnm) Then ls_category_cnm = ""
	
	If ls_category_c = "" Then 
		f_msg_usr_err(200, Title, "민원유형 대분류 코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypec")
		Return -1
	End If
	If ls_category_cnm = "" Then 
		f_msg_usr_err(200, Title, "민원유형 대분류명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("troubletypecnm")
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
	Name 	: b1w_reg_categoryC
	Desc.	: 민원유형 대분류 등록
	Ver 	: 1.0
	Date	: 2003.08.12
	Progrmaer: Choo YoonShik(chooys)
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
dw_cond.SetColumn("categorycnm")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("troubletypec")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_trouble_categoryc
integer x = 41
integer y = 52
integer width = 1381
integer height = 140
string dataobject = "b1dw_cnd_reg_trouble_categoryc"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_trouble_categoryc
integer x = 1499
integer y = 36
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_trouble_categoryc
integer x = 1801
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_trouble_categoryc
integer x = 18
integer width = 1454
integer height = 212
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_trouble_categoryc
integer x = 315
integer y = 1768
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_trouble_categoryc
integer x = 23
integer y = 1768
end type

type p_save from w_a_reg_m`p_save within b1w_reg_trouble_categoryc
integer x = 608
integer y = 1768
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_trouble_categoryc
integer x = 18
integer y = 240
integer width = 2103
integer height = 1476
string dataobject = "b1dw_reg_trouble_categoryc"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_trouble_categoryc
integer x = 1179
integer y = 1768
end type

