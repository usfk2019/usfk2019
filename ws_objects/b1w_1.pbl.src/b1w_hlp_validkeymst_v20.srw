$PBExportHeader$b1w_hlp_validkeymst_v20.srw
$PBExportComments$[parkkh] Help 인증MST-인증Key
forward
global type b1w_hlp_validkeymst_v20 from w_a_hlp
end type
end forward

global type b1w_hlp_validkeymst_v20 from w_a_hlp
integer width = 3488
integer height = 1688
end type
global b1w_hlp_validkeymst_v20 b1w_hlp_validkeymst_v20

type variables
String is_bonsa_partner, is_used_level, is_used_level_code[], is_customerid
end variables

on b1w_hlp_validkeymst_v20.create
call super::create
end on

on b1w_hlp_validkeymst_v20.destroy
call super::destroy
end on

event ue_find;call super::ue_find;//조회
String ls_validkey_type, ls_idate_fr, ls_idate_to, ls_where, ls_validkey, ls_partner, ls_where_tmp, ls_keyday
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
		IF ls_where <> "" Then ls_where += " And "
		//ls_where += "( partner = '" + is_data[2] + "')"		
		ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_data[2]  + "'))"
		
	Case is_used_level_code[2]     //자기할당자원

		IF ls_where <> "" Then ls_where += " And "
		//ls_where += "( partner = '" + is_data[2] + "')"
		ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_data[2]  + "'))"
		
	
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
		Else                 
			//해당대리점이 본사일 경우
			IF ls_where <> "" Then ls_where += " And "
			//ls_where += "( partner = '" + is_bonsa_partner + "')"
			ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_bonsa_partner  + "'))"
		
		End IF        
End Choose		

//2004-12-08 kem 수정
//가격정책이 같거나 혹은 가격정책이 Null인 것만 가져온다.
If is_data[3] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " ( priceplan is null Or priceplan = '" + is_data[3] + "' ) "
End IF


/****************2013-07-08 hmk 수정***************************/
//해지한지 X일이 되는 일자부터 가용번호가 되도록 처리
// ex> 2012-12-13 해지시 20130113부터 가용번호

// sysctl1t.Z100 = 해지인증키 가용전환일수
select trim(ref_content) into :ls_keyday 
from sysctl1t
where module  = 'Z1'
  and ref_no = 'Z100';
 
//일단 위의 조건을 아래 or절에 써야 하니 담아두자..
ls_where_tmp = ls_where

//해지한지 X일이 되는 일자부터 가용번호가 되는 건들
IF ls_where <> "" Then ls_where += " And "
	ls_where += " validkey in (   select validkey from validinfo  where todt <= sysdate - " + ls_keyday + ")"

IF ls_where <> "" Then ls_where += " And "
	ls_where += " validkey in (   select validkey from validinfo  where todt <= sysdate - " + ls_keyday + ")"


////동일고객(customerid)이 해지한 번호는 30일이 안되더라도 사용중이 아니면 가용번호 되도록 처리
IF is_customerid <> "" Then
	IF ls_where <> "" Then ls_where += " union "
		ls_where += " select validkey, 		" +&
                  "   validkey_type,		" +&
						"	 status,					" +&
						"	 sale_flag,				" +&
						"	 idate,					" +&
						"	 iseqno,					" +&
						"	 partner,				" +&
						"	 remark					" +&
					   " from validkeymst      " +&
					   " where sale_flag = '0' " +&  
						"  and validkey in (   select validkey from validinfo  where  customerid = " + is_customerid + " and  todt > sysdate - " + ls_keyday + ")" 
	   If ls_where_tmp <> "" Then
			ls_where += " And " 
			ls_where += ls_where_tmp 
		End if
END IF
/***************************************************************/

//clipboard(ls_where)
//messagebox(is_used_level, ls_where )

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
is_customerid = is_data[6]          // customerid



end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.validkey[al_selrow])		//ID

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_validkeymst_v20
integer x = 1691
integer y = 44
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_validkeymst_v20
integer x = 69
integer y = 56
integer width = 1376
integer height = 280
string dataobject = "b1dw_cnd_hlp_validkeymst_v20"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_validkeymst_v20
integer x = 1989
integer y = 44
end type

type p_close from w_a_hlp`p_close within b1w_hlp_validkeymst_v20
integer x = 2286
integer y = 44
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_validkeymst_v20
integer width = 1445
integer height = 360
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_validkeymst_v20
integer x = 27
integer y = 372
integer width = 3424
integer height = 1188
string dataobject = "b1dw_hlp_validkeymst_v20"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkey_t
uf_init(ldwo_SORT)
end event

