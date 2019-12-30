$PBExportHeader$u_p_psetup.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_psetup from u_p_base
end type
end forward

global type u_p_psetup from u_p_base
boolean originalsize = true
string picturename = "psetup_e.gif"
end type
global u_p_psetup u_p_psetup

event clicked;call super::clicked;Parent.TriggerEvent('ue_psetup')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "psetup_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "psetup_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "psetup_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "psetup_e.gif"
end event

on u_p_psetup.create
end on

on u_p_psetup.destroy
end on

