$PBExportHeader$u_d_mul_sel_ext.sru
$PBExportComments$dw Multi-Select Extent ( from u_d_sort)
forward
global type u_d_mul_sel_ext from u_d_sort
end type
end forward

global type u_d_mul_sel_ext from u_d_sort
int Width=1153
end type
global u_d_mul_sel_ext u_d_mul_sel_ext

type variables
long il_selected_row
boolean ib_action
end variables

forward prototypes
public function integer ufi_select_range (long al_row)
end prototypes

public function integer ufi_select_range (long al_row);long ll_i

//file manager functionality ... turn off all rows then select new range
SetRedraw(FALSE)
SelectRow(0, FALSE)

IF il_selected_row = 0 THEN
	SetRedraw(TRUE)
	RETURN 1
END IF

IF il_selected_row > al_row THEN
	FOR ll_i = il_selected_row TO al_row STEP -1
		SelectRow(ll_i, TRUE)
	END FOR
ELSE
	FOR ll_i = il_selected_row TO al_row
		SelectRow( ll_i, TRUE)
	NEXT
END IF

SetRedraw(TRUE)
RETURN 1

end function

event clicked;call super::clicked;If row = 0 then Return


//case of select multiple rows range using the shift key
IF Keydown(KeyShift!) THEN
	ufi_select_range(row)
ELSEIF this.IsSelected(row) THEN
	il_selected_row = row
	ib_action = TRUE
ELSEIF Keydown(KeyControl!) THEN
	il_selected_row = row
	this.SelectRow(row, TRUE)
ELSE
	il_selected_row = row
	If IsSelected( row ) then
		SelectRow( row ,FALSE)
	Else
		SelectRow(0, FALSE )
		SelectRow( row , TRUE )
	End If

END IF  //selected row
end event

