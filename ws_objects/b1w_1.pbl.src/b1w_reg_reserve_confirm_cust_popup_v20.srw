$PBExportHeader$b1w_reg_reserve_confirm_cust_popup_v20.srw
$PBExportComments$[ohj] 서비스 가입예약확정처리(고객중복- 선택 popup) v20
forward
global type b1w_reg_reserve_confirm_cust_popup_v20 from w_a_hlp
end type
end forward

global type b1w_reg_reserve_confirm_cust_popup_v20 from w_a_hlp
integer width = 3003
integer height = 1520
end type
global b1w_reg_reserve_confirm_cust_popup_v20 b1w_reg_reserve_confirm_cust_popup_v20

type variables
String is_cregno, is_ssno, is_pgm_id, is_status[]
Long   il_seq
end variables

on b1w_reg_reserve_confirm_cust_popup_v20.create
call super::create
end on

on b1w_reg_reserve_confirm_cust_popup_v20.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//조회
String ls_validkey_type, ls_idate_fr, ls_idate_to, ls_where, ls_validkey, ls_partner
String ls_ret_partner, ls_ret_prefixno
Long ll_row

ls_where = ""
If is_ssno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "ssno = '" + is_ssno + "' "	
End If

If is_cregno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cregno = '" + is_cregno + "' "	
End If

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
//dw_cond.Enabled = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_reg_reserve_confirm_cust_popup_v20
	Desc	: 고객확정처리
	Ver	: 	2.0     
	Date	: 	2005.05.13
	Programer : oh hye jin
-------------------------------------------------------------------------*/
String ls_preseq
String ls_ref_desc, ls_temp

f_center_window(b1w_reg_reserve_confirm_cust_popup_v20)

iu_cust_msg = Message.PowerObjectParm
is_ssno   = iu_cust_msg.is_data[1]
is_cregno = iu_cust_msg.is_data[2]
is_pgm_id = iu_cust_msg.is_data[3]
il_seq    = iu_cust_msg.il_data[1]

dw_hlp.SetRowFocusIndicator(off!)	

//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_status[]) 

Post Event ue_find()

end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_ok();Long    ll_row, ll_cnt = 0
Integer i, li_rc
String  ls_check, ls_yn, ls_customerid, ls_customernm

ll_row = dw_hlp.GetSelectedRow( 0 ) 

dw_cond.AcceptText()
ls_check = dw_cond.object.check[1]

If ls_check = 'Y' Then
	For i = 1 To dw_hlp.Rowcount() 
		ls_yn = dw_hlp.Object.check_yn[i]
		If ls_yn = 'Y' Then
			ls_customerid = dw_hlp.Object.Customerid[i]
			ls_customernm = dw_hlp.Object.customernm[i]
			ll_cnt ++
		End If
	Next
	
	If ll_cnt = 0 Then
		f_msg_info(9000, Title, "한명의 고객은 선택하셔야 합니다.!!")	
		Return
		
	ElseIf ll_cnt > 1 Then
		f_msg_info(9000, Title, "한명의 고객만 선택하십시오!!")	
		Return
	End If
	
	UPDATE PRE_SVCORDER
		SET STATUS     = :is_status[2]
		  , CUSTOMERID = :ls_customerid
		  , CUSTOMERNM = :ls_customernm
		  , UPDT_USER  = :gs_user_id
		  , UPDTDT     = SYSDATE
		  , PGM_ID     = :gs_pgm_id[gi_open_win_no]
	 WHERE PRESEQ     = :il_seq       ;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Update Error (PRE_SVCORDER)")
		Rollback;
		Return
	ElseIf SQLCA.SQLCode = 0 Then
		commit;
		f_msg_info(9000, Title, "저장성공")	
	End If		
	
	//기존 고객으로 했을떄... 주소라든가 하는 사항이 예약하면서 변경도ㅒㅆ으면? 어쩔것이냐...
	//상태만 업데이트했으니...
	
//신규고객으로 처리하겠다.
ElseIf ls_check = 'N' Then
	//Save Check
	b1u_dbmgr1_v20 lu_check
	lu_check = Create b1u_dbmgr1_v20
	lu_check.is_caller = "b1w_reg_reserve_confirm_cust_popup_v20%ue_ok"
	lu_check.is_title = Title
	lu_check.il_data[1] = il_seq                    //preseq
	lu_check.is_data[1] = gs_pgm_id[gi_open_win_no]
	lu_check.is_data[2] = gs_user_id
	
	lu_check.uf_prc_db_04()
	li_rc = lu_check.ii_rc
	
	If li_rc = -1  Then
		Rollback;
		Destroy lu_check
		f_msg_info(9000, Title, "저장실패")	
		Return 	
	Else
		commit;
		f_msg_info(9000, Title, "저장성공")	
	End If
	
	Destroy lu_check
	
End If

Close( This )

//
//If ll_row = 0 Then
//	f_msg_info(3020, This.Title, "Select Column")
//	Return
//End If
//
//If Upper(iu_cust_help.is_data[1]) = "CLOSEWITHRETURN" Then
//	Trigger Event ue_extra_ok_with_return(ll_row, li_ret)
//	If li_ret < 0 Then
//		Return
//	End If
//Else 
//	Trigger Event ue_extra_ok( ll_row ,li_ret)
//	If li_ret < 0 Then
//		Return
//	End If		
//End If
//
//iu_cust_help.ib_data[1] = True //Help값이 선정됨.
//Close( This )

end event

type p_1 from w_a_hlp`p_1 within b1w_reg_reserve_confirm_cust_popup_v20
boolean visible = false
integer x = 1691
integer y = 44
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within b1w_reg_reserve_confirm_cust_popup_v20
integer x = 69
integer y = 72
integer width = 1376
integer height = 104
string dataobject = "b1dw_cnd_reserve_confirm_cust_popup_v20"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_reg_reserve_confirm_cust_popup_v20
integer x = 1582
integer y = 64
end type

type p_close from w_a_hlp`p_close within b1w_reg_reserve_confirm_cust_popup_v20
integer x = 1879
integer y = 64
end type

type gb_cond from w_a_hlp`gb_cond within b1w_reg_reserve_confirm_cust_popup_v20
integer y = 8
integer width = 1445
integer height = 188
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_reg_reserve_confirm_cust_popup_v20
integer y = 216
integer width = 2917
integer height = 1188
string dataobject = "b1dw_reg_reserve_confirm_cust_popup_v20"
boolean livescroll = false
end type

event dw_hlp::doubleclicked;//override
end event

