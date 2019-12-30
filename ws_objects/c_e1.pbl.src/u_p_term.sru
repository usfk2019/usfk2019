$PBExportHeader$u_p_term.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_term from u_p_base
end type
end forward

global type u_p_term from u_p_base
boolean originalsize = true
string picturename = "term_e.gif"
end type
global u_p_term u_p_term

event ue_buttondown;call super::ue_buttondown;This.PictureName = "term_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "term_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "term_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "term_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_term')
end event

on u_p_term.create
end on

on u_p_term.destroy
end on

