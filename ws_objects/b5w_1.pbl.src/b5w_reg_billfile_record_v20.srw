$PBExportHeader$b5w_reg_billfile_record_v20.srw
$PBExportComments$[ohj] 청구file record 구성
forward
global type b5w_reg_billfile_record_v20 from w_a_reg_m
end type
end forward

global type b5w_reg_billfile_record_v20 from w_a_reg_m
end type
global b5w_reg_billfile_record_v20 b5w_reg_billfile_record_v20

type variables
String is_bill_type

end variables

on b5w_reg_billfile_record_v20.create
call super::create
end on

on b5w_reg_billfile_record_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b5w_reg_billfile_record
	Desc.	: 	청구서 file record 항목
	Ver.	:	1.0
	Date	: 	2004.02.22
	Programer : oh hye jin
--------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc, ls_temp, ls_result[], ls_where_1, ls_new
Long   ll_row, li_i


is_bill_type = Trim(dw_cond.object.bill_type[1])

If IsNull(is_bill_type) Then is_bill_type = ""

If is_bill_type = "" Then
	f_msg_info(200, Title, "Bill Type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("bill_type")
	Return 
End If	

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " INVF_TYPE = '" + is_bill_type + "' "

//ls_ref_desc = ""
//ls_temp = fs_get_control("B0","A100", ls_ref_desc)
//If ls_temp <> "" Then
//   fi_cut_string(ls_temp, ";" , ls_result[])
//End if
//
//ls_where_1 = ""
//For li_i = 1 To UpperBound(ls_result[])
//	If ls_where_1 <> "" Then ls_where_1 += " Or "
//	ls_where_1 += "A.method = '" + ls_result[li_i] + "'"
//Next
//
//If ls_where <> "" Then
//	If ls_where_1 <> "" Then ls_where = ls_where + " And ( " + ls_where_1 + " ) "  
//Else
//	ls_where = ls_where_1
//End if

dw_detail.SetRedraw(False)

dw_detail.is_where = ls_where

//Retrieve
ll_row = dw_detail.Retrieve()

dw_detail.SetRedraw(True)
dw_detail.SetFocus()
//dw_detail.SelectRow(0, False)
//dw_detail.ScrollToRow(1)
//dw_detail.SelectRow(1, True)
	
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
//	This.Trigger Event ue_reset()		//찾기가 없으면 reset
//	Return
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
//	p_new.TriggerEvent("ue_disable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
	
Else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
//	p_new.TriggerEvent("ue_disable")
End If


end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
//Save
Long   ll_row, ll_rows, ll_findrow, ll_i, ll_zoncodcnt, i, ll_max_seqno
Long   ll_rows1, ll_rows2, ll_seqno
String ls_record, ls_Description, ls_record_type

ll_rows = dw_detail.RowCount()

For ll_row = 1 To ll_rows
	
//	ll_seqno = dw_detail.Object.seqno[ll_row]
//	If IsNull(ll_seqno) Then ll_seqno = 0
//	
//	If ll_seqno = 0 Then
//		f_msg_usr_err(200, Title, "seq")
//		dw_detail.SetColumn("seqno")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
	
//	SELECT MAX(SEQNO)
//	  INTO :ll_max_seqno
//	  FROM INVF_RECORDMST
//	 WHERE INVF_TYPE = :is_bill_type   ;
////	 
////	If SQLCA.SQLCode < 0 Then
////		f_msg_sql_err(Title, "select Error(INVF_RECORDMST)")
////	ElseIf SQLCA.SQLCode = 100 Then
////		If ll_seqno <> 1 Then
////			f_msg_usr_err(9000, Title, "첫번째는 1을 선택해야 합니다.")
////			dw_detail.SetColumn("seqno")
////			Return -2
////		End If
////	
////	End If
////	 
//MESSAGEBOX('ll_seqno', ll_seqno)
//MESSAGEBOX('ll_max_seqno', ll_max_seqno)
//	If ll_seqno >= ll_max_seqno Then
//		f_msg_usr_err(9000, Title, "입력된 seq보다 커야 합니다.")
//		dw_detail.SetColumn("seqno")
//		Return -2		
//	End If
	
	dw_detail.SetItem(ll_row, 'seqno', ll_row)

	ls_record = Trim(dw_detail.Object.record[ll_row])

	If IsNull(ls_record) Then ls_record = ""
	
	 //필수 항목 check 
	If ls_record = "" Then
		f_msg_usr_err(200, Title, "record")
		dw_detail.SetColumn("record")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	ls_Description = Trim(dw_detail.Object.record_desc[ll_row])

	If IsNull(ls_Description) Then ls_Description = ""
	
	 //필수 항목 check 
	If ls_Description = "" Then
		f_msg_usr_err(200, Title, "Description")
		dw_detail.SetColumn("record_desc")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	ls_record_type = Trim(dw_detail.Object.record_type[ll_row])

	If IsNull(ls_record_type) Then ls_record_type = ""
	
	 //필수 항목 check 
	If ls_record_type = "" Then
		f_msg_usr_err(200, Title, "Record Type")
		dw_detail.SetColumn("record_type")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRedraw(True)
		Return -2
	End If
	
	
	
NEXT

//For ll_rows1 = 1 To dw_detail.RowCount()
//
//	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
//		dw_detail.object.updt_user[ll_rows1] = gs_user_id
//		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
//	End If
//	
//Next

	
Return 0

//	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
//	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
//	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
//	ls_areanum = Trim(dw_detail.Object.areanum[ll_row])
//	ls_itemcod = Trim(dw_detail.Object.itemcod[ll_row])
//	ls_enddt  = String(dw_detail.Object.enddt[ll_row])
//	
//	If IsNull(ls_zoncod) Then ls_zoncod = ""
//	If IsNull(ls_opendt) Then ls_opendt = ""
//	If IsNull(ls_tmcod) Then ls_tmcod = ""
//	If IsNull(ls_areanum) Then ls_areanum = ""
//	If IsNull(ls_itemcod) Then ls_itemcod = ""
//	If IsNull(ls_enddt) Then ls_enddt = ""
//	
//    //필수 항목 check 
//	If ls_zoncod = "" Then
//		f_msg_usr_err(200, Title, "Zone")
//		dw_detail.SetColumn("zoncod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//		
//	End If
//	
//	If ls_opendt = "" Then
//		f_msg_usr_err(200, Title, "Effective-From")
//		dw_detail.SetColumn("opendt")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_enddt <> "" Then
//		If ls_opendt > ls_enddt Then
//			f_msg_usr_err(9000, Title, "Effective-To Date Should Be Later Or Equal To Effective-From Date.")
//			dw_detail.setColumn("enddt")
//			dw_detail.setRow(ll_row)
//			dw_detail.scrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//		End If
//	End If
//	
//	If ls_areanum = "" Then
//		f_msg_usr_err(200, Title, "Called Number")
//		dw_detail.SetColumn("areanum")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_tmcod = "" Then
//		f_msg_usr_err(200, Title, "Rate Period")
//		dw_detail.SetColumn("tmcod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//
//	//시작Point - khpark 추가 -
//	lc_frpoint = dw_detail.Object.frpoint[ll_row]
//	If IsNull(lc_frpoint) Then dw_detail.Object.frpoint[ll_row] = 0
//
//	If dw_detail.Object.frpoint[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Usage Tier Should Be More Than 0.")
//		dw_detail.SetColumn("frpoint")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If ls_itemcod = "" Then
//		f_msg_usr_err(200, Title, "Item")
//		dw_detail.SetColumn("itemcod")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.unitsec[ll_row] = 0 Then
//		f_msg_usr_err(200, Title, "Initial Increment")
//		dw_detail.SetColumn("unitsec")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.unitfee[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Initial Rate")
//		dw_detail.SetColumn("unitfee")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.munitsec[ll_row] = 0 Then
//		f_msg_usr_err(200, Title, "Initial Increment(Message)")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetColumn("munitsec")		
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	If dw_detail.Object.munitfee[ll_row] < 0 Then
//		f_msg_usr_err(200, Title, "Initial Rate(Message)")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetColumn("munitfee")		
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	
//	// 1 zoncod가 같으면 
//	If ls_Ozoncod = ls_zoncod And ls_Oopendt = ls_opendt Then 
//		
//		//2  같은 zonecod 에서 Y Priefix가 다들 수 없다. 
//		If Mid(ls_tmcod, 2, 1) <> Mid(ls_Otmcod, 2, 1) Then
//			f_msg_usr_err(9000, Title, "Same Zone Should Be Same Discount Hours.")
//			dw_detail.SetColumn("tmcod")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//	
//		ElseIf ls_tmcod <> ls_Otmcod Then 		//tmcode 같은지 비교	
//			li_tmcodcnt += 1							//tmcod가 다르면 count 1 추가
//		End If	// 2 close						
//	
//	// 1 else	
//	Else
//		//3. zoncod가 같지 않으면 arecod에 있는것 인지 비교.
//		If lb_notExist = False Then
//			lb_notExist = True
//			For ll_i = 1 To UpperBound(ls_arezoncod)
//				If ls_arezoncod[ll_i] = ls_zoncod Then 
//					lb_notExist = False
//					Exit
//				Else
//					ls_arezoncod1 = ls_zoncod
//					ls_arezoncodnm = Trim(dw_detail.object.compute_zone[ll_row])
//				End If
//			Next
//		End If	 // 3 close	
//	  If ls_Ozoncod <>  ls_zoncod Then 
//	      ll_zoncodCnt += 1								// zoncod 코드가 다르면 count 1 추가
//	   End If
//        
//		// 4 zonecod가  바뀌었거나 처음 row 일때
//		// X Preifx 는 "X"가 아니면 다 있어야 한다. 기본이 3개이다
//		If ll_row > 1 Then
//			
//			If ls_tmcodX <> 'X' and Len(ls_tmcodX) <> li_MAXTMKIND Then
//				f_msg_usr_err(9000, Title, "All The Discount Hours Codes Have To Be Registered By Each Day(weekday/weekend/holyday).")
//				dw_detail.SetColumn("tmcod")
//				dw_detail.SetRow(ll_row - 1)
//				dw_detail.ScrollToRow(ll_row - 1)
//				dw_detail.SetRedraw(True)
//				Return -2
//			End If 
//			
//			li_rtmcnt = -1
//			//이미 Select됐된 시간대인지 Check
//			For li_i = 1 To li_cnt_tmkind
//				If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_rtmcnt = Integer(ls_tmkind[li_i,2])
//			Next
//		
//			// 5 tmcod에 해당 pricecod 별로 tmcod check
//			If li_rtmcnt < 0 Then
//				li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//				If li_return < 0 Then 
//					dw_detail.SetRedraw(True)
//					Return -2
//				End If
//				
//				li_cnt_tmkind += 1
//				ls_tmkind[li_cnt_tmkind,1] = Left(ls_Otmcod, 2)
//				ls_tmkind[li_cnt_tmkind,2] = String(li_rtmcnt)
//			End If // 5 close
//			
//			//누락된 시간대코드가 없는지 Check
//			If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//				f_msg_usr_err(9000, Title, "Registered Discount Hours Code Is Not Enough Or It Is Not Registered Discount Hours Code.")
//				dw_detail.SetColumn("tmcod")
//				dw_detail.SetRow(ll_row - 1)
//				dw_detail.ScrollToRow(ll_row - 1)
//				dw_detail.SetRedraw(True)
//				Return -2
//			End If
//	
//			li_tmcodcnt = 1		//올바르면 tmcod count 초기화 한다. 
//		    ls_tmcodX = ""
//		Else // 4 else	 
//			li_tmcodcnt += 1	// 처음 row 이면 + 1 해준다. 
//			
//		End If // 4 close
//	End If // 1 close ls_Ozoncod = ls_zoncod 조건 
//	
//	// 6 X Prefix "X" 이면 다른것과 같이 쓸 수 없다
//	If Left(ls_tmcod, 1) = 'X' Then
//		If Len(ls_tmcodX) > 0 And ls_tmcodX <> 'X' Then
//			f_msg_usr_err(9000, Title, "All Time Cannot Be Used With Other Discount Hours." )
//			dw_detail.SetColumn("tmcod")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			Return -2
//		ElseIf Len(ls_tmcodX) = 0 Then 
//			ls_tmcodX += Left(ls_tmcod, 1)
//		End If
//	Else
//		lb_addX = True
//		For li_i = 1 To Len(ls_tmcodX)
//			If Mid(ls_tmcodX, li_i, 1) = Left(ls_tmcod, 1) Then lb_addX = False
//		Next
//		If lb_addX Then ls_tmcodX += Left(ls_tmcod, 1)
//	End If				
//	
//	ll_findrow = 0
//	If ls_Ozoncod <> ls_zoncod Or ls_Otmcod <> ls_tmcod Or ls_Oopendt <> ls_opendt Then
//		
//		ll_findrow = dw_detail.Find(" zoncod = '" + ls_zoncod + "' and tmcod = '" + ls_tmcod + &
//		                            "' and string(opendt,'yyyymmdd') = '" + ls_opendt  + &
//									"' and frpoint = 0", 1, ll_rows)
//
//		If ll_findrow <= 0 Then
//			f_msg_usr_err(9000, Title, "Usage Tier Value '0' Is Mandatory For Corresponding Zone/Effective-From/Discount Hours." )		
//			dw_detail.SetColumn("frpoint")
//			dw_detail.SetRow(ll_row)
//			dw_detail.ScrollToRow(ll_row)
//			dw_detail.SetRedraw(True)
//			return -2
//		End IF
//		
//	End IF
//		
//	ls_Ozoncod = ls_zoncod
//	ls_Otmcod  = ls_tmcod
//	ls_Oopendt = ls_opendt
//Next

//
//// zoncod가 하나만 있을경우 
//If Len(ls_tmcodX) <> li_MAXTMKIND And ls_tmcodX <> 'X' Then
//	f_msg_usr_err(9000, Title, "All The Discount Hours Codes Have To Be Registered By Each Day(weekday/weekend/holyday).")
//							
//	dw_detail.SetFocus()
//	dw_detail.SetRedraw(True)
//	Return -2
//End If
//
//li_rtmcnt = -1
////이미 Select됐된 시간대인지 Check
//For li_i = 1 To li_cnt_tmkind
//	If Left(ls_Otmcod, 2) = ls_tmkind[li_i,1] Then li_Rtmcnt = Integer(ls_tmkind[li_i,2])
//Next
//
////새로운 시간대이면 tmcod table에 정의 되어있는것 찾음 
//If li_rtmcnt < 0 Then
//	li_return = b0fi_chk_tmcod(ls_priceplan, Left(ls_Otmcod, 2), li_rtmcnt, Title)
//	If li_return < 0 Then
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//End If
//
////누락된 시간대코드가 없는지 Check
//If li_rtmcnt > li_tmcodcnt Or li_rtmcnt = 0 Then 
//	f_msg_usr_err(9000, Title, "Registered Discount Hours Code Is Not Enough Or It Is Not Registered Discount Hours Code.")
//						
//	dw_detail.SetColumn("tmcod")
//	dw_detail.SetRow(ll_rows)
//	dw_detail.ScrollToRow(ll_rows)
//	dw_detail.SetRedraw(True)
//	Return -2
//End If
//
////같은 시간대  code error 처리
//ls_Ozoncod = ""
//ls_Otmcod  = ""
//ls_Oopendt = ""
//lc_Ofrpoint = -1
//For ll_row = 1 To ll_rows
//	ls_zoncod = Trim(dw_detail.Object.zoncod[ll_row])
//	ls_opendt = String(dw_detail.object.opendt[ll_row],'yyyymmdd')
//	ls_tmcod = Trim(dw_detail.Object.tmcod[ll_row])
//	lc_frpoint = dw_detail.Object.frpoint[ll_row]
//	If ls_zoncod = ls_Ozoncod and ls_opendt = ls_Oopendt and ls_tmcod = ls_Otmcod and lc_frpoint = lc_Ofrpoint Then
//		f_msg_usr_err(9000, Title, "Same Zone And Same Discount Hours Use Same Usage Tier.")
//		dw_detail.SetColumn("frpoint")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//	End If
//	ls_Ozoncod = ls_zoncod
//	ls_Oopendt = ls_opendt
//	ls_Otmcod = ls_tmcod
//	lc_Ofrpoint = lc_frpoint
//Next		
//
//If lb_notExist Then
//	If ls_arezoncod1 <> ls_arezoncodnm Then
//		f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//		//Return -2
//	Else
//		If ls_arezoncod1 = "ALL" Then
//			f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//			//Return -2
//		Else
//			f_msg_info(9000, Title, "It Is Not Registered Zone [ " + ls_arezoncod1 + " (" + ls_arezoncodnm + " ) ] In Rate Zones." )
//			dw_detail.SetFocus()
//			dw_detail.SetRedraw(True)
//			Return -2
//		End If
//	End If
//End If
//
//If ll_zoncodCnt < UpperBound(ls_arezoncod) Then 
//	f_msg_info(9000, Title, "You Have To Register The Rate For All Registered Zones.")
//	//Return -2
//End If
//
//ls_sort = "compute_zone, string(opendt,'yyyymmdd'), tmcod, frpoint"
//dw_detail.SetSort(ls_sort)
//dw_detail.Sort()
//dw_detail.SetRedraw(True)
//
//
////적용종료일과 적용개시일의 중복check 로직 추가 2003.10.30 김은미
//For ll_rows1 = 1 To dw_detail.RowCount()
//	ls_parttype1  = Trim(dw_detail.object.parttype[ll_rows1])
//	ls_partcod1   = Trim(dw_detail.object.partcod[ll_rows1])
//	ls_zoncod1    = Trim(dw_detail.object.zoncod[ll_rows1])
//	ls_tmcod1     = Trim(dw_detail.object.tmcod[ll_rows1])
//	ls_frpoint1   = String(dw_detail.object.frpoint[ll_rows1])
//	ls_areanum1   = Trim(dw_detail.object.areanum[ll_rows1])
//	ls_itemcod1   = Trim(dw_detail.object.itemcod[ll_rows1])
//	ls_opendt1    = String(dw_detail.object.opendt[ll_rows1], 'yyyymmdd')
//	ls_enddt1     = String(dw_detail.object.enddt[ll_rows1], 'yyyymmdd')
//	
//	If IsNull(ls_enddt1) Or ls_enddt1 = "" Then ls_enddt1 = '99991231'
//	
//	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
//		If ll_rows1 = ll_rows2 Then
//			Exit
//		End If
//		ls_parttype2 = Trim(dw_detail.object.parttype[ll_rows2])
//		ls_partcod2  = Trim(dw_detail.object.partcod[ll_rows2])
//		ls_zoncod2   = Trim(dw_detail.object.zoncod[ll_rows2])
//		ls_tmcod2    = Trim(dw_detail.object.tmcod[ll_rows2])
//		ls_frpoint2  = String(dw_detail.object.frpoint[ll_rows2])
//		ls_areanum2  = Trim(dw_detail.object.areanum[ll_rows2])
//		ls_itemcod2  = Trim(dw_detail.object.itemcod[ll_rows2])
//		ls_opendt2   = String(dw_detail.object.opendt[ll_rows2], 'yyyymmdd')
//		ls_enddt2    = String(dw_detail.object.enddt[ll_rows2], 'yyyymmdd')
//		
//		If IsNull(ls_enddt2) Or ls_enddt2 = "" Then ls_enddt2 = '99991231'
//		
//		If (ls_parttype1 = ls_parttype2) And (ls_partcod1 = ls_partcod2) And (ls_zoncod1 =  ls_zoncod2) &
//			And (ls_tmcod1 = ls_tmcod2) And (ls_frpoint1 = ls_frpoint2) And (ls_areanum1 = ls_areanum2) And (ls_itemcod1 = ls_itemcod2) Then
//			
//			If ls_enddt1 >= ls_opendt2 Then
//				f_msg_info(9000, Title, "Same Zone[ " + ls_zoncod1 + " ], Same Discount[ " + ls_tmcod1 + " ], " &
//												+ "Same Usage Tier[ " + ls_frpoint1 + " ], Same Item[ " + ls_itemcod1 + " ] Use Same Effective-From Date.")
//				Return -2
//			End If
//		End If
//		
//	Next
	//Update Log
//	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
//		dw_detail.object.updt_user[ll_rows1] = gs_user_id
//		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
//	End If
//	
//Next
//



end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row, ll_max_seqno = 0

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

SELECT MAX(SEQNO)
  INTO :ll_max_seqno
  FROM INVF_RECORDMST
 WHERE INVF_TYPE = :is_bill_type   ;

// messagebox('', 'q')
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(Title, "select Error(INVF_RECORDMST)")
//	REturn -2
//	
//ElseIf SQLCA.SQLCode = 100 Then
//	messagebox('', 'qq')
//	dw_detail.SetItem(ll_row, 'seqno', 1)
//ElseIf SQLCA.SQLCode = 0 Then
//	
//	dw_detail.SetItem(ll_row, 'seqno', ll_max_seqno + 1)
//End If
//messagebox('',ll_max_seqno )

//If IsNull(ll_max_seqno) Or ll_max_seqno = 0 Then
//	dw_detail.SetItem(ll_row, 'seqno', 1)
//Else
//	dw_detail.SetItem(ll_row, 'seqno', ll_max_seqno + 1)
//End If

dw_detail.SetItem(ll_row, 'invf_type' , is_bill_type)
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_billfile_record_v20
integer x = 59
integer y = 76
integer width = 1623
integer height = 112
string dataobject = "b5dw_cnd_billfile_record"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_billfile_record_v20
integer x = 1920
integer y = 80
end type

type p_close from w_a_reg_m`p_close within b5w_reg_billfile_record_v20
integer x = 2226
integer y = 80
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_billfile_record_v20
integer y = 8
integer width = 1765
integer height = 228
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_billfile_record_v20
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_billfile_record_v20
end type

type p_save from w_a_reg_m`p_save within b5w_reg_billfile_record_v20
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_billfile_record_v20
integer y = 292
integer height = 1256
string dataobject = "b5dw_cnd_reg_billfile_record_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;Long 	ll_max_seqno, ll_seqno

If dwo.name  = 'seqno' Then
	
	ll_seqno = dw_detail.Object.seqno[row]
	
	SELECT MAX(SEQNO)
	  INTO :ll_max_seqno
	  FROM INVF_RECORDMST
	 WHERE INVF_TYPE = :is_bill_type   ;

	If ll_seqno <= ll_max_seqno Then
		f_msg_usr_err(9000, This.Title, "입력된 seq보다 커야 합니다.")
		dw_detail.SetColumn("seqno")
		Return -2		
	End If
	
End If
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_billfile_record_v20
end type

