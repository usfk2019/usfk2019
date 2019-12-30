$PBExportHeader$b1u_check_1.sru
$PBExportComments$[parkkh] Check Object
forward
global type b1u_check_1 from u_cust_a_check
end type
end forward

global type b1u_check_1 from u_cust_a_check
end type
global b1u_check_1 b1u_check_1

forward prototypes
public subroutine uf_prc_check ()
public subroutine uf_prc_check_01 ()
end prototypes

public subroutine uf_prc_check ();/*-------------------------------------------------------------------------
	name	: uf_prc_check()
	desc.	: 저장실 필수 입력 항목 Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2002.10.01
	programer : Park Kyung Hae (parkkh)
--------------------------------------------------------------------------*/	

//b1w_reg_customertrouble
String ls_customerid, ls_troubletype, ls_receiptdt, ls_note
String ls_receiupt_user, ls_responsedt, ls_closedt
String ls_admodel_yn
Long ll_row, i
DateTime ldt_receiptdt, ldt_responsedt, ldt_closedt
boolean lb_check
ii_rc = -2

//b1w_reg_customertrouble_1
String ls_troubletypea, ls_troubletypeb, ls_troubletypec


Choose Case is_caller
	Case "b1w_reg_customermtrouble%extra_save"
//		lu_check.is_caller = "ss1w_reg_customerm_trouble%extra_save"
//		lu_check.is_title    = This.Title
//		lu_check.ib_data[1]  = ib_new
//		lu_check.ii_data[1]  = ai_select_tab 						//SelectedTab 
//		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]		//Data Window	

      Choose Case ii_data[1]
			Case 1
				ls_customerid  = Trim(idw_data[1].object.customer_trouble_customerid[1])
				If IsNull(ls_customerid) Then ls_customerid = ""
				If ls_customerid = "" Then
					f_msg_usr_err(200, is_title, "고객번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_customerid")
					Return
				End If

				ls_troubletype  = Trim(idw_data[1].object.customer_trouble_troubletype[1])
				If IsNull(ls_troubletype) Then ls_troubletype = ""
				If ls_troubletype = "" Then
					f_msg_usr_err(200, is_title, "민원유형")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_troubletype")
					Return
				End If
				
				ldt_receiptdt  = idw_data[1].object.customer_trouble_receiptdt[1]
				ls_receiptdt = String(ldt_receiptdt, 'YYYYMMDD')
				If IsNull(ls_receiptdt) Then ls_receiptdt = ""
				If ls_receiptdt = "" Then
					f_msg_usr_err(200, is_title, "접수일자")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_receiptdt")
					Return
				End If
				
				ldt_closedt  = idw_data[1].object.customer_trouble_closedt[1]
				ls_closedt = String(ldt_closedt, 'YYYYMMDD')
				
				////// 날짜 체크
				If ls_receiptdt <> "" Then 
					lb_check = fb_chk_stringdate(ls_receiptdt)
					If Not lb_check Then 
						f_msg_usr_err(210, is_Title, "'접수일자의 날짜 포맷 오류입니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End If
				End if
						
				If ls_receiptdt <> "" and ls_closedt <> "" Then
					If ls_receiptdt > ls_closedt Then
						f_msg_usr_err(221, is_Title, "접수일자가 처리완료일자보다 작아야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End if
				End if
				
				ls_note  = Trim(idw_data[1].object.customer_trouble_trouble_note[1])
				If IsNull(ls_note) Then ls_note = ""
				If ls_note = "" Then
					f_msg_usr_err(200, is_title, "접수내역")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_note")
					Return
				End If
				
			
				
			Case 2
				
				ll_row = idw_data[1].RowCount()
				For i =1 To ll_row
					ls_responsedt = String(idw_data[1].object.troubl_response_responsedt[i], 'YYYYMMDD')
					If IsNull(ls_responsedt) Then ls_responsedt = ""
					If ls_responsedt = "" Then
						f_msg_usr_err(200, is_title, "처리일자")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_responsedt")
						Return
					End If
					
					ls_note = Trim(idw_data[1].object.troubl_response_response_note[i])
					If IsNull(ls_note) Then ls_note = ""
					If ls_note = "" Then
						f_msg_usr_err(200, is_title, "처리내역")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_response_note")
						Return
					End If
		       Next
		End Choose
		
			Case "b1w_reg_customermtrouble_1%extra_save"
//		lu_check.is_caller = "ss1w_reg_customerm_trouble%extra_save"
//		lu_check.is_title    = This.Title
//		lu_check.ib_data[1]  = ib_new
//		lu_check.ii_data[1]  = ai_select_tab 						//SelectedTab 
//		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]		//Data Window	

      Choose Case ii_data[1]
			Case 1
				ls_customerid  = Trim(idw_data[1].object.customer_trouble_customerid[1])
				If IsNull(ls_customerid) Then ls_customerid = ""
				If ls_customerid = "" Then
					f_msg_usr_err(200, is_title, "고객번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_customerid")
					Return
				End If
				
				ls_troubletypec  = Trim(idw_data[1].object.troubletypeb_troubletypec[1])
				If IsNull(ls_troubletypec) Then ls_troubletypec = ""
				If ls_troubletypec = "" Then
					f_msg_usr_err(200, is_title, "민원유형 대분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypeb_troubletypec")
					Return
				End If
				
				ls_troubletypeb  = Trim(idw_data[1].object.troubletypea_troubletypeb[1])
				If IsNull(ls_troubletypeb) Then ls_troubletypeb = ""
				If ls_troubletypeb = "" Then
					f_msg_usr_err(200, is_title, "민원유형 중분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypea_troubletypeb")
					Return
				End If

				ls_troubletypea  = Trim(idw_data[1].object.troubletypemst_troubletypea[1])
				If IsNull(ls_troubletypea) Then ls_troubletypea = ""
				If ls_troubletypea = "" Then
					f_msg_usr_err(200, is_title, "민원유형 소분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypemst_troubletypea")
					Return
				End If
				
				ls_troubletype  = Trim(idw_data[1].object.customer_trouble_troubletype[1])
				If IsNull(ls_troubletype) Then ls_troubletype = ""
				If ls_troubletype = "" Then
					f_msg_usr_err(200, is_title, "민원유형")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_troubletype")
					Return
				End If
				
				ldt_receiptdt  = idw_data[1].object.customer_trouble_receiptdt[1]
				ls_receiptdt = String(ldt_receiptdt, 'YYYYMMDD')
				If IsNull(ls_receiptdt) Then ls_receiptdt = ""
				If ls_receiptdt = "" Then
					f_msg_usr_err(200, is_title, "접수일자")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_receiptdt")
					Return
				End If
				
				ldt_closedt  = idw_data[1].object.customer_trouble_closedt[1]
				ls_closedt = String(ldt_closedt, 'YYYYMMDD')
				
				////// 날짜 체크
				If ls_receiptdt <> "" Then 
					lb_check = fb_chk_stringdate(ls_receiptdt)
					If Not lb_check Then 
						f_msg_usr_err(210, is_Title, "'접수일자의 날짜 포맷 오류입니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End If
				End if
						
				If ls_receiptdt <> "" and ls_closedt <> "" Then
					If ls_receiptdt > ls_closedt Then
						f_msg_usr_err(221, is_Title, "접수일자가 처리완료일자보다 작아야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End if
				End if
				
				ls_note  = Trim(idw_data[1].object.customer_trouble_trouble_note[1])
				If IsNull(ls_note) Then ls_note = ""
				If ls_note = "" Then
					f_msg_usr_err(200, is_title, "접수내역")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_note")
					Return
				End If
				
			Case 2
				
				ll_row = idw_data[1].RowCount()
				For i =1 To ll_row
					ls_responsedt = String(idw_data[1].object.troubl_response_responsedt[i], 'YYYYMMDD')
					If IsNull(ls_responsedt) Then ls_responsedt = ""
					If ls_responsedt = "" Then
						f_msg_usr_err(200, is_title, "처리일자")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_responsedt")
						Return
					End If
					
					ls_note = Trim(idw_data[1].object.troubl_response_response_note[i])
					If IsNull(ls_note) Then ls_note = ""
					If ls_note = "" Then
						f_msg_usr_err(200, is_title, "처리내역")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_response_note")
						Return
					End If
		       Next
		End Choose
				
		
End Choose

ii_rc = 0 


end subroutine

public subroutine uf_prc_check_01 ();/*-------------------------------------------------------------------------
	name	: uf_prc_check_01()
	desc.	: 저장실 필수 입력 항목 Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2003.12.10
	programer : C.BORA
--------------------------------------------------------------------------*/	

//b1w_reg_customertrouble_2
String ls_customerid, ls_troubletype, ls_receiptdt, ls_note, ls_note2
String ls_receiupt_user, ls_responsedt, ls_closedt, ls_trouble_status, ls_modelno
String ls_admodel_yn, ls_troubleno, ls_partner
Long ll_row, i, lc_troubleno,ll_seq
DateTime ldt_receiptdt, ldt_responsedt, ldt_closedt
String ls_troubletypea, ls_troubletypeb, ls_troubletypec
boolean lb_check
ii_rc = -2





Choose Case is_caller
		
			Case "b1w_reg_customermtrouble_2%extra_save"
//		lu_check.is_caller = "ss1w_reg_customerm_trouble%extra_save"
//		lu_check.is_title    = This.Title
//		lu_check.ib_data[1]  = ib_new
//		lu_check.ii_data[1]  = ai_select_tab 						//SelectedTab 
//		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]		//Data Window	

      Choose Case ii_data[1]
			Case 1
				lc_troubleno = idw_data[1].object.customer_trouble_troubleno[1]
				ls_partner = Trim(idw_data[1].object.customer_trouble_partner[1])
				
				
				ls_customerid  = Trim(idw_data[1].object.customer_trouble_customerid[1])
				If IsNull(ls_customerid) Then ls_customerid = ""
				If ls_customerid = "" Then
					f_msg_usr_err(200, is_title, "고객번호")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_customerid")
					Return
				End If
				
				ls_troubletypec  = Trim(idw_data[1].object.troubletypeb_troubletypec[1])
				If IsNull(ls_troubletypec) Then ls_troubletypec = ""
				If ls_troubletypec = "" Then
					f_msg_usr_err(200, is_title, "민원유형 대분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypeb_troubletypec")
					Return
				End If
				
				ls_troubletypeb  = Trim(idw_data[1].object.troubletypea_troubletypeb[1])
				If IsNull(ls_troubletypeb) Then ls_troubletypeb = ""
				If ls_troubletypeb = "" Then
					f_msg_usr_err(200, is_title, "민원유형 중분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypea_troubletypeb")
					Return
				End If

				ls_troubletypea  = Trim(idw_data[1].object.troubletypemst_troubletypea[1])
				If IsNull(ls_troubletypea) Then ls_troubletypea = ""
				If ls_troubletypea = "" Then
					f_msg_usr_err(200, is_title, "민원유형 소분류")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("troubletypemst_troubletypea")
					Return
				End If
				
				ls_troubletype  = Trim(idw_data[1].object.customer_trouble_troubletype[1])
				If IsNull(ls_troubletype) Then ls_troubletype = ""
				If ls_troubletype = "" Then
					f_msg_usr_err(200, is_title, "민원유형")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_troubletype")
					Return
				End If
				
				ls_trouble_status  = Trim(idw_data[1].object.customer_trouble_trouble_status[1])
				If IsNull(ls_trouble_status) Then ls_trouble_status = ""
				If ls_trouble_status = "" Then
					f_msg_usr_err(200, is_title, "처리상태")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_status")
					Return
				End If
				
				//모델을 필수로 입력
				Select admodel_yn into :ls_admodel_yn from troubletypemst
				where troubletype = :ls_troubletype;
				
				If ls_admodel_yn = "Y" Then
						ls_modelno  = Trim(idw_data[1].object.customer_trouble_modelno[1])
					If IsNull(ls_modelno) Then ls_modelno = ""
					If ls_modelno = "" Then
						f_msg_usr_err(200, is_title, "모델명")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_modelno")
						Return
					End If
				End IF
				
				
				
				ldt_receiptdt  = idw_data[1].object.customer_trouble_receiptdt[1]
				ls_receiptdt = String(ldt_receiptdt, 'YYYYMMDD')
				If IsNull(ls_receiptdt) Then ls_receiptdt = ""
				If ls_receiptdt = "" Then
					f_msg_usr_err(200, is_title, "접수일자")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_receiptdt")
					Return
				End If
				
				ldt_closedt  = idw_data[1].object.customer_trouble_closedt[1]
				ls_closedt = String(ldt_closedt, 'YYYYMMDD')
				
				////// 날짜 체크
				If ls_receiptdt <> "" Then 
					lb_check = fb_chk_stringdate(ls_receiptdt)
					If Not lb_check Then 
						f_msg_usr_err(210, is_Title, "'접수일자의 날짜 포맷 오류입니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End If
				End if
						
				If ls_receiptdt <> "" and ls_closedt <> "" Then
					If ls_receiptdt > ls_closedt Then
						f_msg_usr_err(221, is_Title, "접수일자가 처리완료일자보다 작아야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("customer_trouble_receiptdt")
						Return
					End if
				End if
				
				ls_note  = Trim(idw_data[1].object.customer_trouble_trouble_note[1])
				If IsNull(ls_note) Then ls_note = ""
				If ls_note = "" Then
					f_msg_usr_err(200, is_title, "접수내역")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("customer_trouble_trouble_note")
					Return
				End If
				
				//신규가 아니면 Insert 한다.
				If ib_data[1] = FALSE and &
				  (idw_data[1].GetItemStatus(1, "customer_trouble_trouble_status", Primary!) = DataModified! or idw_data[1].GetItemStatus(1, "customer_trouble_closeyn", Primary!) = DataModified!) Then
					
					//Seq Number
					Select nvl(max(seq) + 1, 1) 
					Into :ll_seq
					From troubl_response
					Where troubleno = :lc_troubleno ;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, "Select Seq")
						RollBack;
						Return
					End If				
					
					Insert Into troubl_response(troubleno, seq, responsedt, response_user,
					 partner, trouble_status, crtdt, updt_user, updtdt, crt_user, pgm_id)
					values (:lc_troubleno, :ll_seq, sysdate, :gs_user_id, :ls_partner, 
					        :ls_trouble_status, sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);
					
				
					//Error
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, "Insert Error (troubl_response)")
						Return
					End If
				End If
				
			Case 2
				
				ll_row = idw_data[1].RowCount()
				For i =1 To ll_row
					ls_responsedt = String(idw_data[1].object.troubl_response_responsedt[i], 'YYYYMMDD')
					If IsNull(ls_responsedt) Then ls_responsedt = ""
					If ls_responsedt = "" Then
						f_msg_usr_err(200, is_title, "처리일자")
						idw_data[1].SetRow(i)
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("troubl_response_responsedt")
						Return
					End If
					
					
					ls_trouble_status  = Trim(idw_data[1].object.troubl_response_trouble_status[i])
					If IsNull(ls_trouble_status) Then ls_trouble_status = ""
					If ls_trouble_status = "" Then
						f_msg_usr_err(200, is_title, "처리상태")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("troubl_response_trouble_status")
						Return
					End If
					
//					ls_note = Trim(idw_data[1].object.troubl_response_response_note[i])
//					ls_note2 = Trim(idw_data[1].object.troubl_response_response_note2[i])
//					If IsNull(ls_note) Then ls_note = ""
//					If IsNull(ls_note2) Then ls_note2 = ""
//					If ls_note = ""  and ls_note2 = "" Then
//						f_msg_usr_err(200, is_title, "처리내역")
//						idw_data[1].SetRow(i)
//						idw_data[1].ScrollToRow(i)
//						idw_data[1].SetColumn("troubl_response_response_note")
//						Return
//					End If
					
					
		       Next
		End Choose
				
		
End Choose

ii_rc = 0 


end subroutine

on b1u_check_1.create
call super::create
end on

on b1u_check_1.destroy
call super::destroy
end on

