$PBExportHeader$u_p_check.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_check from u_p_base
end type
end forward

global type u_p_check from u_p_base
boolean originalsize = true
string picturename = "check_e.gif"
end type
global u_p_check u_p_check

event clicked;call super::clicked;Parent.TriggerEvent("ue_check")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "check_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "check_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "check_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "check_e.gif"
end event

on u_p_check.create
end on

on u_p_check.destroy
end on

