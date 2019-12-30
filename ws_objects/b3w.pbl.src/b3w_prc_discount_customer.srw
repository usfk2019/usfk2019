$PBExportHeader$b3w_prc_discount_customer.srw
$PBExportComments$할인대상자생성 By 변유신 2003.1.06
forward
global type b3w_prc_discount_customer from w_a_prc
end type
end forward

global type b3w_prc_discount_customer from w_a_prc
integer height = 1304
end type
global b3w_prc_discount_customer b3w_prc_discount_customer

on b3w_prc_discount_customer.create
call super::create
end on

on b3w_prc_discount_customer.destroy
call super::destroy
end on

event ue_chg_mode(string as_mode);as_mode = Upper(as_mode)
Choose Case as_mode
	Case "INPUT"
		If IsValid(w_msg_wait) Then Close(w_msg_wait)
		
		p_ok.TriggerEvent("ue_enable")
		p_close.TriggerEvent("ue_enable")
		
//		dw_msg_processing.Visible = False
//		dw_msg_time.Visible = False
		
		//Change size
		This.Resize(This.Width, ln_up.BeginY + (This.Height - This.WorkSpaceHeight()))

	Case "PROCESS"
//		//Change size(다시 실행시..)
//		This.Resize(This.Width, ln_up.BeginY + (This.Height - This.WorkSpaceHeight()))

		If Not IsValid(w_msg_wait) Then Open(w_msg_wait)
		//w_msg_wait.Title = "Process Name - " + iu_cust_msg.is_pgm_name
		
		p_ok.TriggerEvent("ue_disable")
		p_close.TriggerEvent("ue_disable")

//		dw_msg_time.Object.std_time[1] = dw_msg_time.Object.current_time[1]
		dw_msg_time.Object.start_time[1] = fdt_get_dbserver_now()

	Case "COMPLETED"
		If IsValid(w_msg_wait) Then Close(w_msg_wait)
		p_ok.TriggerEvent("ue_enable")
		p_close.TriggerEvent("ue_enable")

//		dw_msg_processing.Visible = True
//		dw_msg_time.SetRedraw(True)
//		dw_msg_time.Object.DataWindow.Timer_Interval = '0'

//		dw_msg_time.Visible = True
	
		//Change size
		This.Resize(This.Width, ln_down.BeginY + (This.Height - This.WorkSpaceHeight()))
	Case Else
		MessageBox("ue_chg_mode", "No Matching case statement - " + as_mode)
End Choose

end event

event open;call super::open;MessageBox("titleOpen",iu_cust_msg.is_pgm_name)
end event

type p_ok from w_a_prc`p_ok within b3w_prc_discount_customer
integer x = 1417
integer y = 64
end type

type dw_input from w_a_prc`dw_input within b3w_prc_discount_customer
integer y = 80
integer width = 1285
integer height = 168
string dataobject = "b3dw_cnd_prc_discount_customer"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b3w_prc_discount_customer
integer x = 14
integer y = 888
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b3w_prc_discount_customer
integer x = 14
integer y = 372
end type

type ln_up from w_a_prc`ln_up within b3w_prc_discount_customer
integer beginx = 0
integer beginy = 356
integer endx = 1751
integer endy = 356
end type

type ln_down from w_a_prc`ln_down within b3w_prc_discount_customer
end type

type p_close from w_a_prc`p_close within b3w_prc_discount_customer
integer x = 1417
integer y = 172
end type

type gb_cond from w_a_prc`gb_cond within b3w_prc_discount_customer
integer y = 28
integer width = 1330
integer height = 252
end type

