$PBExportHeader$b0w_reg_sacmst_v20.srw
$PBExportComments$[ohj] 서비스별 접속번호 등록 v20
forward
global type b0w_reg_sacmst_v20 from w_a_reg_m
end type
type p_reload from u_p_reload within b0w_reg_sacmst_v20
end type
end forward

global type b0w_reg_sacmst_v20 from w_a_reg_m
integer width = 2853
integer height = 1920
event ue_reload ( )
p_reload p_reload
end type
global b0w_reg_sacmst_v20 b0w_reg_sacmst_v20

type variables
DataWindowChild idc_itemcod
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

on b0w_reg_sacmst_v20.create
int iCurrent
call super::create
this.p_reload=create p_reload
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reload
end on

on b0w_reg_sacmst_v20.destroy
call super::destroy
destroy(this.p_reload)
end on

event ue_ok();call super::ue_ok;String	ls_where, ls_sac, ls_svccod
Long		ll_rows


ls_svccod = fs_snvl(dw_cond.Object.svccod[1], '')
ls_sac	 = fs_snvl(dw_cond.Object.sac[1]   , '')

//Dynamic SQL
ls_where = ""
IF ls_svccod <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " svccod = '" + ls_svccod + "'"
END IF

IF ls_sac <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(sacnum) LIKE UPPER('%" + ls_sac + "%')"
END IF

dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, This.Title, "")
END IF

p_reload.TriggerEvent("ue_enable")
end event

event type integer ue_reset();call super::ue_reset;
p_insert.TriggerEvent("ue_enable")
p_reload.TriggerEvent("ue_disable")	

RETURN 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insertion Log
dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

dw_detail.SetFocus()
dw_detail.SetColumn("sacnum")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name : b0w_reg_sacmst
	Desc. : 접속번호 Master
	Date : 2003.06.12
	Auth : C.Bora
------------------------------------------------------------------------*/

p_reload.TriggerEvent("ue_disable")
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt, ll_rows1, ll_rows2
String	ls_sac, ls_svccod, ls_origintype, ls_sac1, ls_sac2, ls_svctype

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sac	     = fs_snvl(dw_detail.Object.sacnum[ll_rowcnt]    , '')
   ls_svctype    = fs_snvl(dw_detail.Object.svctype[ll_rowcnt]   , '')
	ls_svccod     = fs_snvl(dw_detail.Object.svccod[ll_rowcnt]    , '')
	ls_origintype = fs_snvl(dw_detail.Object.origintype[ll_rowcnt], '')
		
	IF ls_sac = "" THEN
		f_msg_usr_err(200, Title, "SAC")
		dw_detail.setColumn("sacnum")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	IF ls_svctype = "" THEN
		f_msg_usr_err(200, Title, "서비스유형")
		dw_detail.setColumn("svctype")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	//서비스 체크
	IF ls_svccod = "" THEN
		f_msg_usr_err(200, Title, "서비스")
		dw_detail.setColumn("svccod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	IF ls_origintype = "" THEN
		f_msg_usr_err(200, Title, "발신지유형")
		dw_detail.setColumn("origintype")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF		

NEXT 

//중복체크
For ll_rows1 = 1 To dw_detail.RowCount()

	ls_sac1 = fs_snvl(dw_detail.Object.sacnum[ll_rows1]    , '')
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		
		ls_sac2 = fs_snvl(dw_detail.Object.sacnum[ll_rows2]    , '')
	
		If ls_sac1 = ls_sac2 Then
			f_msg_info(9000, Title, "SAC [ " + ls_sac2 + " ]이(가) 중복됩니다.")
			dw_detail.SetColumn("sacnum")
			Return -2
		End If
		
	Next
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF

Next

//No Error
RETURN 0
end event

event resize;call super::resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_reload.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	p_reload.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_sacmst_v20
integer x = 37
integer y = 68
integer width = 1966
integer height = 108
string dataobject = "b0dw_cnd_sacmat_v20"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_sacmst_v20
integer x = 2158
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b0w_reg_sacmst_v20
integer x = 2464
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_sacmst_v20
integer x = 23
integer width = 2011
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_sacmst_v20
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_sacmst_v20
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b0w_reg_sacmst_v20
integer x = 626
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_sacmst_v20
integer x = 23
integer y = 228
integer width = 2761
integer height = 1396
string dataobject = "b0dw_reg_sacmst_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_svctype

//If dwo.name = 'svccod' Then
//	SELECT SVCTYPE
//	  INTO :ls_svctype
//	  FROM SVCMST
//	 WHERE SVCCOD = :data  ;
//	 
//	 dw_detail.SetITem(row, 'svctype', ls_svctype)
//	 
//End If

//Long ll_row
//String ls_filter,ls_itemcod
//If dwo.name = 'svctype' Then
//	ll_row = dw_detail.GetChild("svccod", idc_itemcod)
//	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//	ls_filter = "svctype IN ('ALL', '" + data + "') "
//	idc_itemcod.SetFilter(ls_filter)			//Filter정함
//	idc_itemcod.Filter()
//	idc_itemcod.SetTransObject(SQLCA)
//	ll_row =idc_itemcod.Retrieve() 
//
//	If ll_row < 0 Then 				//디비 오류 
//		f_msg_usr_err(2100, Title, "Retrieve()")
//		Return -1
//	ElseIf ll_row > 0 Then			//첫row의 값을 Setting한다.
//		ls_itemcod = idc_itemcod.GetItemString(1, "svccod")
//		dw_detail.object.svccod[row] = ls_itemcod
//	End if
//End If	  
end event

event dw_detail::clicked;call super::clicked;Long ll_row
String ls_filter
dw_detail.AcceptText()
If dwo.name = 'svccod' Then
	If fs_snvl(dw_detail.Object.svctype[row], '') = '' Then 
		f_msg_usr_err(200, Title, "서비스유형")
		dw_detail.setColumn("svctype")
		dw_detail.setRow(row)
		dw_detail.scrollToRow(row)
		dw_detail.setFocus()
		Return 1
	End If
//	ll_row = dw_detail.GetChild("svccod", idc_itemcod)
//	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//	ls_filter = "svctype IN ('ALL', '" + dw_detail.object.svctype[row] + "') "
//	idc_itemcod.SetFilter(ls_filter)			//Filter정함
//	idc_itemcod.Filter()
//	idc_itemcod.SetTransObject(SQLCA)
//	ll_row =idc_itemcod.Retrieve()
End If
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_sacmst_v20
integer x = 1230
integer y = 1664
end type

type p_reload from u_p_reload within b0w_reg_sacmst_v20
integer x = 928
integer y = 1664
boolean bringtotop = true
end type

