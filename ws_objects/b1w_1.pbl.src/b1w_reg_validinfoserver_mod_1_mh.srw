$PBExportHeader$b1w_reg_validinfoserver_mod_1_mh.srw
$PBExportComments$[parkkh] validinfoserver 재처리
forward
global type b1w_reg_validinfoserver_mod_1_mh from w_a_reg_m
end type
end forward

global type b1w_reg_validinfoserver_mod_1_mh from w_a_reg_m
integer width = 3305
integer height = 1912
end type
global b1w_reg_validinfoserver_mod_1_mh b1w_reg_validinfoserver_mod_1_mh

type variables
String is_coid //사업자 ID
String is_result_fail
string is_result[], is_Xener_svccod[]

end variables

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_reg_validinfoserver_mod
	Desc.	: validinfoserverh 처리실패 재처리반영
	Date	: 2003.06.11
	Ver.	: 1.0
	Porgramer : Park Kyungh Hae(parkkh)
--------------------------------------------------------------------------*/
Long ll_rc
Int  li_cnt
String ls_ref_desc, ls_temp, ls_result[]

// SYSCTL1T의 사업자 ID
ls_ref_desc = ""
is_coid = fs_get_control("00","G200", ls_ref_desc)

//작업결과(Server인증Key) 코드 
ls_ref_desc = ""
ls_temp = fs_get_control("B1","P300", ls_ref_desc)
If ls_temp = "" Then Return 
fi_cut_string(ls_temp, ";" , ls_result[])
is_result_fail = ls_result[3]
is_result[] = ls_result[]

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   		//GateKeeper 연동 method

dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())
end event

event ue_ok();call super::ue_ok;String ls_where 
String ls_date_fr, ls_date_to, ls_validkey, ls_err_code
Date ld_date_to, ld_date_fr
Long   ll_rc
Int    li_rc

ls_date_fr = String(dw_cond.object.fromdt[1], "yyyymmdd")
ls_date_to = String(dw_cond.object.todt[1], "yyyymmdd")
ld_date_fr = dw_cond.object.fromdt[1]
ld_date_to = dw_cond.object.todt[1]
ls_validkey = dw_cond.object.validkey[1]
ls_err_code = dw_cond.object.err_code[1]

If IsNull(ls_date_fr) Then ls_date_fr = ""
If IsNull(ls_date_to) Then ls_date_to = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_err_code) Then ls_err_code = ""

If ls_date_fr <> "" and ls_date_to <> "" Then
	li_rc = fi_chk_frto_day(ld_date_fr, ld_date_to)
	If li_rc = - 1 Then
		f_msg_usr_err(201, title, "작업요청일")
		Return
	End If
End If

ls_where = ""
If ls_date_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(cworkdt, 'yyyymmdd') >= '" + ls_date_fr + "' "
End If

If ls_date_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(cworkdt, 'yyyymmdd') <= '" + ls_date_to + "' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " validkey = '" + ls_validkey + "' "
End If

If ls_err_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " err_code = '" + ls_err_code + "' "
End If

//사업자 ID
If is_coid <> "*" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " coid = '" + is_coid + "' "
End If

//작업결과가 실패인것만 retrieve 한다.
If is_result_fail <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " result = '" + is_result[3] + "' "
End If

dw_detail.is_where = ls_where
ll_rc = dw_detail.Retrieve()

If ll_rc < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
	Return
elseIf ll_rc = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If

p_ok.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = false

Return
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR
End If

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_cond.setredraw(False)
dw_detail.Reset()
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())
dw_cond.Enabled = True
dw_cond.SetFocus()
dw_cond.setredraw(true)

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_rc

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

//If This.Trigger Event ue_extra_save() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If

li_rc = This.Trigger Event ue_extra_save()

If li_rc = -1 Then
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
	
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

Return 0
end event

on b1w_reg_validinfoserver_mod_1_mh.create
call super::create
end on

on b1w_reg_validinfoserver_mod_1_mh.destroy
call super::destroy
end on

event type integer ue_extra_save();call super::ue_extra_save;Long   ll_rc
Int    li_cnt, li_count
String ls_validkey, ls_vpassword, ls_customerid, ls_auth_method, ls_ip_address
String ls_h323id, ls_coid, ls_gkid, ls_check_yn, ls_svccod, ls_xener_svc
Double lb_payamt
Long ll_row, ll_i
Integer li_rc
b1u_dbmgr4_v20	lu_dbmgr

If dw_detail.RowCount() = 0 Then Return 0 

li_rc = -2

For li_cnt = 1 to  dw_detail.RowCount()
	
	ls_check_yn = ""
	ls_check_yn = dw_detail.object.check_yn[li_cnt]
	
	If ls_check_yn = "1" Then
		ls_validkey = Trim(dw_detail.object.validkey[li_cnt])
		ls_vpassword = Trim(dw_detail.object.vpassword[li_cnt])
		ls_customerid = Trim(dw_detail.object.customerid[li_cnt])
		ls_auth_method = Trim(dw_detail.object.auth_method[li_cnt])
		ls_ip_address = Trim(dw_detail.object.ip_address[li_cnt])	
		ls_h323id = Trim(dw_detail.object.h323id[li_cnt])
		ls_svccod = dw_detail.object.svccod[li_cnt]
		If IsNull(ls_validkey) Then ls_validkey = ""
		If IsNull(ls_vpassword) Then ls_vpassword = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""
		If IsNull(ls_auth_method) Then ls_auth_method = ""
		If IsNull(ls_ip_address) Then ls_ip_address = ""
		If IsNull(ls_h323id) Then ls_h323id = ""
		If IsNull(ls_svccod) Then ls_svccod = ""

		If ls_validkey = "" Then
			f_msg_usr_err(200, title, "인증KEY")
			dw_detail.SetFocus()
			dw_detail.SetColumn("validkey")
			dw_detail.SetRow(li_cnt)
			dw_detail.ScrollToRow(li_cnt)
			Return li_rc
		End If
		
//		If ls_vpassword = "" Then
//			f_msg_usr_err(200, title, "인증PassWord")
//			dw_detail.SetFocus()
//			dw_detail.SetColumn("vpassword")
//			dw_detail.SetRow(li_cnt)
//			dw_detail.ScrollToRow(li_cnt)
//			Return li_rc
//		End If

		ls_xener_svc = 'N'
		For ll_i = 1  to UpperBound(is_Xener_svccod)
			IF ls_svccod = is_xener_svccod[ll_i] Then
				ls_xener_svc = 'Y'
				Exit
			End IF
		NEXT	

        IF ls_xener_svc = 'Y' Then

			If ls_auth_method = "" Then
				f_msg_usr_err(200, Title, "인증방법")
				dw_detail.SetFocus()
				dw_detail.SetColumn("auth_method")
				dw_detail.SetRow(li_cnt)
				dw_detail.ScrollToRow(li_cnt)
				Return li_rc
			End If		
			
			If LeftA(ls_auth_method,1) = 'S' Then
				If ls_ip_address = "" Then
					f_msg_usr_err(200, Title, "IP ADDRESS")
					dw_detail.SetFocus()
					dw_detail.SetColumn("ip_address")
					dw_detail.SetRow(li_cnt)
					dw_detail.ScrollToRow(li_cnt)
					Return li_rc
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				If ls_h323id = "" Then
					f_msg_usr_err(200, Title, "H323ID")
					dw_detail.SetFocus()
					dw_detail.SetColumn("h323id")
					dw_detail.SetRow(li_cnt)
					dw_detail.ScrollToRow(li_cnt)
					Return li_rc
				End If		
			End If
		End IF		
			
	End If
Next

//저장
lu_dbmgr = Create b1u_dbmgr4_v20
lu_dbmgr.is_caller = "b1w_reg_validinfoserver_mod_1_mh%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = gs_user_id
lu_dbmgr.is_data[2] = is_result[3]
lu_dbmgr.is_data[3] = is_result[4]
lu_dbmgr.is_data[4] = is_result[1]
  
lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
	Return li_rc
End If

Destroy lu_dbmgr

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_validinfoserver_mod_1_mh
integer x = 59
integer y = 60
integer width = 1472
integer height = 308
string dataobject = "b1dw_cnd_reg_validinfoserver_mod_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_validinfoserver_mod_1_mh
integer x = 1765
integer y = 68
end type

type p_close from w_a_reg_m`p_close within b1w_reg_validinfoserver_mod_1_mh
integer x = 2080
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_validinfoserver_mod_1_mh
integer width = 1577
integer height = 400
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_validinfoserver_mod_1_mh
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_validinfoserver_mod_1_mh
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_validinfoserver_mod_1_mh
integer x = 91
integer y = 1636
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_validinfoserver_mod_1_mh
integer y = 432
integer width = 3209
integer height = 1152
string dataobject = "b1dw_reg_validinfoserver_mod_1_mh"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_validinfoserver_mod_1_mh
integer x = 425
integer y = 1636
end type

