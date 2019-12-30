$PBExportHeader$u_p_create_intr.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_create_intr from u_p_base
end type
end forward

global type u_p_create_intr from u_p_base
boolean originalsize = true
string picturename = "intr_e.gif"
end type
global u_p_create_intr u_p_create_intr

event clicked;call super::clicked;Parent.TriggerEvent("ue_create_intr")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "intr_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "intr_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "intr_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "intr_e.gif"
end event

on u_p_create_intr.create
end on

on u_p_create_intr.destroy
end on

