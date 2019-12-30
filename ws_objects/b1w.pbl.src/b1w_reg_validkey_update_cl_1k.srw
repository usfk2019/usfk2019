$PBExportHeader$b1w_reg_validkey_update_cl_1k.srw
$PBExportComments$[islim] 인증key 변경/추가-제너 - 킬트
forward
global type b1w_reg_validkey_update_cl_1k from b1w_reg_validkey_update_cl
end type
end forward

global type b1w_reg_validkey_update_cl_1k from b1w_reg_validkey_update_cl
end type
global b1w_reg_validkey_update_cl_1k b1w_reg_validkey_update_cl_1k

on b1w_reg_validkey_update_cl_1k.create
call super::create
end on

on b1w_reg_validkey_update_cl_1k.destroy
call super::destroy
end on

event ue_add();Integer	li_return
String ls_where, ls_validkey, ls_contractseq, ls_itemcod, ls_svctype, ls_svccod
Long ll_row, ll_cnt

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

//ls_validkey = Trim(dw_cond.object.validkey[1])
//If IsNull(ls_validkey) Then ls_validkey = ""
//
//If ls_validkey = "" Then
//	f_msg_info(200, Title, "인증Key")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("validkey")
//	Return
//End If

ls_contractseq = Trim(dw_cond.object.contractseq[1])
If IsNull(ls_contractseq) Then ls_contractseq = ""

If ls_contractseq = "" Then
	f_msg_info(200, Title, "계약 Seq")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Return
End If

//인증Key 후불서비스인지... 상태가. 개통인지... CHECK
iu_check = Create b1u_dbmgr4
iu_check.is_caller = "b1w_reg_validkey_update%ue_add"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_contractseq  		//계약번호
//iu_check.is_data[2] = itemcod       //해당 계약번호에 itemcod
//iu_check.is_data[3] = ls_svctype    //해당 계약번호에 svctype
//iu_check.is_data[4] = ls_status     //해당 계약번호에 status
//iu_check.is_data[5] = priceplan     //해당 계약번호에 priceplan
//iu_check.is_data[6] = ls_svccod     //해당 계약번호에 svccod		
//iu_check.il_data[1]                 //해당 계약번호에 인증KEY 갯수
//iu_check.il_data[2]                 //해당 계약번호에 priceplan의 validkeycnt

//SetPointer(HourGlass!)
iu_check.uf_prc_db_01()
//SetPointer(Arrow!)
If iu_check.ii_rc = -1 Then 
	Destroy iu_check
	Return
end If

If (iu_check.is_data[3] = is_svctype_post) or (iu_check.is_data[3] = is_svctype_pre) Then
Else
	f_msg_info(9000, Title, "후불/선불제서비스 계약만 변경가능!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Destroy iu_check	
	return
End IF

If iu_check.is_data[4] <> is_status Then
	f_msg_info(9000, Title, "개통상태인 계약만 변경가능!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Destroy iu_check	
	return
End IF

If iu_check.il_data[1] >= iu_check.il_data[2] Then
	f_msg_info(9000, Title, "해당 계약Seq에 인증KEY 등록은 " +string(iu_check.il_data[2])+ "개까지 등록 가능합니다."  + '~r~n~r~n' + &
	                        "더이상 인증KEY 등록을 할 수 없습니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Destroy iu_check
	Return
End If

ls_itemcod = iu_check.is_data[2]
ls_svctype = iu_check.is_data[3]
ls_svccod = iu_check.is_data[6]

Destroy iu_check

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "선/후불서비스 인증KEY 추가"
iu_cust_msg.is_grp_name = "선/후불서비스 인증Key 변경/추가"
iu_cust_msg.is_data[1] = ls_itemcod	     //itemcod
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = ls_contractseq      //계약SEQ
iu_cust_msg.is_data[4] = ls_svctype      //서비스타입
iu_cust_msg.is_data[5] = is_status       //개통상태 코드
iu_cust_msg.is_data[6] = ls_svccod       //서비스코드

OpenWithParm(b1w_validkey_update_popup_2_cl_1k, iu_cust_msg)

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_disable")

//dw_cond.Enabled = False
//dw_detail.SetFocus()
end event

event ue_change();Integer	li_return
String ls_where, ls_validkey, ls_svccod, ls_svctype, ls_contractseq
Long ll_row, ll_cnt

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

ls_validkey = Trim(dw_cond.object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_validkey = "" Then
	f_msg_info(200, Title, "인증Key")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey")
	Return
End If

ls_contractseq = Trim(dw_cond.object.contractseq[1])
If IsNull(ls_contractseq) Then ls_contractseq = ""

If ls_contractseq = "" Then
	f_msg_info(200, Title, "계약 Seq")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Return
End If

//인증Key 후불서비스인지... 상태가. 개통인지... CHECK
iu_check = Create b1u_dbmgr4
iu_check.is_caller = "b1w_reg_validkey_update%ue_change"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_validkey     //인증KEY
iu_check.is_data[7] = ls_contractseq
//iu_check.is_data[2] = ls_svctype    //해당 인증KEY의 svctype
//iu_check.is_data[3] = ls_status     //해당 인증KEY의 status
//iu_check.is_data[4] = ls_fromdt     //해당 인증KEY의 Fromdt
//iu_check.is_data[5] = ls_use_yn     //해당 인증KEY의 사용여부
//iu_check.is_data[6] = ls_svccod     //해당 인증KEY의 svccod
		
iu_check.uf_prc_db_01()
If iu_check.ii_rc = -1 Then 
	Destroy iu_check
	Return
end If

If (iu_check.is_data[2] = is_svctype_post) or (iu_check.is_data[2] = is_svctype_pre) Then
Else
	f_msg_info(9000, Title, "후불/선불제서비스 인증Key만 변경가능!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey")
	Destroy iu_check	
	return
End IF

If iu_check.is_data[3] <> is_status Then
	f_msg_info(9000, Title, "개통상태인 인증Key만 변경가능!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey")
	Destroy iu_check	
	return
End IF

If iu_check.is_data[5] <> 'Y' Then
	f_msg_info(9000, Title, "사용여부가 Yes인 인증Key만 변경가능!!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey")
	Destroy iu_check	
	return
End IF

is_fromdt = iu_check.is_data[4]
ls_svccod = iu_check.is_data[6]
ls_svctype = iu_check.is_data[2]

Destroy iu_check

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "선/후불서비스 인증KEY 변경"
iu_cust_msg.is_grp_name = "선/후불서비스 인증Key 변경/추가"
iu_cust_msg.is_data[1] = ls_validkey	     //validkey
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = is_fromdt           //fromdt
iu_cust_msg.is_data[4] = ls_svccod           //svccod
iu_cust_msg.is_data[5] = ls_svctype          //svctype

OpenWithParm(b1w_validkey_update_popup_1_cl_1k, iu_cust_msg)

//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//p_ok.TriggerEvent("ue_disable")
//dw_cond.Enabled = False
//dw_detail.SetFocus()
end event

event ue_term();String   ls_validkey, ls_contractseq


If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

ls_validkey = Trim(dw_cond.object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_validkey = "" Then
	f_msg_info(200, Title, "인증Key")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey")
	Return
End If


ls_contractseq = Trim(dw_cond.object.contractseq[1])
If IsNull(ls_contractseq) Then ls_contractseq = ""

If ls_contractseq = "" Then
	f_msg_info(200, Title, "계약 Seq")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Return
End If

//인증Key 후불서비스인지
iu_check = Create b1u_dbmgr4
iu_check.is_caller = "b1w_reg_validkey_term"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_validkey     //인증KEY
//is_data[2] = is_fromdt
iu_check.is_data[3] = ls_contractseq  //계약 SEq     

iu_check.uf_prc_db_03()

If iu_check.ii_rc = -1 Then 
	Destroy iu_check
	Return
end If

is_fromdt = iu_check.is_data[2]

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "선/후불서비스 인증KEY 해지"
iu_cust_msg.is_grp_name = "선/후불서비스 인증Key 변경/추가"
iu_cust_msg.is_data[1] = ls_validkey	     //validkey
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = is_fromdt           //fromdt
iu_cust_msg.is_data[4] = ls_contractseq      //contractseq
iu_cust_msg.is_data[5] = iu_check.is_data[4]            //서비스 Type


OpenWithParm(b1w_validkey_update_popup_3_cl_1k, iu_cust_msg)


end event

type dw_cond from b1w_reg_validkey_update_cl`dw_cond within b1w_reg_validkey_update_cl_1k
end type

type p_ok from b1w_reg_validkey_update_cl`p_ok within b1w_reg_validkey_update_cl_1k
end type

type p_close from b1w_reg_validkey_update_cl`p_close within b1w_reg_validkey_update_cl_1k
end type

type gb_cond from b1w_reg_validkey_update_cl`gb_cond within b1w_reg_validkey_update_cl_1k
end type

type p_delete from b1w_reg_validkey_update_cl`p_delete within b1w_reg_validkey_update_cl_1k
end type

type p_insert from b1w_reg_validkey_update_cl`p_insert within b1w_reg_validkey_update_cl_1k
end type

type p_save from b1w_reg_validkey_update_cl`p_save within b1w_reg_validkey_update_cl_1k
end type

type dw_detail from b1w_reg_validkey_update_cl`dw_detail within b1w_reg_validkey_update_cl_1k
end type

type p_reset from b1w_reg_validkey_update_cl`p_reset within b1w_reg_validkey_update_cl_1k
end type

type p_change from b1w_reg_validkey_update_cl`p_change within b1w_reg_validkey_update_cl_1k
end type

type p_add from b1w_reg_validkey_update_cl`p_add within b1w_reg_validkey_update_cl_1k
end type

type p_term from b1w_reg_validkey_update_cl`p_term within b1w_reg_validkey_update_cl_1k
end type

