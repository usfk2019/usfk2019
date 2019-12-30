$PBExportHeader$b1w_prt_troubletype_list.srw
$PBExportComments$[kem] 장애 분석 보고서
forward
global type b1w_prt_troubletype_list from w_a_print
end type
end forward

global type b1w_prt_troubletype_list from w_a_print
integer width = 3323
integer height = 1992
end type
global b1w_prt_troubletype_list b1w_prt_troubletype_list

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 2 //세로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_troubletype_list
	Desc.	: 장애 분석 보고서 
	Ver.	: 1.0
	Date	: 2003.12.11
	Programer : kem
-------------------------------------------------------------------------*/

dw_cond.object.type[1] = "0"
end event

on b1w_prt_troubletype_list.create
call super::create
end on

on b1w_prt_troubletype_list.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_fromdt, ls_todt, ls_type, ls_fromdt1, ls_todt1
Date   ld_fromdt, ld_todt
Long ll_row 

dw_cond.AcceptText()

ld_fromdt = dw_cond.object.fromdt[1]
ld_todt   = dw_cond.object.todt[1]
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_todt   = String(ld_todt, 'yyyymmdd')
ls_type   = Trim(dw_cond.object.type[1])

//Null Check
If IsNull(ls_fromdt) Or ls_fromdt = "" Then
	ls_fromdt  = "19000101"
	ls_fromdt1 = "00000000"
Else
	ls_fromdt1 = ls_fromdt
End If
If IsNull(ls_todt) Or ls_todt = "" Then
	ls_todt  = "29991231"
	ls_todt1 = "00000000"
Else
	ls_todt1 = ls_todt
End If
If IsNull(ls_type) Then ls_type = ""

If ls_type = "" Then
	f_msg_info(200, Title, "출력구분")
	dw_cond.SetFocus()
	dw_cond.setColumn("type")
	Return
End If
		
//Retrieve
dw_list.SetReDraw(False)
If ls_type = "0" Then
	dw_list.DataObject = "b1dw_prt_troubletype_list"
	dw_list.SetTransObject(SQLCA)
ElseIf ls_type = "1" Then
	dw_list.DataObject = "b1dw_prt_troubletype_list1"
	dw_list.SetTransObject(SQLCA)
ElseIf ls_type = "2" Then
	dw_list.DataObject = "b1dw_prt_troubletype_list2"
	dw_list.SetTransObject(SQLCA)
ElseIf ls_type = "3" Then
	dw_list.DataObject = "b1dw_prt_troubletype_list3"
	dw_list.SetTransObject(SQLCA)
Else
	dw_list.DataObject = "b1dw_prt_troubletype_list4"
	dw_list.SetTransObject(SQLCA)
End If

ll_row = dw_list.Retrieve(ls_fromdt, ls_todt)
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	dw_list.SetReDraw(True)

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	dw_list.SetReDraw(True)
End If

If ls_fromdt1 <> "00000000" Then
	dw_list.object.t_fromdt.text = LeftA(ls_fromdt1,4) + '-' + MidA(ls_fromdt1,5,2) + '-' + RightA(ls_fromdt1,2)
End If
If ls_todt1 <> "00000000" Then
	dw_list.object.t_todt.text = LeftA(ls_todt1,4) + '-' + MidA(ls_todt1,5,2) + '-' + RightA(ls_todt1,2)
End If

dw_list.SetReDraw(True)
		
		

end event

event ue_reset();call super::ue_reset;
 dw_cond.object.type[1] = "0"
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_troubletype_list
integer x = 46
integer y = 36
integer width = 2487
integer height = 356
string dataobject = "b1dw_cnd_prt_troubletype_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_troubletype_list
integer x = 2670
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_troubletype_list
integer x = 2967
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_troubletype_list
integer y = 420
integer width = 3227
integer height = 1224
string dataobject = "b1dw_prt_troubletype_list"
end type

type p_1 from w_a_print`p_1 within b1w_prt_troubletype_list
integer x = 2688
integer y = 1684
end type

type p_2 from w_a_print`p_2 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_3 from w_a_print`p_3 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_5 from w_a_print`p_5 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_6 from w_a_print`p_6 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_7 from w_a_print`p_7 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_8 from w_a_print`p_8 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_9 from w_a_print`p_9 within b1w_prt_troubletype_list
integer y = 1684
end type

type p_4 from w_a_print`p_4 within b1w_prt_troubletype_list
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_troubletype_list
integer y = 1652
end type

type p_port from w_a_print`p_port within b1w_prt_troubletype_list
integer y = 1720
end type

type p_land from w_a_print`p_land within b1w_prt_troubletype_list
integer y = 1720
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_troubletype_list
integer width = 2514
integer height = 400
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_troubletype_list
integer y = 1684
end type

