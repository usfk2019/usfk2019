﻿$PBExportHeader$s1w_prc_crt_customercnt_v20.srw
$PBExportComments$[ohj]판매실적고객 v20
forward
global type s1w_prc_crt_customercnt_v20 from w_a_prc
end type
end forward

global type s1w_prc_crt_customercnt_v20 from w_a_prc
integer width = 1947
integer height = 1216
end type
global s1w_prc_crt_customercnt_v20 s1w_prc_crt_customercnt_v20

type variables
String ls_test, is_last_date
end variables

on s1w_prc_crt_customercnt_v20.create
call super::create
end on

on s1w_prc_crt_customercnt_v20.destroy
call super::destroy
end on

event open;call super::open;Integer li_return
String ls_ref_content, ls_ref_desc, ls_temp, ls_return[]
Date ld_bildt, ld_bildt_ctl

iu_cust_msg = create u_cust_a_msg 

ls_ref_desc = ""
is_last_date = fs_get_control("S1", "S100", ls_ref_desc)

dw_input.Object.dtsale_fr[1] = fd_date_next(date(string(is_last_date, '@@@@-@@-@@')),1)
dw_input.Object.dtsale[1]    = fd_date_next(date(string(is_last_date, '@@@@-@@-@@')),1)

end event

event type integer ue_input();call super::ue_input;String ls_dtsale, ls_dtsale_fr, ls_sysdate

ls_dtsale_fr = String(dw_input.Object.dtsale_fr[1],'yyyymmdd')
ls_dtsale    = String(dw_input.Object.dtsale[1],'yyyymmdd')
ls_sysdate   = string(date(fdt_get_dbserver_now()), 'yyyymmdd')

If IsNull(ls_dtsale_fr) Then ls_dtsale_fr = ""
If IsNull(ls_dtsale)    Then ls_dtsale    = ""

If ls_dtsale = "" Then
	f_msg_info(9000, Title, "생성구간을 입력하십시오.")
	dw_input.SetFocus()
	dw_input.SetColumn('dtsale')
	Return -1
End If

If ls_dtsale_fr > ls_dtsale or ls_dtsale >= ls_sysdate Then
	f_msg_info(9000, This.Title, "일자(To)를 확인하세요")
	dw_input.SetFocus()
   dw_input.SetColumn("dtsale")
	Return -1
End If

Return 0

end event

event type integer ue_process();call super::ue_process;//프로시저 Call
String ls_dtsale,ls_pgm_id
String ls_errmsg
double lb_return
double lb_count

lb_return = -1
ls_errmsg = space(256)


ls_dtsale = String(dw_input.Object.dtsale[1],'yyyymmdd')

//subroutine S1W_PRC_CRT_CUSTOMERCNT(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"S1W_PRC_CRT_CUSTOMERCNT~""
//처리부분...
SQLCA.S1W_PRC_CRT_CUSTOMERCNT(ls_dtsale,gs_user_id, gs_pgm_id[1], lb_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	lb_return = -1

ElseIf lb_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	
End If

If lb_return <> 0 Then	Return -1

If IsNull(lb_count) Then lb_count = 0
	
is_msg_process = String(lb_count, "#,##0") + "건"

Return 0



end event

type p_ok from w_a_prc`p_ok within s1w_prc_crt_customercnt_v20
integer x = 1326
integer y = 96
end type

type dw_input from w_a_prc`dw_input within s1w_prc_crt_customercnt_v20
integer x = 46
integer y = 60
integer width = 1221
integer height = 192
string dataobject = "s1dw_cnd_prc_customercnt_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within s1w_prc_crt_customercnt_v20
integer x = 18
integer y = 796
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within s1w_prc_crt_customercnt_v20
integer x = 18
integer y = 332
end type

type ln_up from w_a_prc`ln_up within s1w_prc_crt_customercnt_v20
integer beginx = 18
integer beginy = 316
integer endx = 1769
integer endy = 316
end type

type ln_down from w_a_prc`ln_down within s1w_prc_crt_customercnt_v20
integer beginx = 18
integer beginy = 1076
integer endx = 1769
integer endy = 1076
end type

type p_close from w_a_prc`p_close within s1w_prc_crt_customercnt_v20
integer x = 1618
integer y = 96
end type

type gb_cond from w_a_prc`gb_cond within s1w_prc_crt_customercnt_v20
integer width = 1266
integer height = 272
end type

