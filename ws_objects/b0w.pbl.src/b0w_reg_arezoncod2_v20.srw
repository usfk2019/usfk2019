$PBExportHeader$b0w_reg_arezoncod2_v20.srw
$PBExportComments$[ohj] 서비스, 발신지별  대역 등록 v20
forward
global type b0w_reg_arezoncod2_v20 from w_a_reg_m
end type
type cb_load from commandbutton within b0w_reg_arezoncod2_v20
end type
type p_reload from u_p_reload within b0w_reg_arezoncod2_v20
end type
type p_saveas from u_p_saveas within b0w_reg_arezoncod2_v20
end type
type p_fileread from u_p_fileread within b0w_reg_arezoncod2_v20
end type
end forward

global type b0w_reg_arezoncod2_v20 from w_a_reg_m
integer width = 4050
integer height = 1864
event ue_reload ( )
event ue_saveas ( )
event ue_fileread ( )
cb_load cb_load
p_reload p_reload
p_saveas p_saveas
p_fileread p_fileread
end type
global b0w_reg_arezoncod2_v20 b0w_reg_arezoncod2_v20

type variables
String is_type
end variables

event ue_reload();Boolean lb_return
String ls_ipaddress, ls_port
String ls_buffer
Long ll_return, ll_socket, ll_length

String ls_module, ls_ref_no, ls_ref_desc

u_api lu_api
lu_api =  Create u_api

ls_module = "00"
ls_ref_no = "S60" + gc_server_no + "1"
ls_ipaddress = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

ls_module = "00"
ls_ref_no = "S602"
ls_port = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
ll_socket = lu_api.PBTcpConnectA(ls_ipaddress, ls_port)
If ll_socket > 0 Then
	ls_buffer = "2   1234"
	ll_length = LenA(ls_buffer)
	ll_return = lu_api.PBTcpWriteA(ll_socket, ls_buffer, ll_length)
	lb_return = lu_api.PBTcpCloseA(ll_socket)
	If ll_return <> ll_length Then
		f_msg_usr_err(9000, Title, "Server에 반영되지 않았습니다.")
	Else
		f_msg_info(3000, Title, "Server에 반영되었습니다.")
	End If
Else
	f_msg_usr_err(9000, Title, "Server에 반영되지 않았습니다.")
End If

end event

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel! , True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

event ue_fileread();//승인 요청 된 파일 불러옴
Constant Integer li_MAX_DIR = 255
String ls_filename, ls_pathname, ls_curdir
Int li_rc
Long ll_row
Boolean	lb_return

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

//파일 선택
li_rc = GetFileOpenName("Select File" , ls_pathname, ls_filename, '', &
						'Text Files(*.TXT), *.TXT')
						
If li_rc <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

dw_detail.Reset()
ll_row= dw_detail.RowCount()
dw_detail.importfile(ls_pathname)

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api
ls_pathname = ""

Return 
end event

on b0w_reg_arezoncod2_v20.create
int iCurrent
call super::create
this.cb_load=create cb_load
this.p_reload=create p_reload
this.p_saveas=create p_saveas
this.p_fileread=create p_fileread
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_load
this.Control[iCurrent+2]=this.p_reload
this.Control[iCurrent+3]=this.p_saveas
this.Control[iCurrent+4]=this.p_fileread
end on

on b0w_reg_arezoncod2_v20.destroy
call super::destroy
destroy(this.cb_load)
destroy(this.p_reload)
destroy(this.p_saveas)
destroy(this.p_fileread)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_arezoncod2_v20
	Desc	: 	서비스, 발신지별 대역 등록
	Ver	:	1.0
	Date	: 	2005.04.14
	Prgogramer : oh hye jin
--------------------------------------------------------------------------*/
Integer li_rc
String  ls_filter
DataWindowChild ldwc_nodeno


//조회를 하고 나서 표준 대역 Load 할 수 있게 한다.
cb_load.enabled = False
p_reload.TriggerEvent("ue_disable")	

String ls_ref_desc
//상품요율 서비스유형별 관리여부(Y/N)
is_type = fs_get_control("00", "Z150", ls_ref_desc)	

If is_type = 'Y' Then
	dw_cond.dataObject = "b0dw_cnd_reg_arezoncod2_svc_v20"
	dw_cond.SetTransObject(SQLCA)
	dw_cond.insertrow(0)
	dw_cond.Object.parttype[1] = "S"
	dw_cond.Object.priceplan.Visible   = 0
	dw_cond.Object.priceplan_t.Visible = 0
	
	dw_cond.Object.svccod.Visible   = 1
	dw_cond.Object.svccod_t.Visible = 1
	dw_cond.SetItem(1, 'priceplan', 'ALL')
	
Else
	dw_cond.dataObject = "b0dw_cnd_reg_arezoncod2_v20"
	dw_cond.SetTransObject(SQLCA)
	dw_cond.insertrow(0)
	dw_cond.SetItem(1, 'svccod'   , 'ALL')
	dw_cond.SetItem(1, 'priceplan', 'ALL')
	
	li_rc = dw_cond.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = 'ALL' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Title, "Nodeno Retrieve()")
			Return
		End If	
End If


end event

event type integer ue_extra_insert(long al_insert_row);//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("arezoncod2_areacod")

//Setting
dw_detail.object.arezoncod2_svccod[al_insert_row]    = Trim(dw_cond.object.svccod[1])
dw_detail.object.arezoncod2_priceplan[al_insert_row] = Trim(dw_cond.object.priceplan[1])
dw_detail.object.arezoncod2_nodeno[al_insert_row]    = Trim(dw_cond.object.nodeno[1])

//Log
dw_detail.object.arezoncod2_crt_user[al_insert_row]  = gs_user_id
dw_detail.object.arezoncod2_crtdt[al_insert_row]     = fdt_get_dbserver_now()
dw_detail.object.arezoncod2_pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
//dw_detail.object.arezoncod2_updt_user[al_insert_row] = gs_user_id
//dw_detail.object.arezoncod2_updtdt[al_insert_row]    = fdt_get_dbserver_now()

Return 0
end event

event ue_ok();call super::ue_ok;//조회
String ls_parttype, ls_nodeno, ls_countrycod, ls_zoncod, ls_areacod, ls_svccod, ls_priceplan, ls_where
Long ll_row

ls_nodeno     = fs_snvl(dw_cond.object.nodeno[1]    , '')
ls_countrycod = fs_snvl(dw_cond.object.countrycod[1], '')
ls_zoncod     = fs_snvl(dw_cond.object.zoncod[1]    , '')
ls_areacod    = fs_snvl(dw_cond.object.areacod[1]   , '')
ls_svccod     = fs_snvl(dw_cond.object.svccod[1]   , '')
ls_priceplan  = fs_snvl(dw_cond.object.priceplan[1], '')	 

If is_type = 'Y' Then
	ls_parttype   = fs_snvl(dw_cond.object.parttype[1], '')

	//필수 항목 Check

	If ls_parttype = "" Then
		f_msg_info(200, Title,"작업선택")
		dw_cond.SetFocus()
		dw_cond.SetColumn("parttype")
		Return
	End If	
	
	If ls_parttype = 'S' Then
		ls_priceplan = 'ALL'		
		
		If ls_svccod = "" Then
			f_msg_info(200, Title,"서비스")
			dw_cond.SetFocus()
			dw_cond.SetColumn("svccod")
			Return
		End If
		
		dw_cond.object.priceplan[1] = ls_priceplan
	Else
		
		If ls_priceplan = "" Then
			f_msg_info(200, Title,"가격정책")
			dw_cond.SetFocus()
			dw_cond.SetColumn("priceplan")
			Return
		End If
		
		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM PRICEPLANMST
		 WHERE PRICEPLAN = :ls_priceplan;
	
		dw_cond.object.svccod[1]    = ls_svccod
		
	End If
End If

If ls_nodeno = "" Then
	f_msg_info(200, Title,"발신지")
	dw_cond.SetFocus()
	dw_cond.SetColumn("nodeno")
	Return
End If

ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.SVCCOD = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.priceplan = '" + ls_priceplan + "' "
End If

If ls_countrycod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "B.COUNTRYCOD = '" + ls_countrycod + "' "
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.ZONCOD = '" + ls_zoncod + "' "
End If

If ls_areacod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "A.AREACOD like '" + ls_areacod + "%' "
End If

//retrieve
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(ls_nodeno)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

p_reload.TriggerEvent("ue_enable")	
end event

event type integer ue_extra_save();//Save Check
String ls_areacod, ls_zoncod, ls_zoncod_cost
Long i, ll_row

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0

For i = 1 To ll_row
	ls_areacod = Trim(dw_detail.object.arezoncod2_areacod[i])
	If IsNull(ls_areacod) Then ls_areacod = ""
	If ls_areacod = "" Then
		f_msg_usr_err(200, Title, "지역코드")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("arezoncod2_areacod")
		Return -1
	End If
	
	ls_zoncod = Trim(dw_detail.object.arezoncod2_zoncod[i])
	If IsNull(ls_zoncod) Then ls_zoncod = ""
	If ls_zoncod = "" Then
		f_msg_usr_err(200, Title, "대 역")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("arezoncod2_zoncod")
		Return -1
	End If
	
	ls_zoncod_cost = Trim(dw_detail.object.arezoncod2_zoncod_cost[i])
	If IsNull(ls_zoncod_cost) Then ls_zoncod_cost = ""
	If ls_zoncod_cost = "" Then
		f_msg_usr_err(200, Title, "원가대역")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("arezoncod2_zoncod_cost")
		Return -1
	End If
	
	//Update Log
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.arezoncod2_updt_user[i] = gs_user_id
		dw_detail.object.arezoncod2_updtdt[i]    = fdt_get_dbserver_now()
   End If
Next

Return 0
	
	
end event

event resize;call super::resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_reload.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_saveas.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_fileread.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	p_reload.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_saveas.Y	=  newheight - iu_cust_w_resize.ii_button_space
	p_fileread.Y	=  newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.SetFocus()

p_reload.TriggerEvent("ue_disable")
p_saveas.TriggerEvent("ue_disable")
p_fileread.TriggerEvent("ue_disable")


//If is_type = 'N' Then
//	dw_cond.SetItem(1, 'svccod'   , 'ALL')
//	dw_cond.SetItem(1, 'priceplan', 'ALL')
//	
//ElseIf is_type = 'Y' Then
//	dw_cond.SetItem(1, 'svccod'   , '')
//	dw_cond.SetItem(1, 'priceplan', 'ALL')
//	dw_cond.Object.parttype[1] = "S"
//	
//	dw_cond.Object.priceplan.Visible   = 0
//	dw_cond.Object.priceplan_t.Visible = 0
//	
//	dw_cond.Object.svccod.Visible   = 1
//	dw_cond.Object.svccod_t.Visible = 1
//	
//End If
//
return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

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
cb_load.Enabled = False

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_arezoncod2_v20
integer y = 80
integer width = 3246
integer height = 248
string dataobject = "b0dw_cnd_reg_arezoncod2_svc_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_filter, ls_svccod, ls_priceplan
Int li_rc

DataWindowChild ldwc_nodeno

Choose Case dwo.Name
	Case "parttype"
		If data = "S" Then
			This.Object.priceplan.Visible = 0
			This.Object.priceplan_t.Visible = 0
			This.Object.svccod.Visible = 1
			This.Object.svccod_t.Visible = 1	
			dw_cond.SetItem(1, 'priceplan', 'ALL')
			dw_cond.SetItem(1, 'svccod'   , ''   )
		
		Else
			This.Object.priceplan.Visible = 1
			This.Object.priceplan_t.Visible = 1
			This.Object.svccod.Visible = 0
			This.Object.svccod_t.Visible = 0	
			dw_cond.SetItem(1, 'svccod'   , 'ALL')
			dw_cond.SetItem(1, 'priceplan', ''   )
		End If
		
	Case "svccod"
		// dddw change
//		dw_cond.Modify("nodeno.dddw.name = 'b0dc_dddw_nodeno_v20'")
//		dw_cond.Modify("nodeno.dddw.datacolumn = 'nodeno'")
//		dw_cond.Modify("nodeno.dddw.displayColumn = 'codenm'")
//		dw_cond.Modify("nodeno.dddw.UseAsBorder = 'Yes'")
//		dw_cond.Modify("nodeno.dddw.VScrollBar	= 'Yes'")		
		
		dw_cond.object.nodeno[1] = ''
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + data + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
	Case "priceplan"
		
		SELECT SVCCOD
	  	  INTO :ls_svccod
	     FROM PRICEPLANMST
	    WHERE PRICEPLAN = :data;
		
		dw_cond.object.nodeno[1] = ''
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
		
	Case "nodeno"
		If is_type = 'Y' Then  //
			If dw_cond.object.parttype[1] = "S" Then			
				
				ls_svccod = fs_snvl(dw_cond.Object.svccod[1], '')
				
				If ls_svccod = '' Then
					f_msg_info(9000, parent.title,  "서비스를 먼저 선택하여 주십시오.")
					This.Object.nodeno[1] = ""
					Return 2
				End If
				
			Else
				ls_priceplan = fs_snvl(dw_cond.Object.priceplan[1], '')
				
				If ls_priceplan = '' Then
					f_msg_info(9000, parent.title,  "가격정책을 먼저 선택하여 주십시오.")
					This.Object.nodeno[1] = ""
					Return 2
				End If
				
			End If
			
		End If
		
End Choose

end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_arezoncod2_v20
integer x = 3360
integer y = 72
end type

type p_close from w_a_reg_m`p_close within b0w_reg_arezoncod2_v20
integer x = 3666
integer y = 72
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_arezoncod2_v20
integer width = 3291
integer height = 364
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_arezoncod2_v20
integer x = 329
integer y = 1632
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_arezoncod2_v20
integer y = 1632
end type

type p_save from w_a_reg_m`p_save within b0w_reg_arezoncod2_v20
integer x = 626
integer y = 1632
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_arezoncod2_v20
integer y = 380
integer width = 3936
integer height = 1216
string dataobject = "b0dw_reg_areazoncod2_v20"
end type

event dw_detail::retrieveend;call super::retrieveend;//처음 입력했을시 버튼 활성화
p_saveas.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_enable")
If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
   dw_cond.Enabled = False
	cb_load.Enabled = True

Else							//자료가 있으면 표준대역을 불러올 수 없다.
//	cb_load.Enabled = False    '2003.10.15 수정.
	cb_load.Enabled = True
	
End If


end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::itemchanged;call super::itemchanged;//지역 코드 선택시 해당 정보 Display
Integer li_rc
b0u_dbmgr lu_dbmgr
lu_dbmgr = Create b0u_dbmgr

If dwo.name = "arezoncod2_areacod" Then
		
		lu_dbmgr.is_caller = "b0w_reg_standard_zone%display"
		lu_dbmgr.is_title = Title
		lu_dbmgr.is_data[1] = data
		lu_dbmgr.uf_prc_db()
		li_rc = lu_dbmgr.ii_rc
		If li_rc < 0 Then 
			Destroy lu_dbmgr
			Return li_rc
		End If
		
		dw_detail.object.areamst_areanm[row]     = lu_dbmgr.is_data[2]	//지역명
		dw_detail.object.areamst_areagroup[row]  = lu_dbmgr.is_data[3]	//지역상위그룹
		dw_detail.object.areamst_countrycod[row] = lu_dbmgr.is_data[4]	//국가
End If
	
Destroy lu_dbmgr
Return 0


end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_arezoncod2_v20
integer x = 1221
integer y = 1632
end type

type cb_load from commandbutton within b0w_reg_arezoncod2_v20
integer x = 3365
integer y = 196
integer width = 585
integer height = 112
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "대역Copy"
end type

event clicked;//해당 고객의 
String ls_nodeno, ls_svccod, ls_priceplan, ls_parttype
Long ll_row

If is_type = 'Y' Then
	ls_parttype = Trim(dw_cond.Object.parttype[1])		//발신지
Else
	ls_parttype = 'N'
End If

ls_svccod    = Trim(dw_cond.Object.svccod[1])		//서비스
ls_priceplan = Trim(dw_cond.Object.priceplan[1])		//서비스
ls_nodeno    = Trim(dw_cond.Object.nodeno[1])		//발신지

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "대역 Copy"
iu_cust_msg.is_grp_name = "통화서비스 요율 관리"
iu_cust_msg.is_data[1] = ls_nodeno
iu_cust_msg.is_data[2] = ls_svccod
iu_cust_msg.is_data[3] = is_type
iu_cust_msg.is_data[4] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.is_data[5] = ls_priceplan
iu_cust_msg.is_data[6] = ls_parttype
iu_cust_msg.idw_data[1] = dw_detail

//Open
//표준대역 윈도우 연다.
OpenWithParm(b0w_inq_areazoncod_popup2_v20, iu_cust_msg)  

Return 0 
end event

type p_reload from u_p_reload within b0w_reg_arezoncod2_v20
integer x = 923
integer y = 1632
boolean bringtotop = true
end type

type p_saveas from u_p_saveas within b0w_reg_arezoncod2_v20
integer x = 1687
integer y = 1632
boolean bringtotop = true
end type

type p_fileread from u_p_fileread within b0w_reg_arezoncod2_v20
integer x = 2002
integer y = 1632
boolean bringtotop = true
end type

