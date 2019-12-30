$PBExportHeader$u_p_ok.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_ok from u_p_base
end type
end forward

global type u_p_ok from u_p_base
boolean originalsize = true
string picturename = "ok_e.gif"
end type
global u_p_ok u_p_ok

event clicked;call super::clicked;Parent.TriggerEvent("ue_ok")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "ok_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "ok_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "ok_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "ok_e.gif"
end event

on u_p_ok.create
end on

on u_p_ok.destroy
end on

