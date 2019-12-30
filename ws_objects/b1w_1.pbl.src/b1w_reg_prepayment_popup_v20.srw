$PBExportHeader$b1w_reg_prepayment_popup_v20.srw
$PBExportComments$[ohj] 선납서비스 수납처리-popup v20
forward
global type b1w_reg_prepayment_popup_v20 from w_base
end type
type p_1 from u_p_save within b1w_reg_prepayment_popup_v20
end type
type p_create from u_p_create within b1w_reg_prepayment_popup_v20
end type
type p_select from picture within b1w_reg_prepayment_popup_v20
end type
type dw_check from u_d_base within b1w_reg_prepayment_popup_v20
end type
type dw_cond from u_d_external within b1w_reg_prepayment_popup_v20
end type
type p_close from u_p_close within b1w_reg_prepayment_popup_v20
end type
type p_ok from u_p_ok within b1w_reg_prepayment_popup_v20
end type
type gb_1 from groupbox within b1w_reg_prepayment_popup_v20
end type
end forward

global type b1w_reg_prepayment_popup_v20 from w_base
integer width = 2802
integer height = 612
string title = "Copy Standard Rate Zones"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
event ue_create ( )
event type integer ue_save ( )
p_1 p_1
p_create p_create
p_select p_select
dw_check dw_check
dw_cond dw_cond
p_close p_close
p_ok p_ok
gb_1 gb_1
end type
global b1w_reg_prepayment_popup_v20 b1w_reg_prepayment_popup_v20

type variables
String  is_cnd_invf_type, is_cnd_pay_method, is_cnd_inv_type, is_cnd_chargedt, &
        is_cnd_bankpay, is_cnd_creditpay, is_cnd_etcpay, is_day
Date    id_workdt, id_inputclosedt, id_cnd_trdt
Integer li_return
String  is_return = '1'

u_cust_db_app iu_mdb_app
end variables

forward prototypes
public function integer wf_billfile_create ()
end prototypes

event ue_close();closewithreturn(this,is_return)
Close(This)
end event

event ue_ok();//Long ll_row
//
////Retrieve
//ll_row = dw_cond.Retrieve()
//
//dw_cond.SetFocus()
//dw_cond.SelectRow(0, False)
//dw_cond.ScrollToRow(1)
//dw_cond.SelectRow(1, True)
//
//
//If ll_row = 0 Then
//	f_msg_info(1000, Title, "")
//ElseIf ll_row < 0 Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
//	Return
//End If
//
end event

event ue_create();//Choose Case dwo.name
//	Case "cnd_chargedt"
//		
//		Date ld_reqdt
//		SELECT REQDT
//		  INTO :ld_reqdt
//		  FROM REQCONF
//		 WHERE CHARGEDT = :data ;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(Title, "select Error(REQCONF)")
//			Return -1
//			
//		ElseIf SQLCA.SQLCode = 100 Then
//			f_msg_sql_err(Title, "select no-data(REQCONF)")
//
//		Else
//			dw_cond.SetItem(row, 'cnd_trdt', ld_reqdt)
//		
//		End If		
//		  
//End Choose
//
//Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
String   ls_paydt, ls_paytype, ls_remark
Date ld_paydt
Long     i, ll_seq
//Int li_return

//ii_error_chk = -1
If dw_cond.AcceptText() < 0 Then
	dw_cond.SetFocus()
	Return LI_ERROR
End If

ls_paydt   = string(dw_cond.object.paydt[1], 'yyyymmdd')
ls_paytype = string(dw_cond.object.paytype[1])
ls_remark  = string(dw_cond.object.remark[1])
ld_paydt   = dw_cond.object.paydt[1]

If Isnull(ls_paydt)   Then ls_paydt = ''
If Isnull(ls_paytype) Then ls_paytype = ''

If ls_paydt = '' Then
	f_msg_usr_err(200, Title, "결제일자")
	dw_cond.SetColumn("paydt")
	Return -2
End If

If ls_paytype = '' Then
	f_msg_usr_err(200, Title, "결제방법")
	dw_cond.SetColumn("paytype")
	Return -2
End If

For i = 1 To iu_cust_msg.idw_data[1].rowcount()
	If iu_cust_msg.idw_data[2].object.gubun[i] = '1' Then
		//seq
		SELECT SEQ_PREPAYMENT.NEXTVAL
		  INTO :ll_seq
		  FROM dual;
		  
		iu_cust_msg.idw_data[2].object.seq[i]      = ll_seq
		iu_cust_msg.idw_data[2].object.paydt[i]    = ld_paydt
		iu_cust_msg.idw_data[2].object.paytype[i]  = ls_paytype	
		iu_cust_msg.idw_data[2].object.remark[i]   = ls_remark
		iu_cust_msg.idw_data[2].object.pgm_id[i]	 = gs_pgm_id[gi_open_win_no]
		iu_cust_msg.idw_data[2].object.crt_user[i] = gs_user_id
		iu_cust_msg.idw_data[2].object.crtdt[i]    = fdt_get_dbserver_now()
		iu_cust_msg.idw_data[2].object.gubun[i]    = '3'
	Else
		Exit
	End If
Next

is_return = '2'

This.Trigger Event ue_close()

Return 0

end event

public function integer wf_billfile_create ();//String  is_cnd_invf_type, is_cnd_pay_method, is_cnd_inv_type, is_cnd_chargedt, &
//        is_cnd_bankpay, is_cnd_creditpay, is_cnd_etcpay
//Date    id_workdt, id_inputclosedt



//SELECT RECORD
//
//  FROM INVF_RECORDMST 
// WHERE INVF_TYPE = :is_cnd_invf_type;
// 
//SELECT MAX(SEQNO)
//  INTO :ll_seqno
//  FROM INVF_RECORDDET 
// WHERE INVF_TYPE = :is_cnd_invf_type
//   AND RECORD    = :;
// 

//
//ls_fr_partner = dw_detail.Object.fr_partner[1]
//ls_remark     = dw_detail.Object.remark[1]
//
//If IsNull(ls_fr_partner) Then ls_fr_partner = ""
//If IsNull(ls_remark)     Then ls_remark     = ""
//
//If ls_fr_partner = "" Then
//	Return -2
//End If
//
//If il_cnt = 0 Then
//	f_msg_info(3020, Title, "There is no quota for vailidation key. Generate the vailidation key.")
//	Return -2
//End If
//
//If il_cnt < il_reqqty Then
//	If f_msg_ques_yesno2(9000, Title, "Available quata is [ " +  string(il_cnt) + " ]. Your request is unable to provide. ~r~n " + &
//	                                  " Do you want to quate available quantity? ", 1)    = 2 Then
//		Return -2
//	Else
//		//할당가능 수량으로...
//		ll_reqqty_cu = il_cnt
//	End If
//End If
//
//If ll_reqqty_cu <> 0 Then //할당가능수량
//	ll_su = ll_reqqty_cu
//	
//Else //요청수량만큼 할당
//	ll_su = il_reqqty
//	
//End If
//
////SEQ
//Select seq_validkey_moveno.nextval 
//  into :ll_seq 
//  from dual;
// 

//String  is_cnd_invf_type, is_cnd_pay_method, is_cnd_inv_type, is_cnd_chargedt, &
//        is_cnd_bankpay, is_cnd_creditpay, is_cnd_etcpay
//Date    id_workdt, id_inputclosedt

Integer li_rc
////***** 처리부분 *****
b5u_dbmgr iu_db

iu_db = Create b5u_dbmgr

iu_db.is_title = Title
iu_db.is_data[1] = is_cnd_invf_type
iu_db.is_data[2] = is_cnd_pay_method	 
iu_db.is_data[3] = is_cnd_inv_type	
iu_db.is_data[4] = is_cnd_chargedt				
iu_db.is_data[5] = is_cnd_bankpay
iu_db.is_data[6] = is_cnd_creditpay
iu_db.is_data[7] = is_cnd_etcpay
iu_db.is_data[8] = gs_user_id
iu_db.is_data[9] = gs_pgm_id[gi_open_win_no]

iu_db.id_data[1] = id_workdt	
iu_db.id_data[2] = id_inputclosedt
iu_db.id_data[3] = id_cnd_trdt

//iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_01()
li_rc	= iu_db.ii_rc

If li_rc < 0 Then
//	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy b5u_dbmgr
	Return -1
End If

//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy b5u_dbmgr
//
Return 0
end function

on b1w_reg_prepayment_popup_v20.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_create=create p_create
this.p_select=create p_select
this.dw_check=create dw_check
this.dw_cond=create dw_cond
this.p_close=create p_close
this.p_ok=create p_ok
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_create
this.Control[iCurrent+3]=this.p_select
this.Control[iCurrent+4]=this.dw_check
this.Control[iCurrent+5]=this.dw_cond
this.Control[iCurrent+6]=this.p_close
this.Control[iCurrent+7]=this.p_ok
this.Control[iCurrent+8]=this.gb_1
end on

on b1w_reg_prepayment_popup_v20.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_create)
destroy(this.p_select)
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_ok)
destroy(this.gb_1)
end on

event open;call super::open;/*-------------------------------------------------------
	Name	: b1w_reg_prepayment_popup_v20
	Desc.	: 
	Ver.	: 1.0
	Date	: 2006.02.09
	Programer : oh hye jin
---------------------------------------------------------*/
Long   ll_row
String ls_itemcod, ls_ref_desc, ls_filter, ls_svccode, ls_priceplan
DataWindowChild ldc_paytype
iu_mdb_app = Create u_cust_db_app

f_center_window(b1w_reg_prepayment_popup_v20)

dw_cond.SetItem(1, 'sale_amt'    , iu_cust_msg.il_data[1])
dw_cond.SetItem(1, 'payamt'      , iu_cust_msg.il_data[2])
dw_cond.SetItem(1, 'taxamt'      , iu_cust_msg.il_data[3])
dw_cond.SetItem(1, 'inputclosedt', iu_cust_msg.idt_data[1])
dw_cond.SetItem(1, 'paydt'       , fdt_get_dbserver_now())

ls_svccode   = iu_cust_msg.is_data[1]
ls_priceplan = iu_cust_msg.is_data[2]

//납부방법 서비스, 가격정책별로 조회 되도록
ll_row = dw_cond.GetChild("paytype", ldc_paytype)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "     svccod = '" + ls_svccode + "' " &
          + " and decode(priceplan, 'ALL', '" + ls_priceplan+ "', priceplan) =  '" + ls_priceplan+ "'"

ldc_paytype.SetFilter(ls_filter)			//Filter정함
ldc_paytype.Filter()
ldc_paytype.SetTransObject(SQLCA)
ll_row = ldc_paytype.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "결제방법 Retrieve()")
	Return -1
End If	

//납기일자
//is_day = fs_get_control("B1", "P601", ls_ref_desc)	
dw_cond.Enabled = True
//TriggerEvent("ue_ok")

Return 0 

end event

type p_1 from u_p_save within b1w_reg_prepayment_popup_v20
integer x = 2130
integer y = 56
end type

type p_create from u_p_create within b1w_reg_prepayment_popup_v20
boolean visible = false
integer x = 2336
integer y = 324
boolean enabled = false
end type

event clicked;call super::clicked;//String  ls_cnd_invf_type, ls_cnd_pay_method, ls_cnd_inv_type, ls_cnd_chargedt, &
//        ls_cnd_bankpay, ls_cnd_creditpay, ls_cnd_etcpay
//Date    ld_cnd_trdt, ld_workdt, ld_inputclosedt
//Integer li_return
//ls_cnd_invf_type  = dw_cond.object.cnd_invf_type[1]
//ls_cnd_chargedt   = dw_cond.object.cnd_chargedt[1]
//ls_cnd_pay_method = dw_cond.object.cnd_pay_method[1]  //giro
//ls_cnd_bankpay    = dw_cond.object.cnd_bankpay[1] 		//자동이체
//ls_cnd_creditpay  = dw_cond.object.cnd_creditpay[1] 	//카드
//ls_cnd_etcpay     = dw_cond.object.cnd_etcpay[1]	 	//기타
//ls_cnd_inv_type   = dw_cond.object.cnd_inv_type[1]		//청구서 유형
//ld_workdt         = dw_cond.object.cnd_workdt[1]
//ld_inputclosedt   = dw_cond.object.cnd_inputclosedt[1]
//
//If IsNull(ls_cnd_invf_type)  Then ls_cnd_invf_type  = ''
//If IsNull(ls_cnd_chargedt)   Then ls_cnd_chargedt   = ''
//
//SetPointer(HourGlass!)
//
////필수 항목 check 
//If ls_cnd_invf_type = "" Then
//	f_msg_usr_err(200, Title, "Bill File Type")
//	dw_cond.SetColumn("cnd_invf_type")
//	Return -2
//End If
//
//If ls_cnd_chargedt = "" Then
//	f_msg_usr_err(200, Title, "Bii Cycle")
//	dw_cond.SetColumn("cnd_chargedt")
//	Return -2
//End If
//
//If ls_cnd_pay_method = 'N' And ls_cnd_bankpay = 'N' And ls_cnd_creditpay = 'N' And ls_cnd_etcpay = 'N' Then
//	f_msg_usr_err(200, Title, "Pay Method 중 한가지는 선택하여야 합니다.")
//	dw_cond.SetColumn("cnd_pay_method")
//	Return -2
//End If
//
//
//u_cust_db_app iu_cust_db_app
//li_return = wf_billfile_create()
//
//Choose Case li_return
//	Case Is < -2
//		dw_cond.SetFocus()
//
//	Case -2
//		dw_cond.SetFocus()
//	Case -1
//		rollback;
//		
//		f_msg_info(3010,Title,"Save")
//				
//	Case Is >= 0
//		commit;
//		//This.Trigger Event ue_ok()
//		
//		f_msg_info(3000,Title,"Save")
//		 
//End Choose	
//	//ii_error_chk = 0
//	//p_new.TriggerEvent("ue_enable")
//	
//Return 0
//SetPointer(Arrow!)
end event

type p_select from picture within b1w_reg_prepayment_popup_v20
boolean visible = false
integer x = 2368
integer y = 200
integer width = 283
integer height = 96
string picturename = "select_e.gif"
boolean focusrectangle = false
end type

event clicked;//표준 요금 조회
//String ls_priceplan, ls_pgm_id, ls_priceplan_old
//Long ll_row, i, ll_baserate, ll_addrate, ll_cnt
//Dec{6} ldc_baseamt, ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
//Dec{6} ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5
//DateTime ldt_sysdate
//Integer li_result

//dw_cond.accepttext()
//ldt_sysdate = fdt_get_dbserver_now() 
//
//ls_priceplan = Trim(dw_cond.object.priceplan[1])
//ls_priceplan_old = iu_cust_msg.is_data[1]
//ls_pgm_id = iu_cust_msg.is_data[2]
//ldc_baseamt = dw_cond.object.baseamt[1]
//ll_baserate = dw_cond.object.baserate[1]
//ll_addrate = dw_cond.object.addrate[1]
//ldc_addamt = dw_cond.object.addamt[1]
//
//If IsNull(ls_priceplan) Then ls_priceplan = ""
//
////필수 항목 Check
//If ls_priceplan = "" Then
//	f_msg_info(200, Title,"Price Plan")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("priceplan")
//   Return
//End If
//
//If ll_baserate < 0 Then 
//	f_msg_usr_err(201, title, "Initial Rate x (Fixed Rate)")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("baserate")
//	Return
//End If
//
//If ll_addrate < 0 Then 
//	f_msg_usr_err(201, title, "Add'l Rate  x (Fixed Rate)")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("addrate")
//	Return
//End If
String ls_itemkey_desc, ls_itemtype, ls_pgmcode
Long   ll_row, ll_itemkey, ll_new_row, ll_rows
ll_row          = dw_cond.Getrow()
ll_itemkey      = dw_cond.object.itemkey[ll_row]
ls_itemkey_desc = dw_cond.object.itemkey_desc[ll_row]
ls_itemtype     = dw_cond.object.itemtype[ll_row]
ls_pgmcode      = dw_cond.object.pgmcode[ll_row]

iu_cust_msg.idw_data[1].AcceptText()
ll_rows = iu_cust_msg.idw_data[1].RowCount()
							

//해당 PricePlan으로 Setting
ll_new_row = iu_cust_msg.idw_data[1].Insertrow(0)

iu_cust_msg.idw_data[1].ScrollToRow(ll_new_row)

iu_cust_msg.idw_data[1].object.itemkey[ll_new_row]      = ll_itemkey
iu_cust_msg.idw_data[1].object.itemkey_desc[ll_new_row] = ls_itemkey_desc
iu_cust_msg.idw_data[1].object.itemtype[ll_new_row]     = ls_itemtype
iu_cust_msg.idw_data[1].object.pgmcode[ll_new_row]      = ls_pgmcode
iu_cust_msg.idw_data[1].object.item_value[ll_new_row]   ='P'
iu_cust_msg.idw_data[1].object.invf_type[ll_new_row]    = iu_cust_msg.is_data[1]
iu_cust_msg.idw_data[1].object.record[ll_new_row]       = iu_cust_msg.is_data[2]
iu_cust_msg.idw_data[1].object.seqno[ll_new_row]        = iu_cust_msg.il_data[1]


//복사한다.
//dw_check.RowsCopy(1,dw_check.RowCount(), &
//								Primary!,iu_cust_msg.idw_data[1] ,1, Primary!)
//	

//For i = ll_row To ll_row
//	iu_cust_msg.idw_data[1].object.priceplan[i] = ls_priceplan_old
//	iu_cust_msg.idw_data[1].object.pgm_id[i]	= ls_pgm_id
//	iu_cust_msg.idw_data[1].object.crt_user[i] = gs_user_id
//	iu_cust_msg.idw_data[1].object.crtdt[1] = ldt_sysdate
//	iu_cust_msg.idw_data[1].object.updt_user[i] = gs_user_id
//	iu_cust_msg.idw_data[1].object.updtdt[1] = ldt_sysdate
//Next

end event

type dw_check from u_d_base within b1w_reg_prepayment_popup_v20
boolean visible = false
integer x = 23
integer y = 480
integer width = 2555
integer height = 672
integer taborder = 20
string dataobject = "b0dw_reg_zoncst3_check"
borderstyle borderstyle = stylebox!
end type

type dw_cond from u_d_external within b1w_reg_prepayment_popup_v20
integer x = 50
integer y = 48
integer width = 2002
integer height = 452
integer taborder = 10
string dataobject = "b1dw_cnd_prepayment_popup_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event buttonclicked;call super::buttonclicked;String   ls_direct_paytype, ls_st_enddt, ls_priceplan, ls_itemcod1, ls_oneoffcharge_yn, &
         ls_additem, ls_method, ls_bilfromdt, ls_customerid, ls_enddt_contract, &
			ls_max_saletodt, ls_direct_gubun, ls_direct_change, ls_direct_change_name
Long     ll_row, ll_contractseq, ll_period, ll_validity_term, ll_addunit, ll_i, ll_row_2, &
         ll_orderno, ll_count, ll_cnt = 0, ll_add = 0, ll_between
Date     ldt_period_extension, ldt_enddt, ldt_date_next_1, ld_bil_fromdt, ldt_date_next, &
		   ld_inputclosedt, ldt_max_saletodt, ld_enddt_contract, ldt_max_salefromdt
Decimal  ldc_unitcharge, ldc_payamt

dw_cond.Accepttext()
ll_row   = iu_cust_msg.idw_data[1].Getrow()
ll_row_2 = iu_cust_msg.idw_data[2].Getrow()

If ll_row   <= 0 Then Return
If ll_row_2 <= 0 Then Return
	 
ll_contractseq    = iu_cust_msg.idw_data[1].object.contractseq[ll_row]
ls_customerid     = iu_cust_msg.idw_data[1].object.customerid[ll_row]
ls_priceplan      = iu_cust_msg.idw_data[1].object.priceplan[ll_row]
ls_oneoffcharge_yn= iu_cust_msg.idw_data[1].object.oneoffcharge_yn[ll_row]
ls_itemcod1       = iu_cust_msg.idw_data[1].object.itemcod[ll_row]
ls_direct_paytype = fs_snvl(iu_cust_msg.idw_data[1].object.direct_paytype[ll_row], '')	

ll_orderno        = iu_cust_msg.idw_data[2].object.orderno[ll_row_2]
ldt_enddt         = Date(iu_cust_msg.idw_data[1].object.enddt[ll_row])    //기간만료일
ls_st_enddt       = String(ldt_enddt, 'YYYYMMDD')
ls_direct_change  = dw_cond.object.direct_paytype[1]
//ls_direct_gubun   = dw_cond.Describe("direct_proc_gubun.Alignment")


SELECT UNITCHARGE
	  , ADDUNIT
	  , METHOD
	  , NVL(ADDITEM, '') ADDITEM
	  , VALIDITY_TERM
  INTO :ldc_unitcharge
	  , :ll_addunit
	  , :ls_method
	  , :ls_additem
	  , :ll_validity_term
  FROM PRICEPLAN_RATE2
 WHERE PRICEPLAN = :ls_priceplan
	AND ITEMCOD   = :ls_itemcod1    ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " SELECT Error(PRICEPLAN_RATE2) RATE INFO")
	Return 
End If

If dwo.name  = 'bt_period' Then
	
	ll_period   = This.object.period[1]
	
	If IsNull(ll_period) Then ll_period = 0
	
	If ll_period = 0 Then
		f_msg_usr_err(200, Title, "기간연장")
		This.SetColumn("period")
		Return 
	ElseIf ll_period < 0 Then
		f_msg_usr_err(9000, Title, "기간 연장만 가능합니다.")
		This.SetColumn("period")
		Return 		
	End If

//	If f_msg_ques_yesno2(9000, Title, "현재 기간만료일은 " + string(ldt_enddt, 'yyyy/mm/dd') + "입니다. ~r~n " + &
//	                                  string(ll_period) + "회 연장하시면 만료일은 " +  기간연장 하시겠습니까?", 1) = 2 Then
//		Return
//	End If
	
	If ls_oneoffcharge_yn = 'Y' Then
		ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
	Else
		ldc_payamt = ldc_unitcharge
	End If
	
	If ls_direct_paytype = '100' Then	//청구서발송방식
		
		ld_bil_fromdt = fd_date_next(ldt_enddt, 1)
		
		If ls_method = 'A' Then  //daily 정액
		
			ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
			
			SELECT :ldt_date_next_1 -1 
			  INTO :ldt_date_next
			  FROM DUAL                 ;									
			
		ElseIf ls_method = 'M' Then //월정액
			ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
			
			SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
			  INTO :ldt_date_next
			  FROM DUAL;
			  
		End If	

		If f_msg_ques_yesno2(9000, Title, " 현재 기간만료일은 " + string(ldt_enddt, 'yyyy/mm/dd') + "입니다. ~r~n " + &
													 " " + string(ll_period) + "회 연장하시면 만료일은 " + string(ldt_date_next, 'yyyy/mm/dd')+ " 입니다. ~r~n " + &
													 " 기간연장 하시겠습니까? ", 1) = 2 Then
			Return
		End If

		UPDATE CONTRACTMST
			SET ENDDT          = :ldt_date_next
		 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(Title, " Update CONTRACTMST Table(ENDDT)")				
			Return 
		End If	
	
	ElseIf ls_direct_paytype = '200' Then  //직접입금방식
		For ll_i = 1 To ll_period 
			
			ld_bil_fromdt = fd_date_next(ldt_enddt, 1)  //salefromdt  -> TODT +1 
			
			If ls_method = 'A' Then  //daily 정액
			
				ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
				
				SELECT :ldt_date_next_1 -1 
				  INTO :ldt_date_next
				  FROM DUAL                 ;									
				
			ElseIf ls_method = 'M' Then //월정액
				ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
				
				SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
				  INTO :ldt_date_next
				  FROM DUAL;
				  
			End If		
		Next
		
		
		If f_msg_ques_yesno2(9000, Title, " 현재 기간만료일은 " + string(ldt_enddt, 'yyyy/mm/dd') + "입니다. ~r~n " + &
													 " " + string(ll_period) + "회 연장하시면 만료일은 " + string(ldt_date_next, 'yyyy/mm/dd')+ " 입니다. ~r~n " + &
													 " 기간연장 하시겠습니까? ", 1) = 2 Then
			Return
		End If
		
		For ll_i = 1 To ll_period 
			
			ld_bil_fromdt = fd_date_next(ldt_enddt, 1)  //salefromdt  -> TODT +1 
			
			If ls_method = 'A' Then  //daily 정액
			
				ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
				
				SELECT :ldt_date_next_1 -1 
				  INTO :ldt_date_next
				  FROM DUAL                 ;									
				
			ElseIf ls_method = 'M' Then //월정액
				ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
				
				SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
				  INTO :ldt_date_next
				  FROM DUAL;
				  
			End If	

			ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(is_day))			
		
			INSERT INTO PREPAYMENT 
						 ( seq, customerid, orderno, contractseq,
							itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt,
							crt_user, crtdt, pgm_id)
				VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
							:ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
							:ld_inputclosedt, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]);
								 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " INSERT Error(PREPAYMENT)")
				RollBack;
				Return 
			End If
			
		Next		
		
		UPDATE CONTRACTMST
			SET ENDDT          = :ldt_date_next
		 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(Title, " Update CONTRACTMST Table(ENDDT)")				
			Return 
		End If
		
	ElseIF ls_direct_paytype = '' Then
		f_msg_usr_err(9000, Title, "납부방식이 존재하지 않습니다. 기간연장 할 수 없습니다.")
		Return 
	End If
	
ElseIf dwo.name  = 'bt_payment' Then
	
	ls_direct_paytype = fs_snvl(This.object.direct_paytype[1], '')
	If ls_direct_paytype = '' Then 
		f_msg_usr_err(200, Title, "납부방식")
		This.SetColumn("direct_paytype")
		Return 
	End If
	
	If iu_cust_msg.idw_data[1].object.direct_paytype[ll_row]  = ls_direct_paytype Then
		f_msg_usr_err(9000, Title, "납부방식이 동일합니다. 다시 확인하세요.")
		This.SetColumn("direct_paytype")
		Return 		
	End If
	If ls_direct_change = '100' Then
		ls_direct_change_name = '청구서발송방식'
	ElseIf ls_direct_change = '200' Then
		ls_direct_change_name = '직접입금방식'
	End If
	If f_msg_ques_yesno2(9000, Title, "납부방식을 " + ls_direct_change_name + "으로 변경하시겠습니까?", 1) = 2 Then
		Return
	End If
	
	UPDATE CONTRACTMST
	   SET DIRECT_PAYTYPE = :ls_direct_paytype
	 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
	
	If SQLCA.SQLCode <> 0 Then
		RollBack;	
		f_msg_sql_err(Title, " Update CONTRACTMST Table(DIRECT_PAYTYPE)")				
		Return 
	End If
	
	//직접 방식 -> 청구서발송방식 
	If ls_direct_paytype = '100' Then
		DELETE FROM PREPAYMENT 
		      WHERE CONTRACTSEQ = :ll_contractseq
				  AND PAYTYPE IS NULL
				  AND PAYDT	  IS NULL  ;
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(Title, " DELETE PREPAYMENT Table")				
			Return 
		End If				  

	//청구서발송방식 -> 직접 방식
	ElseIf ls_direct_paytype = '200' Then
		
		SELECT MAX(SALETODT)
		     , MAX(SALEFROMDT)
		     , COUNT(*) 
		  INTO :ldt_max_saletodt
		     , :ldt_max_salefromdt
		     , :ll_count
		  FROM PREPAYMENT
		 WHERE CONTRACTSEQ = :ll_contractseq                 ;
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(Title, " SELECT PREPAYMENT Table (MAX SALETODT)")
			Return 
		End If	
		
		//최초 가격정책당시 지정된 횟수를 일수로 표시했을떄 만기일보다 작다면 만기일에 맞게 
		//prepayment를 늘리기 위해... 만기일자 가져온다
		SELECT ENDDT
		  INTO :ld_enddt_contract
		  FROM CONTRACTMST
		 WHERE CONTRACTSEQ = :ll_contractseq                 ;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			f_msg_sql_err(Title, " SELECT CONTRACTMST Table (ENDDT)")
			Return 
		End If
		
		ls_enddt_contract = string(ld_enddt_contract, 'yyyymmdd')
		ls_max_saletodt   = string(ldt_max_saletodt, 'yyyymmdd')
		
		If ls_method = 'A' Then  //daily 정액
			
		  SELECT to_number(to_date(:ls_enddt_contract,'yyyymmdd') - to_date(:ls_max_saletodt,'yyyymmdd')) / :ll_addunit 
		  	 INTO :ll_between
		  	 FROM DUAL ;	
				
			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(Title, " SELECT daily next date")
				Return 
			End If		
			
		ElseIf ls_method = 'M' Then //월정액
			
		  SELECT MONTHS_BETWEEN(to_date(:ls_enddt_contract,'yyyymmdd'), to_date(:ls_max_saletodt,'yyyymmdd'))
		  	 INTO :ll_between
		  	 FROM DUAL ;
			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(Title, " SELECT Month next date")
				Return 
			End If	
			
		End If
		
	   ll_cnt = ll_between
		
		If ll_cnt <= 0 Then Return
		
		If ls_oneoffcharge_yn = 'Y' Then
			ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
		Else
			ldc_payamt = ldc_unitcharge
		End If		
		
		ld_bil_fromdt = fd_date_next(ldt_max_saletodt, 1)

		For ll_i = 1 To ll_cnt
			If ll_i <> 1 Then
				ld_bil_fromdt = fd_date_next(ldt_date_next, 1)  //salefromdt  -> TODT +1 
			End If
			
			If ls_method = 'A' Then  //daily 정액
			
				ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
				
				SELECT :ldt_date_next_1 -1 
				  INTO :ldt_date_next
				  FROM DUAL                 ;									
				
			ElseIf ls_method = 'M' Then //월정액
				ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
				
				SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
				  INTO :ldt_date_next
				  FROM DUAL;
				  
			End If	

			ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(is_day))			
		
			INSERT INTO PREPAYMENT 
						 ( seq, customerid, orderno, contractseq,
							itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt,
							crt_user, crtdt, pgm_id)
				VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
							:ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
							:ld_inputclosedt, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]);
								 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " INSERT Error(PREPAYMENT)")
				RollBack;
				Return 
			End If
			
		Next		
		
		
	End If
	
End If
commit;
f_msg_info(3000,This.Title,"Save")

Trigger Event ue_close()


end event

type p_close from u_p_close within b1w_reg_prepayment_popup_v20
integer x = 2414
integer y = 56
integer taborder = 30
boolean originalsize = false
end type

type p_ok from u_p_ok within b1w_reg_prepayment_popup_v20
boolean visible = false
integer x = 2391
integer y = 248
end type

type gb_1 from groupbox within b1w_reg_prepayment_popup_v20
integer x = 37
integer y = 4
integer width = 2030
integer height = 508
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

