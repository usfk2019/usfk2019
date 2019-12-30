$PBExportHeader$c1w_reg_carrier_mst.srw
$PBExportComments$[ysbyun]회선사업자등록
forward
global type c1w_reg_carrier_mst from w_a_reg_m_m
end type
end forward

global type c1w_reg_carrier_mst from w_a_reg_m_m
integer width = 3191
integer height = 1964
end type
global c1w_reg_carrier_mst c1w_reg_carrier_mst

on c1w_reg_carrier_mst.create
call super::create
end on

on c1w_reg_carrier_mst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;
String ls_nmsaup, ls_keysaup
String ls_where
Long ll_row

// 검색조건
ls_nmsaup   = trim(dw_cond.Object.nmsaup[1])
ls_keysaup  = trim(dw_cond.Object.keysaup[1])


ls_where = ""
If ls_nmsaup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " carriernm like '" + ls_nmsaup + "%' "
End If

If ls_keysaup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	   ls_where += " carrierkey like '" + ls_keysaup + "%' "
End If


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
  

If ll_row = 0 Then 
		f_msg_info(1000, Title, "등록된 사업자가 없습니다.")
		p_insert.TriggerEvent("ue_enable")
		
ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return
End If

	
	
	
end event

event type integer ue_reset();call super::ue_reset;p_reset.TriggerEvent("ue_enable")
return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_idsaup, ls_keysaup, ls_nmsaup, ls_carriertype, ls_ratetype
int li_curRow,li_rowcount

li_rowcount = dw_detail.RowCount()
If li_rowcount = 0 then return 0

li_curRow = dw_detail.GetRow()

ls_idsaup  = dw_detail.Object.carrierid[li_curRow]
ls_keysaup = dw_detail.Object.carrierkey[li_curRow]
ls_nmsaup  = dw_detail.Object.carriernm[li_curRow]
ls_carriertype = dw_detail.object.carriertype[li_curRow]
ls_ratetype = dw_detail.object.ratetype[li_curRow]

IF isnull(ls_idsaup) then ls_idsaup = ""
IF isnull(ls_keysaup) then ls_keysaup = ""
IF isnull(ls_nmsaup) then ls_nmsaup = ""
If IsNull(ls_carriertype) Then ls_carriertype = ""
If IsNull(ls_ratetype) Then ls_ratetype = ""

    
	 If ls_idsaup = "" Then
		f_msg_usr_err(200, Title,"사업자ID")
		dw_detail.SetRow(li_curRow)
		dw_detail.ScrollToRow(li_curRow)
		dw_detail.SetColumn("carrierid")
		Return -1
	 End If
    
	 If ls_keysaup = "" Then
		f_msg_usr_err(200, Title,"사업자Key")
		dw_detail.SetRow(li_curRow)
		dw_detail.ScrollToRow(li_curRow)
		dw_detail.SetColumn("carrierkey")
		Return -1
	 End If
	 
	 If ls_nmsaup = "" Then
		f_msg_usr_err(200, Title,"사업자명")
		dw_detail.SetRow(li_curRow)
		dw_detail.ScrollToRow(li_curRow)
		dw_detail.SetColumn("carriernm")
		Return -1
	 End If
	 
	 If ls_carriertype = "" Then
		f_msg_usr_err(200, Title, "사업자유형")
		dw_detail.SetRow(li_curRow)
		dw_detail.ScrollToRow(li_curROw)
		dw_detail.SetColumn("carriertype")
		Return -1
	End If
	
	If ls_ratetype = "" Then
		f_msg_usr_err(200, Title, "정산유형")
		dw_detail.SetRow(li_curRow)
		dw_detail.ScrollToRow(li_curROw)
		dw_detail.SetColumn("ratetype")
		Return -1
	End If
    
	   dw_detail.object.updt_user[li_curRow] = gs_user_id
		dw_detail.object.updtdt[li_curRow] = fdt_get_dbserver_now()
	 
return 0
 

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;

dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
				
return 0
end event

event type integer ue_save();int li_newrow,li_oldrow
li_oldrow = dw_master.GetRow()
Constant Int LI_ERROR = -1


If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
End if

// 저장후 화면갱신 
triggerEvent('ue_ok')

return 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
//Int li_return

//ii_error_chk = -1
dw_detail.Reset()
dw_master.Reset()

ll_row = dw_detail.InsertRow(0)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

p_save.TriggerEvent("ue_enable")

dw_detail.object.carrierid.protect = 0
dw_detail.object.carrierid.background.color = RGB(108,147,137)
dw_detail.object.carrierid.color = RGB(255,255,255)

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within c1w_reg_carrier_mst
integer y = 44
integer width = 2295
integer height = 180
string dataobject = "c1dw_cnd_reg_carrier_mst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within c1w_reg_carrier_mst
integer x = 2519
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within c1w_reg_carrier_mst
integer x = 2821
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within c1w_reg_carrier_mst
integer width = 2391
integer height = 244
end type

type dw_master from w_a_reg_m_m`dw_master within c1w_reg_carrier_mst
integer x = 9
integer y = 276
integer width = 3118
integer height = 492
string dataobject = "c1dw_inq_reg_carrier_mst"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.carrierid_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within c1w_reg_carrier_mst
integer x = 9
integer y = 804
integer width = 3109
integer height = 888
string dataobject = "c1dw_reg_reg_carrier_mst"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)


dw_detail.is_help_win[1] = "w_hlp_post"
dw_detail.idwo_help_col[1] = dw_detail.Object.zipcod
dw_detail.is_data[1] = "CloseWithReturn"
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_idsaup, ls_where
Long ll_row

ls_idsaup = dw_master.Object.carrierid[al_select_row]
ls_where = "carrierid = '" + ls_idsaup + "' "

dw_detail.is_where = ls_where		

ll_row = dw_detail.Retrieve()	

If ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If

This.object.carrierid.Protect = 1
This.Object.carrierid.Background.Color = RGB(255, 251, 240)
This.Object.carrierid.Color = RGB(0, 0, 0)

Return 0
end event

event dw_detail::doubleclicked;call super::doubleclicked;int li_row 

Choose Case dwo.name
			Case "zipcod"
				If iu_cust_help.ib_data[1] Then
					Object.zipcod[row] = iu_cust_help.is_data[1]
					Object.addr1[row] = iu_cust_help.is_data[2]
					Object.addr2[row] = iu_cust_help.is_data[3]
				End if				
End Choose
end event

event dw_detail::ue_init();call super::ue_init;This.is_help_win[1] = "w_hlp_post"
This.idwo_help_col[1] = This.Object.zipcod
This.is_data[1] = "CloseWithReturn"
end event

type p_insert from w_a_reg_m_m`p_insert within c1w_reg_carrier_mst
integer x = 23
integer y = 1708
end type

type p_delete from w_a_reg_m_m`p_delete within c1w_reg_carrier_mst
integer x = 315
integer y = 1708
end type

type p_save from w_a_reg_m_m`p_save within c1w_reg_carrier_mst
integer x = 613
integer y = 1708
end type

type p_reset from w_a_reg_m_m`p_reset within c1w_reg_carrier_mst
integer x = 1339
integer y = 1708
boolean enabled = true
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within c1w_reg_carrier_mst
integer x = 9
integer y = 772
end type

