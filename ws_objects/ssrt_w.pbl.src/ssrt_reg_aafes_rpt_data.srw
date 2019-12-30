$PBExportHeader$ssrt_reg_aafes_rpt_data.srw
$PBExportComments$[kem] AAFES Report 수동입력 등록
forward
global type ssrt_reg_aafes_rpt_data from w_a_reg_m
end type
end forward

global type ssrt_reg_aafes_rpt_data from w_a_reg_m
integer width = 3191
integer height = 2016
end type
global ssrt_reg_aafes_rpt_data ssrt_reg_aafes_rpt_data

type variables
String is_cus_status
end variables

on ssrt_reg_aafes_rpt_data.create
call super::create
end on

on ssrt_reg_aafes_rpt_data.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String 	ls_where, ls_type, ls_shopid, ls_shoptype, ls_fromdt, ls_todt
Long 		ll_row

dw_cond.AcceptText()

ls_type        = Trim(dw_cond.object.type[1])
ls_shopid		= Trim(dw_cond.object.partner[1])
ls_shoptype		= Trim(dw_cond.object.shoptype[1])
ls_fromdt      = String(dw_cond.Object.fromdt[1],'yyyymmdd')
ls_todt        = String(dw_cond.Object.todt[1], 'yyyymmdd')


If IsNull(ls_type) 		Then ls_type 		= ""
If IsNull(ls_shopid) 	Then ls_shopid		= ""
If IsNull(ls_shoptype) 	Then ls_shoptype 	= ""
If IsNull(ls_fromdt) 	Then ls_fromdt 	= ""
If IsNull(ls_todt) 		Then ls_todt 		= ""


ls_where = ""
If ls_type <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " type = '" + ls_type + "' "
End If

If ls_shopid <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " shopid = '" + ls_shopid + "'"
End If

If ls_shoptype <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " shop_type = '" + ls_shoptype + "'"
End If

//If ls_fromdt > ls_todt Then
//	f_msg_info(200, Title, "Date")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("fromdt")
//	Return
//End If
	
If ls_fromdt <> "" And ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " to_char(fromdt,'yyyymmdd') >= '" + ls_fromdt + "'"
	ls_where += " AND to_char(nvl(todt,sysdate),'yyyymmdd') <= '" + ls_todt + "' "
ElseIf ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " to_char(fromdt,'yyyymmdd') >= '" + ls_fromdt + "'"
ElseIf ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " to_char(nvl(todt,sysdate),'yyyymmdd') <= '" + ls_todt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If
SetRedraw(False)

If ll_row > 0 Then
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_disable")

	dw_cond.Enabled 		= False
else
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_enable")
	dw_cond.Enabled 		= True
	dw_cond.SetFocus()
End If

SetRedraw(True)
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: ssrt_reg_aafes_report_data
	Desc.	: 보고서(추가매출 등록)
	Ver.	: 1.0
	Date	: 2011.11.08
	Programer : kem
-------------------------------------------------------------------------*/

p_insert.TriggerEvent("ue_enable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)

dw_detail.SetColumn("type")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_type, ls_shopid, ls_shop_type, ls_key_id, ls_fromdt

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_type 			= Trim(dw_detail.Object.type[ll_i])
	ls_shopid 		= Trim(dw_detail.Object.shopid[ll_i])	
	ls_shop_type 	= Trim(dw_detail.Object.shop_type[ll_i])	
	ls_key_id 		= Trim(dw_detail.Object.key_id[ll_i])	
	ls_fromdt		= String(dw_detail.Object.fromdt[ll_i],'yyyymmdd')	
	
	If IsNull(ls_type)  		Then ls_type = ""
	If IsNull(ls_shopid) 	Then ls_shopid = ""
	If IsNull(ls_shop_type) Then ls_shop_type = ""
	If IsNull(ls_key_id) 	Then ls_key_id = ""
	If IsNull(ls_fromdt) 	Then ls_fromdt = ""
	
	If ls_type = "" Then 
		f_msg_usr_err(200, Title, "TYPE")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("type")
		Return -1
	End If
	
	If ls_shopid = "" Then 
		f_msg_usr_err(200, Title, "Shop")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("shopid")
		Return -1
	End If
	
	If ls_shop_type = "" Then 
		f_msg_usr_err(200, Title, "Shop Type")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("shop_type")
		Return -1
	End If
	
	If ls_key_id = "" Then 
		f_msg_usr_err(200, Title, "Key ID")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("key_id")
		Return -1
	End If
	
	If ls_fromdt = "" Then 
		f_msg_usr_err(200, Title, "From Date")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If
	
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
   End If
Next

Return 0
	
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_aafes_rpt_data
integer x = 37
integer y = 52
integer width = 2217
integer height = 264
string dataobject = "ssrt_cnd_reg_aafes_report_data"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within ssrt_reg_aafes_rpt_data
integer x = 2446
integer y = 68
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_aafes_rpt_data
integer x = 2747
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_aafes_rpt_data
integer x = 18
integer width = 2290
integer height = 320
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_aafes_rpt_data
integer x = 315
integer y = 1752
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_aafes_rpt_data
integer x = 23
integer y = 1752
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_aafes_rpt_data
integer x = 608
integer y = 1752
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_aafes_rpt_data
integer x = 18
integer y = 348
integer width = 3095
integer height = 1368
string dataobject = "ssrt_reg_aafes_report_data"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_aafes_rpt_data
integer x = 1179
integer y = 1752
end type

