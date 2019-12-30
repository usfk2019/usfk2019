$PBExportHeader$b0w_reg_priceplanmst_sams.srw
$PBExportComments$[ceusee] 가격정책 등록
forward
global type b0w_reg_priceplanmst_sams from w_a_reg_m_m3
end type
end forward

global type b0w_reg_priceplanmst_sams from w_a_reg_m_m3
integer width = 3255
integer height = 2240
end type
global b0w_reg_priceplanmst_sams b0w_reg_priceplanmst_sams

type variables
Boolean ib_new
String is_check ,is_currency_type, is_zoncst
end variables

on b0w_reg_priceplanmst_sams.create
call super::create
end on

on b0w_reg_priceplanmst_sams.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_priceplanmst
	Desc.	: 가격 정책 마스터 등록
	Ver 	: 1.0
	Date	: 2002.11.12
	Progrmaer: Choi Bo Ra(cesuee)
-------------------------------------------------------------------------*/
ib_new = FALSE

String ls_desc
is_zoncst = fs_get_control("B0", "P100", ls_desc)
is_currency_type = fs_get_control("B0", "P105", ls_desc)
end event

event ue_ok();//조회
String ls_svccod, ls_priceplan_desc, ls_new, ls_where
Long ll_row

ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan_desc = Trim(dw_cond.object.priceplan_desc[1])
ls_new = Trim(dw_cond.object.new[1])
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan_desc) Then ls_priceplan_desc = ""
If IsNull(ls_new) Then ls_new = ""

//신규 등록 여부
If ls_new = "Y" Then
	ib_new = True
Else
	ib_new = False
End If


//신규일때
If ib_new = True Then
	dw_detail2.ib_delete = True
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("Clicked")
	dw_detail2.object.priceplan.Protect = 0
	dw_detail2.Object.priceplan.Background.Color = RGB(108, 147, 137)
	dw_detail2.Object.priceplan.Color = RGB(255, 255, 255)		
Else

	ls_where = ""
	If ls_svccod <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "svccod = '" + ls_svccod + "' "
	End If
	
	If ls_priceplan_desc <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "priceplan_desc like '" + ls_priceplan_desc + "%' "
	End If
	

	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	
	//확인
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return
	
	Else
		 //처음 선택 row  보여지게 하기
		dw_master.event ue_select()
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	End If

End If

end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;//저장 Check
String ls_svccod, ls_priceplan, ls_priceplan_desc
String ls_currency_type, ls_use_yn, ls_pricetable, ls_decpoint
String ls_itemcod, ls_auth_level, ls_validkey_cnt
Long ll_row, i

If dw_detail2.RowCount() = 0 Then 
	ai_return = 0
	Return
End If

//priceplanmst
ls_priceplan = Trim(dw_detail2.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""
If ls_priceplan = "" Then
	f_msg_usr_err(200, Title,"가격정책코드")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("priceplan")
	ai_return = -1
	Return
End If
	
ls_priceplan_desc = Trim(dw_detail2.object.priceplan_desc[1])
If IsNull(ls_priceplan_desc) Then ls_priceplan_desc = ""
If ls_priceplan_desc = "" Then
	f_msg_usr_err(200, Title,"가격정책명")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("priceplan_desc")
	ai_return = -1
	Return 
End If

ls_svccod = Trim(dw_detail2.object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""
If ls_svccod = "" Then
	f_msg_usr_err(200, Title,"서비스")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("svccod")
	ai_return = -1
	Return 
End If

ls_currency_type = Trim(dw_detail2.object.currency_type[1])
If IsNull(ls_currency_type) Then ls_currency_type = ""
If ls_currency_type = "" Then
	f_msg_usr_err(200, Title,"통화구분")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("currency_type")
	ai_return = -1
	Return
End If

ls_decpoint = String(dw_detail2.object.decpoint[1])
If IsNull(ls_decpoint) Then ls_decpoint = ""
If ls_decpoint = "" Then
	f_msg_usr_err(200, Title,"소숫점 자리수")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("decpoint")
	ai_return = -1
	Return
End If

ls_use_yn = Trim(dw_detail2.object.use_yn[1])
If IsNull(ls_use_yn) Then ls_svccod = ""
If ls_use_yn = "" Then
	f_msg_usr_err(200, Title,"사용여부")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("use_yn")
	ai_return = -1
	Return
End If

ls_pricetable = Trim(dw_detail2.object.pricetable[1])
If IsNull(ls_pricetable) Then ls_pricetable = ""
If ls_pricetable = "" Then
	f_msg_usr_err(200, Title,"적용요율 테이블")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("pricetable")
	ai_return = -1
	Return
End If
ls_auth_level= String(dw_detail2.object.auth_level[1])
If IsNull(ls_auth_level) Then ls_auth_level = ""
If ls_auth_level = "" Then
	f_msg_usr_err(200, Title,"Authority")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("auth_level")
	ai_return = -1
	Return
End If

ls_validkey_cnt = String(dw_detail2.object.validkeycnt[1])
If IsNull(ls_validkey_cnt) Then ls_validkey_cnt = ""
If ls_validkey_cnt = "" Then
	f_msg_usr_err(200, Title,"인증Key갯수")
	dw_detail2.SetFocus()
	dw_detail2.SetColumn("validkeycnt")
	ai_return = -1
	Return
End If

//Log
If dw_detail2.GetItemStatus(1, 0, Primary!) = DataModified! THEN
	dw_detail2.object.updt_user[1] = gs_user_id
	dw_detail2.object.updtdt[1] = fdt_get_dbserver_now()
End If

//Priceplandet tabel
ll_row = dw_detail.RowCount()
If ll_row = 0 Then
	ai_return = 0
	Return 
End If

For i = 1 To ll_row
	ls_itemcod = Trim(dw_detail.object.itemcod[1])
	If IsNull(ls_itemcod) Then ls_itemcod = ""
	If ls_itemcod = "" Then
		f_msg_usr_err(200, Title, "품목명")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("itemcod")
		ai_return = -2
		Return
	End If
	//Log
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[1] = gs_user_id
		dw_detail.object.updtdt[1] = fdt_get_dbserver_now()
   End If
Next

ai_return = 0
Return

end event

event ue_extra_insert(long al_insert_row, ref integer ai_return);call super::ue_extra_insert;String ls_priceplan
Long al_master_row

If ib_new Then
	dw_detail2.object.updt_user[al_insert_row] = gs_user_id
	dw_detail2.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
	dw_detail2.object.crt_user[al_insert_row] = gs_user_id
	dw_detail2.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
	dw_detail2.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
	p_insert.TriggerEvent("ue_disable")
	
	//Setting
	dw_detail2.object.decpoint[al_insert_row] = 0
	dw_detail2.object.pricetable[al_insert_row] = is_zoncst
	dw_detail2.object.currency_type[al_insert_row] = is_currency_type
Else
	p_insert.TriggerEvent("ue_enable")
   al_master_row = dw_master.GetSelectedRow(0)
	If al_master_row <= 0 Then Return		
	ls_priceplan = Trim(dw_master.object.priceplan[al_master_row])
	
   dw_detail.object.updt_user[al_insert_row] = gs_user_id
	dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
	dw_detail.object.crt_user[al_insert_row] = gs_user_id
	dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
	dw_detail.object.priceplan[al_insert_row] = ls_priceplan
	dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
	
End If


end event

event ue_delete;//Delete
Int li_return

ii_error_chk = -1

This.Trigger Event ue_extra_delete(li_return)

If li_return < 0 Then
	Return
End if

//dw_detail  Delete  contdet table delete
If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

//priceplandet table에 자료가 없으면 priceplanmst 자료 delete
If dw_detail.RowCount() = 0 Then  
   dw_detail2.DeleteRow(0)
   is_check = "DEL"			//삭제
End If

If dw_detail.RowCount() = 0 Then
	p_delete.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_disable")
End If

ii_error_chk = 0
end event

event type integer ue_save();Int li_return
Long ll_row

ii_error_chk = -1

If dw_detail2.AcceptText() < 0 Then
	dw_detail2.SetFocus()
	Return -1
End if

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

This.Trigger Event ue_extra_save(li_return)

If li_return = - 1 Then
	dw_detail2.SetFocus()
	p_insert.TriggerEvent("ue_disable")
	Return -1
End if

If li_return = - 2 Then
	dw_detail2.SetFocus()
	Return -1
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	f_msg_info(3010,This.Title,"Save")
	return -1
end If

If dw_detail2.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail2.SetFocus()
		return -1
	End If
	f_msg_info(3010,This.Title,"Save")
	return -1
end If

// 저장후 commit 전에 할일 
li_return = 1
Event ue_save_after( li_return )
If li_return < 0 then
	f_msg_info(3010,This.Title,"Save")
	rollback ;
	return -1
End If


//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then

	dw_detail.SetFocus()
	return -1
End If
p_insert.TriggerEvent("ue_enable")
f_msg_info(3000,This.Title,"Save")
//priceplanmst 저장후
String ls_svccod, ls_priceplan_desc
If ib_new Then
	ls_svccod = Trim(dw_detail2.object.svccod[1])
	ls_priceplan_desc = Trim(dw_detail2.object.priceplan_desc[1])
   dw_detail2.reset()
	dw_cond.Reset()
	dw_cond.InsertRow(0)
	dw_cond.object.svccod[1] = ls_svccod
	dw_cond.object.priceplan_desc[1] = ls_priceplan_desc
	TriggerEvent("ue_ok")
	ib_new = False
End If

//priceplanmst table 삭제후  retrieve
If is_check = "DEL" Then				//Delete
  If dw_master.RowCount() > 1 Then		//row이 있음 Ok Event
	 ll_row = TriggerEvent("ue_ok")
	 If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -1
	 End If
 Else
 	 TriggerEvent("ue_reset")
  	 
 End If
 is_check = ""
End If

ii_error_chk = 0
return 1
end event

event ue_insert;Long ll_row
Int li_return

ii_error_chk = -1
If ib_new  Then
	ll_row = dw_detail2.InsertRow(dw_detail.GetRow() +1 )
	dw_detail2.ScrollToRow(ll_row)
	dw_detail2.SetRow(ll_row)
	dw_detail2.SetFocus()
Else	
	ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)
	dw_detail.ScrollToRow(ll_row)
	dw_detail.SetRow(ll_row)
	dw_detail.SetFocus()

End If

This.Trigger Event ue_extra_insert(ll_row,li_return)

If li_return < 0 Then
	Return
End if

ii_error_chk = 0
end event

type dw_cond from w_a_reg_m_m3`dw_cond within b0w_reg_priceplanmst_sams
integer x = 73
integer y = 56
integer width = 1618
integer height = 208
string dataobject = "b0dw_cnd_reg_pricepanmst_sams"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m3`p_ok within b0w_reg_priceplanmst_sams
integer x = 1810
integer y = 48
end type

type p_close from w_a_reg_m_m3`p_close within b0w_reg_priceplanmst_sams
integer x = 2107
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b0w_reg_priceplanmst_sams
integer width = 1701
integer height = 292
end type

type dw_master from w_a_reg_m_m3`dw_master within b0w_reg_priceplanmst_sams
integer y = 300
integer height = 548
string dataobject = "b0dw_cnd_pricerate1_sams"
end type

event dw_master::ue_select;Long ll_selected_row 
Integer li_return, li_ret


ll_selected_row = GetSelectedRow( 0 )

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = Parent.Event ue_save()
			If isnull( li_ret ) or li_ret < 0 then return
		CASE 2
		CASE ELSE
			Return
	END CHOOSE
		
end If


//순서 바꿈
dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If
	
dw_detail.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If

end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.priceplan_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m3`dw_detail within b0w_reg_priceplanmst_sams
integer y = 1384
string dataobject = "b0dw_reg_priceplandet_sams"
end type

event dw_detail::ue_retrieve;call super::ue_retrieve;String ls_priceplan, ls_where
Long ll_row

If al_select_row = 0 Then Return
ls_priceplan = Trim(dw_master.object.priceplan[al_select_row])
ls_where = "priceplan = '" + ls_priceplan + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then		
	f_msg_usr_err(2100, Title, "Retrieve()")
	ai_return = -1
	Return
End If

ai_return = 0
ib_insert = True
ib_delete = True
Return
end event

event dw_detail::retrieveend;call super::retrieveend;//Long i
//String ls_mainitem_yn
//
//If rowcount = 0 Then
//	p_save.TriggerEvent("ue_disable")
//End If
//
//
//For i = 1 To rowcount 
//	dw_detail.object.chk[i] = "Y" 
//
//Next
//
end event

type p_insert from w_a_reg_m_m3`p_insert within b0w_reg_priceplanmst_sams
integer y = 2008
end type

type p_delete from w_a_reg_m_m3`p_delete within b0w_reg_priceplanmst_sams
integer x = 329
integer y = 2008
end type

type p_save from w_a_reg_m_m3`p_save within b0w_reg_priceplanmst_sams
integer x = 626
integer y = 2008
end type

type p_reset from w_a_reg_m_m3`p_reset within b0w_reg_priceplanmst_sams
integer x = 1326
integer y = 2008
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b0w_reg_priceplanmst_sams
integer y = 880
integer height = 464
string dataobject = "b0dw_reg_priceplanmst_sams"
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail2::ue_retrieve(long al_select_row, ref integer ai_return);//priceplanmst table retrieve
String ls_priceplan, ls_where, ls_filter
Long ll_row
Integer li_exist
DataWindowChild ldc_child

If al_select_row = 0 Then Return
ls_priceplan = Trim(dw_master.object.priceplan[al_select_row])
ls_where = "priceplan = '" + ls_priceplan + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()

If ll_row < 0 Then		
	f_msg_usr_err(2100, Title, "Retrieve()")
	ai_return = -1
	Return
End If

//해당 service에 대한 Item만 가져옴
li_exist = dw_detail.GetChild("itemcod", ldc_child)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild()-Item Code")

ls_filter = "svccod = '" + Trim(This.object.svccod[1]) + "' "
ldc_child.SetFilter(ls_filter)							//Filter정함
ldc_child.Filter()
ldc_child.SetTransObject(SQLCA)
li_exist =ldc_child.Retrieve()

If li_exist < 0 Then 								//디비 오류 
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return
End If 

This.object.priceplan.Protect = 1
This.Object.priceplan.Background.Color = RGB(255, 251, 240)
This.Object.priceplan.Color = RGB(0, 0, 0)		

//성공
ai_return = 0
ib_insert = True
ib_delete = True
end event

event dw_detail2::itemchanged;call super::itemchanged;If ib_new = True Then
	p_insert.TriggerEvent("ue_disable")
End If
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b0w_reg_priceplanmst_sams
integer x = 27
integer y = 848
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b0w_reg_priceplanmst_sams
integer x = 27
integer y = 1348
end type

