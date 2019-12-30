$PBExportHeader$e01w_reg_select_dly.srw
$PBExportComments$[parkkh] 연체대상자추출
forward
global type e01w_reg_select_dly from w_a_reg_m_sql
end type
end forward

global type e01w_reg_select_dly from w_a_reg_m_sql
integer width = 2043
integer height = 1400
end type
global e01w_reg_select_dly e01w_reg_select_dly

type variables

end variables

on e01w_reg_select_dly.create
call super::create
end on

on e01w_reg_select_dly.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;///////////////////////////
// SAVE시 PROCEDURE 호출
//////////////////////////

Long 		ll_row
String 	ls_where 
Integer 	li_delay_months, 		li_delay_months_to

li_delay_months 		= dw_cond.Object.delay_months[1]
If li_delay_months = 0 Then SetNull(li_delay_months)

li_delay_months_to 	= dw_cond.Object.delay_months_to[1]
If li_delay_months_to = 0 Then 	SetNull(li_delay_months_to)

If Not IsNull(li_delay_months) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " bil.overdue_MONTHS >= " + String(li_delay_months) + " " 
End If

If Not IsNull(li_delay_months_to) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " bil.overdue_MONTHS <= " + String(li_delay_months_to) + " " 
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If


end event

event open;call super::open;String ls_module, ls_ref_no, ls_ref_desc
String ls_std_mon

ls_module 		= "E2"
ls_ref_no 		= "A102" 
ls_ref_desc 	= ""
ls_std_mon 		= fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
If IsNull(ls_std_mon) Then ls_std_mon = ""

dw_cond.Object.std_mon[1] = ls_std_mon

end event

event type integer ue_save_sql();call super::ue_save_sql;Integer li_return
Long ll_return, ll_dly_mfr, ll_dly_mto
String ls_errmsg, ls_stddt
Double lb_count

li_return = MessageBox(Title, "해당 연체개월에 포함된 고객을 연체대상자로 추출합니다.~r" + &
                              "계속하시겠습니까?", Question!, YesNo!, 1)
If li_return <> 1 Then Return -1						

SetPointer(HourGlass!)

ll_dly_mfr 	= dw_cond.Object.delay_months[1]
ll_dly_mto 	= dw_cond.Object.delay_months_to[1]
ls_stddt 	= Trim(dw_cond.Object.std_mon[1])

If IsNull(String(ll_dly_mfr)) Then ll_dly_mfr 	= 0
If IsNull(String(ll_dly_mto)) Then ll_dly_mto 	= 999
If IsNull(ls_stddt) 				Then ls_stddt 		= ""

ll_return = -1
ls_errmsg = space(256)

// 처리부분...
//subroutine E01_SELECT_DLY(long P_DELAYM_FR,long P_DELAYM_TO,string P_PGM_ID,string P_USER_ID,string P_STDMONTH,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"ANYUSERJ~".~"E01_SELECT_DLY~""
SQLCA.e01_select_dly(ll_dly_mfr, ll_dly_mto, gs_pgm_id[gi_open_win_no], gs_user_id,ls_stddt, ll_return, ls_errmsg, lb_count)

SetPointer(Arrow!)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

If ll_return <> 0 Then	//실패
	f_msg_usr_err(9000, Title, "처리도중 Error 발생")
	Return -1
Else				//성공
   MessageBox(This.Title, "처리가 정상적으로 종료되었습니다(추출건수 : " + String(lb_count, "#,##0") + ").")
	Return 0
End If

end event

event ue_save();call super::ue_save;Return
end event

type dw_cond from w_a_reg_m_sql`dw_cond within e01w_reg_select_dly
integer x = 41
integer width = 1010
integer height = 224
string dataobject = "e01d_cnd_reg_select_dly"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_sql`p_ok within e01w_reg_select_dly
integer x = 1097
integer y = 44
end type

type p_close from w_a_reg_m_sql`p_close within e01w_reg_select_dly
integer x = 1691
integer y = 44
end type

type gb_cond from w_a_reg_m_sql`gb_cond within e01w_reg_select_dly
integer width = 1033
integer height = 280
end type

type p_save from w_a_reg_m_sql`p_save within e01w_reg_select_dly
integer x = 1394
integer y = 44
end type

type dw_detail from w_a_reg_m_sql`dw_detail within e01w_reg_select_dly
integer y = 292
integer width = 1943
integer height = 984
string dataobject = "e01d_reg_select_dly"
end type

event dw_detail::ue_init;ib_sort_use = False
end event

