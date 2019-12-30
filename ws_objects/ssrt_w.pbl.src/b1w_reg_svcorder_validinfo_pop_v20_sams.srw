$PBExportHeader$b1w_reg_svcorder_validinfo_pop_v20_sams.srw
$PBExportComments$서비스개통신청인증정보등록/조회
forward
global type b1w_reg_svcorder_validinfo_pop_v20_sams from w_a_reg_m
end type
type p_cancel from u_p_cancel within b1w_reg_svcorder_validinfo_pop_v20_sams
end type
type cb_callingnum from commandbutton within b1w_reg_svcorder_validinfo_pop_v20_sams
end type
end forward

global type b1w_reg_svcorder_validinfo_pop_v20_sams from w_a_reg_m
integer width = 3173
integer height = 696
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
p_cancel p_cancel
cb_callingnum cb_callingnum
end type
global b1w_reg_svcorder_validinfo_pop_v20_sams b1w_reg_svcorder_validinfo_pop_v20_sams

type variables
integer 		ii_cnt
Long 			il_length, il_length_h, 	il_row

String 		is_pgm_gu, is_validkey_type, is_langtype, is_auth_method
String 		is_validkey_typenm, is_crt_kind, is_prefix, is_type, is_crt_kind_code[]
String 		is_crt_kind_h, is_prefix_h, is_type_h, is_auth_method_h, is_validkey_type_h
String 		is_reg_partner, is_priceplan, is_customerid, is_first_gu
String 		is_close_gu, is_validitem_yn, is_used_level, is_used_level_h, &
				is_partner

datawindow idw_data

String is_callforward_type,is_callforward_code[] //2005-07-06 khpark add


end variables

forward prototypes
public function integer wf_validkey_setting ()
public function integer wfi_dw_detail_setting ()
end prototypes

public function integer wf_validkey_setting ();integer li_return

If is_validkey_type <> "" Then
	
	//validkey_type에 따른 info 가져오기
	li_return = b1fi_validkey_type_info_v20(this.title,is_validkey_type,is_validkey_typenm,is_crt_kind,is_prefix,il_length,is_auth_method,is_type,is_used_level) 

	If li_return = -1 Then
	    return -1
	End IF

	dw_detail.Object.auth_method[1] = is_auth_method

	dw_detail.Object.validkey.Pointer    = "Arrow!"
	dw_detail.idwo_help_col[1] = dw_detail.Object.gu

	Choose Case is_crt_kind			
		Case is_crt_kind_code[1]         //수동Manual
			dw_detail.Object.validkey.protect = 0
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
	
			dw_detail.Object.validkey.protect = 1
			dw_detail.Object.validkey.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.validkey.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]         //자원관리Resource
			
			dw_detail.Object.validkey.Protect = 1
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
			dw_detail.Object.validkey.Pointer = "Help!"
			dw_detail.idwo_help_col[1] = dw_detail.Object.validkey
			dw_detail.is_help_win[1] = "b1w_hlp_validkeymst_v20_SAMS"
			dw_detail.is_data[1] = "CloseWithReturn"
			dw_detail.is_data[2] = is_reg_partner       //유치처
			dw_detail.is_data[3] = is_priceplan         //가격정책

		Case is_crt_kind_code[5]         //고객대체
		
			dw_detail.Object.validkey.Protect   = 0
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)	
			 
			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
			Else
				dw_detail.Object.validkey[1] = is_customerid
			End IF			
		
	End Choose

End IF

return 0
end function

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
		 cb_callingnum.enabled = False
	CASE is_callforward_code[2]     //착신전환비밀번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.password.Protect = 0
		 dw_detail.Object.password.Color =  RGB(0,0,0)
         dw_detail.Object.password.Background.Color =  RGB(255,255,255)
    	 cb_callingnum.enabled = False
	CASE is_callforward_code[3]     //착신전환발신번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.callforwardno.Background.Color =  RGB(255,255,255)
		 dw_detail.Object.password.Protect = 1
		 dw_detail.Object.password.Color = RGB(0,0,0)
         dw_detail.Object.password.Background.Color =  RGB(255, 251, 240)	
		  cb_callingnum.enabled = True
	CASE ELSE
		 dw_detail.Object.callforwardno.Protect = 1
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
         dw_detail.Object.callforwardno.Background.Color =  RGB(255, 251, 240)			
		 dw_detail.Object.password.Protect = 1
		 dw_detail.Object.password.Color = RGB(0,0,0)
         dw_detail.Object.password.Background.Color =  RGB(255, 251, 240)			
		 cb_callingnum.enabled = False
END CHOOSE	

//가격정책별 인증KEYTYPE
li_exist = dw_detail.GetChild("validkey_type", ldc_validkey_type)		//DDDW 구함
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

dw_detail.Object.validitem3.Pointer = "Arrow!"
dw_detail.idwo_help_col[2] = dw_detail.Object.gu
	
IF is_validitem_yn = 'Y' Then	
	
	Choose Case is_crt_kind_h		
		Case is_crt_kind_code[1]                         //수동Manual
			dw_detail.Object.validitem3.protect = 0
			dw_detail.Object.validitem3.Pointer = "Arrow!"
			dw_detail.idwo_help_col[2] = dw_detail.Object.gu
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
	
			dw_detail.Object.validitem3.protect = 1
			dw_detail.Object.validitem3.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.validitem3.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]                        //자원관리Resource
			
			dw_detail.Object.validitem3.Protect   = 1
//			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
//			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)
			
			dw_detail.Object.validitem3.Pointer   = "Help!"
			dw_detail.idwo_help_col[2] = dw_detail.Object.validitem3
			dw_detail.is_help_win[2] = "b1w_hlp_validkeymst_v20_SAMS"
			dw_detail.is_data[1] = "CloseWithReturn"
			dw_detail.is_data[2] = is_reg_partner         //유치처
			dw_detail.is_data[3] = is_priceplan           //가격정책
	
		Case is_crt_kind_code[5]              //고객대체
		
			dw_detail.Object.validitem3.Protect   = 0
//			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
//			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)	

 			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
			Else
				dw_detail.Object.validitem3[1] = is_customerid
			End IF			
		
	End Choose
End IF

return  0
end function

on b1w_reg_svcorder_validinfo_pop_v20_sams.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
this.cb_callingnum=create cb_callingnum
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
this.Control[iCurrent+2]=this.cb_callingnum
end on

on b1w_reg_svcorder_validinfo_pop_v20_sams.destroy
call super::destroy
destroy(this.p_cancel)
destroy(this.cb_callingnum)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder_validinfo_pop_v20
	Desc	: 	서비스개통신청(인증정보등록)- popup
	Ver.	:	1.0
	Date	: 	2005.04.13
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/
Long ll_row
integer li_return
String ls_where, ls_ref_desc, ls_temp, ls_svccod, ls_filter
Datawindowchild ldc_wkflag2

//window 중앙에
f_center_window(this)

iu_cust_msg 			= Message.PowerObjectParm
is_pgm_gu 				= iu_cust_msg.is_data[1]            //프로그램 구분
is_validkey_type 		= iu_cust_msg.is_data[2]     //validkey_type
is_langtype 			= iu_cust_msg.is_data[3]          //langtype(언어멘트)
is_priceplan 			= iu_cust_msg.is_data[4]         //가격정책
is_reg_partner 		= iu_cust_msg.is_data[5]       //유치처
is_customerid 			= iu_cust_msg.is_data[6]        //고객번호
ls_svccod     			= iu_cust_msg.is_data[8]  
is_partner    			= iu_cust_msg.is_data[9]  //SHOPID

ii_cnt 					= iu_cust_msg.ii_data[1]               //발신지Location check yn ii_cnt
il_row 					= iu_cust_msg.il_data[1]               //현재row
idw_data 				= iu_cust_msg.idw_data[1]
//2005-07-06 khpark add
is_callforward_type = iu_cust_msg.is_data[7]  //착신전환유형

//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_crt_kind_code[]) 

//부가서비스유형코드  //2005-07-06 khpark add
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_callforward_code[])

IF is_pgm_gu = 'Ue_extra_insert' Then
    //insert
	li_return = This.Trigger Event ue_insert()
	
	If li_return < 0 Then
		Return
	End if
	
Else
    
	//dw_detail의 dddw의 retrieve를 위해서
	//b1w_reg_svc_actorder_v20 에서 더블클릭시 해당 루틴탄다.
	//이때,dw_detail에 한건도 없을 경우 dddw가 셋팅이 제대로 되지 않아 insertrow 하고 deleterow한후, rowscopy한다.
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

ll_row = dw_detail.GetChild("langtype", ldc_wkflag2)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod = '" + ls_svccod + "' "
ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
ldc_wkflag2.Filter()
ldc_wkflag2.SetTransObject(SQLCA)
ll_row = ldc_wkflag2.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
	Return -1
End If

p_save.TriggerEvent("ue_enable")
end event

event resize;call super::resize;SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_save.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
else
	p_save.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space
End If


cb_callingnum.Y = p_save.Y

SetRedraw(True)

end event

event type integer ue_extra_save();String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
String ls_validkey_type, ls_validkey_loc, ls_callforwardno, ls_password,ls_callingnum_all
Long ll_row, ll_cnt

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then return 0

ls_validkey_type = dw_detail.object.validkey_type[1]
ls_validkey = trim(dw_detail.object.validkey[1])
ls_vpassword = dw_detail.object.vpassword[1]
ls_cid  = dw_detail.object.validitem1[1]
ls_auth_method = dw_detail.object.auth_method[1]
ls_validkey_loc = dw_detail.object.validkey_loc[1]
If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_vpassword) Then ls_vpassword = ""
If IsNull(ls_cid) Then ls_cid = ""
If IsNull(ls_auth_method) Then ls_auth_method = ""		
If IsNull(ls_validkey_loc) Then ls_validkey_loc = ""
ls_ip_address = dw_detail.object.validitem2[1]
If IsNull(ls_ip_address) Then ls_ip_address = ""				
ls_h323id = dw_detail.object.validitem3[1]
If IsNull(ls_h323id) Then ls_h323id = ""							

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

event type integer ue_insert();call super::ue_insert;long ll_row
integer li_return
String ls_validkey_type

ll_row = dw_detail.getrow()
//default 셋팅
dw_detail.object.validkey_type[ll_row] = is_validkey_type
dw_detail.object.langtype[ll_row] = is_langtype

return 0 
end event

event close;call super::close;long ll_row 

ll_row = dw_detail.getrow()

IF is_close_gu = "CANCEL" Then     //close 버튼 클릭 시 check , cancle 버튼 클릭시는 취소
Else
	IF is_pgm_gu = 'Ue_extra_insert' Then
	   //복사한다.
	   dw_detail.RowsCopy(ll_row,ll_row, &
										Primary!,idw_data,il_row, Primary!)
	Else
	    //doubleclicked에서 popup창 띄웠을 경우 해당row 변경해야 하므로 해당row delete 후 변경사항 rowcopy
		idw_data.deleterow(il_row)
		dw_detail.RowsCopy(ll_row,ll_row, &
									Primary!,idw_data,il_row, Primary!)
	End IF
End IF
end event

event closequery;integer li_return

IF is_close_gu = "CANCEL" Then     //close 버튼 클릭 시 check , cancle 버튼 클릭시는 취소
Else
	is_close_gu = "APPLY"
	//입력값 check
	li_return = This.Trigger Event ue_extra_save()

	If li_return < 0 Then
		Return -1
    End if

End IF


end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer x = 59
integer y = 420
integer width = 1810
integer height = 52
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validinfo_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer x = 782
integer y = 476
boolean enabled = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer width = 2199
integer height = 56
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_svcorder_validinfo_pop_v20_sams
integer x = 2665
integer y = 472
boolean enabled = true
boolean originalsize = true
end type

event p_save::clicked;Parent.TriggerEvent('ue_close')
end event

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_svcorder_validinfo_pop_v20_sams
integer y = 52
integer width = 3072
integer height = 360
integer taborder = 20
string dataobject = "b1dw_reg_svcorder_validinfo_pop_v20_sams"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;integer li_return

CHOOSE Case dwo.name

    Case "validkey_type"
		
		is_validkey_type = data		

		dw_detail.Object.validkey[1] = ""
     	dw_detail.Object.validitem2[1] = ""
    	dw_detail.Object.validitem3[1] = ""
		
		//dw_detail validkey 셋팅값
		wf_validkey_setting()	

End CHoose
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

//Help Window
This.idwo_help_col[1] 	= This.Object.validkey
This.is_help_win[1] 		= "b1w_hlp_validkeymst_v20_sams"
This.is_data[1] 			= "CloseWithReturn"

//유치파트너
This.idwo_help_col[2] = This.Object.validitem3
This.is_help_win[2] = "b1w_hlp_validkeymst_v20_sams"
end event

event dw_detail::doubleclicked;//조상script 차후에 실행한다. validkey_type, used_level 데이타값 넘겨주기 위함
IF dwo.name = "validkey" Then    //
	If is_validkey_type = "" Then
		f_msg_usr_err(200, Title, "인증KeyType")
		dw_detail.SetRow(1)
		dw_detail.ScrollToRow(1)
		dw_detail.SetColumn("validkey_type")
		return -1 
	End If
   this.is_data[4]	 	= is_validkey_type	     //validkey_type
	this.is_data[5] 		= is_used_level          //대리점의 인증Key사용권한
	this.is_data[6] 		= is_partner  	        //대리점
	
ElseIf dwo.name = "validitem3" Then
    this.is_data[4] = is_validkey_type_h     //validkey_type
	this.is_data[5] = is_used_level_h        //대리점의 인증Key사용권한
End If

Call u_d_help::doubleclicked

If dwo.name = "validkey" Then
    IF is_crt_kind = is_crt_kind_code[4] Then   //type이 자원관리일 경우만
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.validkey[row] = &
			dw_detail.iu_cust_help.is_data[1]
		End If
	End If
ElseIf dwo.name = "validitem3" Then
    IF is_crt_kind_h = is_crt_kind_code[4] Then  //type이 자원관리일 경우만
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.validitem3[row] = &
			dw_detail.iu_cust_help.is_data[1]
		End If
	End If	
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_svcorder_validinfo_pop_v20_sams
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type p_cancel from u_p_cancel within b1w_reg_svcorder_validinfo_pop_v20_sams
integer x = 2327
integer y = 472
integer height = 96
boolean bringtotop = true
end type

event clicked;call super::clicked;is_close_gu = "CANCEL"
close(parent)
end event

type cb_callingnum from commandbutton within b1w_reg_svcorder_validinfo_pop_v20_sams
integer x = 1408
integer y = 476
integer width = 841
integer height = 88
integer taborder = 30
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "발신가능전화번호 등록/조회"
end type

event clicked;String ls_callingnum_all, ls_pgm_gu,ls_callforwardno

dw_detail.accepttext()

CHOOSE CASE is_callforward_type    
	CASE is_callforward_code[1]    //착신전환일반유형일때 
		return 0		
	CASE is_callforward_code[2]    //착신전환패스워드인증유형일때 
		return 0
	CASE is_callforward_code[3]    //착신전환발신인증유형일때
		ls_callforwardno = dw_detail.object.callforwardno[1]
		If IsNull(ls_callforwardno) Then ls_callforwardno = ""							

		If ls_callforwardno = "" Then
			f_msg_usr_err(200, Title, "착신전환번호")
			dw_detail.SetColumn("callforwardno")
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
iu_cust_msg.is_pgm_name = "발신가능전화번호등록/조회"
iu_cust_msg.is_grp_name = "서비스개통신청/인증정보등록"
iu_cust_msg.is_data[1] = ls_pgm_gu                            //프로그램 구분
iu_cust_msg.is_data[2] = dw_detail.object.validkey[1]         //validkey
iu_cust_msg.is_data[3] = dw_detail.object.callforwardno[1]    //착신번환번호
iu_cust_msg.is_data[4] = ls_callingnum_all                    //발신가능전화번호(묶음)
iu_cust_msg.idw_data[1] = dw_detail 

OpenWithParm(b1w_reg_callforwarding_auth_pop_v20, iu_cust_msg)
end event

