$PBExportHeader$p1w_reg_call_cancel.srw
$PBExportComments$[ceusee] 이중호 해지
forward
global type p1w_reg_call_cancel from w_a_reg_m
end type
type p_cancel from u_p_cancel within p1w_reg_call_cancel
end type
end forward

global type p1w_reg_call_cancel from w_a_reg_m
integer width = 3099
event ue_cancel ( )
p_cancel p_cancel
end type
global p1w_reg_call_cancel p1w_reg_call_cancel

event ue_cancel();Boolean	lb_return, lb_eflag
Long		ll_rows, ll_i, ll_row_cnt
Long		ll_return, ll_socket, ll_length
String	ls_ipaddress, ls_port
String	ls_pid, ls_yn, ls_header, ls_body, ls_buffer
String	ls_module, ls_ref_no, ls_ref_desc

u_api lu_api
lu_api =  Create u_api

ls_module = "00"
ls_ref_no = "S60" + gc_server_no + "1"
ls_ipaddress = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

ls_module = "00"
ls_ref_no = "S602"
ls_port = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
ll_socket = lu_api.PBTcpConnectA(ls_ipaddress, ls_port)

lb_eflag = False
If ll_socket > 0 Then
	ls_header = "8   "
	
	ll_row_cnt = dw_detail.RowCount()

	For ll_rows = 1 To ll_row_cnt
		// 선택된 row 값들의 pid 로 이중호 해제
		If dw_detail.IsSelected(ll_rows) Then 
	
			ls_pid = Trim(dw_detail.Object.pid[ll_rows])
		
			ls_body = fs_fill_spaces(ls_pid, 20)
			ls_buffer = ls_header + ls_body
			ll_length = LenA(ls_buffer)
			ll_return = lu_api.PBTcpWriteA(ll_socket, ls_buffer, ll_length)
		
			If ll_return <> ll_length Then
				lb_eflag = True
				Exit
			End If
		End If
	
    dw_detail.SetitemStatus(ll_rows, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
   Next
	
	

	lb_return = lu_api.PBTcpCloseA(ll_socket)
	If lb_eflag Then
		f_msg_usr_err(3010, Title, "")
	Else
		f_msg_info(3000, Title, "")
	End If
Else
	f_msg_usr_err(3010, Title, "")
	Destroy lu_api
	Return
End If



Destroy lu_api


end event

on p1w_reg_call_cancel.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
end on

on p1w_reg_call_cancel.destroy
call super::destroy
destroy(this.p_cancel)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : p1w_reg_call_cancle
	Desc : 이중호 해지
	Date : 2003.06.19
	Auth. : C.BORA
--------------------------------------------------------------------------*/
dw_detail.SetRowFocusIndicator(Off!)
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where = ""

String	ls_pid, ls_salid
String	ls_crtdt_from, ls_crtdt_to
String	ls_contno, ls_contno_to

//**** Accept User Input Condition     ****
ls_pid = Trim(dw_cond.Object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contno= Trim(dw_cond.Object.contno[1])
If IsNull(ls_contno) Then ls_contno = ""

//**** Check User Input Condition      ****
If ls_pid = "" and ls_contno = "" Then	
	f_msg_info(100, Title, "Pin # Or Serial #")
	dw_cond.SetColumn("pid")
	dw_cond.SetFocus()
	Return
End If

ls_where = ""

If ls_contno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.contno like '" + ls_contno + "%' "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "p_cardmst.pid like '" + ls_pid + "%' "
End If

dw_detail.is_where = ls_where

//**** Data Retrieve                   ****
ll_rows = dw_detail.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, This.Title, "")
	Return
End If


end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_cancel.Y = newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within p1w_reg_call_cancel
integer y = 76
integer width = 1714
integer height = 136
string dataobject = "p1dw_cnd_call_cancle"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within p1w_reg_call_cancel
integer x = 1902
integer y = 44
end type

type p_close from w_a_reg_m`p_close within p1w_reg_call_cancel
integer x = 2208
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within p1w_reg_call_cancel
integer width = 1783
integer height = 248
end type

type p_delete from w_a_reg_m`p_delete within p1w_reg_call_cancel
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within p1w_reg_call_cancel
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within p1w_reg_call_cancel
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within p1w_reg_call_cancel
integer y = 284
integer height = 1280
string dataobject = "p1dw_reg_call_cancel"
end type

event dw_detail::clicked;call super::clicked;If row = 0 Then Return

If dwo.name <> "chk" Then
	If KeyDown(keycontrol!) Then
				If IsSelected(row) Then
					SelectRow(row, False)
					This.object.chk[row] = 'N'
				Else
					SelectRow(row, True)
					This.object.chk[row] = 'Y'
				End If	
	
	Else	
			If IsSelected(row) Then
				SelectRow(row, False)
				This.object.chk[row] = 'N'
			Else
				SelectRow(row, True)
				This.object.chk[row] = 'Y'
			End If
	End If
End if

end event

event dw_detail::itemchanged;call super::itemchanged;//Check 선택 했을시.
If dwo.name = "chk" Then
	If data = "Y" then
		SelectRow(row, TRUE)
	Else 
		SelectRow(row, False)
	End If
End If
end event

event dw_detail::buttonclicked;call super::buttonclicked;Long i
If dwo.name ="b_all" Then
	If dw_detail.Rowcount() = 0 Then Return 0
	For i = 1 To dw_detail.RowCount()
		dw_detail.object.chk[i] = 'Y'
		SelectRow(i, True)
	Next
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within p1w_reg_call_cancel
end type

type p_cancel from u_p_cancel within p1w_reg_call_cancel
integer x = 55
integer y = 1600
integer height = 92
boolean bringtotop = true
end type

