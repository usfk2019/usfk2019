$PBExportHeader$b1w_reg_customer_c_1k.srw
$PBExportComments$[islim] 고객정보 등록-후불&선불제- kilt
forward
global type b1w_reg_customer_c_1k from b1w_reg_customer_c
end type
end forward

global type b1w_reg_customer_c_1k from b1w_reg_customer_c
end type
global b1w_reg_customer_c_1k b1w_reg_customer_c_1k

on b1w_reg_customer_c_1k.create
int iCurrent
call super::create
end on

on b1w_reg_customer_c_1k.destroy
call super::destroy
end on

type dw_cond from b1w_reg_customer_c`dw_cond within b1w_reg_customer_c_1k
end type

type p_ok from b1w_reg_customer_c`p_ok within b1w_reg_customer_c_1k
end type

type p_close from b1w_reg_customer_c`p_close within b1w_reg_customer_c_1k
end type

type gb_cond from b1w_reg_customer_c`gb_cond within b1w_reg_customer_c_1k
end type

type dw_master from b1w_reg_customer_c`dw_master within b1w_reg_customer_c_1k
end type

type p_insert from b1w_reg_customer_c`p_insert within b1w_reg_customer_c_1k
end type

type p_delete from b1w_reg_customer_c`p_delete within b1w_reg_customer_c_1k
end type

type p_save from b1w_reg_customer_c`p_save within b1w_reg_customer_c_1k
end type

type p_reset from b1w_reg_customer_c`p_reset within b1w_reg_customer_c_1k
end type

type tab_1 from b1w_reg_customer_c`tab_1 within b1w_reg_customer_c_1k
end type

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = ""
String ls_svctype, ls_customerid
Integer li_exist
 
Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
			Case "logid"		//Log ID
				ls_logid = Trim(idw_tabpage[ai_tabpage].Object.logid[al_row])
				If IsNull(ls_logid) Then ls_logid = ""
				If ls_logid = ""  Then
					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					End If
					
					idw_tabpage[ai_tabpage].Object.password.Color = RGB(255,255,255)		
			        idw_tabpage[ai_tabpage].Object.password.Background.Color = RGB(108, 147, 137)
				End If
			Case "payid"		//납입자 번호
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.payid[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					
					 ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
				  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
				  If li_exist > 0 Then 
					 f_msg_usr_err(404, title, "")
					 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
					 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
					 Return 0
				 End If
				
					
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.phone1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.phone1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.phone1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[6]
					End If
					
					
					//명의인 정보에 넣기
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
					End If
					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row])) or &
					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row]) = ""  Then
						idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
					End If
					
				End If
			Case "zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					
					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
			Case "holder_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
	Case 2
		Choose Case adwo_dwo.name
			Case "bil_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.bil_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.bil_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.bil_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
		
	Case 3

		idw_tabpage[3].accepttext()
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		If idw_tabpage[ai_tabpage].object.use_yn[al_row] = 'Y' Then		
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "인증정보수정"
			iu_cust_msg.is_grp_name = "고객등록"
			iu_cust_msg.is_data[1] = Trim(idw_tabpage[ai_tabpage].object.svctype[al_row])  //svctype
			iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
			iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row]) //validkey
			iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
		
			OpenWithParm(b1w_reg_validinfo_popup_update_cl_1k, iu_cust_msg)
	
			If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, 3) < 0 Then
				Return -1
			End If
			
			tab_1.ib_tabpage_check[3] = True
		End IF
		
		
	Case 5
		
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "신청정보 상세품목"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.orderno[al_row])
		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.ref_contractseq[al_row])
		
		OpenWithParm(b1w_inq_svcorder_popup, iu_cust_msg)
	
	Case 6
		ll_master_row = dw_master.GetSelectedRow(0)
	  	If ll_master_row < 0 Then Return 0
	  
	  	ls_svctype = idw_tabpage[ai_tabpage].object.svcmst_svctype[al_row]
		  
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "계약정보 상세품목"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractseq[al_row])
		iu_cust_msg.is_data[2] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		
		If ls_svctype = is_svctype_pre Then
		  	OpenWithParm(b1w_inq_contmst_popup_pre, iu_cust_msg) 
		Else
		  	OpenWithParm(b1w_inq_contmst_popup, iu_cust_msg) 			
		End If
	
	Case 8
		
		ll_master_row = dw_master.GetSelectedRow(0)
	  	If ll_master_row < 0 Then Return 0
	  
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "할부 내역 상세정보"
		iu_cust_msg.is_grp_name = "고객관리"
		iu_cust_msg.is_data[1] = String(idw_tabpage[ai_tabpage].object.contractmst_contractseq[al_row])
		iu_cust_msg.is_data[3] = Trim(dw_master.object.customerm_customerid[ll_master_row])
		iu_cust_msg.is_data[4] = Trim(dw_master.object.customerm_customernm[ll_master_row])
		
		OpenWithParm(b1w_inq_quota_popup, iu_cust_msg) 

End Choose  

Return 0
end event

type st_horizontal from b1w_reg_customer_c`st_horizontal within b1w_reg_customer_c_1k
end type

type p_view from b1w_reg_customer_c`p_view within b1w_reg_customer_c_1k
end type

