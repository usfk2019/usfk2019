$PBExportHeader$b1w_reg_svc_actorder_3_1k.srw
$PBExportComments$[kem] 서비스신청/개통(할부가능)-com&life
forward
global type b1w_reg_svc_actorder_3_1k from b1w_reg_svc_actorder_3
end type
end forward

global type b1w_reg_svc_actorder_3_1k from b1w_reg_svc_actorder_3
end type
global b1w_reg_svc_actorder_3_1k b1w_reg_svc_actorder_3_1k

on b1w_reg_svc_actorder_3_1k.create
call super::create
end on

on b1w_reg_svc_actorder_3_1k.destroy
call super::destroy
end on

event ue_ok();//String ls_h323id2
String ls_t_4

//ls_h323id2=Trim(String(dw_cond.object.h323id))
ls_t_4 = Trim(String(dw_cond.object.t_4.text))

//해당 서비스에 해당하는 품목 조회
String ls_svccod, ls_priceplan, ls_customerid, ls_partner, ls_requestdt
String ls_where, ls_contract_no, ls_gkid, ls_auth_method, ls_sysdt
String ls_ip_address, ls_h323id, ls_bil_fromdt, ls_reg_partner, ls_sale_partner
String ls_langtype
Long ll_row

ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_customerid   = Trim(dw_cond.object.customerid[1])
ls_svccod       = Trim(dw_cond.object.svccod[1])
ls_priceplan    = Trim(dw_cond.object.priceplan[1])
ls_requestdt    = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_bil_fromdt   = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_partner      = Trim(dw_cond.object.partner[1])
is_act_gu       = Trim(dw_cond.object.act_gu[1])
ls_reg_partner  = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(is_act_gu) Then is_act_gu = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	ll_row = wfi_get_customerid(ls_customerid)		//올바른 고객인지 확인
	If ll_row = -1 Then Return
	 
End If

If ls_requestdt = "" Then
	f_msg_info(200, Title, "개통요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If


If ls_requestdt < ls_sysdt Then
	f_msg_usr_err(210, Title, "개통요청일은 오늘날짜 이상이여야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If		

If ls_partner = "" Then
	f_msg_info(200, Title, "수행처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

If ls_svccod = "" Then
	f_msg_info(200, Title, "신청서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

If ls_priceplan = "" Then
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return
End If

If is_act_gu = "" Then
	f_msg_info(200, Title, "개통처리")
	dw_cond.SetFocus()
	dw_cond.SetColumn("act_gu")
	Return
End IF

If is_act_gu = "Y" Then
	If ls_bil_fromdt = "" Then
		f_msg_info(200, Title, "과금시작일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If
	
	If ls_bil_fromdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "과금시작일은 오늘날짜 이상이여야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If		

End IF

If ls_reg_partner = "" Then
	f_msg_info(200, Title, "유치처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reg_partner")
	Return
End If

If ls_sale_partner = "" Then
	f_msg_info(200, Title, "매출처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sale_partner")
	Return
End If




is_n_langtype  = Trim(dw_cond.object.langtype[1])
is_n_auth_method = Trim(dw_cond.object.auth_method[1])
is_n_validitem3 = Trim(dw_cond.object.h323id[1])
is_n_validitem2 = Trim(dw_cond.object.ip_address[1])
is_n_validitem1 = Trim(dw_cond.object.validitem1[1])
If IsNull(is_n_langtype) Then is_n_langtype = ""
If IsNull(is_n_auth_method) Then is_n_auth_method = ""
If IsNull(is_n_validitem1) Then is_n_validitem1 = ""
If IsNull(is_n_validitem2) Then is_n_validitem2 = ""
If IsNull(is_n_validitem3) Then is_n_validitem3 = ""

If ls_t_4 = "착신지번호1"  Then
	If is_n_validitem3 = "" Then
		f_msg_info(200, Title, "착신지번호1")
		dw_cond.SetFocus()
		dw_cond.SetColumn("h323id")
		Return
	End If
End If

If ls_t_4 = "접속번호"  Then
	If is_n_validitem3 = "" Then
		f_msg_info(200, Title, "접속번호")
		dw_cond.SetFocus()
		dw_cond.SetColumn("h323id")
		Return
	End If
End If
//If il_validkey_cnt > 0 Then
//
//	ls_gkid = Trim(dw_cond.object.gkid[1])
//	ls_auth_method = Trim(dw_cond.object.auth_method[1])
//	ls_h323id = Trim(dw_cond.object.h323id[1])
//	ls_ip_address = Trim(dw_cond.object.ip_address[1])
//	ls_langtype  = Trim(dw_cond.object.langtype[1])
//
//	If IsNull(ls_gkid) Then ls_gkid = ""
//	If IsNull(ls_auth_method) Then ls_auth_method = ""
//	If IsNull(ls_h323id) Then ls_h323id = ""
//	If IsNull(ls_ip_address) Then ls_ip_address = ""
//	If IsNull(ls_langtype) Then ls_langtype = ""
//
//	If ls_langtype = "" Then
//		f_msg_info(200, Title, "멘트 언어")		
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("langtype")
//		Return 
//	End If
//
//	If is_xener_svc = 'Y' Then
//		
//		If ls_gkid = "" Then
//			f_msg_info(200, Title, "GKID")		
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("gkid")
//			Return 
//		End If
//		
//		If ls_auth_method = "" Then
//			f_msg_info(200, Title, "인증방법")
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("auth_method")
//			Return 
//		End If		
//	
//		If left(ls_auth_method,1) = 'S' Then
//			ls_ip_address = dw_cond.object.ip_address[1]
//			If IsNull(ls_ip_address) Then ls_ip_address = ""				
//			If ls_ip_address = "" Then
//				f_msg_info(200, Title, "IP ADDRESS")
//				dw_cond.SetFocus()
//				dw_cond.SetColumn("ip_address")
//				Return
//			End If		
//		End if
//	
//		If mid(ls_auth_method,7,1) <> 'E' Then
//			ls_h323id = dw_cond.object.h323id[1]
//			If IsNull(ls_h323id) Then ls_h323id = ""							
//			If ls_h323id = "" Then
//				f_msg_info(200, Title, "H323ID")
//				dw_cond.SetFocus()
//				dw_cond.SetColumn("h323id")
//				Return 
//			End If		
//		End if	
//	End If
//End If

ls_where = ""
ls_where += "det.priceplan ='" + ls_priceplan + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

SetRedraw(False)

If ll_row > 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail2.SetFocus()

	dw_detail2.Enabled = True
	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
End If

If il_validkey_cnt > 0 Then
	dw_detail.ib_insert = True
	dw_detail.ib_delete = True	
	dw_detail.Enabled = True
	dw_detail.visible = True	
	dw_detail.setfocus()	
    st_horizontal.Visible = True
Else 
	dw_detail.ib_insert = False
	dw_detail.ib_delete = False
	dw_detail.Enabled = False
	dw_detail.visible = False
    st_horizontal.Visible = False
End If

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)


end event

event ue_insert();//override

Long ll_row, ll_cnt
Int li_return

String ls_svccod
int i

ls_svccod=LeftA(String(dw_cond.object.svccod[1]), 2)


ll_cnt = dw_detail.RowCount()
If ll_cnt >= il_validkey_cnt Then
	f_msg_usr_err(9000,title,"해당가격정책에 인증KEY 등록은 ~r~n~r~n" +string(il_validkey_cnt)+ "개까지 등록 가능합니다.")
	Return
End If

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)
dw_detail.object.langtype[ll_row] = is_n_langtype
dw_detail.object.auth_method[ll_row] = is_n_auth_method
dw_detail.object.validitem1[ll_row] = is_n_validitem1
dw_detail.object.validitem2[ll_row] = is_n_validitem2
dw_detail.object.validitem3[ll_row] = is_n_validitem3
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If is_xener_svc = 'N' Then
	dw_detail.object.auth_method.Protect = 1
	dw_detail.Object.auth_method.Background.Color = RGB(255, 251, 240)
	dw_detail.Object.auth_method.Color = RGB(255, 255, 255)
	
	If ls_svccod = "X1" Then		
		dw_detail.object.validitem3.background.color = RGB(255,255,255)
		dw_detail.object.validitem3.color=RGB(0,0,0)				
	Elseif ls_svccod = "X2"	Then		//로밍플라이-랜드서비스
		dw_detail.object.validitem3.color= RGB(255,255,255)			
		dw_detail.object.validitem3.Background.Color= RGB(108,147,137)						
	Elseif ls_svccod = "X3"	Then //로밍플라이-모바일
		dw_detail.object.validitem3.color= RGB(255,255,255)			
		dw_detail.object.validitem3.Background.Color= RGB(108,147,137)						
	Else 
		dw_detail.object.validitem3.background.color = RGB(255,255,255)
		dw_detail.object.validitem3.color=RGB(0,0,0)				
	End If

ElseIf is_xener_svc = 'Y' Then
	dw_detail.object.auth_method.Protect = 0
	dw_detail.Object.auth_method.Background.Color = RGB(108, 147, 137)
	dw_detail.Object.auth_method.Color = RGB(255, 255, 255)
	
	If ls_svccod = "X1" Then		
		dw_detail.object.validitem3.background.color = RGB(255,255,255)
		dw_detail.object.validitem3.color=RGB(0,0,0)				
	Elseif ls_svccod = "X2"	Then		//로밍플라이-랜드서비스
		dw_detail.object.validitem3.color= RGB(255,255,255)			
		dw_detail.object.validitem3.Background.Color= RGB(108,147,137)						
	Elseif ls_svccod = "X3"	Then //로밍플라이-모바일
		dw_detail.object.validitem3.color= RGB(255,255,255)			
		dw_detail.object.validitem3.Background.Color= RGB(108,147,137)						
	Else 
		dw_detail.object.validitem3.background.color = RGB(255,255,255)
		dw_detail.object.validitem3.color=RGB(0,0,0)				
	End If

End If

//This.Trigger Event ue_extra_insert(ll_row,li_return)
//
//If li_return < 0 Then
//	Return
//End if
//



	


//Return 0
end event

event ue_extra_save(ref integer ai_return);
Long ll_row
Integer li_rc
b1u_dbmgr 	lu_dbmgr
Long i

String ls_t_3

ls_t_3 = Trim(String(dw_cond.object.t_4.text))


SetNull(il_contractseq)
ll_row  = dw_detail2.RowCount()
If ll_row = 0 Then 
	ai_return = 0
	Return
End if

If il_validkey_cnt > 0 Then
	ll_row  = dw_detail.RowCount()
	If ll_row = 0 Then 
		f_msg_usr_err(9000, Title, "사용할 인증KEY를 입력하셔야 합니다.")		
		ai_return = -2
		Return
	End if
End if

If ls_t_3 = "착신지번호1"  Then
	for i=1 to ll_row
		If Trim(String(dw_detail.object.validitem3[i]))= "" Then
			f_msg_info(200, Title, "착신지번호1")
			dw_detail.SetFocus()
			dw_detail.SetColumn(4)
			ai_return = -2
			Return
		End If
	Next			
End If


If ls_t_3 = "접속번호"  Then
	for i=1 to ll_row
		If Trim(String(dw_detail.object.validitem3[i])) = "" Then
			f_msg_info(200, Title, "접속번호")
			dw_detail.SetFocus()
			dw_detail.SetColumn(4)
			ai_return = -2
			Return
		End If
	Next	
End If

	
//저장
lu_dbmgr = Create b1u_dbmgr
lu_dbmgr.is_caller   = "b1w_reg_svc_actorder_3%save"
lu_dbmgr.is_title    = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2                //품목
lu_dbmgr.idw_data[3] = dw_detail			          //인증KEY
lu_dbmgr.is_data[1]  = gs_user_id
lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
lu_dbmgr.is_data[5]  = is_svctype                //svctype
lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
lu_dbmgr.is_data[7]  = is_type         			 //MVNO svc type
lu_dbmgr.is_data[8]  = is_xener_svc    			 //xener 서비스여부  khpark modify 2004.04.09

lu_dbmgr.uf_prc_db_06()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	ai_return = -1
	Return
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	ai_return = -2	
	Return
End If

If li_rc = -3 Then
	Destroy lu_dbmgr
	ai_return = -3		
	Return
End If

il_orderno = lu_dbmgr.il_data[1]
If is_act_gu = "Y" Then
	il_contractseq = lu_dbmgr.il_data[2]
End If

Destroy lu_dbmgr

ai_return = li_rc

Return
end event

type dw_cond from b1w_reg_svc_actorder_3`dw_cond within b1w_reg_svc_actorder_3_1k
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_svccod

ls_svccod=LeftA(String(dw_cond.object.svccod[1]), 2)
//ls_svccod =  Left(data, 2)

Choose Case dwo.Name
	Case "svccod"
		Choose Case ls_svccod
			Case "X1"         //소분류
				dw_cond.object.t_4.text="H323ID"
				dw_cond.object.t_5.text="IP Address"
				dw_cond.object.h323id.background.color = RGB(255,255,255)
				dw_cond.object.h323id.color=RGB(0,0,0)				
				
			Case "X2"			//로밍플라이-랜드서비스
				dw_cond.object.t_4.text="접속번호"
				dw_cond.object.t_5.text=""
				dw_cond.object.h323id.color= RGB(255,255,255)			
				dw_cond.object.h323id.Background.Color= RGB(108,147,137)		

				 
			Case "X3"			//로밍플라이-모바일
				dw_cond.object.t_4.text="착신지번호1"
				dw_cond.object.t_5.text="착신지번호2"
				dw_cond.object.h323id.color= RGB(255,255,255)			
				dw_cond.object.h323id.Background.Color= RGB(108,147,137)		
				

//			Case "L"
//				is_select_cod = "locationL"				
//				Modify("location.dddw.name=''")
//				Modify("location.dddw.DataColumn=''")
//				Modify("location.dddw.DisplayColumn=''")
//				This.Object.location[row] = ''				
//				Modify("location.dddw.name=b1dc_dddw_location")
//				Modify("location.dddw.DataColumn='location'")
//				Modify("location.dddw.DisplayColumn='locationnm'")
//				
//			Case else					//분류선택 안했을 경우...
//				is_select_cod = ""				
//				Modify("location.dddw.name=''")
//				This.Object.location[row] = ''
			Case else					//분류선택 안했을 경우...
				dw_cond.object.t_4.text="H323ID"
				dw_cond.object.t_5.text="IP Address"
				dw_cond.object.h323id.background.color = RGB(255,255,255)
				dw_cond.object.h323id.color=RGB(0,0,0)				
		End Choose
		Case "priceplan"
			Choose Case ls_svccod
				Case "X1"         //소분류
					dw_cond.object.t_4.text="H323ID"
					dw_cond.object.t_5.text="IP Address"
					dw_cond.object.h323id.background.color = RGB(255,255,255)
					dw_cond.object.h323id.color=RGB(0,0,0)				
					
				Case "X2"			//로밍플라이-랜드서비스
					dw_cond.object.t_4.text="접속번호"
					dw_cond.object.t_5.text=""
					dw_cond.object.h323id.color= RGB(255,255,255)			
					dw_cond.object.h323id.Background.Color= RGB(108,147,137)		
	
					 
				Case "X3"			//로밍플라이-모바일
					dw_cond.object.t_4.text="착신지번호1"
					dw_cond.object.t_5.text="착신지번호2"
					dw_cond.object.h323id.color= RGB(255,255,255)			
					dw_cond.object.h323id.Background.Color= RGB(108,147,137)		
					

				Case else					//분류선택 안했을 경우...
					dw_cond.object.t_4.text="H323ID"
					dw_cond.object.t_5.text="IP Address"
					dw_cond.object.h323id.background.color = RGB(255,255,255)
					dw_cond.object.h323id.color=RGB(0,0,0)		
			End Choose
End Choose

Return 0
end event

type p_ok from b1w_reg_svc_actorder_3`p_ok within b1w_reg_svc_actorder_3_1k
end type

type p_close from b1w_reg_svc_actorder_3`p_close within b1w_reg_svc_actorder_3_1k
end type

type gb_cond from b1w_reg_svc_actorder_3`gb_cond within b1w_reg_svc_actorder_3_1k
end type

type dw_master from b1w_reg_svc_actorder_3`dw_master within b1w_reg_svc_actorder_3_1k
end type

type dw_detail from b1w_reg_svc_actorder_3`dw_detail within b1w_reg_svc_actorder_3_1k
end type

type p_insert from b1w_reg_svc_actorder_3`p_insert within b1w_reg_svc_actorder_3_1k
end type

type p_delete from b1w_reg_svc_actorder_3`p_delete within b1w_reg_svc_actorder_3_1k
end type

type p_save from b1w_reg_svc_actorder_3`p_save within b1w_reg_svc_actorder_3_1k
end type

type p_reset from b1w_reg_svc_actorder_3`p_reset within b1w_reg_svc_actorder_3_1k
end type

type dw_detail2 from b1w_reg_svc_actorder_3`dw_detail2 within b1w_reg_svc_actorder_3_1k
end type

event dw_detail2::retrieveend;call super::retrieveend;
String ls_svccod
int i

ls_svccod=LeftA(String(dw_cond.object.svccod[1]), 2)

	
If ls_svccod = "X1" Then		
	dw_detail.object.t_3.text = "H323ID"
	dw_detail.object.t_1.text= "IP Address"
	
Elseif ls_svccod = "X2"	Then		//로밍플라이-랜드서비스
	dw_detail.object.t_3.text="접속번호"
	dw_detail.object.t_1.text=""
	
Elseif ls_svccod = "X3"	Then //로밍플라이-모바일
	dw_detail.object.t_3.text = "착신지번호1"
	dw_detail.object.t_1.text = "착신지번호2"
	
Else 
	dw_detail.object.t_3.text = "H323ID"
	dw_detail.object.t_1.text = "IP Address"

End If


//Return 0
end event

type st_horizontal2 from b1w_reg_svc_actorder_3`st_horizontal2 within b1w_reg_svc_actorder_3_1k
end type

type st_horizontal from b1w_reg_svc_actorder_3`st_horizontal within b1w_reg_svc_actorder_3_1k
end type

