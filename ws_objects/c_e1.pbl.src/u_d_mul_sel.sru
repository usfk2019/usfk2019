$PBExportHeader$u_d_mul_sel.sru
$PBExportComments$dw Multi-Select ( from u_d_sort )
forward
global type u_d_mul_sel from u_d_sort
end type
end forward

global type u_d_mul_sel from u_d_sort
end type
global u_d_mul_sel u_d_mul_sel

event clicked;call super::clicked;/* if clicked outside of row return */
/* if clicked selected row that must be not selected */
/* if clicked not selected row that must be selected */

If row = 0 then Return

If IsSelected( row )  then
	SelectRow( row ,FALSE)
Else
	SelectRow( row , TRUE )
End If

end event

