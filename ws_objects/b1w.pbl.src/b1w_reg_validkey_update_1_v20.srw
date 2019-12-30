$PBExportHeader$b1w_reg_validkey_update_1_v20.srw
$PBExportComments$[ohj] 인증key 변경/추가/해지 v20
forward
global type b1w_reg_validkey_update_1_v20 from w_a_reg_m
end type
type p_change from u_p_change within b1w_reg_validkey_update_1_v20
end type
type p_add from u_p_add within b1w_reg_validkey_update_1_v20
end type
type p_term from u_p_term within b1w_reg_validkey_update_1_v20
end type
end forward

global type b1w_reg_validkey_update_1_v20 from w_a_reg_m
integer width = 2519
integer height = 476
string title = ""
windowstate windowstate = normal!
event ue_change ( )
event ue_add ( )
event ue_term ( )
p_change p_change
p_add p_add
p_term p_term
end type
global b1w_reg_validkey_update_1_v20 b1w_reg_validkey_update_1_v20

type variables
String is_fromdt, is_validkey, is_status
String is_svctype_post, is_svctype_pre 
b1u_dbmgr1_v20 iu_check


end variables

event ue_change;Integer	li_return, li_ing_validkey
String ls_where, ls_validkey, ls_svccod, ls_svctype, ls_contractseq
Long ll_row, ll_cnt, ll_seq
string ls_itemcod, ls_addition_code,ls_callforward_yn,ls_callforwardno, ls_password
date ld_item_todt


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

//인증Key 선/후불서비스인지... 상태가. 개통인지... CHECK
iu_check = Create b1u_dbmgr1_v20
iu_check.is_caller = "b1w_reg_validkey_update_1_v20%ue_change"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_validkey     //인증KEY
iu_check.is_data[7] = ls_contractseq
//iu_check.is_data[2] = ls_svctype    //해당 인증KEY의 svctype
//iu_check.is_data[3] = ls_status     //해당 인증KEY의 status
//iu_check.is_data[4] = ls_fromdt     //해당 인증KEY의 Fromdt
//iu_check.is_data[5] = ls_use_yn     //해당 인증KEY의 사용여부
//iu_check.is_data[6] = ls_svccod     //해당 인증KEY의 svccod
//iu_check.is_data[8] = ls_itemcod                //착신전환부가서비스품목
//iu_check.is_data[9] = ls_addition_code          //착신전환부가서비스코드
//iu_check.is_data[10] = ls_callforward_yn        //착신전환부가서비스여부
//iu_check.is_data[11] = ls_callforwardno         //착신전환번호
//iu_check.is_data[12] = ls_passwordo             //착신전환password
//iu_check.il_data[1]  = ll_seq                   //착신전환정보 seq
//iu_check.id_data[1] = ld_item_todt              //착신전환부가서비스품목 todt
		
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
ls_itemcod = iu_check.is_data[8]
ls_addition_code = iu_check.is_data[9]
ls_callforward_yn = iu_check.is_data[10]
ls_callforwardno = iu_check.is_data[11]
ls_password = iu_check.is_data[12]
ll_seq = iu_check.il_data[1]
ld_item_todt = iu_check.id_data[1]

//변경전 번호가 기신청중인 번호인지 체크 Start by HMK
select count(*) into :li_ing_validkey
from validinfo_change
where validkey = :ls_validkey
  and to_char(fromdt,'yyyymmdd') >= :is_fromdt
  and change_type = '0' //'변경전(OLD)'
  using SQLCA;

if li_ing_validkey > 0 then
		f_msg_info(9000, Title, ls_validkey + " 은 이미 번호변경 신청중인 번호입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("validkey")
		Destroy iu_check	
		return
end if
//End by HMK

Destroy iu_check

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "선/후불서비스 인증KEY 변경"
iu_cust_msg.is_grp_name = "선/후불서비스 인증Key 변경/추가"
iu_cust_msg.is_data[1] = ls_validkey	     //validkey
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
iu_cust_msg.is_data[3] = is_fromdt           //fromdt
iu_cust_msg.is_data[4] = ls_svccod           //svccod
iu_cust_msg.is_data[5] = ls_svctype          //svctype
iu_cust_msg.is_data[6] = ls_contractseq      //계약번호
iu_cust_msg.is_data[7] = ls_itemcod               //착신전환부가서비스품목
iu_cust_msg.is_data[8] = ls_addition_code         //착신전환부가서비스코드
iu_cust_msg.is_data[9] = ls_callforward_yn        //착신전환부가서비스여부
iu_cust_msg.is_data[10] = ls_callforwardno        //착신전환번호
iu_cust_msg.is_data[11] = ls_password             //착신전환Password
iu_cust_msg.il_data[1]  = ll_seq                  //착신전환정보 seq
iu_cust_msg.id_data[1] = ld_item_todt             //착신전환부가서비스품목 todt

OpenWithParm(b1w_validkey_update_popup_1_1_v20, iu_cust_msg)

//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//p_ok.TriggerEvent("ue_disable")
//dw_cond.Enabled = False
//dw_detail.SetFocus()
end event

event ue_add();Integer	li_return
String ls_where, ls_validkey, ls_contractseq, ls_itemcod, ls_svctype, ls_svccod
Long ll_row, ll_cnt
String ls_addition_code,ls_callforward_yn
Date ld_item_todt

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

//인증Key 후불/선불제서비스인지... 상태가. 개통인지... CHECK
iu_check = Create b1u_dbmgr1_v20
iu_check.is_caller = "b1w_reg_validkey_update_1_v20%ue_add"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_contractseq  		//계약번호
//iu_check.is_data[3] = ls_svctype    //해당 계약번호에 svctype
//iu_check.is_data[4] = ls_status     //해당 계약번호에 status
//iu_check.is_data[5] = priceplan     //해당 계약번호에 priceplan
//iu_check.is_data[6] = ls_svccod     //해당 계약번호에 svccod		
//iu_check.il_data[1]                 //해당 계약번호에 인증KEY 갯수
//iu_check.il_data[2]                 //해당 계약번호에 priceplan의 validkeycnt
//iu_check.is_data[7] = ls_itemcod               //착신전환부가서비스품목
//iu_check.is_data[8] = ls_addition_code         //착신전환부가서비스유형
//iu_check.is_data[9] = ls_callforward_yn        //착신전환부가서비스여부
//iu_check.id_data[1] = ld_item_todt             //착신전환부가서비스품목 todt

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

ls_svctype = iu_check.is_data[3]
ls_svccod  = iu_check.is_data[6]
ls_itemcod = iu_check.is_data[7]
ls_addition_code = iu_check.is_data[8]
ls_callforward_yn = iu_check.is_data[9]
ld_item_todt = iu_check.id_data[1]

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
iu_cust_msg.is_data[7] = ls_itemcod         //착신전환부가서비스품목
iu_cust_msg.is_data[8] = ls_addition_code   //착신전환부가서비스유형
iu_cust_msg.is_data[9] = ls_callforward_yn  //착신전환부가서비스여부
iu_cust_msg.id_data[1] = ld_item_todt       //착신전환부가서비스품목 todt

OpenWithParm(b1w_validkey_update_popup_2_1_v20, iu_cust_msg)

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_disable")

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
iu_check = Create b1u_dbmgr1_v20
iu_check.is_caller = "b1w_reg_validkey_update_1_v20%ue_term"
iu_check.is_title = This.Title
iu_check.idw_data[1] = dw_cond
iu_check.is_data[1] = ls_validkey     //인증KEY
//is_data[2] = is_fromdt
iu_check.is_data[5] = ls_contractseq  //계약 SEq     

iu_check.uf_prc_db_01()

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


OpenWithParm(b1w_validkey_update_popup_3_1_v20, iu_cust_msg)


end event

on b1w_reg_validkey_update_1_v20.create
int iCurrent
call super::create
this.p_change=create p_change
this.p_add=create p_add
this.p_term=create p_term
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_change
this.Control[iCurrent+2]=this.p_add
this.Control[iCurrent+3]=this.p_term
end on

on b1w_reg_validkey_update_1_v20.destroy
call super::destroy
destroy(this.p_change)
destroy(this.p_add)
destroy(this.p_term)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validinfo_popup_update
	Desc	: 	후불인증정보 변경/추가- update popup
	Ver.	:	1.0
	Date	: 	2003.11.10
	programer : Kim Eun Mi(kem)
-------------------------------------------------------------------------*/
String ls_ref_desc

ls_ref_desc = ""
is_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태
is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)    //선불서비스타입


end event

event resize;call super::resize;////변경 추가 버튼 위치 자동조정 추가
//
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	p_change.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//	p_change.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//Else
////	p_change.Y	= newheight - iu_cust_w_resize.ii_button_space
//End If
//
//SetRedraw(True)
end event

event key;Choose Case key
	Case KeyEscape!
		This.TriggerEvent(is_close)
End Choose

end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_validkey_update_1_v20
integer x = 41
integer y = 56
integer width = 1243
integer height = 216
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validkey_update_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "contractseq"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.contractseq[row] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.Object.validkey[row] = dw_cond.iu_cust_help.is_data[2]
		End If
		
	
End Choose

Return 0 
end event

event dw_cond::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.contractseq
This.is_help_win[1] = "b1w_hlp_contractmst_v20"
This.is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 585
integer y = 1228
boolean enabled = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_validkey_update_1_v20
integer x = 1728
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_validkey_update_1_v20
integer width = 1280
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_validkey_update_1_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 1330
integer y = 84
integer height = 168
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_validkey_update_1_v20
boolean visible = false
integer y = 52
integer width = 1257
integer height = 280
integer taborder = 20
string dataobject = "b1dw_reg_validkey_update"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;IF dwo.name= "auth_method" Then
	
	If LeftA(data, 1) = 'D' Then This.object.validitem2[1] = ""

	If MidA(data, 7,1) = 'E' Then This.object.validitem3[1]= ""

End If
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type p_change from u_p_change within b1w_reg_validkey_update_1_v20
integer x = 1390
integer y = 48
boolean bringtotop = true
end type

type p_add from u_p_add within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 1669
integer y = 176
boolean bringtotop = true
boolean enabled = false
string picturename = "D:\03.PB_\03.SSRT_SAMS\Template2.0\add_d.gif"
end type

type p_term from u_p_term within b1w_reg_validkey_update_1_v20
boolean visible = false
integer x = 1979
integer y = 176
boolean bringtotop = true
boolean enabled = false
string picturename = "D:\03.PB_\03.SSRT_SAMS\Template2.0\term_d.gif"
end type

