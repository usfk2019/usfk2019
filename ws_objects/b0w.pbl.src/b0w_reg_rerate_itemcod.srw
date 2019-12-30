$PBExportHeader$b0w_reg_rerate_itemcod.srw
$PBExportComments$[parkkh] 대역코드 등록
forward
global type b0w_reg_rerate_itemcod from w_a_reg_m
end type
end forward

global type b0w_reg_rerate_itemcod from w_a_reg_m
integer width = 2784
integer height = 1924
end type
global b0w_reg_rerate_itemcod b0w_reg_rerate_itemcod

on b0w_reg_rerate_itemcod.create
call super::create
end on

on b0w_reg_rerate_itemcod.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;LONG		ll_row
STRING	ls_where,		ls_priceplan

//조회 시 상단 대분류명 like 조회
ls_priceplan = Trim(dw_cond.Object.priceplan[1]) 

If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_where = ""
IF ls_priceplan <> "" THEN
	IF ls_where <> "" THEN ls_where += " And "
	ls_where += " PRICEPLAN = '" + ls_priceplan + "' "	
ELSE
	f_msg_usr_err(200, Title, "Price Plan")
	Return
END IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

p_insert.TriggerEvent("ue_enable")

end event

event ue_extra_save;LONG		ll_row,			ll_i
STRING	ls_priceplan,	ls_itemcod,			ls_use_yn,			ls_bilamt_yn,		ls_dcbilamt_yn

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_priceplan = Trim(dw_detail.Object.priceplan[ll_i])
	ls_itemcod	 = Trim(dw_detail.Object.itemcod[ll_i])
	ls_bilamt_yn = Trim(dw_detail.Object.bilamt_yn[ll_i])
	ls_dcbilamt_yn = Trim(dw_detail.Object.dcbilamt_yn[ll_i])
	
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	If IsNull(ls_bilamt_yn) Then ls_bilamt_yn = ""
	If IsNull(ls_dcbilamt_yn) Then ls_dcbilamt_yn = ""	
	
	If ls_priceplan = "" Then 
		f_msg_usr_err(200, Title, "PricePlan")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("itemcod")
		Return -1
	End If
	If ls_itemcod = "" Then 
		f_msg_usr_err(200, Title, "Item")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("itemcod")
		Return -1
	End If
	
	IF ls_bilamt_yn = "" AND ls_dcbilamt_yn = "" THEN
		f_msg_usr_err(200, Title, "bilamt")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("bilamt_yn")
		Return -1
	END IF
	
	IF ls_bilamt_yn = "N" AND ls_dcbilamt_yn = "N" THEN
		f_msg_usr_err(200, Title, "bilamt")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("bilamt_yn")
		Return -1
	END IF	
	
	IF ls_bilamt_yn = "Y" AND ls_dcbilamt_yn = "Y" THEN
		f_msg_usr_err(200, Title, "bilamt")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("bilamt_yn")
		Return -1
	END IF			
	
	//log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
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
//p_insert.TriggerEvent("ue_enable")
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event ue_reset;call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("priceplan")

//p_insert.TriggerEvent("ue_enable")

Return 0
end event

event ue_extra_insert;STRING	ls_priceplan

ls_priceplan = Trim(dw_cond.Object.priceplan[1])

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("itemcod")

//Log 정보
dw_detail.object.use_yn[al_insert_row] = "Y"
dw_detail.object.priceplan[al_insert_row] = ls_priceplan
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

gi_open_win_no

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_rerate_itemcod
integer x = 41
integer y = 44
integer width = 1157
integer height = 140
string dataobject = "b0dw_cnd_rerate_itemcod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_rerate_itemcod
integer x = 1275
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b0w_reg_rerate_itemcod
integer x = 1573
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_rerate_itemcod
integer x = 23
integer width = 1202
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_rerate_itemcod
integer x = 315
integer y = 1700
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_rerate_itemcod
integer x = 23
integer y = 1700
end type

type p_save from w_a_reg_m`p_save within b0w_reg_rerate_itemcod
integer x = 608
integer y = 1700
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_rerate_itemcod
integer x = 23
integer y = 220
integer width = 2688
integer height = 1444
string dataobject = "b0dw_reg_rerate_itemcod"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::editchanged;//Update log
dw_detail.object.updt_user[row] = gs_user_id
dw_detail.object.updtdt[row] = fdt_get_dbserver_now()
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

type p_reset from w_a_reg_m`p_reset within b0w_reg_rerate_itemcod
integer x = 1079
integer y = 1700
end type

