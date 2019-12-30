$PBExportHeader$b1w_prt_refilllog.srw
$PBExportComments$[jsha] 충전보고서(선불)
forward
global type b1w_prt_refilllog from w_a_print
end type
end forward

global type b1w_prt_refilllog from w_a_print
integer width = 3360
boolean ib_print_horizental = true
integer ii_orientation = 1
end type
global b1w_prt_refilllog b1w_prt_refilllog

on b1w_prt_refilllog.create
call super::create
end on

on b1w_prt_refilllog.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_refilldt_fr, ls_refilldt_to, ls_contractseq, ls_customerid, ls_validkey
Date ld_refilldt_fr, ld_refilldt_to
Integer li_check

ld_refilldt_fr = dw_cond.object.refilldt_fr[1]
ld_refilldt_to = dw_cond.object.refilldt_to[1]
ls_refilldt_fr = Trim(String(ld_refilldt_fr, 'yyyymmdd'))
ls_refilldt_to = Trim(String(ld_refilldt_to, 'yyyymmdd'))
ls_contractseq = Trim(String(dw_cond.object.contractseq[1]))
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If IsNull(ls_refilldt_fr) Then ls_refilldt_fr = ""
If IsNull(ls_refilldt_to) Then ls_refilldt_to = ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_validkey) Then ls_validkey = ""

// 충전일자의 From ~ To Check
If ls_refilldt_fr <> "" AND ls_refilldt_to <> "" Then
	li_check = fi_chk_frto_day(ld_refilldt_fr, ld_refilldt_to)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "충전일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("refilldt_fr")
		Return
	END IF
END IF

// Dynamic SQL
ls_where = ""

If ls_refilldt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(r.refilldt, 'yyyymmdd') >= '" + ls_refilldt_fr + "' "
End If

If ls_refilldt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(r.refilldt, 'yyyymmdd') <= '" + ls_refilldt_to + "' "
End If

If ls_contractseq <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " r.contractseq = '" + ls_contractseq + "' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " c.customerid = '" + ls_customerid + "' "
End If

If ls_validkey <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " c.contractseq in (select contractseq from validinfo where validkey= '" + ls_validkey + "') "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ls_refilldt_fr <> "" Then
	dw_list.object.t_refilldt_fr.Text = String(ls_refilldt_fr,'@@@@-@@-@@')
End If

If ls_refilldt_to <> "" Then
	dw_list.object.t_refilldt_to.Text = String(ls_refilldt_to, '@@@@-@@-@@')
End If

If ll_row = 0 Then
	f_msg_info(1000, Title,"")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 
End If

end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_refilllog
integer y = 56
integer height = 216
string dataobject = "b1dw_cnd_prt_refilllog"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

Return 0
end event

type p_ok from w_a_print`p_ok within b1w_prt_refilllog
end type

type p_close from w_a_print`p_close within b1w_prt_refilllog
end type

type dw_list from w_a_print`dw_list within b1w_prt_refilllog
integer y = 324
integer width = 3264
string dataobject = "b1dw_prt_refilllog"
end type

type p_1 from w_a_print`p_1 within b1w_prt_refilllog
end type

type p_2 from w_a_print`p_2 within b1w_prt_refilllog
end type

type p_3 from w_a_print`p_3 within b1w_prt_refilllog
end type

type p_5 from w_a_print`p_5 within b1w_prt_refilllog
end type

type p_6 from w_a_print`p_6 within b1w_prt_refilllog
end type

type p_7 from w_a_print`p_7 within b1w_prt_refilllog
end type

type p_8 from w_a_print`p_8 within b1w_prt_refilllog
end type

type p_9 from w_a_print`p_9 within b1w_prt_refilllog
end type

type p_4 from w_a_print`p_4 within b1w_prt_refilllog
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_refilllog
end type

type p_port from w_a_print`p_port within b1w_prt_refilllog
end type

type p_land from w_a_print`p_land within b1w_prt_refilllog
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_refilllog
integer y = 12
integer height = 280
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_refilllog
end type

