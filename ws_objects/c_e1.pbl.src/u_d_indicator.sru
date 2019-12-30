$PBExportHeader$u_d_indicator.sru
$PBExportComments$dw Indicator ( from u_d_dberr )
forward
global type u_d_indicator from u_d_dberr
end type
end forward

global type u_d_indicator from u_d_dberr
event ue_key pbm_dwnkey
end type
global u_d_indicator u_d_indicator

type variables
Boolean ib_downarrow


// 버튼 visible 값을 조정한다.
Boolean ib_insert
Boolean ib_delete

end variables

event ue_key;// If you want Insert using down key, set 'ib_downarrow = True' at constructor event
IF ib_downarrow  And keyflags = 0 THEN
	If key = KeyDownArrow! THEN
		If GetRow() = RowCount() Then
			parent.triggerevent( "ue_insert" )
		End If
	END IF
END IF

If key = KeyF1! Then
	//Help을 뛰우기 위해
	fs_show_help(gs_pgm_id[gi_open_win_no])
End If

end event

event constructor;call super::constructor;SetRowFocusIndicator(Hand!)
end event

on u_d_indicator.create
end on

on u_d_indicator.destroy
end on

