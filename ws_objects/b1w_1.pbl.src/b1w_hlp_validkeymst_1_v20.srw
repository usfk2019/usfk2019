$PBExportHeader$b1w_hlp_validkeymst_1_v20.srw
$PBExportComments$[parkkh] Help 인증MST- RoutID
forward
global type b1w_hlp_validkeymst_1_v20 from w_a_hlp
end type
end forward

global type b1w_hlp_validkeymst_1_v20 from w_a_hlp
integer width = 3488
integer height = 1688
end type
global b1w_hlp_validkeymst_1_v20 b1w_hlp_validkeymst_1_v20

type variables
String is_bonsa_partner, is_used_level, is_used_level_code[]
end variables

on b1w_hlp_validkeymst_1_v20.create
call super::create
end on

on b1w_hlp_validkeymst_1_v20.destroy
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
If ls_validkey_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "validkey_type = '" + ls_validkey_type + "' "	
End If

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

//is_data[2] = reg_partner (유치대리점)
//대리점의인증Key사용권한
Choose Case is_used_level
	Case is_used_level_code[1]     //제한없음
		
	Case is_used_level_code[2]     //자기할당자원

		IF ls_where <> "" Then ls_where += " And "
		ls_where += "( partner = '" + is_data[2] + "')"
	
    Case is_used_level_code[3]     //자기할당자원&자기상위관리대상대리점할당자원
		
		IF is_data[2] <> is_bonsa_partner Then      // 해당대리점이 본사가 아닐때
			If is_data[2] <> "" Then

				//자기 상위관리대상대리점 찾아옴
				IF b1fi_partner_prefixno_levelcod(this.title,is_data[2],ls_ret_partner,ls_ret_prefixno) > 0 Then
					IF ls_where <> "" Then ls_where += " And "
					ls_where += "( partner = '" + is_data[2] + "' or partner = '"+ ls_ret_partner + "')"
				Else
					return
				End IF				
			End If
		Else                       //해당대리점이 본사일 경우
			ls_where += "( partner = '" + is_bonsa_partner + "')"
		End IF        
End Choose		

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

event open;call super::open;String ls_ref_desc, ls_temp
This.Title = "Help ValidkeyMST"

ls_ref_desc = ""
is_bonsa_partner = fs_get_control("A1", "C102", ls_ref_desc)

//대리점의 인증Key사용권한(제한없음;자기할당자원;자기할당자원&관리대리점할당자원)  0;1;2
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P504", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_used_level_code[]) 

//is_data[2] = is_reg_partner       //유치처
//is_data[3] = is_priceplan         //가격정책
//is_data[4] = is_validkey_type	    //validkey_type
//is_data[5] = is_used_level        //대리점의 인증Key사용권한
dw_cond.object.validkey_type[1] = is_data[4]
is_used_level = is_data[5]          //대리점의 인증Key사용권한



end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.validkey[al_selrow])		//ID
iu_cust_help.is_data[2] = string(dw_hlp.Object.systemid[al_selrow])		//systemid
iu_cust_help.is_data[3] = string(dw_hlp.Object.rte_type[al_selrow])		//routekey type
iu_cust_help.is_data[4] = string(dw_hlp.Object.in_out_type[al_selrow])	//in out type

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_validkeymst_1_v20
integer x = 1563
integer y = 44
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_validkeymst_1_v20
integer y = 56
integer width = 1262
integer height = 280
string dataobject = "b1dw_cnd_hlp_validkeymst_1_v20"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_validkeymst_1_v20
integer x = 1861
integer y = 44
end type

type p_close from w_a_hlp`p_close within b1w_hlp_validkeymst_1_v20
integer x = 2158
integer y = 44
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_validkeymst_1_v20
integer width = 1326
integer height = 352
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_validkeymst_1_v20
integer x = 27
integer y = 372
integer width = 3424
integer height = 1188
string dataobject = "b1dw_hlp_validkeymst_1_v20"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkey_t
uf_init(ldwo_SORT)
end event

