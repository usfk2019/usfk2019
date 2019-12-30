$PBExportHeader$w_a_print_preview.srw
$PBExportComments$Print Preview Ancestor(from w_a_print_a ) - Response Window
forward
global type w_a_print_preview from w_a_print_preview_a
end type
end forward

global type w_a_print_preview from w_a_print_preview_a
WindowState WindowState=maximized!
end type
global w_a_print_preview w_a_print_preview

on w_a_print_preview.create
call w_a_print_preview_a::create
end on

on w_a_print_preview.destroy
call w_a_print_preview_a::destroy
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////////////////
////   Argument for preview
//////////////////////////////////////////////////////////////////////////////////////
//iu_cust_msg.is_data[1]  is dataobject( string )
//iu_cust_msg.idw_data[1] is datawindow( datawindow var )
//iu_cust_msg.is_data[2]  is print title ( string )




iu_cust_msg1 = Message.PowerObjectParm

dw_list.DataObject = iu_cust_msg1.is_data[1] 
dw_list.SetTransObject( Sqlca )
dw_list.Object.Data = iu_cust_msg1.idw_data[1].Object.Data
is_pgm_name = iu_cust_msg1.is_data[2] 

If UpperBound( iu_cust_msg1.is_temp[]  ) > 0 then
	is_condition = iu_cust_msg1.is_temp[1] 
End IF	

If UpperBound( iu_cust_msg1.ii_data[]  ) > 0 then
	ii_orientation = iu_cust_msg1.ii_data[1] 
End IF	


is_pgm_id1 =  iu_cust_msg1.is_pgm_id


dw_list.AcceptText()

Trigger Event ue_init()
Post Event ue_set_header()
Post Event ue_preview_set()



end event

