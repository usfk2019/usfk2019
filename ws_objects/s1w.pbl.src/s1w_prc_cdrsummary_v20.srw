$PBExportHeader$s1w_prc_cdrsummary_v20.srw
$PBExportComments$[ohj]통화량실적Summary, Summary2 선/후불 v20
forward
global type s1w_prc_cdrsummary_v20 from w_a_prc
end type
end forward

global type s1w_prc_cdrsummary_v20 from w_a_prc
integer width = 2034
integer height = 1228
end type
global s1w_prc_cdrsummary_v20 s1w_prc_cdrsummary_v20

type variables
String ls_test, is_pre, is_post ,is_yyyymmdd_post, is_yyyymmdd_pre
end variables

on s1w_prc_cdrsummary_v20.create
call super::create
end on

on s1w_prc_cdrsummary_v20.destroy
call super::destroy
end on

event open;call super::open;Integer li_return
String ls_ref_content, ls_ref_desc, ls_temp, ls_return[]
Date ld_bildt, ld_bildt_ctl

iu_cust_msg = create u_cust_a_msg 

String ls_module, ls_ref_no, ls_date[]
String ls_yyyymmdd

ls_temp = ""
ls_temp = fs_get_control('S1', 'S102', ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_date[])
is_yyyymmdd_pre =  ls_date[1]

ls_temp = ""
ls_temp = fs_get_control('S1', 'S108', ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_date[])
is_yyyymmdd_post =  ls_date[1]

is_pre  = fs_get_control("B0", "P101", ls_ref_desc)//선불제  0
is_post = fs_get_control("B0", "P102", ls_ref_desc)//후불제  1

dw_input.Object.dtfrom[1] = fd_date_next(Date(String(is_yyyymmdd_post, "@@@@-@@-@@")), 1)
dw_input.Object.dtto[1]   = fd_date_next(Date(String(is_yyyymmdd_post, "@@@@-@@-@@")), 1)

end event

event type integer ue_input();call super::ue_input;String ls_dtfrom, ls_dtto,ls_sysdate
ls_sysdate = string(date(fdt_get_dbserver_now()), "yyyymmdd") 
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

If ls_dtto >= ls_sysdate Then
	f_msg_info(9000, Title, "작업일자(TO)는 오늘 날짜보다 작아야 합니다..")
	dw_input.SetFocus()
	dw_input.SetColumn('dtto')
	Return -1
End If


Return 0

end event

event type integer ue_process();call super::ue_process;String ls_dtfrom, ls_dtto, ls_svctype
String ls_errmsg
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)

ls_dtfrom  = String(dw_input.Object.dtfrom[1],'yyyymmdd')
ls_dtto    = String(dw_input.Object.dtto[1],'yyyymmdd')
ls_svctype = dw_input.Object.svctype[1]

//처리부분...
If ls_svctype = is_post Then
	SQLCA.S1CDRSUMPOST_CDRSUMMARY_V2(ls_dtto, 1000, 100, ll_return,ls_errmsg,lb_count)
Else
	SQLCA.S1CDRSUMPRE_CDRSUMMARY_V2(ls_dtto, 1000, 100, ll_return,ls_errmsg,lb_count)
End If
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

type p_ok from w_a_prc`p_ok within s1w_prc_cdrsummary_v20
integer x = 1381
integer y = 56
end type

type dw_input from w_a_prc`dw_input within s1w_prc_cdrsummary_v20
integer x = 41
integer y = 72
integer width = 1216
integer height = 172
string dataobject = "s1dw_CdrSummary_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::itemchanged;call super::itemchanged;Long ll_row
String ls_filter, ls_itemcod

If dwo.name = "svctype" Then
	
	If data = "1" Then
		dw_input.Object.dtfrom[1] = fd_date_next(Date(String(is_yyyymmdd_post, "@@@@-@@-@@")), 1)
		dw_input.Object.dtto[1]   = fd_date_next(Date(String(is_yyyymmdd_post, "@@@@-@@-@@")), 1)
	
	ElseIf data = "0" Then
		dw_input.Object.dtfrom[1] = fd_date_next(Date(String(is_yyyymmdd_pre, "@@@@-@@-@@")), 1)
		dw_input.Object.dtto[1]   = fd_date_next(Date(String(is_yyyymmdd_pre, "@@@@-@@-@@")), 1)
   End If
	
End If

end event

type dw_msg_time from w_a_prc`dw_msg_time within s1w_prc_cdrsummary_v20
integer x = 18
integer y = 828
integer width = 1957
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within s1w_prc_cdrsummary_v20
integer x = 18
integer y = 364
integer width = 1957
end type

type ln_up from w_a_prc`ln_up within s1w_prc_cdrsummary_v20
integer beginx = 18
integer beginy = 344
integer endx = 1769
integer endy = 344
end type

type ln_down from w_a_prc`ln_down within s1w_prc_cdrsummary_v20
integer beginx = 18
integer beginy = 1108
integer endx = 1769
integer endy = 1108
end type

type p_close from w_a_prc`p_close within s1w_prc_cdrsummary_v20
integer x = 1696
integer y = 56
end type

type gb_cond from w_a_prc`gb_cond within s1w_prc_cdrsummary_v20
integer width = 1275
integer height = 308
end type

