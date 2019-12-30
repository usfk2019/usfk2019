$PBExportHeader$s2w_prc_voice_tong1.srw
$PBExportComments$[ysbyun]통화량실적Summary1
forward
global type s2w_prc_voice_tong1 from w_a_prc
end type
end forward

global type s2w_prc_voice_tong1 from w_a_prc
integer width = 2034
integer height = 1228
end type
global s2w_prc_voice_tong1 s2w_prc_voice_tong1

type variables
String ls_test
end variables

on s2w_prc_voice_tong1.create
call super::create
end on

on s2w_prc_voice_tong1.destroy
call super::destroy
end on

event open;call super::open;Integer li_return
String ls_ref_content, ls_ref_desc, ls_temp, ls_return[]
Date ld_bildt, ld_bildt_ctl

iu_cust_msg = create u_cust_a_msg 

//발생월
ls_ref_content = fs_get_control('S1', 'S102', ls_ref_desc)
If IsNull(ls_ref_content) Then Return

dw_input.Object.dtfrom[1] = fd_date_next(Date(String(ls_ref_content, "@@@@-@@-@@")), 1)
dw_input.Object.dtto[1]   = fd_date_pre(Date(fdt_get_dbserver_now()), 1)

end event

event type integer ue_input();call super::ue_input;String ls_dtfrom, ls_dtto

ls_dtfrom = String(dw_input.Object.dtfrom[1],'yyyymmdd')
ls_dtto   = String(dw_input.Object.dtto[1],'yyyymmdd')

If IsNull(ls_dtfrom) Then ls_dtfrom = ""
If IsNull(ls_dtto) Then ls_dtto = ""

If ls_dtto = "" Then
	f_msg_info(9000, Title, "생성구간을 입력하십시오.")
	dw_input.SetFocus()
	dw_input.SetColumn('dtto')
	Return -1
End If

If ls_dtfrom > ls_dtto Then
	f_msg_info(9000, Title, "구간이 잘못입력되었습니다.")
	dw_input.SetFocus()
	dw_input.SetColumn('dtto')
	Return -1
End If

If ls_dtto >= String(fdt_get_dbserver_now(),'yyyymmdd') Then
	f_msg_info(9000, Title, "작업일자(TO)는 오늘 날짜보다 작아야 합니다..")
	dw_input.SetFocus()
	dw_input.SetColumn('dtto')
	Return -1
End If


Return 0

end event

event type integer ue_process();call super::ue_process;String ls_dtfrom, ls_dtto, ls_pgm_id
String ls_errmsg
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)


ls_dtfrom = String(dw_input.Object.dtfrom[1],'yyyymmdd')
ls_dtto   = String(dw_input.Object.dtto[1],'yyyymmdd')

//처리부분...
SQLCA.S1W_PRC_VOICE_TONG1(ls_dtfrom,ls_dtto, gs_pgm_id[1], gs_user_id, ll_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	 
End If

If ll_return <> 0 Then	Return -1

If IsNull(lb_count) Then lb_count = 0
	
is_msg_process = String(lb_count, "#,##0") + "건"

Return 0

end event

type p_ok from w_a_prc`p_ok within s2w_prc_voice_tong1
integer x = 1381
integer y = 56
end type

type dw_input from w_a_prc`dw_input within s2w_prc_voice_tong1
integer x = 41
integer y = 72
integer width = 1216
integer height = 172
string dataobject = "s2dw_cnd_prc_voice_tong1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within s2w_prc_voice_tong1
integer x = 18
integer y = 828
integer width = 1957
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within s2w_prc_voice_tong1
integer x = 18
integer y = 364
integer width = 1957
end type

type ln_up from w_a_prc`ln_up within s2w_prc_voice_tong1
integer beginx = 18
integer beginy = 344
integer endx = 1769
integer endy = 344
end type

type ln_down from w_a_prc`ln_down within s2w_prc_voice_tong1
integer beginx = 18
integer beginy = 1108
integer endx = 1769
integer endy = 1108
end type

type p_close from w_a_prc`p_close within s2w_prc_voice_tong1
integer x = 1696
integer y = 56
end type

type gb_cond from w_a_prc`gb_cond within s2w_prc_voice_tong1
integer width = 1275
integer height = 308
end type

