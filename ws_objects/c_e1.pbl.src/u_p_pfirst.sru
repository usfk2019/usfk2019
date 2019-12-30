$PBExportHeader$u_p_pfirst.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_pfirst from u_p_base
end type
end forward

global type u_p_pfirst from u_p_base
integer width = 192
boolean originalsize = true
string picturename = "pfirst_e.gif"
end type
global u_p_pfirst u_p_pfirst

event clicked;call super::clicked;Parent.TriggerEvent('ue_pfirst')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "pfirst_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "pfirst_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "pfirst_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "pfirst_e.gif"
end event

on u_p_pfirst.create
end on

on u_p_pfirst.destroy
end on

