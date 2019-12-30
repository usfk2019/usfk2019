$PBExportHeader$b1w_validkey_update_popup_3_cl_1k.srw
$PBExportComments$[islim] 인증 Key 해지(X1) - 킬트
forward
global type b1w_validkey_update_popup_3_cl_1k from b1w_validkey_update_popup_3_cl
end type
end forward

global type b1w_validkey_update_popup_3_cl_1k from b1w_validkey_update_popup_3_cl
end type
global b1w_validkey_update_popup_3_cl_1k b1w_validkey_update_popup_3_cl_1k

on b1w_validkey_update_popup_3_cl_1k.create
call super::create
end on

on b1w_validkey_update_popup_3_cl_1k.destroy
call super::destroy
end on

event open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_3
	Desc	: 인증KEY 해지
	Ver	: 	1.0
	Date	: 	2003.09.25
	Programer : ceusee
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]

Call w_base::Open

f_center_window(b1w_validkey_update_popup_3_cl_1k)
is_validkey = ""
is_fromdt = ""

//iu_cust_msg.is_data[1] = ls_validkey	     //validkey
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = is_fromdt           //fromdt

iu_cust_msg = Message.PowerObjectParm
is_validkey = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]
is_contractseq = iu_cust_msg.is_data[4]
is_svctype = iu_cust_msg.is_data[5]

If is_validkey <> "" Then
	Post Event ue_ok()
End If
end event

type p_save from b1w_validkey_update_popup_3_cl`p_save within b1w_validkey_update_popup_3_cl_1k
end type

type p_close from b1w_validkey_update_popup_3_cl`p_close within b1w_validkey_update_popup_3_cl_1k
end type

type dw_detail from b1w_validkey_update_popup_3_cl`dw_detail within b1w_validkey_update_popup_3_cl_1k
end type

event dw_detail::retrieveend;call super::retrieveend;Long ll_i
String validitem3_t, ls_svccod

dw_detail.AcceptText()

ll_i=dw_detail.rowcount()


ls_svccod=LeftA(dw_detail.object.svccod[ll_i], 2)

If ll_i = 1 Then
	If ls_svccod= "X2" Then			//로밍플라이-랜드서비스
		dw_detail.object.validitem3_t.text="접속번호"
		dw_detail.object.t_4.text=""
	ElseIf ls_svccod= "X3"	Then		//로밍플라이-모바일
		dw_detail.object.validitem3_t.text="착신지번호"
		dw_detail.object.t_4.text=""
	End If
Else
	return -1
End If
end event

type ln_2 from b1w_validkey_update_popup_3_cl`ln_2 within b1w_validkey_update_popup_3_cl_1k
end type

