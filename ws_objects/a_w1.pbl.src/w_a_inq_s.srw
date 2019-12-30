$PBExportHeader$w_a_inq_s.srw
$PBExportComments$single master Inquiry ( from w_a_condition)
forward
global type w_a_inq_s from w_a_condition
end type
type dw_detail from u_d_base within w_a_inq_s
end type
end forward

global type w_a_inq_s from w_a_condition
integer height = 1840
dw_detail dw_detail
end type
global w_a_inq_s w_a_inq_s

on w_a_inq_s.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
end on

on w_a_inq_s.destroy
call super::destroy
destroy(this.dw_detail)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < dw_detail.Y Then
	dw_detail.Height = 0
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_condition`dw_cond within w_a_inq_s
integer taborder = 10
end type

type p_ok from w_a_condition`p_ok within w_a_inq_s
end type

type p_close from w_a_condition`p_close within w_a_inq_s
end type

type gb_cond from w_a_condition`gb_cond within w_a_inq_s
end type

type dw_detail from u_d_base within w_a_inq_s
integer x = 27
integer y = 320
integer width = 3013
integer height = 1384
integer taborder = 0
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

