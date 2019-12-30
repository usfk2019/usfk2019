$PBExportHeader$u_p_confirm.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_confirm from u_p_base
end type
end forward

global type u_p_confirm from u_p_base
boolean originalsize = true
string picturename = "confirm_e.gif"
end type
global u_p_confirm u_p_confirm

event ue_buttondown;call super::ue_buttondown;This.PictureName = "confirm_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "confirm_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "confirm_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "confirm_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_confirm')
end event

on u_p_confirm.create
end on

on u_p_confirm.destroy
end on

