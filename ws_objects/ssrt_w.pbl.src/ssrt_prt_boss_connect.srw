$PBExportHeader$ssrt_prt_boss_connect.srw
$PBExportComments$[1hera] Boss Connect List
forward
global type ssrt_prt_boss_connect from w_a_print_sort
end type
end forward

global type ssrt_prt_boss_connect from w_a_print_sort
event ue_saveas_init ( )
end type
global ssrt_prt_boss_connect ssrt_prt_boss_connect

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on ssrt_prt_boss_connect.create
call super::create
end on

on ssrt_prt_boss_connect.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String 	ls_where
String 	ls_cid, 	ls_contractno,	ls_orderno, ls_status, ls_siid
Long 		ll_row

ls_cid 			= Trim(dw_cond.object.customerid[1])
ls_contractno 	= Trim(dw_cond.object.contractno[1])
ls_orderno 		= Trim(dw_cond.object.orderno[1])
ls_status 		= Trim(dw_cond.object.status[1])
ls_siid        = Trim(dw_cond.object.siid[1])

IF ( ls_cid = "" AND ls_contractno = ""  AND ls_orderno = "" AND ls_status = "" ) THEN
	f_msg_info(200, Title, "Search By ? ")
	dw_cond.SetFocus()
	dw_cond.setColumn("customerid")
	Return 
END IF

//Null Check
If IsNull(ls_cid) 			Then ls_cid = ""
If IsNull(ls_contractno) 	Then ls_contractno = ""
If IsNull(ls_orderno) 		Then ls_orderno = ""
If IsNull(ls_status) 		Then ls_status = ""
If IsNull(ls_siid)    		Then ls_siid = ""

//Retrieve
ls_where = ""

If ls_cid <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "a.customerid = '" + ls_cid + "' "
End If

If ls_contractno <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "a.contractseq = '" + ls_contractno + "' "
End If

If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "a.orderno = '" + ls_orderno + "' "
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "a.status = '" + ls_status + "' "
End If

If ls_siid <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "a.siid = '" + ls_siid + "' "
End If

//clipboard(ls_where)
//clipboard(dw_List.getsqlselect())
//messagebox("1",ls_Where)

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로0, 가로1
ib_margin = False
end event

type dw_list from w_a_print_sort`dw_list within ssrt_prt_boss_connect
integer y = 512
integer height = 1024
integer taborder = 0
string dataobject = "ssrt_prt_boss_connect"
end type

event dw_list::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.dacom_svctype_t
uf_init(ldwo_SORT)
end event

event dw_list::clicked;call super::clicked;

String ls_type
ls_type = dwo.Type


end event

type dw_cond from w_a_print_sort`dw_cond within ssrt_prt_boss_connect
integer x = 50
integer width = 2327
integer height = 428
string dataobject = "ssrt_cnd_prt_boss_connect"
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm, ls_memberid, &
		 ls_operator
Integer	li_cnt

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select customernm	  INTO :ls_customernm		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			return 1
		ELSE
			This.Object.customernm[1] 	=  ls_customernm
		END IF
End Choose

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::losefocus;call super::losefocus;this.Accepttext()
end event

event dw_cond::itemerror;call super::itemerror;Return 1
end event

type p_ok from w_a_print_sort`p_ok within ssrt_prt_boss_connect
end type

type p_close from w_a_print_sort`p_close within ssrt_prt_boss_connect
end type

type p_1 from w_a_print_sort`p_1 within ssrt_prt_boss_connect
end type

type p_2 from w_a_print_sort`p_2 within ssrt_prt_boss_connect
end type

type p_3 from w_a_print_sort`p_3 within ssrt_prt_boss_connect
end type

type p_5 from w_a_print_sort`p_5 within ssrt_prt_boss_connect
end type

type p_6 from w_a_print_sort`p_6 within ssrt_prt_boss_connect
end type

type p_7 from w_a_print_sort`p_7 within ssrt_prt_boss_connect
end type

type p_8 from w_a_print_sort`p_8 within ssrt_prt_boss_connect
end type

type p_9 from w_a_print_sort`p_9 within ssrt_prt_boss_connect
end type

type p_4 from w_a_print_sort`p_4 within ssrt_prt_boss_connect
end type

type gb_1 from w_a_print_sort`gb_1 within ssrt_prt_boss_connect
end type

type p_port from w_a_print_sort`p_port within ssrt_prt_boss_connect
end type

type p_land from w_a_print_sort`p_land within ssrt_prt_boss_connect
end type

type gb_cond from w_a_print_sort`gb_cond within ssrt_prt_boss_connect
integer width = 2363
integer height = 480
integer taborder = 0
end type

