$PBExportHeader$w_hlp_pgm_id.srw
$PBExportComments$[AJT] Program ID
forward
global type w_hlp_pgm_id from w_a_hlp
end type
end forward

global type w_hlp_pgm_id from w_a_hlp
integer width = 2971
string title = "COSTCENTER HELP"
end type
global w_hlp_pgm_id w_hlp_pgm_id

on w_hlp_pgm_id.create
call super::create
end on

on w_hlp_pgm_id.destroy
call super::destroy
end on

event ue_extra_ok;call super::ue_extra_ok;dw_source.Object.pgm_id[dw_source.GetRow()] = &
 dw_hlp.object.pgm_id[al_selrow]



end event

event ue_find;call super::ue_find;String ls_temp, ls_where

dw_cond.AcceptText()

ls_where = ""
ls_temp = Trim( dw_cond.Object.pgm_id[1] )
If IsNull(ls_temp) Then ls_temp = ""

If ls_temp <> "" Then
	ls_where = " pgm_id like '" + ls_temp + "%' "
End IF

ls_temp = Trim( dw_cond.Object.pgm_nm[1] )
If IsNull(ls_temp) Then ls_temp = ""

If ls_temp <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += " pgm_nm like '" + ls_temp + "%' "
End If

ls_temp = Trim( dw_cond.Object.p_pgm_id[1] )
If IsNull(ls_temp) Then ls_temp = ""

If ls_temp <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += " p_pgm_id like '" + ls_temp + "%' "
End If

//MessageBox("Test", ls_where)

dw_hlp.is_where = ls_where
dw_hlp.Retrieve()

end event

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;//iu_cust_help.is_data[5] = dw_hlp.Object.costct[al_selrow]
//
//iu_cust_help.ib_data[1] = TRUE

end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
//Close(This)
end event

event open;call super::open;This.Title = "Program ID"
end event

type p_1 from w_a_hlp`p_1 within w_hlp_pgm_id
integer x = 2039
integer y = 56
end type

type dw_cond from w_a_hlp`dw_cond within w_hlp_pgm_id
integer x = 37
integer width = 1906
integer height = 220
string dataobject = "d_hlp_cnd_pgm_id"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within w_hlp_pgm_id
integer x = 2336
integer y = 56
end type

type p_close from w_a_hlp`p_close within w_hlp_pgm_id
integer x = 2633
integer y = 56
end type

type gb_cond from w_a_hlp`gb_cond within w_hlp_pgm_id
integer x = 27
integer width = 1929
integer height = 288
end type

type dw_hlp from w_a_hlp`dw_hlp within w_hlp_pgm_id
integer x = 27
integer y = 300
integer width = 2875
integer height = 1476
string dataobject = "d_hlp_detail_pgm_id"
boolean hscrollbar = true
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort

ldwo_sort = This.Object.pgm_id_t

uf_init(ldwo_sort)

This.SetRowFocusIndicator(off!)
end event

