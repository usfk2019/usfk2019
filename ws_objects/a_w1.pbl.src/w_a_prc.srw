$PBExportHeader$w_a_prc.srw
$PBExportComments$Processing Ancestor(from w_a_base)
forward
global type w_a_prc from w_base
end type
type p_ok from u_p_ok within w_a_prc
end type
type dw_input from u_d_external within w_a_prc
end type
type dw_msg_time from u_d_external within w_a_prc
end type
type dw_msg_processing from u_d_external within w_a_prc
end type
type ln_up from line within w_a_prc
end type
type ln_down from line within w_a_prc
end type
type p_close from u_p_close within w_a_prc
end type
type gb_cond from groupbox within w_a_prc
end type
end forward

global type w_a_prc from w_base
integer x = 914
integer y = 540
integer width = 1961
integer height = 1336
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event type integer ue_input ( )
event type integer ue_process ( )
event ue_chg_mode ( string as_mode )
event type integer ue_pre_complete ( )
event ue_ok ( )
event ue_close ( )
p_ok p_ok
dw_input dw_input
dw_msg_time dw_msg_time
dw_msg_processing dw_msg_processing
ln_up ln_up
ln_down ln_down
p_close p_close
gb_cond gb_cond
end type
global w_a_prc w_a_prc

type variables
//NVO For Processing
u_cust_a_db iu_cust_db_prc

//NVO For Common Processing
u_cust_db_app iu_cust_db_app

//Messeage for messagebox
String is_msg_text
String is_msg_process

//Messeage No. for messagebox
Long il_msg_no

end variables

event ue_chg_mode;as_mode = Upper(as_mode)
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
		w_msg_wait.Title = "Process Name - " + iu_cust_msg.is_pgm_name
		
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

event ue_pre_complete;DateTime ldt_start_time, ldt_end_time

dw_msg_time.Object.end_time[1] = fdt_get_dbserver_now()

ldt_start_time = dw_msg_time.Object.start_time[1]
ldt_end_time = dw_msg_time.Object.end_time[1]

dw_msg_time.Object.eclipsed_time[1] = &
 RelativeTime(Time("00:00:00"), SecondsAfter(Time(ldt_start_time), Time(ldt_end_time)) + &
  DaysAfter(Date(ldt_start_time), Date(ldt_end_time)) * 24 * 3600  )

dw_msg_processing.Object.prg_msg[1] = is_msg_process

Return 0

end event

event ue_ok;Integer li_rc

//***** 초기화 작업 *****
SetPointer(HourGlass!)

//***** 입력 부분 *****
If dw_input.AcceptText() < 0 Then
	dw_input.SetFocus()
	Return
End If

If This.Trigger Event ue_input() < 0 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//실행의 확인 작업
li_rc = f_msg_ques_yesno2(il_msg_no, Title, is_msg_text, 1)

If li_rc <> 1 Then
//	//Input Mode로
//	Trigger Event ue_chg_mode("INPUT")
	Return
End If

//***** Process부분 *****
//Process Mode로
Trigger Event ue_chg_mode("PROCESS")

//Process call
li_rc = Trigger Event ue_process()

If Trigger Event ue_pre_complete() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()

	//Input Mode로
	Trigger Event ue_chg_mode("INPUT")
	f_msg_info(3010, Title, iu_cust_msg.is_pgm_name)
Else
	//Completed Mode로
	Trigger Event ue_chg_mode("COMPLETED")
End If

If li_rc < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()
	f_msg_info(3010, Title, iu_cust_msg.is_pgm_name)
Else
	//COMMIT;와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()

	f_msg_info(3000, Title, iu_cust_msg.is_pgm_name)
End If

end event

event ue_close;call super::ue_close;Close(This)
end event

on w_a_prc.create
int iCurrent
call super::create
this.p_ok=create p_ok
this.dw_input=create dw_input
this.dw_msg_time=create dw_msg_time
this.dw_msg_processing=create dw_msg_processing
this.ln_up=create ln_up
this.ln_down=create ln_down
this.p_close=create p_close
this.gb_cond=create gb_cond
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_ok
this.Control[iCurrent+2]=this.dw_input
this.Control[iCurrent+3]=this.dw_msg_time
this.Control[iCurrent+4]=this.dw_msg_processing
this.Control[iCurrent+5]=this.ln_up
this.Control[iCurrent+6]=this.ln_down
this.Control[iCurrent+7]=this.p_close
this.Control[iCurrent+8]=this.gb_cond
end on

on w_a_prc.destroy
call super::destroy
destroy(this.p_ok)
destroy(this.dw_input)
destroy(this.dw_msg_time)
destroy(this.dw_msg_processing)
destroy(this.ln_up)
destroy(this.ln_down)
destroy(this.p_close)
destroy(this.gb_cond)
end on

event open;call super::open;Trigger Event ue_chg_mode("INPUT")

iu_cust_db_app = Create u_cust_db_app

ln_up.LineColor = This.BackColor
ln_down.LineColor = This.BackColor

dw_msg_processing.Object.prg_name[1] = "'" + iu_cust_msg.is_pgm_name + "'"

is_msg_text = iu_cust_msg.is_pgm_name
il_msg_no = 200

end event

event close;call super::close;Destroy iu_cust_db_app
Destroy iu_cust_db_prc
end event

type p_ok from u_p_ok within w_a_prc
integer x = 1609
integer y = 116
integer taborder = 20
end type

type dw_input from u_d_external within w_a_prc
event ue_keydown pbm_dwnkey
integer x = 55
integer y = 40
integer width = 1472
integer height = 344
integer taborder = 10
boolean border = false
borderstyle borderstyle = stylebox!
end type

event ue_keydown;If keyflags = 0 Then
	Choose Case key
		Case KeyEnter!
			Parent.TriggerEvent(is_default)
		Case KeyEscape!
			Parent.TriggerEvent(is_close)
		Case KeyF1!    //Help을 뛰우기 위해
		 fs_show_help(gs_pgm_id[gi_open_win_no])
	End Choose
End If

end event

type dw_msg_time from u_d_external within w_a_prc
integer x = 32
integer y = 900
integer width = 1897
integer height = 272
integer taborder = 0
string dataobject = "d_eclipsed_time"
borderstyle borderstyle = stylebox!
end type

type dw_msg_processing from u_d_external within w_a_prc
integer x = 32
integer y = 436
integer width = 1897
integer height = 448
integer taborder = 0
string dataobject = "d_msg_processing"
borderstyle borderstyle = stylebox!
end type

type ln_up from line within w_a_prc
long linecolor = 65535
integer linethickness = 12
integer beginx = 32
integer beginy = 416
integer endx = 1783
integer endy = 416
end type

type ln_down from line within w_a_prc
long linecolor = 65535
integer linethickness = 12
integer beginx = 32
integer beginy = 1188
integer endx = 1783
integer endy = 1188
end type

type p_close from u_p_close within w_a_prc
integer x = 1609
integer y = 224
integer taborder = 30
boolean originalsize = false
end type

type gb_cond from groupbox within w_a_prc
integer x = 32
integer width = 1513
integer height = 400
integer taborder = 40
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

