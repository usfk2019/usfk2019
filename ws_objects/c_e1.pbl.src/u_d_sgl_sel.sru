$PBExportHeader$u_d_sgl_sel.sru
$PBExportComments$dw Single-Select ( from u_d_sort )
forward
global type u_d_sgl_sel from u_d_sort
end type
end forward

global type u_d_sgl_sel from u_d_sort
end type
global u_d_sgl_sel u_d_sgl_sel

event constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event clicked;call super::clicked;/* if clicked outside of row return */
/* if clicked selected row that must be not selected */
/* if clicked not selected row that must be selected */

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

event retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
End If

end event

