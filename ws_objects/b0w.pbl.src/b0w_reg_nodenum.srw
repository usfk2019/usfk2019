$PBExportHeader$b0w_reg_nodenum.srw
$PBExportComments$[parkkh] 발신지 정의 등록
forward
global type b0w_reg_nodenum from w_a_reg_m
end type
type p_reload from u_p_reload within b0w_reg_nodenum
end type
end forward

global type b0w_reg_nodenum from w_a_reg_m
integer width = 2286
event ue_reload ( )
p_reload p_reload
end type
global b0w_reg_nodenum b0w_reg_nodenum

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

on b0w_reg_nodenum.create
int iCurrent
call super::create
this.p_reload=create p_reload
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reload
end on

on b0w_reg_nodenum.destroy
call super::destroy
destroy(this.p_reload)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b0w_reg_code_nodenum
	Desc.	: 발신지 정의 
	Ver.	: 1.0
	Date	: 2002.09.26
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/

p_reload.TriggerEvent("ue_disable")	


end event

event ue_ok();call super::ue_ok;String ls_originno, ls_name, ls_where
Long ll_row

ls_originno = Trim(dw_cond.object.originnum[1])
ls_name = Trim(dw_cond.object.name[1])
If IsNull(ls_originno) Then ls_originno = ""
If IsNull(ls_name) Then ls_name = ""

ls_where = ""
If ls_originno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "nodenum.originnum like '" + ls_originno + "%' "
End If

If ls_name <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " Upper(syscod2t.codenm) like '%" + Upper(ls_name) + "%' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title , "Retrieve()")
End If

p_reload.TriggerEvent("ue_enable")

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("nodenum_originnum")

//Log 정보
dw_detail.object.nodenum_crt_user[al_insert_row] = gs_user_id
dw_detail.object.nodenum_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.nodenum_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.nodenum_updt_user[al_insert_row] = gs_user_id
dw_detail.object.nodenum_updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0 
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_nodeno, ls_originnum
Long ll_row, i

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

For i = 1 To ll_row
	ls_originnum = dw_detail.object.nodenum_originnum[i]
	If IsNull(ls_originnum) Then ls_originnum = ""
	If ls_originnum = "" Then
		f_msg_usr_err(200, Title, "Origin No.")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("nodenum_originnum")
		Return - 1
	End If
	
	ls_nodeno = dw_detail.object.nodenum_nodeno[i]
	If IsNull(ls_nodeno) Then ls_nodeno = ""
	If ls_nodeno = "" Then
		f_msg_usr_err(200, Title, "발신지")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.Setcolumn("nodenum_nodeno")
	    Return -1
	End If
	
	//log 정보
   If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.nodenum_updt_user[i] = gs_user_id
		dw_detail.object.nodenum_updtdt[i] = fdt_get_dbserver_now()
   End If
Next

Return 0 

end event

event type integer ue_reset();call super::ue_reset;//dw_cond.object.originnum[1] = ""
//dw_cond.object.name[1] = ""
dw_cond.SetColumn("originnum")

p_reload.TriggerEvent("ue_disable")	

Return 0
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

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_nodenum
integer x = 55
integer y = 44
integer width = 1344
integer height = 212
string dataobject = "b0dw_cnd_reg_nodenum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_nodenum
integer x = 1541
integer y = 60
end type

type p_close from w_a_reg_m`p_close within b0w_reg_nodenum
integer x = 1856
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_nodenum
integer width = 1408
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_nodenum
integer x = 329
integer y = 1616
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_nodenum
integer y = 1616
end type

type p_save from w_a_reg_m`p_save within b0w_reg_nodenum
integer x = 626
integer y = 1616
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_nodenum
integer x = 23
integer width = 2185
integer height = 1264
string dataobject = "b0dw_reg_nodenum"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_nodeno, ls_name

If dwo.name = "nodenum_nodeno" 	 Then // number 이면 
	ls_nodeno = Trim(dw_detail.object.nodenum_nodeno[row])
	Select codenm
	Into :ls_name
	From syscod2t
	Where (grcode = 'B200' and use_yn = 'Y')
	and ( code = :ls_nodeno);
	
	If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "SELECT Origination")
			RollBack;
			Return -1
	End If				
	
	dw_detail.object.syscod2t_codenm[row] = ls_name
End If

	
	
	
	
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_nodenum
integer x = 1221
integer y = 1616
end type

type p_reload from u_p_reload within b0w_reg_nodenum
integer x = 923
integer y = 1616
boolean bringtotop = true
end type

