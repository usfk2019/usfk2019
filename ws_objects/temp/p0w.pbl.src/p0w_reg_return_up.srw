$PBExportHeader$p0w_reg_return_up.srw
$PBExportComments$[jsha] 반품 카드 수정조회
forward
global type p0w_reg_return_up from w_a_reg_m
end type
end forward

global type p0w_reg_return_up from w_a_reg_m
integer width = 2976
integer height = 1816
end type
global p0w_reg_return_up p0w_reg_return_up

on p0w_reg_return_up.create
call super::create
end on

on p0w_reg_return_up.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where
Long ll_rows
String ls_returndt_fr, ls_returndt_to, ls_pid, ls_return_type, ls_partner
Date ld_returndt_fr, ld_returndt_to
Integer li_check

ld_returndt_fr = dw_cond.object.returndt_fr[1]
ld_returndt_to = dw_cond.object.returndt_to[1]
ls_returndt_fr = String(ld_returndt_fr, 'yyyymmdd')
ls_returndt_to = String(ld_returndt_to, 'yyyymmdd')
ls_pid = Trim(dw_cond.object.pid[1])
ls_return_type = Trim(dw_cond.object.return_type[1])
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_returndt_fr) then ls_returndt_fr = ""
If IsNull(ls_returndt_to) then ls_returndt_to = ""
If IsNull(ls_pid) then ls_pid = ""
If IsNull(ls_return_type) then ls_return_type = ""
If IsNull(ls_partner) then ls_partner = ""
//Messagebox("1", ls_returndt_to)

//반품일자 Check
IF ls_returndt_to <> "" AND ls_returndt_fr <> "" THEN
	li_check = fi_chk_frto_day(ld_returndt_fr, ld_returndt_to)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "반품일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("returndt_fr")
		Return
	END IF
END IF

//Dynamic SQL
ls_where = ""

If ls_returndt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(p_cardreturn.returndt,'yyyymmdd') >= '" + ls_returndt_fr + "' "
End If

If ls_returndt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(p_cardreturn.returndt,'yyyymmdd') <= '" + ls_returndt_to + "' "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.pid = '" + ls_pid + "' "
End If

If ls_return_type <> "" Then
	If ls_where <> "" THen ls_where += " AND "
	ls_where += "p_cardreturn.return_type = '" + ls_return_type + "' "
END If

If ls_partner <> "" Then
	If ls_where <> "" THen ls_where += " AND "
	ls_where += "p_cardmst.partner_prefix = '" + ls_partner + "' "
END If

dw_detail.is_where = ls_where

//Retrieve()
ll_rows = dw_detail.Retrieve()

If ll_rows = 0  Then
	f_msg_info(1000, Title, "")
	//TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve")
End If

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_rows, ll_rowcnt
String ls_returndt, ls_return_type

ll_rows = dw_detail.RowCount()

For ll_rowcnt = 1 to ll_rows
	ls_returndt = Trim(String(dw_detail.object.p_cardreturn_returndt[ll_rowcnt],'yyyymmdd'))
	ls_return_type = Trim(dw_detail.object.p_cardreturn_return_type[ll_rowcnt])
	
	If IsNull(ls_returndt) then ls_returndt = ""
	If IsNull(ls_return_type) then ls_return_type = ""
	
	IF ls_returndt = "" THEN
		f_msg_usr_err(200, Title, "반품일자")
		dw_detail.setColumn("p_cardreturn_returndt")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_return_type = "" THEN
		f_msg_usr_err(200, Title, "반품사유")
		dw_detail.setColumn("p_cardreturn_return_type")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.p_cardreturn_updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.p_cardreturn_updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
		dw_detail.Object.p_cardreturn_pgm_id[ll_rowcnt]		= gs_pgm_id[gi_open_win_no]		
	END IF
Next

Return 0
	
end event

event type integer ue_extra_delete();call super::ue_extra_delete;p0c_dbmgr2   lu_dbmgr
Integer li_rc
li_rc = MessageBox(This.Title, "선택하신 자료를 삭제시 복구할 수 없습니다.~r~n삭제하시겠습니까?~r~n" &
                   , Question!, YesNo!)

//No
If li_rc = 2 Then Return -1

//Yes
lu_dbmgr = Create p0c_dbmgr2
lu_dbmgr.is_caller = "p0w_reg_return_up%delete"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	//error
	Destroy lu_dbmgr
	Return -1
END If
	
Destroy lu_dbmgr

Return 0

end event

event type integer ue_delete();Constant Int LI_ERROR = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
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
End If

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within p0w_reg_return_up
integer width = 1801
integer height = 312
string dataobject = "p0dw_cnd_reg_return_up"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p0w_reg_return_up
integer x = 1984
integer y = 76
end type

type p_close from w_a_reg_m`p_close within p0w_reg_return_up
integer x = 2309
integer y = 76
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within p0w_reg_return_up
integer width = 1861
integer height = 396
end type

type p_delete from w_a_reg_m`p_delete within p0w_reg_return_up
integer x = 41
integer y = 1560
end type

type p_insert from w_a_reg_m`p_insert within p0w_reg_return_up
boolean visible = false
integer y = 1580
end type

type p_save from w_a_reg_m`p_save within p0w_reg_return_up
integer x = 338
integer y = 1560
end type

type dw_detail from w_a_reg_m`dw_detail within p0w_reg_return_up
integer y = 428
integer width = 2871
integer height = 1084
string dataobject = "p0dw_reg_return_up"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!) 
end event

type p_reset from w_a_reg_m`p_reset within p0w_reg_return_up
integer x = 855
integer y = 1560
end type

