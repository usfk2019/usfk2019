$PBExportHeader$b0w_reg_zone.srw
$PBExportComments$[parkkh] 대역코드 등록
forward
global type b0w_reg_zone from w_a_reg_m
end type
end forward

global type b0w_reg_zone from w_a_reg_m
integer width = 1920
integer height = 1924
end type
global b0w_reg_zone b0w_reg_zone

on b0w_reg_zone.create
call super::create
end on

on b0w_reg_zone.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where, ls_zonnm

//조회 시 상단 대분류명 like 조회
ls_zonnm = Trim(dw_cond.Object.zonnm[1])

If IsNull(ls_zonnm) Then ls_zonnm = ""

ls_where = ""
If ls_zonnm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(zonnm) Like '%" + Upper(ls_zonnm) + "%' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_zoncod, ls_zonnm

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_i]) 
	ls_zonnm = Trim(dw_detail.Object.zonnm[ll_i])	
	
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If IsNull(ls_zonnm) Then ls_zonnm = ""
	
	If ls_zoncod = "" Then 
		f_msg_usr_err(200, Title, "대역코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("zoncod")
		Return -1
	End If
	If ls_zonnm = "" Then 
		f_msg_usr_err(200, Title, "대역명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("zonnm")
		Return -1
	End If
	
	//log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
	//	dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
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
dw_cond.SetColumn("zonnm")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("zoncod")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_zone
integer x = 41
integer y = 44
integer width = 1157
integer height = 140
string dataobject = "b0dw_cnd_reg_zone"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_zone
integer x = 1275
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b0w_reg_zone
integer x = 1573
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_zone
integer x = 23
integer width = 1202
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_zone
integer x = 315
integer y = 1700
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_zone
integer x = 23
integer y = 1700
end type

type p_save from w_a_reg_m`p_save within b0w_reg_zone
integer x = 608
integer y = 1700
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_zone
integer x = 23
integer y = 220
integer width = 1829
integer height = 1444
string dataobject = "b0dw_reg_zone"
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

type p_reset from w_a_reg_m`p_reset within b0w_reg_zone
integer x = 1193
integer y = 1700
end type

