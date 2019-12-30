$PBExportHeader$b1w_reg_rental_pop_v20_sams_old.srw
$PBExportComments$서비스 신청시 장비임대 등록
forward
global type b1w_reg_rental_pop_v20_sams_old from w_a_reg_m
end type
end forward

global type b1w_reg_rental_pop_v20_sams_old from w_a_reg_m
boolean visible = false
integer width = 3397
integer height = 1104
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_search ( )
end type
global b1w_reg_rental_pop_v20_sams_old b1w_reg_rental_pop_v20_sams_old

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt, is_act_gu, is_reg_partner
String is_priceplan,is_customerid, is_partner, is_svccod, is_itemcod[], is_main_itemcod, &
       is_adtype, is_customernm, is_contractseq
Long il_cnt, il_customer_hw, il_itemcodcnt
Boolean ib_order

end variables

forward prototypes
public function integer wfi_set_saleamt (long al_row)
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wfi_get_hwseq (string as_serialno, long al_row)
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

public function integer wfi_set_saleamt (long al_row);Long   ll_row, i, ll_cnt, j
String ls_itemcod
Dec{2} ldc_saleamt


ll_row = al_row
ls_itemcod =  trim(dw_detail.Object.itemcod[ll_row])
SELECT A.UNITCHARGE
		  INTO :ldc_saleamt
		  FROM PRICEPLAN_RATE2 A
		     , ADMODEL_ITEM B
 WHERE A.PRICEPLAN = :is_priceplan
   AND A.ITEMCOD   = :ls_itemcod
	AND A.ITEMCOD   = B.ITEMCOD
	AND TO_CHAR(A.fromdt, 'YYYYMMDD') = ( SELECT MAX(TO_CHAR(C.FROMDT, 'YYYYMMDD'))
															  FROM PRICEPLAN_RATE2 C
															     , ADMODEL_ITEM D
															 WHERE C.PRICEPLAN = :is_priceplan
															   AND C.ITEMCOD   = :ls_itemcod
																AND C.ITEMCOD   = D.ITEMCOD
																AND TO_CHAR(C.FROMDT,'YYYYMMDD') <= :is_orderdt);
				
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "판매금액 Select Error(PRICEPLAN)")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			
		Else
			IF IsNull(ldc_saleamt) then ldc_saleamt = 0
			dw_detail.Object.sale_amt[ll_row] = ldc_saleamt
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
String ls_adtype, ls_contno

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
Select adseq, adtype, mv_partner, contno
Into :ll_adseq, :ls_adtype, :is_partner, :ls_contno
From admst
Where serialno = :as_serialno;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(ADMST)")
	Return  -1
End If

dw_detail.object.adseq[al_row] = ll_adseq
dw_detail.object.adtype[al_row] = ls_adtype
dw_detail.object.contno[al_row] = ls_contno

Return 0
end function

public function integer wf_read_contno (string wfs_contno, long wfl_row);/*------------------------------------------------------------------------	
	Desc.	: 	장비 contno
	Arg	:	String ls_contno
	Ret.	:	0 		Seccess
				-1 	Error
	Ver.	: 	1.0
---------------------------------------------------------------------------*/
Integer 	li_cnt
Long 		ll_adseq, ll_old_adseq = 0, 	ll_iseqno
String 	ls_adtype, ls_contno, ls_serialno

String 	ls_modelno, ls_modelnm, ls_status, &
			ls_itemcod, ls_saledt
DEC{2}	ldc_saleamt


ls_contno = wfs_contno
ls_saledt = String(fdt_get_dbserver_now(), 'yyyymmdd')

Select count(*)	Into :li_cnt	From admst
Where contno = :ls_contno;

//Data Not Fount
If li_cnt = 0 Then
 	f_msg_usr_err(201, Title, "control No")
//	dw_cond.SetColumn("serialno")
	Return - 1
End If

//해당 정보 가져오기
//1. ADMST의 MODELNO Read
SELECT ADSEQ, 				trim(MODELNO), 		trim(itemcod),  trim(status), ISEQNO,
       adtype, 			mv_partner, 			serialno
  INTO :ll_adseq, 		:ls_modelno, 			:ls_itemcod, 	 :ls_status,	:ll_iseqno,
       :ls_adtype, 		:is_partner, 			:ls_serialno
  FROM ADMST
 WHERE CONTNO = :ls_contno  ;

//모델명 read
select trim(modelnm)  INTO :ls_modelnm   FROM ADMODEL B
 WHERE MODELNO 	=  :ls_modelno ;
 
 IF IsNull(ls_modelnm) then ls_modelnm = ''
//Price read
select sale_unitamt, sale_item  INto :ldc_saleamt, :ls_itemcod
  from model_price
 where modelno =  :ls_modelno
   AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
	                                      FROM model_price
													 WHERE modelno =  :ls_modelno
													   AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;
														

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
dw_detail.object.sale_amt[wfl_row] 	= ldc_saleamt
dw_detail.object.CONTNO[wfl_row]		= ls_contno 


return 0
end function

on b1w_reg_rental_pop_v20_sams_old.create
call super::create
end on

on b1w_reg_rental_pop_v20_sams_old.destroy
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
b1u_dbmgr9_v20_sams	lu_dbmgr
DataWindowChild ldc

is_act_gu 		= ""  	//신청/ 처리 구분
is_orderdt 		= ""
is_orderno 		= ""
is_priceplan 	= ""
is_customerid 	= ""
il_cnt = 0

//window 중앙에
f_center_window(b1w_reg_rental_pop_v20_sams)

//Data 받아오기
ib_order       = iu_cust_msg.ib_data[1]
is_orderno     = String(iu_cust_msg.il_data[1])
is_contractseq = String(iu_cust_msg.il_data[2])
is_customerid  = iu_cust_msg.is_data2[2]
is_pgmid       = iu_cust_msg.is_data2[3]
is_act_gu      = iu_cust_msg.is_data2[4]
is_customernm  = iu_cust_msg.is_data2[5]
is_orderdt 	 	= iu_cust_msg.is_data2[6]

dw_cond.object.customerid[1]  = is_customerid
dw_cond.object.customernm[1]  = is_customernm
dw_cond.object.orderno[1]     = is_orderno
dw_cond.object.contractseq[1] = is_contractseq

//priceplan, itemcod, itemnm, orderdt 가져오기
lu_dbmgr = Create b1u_dbmgr9_v20_sams
lu_dbmgr.is_caller = "b1w_reg_rental_pop_v20_sams%getdata"
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


//main itemcod에 해당하는 장비모델
ll_rowcount = UpperBound(iu_cust_msg.is_data[])
For i = 1 To ll_rowcount
	is_itemcod[i] = iu_cust_msg.is_data[i]
	
	SELECT count(A.ITEMCOD)
	  INTO :li_rows
	  FROM ITEMMST A, ADMODEL_ITEM B
	 WHERE A.ITEMCOD = B.ITEMCOD
	   AND A.ITEMCOD  = :is_itemcod[i]
	   AND A.QUOTA_YN = 'R';
		

	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Itemmst Select Error(ITEMCOD)")
		Return
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
		
	Else
		If li_rows > 0 Then
			li_rowcnt = dw_detail.InsertRow(0)
			
			dw_detail.object.itemcod[li_rowcnt] = is_itemcod[i]
			
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
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, Title, "서비스에 해당하는 장비모델이 없습니다.")
				Return -1
			Else
				dw_detail.object.modelno[li_rowcnt] = ls_modelno
				dw_detail.object.modelnm[li_rowcnt] = ls_modelnm
			End If
			//=====================================
			//해당 금액
			//=====================================
			wfi_set_saleamt(li_rowcnt)
			
			
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

If dw_detail.RowCount() > 0 Then
	ls_status = fs_get_control("E1", "A100", ls_desc)
	
	ls_modelno = Trim(dw_detail.object.modelno[1])

	li_row = dw_detail.GetChild("serialno", ldc)		//DDDW 구함
	If li_row = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Serial No.")
	ls_filter = "modelno = '" + ls_modelno  + "' And status = '" + ls_status + "' "
	ldc.SetTransObject(SQLCA)
	li_row =ldc.Retrieve()
	ldc.SetFilter(ls_filter)			//Filter정함
	ldc.Filter()
End If

If ib_order = False Then 	//개통 상태(신청상태가 아니면) 수정 불가능
	Trigger Event ue_search()
	Return
	
Else
	If il_cnt = 0 Then    //신규이면
	   //상태 코드 가져오기
		ls_ref_desc =""
		//is_status = fs_get_control("E1", "A101", ls_ref_desc) //2006.01.17 juede comment
		is_status = fs_get_control("E1", "A103", ls_ref_desc) //2006.01.17 juede add
		is_action = fs_get_control("E1", "A301", ls_ref_desc)
		p_delete.TriggerEvent("ue_disable")
	Else
		Trigger Event ue_search()
		Return
	
   End If
End If


ls_ref_desc =""
// is_status = fs_get_control("E1", "A101", ls_ref_desc) //2006.01.17 juede comment
is_status = fs_get_control("E1", "A103", ls_ref_desc) //2006.01.17 juede add
is_action = fs_get_control("E1", "A301", ls_ref_desc)
is_adtype = fs_get_control("E1", "A601", ls_ref_desc)
	
dw_detail.object.adtype[1] = is_adtype

Destroy lu_dbmgr

dw_cond.SetItemStatus(0, 0, Primary!, NotModified!)
dw_detail.SetItemStatus(0, 0, Primary!, NotModified!)


end event

event type integer ue_extra_save();Long ll_row, i, ll_seq
Dec{2} lc_amt[], lc_totalamt
Dec lc_saleamt
Integer li_rc
String ls_itemcod
b1u_dbmgr9_v20_sams	lu_dbmgr

	
//장비 정보 table insert

//장비 등록


lu_dbmgr = Create b1u_dbmgr9_v20_sams
lu_dbmgr.is_caller = "b1w_reg_rental_pop_v20_sams%hw_save"
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
lu_dbmgr.uf_prc_db()
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

event type integer ue_save();Constant Int LI_ERROR = -1
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
	
End If

f_msg_info(3000,This.Title,"Save")
//Trigger Event ue_reset()

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
dw_detail.SetItemStatus(0, 0, Primary!, NotModified!)
//TriggerEvent('ue_close')
Close(This)

Return 0
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

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_rental_pop_v20_sams_old
integer x = 46
integer y = 72
integer width = 2962
integer height = 364
string dataobject = "b1dw_cnd_reg_rental_pop_v20"
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

type p_ok from w_a_reg_m`p_ok within b1w_reg_rental_pop_v20_sams_old
boolean visible = false
integer x = 3058
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b1w_reg_rental_pop_v20_sams_old
integer x = 3058
integer y = 180
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_rental_pop_v20_sams_old
integer width = 2994
integer height = 460
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_rental_pop_v20_sams_old
boolean visible = false
integer x = 1010
integer y = 1888
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_rental_pop_v20_sams_old
boolean visible = false
integer x = 709
integer y = 1888
end type

type p_save from w_a_reg_m`p_save within b1w_reg_rental_pop_v20_sams_old
integer x = 50
integer y = 904
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_rental_pop_v20_sams_old
integer x = 37
integer y = 488
integer width = 2990
integer height = 388
string dataobject = "b1dw_cnd_reg_quotainfo_pop_ad_v20_sams"
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

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild ldc_child, ldc
String ls_status, ls_desc, ls_filter, ls_modelnm, ls_itemcod
Integer li_exist, li_row

Choose Case dwo.name
	Case "contno" 
		If IsNull(data) Then data = ""
		If data <> "" Then
			If wf_read_contno(data, row) = - 1 Then 
				Return 2
			End If
		END IF
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_rental_pop_v20_sams_old
integer x = 352
integer y = 904
boolean enabled = true
end type

