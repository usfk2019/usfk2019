$PBExportHeader$ubs_w_pop_validkey.srw
$PBExportComments$[jhchoi] 인증키 검색 팝업(서비스신청용) - 2009.05.11
forward
global type ubs_w_pop_validkey from w_a_hlp
end type
type dw_detail from datawindow within ubs_w_pop_validkey
end type
type p_save from u_p_save within ubs_w_pop_validkey
end type
end forward

global type ubs_w_pop_validkey from w_a_hlp
integer width = 2752
integer height = 1712
event type integer ue_insert ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
dw_detail dw_detail
p_save p_save
end type
global ubs_w_pop_validkey ubs_w_pop_validkey

type variables
String is_bonsa_partner, is_used_level, is_used_level_code[], is_partner

integer 		ii_cnt
Long 			il_length, il_length_h, 	il_row

String 		is_pgm_gu, is_validkey_type, is_langtype, is_auth_method
String 		is_validkey_typenm, is_crt_kind, is_prefix, is_type, is_crt_kind_code[]
String 		is_crt_kind_h, is_prefix_h, is_type_h, is_auth_method_h, is_validkey_type_h
String 		is_reg_partner, is_priceplan, is_customerid, is_first_gu
String 		is_close_gu, is_validitem_yn, is_used_level_h			

datawindow idw_data

String is_callforward_type,is_callforward_code[] //2005-07-06 khpark add


end variables

forward prototypes
public function integer wfi_dw_detail_setting ()
public function integer wf_validkey_setting ()
end prototypes

event type integer ue_insert();long ll_row
integer li_return
String ls_validkey_type

ll_row = dw_detail.getrow()
//default 셋팅
dw_cond.object.validkey_type[1] = is_validkey_type
dw_detail.object.validkey_type[ll_row] = is_validkey_type
dw_detail.object.langtype[ll_row] = is_langtype

return 0 
end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

f_msg_info(3000,This.Title,"Save")

Return 0
end event

event type integer ue_extra_save();String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
String ls_validkey_type, ls_validkey_loc, ls_callforwardno, ls_password,ls_callingnum_all
Long ll_row, ll_cnt

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then return 0

ls_validkey_type = dw_detail.object.validkey_type[1]
ls_validkey		  = trim(dw_detail.object.validkey[1])
ls_vpassword	  = dw_detail.object.vpassword[1]
ls_cid 			  = dw_detail.object.validitem1[1]
ls_auth_method	  = dw_detail.object.auth_method[1]
ls_validkey_loc  = dw_detail.object.validkey_loc[1]
ls_ip_address 	  = dw_detail.object.validitem2[1]
ls_h323id		  = dw_detail.object.validitem3[1]

If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ls_validkey)		 Then ls_validkey = ""
If IsNull(ls_vpassword)		 Then ls_vpassword = ""
If IsNull(ls_cid)				 Then ls_cid = ""
If IsNull(ls_auth_method)	 Then ls_auth_method = ""		
If IsNull(ls_validkey_loc)	 Then ls_validkey_loc = ""
If IsNull(ls_ip_address)	 Then ls_ip_address = ""				
If IsNull(ls_h323id)			 Then ls_h323id = ""							

If ls_validkey_type = "" Then
	f_msg_usr_err(200, Title, "인증KeyType")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("validkey_type")
	return -1 
End If

IF is_crt_kind = is_crt_kind_code[1] or is_crt_kind = is_crt_kind_code[4] or is_crt_kind = is_crt_kind_code[5] Then
	If ls_validkey = "" Then
		f_msg_usr_err(200, Title, "인증 Key")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("validkey")
		return -1
	End If
End IF

If LeftA(ls_auth_method,2) = 'PA' Then
	If ls_vpassword = "" Then
		f_msg_usr_err(200, Title, "인증 Password")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("vpassword")
		return -1
	End If
End If

If LeftA(ls_auth_method,5) = 'STCIP' Then
	If ls_ip_address = "" Then
		f_msg_usr_err(200, Title, "IP ADDRESS")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("validitem2")
		return -1
	End If		
End if
If is_crt_kind_h = is_crt_kind_code[2] Or is_crt_kind_h = is_crt_kind_code[3] Then
Else
	If MidA(ls_auth_method,7,4) = 'BOTH' or  MidA(ls_auth_method,7,4) = 'H323' Then
		If ls_h323id = "" Then
			f_msg_usr_err(200, Title, "H323ID")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			dw_detail.SetColumn("validitem3")
			return -1
		End If			
	End IF
End If

If ii_cnt > 0 Then    //인증KeyLocation 입력여부
	If ls_validkey_loc = "" Then
		f_msg_usr_err(200, Title, "인증KeyLocation")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("validkey_loc")
		Return	-1
	End If
End IF

//khpark add 2005-07-07 start
CHOOSE CASE is_callforward_type    
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		
	CASE is_callforward_code[2]    //착신전환패스워드인증유형일때 

		ls_callforwardno = dw_detail.object.callforwardno[1]
		ls_password = dw_detail.object.password[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							
		If IsNull(ls_password) Then ls_password = ""							
		
		If ls_callforwardno <> "" Then
			If ls_password = "" Then
				f_msg_usr_err(200, Title, "착신전환Password")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				dw_detail.SetColumn("password")
				return -1
			End If		
		End if

	CASE is_callforward_code[3]    //착신전환발신인증유형일때
		ls_callforwardno = dw_detail.object.callforwardno[1]
		ls_callingnum_all = dw_detail.object.callingnum[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							
		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""							

		If ls_callforwardno <> "" Then
			If ls_callingnum_all = "" Then
				f_msg_usr_err(200, Title, "발신가능전화번호")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				dw_detail.SetColumn("callforwardno")
				return -1
			End If		
		End if
END CHOOSE
//khpark add 2005-07-07 start

return 0
end event

public function integer wfi_dw_detail_setting ();integer li_return
DataWindowChild ldc_validkey_type
Long li_exist
String ls_filter

//인증Key Location 입력여부
IF ii_cnt > 0 Then
	 dw_detail.Object.validkey_loc.visible = True
    dw_detail.Object.validkey_loc_t.visible = True
Else
	 dw_detail.Object.validkey_loc.visible = False
    dw_detail.Object.validkey_loc_t.visible = False
End IF	

CHOOSE CASE is_callforward_type    
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
       dw_detail.Object.callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.password.Protect = 1
		 dw_detail.Object.password.Color = RGB(0,0,0)
       dw_detail.Object.password.Background.Color =  RGB(255, 251, 240)			 	 	
//		 cb_callingnum.enabled = False
	CASE is_callforward_code[2]     //착신전환비밀번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
       dw_detail.Object.callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.password.Protect = 0
		 dw_detail.Object.password.Color =  RGB(0,0,0)
       dw_detail.Object.password.Background.Color =  RGB(255,255,255)
//  	 cb_callingnum.enabled = False
	CASE is_callforward_code[3]     //착신전환발신번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
       dw_detail.Object.callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.password.Protect = 1
		 dw_detail.Object.password.Color = RGB(0,0,0)
       dw_detail.Object.password.Background.Color =  RGB(255, 251, 240)	
//		 cb_callingnum.enabled = True
	CASE ELSE
		 dw_detail.Object.callforwardno.Protect = 1
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
       dw_detail.Object.callforwardno.Background.Color =  RGB(255, 251, 240)			
		 dw_detail.Object.password.Protect = 1
		 dw_detail.Object.password.Color = RGB(0,0,0)
       dw_detail.Object.password.Background.Color =  RGB(255, 251, 240)			
//		 cb_callingnum.enabled = False
END CHOOSE	

//가격정책별 인증KEYTYPE
li_exist = dw_cond.GetChild("validkey_type", ldc_validkey_type)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
ls_filter = "a.priceplan = '" + is_priceplan + "'  " 
ldc_validkey_type.SetTransObject(SQLCA)
li_exist =ldc_validkey_type.Retrieve()
ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
ldc_validkey_type.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return -1  		//선택 취소 focus는 그곳에
End If

//해당 가격정책에 VALIDTIEM에 따른 info 가져오기
li_return = b1fi_validitem_info_v20(this.title,is_priceplan,is_validitem_yn,is_validkey_type_h,is_crt_kind_h,is_prefix_h,il_length_h,is_auth_method_h,is_type_h, is_used_level_h) 

If li_return = -1 Then
    return -1
End IF

return  0
end function

public function integer wf_validkey_setting ();integer li_return

If is_validkey_type <> "" Then
	
	dw_detail.Object.validkey_type[1] = is_validkey_type
	
	//validkey_type에 따른 info 가져오기
	li_return = b1fi_validkey_type_info_v20(this.title,is_validkey_type,is_validkey_typenm,is_crt_kind,is_prefix,il_length,is_auth_method,is_type,is_used_level) 

	If li_return = -1 Then
	    return -1
	End IF
	
	dw_detail.Object.auth_method[1] = is_auth_method

	Choose Case is_crt_kind			
		Case is_crt_kind_code[1]         //수동Manual
			dw_hlp.Enabled = FALSE
			dw_detail.Object.validkey.protect = 0
			dw_detail.Object.validkey.Background.Color = RGB(107, 146, 140)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
			dw_detail.SetFocus()
			dw_detail.SetRow(1)
			dw_detail.SetColumn('validkey')
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
			dw_hlp.Enabled = TRUE
			dw_detail.Object.validkey.protect = 1
			dw_detail.Object.validkey.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.validkey.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]         //자원관리Resource
			dw_hlp.Enabled = TRUE
			dw_detail.Object.validkey.Protect = 1
			dw_detail.Object.validkey.Background.Color = RGB(107, 146, 140)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
		Case is_crt_kind_code[5]         //고객대체
			dw_hlp.Enabled = FALSE
			dw_detail.Object.validkey.Protect   = 0
			dw_detail.Object.validkey.Background.Color = RGB(107, 146, 140)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)	
			
			dw_detail.SetFocus()
			dw_detail.SetRow(1)
			dw_detail.SetColumn('validkey')			
			 
			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
			Else
				dw_cond.Object.validkey[1] = is_customerid				
				dw_detail.Object.validkey[1] = is_customerid
			End IF
		
	End Choose

End IF

return 0
end function

on ubs_w_pop_validkey.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.p_save=create p_save
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.p_save
end on

on ubs_w_pop_validkey.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.p_save)
end on

event ue_find;call super::ue_find;//조회
String ls_validkey_type, ls_where, ls_validkey, ls_partner, ls_where_tmp , ls_keyday
String ls_ret_partner, ls_ret_prefixno
Long ll_row


ls_validkey_type 	= Trim(dw_cond.object.validkey_type[1])
ls_validkey 		= Trim(dw_cond.object.validkey[1])

If IsNull(ls_validkey_type) 	Then ls_validkey_type 	= ""
If IsNull(ls_validkey) 			Then ls_validkey 			= ""

ls_where = ""
If is_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	//ls_where += "partner = '" + is_partner + "' "	
	ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_partner + "'))"
End If

If ls_validkey_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "validkey_type = '" + ls_validkey_type + "' "	
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(validkey) like '%" + Upper(ls_validkey) + "%' "
End If

//is_data[2] = reg_partner (유치대리점)
//대리점의인증Key사용권한
Choose Case is_used_level
	Case is_used_level_code[1]     //제한없음
		
	Case is_used_level_code[2]     //자기할당자원

		IF ls_where <> "" Then ls_where += " And "
		//ls_where += "( partner = '" + is_data[2] + "')"
		ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_data[2] + "'))"
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
			ls_where += "partner in (select partner from partnermst where basecod = (select basecod from partnermst where   partner = '" + is_bonsa_partner + "'))"
		End IF        
End Choose		

//2004-12-08 kem 수정
//가격정책이 같거나 혹은 가격정책이 Null인 것만 가져온다.
If is_data[3] <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " ( priceplan is null Or priceplan = '" + is_data[3] + "' ) "
End IF


/****************2013-03-21 hmk 수정***************************/
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


//RQ-UBS-201503-06 의거 재수정-070번호 신청할 때 번호선택창(POPUP창)에서 사용 가능한 번호가 뜨지 않는 경우 확인요청
// 위처럼 하면 validinfo 에 있는 validkey만 나오게 되므로.. validkeymst의 가용번호가 제외된다.
//IF ls_where <> "" Then ls_where += " minus "
//		ls_where += " select validkey, 		" +&
//                  "   validkey_type,		" +&
//						"	 status,					" +&
//						"	 sale_flag,				" +&
//						"	 idate,					" +&
//						"	 iseqno,					" +&
//						"	 partner,				" +&
//						"	 remark					" +&
//					   " from validkeymst      " +&
//					   " where sale_flag = '0' " +&  
//						"  and validkey in (   select validkey from validinfo  where todt > sysdate - " + ls_keyday + ")" 
//


//동일고객(customerid)이 해지한 번호는 30일이 안되더라도 사용중이 아니면 가용번호 되도록 처리
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
//messagebox("", ls_where)

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 then
//	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

dw_hlp.SetFocus()


end event

event open;call super::open;STRING	ls_ref_desc, ls_temp,	ls_svccod
INT		li_return

This.Title = "Number"

//window 중앙에
f_center_window(this)

iu_cust_msg 			= Message.PowerObjectParm
is_pgm_gu 				= iu_cust_msg.is_data[1]			//프로그램 구분
is_validkey_type 		= iu_cust_msg.is_data[2]			//validkey_type
is_langtype 			= iu_cust_msg.is_data[3]			//langtype(언어멘트)
is_priceplan 			= iu_cust_msg.is_data[4]			//가격정책
is_reg_partner 		= iu_cust_msg.is_data[5]			//유치처
is_customerid 			= iu_cust_msg.is_data[6]			//고객번호
is_callforward_type  = iu_cust_msg.is_data[7]			//착신전환유형
ls_svccod     			= iu_cust_msg.is_data[8]  
is_partner    			= iu_cust_msg.is_data[9]			//SHOPID
ii_cnt 					= iu_cust_msg.ii_data[1]			//발신지Location check yn ii_cnt
il_row 					= iu_cust_msg.il_data[1]			//현재row
idw_data 				= iu_cust_msg.idw_data[1]

//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp		= fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp 	= "" Then Return
fi_cut_string(ls_temp, ";" , is_crt_kind_code[])

//부가서비스유형코드  //2005-07-06 khpark add
ls_ref_desc = ""
ls_temp		= fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp 	= "" Then Return
fi_cut_string(ls_temp, ";", is_callforward_code[])

ls_ref_desc 	  = ""
is_bonsa_partner = fs_get_control("A1", "C102", ls_ref_desc)

//대리점의 인증Key사용권한(제한없음;자기할당자원;자기할당자원&관리대리점할당자원)  0;1;2
ls_ref_desc = ""
ls_temp		= fs_get_control("B1", "P504", ls_ref_desc)
If ls_temp 	= "" Then Return
fi_cut_string(ls_temp, ";" , is_used_level_code[]) 

IF is_pgm_gu = 'Ue_extra_insert' Then
    //insert
	li_return = This.Trigger Event ue_insert()
	
	If li_return < 0 Then
		Return
	End if
elseif is_pgm_gu = 'ubs_w_reg_activation' then   //모바일서비스는 (grcode ='ZM103') 개통시 번호할당
	
	li_return = This.Trigger Event ue_insert()
	
	If li_return < 0 Then
		Return
	End if
	
Else
	//b1w_reg_svc_actorder_v20 에서 더블클릭시 해당 루틴탄다.
	//이때,dw_detail에 한건도 없을 경우 dddw가 셋팅이 제대로 되지 않아 insertrow 하고 deleterow한후, rowscopy한다.
	dw_cond.object.validkey_type[1] = is_validkey_type
	dw_detail.insertrow(0)
	dw_detail.deleterow(0)
   // parent.dw_detail에 Doubleclicked 시
   idw_data.RowsCopy(il_row,il_row,Primary!,dw_detail,1,Primary!)
End IF

is_first_gu = 'Y'   //셋팅관련

is_validkey_type = dw_detail.object.validkey_type[1]
If IsNull(is_validkey_type) Then is_validkey_type = ""

//dw_detail validkey 셋팅값
If wf_validkey_setting() = -1 Then
	return 
End IF
//dw_detail 기타셋팅값
If wfi_dw_detail_setting() = -1 Then
	return 
End IF

is_first_gu = 'N'    //셋팅관련

p_save.TriggerEvent("ue_enable")
end event

event ue_close();Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.validkey[al_selrow])		//ID

end event

event close;call super::close;long ll_row 

ll_row = dw_detail.getrow()

IF is_close_gu = "CANCEL" Then     //close 버튼 클릭 시 check , cancle 버튼 클릭시는 취소
Else
	IF is_pgm_gu = 'Ue_extra_insert' Then
	   //복사한다.
	   dw_detail.RowsCopy(ll_row,ll_row, Primary!,idw_data,il_row, Primary!)
	elseif is_pgm_gu = 'ubs_w_reg_activation' Then //모바일서비스는 (grcode ='ZM103') 개통시 번호할당
		
		idw_data.object.validkey[il_row] = dw_detail.object.validkey[ll_row]  
	Else
		//doubleclicked에서 popup창 띄웠을 경우 해당row 변경해야 하므로 해당row delete 후 변경사항 rowcopy
		idw_data.deleterow(il_row)
		dw_detail.RowsCopy(ll_row,ll_row, Primary!,idw_data,il_row, Primary!)
	End IF
End IF


end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_validkey
boolean visible = false
integer x = 2080
integer y = 1484
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_validkey
integer x = 59
integer y = 40
integer width = 2633
integer height = 184
string dataobject = "ubs_dw_pop_validkey_cond"
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;integer li_return

CHOOSE Case dwo.name

    Case "validkey_type"
		
		is_validkey_type = data		

		dw_detail.Object.validkey[1] = ""
     	dw_detail.Object.validitem2[1] = ""
    	dw_detail.Object.validitem3[1] = ""
		
		//dw_detail validkey 셋팅값
		wf_validkey_setting()	
		
		PARENT.TRIGGER EVENT ue_find()
		
    Case "validkey"
	
		PARENT.TRIGGER EVENT ue_find()

End CHoose
end event

type p_ok from w_a_hlp`p_ok within ubs_w_pop_validkey
boolean visible = false
integer x = 2377
integer y = 1484
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_validkey
integer x = 1696
integer y = 1484
end type

event p_close::clicked;is_close_gu = 'CANCEL'

Parent.TriggerEvent('ue_close')

return 0
end event

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_validkey
integer x = 27
integer width = 2688
integer height = 244
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_validkey
integer x = 27
integer y = 260
integer width = 2693
integer height = 1188
string dataobject = "ubs_dw_pop_validkey_mas"
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkey_t
uf_init(ldwo_SORT)
end event

event dw_hlp::clicked;call super::clicked;//dw_hlp.AcceptText()

This.SetFocus()

IF row <= 0 THEN RETURN -1

dw_detail.Object.validkey[1] = THIS.Object.validkey[row]

RETURN 0
end event

event dw_hlp::doubleclicked;//
end event

type dw_detail from datawindow within ubs_w_pop_validkey
integer x = 27
integer y = 1472
integer width = 1198
integer height = 128
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_validkey_det"
boolean border = false
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
InsertRow( 0 )
end event

type p_save from u_p_save within ubs_w_pop_validkey
integer x = 1390
integer y = 1484
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;
IF Parent.TriggerEvent('ue_save') < 0 THEN
	RETURN -1
END IF

Parent.TriggerEvent('ue_close')


end event

