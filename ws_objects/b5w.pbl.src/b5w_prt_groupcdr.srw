$PBExportHeader$b5w_prt_groupcdr.srw
$PBExportComments$[ssong] 그룹별 통화내역서
forward
global type b5w_prt_groupcdr from w_a_print
end type
end forward

global type b5w_prt_groupcdr from w_a_print
integer width = 3470
integer height = 2328
end type
global b5w_prt_groupcdr b5w_prt_groupcdr

type variables
String is_format
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
end prototypes

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay id(wfi_get_payid)")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

on b5w_prt_groupcdr.create
call super::create
end on

on b5w_prt_groupcdr.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_workmm, ls_payid, ls_chargedt

ls_workmm  = Trim(String(dw_cond.Object.workmm[1], 'yyyymmdd'))
ls_payid   = Trim(dw_cond.Object.payid[1])
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
If IsNull(ls_workmm) Then ls_workmm = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_chargedt) Then ls_chargedt = ""

If ls_workmm = "" Then
	f_msg_usr_err(200, Title, "청구기준일")
	dw_cond.SetColumn("workmm")
	Return
End If

ls_where = ""
If ls_chargedt <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " cdr.chargedt = '" + ls_chargedt + "' "
End If
If ls_workmm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(cdr.trdt,'yyyymmdd') = '" + ls_workmm + "' "
End If
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " cdr.payid = '" + ls_payid + "' "
End If

dw_list.is_where =  ls_where
ll_rows = dw_list.Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If
	

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_groupcdr
integer y = 64
integer width = 2007
integer height = 208
string dataobject = "b5dw_prt_cnd_groupcdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;
Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.customernm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
End Choose

AcceptText()

Return 0 
		
		
		

end event

event dw_cond::itemchanged;call super::itemchanged;String ls_payid
int    li_rc

Choose Case Dwo.Name
	Case "payid"
		ls_payid = dw_cond.object.payid[1]
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.Object.payid[1] = ""
			dw_cond.Object.customernm[1] = ""
			dw_cond.SetColumn("payid")
			return 2
		End IF
End Choose

end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b5w_prt_groupcdr
integer x = 2569
integer y = 104
end type

type p_close from w_a_print`p_close within b5w_prt_groupcdr
integer x = 2885
integer y = 104
end type

type dw_list from w_a_print`dw_list within b5w_prt_groupcdr
integer y = 312
integer width = 3378
integer height = 1644
string dataobject = "b5dw_prt_det_groupcdr"
end type

type p_1 from w_a_print`p_1 within b5w_prt_groupcdr
integer x = 2898
integer y = 1996
end type

type p_2 from w_a_print`p_2 within b5w_prt_groupcdr
integer x = 695
integer y = 1996
end type

type p_3 from w_a_print`p_3 within b5w_prt_groupcdr
integer x = 2574
integer y = 1996
end type

type p_5 from w_a_print`p_5 within b5w_prt_groupcdr
integer x = 1385
integer y = 1996
end type

type p_6 from w_a_print`p_6 within b5w_prt_groupcdr
integer x = 1961
integer y = 1996
end type

type p_7 from w_a_print`p_7 within b5w_prt_groupcdr
integer x = 1769
integer y = 1996
end type

type p_8 from w_a_print`p_8 within b5w_prt_groupcdr
integer x = 1577
integer y = 1996
end type

type p_9 from w_a_print`p_9 within b5w_prt_groupcdr
integer x = 1010
integer y = 1996
end type

type p_4 from w_a_print`p_4 within b5w_prt_groupcdr
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_groupcdr
integer x = 55
integer y = 1968
end type

type p_port from w_a_print`p_port within b5w_prt_groupcdr
integer x = 105
integer y = 2024
end type

type p_land from w_a_print`p_land within b5w_prt_groupcdr
integer x = 265
integer y = 2036
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_groupcdr
integer y = 8
integer width = 2053
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_groupcdr
integer x = 2249
integer y = 1996
end type

