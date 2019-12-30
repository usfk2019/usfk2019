$PBExportHeader$b1w_reg_svcorder_update_a.srw
$PBExportComments$[ceusee] 신청 내역 수정(All)
forward
global type b1w_reg_svcorder_update_a from w_a_reg_s
end type
end forward

global type b1w_reg_svcorder_update_a from w_a_reg_s
integer width = 2784
integer height = 1024
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global b1w_reg_svcorder_update_a b1w_reg_svcorder_update_a

type variables
String is_actorder, is_date_check, is_cancel
end variables

on b1w_reg_svcorder_update_a.create
call super::create
end on

on b1w_reg_svcorder_update_a.destroy
call super::destroy
end on

event open;call super::open;f_center_window(b1w_reg_svcorder_update_a)

String ls_orderno, ls_ref_desc

iu_cust_msg = Message.PowerObjectParm

ls_orderno = iu_cust_msg.is_data[1]
is_actorder = iu_cust_msg.is_data[2]  //개통 신청 상태
is_cancel = iu_cust_msg.is_data[3]  //해지 신청 상태 코드


is_date_check = fs_get_control("B0", "P210", ls_ref_desc)  //개통일 Check


Long ll_row
//조회
ll_row = dw_detail.Retrieve(ls_orderno)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
End If
end event

event ue_extra_save;String ls_reqdt, ls_partner, ls_sale_partner, ls_reg_partner, ls_maintain_partner
String ls_sysdt, ls_customerid, ls_svccod, ls_priceplan
LONG	 ll_svc_cnt, ll_price_cnt

ls_reqdt = String(dw_detail.object.requestdt[1], 'yyyymmdd')
ls_partner = Trim(dw_detail.object.partner[1])
ls_sysdt = String(fdt_get_dbserver_now(), 'yyyymmdd')
ls_customerid = Trim(dw_detail.object.customerid[1])
ls_svccod = Trim(dw_detail.object.svccod[1])
ls_priceplan = Trim(dw_detail.object.priceplan[1])

If IsNull(ls_reqdt) Then ls_reqdt = ""
If IsNull(ls_partner) Then ls_partner = ""

If ls_reqdt  = "" Then
	f_msg_usr_err(210, title, "신청요청일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("requestdt")
	Return -1
End If

SELECT COUNT(*) INTO :ll_svc_cnt
FROM   SYSCOD2T
WHERE  GRCODE = 'BOSS03'
AND    CODE   = :ls_svccod
AND    USE_YN = 'Y';

SELECT COUNT(*) INTO :ll_price_cnt
FROM   SYSCOD2T
WHERE  GRCODE = 'BOSS04'
AND    CODE   = :ls_svccod
AND    USE_YN = 'Y';

IF ll_svc_cnt > 0 THEN    //인증서비스이고
	IF ll_price_cnt <= 0 THEN			//예외 가격정책이 아니면
		IF ls_reqdt <= ls_sysdt THEN
			f_msg_usr_err(212, Title, "요청일을 당일로 변경하시면 인증 처리가 불가합니다. 취소후 작업바랍니다.")
			dw_detail.SetFocus()
			dw_detail.SetColumn("requestdt")
			Return -1
		END IF
	END IF
END IF

If dw_detail.object.status[1] = is_actorder or &
	dw_detail.object.status[1] = is_cancel Then
	
	If fb_reqdt_check(Title,ls_customerid,ls_reqdt,"개통요청일") Then
	Else
		dw_detail.SetFocus()
		dw_detail.SetColumn("requestdt")
		Return -1
	End If

	If is_date_check = 'Y' Then
		If ls_reqdt < ls_sysdt Then
			f_msg_usr_err(212, Title + "today:" + MidA(ls_sysdt, 1,4) + "-" + MidA(ls_sysdt, 5,2) + "-" + &
																MidA(ls_sysdt, 7,2), "신청요청일")
			dw_detail.SetFocus()
			dw_detail.SetColumn("requestdt")
			Return -1
		End If		
	End If
Else
	If ls_reqdt < ls_sysdt Then
			f_msg_usr_err(212, Title + "today:" + MidA(ls_sysdt, 1,4) + "-" + MidA(ls_sysdt, 5,2) + "-" + &
																MidA(ls_sysdt, 7,2), "신청요청일")
			dw_detail.SetFocus()
			dw_detail.SetColumn("requestdt")
			Return -1
		End If		
End If
 

If ls_partner  = "" Then
	f_msg_usr_err(210, title, "수행처")
	dw_detail.SetFocus()
	dw_detail.SetColumn("parter")
	Return -1
End If
//개통 신청 이면
If dw_detail.object.status[1] = is_actorder Then 
	
	ls_sale_partner = Trim(dw_detail.object.sale_partner[1])
	ls_reg_partner = Trim(dw_detail.object.reg_partner[1])
	ls_maintain_partner = Trim(dw_detail.object.maintain_partner[1])
	If IsNull(ls_sale_partner) Then ls_sale_partner = ""
	If IsNull(ls_reg_partner) Then ls_reg_partner = ""
	If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""
	
	
	If ls_reg_partner  = "" Then
		f_msg_usr_err(210, title, "유치처")
		dw_detail.SetFocus()
		dw_detail.SetColumn("reg_partner")
		Return -1
	End If

	If ls_sale_partner  = "" Then
		f_msg_usr_err(210, title, "매출처")
		dw_detail.SetFocus()
		dw_detail.SetColumn("sale_partner")
		Return -1
	End If

   If ls_maintain_partner  = "" Then
		f_msg_usr_err(210, title, "관리처")
		dw_detail.SetFocus()
		dw_detail.SetColumn("maintain_partner")
		Return -1
	End If
End If
Return 0



end event

event resize;//
end event

type dw_cond from w_a_reg_s`dw_cond within b1w_reg_svcorder_update_a
boolean visible = false
end type

type p_ok from w_a_reg_s`p_ok within b1w_reg_svcorder_update_a
boolean visible = false
end type

type p_close from w_a_reg_s`p_close within b1w_reg_svcorder_update_a
integer x = 2437
integer y = 800
end type

type gb_cond from w_a_reg_s`gb_cond within b1w_reg_svcorder_update_a
boolean visible = false
end type

type dw_detail from w_a_reg_s`dw_detail within b1w_reg_svcorder_update_a
integer y = 32
integer width = 2711
integer height = 732
string dataobject = "b1dw_reg_svcorder_update_a"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_detail::retrieveend;call super::retrieveend;if rowcount > 0 Then
	 If This.object.status[1] = is_actorder Then   // 개통 신청과 같으면
	   This.object.reg_partner.Protect = 0
		This.object.sale_partner.Protect = 0
		This.object.maintain_partner.Protect = 0
		
		This.object.reg_partner.BackGround.Color = RGB(108, 147, 137)
		This.object.reg_partner.Color = RGB(255,255,255)
		This.object.reg_partner.Border = True
		This.SetBorderStyle("reg_partner", Lowered!)

		This.object.sale_partner.BackGround.Color = RGB(108, 147, 137)
		This.object.sale_partner.Color = RGB(255,255,255)
		This.object.sale_partner.Border = True
		This.SetBorderStyle("sale_partner", Lowered!)
	
		
		This.object.maintain_partner.BackGround.Color = RGB(108, 147, 137)
		This.object.maintain_partner.Color = RGB(255,255,255)
		This.object.maintain_partner.Border = True
		This.SetBorderStyle("maintain_partner", Lowered!)

	Else  // 수정 못하게
		This.object.reg_partner.Protect = 1
		This.object.sale_partner.Protect = 1
		This.object.maintain_partner.Protect = 1
		
		This.object.reg_partner.BackGround.Color = RGB(255, 251, 240)
		This.object.reg_partner.Color = RGB(0,0,0)
		This.object.reg_partner.Border = False
		
		This.object.sale_partner.BackGround.Color = RGB(255, 251, 240)
		This.object.sale_partner.Color = RGB(0,0,0)
		This.object.sale_partner.Border = False
		
		This.object.maintain_partner.BackGround.Color = RGB(255, 251, 240)
		This.object.maintain_partner.Color = RGB(0,0,0)
		This.object.maintain_partner.Border = False
    End If
End If

end event

type p_delete from w_a_reg_s`p_delete within b1w_reg_svcorder_update_a
boolean visible = false
integer y = 744
end type

type p_insert from w_a_reg_s`p_insert within b1w_reg_svcorder_update_a
boolean visible = false
integer y = 744
end type

type p_save from w_a_reg_s`p_save within b1w_reg_svcorder_update_a
integer x = 2126
integer y = 800
end type

type p_reset from w_a_reg_s`p_reset within b1w_reg_svcorder_update_a
boolean visible = false
integer y = 744
end type

