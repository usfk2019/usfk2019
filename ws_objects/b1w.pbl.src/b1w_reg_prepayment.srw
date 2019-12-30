$PBExportHeader$b1w_reg_prepayment.srw
$PBExportComments$[ohj] 기간제선납상품수납
forward
global type b1w_reg_prepayment from w_a_reg_m_m
end type
type p_new from u_p_new within b1w_reg_prepayment
end type
type bt_check from commandbutton within b1w_reg_prepayment
end type
end forward

global type b1w_reg_prepayment from w_a_reg_m_m
integer width = 3246
integer height = 1952
event ue_new ( )
p_new p_new
bt_check bt_check
end type
global b1w_reg_prepayment b1w_reg_prepayment

type variables
String is_priceplan		//Price Plan Code
String is_result[], is_cus_status, is_mode = 'U', is_day
Date   id_saledate_nx, id_saledate_ed
Long   il_contractseq 

DataWindowChild idc_itemcod
end variables

forward prototypes
public function integer wfi_check_value (string as_parttype, string as_partcod)
public function integer wfi_get_itemcod (ref string as_itemcod[])
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_check_value (string as_parttype, string as_partcod);//해당 parttype, partcod 를 가지고 기존에 data가 있는지 체크한다.
Long ll_cnt

SELECT COUNT(PARTCOD)
  INTO :ll_cnt
  FROM PARTICULAR_ZONCST
 WHERE PARTTYPE = :as_parttype
   AND PARTCOD  = :as_partcod ;
	
If SQLCA.SQLCode <> 0 Then
	f_msg_usr_err(2100, Title, "Select()")
	Return -1
End If
	
If ll_cnt > 0 Then
	Return -2
End If
	
Return 0
end function

public function integer wfi_get_itemcod (ref string as_itemcod[]);String ls_itemcod
Long ll_rows

ll_rows = 0
DECLARE itemcod CURSOR FOR
				Select det.itemcod
			   From priceplandet det, itemmst item
				Where det.itemcod = item.itemcod
				and item.pricetable <> (select ref_content from sysctl1t where module = 'B0' and Ref_no = 'P100');
   
	Open itemcod;
		 	Do While(True)	
			Fetch itemcod
			into :ls_itemcod;
			
			//error
			 If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(title, " Select Error(PRICEPLANDET)")
				Close itemcod;
				Return -1
			 
			 ElseIf SQLCA.SQLCODE = 100 Then
				exit;
			 End If
			 
			 ll_rows += 1
			 as_itemcod[ll_rows] = ls_itemcod
	
	Loop
CLOSE itemcod;

Return 0
end function

public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE zoncod like :as_zoncod;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(Title, ":CURSOR cur_get_arezoncod")
	Return -1
End If

OPEN cur_get_arezoncod;
Do While(True)
	FETCH cur_get_arezoncod
	INTO :ls_zoncod;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(Title, ":cur_get_arezoncod")
		CLOSE cur_get_arezoncod;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_rows += 1
	as_arezoncod[ll_rows] = ls_zoncod
	
Loop
CLOSE cur_get_arezoncod;

Return ll_rows
end function

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2004.12.10
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm
Select customernm,
	   status
Into :ls_customernm,
	 :is_cus_status
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

on b1w_reg_prepayment.create
int iCurrent
call super::create
this.p_new=create p_new
this.bt_check=create bt_check
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
this.Control[iCurrent+2]=this.bt_check
end on

on b1w_reg_prepayment.destroy
call super::destroy
destroy(this.p_new)
destroy(this.bt_check)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_prepayment
	Desc.	: 	개별 요율등록
	Ver.	:	1.0
	Date	: 	2004.12.09
	Programer : OHJ
--------------------------------------------------------------------------*/
p_new.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")

String ls_ref_desc, ls_temp

//선불, 선불카드...
ls_ref_desc = ""
ls_temp = fs_get_control("B1","P211", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_result[])
End if

//납기일자
is_day = fs_get_control("B1", "P601", ls_ref_desc)	
end event

event ue_ok();call super::ue_ok;String ls_customerid, ls_validkey, ls_where, ls_ref_desc, ls_temp, ls_result[], ls_where_1
Long   ll_row, li_i

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_validkey    = Trim(dw_cond.object.validkey[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_validkey)   Then ls_validkey   = ""

ls_where = ""
If ls_customerid <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.CUSTOMERID = '" + ls_customerid + "' "
End If

If ls_validkey <> '' Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.CONTRACTSEQ IN (SELECT CONTRACTSEQ                     " + &
	           "                      FROM VALIDINFO                       "  + &
				  "  					      WHERE VALIDKEY = '" + ls_validkey + "')" 
End If

ls_where_1 = ""
For li_i = 1 To UpperBound(is_result[])
	If ls_where_1 <> "" Then ls_where_1 += " Or "
	ls_where_1 += " D.SVCTYPE = '" + is_result[li_i] + "'"
Next

If ls_where <> "" Then
	If ls_where_1 <> "" Then ls_where = ls_where + " And ( " + ls_where_1 + " ) "  
Else
	ls_where = "(" + ls_where_1 + ")"
End if

dw_detail.ReSet()
dw_master.SetRedraw(False)

dw_master.is_where = ls_where

//Retrieve
ll_row = dw_master.Retrieve()

dw_master.SetRedraw(True)

dw_master.SetFocus()
dw_master.SelectRow(0, False)
dw_master.ScrollToRow(1)
dw_master.SelectRow(1, True)
	
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")

	p_ok.TriggerEvent("ue_enable")
	dw_cond.Enabled = True
	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
	
Else
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
//	dw_cond.SetItem(1, 'gubun', 'N')
  dw_cond.Enabled = False
	
End If

is_mode = 'U'

Return
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_customerid, ls_itemcod, ls_priceplan, ls_itemcod1, ls_additem, ls_code, &
       ls_method, ls_bilfromdt
Long   ll_row, ll_cu_row, ll_contractseq, ll_orderno, i, ll_seq, ll_addunit
Double ld_unitcharge
Date   ld_saledate, ld_saledate_nx, ld_salefromdt, ld_saletodt, ld_bil_fromdt, &
       ldt_date_next_1, ldt_date_next, ld_inputclosedt

ll_row    = dw_master.GetSelectedRow(0) 
ll_cu_row = al_insert_row - 1

ls_customerid  = Trim(dw_master.object.customerid[ll_row])
ll_contractseq = dw_master.object.contractseq[ll_row]
ls_priceplan   = Trim(dw_master.object.priceplan[ll_row])

ll_orderno     = dw_detail.object.orderno[ll_cu_row]
ls_itemcod     = Trim(dw_detail.object.itemcod[ll_cu_row])
ls_itemcod1    = Trim(dw_detail.object.itemcod[1])
ld_salefromdt  = date(dw_detail.object.salefromdt[ll_cu_row])
ld_saletodt    = date(dw_detail.object.saletodt[ll_cu_row])

ld_saledate    = date(dw_detail.object.salemonth[ll_cu_row])
ld_saledate_nx = fd_next_month(ld_saledate, 1)
id_saledate_ed = fd_next_month(ld_saledate_nx, 1)
il_contractseq = ll_contractseq
//SELECT UNITCHARGE
//	  , ADDUNIT
//	  , METHOD
//	  , NVL(ADDITEM, '') ADDITEM
//	  , VALIDITY_TERM
//  INTO :ldc_unitcharge
//	  , :ll_addunit
//	  , :ls_method
//	  , :ls_additem
//	  , :ll_validity_term
//판매금액, additem ...
SELECT UNITCHARGE
     , NVL(ADDITEM, '') ADDITEM
	  , METHOD
	  , ADDUNIT
  INTO :ld_unitcharge
     , :ls_additem
	  , :ls_method
	  , :ll_addunit
  FROM PRICEPLAN_RATE2
 WHERE PRICEPLAN = :ls_priceplan
   AND ITEMCOD   = :ls_itemcod1   ;
	//AND :ld_saledate_nx BETWEEN FROMDT AND NVL(TODT, :ld_saledate_nx) ;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "Select Error(PRICEPLAN_RATE2)")
	Return 0
End If

If fs_snvl(ls_additem, '') = '' Then
	ls_code = ls_itemcod1  // 첫쨰 itemcode
Else 
	ls_code = ls_additem
End If

ld_bil_fromdt = fd_date_next(ld_saletodt, 1)  //salefromdt  <= 전row의 TODT +1 

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

//seq
SELECT SEQ_PREPAYMENT.NEXTVAL
  INTO :ll_seq
  FROM dual;
  
//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]

//Price Plan Code Setting
dw_detail.object.seq[al_insert_row]          = ll_seq
dw_detail.object.customerid[al_insert_row]   = ls_customerid
dw_detail.object.contractseq[al_insert_row]  = ll_contractseq
dw_detail.object.orderno[al_insert_row]      = ll_orderno
dw_detail.object.itemcod[al_insert_row]      = ls_code
dw_detail.object.salefromdt[al_insert_row]   = ld_bil_fromdt
dw_detail.object.saletodt[al_insert_row]     = ldt_date_next

dw_detail.object.inputclosedt[al_insert_row] = ld_inputclosedt

dw_detail.object.salemonth[al_insert_row]    = ld_bil_fromdt
dw_detail.object.sale_amt[al_insert_row]     = ld_unitcharge
dw_detail.object.payamt[al_insert_row]       = ld_unitcharge
dw_detail.object.gubun[al_insert_row]        = '1'

//For i = 1 To dw_detail.RowCount()
//	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//Next

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("saletodt")

Return 0 

////판매금액...
//SELECT UNITCHARGE
//     , NVL(ADDITEM, '') ADDITEM
//  INTO :ld_unitcharge
//     , :ls_additem
//  FROM PRICEPLAN_RATE2
// WHERE PRICEPLAN = :ls_priceplan
//   AND ITEMCOD   = :ls_itemcod1
//	AND :ld_saledate_nx BETWEEN FROMDT AND NVL(TODT, :ld_saledate_nx) ;
//	
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title, "Select Error(PRICEPLAN_RATE2)")
//	Return 0
//End If
//
//seq
//SELECT SEQ_PREPAYMENT.NEXTVAL
//  INTO :ll_seq
//  FROM dual;
//  
//Log
//dw_detail.object.crt_user[al_insert_row] = gs_user_id
//dw_detail.object.crtdt[al_insert_row]    = fdt_get_dbserver_now()
//dw_detail.object.pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
//
//Price Plan Code Setting
//dw_detail.object.seq[al_insert_row]          = ll_seq
//dw_detail.object.customerid[al_insert_row]   = ls_customerid
//dw_detail.object.contractseq[al_insert_row]  = ll_contractseq
//dw_detail.object.orderno[al_insert_row]      = ll_orderno
//dw_detail.object.itemcod[al_insert_row]      = ls_itemcod
//dw_detail.object.inputclosedt[al_insert_row] = fdt_get_dbserver_now()
//dw_detail.object.salemonth[al_insert_row]    = ld_saledate_nx
//dw_detail.object.sale_amt[al_insert_row]     = ld_unitcharge
//dw_detail.object.payamt[al_insert_row]      = ld_unitcharge
//dw_detail.object.gubun[al_insert_row]        = '1'
//
//Insert 시 해당 row 첫번째 컬럼에 포커스
//dw_detail.SetRow(al_insert_row)
//dw_detail.ScrollToRow(al_insert_row)
//dw_detail.SetColumn("paytype")
//
//For i = 1 To dw_detail.RowCount()
//	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//Next
//
//Return 0 
end event

event type integer ue_extra_save();//Save Check
//Save
String ls_paytype, ls_paydt, ls_incldt, ls_saletodt, ls_direct_paytype, ls_priceplan, &
       ls_itemcod1
Long   ll_row, ll_rows, ll_rows1, ll_rows2, ll_saleamt, ll_payamt, ll_contractseq, &
       ll_sale_amt_sum = 0, ll_validity_term
Date   ld_enddt_contract, ld_saletodt
Double ld_unitcharge, ld_term

ll_rows = dw_detail.RowCount()

ll_contractseq = dw_master.object.contractseq[dw_master.getrow()]
ls_priceplan   = dw_master.object.priceplan[dw_master.getrow()]
ls_itemcod1    = dw_detail.object.itemcod[1]

//만기일 가져오기
SELECT ENDDT
  INTO :ld_enddt_contract
  FROM CONTRACTMST
 WHERE CONTRACTSEQ = :ll_contractseq                 ;

If SQLCA.SQLCode <> 0 Then
	f_msg_sql_err(Title, " SELECT CONTRACTMST Table (ENDDT)")
	Return 0
End If

SELECT UNITCHARGE
	  , VALIDITY_TERM
  INTO :ld_unitcharge
	  , :ll_validity_term
  FROM PRICEPLAN_RATE2
 WHERE PRICEPLAN = :ls_priceplan
   AND ITEMCOD   = :ls_itemcod1   ;
	
//SELECT MAX(SALETODT)
//  INTO :ld_max_saletodt
//  FROM PREPAYMENT
// WHERE CONTRACTSEQ = :ll_contractseq                 ;
// 
//If SQLCA.SQLCode <> 0 Then
//	f_msg_sql_err(Title, " SELECT PREPAYMENT Table (MAX SALETODT)")
//	Return 0
//End If	


//insert후 save
If is_mode = 'I' Then
		
	For ll_row = 1 To ll_rows
		ls_paytype  = Trim(dw_detail.Object.paytype[ll_row])
		ls_paydt    = string(dw_detail.Object.paydt[ll_row], 'yyyymmdd')
		ls_incldt   = string(dw_detail.Object.inputclosedt[ll_row], 'yyyymmdd')
		
		ls_saletodt = fs_snvl(string(dw_detail.Object.saletodt[ll_row]  , 'yyyymmdd'), '')
		ll_saleamt  = dw_detail.Object.sale_amt[ll_row]

		If IsNull(ls_paytype) Then ls_paytype = ""
		If IsNull(ls_paydt)   Then ls_paydt   = ""
		If IsNull(ls_incldt)  Then ls_incldt  = ""
		If IsNull(ll_saleamt) Then ll_saleamt = 0
		
		//필수 항목 check 
		If ls_paytype = "" Then
			If ls_paydt <> "" Then
				f_msg_usr_err(200, Title, "납부방법")
				dw_detail.SetColumn("paytype")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				Return -2
			End If
		ElseIf ls_paytype <> "" Then
			If ls_paydt = "" Then
				f_msg_usr_err(200, Title, "납부일자")
				dw_detail.SetColumn("paydt")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				Return -2
			End If		
		End If
		
		If ls_incldt = "" Then
			f_msg_usr_err(200, Title, "납기일자")
			dw_detail.SetColumn("inputclosedt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If		
		
		If ls_saletodt = "" Then
			f_msg_usr_err(200, Title, "판매종료일")
			dw_detail.SetColumn("saletodt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If		
		
		If ll_saleamt = 0 Then
			f_msg_usr_err(200, Title, "판매금액")
			dw_detail.SetColumn("sale_amt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If	
		

	Next
//삭제나 수정후 save
Else 
	For ll_row = 1 To ll_rows
		ls_paytype  = Trim(dw_detail.Object.paytype[ll_row])
		ls_paydt    = string(dw_detail.Object.paydt[ll_row], 'yyyymmdd')
		ls_incldt   = string(dw_detail.Object.inputclosedt[ll_row], 'yyyymmdd')
		
		ls_saletodt = fs_snvl(string(dw_detail.Object.saletodt[ll_row]  , 'yyyymmdd'), '')
		ll_saleamt  = dw_detail.Object.sale_amt[ll_row]
		ll_payamt   = dw_detail.Object.payamt[ll_row]
		
		ls_direct_paytype = fs_snvl(dw_master.object.direct_paytype[dw_master.getrow()], '')
	
		If IsNull(ls_paytype) Then ls_paytype = ""
		If IsNull(ls_paydt)   Then ls_paydt   = ""
		If IsNull(ls_incldt)  Then ls_incldt  = ""
		If IsNull(ll_saleamt) Then ll_saleamt = 0
		If IsNull(ll_payamt)  Then ll_payamt  = 0
		
		//필수 항목 check 
		If ls_paytype = "" Then
			If ls_paydt <> "" Then
				f_msg_usr_err(200, Title, "납부방법")
				dw_detail.SetColumn("paytype")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				Return -2
			End If
		ElseIf ls_paytype <> "" Then
			If ls_paydt = "" Then
				f_msg_usr_err(200, Title, "납부일자")
				dw_detail.SetColumn("paydt")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				Return -2
			End If		
		End If
	
	//	If ls_paytype = "" Then
	//		f_msg_usr_err(200, Title, "Payment Method")
	//		dw_detail.SetColumn("paytype")
	//		dw_detail.SetRow(ll_row)
	//		dw_detail.ScrollToRow(ll_row)
	//		Return -2
	//	End If
	//
	//	If ls_paydt = "" Then
	//		f_msg_usr_err(200, Title, "Payment Date")
	//		dw_detail.SetColumn("paydt")
	//		dw_detail.SetRow(ll_row)
	//		dw_detail.ScrollToRow(ll_row)
	//		Return -2
	//	End If		
	
		If ls_incldt = "" Then
			f_msg_usr_err(200, Title, "납기일자")
			dw_detail.SetColumn("inputclosedt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If		
		
		If ls_saletodt = "" Then
			f_msg_usr_err(200, Title, "판매종료일")
			dw_detail.SetColumn("saletodt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If		
		
		If ll_saleamt = 0 Then
			f_msg_usr_err(200, Title, "판매금액")
			dw_detail.SetColumn("sale_amt")
			dw_detail.SetRow(ll_row)
			dw_detail.ScrollToRow(ll_row)
			Return -2
		End If	
		
		If ls_paydt <> "" And ls_paytype <> "" Then
			If ll_payamt = 0 Then
				f_msg_usr_err(200, Title, "납부금액")
				dw_detail.SetColumn("payamt")
				dw_detail.SetRow(ll_row)
				dw_detail.ScrollToRow(ll_row)
				Return -2
			End If		
		End If
	Next
End If

ls_direct_paytype = fs_snvl(dw_master.object.direct_paytype[dw_master.getrow()], '')
ld_saletodt       = date(dw_detail.Object.saletodt[dw_detail.rowcount()])

If ls_direct_paytype  <> '100' Then
	If ld_enddt_contract > ld_saletodt Then
		f_msg_usr_err(9000, Title, "판매기간To가 기간만료일보다 작습니다.")
		Return -2
		
	ElseIf ld_enddt_contract < ld_saletodt Then  //경고는 보내나 save처리
		f_msg_usr_err(9000, Title, "판매기간To가 기간만료일보다 크나 선납처리합니다.")
	End If
	
	For ll_rows1 = 1 To ll_rows
		ll_sale_amt_sum = ll_sale_amt_sum + dw_detail.object.sale_amt[ll_rows1]
	Next
	
	ld_term = ld_unitcharge * ll_validity_term 
	
	If ld_term <> ll_sale_amt_sum Then //경고는 보내나 save처리
		f_msg_usr_err(9000, Title, "판매총금액이 가격정책에 등록된 판매금액과 다르나 선납처리합니다.")
		
	End If
	
End If

For ll_rows1 = 1 To ll_rows

	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
	End If
	
Next

Return 0
end event

event resize;//2000-06-28 by kem
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_new.Y	   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_new.Y	   = newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
//	bt_check.x	    = newwidth - iu_cust_w_resize.ii_button_space   - 480 
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.customerid[1] = ""
dw_cond.object.validkey[1]    = ""

p_reset.TriggerEvent("ue_enable")
is_mode = 'U'
Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1
If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
//	If is_mode = 'I' Then
//		UPDATE CONTRACTMST
//		   SET BIL_TODT    = :id_saledate_ed
//		 WHERE CONTRACTSEQ = :il_contractseq   ;
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Update Error(CONTRACTMST)")
//			RollBack;
//			Return LI_ERROR
//		End If
//			
//	End If	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")

	dw_detail.ResetUpdate()
	dw_detail.ReSet()
	This.Trigger Event ue_ok()

End if

is_mode = 'U'
//ii_error_chk = 0
//p_new.TriggerEvent("ue_enable")

Return 0

end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long   ll_row, ll_row_de, ll_contractseq
String ls_ref_itemseq, ls_direct_paytype
Date   ld_enddt_contract, ld_max_saletodt

//Int li_return

//ii_error_chk = -1

dw_detail.accepttext()

ll_row    = dw_master.getrow()
ll_row_de = dw_detail.getrow()

ls_direct_paytype = fs_snvl(dw_master.object.direct_paytype[ll_row], '')
ll_contractseq    = dw_master.object.contractseq[ll_row]

//청구서발송방식이면 return
If ls_direct_paytype = '100' Then 
	f_msg_usr_err(9000, Title, "납부방식이 직접입금방식인 경우에만 입력 가능합니다. ")
	Return 0
ElseIf ls_direct_paytype = '' Then
	f_msg_usr_err(9000, Title, "납부방식이 존재하지 않습니다. 관리자에게 문의하세요!")
	Return 0
End If

//만기일 가져오기
SELECT ENDDT
  INTO :ld_enddt_contract
  FROM CONTRACTMST
 WHERE CONTRACTSEQ = :ll_contractseq                 ;

If SQLCA.SQLCode <> 0 Then
	f_msg_sql_err(Title, " SELECT CONTRACTMST Table (ENDDT)")
	Return 0
End If

//SELECT MAX(SALETODT)
//  INTO :ld_max_saletodt
//  FROM PREPAYMENT
// WHERE CONTRACTSEQ = :ll_contractseq                 ;
// 
//If SQLCA.SQLCode <> 0 Then
//	f_msg_sql_err(Title, " SELECT PREPAYMENT Table (MAX SALETODT)")
//	Return 0
//End If	
If dw_detail.rowcount() <> 0 Then
	ld_max_saletodt       = date(dw_detail.Object.saletodt[dw_detail.rowcount()])
	
	If ld_enddt_contract <= ld_max_saletodt Then
		f_msg_usr_err(9000, Title, "판매기간보다 기간만료일이 빠를 때 입력 가능합니다.")
		Return 0
	End If
	
End If
ll_row = dw_detail.InsertRow(dw_detail.Rowcount()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if
is_mode = 'I'

Return 0
//ii_error_chk = 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;Long	 ll_row, ll_ref_itemseq, ll_row_de
String ls_direct_paytype

dw_detail.accepttext()
is_mode = 'D'
ll_row    = dw_master.getrow()
ll_row_de = dw_detail.getrow()

If ll_row_de <> dw_detail.rowcount() Then 
	f_msg_usr_err(9000, Title, "최근 데이타만 삭제 가능합니다.")
	Return -1
End If

ll_ref_itemseq    = dw_detail.object.ref_itemseq[ll_row_de]
ls_direct_paytype = fs_snvl(dw_master.object.direct_paytype[ll_row], '')

If Isnull(ll_ref_itemseq) Then ll_ref_itemseq = 0

If ls_direct_paytype = '100' Then
	
	f_msg_usr_err(9000, Title, "납부방식이 청구서발송방식인 경우는 삭제하실 수 없습니다.")
	Return -1
	
ElseIf ls_direct_paytype = '' Then
	f_msg_usr_err(9000, Title, "납부방식이 존재하지 않습니다. 관리자에게 문의하세요")
	Return -1
	
End If

If ll_ref_itemseq <> 0 Then
	
	f_msg_usr_err(9000, Title, "청구된 납입정보는 삭제할 수 없습니다.")
	Return -1
	
End If

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_prepayment
integer x = 64
integer y = 96
integer width = 2171
integer height = 116
string dataobject = "b1dw_cnd_prepayment"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_filter, ls_itemcod, ls_codename
Long   li_rc
DataWindowChild ldc


Choose Case dwo.name
	Case "customerid"
		
		wfi_get_customerid(data)
End Choose
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
			 is_cus_status = dw_cond.iu_cust_help.is_data[3]
		End If
//		dw_cond.object.svccod.Protect = 0
End Choose
end event

event dw_cond::buttonclicked;call super::buttonclicked;//String   ls_direct_paytype, ls_st_enddt, ls_priceplan, ls_itemcod1, ls_oneoffcharge_yn, &
//         ls_additem, ls_method, ls_bilfromdt, ls_customerid, ls_enddt_contract, ls_max_saletodt
//Long     ll_row, ll_contractseq, ll_period, ll_validity_term, ll_addunit, ll_i, ll_row_2, &
//         ll_orderno, ll_count, ll_cnt = 0, ll_add = 0, ll_between
//Date     ldt_period_extension, ldt_enddt, ldt_date_next_1, ld_bil_fromdt, ldt_date_next, &
//		   ld_inputclosedt, ldt_max_saletodt, ld_enddt_contract, ldt_max_salefromdt
//Decimal  ldc_unitcharge, ldc_payamt
//
//dw_cond.Accepttext()
//ll_row   = dw_master.Getrow()
//ll_row_2 = dw_detail.Getrow()
//
//If ll_row   <= 0 Then Return
//If ll_row_2 <= 0 Then Return
//	 
//ll_contractseq    = dw_master.object.contractseq[ll_row]
//ls_customerid     = dw_master.object.customerid[ll_row]
//ls_priceplan      = dw_master.object.priceplan[ll_row]
//ls_oneoffcharge_yn= dw_master.object.oneoffcharge_yn[ll_row]
//ls_itemcod1       = dw_master.object.itemcod[ll_row]
//ls_direct_paytype = fs_snvl(dw_master.object.direct_paytype[ll_row], '')	
//
//ll_orderno        = dw_detail.object.orderno[ll_row_2]
//ldt_enddt         = Date(dw_master.object.enddt[ll_row])    //기간만료일
//ls_st_enddt       = String(ldt_enddt, 'YYYYMMDD')
//
//SELECT UNITCHARGE
//	  , ADDUNIT
//	  , METHOD
//	  , NVL(ADDITEM, '') ADDITEM
//	  , VALIDITY_TERM
//  INTO :ldc_unitcharge
//	  , :ll_addunit
//	  , :ls_method
//	  , :ls_additem
//	  , :ll_validity_term
//  FROM PRICEPLAN_RATE2
// WHERE PRICEPLAN = :ls_priceplan
//	AND ITEMCOD   = :ls_itemcod1    ;
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(title, " SELECT Error(PRICEPLAN_RATE2) RATE INFO")
//	Return 
//End If
//
//If dwo.name  = 'bt_period' Then
//	
//	ll_period   = This.object.period[1]
//	
//	If IsNull(ll_period) Then ll_period = 0
//	
//	If ll_period = 0 Then
//		f_msg_usr_err(200, Title, "Period  Extension")
//		This.SetColumn("period")
//		Return 
//	ElseIf ll_period < 0 Then
//		f_msg_usr_err(9000, Title, "기간 연장만 가능합니다.")
//		This.SetColumn("period")
//		Return 		
//	End If
//
//	If f_msg_ques_yesno2(9000, Title, "기간연장 하시겠습니까?", 1) = 2 Then
//		Return
//	End If
//	
//	If ls_oneoffcharge_yn = 'Y' Then
//		ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
//	Else
//		ldc_payamt = ldc_unitcharge
//	End If
//	
//	If ls_direct_paytype = '100' Then	//청구서발송방식
//		
//		ld_bil_fromdt = fd_date_next(ldt_enddt, 1)
//		
//		If ls_method = 'A' Then  //daily 정액
//		
//			ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
//			
//			SELECT :ldt_date_next_1 -1 
//			  INTO :ldt_date_next
//			  FROM DUAL                 ;									
//			
//		ElseIf ls_method = 'M' Then //월정액
//			ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
//			
//			SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
//			  INTO :ldt_date_next
//			  FROM DUAL;
//			  
//		End If	
//				
//		UPDATE CONTRACTMST
//			SET ENDDT          = :ldt_date_next
//		 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
//		
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(Title, " Update CONTRACTMST Table(ENDDT)")				
//			Return 
//		End If	
//	
//	ElseIf ls_direct_paytype = '200' Then  //직접입금방식
//		
//		For ll_i = 1 To ll_period 
//			
//				ld_bil_fromdt = fd_date_next(ldt_enddt, 1)  //salefromdt  -> TODT +1 
//				
//				If ls_method = 'A' Then  //daily 정액
//				
//					ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
//					
//					SELECT :ldt_date_next_1 -1 
//					  INTO :ldt_date_next
//					  FROM DUAL                 ;									
//					
//				ElseIf ls_method = 'M' Then //월정액
//					ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
//					
//					SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
//					  INTO :ldt_date_next
//					  FROM DUAL;
//					  
//				End If	
//	
//				ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(is_day))			
//			
//				INSERT INTO PREPAYMENT 
//							 ( seq, customerid, orderno, contractseq,
//								itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt,
//								crt_user, crtdt, pgm_id)
//					VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
//								:ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
//								:ld_inputclosedt, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]);
//									 
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, " INSERT Error(PREPAYMENT)")
//				RollBack;
//				Return 
//			End If
//			
//		Next		
//		
//		UPDATE CONTRACTMST
//			SET ENDDT          = :ldt_date_next
//		 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
//		
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(Title, " Update CONTRACTMST Table(ENDDT)")				
//			Return 
//		End If
//		
//	ElseIF ls_direct_paytype = '' Then
//		f_msg_usr_err(9000, Title, "납부방식이 존재하지 않습니다. 기간연장 할 수 없습니다.")
//		Return 
//	End If
//	
//ElseIf dwo.name  = 'bt_payment' Then
//
//	If f_msg_ques_yesno2(9000, Title, "납부방식을 변경하시겠습니까?", 1) = 2 Then
//		Return
//	End If
//	
//	ls_direct_paytype = fs_snvl(This.object.direct_paytype[1], '')
//	If ls_direct_paytype = '' Then 
//		f_msg_usr_err(200, Title, "Payment Process")
//		This.SetColumn("direct_paytype")
//		Return 
//	End If
//	
//	If dw_master.object.direct_paytype[ll_row]  = ls_direct_paytype Then
//		f_msg_usr_err(9000, Title, "납부방식이 동일합니다. 다시 확인하세요.")
//		This.SetColumn("direct_paytype")
//		Return 		
//	End If
//	
//	UPDATE CONTRACTMST
//	   SET DIRECT_PAYTYPE = :ls_direct_paytype
//	 WHERE CONTRACTSEQ    = :ll_contractseq                 ;
//	
//	If SQLCA.SQLCode <> 0 Then
//		RollBack;	
//		f_msg_sql_err(Title, " Update CONTRACTMST Table(DIRECT_PAYTYPE)")				
//		Return 
//	End If
//	
//	//직접 방식 -> 청구서발송방식 
//	If ls_direct_paytype = '100' Then
//		DELETE FROM PREPAYMENT 
//		      WHERE CONTRACTSEQ = :ll_contractseq
//				  AND PAYTYPE IS NULL
//				  AND PAYDT	  IS NULL  ;
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(Title, " DELETE PREPAYMENT Table")				
//			Return 
//		End If				  
//
//	//청구서발송방식 -> 직접 방식
//	ElseIf ls_direct_paytype = '200' Then
//		
//		SELECT MAX(SALETODT)
//		     , MAX(SALEFROMDT)
//		     , COUNT(*) 
//		  INTO :ldt_max_saletodt
//		     , :ldt_max_salefromdt
//		     , :ll_count
//		  FROM PREPAYMENT
//		 WHERE CONTRACTSEQ = :ll_contractseq                 ;
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(Title, " SELECT PREPAYMENT Table (MAX SALETODT)")
//			Return 
//		End If	
//		
//		//최초 가격정책당시 지정된 횟수를 일수로 표시했을떄 만기일보다 작다면 만기일에 맞게 
//		//prepayment를 늘리기 위해... 만기일자 가져온다
//		SELECT ENDDT
//		  INTO :ld_enddt_contract
//		  FROM CONTRACTMST
//		 WHERE CONTRACTSEQ = :ll_contractseq                 ;
//		
//		If SQLCA.SQLCode <> 0 Then
//			RollBack;	
//			f_msg_sql_err(Title, " SELECT CONTRACTMST Table (ENDDT)")
//			Return 
//		End If
//		
//		ls_enddt_contract = string(ld_enddt_contract, 'yyyymmdd')
//		ls_max_saletodt   = string(ldt_max_saletodt, 'yyyymmdd')
//		
//		If ls_method = 'A' Then  //daily 정액
//			
//		  SELECT to_number(to_date(:ls_enddt_contract,'yyyymmdd') - to_date(:ls_max_saletodt,'yyyymmdd')) / :ll_addunit 
//		  	 INTO :ll_between
//		  	 FROM DUAL ;						
//		
//		ElseIf ls_method = 'M' Then //월정액
//			
//		  SELECT MONTHS_BETWEEN(to_date(:ls_enddt_contract,'yyyymmdd'), to_date(:ls_max_saletodt,'yyyymmdd'))
//		  	 INTO :ll_between
//		  	 FROM DUAL ;
//			
//		End If
//		
//	   ll_cnt = ll_between
//		
//		If ll_cnt <= 0 Then Return
//		
//		If ls_oneoffcharge_yn = 'Y' Then
//			ldc_payamt = Round(ldc_unitcharge / ll_validity_term, 0)
//		Else
//			ldc_payamt = ldc_unitcharge
//		End If		
//		
//		ld_bil_fromdt = fd_date_next(ldt_max_saletodt, 1)
//
//		For ll_i = 1 To ll_cnt
//			If ll_i <> 1 Then
//				ld_bil_fromdt = fd_date_next(ldt_date_next, 1)  //salefromdt  -> TODT +1 
//			End If
//			
//			If ls_method = 'A' Then  //daily 정액
//			
//				ldt_date_next_1 = fd_date_next(ld_bil_fromdt, ll_addunit)
//				
//				SELECT :ldt_date_next_1 -1 
//				  INTO :ldt_date_next
//				  FROM DUAL                 ;									
//				
//			ElseIf ls_method = 'M' Then //월정액
//				ls_bilfromdt  = string(ld_bil_fromdt, 'YYYYMMDD') 
//				
//				SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_addunit) -1
//				  INTO :ldt_date_next
//				  FROM DUAL;
//				  
//			End If	
//
//			ld_inputclosedt = fd_date_next(ld_bil_fromdt, long(is_day))			
//		
//			INSERT INTO PREPAYMENT 
//						 ( seq, customerid, orderno, contractseq,
//							itemcod, salemonth, salefromdt, saletodt, sale_amt, inputclosedt,
//							crt_user, crtdt, pgm_id)
//				VALUES ( seq_prepayment.nextval, :ls_customerid, :ll_orderno, :ll_contractseq,
//							:ls_itemcod1, :ld_bil_fromdt, :ld_bil_fromdt, :ldt_date_next, :ldc_payamt,
//							:ld_inputclosedt, :gs_user_id, sysdate, :gs_pgm_id[gi_open_win_no]);
//								 
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, " INSERT Error(PREPAYMENT)")
//				RollBack;
//				Return 
//			End If
//			
//		Next		
//		
//		
//	End If
//	
//End If
//commit;
//f_msg_info(3000,This.Title,"Save")
//Trigger Event ue_ok()
//
//
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_prepayment
integer x = 2373
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_prepayment
integer x = 2679
integer y = 48
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_prepayment
integer x = 37
integer y = 32
integer width = 2217
integer height = 200
integer taborder = 0
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_prepayment
integer y = 276
integer width = 3113
integer height = 564
integer taborder = 30
string dataobject = "b1dw_cnd_reg_prepayment"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.customerid_t
uf_init( ldwo_sort, "A", RGB(0,0,128) )

end event

event dw_master::rowfocuschanged;call super::rowfocuschanged;
If currentrow = 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	
	String ls_oneoffcharge_yn, ls_status, ls_direct_paytype
	
	ls_oneoffcharge_yn = dw_master.object.oneoffcharge_yn[currentrow]	
	ls_status          = dw_master.object.status[currentrow]	
	ls_direct_paytype  = dw_master.object.direct_paytype[currentrow]
	
	If IsNull(ls_oneoffcharge_yn) Then ls_oneoffcharge_yn = ""
	If IsNull(ls_status)          Then ls_status          = ""
	
//	If ls_oneoffcharge_yn = 'Y' And ls_status = '20' Then
//
//		p_delete.TriggerEvent('ue_disable') 
//		p_insert.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")		
//	Else
//		p_insert.TriggerEvent("ue_disable")	
//		p_delete.TriggerEvent('ue_disable')
//		p_save.TriggerEvent("ue_enable")			
//	End If
	
//	If ls_direct_paytype = '200' Then
//		dw_cond.object.st_unit.text = 'Day(s)'
//	ElseIf ls_direct_paytype = '100' Then
//		dw_cond.object.st_unit.text = 'Month(s)'
//	Else
//		dw_cond.object.st_unit.text = 'Month(s)'
//	End If
	
End If
end event

event dw_master::retrieveend;
If rowcount > 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	//dw_cond.Enabled = True
	p_ok.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")

	dw_detail.SetFocus()
	
	String ls_oneoffcharge_yn, ls_status
	
	ls_oneoffcharge_yn = dw_master.object.oneoffcharge_yn[1]	
	ls_status          = dw_master.object.status[1]	
	
	If IsNull(ls_oneoffcharge_yn) Then ls_oneoffcharge_yn = ""
	If IsNull(ls_status)          Then ls_status          = ""
	
//	If ls_oneoffcharge_yn = 'Y' And ls_status = '20' Then
//
//		p_delete.TriggerEvent('ue_enable') 
//		p_insert.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")		
//	Else
//		p_insert.TriggerEvent("ue_disable")	
//		p_delete.TriggerEvent('ue_disable')
//		p_save.TriggerEvent("ue_enable")			
//	End If	
End If
end event

event dw_master::doubleclicked;//If row = 0 Then Return 0
//
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = "Periodic prepaid product payment"
//iu_cust_msg.idt_data[1] = This.Object.enddt[row]
//iu_cust_msg.il_data[1]  = This.Object.contractseq[row]
//iu_cust_msg.idw_data[1] = dw_master
//iu_cust_msg.idw_data[2] = dw_detail
//
//OpenWithParm(b1w_reg_prepayment_popup, iu_cust_msg)
//
//
//Trigger Event ue_ok()
//
////iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
////iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row]) //validkey
////iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
////
//////			ohj 2005.02.21 인증방법 추가로 인한 로직 추가로 popup변경
//////			OpenWithParm(b1w_reg_validinfo_popup_update_cl, iu_cust_msg)
////	OpenWithParm(b1w_reg_validinfo_popup_update_cl_g, iu_cust_msg)
end event

event dw_master::clicked;call super::clicked;If row > 0 Then
	String ls_oneoffcharge_yn, ls_status
	
	ls_oneoffcharge_yn = dw_master.object.oneoffcharge_yn[row]	
	ls_status          = dw_master.object.status[row]	
	
	If IsNull(ls_oneoffcharge_yn) Then ls_oneoffcharge_yn = ""
	If IsNull(ls_status)          Then ls_status          = ""
	
//	If ls_oneoffcharge_yn = 'Y' And ls_status = '20' Then
//
//		p_delete.TriggerEvent('ue_disable') 
//		p_insert.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")		
//	Else
//		p_insert.TriggerEvent("ue_disable")	
//		p_delete.TriggerEvent('ue_disable')
//		p_save.TriggerEvent("ue_enable")
//	End If
	
End If
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_prepayment
integer x = 37
integer y = 896
integer width = 3113
integer height = 784
integer taborder = 50
string dataobject = "b1dw_reg_prepayment"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_contractseq, ls_itemcod, ls_filter, ls_method, ls_target_type
String ls_type
Long ll_row, i
Integer li_cnt
Dec{0} lc_data
DataWindowChild ldc

dw_master.AcceptText()

If dw_master.RowCount() > 0 Then
	ls_contractseq = string(dw_master.object.contractseq[al_select_row])
	
	If IsNull(ls_contractseq) Then ls_contractseq = ""
	
	If  ls_contractseq = "" Then Return -2
	
	ls_where = ""
	If ls_where <> "" Then ls_where += " And "
	ls_where += " contractseq = '" + ls_contractseq + "' "

	//dw_detail 조회
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	dw_detail.SetRedraw(False)
	
	If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
	End If
	
//	For i = 1 To dw_detail.RowCount()
//		dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//	Next
   
	dw_detail.SetRedraw(true)

End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "sale_amt"
		dw_detail.SetItem(row, 'payamt', long(data))
	
End Choose

Return 0

//String ls_opendt, ls_munitsec
//Long ll_range1, ll_range2, ll_range3, ll_range4, ll_range5, ll_mod
//
//If (dw_detail.GetItemStatus(row, 0, Primary!) = New!) Or (This.GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//	ls_munitsec = "0"
//Else
//	ls_munitsec = String(This.object.munitsec[row])
//	If IsNull(ls_munitsec) Then ls_munitsec = ""
//End If
//
//Choose Case dwo.name
//	// 대역이 ALL 이면 착신지번호(특번) 필수입력
//	// 대역이 ALL 이 아니면 착신지번호는 ALL로 셋팅
//	Case "zoncod"
//		If data = 'ALL'  Then 
//			This.Object.areanum[row] = ""
//			This.Object.areanum.Protect = 0 
//		Else
//			This.Object.areanum[row] = 'ALL'
//			This.Object.areanum.Protect = 1
//		End If
//
//	Case "unitsec"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec[row] > 0)  Then
//				This.object.munitsec[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitfee"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee[row] > 0)  Then
//				This.object.munitfee[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange1[row] > 0)  Then
//				This.object.mtmrange1[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.object.munitsec1[row] > 0) Then
//				This.object.munitsec1[row] = Long(data)
//			End If
//		End If
//		
//		ll_range1 = This.object.tmrange1[row]
//		
//		If ll_range1 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range1, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetColumn("tmrange1")
//				Return -1
//			End If
//		End If
//	
//	Case "unitfee1"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.object.munitfee1[row] > 0)  Then
//				This.object.munitfee1[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange2[row] > 0)  Then
//				This.object.mtmrange2[row] = Long(data)
//			End If
//		End If
//	
//		
//	Case "unitsec2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec2[row] > 0)  Then
//				This.object.munitsec2[row] = Long(data)
//			End If
//		End If
//		
//		ll_range2 = This.object.tmrange2[row]
//		
//		If ll_range2 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range2, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange2")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee2"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee2[row] > 0)  Then
//				This.object.munitfee2[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange3[row] > 0)  Then
//				This.object.mtmrange3[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec3[row] > 0)  Then
//				This.object.munitsec3[row] = Long(data)
//			End If
//		End If
//		
//		ll_range3 = This.object.tmrange3[row]
//		
//		If ll_range3 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range3, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange3")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee3"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee3[row] > 0)  Then
//				This.object.munitfee3[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange4[row] > 0)  Then
//				This.object.mtmrange4[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec4[row] > 0)  Then
//				This.object.munitsec4[row] = Long(data)
//			End If
//		End If
//		
//		ll_range4 = This.object.tmrange4[row]
//		
//		If ll_range4 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range4, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange4")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee4"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee4[row] > 0)  Then
//				This.object.munitfee4[row] = Long(data)
//			End If
//		End If
//		
//	Case "tmrange5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.mtmrange5[row] > 0)  Then
//				This.object.mtmrange5[row] = Long(data)
//			End If
//		End If
//		
//	Case "unitsec5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitsec5[row] > 0)  Then
//				This.object.munitsec5[row] = Long(data)
//			End If
//		End If
//		
//		ll_range5 = This.object.tmrange5[row]
//		
//		If ll_range5 > 0 And Long(data) > 0 Then
//			ll_mod = Mod(ll_range5, Long(data))
//		
//			If ll_mod <> 0 Then
//				f_msg_info(9000, Title, "The value which time range is devided by unit time is not correct.  Please put it again.")
//				This.SetFocus()
//				This.SetColumn("tmrange5")
//				Return -1
//			End If
//		End If
//		
//	Case "unitfee5"
//		If ls_munitsec = '0' Or ls_munitsec = "" Then
//			If NOT(This.Object.munitfee5[row] > 0)  Then
//				This.object.munitfee5[row] = Long(data)
//			End If
//		End If
//		
//End Choose
//
//Return 0
end event

event dw_detail::retrieveend;call super::retrieveend;Long ll_row, i
String ls_filter, ls_target_type
Dec lc_data

If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
//	dw_cond.Enabled = false
		
ElseIf rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")

	dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
   dw_cond.Enabled = False

End If


end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_prepayment
integer x = 46
integer y = 1708
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_prepayment
integer x = 338
integer y = 1708
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_prepayment
integer x = 631
integer y = 1708
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_prepayment
integer x = 1321
integer y = 1708
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_prepayment
integer x = 41
integer y = 848
integer height = 36
end type

type p_new from u_p_new within b1w_reg_prepayment
boolean visible = false
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

type bt_check from commandbutton within b1w_reg_prepayment
integer x = 2359
integer y = 156
integer width = 617
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "기간연장/결재방법변경"
end type

event clicked;Long ll_row

If dw_master.Getrow() <= 0 Then Return 0

ll_row = dw_master.Getrow()

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "Periodic prepaid product payment"
iu_cust_msg.idt_data[1] = dw_master.Object.enddt[ll_row]
iu_cust_msg.il_data[1]  = dw_master.Object.contractseq[ll_row]
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail

OpenWithParm(b1w_reg_prepayment_popup, iu_cust_msg)


Trigger Event ue_ok()

//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   //프로그램 ID
//iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.validkey[al_row]) //validkey
//iu_cust_msg.is_data[4] = String(idw_tabpage[ai_tabpage].object.fromdt[al_row],'yyyymmdd')  //fromdt
//
////			ohj 2005.02.21 인증방법 추가로 인한 로직 추가로 popup변경
////			OpenWithParm(b1w_reg_validinfo_popup_update_cl, iu_cust_msg)
//	OpenWithParm(b1w_reg_validinfo_popup_update_cl_g, iu_cust_msg)
end event

