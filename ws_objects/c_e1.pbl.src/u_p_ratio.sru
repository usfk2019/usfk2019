$PBExportHeader$u_p_ratio.sru
$PBExportComments$Picture User Object (from u_p_base )
forward
global type u_p_ratio from u_p_base
end type
end forward

global type u_p_ratio from u_p_base
boolean originalsize = true
string picturename = "ratio_e.gif"
end type
global u_p_ratio u_p_ratio

event clicked;call super::clicked;Parent.TriggerEvent('ue_ratio')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "ratio_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "ratio_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "ratio_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "ratio_e.gif"
end event

on u_p_ratio.create
end on

on u_p_ratio.destroy
end on

