$PBExportHeader$ssrt_prt_prepay_list.srw
$PBExportComments$[1hera] 선수금입금 및 적용내역조회
forward
global type ssrt_prt_prepay_list from w_a_print
end type
end forward

global type ssrt_prt_prepay_list from w_a_print
end type
global ssrt_prt_prepay_list ssrt_prt_prepay_list

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt, &
			ls_cid,				ls_base

ls_cid 		= Trim(dw_cond.Object.customerid[1])
ls_base 		= Trim(dw_cond.Object.base[1])

If IsNull(ls_cid) 		Then ls_cid 		= ""
If IsNull(ls_base) 		Then ls_base		= ""


//ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

If ls_cid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.PAYID = '" + ls_cid + "' "
End If
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " B.BASECOD = '" + ls_base + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If


end event

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on ssrt_prt_prepay_list.create
call super::create
end on

on ssrt_prt_prepay_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_prepay_list')

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_prepay_list
integer x = 50
integer y = 56
integer width = 1774
integer height = 204
string dataobject = "ssrt_cnd_prt_prepay_list"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select customernm		  INTO :ls_customernm		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		 IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
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

type p_ok from w_a_print`p_ok within ssrt_prt_prepay_list
integer x = 1929
integer y = 76
end type

type p_close from w_a_print`p_close within ssrt_prt_prepay_list
integer x = 2240
integer y = 76
end type

type dw_list from w_a_print`dw_list within ssrt_prt_prepay_list
integer x = 23
integer y = 280
integer height = 1388
string dataobject = "ssrt_prt_prepay_list"
end type

event dw_list::clicked;call super::clicked;//If IsSelected( row ) then
//	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If
//
end event

event dw_list::doubleclicked;call super::doubleclicked;	String ls_cid, ls_payer
	
	ls_cid 	= Trim(This.object.payid[row])
	ls_payer = Trim(This.object.customernm[row])

	iu_cust_msg = Create u_cust_a_msg

	
	iu_cust_msg.is_pgm_name = "선수금현황"
	iu_cust_msg.is_grp_name = "선수금리스트"
	iu_cust_msg.is_pgm_id 	= gs_pgm_id[gi_open_win_no]
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.is_data[1] = ls_cid					//customer ID
	iu_cust_msg.is_data[2] = ls_payer				//customer NM
   OpenWithParm(ssrt_prt_prepay_popup, iu_cust_msg)
	
DESTROY iu_cust_msg	
	 


end event

type p_1 from w_a_print`p_1 within ssrt_prt_prepay_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_prepay_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_prepay_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_prepay_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_prepay_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_prepay_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_prepay_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_prepay_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_prepay_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_prepay_list
end type

type p_port from w_a_print`p_port within ssrt_prt_prepay_list
end type

type p_land from w_a_print`p_land within ssrt_prt_prepay_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_prepay_list
integer y = 20
integer width = 1856
integer height = 248
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_prepay_list
end type

