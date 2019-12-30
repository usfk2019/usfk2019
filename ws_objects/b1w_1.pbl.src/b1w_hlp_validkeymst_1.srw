$PBExportHeader$b1w_hlp_validkeymst_1.srw
$PBExportComments$[parkkh] Help 인증MST
forward
global type b1w_hlp_validkeymst_1 from w_a_hlp
end type
end forward

global type b1w_hlp_validkeymst_1 from w_a_hlp
integer width = 3488
integer height = 1688
end type
global b1w_hlp_validkeymst_1 b1w_hlp_validkeymst_1

type variables
String is_bonsa_partner, is_validkey_gubun
end variables

on b1w_hlp_validkeymst_1.create
call super::create
end on

on b1w_hlp_validkeymst_1.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//조회
String ls_validkey_type, ls_idate_fr, ls_idate_to, ls_where, ls_validkey, ls_partner
String ls_ret_partner, ls_ret_prefixno
Long ll_row

ls_validkey_type = Trim(dw_cond.object.validkey_type[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_idate_fr = String(dw_cond.object.idate_fr[1],'yyyymmdd')
ls_idate_to = String(dw_cond.object.idate_to[1],'yyyymmdd')

If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_idate_fr) Then ls_idate_fr = ""
If IsNull(ls_idate_to) Then ls_idate_to = ""

ls_where = ""
//If ls_validkey_type <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "validkey_type = '" + ls_validkey_type + "' "	
//End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(validkey) like '%" + Upper(ls_validkey) + "%' "
End If

If ls_idate_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(idate,'yyyymmdd') >= '" + ls_idate_fr + "' "
End If

If ls_idate_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(idate,'yyyymmdd') <= '" + ls_idate_fr + "' "
End If

//is_data[2] <= is_req_yn (할당모듈 여부)
//is_data[3] <= reg_partner (해당대리점)

If is_data[2] = "Y" and is_data[3] <> "" Then  //할당여부 is_data[2] = 'Y' 일때

	If is_validkey_gubun = 'Y' Then//2005.02.18 파라미터값이  Y일때 유치처가 가지고 있는 인증key만 조회 하여 개통신청할 수 있다.
		
		IF ls_where <> "" Then ls_where += " And "
		ls_where += "( partner = '" + is_data[3] + "')"
	Else
		//2004-12-08 kem 수정(본사는 본사것만 대리점은 상위총판대리점에 해당하는 것만)
		IF is_data[3] <> is_bonsa_partner Then
		
			IF b1fi_partner_prefixno_levelcod(this.title,is_data[3],ls_ret_partner, ls_ret_prefixno) > 0 Then
				IF ls_where <> "" Then ls_where += " And "
				ls_where += "( partner = '" + is_data[3] + "' or partner = '"+ ls_ret_partner + "')"
			Else
				return
			End IF
		Else
			ls_where += "( partner = '" + is_bonsa_partner + "')"
		End IF
	End If
	
End IF

//priceplan에 해당하는  vaplidkey_type select
//If is_data[4] <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += " validkey_type = (select validkey_type from priceplan_validkey_type where priceplan = '" + is_data[4] + "') "
//End IF

//2004-12-08 kem 수정
//가격정책이 같거나 혹은 가격정책이 Null인 것만 가져온다.
If is_data[4] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " ( priceplan is null Or priceplan = '" + is_data[4] + "' ) "
End IF

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;String ls_ref_desc
This.Title = "Help ValidkeyMST"

ls_ref_desc = ""
is_bonsa_partner = fs_get_control("A1", "C102", ls_ref_desc)

// 2005.03.17 유치대리점 자신이 가지고 있는 인증key만 개통신청할수 있다. 'Y'일때...
is_validkey_gubun = fs_get_control("00", "Z800", ls_ref_desc)

end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.validkey[al_selrow])		//ID
iu_cust_help.is_data[2] = string(dw_hlp.Object.systemid[al_selrow])		//systemid
iu_cust_help.is_data[3] = string(dw_hlp.Object.rte_type[al_selrow])		//routekey type
iu_cust_help.is_data[4] = string(dw_hlp.Object.in_out_type[al_selrow])	//in out type

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_validkeymst_1
integer x = 1563
integer y = 44
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_validkeymst_1
integer y = 56
integer width = 1262
integer height = 280
string dataobject = "b1dw_cnd_hlp_validkeymst_1"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_validkeymst_1
integer x = 1861
integer y = 44
end type

type p_close from w_a_hlp`p_close within b1w_hlp_validkeymst_1
integer x = 2158
integer y = 44
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_validkeymst_1
integer width = 1326
integer height = 352
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_validkeymst_1
integer x = 27
integer y = 372
integer width = 3424
integer height = 1188
string dataobject = "b1dw_hlp_validkeymst_1"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkey_t
uf_init(ldwo_SORT)
end event

