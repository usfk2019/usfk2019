$PBExportHeader$b0w_reg_origin_vc_v20.srw
$PBExportComments$[ohj] Origin 등록 v20
forward
global type b0w_reg_origin_vc_v20 from w_a_reg_m_m
end type
type p_reload from u_p_reload within b0w_reg_origin_vc_v20
end type
type cb_copy from commandbutton within b0w_reg_origin_vc_v20
end type
end forward

global type b0w_reg_origin_vc_v20 from w_a_reg_m_m
integer width = 2679
integer height = 2008
event ue_reload ( )
p_reload p_reload
cb_copy cb_copy
end type
global b0w_reg_origin_vc_v20 b0w_reg_origin_vc_v20

type variables
String is_sacnum, is_origintype
end variables

forward prototypes
public function integer wfi_get_originnum (string as_nodeno, ref string as_originnum)
end prototypes

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

public function integer wfi_get_originnum (string as_nodeno, ref string as_originnum);

Select originnum
 Into :as_originnum
 From nodenum
Where nodeno = :as_nodeno;

//error
If SQLCA.SQLCODE < 0 Then
	f_msg_sql_err(title, " Select Error(NODENUM)")
	Return -1

ElseIf SQLCA.SQLCODE = 100 Then
	
//	f_msg_sql_err(title, " Select Error(NODENUM)")
	Return 1
	
End If

Return 0
end function

on b0w_reg_origin_vc_v20.create
int iCurrent
call super::create
this.p_reload=create p_reload
this.cb_copy=create cb_copy
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reload
this.Control[iCurrent+2]=this.cb_copy
end on

on b0w_reg_origin_vc_v20.destroy
call super::destroy
destroy(this.p_reload)
destroy(this.cb_copy)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_origin_vc
	Desc.	: 	Origin 등록
	Ver.	:	1.0
	Date	: 	2003.12.16
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/

p_reload.TriggerEvent("ue_disable")	

cb_copy.enabled = False
end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_svctype, ls_where, ls_sacnum
Long ll_row

ls_sacnum = Trim(dw_cond.object.sacnum[1])
If IsNull(ls_sacnum) Then ls_sacnum = ""

ls_svctype = Trim(dw_cond.object.svccod[1])
If IsNull(ls_svctype) Then ls_svctype = ""

ls_where = ""
If ls_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " sacnum = '" + ls_sacnum + "' "
End IF

If ls_svctype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " svccod = '" + ls_svctype + "' "
End IF

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "SACMSt")
	This.Trigger Event ue_reset()		//찾기가 없으면 resert
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

p_reload.TriggerEvent("ue_enable")
cb_copy.enabled = True
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_temp, ls_ref_desc, ls_result[], ls_type1, ls_type3
Int li_rc
DataWindowChild ldc_stelprefix

ls_temp = fs_get_control("00", "Z410", ls_ref_desc)
li_rc = fi_cut_string(ls_temp, ";", ls_result[])
ls_type1 = ls_result[1]
ls_type3 = ls_result[3]

If is_origintype = ls_type1 Then		// 발신지유형 : 접속번호
	dw_detail.Object.stelprefix.Protect = 1
	dw_detail.Object.stelprefix.Color = RGB(0, 0, 0)
	dw_detail.Object.stelprefix.Background.Color = RGB(255, 251, 240)
	dw_detail.Object.stelprefix[al_insert_row] = 'None'
	
	dw_detail.Object.stelprefix.Edit.case = "Any"
	dw_detail.Object.stelprefix.Edit.limit = 30
	dw_detail.Object.stelprefix.Edit.AutoHScroll	= "Yes"
	dw_detail.Object.stelprefix.Edit.AutoSelect = "Yes"
	dw_detail.Object.stelprefix.Edit.FocusRectangle = "Yes"
	
ElseIf is_origintype = ls_type3 Then 	//	발신지유형 : 인증Key Location
	dw_detail.Object.stelprefix.Protect = 0
	dw_detail.Object.stelprefix.Color = RGB(255, 255, 255)
	dw_detail.Object.stelprefix.Background.Color = RGB(108, 147, 137)
	
	dw_detail.Object.stelprefix.dddw.Name = "b1dc_dddw_validkey_location"
	dw_detail.Object.stelprefix.dddw.DisplayColumn = "codenm"
	dw_detail.Object.stelprefix.dddw.DataColumn = "code"
	dw_detail.Modify("stelprefix.dddw.VScrollBar = 'Yes'")
	dw_detail.Modify("stelprefix.dddw.Line = 7")
	dw_detail.Modify("stelprefix.dddw.PercentWidth = 140")
	dw_detail.GetChild("stelprefix", ldc_stelprefix)
	ldc_stelprefix.SetTransObject(SQLCA)
	ldc_stelprefix.Retrieve()
	
	// Insert 시 해당 row 첫번째 컬럼에 포커스
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("stelprefix")
	
Else	//	발신지유형 : Prefix
	dw_detail.Object.stelprefix.Protect = 0
	dw_detail.Object.stelprefix.Color = RGB(255, 255, 255)
	dw_detail.Object.stelprefix.Background.Color = RGB(108, 147, 137)
	
	dw_detail.Object.stelprefix.Edit.case = "Any"
	dw_detail.Object.stelprefix.dddw.limit = 30
	dw_detail.Object.stelprefix.Edit.AutoHScroll	= "Yes"
	dw_detail.Object.stelprefix.Edit.AutoSelect = "Yes"
	dw_detail.Object.stelprefix.Edit.FocusRectangle = "Yes"

	//Insert 시 해당 row 첫번째 컬럼에 포커스
	dw_detail.SetRow(al_insert_row)
	dw_detail.ScrollToRow(al_insert_row)
	dw_detail.SetColumn("stelprefix")
End If

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.sacnum[al_insert_row] = is_sacnum

Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_stelprefix,  ls_nodeno, ls_originnum
Long ll_rows, i

ll_rows = dw_detail.RowCount()

If ll_rows = 0 Then Return 0

//Loop
For i=1 To ll_rows
	ls_stelprefix = Trim(dw_detail.object.stelprefix[i])
	ls_nodeno = Trim(dw_detail.object.nodeno[i])
	ls_originnum = Trim(dw_detail.object.originnum[i])
	If IsNull(ls_stelprefix) Then ls_stelprefix = ""
	If IsNull(ls_nodeno) Then ls_nodeno = ""
    If IsNull(ls_originnum) Then ls_originnum = ""
	
	If ls_stelprefix = "" Then
		f_msg_usr_err(200, Title,"발신지Prefix")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("stelprefix")
		Return -1
	End If
	
	If ls_nodeno = "" Then
		f_msg_usr_err(200, Title,"발신지")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("nodeno")
		Return -1
	End If
	
	If ls_originnum = "" Then
		f_msg_usr_err(200, Title,"발신지")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("nodeno")
		Return -1
	End If
	
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
    	dw_detail.object.pgm_id[i] = gs_pgm_id[gi_open_win_no]
   End If
	
Next

Return 0
end event

event resize;call super::resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정

SetRedraw(False)

p_reload.Y	= p_insert.Y

SetRedraw(True)
end event

event type integer ue_reset();call super::ue_reset;dw_cond.SetColumn("sacnum")
p_reload.TriggerEvent("ue_disable")	
cb_copy.enabled = False

return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b0w_reg_origin_vc_v20
integer x = 41
integer y = 88
integer width = 1838
integer height = 96
string dataobject = "b0dw_cnd_reg_origin_vc_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b0w_reg_origin_vc_v20
integer x = 2025
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b0w_reg_origin_vc_v20
integer x = 2331
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b0w_reg_origin_vc_v20
integer x = 27
integer y = 12
integer width = 1888
integer height = 216
end type

type dw_master from w_a_reg_m_m`dw_master within b0w_reg_origin_vc_v20
integer x = 23
integer y = 268
integer width = 2583
integer height = 500
string dataobject = "b0dw_inq_origin_vc_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.sacnum_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b0w_reg_origin_vc_v20
integer x = 23
integer y = 800
integer width = 2583
integer height = 900
string dataobject = "b0dw_reg_origin_vc_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master click시 Retrieve
String ls_where
String ls_temp, ls_ref_desc, ls_result[], ls_type1, ls_type3
Long ll_row
Int li_rc
DataWindowChild ldc_stelprefix

ls_temp = fs_get_control("00", "Z410", ls_ref_desc)
li_rc = fi_cut_string(ls_temp, ";", ls_result[])
ls_type1 = ls_result[1]
ls_type3 = ls_result[3]

is_sacnum = Trim(dw_master.object.sacnum[al_select_row])
is_origintype = Trim(dw_master.object.origintype[al_select_row])
If IsNull(is_sacnum) Then is_sacnum = ""
If IsNull(is_origintype) Then is_origintype = ""

ls_where = ""

If is_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " sacnum = '" + is_sacnum + "' "
End If

//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
dw_detail.SetRedraw(False)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

dw_detail.SetRedraw(True)

If is_origintype = ls_type1 Then		// 발신지유형 : 접속번호
	dw_detail.Object.stelprefix.Protect = 1
	dw_detail.Object.stelprefix.Color = RGB(0, 0, 0)
	dw_detail.Object.stelprefix.Background.Color = RGB(255, 251, 240)
	
	dw_detail.Object.stelprefix_t.Text = "발신지Prefix"
		
	dw_detail.Object.stelprefix.Edit.case = "Any"
	dw_detail.Object.stelprefix.Edit.limit = 30
	dw_detail.Object.stelprefix.Edit.AutoHScroll	= "Yes"
	dw_detail.Object.stelprefix.Edit.AutoSelect = "Yes"
	dw_detail.Object.stelprefix.Edit.FocusRectangle = "Yes"
	
ElseIf is_origintype = ls_type3 Then 	//	발신지유형 : 인증Key Location
	dw_detail.Object.stelprefix.Protect = 0
	dw_detail.Object.stelprefix.Color = RGB(255, 255, 255)
	dw_detail.Object.stelprefix.Background.Color = RGB(108, 147, 137)
	
	dw_detail.Object.stelprefix_t.Text = "Location"
	
	dw_detail.Object.stelprefix.dddw.Name = "b1dc_dddw_validkey_location"
	dw_detail.Object.stelprefix.dddw.DisplayColumn = "codenm"
	dw_detail.Object.stelprefix.dddw.DataColumn = "code"
	dw_detail.Modify("stelprefix.dddw.VScrollBar = 'Yes'")
	dw_detail.Modify("stelprefix.dddw.Line = 7")
	dw_detail.Modify("stelprefix.dddw.PercentWidth = 140")
	dw_detail.GetChild("stelprefix", ldc_stelprefix)
	ldc_stelprefix.SetTransObject(SQLCA)
	ldc_stelprefix.Retrieve()
	
	dw_detail.SetColumn("nodeno")
	dw_Detail.SetFocus()
	
Else	//	발신지유형 : Prefix
	dw_detail.Object.stelprefix.Protect = 0
	dw_detail.Object.stelprefix.Color = RGB(255, 255, 255)
	dw_detail.Object.stelprefix.Background.Color = RGB(108, 147, 137)
	
	dw_detail.Object.stelprefix_t.Text = "발신지Prefix"
	
	dw_detail.Object.stelprefix.Edit.case = "Any"
	dw_detail.Object.stelprefix.dddw.limit = 30
	dw_detail.Object.stelprefix.Edit.AutoHScroll	= "Yes"
	dw_detail.Object.stelprefix.Edit.AutoSelect = "Yes"
	dw_detail.Object.stelprefix.Edit.FocusRectangle = "Yes"

End If


Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_originnum
long ll_return

If dwo.name = "nodeno" Then
	
   	ll_return = wfi_get_originnum(data, ls_originnum)
	If ll_return = -1 Then
		 return 1
    ElseIf ll_return = 1 Then
		 return 1		
	End IF	
	
	Object.originnum[row] = ls_originnum
	
End If
end event

type p_insert from w_a_reg_m_m`p_insert within b0w_reg_origin_vc_v20
integer y = 1768
end type

type p_delete from w_a_reg_m_m`p_delete within b0w_reg_origin_vc_v20
integer y = 1768
end type

type p_save from w_a_reg_m_m`p_save within b0w_reg_origin_vc_v20
integer x = 617
integer y = 1768
end type

type p_reset from w_a_reg_m_m`p_reset within b0w_reg_origin_vc_v20
integer x = 1353
integer y = 1768
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b0w_reg_origin_vc_v20
integer x = 14
integer y = 768
end type

type p_reload from u_p_reload within b0w_reg_origin_vc_v20
integer x = 910
integer y = 1768
boolean bringtotop = true
boolean originalsize = false
end type

type cb_copy from commandbutton within b0w_reg_origin_vc_v20
integer x = 2030
integer y = 156
integer width = 581
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "발신지Prefix Copy"
end type

event clicked;//해당 고객의 
String ls_sacnum
Long ll_row, ll_master_row


ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row = 0 Then return 0

ls_sacnum = Trim(dw_master.object.sacnum[ll_master_row])  //접속번호

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "발신지등록"
iu_cust_msg.is_grp_name = "발신지별Prefix(Origin)"
iu_cust_msg.is_data[1] = ls_sacnum
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.idw_data[1] = dw_detail

//Open
OpenWithParm(b0w_inq_origin_vc_popup, iu_cust_msg)  //청구 윈도우 연다.

Return 0 
end event

