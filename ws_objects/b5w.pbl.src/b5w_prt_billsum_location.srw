$PBExportHeader$b5w_prt_billsum_location.srw
$PBExportComments$[chooys] 지역별 청구수납현황
forward
global type b5w_prt_billsum_location from w_a_print
end type
end forward

global type b5w_prt_billsum_location from w_a_print
end type
global b5w_prt_billsum_location b5w_prt_billsum_location

type variables
String is_pos
end variables

on b5w_prt_billsum_location.create
call super::create
end on

on b5w_prt_billsum_location.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;String ls_fromdt
String ls_location
Date ld_fromdt
String ls_where
Long ll_rows
b5u_dbmgr5 	lu_dbmgr
Integer li_rc
String ls_ref_desc, ls_temp, ls_result[]
Integer li_return
String ls_overamt_cod, ls_oversum_cod

ls_ref_desc = ""
ls_temp = fs_get_control("B5", "T108", ls_ref_desc)
If ls_temp = "" Then Return

li_return = fi_cut_string(ls_temp, ";", ls_result[])
If li_return <= 0 Then Return
ls_overamt_cod = ls_result[1]
ls_oversum_cod = ls_result[2]

ld_fromdt =  dw_cond.object.fromdt[1]
ls_fromdt = String(dw_cond.object.fromdt[1], 'yyyymm')
ls_location = Trim(dw_cond.object.location[1])
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_location) Then ls_location = ""

If ls_fromdt = "" Then
	f_msg_info(200, title, "청구수납기준월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

dw_list.SetRedraw(False)
dw_list.Reset()


If ls_location = "" Then
	dw_list.SetTransObject(SQLCA)
	ll_rows = dw_list.retrieve(ls_fromdt,"%",ls_overamt_cod,ls_oversum_cod)
Else
	dw_list.SetTransObject(SQLCA)
	ll_rows = dw_list.retrieve(ls_fromdt,ls_location,ls_overamt_cod,ls_oversum_cod)
End If


If is_pos = "1" Then
	dw_list.object.tramt.Format = "#,##0.0"
   dw_list.object.payamt.Format = "#,##0.0"
	dw_list.object.agamt.Format = "#,##0.0"
	dw_list.object.sum_tramt.Format = "#,##0.0"
	dw_list.object.sum_payamt.Format = "#,##0.0"
	dw_list.object.sum_agamt.Format = "#,##0.0"
	dw_list.object.csum_agamt.Format = "#,##0.0"
	dw_list.object.overamt.Format = "#,##0.0"
	dw_list.object.oversum.Format = "#,##0.0"
	dw_list.object.sum_overamt.Format = "#,##0.0"
	dw_list.object.sum_oversum.Format = "#,##0.0"
ElseIf is_pos = "2" Then
	dw_list.object.tramt.Format = "#,##0.00"
	dw_list.object.payamt.Format = "#,##0.00"
	dw_list.object.agamt.Format = "#,##0.00"
	dw_list.object.sum_tramt.Format = "#,##0.00"
	dw_list.object.sum_payamt.Format = "#,##0.00"
	dw_list.object.sum_agamt.Format = "#,##0.00"
	dw_list.object.csum_agamt.Format = "#,##0.00"
	dw_list.object.overamt.Format = "#,##0.00"
	dw_list.object.oversum.Format = "#,##0.00"
	dw_list.object.sum_overamt.Format = "#,##0.00"
	dw_list.object.sum_oversum.Format = "#,##0.00"
Else
	dw_list.object.tramt.Format = "#,##0"
	dw_list.object.payamt.Format = "#,##0"
	dw_list.object.agamt.Format = "#,##0"
	dw_list.object.sum_tramt.Format = "#,##0"
	dw_list.object.sum_payamt.Format = "#,##0"
	dw_list.object.sum_agamt.Format = "#,##0"
	dw_list.object.csum_agamt.Format = "#,##0"
	dw_list.object.overamt.Format = "#,##0"
	dw_list.object.oversum.Format = "#,##0"
	dw_list.object.sum_overamt.Format = "#,##0"
	dw_list.object.sum_oversum.Format = "#,##0"
End If


////모래시계표시
//SetPointer (HourGlass! )
//
//IF ll_rows > 0 THEN
//
//	lu_dbmgr = Create b5u_dbmgr5
//	lu_dbmgr.is_caller = "b5w_prt_bilsum_location%ok"
//	lu_dbmgr.is_title = Title
//	lu_dbmgr.is_data[1] = ls_fromdt
//	lu_dbmgr.idw_data[1] = dw_list
//	lu_dbmgr.uf_prc_db()
//	li_rc = lu_dbmgr.ii_rc
//	
//	If li_rc < 0 Then
//		Destroy lu_dbmgr
//	End If
//	
//	Destroy lu_dbmgr
//	
//
//ELSEIf ll_rows < 0 Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
//	Return
//ElseIf ll_rows = 0 Then
//	f_msg_info(1000, Title, "")
//END IF
//
////모래시계표시 해제
//SetPointer (Arrow! )

dw_list.object.t_fromdt.Text = MidA(ls_fromdt, 1, 4) + "-" + MidA(ls_fromdt, 5, 2)
dw_list.SetRedraw(True)
end event

event open;call super::open;String ls_desc

dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())

//금액의 소숫점 자리수 가져오기(B5:H200)
is_pos = fs_get_control("B5","H200",ls_desc)

end event

event ue_reset();call super::ue_reset;dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_billsum_location
integer x = 64
integer y = 88
integer width = 1824
integer height = 148
string dataobject = "b5dw_cnd_prt_billsum_location"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_billsum_location
integer x = 1993
integer y = 36
end type

type p_close from w_a_print`p_close within b5w_prt_billsum_location
integer x = 2295
integer y = 36
end type

type dw_list from w_a_print`dw_list within b5w_prt_billsum_location
integer y = 288
integer height = 1332
string dataobject = "b5dw_prt_bilsum_location_2"
end type

type p_1 from w_a_print`p_1 within b5w_prt_billsum_location
end type

type p_2 from w_a_print`p_2 within b5w_prt_billsum_location
end type

type p_3 from w_a_print`p_3 within b5w_prt_billsum_location
end type

type p_5 from w_a_print`p_5 within b5w_prt_billsum_location
end type

type p_6 from w_a_print`p_6 within b5w_prt_billsum_location
end type

type p_7 from w_a_print`p_7 within b5w_prt_billsum_location
end type

type p_8 from w_a_print`p_8 within b5w_prt_billsum_location
end type

type p_9 from w_a_print`p_9 within b5w_prt_billsum_location
end type

type p_4 from w_a_print`p_4 within b5w_prt_billsum_location
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_billsum_location
end type

type p_port from w_a_print`p_port within b5w_prt_billsum_location
end type

type p_land from w_a_print`p_land within b5w_prt_billsum_location
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_billsum_location
integer width = 1861
integer height = 264
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_billsum_location
end type

