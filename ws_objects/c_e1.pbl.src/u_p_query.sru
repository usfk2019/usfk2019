$PBExportHeader$u_p_query.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_query from u_p_base
end type
end forward

global type u_p_query from u_p_base
boolean originalsize = true
string picturename = "query_e.gif.gif"
end type
global u_p_query u_p_query

event clicked;call super::clicked;Parent.TriggerEvent("ue_query")

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "query_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "query_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "query_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "query_e.gif"
end event

on u_p_query.create
end on

on u_p_query.destroy
end on

