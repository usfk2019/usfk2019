$PBExportHeader$c1w_reg_carrier_rate2_naray.srw
$PBExportComments$[ssong] 회선정산요율 naray old virsion
forward
global type c1w_reg_carrier_rate2_naray from w_a_reg_m
end type
end forward

global type c1w_reg_carrier_rate2_naray from w_a_reg_m
event ue_fileread ( )
end type
global c1w_reg_carrier_rate2_naray c1w_reg_carrier_rate2_naray

type variables
String is_ratetype
end variables

on c1w_reg_carrier_rate2_naray.create
call super::create
end on

on c1w_reg_carrier_rate2_naray.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_carrierid, ls_where
Long ll_row

ls_carrierid = Trim(dw_cond.object.cdsaup[1])

If IsNull(ls_carrierid) Then ls_carrierid = ""

// 필수항목 Check
If ls_carrierid = "" Then
	f_msg_info(200, Title,"회선사업자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cdsaup")
   Return
End If

// Dynamic SQL
If ls_carrierid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " carrierid = '" + ls_carrierid + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

IF ll_row = 0 Then 
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")



end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.object.carrierid[al_insert_row] = dw_cond.object.cdsaup[1]

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.opendt[al_insert_row] = Date(fdt_get_dbserver_now())

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long li_RowCount, li_row
String ls_addamt

li_RowCount = dw_detail.RowCount()

For li_row = 1 to li_RowCount
	
	// 필수항목 Check
	If IsNull(dw_detail.object.areacod[li_row]) Then
		f_msg_usr_err(200, Title, "지역코드")
		dw_detail.SetColumn("areacod")
		dw_detail.SetRow(li_row)
		Return -1
	End If
	
	If IsNull(dw_detail.object.opendt[li_row]) Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	
	If IsNull(dw_detail.object.opendt[li_row]) Then
		f_msg_usr_err(200, Title, "적용개시일")
		dw_detail.SetColumn("opendt")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	
	If IsNull(dw_detail.object.zoncod[li_row]) Then
		f_msg_usr_err(200, Title, "대역코드")
		dw_detail.SetColumn("zoncod")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	
	If dw_detail.object.addsec[li_row] = 0 Then
		f_msg_usr_err(200, Title, "도수(sec)")
		dw_detail.SetColumn("addsec")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	
	ls_addamt = String(dw_detail.object.addamt[li_row])
	If IsNull(ls_addamt) Then ls_addamt = ''
		
	If ls_addamt = '' Then
		f_msg_usr_err(200, Title, "금액")
		dw_detail.SetColumn("addamt")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	
	If IsNull(dw_detail.object.zonegroup[li_row]) Then
		f_msg_usr_err(200, Title, "대역그룹")
		dw_detail.SetColumn("zonegroup")
		dw_detail.SetRow(li_row)
		Return -1 
	End If
	If dw_detail.GetItemStatus(li_row, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[li_row] = gs_user_id
		dw_detail.object.updtdt[li_row] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[li_row] = gs_pgm_id[gi_open_win_no]
	End If
	
Next

Return 0
end event

event type integer ue_insert();call super::ue_insert;dw_cond.object.cdsaup.Protect = 1

Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.reset()
dw_cond.insertrow(0)

dw_cond.object.cdsaup.Protect = 0

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within c1w_reg_carrier_rate2_naray
integer width = 1152
integer height = 164
string dataobject = "c1dw_cnd_reg_carrier_rate_naray"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within c1w_reg_carrier_rate2_naray
integer x = 1349
integer y = 44
end type

type p_close from w_a_reg_m`p_close within c1w_reg_carrier_rate2_naray
integer x = 1655
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within c1w_reg_carrier_rate2_naray
integer width = 1189
integer height = 240
end type

type p_delete from w_a_reg_m`p_delete within c1w_reg_carrier_rate2_naray
integer x = 334
integer y = 1576
end type

type p_insert from w_a_reg_m`p_insert within c1w_reg_carrier_rate2_naray
integer x = 41
integer y = 1576
end type

type p_save from w_a_reg_m`p_save within c1w_reg_carrier_rate2_naray
integer x = 631
integer y = 1576
end type

type dw_detail from w_a_reg_m`dw_detail within c1w_reg_carrier_rate2_naray
integer y = 256
integer height = 1264
string dataobject = "c1dw_inq_reg_carrier_rate2_naray"
end type

event dw_detail::constructor;call super::constructor;dw_detail.setrowfocusindicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within c1w_reg_carrier_rate2_naray
integer x = 1147
integer y = 1576
end type

