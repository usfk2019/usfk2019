$PBExportHeader$u_d_sim_sql.sru
$PBExportComments$dw Single-Select & Indicator for SQL ( from u_d_sort )
forward
global type u_d_sim_sql from u_d_sort
end type
end forward

global type u_d_sim_sql from u_d_sort
end type
global u_d_sim_sql u_d_sim_sql

type variables
boolean ib_indicator = False
boolean ib_highlight = False

end variables

event constructor;call super::constructor;If ib_indicator Then
	This.SetRowFocusIndicator(Hand!)
Else
	This.SetRowFocusIndicator(Off!)
End If
end event

event clicked;call super::clicked;If row = 0 Then Return

If ib_highlight Then
	If IsSelected(row) Then
		SelectRow(row, False)
	Else
		SelectRow(0, False)
		SelectRow(row, True)
	End If
End If
end event

event retrieveend;If rowcount > 0 Then
	If ib_highlight Then SelectRow(1, True)
End If

end event

