$PBExportHeader$w_a_m_master.srw
$PBExportComments$Multi master ( from w_a_condition)
forward
global type w_a_m_master from w_a_condition
end type
type dw_master from u_d_sgl_sel within w_a_m_master
end type
end forward

global type w_a_m_master from w_a_condition
integer width = 3035
dw_master dw_master
end type
global w_a_m_master w_a_m_master

on w_a_m_master.create
int iCurrent
call super::create
this.dw_master=create dw_master
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
end on

on w_a_m_master.destroy
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

type dw_cond from w_a_condition`dw_cond within w_a_m_master
integer width = 2203
integer taborder = 10
end type

type p_ok from w_a_condition`p_ok within w_a_m_master
integer x = 2382
integer y = 52
end type

type p_close from w_a_condition`p_close within w_a_m_master
integer x = 2683
integer y = 52
end type

type gb_cond from w_a_condition`gb_cond within w_a_m_master
integer width = 2249
end type

type dw_master from u_d_sgl_sel within w_a_m_master
event ue_key pbm_dwnkey
integer x = 32
integer y = 320
integer width = 2907
integer taborder = 20
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event ue_key;If keyflags = 0 Then
	If key = KeyEscape! Then
		Parent.TriggerEvent(is_close)
	ElseIf key = KeyF1!   Then
		fs_show_help(gs_pgm_id[gi_open_win_no])
	End If
End If

end event

