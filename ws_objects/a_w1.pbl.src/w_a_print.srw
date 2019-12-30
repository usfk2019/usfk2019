$PBExportHeader$w_a_print.srw
$PBExportComments$Print Ancestor(from w_a_print_a )
forward
global type w_a_print from w_a_print_a
end type
type p_saveas from u_p_saveas within w_a_print
end type
end forward

global type w_a_print from w_a_print_a
integer height = 1984
event ue_saveas ( )
event ue_saveas_init ( )
p_saveas p_saveas
end type
global w_a_print w_a_print

type variables
boolean ib_saveas = False
datawindow idw_saveas
end variables

event ue_saveas;Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If idw_saveas.RowCount() <= 0 Then
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

li_return = idw_saveas.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

on w_a_print.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on w_a_print.destroy
call super::destroy
destroy(this.p_saveas)
end on

event open;call super::open;is_pgm_name = Trim( iu_cust_msg.is_pgm_name )

Trigger Event ue_saveas_init()
Trigger Event ue_init()
TriggerEvent( "ue_preview_set" )
TriggerEvent("ue_reset")

Post Event ue_set_header()

end event

event ue_init;call super::ue_init;If Not ib_saveas Then
	p_saveas.Visible = False
Else
	p_saveas.Visible = True
End If

end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_list.Y + iu_cust_w_resize.ii_button_space) Then
	p_saveas.Y	= dw_list.Y + iu_cust_w_resize.ii_dw_button_space
Else
	p_saveas.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event ue_set_header;call super::ue_set_header;//jybaek 2000/10/17 
dw_cond.SetFocus()
end event

event ue_reset();call super::ue_reset;//Save As 버튼을  권한 줌
p_saveas.TriggerEvent("ue_enable")
//프린트 버튼
p_3.TriggerEvent("ue_enable")  
end event

type dw_cond from w_a_print_a`dw_cond within w_a_print
integer width = 2245
end type

type p_ok from w_a_print_a`p_ok within w_a_print
integer x = 2464
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_print_a`p_close within w_a_print
integer x = 2766
integer y = 52
end type

type dw_list from w_a_print_a`dw_list within w_a_print
integer y = 340
integer height = 1280
end type

event dw_list::retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_saveas.TriggerEvent("ue_enable")
End If	

end event

type p_1 from w_a_print_a`p_1 within w_a_print
integer x = 2697
integer y = 1664
end type

type p_2 from w_a_print_a`p_2 within w_a_print
integer y = 1664
end type

type p_3 from w_a_print_a`p_3 within w_a_print
integer x = 2395
integer y = 1664
end type

type p_5 from w_a_print_a`p_5 within w_a_print
integer x = 1216
integer y = 1664
end type

type p_6 from w_a_print_a`p_6 within w_a_print
integer x = 1819
integer y = 1664
end type

type p_7 from w_a_print_a`p_7 within w_a_print
integer x = 1618
integer y = 1664
end type

type p_8 from w_a_print_a`p_8 within w_a_print
integer x = 1417
integer y = 1664
end type

type p_9 from w_a_print_a`p_9 within w_a_print
integer y = 1664
end type

type p_4 from w_a_print_a`p_4 within w_a_print
integer x = 1042
integer y = 1696
end type

type gb_1 from w_a_print_a`gb_1 within w_a_print
integer y = 1624
integer height = 216
end type

type p_port from w_a_print_a`p_port within w_a_print
integer x = 96
integer y = 1688
end type

type p_land from w_a_print_a`p_land within w_a_print
integer x = 256
integer y = 1700
end type

type gb_cond from w_a_print_a`gb_cond within w_a_print
integer width = 2327
end type

type p_saveas from u_p_saveas within w_a_print
integer x = 2103
integer y = 1664
boolean bringtotop = true
boolean originalsize = false
end type

