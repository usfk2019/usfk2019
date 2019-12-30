$PBExportHeader$b1w_reg_itemadd_popup_v20.srw
$PBExportComments$[ohj] 품목사용 popup v20
forward
global type b1w_reg_itemadd_popup_v20 from w_a_reg_m
end type
type gb_1 from gb_cond within b1w_reg_itemadd_popup_v20
end type
end forward

global type b1w_reg_itemadd_popup_v20 from w_a_reg_m
integer width = 1184
integer height = 612
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
gb_1 gb_1
end type
global b1w_reg_itemadd_popup_v20 b1w_reg_itemadd_popup_v20

type variables
String is_pgm_gu, is_itemcod, is_priceplan, is_item[]
Long il_contractseq, il_grouptype
Date id_cont_fromdt, id_reqdt//, id_reqdt_end

datawindow idw_data


end variables

on b1w_reg_itemadd_popup_v20.create
int iCurrent
call super::create
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_1
end on

on b1w_reg_itemadd_popup_v20.destroy
call super::destroy
destroy(this.gb_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_itemadd_popup_v20
	Desc	: 	품목사용
	Ver.	:	1.0
	Date	: 	2005.05.21
	programer : ohj
-------------------------------------------------------------------------*/
Long     ll_row, ll_addunit, ll_validity_term, ll_use
integer  li_return
String   ls_where, ls_ref_desc, ls_temp, ls_requestdt, ls_method, ls_bilfromdt, &
         ls_cu_date, ls_bil_todt
Date   ldt_bilfromdt, ldt_date_next, ldt_date_next_1, ld_fromdt, ld_currdate

//window 중앙에
f_center_window(b1w_reg_itemadd_popup_v20)

dw_detail.SetRowFocusIndicator(off!)	

is_pgm_gu      = iu_cust_msg.is_data[1]
is_itemcod     = iu_cust_msg.is_data[2]
is_priceplan   = iu_cust_msg.is_data[3]
id_cont_fromdt = iu_cust_msg.id_data[1] 
id_reqdt		   = iu_cust_msg.id_data[2]  
//id_reqdt_end	= iu_cust_msg.id_data[3]  	
il_contractseq = iu_cust_msg.il_data[1]
il_grouptype   = iu_cust_msg.il_data[2]
idw_data       = iu_cust_msg.idw_data[1]
ld_fromdt      = iu_cust_msg.id_data[3] 
ld_currdate    = iu_cust_msg.id_data[4]

Integer j, i
Long    ll_contract
String  ls_itemcod

ls_cu_date = string(ld_currdate, 'yyyymmdd')
j = 1
For i = 1 To idw_data.Rowcount()
	ll_contract = idw_data.object.contractseq[i]
	ls_itemcod  = idw_data.object.itemcod[i]
	ls_bil_todt = fs_snvl(string(idw_data.object.bil_todt[i], 'yyyymmdd'), '')
	
	If isnull(ll_contract) Then ll_contract = 0
	If ll_contract <> 0 Then
		If ls_bil_todt = '' Or ls_bil_todt > ls_cu_date Then
			is_item[j] = ls_itemcod
			j ++
		End If
	End If
Next

dw_detail.insertrow(0)

dw_detail.Object.itemcod[1]    = is_itemcod

//이용 중지된 경우 bil_fromdt가 존재하나 걍 오늘일짜로 세팅.... todt는 null, 기간제이면 계산세팅
If isnull(ld_fromdt) = False Then
	dw_detail.Object.bil_fromdt[1] = ld_fromdt
Else
	dw_detail.Object.bil_fromdt[1] = fdt_get_dbserver_now()
End If

ls_requestdt = String(fdt_get_dbserver_now(), 'yyyymmdd')

SELECT A.VALIDITY_TERM
	  , A.METHOD
	  , A.ADDUNIT			  
  INTO :ll_validity_term
	  , :ls_method
	  , :ll_addunit
  FROM PRICEPLAN_RATE2 A,
		 ITEMMST B
 WHERE A.ITEMCOD   = B.ITEMCOD
	AND A.PRICEPLAN = :is_priceplan
	AND B.PREBIL_YN = 'Y'
	AND TO_CHAR(A.FROMDT,'YYYYMMDD') <= :ls_requestdt
	AND TO_CHAR(NVL(A.TODT, SYSDATE),'YYYYMMDD') >= :ls_requestdt
	AND ROWNUM = 1;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT validity_term")				
	Return 1
End If
		
ldt_bilfromdt = dw_detail.Object.bil_fromdt[1]       	//과금시작일
ll_use        = ll_addunit * ll_validity_term 	//사용가능일(월)
ls_bilfromdt  = string(ldt_bilfromdt, 'YYYYMMDD')

If ls_method = 'A' Then
	
	ldt_date_next_1 = fd_date_next(ldt_bilfromdt, ll_use)
	
	SELECT :ldt_date_next_1 -1 
	  INTO :ldt_date_next
	  FROM DUAL                 ;
	
	dw_detail.Object.bil_todt[1] = ldt_date_next
	
ElseIf ls_method = 'M' Then
	
	SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
	  INTO :ldt_date_next
	  FROM DUAL;
	  
	dw_detail.Object.bil_todt[1] = ldt_date_next

Else
//	dw_cond.Object.enddt[1] = 
End If

dw_detail.SetColumn("bil_fromdt")

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)
p_save.TriggerEvent("ue_enable")
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space - 30
End If

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space   + 35
	p_save.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space   + 35
	//p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
else
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space  + 35
	p_save.Y	= newheight - iu_cust_w_resize.ii_button_space  + 35
//	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event type integer ue_extra_save();Long    ll_row, ll_cnt, ll_type, i, ll_type_1, ll_groupno, ll_groupno_1
String ls_bil_fromdt, ls_cont_fromdt

dw_detail.accepttext()

ll_row = dw_detail.RowCount()
If ll_row = 0 Then return 0

ls_bil_fromdt  = fs_snvl(string(dw_detail.object.bil_fromdt[1], 'yyyymmdd'), '')
ls_cont_fromdt = string(id_cont_fromdt, 'yyyymmdd')

If ls_bil_fromdt < ls_cont_fromdt Then
	f_msg_usr_err(210, Title, "계약의 과금시작일보다 빠를 수 없습니다.")
	dw_detail.SetColumn("bil_fromdt")
	return -1
End If

If ls_bil_fromdt >= string(id_reqdt, 'yyyymmdd') Then// And ls_bil_fromdt <= string(id_reqdt_end, 'yyyymmdd')  Then
Else
//	f_msg_usr_err(210, Title, "과금시작일은 해당고객 청구일자의 사용기간 범위이내이어야 합니다.")
	f_msg_usr_err(210, Title, "과금시작일은 해당고객 청구기준일이후 이여야 합니다..")
	dw_detail.SetColumn("bil_fromdt")
	return -1
End If
  
SELECT groupno
  INTO :ll_groupno
  FROM priceplandet
 WHERE PRICEPLAN = :is_priceplan
   AND ITEMCOD   = :is_itemcod    ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " Select Error(priceplandet)")
	Return -1
End If
	
If il_grouptype = 0 Then
	For i = 1 To UpperBound(is_item)

		SELECT grouptype
		     , groupno
		  INTO :ll_type_1
		     , :ll_groupno_1
		  FROM priceplandet
		 WHERE PRICEPLAN = :is_priceplan
		   AND ITEMCOD   = :is_item[i]  ;			
			
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, " Select Error(priceplandet)")
			Return -1
		End If
		
		If ll_type_1 = 0 And ll_groupno_1 = ll_groupno Then
			f_msg_info(9000, Title, " 선택한 품목은 동일그룹중1개만선택하는 유형입니다. r"  &
			                      + " 기존에 등록된 품목중 같은 유형이면서 같은 그룹번호를 가진 품목이 존재합니다.")
			Return -1
		End If
	Next		
	
End If
	
return 0
end event

event type integer ue_insert();call super::ue_insert;//long ll_row
//integer li_return
//String ls_validkey_type
//
//ll_row = dw_detail.getrow()
////default 셋팅
//dw_detail.object.validkey_type[ll_row] = is_validkey_type
//dw_detail.object.langtype[ll_row] = is_langtype
//
return 0 
end event

event closequery;//
//Integer li_return
//
////입력값 check
//li_return = This.Trigger Event ue_extra_save()
//
//If li_return < 0 Then
//	Return -1
// End if
//
//
end event

event ue_ok();call super::ue_ok;//조회
String  ls_validkey_type, ls_idate_fr, ls_idate_to, ls_where, ls_validkey, ls_partner
String ls_ret_partner, ls_ret_prefixno
Long ll_row
 
If ls_where <> "" Then ls_where += " And "
ls_where += "contractseq = '" + string(il_contractseq) + "' "	

If ls_where <> "" Then ls_where += " And "
ls_where += "itemcod = '" + is_itemcod + "' "	

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event type integer ue_save();If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return -1
End If

Date ld_bilfromdt, ld_biltodt
Long ll_orderno, ll_cnt
String ls_item
ld_bilfromdt = dw_detail.object.bil_fromdt[1]
ld_biltodt   = dw_detail.object.bil_todt[1]

Select orderno
  into :ll_orderno
  From ContractDet
 where contractseq = :il_contractseq 
   and rownum = 1 ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "select Error(CONTRACTDET)")
	RollBack;
	Return -1
End If		

SELECT ITEMCOD
  INTO :ls_item
  FROM CONTRACTDET
 WHERE ORDERNO     = :ll_orderno
   AND ITEMCOD     = :is_itemcod 
	AND CONTRACTSEQ = :il_contractseq;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "select  Error(CONTRACTDET)")
	Return -1
	
ElseIf SQLCA.SQLCode = 100 Then
	
	INSERT INTO CONTRACTDET
			 ( ORDERNO
			 , ITEMCOD
			 , CONTRACTSEQ
			 , BIL_FROMDT
			 , BIL_TODT        )
	  VALUES
			 ( :ll_orderno
			 , :is_itemcod
			 , :il_contractseq
			 , :ld_bilfromdt
			 , :ld_biltodt     );
			 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Insert Error(CONTRACTDET)")
		RollBack;
		Return -1
	End If	
ElseIf SQLCA.SQLCode = 0 Then

	UPDATE CONTRACTDET
		SET BIL_FROMDT = :ld_bilfromdt
		  , BIL_TODT   = :ld_biltodt
	 WHERE ORDERNO    = :ll_orderno
		AND ITEMCOD    = :is_itemcod;
				 
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "update Error(CONTRACTDET)")
		RollBack;
		Return -1
	End If	
End If	

//P_SAVE.enabled = False
f_msg_info(3000,This.Title,"Save")
p_save.TriggerEvent("ue_disable")
COMMIT;

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_itemadd_popup_v20
boolean visible = false
integer x = 0
integer y = 548
integer width = 1810
integer height = 264
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validinfo_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_itemadd_popup_v20
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within b1w_reg_itemadd_popup_v20
integer x = 859
integer y = 428
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_itemadd_popup_v20
boolean visible = false
integer x = 14
integer y = 552
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_itemadd_popup_v20
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_itemadd_popup_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_itemadd_popup_v20
integer x = 553
integer y = 428
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_itemadd_popup_v20
integer x = 64
integer y = 88
integer width = 1029
integer height = 184
integer taborder = 20
string dataobject = "b1dw_reg_itemadd_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;//integer li_return
//
//CHOOSE Case dwo.name
//
//    Case "validkey_type"
//		
//		is_validkey_type = data		
//
//		dw_detail.Object.validkey[1] = ""
//     	dw_detail.Object.validitem2[1] = ""
//    	dw_detail.Object.validitem3[1] = ""
//		
//		//dw_detail validkey 셋팅값
//		wf_validkey_setting()	
//
//End CHoose
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

////Help Window
//This.idwo_help_col[1] = This.Object.validkey
//This.is_help_win[1] = "b1w_hlp_validkeymst_v20"
//This.is_data[1] = "CloseWithReturn"
//
////유치파트너
//This.idwo_help_col[2] = This.Object.validitem3
//This.is_help_win[2] = "b1w_hlp_validkeymst_v20"
//
end event

event dw_detail::doubleclicked;////조상script 차후에 실행한다. validkey_type, used_level 데이타값 넘겨주기 위함
//IF dwo.name = "validkey" Then    //
//	If is_validkey_type = "" Then
//		f_msg_usr_err(200, Title, "인증KeyType")
//		dw_detail.SetRow(1)
//		dw_detail.ScrollToRow(1)
//		dw_detail.SetColumn("validkey_type")
//		return -1 
//	End If
//    this.is_data[4] = is_validkey_type	     //validkey_type
//	this.is_data[5] = is_used_level          //대리점의 인증Key사용권한
//ElseIf dwo.name = "validitem3" Then
//    this.is_data[4] = is_validkey_type_h     //validkey_type
//	this.is_data[5] = is_used_level_h        //대리점의 인증Key사용권한
//End If
//
//Call u_d_help::doubleclicked
//
//If dwo.name = "validkey" Then
//    IF is_crt_kind = is_crt_kind_code[4] Then   //type이 자원관리일 경우만
//		If dw_detail.iu_cust_help.ib_data[1] Then
//			dw_detail.Object.validkey[row] = &
//			dw_detail.iu_cust_help.is_data[1]
//		End If
//	End If
//ElseIf dwo.name = "validitem3" Then
//    IF is_crt_kind_h = is_crt_kind_code[4] Then  //type이 자원관리일 경우만
//		If dw_detail.iu_cust_help.ib_data[1] Then
//			dw_detail.Object.validitem3[row] = &
//			dw_detail.iu_cust_help.is_data[1]
//		End If
//	End If	
//End If
//
//Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_itemadd_popup_v20
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

type gb_1 from gb_cond within b1w_reg_itemadd_popup_v20
boolean visible = true
integer x = 46
integer y = 4
integer width = 1111
integer height = 324
integer taborder = 20
end type

