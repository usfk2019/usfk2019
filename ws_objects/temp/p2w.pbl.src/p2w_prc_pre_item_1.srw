﻿$PBExportHeader$p2w_prc_pre_item_1.srw
$PBExportComments$[ceusee] 선불카드 매출 실적(p_refilllog)
forward
global type p2w_prc_pre_item_1 from w_a_prc
end type
end forward

global type p2w_prc_pre_item_1 from w_a_prc
integer width = 1957
integer height = 1216
end type
global p2w_prc_pre_item_1 p2w_prc_pre_item_1

type variables
String ls_test
end variables

on p2w_prc_pre_item_1.create
call super::create
end on

on p2w_prc_pre_item_1.destroy
call super::destroy
end on

event open;call super::open;Integer li_return
Date ld_fromdt
String ls_ref_content, ls_ref_desc, ls_temp


iu_cust_msg = create u_cust_a_msg 
ls_temp = fs_get_control("S1", "S103", ls_ref_desc)

dw_input.Object.fromdt[1] = fd_date_next(Date(String(ls_temp, "@@@@-@@-@@")), 1)
dw_input.object.todt[1] = Date(fdt_get_dbserver_now())
end event

event type integer ue_input();call super::ue_input;String ls_fromdt, ls_todt

ls_fromdt = String(dw_input.Object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_input.Object.todt[1],'yyyymmdd')

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

If ls_fromdt = "" Then
	f_msg_info(210, Title, "생성일자")
	dw_input.SetFocus()
	dw_input.SetColumn('fromdt')
	Return -1
End If

If ls_todt = "" Then
	f_msg_info(210, Title, "생성일자")
	dw_input.SetFocus()
	dw_input.SetColumn('todt')
	Return -1
End If

If ls_fromdt > ls_todt Then
	f_msg_usr_err(211, Title, "생성일자")
	dw_input.setfocus()
	dw_input.SetColumn("todt")
	return -1
End If

Return 0

end event

event type integer ue_process();call super::ue_process;//프로시저 Call
String ls_fromdt, ls_todt,ls_pgm_id
String ls_errmsg
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)


ls_fromdt = String(dw_input.Object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_input.object.todt[1], 'yyyymmdd')

//처리부분...
//subroutine APPENDITEMSALE_PRE_BILCDR(string P_YYYYMMDD_FR,string P_YYYYMMDD_TO,string P_VALIDKEY,
//string P_USER, ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"HKTEL~".~"APPENDITEMSALE_PRE_BILCDR~""
SQLCA.AppendItemsale_P_Refill(ls_fromdt, ls_todt,gs_user_id, ll_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	
End If

If ll_return <> 0 Then	Return -1

If IsNull(lb_count) Then lb_count = 0
	
is_msg_process = String(lb_count, "#,##0") + " 건"

Return 0



end event

type p_ok from w_a_prc`p_ok within p2w_prc_pre_item_1
integer x = 1339
integer y = 52
end type

type dw_input from w_a_prc`dw_input within p2w_prc_pre_item_1
integer x = 46
integer y = 72
integer width = 1179
integer height = 172
string dataobject = "p2dw_cnd_prc_pre_item"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within p2w_prc_pre_item_1
integer x = 18
integer y = 796
integer width = 1888
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p2w_prc_pre_item_1
integer x = 18
integer y = 332
integer width = 1893
end type

type ln_up from w_a_prc`ln_up within p2w_prc_pre_item_1
integer beginx = 18
integer beginy = 316
integer endx = 1769
integer endy = 316
end type

type ln_down from w_a_prc`ln_down within p2w_prc_pre_item_1
integer beginx = 18
integer beginy = 1076
integer endx = 1769
integer endy = 1076
end type

type p_close from w_a_prc`p_close within p2w_prc_pre_item_1
integer x = 1637
integer y = 52
end type

type gb_cond from w_a_prc`gb_cond within p2w_prc_pre_item_1
integer width = 1239
integer height = 272
end type

