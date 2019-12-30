$PBExportHeader$b1w_reg_quotainfo_pop.srw
$PBExportComments$[ceusee] 장비/할부 등록
forward
global type b1w_reg_quotainfo_pop from w_a_reg_m
end type
end forward

global type b1w_reg_quotainfo_pop from w_a_reg_m
integer width = 2523
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_serarch ( )
end type
global b1w_reg_quotainfo_pop b1w_reg_quotainfo_pop

type variables
String is_orderno, is_pgmid, is_status, is_action, is_orderdt
String is_priceplan, is_itemcod, is_customerid, is_partner
Boolean ib_order
Long il_cnt, il_customer_hw

end variables

forward prototypes
public function integer wfi_get_hwseq (string as_serialno)
public function integer wfi_del_quotainfo (string as_orderno, string as_customerid, string as_itemcod)
public function integer wfi_set_saleamt (string as_orderno, string as_priceplan, string as_customerid, string as_itemcod, string as_orderdt)
end prototypes

event ue_serarch;//자료가 있으면 해당 자료 조회
String ls_where
Long ll_row
Integer li_rc

//조회만 가능 하게
dw_cond.Enabled = False
dw_detail.Enabled = False
dw_cond.object.t_3.Visible = False
dw_cond.object.startdate.Visible = False
p_ok.TriggerEvent("ue_disable")

b1u_dbmgr	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr

ls_where = "orderno = '" + is_orderno + "' And customerid = '" + is_customerid + "' And"  + &
           " itemcod ='" + is_itemcod + "' "


//장비정보 가져오기
lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop%inq"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_customerid
lu_dbmgr.is_data[2] = is_itemcod
lu_dbmgr.is_data[3] = is_orderno
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then
	Destroy lu_dbmgr
	Return
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retriev()")
	Return
End If
//수정 불가능
p_save.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

Destroy lu_dbmgr
Return
	
end event

public function integer wfi_get_hwseq (string as_serialno);
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
Long ll_adseq
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

dw_cond.object.hwseq[1] = ll_adseq
dw_cond.object.adtype[1] = ls_adtype



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

public function integer wfi_set_saleamt (string as_orderno, string as_priceplan, string as_customerid, string as_itemcod, string as_orderdt);/*------------------------------------------------------------------------
	Name	:	wfi_set_saleamt
	Arg.	:	deciaml - ac_orderno
				string -	as_customerid
						 - as_priceplan
						 - as_itemcod
	Desc.	:	해당 장비에 대한 기본요금 Setting
	Retu.	:  -1  : error
				 0  : 성공
   date	: 	2002.10.02
-------------------------------------------------------------------------*/
Dec{6} ldc_basicamt


//기존의 자료가 있는지 확인
Select count(*)
Into :il_cnt
From quota_info
Where to_char(orderno) = :as_orderno and customerid = :as_customerid and itemcod = :as_itemcod;


If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Select Error(QUOTA_INFO)")
	Return  -1
End If

//Customer_HW		//임대 때문에
Select count(*)
Into :il_customer_hw
From customer_hw
Where to_char(orderno) = :as_orderno and customerid = :as_customerid and itemcod = :as_itemcod;

//신규 / 임대
If (il_cnt = 0  and il_customer_hw = 0) Or il_customer_hw <> 0  Then
	//신청일자 보다 작은것중에 가장 큰 날짝의 요금 가져옴
	Select unitcharge
	Into :ldc_basicamt
	From priceplan_rate1
	Where priceplan = :as_priceplan and itemcod = :as_itemcod and
			to_char(fromdt,'yyyymmdd') = ( Select Max(to_char(fromdt, 'yyyymmdd'))
													 From priceplan_rate1
													 Where priceplan = :as_priceplan and itemcod = :as_itemcod and
														to_char(fromdt, 'yyyymmdd') < = :as_orderdt );
												
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Select Error(PRICEPLAN_RATE1)")
		Return  -1
	End If
	
	dw_cond.object.basicamt[1] = ldc_basicamt
End If

//할부여서 기본값이 있을때
If il_cnt <> 0 Then
	Select Sum(sale_amt)
	Into :ldc_basicamt
	From quota_info
	where to_char(orderno) = :as_orderno and customerid = :as_customerid;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Select Error(QUOTA_INFO)")
		Return  -1
	End If
	
	dw_cond.object.basicamt[1] = ldc_basicamt

End If

return 0 
end function

on b1w_reg_quotainfo_pop.create
call super::create
end on

on b1w_reg_quotainfo_pop.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_quotainfo_pop
	Desc	: 	장비 할부등록
	Ver.	:	1.0
	Date	: 	2002.10.02
	programer : choi bo ra (ceusee)
-------------------------------------------------------------------------*/
Integer li_rc, li_cnt
String ls_ref_desc, ls_type, ls_name[], ls_reqnum_dw

is_orderdt = ""
is_orderno = ""
is_itemcod = ""
is_priceplan = ""
is_customerid = ""
il_cnt = 0
//window 중앙에
f_center_window(b1w_reg_quotainfo_pop)
dw_cond.object.serialno.Protect = 1

//Data 받아오기
ib_order = iu_cust_msg.ib_data[1]
is_orderno = iu_cust_msg.is_data[5]
is_itemcod = iu_cust_msg.is_data[2]
is_priceplan = iu_cust_msg.is_data[4]
is_customerid = iu_cust_msg.is_data[1]
is_pgmid = iu_cust_msg.is_data[6]
is_orderdt = MidA(iu_cust_msg.is_data[7], 1, 4) + MidA(iu_cust_msg.is_data[7], 6, 2) + MidA(iu_cust_msg.is_data[7], 9, 2)

//Data Setting
dw_cond.object.itemcod[1] = is_itemcod
dw_cond.object.priceplan[1] = is_priceplan
dw_cond.object.itemnm[1] = iu_cust_msg.is_data[3]

//해당 Item 금액 가져오기
li_rc = wfi_set_saleamt(is_orderno, is_priceplan, is_customerid, is_itemcod, is_orderdt)
If li_rc < 0 Then
	f_msg_usr_err(9000, Title, "장비에 대한 판매금액이 올바르지 않습니다.")
   Return
End If

//Format 지정
ls_ref_desc = ""
ls_reqnum_dw = fs_get_control("B0", "P105", ls_ref_desc)
li_cnt = fi_cut_string(ls_reqnum_dw, ";", ls_name[])

Select currency_type
Into 	:ls_type
From priceplanmst
where priceplan = :is_priceplan;

If ls_name[1] = ls_type Then
	dw_cond.object.basicamt.Format = "#,##0.00"
Else
	dw_cond.object.basicamt.Format = "#,##0.000000"
End If

If ib_order = False Then 	//개통 상태(신청상태가 아니면) 수정 불가능
	Trigger Event ue_serarch()
	
Else
	If il_cnt = 0 And il_customer_hw = 0 Then    //신규이면
	   //상태 코드 가져오기
		ls_ref_desc =""
		is_status = fs_get_control("E1", "A101", ls_ref_desc)
		is_action = fs_get_control("E1", "A301", ls_ref_desc)

	
		dw_detail.object.sale_amt.Protect = 0
		dw_cond.object.cnt.Protect = 0
		dw_cond.object.startdate.Protect =0
		dw_cond.Object.cnt.Background.Color = RGB(108, 147, 137)
		dw_cond.Object.cnt.Color = RGB(255, 255, 255)
		dw_detail.object.sale_amt.Background.Color = RGB(255,255,255)
		dw_detail.object.sale_amt.Color = RGB(0, 0, 0)
		dw_cond.object.startdate.visible = True
		dw_cond.object.t_3.visible = True
		p_delete.TriggerEvent("ue_disable")
	Else
		Trigger Event ue_serarch()
	
   End If
End If
 




end event

event ue_ok();Dec{6} ldc_basicamt
Long ll_row, ll_hwseq
Integer li_rc, li_cnt
Date ld_startdate
String ls_cnt, ls_startdate, ls_where
String ls_modelno, ls_serialno, ls_sale_flag

b1u_dbmgr	lu_dbmgr
lu_dbmgr = Create b1u_dbmgr


			  
//If ib_order = True Then  //신청상태
  
   //신규
	If il_cnt  = 0  and il_customer_hw  = 0 Then		
	
	
		li_cnt = dw_cond.object.cnt[1]
		ls_cnt = String(li_cnt)
		
		ls_startdate = String(dw_cond.object.startdate[1],'yyyymm')
		ls_modelno = Trim(dw_cond.object.modelno[1])
		ls_serialno = Trim(dw_cond.object.serialno[1])
		ls_sale_flag = Trim(dw_cond.object.sale_flag[1])
		If IsNull(ls_startdate) Then ls_startdate = ""
		If IsNull(ls_modelno) Then ls_modelno = ""
		If IsNull(ls_serialno) Then ls_serialno = ""
		If IsNull(ls_sale_flag) Then ls_sale_flag = ""
		
		ldc_basicamt = dw_cond.object.basicamt[1]
		If IsNull(ls_cnt) Then ls_cnt = ""
		If IsNull(ls_startdate) Then ls_startdate = ""
		
		//셋 정보 다 입력
		If ls_modelno <> "" Or ls_sale_flag <> "" Or ls_serialno <> "" Then
			If ls_modelno = "" Then
				f_msg_info(200, Title, "장비모델")
				dw_cond.SetFocus()
				dw_cond.SetColumn("modelno")
				Return
			End If
			
			If ls_serialno = "" Then
				f_msg_info(200, Title, "Serial No")
				dw_cond.SetFocus()
				dw_cond.SetColumn("serialno")
				Return
			End If
			
			If ls_sale_flag = "" Then
				f_msg_info(200, Title, "판매/임대구분")
				dw_cond.SetFocus()
				dw_cond.SetColumn("sale_flag")
				Return
			End If
		End If
			
		//올바를 Serial No. 인지 확인
		If ls_serialno <> "" Then
			ll_hwseq = dw_cond.object.hwseq[1]
			If IsNull(ll_hwseq) Then
				f_msg_usr_err(201, Title, "Serial No")
				dw_cond.SetFocus()
				dw_cond.SetColumn("adtype")
				Return
			End If
		End If	
		
		//장비가 판매이면 할부 개월수 할부 적용시작 필수
		If ls_sale_flag = "1" Or ls_sale_flag = "" Then
			If ls_cnt = "" Then
				f_msg_info(200, Title, "할부개월수")
				dw_cond.SetFocus()
				dw_cond.SetColumn("cnt")
				Return
			End If
			
			If ls_startdate = "" Then
				f_msg_info(200, Title, "할부적용시작")
				dw_cond.SetFocus()
				dw_cond.SetColumn("startdate")
				Return
			End If
		   
			//할부 개월수 계산
			//날짜가 비어있지 않으면
			ls_startdate = ls_startdate + "01"
			ld_startdate = Date(MidA(ls_startdate,1,4) + "-" + MidA(ls_startdate,5,2) + "-01")
			Messagebox("@@@", ls_startdate)
			
			lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop%insert"
			lu_dbmgr.is_title = Title
			lu_dbmgr.ii_data[1] = li_cnt
			lu_dbmgr.id_data[1] = ld_startdate
			lu_dbmgr.is_data[1] = is_customerid
			lu_dbmgr.is_data[2] = is_itemcod
			lu_dbmgr.is_data[3] = is_orderno
			lu_dbmgr.is_data[4] = gs_user_id
			lu_dbmgr.is_data[5] = is_pgmid
			lu_dbmgr.is_data[6] = ls_startdate
			lu_dbmgr.ic_data[1] = ldc_basicamt
			lu_dbmgr.idw_data[1] = dw_detail
			lu_dbmgr.uf_prc_db()
			li_rc = lu_dbmgr.ii_rc
			If li_rc < 0 Then
				Destroy lu_dbmgr
				Return
			End If
		   
		   p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		
	  Else				//임대
		  li_rc = MessageBox(This.Title, "임대 정보를 저장 하시겠습니까?",&
									Question!, YesNo!)
		 If li_rc = 1 Then
			Trigger Event ue_extra_save()
		 Else
			 p_save.TriggerEvent("ue_enable")
			 p_reset.TriggerEvent("ue_disable")
		 End If
	  End If
     p_delete.TriggerEvent("ue_disble")
		
End If
	

Destroy lu_dbmgr
p_ok.TriggerEvent("ue_disable")
dw_cond.Enabled = False
Return 
end event

event ue_extra_save;Long ll_row, i, ll_seq
Dec{2} lc_amt[], lc_totalamt
Dec lc_basicamt
Integer li_rc
String ls_sale_flag
b1u_dbmgr	lu_dbmgr

ls_sale_flag = Trim(dw_cond.object.sale_flag[1])
If IsNull(ls_sale_flag) Then ls_sale_flag= ""

//판매이면 할부 계월수 정보 확인
If ls_sale_flag = "1"  Or ls_sale_flag = "" Then

	ll_row = dw_detail.RowCount()
	If ll_row = 0 Then Return -1   //error
	
	lc_basicamt = dw_cond.object.basicamt[1]
	
	For i =1 To ll_row
		lc_amt[i] = dw_detail.object.sale_amt[i]
		lc_totalamt += lc_amt[i]
	Next
	
	//금액이 같지 않으면 저장안됨.
	If lc_basicamt <> lc_totalamt Then
		f_msg_usr_err(9000, Title, "조정금액의 합이 판매금액과 같지 않습니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("sale_amt")
		Return -2
	End If
End If


//처음 신청 판매/ 임대 구분 없이 장비 정보 table insert
//If il_cnt = 0 Then
	//장비 등록
	lu_dbmgr = Create b1u_dbmgr
	lu_dbmgr.is_caller = "b1w_reg_quotainfo_pop%hw_save"
	lu_dbmgr.is_title = Title
	lu_dbmgr.is_data[1] = is_customerid
	lu_dbmgr.is_data[2] = is_itemcod
	lu_dbmgr.is_data[3] = is_orderno
	lu_dbmgr.is_data[4] = gs_user_id
	lu_dbmgr.is_data[5] = is_pgmid
	lu_dbmgr.is_data[6] = is_status
	lu_dbmgr.is_data[7] = is_action
	lu_dbmgr.is_data[8] = is_partner
	lu_dbmgr.idw_data[1] = dw_cond
	lu_dbmgr.uf_prc_db()
	li_rc = lu_dbmgr.ii_rc
	If li_rc < 0 Then		//Error
		Destroy lu_dbmgr
		Return - 2
	End If
	
   If ls_sale_flag = "1"  Or ls_sale_flag = "" Then
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
	End If
 // End If   //il_cnt = 0


//UpdateLog
For i = 1 To ll_row
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
			dw_detail.object.updt_user[i] = gs_user_id
			dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
	End If
Next

Destroy lu_dbmgr
Return 0
end event

event ue_save;Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
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
	
	f_msg_info(3000,This.Title,"Save")
End If

//Close
il_cnt = 1
Trigger Event ue_close()

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

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If


p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.object.cnt[1] = 1
dw_cond.object.startdate[1] = fdt_get_dbserver_now()
dw_cond.Enabled = True
dw_cond.SetFocus()

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_quotainfo_pop
integer y = 44
integer width = 2098
integer height = 660
string dataobject = "b1dw_cnd_reg_quotainfo_pop"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;//해당 모델에 대한 장비 시리얼 번호 가져오기
DataWindowChild ldc_child
String ls_filter, ls_serialno
Integer li_exist

This.SetRedraw(False)

If dwo.name = "modelno" Then
	//색깔 변하게 하기 
	If IsNull(data) or data = "" Then
		This.object.modelno.Background.Color = RGB(255, 255, 255)
		This.object.modelno.Color = RGB(0, 0, 0)
		This.object.sale_flag.Background.Color = RGB(255, 255, 255)
		This.object.sale_flag.Color = RGB(0, 0, 0)
		This.object.serialno.Background.Color = RGB(255, 255, 255)
		This.object.serialno.Color = RGB(0, 0, 0)
		This.object.serialno.Protect = 1
	Else
		This.object.modelno.Background.Color = RGB(108, 147, 137)
		This.object.modelno.Color = RGB(255, 255, 255)
		This.object.sale_flag.Background.Color = RGB(108, 147, 137)
		This.object.sale_flag.Color = RGB(255, 255, 255)
		This.object.serialno.Background.Color = RGB(108, 147, 137)
		This.object.serialno.Color = RGB(255, 255, 255)
		This.object.serialno.Protect = 0
	End If
	
	This.object.serialno[row] = ''				
	li_exist = dw_cond.GetChild("serialno", ldc_child)		//DDDW 구함
	If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Serial No.")
	ls_filter = "modelno = '" + data  + "' And mv_partner = '" + gs_user_group + "' "
	ldc_child.SetTransObject(SQLCA)
	li_exist =ldc_child.Retrieve()
	ldc_child.SetFilter(ls_filter)			//Filter정함
	ldc_child.Filter()
	
ElseIf dwo.name = "serialno" Then
   //Data 확인 작업
	If IsNull(data) Then data = ""
	If data <> "" Then
		If wfi_get_hwseq(data) = - 1 Then 
			Return 2
		End If
	End If		
ElseIf dwo.name = "sale_flag" Then
	If IsNull(data) or data = "" Then
		This.object.modelno.Background.Color = RGB(255, 255, 255)
		This.object.modelno.Color = RGB(0, 0, 0)
		This.object.sale_flag.Background.Color = RGB(255, 255, 255)
		This.object.sale_flag.Color = RGB(0, 0, 0)
		This.object.serialno.Background.Color = RGB(255, 255, 255)
		This.object.serialno.Color = RGB(0, 0, 0)
		This.object.serialno.Protect = 1
	Else
		This.object.modelno.Background.Color = RGB(108, 147, 137)
		This.object.modelno.Color = RGB(255, 255, 255)
		This.object.sale_flag.Background.Color = RGB(108, 147, 137)
		This.object.sale_flag.Color = RGB(255, 255, 255)
		This.object.serialno.Background.Color = RGB(108, 147, 137)
		This.object.serialno.Color = RGB(255, 255, 255)
		This.object.serialno.Protect = 0
	End If
	
	//임대이면 필수 가 바뀜
	If data = "2" Then
		This.object.cnt.Background.Color = RGB(255, 255, 255)
		This.object.cnt.Color = RGB(0, 0, 0)
		This.object.startdate.Background.Color = RGB(255, 255, 255)
		This.object.startdate.Color = RGB(0, 0, 0)
		This.object.startdate.Protect = 1
		This.object.cnt.Protect = 1
	
	Else
		This.object.cnt.Background.Color = RGB(108, 147, 137)
		This.object.cnt.Color = RGB(255, 255, 255)
		This.object.startdate.Background.Color = RGB(108, 147, 137)
		This.object.startdate.Color = RGB(255, 255, 255)
		This.object.startdate.Protect = 0
		This.object.cnt.Protect = 0
		
	End If
End IF

This.SetRedraw(True)
Return 0 


end event

type p_ok from w_a_reg_m`p_ok within b1w_reg_quotainfo_pop
integer x = 2199
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b1w_reg_quotainfo_pop
integer x = 2199
integer y = 172
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_quotainfo_pop
integer x = 41
integer width = 2130
integer height = 740
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_quotainfo_pop
boolean visible = false
integer x = 55
integer y = 1652
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_quotainfo_pop
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_quotainfo_pop
integer x = 37
integer y = 1636
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_quotainfo_pop
integer x = 23
integer y = 756
integer width = 2459
integer height = 840
string dataobject = "b1dw_reg_quotainfo_pop"
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

type p_reset from w_a_reg_m`p_reset within b1w_reg_quotainfo_pop
integer x = 338
integer y = 1636
boolean enabled = true
end type

