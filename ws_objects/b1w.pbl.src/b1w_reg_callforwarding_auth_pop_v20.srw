$PBExportHeader$b1w_reg_callforwarding_auth_pop_v20.srw
$PBExportComments$[parkkh]서비스개통신청인증정보등록/조회
forward
global type b1w_reg_callforwarding_auth_pop_v20 from w_a_reg_m
end type
type p_cancel from u_p_cancel within b1w_reg_callforwarding_auth_pop_v20
end type
end forward

global type b1w_reg_callforwarding_auth_pop_v20 from w_a_reg_m
integer width = 2711
integer height = 1072
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
p_cancel p_cancel
end type
global b1w_reg_callforwarding_auth_pop_v20 b1w_reg_callforwarding_auth_pop_v20

type variables
String is_pgm_gu, is_validkey_type, is_langtype, is_auth_method
integer ii_cnt
String is_validkey_typenm, is_crt_kind, is_prefix, is_type, is_crt_kind_code[]
String is_crt_kind_h, is_prefix_h, is_type_h, is_auth_method_h, is_validkey_type_h
Long il_length, il_length_h
String is_reg_partner, is_priceplan, is_customerid, is_first_gu
String is_close_gu, is_validitem_yn, is_used_level, is_used_level_h
Long il_row
datawindow idw_data

String is_callforward_type,is_callforward_code[] //2005-07-06 khpark add
String is_callforwardno,is_validkey,is_callingnum_all,is_callingnum[]


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
			dw_detail.is_help_win[1] = "b1w_hlp_validkeymst_v20"
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
		 dw_detail.Object.callforwardno.Color = RGB(255,255,255)
       dw_detail.Object.callforwardno.Background.Color =  RGB(108, 147, 137)	
		 dw_detail.Object.passward.Protect = 1
		 dw_detail.Object.passward.Color = RGB(0,0,0)
       dw_detail.Object.passward.Background.Color =  RGB(255, 251, 240)			 	 	
	CASE is_callforward_code[2]     //착신전환비밀번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(255,255,255)
       dw_detail.Object.callforwardno.Background.Color =  RGB(108, 147, 137)	
		 dw_detail.Object.passward.Protect = 0
		 dw_detail.Object.passward.Color = RGB(255,255,255)
       dw_detail.Object.passward.Background.Color =  RGB(108, 147, 137)		
	CASE is_callforward_code[3]     //착신전환발신번호인증일때
		 dw_detail.Object.callforwardno.Protect = 0
		 dw_detail.Object.callforwardno.Color = RGB(255,255,255)
       dw_detail.Object.callforwardno.Background.Color =  RGB(108, 147, 137)	
		 dw_detail.Object.passward.Protect = 1
		 dw_detail.Object.passward.Color = RGB(0,0,0)
       dw_detail.Object.passward.Background.Color =  RGB(255, 251, 240)		
	CASE ELSE
		 dw_detail.Object.callforwardno.Protect = 1
		 dw_detail.Object.callforwardno.Color = RGB(0,0,0)
       dw_detail.Object.callforwardno.Background.Color =  RGB(255, 251, 240)			
		 dw_detail.Object.passward.Protect = 1
		 dw_detail.Object.passward.Color = RGB(0,0,0)
       dw_detail.Object.passward.Background.Color =  RGB(255, 251, 240)			
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
			dw_detail.is_help_win[2] = "b1w_hlp_validkeymst_v20"
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

on b1w_reg_callforwarding_auth_pop_v20.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
end on

on b1w_reg_callforwarding_auth_pop_v20.destroy
call super::destroy
destroy(this.p_cancel)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_callforwarding_auth_pop_v20
	Desc	: 	서비스개통신청(발신가능전화번호등록)- popup
	Ver.	:	1.0
	Date	: 	2005.07.07
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/
Long ll_row, ll_i
integer li_return
String ls_where, ls_ref_desc, ls_temp

//window 중앙에
f_center_window(b1w_reg_callforwarding_auth_pop_v20)

iu_cust_msg = Message.PowerObjectParm
is_pgm_gu = iu_cust_msg.is_data[1]            //프로그램 구분
is_validkey = iu_cust_msg.is_data[2]          //validkey
is_callforwardno = iu_cust_msg.is_data[3]     //착신번환번호
is_callingnum_all = iu_cust_msg.is_data[4]    //발신가능전화번호
idw_data = iu_cust_msg.idw_data[1]

IF is_pgm_gu = 'First' Then
    //insert
	li_return = This.Trigger Event ue_insert()
	
	If li_return < 0 Then
		Return
	End if
	
Else
	//발신가능전화번호 짜르기...
    fi_cut_string(is_callingnum_all, ";", is_callingnum[])
    FOR ll_i= 1 TO UpperBound(is_callingnum[])
		ll_row = dw_detail.insertrow(0)
		dw_detail.object.validkey[ll_row] = is_validkey
		dw_detail.object.callforwardno[ll_row] = is_callforwardno
		dw_detail.object.callingnum[ll_row] = is_callingnum[ll_i]		
    NEXT
End IF

p_save.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
end event

event resize;call super::resize;SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_save.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
else
	p_save.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event type integer ue_insert();call super::ue_insert;long ll_row

ll_row = dw_detail.getrow()
//default 셋팅
dw_detail.object.validkey[ll_row] = is_validkey
dw_detail.object.callforwardno[ll_row] = is_callforwardno

return 0 
end event

event close;call super::close;long ll_row 

ll_row = dw_detail.getrow()

IF is_close_gu = "CANCEL" Then     //close 버튼 클릭 시 check , cancle 버튼 클릭시는 취소
Else
	idw_data.object.callingnum[1] = is_callingnum_all
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

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_callingnum, ls_callingnum_all

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

ls_callingnum_all = ""
//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_callingnum = Trim(dw_detail.Object.callingnum[ll_i])
	If IsNull(ls_callingnum) Then ls_callingnum = ""
	
	If ls_callingnum = "" Then 
		f_msg_usr_err(200, Title, "발신가능전화번호")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("callingnum")
		Return -1
	End If
	
	IF ll_i = ll_row Then
		ls_callingnum_all += ls_callingnum    //마지막행일때는 ';' 붙이지 않는다.
	Else
		ls_callingnum_all += ls_callingnum + ';'
	End IF
	
Next

is_callingnum_all = ls_callingnum_all

Return 0
	
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_callforwarding_auth_pop_v20
boolean visible = false
integer x = 23
integer y = 24
integer width = 1810
integer height = 264
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validinfo_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_callforwarding_auth_pop_v20
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within b1w_reg_callforwarding_auth_pop_v20
boolean visible = false
integer x = 2021
integer y = 684
boolean enabled = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_callforwarding_auth_pop_v20
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_callforwarding_auth_pop_v20
integer x = 1582
integer y = 796
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_callforwarding_auth_pop_v20
integer x = 1243
integer y = 796
end type

type p_save from w_a_reg_m`p_save within b1w_reg_callforwarding_auth_pop_v20
integer x = 2258
integer y = 796
boolean enabled = true
end type

event p_save::clicked;Parent.TriggerEvent('ue_close')
end event

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_callforwarding_auth_pop_v20
integer y = 52
integer width = 2597
integer height = 668
integer taborder = 20
string dataobject = "b1dw_reg_callforwarding_auth_pop_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_callforwarding_auth_pop_v20
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type p_cancel from u_p_cancel within b1w_reg_callforwarding_auth_pop_v20
integer x = 1920
integer y = 796
integer height = 96
boolean bringtotop = true
end type

event clicked;call super::clicked;is_close_gu = "CANCEL"
close(parent)
end event

