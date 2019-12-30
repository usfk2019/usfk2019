$PBExportHeader$b1w_reg_directpay_pop_sams.srw
$PBExportComments$서비스 신청시 장비/할부 등록
forward
global type b1w_reg_directpay_pop_sams from w_a_reg_m
end type
type dw_detail2 from datawindow within b1w_reg_directpay_pop_sams
end type
end forward

global type b1w_reg_directpay_pop_sams from w_a_reg_m
integer width = 3397
integer height = 2104
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
dw_detail2 dw_detail2
end type
global b1w_reg_directpay_pop_sams b1w_reg_directpay_pop_sams

type variables
String 	is_orderno, is_pgmid, 	is_status, 		is_action, &
			is_orderdt, is_act_gu, 	is_reg_partner
String 	is_priceplan,				is_customerid, is_partner, &
			is_svccod, 					is_itemcod[], 	is_main_itemcod, &
			is_customernm, 			is_reqdt, &
			is_adtype,					is_memberid,	is_method[], &
			is_payid, is_trcod[],	is_amt_check, is_pgm_id
Long il_cnt, il_customer_hw, il_contractseq, il_itemcodcnt
DEC{2}	idc_amt[], idc_total, idc_receive, idc_change, idc_deposit, idc_impact
Boolean ib_order


end variables

forward prototypes
public function integer wf_set_impact (string as_data)
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wfi_get_hwseq (string as_serialno, long al_row)
public function integer wfi_set_saleamt (string as_orderno, string as_priceplan, string as_customerid, long al_rowcount, string as_orderdt)
public subroutine wf_set_total ()
end prototypes

event ue_search();//자료가 있으면 해당 자료 조회
String ls_where
Long ll_row
Integer li_rc
Dec{6}  ldc_basicamt, ldc_beforeamt, ldc_deposit, ldc_receamt, ldc_saleamt, ldc_totamt, ldc_amt

//조회만 가능 하게
dw_cond.Enabled = False
dw_detail.Enabled = False
dw_detail2.Enabled = False
p_ok.TriggerEvent("ue_disable")

b1u_dbmgr9	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr9

ls_where = "orderno = '" + is_orderno + "' And customerid = '" + is_customerid + "' "

//장비정보, 미수금정보 가져오기
lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop_2%inq"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_customerid
//lu_dbmgr.is_data[2] = is_itemcod[1]
lu_dbmgr.is_data[3] = is_orderno
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2
lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then
	Destroy lu_dbmgr
	Return
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//금액을 계산하여 할부포함 여부 셋팅
ldc_basicamt = dw_cond.object.basicamt[1]
ldc_saleamt  = dw_cond.object.saleamt[1]
ldc_beforeamt = dw_cond.object.beforeamt[1]
ldc_deposit  = dw_cond.object.deposit[1]

ldc_totamt   = ldc_basicamt + ldc_deposit
ldc_amt      = ldc_totamt - ldc_beforeamt


If ldc_deposit <> 0 Then
	If ldc_amt = ldc_saleamt Then   //할부포함인 경우
		dw_cond.object.gubun[1] = 'Y'
		dw_cond.object.receamt[1] = ldc_beforeamt
	Else    //할부포함이 아닐 경우
		dw_cond.object.gubun[1] = 'N'
		dw_cond.object.receamt[1] = ldc_beforeamt + ldc_deposit
	End If
End If



//수정 불가능
p_save.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

Destroy lu_dbmgr
Return
	
end event

public function integer wf_set_impact (string as_data);LONG		ll_row1
INT		ii
DEC{2}	ldc_impact1,		ldc_total,		ldc_impact,		ldc_impact_10

ll_row1 = dw_detail2.RowCount()

ldc_impact = DEC(as_data)										//카드 입력한 금액
ldc_impact_10 = ROUND(ldc_impact * 0.1, 2)				//카드 입력한 금액의 10%

IF ldc_impact = 0 THEN
	RETURN -1
END IF

idc_impact = 0

FOR ii = 1 TO ll_row1
	ldc_impact1 = dw_detail2.Object.impack_card[ii]	
	IF IsNull(ldc_impact1) THEN ldc_impact1 = 0
	idc_impact  = idc_impact + ldc_impact1	
NEXT

IF idc_impact > 0 THEN
	IF idc_impact < ldc_impact_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF
ELSE
	IF idc_impact > ldc_impact_10 THEN
		MessageBox("확인", "입력한 Impact Card 금액의 할인액이 더 큽니다.")
		RETURN -1
	END IF	
END IF

ldc_total = dw_cond.Object.total[1]

IF idc_impact <> 0 THEN
	dw_cond.Object.credit[1]	= ldc_total - ldc_impact_10
ELSE
	dw_cond.Object.credit[1]	= 0
END IF


RETURN 0


end function

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

dw_detail2.object.adseq[al_row] = ll_adseq
dw_detail2.object.adtype[al_row] = ls_adtype

Return 0
end function

public function integer wfi_set_saleamt (string as_orderno, string as_priceplan, string as_customerid, long al_rowcount, string as_orderdt);/*------------------------------------------------------------------------
	Name	:	wfi_set_saleamt
	Arg.	:	deciaml - ac_orderno
				string -	as_customerid
						 - as_priceplan
						 - as_itemcod[]
						 - as_orderdt
	Desc.	:	해당 장비에 대한 판매금액 Setting
	Retu.	:  -1  : error
				 0  : 성공
   date	: 	20031.10.22
-------------------------------------------------------------------------*/
Long   ll_rowcount, i, ll_cnt, j
String ls_itemcod
Dec{6} ldc_basicamt, ldc_unitcharge, ldc_saleamt


//기존의 자료가 있는지 확인
Select count(*)
Into :il_cnt
From quota_info
Where to_char(orderno) = :as_orderno and customerid = :as_customerid;


If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(QUOTA_INFO)")
	Return  -1
End If

If al_rowcount > 0 Then
	//해당 itemcod에 해당하는 판매금액 select
	For i = 1 To al_rowcount
		//신청일자 보다 작은것중에 가장 큰 날짜의 요금 가져옴
		SELECT A.UNITCHARGE
		  INTO :ldc_unitcharge
		  FROM PRICEPLAN_RATE2 A
		     , ADMODEL_ITEM B
		 WHERE A.PRICEPLAN = :as_priceplan
		   AND A.ITEMCOD   = :is_itemcod[i]
			AND A.ITEMCOD   = B.ITEMCOD
			AND TO_CHAR(A.fromdt, 'YYYYMMDD') = ( SELECT MAX(TO_CHAR(C.FROMDT, 'YYYYMMDD'))
															  FROM PRICEPLAN_RATE2 C
															     , ADMODEL_ITEM D
															 WHERE C.PRICEPLAN = :as_priceplan
															   AND C.ITEMCOD   = :is_itemcod[i]
																AND C.ITEMCOD   = D.ITEMCOD
																AND TO_CHAR(C.FROMDT,'YYYYMMDD') <= :as_orderdt);
				
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "판매금액 Select Error(PRICEPLAN)")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			
		Else
			ldc_basicamt = ldc_basicamt + ldc_unitcharge
		End If
	
	Next

	If ldc_basicamt <> 0 Then
		dw_cond.object.basicamt[1] = ldc_basicamt
		dw_cond.object.saleamt[1]  = ldc_basicamt
	End If
Else
	//Cursor 서비스신청시 할부품목 select
	DECLARE itemcod_c	CURSOR FOR
		SELECT con.itemcod
		  FROM contractdet con
		     , itemmst     itm
		 WHERE con.itemcod = itm.itemcod
		   AND to_char(con.orderno) = :as_orderno
			AND itm.quota_yn  = 'Y'
		 ORDER BY con.itemcod ;
		 
	OPEN itemcod_c;
		
	Do While(True)
		FETCH itemcod_c INTO :ls_itemcod;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "CURSOR itemcod_c errror")				
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
		End If
	
		If IsNull(ls_itemcod) Or ls_itemcod = "" Then
			f_msg_sql_err(Title, "할부품목 Select Error(CONTRACTDET)")
			Return -1
		Else
			j++
			is_itemcod[j] = ls_itemcod
		End If
	Loop
	
	Close itemcod_c;
	
	For i = 1 To j
		//신청일자 보다 작은것중에 가장 큰 날짜의 요금 가져옴
		SELECT A.UNITCHARGE
		  INTO :ldc_unitcharge
		  FROM PRICEPLAN_RATE2 A
		     , ADMODEL B
		 WHERE A.PRICEPLAN = :as_priceplan
		   AND A.ITEMCOD   = :is_itemcod[i]
			AND A.ITEMCOD   = B.ITEMCOD
			AND TO_CHAR(A.fromdt, 'YYYYMMDD') = ( SELECT MAX(TO_CHAR(C.FROMDT, 'YYYYMMDD'))
															  FROM PRICEPLAN_RATE2 C
															     , ADMODEL D
															 WHERE C.PRICEPLAN = :as_priceplan
															   AND C.ITEMCOD   = :is_itemcod[i]
																AND C.ITEMCOD   = D.ITEMCOD
																AND TO_CHAR(C.FROMDT,'YYYYMMDD') <= :as_orderdt);
				
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "판매금액 Select Error(PRICEPLAN)")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			
		Else
			ldc_basicamt = ldc_basicamt + ldc_unitcharge
		End If
	
	Next

	If ldc_basicamt <> 0 Then
		dw_cond.object.basicamt[1] = ldc_basicamt
		dw_cond.object.saleamt[1]  = ldc_basicamt
	End If
	
End If

//할부여서 기본값이 있을때
If il_cnt <> 0 Then
	Select Sum(sale_amt)
	Into :ldc_saleamt
	From quota_info
	where to_char(orderno) = :as_orderno and customerid = :as_customerid;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Select Error(QUOTA_INFO)")
		Return  -1
	End If
	
	dw_cond.object.saleamt[1] = ldc_saleamt

End If

Return 0
end function

public subroutine wf_set_total ();dec{2} ldc_TOTAL

ldc_total = 0
ldc_total= dw_cond.Object.total[1]

F_INIT_DSP(2, "", String(ldc_total))

return 
end subroutine

on b1w_reg_directpay_pop_sams.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
end on

on b1w_reg_directpay_pop_sams.destroy
call super::destroy
destroy(this.dw_detail2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_quotainfo_pop_2
	Desc	: 	서비스 신청시 장비즉시불 처리 
	Ver.	:	1.0
	Date	: 	2007.7.18
	programer : 1hera
-------------------------------------------------------------------------*/
//Integer i
String  ls_itemcod, ls_itemnm
datawindow ldw

is_amt_check = 'N'

F_INIT_DSP(1,"","")


dw_cond.Reset()
dw_cond.InsertRow(0)
//
Long	ll_row, ll, row, ll_cnt, ll_priority
String ls_ref_desc, ls_temp, ls_reqdt, ls_regcod, ls_customernm
DEC{2}	ldc_unitamt
date 		ldt_paydt

// 2019.04.24 Vat 처리를 위한 변수 추가 Modified by Han
DEC{2}	ld_vat_amt, ld_taxrate
string   ls_surtaxyn

is_act_gu 		= ""  	//신청/ 처리 구분
is_orderdt 		= ""
is_orderno 		= ""
is_priceplan 	= ""
is_customerid 	= ""
il_cnt = 0

//window 중앙에
f_center_window(this)

ldt_paydt = F_FIND_SHOP_CLOSEDT(GS_SHOPID)

//Data 받아오기
ib_order       = iu_cust_msg.ib_data[1]
is_orderno     = String(iu_cust_msg.il_data[1])
il_contractseq = iu_cust_msg.il_data[2]

//iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
//iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
//iu_cust_msg.is_data[3] 	= ls_memberid 					//member ID
//iu_cust_msg.is_data[4] 	= ls_reqdt 			//
//iu_cust_msg.is_data[5] 	= ls_priceplan 				//가격정책
//

is_customerid  = iu_cust_msg.is_data[1]
is_pgmid       = iu_cust_msg.is_data[2]
is_memberid  	= iu_cust_msg.is_data[3]
is_reqdt			= iu_cust_msg.is_data[4]
is_priceplan	= iu_cust_msg.is_data[5]
is_svccod		= iu_cust_msg.is_data[6]
is_pgm_id		= iu_cust_msg.is_pgm_id

select payid, customernm into :is_payid, :ls_customernm from customerm
 where customerid = :is_customerid ;
 

//is_act_gu      = iu_cust_msg.is_data2[4]
//PayMethod101, 102, 103, 104, 105, 107
//PayMethod 
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

dw_cond.object.method1[1] = is_method[1]
dw_cond.object.method2[1] = is_method[2]
dw_cond.object.method3[1] = is_method[3]
dw_cond.object.method4[1] = is_method[4]
dw_cond.object.method5[1] = is_method[5]
dw_cond.object.method6[1] = is_method[6]

dw_cond.object.paydt[1] 		= ldt_paydt

//trcode
ls_temp 			= fs_get_control("B5", "I102", ls_ref_desc)
fi_cut_string(ls_temp, ";", is_trcod[])

dw_cond.Object.trcod1[1] = is_trcod[1]
dw_cond.Object.trcod2[1] = is_trcod[2]
dw_cond.Object.trcod3[1] = is_trcod[3]
dw_cond.Object.trcod4[1] = is_trcod[4]
dw_cond.Object.trcod5[1] = is_trcod[5]
dw_cond.Object.trcod6[1] = is_trcod[6]

dw_cond.object.amt1[1] = 0
dw_cond.object.amt2[1] = 0
dw_cond.object.amt3[1] = 0
dw_cond.object.amt4[1] = 0
dw_cond.object.amt5[1] = 0
dw_cond.object.amt6[1] = 0

dw_cond.object.customerid[1] = is_customerid
dw_cond.object.customernm[1] = ls_customernm
dw_cond.object.orderno[1]    = is_orderno
dw_cond.object.priceplan[1]  = is_priceplan
dw_cond.object.svccod[1]  	= is_svccod

//itemcod, itemnm, unitamt read
String ls_chk, ls_onefee, ls_bil

ldw = iu_cust_msg.idw_data[1]
ll_row 			= ldw.RowCount()
idc_total 		= 0
idc_receive 	= 0
idc_change 		= 0
idc_deposit		= 0
FOR ll = 1 to ll_row
	ls_chk 		= Trim(ldw.object.chk[ll])
	ls_onefee 	= Trim(ldw.object.oneoffcharge_yn[ll])
	ls_bil 		= Trim(ldw.object.bilitem_yn[ll])
	ls_itemcod 	= Trim(ldw.object.itemcod[ll])
	ls_itemnm 	= Trim(ldw.object.itemnm[ll])
	
	
	//if isnull(ls_itemnm) or ls_itemnm = '' then
//		select itemnm into :ls_itemnm
// 2019.04.24 surtaxyn 추가
		SELECT itemnm    , DECODE(surtaxyn,'N','*',' '), FNC_GET_TAXRATE(:is_customerid, 'I', :ls_itemcod, :ldt_paydt)
		  INTO :ls_itemnm, :ls_surtaxyn                , :ld_taxrate
		  FROM itemmst
		 WHERE itemcod = :ls_itemcod;
		
		If SQLCA.SQLCode < 0 Then
					f_msg_info(9000, Title, "item name Select Error")
					Return 0
		end if

	//end if
	
	//select FNC_GET_TAXRATE(:is_customerid, 'I', :ls_itemcod, :ldt_paydt) into  :ld_taxrate from dual;
	
	ll_priority = ldw.object.itemmst_priority[ll]
	//IF ls_chk = "Y" AND ls_onefee = "Y" AND ls_bil ="N" THEN
	IF (ls_chk = "Y" or ls_chk = "M") AND ls_onefee = "Y" AND ls_bil ="N" THEN
	   if ls_chk = 'Y' then
// 2019.04.24 VAT 계산 추가 Modified by Han
				SELECT NVL(unitcharge,0)  , TRUNC(NVL(unitcharge,0) * :ld_taxrate / 100, 2)
				  INTO :ldc_unitamt, :ld_vat_amt
				  FROM priceplan_rate2
				 WHERE priceplan                   = :is_priceplan
				   AND itemcod                     = :ls_itemcod
				   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
																  FROM priceplan_rate2
																 WHERE priceplan = :is_priceplan
																	AND itemcod	  = :ls_itemcod
																	AND to_char(fromdt, 'yyyymmdd') <= :is_reqdt ) ;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_info(9000, Title, "priceplan_rate2 Select Error")
					Return 0
				ElseIf SQLCA.SQLCode = 100 Then
					f_msg_info(9000, Title, "서비스에 해당하는 가격이 없습니다.")
					Return 0
				End If
		elseif ls_chk = 'M' then
				  ldc_unitamt = ldw.object.sale_amt[ll]
		end if
		
		SELECT COUNT(*) INTO :ll_cnt
		FROM   DEPOSIT_REFUND
		WHERE ( IN_ITEM = :ls_itemcod OR OUT_ITEM = :ls_itemcod );
		
		IF ll_cnt > 0 THEN
			idc_deposit = idc_deposit + ldc_unitamt
		END IF

		If IsNull(ldc_unitamt) then ldc_unitamt = 0
//		IF ldc_unitamt > 0 then
			row = dw_detail2.InsertRow(0)
			dw_detail2.Object.itemcod[row] 	= ls_itemcod
			dw_detail2.Object.contno[row] 	= ""
			dw_detail2.Object.modelno[row] 	= ""
			dw_detail2.Object.remark[row] 	= ""
			dw_detail2.Object.qty[row] 	= 1
			dw_detail2.Object.itemnm[row] 	= ls_itemnm
			dw_detail2.Object.sale_amt[row] 	= ldc_unitamt
			dw_detail2.Object.paycnt[row] 	= 1
			dw_detail2.Object.priority[row] 	= ll_priority

// 2019.04.24 추가된 Column Value Setting. Modified by Han
			dw_detail2.Object.vat_amt [row]  = ld_vat_amt
			dw_detail2.Object.surtaxyn[row]  = ls_surtaxyn
			
			IF ll_cnt <= 0 THEN    // DEPOSIT 항목임
				dw_detail2.Object.impack_card[row] 	= Round(ldc_unitamt * 0.1, 2)
				dw_detail2.Object.impack_not[row] 	= Round(ldc_unitamt - Round(ldc_unitamt * 0.1, 2), 2)
				dw_detail2.Object.impack_check[row]	= 'A' 			//정렬시키기 위하여!
			ELSE
				dw_detail2.Object.impack_card[row] 	= 0
				dw_detail2.Object.impack_not[row] 	= ldc_unitamt		
				dw_detail2.Object.impack_check[row]	= 'B'
			END IF

// 2019.04.24 Vat금액 Add. Modified by Han
			idc_total += ldc_unitamt + ld_vat_amt
			
			select regcod into :ls_regcod from itemmst
			 where itemcod = :ls_itemcod ;
			 
			If IsNull(ls_regcod) then ls_regcod = ""
			dw_detail2.Object.regcod[row] 	= ls_regcod
			
//		END IF
	END IF
	
NEXT
//IF idc_total > 0 then
	dw_cond.Object.TOTAL[1] = idc_total
//END IF




end event

event ue_extra_save;Long 		ll_row, i, ll_seq, ll_det_row
Dec{2} 	lc_amt[], lc_totalamt,	ldc_impack, ldc_card
Dec 		lc_saleamt
Integer 	li_rc, li_rtn
String 	ls_itemcod,			ls_paydt,		ls_customerid, ls_memberid, &
			ls_shop_closedt,	ls_operator,	ls_orderno,		ls_contno,		ls_quota_yn
date		ldt_shop_closedt


dw_cond.AcceptText()

b1u_dbmgr_dailypayment	lu_dbmgr

ls_customerid 	= trim(dw_cond.Object.customerid[1])
idc_total 		= dw_cond.Object.total[1]
idc_receive 	= dw_cond.Object.cp_receive[1]
idc_change 		= dw_cond.Object.cp_change[1]
ldc_impack		= dw_cond.Object.amt5[1]
ls_shop_closedt = String(f_find_shop_closedt(gs_shopid), 'yyyymmdd')
ls_operator    = trim(dw_cond.Object.operator[1])
ls_orderno     = dw_cond.Object.orderno[1]
ls_paydt			= String(dw_cond.Object.paydt[1], 'yyyymmdd')

select memberid into :ls_memberid from customerm
 where customerid  = :ls_customerid ;
 
IF IsNull(ls_memberid)  THEN ls_memberid = ""
IF IsNull(ls_operator)	THEN ls_operator = ""

IF ls_operator = "" then
	f_msg_usr_err(9000, Title, "Operator를 입력하세요")
	dw_cond.SetFocus()
	dw_cond.SetColumn("operator")
	Return -2	
END IF

IF idc_total > idc_receive then
	f_msg_usr_err(9000, Title, "입금액이 부족합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("amt1")
	Return -2	
END IF
//==========================================================
// 입금액이 sale금액보다 크거나 같으면.... 처리
//==========================================================
// 단 카드 입금액이 총판매금액보다 크면 처리 못함.
DEC{2}	ldc_total,	ldc_card_total
ldc_total 		= 	dw_cond.Object.total[1]
ldc_card_total = 	dw_cond.Object.amt2[1] + &
						dw_cond.Object.amt3[1] + &
						dw_cond.Object.amt4[1] + &
						dw_cond.Object.amt5[1]
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

//li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
//li_rtn = 1  mkhan  20181019
li_rtn = 1

F_INIT_DSP(3, String(idc_receive), String(idc_change))

//2009.06.10 추가
IF ldc_impack <> 0 THEN
	Dec{2} 	ldc_90
	ldc_90   = dw_cond.Object.credit[1]
	ldc_card = dw_cond.Object.amt3[1]
	dw_cond.Object.amt5[1] = idc_total - ldc_90
	dw_cond.Object.amt3[1] = ldc_card + (ldc_impack - (idc_total - ldc_90))
END IF

//2009.06.10 제거
//10%는 Impact 90%는 Credit card 로 분할 처리

//ldc_100 =  dw_cond.Object.amt5[1]
//If IsNull(ldc_100) then ldc_100 = 0
//IF ldc_100 <> 0 then
//	ldc_10 						= Round(ldc_100 * 0.1, 2)
//	ldc_90 						= ldc_100 - ldc_10
//	ldc_card = dw_cond.Object.amt3[1]
//	If IsNull(ldc_card) then ldc_card = 0
//	dw_cond.Object.amt5[1]	= ldc_10
//	dw_cond.Object.amt3[1]	= ldc_card + ldc_90
//END IF
//2009.06.10 제거
dw_cond.Accepttext()

//저장
lu_dbmgr = Create b1u_dbmgr_dailypayment
lu_dbmgr.is_caller 	= "direct"
lu_dbmgr.is_title 	= Title
lu_dbmgr.idw_data[1] = dw_cond //조건
lu_dbmgr.idw_data[2] = dw_detail2//item 정보

lu_dbmgr.is_data[1] 	= ls_customerid
lu_dbmgr.is_data[2] 	= ls_shop_closedt //paydt(shop별 마감일 )
lu_dbmgr.is_data[3] 	= GS_SHOPID //shopid
lu_dbmgr.is_data[4] 	= ls_operator //Operator

IF li_rtn = 1 THEN 
	lu_dbmgr.is_data[5] 	= "Y"
ELSE
	lu_dbmgr.is_data[5] 	= "N"
END IF

lu_dbmgr.is_data[6] 	= "DIRECT"
lu_dbmgr.is_data[7] 	= "N" //ADMST Update 여부
lu_dbmgr.is_data[8] 	= ls_memberid //
lu_dbmgr.is_data[9] 	= "N"  //ls_adlog_yn
lu_dbmgr.is_data[10] = "DIRECT" //PGM_ID


lu_dbmgr.uf_prc_db_09()
//위 함수에서 이미 commit 한 상태임.
li_rc = lu_dbmgr.ii_rc
Destroy lu_dbmgr

If li_rc = -1 Or li_rc = -3 Then
	Return -1
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "!!")
	Return -1
End If

ll_det_row = dw_detail2.RowCount() 

FOR i = 1 TO ll_det_row
	ls_itemcod = dw_detail2.Object.itemcod[i]
	
	SELECT NVL(QUOTA_YN, 'N') INTO :ls_quota_yn
	FROM   ITEMMST
	WHERE  ITEMCOD = :ls_itemcod;
	
	IF ls_quota_yn = 'Y' OR ls_quota_yn = 'R' THEN
		SELECT CONTNO INTO :ls_contno
		FROM   ADMST
		WHERE  CUSTOMERID = :ls_customerid
		AND    ORDERNO = TO_NUMBER(:ls_orderno)
		AND    ITEMCOD = :ls_itemcod;
		
		UPDATE DAILYPAYMENT
		SET    REMARK = :ls_contno
		WHERE  CUSTOMERID = :ls_customerid
		AND    PAYDT      = TO_DATE(:ls_paydt, 'YYYYMMDD')
		AND    ORDERNO    = TO_NUMBER(:ls_orderno) 
		AND    ITEMCOD    = :ls_itemcod;
		
		IF sqlca.sqlcode < 0 THEN
			ROLLBACK;
			f_msg_usr_err(9000, Title, "update Error( DAILYPAYMENT )")
			RETURN -1
		END IF
	END IF
NEXT			

IF idc_deposit > 0 THEN
	INSERT INTO DEPOSIT_LOG
		( PAYSEQ, PAY_TYPE, PAYDT, SHOPID, OPERATOR,
		  CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
		  PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
		  TRDT, MARK, AUTO_CHK, APPROVALNO, CRTDT,
		  CRT_USER, DCTYPE, MANUAL_YN, PGM_ID, REMARK2,
		  ORDERNO )
	SELECT PAYSEQ, 'I', PAYDT, SHOPID, OPERATOR,
			 CUSTOMERID, 0, ITEMCOD, PAYMETHOD, REGCOD, // 2012.6.14 null -> 0으로 변경
			 PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
			 TRDT, MARK, AUTO_CHK, APPROVALNO, SYSDATE,
			 :gs_user_id, DCTYPE, MANUAL_YN, :gs_pgm_id[gi_open_win_no], REMARK2,
			 ORDERNO
	FROM   DAILYPAYMENT
	WHERE  CUSTOMERID = :ls_customerid
	AND    PAYDT      = TO_DATE(:ls_paydt, 'YYYYMMDD')
	AND    ORDERNO    = TO_NUMBER(:ls_orderno)
	AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND );
	
	IF sqlca.sqlcode < 0 THEN
		ROLLBACK;
		f_msg_usr_err(9000, Title, "Insert Error( DEPOSIT_LOG )")
		RETURN -1
	END IF	
END IF	

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

//If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If

li_return = Trigger Event ue_extra_save()
If li_return = -2  Then
	dw_detail.SetFocus()
	Return LI_ERROR
ElseIf li_return = -3 Then
	
	Trigger Event ue_reset()
	Return LI_ERROR
End If

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
		//COMMIT와 동일한 기능
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()
	
		If iu_cust_db_app.ii_rc = -1 Then
			dw_detail.SetFocus()
			Return LI_ERROR
		End If

	End If

f_msg_info(3000,This.Title,"Save")
F_INIT_DSP(1,"","")

//Trigger Event ue_reset()

dw_cond.SetColumn("amt1")

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_disable")

is_amt_check = 'Y'

Return 0
end event

event ue_reset;Constant Int LI_ERROR = -1
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
//dw_detail.Reset()

//색깔 바꾸기
//dw_detail2.object.modelno.Background.Color = RGB(255, 255, 255)
//dw_detail2.object.modelno.Color = RGB(0, 0, 0)
//dw_detail2.object.serialno.Background.Color = RGB(255, 255, 255)
//dw_detail2.object.serialno.Color = RGB(0, 0, 0)
//dw_detail2.object.serialno.Protect = 1

//dw_cond.object.cnt[1] = 0
dw_cond.Enabled = True
//dw_cond.object.saleamt[1] = dw_cond.object.basicamt[1]
//dw_cond.object.beforeamt[1] = 0
//dw_cond.object.deposit[1] = 0
//dw_cond.object.receamt[1] = 0
//dw_detail2.object.serialno[1] = ls_null
//dw_detail2.object.adseq[1] = 0
//dw_detail2.object.modelno[1] = ls_null
dw_cond.object.amt1[1]	 = 0
dw_cond.object.amt2[1]	 = 0
dw_cond.object.amt3[1]	 = 0
dw_cond.object.amt4[1]	 = 0
dw_cond.object.amt5[1]	 = 0
dw_cond.object.amt6[1]	 = 0
dw_cond.object.credit[1] = 0


//dw_cond.SetColumn("beforeamt")

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_enable")
dw_cond.SetFocus()
dw_cond.SetColumn("amt1")

Return 0
end event

event resize;call super::resize;
If newwidth < dw_detail2.X  Then
	dw_detail2.Width = 0
Else
	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
End If
end event

event ue_close();F_INIT_DSP(1,"","")

iu_cust_msg.ib_data[1] = TRUE
iu_cust_msg.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

//Destroy iu_cust_msg

Close( This )

end event

event close;INT li_i

F_INIT_DSP(1,"","")

iu_cust_msg.ib_data[1] = TRUE
iu_cust_msg.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

//메세지 넘기기 전에 에러나서...

//프로그램 관리 Queue에 저장 & 저장할 Index를 결정
For li_i = 1 To gi_max_win_no
	If gs_pgm_id[li_i] = is_pgm_id Then
		gs_pgm_id[li_i] = ""
		Exit
	End If
Next

Destroy iu_cust_db_app

//열린 윈도우 갯수 감소
gi_open_win_no --

//Destroy iu_cust_msg

If gi_open_win_no < 1 Then
	w_mdi_main.st_resize.Show()
	w_mdi_main.tv_menu.Show()
	m_mdi_main.ib_visible = True
End If	

Destroy(iu_cust_w_resize)


end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_directpay_pop_sams
integer x = 46
integer y = 40
integer width = 2981
integer height = 536
string dataobject = "b1dw_cnd_reg_directpay_pop_sams"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::losefocus;call super::losefocus;this.AcceptText()
end event

event dw_cond::itemchanged;call super::itemchanged;STRING	ls_paydt_1, ls_sysdate, ls_empnm, ls_paydt, ls_paydt_c
DEC{2}	ldc_total, ldc_receive, ldc_change, ldc_90
DATE		ldt_paydt
LONG		ll_return

dw_cond.AcceptText()

choose case dwo.name
	CASE "amt1", "amt2", "amt3", "amt4", "amt5", "amt6"
		IF dwo.Name = "amt5" THEN
			ll_return = wf_set_impact(data)
			IF ll_return < 0 THEN
				THIS.Object.amt5[row] 	= 0
				THIS.Object.credit[row] = 0				
				RETURN 2
			END IF			
		END IF
		
		WF_SET_TOTAL()
		
	CASE "paydt"
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
	CASE "operator"
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
		
end choose

//
//ldc_total = this.Object.total[1]
//ldc_receive = this.Object.cp_receive[1]
//ldc_total = this.Object.cp_change[1]
//
//
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_directpay_pop_sams
boolean visible = false
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_directpay_pop_sams
integer x = 3058
integer y = 180
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_directpay_pop_sams
integer width = 3013
integer height = 580
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_directpay_pop_sams
boolean visible = false
integer x = 1010
integer y = 1884
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_directpay_pop_sams
boolean visible = false
integer x = 709
integer y = 1884
end type

type p_save from w_a_reg_m`p_save within b1w_reg_directpay_pop_sams
integer x = 50
integer y = 1884
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_directpay_pop_sams
boolean visible = false
integer x = 23
integer y = 1828
integer width = 3013
integer height = 52
boolean enabled = false
string dataobject = "b1dw_reg_quotainfo_pop1_cl"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;//Setting
Long ll_row, i
ll_row = dw_detail.RowCount()
//임대여서 자료 없을때
If ll_row = 0 Then 
	dw_cond.object.cnt[1] = 1
	Return 0
End If

dw_cond.object.cnt[1] = ll_row
For i = 1 To ll_row
	dw_detail.object.amt[i] = dw_detail.object.sale_amt[i]
Next
If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_directpay_pop_sams
integer x = 352
integer y = 1884
boolean enabled = true
end type

type dw_detail2 from datawindow within b1w_reg_directpay_pop_sams
integer x = 37
integer y = 592
integer width = 3003
integer height = 1228
integer taborder = 11
string title = "none"
string dataobject = "b1dw_reg_directitem_pop_sams"
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event itemchanged;DataWindowChild ldc_child, ldc
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

event itemfocuschanged;String ls_status, ls_desc, ls_filter, ls_modelno
Integer li_exist
DataWindowChild ldc_child

If dwo.name = "serialno" Then
	//장비재고상태코드
	ls_status = fs_get_control("E1", "A100", ls_desc)
	
	This.object.serialno[row] = ''
	ls_modelno = Trim(This.object.modelno[row])
	
	li_exist = dw_detail2.GetChild("serialno", ldc_child)		//DDDW 구함
	If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Serial No.")
	
	If IsNull(ls_modelno) Or ls_modelno = "" Then
		ls_filter = ""
	Else
		ls_filter = "modelno = '" + ls_modelno  + "' And status = '" + ls_status + "' "
	End If
	ldc_child.SetTransObject(SQLCA)
	li_exist =ldc_child.Retrieve()
	ldc_child.SetFilter(ls_filter)			//Filter정함
	ldc_child.Filter()
End If
end event

