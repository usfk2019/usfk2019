$PBExportHeader$b5w_reg_sendemail.srw
$PBExportComments$[jsha] email청구서발송
forward
global type b5w_reg_sendemail from w_a_reg_m_m
end type
type p_send from u_p_send within b5w_reg_sendemail
end type
type gb_master from groupbox within b5w_reg_sendemail
end type
end forward

global type b5w_reg_sendemail from w_a_reg_m_m
integer width = 2944
integer height = 1952
event type integer ue_send ( )
event type integer ue_extra_send ( )
p_send p_send
gb_master gb_master
end type
global b5w_reg_sendemail b5w_reg_sendemail

forward prototypes
public subroutine of_resizepanels ()
end prototypes

event type integer ue_send();Constant Int LI_ERROR = -1
integer li_return
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

li_return = This.Trigger Event ue_extra_send()  

If li_return < 0 Then     				//실패
	Return LI_ERROR
ElseIf li_return = 0 Then
	f_msg_info(3000,This.Title,"Send")  //성공

End if 

TriggerEvent('ue_reset')

Return 0


end event

event type integer ue_extra_send();String ls_file_name, ls_sender, ls_send_date
String ls_trdt, ls_closedt, ls_bilcycle
Date ld_send_date, ld_trdt, ld_closedt
String ls_temp, ls_ref_desc, ls_result[]
Integer li_return, li_rc
b5u_dbmgr3 lu_dbmgr

If dw_detail.RowCount() = 0 Then Return 0
dw_master.AcceptText()

ld_trdt = dw_cond.Object.trdt[1]
ls_trdt = Trim(String(ld_trdt, 'yyyymmdd'))
ls_bilcycle = Trim(dw_cond.Object.bilcycle[1])
ld_closedt = dw_cond.Object.closedt[1]
ls_closedt = Trim(String(ld_closedt,'yyyymmdd'))
ls_file_name = Trim(dw_master.Object.file_name[1])
ls_sender = Trim(dw_master.Object.sender[1])
ld_send_date = dw_master.Object.send_date[1]
ls_send_date = Trim(String(ld_send_date,'yyyymmdd'))

If IsNull(ls_file_name) Then ls_file_name = ""
If IsNull(ls_sender) Then ls_sender = ""
If IsNull(ls_send_date) Then ls_send_date = ""

// mandatory item check
If ls_file_name = "" Then
	f_msg_usr_err(200, This.Title, "HTML FIle Name")
	dw_master.SetFocus()
	dw_master.SetColumn("file_name")
	Return -1
End If
If ls_sender = "" Then
	f_msg_usr_err(200, This.Title, "Sender")
	dw_master.SetFocus()
	dw_master.SetColumn("sender")
	Return -1
End IF
If ls_send_date = "" Then
	f_msg_usr_err(200, This.Title, "send_date")
	dw_master.SetFocus()
	dw_master.SetColumn("send_date")
	Return -1
End If

ls_temp = fs_get_control("B5", "P300", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result)

// DB
lu_dbmgr = Create b5u_dbmgr3
lu_dbmgr.is_caller = "b5w_reg_sendemail%send"
lu_dbmgr.is_title = This.Title
lu_dbmgr.is_data[1] = ls_bilcycle
lu_dbmgr.is_data[2] = ls_file_name
lu_dbmgr.is_data[3] = ls_sender
lu_dbmgr.is_data[4] = ls_result[1] 		// 미전송
lu_dbmgr.id_data[1] = ld_trdt
lu_dbmgr.id_data[2] = ld_closedt
lu_dbmgr.id_data[3] = ld_send_date
lu_dbmgr.idw_data[1] = dw_detail

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then        //실패
	Destroy lu_dbmgr
	Return -1
ElseIf li_rc = 0 Then 
   Destroy lu_dbmgr		//성공 
	Return 0
End If

Destroy lu_dbmgr

Return 0 


end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls. 
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width + 500, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

// Top processing
idrg_Top.Move(dw_cond.x, ii_WindowTop)
idrg_Top.Resize(dw_cond.width, st_horizontal.Y - idrg_Top.Y - 20)


end subroutine

on b5w_reg_sendemail.create
int iCurrent
call super::create
this.p_send=create p_send
this.gb_master=create gb_master
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_send
this.Control[iCurrent+2]=this.gb_master
end on

on b5w_reg_sendemail.destroy
call super::destroy
destroy(this.p_send)
destroy(this.gb_master)
end on

event open;call super::open;// dw_master 
String ls_filename, ls_ref_desc
ls_ref_desc = ""
ls_filename = fs_get_control("B5", "E100", ls_ref_desc)
dw_master.InsertRow(0)
dw_master.Object.file_name[1] = ls_filename
dw_master.object.send_date[1] = fdt_get_dbserver_now()
p_send.TriggerEvent("ue_disable")

end event

event ue_ok();call super::ue_ok;String ls_trdt, ls_bilcycle, ls_pay_method, ls_closedt, ls_customernm, ls_payid
Date ld_trdt, ld_closedt
String ls_where, ls_temp, ls_ref_desc
Long ll_row

ld_trdt = dw_cond.Object.trdt[1]
ls_trdt = Trim(String(ld_trdt,'yyyymmdd'))
ls_bilcycle = Trim(dw_cond.Object.bilcycle[1])
ls_pay_method = Trim(dw_cond.Object.pay_method[1])
ld_closedt = dw_cond.Object.closedt[1]
ls_closedt = Trim(String(ld_closedt,'yyyymmdd'))
ls_customernm = Trim(dw_cond.Object.customernm[1])
ls_payid = Trim(dw_cond.Object.payid[1])

If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_bilcycle) Then ls_bilcycle = ""
If IsNull(ls_pay_method) Then ls_pay_method = ""
If IsNull(ls_closedt) Then ls_closedt = ""
If IsNull(ls_customernm) Then ls_customernm = ""
If IsNull(ls_payid) Then ls_payid = ""

// 필수 Check
/*
If ls_trdt = "" Then
	f_msg_usr_err(200, This.Title, "Billing Cycle Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
End If
*/
If ls_bilcycle = "" Then
	f_msg_usr_err(200, This.Title, "Billing Cycle date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("bilcycle")
	Return
End If

// Query
ls_where = ""

If ls_trdt <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " to_char(req.trdt,'yyyymmdd') = '" + ls_trdt + "' "
End If
If ls_bilcycle <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " req.chargedt = '" + ls_bilcycle + "' "
End If
If ls_pay_method <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " req.pay_method = '" + ls_pay_method + "' "
End If
If ls_closedt <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " to_char(req.inputclosedtcur,'yyyymmdd') = '" + ls_closedt + "' "
End If
If ls_customernm <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " cus.customernm = '" + ls_customernm + "' "
End If
If ls_payid <> "" Then
	If ls_where <> "" then ls_where += " AND "
	ls_where += " req.payid = '" + ls_payid + "' "
End If

dw_detail.is_where = ls_where

ls_temp = fs_get_control('B0', 'P132', ls_ref_desc) //e-mail 발송

ll_row = dw_detail.Retrieve(ls_temp)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
Else
	p_send.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
End If

end event

event resize;////2000-06-28 by kEnn
////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
////
//
//CALL w_a_m_master::resize
//
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	dw_detail.Height = 0
//  
//	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	p_send.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//Else
//	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
// 
//
//	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
//	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
//	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//	p_send.Y		= newheight - iu_cust_w_resize.ii_button_space_1
//End If
//
//// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()
//
//SetRedraw(True)
//

//2000-06-28 by kEnn
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
	p_send.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_send.Y		= newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc
String ls_filename, ls_ref_desc
//ii_error_chk = -1

dw_detail.AcceptText()
/*
If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If
*/

//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_send.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
ls_ref_desc = ""
ls_filename = fs_get_control("B5", "E100", ls_ref_desc)
dw_master.InsertRow(0)
dw_master.Object.file_name[1] = ls_filename
dw_master.object.send_date[1] = fdt_get_dbserver_now()

dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_detail.Reset()

//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b5w_reg_sendemail
integer x = 55
integer width = 2290
integer height = 308
string dataobject = "b5dw_cnd_reg_sendemail"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Date ld_trdt, ld_closedt, ld_date
setnull(ld_date)

Choose Case dwo.name
	Case "bilcycle"
		SELECT reqdt, add_months(inputclosedt, 1)
		INTO :ld_trdt, :ld_closedt
		FROM reqconf
		WHERE chargedt = :data;
		
		IF SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "itemchanged-SELECT reqconf")
			dw_cond.Object.trdt[1] = ld_date	
			dw_cond.Object.closedt[1] = ld_date
			Return 2
		End If	
		
		dw_cond.Object.trdt[1] = ld_trdt
		dw_cond.Object.closedt[1] = ld_closedt
		
End Choose

Return 0
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "payid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.payid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0
end event

type p_ok from w_a_reg_m_m`p_ok within b5w_reg_sendemail
integer x = 2510
integer y = 64
end type

type p_close from w_a_reg_m_m`p_close within b5w_reg_sendemail
integer x = 2510
integer y = 180
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b5w_reg_sendemail
integer x = 27
integer width = 2354
integer height = 376
end type

type dw_master from w_a_reg_m_m`dw_master within b5w_reg_sendemail
integer x = 55
integer y = 408
integer width = 2290
integer height = 288
string dataobject = "b5dw_reg_sendemail_m"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_master::clicked;Return 0
end event

type dw_detail from w_a_reg_m_m`dw_detail within b5w_reg_sendemail
integer y = 724
integer width = 2638
string dataobject = "b5dw_reg_sendemail"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b5w_reg_sendemail
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b5w_reg_sendemail
boolean visible = false
end type

type p_save from w_a_reg_m_m`p_save within b5w_reg_sendemail
boolean visible = false
end type

type p_reset from w_a_reg_m_m`p_reset within b5w_reg_sendemail
integer x = 416
integer y = 1680
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b5w_reg_sendemail
integer y = 720
end type

type p_send from u_p_send within b5w_reg_sendemail
integer x = 78
integer y = 1680
boolean bringtotop = true
boolean originalsize = false
end type

type gb_master from groupbox within b5w_reg_sendemail
integer x = 27
integer y = 352
integer width = 2354
integer height = 364
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

