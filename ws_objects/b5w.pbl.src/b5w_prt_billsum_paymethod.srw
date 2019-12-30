$PBExportHeader$b5w_prt_billsum_paymethod.srw
$PBExportComments$[chooys] 결제방법별 청구수납현황
forward
global type b5w_prt_billsum_paymethod from w_a_print
end type
end forward

global type b5w_prt_billsum_paymethod from w_a_print
end type
global b5w_prt_billsum_paymethod b5w_prt_billsum_paymethod

type variables
Int ii_pos
end variables

on b5w_prt_billsum_paymethod.create
call super::create
end on

on b5w_prt_billsum_paymethod.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;String ls_trdt
String ls_location
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

ls_trdt = String(dw_cond.object.trdt[1], 'yyyymm')
If IsNull(ls_trdt) Then ls_trdt = ""

If ls_trdt = "" Then
	f_msg_info(200, title, "청구수납기준월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
End If

dw_list.SetRedraw(False)
dw_list.Reset()


//모래시계표시
SetPointer (HourGlass! )


ll_rows = dw_list.retrieve(ls_trdt,ls_overamt_cod,ls_oversum_cod)

IF ll_rows > 0 THEN

	lu_dbmgr = Create b5u_dbmgr5
	lu_dbmgr.is_caller = "b5w_prt_bilsum_paymethod%ok"
	lu_dbmgr.is_title = Title
	lu_dbmgr.is_data[1] = ls_trdt
	lu_dbmgr.idw_data[1] = dw_list
	lu_dbmgr.uf_prc_db_01()
	li_rc = lu_dbmgr.ii_rc
	
	If li_rc < 0 Then
		Destroy lu_dbmgr
	End If
	
	Destroy lu_dbmgr
	

ELSEIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
END IF

//모래시계표시 해제
SetPointer (Arrow! )

dw_list.object.t_today.Text = String(fdt_get_dbserver_now(),"YYYY-MM-DD")
dw_list.SetRedraw(True)
end event

event open;call super::open;String ls_pos, ls_desc

dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())

//금액의 소숫점 자리수 가져오기(B5:H200)
ls_pos = fs_get_control("B5","H200",ls_desc)
ii_pos = Integer(ls_pos)


If ls_pos = "1" Then
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
ElseIf ls_pos = "2" Then
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
end event

event ue_reset();call super::ue_reset;dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())

end event

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_billsum_paymethod
integer x = 91
integer y = 92
integer width = 832
integer height = 148
string dataobject = "b5dw_cnd_prt_billsum_paymethod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_billsum_paymethod
integer x = 1047
integer y = 48
end type

type p_close from w_a_print`p_close within b5w_prt_billsum_paymethod
integer x = 1349
integer y = 48
end type

type dw_list from w_a_print`dw_list within b5w_prt_billsum_paymethod
integer y = 288
integer height = 1332
string dataobject = "b5dw_inq_prt_billsum_paymethod"
end type

type p_1 from w_a_print`p_1 within b5w_prt_billsum_paymethod
end type

type p_2 from w_a_print`p_2 within b5w_prt_billsum_paymethod
end type

type p_3 from w_a_print`p_3 within b5w_prt_billsum_paymethod
end type

type p_5 from w_a_print`p_5 within b5w_prt_billsum_paymethod
end type

type p_6 from w_a_print`p_6 within b5w_prt_billsum_paymethod
end type

type p_7 from w_a_print`p_7 within b5w_prt_billsum_paymethod
end type

type p_8 from w_a_print`p_8 within b5w_prt_billsum_paymethod
end type

type p_9 from w_a_print`p_9 within b5w_prt_billsum_paymethod
end type

type p_4 from w_a_print`p_4 within b5w_prt_billsum_paymethod
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_billsum_paymethod
end type

type p_port from w_a_print`p_port within b5w_prt_billsum_paymethod
end type

type p_land from w_a_print`p_land within b5w_prt_billsum_paymethod
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_billsum_paymethod
integer width = 896
integer height = 264
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_billsum_paymethod
end type

