$PBExportHeader$u_p_pprev.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_pprev from u_p_base
end type
end forward

global type u_p_pprev from u_p_base
integer width = 192
boolean originalsize = true
string picturename = "pprev_e.gif"
end type
global u_p_pprev u_p_pprev

event clicked;call super::clicked;Parent.TriggerEvent('ue_pprev')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "pprev_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "pprev_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "pprev_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "pprev_e.gif"
end event

on u_p_pprev.create
end on

on u_p_pprev.destroy
end on

