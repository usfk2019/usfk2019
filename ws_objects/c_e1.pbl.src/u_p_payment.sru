$PBExportHeader$u_p_payment.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_payment from u_p_base
end type
end forward

global type u_p_payment from u_p_base
boolean originalsize = true
string picturename = "payment_e.gif"
end type
global u_p_payment u_p_payment

event clicked;Parent.TriggerEvent('ue_payment')
end event

event ue_buttonup;This.PictureName = "payment_e.gif"
end event

event ue_buttondown;This.PictureName = "payment_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "payment_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "payment_e.gif"
end event

on u_p_payment.create
end on

on u_p_payment.destroy
end on

