$PBExportHeader$b0w_reg_sacmst.srw
$PBExportComments$[ceusee] 접속번호 타입등록
forward
global type b0w_reg_sacmst from w_a_reg_m
end type
type p_reload from u_p_reload within b0w_reg_sacmst
end type
end forward

global type b0w_reg_sacmst from w_a_reg_m
integer width = 2281
integer height = 1920
event ue_reload ( )
p_reload p_reload
end type
global b0w_reg_sacmst b0w_reg_sacmst

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

on b0w_reg_sacmst.create
int iCurrent
call super::create
this.p_reload=create p_reload
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reload
end on

on b0w_reg_sacmst.destroy
call super::destroy
destroy(this.p_reload)
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_sac

ls_sac	= Trim( dw_cond.Object.sac[1] )

IF( IsNull(ls_sac) ) THEN ls_sac = ""

//Dynamic SQL
IF ls_sac <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "UPPER(sac) LIKE UPPER('%" + ls_sac + "%')"
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

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_sac,ls_svctype

ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	//필수항목체크
	ls_sac	= Trim(dw_detail.Object.sacnum[ll_rowcnt])
	IF IsNull(ls_sac) THEN ls_sac = ""
	

	
	ls_svctype	= Trim(dw_detail.Object.svctype[ll_rowcnt])
	IF IsNull(ls_svctype) THEN ls_svctype = ""
	
	
	IF ls_sac = "" THEN
		f_msg_usr_err(200, Title, "SAC")
		dw_detail.setColumn("sacnum")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	

	//서비스유형 체크
	IF ls_svctype = "" THEN
		f_msg_usr_err(200, Title, "서비스유형")
		dw_detail.setColumn("svctype")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	
	
	//업데이트 처리
	IF dw_detail.GetItemStatus(ll_rowcnt,0,Primary!) = DataModified! THEN
		dw_detail.Object.updt_user[ll_rowcnt]	= gs_user_id
		dw_detail.Object.updtdt[ll_rowcnt]		= fdt_get_dbserver_now()
	END IF

NEXT 

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

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_sacmst
integer x = 37
integer y = 64
integer width = 1184
integer height = 120
string dataobject = "b0dw_cnd_sacmat"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_sacmst
integer x = 1358
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b0w_reg_sacmst
integer x = 1664
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_sacmst
integer x = 23
integer width = 1234
integer height = 196
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_sacmst
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_sacmst
integer x = 23
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b0w_reg_sacmst
integer x = 626
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_sacmst
integer x = 23
integer y = 228
integer width = 2194
integer height = 1396
string dataobject = "b0dw_reg_sacmst"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_sacmst
integer x = 1230
integer y = 1664
end type

type p_reload from u_p_reload within b0w_reg_sacmst
integer x = 928
integer y = 1664
boolean bringtotop = true
end type

