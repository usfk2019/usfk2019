$PBExportHeader$b1w_reg_svcorder_validinfo_pop_1_v20.srw
$PBExportComments$[parkkh]서비스개통신청인증정보등록/조회
forward
global type b1w_reg_svcorder_validinfo_pop_1_v20 from w_a_reg_m
end type
type p_cancel from u_p_cancel within b1w_reg_svcorder_validinfo_pop_1_v20
end type
end forward

global type b1w_reg_svcorder_validinfo_pop_1_v20 from w_a_reg_m
integer width = 3159
integer height = 768
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
p_cancel p_cancel
end type
global b1w_reg_svcorder_validinfo_pop_1_v20 b1w_reg_svcorder_validinfo_pop_1_v20

type variables
String is_pgm_gu, is_validkey_type, is_langtype, is_auth_method
integer ii_cnt
String is_validkey_typenm, is_crt_kind, is_prefix, is_type, is_crt_kind_code[]
String is_crt_kind_h, is_prefix_h, is_type_h, is_auth_method_h, is_validkey_type_h
Long il_length, il_length_h
String is_reg_partner, is_priceplan, is_customerid
String is_close_gu, is_validitem_yn, is_used_level, is_used_level_h, is_first_gu
Long il_row
datawindow idw_data


end variables

forward prototypes
public function integer wf_validkey_setting ()
end prototypes

public function integer wf_validkey_setting ();integer li_return

If is_validkey_type <> "" Then
	
	//validkey_type에 따른 info 가져오기
	li_return = b1fi_validkey_type_info_v20(this.title,is_validkey_type,is_validkey_typenm,is_crt_kind,is_prefix,il_length,is_auth_method,is_type,is_used_level) 

	If li_return = -1 Then
	
	End IF

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
			dw_detail.is_help_win[1] = "b1w_hlp_validkeymst_1_v20"
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

on b1w_reg_svcorder_validinfo_pop_1_v20.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
end on

on b1w_reg_svcorder_validinfo_pop_1_v20.destroy
call super::destroy
destroy(this.p_cancel)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svcorder_validinfo_pop_1_v20
	Desc	: 	서비스개통신청(route정보등록)- popup - 입출중계서비스일 경우
	Ver.	:	1.0
	Date	: 	2005.04.21.
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/
Long ll_row, li_exist
integer li_return
String ls_where, ls_ref_desc, ls_temp, ls_filter
DataWindowChild ldc_validkey_type

//window 중앙에
f_center_window(b1w_reg_svcorder_validinfo_pop_1_v20)

iu_cust_msg = Message.PowerObjectParm
is_pgm_gu = iu_cust_msg.is_data[1]            //프로그램 구분
is_validkey_type = iu_cust_msg.is_data[2]     //validkey_type
is_langtype = iu_cust_msg.is_data[3]          //langtype(언어멘트)
is_priceplan = iu_cust_msg.is_data[4]         //가격정책
is_reg_partner = iu_cust_msg.is_data[5]       //유치처
is_customerid = iu_cust_msg.is_data[6]        //고객번호
ii_cnt = iu_cust_msg.ii_data[1]               //발신지Location check yn ii_cnt
il_row = iu_cust_msg.il_data[1]               //현재row
idw_data = iu_cust_msg.idw_data[1]

//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_crt_kind_code[]) 

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
wf_validkey_setting()	
is_first_gu = 'N'   //셋팅관련

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

SetRedraw(True)

end event

event type integer ue_extra_save();String ls_validkey, ls_vpassword, ls_svccod, ls_priceplan, ls_svctype, ls_gkid
String ls_cid, ls_auth_method, ls_ip_address, ls_h323id, ls_pricemodel, ls_pid
String ls_validkey_type, ls_validkey_loc
Long ll_row, ll_cnt

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then return 0

ls_validkey_type = dw_detail.object.validkey_type[1]
ls_validkey = dw_detail.object.validkey[1]
If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_validkey_type = "" Then
	f_msg_usr_err(200, Title, "인증KeyType")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("validkey_type")
	return -1 
End If

IF is_crt_kind = is_crt_kind_code[1] or is_crt_kind = is_crt_kind_code[4] or is_crt_kind = is_crt_kind_code[5] Then
	If ls_validkey = "" Then
		f_msg_usr_err(200, Title, "Roue-No.")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetColumn("validkey")
		return -1
	End If
End IF

return 0
end event

event type integer ue_insert();call super::ue_insert;long ll_row
integer li_return
String ls_validkey_type

ll_row = dw_detail.getrow()
//default 셋팅
dw_detail.object.validkey_type[ll_row] = is_validkey_type

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

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_svcorder_validinfo_pop_1_v20
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

type p_ok from w_a_reg_m`p_ok within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
integer x = 2007
integer y = 540
boolean enabled = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_svcorder_validinfo_pop_1_v20
integer x = 2816
integer y = 532
boolean enabled = true
end type

event p_save::clicked;Parent.TriggerEvent('ue_close')
end event

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_svcorder_validinfo_pop_1_v20
integer y = 52
integer width = 3072
integer height = 424
integer taborder = 20
string dataobject = "b1dw_reg_svcorder_validinfo_pop_1_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;integer li_return

CHOOSE Case dwo.name
	
    Case "validkey_type"
		
		is_validkey_type = data	
		//dw_detail validkey 셋팅값
		wf_validkey_setting()	

End CHoose
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

//Help Window
This.idwo_help_col[1] = This.Object.validkey
This.is_help_win[1] = "b1w_hlp_validkeymst_v20"
This.is_data[1] = "CloseWithReturn"
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
    this.is_data[4] = is_validkey_type	     //validkey_type
	this.is_data[5] = is_used_level          //대리점의 인증Key사용권한
End If

Call u_d_help::doubleclicked

If dwo.name = "validkey" Then
    IF is_crt_kind = is_crt_kind_code[4] Then   //type이 자원관리일 경우만
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.validkey[row] = &
			dw_detail.iu_cust_help.is_data[1]
			dw_detail.Object.validitem1[row] = &
			dw_detail.iu_cust_help.is_data[2]
			dw_detail.Object.validitem2[row] = &
			dw_detail.iu_cust_help.is_data[3]
			dw_detail.Object.validitem3[row] = &
			dw_detail.iu_cust_help.is_data[4]			
		End If
	End If
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_svcorder_validinfo_pop_1_v20
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type p_cancel from u_p_cancel within b1w_reg_svcorder_validinfo_pop_1_v20
integer x = 2478
integer y = 532
integer height = 96
boolean bringtotop = true
end type

event clicked;call super::clicked;is_close_gu = "CANCEL"
close(parent)
end event

