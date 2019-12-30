$PBExportHeader$b2u_check.sru
$PBExportComments$[ceusee] Check Object
forward
global type b2u_check from u_cust_a_check
end type
end forward

global type b2u_check from u_cust_a_check
end type
global b2u_check b2u_check

forward prototypes
public subroutine uf_prc_check2 ()
public subroutine uf_prc_check ()
end prototypes

public subroutine uf_prc_check2 ();//Settle_Regcommmst, Settle_salecommst

//b2w_reg_settle_regrate%save
String ls_svcitem_flag, ls_levelcod, ls_comamt, ls_comrate
String ls_svcitem, ls_old_svcitem_flag, ls_old_levelcod, ls_old_fromdt, ls_old_fromcnt
String ls_fromcnt, ls_tocnt, ls_fromamt, ls_toamt

String ls_itemcod, ls_fromdt
String ls_pre_itemcod, ls_pre_fromdt
DEC ldc_fromcnt, ldc_tocnt
DEC ldc_pre_fromcnt, ldc_pre_tocnt

String ls_commplan
String ls_pre_commplan
DEC ldc_fromamt, ldc_toamt
DEC ldc_pre_fromamt, ldc_pre_toamt

String ls_settleplan, ls_pre_settleplan

Integer li_cnt
Long ll_row, i, j
Dec{2} ldc_comamt
Boolean lb_true
String ls_sort

ii_rc = -1
lb_true = False

Choose Case is_caller
	Case "b2w_reg_settle_regrate%save"
		//lu_check.is_caller = "b2w_reg_settle_regrate%save"
		//lu_check.is_title = Title
		//lu_check.idw_data[1] = dw_detail

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then 
			ii_rc = 0 
			Return
		End If
		
		idw_data[1].AcceptText()
		
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, itemcod A, fromcnt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()
			
			ls_pre_itemcod = ""
			ls_pre_fromdt = ""
			ldc_pre_fromcnt = 0
			ldc_Pre_tocnt = 0
			
			
			//Check
			For i = 1 To ll_row
				
				ls_itemcod = Trim(idw_data[1].Object.itemcod[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromcnt = idw_data[1].Object.fromcnt[i]
				ldc_tocnt = idw_data[1].Object.tocnt[i]
				
				If IsNull(ls_itemcod) Then ls_itemcod = ""
				
				If ls_itemcod = "" Then
					f_msg_usr_err(200, is_title, "품목명")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("itemcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_fromdt) Then ls_fromdt = ""
				
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				
				ls_fromcnt = String(idw_data[1].object.fromcnt[i])
				ls_tocnt = String(idw_data[1].object.tocnt[i])
				
				
				If IsNull(ls_fromcnt) Then ls_fromcnt = ""
				If IsNull(ls_tocnt) Then ls_tocnt = ""
				
				
				
				If ls_fromcnt = "" Then
					f_msg_usr_err(200, is_title, "유치건수From(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromcnt")
					ii_rc = -2
					Return
				End If
				
				If ls_tocnt <> "" Then
					If Long(ls_fromcnt) >= Long(ls_tocnt) Then
						f_msg_usr_err(201, is_title, "유치건수To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("tocnt")
						ii_rc = -2
						Return
					End If
				End If
				
				//필수 입력
				If Long(ls_fromcnt) > 0 Then
					ldc_comamt = idw_data[1].object.comamt[i]
					If ldc_comamt = 0  or IsNull(String(ldc_comamt))Then
						f_msg_usr_err(201, is_title, "건별수수료")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("comamt")
						ii_rc = -2
						Return
					End If
				End If
				

				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If
	
	
					//품목 및 개시일이 같으면 체크
				IF ls_itemcod = ls_pre_itemcod AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromcnt = ldc_pre_fromcnt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("fromcnt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromcnt <> ldc_pre_tocnt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_tocnt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_itemcod <> ls_pre_itemcod OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_tocnt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 유치건수To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("tocnt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_itemcod = ls_itemcod
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromcnt = ldc_fromcnt
				ldc_pre_tocnt = ldc_tocnt
				
			 Next
			 
			
		
	Case "b2w_reg_settle_salerate%save"
		//lu_check.is_caller = "b2w_reg_settle_salerate%save"
		//lu_check.is_title = Title
		//lu_check.idw_data[1] = dw_detail
		
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then 
			ii_rc = 0 
			Return
		End If
		
		idw_data[1].AcceptText()
			ls_sort = "String(fromdt,'YYYYMMDD') D, settleplan A, from_amt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()

			ls_pre_settleplan = ""
			ls_pre_fromdt = ""
			ldc_pre_fromamt = 0
			ldc_Pre_toamt = 0
			
			For i = 1 To ll_row
				
				
				ls_settleplan = String(idw_data[1].object.settleplan[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromamt = idw_data[1].Object.from_amt[i]
				ldc_toamt = idw_data[1].Object.to_amt[i]
				
				
				If IsNull(ls_settleplan) Then ls_settleplan = ""
					If ls_settleplan = "" Then
						f_msg_usr_err(200, is_title, "수수료유형")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("settleplan")
						ii_rc = -2
						Return
					End If
									
 				If IsNull(ls_fromdt) Then ls_fromdt = ""
					
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				ls_fromamt = String(idw_data[1].object.from_amt[i])
				If IsNull(ls_fromamt) Then ls_fromamt = ""
				ls_toamt = String(idw_data[1].object.to_amt[i])
				If IsNull(ls_toamt) Then ls_toamt = ""
					
				If ls_fromamt = "" Then
					f_msg_usr_err(200, is_title, "대상매출액Form(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("from_amt")
					ii_rc = -2
					Return
				End If
				
				If ls_toamt <> "" Then
					If Dec(ls_fromamt) >= Dec(ls_toamt) Then
						f_msg_usr_err(201, is_title, "대상매출액To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("to_amt")
						ii_rc = -2
						Return
					End If
				End IF
				
				ls_comrate = String(idw_data[1].object.comrate[i])
				If IsNull(ls_comrate) Then ls_comrate = ""
				If ls_comrate = "" Then
					f_msg_usr_err(200, is_title, "수수료율(%)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("comrate")
					ii_rc = -2
					Return
				End If
						
				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If
				
				//품목 및 개시일이 같으면 체크
				IF ls_settleplan = ls_pre_settleplan AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromamt = ldc_pre_fromamt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("from_amt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromamt <> ldc_pre_toamt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_toamt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_settleplan <> ls_pre_settleplan OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_toamt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 대상매출액To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("toamt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_settleplan = ls_settleplan
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromamt = ldc_fromamt
				ldc_pre_toamt = ldc_toamt
				
			Next

End Choose
ii_rc = 0

end subroutine

public subroutine uf_prc_check ();//b2w_reg_contractcom_rate%save
String ls_svcitem_flag, ls_levelcod, ls_comamt, ls_comrate
String ls_svcitem, ls_old_svcitem_flag, ls_old_levelcod, ls_old_fromdt, ls_old_fromcnt
String ls_fromcnt, ls_tocnt, ls_fromamt, ls_toamt

String ls_itemcod, ls_fromdt
String ls_pre_itemcod, ls_pre_fromdt, ls_pre_levelcod
DEC ldc_fromcnt, ldc_tocnt
DEC ldc_pre_fromcnt, ldc_pre_tocnt

String ls_commplan
String ls_pre_commplan
DEC ldc_fromamt, ldc_toamt
DEC ldc_pre_fromamt, ldc_pre_toamt

String ls_settleplan, ls_pre_settleplan

//maintaincommst add 2005.01.27 (islim)
DEC ldc_ldc_comamt   //수수료액


Integer li_cnt
Long ll_row, i, j
Dec{2} ldc_comamt
Boolean lb_true
String ls_sort

ii_rc = -1
lb_true = False

Choose Case is_caller
	Case "b2w_reg_contractcom_rate%save"
		//lu_check.is_caller = "b2w_reg_contractcom_rate%save"
		//lu_check.is_title = Title
		//lu_check.ii_data[1] = ai_select_tab
		//lu_check.is_data[1] = ls_levelcod
		//lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then 
			ii_rc = 0 
			Return
		End If
		
		idw_data[1].AcceptText()
		
    Choose Case ii_data[1]
		Case 1
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, itemcod A, fromcnt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()
			
			ls_pre_levelcod = ""
			ls_pre_itemcod = ""
			ls_pre_fromdt = ""
			ldc_pre_fromcnt = 0
			ldc_Pre_tocnt = 0

			//Check
			For i = 1 To ll_row
				
				ls_levelcod = Trim(idw_data[1].Object.levelcod[i])
				ls_itemcod = Trim(idw_data[1].Object.itemcod[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromcnt = idw_data[1].Object.fromcnt[i]
				ldc_tocnt = idw_data[1].Object.tocnt[i]
				
				If IsNull(ls_levelcod) Then ls_levelcod = ""
				If ls_levelcod = "" Then
					f_msg_usr_err(200, is_title, "LEVEL")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("levelcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_itemcod) Then ls_itemcod = ""
				If ls_itemcod = "" Then
					f_msg_usr_err(200, is_title, "품목명")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("itemcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_fromdt) Then ls_fromdt = ""
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				
				ls_fromcnt = String(idw_data[1].object.fromcnt[i])
				ls_tocnt = String(idw_data[1].object.tocnt[i])
				
				
				If IsNull(ls_fromcnt) Then ls_fromcnt = ""
				If IsNull(ls_tocnt) Then ls_tocnt = ""
				
				
				
				If ls_fromcnt = "" Then
					f_msg_usr_err(200, is_title, "유치건수From(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromcnt")
					ii_rc = -2
					Return
				End If
				
				If ls_tocnt <> "" Then
					If Long(ls_fromcnt) >= Long(ls_tocnt) Then
						f_msg_usr_err(201, is_title, "유치건수To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("tocnt")
						ii_rc = -2
						Return
					End If
				End If
				
				//필수 입력
				If Long(ls_fromcnt) > 0 Then
					ldc_comamt = idw_data[1].object.comamt[i]
					If ldc_comamt = 0  or IsNull(String(ldc_comamt))Then
						f_msg_usr_err(201, is_title, "건별수수료")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("comamt")
						ii_rc = -2
						Return
					End If
				End If
				

				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If
				

					
				//품목 및 개시일이 같으면 체크
				IF ls_levelcod = ls_pre_levelcod AND ls_itemcod = ls_pre_itemcod AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromcnt = ldc_pre_fromcnt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("fromcnt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromcnt <> ldc_pre_tocnt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_tocnt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_itemcod <> ls_pre_itemcod OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_tocnt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 유치건수To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("tocnt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF

				ls_pre_levelcod = ls_levelcod
				ls_pre_itemcod = ls_itemcod
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromcnt = ldc_fromcnt
				ldc_pre_tocnt = ldc_tocnt
				
			Next
			 


		
		Case 2
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, commplan A, from_amt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()
			
			ls_pre_levelcod = ""
			ls_pre_commplan = ""
			ls_pre_fromdt = ""
			ldc_pre_fromamt = 0
			ldc_Pre_toamt = 0
			
			For i = 1 To ll_row
				
				ls_levelcod = Trim(idw_data[1].Object.levelcod[i])			
				ls_commplan = Trim(idw_data[1].Object.commplan[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromamt = idw_data[1].Object.from_amt[i]
				ldc_toamt = idw_data[1].Object.to_amt[i]
				
				If IsNull(ls_levelcod) Then ls_levelcod = ""
				If ls_levelcod = "" Then
					f_msg_usr_err(200, is_title, "LEVEL")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("levelcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_commplan) Then ls_commplan = ""
				If ls_commplan = "" Then
					f_msg_usr_err(200, is_title, "수수료유형")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("commplan")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_fromdt) Then ls_fromdt = ""
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				ls_fromamt = String(idw_data[1].Object.from_amt[i])
				If IsNull(ls_fromamt) Then ls_fromamt = ""
				ls_toamt = String(idw_data[1].Object.to_amt[i])
				If IsNull(ls_toamt) Then ls_toamt = ""
					
				If ls_fromamt = "" Then
					f_msg_usr_err(200, is_title, "대상매출액Form(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("from_amt")
					ii_rc = -2
					Return
				End If
				
				If ls_toamt <> "" Then
					If Dec(ls_fromamt) >= Dec(ls_toamt) Then
						f_msg_usr_err(201, is_title, "대상매출액To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("to_amt")
						ii_rc = -2
						Return
					End If
				End IF
				
				ls_comrate = String(idw_data[1].object.comrate[i])
				If IsNull(ls_comrate) Then ls_comrate = ""
				If ls_comrate = "" Then
					f_msg_usr_err(200, is_title, "수수료율(%)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("comrate")
					ii_rc = -2
					Return
				End If
				
				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If

				//품목 및 개시일이 같으면 체크
				IF ls_levelcod = ls_pre_levelcod AND ls_commplan = ls_pre_commplan AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromamt = ldc_pre_fromamt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("from_amt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromamt <> ldc_pre_toamt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_toamt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_commplan <> ls_pre_commplan OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_toamt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 대상매출액To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("toamt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_levelcod = ls_levelcod
				ls_pre_commplan = ls_commplan
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromamt = ldc_fromamt
				ldc_pre_toamt = ldc_toamt
				
			NEXT	

      //maintaincommst add 2005.01.27 (islim)
		Case 3
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, commplan A, from_amt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()
			
			ls_pre_levelcod = ""
			ls_pre_commplan = ""
			ls_pre_fromdt = ""
			ldc_pre_fromamt = 0
			ldc_Pre_toamt = 0
			
			For i = 1 To ll_row
				
				ls_levelcod = Trim(idw_data[1].Object.levelcod[i])			
				ls_commplan = Trim(idw_data[1].Object.commplan[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromamt = idw_data[1].Object.from_amt[i]
				ldc_toamt = idw_data[1].Object.to_amt[i]
				
				If IsNull(ls_levelcod) Then ls_levelcod = ""
				If ls_levelcod = "" Then
					f_msg_usr_err(200, is_title, "LEVEL")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("levelcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_commplan) Then ls_commplan = ""
				If ls_commplan = "" Then
					f_msg_usr_err(200, is_title, "수수료유형")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("commplan")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_fromdt) Then ls_fromdt = ""
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				ls_fromamt = String(idw_data[1].Object.from_amt[i])
				If IsNull(ls_fromamt) Then ls_fromamt = ""
				ls_toamt = String(idw_data[1].Object.to_amt[i])
				If IsNull(ls_toamt) Then ls_toamt = ""
					
				If ls_fromamt = "" Then
					f_msg_usr_err(200, is_title, "대상매출액Form(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("from_amt")
					ii_rc = -2
					Return
				End If
				
				If ls_toamt <> "" Then
					If Dec(ls_fromamt) >= Dec(ls_toamt) Then
						f_msg_usr_err(201, is_title, "대상매출액To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("to_amt")
						ii_rc = -2
						Return
					End If
				End IF
				
				ls_comrate = String(idw_data[1].object.comrate[i])
				ls_comamt =  String(idw_data[1].object.comamt[i])
				
				If IsNull(ls_comrate) Then ls_comrate = ""
				If IsNull(ls_comamt) Then ls_comamt = ""
				If ls_comrate = "" or ls_comamt= "" Then
					f_msg_usr_err(201, is_title, "수수료율(%) 또는 수수료액을 입력하셔야 합니다.")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("comrate")
					ii_rc = -2
					Return
				End If
				
				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If

				//품목 및 개시일이 같으면 체크
				IF ls_levelcod = ls_pre_levelcod AND ls_commplan = ls_pre_commplan AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromamt = ldc_pre_fromamt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("from_amt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromamt <> ldc_pre_toamt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_toamt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_commplan <> ls_pre_commplan OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_toamt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 대상매출액To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("toamt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_levelcod = ls_levelcod
				ls_pre_commplan = ls_commplan
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromamt = ldc_fromamt
				ldc_pre_toamt = ldc_toamt
				
			NEXT	
	
	End Choose

	Case "b2w_reg_settle_rate%save"
		//lu_check.is_caller = "b2w_reg_settle_rate%save"
		//lu_check.is_title = Title
		//lu_check.ii_data[1] = ai_select_tab
		//lu_check.is_data[1] = ls_levelcod
		//lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then 
			ii_rc = 0 
			Return
		End If
		
		idw_data[1].AcceptText()
		
    Choose Case ii_data[1]
		Case 1
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, itemcod A, fromcnt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()
			
			ls_pre_itemcod = ""
			ls_pre_fromdt = ""
			ldc_pre_fromcnt = 0
			ldc_Pre_tocnt = 0
			
			
			//Check
			For i = 1 To ll_row
				
				ls_itemcod = Trim(idw_data[1].Object.itemcod[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromcnt = idw_data[1].Object.fromcnt[i]
				ldc_tocnt = idw_data[1].Object.tocnt[i]
				
				
				If IsNull(ls_itemcod) Then ls_itemcod = ""
				
				If ls_itemcod = "" Then
					f_msg_usr_err(200, is_title, "품목명")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("itemcod")
					ii_rc = -2
					Return
				End If
				
				If IsNull(ls_fromdt) Then ls_fromdt = ""
				
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				
				ls_fromcnt = String(idw_data[1].object.fromcnt[i])
				ls_tocnt = String(idw_data[1].object.tocnt[i])
				
				
				If IsNull(ls_fromcnt) Then ls_fromcnt = ""
				If IsNull(ls_tocnt) Then ls_tocnt = ""
				
				
				
				If ls_fromcnt = "" Then
					f_msg_usr_err(200, is_title, "유치건수From(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromcnt")
					ii_rc = -2
					Return
				End If
				
				If ls_tocnt <> "" Then
					If Long(ls_fromcnt) >= Long(ls_tocnt) Then
						f_msg_usr_err(201, is_title, "유치건수To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("tocnt")
						ii_rc = -2
						Return
					End If
				End If
				
				//필수 입력
				If Long(ls_fromcnt) > 0 Then
					ldc_comamt = idw_data[1].object.comamt[i]
					If ldc_comamt = 0  or IsNull(String(ldc_comamt))Then
						f_msg_usr_err(201, is_title, "건별수수료")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("comamt")
						ii_rc = -2
						Return
					End If
				End If
				

				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If
	
	
					//품목 및 개시일이 같으면 체크
				IF ls_itemcod = ls_pre_itemcod AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromcnt = ldc_pre_fromcnt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("fromcnt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromcnt <> ldc_pre_tocnt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_tocnt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("tocnt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_itemcod <> ls_pre_itemcod OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_tocnt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 유치건수To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("tocnt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_itemcod = ls_itemcod
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromcnt = ldc_fromcnt
				ldc_pre_tocnt = ldc_tocnt
				
			 Next
			 
			
		
		Case 2
			
			ls_sort = "String(fromdt,'YYYYMMDD') D, settleplan A, from_amt A"
			idw_data[1].SetSort(ls_sort)
			idw_data[1].Sort()

			ls_pre_settleplan = ""
			ls_pre_fromdt = ""
			ldc_pre_fromamt = 0
			ldc_Pre_toamt = 0
			
			For i = 1 To ll_row
				
				
				ls_settleplan = String(idw_data[1].object.settleplan[i])
				ls_fromdt = String(idw_data[1].object.fromdt[i], 'yyyymmdd')
				ldc_fromamt = idw_data[1].Object.from_amt[i]
				ldc_toamt = idw_data[1].Object.to_amt[i]
				
				
				If IsNull(ls_settleplan) Then ls_settleplan = ""
					If ls_settleplan = "" Then
						f_msg_usr_err(200, is_title, "수수료유형")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("settleplan")
						ii_rc = -2
						Return
					End If
									
 				If IsNull(ls_fromdt) Then ls_fromdt = ""
					
				If ls_fromdt = "" Then
					f_msg_usr_err(200, is_title, "적용개시일")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("fromdt")
					ii_rc = -2
					Return
				End If
				
				ls_fromamt = String(idw_data[1].object.from_amt[i])
				If IsNull(ls_fromamt) Then ls_fromamt = ""
				ls_toamt = String(idw_data[1].object.to_amt[i])
				If IsNull(ls_toamt) Then ls_toamt = ""
					
				If ls_fromamt = "" Then
					f_msg_usr_err(200, is_title, "대상매출액Form(>=)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("from_amt")
					ii_rc = -2
					Return
				End If
				
				If ls_toamt <> "" Then
					If Dec(ls_fromamt) >= Dec(ls_toamt) Then
						f_msg_usr_err(201, is_title, "대상매출액To(<) 보다 커야 합니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("to_amt")
						ii_rc = -2
						Return
					End If
				End IF
				
				ls_comrate = String(idw_data[1].object.comrate[i])
				If IsNull(ls_comrate) Then ls_comrate = ""
				If ls_comrate = "" Then
					f_msg_usr_err(200, is_title, "수수료율(%)")
					idw_data[1].SetFocus()
					idw_data[1].ScrollToRow(i)
					idw_data[1].SetColumn("comrate")
					ii_rc = -2
					Return
				End If
						
				//Update Log
				If idw_data[1].GetItemStatus(i, 0, Primary!) = DataModified! THEN
					idw_data[1].object.updt_user[i] = gs_user_id
					idw_data[1].object.updtdt[i] = fdt_get_dbserver_now()
				End If
				
				//품목 및 개시일이 같으면 체크
				IF ls_settleplan = ls_pre_settleplan AND ls_fromdt = ls_pre_fromdt THEN
					//1.유치건수From이 같으면 에러
					IF ldc_fromamt = ldc_pre_fromamt THEN
						f_msg_usr_err(201, is_title, "중복 데이터 입니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow(i)
						idw_data[1].SetColumn("from_amt")
						ii_rc  = -2
						Return
					END IF
					
					//2.유치건수 범위가 겹치거나 누락되는 부분이 있으면 에러
					IF ldc_fromamt <> ldc_pre_toamt THEN
						f_msg_usr_err(201, is_title, "입력된 범위가 잘못되었습니다.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//3.이전데이터의 유치건수to가 없으면 에러
					IF IsNull(ldc_pre_toamt) THEN
						f_msg_usr_err(201, is_title, "유치건수 범위를 입력하세요.")
						idw_data[1].SetFocus()
						idw_data[1].ScrollToRow((i -1))
						idw_data[1].SetColumn("to_amt")
						ii_rc  = -2
						Return
					END IF
					
					//4.마지막 데이터이면
//					IF ls_settleplan <> ls_pre_settleplan OR ls_fromdt <> ls_pre_fromdt THEN
//						 //유치건수to가 있으면 에러
//						IF NOT IsNull(ldc_toamt) THEN
//							f_msg_usr_err(201, is_title, "마지막 데이터는 대상매출액To(<)이 없어야 합니다.")
////							idw_data[1].SetFocus()
////							idw_data[1].ScrollToRow(i)
////							idw_data[1].SetColumn("toamt")
////							idw_data[1].Object.tocnt[i] = 0
//							ii_rc  = -2
//							Return
//						END IF
//					END IF
					
				END IF
				
				ls_pre_settleplan = ls_settleplan
				ls_pre_fromdt = ls_fromdt
				ldc_pre_fromamt = ldc_fromamt
				ldc_pre_toamt = ldc_toamt
				
			Next

	End Choose

End Choose
ii_rc = 0

end subroutine

on b2u_check.create
call super::create
end on

on b2u_check.destroy
call super::destroy
end on

