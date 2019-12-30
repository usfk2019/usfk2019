$PBExportHeader$u_p_insert.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_insert from u_p_base
end type
end forward

global type u_p_insert from u_p_base
boolean originalsize = true
string picturename = "insert_e.gif"
end type
global u_p_insert u_p_insert

event clicked;call super::clicked;  If fb_enable_button("INSERT", gi_group_auth) Then
	Parent.TriggerEvent('ue_insert')
  Else
	Return 0 
 End If 
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "insert_e.gif"

end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "insert_x.gif"

end event

event ue_disable();call super::ue_disable;This.PictureName = "insert_d.gif"

end event

event ue_enable();call super::ue_enable;If fb_enable_button("INSERT", gi_group_auth) Then
   This.PictureName = "insert_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "insert_d.gif"
	This.Enabled = FALSE
End If

end event

on u_p_insert.create
end on

on u_p_insert.destroy
end on

