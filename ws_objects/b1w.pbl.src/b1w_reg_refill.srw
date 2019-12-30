$PBExportHeader$b1w_reg_refill.srw
$PBExportComments$[jsha] 선불수동충전
forward
global type b1w_reg_refill from w_a_reg_m_sql
end type
end forward

global type b1w_reg_refill from w_a_reg_m_sql
integer width = 3026
integer height = 2476
end type
global b1w_reg_refill b1w_reg_refill

type variables
String is_refill_type   //보상충전 Type
Long	il_row_before = 0
Dec{2} ic_refill_amt, ic_sale_amt
String is_partner, is_remark, is_refilldt, is_svctype_pre

end variables

forward prototypes
public function integer wf_refill_rate (string as_partner, string as_priceplan, string as_requestdt, decimal adc_price, ref decimal adc_rate)
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wf_refill_rate (string as_partner, string as_priceplan, string as_requestdt, decimal adc_price, ref decimal adc_rate);/*2003.07.26. parkkh
   [argument] 
	- as_partner 		string :유치partner
    - as_priceplan 		string :가격정책
	- as_opendt			string :
	- adc_price 		decimal: 상품가격
	- adc_rate			decimal: rate   <<== reference
	[return]
	   0	: 정상처리
	   1	: data notfound(select)
	  -1	: 비정상처리	*/


Select rate
 Into :adc_rate
 From refillpolicy
where partner = :as_partner  
 and priceplan = :as_priceplan 
 and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
 	      			  			  	   from refillpolicy 
				      				  where to_char(fromdt, 'yyyymmdd') <= :as_requestdt
									    and partner = :as_partner  
									    and priceplan = :as_priceplan
										and fromamt <= :adc_price
										and nvl(toamt, :adc_price +1) > :adc_price )
 and fromamt <= :adc_price
 and nvl(toamt, :adc_price + 1) > :adc_price ;

If SQLCA.SQLCode < 0 Then
	Return -1
ElseIf SQLCA.SQLCode  = 100 Then
	Return  1
End If

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm

Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0
end function

on b1w_reg_refill.create
call super::create
end on

on b1w_reg_refill.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc, ls_temp, ls_status
String ls_validkey, ls_customerid, ls_contractseq
Long ll_row, ll_priceplan_cnt
Dec lc_amt
Int li_index, i, li_rc

//** 상태:개통 **//
ls_ref_desc = ""
ls_status = fs_get_control("B0", "P223", ls_ref_desc)

ls_contractseq = Trim(String(dw_cond.Object.contractseq[1]))
If IsNull(ls_contractseq) Then ls_contractseq = ""

ls_validkey = trim(dw_cond.Object.validkey[1])
If IsNull(ls_validkey) Then ls_validkey = ""

ls_customerid = trim(dw_cond.Object.customerid[1])
If IsNull(ls_customerid) Then ls_customerid = ""

If ls_contractseq = "" and ls_validkey = "" and ls_customerid = "" Then
	f_msg_usr_err(200, Title, "계약번호, 인증key, 고객번호 중에 한가지를 반드시 입력하셔야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	Return
End If

ls_where = ""
If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(a.contractseq) = '" + ls_contractseq + "' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.contractseq in ( select contractseq from validinfo where validkey = '" + ls_validkey + "' ) "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.customerid = '" + ls_customerid +"' "
End If

//개통상태인것만 
If ls_where <> "" Then ls_where += " AND "
ls_where += "a.status= '" + ls_status +"' "

//선불제 type인 svccod만 select
If ls_where <> "" Then ls_where += " AND "
ls_where += "a.svccod in (select svccod from svcmst where svctype =  '" + is_svctype_pre + "')"


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row > 0 Then
	ll_priceplan_cnt = dw_detail.Object.count[1]
	
	If ll_priceplan_cnt > 1 then
		f_msg_usr_err(2100,Title, "중복된 가격정책입니다.")
		p_save.TriggerEvent("ue_disable")
		Return
	ElseIf ll_priceplan_cnt = 1 then
		dw_cond.Object.priceplan[1] = dw_detail.Object.contractmst_priceplan[1]
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

event open;call super::open;String ls_ref_desc, ls_tmp, ls_data[]
Integer li_return

ls_tmp = fs_get_control('B1', 'B600', ls_ref_desc)
If ls_tmp = "" Then Return
li_return = fi_cut_string(ls_tmp, ";", ls_data[])
If li_return <= 0 Then Return

is_refill_type = ls_data[4]
dw_cond.object.refilldt[1] = Date(fdt_get_dbserver_now())

is_svctype_pre = fs_get_control('B0', 'P101', ls_ref_desc)

end event

event ue_save();Integer li_return

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
		f_msg_info(3010, This.Title, "선불제충전")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "선불제충전완료")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
			dw_cond.Enabled = True
			dw_cond.Reset()
			dw_cond.InsertRow(0)
			dw_cond.SetFocus()
		End If
End Choose
end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_where
Long ll_row,i , ll_count
String ls_refill_type, ls_remark, ls_pid, ls_contno , ls_partner_prefix, ls_refilldt
Dec{2} lc_refill_amt, lc_sale_amt
Integer li_return ,li_rc
ll_count = 0 

ls_partner_prefix = dw_cond.Object.partner_prefix[1]
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""

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

For i = 1 To dw_detail.RowCount()
	If dw_detail.IsSelected(i) Then ll_count ++
Next

If ll_count = 0 Then
	MessageBox(Title, "충전할 건을 선택하십시오.")
	dw_cond.SetFocus()
	Return -2
End If

li_return = f_msg_ques_yesno(9000, Title, String(ll_count) +" 건을 충전하시겠습니까?")
If li_return = 2 Then Return -2 

//***** 처리부분 *****
b1u_dbmgr5 lu_dbmgr

lu_dbmgr = Create b1u_dbmgr5

lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "p1w_reg_refill%save"

lu_dbmgr.ic_data[1] = lc_refill_amt			//충전금액
lu_dbmgr.ic_data[2] = lc_sale_amt	   		//판매금액  
lu_dbmgr.is_data[1] = ls_partner_prefix		//대리점
lu_dbmgr.is_data[2] = ls_refill_type		//충전유형
lu_dbmgr.is_data[3] = ls_refilldt			//충전일자
lu_dbmgr.is_data[4] = ls_remark				//비고

lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.uf_prc_db()

li_rc	= lu_dbmgr.ii_rc

Destroy lu_dbmgr

Return li_rc
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b1w_reg_refill
integer y = 40
integer width = 2181
integer height = 936
string dataobject = "b1dw_cnd_reg_refill"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_partner_prefix
Long ll_row, li_return
Dec ldc_rate
Dec{2} lc_sale_amt, lc_amt, ldc_refill_amt
String ls_partner, ls_priceplan, ls_refilldt, ls_refill_type

ls_priceplan = This.object.priceplan[1]
ls_refill_type = This.object.refill_type[1]
If isnull(ls_priceplan) Then ls_priceplan = ""
If isnull(ls_refill_type) Then ls_refill_type = ""

//판매 금액을 가져오기 위한 것
Choose Case dwo.name
	Case "customerid" 
   		wfi_get_customerid(data)		
		
	Case "partner_prefix" 
		If is_refill_type <> ls_refill_type Then
			//판매금액 가져오기
			ldc_refill_amt = This.object.refill_amt[1]
			ls_refilldt = String(This.object.refilldt[1], 'yyyymmdd')
			If isnull(ls_refilldt) Then ls_refilldt = ""

			If ls_priceplan <> "" and ls_refilldt <> "" and ldc_refill_amt <> 0 Then
				ldc_rate = 0 
				li_return = wf_refill_rate(data, ls_priceplan, ls_refilldt, ldc_refill_amt, ldc_rate) 
		
				If li_return = -1 Then
					f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
					Return 1
				ElseIf li_return = 1 Then
					This.object.sale_amt[1] = ldc_refill_amt		
				ElseIf li_return = 0 Then
					This.object.sale_amt[1] = ldc_refill_amt * ldc_rate/100
				End If
			End IF
		End If	
		
	Case "refill_amt" 
		If is_refill_type <> ls_refill_type Then
			ls_partner = This.object.partner_prefix[1]
			//판매금액 가져오기
			ldc_refill_amt = This.object.refill_amt[1]
			ls_refilldt = String(This.object.refilldt[1], 'yyyymmdd')
			If isnull(ls_refilldt) Then ls_refilldt = ""
			If isnull(ls_partner) Then ls_partner = ""
			
			If ls_priceplan <> "" and ls_refilldt <> "" and ldc_refill_amt <> 0 and ls_partner <> "" Then
				ldc_rate = 0 
				li_return = wf_refill_rate(ls_partner, ls_priceplan, ls_refilldt,  Dec(data), ldc_rate) 
		
				If li_return = -1 Then
					f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
					Return 1
				ElseIf li_return = 1 Then
					This.object.sale_amt[1] = ldc_refill_amt		
				ElseIf li_return = 0 Then
					This.object.sale_amt[1] = ldc_refill_amt * ldc_rate/100
				End If
			End IF
	
		End If
		
	Case "refilldt" 
		If is_refill_type <> ls_refill_type Then
			ls_partner = This.object.partner_prefix[1]
			ldc_refill_amt = This.object.refill_amt[1]
			
			ls_refilldt = MidA(data,1,4) + MidA(data,6,2) + MidA(data,9,2)
			
			If ls_priceplan <> "" and ls_refilldt <> "" and ldc_refill_amt <> 0 and ls_partner <> "" Then
				ldc_rate = 0 
				li_return = wf_refill_rate(ls_partner, ls_priceplan, ls_refilldt, ldc_refill_amt, ldc_rate) 
		
				If li_return = -1 Then
					f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
					Return 1
				ElseIf li_return = 1 Then
					This.object.sale_amt[1] = ldc_refill_amt		
				ElseIf li_return = 0 Then
					This.object.sale_amt[1] = ldc_refill_amt * ldc_rate/100
				End If
			End IF
		End If
End Choose
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

Return 0
end event

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_reg_m_sql`p_ok within b1w_reg_refill
integer x = 2386
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b1w_reg_refill
integer x = 2386
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b1w_reg_refill
integer width = 2240
integer height = 988
end type

type p_save from w_a_reg_m_sql`p_save within b1w_reg_refill
integer x = 2386
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b1w_reg_refill
integer y = 1012
integer width = 2935
integer height = 1332
string dataobject = "b1dw_reg_refill"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.contractmst_contractseq_t
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

event dw_detail::retrieveend;call super::retrieveend;Long ll_row
String ls_filter

If rowcount = 0 Then
 	return 0
End If

//Format 지정
String ls_type, ls_priceplan
Integer li_cnt

ls_priceplan = Trim(dW_detail.object.contractmst_priceplan[1])

//Format 지정
Select decpoint
Into 	:ls_type
From priceplanmst
where priceplan = :ls_priceplan;

If ls_type = "0" Then
	dw_cond.object.refill_amt.Format = "#,##0"
	dw_cond.object.sale_amt.Format = "#,##0"
	dw_detail.object.contractmst_balance.Format = "#,##0"
	dw_detail.object.contractmst_last_refill_amt.Format = "#,##0"
ElseIf ls_type = "1" Then
	dw_cond.object.refill_amt.Format = "#,##0.0"	
	dw_cond.object.sale_amt.Format = "#,##0.0"
	dw_detail.object.contractmst_balance.Format = "#,##0.0"
	dw_detail.object.contractmst_last_refill_amt.Format = "#,##0.0"
ElseIf ls_type = "2" Then
	dw_cond.object.refill_amt.Format = "#,##0.00"	
	dw_cond.object.sale_amt.Format = "#,##0.00"
	dw_detail.object.contractmst_balance.Format = "#,##0.00"
	dw_detail.object.contractmst_last_refill_amt.Format = "#,##0.00"
ElseIf ls_type = "3" Then
	dw_cond.object.refill_amt.Format = "#,##0.000"	
	dw_cond.object.sale_amt.Format = "#,##0.000"
	dw_detail.object.contractmst_balance.Format = "#,##0.000"
	dw_detail.object.contractmst_last_refill_amt.Format = "#,##0.000"
ElseIf ls_type = "4" Then
	dw_cond.object.refill_amt.Format = "#,##0.0000"	
	dw_cond.object.sale_amt.Format = "#,##0.0000"
	dw_detail.object.contractmst_balance.Format = "#,##0.0000"
	dw_detail.object.contractmst_last_refill_amt.Format = "#,##0.0000"
End If
end event

