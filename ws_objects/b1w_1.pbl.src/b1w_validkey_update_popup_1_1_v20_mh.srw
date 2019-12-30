$PBExportHeader$b1w_validkey_update_popup_1_1_v20_mh.srw
$PBExportComments$[ohj] 인증 Key 변경 v20
forward
global type b1w_validkey_update_popup_1_1_v20_mh from w_base
end type
type cb_callingnum from commandbutton within b1w_validkey_update_popup_1_1_v20_mh
end type
type dw_detail from u_d_help within b1w_validkey_update_popup_1_1_v20_mh
end type
type p_save from u_p_save within b1w_validkey_update_popup_1_1_v20_mh
end type
type p_close from u_p_close within b1w_validkey_update_popup_1_1_v20_mh
end type
type ln_2 from line within b1w_validkey_update_popup_1_1_v20_mh
end type
end forward

global type b1w_validkey_update_popup_1_1_v20_mh from w_base
integer width = 2921
integer height = 2100
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
cb_callingnum cb_callingnum
dw_detail dw_detail
p_save p_save
p_close p_close
ln_2 ln_2
end type
global b1w_validkey_update_popup_1_1_v20_mh b1w_validkey_update_popup_1_1_v20_mh

type variables
String is_validkey, is_pgm_id, is_fromdt, is_pgm_gu, is_customerid, is_first_gu
String is_svccod//, is_Xener_svccod[], is_xener_svc
String is_svctype_post, is_svctype_pre, is_svctype, is_partner
String is_req_yn, is_used_level, is_reg_partner, is_svctype_in, is_svctype_out
int    ii_validkeytype_cnt
String is_validkey_type = "", is_inout_svctype
String is_validkey_typenm, is_crt_kind, is_prefix, is_type, is_crt_kind_code[]
String is_langtype, is_auth_method, is_priceplan
Long   il_length 
Integer ii_cnt
String is_validitem_yn, is_validkey_type_h, is_crt_kind_h, is_prefix_h
String is_auth_method_h,is_type_h, is_used_level_h
Long   il_length_h

string is_contractseq,is_addition_itemcod,is_addition_code,is_callforward_yn,is_callforwardno
string is_callforward_code[],is_call_password
Long il_callforward_seq
date id_addition_item_todt


end variables

forward prototypes
public function integer wfi_dw_detail_setting ()
public function integer wf_validkey_setting ()
end prototypes

event ue_ok();Long ll_row , li_exist, ll_result
String ls_where, ls_filter
DataWindowChild ldc_validkey_type
//조회

ls_where = " v.validkey = '" + is_validkey + "' AND to_char(v.fromdt,'yyyymmdd') = '" + is_fromdt + "' " + &
           " AND v.svccod = '" + is_svccod +"'"
	
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_detail.Object.new_fromdt[1] = RelativeDate(date(fdt_get_dbserver_now()),1)
dw_detail.object.callforwardno[1] = is_callforwardno
dw_detail.object.new_callforwardno[1] = is_callforwardno
dw_detail.object.password[1] = is_call_password
dw_detail.object.new_password[1] = is_call_password
is_validkey_type = dw_detail.Object.new_validkey_type[1]

//인증KeyLocation 입력여부 
ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccod, ii_cnt)

IF ii_cnt > 0 Then
	dw_detail.Object.new_validkey_loc.visible = True
	dw_detail.Object.new_validkey_loc_t.visible = True
Else
	dw_detail.Object.new_validkey_loc.visible = False
	dw_detail.Object.new_validkey_loc_t.visible = False
End IF

//가격정책별 인증KEYTYPE
li_exist = dw_detail.GetChild("new_validkey_type", ldc_validkey_type)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
ls_filter = "a.priceplan = '" + is_priceplan + "'  " 
ldc_validkey_type.SetTransObject(SQLCA)
li_exist =ldc_validkey_type.Retrieve()
ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
ldc_validkey_type.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return   		//선택 취소 focus는 그곳에
End If

If wf_validkey_setting() = -1 Then
	return 
End IF
//dw_detail 기타셋팅값
If wfi_dw_detail_setting() = -1 Then
	return 
End IF
end event

event ue_close;Close(This)
end event

event type integer ue_save();Long ll_row
Integer li_rc
b1u_dbmgr4_v20 	lu_dbmgr


ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return 0
End If

//Select nvl(validkeycnt,0)
//  Into :ii_validkeytype_cnt
//  From priceplanmst
//where priceplan  = :is_priceplan;
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(title, "SELECT validkey_yn from priceplanmst")				
//	Return 1
//End If	

IF (is_svctype_in = is_svctype) or ( is_svctype_out = is_svctype) Then
	is_inout_svctype = 'Y'
End If
//
//저장
lu_dbmgr = Create b1u_dbmgr4_v20
lu_dbmgr.is_caller = "b1w_validkey_update_popup_1_1_v20_moohan%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = is_fromdt
lu_dbmgr.is_data[2]  = is_validkey						//변경전..
lu_dbmgr.is_data[3]  = is_pgm_id
lu_dbmgr.is_data[4]  = is_inout_svctype
//lu_dbmgr.is_data[4]  = is_xener_svc              //제너서비스여부
//lu_dbmgr.ii_data[1]  = ii_validkeytype_cnt         //validkeytype count
//khpark add 2005-07-11
lu_dbmgr.is_data[5]  = is_addition_code      	 //착신전환부가서비스코드
lu_dbmgr.is_data[6]  = is_addition_itemcod    	 //착신전환부가서비스품목
lu_dbmgr.il_data[1]  = il_callforward_seq        //착신전환정보 seq
lu_dbmgr.id_data[1]  = id_addition_item_todt  	 //착신전환부가서비스품목 todt

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Or li_rc = -2 or li_rc = -3 Then
	Rollback;
	Destroy lu_dbmgr
	Return -1
End If

Destroy lu_dbmgr

P_save.TriggerEvent("ue_disable")
dw_detail.enabled = False
cb_callingnum.enabled  = False

Return 0
end event

event type integer ue_extra_save();String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
String ls_validkey_type, ls_validkey_loc
Long ll_row, ll_cnt
String ls_callforwardno,ls_password,ls_callingnum_all

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then return 0

ls_validkey_type = fs_snvl(dw_detail.object.new_validkey_type[1], '')
ls_validkey      = fs_snvl(dw_detail.object.new_validkey[1]     , '')
ls_vpassword     = fs_snvl(dw_detail.object.new_vpassword[1]    , '')
ls_cid           = fs_snvl(dw_detail.object.cid[1]              , '')
ls_auth_method   = fs_snvl(dw_detail.object.new_auth_method[1]  , '')
ls_validkey_loc  = fs_snvl(dw_detail.object.new_validkey_loc[1] , '')
ls_ip_address    = fs_snvl(dw_detail.object.ip_address[1]       , '')
ls_h323id        = fs_snvl(dw_detail.object.h323id[1]           , '')

If ls_validkey_type = "" Then
	f_msg_usr_err(200, Title, "인증KeyType")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("new_validkey_type")
	return -1 
End If

IF is_crt_kind = is_crt_kind_code[1] or is_crt_kind = is_crt_kind_code[4] or is_crt_kind = is_crt_kind_code[5] Then
	If ls_validkey = "" Then
		f_msg_usr_err(200, Title, "인증 Key")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("new_validkey")
		return -1
	End If
End IF

If LeftA(ls_auth_method,2) = 'PA' Then
	If ls_vpassword = "" Then
		f_msg_usr_err(200, Title, "인증 Password")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("new_vpassword")
		return -1
	End If
End If

If LeftA(ls_auth_method,5) = 'STCIP' Then
	If ls_ip_address = "" Then
		f_msg_usr_err(200, Title, "IP ADDRESS")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("ip_address")
		return -1
	End If		
End if
	
If MidA(ls_auth_method,7,4) = 'BOTH' or  MidA(ls_auth_method,7,4) = 'H323' Then
	If ls_h323id = "" Then
		f_msg_usr_err(200, Title, "H323ID")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("h323id")
		return -1
	End If			
End IF

If ii_cnt > 0 Then    //인증KeyLocation 입력여부
	If ls_validkey_loc = "" Then
		f_msg_usr_err(200, Title, "인증KeyLocation")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("new_validkey_loc")
		Return	-1
	End If
End IF

//khpark add 2005-07-11 start
CHOOSE CASE is_addition_code   
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		
	CASE is_callforward_code[2]    //착신전환패스워드인증유형일때 

		ls_callforwardno = dw_detail.object.new_callforwardno[1]
		ls_password = dw_detail.object.new_password[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							
		If IsNull(ls_password) Then ls_password = ""							
		
		If ls_callforwardno <> "" Then
			If ls_password = "" Then
				f_msg_usr_err(200, Title, "착신전환Password")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				dw_detail.SetColumn("new_password")
				return -1
			End If		
		End if

	CASE is_callforward_code[3]    //착신전환발신인증유형일때
		ls_callforwardno = dw_detail.object.new_callforwardno[1]
		ls_callingnum_all = dw_detail.object.callingnum[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							
		If IsNull(ls_callingnum_all) Then ls_callingnum_all = ""							

		If ls_callforwardno <> "" Then
			If ls_callingnum_all = "" Then
				f_msg_usr_err(200, Title, "발신가능전화번호")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				dw_detail.SetColumn("new_callforwardno")
				return -1
			End If		
		End if
END CHOOSE
//khpark add 2005-07-11 start

return 0
end event

public function integer wfi_dw_detail_setting ();integer li_return
DataWindowChild ldc_validkey_type
Long li_exist, ll_result
String ls_filter

//인증KeyLocation 입력여부 
//ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccod, ii_cnt)
//IF ii_cnt > 0 Then
//	dw_detail.Object.new_validkey_loc.visible = True
//    dw_detail.Object.new_validkey_loc_t.visible = True
//Else
//	dw_detail.Object.new_validkey_loc.visible = False
//    dw_detail.Object.new_validkey_loc_t.visible = False
//End IF	
//
////가격정책별 인증KEYTYPE
//li_exist = dw_detail.GetChild("new_validkey_type", ldc_validkey_type)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
//ls_filter = "a.priceplan = '" + is_priceplan + "'  " 
//ldc_validkey_type.SetTransObject(SQLCA)
//li_exist =ldc_validkey_type.Retrieve()
//ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
//ldc_validkey_type.Filter()
//
//If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Retrieve()")
//  Return -1  		//선택 취소 focus는 그곳에
//End If

//khaprk add 2005-07-11 start
CHOOSE CASE is_addition_code
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		 dw_detail.Object.new_callforwardno.Protect = 0
		 dw_detail.Object.new_callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.new_callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.new_password.Protect = 1
		 dw_detail.Object.new_password.Color = RGB(0,0,0)
         dw_detail.Object.new_password.Background.Color =  RGB(255, 251, 240)			 	 	
		 cb_callingnum.enabled = False
	CASE is_callforward_code[2]     //착신전환비밀번호인증일때
		 dw_detail.Object.new_callforwardno.Protect = 0
		 dw_detail.Object.new_callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.new_callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.new_password.Protect = 0
		 dw_detail.Object.new_password.Color =  RGB(0,0,0)
         dw_detail.Object.new_password.Background.Color =  RGB(255,255,255)
    	 cb_callingnum.enabled = False
	CASE is_callforward_code[3]     //착신전환발신번호인증일때
		 dw_detail.Object.new_callforwardno.Protect = 0
		 dw_detail.Object.new_callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.new_callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.new_password.Protect = 1
		 dw_detail.Object.new_password.Color = RGB(0,0,0)
         dw_detail.Object.new_password.Background.Color =  RGB(255, 251, 240)	
		  cb_callingnum.enabled = True
	CASE ELSE
		 dw_detail.Object.new_callforwardno.Protect = 1
		 dw_detail.Object.new_callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.new_callforwardno.Background.Color =  RGB(255, 251, 240)			
		 dw_detail.Object.new_password.Protect = 1
		 dw_detail.Object.new_password.Color = RGB(0,0,0)
         dw_detail.Object.new_password.Background.Color =  RGB(255, 251, 240)			
		 cb_callingnum.enabled = False
END CHOOSE	
//khaprk add 2005-07-11 end

//해당 가격정책에 VALIDTIEM에 따른 info 가져오기
li_return = b1fi_validitem_info_v20(this.title,is_priceplan,is_validitem_yn,is_validkey_type_h,is_crt_kind_h,is_prefix_h,il_length_h,is_auth_method_h,is_type_h, is_used_level_h) 

If li_return = -1 Then
    return -1
End IF

dw_detail.Object.h323id.Pointer = "Arrow!"
//dw_detail.idwo_help_col[2] = dw_detail.Object.gu
	
IF is_validitem_yn = 'Y' Then	
	
	Choose Case is_crt_kind_h		
		Case is_crt_kind_code[1]                         //수동Manual
			dw_detail.Object.h323id.protect = 0
			dw_detail.Object.h323id.Pointer = "Arrow!"
		//	dw_detail.idwo_help_col[2] = dw_detail.Object.gu
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
	
			dw_detail.Object.h323id.protect = 1
			dw_detail.Object.h323id.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.h323id.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]                        //자원관리Resource
			
			dw_detail.Object.h323id.Protect   = 1
//			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
//			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)
			
			dw_detail.Object.h323id.Pointer   = "Help!"
			dw_detail.idwo_help_col[2] = dw_detail.Object.h323id
			dw_detail.is_help_win[2] = "b1w_hlp_validkeymst_v20"
			dw_detail.is_data[1] = "CloseWithReturn"
			dw_detail.is_data[2] = is_reg_partner         //유치처
			dw_detail.is_data[3] = is_priceplan           //가격정책
	
		Case is_crt_kind_code[5]              //고객대체
		
			dw_detail.Object.h323id.Protect   = 0
//			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
//			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)	

// 			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
//			Else
				dw_detail.Object.h323id[1] = is_customerid
//			End IF			
		
	End Choose
End IF

return  0
end function

public function integer wf_validkey_setting ();integer li_return

If is_validkey_type <> "" Then
	
	//validkey_type에 따른 info 가져오기
	li_return = b1fi_validkey_type_info_v20(this.title,is_validkey_type,is_validkey_typenm,is_crt_kind,is_prefix,il_length,is_auth_method,is_type,is_used_level) 

	If li_return = -1 Then
	    return -1
	End IF

	is_reg_partner = dw_detail.Object.reg_partner[1]
	is_customerid  = dw_detail.Object.customerid[1]
	
	dw_detail.Object.new_auth_method[1] = is_auth_method

	dw_detail.Object.new_validkey.Pointer    = "Arrow!"
	// 몰라 dw_detail.idwo_help_col[1] = dw_detail.Object.gu

	Choose Case is_crt_kind			
		Case is_crt_kind_code[1]         //수동Manual
			dw_detail.Object.new_validkey.protect = 0
			dw_detail.Object.new_validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.new_validkey.Color = RGB(255, 255, 255)
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
	
			dw_detail.Object.new_validkey.protect = 1
			dw_detail.Object.new_validkey.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.new_validkey.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]         //자원관리Resource
			
			dw_detail.Object.new_validkey.Protect = 1
			dw_detail.Object.new_validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.new_validkey.Color = RGB(255, 255, 255)
			
			dw_detail.Object.new_validkey.Pointer = "Help!"
			dw_detail.idwo_help_col[1] = dw_detail.Object.new_validkey
			dw_detail.is_help_win[1] = "b1w_hlp_validkeymst_v20"
			dw_detail.is_data[1] = "CloseWithReturn"
			dw_detail.is_data[2] = is_reg_partner       //유치처
			dw_detail.is_data[3] = is_priceplan         //가격정책

		Case is_crt_kind_code[5]         //고객대체
		
			dw_detail.Object.new_validkey.Protect   = 0
			dw_detail.Object.new_validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.new_validkey.Color = RGB(255, 255, 255)	
			 
//			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
//			Else
				dw_detail.Object.new_validkey[1] = is_customerid
//			End IF			
		
	End Choose

End IF

Return 0
end function

on b1w_validkey_update_popup_1_1_v20_mh.create
int iCurrent
call super::create
this.cb_callingnum=create cb_callingnum
this.dw_detail=create dw_detail
this.p_save=create p_save
this.p_close=create p_close
this.ln_2=create ln_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_callingnum
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.ln_2
end on

on b1w_validkey_update_popup_1_1_v20_mh.destroy
call super::destroy
destroy(this.cb_callingnum)
destroy(this.dw_detail)
destroy(this.p_save)
destroy(this.p_close)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_1_1
	Desc	: 인증KEY 추가
	Ver	: 	2.0     
	Date	: 	2004.06.02
	Programer : Park Kyung Hae(parkkh)
	            kem modify 2005.11.09
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
long ll_i

f_center_window(b1w_validkey_update_popup_1_1_v20_mh)
is_validkey = ""
is_fromdt = ""

iu_cust_msg = Message.PowerObjectParm
is_validkey = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_fromdt = iu_cust_msg.is_data[3]
is_svccod = iu_cust_msg.is_data[4]
is_svctype = iu_cust_msg.is_data[5]
is_contractseq = iu_cust_msg.is_data[6]       //계약번호
is_addition_itemcod = iu_cust_msg.is_data[7]  //착신전환부가서비스품목
is_addition_code = iu_cust_msg.is_data[8]     //착신전환부가서비스코드
is_callforward_yn = iu_cust_msg.is_data[9]    //착신전환부가서비스여부
is_callforwardno = iu_cust_msg.is_data[10]    //착신전환번호
is_call_password = iu_cust_msg.is_data[11]    //착신전환Password
il_callforward_seq = iu_cust_msg.il_data[1]   //착신전환정보 seq
id_addition_item_todt = iu_cust_msg.id_data[1] //착신전환부가서비스품목 todt

//ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre  = fs_get_control("B0", "P101", ls_ref_desc)   //선불서비스타입
is_svctype_in   = fs_get_control("B0", "P108", ls_ref_desc)   //입중계서비스타입
is_svctype_out  = fs_get_control("B0", "P109", ls_ref_desc)   //출중계서비스타

//부가서비스유형코드(착신전환부가서비스코드)
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_callforward_code[])		

//할당모듈 사용여부
//ls_ref_desc = ""
//is_req_yn = fs_get_control("B1", "P401", ls_ref_desc)
//If is_req_yn = "" Then is_req_yn= "N"
//
//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_crt_kind_code[]) 

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	Return
End If

IF is_svctype = is_svctype_post or is_svctype = is_svctype_in or is_svctype = is_svctype_out Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_1_1_v20_mh"
    dw_detail.Trigger Event Constructor()
//	dw_detail.SetTransObject(SQLCA)
Elseif is_svctype = is_svctype_pre Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_1_pre_v20_mh"
    dw_detail.Trigger Event Constructor()
//	dw_detail.SetTransObject(SQLCA)	
End If

//is_xener_svc = 'N'
//For ll_i = 1  to UpperBound(is_Xener_svccod)
//	IF is_svccod = is_Xener_svccod[ll_i] Then
//		is_xener_svc = 'Y'
//		Exit
//	End IF
//NEXT	

If is_validkey <> "" Then
	Post Event ue_ok()
End If
end event

type cb_callingnum from commandbutton within b1w_validkey_update_popup_1_1_v20_mh
integer x = 1413
integer y = 1828
integer width = 704
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "발신가능전화번호 등록"
end type

event clicked;String ls_callingnum_all, ls_pgm_gu,ls_callforwardno

dw_detail.accepttext()

CHOOSE CASE is_addition_code 
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		return 0		
	CASE is_callforward_code[2]    //착신전환패스워드인증유형일때 
		return 0
	CASE is_callforward_code[3]    //착신전환발신인증유형일때
		ls_callforwardno = dw_detail.object.new_callforwardno[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							

		If ls_callforwardno = "" Then
			f_msg_usr_err(200, Title, "착신전환번호")
			dw_detail.SetColumn("new_callforwardno")
			return -1
		End if
END CHOOSE

ls_callingnum_all = dw_detail.object.callingnum[1] 
If isnull(ls_callingnum_all) Then
	ls_callingnum_all = ''
	ls_pgm_gu = 'First'
Else
	ls_pgm_gu = 'NotFirst'
End IF	

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "발신가능전화번호등록"
iu_cust_msg.is_grp_name = "인증정보변경"
iu_cust_msg.is_data[1] = ls_pgm_gu                            //프로그램 구분
iu_cust_msg.is_data[2] = dw_detail.object.new_validkey[1]         //validkey
iu_cust_msg.is_data[3] = dw_detail.object.new_callforwardno[1]    //착신번환번호
iu_cust_msg.is_data[4] = ls_callingnum_all                    //발신가능전화번호(묶음)
iu_cust_msg.idw_data[1] = dw_detail 

OpenWithParm(b1w_reg_callforwarding_auth_pop_v20, iu_cust_msg)
end event

type dw_detail from u_d_help within b1w_validkey_update_popup_1_1_v20_mh
integer x = 37
integer y = 48
integer width = 2789
integer height = 1744
integer taborder = 10
string dataobject = "b1dw_validkey_update_popup_1_pre_v20_mh"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event ue_init();call super::ue_init;////Help Window
////validkeymst ID help
//This.is_help_win[1] = "b1w_hlp_validkeymst"
//This.idwo_help_col[1] = This.Object.new_validkey
//This.is_data[1] = "CloseWithReturn"
//This.is_data[2] = is_req_yn
////dw_detial retrieveend()에 정의 되어 있음.
////This.is_data[3] = This.Object.contractmst_reg_partne                r[1]
//


//Help Window
This.idwo_help_col[1] = This.Object.new_validkey
This.is_help_win[1] = "b1w_hlp_validkeymst_v20"
This.is_data[1] = "CloseWithReturn"
This.is_data[2] = is_req_yn

//유치파트너
This.idwo_help_col[2] = This.Object.h323id
This.is_help_win[2] = "b1w_hlp_validkeymst_v20"

end event

event doubleclicked;//Choose Case dwo.name
//	Case "new_validkey"
//		If ii_validkeytype_cnt > 0 Then
//			If dw_detail.iu_cust_help.ib_data[1] Then
//				 dw_detail.Object.new_validkey[row] = dw_detail.iu_cust_help.is_data[1]
//
//			End If
//		End IF
//End Choose
//
//Return 0 

//조상script 차후에 실행한다. validkey_type, used_level 데이타값 넘겨주기 위함

IF dwo.name = "new_validkey" Then
	IF is_crt_kind_code[4] <> is_crt_kind Then return
	If is_validkey_type = "" Then
		f_msg_usr_err(200, Title, "인증KeyType")
		dw_detail.SetRow(1)
		dw_detail.ScrollToRow(1)
		dw_detail.SetColumn("new_validkey_type")
		return -1 
	End If
   this.is_data[4] = is_validkey_type	     //validkey_type
	this.is_data[5] = is_used_level          //대리점의 인증Key사용권한
ElseIf dwo.name = "h323id" Then
		
	IF is_crt_kind_code[4] <> is_crt_kind_h Then return
   this.is_data[4] = is_validkey_type_h     //validkey_type
	this.is_data[5] = is_used_level_h        //대리점의 인증Key사용권한
End If

Call u_d_help::doubleclicked

If dwo.name = "new_validkey" Then
    IF is_crt_kind = is_crt_kind_code[4] Then   //type이 자원관리일 경우만
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.new_validkey[row] = dw_detail.iu_cust_help.is_data[1]
		End If
	End If
ElseIf dwo.name = "h323id" Then
    IF is_crt_kind_h = is_crt_kind_code[4] Then  //type이 자원관리일 경우만
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.h323id[row] = dw_detail.iu_cust_help.is_data[1]
		End If
	End If	
End If

Return 0
end event

event retrieveend;call super::retrieveend;//String ls_filter
//Long   li_exist, ll_result
//DataWindowChild ldc_validkey_type
//
is_priceplan= This.Object.priceplan[1]
IF IsNull(is_priceplan) Then is_priceplan = ""
//
////This.object.new_validkey.Pointer = "Arrow!"
////This.idwo_help_col[1] = This.object.contractmst_reg_partner
////This.object.new_validkey.Protect = 0
////
////validkeytype에 존재하면 edit 불가 (Help 사용)
//IF b1fi_validkeytype_check(parent.title,is_priceplan, ii_validkeytype_cnt) > 0 Then
//   IF ii_validkeytype_cnt > 0 Then
//	   This.object.new_validkey.Pointer = "help!"
//	   This.idwo_help_col[1] = This.object.new_validkey
//	   This.object.new_validkey.Protect = 1
//   End IF
//End IF
//
////해당가격정책에 해당하는 validkeymst Help validkeytype 찾기 위함.
//This.is_data[4] = is_priceplan
////인증KEY관리 할당 모듈 사용시 validkeymst Help에 partner조건 추가위함.
//IF is_req_yn= "Y" Then
//	This.is_data[3] = This.Object.contractmst_reg_partner[1]
//Else
//	This.is_data[3] = ''
//End IF
//
////가격정책별 인증KEYTYPE
//li_exist = This.GetChild("new_validkey_type", ldc_validkey_type)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
//ls_filter = "a.priceplan = '" + is_priceplan  + "'  " 
//ldc_validkey_type.SetTransObject(SQLCA)
//li_exist =ldc_validkey_type.Retrieve()
//ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
//ldc_validkey_type.Filter()
//
//If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Retrieve()")
//  Return 1  		//선택 취소 focus는 그곳에
//End If
//
////해당 Priceplan 인증KeyLocation 입력여부 
////ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccod, ii_cnt)
////
//////인증Key Location 입력여부
////IF ii_cnt > 0 Then
////	dw_detail.Object.new_validkey_loc.visible = True
////	dw_detail.Object.new_validkey_loc_t.visible = True
////Else
////	dw_detail.Object.new_validkey_loc.visible = False
////	dw_detail.Object.new_validkey_loc_t.visible = False
////End IF
end event

event itemchanged;call super::itemchanged;integer li_return

CHOOSE Case dwo.name

    Case "new_validkey_type"
		
		is_validkey_type = data		

		dw_detail.Object.new_validkey[1] = ""
     	dw_detail.Object.ip_address[1] = ""
    	dw_detail.Object.h323id[1] = ""
		
		//dw_detail validkey 셋팅값
		wf_validkey_setting()	

End CHoose
end event

event constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_save from u_p_save within b1w_validkey_update_popup_1_1_v20_mh
integer x = 2194
integer y = 1828
boolean originalsize = false
end type

type p_close from u_p_close within b1w_validkey_update_popup_1_1_v20_mh
integer x = 2537
integer y = 1828
boolean originalsize = false
end type

type ln_2 from line within b1w_validkey_update_popup_1_1_v20_mh
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

