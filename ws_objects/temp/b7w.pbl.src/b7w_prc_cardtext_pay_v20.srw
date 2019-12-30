$PBExportHeader$b7w_prc_cardtext_pay_v20.srw
$PBExportComments$[jsha] 신용카드 입금처리
forward
global type b7w_prc_cardtext_pay_v20 from w_a_inq_m_m
end type
type cb_pay from commandbutton within b7w_prc_cardtext_pay_v20
end type
end forward

global type b7w_prc_cardtext_pay_v20 from w_a_inq_m_m
integer height = 1268
event ue_process ( )
cb_pay cb_pay
end type
global b7w_prc_cardtext_pay_v20 b7w_prc_cardtext_pay_v20

event ue_process();String ls_errmsg, ls_pgm_id
String ls_temp, ls_ref_desc, ls_pay_type[], ls_paytype
Double lb_count
Long  ll_return, ll_workno, ll_row
Int    li_cnt

ll_row = dw_master.GetRow()
If ll_row <= 0 Then Return

ll_workno = dw_master.Object.workno[ll_row]
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ll_return = -1

//입금유형(REQDTL:PAYTYPE)
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_pay_type[])
ls_paytype = ls_pay_type[4]

//입금유형- Card type
If IsNull(ls_paytype) Or ls_paytype = "" Then Return 

// Procedure Call
SQLCA.B7CARDREQPAY(ll_workno, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

//지로 입금 처리
SQLCA.B5REQPAY2DTL_NOSEQ(ls_paytype, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 

ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	f_msg_info(3000, Title, "입금TR생성이 되지 않았습니다.")
	Return 
Else							//성공
	f_msg_info(3000, Title, "신용카드 입금 처리 반영(건수 : " + String(lb_count)+ ")")
	Return
End If

end event

on b7w_prc_cardtext_pay_v20.create
int iCurrent
call super::create
this.cb_pay=create cb_pay
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_pay
end on

on b7w_prc_cardtext_pay_v20.destroy
call super::destroy
destroy(this.cb_pay)
end on

event ue_ok();call super::ue_ok;String ls_where, ls_status, ls_ref_desc, ls_temp, ls_result[]
Long ll_row
Int li_return

ls_temp = fs_get_control("B7", "C100", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])
ls_status = ls_result[4]

ls_where = " a.status = '" + ls_status + "' "
dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If
end event

type dw_cond from w_a_inq_m_m`dw_cond within b7w_prc_cardtext_pay_v20
boolean visible = false
end type

type p_ok from w_a_inq_m_m`p_ok within b7w_prc_cardtext_pay_v20
boolean visible = false
end type

type p_close from w_a_inq_m_m`p_close within b7w_prc_cardtext_pay_v20
integer x = 512
integer y = 1036
end type

type gb_cond from w_a_inq_m_m`gb_cond within b7w_prc_cardtext_pay_v20
boolean visible = false
end type

type dw_master from w_a_inq_m_m`dw_master within b7w_prc_cardtext_pay_v20
integer x = 37
integer y = 24
string dataobject = "b7dw_m_prc_cardtext_pay_v20"
end type

type dw_detail from w_a_inq_m_m`dw_detail within b7w_prc_cardtext_pay_v20
integer x = 37
integer y = 460
integer height = 528
end type

type st_horizontal from w_a_inq_m_m`st_horizontal within b7w_prc_cardtext_pay_v20
integer y = 428
end type

type cb_pay from commandbutton within b7w_prc_cardtext_pay_v20
integer x = 46
integer y = 1028
integer width = 425
integer height = 104
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "입금처리"
end type

event clicked;Parent.TriggerEvent('ue_process')
end event

