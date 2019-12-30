$PBExportHeader$u_p_pnext.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_pnext from u_p_base
end type
end forward

global type u_p_pnext from u_p_base
integer width = 192
boolean originalsize = true
string picturename = "pnext_e.gif"
end type
global u_p_pnext u_p_pnext

event clicked;call super::clicked;Parent.TriggerEvent('ue_pnext')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "pnext_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "pnext_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "pnext_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "pnext_e.gif"
end event

on u_p_pnext.create
end on

on u_p_pnext.destroy
end on

