﻿$PBExportHeader$ssrt_prt_autopay_failed_list.srw
$PBExportComments$[1hera] Autopayment Failed List
forward
global type ssrt_prt_autopay_failed_list from w_a_print
end type
end forward

global type ssrt_prt_autopay_failed_list from w_a_print
end type
global ssrt_prt_autopay_failed_list ssrt_prt_autopay_failed_list

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt, &
			ls_cid,				ls_base

ls_reqdt 	= String(dw_cond.Object.reqdt[1], "yyyymmdd")
ls_cid 		= Trim(dw_cond.Object.customerid[1])
ls_base 		= Trim(dw_cond.Object.base[1])

If IsNull(ls_reqdt) 		Then ls_reqdt 		= ""
If IsNull(ls_cid) 		Then ls_cid 		= ""
If IsNull(ls_base) 		Then ls_base		= ""

If ls_reqdt = '' Then
	f_msg_usr_err(200, Title, "Request Date")
	dw_cond.Setfocus()
	dw_cond.Setcolumn("reqdt")
	return
end If

ls_temp 		= "Request Date : " + string(dw_cond.Object.reqdt[1], 'mm-dd-yyyy')
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

If ls_reqdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.REQUESTDT = '" + ls_reqdt +  "' "
End If
If ls_cid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.PAYID = '" + ls_cid + "' "
End If
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.GROUPID = '" + ls_base + "' "
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

on ssrt_prt_autopay_failed_list.create
call super::create
end on

on ssrt_prt_autopay_failed_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

Long ll_row, ll_jj
String ls_nm
String ls_date

dw_list.AcceptText()

IF dw_list.RowCount() > 0 then
	FOR ll_jj = 1 to dw_list.RowCount()
//		ls_nm = dw_list.Describe("Evaluate('LookUpDisplay(status)', " + String(ll_jj) +" )")
//		dw_list.Object.status_1[ll_jj] = ls_nm
		dw_list.Object.expdt[ll_jj] = '20' + dw_list.Object.expdt[ll_jj]
	NEXT
	ls_date = String (fdt_get_dbserver_now(),'yyyymmdd')
	f_excel_ascii1(dw_list, ls_date + '_prt_autopay_failed_list')
END IF

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_autopay_failed_list
integer x = 50
integer y = 56
integer width = 2089
integer height = 264
string dataobject = "ssrt_cnd_prt_autopay_failed_list"
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

type p_ok from w_a_print`p_ok within ssrt_prt_autopay_failed_list
integer x = 2203
integer y = 76
end type

type p_close from w_a_print`p_close within ssrt_prt_autopay_failed_list
integer x = 2514
integer y = 76
end type

type dw_list from w_a_print`dw_list within ssrt_prt_autopay_failed_list
integer x = 23
integer y = 372
integer height = 1296
string dataobject = "ssrt_prt_autopay_failed_list_new"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_autopay_failed_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_autopay_failed_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_autopay_failed_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_autopay_failed_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_autopay_failed_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_autopay_failed_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_autopay_failed_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_autopay_failed_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_autopay_failed_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_autopay_failed_list
end type

type p_port from w_a_print`p_port within ssrt_prt_autopay_failed_list
end type

type p_land from w_a_print`p_land within ssrt_prt_autopay_failed_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_autopay_failed_list
integer y = 20
integer width = 2139
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_autopay_failed_list
end type

