$PBExportHeader$u_d_dragdrop.sru
$PBExportComments$dw dragdrop ( from u_d_mul_sel_ext )
forward
global type u_d_dragdrop from u_d_mul_sel_ext
end type
end forward

global type u_d_dragdrop from u_d_mul_sel_ext
int Width=1340
int Height=641
event ue_lbuttondown pbm_lbuttondown
event ue_lbuttonup pbm_lbuttonup
event ue_mousemove pbm_mousemove
event ue_drag_process ( )
end type
global u_d_dragdrop u_d_dragdrop

type variables
boolean ib_drag_act
public dragobject ido_draged
public string is_draged
end variables

event ue_lbuttondown;call super::ue_lbuttondown;ib_drag_act = True


end event

event ue_lbuttonup;call super::ue_lbuttonup;ib_drag_act = false


end event

event ue_mousemove;call super::ue_mousemove;if ib_drag_act then
	DragIcon = 'draggo.ico'
	Drag( begin! )
end if	

end event

event dragdrop;call super::dragdrop;ido_draged = DraggedObject()
is_draged = ido_draged.Classname()


trigger event ue_drag_process()

end event

