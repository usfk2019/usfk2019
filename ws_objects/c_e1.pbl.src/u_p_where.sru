$PBExportHeader$u_p_where.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_where from u_p_base
end type
end forward

global type u_p_where from u_p_base
boolean originalsize = true
string picturename = "where_e.gif"
end type
global u_p_where u_p_where

event clicked;call super::clicked;Parent.TriggerEvent("ue_where")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "where_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "where_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "where_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "where_e.gif"
end event

on u_p_where.create
end on

on u_p_where.destroy
end on

