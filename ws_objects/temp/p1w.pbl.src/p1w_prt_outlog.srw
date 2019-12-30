$PBExportHeader$p1w_prt_outlog.srw
$PBExportComments$[jsha] 출고이력조회
forward
global type p1w_prt_outlog from w_a_print
end type
end forward

global type p1w_prt_outlog from w_a_print
end type
global p1w_prt_outlog p1w_prt_outlog

on p1w_prt_outlog.create
call super::create
end on

on p1w_prt_outlog.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_outdt_fr, ls_outdt_to, ls_pricemodel, ls_partner_prefix
Long ll_row
Integer li_return
Date ld_outdt_fr, ld_outdt_to

ld_outdt_fr = dw_cond.Object.outdt_fr[1]
ld_outdt_to = dw_cond.Object.outdt_to[1]
ls_outdt_fr = String(dw_cond.Object.outdt_fr[1],'yyyy-mm-dd')
ls_outdt_to = String(dw_cond.Object.outdt_to[1],'yyyy-mm-dd')
ls_pricemodel = Trim(dw_cond.Object.pricemodel[1])
ls_partner_prefix = Trim(dw_cond.Object.partner_prefix[1])

If IsNull(ls_outdt_fr) Then ls_outdt_fr = ""
If IsNull(ls_outdt_to) Then ls_outdt_to = ""
If IsNull(ls_pricemodel) Then ls_pricemodel = ""
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""
	  
ls_where = ""

If ls_outdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(a.outdt,'yyyy-mm-dd') >= '" + ls_outdt_fr + "' "
End If
If ls_outdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(a.outdt,'yyyy-mm-dd') <= '" + ls_outdt_to + "' "
End If
If ls_pricemodel <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.pricemodel = '" + ls_pricemodel + "' "
End If
If ls_partner_prefix <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.partner_prefix = '" + ls_partner_prefix + "' "
End If
If ls_outdt_fr <> "" AND ls_outdt_to <> "" Then
	li_return = fi_chk_frto_day(ld_outdt_fr, ld_outdt_to)
	If li_return = -1 Then
	 f_msg_usr_err(211, Title, "출고일자")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("oudt_fr")
	 Return 
	End If
End If
	
dw_list.Modify("outdtfr.text= '" + ls_outdt_fr + "' ")
dw_list.Modify("outdtto.text= '" + ls_outdt_to + "' ")
		
dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retreive()")
End If

Return
end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = True
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_outlog
integer width = 2034
integer height = 216
string dataobject = "p1dw_cnd_prt_outlog"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p1w_prt_outlog
integer x = 2226
end type

type p_close from w_a_print`p_close within p1w_prt_outlog
integer x = 2528
end type

type dw_list from w_a_print`dw_list within p1w_prt_outlog
integer y = 288
string dataobject = "p1dw_prt_outlog"
end type

type p_1 from w_a_print`p_1 within p1w_prt_outlog
end type

type p_2 from w_a_print`p_2 within p1w_prt_outlog
end type

type p_3 from w_a_print`p_3 within p1w_prt_outlog
end type

type p_5 from w_a_print`p_5 within p1w_prt_outlog
end type

type p_6 from w_a_print`p_6 within p1w_prt_outlog
end type

type p_7 from w_a_print`p_7 within p1w_prt_outlog
end type

type p_8 from w_a_print`p_8 within p1w_prt_outlog
end type

type p_9 from w_a_print`p_9 within p1w_prt_outlog
end type

type p_4 from w_a_print`p_4 within p1w_prt_outlog
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_outlog
end type

type p_port from w_a_print`p_port within p1w_prt_outlog
end type

type p_land from w_a_print`p_land within p1w_prt_outlog
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_outlog
integer width = 2071
integer height = 268
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_outlog
end type

