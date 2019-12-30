$PBExportHeader$p2w_prc_pre_item_cancel.srw
$PBExportComments$[ceusee] 선불 매출 실적 취소
forward
global type p2w_prc_pre_item_cancel from w_a_prc
end type
end forward

global type p2w_prc_pre_item_cancel from w_a_prc
integer width = 1957
integer height = 1216
end type
global p2w_prc_pre_item_cancel p2w_prc_pre_item_cancel

type variables
String ls_test
end variables

on p2w_prc_pre_item_cancel.create
call super::create
end on

on p2w_prc_pre_item_cancel.destroy
call super::destroy
end on

event open;call super::open;Integer li_return
String ls_ref_content, ls_ref_desc, ls_temp


iu_cust_msg = create u_cust_a_msg 
ls_temp = fs_get_control("S1", "S103", ls_ref_desc)

dw_input.object.todt[1] = Date(String(ls_temp, "@@@@-@@-@@"))


end event

event type integer ue_input();call super::ue_input;String ls_fromdt, ls_todt

ls_fromdt = String(dw_input.Object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_input.Object.todt[1],'yyyymmdd')

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

If ls_fromdt = "" Then
	f_msg_info(210, Title, "취소일자")
	dw_input.SetFocus()
	dw_input.SetColumn('fromdt')
	Return -1
End If

If ls_todt = "" Then
	f_msg_info(210, Title, "취소일자")
	dw_input.SetFocus()
	dw_input.SetColumn('todt')
	Return -1
End If

If ls_fromdt > ls_todt Then
	f_msg_usr_err(211, Title, "취소일자")
	dw_input.setfocus()
	dw_input.SetColumn("fromdt")
	return -1
End If

Return 0

end event

event type integer ue_process();call super::ue_process;//프로시저 Call
String ls_fromdt, ls_todt
String ls_errmsg
p2c_dbmgr 	lu_dbmgr
Integer li_rc

lu_dbmgr = Create p2c_dbmgr
lu_dbmgr.is_caller = "p2w_prc_pre_item_cancle"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_input
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
   Return  -1
End If

is_msg_process = String(lu_dbmgr.il_data[1], "#,##0") + " 건"

Destroy lu_dbmgr
Return 0



end event

type p_ok from w_a_prc`p_ok within p2w_prc_pre_item_cancel
integer x = 1339
integer y = 52
end type

type dw_input from w_a_prc`dw_input within p2w_prc_pre_item_cancel
integer x = 59
integer y = 68
integer width = 1179
integer height = 184
string dataobject = "p2dw_cnd_prc_pre_item_cancel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within p2w_prc_pre_item_cancel
integer x = 18
integer y = 796
integer width = 1888
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p2w_prc_pre_item_cancel
integer x = 18
integer y = 332
integer width = 1893
end type

type ln_up from w_a_prc`ln_up within p2w_prc_pre_item_cancel
integer beginx = 18
integer beginy = 316
integer endx = 1769
integer endy = 316
end type

type ln_down from w_a_prc`ln_down within p2w_prc_pre_item_cancel
integer beginx = 18
integer beginy = 1076
integer endx = 1769
integer endy = 1076
end type

type p_close from w_a_prc`p_close within p2w_prc_pre_item_cancel
integer x = 1637
integer y = 52
end type

type gb_cond from w_a_prc`gb_cond within p2w_prc_pre_item_cancel
integer width = 1239
integer height = 272
end type

