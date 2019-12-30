$PBExportHeader$b1w_reg_inq_creditstat.srw
$PBExportComments$[kem] 신용정보조회
forward
global type b1w_reg_inq_creditstat from w_a_reg_m
end type
end forward

global type b1w_reg_inq_creditstat from w_a_reg_m
integer width = 3127
integer height = 1924
end type
global b1w_reg_inq_creditstat b1w_reg_inq_creditstat

type variables
String is_method
end variables

on b1w_reg_inq_creditstat.create
call super::create
end on

on b1w_reg_inq_creditstat.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row, ll_i
String ls_where, ls_order_yn
String ls_inqreqdt, ls_inqstat, ls_partner
Datetime ldt_inqdt

ls_inqreqdt = String(dw_cond.Object.inqreqdt[1],'yyyymmdd')
ls_inqstat = dw_cond.Object.inqstat[1]
ls_partner = dw_cond.Object.partner[1]

If IsNull(ls_inqreqdt) Then ls_inqreqdt = ""
If IsNull(ls_inqstat) Then ls_inqstat = ""
If IsNull(ls_partner) Then ls_partner = ""

If ls_inqreqdt = "" Then
	f_msg_info(200, Title, "조회요청일")
	dw_cond.SetColumn("inqreqdt")
	Return
End If

ls_where = ""
If ls_inqreqdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(inqreqdt,'yyyymmdd') <= '" + ls_inqreqdt + "'"	
End If

If ls_inqstat <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " inqstat = '" + ls_inqstat + "' "	
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " partner = '" + ls_partner + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(gs_user_id)

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

ll_row = dw_detail.rowcount()
//retrieve 후 값 셋팅!!
For ll_i = 1 To ll_row
	ls_order_yn = dw_detail.Object.order_yn[ll_i]
	If isNull(ls_order_yn) Then dw_detail.Object.order_yn[ll_i] = 'Y'
	ldt_inqdt = dw_detail.Object.inqdt[ll_i]
	If isNull(ldt_inqdt) Then dw_detail.Object.inqdt[ll_i] = fdt_get_dbserver_now()	
Next
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_countrycod, ls_countrynm

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
   End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_inq_creditstat
	Desc.	: 신용정보조회
	Ver 	: 1.0
	Date	: 2002.11.22
	Progrmaer: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_ref_desc
ls_ref_desc = ""
is_method = fs_get_control("A1", "C500", ls_ref_desc)

p_insert.TriggerEvent("ue_enable")

dw_cond.object.inqreqdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.inqstat[1] = is_method





end event

event type integer ue_insert();call super::ue_insert;//p_delete.TriggerEvent("ue_enable")
//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//
Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("inqreqdt")
dw_cond.Object.inqreqdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.inqstat[1] = is_method

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;////Insert 시 해당 row 첫번째 컬럼에 포커스
//dw_detail.SetRow(al_insert_row)
//dw_detail.ScrollToRow(al_insert_row)
//dw_detail.SetColumn("countrycod")
//
////Log 정보
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.updt_user[al_insert_row] = gs_user_id
//dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
//
Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_inq_creditstat
integer y = 40
integer width = 2263
integer height = 260
string dataobject = "b1dw_cnd_reg_inq_creditstat"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_inq_creditstat
integer x = 2450
integer y = 56
end type

type p_close from w_a_reg_m`p_close within b1w_reg_inq_creditstat
integer x = 2747
integer y = 56
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_inq_creditstat
integer height = 312
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_inq_creditstat
boolean visible = false
integer x = 329
integer y = 1696
integer height = 172
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_inq_creditstat
boolean visible = false
integer x = 91
integer y = 1696
end type

type p_save from w_a_reg_m`p_save within b1w_reg_inq_creditstat
integer x = 96
integer y = 1692
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_inq_creditstat
integer x = 23
integer y = 336
integer width = 3022
integer height = 1324
string dataobject = "b1dw_req_inq_creditstat"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;//Item Changed
Boolean lb_check
String ls_data 
Choose Case dwo.name
	Case "order_yn"
		 This.Object.inqdt[row] = fdt_get_dbserver_now()	
		
End Choose
	
Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_inq_creditstat
integer x = 393
integer y = 1692
end type

