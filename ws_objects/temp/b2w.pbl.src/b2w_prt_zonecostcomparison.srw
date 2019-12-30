$PBExportHeader$b2w_prt_zonecostcomparison.srw
$PBExportComments$[ssong] 대역별 원가대비 수익율 현황
forward
global type b2w_prt_zonecostcomparison from w_a_print
end type
end forward

global type b2w_prt_zonecostcomparison from w_a_print
integer width = 3218
end type
global b2w_prt_zonecostcomparison b2w_prt_zonecostcomparison

on b2w_prt_zonecostcomparison.create
call super::create
end on

on b2w_prt_zonecostcomparison.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b2w_prt_zonecostcomparison
	Desc.	: 대역별 원가대비 수익율현황
	Ver.	: 1.0
	Date	: 2004.8.27
	Programer : Song Eun Mi(ssong)
-------------------------------------------------------------------------*/

dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
dw_cond.object.todt[1]   = fdt_get_dbserver_now()

end event

event ue_init();call super::ue_init;ii_orientation = 2 //세로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String ls_fromdt, ls_todt, ls_carrier, ls_svccod, ls_where
Long ll_row
Date ld_fromdt, ld_todt

ls_carrier     = Trim(dw_cond.Object.carrier[1])
ls_svccod      = Trim(dw_cond.object.svccod[1])

ls_fromdt = String(dw_cond.object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_cond.object.todt[1],'yyyymmdd')
ld_fromdt = dw_cond.object.fromdt[1]
ld_todt = dw_cond.object.todt[1]

If IsNull(ls_carrier) Then ls_carrier = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

//Retrieve
If ls_fromdt = "" Then
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_todt = "" Then
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("todt")
	Return
End If

If ls_fromdt <> "" And ls_todt <> "" Then
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(210, title, "작업일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	End If
End If

ls_where = ""

If ls_carrier <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.carrier = '" + ls_carrier + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccod + "' "
End If

dw_list.is_where = ls_where
dw_list.object.fr_to.Text   = String(dw_cond.object.fromdt[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.todt[1], 'yyyy-mm-dd')

If ls_carrier = "" Then
	dw_list.object.carrier.Text = 'ALL'
Else
	dw_list.object.carrier.Text = dw_cond.object.t_carrier[1]
End If

If ls_svccod = "" Then
	dw_list.object.svccod.Text = 'ALL'
Else
	dw_list.object.svccod.Text = dw_cond.object.t_svccod[1]
End If

ll_row = dw_list.Retrieve(ls_fromdt, ls_todt)
If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


end event

event ue_reset();call super::ue_reset;dw_cond.object.fromdt[1] = fdt_get_dbserver_now()
dw_cond.object.todt[1]   = fdt_get_dbserver_now()
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_zonecostcomparison
integer y = 68
integer width = 2327
integer height = 200
string dataobject = "b2dw_prt_cnd_zone_costcomparison"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_zonecostcomparison
integer x = 2546
end type

type p_close from w_a_print`p_close within b2w_prt_zonecostcomparison
integer x = 2848
end type

type dw_list from w_a_print`dw_list within b2w_prt_zonecostcomparison
integer y = 312
integer width = 3095
integer height = 1308
string dataobject = "b2dw_prt_det_zone_costcomparison"
end type

type p_1 from w_a_print`p_1 within b2w_prt_zonecostcomparison
end type

type p_2 from w_a_print`p_2 within b2w_prt_zonecostcomparison
end type

type p_3 from w_a_print`p_3 within b2w_prt_zonecostcomparison
end type

type p_5 from w_a_print`p_5 within b2w_prt_zonecostcomparison
end type

type p_6 from w_a_print`p_6 within b2w_prt_zonecostcomparison
end type

type p_7 from w_a_print`p_7 within b2w_prt_zonecostcomparison
end type

type p_8 from w_a_print`p_8 within b2w_prt_zonecostcomparison
end type

type p_9 from w_a_print`p_9 within b2w_prt_zonecostcomparison
end type

type p_4 from w_a_print`p_4 within b2w_prt_zonecostcomparison
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_zonecostcomparison
end type

type p_port from w_a_print`p_port within b2w_prt_zonecostcomparison
end type

type p_land from w_a_print`p_land within b2w_prt_zonecostcomparison
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_zonecostcomparison
integer width = 2395
integer height = 292
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_zonecostcomparison
end type

