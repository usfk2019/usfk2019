$PBExportHeader$u_p_transfer.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_transfer from u_p_base
end type
end forward

global type u_p_transfer from u_p_base
boolean originalsize = true
string picturename = "transfer_e.gif"
end type
global u_p_transfer u_p_transfer

event ue_buttondown;call super::ue_buttondown;This.PictureName = "transfer_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "transfer_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "transfer_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "transfer_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_transfer')
end event

on u_p_transfer.create
end on

on u_p_transfer.destroy
end on

