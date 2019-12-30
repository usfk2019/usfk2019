$PBExportHeader$b1w_reg_prepayment_pop.srw
$PBExportComments$[kem] 서비스 신청시 선납판매정보 등록
forward
global type b1w_reg_prepayment_pop from w_a_reg_m
end type
end forward

global type b1w_reg_prepayment_pop from w_a_reg_m
integer width = 3305
integer height = 1764
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
end type
global b1w_reg_prepayment_pop b1w_reg_prepayment_pop

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt, is_act_gu, is_itemcod
String is_priceplan,is_customerid, is_partner, is_svccod, is_direct_paytype
String is_gubun = '1', is_gu = '1'
Long il_cnt, il_contractseq
Boolean ib_order

end variables

forward prototypes
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wfi_get_hwseq (string as_serialno, long al_row)
end prototypes

public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod);/*------------------------------------------------------------------------
	Name	:	wfi_del_quotainfo
	Desc.	:	고객에대한 서비스 신청상태가 아직 개통상태가 아니면
				할부정보를 지우고 다시 등록할 수 있게 한다.
	Arg.	: 	String	-as_orderno
							-as_customerid
							-as_itemcod
	Ret.	:	-1 Error
				0 성공
	Date	:	2002.10.03
--------------------------------------------------------------------------*/
Delete From quota_info
Where to_char(orderno) = :as_orderno and customerid = :as_customerid
		and itemcod = :as_itemcod;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Delete Error(QUOTA_INFO)")
	Return  -1
End If

Commit;
Return 0
end function

public function integer wfi_get_hwseq (string as_serialno, long al_row);
/*------------------------------------------------------------------------	
	Name	:	wfi_get_hwseq
	Desc.	: 	장비 시리얼을 가지고 장비구분 자료 가져오기
	Arg	:	String ls_serialno
	Ret.	:	0 		Seccess
				-1 	Error
	Ver.	: 	1.0
	Date	: 	2002.10.30
---------------------------------------------------------------------------*/
Integer li_cnt
Long ll_adseq, ll_old_adseq = 0
String ls_adtype

Select count(*)
Into :li_cnt
From admst
Where serialno = :as_serialno;

//Data Not Fount
If li_cnt = 0 Then
 	f_msg_usr_err(201, Title, "Serial No")
	dw_cond.SetColumn("serialno")
	Return - 1
End If

//해당 정보 가져오기
Select adseq, adtype, mv_partner
Into :ll_adseq, :ls_adtype, :is_partner
From admst
Where serialno = :as_serialno;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(ADMST)")
	Return  -1
End If

dw_detail.object.adseq[al_row] = ll_adseq
dw_detail.object.adtype[al_row] = ls_adtype

Return 0
end function

on b1w_reg_prepayment_pop.create
call super::create
end on

on b1w_reg_prepayment_pop.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_prepayment_pop
	Desc	: 	선불서비스 신청시 선납판매정보 등록
	Ver.	:	1.0
	Date	: 	2004.12.09
	programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/

b1u_dbmgr12	lu_dbmgr

is_act_gu = ""  	//신청/ 처리 구분
is_orderdt = ""
is_orderno = ""
is_priceplan = ""
is_customerid = ""
il_cnt = 0

//window 중앙에
f_center_window(b1w_reg_prepayment_pop)

//Data 받아오기
ib_order          = iu_cust_msg.ib_data[1]
is_orderno        = String(iu_cust_msg.il_data[1])
il_contractseq    = iu_cust_msg.il_data[2]
is_customerid     = iu_cust_msg.is_data2[2]
is_pgmid          = iu_cust_msg.is_data2[3]
is_act_gu         = iu_cust_msg.is_data2[4]
is_direct_paytype = iu_cust_msg.is_data2[5]

dw_cond.object.customerid[1] = is_customerid
dw_cond.object.customernm[1] = is_customerid
dw_cond.object.orderno[1]    = is_orderno

//priceplan, itemcod, itemnm, orderdt 가져오기
lu_dbmgr = Create b1u_dbmgr12
lu_dbmgr.is_caller = "b1w_reg_prepayment_pop%getdata"
lu_dbmgr.is_data[1] = is_orderno
lu_dbmgr.is_data[2] = is_customerid
lu_dbmgr.uf_prc_db()
If lu_dbmgr.ii_rc < 0 Then
	Destroy lu_dbmgr
	Return
Else
	//조건에 해당하는 data 가져오기
 	is_svccod      = lu_dbmgr.is_data[3]
	is_priceplan   = lu_dbmgr.is_data[4]
	is_orderdt     = lu_dbmgr.is_data[5]
	
End If

dw_cond.Object.svccod[1]    = is_svccod
dw_cond.Object.priceplan[1] = is_priceplan

dw_cond.SetReDraw(True)

Destroy lu_dbmgr

Trigger Event ue_ok()

is_gu = '2'
end event

event type integer ue_extra_save();String ls_paytype, ls_paydt, ls_remark
Long   ll_row, ll_saleamt

For ll_row = 1 To dw_detail.RowCount()
	ls_paytype = fs_snvl(dw_detail.Object.paytype[ll_row], '')
	ls_paydt   = String(dw_detail.Object.paydt[ll_row],'yyyymmdd')
	ll_saleamt = dw_detail.Object.sale_amt[ll_row]
	
	If IsNull(ls_paydt) Then ls_paydt = ""
		
	If ls_paytype <> "" Then 
		If ls_paydt = "" Then
			f_msg_info(9000, Title, "납부방법, 납부일은 같이 입력하셔야 합니다.")
			dw_detail.SetColumn("paydt")
			dw_detail.SetRow(ll_row)
			Return -1
		End If
	Else
		If ls_paydt <> "" Then
			f_msg_info(9000, Title, "납부방법, 납부일은 같이 입력하셔야 합니다.")
			dw_detail.SetColumn("paytype")
			dw_detail.SetRow(ll_row)
			Return -1
		End If
	End If
	If ls_paytype <> ""  And ls_paydt <> "" Then
		dw_detail.SetItem(ll_row, 'payamt', ll_saleamt)
	End If
Next

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null, ls_paytype
Dec    ldc_saleamt

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If
If Trigger Event ue_extra_save() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	dw_detail.SetFocus()
	Trigger Event ue_reset()
	Return LI_ERROR
End If

If dw_detail.Update() < 0  Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	dw_detail.SetFocus()
	Trigger Event ue_reset()
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	ls_paytype = fs_snvl(dw_detail.object.paytype[1], '')
	If ls_paytype <> '' Then
		is_gubun = '2'
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")		
	End If
End If

f_msg_info(3000,This.Title,"Save")
//Trigger Event ue_reset()

dw_cond.Enabled = False
//dw_detail.Enabled = False



Return 0
end event

event closequery;Int li_rc

dw_detail.AcceptText()

//다시 재정의
If (dw_detail.ModifiedCount() > 0) and il_cnt = 0 Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
	//MessageBox(This.Title, "'서비스품목 할부 등록' 메뉴에서 할부정보를 등록하십시오")
   If li_rc <> 1 Then  Return 1 //Process Cancel
	If is_gubun <> '2' Then 
		f_msg_info(9000, Title, "첫달은 선납상품 수납하셔야 합니다.") 
		Return 1
	End if
   Return 0
End If


end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

String ls_null
SetNull(ls_null)
dw_detail.Reset()

dw_cond.Enabled = True
//dw_detail.object.serialno[1] = ls_null
//dw_detail.object.adseq[1] = 0
//dw_detail.SetColumn("serialno")

//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")

If is_gu = '2' Then
	Trigger Event ue_ok()
End If


Return 0
end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String ls_customerid, ls_orderno, ls_where, ls_payment_method, ls_ref_desc
Long   ll_row


ls_customerid = Trim(dw_cond.object.customerid[1])
ls_orderno    = Trim(dw_cond.Object.orderno[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_orderno) Then ls_orderno = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return 
End If

If ls_orderno = "" Then
	f_msg_info(200, Title, "신청번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("orderno")
	Return 
End If


ls_where = ""
ls_where += " customerid ='" + ls_customerid + "' AND TO_CHAR(orderno) = '" + ls_orderno + "' "

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

SetRedraw(False)

If ll_row > 0 Then
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

//payment method default setting
ls_payment_method = fs_get_control("B1","P603", ls_ref_desc)
dw_detail.object.paytype[1] = ls_payment_method

SetRedraw(True)
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_prepayment_pop
integer x = 101
integer y = 64
integer width = 2405
integer height = 304
string dataobject = "b1dw_cnd_reg_prepayment_pop"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;//해당 모델에 대한 장비 시리얼 번호 가져오기
DataWindowChild ldc_child
String  ls_filter, ls_serialno,ls_itemcod, ls_status, ls_desc, ls_gubun
Integer li_exist, li_rc
Long    ll_cnt
Dec     ldc_basicamt, ldc_saleamt, ldc_deposit, ldc_beforeamt, ldc_receamt


Choose Case dwo.name
	Case "modelno"
		//색깔 변하게 하기 
		If IsNull(data) or data = "" Then
			This.object.modelno.Background.Color = RGB(255, 255, 255)
			This.object.modelno.Color = RGB(0, 0, 0)
			This.object.serialno.Background.Color = RGB(255, 255, 255)
			This.object.serialno.Color = RGB(0, 0, 0)
			This.object.serialno.Protect = 1
		Else
			This.object.modelno.Background.Color = RGB(108, 147, 137)
			This.object.modelno.Color = RGB(255, 255, 255)
			This.object.serialno.Background.Color = RGB(108, 147, 137)
			This.object.serialno.Color = RGB(255, 255, 255)
			This.object.serialno.Protect = 0
		End If
		
		//장비재고상태코드
		ls_status = fs_get_control("E1", "A100", ls_desc)
		
		This.object.serialno[row] = ''				
		li_exist = dw_cond.GetChild("serialno", ldc_child)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Serial No.")
		ls_filter = "modelno = '" + data  + "' And status = '" + ls_status + "' "
		ldc_child.SetTransObject(SQLCA)
		li_exist =ldc_child.Retrieve()
		ldc_child.SetFilter(ls_filter)			//Filter정함
		ldc_child.Filter()

//	Case "serialno" 
//   	//Data 확인 작업
//		If IsNull(data) Then data = ""
//		If data <> "" Then
//			If wfi_get_hwseq(data) = - 1 Then 
//				Return 2
//			End If
//		End If
		
	Case "beforeamt"
		ldc_basicamt  = This.object.basicamt[1]
		ldc_saleamt   = This.object.saleamt[1]
		ldc_deposit   = This.object.deposit[1]
		ls_gubun      = Trim(This.object.gubun[1])
		ldc_receamt   = 0
		
		If ls_gubun = "Y" Then
			ldc_receamt = Dec(data)
			This.object.receamt[1] = ldc_receamt
						
			ldc_saleamt = (ldc_basicamt - Dec(data)) + ldc_deposit
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		Else
			ldc_receamt = Dec(data) + ldc_deposit
			This.object.receamt[1] = ldc_receamt
						
			ldc_saleamt = ldc_basicamt - Dec(data)
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		End If
		
	Case "cnt"
		ldc_basicamt = This.object.basicamt[1]
		ll_cnt = Long(data)
		
		If data <> "" Then
			SELECT NVL(DEPOSIT,0)
			  INTO :ldc_deposit
			  FROM DEPOSITMST
			 WHERE FRAMT <= :ldc_basicamt
			   AND NVL(TOAMT, (:ldc_basicamt + 10)) >= :ldc_basicamt
			   AND QUOTAMM = :ll_cnt
			   AND :is_orderdt >= (SELECT TO_CHAR(MAX(FROMDT),'YYYYMMDD')
		                            FROM DEPOSITMST
                                 WHERE FRAMT <= :ldc_basicamt
                                   AND NVL(TOAMT, (:ldc_basicamt + 10)) >= :ldc_basicamt
        		                       AND QUOTAMM = :ll_cnt) ;
																	  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(Title, "Select Error(DEPOSIT)")
				Return 2
			End If
			
			If IsNull(ldc_deposit) Then ldc_deposit = 0
			This.object.deposit[1] = ldc_deposit
		End If
	
		ldc_beforeamt = This.object.beforeamt[1]
		ls_gubun      = Trim(This.object.gubun[1])
		ldc_saleamt   = This.object.saleamt[1]
		
		ldc_receamt = 0 
			
		If ls_gubun = "Y" Then
			ldc_receamt = ldc_beforeamt
			This.object.receamt[1] = ldc_receamt
						
			ldc_saleamt = (ldc_basicamt - ldc_beforeamt) + ldc_deposit
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		Else
			ldc_receamt = ldc_beforeamt + ldc_deposit
			If ldc_receamt <> 0 Then
				This.object.receamt[1] = ldc_receamt
			End If
			
			ldc_saleamt = ldc_basicamt - ldc_beforeamt
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		End If
		
	Case "gubun"
		ldc_basicamt  = This.object.basicamt[1]
		ldc_beforeamt = This.object.beforeamt[1]
		ldc_receamt   = This.object.receamt[1]
		ldc_saleamt   = This.object.saleamt[1]
		ll_cnt        = This.object.cnt[1]
		ldc_deposit   = This.object.deposit[1]
		
		ldc_receamt = 0 
		If data = "Y" Then
			ldc_receamt = ldc_beforeamt
			This.object.receamt[1] = ldc_receamt
						
			ldc_saleamt = (ldc_basicamt - ldc_beforeamt) + ldc_deposit
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		Else
			ldc_receamt = ldc_beforeamt + ldc_deposit
			This.object.receamt[1] = ldc_receamt
						
			ldc_saleamt = ldc_basicamt - ldc_beforeamt
			If ldc_saleamt <> 0 Then
				This.object.saleamt[1] = ldc_saleamt
			End If
		End If

End Choose


Return 0 


end event

event dw_cond::buttonclicked;call super::buttonclicked;
If dwo.name = "b_item" Then
	iu_cust_msg = Create u_cust_a_msg		
	iu_cust_msg.is_pgm_name = "판매상품상세"
	iu_cust_msg.is_grp_name = "임대품목"
	iu_cust_msg.is_data[1]  = is_orderno						//order number
	iu_cust_msg.is_data[2]  = is_priceplan                //priceplan
	iu_cust_msg.is_data[3]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	
	 
   OpenWithParm(b1w_inq_rental_item_popup, iu_cust_msg)
	
	Destroy iu_cust_msg
End If
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_prepayment_pop
boolean visible = false
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_prepayment_pop
integer x = 2656
integer y = 180
boolean originalsize = false
end type

event p_close::clicked;If is_gubun = '2' Then
	Parent.TriggerEvent('ue_close')
Else
	f_msg_info(9000, Title, "첫달은 선납상품 수납하셔야 합니다.") 
	Return
End If
end event

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_prepayment_pop
integer width = 2523
integer height = 384
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_prepayment_pop
boolean visible = false
integer x = 1010
integer y = 1888
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_prepayment_pop
boolean visible = false
integer x = 709
integer y = 1888
end type

type p_save from w_a_reg_m`p_save within b1w_reg_prepayment_pop
integer x = 50
integer y = 1560
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_prepayment_pop
integer x = 37
integer y = 412
integer width = 3232
integer height = 1120
string dataobject = "b1dw_reg_prepayment_pop"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;//Setting
Long ll_row, i
ll_row = dw_detail.RowCount()

If ll_row <= 0 Then Return 0

If ll_row > 0 Then
	p_reset.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild ldc_child, ldc
String ls_status, ls_desc, ls_filter, ls_modelnm, ls_itemcod
Integer li_exist, li_row

Choose Case dwo.name
	Case "serialno" 
   	//Data 확인 작업
		If IsNull(data) Then data = ""
		If data <> "" Then
			If wfi_get_hwseq(data, row) = - 1 Then 
				Return 2
			End If
		End If
		
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_prepayment_pop
integer x = 352
integer y = 1560
boolean enabled = true
end type

