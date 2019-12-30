$PBExportHeader$ssrt_reg_adsale_sams1.srw
$PBExportComments$[1hera ] Sales Total
forward
global type ssrt_reg_adsale_sams1 from w_a_reg_m_m3_sams
end type
type dw_itemlist from datawindow within ssrt_reg_adsale_sams1
end type
end forward

global type ssrt_reg_adsale_sams1 from w_a_reg_m_m3_sams
integer width = 6423
integer height = 2312
boolean resizable = false
dw_itemlist dw_itemlist
end type
global ssrt_reg_adsale_sams1 ssrt_reg_adsale_sams1

type variables
STring 	is_emp_grp, 			is_colnm, &
			is_customerid, &
			is_caldt , &
			is_userid , &
			is_pgm_id , is_basecod, is_control, &
			is_method[], &
			is_trcod[]
Dec{2} 	idc_total, idc_receive, idc_change, idc_deposit, idc_impack

datawindow idw
Long il_get_row
end variables

forward prototypes
public subroutine wf_set_total ()
public function integer wf_read_saleamt (long wfl_iseqno, string wfs_itemcod, long wfl_row, string wfs_modelno, string wfs_sw)
public function long wf_set_impack (string as_data)
public function integer wf_read_other (string wfs_itemcod, long wfl_row)
public function integer wf_read_model (string wfs_modelno, long wfl_row)
end prototypes

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_sale.RowCount() > 0 THEN
	ldc_tot1 	=  dw_sale.GetItemNumber(dw_sale.RowCount(), "cp_total") + dw_sale.GetItemNumber(dw_sale.RowCount(), "tax_tot")
END IF

IF dw_detail.RowCount() > 0 THEN
	ldc_tot2 += dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_total") + dw_detail.GetItemNumber(dw_detail.RowCount(), "tax_tot")
END IF
IF dw_detail2.RowCount() > 0 THEN
	ldc_tot3 += dw_detail2.GetItemNumber(dw_detail2.RowCount(), "cp_total") + dw_detail2.GetItemNumber(dw_detail2.RowCount(), "tax_tot")
END IF

ldc_total =  ldc_tot1 + ldc_tot2 + ldc_tot3
dw_cond.Object.total[1] 		= ldc_total


F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

public function integer wf_read_saleamt (long wfl_iseqno, string wfs_itemcod, long wfl_row, string wfs_modelno, string wfs_sw);String ls_itemcod, ls_modelnm, ls_regcod, ls_modelno, ls_sw, &
			ls_saleItem,	ls_itemnm
Long	ll_iseqno, ll_row, ll_priority, ll_deposit_cnt
dec{2} ldec_saleamt, ldec_total
String ls_saledt

// 2019.04.16 변수 추가 Modified by Han
string ls_customerid, ls_surtaxyn
dec{2} ld_taxamt

ls_itemcod 	= wfs_itemcod
ll_iseqno 	= wfl_iseqno
ll_row 		= wfl_row
ls_modelno  = wfs_modelno
ls_sw 		= wfs_sw 
ls_saledt	= String(dw_cond.Object.paydt[1], 'yyyymmdd')

//모델명 read
select trim(modelnm)  INTO :ls_modelnm   FROM ADMODEL B
 WHERE MODELNO 	=  :ls_modelno ;
 
 IF IsNull(ls_modelnm) then ls_modelnm = ''
 
//Price read
//select sale_unitamt, sale_item  INto :ldec_saleamt, :ls_itemcod
//  from model_price
// where modelno =  :ls_modelno
//   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
//	                                      FROM model_price
//													 WHERE modelno =  :ls_modelno
//													   AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;
// 2019.04.16 Vat 계산 추가 Modified by Han
ls_customerid = dw_cond.Object.customerid[1]

SELECT a.sale_unitamt, a.sale_item, NVL(TRUNC(a.sale_unitamt * b.tax_rate / 100,2),0)
  INTO :ldec_saleamt, :ls_itemcod, :ld_taxamt
  FROM model_price a
     , (SELECT FNC_GET_TAXRATE(:ls_customerid, 'I', :ls_itemcod, to_date(:ls_saledt)) tax_rate
          FROM DUAL) b
 WHERE a.modelno =  :ls_modelno
   AND TO_CHAR(a.fromdt, 'yyyymmdd') = (SELECT MAX(TO_CHAR(fromdt, 'yyyymmdd'))
                                          FROM model_price
                                         WHERE modelno =  :ls_modelno
                                           AND TO_CHAR(fromdt, 'yyyymmdd') <= :ls_saledt);
														
		
IF sqlca.sqlcode < 0 THEN 
	f_msg_info(1000, Title, "MODEL_PRICE ")
	return -1
END IF
IF IsNull(ldec_saleamt) then ldec_saleamt = 0.00
IF IsNull(ls_itemcod) 	then ls_itemcod 	= ""
		
// regcod read
SELECT regcod     , ITEMNM    , PRIORITY    , DECODE(SURTAXYN,'N','*',' ')
  INTO :ls_regcod , :ls_itemnm, :ll_priority, :ls_surtaxyn
  FROM ITEMMST
 WHERE ITEMCOD = :ls_itemcod ;

//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
SELECT COUNT(*) INTO :ll_deposit_cnt
FROM   DEPOSIT_REFUND
WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
IF IsNull(ls_regcod) then ls_regcod  = ""
		
dw_sale.Object.regcod[ll_row] 		= ls_regcod
dw_sale.Object.itemcod[ll_row] 	= ls_itemcod
dw_sale.Object.itemnm[ll_row] 	= ls_itemnm
dw_sale.Object.modelnm[ll_row] 	= ls_modelnm
dw_sale.Object.modelno[ll_row] 	= ls_modelno
dw_sale.Object.sale_amt[ll_row] 	= ldec_saleamt
// 2019.04.16 taxamt 값 처리 추가 Modified by Han
dw_sale.Object.taxamt [ll_row]   = ld_taxamt
dw_sale.Object.surtaxyn[ll_row]  = ls_surtaxyn

dw_sale.Object.priority[ll_row] 	= ll_priority
IF ll_deposit_cnt <= 0 THEN
	dw_sale.Object.impack_card[ll_row] 	= Round(ldec_saleamt * 0.1, 2)
	dw_sale.Object.impack_not[ll_row] 	= Round(ldec_saleamt - Round(ldec_saleamt * 0.1, 2), 2)
	dw_sale.Object.impack_check[ll_row] = 'A'		
ELSE
	dw_sale.Object.impack_card[ll_row] 	= 0
	dw_sale.Object.impack_not[ll_row] 	= ldec_saleamt
	dw_sale.Object.impack_check[ll_row] = 'B'			
END IF
		
wf_set_total()
return 0
end function

public function long wf_set_impack (string as_data);LONG		ll_row1,			ll_row2,			ll_row3
INT		ii,				jj,				kk
DEC{2}	ldc_impack1,	ldc_impack2,	ldc_impack3,	ldc_total,		ldc_impack,		ldc_impack_10

ll_row1 = dw_sale.RowCount()
ll_row2 = dw_detail2.RowCount()
ll_row3 = dw_detail.RowCount()

ldc_impack = DEC(as_data)										//카드 입력한 금액
ldc_impack_10 = ROUND(ldc_impack * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impack = 0 THEN
	RETURN -1
END IF

idc_impack = 0

FOR ii = 1 TO ll_row1
	ldc_impack1 = dw_sale.Object.impack_card[ii]	
	IF IsNull(ldc_impack1) THEN ldc_impack1 = 0
	idc_impack  = idc_impack + ldc_impack1	
NEXT

FOR jj = 1 TO ll_row2
	ldc_impack2 = dw_detail2.Object.impack_card[jj]	
	IF IsNull(ldc_impack2) THEN ldc_impack2 = 0	
	idc_impack  = idc_impack + ldc_impack2			
NEXT

FOR kk = 1 TO ll_row3
	ldc_impack3 = dw_detail.Object.impack_card[kk]	
	IF IsNull(ldc_impack3) THEN ldc_impack3 = 0	
	idc_impack  = idc_impack + ldc_impack3		
NEXT

IF idc_impack > 0 THEN
	IF idc_impack < ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF
ELSE
	IF idc_impack > ldc_impack_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF	
END IF

ldc_total = dw_cond.Object.total[1]
IF idc_impack <> 0 THEN
	dw_cond.Object.credit[1]	= ldc_total - ldc_impack_10
ELSE
	dw_cond.Object.credit[1]	= 0
END IF

RETURN 0


end function

public function integer wf_read_other (string wfs_itemcod, long wfl_row);String 	ls_itemcod, 	ls_modelnm, 	ls_regcod, 	ls_modelno, ls_sw, &
			ls_saleItem, 	ls_itemnm
Long		ll_iseqno, 		ll_row,			ll_priority,		ll_deposit_cnt
dec{2} 	ldec_saleamt, 	ldec_total
String 	ls_paydt
String 	ls_temp, 		ls_ref_desc, 	ls_price_plan

// 2019.04.16 변수 추가 Modified by Han
string ls_customerid, ls_surtaxyn
dec{2} ld_taxrate

ll_row 			= wfl_row

//지정된 가격정책
//ls_price_plan	= fs_get_control("S1", "Z200", ls_ref_desc)
ls_price_plan	= dw_detail.Object.priceplan[wfl_row]
ls_itemcod  	= wfs_itemcod
ls_paydt			= String(dw_cond.Object.paydt[1], 'yyyymmdd')
//-----------------------------------------------------------------
//Price read
SELECT unitcharge  INTO :ldec_saleamt
  FROM priceplan_rate2
 WHERE priceplan = :ls_price_plan
   AND itemcod   = :ls_itemcod
   AND TO_CHAR(fromdt, 'yyyymmdd') = ( SELECT MAX(to_char(fromdt, 'yyyymmdd'))
	                                      FROM priceplan_rate2
													 WHERE priceplan = :ls_price_plan
													   AND itemcod   = :ls_itemcod
													   AND TO_CHAR(fromdt, 'yyyymmdd') <= :ls_paydt ) ;
														
IF IsNull(ldec_saleamt) then ldec_saleamt = 0
		
// regcod read
SELECT regcod     , ITEMNM    , PRIORITY    , DECODE(SURTAXYN,'N','*',' ')
  INTO :ls_regcod , :ls_itemnm, :ll_priority, :ls_surtaxyn
  FROM ITEMMST
 WHERE ITEMCOD = :ls_itemcod ;

IF IsNull(ls_regcod) then ls_regcod  = ""

SELECT COUNT(*) INTO :ll_deposit_cnt
FROM   DEPOSIT_REFUND
WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );

// 2019.04.16 Taxrate 가져오기 추가 Modified by Han
ls_customerid = dw_cond.Object.customerid[1]
SELECT FNC_GET_TAXRATE(:ls_customerid, 'I', :ls_itemcod, to_date(:ls_paydt))
  INTO :ld_taxrate
  FROM DUAL;

dw_detail.Object.regcod[ll_row] 		= ls_regcod
dw_detail.Object.itemcod[ll_row] 	= ls_itemcod
dw_detail.Object.itemnm[ll_row] 		= ls_itemnm
dw_detail.Object.unitamt[ll_row] 	= ldec_saleamt
dw_detail.Object.qty[ll_row] 			= 1
dw_detail.Object.sale_amt[ll_row] 	= ldec_saleamt
dw_detail.Object.priority[ll_row] 	= ll_priority

// 2019.04.16 taxrate dw move Modified by Han
dw_detail.Object.taxrate [ll_row]   = ld_taxrate
dw_detail.Object.surtaxyn[ll_row]   = ls_surtaxyn


IF ll_deposit_cnt <= 0 THEN
	dw_detail.Object.impack_card[ll_row] 	= Round(ldec_saleamt * 0.1, 2)
	dw_detail.Object.impack_not[ll_row] 	= Round(ldec_saleamt - Round(ldec_saleamt * 0.1, 2), 2)
	dw_detail.Object.impack_check[ll_row] 	= 'A'
ELSE
	dw_detail.Object.impack_card[ll_row] 	= 0
	dw_detail.Object.impack_not[ll_row] 	= ldec_saleamt
	dw_detail.Object.impack_check[ll_row] 	= 'B'			
END IF

wf_set_total()
return 0
end function

public function integer wf_read_model (string wfs_modelno, long wfl_row);String ls_itemcod, 	ls_modelnm, ls_regcod, ls_modelno, ls_sw, &
		 ls_saleItem, 	ls_itemnm
Long	ll_iseqno, ll_row,	ll_priority, ll_deposit_cnt
dec{2} ldec_saleamt, ldec_total
String ls_saledt

ls_modelno  = wfs_modelno
ls_saledt	= String(dw_cond.Object.paydt[1], 'yyyymmdd')
ll_row 		= wfl_row

// 2019.04.16 변수 추가 Modified by Han
string ls_customerid, ls_surtaxyn
dec{2} ld_taxrate

//Price read
select sale_unitamt, sale_item  INto :ldec_saleamt, :ls_itemcod
  from model_price
 where modelno =  :ls_modelno
   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
	                                      FROM model_price
													 WHERE modelno =  :ls_modelno
													   AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;


IF IsNull(ls_itemcod) 	then ls_itemcod 	= ""
	
IF sqlca.sqlcode < 0 THEN 
	f_msg_info(1000, Title, "MODEL_PRICE ")
	dw_detail2.Object.modelno[ll_row] = ""
	return -1
END IF

// 2019.04.16 Taxrate 가져오기 추가 Modified by Han
ls_customerid = dw_cond.Object.customerid[1]
SELECT FNC_GET_TAXRATE(:ls_customerid, 'I', :ls_itemcod, to_date(:ls_saledt))
  INTO :ld_taxrate
  FROM DUAL;


// Itemnm, regcod read
select itemnm    ,   regcod    ,  priority   , DECODE(SURTAXYN,'N','*',' ')
  INTO :ls_itemnm, 	:ls_regcod,	:ll_priority, :ls_surtaxyn
  FROM itemmst 
 where itemcod =  :ls_itemcod ;

IF IsNull(ldec_saleamt) then ldec_saleamt = 0.00
IF IsNull(ls_itemnm) 	then ls_itemnm 	= ""
IF IsNull(ls_regcod) 	then ls_regcod  	= ""

//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
SELECT COUNT(*) INTO :ll_deposit_cnt
FROM   DEPOSIT_REFUND
WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		
dw_detail2.Object.regcod[ll_row] 	= ls_regcod
dw_detail2.Object.itemcod[ll_row] 	= ls_itemcod
dw_detail2.Object.itemnm[ll_row] 	= ls_itemnm
dw_detail2.Object.modelno[ll_row] 	= ls_modelno
dw_detail2.Object.unitamt[ll_row] 	= ldec_saleamt
// 2019.04.16 taxrate dw move Modified by Han
dw_detail2.Object.taxrate [ll_row]  = ld_taxrate
dw_detail2.Object.surtaxyn[ll_row]  = ls_surtaxyn

dw_detail2.Object.qty[ll_row] 		= 1
dw_detail2.Object.sale_amt[ll_row] 	= ldec_saleamt
//2014.07.18 이윤주 대리 요청으로, sales_amt에 priority가 들어가지 않도록 막음 by 김선주 
//dw_detail2.Object.sale_amt[ll_row] 	= ll_priority
IF ll_deposit_cnt <= 0 THEN
	dw_detail2.Object.impack_card[ll_row] 	= Round(ldec_saleamt * 0.1, 2)
	dw_detail2.Object.impack_not[ll_row] 	= Round(ldec_saleamt - Round(ldec_saleamt * 0.1, 2), 2)
	dw_detail2.Object.impack_check[ll_row] 	= 'A'	
ELSE
	dw_detail2.Object.impack_card[ll_row] 	= 0
	dw_detail2.Object.impack_not[ll_row] 	= ldec_saleamt
	dw_detail2.Object.impack_check[ll_row] 	= 'B'		
END IF
wf_set_total()
return 0
end function

event ue_reset;call super::ue_reset;F_INIT_DSP(1,"","")


//초기화
Integer li_ret, li_mod
String ls_paymethod, ls_ref_desc
date ldt_saledt
String ls_temp
//PayMethod101, 102, 103, 104, 105, 107
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_trcod[])

SetRedraw(True)

dw_detail.AcceptText()


li_mod = dw_detail.ModifiedCount() + &
			dw_detail.DeletedCount() + &
			dw_detail2.DeletedCount()
			
//IF dw_detail.ModifiedCount()> 0 THEN
//	IF dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_cash") > 0 then 		li_mod += 1
//END IF
			
If li_mod > 0 then
		li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
		CHOOSE CASE li_ret
			CASE 1
				li_ret = -1 
				li_ret = Event ue_save()
				If Isnull( li_ret ) or li_ret < 0 then return
			CASE 2
	
			CASE ELSE
				Return 
		END CHOOSE
			
	end If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_cond.Object.memberid[1] 	= ''
dw_cond.Object.customerid[1] 	= ''
dw_cond.Object.customernm[1] 	= ''
dw_cond.Object.operator[1] 	= ''
dw_cond.Object.operatornm[1] 	= ''

dw_detail.Reset()
dw_sale.Reset()
dw_detail2.Reset()
//dw_detail2.InsertRow(0)
dw_cond.Object.method1[1] = is_method[1]
dw_cond.Object.method2[1] = is_method[2]
dw_cond.Object.method3[1] = is_method[3]
dw_cond.Object.method4[1] = is_method[4]
dw_cond.Object.method5[1] = is_method[5]
dw_cond.Object.method6[1] = is_method[6]

dw_cond.Object.trcod1[1] = is_trcod[1]
dw_cond.Object.trcod2[1] = is_trcod[2]
dw_cond.Object.trcod3[1] = is_trcod[3]
dw_cond.Object.trcod4[1] = is_trcod[4]
dw_cond.Object.trcod5[1] = is_trcod[5]
dw_cond.Object.trcod5[1] = is_trcod[6]

dw_cond.Object.amt1[1] = 0
dw_cond.Object.amt2[1] = 0
dw_cond.Object.amt3[1] = 0
dw_cond.Object.amt4[1] = 0
dw_cond.Object.amt5[1] = 0
dw_cond.Object.amt6[1] = 0
dw_cond.Object.total[1] = 0
dw_cond.Object.credit[1] = 0

//dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//초기화!
idc_deposit = 0
idc_total   = 0
idc_impack	= 0

dw_sale.Reset()
dw_cond.Enabled 				= True

dw_cond.object.partner[1] 		= GS_SHOPID
//dw_cond.object.paymethod[1] 	= ls_paymethod

select closedt INTO :ldt_saledt FROM shopclosemst
where partner =  :gs_shopid ;
IF IsNull(ldt_saledt) OR sqlca.sqlcode <> 0 THEN
	dw_cond.object.paydt[1] 		= date(fdt_get_dbserver_now())
else
	dw_cond.object.paydt[1] 		= ldt_saledt
end if
idw =  dw_sale

end event

event ue_ok();Long 		ll_row
String 	ls_where
String 	ls_customerid, 	ls_partner,	ls_paymethod, ls_operator,		ls_saledt, &
			ls_memberid,		ls_customernm
date		ldat_saledt


//Long li_ret
//
//If dw_detail.ModifiedCount() > 0 or &
//	dw_detail.DeletedCount() > 0 or &
//	dw_sale.ModifiedCount() > 0 or &
//	dw_sale.DeletedCount() > 0 or &
//	dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
//	
//	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
//	CHOOSE CASE li_ret
//		CASE 1
//			li_ret = -1 
//			li_ret = Event ue_save()
//			If Isnull( li_ret ) or li_ret < 0 then return
//		CASE ELSE
//			Return 
//	END CHOOSE
//end If
//
//Event ue_ok_after()
//
//dw_master.event ue_select()

//조회 시 상단 대분류명 like 조회
ls_customerid 	= Trim(dw_cond.Object.customerid[1])
ls_memberid 	= Trim(dw_cond.Object.memberid[1])
ls_saledt 		= String(dw_cond.Object.paydt[1], 'yyyymdd')
ls_partner 		= Trim(dw_cond.Object.partner[1])
ls_operator 	= Trim(dw_cond.Object.operator[1])

If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
If IsNull(ls_operator) 		Then ls_operator		= ""
ls_where = ""

IF ls_memberid <> '' then
	select customerid, 		customernm
	  INTO :ls_customerid,	:ls_customernm
	  FROM customerm
	 where memberid = :ls_memberid ;
		 
	 IF IsNull(ls_customerid) OR sqlca.sqlcode <> 0  then ls_customerid = ""
	 IF IsNull(ls_customernm) OR sqlca.sqlcode <> 0  then ls_customernm = ""
		 
	dw_cond.Object.customerid[1] =  ls_customerid
	dw_cond.Object.customernm[1] =  ls_customernm
END IF

IF ls_customerid = "" then
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("customerid")
	Return 
END IF


IF ls_operator = "" then
//	f_msg_usr_err(200, "Condition", "Operator")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("operator")
	Return 
END IF


//IF ls_memberid = "" then
//	dw_cond.SetFocus()
//	dw_cond.SetRow(1)
//	dw_cond.SetColumn("memberid")
//	Return 
//END IF

p_OK.TriggerEvent("ue_DISable")

p_insert.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")


dw_sale.SetFocus()
	
This.Trigger Event ue_insert()	
	

end event

on ssrt_reg_adsale_sams1.create
int iCurrent
call super::create
this.dw_itemlist=create dw_itemlist
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_itemlist
end on

on ssrt_reg_adsale_sams1.destroy
call super::destroy
destroy(this.dw_itemlist)
end on

event ue_insert;call super::ue_insert;Long ll_row

string ls_customerid
ls_customerid = dw_cond.Object.customerid[1]

if ls_customerid = '' or isnull(ls_customerid) then
	messagebox("확인","CustomerID를 입력하세요!")
	return
end if

ll_row = idw.InsertRow(0)
idw.SCrollToRow(ll_row)
idw.SetFocus()
idw.setRow(ll_row)
idw.SetColumn(is_colnm)

IF idw.dataobject = 'ssrt_reg_adsale_other_sams' THEN
	idw.Object.svccod[ll_row] = 'SSRT'
	
	idw.Event ItemChanged(ll_row, idw.Object.svccod, 'SSRT')
END IF	

p_save.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

//idw.SetFocus()
//idw.SetRow(ll_row)
//idw.SetColumn(1)
end event

event open;call super::open;//postEvent("resize")
dw_cond.SetFocus()
dw_cond.SetColumn("memberid")
end event

event ue_save;Long 		ll_row1, ll_row2, 		ll_row3, 	ll, 				ll_row, 			ll_cnt, &
			i, 		ll_seq,			ll_qty,		ll_cnt_20,		ll_all_20,		ll_cont_cnt,	&
			ll_dep_cnt,	ll_card_check
			
Integer 	li_rtn, 				li_rc, &
			li_check_minus
			
Dec{2} 	ldc_amt,				ldc_card_total,						ldc_total,		ldc_impack,		ldc_card

String 	ls_itemcod, 		ls_paydt, 		ls_customerid, 	ls_chk,	&
			ls_memberid, 		ls_ok,			ls_operator, 		ls_partner, &
			ls_msg,				ls_userid,		ls_contno,			ls_contseq,		ls_remark3, ls_modelno,	&
			ls_svc_check,		ls_contractseq, ls_pid, 			ls_spec_item1,	ls_orderno

date		ldt_shop_closedt,	ldt_paydt,		ldt_closedt_after
//==========================================================================================
ls_customerid		= trim(dw_cond.Object.customerid[1])
ls_operator			= trim(dw_cond.Object.operator[1])
ls_partner			= dw_cond.Object.partner[1]
ldt_shop_closedt 	= f_find_shop_closedt(ls_partner)
ldt_paydt 			= dw_cond.Object.paydt[1]

IF IsNull(ls_customerid) 	then ls_customerid 	= ''
IF IsNull(ls_operator) 		then ls_operator 		= ''

li_rtn =  F_CHECK_ID(ls_customerid, ls_operator)
IF li_rtn =  -1 THEN
		f_msg_usr_err(9000, Title, "Customerid가 존재하지 않습니다.")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.Object.customerid[1] = ''
		dw_cond.Object.customernm[1] = ''
		dw_cond.SetColumn("customerid")
		Return -1 
ELSEIF li_rtn = -2 THEN 
		f_msg_usr_err(9000, Title, "Operator가 존재하지 않습니다.")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.Object.operator[1] = ''
		dw_cond.SetColumn("operator")
		Return -1 
END IF

IF ls_operator = "" then
	f_msg_usr_err(9000, Title, "Operator가 존재하지 않습니다.")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.Object.operator[1] = ''
	dw_cond.SetColumn("operator")
	Return -1 
END IF

ldc_total 		= 	dw_cond.Object.total[1]
ldc_card_total = 	dw_cond.Object.amt2[1] + &
						dw_cond.Object.amt3[1] + &
						dw_cond.Object.amt4[1] + &
						dw_cond.Object.amt5[1]
ldc_impack		=  dw_cond.Object.amt5[1]						
IF ldc_total > 0 then
	IF ldc_card_total > ldc_total then
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.SetColumn("amt1")
		Return -1 
	END IF
ELSE
	IF ldc_card_total < ldc_total then
		f_msg_usr_err(9000, Title, "결제 내용을 확인하세요!")
		dw_cond.SetFocus()
		dw_cond.SetRow(1)
		dw_cond.SetColumn("amt1")
		Return -1 
	END IF
END IF

ldt_closedt_after = RelativeDate(ldt_shop_closedt, 1)

IF ldt_shop_closedt > ldt_paydt then
	f_msg_usr_err(9000, Title, "Shop 마감일과 Sales Date가 다릅니다.~n~t RESET 후 다시 입력하십시요. ")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("customerid")
	Return -1 
END IF

IF ldt_paydt > ldt_closedt_after THEN
	f_msg_usr_err(9000, Title, "Sales Date가 다릅니다.")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("paydt")
	Return -1 
END IF

ll_row1 = dw_sale.RowCount()  	//Single Item (contno)
ll_row2 = dw_detail2.RowCount() 	//Group (modelno)
ll_row3 = dw_detail.RowCount() 	//Others (itemcod)
dw_itemlist.Reset()

// Single Item
IF ll_row1 > 0 THEN
	FOR ll = ll_row1 to 1 step -1
      ldc_amt 	=  dw_sale.Object.sale_amt[ll]
      ls_chk 	=  trim(dw_sale.Object.contno[ll])
		IF IsNull(ls_chk) then ls_chk = ''
		IF IsNull(ldc_amt) then ldc_amt = 0		

		IF (IsNull(ldc_amt) OR ldc_amt = 0) AND ls_chk = '' THEN
			dw_sale.DeleteRow(ll)
	   ELSE
			ll_row                               	= dw_itemlist.InsertRow(0)
			dw_itemlist.Object.contno[ll_row] 	 	= dw_sale.Object.contno[ll]
			dw_itemlist.Object.sale_amt[ll_row]  	= dw_sale.Object.sale_amt[ll]
			dw_itemlist.Object.qty[ll_row] 		 	= 1
			dw_itemlist.Object.manual_yn[ll_row] 	= 'N'
			dw_itemlist.Object.modelno[ll_row] 	 	= dw_sale.Object.modelno[ll]
			dw_itemlist.Object.itemcod[ll_row] 	 	= dw_sale.Object.itemcod[ll]
			dw_itemlist.Object.itemnm[ll_row] 	 	= dw_sale.Object.itemnm[ll]
			dw_itemlist.Object.regcod[ll_row] 	 	= dw_sale.Object.regcod[ll]
			dw_itemlist.Object.remark[ll_row] 	 	= dw_sale.Object.contno[ll]
			dw_itemlist.Object.remark2[ll_row] 	 	= dw_sale.Object.remark2[ll]
			dw_itemlist.Object.sale_type[ll_row] 	= 'Y' // 판매와 동시에 충전시 판매시에만 장비 업데이트하기 위한 체크 필드 2007-08-06 hcjung
			dw_itemlist.Object.priority[ll_row]    = dw_sale.Object.priority[ll]
			dw_itemlist.Object.impack_card[ll_row] = dw_sale.Object.impack_card[ll]
			dw_itemlist.Object.impack_not[ll_row]  = dw_sale.Object.impack_not[ll]

			// 2019.04.16 부가세 + 공급가 금액 Move Modified by Han
			dw_itemlist.Object.sale_tot[ll_row]    = dw_sale.Object.sale_amt[ll] + dw_sale.GetItemNumber(ll, 'taxamt')
			dw_itemlist.Object.vat     [ll_row]    = dw_sale.Object.taxamt  [ll]
			dw_itemlist.Object.surtaxyn[ll_row]    = dw_sale.Object.surtaxyn[ll]

		END IF
	NEXT
END IF

// Group 
IF ll_row2 > 0 THEN
	FOR ll= ll_row2 to 1 step -1
      ldc_amt 	=  dw_detail2.Object.sale_amt[ll]
      ls_chk 	=  trim(dw_detail2.Object.modelno[ll])
		IF IsNull(ls_chk)  THEN ls_chk  = ''
		IF IsNull(ldc_amt) THEN ldc_amt = 0				

      //2014.07.18 sales금액이 0일 경우에, 해당 row를 지우지 못하도록 로직 변경 
		//판매가 아닌, 무상으로 주는 경우가 있다고함(이윤주) by 김선주 
		//IF IsNull(ldc_amt) OR ldc_amt = 0 OR ls_chk = '' THEN
		IF ls_chk = '' THEN
			dw_detail2.DeleteRow(ll)
		ELSE
			//RQ-UBS-201407-09 START BY HMK
			//itemchanged event 강제 호출
			//기본 수량 1로 세팅된 상태로 수량 수정없이 tab키를 안 눌르고 그냥 금액 넣고 처리하면 판매처리가 됩니다. 
         //그래서 요청 드리는 것은 Save할 때 한 번 더 수량 체크를 해서 제약을 걸어 주셔야 할 듯 합니다. 
			long ll_ret, ll_qty2
			ll_qty2 = dw_detail2.Object.qty[ll]
	      ll_ret = dw_detail2.Event ItemChanged(ll, dw_detail2.Object.qty, string(ll_qty2))
			if ll_ret > 0 then
					return -1 //수량제한에 걸려 저장 안되는 케이스
			end if
         //itemchanged event 강제 호출	
			//RQ-UBS-201407-09 END BY HMK
			ll_row                              	= dw_itemlist.InsertRow(0)
			dw_itemlist.Object.contno[ll_row] 		= ""
			dw_itemlist.Object.sale_amt[ll_row] 	= dw_detail2.Object.sale_amt[ll]
			dw_itemlist.Object.qty[ll_row] 			= dw_detail2.Object.qty[ll]
			dw_itemlist.Object.modelno[ll_row] 		= dw_detail2.Object.modelno[ll]
			dw_itemlist.Object.itemcod[ll_row] 		= dw_detail2.Object.itemcod[ll]
			dw_itemlist.Object.itemnm[ll_row] 		= dw_detail2.Object.itemnm[ll]
			dw_itemlist.Object.regcod[ll_row] 	 	= dw_detail2.Object.regcod[ll]
			dw_itemlist.Object.remark[ll_row] 	 	= dw_detail2.Object.remark[ll]			
			dw_itemlist.Object.manual_yn[ll_row] 	= 'N'
			dw_itemlist.Object.remark2[ll_row] 		= ""
			dw_itemlist.Object.sale_type[ll_row]	= '' // 판매와 동시에 충전시 판매시에만 장비 업데이트하기 위한 체크 필드 2007-08-06 hcjung			
			dw_itemlist.Object.priority[ll_row]  	= dw_detail2.Object.priority[ll]			
			dw_itemlist.Object.impack_card[ll_row] = dw_detail2.Object.impack_card[ll]
			dw_itemlist.Object.impack_not[ll_row]  = dw_detail2.Object.impack_not[ll]

			// 2019.04.16 부가세 + 공급가 금액 Move Modified by Han
			dw_itemlist.Object.sale_tot[ll_row]    = dw_detail2.Object.sale_amt[ll] + dw_detail2.GetItemNumber(ll, 'taxamt')
			dw_itemlist.Object.vat     [ll_row]    = dw_detail2.GetItemNumber(ll, 'taxamt')
			dw_itemlist.Object.surtaxyn[ll_row]    = dw_detail2.Object.surtaxyn[ll]

		END IF			
	NEXT
END IF

ll_all_20 = 0

IF ll_row3 > 0 THEN
	FOR ll= ll_row3 to 1 step -1
      ldc_amt =  dw_detail.Object.sale_amt[ll]
      ls_chk 	=  trim(dw_detail.Object.itemcod[ll])
		IF IsNull(ls_chk) then ls_chk = ''
		IF IsNull(ldc_amt) OR ldc_amt = 0 OR ls_chk = '' then
			dw_detail.DeleteRow(ll)
		else
			SELECT COUNT(*) 
			INTO :ll_dep_cnt
			FROM   DEPOSIT_REFUND
			WHERE ( IN_ITEM = :ls_chk OR OUT_ITEM = :ls_chk );
			
			IF ll_dep_cnt > 0 THEN
				ls_contseq = String(dw_detail.Object.contractseq[ll])
				ls_orderno = String(dw_detail.Object.orderno[ll])
				
				IF (IsNull(ls_contseq) OR ls_contseq = "") and (IsNull(ls_orderno) OR ls_orderno = "") THEN
					//IF MessageBox("확인", "보증금 계약번호 또는 ORDER NO.가 입력되지 않았습니다. 계속 진행하시겠습니까?", Question!, YesNo!, 2) = 2 THEN
						f_msg_usr_err(9000, Title, "보증금 계약번호 또는 ORDER NO.가 입력되지 않았습니다.")
						dw_detail.SetFocus()
						dw_detail.SetRow(ll)
						dw_detail.SetColumn("contractseq")
						Return -1 
					//END IF						
				END IF					
			END IF				
			
			// 연동 카드의 충전 아이템인지 확인 ==> 맞으면 Serial No 체크
			SELECT Count(*) 
			INTO :ll_cnt 
			FROM syscod2t 
			 WHERE grcode = 'DacomPPC01'
			   AND use_yn = 'Y'
			   AND CODE  = :ls_chk ;
				
			SELECT Count(*) 
			INTO :ll_cnt_20 
			FROM syscod2t 
			 WHERE grcode = 'DacomPPC04'
			   AND use_yn = 'Y'
			   AND CODE  = :ls_chk ;	
				
			IF ll_cnt_20 = 0 AND ll_cnt = 0 THEN
				ls_remark3 = dw_detail.Object.remark3[ll]
				
				IF IsNull(ls_remark3) OR ls_remark3 = "" THEN
					f_msg_usr_err(9000, Title, "사유를 입력하세요.")
					dw_detail.SetFocus()
					dw_detail.SetRow(ll)
					dw_detail.SetColumn("remark3")
					Return -1 
				END IF
			END IF				
				
			IF ll_cnt_20 > 0 THEN ll_all_20 = ll_all_20 + 1				
			
			IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt = 0
			IF ll_cnt > 0 THEN
				ls_contno 	=  trim(dw_detail.Object.remark[ll])
				IF IsNull(ls_contno) then ls_contno = ''
				IF ls_contno = '' THEN
					f_msg_usr_err(9000, Title, "충전할 카드의 ControlNo.를 입력하세요.")
					dw_detail.SetFocus()
					dw_detail.SetRow(ll)
					dw_detail.SetColumn("Remark")
					Return -1 
				END IF
				
				IF ldc_amt <> ROUND(ldc_amt/10,0)*10 THEN
					f_msg_usr_err(9000, Title, "Please check the recharging amount.")
					dw_detail.SetFocus()
					dw_detail.SetRow(ll)
					dw_detail.SetColumn("sale_amt")
					RETURN -1
				END IF
				
				Select count(*) 
				INTO :ll_cnt 
				FROM admst 
				where contno = :ls_contno;
				
				IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt = 0
				IF ll_cnt = 0 then 
					f_msg_usr_err(9000, Title, "해당 Item에 대한 Contorol No.를 찾을 수 없습니다.~n~t 확인 후 다시 입력하십시요. ")
					dw_detail.SetFocus()
					dw_detail.SetRow(ll)
					dw_detail.SetColumn("Remark")
					Return -1 
				ELSE
					SELECT MODELNO  , PID    , SPEC_ITEM1  
					INTO :ls_modelno, :ls_pid, :ls_spec_item1
					FROM   ADMST
					WHERE  CONTNO = :ls_contno;
					
					SELECT COUNT(*)       , NVL(MAX(SVC_CHECK), 'N') 
					INTO   :ll_card_check , :ls_svc_check
					FROM   CARD_ITEM
					WHERE  CHARGE_ITEM = :ls_chk
					AND    MODELNO = :ls_modelno;
					
					IF ll_card_check <= 0 THEN
						f_msg_usr_err(9000, Title, "해당 Item으로 충전할 수 없는 카드입니다.~n~t 확인 후 다시 입력하십시요. ")
						dw_detail.SetFocus()
						dw_detail.SetRow(ll)
						dw_detail.SetColumn("itemcod")
						Return -1 						
					ELSE
						IF ls_svc_check = 'Y' THEN
							SELECT TO_CHAR(CONTRACTSEQ) 
							INTO :ls_contractseq
							FROM   CUSTOMER_HW
							WHERE  CUSTOMERID = :ls_customerid
							AND    (SERIALNO = :ls_pid OR SERIALNO = :ls_spec_item1);
						
							IF IsNull(ls_contractseq) THEN ls_contractseq = ""
						
							IF ls_contractseq <> "" THEN
								SELECT COUNT(*) 
								INTO :ll_cont_cnt
								FROM   CONTRACTMST
								WHERE  CUSTOMERID = :ls_customerid
								AND    CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
								AND    STATUS = '20';
								
								IF ll_cont_cnt <= 0 THEN
									f_msg_usr_err(9000, Title, "개통된 계약이 없습니다. 계약상태를 확인하세요. ")
									dw_detail.SetFocus()
									dw_detail.SetRow(ll)
									dw_detail.SetColumn("itemcod")
									Return -1 									
								END IF
							ELSE
								f_msg_usr_err(9000, Title, "개통된 계약이 없습니다. 계약상태를 확인하세요. ")
								dw_detail.SetFocus()
								dw_detail.SetRow(ll)
								dw_detail.SetColumn("itemcod")
								Return -1 								
							END IF
						END IF
					END IF					
				END IF					
			ELSE
				ls_contno = ''
			END IF
			
			ll_row                               	= dw_itemlist.InsertRow(0)
			dw_itemlist.Object.contno[ll_row] 	 	= dw_detail.Object.remark[ll]	
			dw_itemlist.Object.sale_amt[ll_row]  	= dw_detail.Object.sale_amt[ll]
			dw_itemlist.Object.qty[ll_row] 		 	= dw_detail.Object.qty[ll]
			dw_itemlist.Object.modelno[ll_row] 	 	= ""
			dw_itemlist.Object.itemcod[ll_row] 	 	= dw_detail.Object.itemcod[ll]
			dw_itemlist.Object.itemnm[ll_row] 	 	= dw_detail.Object.itemnm[ll]
			dw_itemlist.Object.regcod[ll_row] 	 	= dw_detail.Object.regcod[ll]
			dw_itemlist.Object.remark[ll_row] 	 	= dw_detail.Object.remark[ll]			
			dw_itemlist.Object.contno[ll_row] 	 	= ls_contno
			dw_itemlist.Object.manual_yn[ll_row] 	= 'Y'
			dw_itemlist.Object.remark2[ll_row] 	 	= dw_detail.Object.remark2[ll]	
			dw_itemlist.Object.sale_type[ll_row] 	= '' // 판매와 동시에 충전시 판매시에만 장비 업데이트하기 위한 체크 필드 2007-08-06 hcjung
			dw_itemlist.Object.priority[ll_row]  	= dw_detail.Object.priority[ll]
			dw_itemlist.Object.impack_card[ll_row] = dw_detail.Object.impack_card[ll]
			dw_itemlist.Object.impack_not[ll_row]  = dw_detail.Object.impack_not[ll]
			dw_itemlist.Object.contractseq[ll_row] = dw_detail.Object.contractseq[ll]	
			dw_itemlist.Object.remark3[ll_row] 	 	= dw_detail.Object.remark3[ll]
			//2016.06.10 추가
			dw_itemlist.Object.orderno[ll_row] = dw_detail.Object.orderno[ll]

			// 2019.04.16 부가세 + 공급가 금액 Move Modified by Han
			dw_itemlist.Object.sale_tot[ll_row]    = dw_detail.Object.sale_amt[ll] + dw_detail.GetItemNumber(ll, 'taxamt')
			dw_itemlist.Object.vat     [ll_row]    = dw_detail.GetItemNumber(ll, 'taxamt')
			dw_itemlist.Object.surtaxyn[ll_row]    = dw_detail.Object.surtaxyn[ll]

		END IF
	NEXT
END IF
IF dw_itemlist.RowCount() = 0 THEN RETURN -1
	
idc_total 	=  dw_cond.Object.total[1]
idc_receive =  dw_cond.Object.cp_receive[1]

IF IsNull(idc_receive) 	then idc_receive 	= 0
IF IsNull(idc_total) 	then idc_total 	= 0
ls_ok = ''

IF idc_total < 0 THEN
	IF idc_total = idc_receive then
		ls_ok = 'N'
		//입금할 금액이 마이너스(-)인경우에는 입금종류는 하나인지 Check --ADD 2007-4-2
		li_check_minus = 0
		IF dw_cond.Object.amt1[1] <> 0 THEN  li_check_minus += 1
		IF dw_cond.Object.amt2[1] <> 0 THEN  li_check_minus += 1
		IF dw_cond.Object.amt3[1] <> 0 THEN  li_check_minus += 1
		IF dw_cond.Object.amt4[1] <> 0 THEN  li_check_minus += 1
		IF dw_cond.Object.amt5[1] <> 0 THEN  li_check_minus += 1
		IF dw_cond.Object.amt6[1] <> 0 THEN  li_check_minus += 1		
		IF li_check_minus <> 1 THEN
			ls_ok = 'Y'
			ls_msg =  '총액이 마이너스금액(-)인 경우, 입금종류는 하나만 입력 하세요!'
		END IF
		//
	ELSE
		ls_ok = 'Y'
		ls_msg =  '입금액이 다릅니다. 확인 하세요.'
	END IF
ELSEIF idc_total > 0 THEN
	IF idc_total > idc_receive then
		ls_ok = 'Y'
		ls_msg =  '입금액이 부족합니다. 확인 하세요.'
	ELSE
		ls_ok = 'N'
	END IF
ELSEif idc_receive = 0 OR idc_total = 0 then
//2009.05.28 0원도 등록 가능하도록 변경-----------	
//변경전------------------------------------------
//ls_ok = 'Y'
//ls_msg =  '입금액이 없습니다. 확인 하세요.'
//변경전---------------------------------------END
//변경후------------------------------------------	
	IF idc_total = idc_receive THEN
		ls_ok = 'N'
	ELSE
		ls_ok = 'Y'
		ls_msg =  '입금액이 없습니다. 확인 하세요.'
	END IF	
//변경후---------------------------------------END	
//2009.05.28-----------------------------------END
END IF

//2010.05.07 추가. ALL 20% 충전 아이템은 해당가격정책이 개통중인게 있는지 확인한다.
IF ll_all_20 > 0 THEN
	
	SELECT COUNT(*) 
	INTO :ll_cont_cnt
	FROM   CONTRACTMST
	WHERE  CUSTOMERID = :ls_customerid
	AND    STATUS = '20'
	AND    PRICEPLAN IN ( SELECT CODE FROM SYSCOD2T
								 WHERE  GRCODE = 'UBS16'
								 AND    USE_YN = 'Y' );
								 
	IF ll_cont_cnt <= 0 THEN
		ls_ok = 'Y'
		ls_msg = '개통된 계약이 없습니다. 확인하세요.'
	END IF
END IF

IF ls_ok = 'Y'  then
	f_msg_usr_err(9000, Title, ls_msg)
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -1	
END IF

select Count(*) 
INTO :ll_cnt 
FROM CUSTOMERM 
WHERE CUSTOMERID = :ls_customerid ;
IF IsNULL(ll_cnt) then ll_cnt = 0
IF sqlca.sqlcode <> 0 then
	f_msg_usr_err(9000, Title, "Not Found CustomerID")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("customerid")
	Return -1 
	
END IF

//2009.06.10 추가
IF ldc_impack <> 0 THEN
	Dec{2} 	ldc_90
	ldc_90 = dw_cond.Object.credit[1]
	ldc_card = dw_cond.Object.amt3[1]	
	dw_cond.Object.amt5[1] = idc_total - ldc_90
	dw_cond.Object.amt3[1] = ldc_card + (ldc_impack - (idc_total - ldc_90))
END IF

//-3006-8-19 add ------------------------------------------------------------------
//Impact Card로 결제 하는 경우 
//10%는 Impact 90%는 Credit card 로 분할 처리
//Dec{2} 	ldc_10, ldc_90, ldc_100, ldc_impact, ldc_card
//
//ldc_100 =  dw_cond.Object.amt5[1]
//If IsNull(ldc_100) then ldc_100 = 0
//IF ldc_100 <> 0 then
//	ldc_10 						= Round(ldc_100 * 0.1, 2)
//	ldc_90 						= ldc_100 - ldc_10
//	
//	ldc_card 					= dw_cond.Object.amt3[1]
//	If IsNull(ldc_card) then ldc_card = 0
//	
//	dw_cond.Object.amt5[1]	= ldc_10
//	dw_cond.Object.amt3[1]	= ldc_card + ldc_90
//END IF
dw_cond.Accepttext()


b1u_dbmgr_dailypayment	lu_dbmgr

ls_customerid 	= trim(dw_cond.Object.customerid[1])
ls_MEMBERid 	= trim(dw_cond.Object.memberid[1])
ls_partner 		= trim(dw_cond.Object.partner[1])
ls_operator		= trim(dw_cond.Object.operator[1])
idc_total 		= dw_cond.Object.total[1]
idc_receive 	= dw_cond.Object.cp_receive[1]
idc_change 		= dw_cond.Object.cp_change[1]
ls_paydt 		= String(dw_cond.Object.paydt[1], 'yyyymmdd')

//  =========================================================================================
//  2008-03-25 hcjung   
//  디스플레이기에 잔액이 잘못나와서 출력 구문의 위치를 바꿈
//  =========================================================================================
F_INIT_DSP(3, String(idc_receive), String(idc_change))

//li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo! , 1)
li_rtn = 1
//저장
lu_dbmgr = Create b1u_dbmgr_dailypayment
lu_dbmgr.is_caller 	= "save_sales"
lu_dbmgr.is_title 	= Title
lu_dbmgr.idw_data[1] = dw_cond //조건
lu_dbmgr.idw_data[2] = dw_itemlist//item 정보

lu_dbmgr.is_data[1] 	= ls_customerid
lu_dbmgr.is_data[2] 	= ls_paydt  //paydt(shop별 마감일 )
lu_dbmgr.is_data[3] 	= ls_partner //shopid


//EMP_ID Search
//SELECT EMP_ID INTO :ls_userid FROM SYSUSR1T WHERE EMP_NO =  :ls_operator ;
//IF IsNull(ls_userid) then ls_userid = ''

lu_dbmgr.is_data[4] 	= ls_operator //Operator
IF li_rtn = 1 THEN 
	lu_dbmgr.is_data[5] 	= "Y"
ELSE
	lu_dbmgr.is_data[5] 	= "N"
END IF

lu_dbmgr.is_data[6] 	= gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[7] 	= "Y" //ADMST Update 여부
lu_dbmgr.is_data[8] 	= ls_memberid //memberid
lu_dbmgr.is_data[9] 	= "Y" //ADLOG Update
lu_dbmgr.is_data[10] = "SALES" //PGM_ID

lu_dbmgr.uf_prc_db_08()
//위 함수에서 이미 commit 한 상태임.
li_rc = lu_dbmgr.ii_rc
Destroy lu_dbmgr

CHOOSE CASE li_rc
	case -1, -3
		rollback;
		Return -1
	CASE -2
		rollback;
		f_msg_usr_err(9000, Title, "!!")
		Return -1
	case else
		commit;
		f_msg_info(3000, This.Title, "Save")		
		
      INSERT INTO DEPOSIT_LOG
         ( PAYSEQ       , PAY_TYPE           , PAYDT    , SHOPID    , OPERATOR ,
           CUSTOMERID   , CONTRACTSEQ        , ITEMCOD  , PAYMETHOD , REGCOD   ,
           PAYAMT       , BASECOD            , PAYCNT   , PAYID     , REMARK   ,
           TRDT         , MARK               , AUTO_CHK , APPROVALNO, CRTDT    ,
           CRT_USER     , DCTYPE             , MANUAL_YN, PGM_ID    , REMARK2  , ORDERNO )
      SELECT PAYSEQ     , 'I'                , PAYDT    , SHOPID    , OPERATOR ,
           CUSTOMERID   , nvl(CONTRACTSEQ, 0), ITEMCOD  , PAYMETHOD , REGCOD   ,
           PAYAMT       , BASECOD            , PAYCNT   , PAYID     , REMARK   ,
           TRDT         , MARK               , AUTO_CHK , APPROVALNO, SYSDATE  ,
           :gs_user_id  , DCTYPE             , MANUAL_YN, 'SALES'   , REMARK2  , ORDERNO
      FROM   DAILYPAYMENT
      WHERE  CUSTOMERID = :ls_customerid
      AND    PAYDT      = TO_DATE(:ls_paydt, 'YYYYMMDD')
      AND    ITEMCOD IN ( SELECT IN_ITEM 
                          FROM DEPOSIT_REFUND
                          UNION ALL
                          SELECT OUT_ITEM 
                          FROM DEPOSIT_REFUND
                          )
      AND	 PGM_ID = 'SALES';
		
		IF sqlca.sqlcode < 0 THEN
			ROLLBACK;
		ELSE
			COMMIT;
		END IF
END CHOOSE

dw_sale.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_sale.Reset()
dw_detail2.Reset()
dw_detail.Reset()

dw_cond.Object.memberid[1] 	= ''
dw_cond.Object.customerid[1] 	= ''
dw_cond.Object.customernm[1] 	= ''
dw_cond.Object.operator[1] 	= ''
dw_cond.Object.operatornm[1] 	= ''
dw_cond.Object.amt1[1] 			= 0
dw_cond.Object.amt2[1] 			= 0
dw_cond.Object.amt3[1] 			= 0
dw_cond.Object.amt4[1] 			= 0
dw_cond.Object.amt5[1] 			= 0
dw_cond.Object.amt6[1] 			= 0
dw_cond.Object.total[1] 		= 0
dw_cond.Object.credit[1] 		= 0

idc_deposit = 0
idc_total   = 0
idc_impack  = 0

F_INIT_DSP(1,"","")

//TriggerEvent("ue_reset")
Return 0 
end event

event ue_delete();call super::ue_delete;Int li_return

ii_error_chk = -1

This.Trigger Event ue_extra_delete(li_return)

If li_return < 0 Then
	Return
End if

wf_set_total()

IF il_get_row > 0 then
	idw.DeleteRow(il_get_row)
	idw.SetFocus()
End if

ii_error_chk = 0
end event

event close;call super::close;F_INIT_DSP(1,"","")
end event

type dw_cond from w_a_reg_m_m3_sams`dw_cond within ssrt_reg_adsale_sams1
integer y = 44
integer width = 3168
integer height = 560
integer taborder = 0
string dataobject = "ssrt_cnd_adsale_sams1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"


String ls_ref_desc
String ls_filter
INTEGER  li_exist
DataWindowChild ldwc
date	ldt_saledt


is_emp_grp		= ""
is_customerid	= ""
is_caldt 		= ""
is_userid 		= ""
is_pgm_id 		= ""


select emp_group 
  into :is_emp_grp
  from sysusr1t 
 where emp_id =  :gs_user_id ;
//
IF IsNull(is_emp_grp) then is_emp_grp = ''

IF is_emp_grp <> '' then
	select basecod 
	  INTO :is_basecod
	  FROM partnermst
	 WHERE basecod = :is_emp_grp    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(is_basecod) then is_basecod = '000000'
EnD IF

//
//ll_row = dw_list.Retrieve(is_caldt)
//dw_list.object.head.Text = String(is_caldt,'@@@@-@@-@@') 
//
//is_control = fs_get_control("PI", "A101", ls_ref_desc)
//
//IF IsNull(is_control) then is_control = '0'
//
//
//
//String ls_filter
//INTEGER  li_exist
//li_exist = dw_input.GetChild("partner_work", ldwc)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Partner")
//ls_filter = "partner = '" + is_control  + "' "
//ldwc.SetTransObject(SQLCA)
//li_exist =ldwc.Retrieve()
//ldwc.SetFilter(ls_filter)			//Filter정함
//ldwc.Filter()
//		
//If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Retrieve()")
//  Return 1
//End If  






//
dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.memberid[1] 	= dw_cond.iu_cust_help.is_data[4]
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String 	ls_customerid,		ls_customernm,		ls_memberid, 	&
		 	ls_operator,		ls_empnm,			ls_paydt,		&
			ls_paydt_1,			ls_sysdate,			ls_paydt_c
Integer	li_cnt
Date		ldt_paydt
DEC{2}	ldc_total,			ldc_90
LONG		ll_return

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select memberid, 		customernm
		  INTO :ls_memberid, :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_memberid) 	OR sqlca.sqlcode <> 0 	then ls_memberid 		= ""
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			
			return 1
			
		ELSE
			This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
		END IF
	Case "memberid"
		ls_memberid = trim(data)
		select customerid, 		customernm
		  INTO :ls_customerid,	:ls_customernm
		  FROM customerm
		 where memberid = :ls_memberid ;
		 
		 IF IsNull(ls_customerid) then ls_customerid = ""
		 IF IsNull(ls_customernm) then ls_customernm = ""
		 
		This.Object.customerid[1] =  ls_customerid
		This.Object.customernm[1] =  ls_customernm
		
	Case "paydt"
		ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)
		ls_paydt  = String(ldt_paydt, 'yyyymmdd')
		
		SELECT TO_CHAR(TO_DATE(TO_CHAR(:ldt_paydt, 'yyyymmdd'), 'YYYYMMDD') + 1, 'YYYYMMDD'),
				 TO_CHAR(SYSDATE, 'YYYYMMDD'),
				 REPLACE(:data, '-', '') 
		INTO   :ls_paydt_1, :ls_sysdate, :ls_paydt_c
		FROM   DUAL;
		
		IF ls_paydt_c > ls_paydt_1 OR ls_paydt_c < ls_paydt THEN
			dw_cond.object.paydt[row]	= ldt_paydt
			f_msg_usr_err(9000, Title, "Pay Date 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.SetColumn("paydt")
			RETURN 2
		END IF
		
	case 'operator'
		SELECT EMPNM INTO :ls_empnm
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm		

	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impack(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
			END IF			
		END IF		
		
		WF_SET_TOTAL()
End Choose

end event

event dw_cond::losefocus;call super::losefocus;this.Accepttext()
end event

event dw_cond::itemerror;call super::itemerror;return 1
end event

type p_ok from w_a_reg_m_m3_sams`p_ok within ssrt_reg_adsale_sams1
integer x = 3264
integer y = 36
end type

type p_close from w_a_reg_m_m3_sams`p_close within ssrt_reg_adsale_sams1
integer x = 3264
integer y = 144
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3_sams`gb_cond within ssrt_reg_adsale_sams1
integer width = 3214
integer height = 636
integer taborder = 0
end type

type dw_master from w_a_reg_m_m3_sams`dw_master within ssrt_reg_adsale_sams1
integer taborder = 0
end type

type dw_detail from w_a_reg_m_m3_sams`dw_detail within ssrt_reg_adsale_sams1
integer x = 425
integer y = 1716
integer width = 5385
integer height = 368
integer taborder = 30
boolean titlebar = true
string title = "[ Others ]"
string dataobject = "ssrt_reg_adsale_other_sams"
boolean border = false
end type

event dw_detail::itemchanged;call super::itemchanged;DEC{2} 				ldc_saleamt
Integer 				li_exist,	li_rc,	li_rc1
String				ls_filter,	ls_partner,		ls_priceplan,		ls_itemcod,		ls_customerid,	&
						ls_sql,		ls_svccod, 	ls_sql1
Long					ll_qty,		ll_cnt,			ll_deposit_cnt,	ll_dep_cnt,		ll_row, 	ll_row1
DataWindowChild 	ldc_priceplan, 	ldc_itemcod,	ldwc_contractseq, ldwc_orderno

THIS.Accepttext()

ls_partner    =  trim(dw_cond.Object.partner[1])
ls_customerid =  trim(dw_cond.Object.customerid[1])

choose case dwo.name
	Case "svccod"
			this.Object.priceplan[row] = ''
			this.Object.itemcod[row] = ''
			li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data  + &
				"'  And  partner = '" + ls_partner + "' " 

			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			
			//선택할수 있게
			This.object.priceplan.Protect = 0
	Case "priceplan"
			this.Object.itemcod[row] = ''
		
			li_exist 	= This.GetChild("itemcod", ldc_itemcod)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Item code")
			ls_filter = "priceplan = '" + data 	+ "' " 

			ldc_itemcod.SetTransObject(SQLCA)
			li_exist =ldc_itemcod.Retrieve()
			ldc_itemcod.SetFilter(ls_filter)			//Filter정함
			ldc_itemcod.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			//선택할수 있게
			This.object.priceplan.Protect = 0
	case 'itemcod'
		SELECT COUNT(*) INTO :ll_dep_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :data OR OUT_ITEM = :data );
		
		IF ll_dep_cnt > 0 THEN
			
			li_rc = THIS.GetChild("contractseq", ldwc_contractseq)
		
			IF li_rc = -1 THEN
				f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
				this.Object.itemcod[row] = ""
				RETURN 2
			END IF		
			
			ls_svccod = THIS.Object.svccod[row]
			
			ls_sql = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
			" FROM   CONTRACTMST A, PRICEPLANMST B " + &
			" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
			" AND    A.CUSTOMERID = '" + ls_customerid + "' " +&
			" AND    A.SVCCOD = '" + ls_svccod + "' " +&			
			" ORDER BY A.CONTRACTSEQ ASC "
			ldwc_contractseq.SetSqlselect(ls_sql)
			ldwc_contractseq.SetTransObject(SQLCA)
			ll_row = ldwc_contractseq.Retrieve()
	
			IF ll_row < 0 THEN 				//디비 오류 
				f_msg_usr_err(2100, Title, "CONTRACTSEQ Retrieve()")
				this.Object.itemcod[row] = ""				
				RETURN 2
			END IF
			
			//ORDERNO START
			li_rc1 = THIS.GetChild("orderno", ldwc_orderno)
		
			IF li_rc1 = -1 THEN
				f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
				this.Object.itemcod[row] = ""
				RETURN 2
			END IF	
			
			ls_sql1 = " SELECT A.ORDERNO, B.PRICEPLAN_DESC " + &
			" FROM   SVCORDER A, PRICEPLANMST B " + &
			" WHERE  A.PRICEPLAN = B.PRICEPLAN  " +&
			" AND    A.CUSTOMERID = '" + ls_customerid + "' " +&
			" AND    A.SVCCOD = '" + ls_svccod + "' " +&	
			" AND   A.ORDERNO IN (SELECT ORDERNO FROM CONTRACTDET) " +&
			" ORDER BY A.ORDERNO ASC "
			
			ldwc_orderno.SetSqlselect(ls_sql1)
			ldwc_orderno.SetTransObject(SQLCA)
			ll_row1 = ldwc_orderno.Retrieve()
	
			IF ll_row1 < 0 THEN 				//디비 오류 
				f_msg_usr_err(2100, Title, "ORDERNO Retrieve()")
				this.Object.itemcod[row] = ""				
				RETURN 2
			END IF
			//ORDERNO END
		END IF
		
		wf_read_other(data, row)
	
	case 'qty'
		ll_qty 		= this.Object.qty[row]
		ls_itemcod  = this.Object.itemcod[row]		
		IF ll_qty = 0 OR IsNull(ll_qty) then 
			f_msg_info(9000, PARENT.Title, '수량정보를 입력하세요.')
			this.Object.qty[row] = 1
			return 2
		END IF
	
		ldc_saleamt = this.Object.unitamt[row] * Integer(data)
		this.Object.sale_amt[row] = ldc_saleamt		

		//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[row] 	= Round(ldc_saleamt * 0.1, 2)
			THIS.Object.impack_not[row] 	= Round(ldc_saleamt - Round(ldc_saleamt * 0.1, 2), 2)
		ELSE
			dw_sale.Object.impack_card[row] 	= 0
			dw_sale.Object.impack_not[row] 	= DEC(data)
		END IF					
		
		wf_set_total()
		
	case 'sale_amt'
		ls_itemcod = this.Object.itemcod[row]
		//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[row] 	= Round(DEC(data) * 0.1, 2)
			THIS.Object.impack_not[row] 	= Round(DEC(data) - Round(DEC(data) * 0.1, 2), 2)
		ELSE
			dw_sale.Object.impack_card[row] 	= 0
			dw_sale.Object.impack_not[row] 	= DEC(data)
		END IF					
		
//		ls_priceplan	=	Trim(THIS.object.priceplan[row])
//		ls_itemcod		=	Trim(THIS.object.itemcod[row])
//		
//		SELECT COUNT(*) INTO :ll_cnt
//		FROM   DEPOSIT_REFUND
//		WHERE  IN_ITEM = :ls_itemcod;
//		
//		IF ll_cnt > 0 THEN
//			idc_deposit = idc_deposit + DEC(data)
//		END IF

		wf_set_total()
		post Event ue_insert()

	case else
end choose

end event

event dw_detail::getfocus;call super::getfocus;idw = this
is_colnm =  'svccod'

wf_set_total()

end event

event dw_detail::ue_key;call super::ue_key;If key = KeyENTER!  AND this.GetColumnName() = 'sale_amt' Then
	this.InsertRow(0)
	this.SetRow(this.RowCount() + 1)
	this.SetColumn(1)
End If

end event

event dw_detail::losefocus;call super::losefocus;il_get_row =  this.GetRow()
ACCEPTTEXT()
wf_set_total()

end event

event dw_detail::buttonclicked;call super::buttonclicked;Int 		li_i
String 	ls_type, ls_name
Window 	lw_help

	Choose Case dwo.name
		case 'b_rate'
			OpenWithParm(ssrt_exchange_rate_pop, iu_cust_msg)
/*		CASE 'b_ani'
			IF row =  0 then return
			iu_cust_help.idw_data[1] 	= this
			iu_cust_help.il_data[1] 	= row 

			If UpperBound( is_data ) = 0 Then
				iu_cust_help.is_data[1]='' 
			Else			
				iu_cust_help.is_data[] = is_data[]
			End If
			iu_cust_help.is_temp[] = is_temp[]	
			OpenwithParm(lw_help, iu_cust_help, is_help_win[1] )
			If this.iu_cust_help.ib_data[1] Then
				Object.remark[row] 		= iu_cust_help.is_data[1]
			End If   */
		CASE 'b_dacom'
			OpenWithParm(ssrt_dacom_pop, iu_cust_msg)
		case else
	end choose

Return 0
end event

event dw_detail::constructor;call super::constructor;DEC{2} 				ldc_saleamt
Integer 				li_exist
String				ls_filter
DataWindowChild 	ldc_priceplan, 	ldc_itemcod
//
li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then return 
ls_filter = "svccod = '" + 'SSRT'  + "'"

ldc_priceplan.SetTransObject(SQLCA)
li_exist =ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()
This.object.priceplan.Protect = 0

li_exist 	= This.GetChild("itemcod", ldc_itemcod)		//DDDW 구함
If li_exist = -1 Then return 
ls_filter 	= "priceplan = '" + 'P999'  + "' " 

ldc_itemcod.SetTransObject(SQLCA)
li_exist =ldc_itemcod.Retrieve()
ldc_itemcod.SetFilter(ls_filter)			//Filter정함
ldc_itemcod.Filter()
		
This.object.priceplan.Protect = 0

end event

event dw_detail::itemerror;call super::itemerror;return 1
end event

event dw_detail::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] 	= This.Object.b_ani
This.is_help_win[1] 		= "ssrt_anino_pop"
//This.is_help_win[2] 		= "ssrt_pinno_pop"
//This.is_help_win[3] 		= "ssrt_ani2no_pop"
This.is_data[1] 			= "CloseWithReturn"

////
end event

event dw_detail::doubleclicked;//Int 		li_i
//String 	ls_type, ls_name
//Window 	lw_help
//IF row =  0 then return
//
//iu_cust_help.il_data[1] = row  
//ls_name 						= dwo.Name
//
//For li_i = 1 To ii_help_col_no
//	If idwo_help_col[li_i].Name = ls_name Then
//		iu_cust_help.idw_data[1] = this
//
//		If UpperBound( is_data ) = 0 Then
//			iu_cust_help.is_data[1]='' 
//		Else			
//			iu_cust_help.is_data[] = is_data[]
//		End If
//	
//		iu_cust_help.is_temp[] = is_temp[]	
//		
//		OpenwithParm(lw_help, iu_cust_help, is_help_win[li_i]  )
//		Exit
//	End If
//Next
//	
//Choose Case dwo.name
//		Case "b_ani"
//			If this.iu_cust_help.ib_data[1] Then
//				Object.remark[row] 		= iu_cust_help.is_data[1]
//			End If
//End Choose
//Return 0 
//
end event

type p_insert from w_a_reg_m_m3_sams`p_insert within ssrt_reg_adsale_sams1
integer x = 55
integer y = 2092
end type

type p_delete from w_a_reg_m_m3_sams`p_delete within ssrt_reg_adsale_sams1
integer x = 347
integer y = 2092
end type

type p_save from w_a_reg_m_m3_sams`p_save within ssrt_reg_adsale_sams1
integer x = 645
integer y = 2092
end type

type p_reset from w_a_reg_m_m3_sams`p_reset within ssrt_reg_adsale_sams1
integer x = 946
integer y = 2092
end type

type dw_detail2 from w_a_reg_m_m3_sams`dw_detail2 within ssrt_reg_adsale_sams1
integer x = 174
integer y = 1196
integer width = 5641
integer height = 456
integer taborder = 20
boolean titlebar = true
string title = "[ Group ]"
string dataobject = "ssrt_reg_adsale_group_sams"
boolean border = false
end type

event dw_detail2::getfocus;call super::getfocus;idw = this
is_colnm =  'modelno'

wf_set_total()



end event

event dw_detail2::itemchanged;call super::itemchanged;dec{2} ldc_saleamt
String ls_modelnm, ls_modelno, ls_msg, ls_itemcod
long	ll_qty, ll_deposit_cnt, ll_amount

THIS.AcceptText()

choose case dwo.name
	case 'modelno'
		//모델명 read
		//[RQ-UBS-201407-06]의해 아래와 같이 수정 START by HMK
		//select MODELNM INTO :ls_modelnm   FROM ADMODEL
 		//WHERE MODELNO 	=  :DATA ;
		select  MODELNM INTO :ls_modelnm  FROM ADMODEL
		   WHERE MODELNO     =  :DATA
		     AND USE_YN = 'Y'
		     AND MODELNO IN ( SELECT MODELNO FROM AD_GROUPMST WHERE PARTNER = :gs_shopid);
		//[RQ-UBS-201407-06]의해 아래와 같이 수정 END by HMK

		 
 		IF IsNull(ls_modelnm) then ls_modelnm = ''

		IF sqlca.sqlcode <> 0 THEN
			ls_msg  = "Model 정보가 존재하지 않습니다. ~t~n Model No. 확인 후 다시 입력해 주시기 바랍니다."
			f_msg_info(9000, PARENT.Title, ls_msg)
			this.Object.modelno[row] = ""
			return 1
		END IF
		this.Object.modelNM[row] = LS_MODELNM
		
		IF wf_read_model(data, row) = 1 then
			this.Object.modelno[row] = ""
			return 1
		END IF
		//post Event ue_insert() [#8452] /* 김선주 막음. 불필요한 것으로 생각되어, 막음 */
	case 'qty'
		ll_qty     = this.Object.qty[row]	
		ls_modelno = this.Object.modelno[row]
		ls_itemcod = this.Object.itemcod[row]	
		
				
		
		IF ll_qty = 0  OR IsNull(ll_qty) = True then
			f_msg_info(9000, PARENT.Title, '수량정보를 입력하세요.')
			this.Object.qty[row] = 1			
			ldc_saleamt = this.Object.unitamt[row] * this.Object.qty[row] /* [#8652] 2014.08.07 김선주 Add */
		   this.Object.sale_amt[row] = ldc_saleamt /* [#8652] 2014.08.07 김선주 Add */			
			return 1
		END IF
		
		SELECT AMOUNT	INTO :ll_amount
		FROM   AD_GROUPMST
		WHERE  MODELNO = :ls_modelno
		AND    PARTNER = :gs_shopid;
		
		IF IsNull(ll_amount) THEN ll_amount = 0
		
		IF ll_qty > 0 THEN			//판매
			IF ll_amount <= 0 THEN
				f_msg_info(9000, PARENT.Title, '물품 재고수량을 확인하세요.')
				this.Object.qty[row] = 0				
				this.Object.sale_amt[row] = 0 /*[#8652] 2014.08.07 김선주 ADD */
				return 2				
			ELSE
				IF ll_qty > ll_amount THEN
					f_msg_info(9000, PARENT.Title, '물품 재고수량이 부족합니다.')
					this.Object.qty[row] = 0				
					this.Object.sale_amt[row] = 0 /*[#8652] 2014.08.07 김선주 ADD */
					return 2
				END IF					
			END IF
		END IF				
	
		
		ldc_saleamt = 0
		ldc_saleamt = this.Object.unitamt[row] * this.Object.qty[row]
		this.Object.sale_amt[row] = ldc_saleamt
		
		//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[row] 	= Round(ldc_saleamt * 0.1, 2)
			THIS.Object.impack_not[row] 	= Round(ldc_saleamt - Round(ldc_saleamt * 0.1, 2), 2)
		ELSE
			dw_sale.Object.impack_card[row] 	= 0
			dw_sale.Object.impack_not[row] 	= ldc_saleamt
		END IF						
		
		wf_set_total()
	case 'sale_amt'
		
		ls_itemcod = this.Object.itemcod[row]
		//DEPOSIT ITEM 이면 IMPACK_CARD 금액을 계산해놓기 위하여!!!
		SELECT COUNT(*) INTO :ll_deposit_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		IF ll_deposit_cnt <= 0 THEN
			THIS.Object.impack_card[row] 	= Round(DEC(data) * 0.1, 2)
			THIS.Object.impack_not[row] 	= Round(DEC(data) - (DEC(data) * 0.1), 2)
		ELSE
			dw_sale.Object.impack_card[row] 	= 0
			dw_sale.Object.impack_not[row] 	= DEC(data)
		END IF				
		
		wf_set_total()
	case else
end choose

//post Event ue_insert()
end event

event dw_detail2::ue_init;ib_delete = True
ib_insert = True
end event

event dw_detail2::itemfocuschanged;Long	ll_qty, ldc_saleamt
choose case dwo.name
	case 'sale_amount'
		post Event ue_insert()
	
	/* [#8652] 2014.08.07 김선주 From. Add*/
	case 'qty'
		ll_qty = this.Object.qty[row]
		
		If ll_qty = 0 Or IsNull(ll_qty) = True Then 
			f_msg_info(9000, PARENT.Title, '수량정보를 입력하세요!')
			this.Object.qty[row] = 1	
			ldc_saleamt = this.Object.unitamt[row] * this.Object.qty[row] 
		   this.Object.sale_amt[row] = ldc_saleamt 
		End if	
	/* [#8652] 2014.08.07 김선주 To. Add*/		
		
end choose
end event

event dw_detail2::ue_key;call super::ue_key;
If key = KeyENTER!  AND this.GetColumnName() = 'sale_amt' Then
	this.InsertRow(0)
	this.SetRow(this.RowCount() + 1)
	this.SetColumn(1)
End If



end event

event dw_detail2::losefocus;call super::losefocus;il_get_row =  this.GetRow()
ACCEPTTEXT()
wf_set_total()


end event

event dw_detail2::itemerror;call super::itemerror;return 1
end event

type st_horizontal2 from w_a_reg_m_m3_sams`st_horizontal2 within ssrt_reg_adsale_sams1
integer y = 1164
end type

type st_horizontal from w_a_reg_m_m3_sams`st_horizontal within ssrt_reg_adsale_sams1
integer x = 23
integer y = 1656
end type

type dw_sale from w_a_reg_m_m3_sams`dw_sale within ssrt_reg_adsale_sams1
integer x = 23
integer y = 640
integer width = 6377
integer height = 508
integer taborder = 10
boolean titlebar = true
string title = "[Single Item]"
string dataobject = "ssrt_reg_adsale_sams"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event dw_sale::itemchanged;call super::itemchanged;Dec{2} 	ldec_saleamt, ldec_total
DEC	 	ldec_adseq
String 	ls_modelno, 	ls_modelnm, 	ls_itemcod, 	ls_regcod,	 ls_adcust, &
		 	ls_status, 		ls_msg,			ls_partner,		ls_serialno
Long		ll_iseqno, 		ll_cnt,			ll_foundrow
Integer  li_rtn

AcceptText()
ls_partner =  Trim(dw_cond.Object.partner[1])

Choose Case dwo.name
	Case "contno"
		//1. ADMST의 MODELNO Read
		SELECT ADSEQ, 				trim(MODELNO), 		trim(itemcod),  trim(status), ISEQNO, 		Trim(serialno)
		  INTO :ldec_adseq, 		:ls_modelno, 			:ls_itemcod, 	 :ls_status,	:ll_iseqno, :ls_serialno
		  FROM ADMST
		 WHERE CONTNO 			= trim(:DATA)  
		   AND MV_PARTNER 	= :ls_partner ;
		
		IF sqlca.sqlcode <> 0 THEN
			ls_msg  = "재고 정보가 존재하지 않습니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
			f_msg_info(9000, PARENT.Title, ls_msg)
			this.Object.contno[row] 	= ""
			this.Object.modelno[row] 	= ""
			this.Object.modelnm[row] 	= ""
			this.Object.sale_amt[row] 	= 0
			this.Object.remark[row]	 	= ""
			this.Object.itemcod[row] 	= ""
			this.Object.itemnm[row] 	= ""
			this.Object.regcod[row] 	= ""
			this.Object.remark[row] 	= ""
			return 1
		END IF
		IF IsNULL(ls_status) then ls_status = ""
		CHOOSE CASE ls_status
			case 'MG100'
				ls_msg  = "이동 출고 중인 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			case 'RP100'
				ls_msg  = "Rental 중인 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			case 'SG100'
				ls_msg  = "이미 판매가 완료된 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			case 'DG100'
				ls_msg  = "DISPLAY 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			case else
				//Find
				ll_cnt 			= this.RowCount()
				
				IF row > 1 then
					//1 Before
					ll_foundrow = this.Find("contno = '" + data + "'", 1, row - 1)
					if ll_foundrow > 0 THEN
							ls_msg  = "이미 입력된 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
							f_msg_info(9000, PARENT.Title, ls_msg)
							this.Object.contno[row] = ""
							return 1
					END IF
					//2. After
					IF ll_cnt > row then
						ll_foundrow = this.Find("contno = '" + data + "'", row + 1, ll_cnt)
						if ll_foundrow > 0 THEN
							ls_msg  = "이미 입력된 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
							f_msg_info(9000, PARENT.Title, ls_msg)
							this.Object.contno[row] = ""
							return 1
						END IF
					END IF
				ELSEIF row = 1 and ll_cnt > 1 then
					ll_foundrow = this.Find("contno = '" + data + "'", 2, ll_cnt)
					if ll_foundrow > 0 THEN
							ls_msg  = "이미 입력된 상품입니다. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
							f_msg_info(9000, PARENT.Title, ls_msg)
							this.Object.contno[row] = ""
							return 1
					END IF
					
					
				end if
				
		      IF WF_READ_SALEAMT(ll_iseqno, ls_itemcod, row, ls_modelno, '0') = -1 then
					this.Object.contno[row] = ""
					return 1
				Else
					dw_sale.Object.remark[row] 	= ls_serialno
				END IF
		end choose
//	case 'remark'
		post Event ue_insert()
End Choose

end event

event dw_sale::ue_init();call super::ue_init;ib_delete = True
ib_insert = True
end event

event dw_sale::getfocus;idw = this
is_colnm =  'modelno'

wf_set_total()

end event

event dw_sale::losefocus;call super::losefocus;il_get_row =  this.GetRow()
ACCEPTTEXT()
wf_set_total()

end event

event dw_sale::itemerror;call super::itemerror;return 1
end event

type dw_itemlist from datawindow within ssrt_reg_adsale_sams1
boolean visible = false
integer x = 3424
integer y = 228
integer width = 2245
integer height = 452
integer taborder = 10
boolean bringtotop = true
boolean titlebar = true
string title = "none"
string dataobject = "ssrt_reg_adsale_sams_temp"
boolean border = false
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

