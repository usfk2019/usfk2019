$PBExportHeader$b1w_reg_quotainfo_pop_2_v20.srw
$PBExportComments$[kem] 서비스 신청시 장비/할부 등록
forward
global type b1w_reg_quotainfo_pop_2_v20 from w_a_reg_m
end type
type dw_detail2 from datawindow within b1w_reg_quotainfo_pop_2_v20
end type
end forward

global type b1w_reg_quotainfo_pop_2_v20 from w_a_reg_m
integer width = 3397
integer height = 2072
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
dw_detail2 dw_detail2
end type
global b1w_reg_quotainfo_pop_2_v20 b1w_reg_quotainfo_pop_2_v20

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt, is_act_gu, is_reg_partner
String is_priceplan,is_customerid, is_partner, is_svccod, is_itemcod[], is_main_itemcod, is_adtype
String is_contractseq, is_customernm
Long il_cnt, il_customer_hw, il_itemcodcnt
Boolean ib_order

end variables

forward prototypes
public function integer wfi_set_saleamt (string as_orderno, string as_priceplan, string as_customerid, long al_rowcount, string as_orderdt)
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wfi_get_hwseq (string as_serialno, long al_row)
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

b1u_dbmgr9_v20	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr9_v20

ls_where = "orderno = '" + is_orderno + "' And customerid = '" + is_customerid + "' "

//장비정보, 미수금정보 가져오기
lu_dbmgr.is_caller   = "b1w_reg_quotainfo_pop_2%inq"
lu_dbmgr.is_title    = Title
lu_dbmgr.is_data[1]  = is_customerid
//lu_dbmgr.is_data[2] = is_itemcod[1]
lu_dbmgr.is_data[3]  = is_orderno
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2
lu_dbmgr.uf_prc_db_01()
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

//Select count(*)
//Into :li_cnt
//From admst
//Where serialno = :as_serialno;
//
////Data Not Fount
//If li_cnt = 0 Then
// 	f_msg_usr_err(201, Title, "Serial No")
//	dw_cond.SetColumn("serialno")
//	Return - 1
//End If

//해당 정보 가져오기
Select adseq, 		adtype, 		mv_partner
  Into :ll_adseq, :ls_adtype, :is_partner
  From admst
 Where Contno = :as_serialno;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(ADMST)")
	Return  -1
End If

dw_detail2.object.adseq[al_row] = ll_adseq
dw_detail2.object.adtype[al_row] = ls_adtype

Return 0
end function

on b1w_reg_quotainfo_pop_2_v20.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
end on

on b1w_reg_quotainfo_pop_2_v20.destroy
call super::destroy
destroy(this.dw_detail2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_quotainfo_pop_2
	Desc	: 	서비스 신청시 장비할부 등록
	Ver.	:	1.0
	Date	: 	2004.05.20
	programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
Integer li_rc, li_cnt, li_row, i, ll_rowcount, li_rows, li_rowcnt, li_count
String  ls_ref_desc, ls_type, ls_name[], ls_reqnum_dw, ls_itemcod, ls_modelno, ls_modelnm
String  ls_status, ls_filter, ls_desc
Dec{6}  ldc_unitcharge, ldc_basicamt
b1u_dbmgr9_v20	lu_dbmgr
DataWindowChild ldc

is_act_gu = ""  	//신청/ 처리 구분
is_orderdt = ""
is_orderno = ""
is_priceplan = ""
is_customerid = ""
il_cnt = 0

//window 중앙에
f_center_window(b1w_reg_quotainfo_pop_2_v20)

//Data 받아오기
ib_order       = iu_cust_msg.ib_data[1]
is_orderno     = String(iu_cust_msg.il_data[1])
is_contractseq = String(iu_cust_msg.il_data[2])
is_customerid  = iu_cust_msg.is_data2[2]
is_pgmid       = iu_cust_msg.is_data2[3]
is_act_gu      = iu_cust_msg.is_data2[4]
is_customernm  = iu_cust_msg.is_data2[5]

dw_cond.object.customerid[1]  = is_customerid
dw_cond.object.customernm[1]  = is_customernm
dw_cond.object.orderno[1]     = is_orderno
dw_cond.object.contractseq[1] = is_contractseq

//priceplan, itemcod, itemnm, orderdt 가져오기
lu_dbmgr = Create b1u_dbmgr9_v20
lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop_2_v20%getdata"
lu_dbmgr.is_data[1] = is_orderno
lu_dbmgr.is_data[2] = is_customerid
lu_dbmgr.uf_prc_db_01()
If lu_dbmgr.ii_rc < 0 Then
	Destroy lu_dbmgr
	Return
Else
	//조건에 해당하는 data 가져오기
 	is_svccod      = lu_dbmgr.is_data[3]
	is_priceplan   = lu_dbmgr.is_data[4]
	is_orderdt     = lu_dbmgr.is_data[5]
	is_reg_partner = lu_dbmgr.is_data[8]
	
End If

dw_cond.object.svccod[1]      = is_svccod
dw_cond.object.priceplan[1]   = is_priceplan
dw_cond.object.vpricecod[1]   = lu_dbmgr.is_data[7]


dw_detail2.ReSet()
//main itemcod에 해당하는 장비모델
ll_rowcount = UpperBound(iu_cust_msg.is_data[])

For i = 1 To ll_rowcount
	is_itemcod[i] = iu_cust_msg.is_data[i]
	
	SELECT count(A.ITEMCOD)
	  INTO :li_rows
	  FROM ITEMMST A, ADMODEL_ITEM B
	 WHERE A.ITEMCOD = B.ITEMCOD
	   AND A.ITEMCOD  = :is_itemcod[i]
	   AND A.QUOTA_YN = 'Y';
		

	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Itemmst Select Error(ITEMCOD)")
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
		
	Else
		If li_rows > 0 Then
			li_rowcnt = dw_detail2.InsertRow(0)
			
			dw_detail2.object.itemcod[li_rowcnt] = is_itemcod[i]
			
			//장비모델 셋팅
			SELECT A.MODELNO
			     , A.MODELNM
			  INTO :ls_modelno
			     , :ls_modelnm
		     FROM ADMODEL A
			     , ADMODEL_ITEM B
		    WHERE A.MODELNO = B.MODELNO
			   AND B.ITEMCOD = :is_itemcod[i];
				
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, Title, "장비모델 Select Error")
				Return 0
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, Title, "서비스에 해당하는 장비모델이 없습니다.")
				Return 0
			Else
				dw_detail2.object.modelno[li_rowcnt] = ls_modelno
				dw_detail2.object.modelnm[li_rowcnt] = ls_modelnm
			End If
			li_count++
		End If
	End If
	ls_modelno = ""
	ls_modelnm = ""
		
Next

If li_count = 0 Then
	f_msg_info(9000, Title, "서비스에 해당하는 장비모델이 없습니다.")
	Return 0
End IF

If dw_detail2.RowCount() > 0 Then
	ls_status = fs_get_control("E1", "A100", ls_desc)
	
	ls_modelno = Trim(dw_detail2.object.modelno[1])

	li_row = dw_detail2.GetChild("serialno", ldc)		//DDDW 구함
	If li_row = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Serial No.")
	ls_filter = "modelno = '" + ls_modelno  + "' And status = '" + ls_status + "' "
	ldc.SetTransObject(SQLCA)
	li_row =ldc.Retrieve()
	ldc.SetFilter(ls_filter)			//Filter정함
	ldc.Filter()
End If

//해당 Item 금액 가져오기
li_rc = wfi_set_saleamt(is_orderno, is_priceplan, is_customerid, ll_rowcount, is_orderdt)
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "장비에 대한 판매금액이 올바르지 않습니다.")
   Return
End If

If ib_order = False Then 	//개통 상태(신청상태가 아니면) 수정 불가능
	Trigger Event ue_search()
	
Else
	If il_cnt = 0 Then    //신규이면
	   //상태 코드 가져오기
		ls_ref_desc =""
		is_status = fs_get_control("E1", "A101", ls_ref_desc)
		is_action = fs_get_control("E1", "A301", ls_ref_desc)

		dw_cond.object.cnt.Protect = 0
		dw_cond.Object.cnt.Background.Color = RGB(108, 147, 137)
		dw_cond.Object.cnt.Color = RGB(255, 255, 255)

		p_delete.TriggerEvent("ue_disable")
	Else
		Trigger Event ue_search()
	
   End If
End If


//Format 지정
ls_ref_desc = ""
ls_reqnum_dw = fs_get_control("B0", "P105", ls_ref_desc)
li_cnt = fi_cut_string(ls_reqnum_dw, ";", ls_name[])

Select currency_type
  Into :ls_type
  From priceplanmst
 Where priceplan = :is_priceplan;

If ls_name[1] = ls_type Then
	dw_cond.object.basicamt.Format 	= "#,##0.00"
	dw_cond.object.beforeamt.Format 	= "#,##0.00"
	dw_cond.object.deposit.Format 	= "#,##0.00"
	dw_cond.object.receamt.Format 	= "#,##0.00"
	dw_cond.object.saleamt.Format 	= "#,##0.00"
Else
	dw_cond.object.basicamt.Format 	= "#,##0.000000"
	dw_cond.object.beforeamt.Format 	= "#,##0.000000"
	dw_cond.object.deposit.Format 	= "#,##0.000000"
	dw_cond.object.receamt.Format 	= "#,##0.000000"
	dw_cond.object.saleamt.Format 	= "#,##0.000000"
End If

ls_ref_desc =""
is_status = fs_get_control("E1", "A101", ls_ref_desc)
is_action = fs_get_control("E1", "A301", ls_ref_desc)
is_adtype = fs_get_control("E1", "A601", ls_ref_desc)
	
dw_detail2.object.adtype[1] = is_adtype

Destroy lu_dbmgr



end event

event ue_ok();Dec{6} ldc_basicamt, ldc_saleamt, ldc_beforeamt, ldc_deposit, ldc_receamt
Long ll_row, ll_hwseq, ll_rows
Integer li_rc, li_cnt
Date ld_startdate
String ls_cnt, ls_where, ls_gubun
String ls_modelno, ls_serialno

dw_cond.AcceptText()

b1u_dbmgr9_v20	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr9_v20

//신규
li_cnt = dw_cond.object.cnt[1]
ls_cnt = String(li_cnt)

For ll_rows = 1 To dw_detail2.RowCount()
	ls_modelno = Trim(dw_detail2.object.modelno[ll_rows])
	ls_serialno = Trim(dw_detail2.object.serialno[ll_rows])

	If IsNull(ls_modelno) Then ls_modelno = ""
	If IsNull(ls_serialno) Then ls_serialno = ""

	//정보 다 입력
	If ls_modelno = "" Then
		f_msg_info(200, Title, "장비모델")
		dw_detail2.SetFocus()
		dw_detail2.ScrollToRow(ll_rows)
		dw_detail2.SetColumn("modelno")
		Return
	End If
	
	If ls_serialno = "" Then
		f_msg_info(200, Title, "Serial No")
		dw_detail2.SetFocus()
		dw_detail2.ScrollToRow(ll_rows)
		dw_detail2.SetColumn("serialno")
		Return
	End If
	
	//올바른 Serial No. 인지 확인
	If ls_serialno <> "" Then
		ll_hwseq = dw_detail2.object.adseq[ll_rows]
		If IsNull(ll_hwseq) Then
			f_msg_usr_err(201, Title, "Serial No")
			dw_detail2.SetFocus()
			dw_detail2.ScrollToRow(ll_rows)
			dw_detail2.SetColumn("serialno")
			Return
		End If
		
//		//장비SEQ chekc
//		SELECT adseq
//		  INTO :ll_ad
//		  FROM admst
//		 WHERE serialno = :ls_serialno;
//		 
//		If SQLCA.SQLCode < 0 Then
//			f_msg_usr_err(9000, Title, "admst select error')
//			Return
//		End If
//		If ll_hwseq <> ll_ad Then
//			dw_detail2.object.adseq[ll_rows] = ll_ad
//		End If
	End If
Next

If IsNull(ls_cnt) Then ls_cnt = ""

//장비 할부 개월수 필수
If ls_cnt = "" Then
	f_msg_info(200, Title, "할부개월수")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cnt")
	Return
End If

//금액 Check
ldc_basicamt  = dw_cond.object.basicamt[1]
ldc_beforeamt = dw_cond.object.beforeamt[1]
ldc_saleamt   = dw_cond.object.saleamt[1]
ldc_deposit   = dw_cond.object.deposit[1]
ls_gubun      = Trim(dw_cond.object.gubun[1])
ldc_receamt   = 0
	
If ls_gubun = "Y" Then
	ldc_receamt = ldc_beforeamt
	dw_cond.object.receamt[1] = ldc_receamt
		
	ldc_saleamt = (ldc_basicamt - ldc_beforeamt) + ldc_deposit
	If ldc_saleamt <> 0 Then
		dw_cond.object.saleamt[1] = ldc_saleamt
	End If
Else
	ldc_receamt = ldc_beforeamt + ldc_deposit
	dw_cond.object.receamt[1] = ldc_receamt
		
	ldc_saleamt = ldc_basicamt - ldc_beforeamt
	If ldc_saleamt <> 0 Then
		dw_cond.object.saleamt[1] = ldc_saleamt
	End If
End If

If li_cnt > 0 Then

	//할부 개월수 계산
	lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop_2_v20%insert"
	lu_dbmgr.is_title = Title
	lu_dbmgr.ii_data[1] = li_cnt
	//lu_dbmgr.id_data[1] = ld_startdate
	lu_dbmgr.is_data[1] = is_customerid
	lu_dbmgr.is_data[2] = is_main_itemcod
	lu_dbmgr.is_data[3] = is_orderno
	lu_dbmgr.is_data[4] = gs_user_id
	lu_dbmgr.is_data[5] = is_pgmid
	//lu_dbmgr.is_data[6] = ls_startdate
	lu_dbmgr.is_data[6] = is_contractseq
	lu_dbmgr.ic_data[1] = ldc_saleamt   //총판매금액
	lu_dbmgr.idw_data[1] = dw_detail
	
	lu_dbmgr.uf_prc_db_01()
	li_rc = lu_dbmgr.ii_rc
	
	If li_rc < 0 Then
		Destroy lu_dbmgr
		dw_cond.SetColumn("beforeamt")
		Return
	End If
End If

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = False
p_ok.TriggerEvent("ue_disable")
Destroy lu_dbmgr

Return 
end event

event type integer ue_extra_save();Long ll_row, i, ll_seq
Dec{2} lc_amt[], lc_totalamt
Dec lc_saleamt
Integer li_rc
String ls_itemcod
b1u_dbmgr9_v20	lu_dbmgr

//할부 계월수 정보 확인
ll_row = dw_detail.RowCount()
//If ll_row = 0 Then Return -1   //error  2003.11.21 김은미(일시불로직 추가로 제외시킴)
	
lc_saleamt = dw_cond.object.saleamt[1]

If ll_row > 0 Then
	For i =1 To ll_row
		lc_amt[i] = dw_detail.object.sale_amt[i]
		lc_totalamt += lc_amt[i]
	Next
ElseIf ll_row = 0 Then
	lc_totalamt = lc_saleamt
End If
	
//금액이 같지 않으면 저장안됨.
If lc_saleamt <> lc_totalamt Then
	f_msg_usr_err(9000, Title, "조정금액의 합이 총판매금액과 같지 않습니다.")
	dw_detail.SetFocus()
	dw_detail.SetColumn("sale_amt")
	Return -2
End If


//장비 정보 table insert
//If il_cnt = 0 Then
//장비 등록
lu_dbmgr = Create b1u_dbmgr9_v20
lu_dbmgr.is_caller   = "b1w_reg_quotainfo_pop_2_v20%hw_save"
lu_dbmgr.is_title    = Title
lu_dbmgr.is_data[1]  = is_customerid
lu_dbmgr.is_data[2]  = is_main_itemcod
lu_dbmgr.is_data[3]  = is_orderno
lu_dbmgr.is_data[4]  = gs_user_id
lu_dbmgr.is_data[5]  = is_pgmid
lu_dbmgr.is_data[6]  = is_status
lu_dbmgr.is_data[7]  = is_action
lu_dbmgr.is_data[8]  = is_reg_partner
lu_dbmgr.is_data[9]  = is_svccod
lu_dbmgr.is_data[10] = is_contractseq
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2
lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then		//Error   
	Destroy lu_dbmgr
	Return -2
End If
	
//Seqence
For i =1 To ll_row
	Select seq_quota.nextval
	Into :ll_seq
	From dual;
		
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Sequence Error")
		RollBack;
		Return -1 
	End If		
	dw_detail.object.quotaseq[i] = ll_seq
Next


For i = 1 To ll_row
	//개통 처리 까지
//	If is_act_gu = "Y" Then
//		dw_detail.object.contractseq[i] = il_contractseq
//	End If
	
   //UpdateLog
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
	End If
Next

Destroy lu_dbmgr
Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If
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
//Trigger Event ue_reset()

SetNull(ls_null)
dw_cond.object.cnt[1] = 1
dw_cond.Enabled = False
dw_detail2.Enabled = False
dw_detail.Enabled = False
dw_cond.object.saleamt[1] = 0
dw_cond.object.basicamt[1] = 0
dw_cond.object.beforeamt[1] = 0
dw_cond.object.deposit[1] = 0
dw_cond.object.receamt[1] = 0
For li_row = 1 To dw_detail2.RowCount()
	dw_detail2.object.serialno[li_row] = ls_null
	dw_detail2.object.adseq[li_row]    = 0
	dw_detail2.object.modelno[li_row]  = ls_null
Next
dw_cond.SetColumn("beforeamt")

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_disable")

Return 0
end event

event ue_delete;//Long li_chk, ll_row, i
//Integer li_rc
//li_chk =  f_msg_ques_yesno2(100, Title, "~r고객번호 : " + is_customerid + &
//										" 신청 개통 번호 : " + is_orderno, 2)
//
//
//If li_chk = 1 Then		//Yes
//	li_rc = wfi_del_quotainfo(is_orderno, is_customerid, is_itemcod)
//	If li_rc < 0 Then
//		f_msg_usr_err(9000, Title, is_orderno + ": 장비/할부 정보 삭제중 Error 발생")
//		Return -1
//	End If
//	il_cnt = 0				//Setting
//	
// 
//   dw_detail.Reset()
//	f_msg_info(3000,Title,"Delete")
//	dw_cond.Enabled = True			//다시 선택할 수 있도록 함.
//	p_ok.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_disable")
//	p_save.TriggerEvent("ue_disable")
//End If
//
//
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

//색깔 바꾸기
//dw_detail2.object.modelno.Background.Color = RGB(255, 255, 255)
//dw_detail2.object.modelno.Color = RGB(0, 0, 0)
//dw_detail2.object.serialno.Background.Color = RGB(255, 255, 255)
//dw_detail2.object.serialno.Color = RGB(0, 0, 0)
//dw_detail2.object.serialno.Protect = 1

dw_cond.object.cnt[1] = 0
dw_cond.Enabled = True
dw_cond.object.saleamt[1] = dw_cond.object.basicamt[1]
dw_cond.object.beforeamt[1] = 0
dw_cond.object.deposit[1] = 0
dw_cond.object.receamt[1] = 0
dw_detail2.object.serialno[1] = ls_null
dw_detail2.object.adseq[1] = 0
//dw_detail2.object.modelno[1] = ls_null
dw_cond.SetColumn("beforeamt")

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

Return 0
end event

event resize;call super::resize;
If newwidth < dw_detail2.X  Then
	dw_detail2.Width = 0
Else
	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
End If
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_quotainfo_pop_2_v20
integer x = 46
integer y = 40
integer width = 2962
integer height = 704
string dataobject = "b1dw_cnd_reg_quotainfo_pop_cl_v20"
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
	iu_cust_msg.is_grp_name = "할부등록"
	iu_cust_msg.is_data[1]  = is_orderno						//order number
	iu_cust_msg.is_data[2]  = is_priceplan                //priceplan
	iu_cust_msg.is_data[3]  = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	
	 
   OpenWithParm(b1w_inq_quota_item_popup, iu_cust_msg)
	
	Destroy iu_cust_msg
End If
end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_quotainfo_pop_2_v20
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_quotainfo_pop_2_v20
integer x = 3058
integer y = 180
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_quotainfo_pop_2_v20
integer width = 2994
integer height = 760
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_quotainfo_pop_2_v20
boolean visible = false
integer x = 1010
integer y = 1888
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_quotainfo_pop_2_v20
boolean visible = false
integer x = 709
integer y = 1888
end type

type p_save from w_a_reg_m`p_save within b1w_reg_quotainfo_pop_2_v20
integer x = 50
integer y = 1896
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_quotainfo_pop_2_v20
integer x = 23
integer y = 1124
integer width = 3342
integer height = 764
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

type p_reset from w_a_reg_m`p_reset within b1w_reg_quotainfo_pop_2_v20
integer x = 352
integer y = 1896
boolean enabled = true
end type

type dw_detail2 from datawindow within b1w_reg_quotainfo_pop_2_v20
integer x = 27
integer y = 768
integer width = 3337
integer height = 344
integer taborder = 11
string title = "none"
string dataobject = "b1dw_cnd_reg_quotainfo_pop_ad"
boolean vscrollbar = true
boolean livescroll = true
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

