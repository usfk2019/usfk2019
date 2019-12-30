$PBExportHeader$p1w_reg_card_refill_individual_v20.srw
$PBExportComments$[ohj] 개별카드 충전 -충전기본료적용 v20
forward
global type p1w_reg_card_refill_individual_v20 from w_a_reg_m_sql
end type
end forward

global type p1w_reg_card_refill_individual_v20 from w_a_reg_m_sql
integer width = 2930
integer height = 2476
end type
global p1w_reg_card_refill_individual_v20 p1w_reg_card_refill_individual_v20

type variables
String is_refill_type   //보상충전 Type
Long	il_row_before = 0
Dec{2} ic_refill_amt, ic_sale_amt
String is_partner, is_remark, is_refilldt, is_level_code, is_partner_main

Dec{2} ic_basic_fee
Dec ic_basic_rate
Long il_extdays, il_len

end variables

on p1w_reg_card_refill_individual_v20.create
call super::create
end on

on p1w_reg_card_refill_individual_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc, ls_temp, ls_result[]
String ls_pid,ls_contno, ls_priceplan, ls_svctype
Long ll_row, ll_priceplan_cnt
Dec lc_amt
Int li_index, i, li_rc

//카드 Type
ls_ref_desc = ""
ls_temp = fs_get_control("P0", "P105", ls_ref_desc)
If ls_temp = "" Then Return 
li_index = fi_cut_string(ls_temp, ";" , ls_result[])

ls_pid = trim(dw_cond.Object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contno = trim(dw_cond.Object.contno[1])
If IsNull(ls_contno) Then ls_contno = ""

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)	// 선불카드 서비스 타입

//ls_priceplan = Trim(dw_cond.object.priceplan[1])
//If IsNull(ls_priceplan) Then ls_priceplan = ""
//If ls_priceplan = "" Then
//	f_msg_usr_err(200, Title, "가격정책")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("priceplan")
//	Return
//End If

If ls_pid = "" and ls_contno = ""  Then
	f_msg_usr_err(200, Title, "Pin#, 관리번호중에 한가지를 반드시 입력하셔야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pid")
	Return
End If

ls_where = ""
If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pid = '" + ls_pid + "' "
End If

If ls_contno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "contno = '" + ls_contno +"' "
End If

//If ls_priceplan <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += "priceplan = '" + ls_priceplan + "' "
//End If


//충전, 반품 카드상태 조건절
If ls_where <> "" Then ls_where += " AND "
For i = 1 To li_index
	If i = 1 Then ls_where += " ( "
	ls_where += "status = '" + ls_result[i] + "' "
	If i = li_index Then 
		ls_where += " ) "
	Else 
		ls_where += " OR "
	End If
Next

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row > 0 Then
	ll_priceplan_cnt  = dw_detail.Object.count[1]
	
	If ll_priceplan_cnt > 1 then
		f_msg_usr_err(2100,Title, "중복된 가격정책입니다.")
		p_save.TriggerEvent("ue_disable")
		Return
	ElseIf ll_priceplan_cnt = 1 then
		dw_cond.Object.priceplan[1] = dw_detail.Object.priceplan[1]
	End If
End If 

If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve Error (OK) ")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
	Return
End If
end event

event open;call super::open;String ls_ref_desc, ls_tmp, ls_data[], ls_partner_yn, ls_prefix[], ls_sql, ls_temp
Integer li_return


ls_tmp = fs_get_control('P0', 'P107', ls_ref_desc)
If ls_tmp = "" Then Return
li_return = fi_cut_string(ls_tmp, ";", ls_data[])

If li_return <= 0 Then Return
is_refill_type = ls_data[3]

//관리대상 레벨 코드 A1 C100
ls_ref_desc = ""
is_level_code = fs_get_control("A1", "C100", ls_ref_desc)

//판매출고 대상 관리대상대리점 여부
ls_ref_desc = ""
ls_partner_yn = fs_get_control("P0", "P002", ls_ref_desc)

//선불카드:prefix관리여부 1 ; 대리점prefixno 2
ls_ref_desc = ""
ls_temp =  fs_get_control("P0", "P003", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";", ls_prefix[])
End If

If Isnull(ls_prefix[2]) Then ls_prefix[2] = '' 

dw_cond.SetReDraw(False)	

dw_cond.object.refilldt[1] = Date(fdt_get_dbserver_now())

//ohj 20050820 선불카드대리점 prefix가 존재하면... 해당 prefix로 시작되는 대리점만 가져온다.
//단 그 prefix대리점은 제외

dataWindowChild	dwc_child
dw_cond.GetChild ("partner_prefix", dwc_child)

dwc_child.SetTransObject (SQLCA)

ls_sql = " select partnernm, partner, prefixno " + &
         "   from partnermst                   " 

If ls_partner_yn = 'Y' Then
	ls_sql = ls_sql + " where levelcod <= (select ref_content from sysctl1t where module = 'A1' and Ref_no = 'C100')" 
End If

If ls_prefix[1] = 'Y' Then
	If ls_prefix[2] <> '' Then
		If ls_partner_yn = 'Y' Then
			ls_sql = ls_sql + "  and prefixno like '" + ls_prefix[2] + "%' and prefixno <> '"+ ls_prefix[2] +"'              "
		Else
			ls_sql = ls_sql + "where prefixno like '" + ls_prefix[2] + "%' and prefixno <> '"+ ls_prefix[2] +"'              "
		End If
	End If
End If

ls_sql = ls_sql + " order by partnernm, partner "

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve()

// 관리 대상대리점 prefixno  length  가져오기
SELECT LENGTH(MAX(PREFIXNO))  
  INTO :il_len
  FROM PARTNERMST  
 WHERE LEVELCOD = :is_level_code  ;
 
If sqlca.sqlcode < 0 Then
	f_msg_sql_err(title,  " Select Error(partnermst) prefixno max length select error" )
	Return
End If

dw_cond.SetReDraw(True)	
end event

event ue_save();Integer li_return
Long ll_rowcnt, ll_getrow, ll_i

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "카드충전")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "카드충전완료")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
End Choose


end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_where
Long ll_row,i , ll_count
String ls_refill_type, ls_remark, ls_pid, ls_contno , ls_partner_prefix, ls_refilldt
String ls_tmp, ls_ref_desc, ls_result[], ls_status, ls_priceplan
Dec{2} lc_refill_amt, lc_sale_amt, lc_rate
Integer li_return ,li_rc, li_ret
ll_count = 0 

ls_partner_prefix = dw_cond.Object.partner_prefix[1]
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""

ls_priceplan   = fs_snvl(dw_cond.object.priceplan[1], '')

If ls_partner_prefix = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner_prefix")
	Return -2
End If

lc_refill_amt = dw_cond.Object.refill_amt[1]
If IsNull(lc_refill_amt) Then lc_refill_amt = 0

If lc_refill_amt = 0 Then
	f_msg_usr_err(200, Title, "충전금액")
	dw_cond.SetFocus()
	dw_cond.SetColumn("refill_amt")
	Return -2
End If

ls_refill_type = dw_cond.Object.refill_type[1]
If IsNull(ls_refill_type) Then ls_refill_type = ""

If ls_refill_type = "" Then
	f_msg_usr_err(200, Title, "충전유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("refill_type")
	Return -2
End If

ls_refilldt = String(dw_cond.Object.refilldt[1],'yyyymmdd')

If ls_refilldt = "" Then
	f_msg_usr_err(200, Title, "충전일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("refilldt")
	Return -2
Else
	If ls_refilldt < String(fdt_get_dbserver_now(), 'yyyymmdd') Then
		f_msg_info(100, This.Title, "충전일자는 현재일자보다 커야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("refilldt")
	   Return -2
	End If
End If

ls_remark = dw_cond.Object.remark[1]
If IsNull(ls_remark) Then ls_remark = ""

lc_sale_amt = dw_cond.Object.sale_amt[1]

//ohj 수정.20050822
If ls_partner_prefix <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_refilldt <> "" And lc_refill_amt <> 0 Then
	li_return= fdc_refillpolicy_v20(ls_partner_prefix, is_partner_main, ls_priceplan, ls_refilldt, abs(lc_refill_amt), lc_rate, ic_basic_fee, ic_basic_rate, il_extdays)
	
	If li_return = -1 Then
		f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
		Return -1
	End If	
	
End If

For i = 1 To dw_detail.RowCount()
	If dw_detail.IsSelected(i) Then  ll_count ++
Next

ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
If ls_tmp = "" Then Return -1
		
li_ret = fi_cut_string(ls_tmp, ";", ls_result[])
If li_ret <= 0 Then Return -1
ls_status = ls_result[3]		//사용

If ll_count = 0 Then
	dw_cond.SetFocus()
	Return -2
End If

li_return = f_msg_ques_yesno(9000, Title, String(ll_count) +" 건을 충전하시겠습니까?")
If li_return = 2 Then Return -2 

//***** 처리부분 *****
p1c_dbmgr2_v20 iu_db

iu_db = Create p1c_dbmgr2_v20

iu_db.is_title = Title
iu_db.is_caller = "p1w_reg_card_refill_individual_v20%save"

iu_db.ic_data[1] = lc_refill_amt			//충전금액
iu_db.ic_data[2] = lc_sale_amt	   	//판매금액  
iu_db.is_data[1] = ls_partner_prefix	//대리점
iu_db.is_data[2] = ls_refill_type		//충전유형
iu_db.is_data[3] = ls_refilldt			//충전일자
iu_db.is_data[4] = ls_remark				//비고
iu_db.is_data[5] = ls_status				//사용 상태
iu_db.ic_data[3] = ic_basic_rate       //기본료율
iu_db.ic_data[4] = ic_basic_fee        //기본료금액
iu_db.il_data[1] = il_extdays          //연장일수
iu_db.is_data[6]  = gs_pgm_id[gi_open_win_no]

iu_db.idw_data[1] = dw_detail 

iu_db.uf_prc_db_02()
li_rc	= iu_db.ii_rc

If li_rc = -1 Then
	Destroy iu_db
	Return li_rc
End If

	
//If dw_detail.Update(True,False) < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_mdb_app.is_caller = "ROLLBACK"
//	iu_mdb_app.is_title = "카드충전"
//	iu_mdb_app.uf_prc_db()
//	If iu_mdb_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return -1
//	End If
//	
//	Return -1
//End If

Destroy iu_db
Return li_rc


end event

type dw_cond from w_a_reg_m_sql`dw_cond within p1w_reg_card_refill_individual_v20
integer x = 78
integer y = 72
integer width = 2162
integer height = 816
string dataobject = "p1dw_cnd_reg_card_refill_individual"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_partner_prefix
Long ll_row
Dec lc_rate, lc_basic_rate
Dec{2} lc_sale_amt= 0, lc_amt, ldc_refill_amt, lc_basic_fee
String ls_partner, ls_priceplan, ls_refilldt, ls_refill_type, ls_origin_refill_type, ls_no
Long ld_extdays
Integer li_return=0 //2005.08.11 add

ldc_refill_amt =0
lc_amt =0
lc_sale_amt=0
lc_basic_fee=0

This.AcceptText()

ls_priceplan   = fs_snvl(This.object.priceplan[1], '')
ls_refill_type = This.object.refill_type[1]

If IsNull(ls_priceplan) Then ls_priceplan =""

//판매 금액을 가져오기 위한 것
Choose Case dwo.name
	Case "contno"
		SELECT PARTNER
	     INTO :ls_partner
		  FROM PARTNERMST
		 WHERE PREFIXNO = ( SELECT PARTNER_PREFIX
		                      FROM P_CARDMST
							  	   WHERE CONTNO = :data     ) ;
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(title,  " Select Error(PARTNERMST)" )
			Return -1
		ElseIf sqlca.sqlcode = 100 Then
			f_msg_usr_err(9000, title, "해당 카드의 대리점정보가 존재하지 않습니다. 확인하세요!")
			Return -1
		End If
		
		This.object.partner_prefix[1] = ls_partner
		
		//관리대상대리점 구하기
		select prefixno
		  into :ls_no
		  from partnermst
		 where partner = :ls_partner  ;
		 
		 If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-대리점 prefix" )
			Return
		 End If
		 
		Select partner
		  Into :is_partner_main
		  from partnermst
		 Where prefixno = substr(:ls_no, 1, :il_len);
		 
		If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-관리대상대리점" )
			Return
		End If
			
	Case "pid"
		SELECT PARTNER
	     INTO :ls_partner
		  FROM PARTNERMST
		 WHERE PREFIXNO = ( SELECT PARTNER_PREFIX
		                      FROM P_CARDMST
							  	   WHERE PID = :data     ) ;
		If SQLCA.SQLCode < 0 Then	
			f_msg_sql_err(title,  " Select Error(PARTNERMST)" )
			Return -1
		ElseIf sqlca.sqlcode = 100 Then
			f_msg_usr_err(9000, title, "해당 카드의 대리점정보가 존재하지 않습니다. 확인하세요!")
			Return -1
		End If
		
		This.object.partner_prefix[1] = ls_partner
		
		//관리대상대리점 구하기
		select prefixno
		  into :ls_no
		  from partnermst
		 where partner = :ls_partner  ;
		 
		 If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-대리점 prefix" )
			Return
		 End If
		 
		Select partner
		  Into :is_partner_main
		  from partnermst
		 Where prefixno = substr(:ls_no, 1, :il_len);
		 
		If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-관리대상대리점" )
			Return
		End If
	
	Case "refill_type"
//		   ls_origin_refill_type = This.object.refill_type.Original[1]
			
		   //보상충전이 아니면..
			If ls_priceplan = '' Then
				f_msg_usr_err(9000, Title, "충전할 카드정보를 먼저 조회 하여야 합니다.")
				
				This.object.refill_type[1] = '' 
				Return 2
			End If
			
		   If is_refill_type <> data Then
				
				This.object.sale_amt.Protect = 0 
				
				ls_partner     = This.object.partner_prefix[1]
				ldc_refill_amt = This.object.refill_amt[1]
				ls_refilldt    = String(This.object.refilldt[1], 'yyyymmdd')
				
				If IsNull(ls_partner)     Then ls_partner     = ""
				If IsNull(ldc_refill_amt) Then ldc_refill_amt = 0
				If IsNull(ls_refilldt)    Then ls_refilldt    = ""
				
				//ohj 수정 2005.08.22
				If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_refilldt <> "" And ldc_refill_amt <> 0 Then
					li_return= fdc_refillpolicy_v20(ls_partner, is_partner_main, ls_priceplan, ls_refilldt, abs(ldc_refill_amt), lc_rate, ic_basic_fee, ic_basic_rate, il_extdays)
					
					If li_return = -1 Then
						f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
						Return -1
					End If	
						
					lc_sale_amt = ldc_refill_amt * (lc_rate /100)	
					
					/* basic fee, rate *end******************************************/
					This.object.sale_amt[1] = lc_sale_amt
					This.object.sale_amt.Background.Color = RGB(255,255,255)
					This.object.sale_amt.Color = RGB(0,0,0)
				End If
				
			Else
				This.object.sale_amt.Protect = 1 
				This.object.sale_amt[1] = 0
				This.object.sale_amt.Background.Color = RGB(255,251,240)
				This.object.sale_amt.Color = RGB(0,0,0)
				
			End If
//				If ls_partner <> "" And ls_refilldt <> "" And ls_priceplan <> "" And ldc_refill_amt <> 0  Then
//					//2005.08.11 modify
//					//lc_rate = fdc_refill_rate_anyuser(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt)
//					li_return = fdc_refill_rate_anyuser(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt, lc_rate)
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 요율")
//						Return -1
//					End If	
//					
//					lc_sale_amt = ldc_refill_amt * (lc_rate /100)
//				
//					/* basic fee, rate *start****************************************/
//					//	ic_basic_fee = fdc_basic_fee_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//					li_return  = fdc_basic_fee_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt,ic_basic_fee )
//	
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-기본료")
//						Return -1
//					End If	
//	
//					//	ic_basic_rate = fdc_basic_rate_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//					li_return = fdc_basic_rate_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt,ic_basic_rate ) 
//	
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 기본요율")
//						Return -1
//					End If		
//	
//					//	il_extdays = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//					li_return = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt,il_extdays) 
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.- 연장일수")
//						Return -1
//					End If			
//					
//					/* basic fee, rate *end******************************************/
//					This.object.sale_amt[1] = lc_sale_amt
//					This.object.sale_amt.Background.Color = RGB(255,255,255)
//					This.object.sale_amt.Color = RGB(0,0,0)
//				End If
//				
//			Else
//				This.object.sale_amt.Protect = 1 
//				This.object.sale_amt[1] = 0
//				This.object.sale_amt.Background.Color = RGB(255,251,240)
//				This.object.sale_amt.Color = RGB(0,0,0)
//				
//			End If	
				
	Case "partner_prefix" 
		If is_refill_type <> ls_refill_type Then
			
			//관리대상대리점 구하기
			select prefixno
			  into :ls_no
			  from partnermst
			 where partner = :data  ;
			 
			 If sqlca.sqlcode < 0 then
				f_msg_sql_err(title,  " Select Error(PARTNERmst)-대리점 prefix" )
				Return
			 End If
			 
			Select partner
			  Into :is_partner_main
			  from partnermst
			 Where prefixno = substr(:ls_no, 1, :il_len);
			 
			If sqlca.sqlcode < 0 then
				f_msg_sql_err(title,  " Select Error(PARTNERmst)-관리대상대리점" )
				Return
			End If
				
			//판매금액 가져오기			
			ldc_refill_amt = This.object.refill_amt[1]
			ls_refilldt    = String(This.object.refilldt[1], 'yyyymmdd')
			
			If IsNull(ldc_refill_amt) Then ldc_refill_amt = 0
			If IsNull(ls_refilldt)    Then ls_refilldt    = ""


			//ohj 수정.20050822
			If data <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_refilldt <> "" And ldc_refill_amt <> 0 Then
				li_return= fdc_refillpolicy_v20(data, is_partner_main, ls_priceplan, ls_refilldt, abs(ldc_refill_amt), lc_rate, ic_basic_fee, ic_basic_rate, il_extdays)
				
				If li_return = -1 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
					Return -1
				End If	
				
				lc_sale_amt = ldc_refill_amt * (lc_rate /100)
				This.object.sale_amt[1] = lc_sale_amt
				
			End If
			
		End If	
		
//			If ls_refilldt <> "" And ls_priceplan <> "" And ldc_refill_amt <> 0 Then
//				//lc_rate = fdc_refill_rate_anyuser(data, ls_priceplan, ls_refilldt, ldc_refill_amt)
//				li_return = fdc_refill_rate_anyuser(data, ls_priceplan, ls_refilldt, ldc_refill_amt, lc_rate)			
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 요율")
//					Return -1
//				End If				
//				lc_sale_amt = ldc_refill_amt * (lc_rate /100)
//				
//				This.object.sale_amt[1] = lc_sale_amt
//				/* basic fee, rate *start****************************************/
//
//				//ic_basic_fee = fdc_basic_fee_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//				li_return = fdc_basic_fee_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt,ic_basic_fee) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. -기본료")
//					Return -1
//				End If			
//
//				//ic_basic_rate = fdc_basic_rate_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//				li_return = fdc_basic_rate_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt,ic_basic_rate) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-기본요율")
//					Return -1
//				End If
//	
//				//il_extdays = fl_refill_extdays_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt) 
//				li_return = fl_refill_extdays_new(data, ls_priceplan, ls_refilldt, ldc_refill_amt,il_extdays) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-연장일수")
//					Return -1
//				End If			
//			End if
			/* basic fee, rate *end		*/	
			
	Case "refill_amt" 
		If is_refill_type <> ls_refill_type Then
			
			ls_partner     = This.object.partner_prefix[1]			
			ldc_refill_amt = This.object.refill_amt[1]
			ls_refilldt    = String(This.object.refilldt[1], 'yyyymmdd')
			
			If IsNull(ls_partner)     Then ls_partner     = ""
			If IsNull(ldc_refill_amt) Then ldc_refill_amt = 0
			If IsNull(ls_refilldt)    Then ls_refilldt    = ""
			
			//ohj 수정.20050822
			If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_refilldt <> "" And ldc_refill_amt <> 0 Then
				li_return= fdc_refillpolicy_v20(ls_partner, is_partner_main, ls_priceplan, ls_refilldt, abs(ldc_refill_amt), lc_rate, ic_basic_fee, ic_basic_rate, il_extdays)
				
				If li_return = -1 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
					Return -1
				End If	
				
				lc_sale_amt = ldc_refill_amt * (lc_rate /100)
				This.object.sale_amt[1] = lc_sale_amt
				
			End If
			
//			If ls_partner <> "" And ls_refilldt <> "" And ls_priceplan <> "" And ldc_refill_amt <> 0 Then
//				//lc_rate = fdc_refill_rate_anyuser(ls_partner, ls_priceplan, ls_refilldt, Dec(data))
//				li_return = fdc_refill_rate_anyuser(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt,lc_rate)
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 요율")
//					Return -1
//				End If						
//				lc_sale_amt = ldc_refill_amt * (lc_rate /100)
//				This.object.sale_amt[1] = lc_sale_amt
//				/* basic fee, rate *start****************************************/
//				//ic_basic_fee = fdc_basic_fee_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data)) 
//
//				li_return = fdc_basic_fee_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data),ic_basic_fee) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.- 기본료")
//					Return -1
//				End If		
//	
//
//				//ic_basic_rate = fdc_basic_rate_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data)) 
//				li_return = fdc_basic_rate_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data),ic_basic_rate) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.- 기본요율")
//					Return -1
//				End If	
//
//				//il_extdays = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data)) 
//				li_return = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_refilldt, Dec(data),il_extdays) 
//
//				If li_return = -1 Then
//					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-연장일수")
//					Return -1
//				End If			
//			End If/* basic fee, rate *end******************************************/
			
		End If
		

End Choose
end event

type p_ok from w_a_reg_m_sql`p_ok within p1w_reg_card_refill_individual_v20
integer x = 2359
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within p1w_reg_card_refill_individual_v20
integer x = 2359
end type

type gb_cond from w_a_reg_m_sql`gb_cond within p1w_reg_card_refill_individual_v20
integer width = 2240
integer height = 916
end type

type p_save from w_a_reg_m_sql`p_save within p1w_reg_card_refill_individual_v20
integer x = 2359
end type

type dw_detail from w_a_reg_m_sql`dw_detail within p1w_reg_card_refill_individual_v20
integer y = 928
integer width = 2825
integer height = 1400
string dataobject = "p1dw_reg_card_refill_individual"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)
end event

event dw_detail::clicked;call super::clicked;Long	ll_start, ll_end

//file manager functionality ... turn off all rows then select new range
If row <= 0 Then Return

//SetRedraw(False)

If il_row_before = 0 Then
	il_row_before = row

	If KeyDown(KeyControl!) Then
		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(row, True)
		End If
	Else
		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(0, False)
			SelectRow(row, True)
		End If
	End If
Else
	If KeyDown(KeyControl!) Then
		il_row_before = row

		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(row, True)
			il_row_before = row
		End If
	ElseIf KeyDown(KeyShift!) Then
		If il_row_before >= row Then
			ll_start = row
			ll_end = il_row_before
		ElseIf il_row_before < row Then
			ll_start = il_row_before
			ll_end = row
		End If

		SelectRow(0, False)
		Do While ( ll_start <= ll_end )
			SelectRow( ll_start, True)
			ll_start += 1
		Loop
	Else
		il_row_before = row

		If IsSelected(row) Then
			SelectRow(row, False)
		Else
			SelectRow(0, False)
			SelectRow(row, True)
			il_row_before = row
		End If
	End If
End If
end event

event dw_detail::buttonclicked;call super::buttonclicked;Choose Case dwo.Name
	Case "b_select_all"
		SelectRow(0, True)
//		p_save.TriggerEvent('ue_enable') 
//		p_delete.TriggerEvent('ue_enable') 
//	Case "b_select_nono"
//		SelectRow(0, False)
End Choose	
end event

