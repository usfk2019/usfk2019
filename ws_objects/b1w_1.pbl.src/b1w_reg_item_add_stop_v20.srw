$PBExportHeader$b1w_reg_item_add_stop_v20.srw
$PBExportComments$[ohj] 푸목추가사용 및 사용중지 v20
forward
global type b1w_reg_item_add_stop_v20 from w_a_reg_m
end type
end forward

global type b1w_reg_item_add_stop_v20 from w_a_reg_m
integer width = 2505
end type
global b1w_reg_item_add_stop_v20 b1w_reg_item_add_stop_v20

type variables
String is_act_status, is_item[]
Date   id_bil_fromdt, id_reqdt_end, id_reqdt
end variables

on b1w_reg_item_add_stop_v20.create
call super::create
end on

on b1w_reg_item_add_stop_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_req_item_add_stop_v20
	Desc.	: 	품목추가사용 및 사용중지
	Ver.	:	1.0
	Date	: 	2005.05.21
	Programer : Oh Hye Jin
--------------------------------------------------------------------------*/
String ls_ref_desc
//개통상태코드
is_act_status = fs_get_control("B0", "P223", ls_ref_desc)


end event

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_contractseq, ls_status, ls_priceplan, ls_priceplannm

ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], '')

If ls_contractseq = '' Then
	f_msg_info(200, Title, "계약Seq")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
   Return 
End If

SELECT STATUS
     , BIL_FROMDT
	  , PRICEPLAN
  INTO :ls_status
     , :id_bil_fromdt
	  , :ls_priceplan	  
  FROM CONTRACTMST
 WHERE to_char(CONTRACTSEQ) = :ls_contractseq; 
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT STATUS from CONTRACTMST")				
	Return 
End If	

If is_act_status <> ls_status Then
	f_msg_usr_err(9000, title, "선택한 계약의 상태가 개통상태이어야 조회가 가능합니다.")
	Return
End If

//ls_where = ""
////Dynamic SQL
//IF ls_contractseq <> "" THEN	
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where = " ( to_char(B.CONTRACTSEQ) = '" + ls_contractseq +"' OR B.CONTRACTSEQ IS NULL)"
//END IF
//
//IF ls_priceplan <> "" THEN	
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += "  A.priceplan = '" + ls_priceplan +"' "
//END IF

//dw_detail.is_where	= ls_where
ll_rows = dw_detail.Retrieve(ls_contractseq, ls_priceplan)

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
End If	
Select priceplan_desc
  into :ls_priceplannm
  from priceplanmst
 where priceplan = :ls_priceplan;
 
dw_detail.object.priceplannm.text = ls_priceplannm

p_delete.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")
dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
dw_cond.Enabled = False

end event

event type integer ue_extra_save();call super::ue_extra_save;//Save
String ls_itemkey, ls_check_type, ls_outputdata, ls_itemkey1, ls_itemkey2
Long   ll_row, ll_cnt, ll_rows, ll_rows1, ll_rows2, ll_length

//Row 수가 없으면
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

dw_detail.AcceptText()

For ll_row = 1 To ll_rows
	//필수 Check
	ls_itemkey    = fs_snvl(dw_detail.object.itemkey[ll_row]   , '')
	ls_check_type = fs_snvl(dw_detail.object.check_type[ll_row], '')
	ls_outputdata = fs_snvl(dw_detail.object.outputdata[ll_row], '')
	
	//필수 항목 check 
	If ls_itemkey = "" Then
		f_msg_usr_err(200, Title, "기능key")
		dw_detail.SetColumn("itemkey")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
	
	If ls_check_type = "" Then
		f_msg_usr_err(200, Title, "Check유형")
		dw_detail.SetColumn("check_type")
		dw_detail.SetRow(ll_row)
		dw_detail.ScrollToRow(ll_row)
		Return -1	
	End If
Next

For ll_rows1 = 1 To dw_detail.RowCount()

	ls_itemkey1    = fs_snvl(Trim(dw_detail.object.itemkey[ll_rows1]), '')
	
	For ll_rows2 = dw_detail.RowCount() To ll_rows1 - 1 Step -1
		If ll_rows1 = ll_rows2 Then
			Exit
		End If
		
		ls_itemkey2  = fs_snvl(Trim(dw_detail.object.itemkey[ll_rows2]), '')
	
		If ls_itemkey1 = ls_itemkey2 Then
			f_msg_info(9000, Title, "기능key [ " + ls_itemkey2 + " ]이(가) 중복됩니다.")
			dw_detail.SetColumn("itemkey")
			Return -2
		End If
		
	Next
	
Next

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.object.file_code[al_insert_row] = dw_cond.object.file_code[1]

dw_detail.SetitemStatus(al_insert_row, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("itemkey")

Return 0
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.contractseq[1] = ""

dw_cond.SetColumn("contractseq")

RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_item_add_stop_v20
integer x = 59
integer y = 80
integer width = 827
integer height = 116
string dataobject = "b1dw_cnd_item_add_stop_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.contractseq
This.is_help_win[1] = "b1w_hlp_contractmst"
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "contractseq"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.contractseq[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_item_add_stop_v20
integer x = 1577
end type

type p_close from w_a_reg_m`p_close within b1w_reg_item_add_stop_v20
integer x = 1883
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_item_add_stop_v20
integer x = 37
integer y = 4
integer width = 1335
integer height = 224
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_item_add_stop_v20
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_item_add_stop_v20
end type

type p_save from w_a_reg_m`p_save within b1w_reg_item_add_stop_v20
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_item_add_stop_v20
integer x = 37
integer y = 252
integer width = 2391
integer height = 1316
string dataobject = "b1dw_reg_item_add_stop_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_delete.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
	
	String ls_cycle, ls_customerid, ls_unitcycle, ls_reqdt
	Long   ll_contractseq, ll_reqcycle
	Date   ld_end_dt
	
   ll_contractseq = long(dw_cond.Object.contractseq[1])
	
	SELECT REQDT
	     , UNITCYCLE
		  , REQCYCLE
	  INTO :id_reqdt
	     , :ls_unitcycle
		  , :ll_reqcycle
	  FROM REQCONF
	 WHERE CHARGEDT = (SELECT BILCYCLE
 							   FROM BILLINGINFO
							  WHERE CUSTOMERID = (select customerid
														   from contractmst
														  where contractseq = :ll_contractseq));
														  
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "select Error(REQCONF)")
		Return -1
	End If
		
	ls_reqdt  = string(id_reqdt, 'YYYYMMDD')
	
	If ls_unitcycle = 'D' Then  
		
		ld_end_dt = fd_date_next(id_reqdt, ll_reqcycle)
		
		SELECT :ld_end_dt -1 
		  INTO :id_reqdt_end
		  FROM DUAL                 ;
		
		
	ElseIf ls_unitcycle = 'M' Then
	
		SELECT ADD_MONTHS(TO_DATE(:ls_reqdt, 'YYYYMMDD'), :ll_reqcycle) -1
		  INTO :id_reqdt_end
		  FROM DUAL;
	End If
		
End If

end event

event dw_detail::buttonclicked;call super::buttonclicked;Long   ll_contractseq, ll_grouptype
String ls_itemcod, ls_contractseq, ls_mainitem_yn, ls_priceplan, ls_bil_fromdt, ls_bil_todt, ls_currdate
Date   ld_bil_fromdt, ld_bil_todt, ld_currdate

This.Selectrow(0, False)
This.Selectrow(row, True)

Choose Case dwo.name
	Case "b_add"
		If dw_detail.rowcount() <= 0 Then Return -1		
		
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ls_contractseq = dw_cond.Object.contractseq[1]
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ll_grouptype   = dw_detail.Object.grouptype[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_currdate    = date(dw_detail.Object.currdate[row])
		
		If ls_mainitem_yn = 'Y' Then 
			f_msg_info(9000, Title, "기본품목은 추가할 수 없습니다.")
			Return
		End If

		If isnull(ll_grouptype) Then
			f_msg_info(9000, Title, "선택하신 품목의 선택유형이 정의 되지 않았습니다.")
			Return
		End If
		
//		If ll_grouptype = 0 Then
//			f_msg_info(9000, Title, " 선택한 품목의 선택유형이 0입니다. ~r"  &
//							       	 + " 이용정지 할 수 없습니다." )
//			Return
//		End If

		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목추가사용"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt				//계약의 과금시작일
		iu_cust_msg.id_data[2] = id_reqdt					//과금마감일
		iu_cust_msg.id_data[3] = ld_bil_fromdt			   //품목의 과금시작일
		iu_cust_msg.id_data[4] = ld_currdate			   //현재일자
		iu_cust_msg.il_data[1] = long(ls_contractseq)
		iu_cust_msg.il_data[2] = ll_grouptype
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemadd_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()
		
	Case "b_stop"
		If dw_detail.rowcount() <= 0 Then Return -1		
		
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ls_contractseq = dw_cond.Object.contractseq[1]
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_bil_todt    = date(dw_detail.Object.bil_todt[row])
		ll_grouptype   = dw_detail.Object.grouptype[row]
		
		If ls_mainitem_yn = 'Y' Then 
			f_msg_info(9000, Title, "기본품목은 사용중지 할 수 없습니다.")
			Return
		End If
		
		If isnull(ll_grouptype) Then
			f_msg_info(9000, Title, "선택하신 품목의 선택유형이 정의 되지 않았습니다.")
			Return
		End If
		
		If ll_grouptype = 0 Then
			f_msg_info(9000, Title, " 선택한 품목의 선택유형이 0입니다. ~r"  &
							       	 + " 사용정지 및 삭제 할 수 없습니다." )
			Return
		End If
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목사용중지"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt
		iu_cust_msg.id_data[2] = id_reqdt
		iu_cust_msg.id_data[3] = id_reqdt_end
		iu_cust_msg.id_data[4] = ld_bil_fromdt
		iu_cust_msg.id_data[5] = ld_bil_todt		
		iu_cust_msg.il_data[1] = long(ls_contractseq)
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemstop_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()	
		
	Case "b_change"

		If dw_detail.rowcount() <= 0 Then Return -1	
		
		ll_grouptype   = dw_detail.Object.grouptype[row]
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ll_contractseq = dw_detail.Object.contractseq[row]
		
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_bil_todt    = date(dw_detail.Object.bil_todt[row])
		ld_currdate    = date(dw_detail.Object.currdate[row])
		
		ls_bil_fromdt  = fs_snvl(String(dw_detail.Object.bil_fromdt[row], 'yyyymmdd'), '')
		ls_bil_todt    = fs_snvl(String(dw_detail.Object.bil_todt[row], 'yyyymmdd'), '')
		ls_currdate    = fs_snvl(String(dw_detail.Object.currdate[row], 'yyyymmdd'), '')		
		ls_contractseq = fs_snvl(string(ll_contractseq), '')
		
		If ll_grouptype <> 0 Then
			f_msg_info(9000, Title, "품목의 선택유형이 0인 품목만 변경이 가능합니다.")
			Return
		End If

		If ls_contractseq <> '' Then
			If ls_bil_todt = '' Then
				If ll_grouptype <> 0  Then
					f_msg_info(9000, Title, "선택한 품목의 선택유형이 0이 아닙니다.")
					Return
				End If
			ElseIF  ls_bil_todt <> '' Then
				IF ls_bil_todt < ls_currdate Then
					f_msg_info(9000, Title, "사용중인 품목이 아닙니다.")
					Return
				Else
					If ll_grouptype <> 0  Then
						f_msg_info(9000, Title, "선택한 품목의 선택유형이 0이 아닙니다.")
						Return
					End If
				End If				
			End If
		Else
			f_msg_info(9000, Title, "사용중인 품목이 아닙니다.")
			Return
		End If
		
		//청구마감일과 과금시작일이 같은면 변경할수 있다.
		If id_reqdt > ld_bil_fromdt Then
			f_msg_info(9000, Title, "청구마감일 이전에 과금이 시작되어 품목 변경 할 수 없습니다.")
			Return
		End If		

		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목변경"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt
		iu_cust_msg.id_data[2] = id_reqdt
		iu_cust_msg.id_data[3] = id_reqdt_end
		iu_cust_msg.id_data[4] = ld_bil_fromdt
		iu_cust_msg.id_data[5] = ld_bil_todt
		iu_cust_msg.id_data[6] = ld_currdate
		iu_cust_msg.il_data[1] = ll_contractseq
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemchange_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()	
		
End Choose
end event

event dw_detail::rowfocuschanged;call super::rowfocuschanged;//This.Selectrow(0, False)
//This.Selectrow(currentrow, True)
end event

event dw_detail::clicked;call super::clicked;Long   ll_contractseq, ll_grouptype
String ls_itemcod, ls_contractseq, ls_mainitem_yn, ls_priceplan, ls_bil_fromdt, ls_bil_todt, ls_currdate
Date   ld_bil_fromdt, ld_bil_todt, ld_currdate

This.Selectrow(0, False)
This.Selectrow(row, True)

Choose Case dwo.name
	Case "b_add"
		If dw_detail.rowcount() <= 0 Then Return -1		
		
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ls_contractseq = dw_cond.Object.contractseq[1]
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ll_grouptype   = dw_detail.Object.grouptype[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_currdate    = date(dw_detail.Object.currdate[row])
		
		If ls_mainitem_yn = 'Y' Then 
			f_msg_info(9000, Title, "기본품목은 추가할 수 없습니다.")
			Return
		End If

		If isnull(ll_grouptype) Then
			f_msg_info(9000, Title, "선택하신 품목의 선택유형이 정의 되지 않았습니다.")
			Return
		End If
		
//		If ll_grouptype = 0 Then
//			f_msg_info(9000, Title, " 선택한 품목의 선택유형이 0입니다. ~r"  &
//							       	 + " 이용정지 할 수 없습니다." )
//			Return
//		End If

		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목추가사용"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt				//계약의 과금시작일
		iu_cust_msg.id_data[2] = id_reqdt					//과금마감일
		iu_cust_msg.id_data[3] = ld_bil_fromdt			   //품목의 과금시작일
		iu_cust_msg.id_data[4] = ld_currdate			   //현재일자
		iu_cust_msg.il_data[1] = long(ls_contractseq)
		iu_cust_msg.il_data[2] = ll_grouptype
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemadd_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()
		
	Case "b_stop"
		If dw_detail.rowcount() <= 0 Then Return -1		
		
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ls_contractseq = dw_cond.Object.contractseq[1]
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_bil_todt    = date(dw_detail.Object.bil_todt[row])
		ll_grouptype   = dw_detail.Object.grouptype[row]
		
		If ls_mainitem_yn = 'Y' Then 
			f_msg_info(9000, Title, "기본품목은 사용중지 할 수 없습니다.")
			Return
		End If
		
		If isnull(ll_grouptype) Then
			f_msg_info(9000, Title, "선택하신 품목의 선택유형이 정의 되지 않았습니다.")
			Return
		End If
		
		If ll_grouptype = 0 Then
			f_msg_info(9000, Title, " 선택한 품목의 선택유형이 0입니다. ~r"  &
							       	 + " 사용정지 및 삭제 할 수 없습니다." )
			Return
		End If
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목사용중지"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt
		iu_cust_msg.id_data[2] = id_reqdt
		iu_cust_msg.id_data[3] = id_reqdt_end
		iu_cust_msg.id_data[4] = ld_bil_fromdt
		iu_cust_msg.id_data[5] = ld_bil_todt		
		iu_cust_msg.il_data[1] = long(ls_contractseq)
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemstop_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()	
		
	Case "b_change"

		If dw_detail.rowcount() <= 0 Then Return -1	
		
		ll_grouptype   = dw_detail.Object.grouptype[row]
		ls_itemcod     = dw_detail.Object.itemcod[row]
		ll_contractseq = dw_detail.Object.contractseq[row]
		
		ls_mainitem_yn = dw_detail.Object.mainitem_yn[row]
		ls_priceplan   = dw_detail.Object.priceplan[row]
		ld_bil_fromdt  = date(dw_detail.Object.bil_fromdt[row])
		ld_bil_todt    = date(dw_detail.Object.bil_todt[row])
		ld_currdate    = date(dw_detail.Object.currdate[row])
		
		ls_bil_fromdt  = fs_snvl(String(dw_detail.Object.bil_fromdt[row], 'yyyymmdd'), '')
		ls_bil_todt    = fs_snvl(String(dw_detail.Object.bil_todt[row], 'yyyymmdd'), '')
		ls_currdate    = fs_snvl(String(dw_detail.Object.currdate[row], 'yyyymmdd'), '')		
		ls_contractseq = fs_snvl(string(ll_contractseq), '')
		
		If ll_grouptype <> 0 Then
			f_msg_info(9000, Title, "품목의 선택유형이 0인 품목만 변경이 가능합니다.")
			Return
		End If

		If ls_contractseq <> '' Then
			If ls_bil_todt = '' Then
				If ll_grouptype <> 0  Then
					f_msg_info(9000, Title, "선택한 품목의 선택유형이 0이 아닙니다.")
					Return
				End If
			ElseIF  ls_bil_todt <> '' Then
				IF ls_bil_todt < ls_currdate Then
					f_msg_info(9000, Title, "사용중인 품목이 아닙니다.")
					Return
				Else
					If ll_grouptype <> 0  Then
						f_msg_info(9000, Title, "선택한 품목의 선택유형이 0이 아닙니다.")
						Return
					End If
				End If				
			End If
		Else
			f_msg_info(9000, Title, "사용중인 품목이 아닙니다.")
			Return
		End If
		
		//청구마감일과 과금시작일이 같은면 변경할수 있다.
		If id_reqdt > ld_bil_fromdt Then
			f_msg_info(9000, Title, "청구마감일 이전에 과금이 시작되어 품목 변경 할 수 없습니다.")
			Return
		End If		

		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "품목변경"
		iu_cust_msg.is_grp_name = "품목추가사용 및 사용중지"
		iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
		iu_cust_msg.is_data[2] = ls_itemcod
		iu_cust_msg.is_data[3] = ls_priceplan
		iu_cust_msg.id_data[1] = id_bil_fromdt
		iu_cust_msg.id_data[2] = id_reqdt
		iu_cust_msg.id_data[3] = id_reqdt_end
		iu_cust_msg.id_data[4] = ld_bil_fromdt
		iu_cust_msg.id_data[5] = ld_bil_todt
		iu_cust_msg.id_data[6] = ld_currdate
		iu_cust_msg.il_data[1] = ll_contractseq
		iu_cust_msg.idw_data[1] = dw_detail
		
		//Open
		OpenWithParm(b1w_reg_itemchange_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
		
		trigger event ue_ok()	
		
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_item_add_stop_v20
end type

