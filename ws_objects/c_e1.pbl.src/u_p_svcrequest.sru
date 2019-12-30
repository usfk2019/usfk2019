$PBExportHeader$u_p_svcrequest.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_svcrequest from u_p_base
end type
end forward

global type u_p_svcrequest from u_p_base
integer width = 590
integer height = 100
string picturename = "svcRequest_e.gif"
end type
global u_p_svcrequest u_p_svcrequest

event clicked;call super::clicked;Parent.TriggerEvent("ue_request")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "svcRequest_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "svcRequest_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "svcRequest_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "svcRequest_e.gif"
end event

on u_p_svcrequest.create
end on

on u_p_svcrequest.destroy
end on

