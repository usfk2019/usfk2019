$PBExportHeader$c1w_prt_carrier_callsum.srw
$PBExportComments$[ssong]사업자별 통화료 현황
forward
global type c1w_prt_carrier_callsum from w_a_print
end type
end forward

global type c1w_prt_carrier_callsum from w_a_print
end type
global c1w_prt_carrier_callsum c1w_prt_carrier_callsum

type variables

end variables

on c1w_prt_carrier_callsum.create
call super::create
end on

on c1w_prt_carrier_callsum.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_prt_carrier_callsum
	Desc.	: 	사업자별 통화료 현황
	Ver.	:	1.0
	Date	:	2005.11.01
	Programer : Song Eun Mi
--------------------------------------------------------------------------*/
dw_cond.Object.yyyymm[1] = fdt_get_dbserver_now()
end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False
end event

event ue_ok();call super::ue_ok;String ls_yyyymm
Long ll_row
Integer li_rc
c1u_dbmgr lu_dbmgr

ls_yyyymm = String(dw_cond.Object.yyyymm[1],'yyyymm')
If Isnull(ls_yyyymm) Then ls_yyyymm = ""

If ls_yyyymm = "" then
	f_msg_usr_err(200, Title, "년월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyymm")	
	return 
End If	

dw_list.setredraw(false)

lu_dbmgr = Create c1u_dbmgr
lu_dbmgr.is_caller = "c1w_prt_carrier_callsum%ue_ok"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_list
lu_dbmgr.is_data[1]  = ls_yyyymm

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	dw_list.setredraw(true)	
	Return 
End If

Destroy lu_dbmgr

dw_list.Object.t_yyyymm.text = String(dw_cond.Object.yyyymm[1],'yyyy년mm월')

ll_row	= dw_list.Rowcount()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	dw_list.setredraw(true)
End If

dw_list.setredraw(true)
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.Object.yyyymm[1] = fdt_get_dbserver_now()
end event

type dw_cond from w_a_print`dw_cond within c1w_prt_carrier_callsum
integer x = 50
integer y = 56
integer width = 1102
integer height = 116
string dataobject = "c1dw_cnd_carrier_callsum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within c1w_prt_carrier_callsum
integer x = 1298
integer y = 68
end type

type p_close from w_a_print`p_close within c1w_prt_carrier_callsum
integer x = 1600
integer y = 68
end type

type dw_list from w_a_print`dw_list within c1w_prt_carrier_callsum
integer y = 216
integer height = 1396
string dataobject = "c1dw_prt_carrier_callsum"
end type

type p_1 from w_a_print`p_1 within c1w_prt_carrier_callsum
end type

type p_2 from w_a_print`p_2 within c1w_prt_carrier_callsum
end type

type p_3 from w_a_print`p_3 within c1w_prt_carrier_callsum
end type

type p_5 from w_a_print`p_5 within c1w_prt_carrier_callsum
end type

type p_6 from w_a_print`p_6 within c1w_prt_carrier_callsum
end type

type p_7 from w_a_print`p_7 within c1w_prt_carrier_callsum
end type

type p_8 from w_a_print`p_8 within c1w_prt_carrier_callsum
end type

type p_9 from w_a_print`p_9 within c1w_prt_carrier_callsum
end type

type p_4 from w_a_print`p_4 within c1w_prt_carrier_callsum
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_carrier_callsum
end type

type p_port from w_a_print`p_port within c1w_prt_carrier_callsum
end type

type p_land from w_a_print`p_land within c1w_prt_carrier_callsum
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_carrier_callsum
integer width = 1202
integer height = 188
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_carrier_callsum
end type

