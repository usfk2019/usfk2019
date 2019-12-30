$PBExportHeader$b1w_reg_admst_pop_new.srw
$PBExportComments$[kem] 서비스 신청시 장비임대 등록
forward
global type b1w_reg_admst_pop_new from w_a_reg_m
end type
end forward

global type b1w_reg_admst_pop_new from w_a_reg_m
integer width = 3397
integer height = 1412
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
end type
global b1w_reg_admst_pop_new b1w_reg_admst_pop_new

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt, is_act_gu, is_reg_partner
String is_priceplan,is_customerid, is_partner, is_svccod, is_itemcod[], is_main_itemcod, &
       is_adtype, is_customernm, is_contractseq, is_save_chk
Long il_cnt, il_customer_hw, il_itemcodcnt
Boolean ib_order

end variables

forward prototypes
public function integer wfi_get_hwseq (string as_serialno, long al_row)
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wf_read_item (string wfs_itemcod, long wfl_row)
public function integer wf_read_contno (string wfs_contno, long wfl_row)
end prototypes

event ue_search();//자료가 있으면 해당 자료 조회
String ls_where
Long ll_row, i
Integer li_rc
Dec{6}  ldc_basicamt, ldc_beforeamt, ldc_deposit, ldc_receamt, ldc_saleamt, ldc_totamt, ldc_amt

//조회만 가능 하게
dw_cond.Enabled = False
dw_detail.Enabled = False

b1u_dbmgr9_v20	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr9_v20

ls_where = "orderno = '" + is_orderno + "' And customerid = '" + is_customerid + "' "

//장비정보 가져오기
lu_dbmgr.is_caller   = "b1w_reg_rental_pop_v20%inq"
lu_dbmgr.is_title    = Title
lu_dbmgr.is_data[1]  = is_customerid
//lu_dbmgr.is_data[2] = is_itemcod[1]
lu_dbmgr.is_data[3]  = is_orderno
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then
	Destroy lu_dbmgr
	Return
End If

For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next 

//수정 불가능
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

Destroy lu_dbmgr
Return
	
end event

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

public function integer wf_read_item (string wfs_itemcod, long wfl_row);/*------------------------------------------------------------------------	
	Desc.	: 	장비 contno
	Arg	:	String ls_contno
	Ret.	:	0 		Seccess
				-1 	Error
	Ver.	: 	1.0
---------------------------------------------------------------------------*/
Integer 	li_cnt,	i
Long 		ll_adseq, ll_old_adseq = 0, 	ll_iseqno, ll_same_chk = 0
String 	ls_adtype, ls_contno, ls_serialno,	ls_pid
String 	ls_modelno, ls_modelnm, ls_status, ls_status2, &
			ls_itemcod, ls_saledt,	ls_desc
String	ls_contno_row1, ls_contno_row2, ls_contno_row3, ls_itemcod_row, ls_contno_row		
DEC{2}	ldc_saleamt

ls_itemcod = wfs_itemcod

//장비모델 셋팅
SELECT  A.MODELNO, A.MODELNM
INTO    :ls_modelno, :ls_modelnm
FROM    ADMODEL A, ADMODEL_ITEM B
WHERE   A.MODELNO = B.MODELNO
AND     B.ITEMCOD = :ls_itemcod;
				
If SQLCA.SQLCode < 0 Then
	f_msg_info(9000, Title, "장비모델 Select Error")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	f_msg_info(9000, Title, "서비스에 해당하는 장비모델이 없습니다.")
	Return -1
Else
	dw_detail.object.modelno[wfl_row] = ls_modelno
	dw_detail.object.modelnm[wfl_row] = ls_modelnm
End If

//ls_contno = wfs_contno
ls_saledt = String(fdt_get_dbserver_now(), 'yyyymmdd')
//ls_status = fs_get_control("E1", "A100", ls_desc)
//2010.05.19 CJH 수정. Moving Goods 빼고 Returning Goods를 넣음...
ls_status = fs_get_control("E1", "A102", ls_desc)
ls_status2= fs_get_control("E1", "A104", ls_desc)

ll_same_chk = 0

ls_contno_row1 = 'X1'
ls_contno_row2 = 'X2'
ls_contno_row3 = 'X3'

FOR i = 1 TO dw_detail.RowCount()
	ls_itemcod_row	= dw_detail.Object.itemcod[i]
	ls_contno_row	= dw_detail.Object.contno[i]
	
	IF IsNull(ls_itemcod_row) THEN ls_itemcod_row = ""
	IF IsNull(ls_contno_row)  THEN ls_contno_row  = ""	
	
	IF i <> wfl_row THEN
		IF ls_itemcod_row = wfs_itemcod THEN
			IF ll_same_chk = 0 THEN
				ls_contno_row1 = ls_contno_row
			ELSEIF ll_same_chk = 1 THEN
				ls_contno_row2 = ls_contno_row
			ELSEIF ll_same_chk = 2 THEN
				ls_contno_row3 = ls_contno_row
			END IF
			ll_same_chk = ll_same_chk + 1
		END IF
	END IF
NEXT

SELECT MIN(CONTNO) INTO :ls_contno
FROM   ADMST
WHERE  MODELNO = :ls_modelno
AND 	 STATUS IN ( :ls_status, :ls_status2 )
AND    ITEMCOD = :ls_itemcod
AND    MV_PARTNER = :gs_shopid
AND    CONTNO NOT IN (:ls_contno_row1, :ls_contno_row2, :ls_contno_row3);

IF IsNull(ls_contno) THEN
	f_msg_info(9000, Title, "재고를 확인하시기 바랍니다.")
	dw_detail.object.modelno[wfl_row] = ""
	dw_detail.object.modelnm[wfl_row] = ""
	dw_detail.object.contno[wfl_row] = ""
	dw_detail.object.itemcod[wfl_row] = ""	
	Return -1
END IF

//해당 정보 가져오기
//1. ADMST의 MODELNO Read
SELECT ADSEQ, 				trim(status), 			ISEQNO,
       adtype, 			mv_partner, 			serialno,		 pid
  INTO :ll_adseq, 		:ls_status,				:ll_iseqno,
       :ls_adtype, 		:is_partner, 			:ls_serialno,	 :ls_pid
  FROM ADMST
 WHERE CONTNO = :ls_contno  ;

//Price read
//select sale_unitamt, sale_item  INto :ldc_saleamt, :ls_itemcod
//  from model_price
// where modelno =  :ls_modelno
//   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
//	                                      FROM model_price
//													 WHERE modelno =  :ls_modelno
//													   AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;
														

IF IsNull(ldc_saleamt) then ldc_saleamt = 0
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(Title, "Select Error(ADMST)")
//	Return  -1
//End If

dw_detail.object.adseq[wfl_row] 		= ll_adseq
dw_detail.object.adtype[wfl_row] 	= ls_adtype
dw_detail.object.itemcod[wfl_row] 	= ls_itemcod
dw_detail.object.modelno[wfl_row] 	= ls_modelno
dw_detail.object.modelnm[wfl_row] 	= ls_modelnm
dw_detail.object.sale_amt[wfl_row] 	= 0
dw_detail.object.CONTNO[wfl_row]		= ls_contno 
dw_detail.object.serialno[wfl_row]	= ls_serialno
dw_detail.object.pid[wfl_row]			= ls_pid

return 0
end function

public function integer wf_read_contno (string wfs_contno, long wfl_row);/*------------------------------------------------------------------------	
	Desc.	: 	장비 contno
	Arg	:	String ls_contno
	Ret.	:	0 		Seccess
				-1 	Error
	Ver.	: 	1.0
---------------------------------------------------------------------------*/
Integer 	li_cnt, i
Long 		ll_adseq, ll_old_adseq = 0, 	ll_iseqno
String 	ls_adtype, ls_contno, ls_serialno,	ls_pid

String 	ls_modelno, ls_modelnm, ls_status, ls_status2, &
			ls_itemcod, ls_saledt,	ls_modelno_de,	ls_itemcod_de,	ls_desc, ls_contno_row
DEC{2}	ldc_saleamt


ls_contno = wfs_contno
ls_saledt = String(fdt_get_dbserver_now(), 'yyyymmdd')
//ls_status = fs_get_control("E1", "A100", ls_desc)
//2010.05.19 CJH 수정. Moving Goods 빼고 Returning Goods를 넣음...
ls_status = fs_get_control("E1", "A102", ls_desc)
ls_status2= fs_get_control("E1", "A104", ls_desc)
ls_modelno_de = Trim(dw_detail.object.modelno[wfl_row])
ls_itemcod_de = Trim(dw_detail.object.itemcod[wfl_row])

Select count(*)	Into :li_cnt	From admst
Where  contno = :ls_contno
and    status in ( :ls_status, :ls_status2 )
and    modelno = :ls_modelno_de
and    itemcod = :ls_itemcod_de
and    mv_partner = :gs_shopid;

//Data Not Fount
If li_cnt = 0 Then
 	f_msg_usr_err(201, Title, "control No")
	dw_detail.Object.itemcod[wfl_row] = "" 	 
	dw_detail.Object.contno[wfl_row] = "" 
//	dw_cond.SetColumn("serialno")
	Return - 1
End If

FOR i = 1 TO dw_detail.RowCount()
	ls_contno_row = dw_detail.Object.contno[i]
	
	IF i <> wfl_row THEN
		IF ls_contno = ls_contno_row THEN
			f_msg_info(9000, Title, "컨트롤 번호를 확인하시기 바랍니다.")
			dw_detail.object.modelno[wfl_row] = ""
			dw_detail.object.modelnm[wfl_row] = ""
			dw_detail.object.contno[wfl_row] = ""
			dw_detail.object.itemcod[wfl_row] = ""	
			Return -1
		END IF
	END IF
NEXT	
//해당 정보 가져오기
//1. ADMST의 MODELNO Read
SELECT ADSEQ, 				trim(MODELNO), 		trim(itemcod),  trim(status), ISEQNO,
       adtype, 			mv_partner, 			serialno,		 pid
  INTO :ll_adseq, 		:ls_modelno, 			:ls_itemcod, 	 :ls_status,	:ll_iseqno,
       :ls_adtype, 		:is_partner, 			:ls_serialno,	 :ls_pid
  FROM ADMST
 WHERE CONTNO = :ls_contno  ;

//모델명 read
select trim(modelnm)  INTO :ls_modelnm   FROM ADMODEL B
 WHERE MODELNO 	=  :ls_modelno ;
 
 IF IsNull(ls_modelnm) then ls_modelnm = ''
//Price read
//select sale_unitamt, sale_item  INto :ldc_saleamt, :ls_itemcod
//  from model_price
// where modelno =  :ls_modelno
//   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
//	                                      FROM model_price
//													 WHERE modelno =  :ls_modelno
//													   AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;
														

IF IsNull(ldc_saleamt) then ldc_saleamt = 0
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(Title, "Select Error(ADMST)")
//	Return  -1
//End If

dw_detail.object.adseq[wfl_row] 		= ll_adseq
dw_detail.object.adtype[wfl_row] 	= ls_adtype
dw_detail.object.itemcod[wfl_row] 	= ls_itemcod
dw_detail.object.modelno[wfl_row] 	= ls_modelno
dw_detail.object.modelnm[wfl_row] 	= ls_modelnm
dw_detail.object.sale_amt[wfl_row] 	= 0
dw_detail.object.CONTNO[wfl_row]		= ls_contno 
dw_detail.object.serialno[wfl_row]	= ls_serialno
dw_detail.object.pid[wfl_row]			= ls_pid

return 0
end function

on b1w_reg_admst_pop_new.create
call super::create
end on

on b1w_reg_admst_pop_new.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_rental_pop
	Desc	: 	서비스 신청시 장비임대 등록
	Ver.	:	1.0
	Date	: 	2004.5.20
	programer : Kim Eun Mi (kem)
-------------------------------------------------------------------------*/
Integer li_rc, li_cnt, li_row, i, ll_rowcount, li_rows, li_rowcnt, li_count
String  ls_ref_desc, ls_type, ls_name[], ls_reqnum_dw, ls_itemcod, ls_modelno, ls_modelnm
String  ls_status, ls_filter, ls_desc
Dec{6}  ldc_unitcharge, ldc_basicamt
Long	  ll_row
b1u_dbmgr9_v20	lu_dbmgr
DataWindowChild ldc, ldwc_itemcod

is_act_gu = ""  	//신청/ 처리 구분
is_orderdt = ""
is_orderno = ""
is_priceplan = ""
is_customerid = ""
il_cnt = 0
is_save_chk = "N"

//window 중앙에
f_center_window(this)

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
lu_dbmgr.is_caller = "b1w_reg_rental_pop_v20%getdata"
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
	is_reg_partner = lu_dbmgr.is_data[8]
End If

dw_cond.object.svccod[1]    = is_svccod
dw_cond.object.priceplan[1] = is_priceplan
dw_cond.object.vpricecod[1] = lu_dbmgr.is_data[7]

If ib_order = False Then 	//개통 상태(신청상태가 아니면) 수정 불가능
	Trigger Event ue_search()
	Return
Else
	If il_cnt = 0 Then    //신규이면
	   //상태 코드 가져오기
		ls_ref_desc =""
		is_status = fs_get_control("E1", "A103", ls_ref_desc) //2006.01.17 juede add
		is_action = fs_get_control("E1", "A301", ls_ref_desc)
		//p_delete.TriggerEvent("ue_disable")
	Else
		Trigger Event ue_search()
		Return
   End If
End If

dw_detail.InsertRow(0)

li_rc = dw_detail.GetChild("itemcod", ldwc_itemcod)

IF li_rc = -1 THEN
	f_msg_usr_err(9000, Title, "Not a DataWindow Child")
	RETURN 
END IF

ls_filter = " priceplan = '" + is_priceplan + "' "

ldwc_itemcod.SetFilter(ls_filter)		
ldwc_itemcod.Filter()
ldwc_itemcod.SetTransObject(SQLCA)
ll_row =ldwc_itemcod.Retrieve() 

IF ll_row < 0 THEN 				//디비 오류 
	f_msg_usr_err(2100, Title, "itemcod Retrieve()")
	RETURN
END IF

ls_ref_desc =""
is_status = fs_get_control("E1", "A103", ls_ref_desc) //2006.01.17 juede add
is_action = fs_get_control("E1", "A301", ls_ref_desc)
is_adtype = fs_get_control("E1", "A601", ls_ref_desc)
	
dw_detail.object.adtype[1] = is_adtype

Destroy lu_dbmgr

dw_cond.SetItemStatus(0, 0, Primary!, NotModified!)
dw_detail.SetItemStatus(0, 0, Primary!, NotModified!)


end event

event ue_extra_save;Long ll_row, i, ll_seq, ll_row_cnt, j, ll_check, ll_sale_cnt, ll_priceplan_cnt
Dec{2} lc_amt[], lc_totalamt
Dec lc_saleamt
Integer li_rc
String ls_itemcod, ls_status, ls_status2, ls_modelno, ls_contno, ls_desc, ls_pwd, ls_pwd_yn
b1u_dbmgr9_v20_sams	lu_dbmgr

ls_status = fs_get_control("E1", "A102", ls_desc)
ls_status2= fs_get_control("E1", "A104", ls_desc)

ll_row_cnt = dw_detail.RowCount()

ll_sale_cnt = 0

FOR j = 1 TO ll_row_cnt
	ls_modelno = Trim(dw_detail.Object.modelno[j])
	ls_contno  = Trim(dw_detail.Object.contno[j])
	ls_pwd_yn  = Trim(dw_detail.Object.pwd_yn[j])
	ls_pwd	  = Trim(dw_detail.Object.spec_item1[j])
	
	IF IsNull(ls_contno) THEN ls_contno = "" 
	IF IsNull(ls_pwd_yn) THEN ls_pwd_yn = "" 
	IF IsNull(ls_pwd) THEN ls_pwd = "" 	
		
	IF ls_contno = "" THEN
		ROLLBACK;		
		f_msg_usr_err(201, Title, "Control No를 반드시 입력하세요")
		RETURN -1
	END IF
	
	IF ls_pwd_yn = "Y" THEN
		IF ls_pwd = "" THEN 
			ROLLBACK;		
			f_msg_usr_err(201, Title, "Password 를 반드시 입력하세요")
			RETURN -1
		END IF			
	END IF
	
	SELECT COUNT(*) INTO :ll_check
	FROM   ADMST
	WHERE  MODELNO = :ls_modelno
	AND    CONTNO  = :ls_contno
	AND    STATUS IN (:ls_status, :ls_status2);
	
	IF ll_check <= 0 THEN
		ROLLBACK;		
		f_msg_usr_err(201, Title, "카드 상태를 확인하세요.")
		RETURN -1
	END IF
	
	ll_sale_cnt = ll_sale_cnt + 1
	
NEXT		

//IF ll_sale_cnt > 0 THEN
//	SELECT COUNT(*) FROM INTO :ll_priceplan_cnt
//	FROM   ADMST_ITEM
//	WHERE  PRICEPLAN = :is_priceplan;
//	
//	IF ll_sale_cnt <> ll_priceplan_cnt THEN
//		ROLLBACK;		
//		f_msg_usr_err(201, Title, "가격정책에 허용된 카드 입력 수량과 다릅니다. 허용수량 :" + STRING(ll_priceplan_cnt))
//		RETURN -1
//	END IF
//END IF
	
//장비 정보 table insert

//장비 등록
lu_dbmgr = Create b1u_dbmgr9_v20_sams
lu_dbmgr.is_caller = "b1w_reg_admst_pop_new%hw_save"
lu_dbmgr.is_title = Title
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
lu_dbmgr.idw_data[2] = dw_detail
lu_dbmgr.uf_prc_db_02()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then		//Error   
	Destroy lu_dbmgr
	Return -2
End If
	
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

event ue_save;Constant Int LI_ERROR = -1
Integer li_return, li_row
String ls_null
Dec    ldc_saleamt

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If
IF dw_detail.ModifiedCount() + DW_DETAIL.DELETEDcOUNT() = 0 THEN
	dw_detail.SetFocus()
	Return LI_ERROR
end if
	

li_return = Trigger Event ue_extra_save()
If li_return <> 0  Then
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
//2010.12.07 수정함. 이것 때문에 cont.no 잘못 입력하고 save 버튼 누르고 캔슬팝업에서 yes 눌렀을때 데이터 윈도우 클리어됨.	
//	Trigger Event ue_reset()
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

is_save_chk = "Y"

SetNull(ls_null)
dw_cond.Enabled = False
dw_detail.Enabled = False

For li_row = 1 To dw_detail.RowCount()
	dw_detail.object.serialno[li_row] = ls_null
	dw_detail.object.adseq[li_row]    = 0
	dw_detail.object.modelno[li_row]  = ls_null
Next

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
dw_detail.SetItemStatus(0, 0, Primary!, NotModified!)

//TriggerEvent('ue_close')
Close(This)

Return 0
end event

event closequery;Int li_rc

dw_detail.AcceptText()

IF is_save_chk = "N" THEN
	MessageBox(This.Title, "카드입력이 완료되지 않았습니다.")
   Return 1
ELSE	
	RETURN 0
END IF	

RETURN 0
	
//
////다시 재정의
//If (dw_detail.ModifiedCount() > 0) and il_cnt = 0 Then
//	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
//		Question!, YesNo!)
//	//MessageBox(This.Title, "'서비스품목 할부 등록' 메뉴에서 할부정보를 등록하십시오")
//   If li_rc <> 1 Then  Return 1 //Process Cancel
//   //Return 0
//End If
//
//dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

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

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")

Return 0
end event

event ue_extra_insert;return 0
end event

event ue_extra_delete;Long ll_row


ll_row = dw_detail.GetRow()

dw_detail.DeleteRow(ll_row)
	
Return 0

end event

event ue_delete;Constant Int LI_ERROR = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.SetFocus()
End if

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_admst_pop_new
integer x = 46
integer y = 72
integer width = 2962
integer height = 364
string dataobject = "b1dw_cnd_reg_admst_pop_new"
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

type p_ok from w_a_reg_m`p_ok within b1w_reg_admst_pop_new
boolean visible = false
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_admst_pop_new
integer x = 3058
integer y = 180
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_admst_pop_new
integer width = 2994
integer height = 460
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_admst_pop_new
integer x = 352
integer y = 1168
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_admst_pop_new
integer x = 37
integer y = 1168
end type

type p_save from w_a_reg_m`p_save within b1w_reg_admst_pop_new
integer x = 667
integer y = 1168
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_admst_pop_new
integer x = 37
integer y = 488
integer width = 3305
integer height = 632
string dataobject = "b1dw_reg_admst_pop_new"
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
//	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild ldc_child, ldc
String ls_status, ls_desc, ls_filter, ls_modelnm, ls_itemcod, ls_pwd_yn
Integer li_exist, li_row, i

Choose Case dwo.name
	Case "itemcod"
		If IsNull(data) Then data = ""
		
//		FOR i = 1 TO THIS.RowCount()
//			ls_itemcod = THIS.Object.itemcod[i]
//			
//			IF i <> row THEN
//				IF ls_itemcod = data THEN
//					f_msg_usr_err(2100, Title, "이미 선택하신 품목입니다.")
//					THIS.Object.itemcod[row] = ""
//					Return 2
//				END IF
//			END IF
//		NEXT		
		
		If data <> "" Then
			If wf_read_item(data, row) = - 1 Then 
				Return 2
			End If
		END IF
		
		SELECT NVL(PWD_YN, 'N') INTO :ls_pwd_yn
		FROM   ADMST_ITEM
		WHERE  PRICEPLAN = :is_priceplan
		AND    ITEMCOD = :data;
		
		IF IsNull(ls_pwd_yn) Then ls_pwd_yn = "N"
		
		THIS.Object.pwd_yn[row] = ls_pwd_yn		
		
	Case "contno" 
		If IsNull(data) Then data = ""
		If data <> "" Then
			If wf_read_contno(data, row) = - 1 Then 
				Return 2
			End If
		END IF
End Choose


end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_admst_pop_new
boolean visible = false
integer x = 352
integer y = 904
boolean enabled = true
end type

