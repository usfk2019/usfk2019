$PBExportHeader$b0w_reg_sacnum_info_v20.srw
$PBExportComments$[ohj] 접속번호 구성 v20
forward
global type b0w_reg_sacnum_info_v20 from w_a_reg_m_m
end type
end forward

global type b0w_reg_sacnum_info_v20 from w_a_reg_m_m
integer width = 3365
end type
global b0w_reg_sacnum_info_v20 b0w_reg_sacnum_info_v20

type variables
String is_new = 'N' , is_type[]
end variables

on b0w_reg_sacnum_info_v20.create
call super::create
end on

on b0w_reg_sacnum_info_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b0w_reg_sacmst
	Desc. : 접속번호 Master
	Date : 2005.07.13
	Auth :  oh hye jin
------------------------------------------------------------------------*/
dw_master.SetRowFocusIndicator(off!)
dw_detail.SetRowFocusIndicator(off!)

String ls_tmp, ls_desc

ls_tmp = fs_get_control("00", "Z850" , ls_desc)
fi_cut_string(ls_tmp, ';', is_type[])
end event

event ue_ok();call super::ue_ok;String	ls_where, ls_type, ls_typeprefix1, ls_typeprefix2, ls_svccod
Long		ll_rows

is_new = fs_snvl(dw_cond.object.new[1], '')

If is_new = 'Y' Then
	
	b0f_setModifiedStatus(dw_master, 0, True, 'M')
	
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")	
	
   p_insert.TriggerEvent("Clicked")	
	
	Return
Else
	b0f_setModifiedStatus(dw_master, 0, False, 'M')
	ls_type = fs_snvl(dw_cond.Object.type[1], '')
	ls_typeprefix1 = fs_snvl(dw_cond.Object.typeprefix1[1], '')
	ls_typeprefix2 = fs_snvl(dw_cond.Object.typeprefix2[1], '')
	ls_svccod = fs_snvl(dw_cond.Object.svccod[1], '')

	//If ls_type = "" Then
	//	f_msg_info(200, Title, "Type")
	//	dw_cond.SetFocus()
	//	dw_cond.SetColumn("Type")
	//	Return
	//End If

	//Dynamic SQL
	ls_where = ""
	IF ls_type <> "" THEN	
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += " A.type = '" + ls_type + "'"
	END IF
	If ls_typeprefix1 <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " A.typeprefix1 = '" + ls_typeprefix1 + "' "
	End If
	If ls_typeprefix2 <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " A.typeprefix2 = '" + ls_typeprefix2 + "' "
	End If
	If ls_svccod <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " B.svccod = '" + ls_svccod + "' "
	End If
	
	dw_master.is_where	= ls_where
	ll_rows = dw_master.Retrieve()
	
	IF ll_rows < 0 THEN
		f_msg_usr_err(2100, Title, "Retrive")
	ELSEIF ll_rows = 0 THEN
		f_msg_info(1000, This.Title, "")
	End If
	
End If
end event

event type integer ue_reset();call super::ue_reset;//p_insert.TriggerEvent("ue_enable")

RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_type, ls_pbxno, ls_typeprefix1, ls_typeprefix2, ls_validkeytype, ls_sacnum, ls_telprefix, &
       ls_chgvalue, ls_fromdt, ls_todt, ls_sort, &
		 ls_type1, ls_pbxno1, ls_typeprefix11, ls_validkeytype1, ls_fromdt1, ls_todt1, &
		 ls_type2, ls_pbxno2, ls_typeprefix22, ls_validkeytype2, ls_fromdt2, ls_todt2, &
		 ls_telprefix1, ls_telprefix2, ls_svccod
Long ll_rows, ll_rows1, ll_rows2, i

If is_new = 'Y' Then
	ll_rows = dw_master.RowCount()
	If ll_rows = 0 Then Return 0
	//Loop
	For i=1 To ll_rows
		ls_type         = fs_snvl(dw_master.object.type[i]        , '')
		ls_pbxno        = fs_snvl(dw_master.object.pbxno[i]       , '')
		ls_typeprefix1  = fs_snvl(dw_master.object.typeprefix1[i] , '')
		ls_typeprefix2  = fs_snvl(dw_master.object.typeprefix2[i] , '')
		ls_validkeytype = fs_snvl(dw_master.object.validkeytype[i], '')	
		ls_sacnum       = fs_snvl(dw_master.object.sacnum[i]      , '')
		ls_svccod       = fs_snvl(dw_master.object.svccod[i]      , '')		
		ls_fromdt       =  String(dw_master.object.fromdt[i]      ,'yyyymmdd')
		ls_todt   	    =  String(dw_master.object.todt[i]        , 'yyyymmdd')
		
		If ls_type = "" Then
			f_msg_usr_err(200, Title,"Type")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("type")
			Return -1
		End If
		
		If ls_pbxno = "" Then
			f_msg_usr_err(200, Title,"교환기번호")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("pbxno")
			Return -1
		End If
		
		//route 일대는 둘중에 하나 필수
		If ls_type = is_type[1] Then
			If ls_typeprefix1 = "" And ls_typeprefix2 = "" Then
				f_msg_usr_err(200, Title,"Type Prefix")
				dw_master.SetRow(i)
				dw_master.ScrollToRow(i)
				dw_master.SetColumn("typeprefix1")
				Return -1
			End If
		//pid ls_typeprefix1 필수
		ElseIf ls_type = is_type[2] Then
			If ls_typeprefix1 = "" Then
				f_msg_usr_err(200, Title,"Type Prefix1")
				dw_master.SetRow(i)
				dw_master.ScrollToRow(i)
				dw_master.SetColumn("typeprefix1")
				Return -1
			End If
		End If
		
		If ls_validkeytype = "" Then
			f_msg_usr_err(200, Title,"인증key Type")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("validkeytype")
			Return -1
		End If
		
		If ls_fromdt = "" Then
			f_msg_usr_err(200, Title,"적용개시일")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("fromdt")
			Return -1
		End If
		
		//적용종료일 체크
		If ls_todt <> "" Then
			If ls_fromdt > ls_todt Then
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				dw_master.setColumn("todt")
				dw_master.setRow(i)
				dw_master.scrollToRow(i)
				dw_master.setFocus()
				Return -2
			End If
		End If
		
		If ls_sacnum = "" Then
			f_msg_usr_err(200, Title,"접속번호")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("sacnum")
			Return -1
		End If
		
		If ls_svccod = "" Then
			f_msg_info(9000, Title, "존재하지 않는 접속번호 입니다. 확인하세요!")
			dw_master.SetRow(i)
			dw_master.ScrollToRow(i)
			dw_master.SetColumn("sacnum")
			Return -1
		End If	
		
		//ls_itemcod_1[i] = ls_itemcod
	
		If dw_master.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_master.object.upt_user[i] = gs_user_id
			dw_master.object.uptdt[i]    = fdt_get_dbserver_now()
		End If
		
	Next
	
//	//적용종료일과 적용개시일 중복check를 위한 Sort
//	dw_master.SetRedraw(False)
//	ls_sort = "type, pbxno, string(fromdt,'yyyymmdd'), string(todt,'yyyymmdd')"
//	dw_master.SetSort(ls_sort)
//	dw_master.Sort()
//	dw_master.SetRedraw(True)
//	
//	//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//	For ll_rows1 = 1 To dw_master.RowCount()
//		
//		ls_type1         = fs_snvl(dw_master.object.type[ll_rows1]        , '')
//		ls_pbxno1        = fs_snvl(dw_master.object.pbxno[ll_rows1]       , '')
////		ls_typeprefix11    = fs_snvl(dw_master.object.typeprefix1[ll_rows1]   , '')
////		ls_typeprefix22    = fs_snvl(dw_master.object.typeprefix2[ll_rows1]   , '')
////		ls_validkeytype1 = fs_snvl(dw_master.object.validkeytype[ll_rows1], '')	
//		ls_fromdt1       =  String(dw_master.object.fromdt[ll_rows1]      , 'yyyymmdd')
//		ls_todt1         =  String(dw_master.object.todt[ll_rows1]        , 'yyyymmdd')
//		
//		If IsNull(ls_todt1) Or ls_todt1 = "" Then ls_todt1 = '99991231'
//		
//		For ll_rows2 = dw_master.RowCount() To ll_rows1 - 1 Step -1
//			If ll_rows1 = ll_rows2 Then
//				Exit
//			End If
//			
//			ls_type2         = fs_snvl(dw_master.object.type[ll_rows2]        , '')
//			ls_pbxno2        = fs_snvl(dw_master.object.pbxno[ll_rows2]       , '')
////			ls_keyprefix2    = fs_snvl(dw_master.object.keyprefix[ll_rows2]   , '')
////			ls_validkeytype2 = fs_snvl(dw_master.object.validkeytype[ll_rows2], '')	
//			ls_fromdt2       =  String(dw_master.object.fromdt[ll_rows2]      , 'yyyymmdd')
//			ls_todt2         =  String(dw_master.object.todt[ll_rows2]        , 'yyyymmdd')
//			
//			If IsNull(ls_todt2) Or ls_todt2 = "" Then ls_todt2 = '99991231'
//			
//			If (ls_type1 = ls_type2) And (ls_pbxno1 = ls_pbxno2) then // And (ls_keyprefix1 = ls_keyprefix2) Then And (ls_validkeytype1 = ls_validkeytype2) Then
//				If ls_todt1 >= ls_fromdt2 Then
//					f_msg_info(9000, Title, "같은 Type[ " + ls_type1 + " ], 같은 교환기번호[ " + ls_pbxno1 + " ]로 적용개시일이 중복됩니다.")//, 같은 인증KeyPrefix [ " + ls_keyprefix1 + " ]로 적용개시일이 중복됩니다.")//, 같은 인증Key Type [ " + ls_validkeytype1 + " ]로 적용개시일이 중복됩니다.")
//					dw_master.SetRow(ll_rows2)
//					dw_master.ScrollToRow(ll_rows2)
//					dw_master.SetColumn("type")
//					Return -2
//				End If
//			End If
//			
//		Next
//		
//	Next
//	
Else
	
	ll_rows = dw_detail.RowCount()
	If ll_rows = 0 Then Return 0
	
	For i=1 To ll_rows
		
		ls_telprefix    = fs_snvl(dw_detail.object.telprefix[i], '')
		ls_chgvalue     = fs_snvl(dw_detail.object.chgvalue[i] , '')
		
		If ls_telprefix = "" Then
			f_msg_usr_err(200, Title,"착신번호 변환Prefix")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("telprefix")
			Return -1
		End If
//		
//		If ls_chgvalue = "" Then
//			f_msg_usr_err(200, Title,"변환값")
//			dw_detail.SetRow(i)
//			dw_detail.ScrollToRow(i)
//			dw_detail.SetColumn("chgvalue")
//			Return -1
//		End If
		
	Next
	
	//적용종료일과 적용개시일 중복check를 위한 Sort
	dw_detail.SetRedraw(False)
	ls_sort = "telprefix"
	dw_detail.SetSort(ls_sort)
	dw_detail.Sort()
	dw_detail.SetRedraw(True)
	
	//적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
	For ll_rows1 = 1 To dw_detail.RowCount()
		
		ls_telprefix1 = fs_snvl(dw_detail.object.telprefix[ll_rows1]        , '')
		
		For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
			If ll_rows1 = ll_rows2 Then
				Exit
			End If
			
			ls_telprefix2 = fs_snvl(dw_detail.object.telprefix[ll_rows2]        , '')
			
			If ls_telprefix1 = ls_telprefix2 Then
				f_msg_info(9000, Title, "착신번호prefix [ " + ls_telprefix1 + " ]가 중복됩니다.")
				dw_detail.SetRow(ll_rows2)
				dw_detail.ScrollToRow(ll_rows2)
				dw_detail.SetColumn("telprefix")
				Return -2				
			End If
			
		Next
		
	Next
	
End If

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log
Double ld_seqno

If is_new = 'Y' Then
	
	SELECT SEQ_sacnuminfo.Nextval
	  INTO :ld_seqno
	  FROM DUAL;
	  
	If sqlca.sqlcode < 0 Then
		f_msg_sql_err(Title, "Select seqno error")
		RollBack;
		Return  0
	End If
	
	dw_master.Object.seqno[al_insert_row]	   = ld_seqno
	dw_master.Object.fromdt[al_insert_row]	   = fdt_get_dbserver_now()
	dw_master.Object.crt_user[al_insert_row]	= gs_user_id
	dw_master.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
	dw_master.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]
	
Else	
	ld_seqno = dw_master.Object.seqno[dw_master.Getrow()]
	dw_detail.Object.seqno[al_insert_row]	   = ld_seqno	
	
End If
	
Return 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
	
If is_new = 'Y' Then
	
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	ll_row = dw_master.InsertRow(dw_master.GetRow()+1)
	
	dw_master.ScrollToRow(ll_row)
	dw_master.SetRow(ll_row)
	dw_master.SetFocus()
	
	If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
		Return 0
	End if
	
	dw_master.SetColumn("type")
	
Else
	
	If dw_master.Getrow() <= 0 Then Return 0
	
   p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)
	
	dw_detail.ScrollToRow(ll_row)
	dw_detail.SetRow(ll_row)
	dw_detail.SetFocus()
	
	If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
		Return 0
	End if
	
	dw_detail.SetColumn("telprefix")
	
End If

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1
If is_new = 'Y' Then
	If dw_master.AcceptText() < 0 Then
		dw_master.SetFocus()
		Return LI_ERROR
	End if
	
	If This.Trigger Event ue_extra_save() < 0 Then
		dw_master.SetFocus()
		Return LI_ERROR
	End if
	
	If dw_master.Update() < 0 then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()
		
		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
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
			dw_master.SetFocus()
			Return LI_ERROR
		End If
		f_msg_info(3000,This.Title,"Save")
		dw_cond.object.new[1] = 'N'
		TriggerEvent("ue_ok")
	End if
Else
	
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
	End if
	
	If dw_master.Update() < 0 then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()
		
		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
			Return LI_ERROR
		End If
		f_msg_info(3010,This.Title,"Save")
		Return LI_ERROR
	End If
	
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

//ii_error_chk = 0
Return 0

end event

event type integer ue_delete();Constant Int LI_ERROR = -1
Long ll_row, ll_rows
//Int li_return

//ii_error_chk = -1
If is_new = 'Y' Then
	
	If This.Trigger Event ue_extra_delete() < 0 Then
		Return LI_ERROR
	End if
	
	If dw_master.RowCount() > 0 Then
		dw_master.DeleteRow(0)
		dw_master.SetFocus()
	End if
Else
	
	If This.Trigger Event ue_extra_delete() < 0 Then
		Return LI_ERROR
	End if
	
	If dw_detail.RowCount() > 0 Then
		dw_detail.DeleteRow(0)
		dw_detail.SetFocus()
	Else
		ll_row  = dw_master.getrow()
		ll_rows = dw_master.rowcount()
		
		If dw_master.RowCount() > 0 Then
			dw_master.DeleteRow(0)
				
			dw_master.SelectRow (0, False)
			dw_master.SelectRow (dw_master.GetRow(), True)
			
			dw_master.SetFocus ()

			If dw_detail.Trigger Event ue_retrieve(dw_master.GetRow()) < 0 Then
				Return LI_ERROR
			End If
			
		End If
	End if
	
End If

Return 0
//ii_error_chk = 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_sacnum_info_v20
integer y = 60
integer width = 2437
integer height = 204
string dataobject = "b0dw_cnd_sacnum_info_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_sacnum_info_v20
integer x = 2656
integer y = 76
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_sacnum_info_v20
integer x = 2962
integer y = 76
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_sacnum_info_v20
integer x = 23
integer width = 2528
integer height = 300
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_sacnum_info_v20
integer x = 32
integer width = 3209
integer height = 1004
string dataobject = "b0dw_cnd_reg_sacnum_info_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.type_t
uf_init(ldwo_SORT)
end event

event dw_master::itemchanged;call super::itemchanged;String ls_svccod

Choose Case lower(dwo.name)
	Case "sacnum"

		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM SACMST
		 WHERE SACNUM = :data;
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(Title, " SELECT SACMST ")
			Return -1
		End If
		dw_master.object.svccod[getrow()] = ls_svccod
		
		
End Choose
		 
end event

event dw_master::clicked;CALL u_d_sort::clicked

If is_new <> 'Y' Then
	//Call u_d_sgl_sel::clicked
	Call w_a_reg_m_m`dw_master::clicked
	
//	If row > 0 Then
//		If dw_detail.Trigger Event ue_retrieve(row) < 0 Then
//			Return
//		End If
//	End If
End If

end event

event dw_master::retrieveend;call super::retrieveend;If is_new = 'Y' Then
	If rowcount > 0 Then
		SelectRow( 1, False )
	End If
End If

end event

event dw_master::doubleclicked;call super::doubleclicked;//If row > 0 Then
//	If dw_detail.Trigger Event ue_retrieve(row) < 0 Then
//		Return
//	End If
//End If
end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_sacnum_info_v20
integer x = 32
integer y = 1356
integer width = 3209
integer height = 268
string dataobject = "b0dw_reg_sacnum_info_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//Retrieve
String ls_where
Double ld_seqno
Long ll_row

If is_new = 'Y' Then Return -1
If al_select_row = 0 Then Return -1		//해당 고객 없음
						
ld_seqno = dw_master.object.seqno[al_select_row]

ls_where = "seqno = '" + string(ld_seqno) + "' "		
dw_detail.is_where = ls_where		
ll_row = dw_detail.Retrieve()	

If ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If
		  
Return 0 
		
end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_sacnum_info_v20
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_sacnum_info_v20
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_sacnum_info_v20
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_sacnum_info_v20
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_sacnum_info_v20
integer x = 32
integer y = 1328
end type

