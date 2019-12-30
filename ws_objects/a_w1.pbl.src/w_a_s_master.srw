$PBExportHeader$w_a_s_master.srw
$PBExportComments$single master ( from w_a_condition)
forward
global type w_a_s_master from w_a_condition
end type
type dw_master from u_d_base within w_a_s_master
end type
end forward

global type w_a_s_master from w_a_condition
dw_master dw_master
end type
global w_a_s_master w_a_s_master

on w_a_s_master.create
int iCurrent
call super::create
this.dw_master=create dw_master
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
end on

on w_a_s_master.destroy
call super::destroy
destroy(this.dw_master)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

//If newheight < dw_master.Y Then
//	dw_master.Height = 0
//Else
//	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_dw_button_space
//End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_condition`dw_cond within w_a_s_master
integer x = 55
integer y = 56
integer taborder = 20
end type

type p_ok from w_a_condition`p_ok within w_a_s_master
integer x = 2446
integer y = 52
string pointer = "Help!"
end type

type p_close from w_a_condition`p_close within w_a_s_master
integer x = 2752
integer y = 52
end type

type gb_cond from w_a_condition`gb_cond within w_a_s_master
end type

type dw_master from u_d_base within w_a_s_master
integer x = 32
integer y = 324
integer taborder = 10
boolean bringtotop = true
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

