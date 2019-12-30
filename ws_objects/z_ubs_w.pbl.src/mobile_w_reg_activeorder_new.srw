$PBExportHeader$mobile_w_reg_activeorder_new.srw
$PBExportComments$모바일 서비스 신청(2015)
forward
global type mobile_w_reg_activeorder_new from w_a_reg_m_tm2
end type
type gb_3 from groupbox within mobile_w_reg_activeorder_new
end type
type gb_2 from groupbox within mobile_w_reg_activeorder_new
end type
type dw_detail1 from u_d_indicator within mobile_w_reg_activeorder_new
end type
type dw_item from u_d_indicator within mobile_w_reg_activeorder_new
end type
type uo_1 from u_calendar_sams within mobile_w_reg_activeorder_new
end type
type dw_detail from u_d_indicator within mobile_w_reg_activeorder_new
end type
type p_1 from u_p_pnext within mobile_w_reg_activeorder_new
end type
type gb_4 from groupbox within mobile_w_reg_activeorder_new
end type
end forward

global type mobile_w_reg_activeorder_new from w_a_reg_m_tm2
integer width = 6240
integer height = 2664
gb_3 gb_3
gb_2 gb_2
dw_detail1 dw_detail1
dw_item dw_item
uo_1 uo_1
dw_detail dw_detail
p_1 p_1
gb_4 gb_4
end type
global mobile_w_reg_activeorder_new mobile_w_reg_activeorder_new

type prototypes
Function Long SetCurrentDirectoryA (String lpPathName ) Library "kernel32" alias for "SetCurrentDirectoryA;Ansi" 
end prototypes

type variables

string is_partner, is_selfequip,  is_cus_status, is_hotbillflag
String is_svctype, is_svccode, is_priceplan, is_act_gu, is_amt_check
Long il_orderno, il_contractseq

//SCHEDULE_DETAIL.SCHEDULESEQ
Long		il_SCHEDULESEQ

integer ii_enable_max_tab
end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine wf_set_item (string as_itemcod, decimal ad_saleamt, string as_chk)
public function integer wf_itemcod_chk (integer ai_selectab)
public function integer wf_read_contno (string wfs_contno, integer wfl_row)
public function integer wf_mobile_sales (long row, string as_modelcd, string as_priceplan, integer ai_month, string as_fromdt)
end prototypes

public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[]);//문자열을 특정구분자(as_cut)로 자른다.
Long ll_rc = 1
Int li_index = 0

as_source = Trim(as_source)
If as_source <> '' Then
	Do While(ll_rc <> 0 )
		li_index ++
		ll_rc = PosA(as_source, as_cut)
		If ll_rc <> 0 Then
			as_result[li_index] = Trim(LeftA(as_source, ll_rc - 1))
		Else
			as_result[li_index] = Trim(as_source)
		End If

		as_source = MidA(as_source, ll_rc + 2)
	Loop
End If

Return li_index
end function

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm, ls_payid, ls_partner, ls_customerid, ls_memberid
Integer	li_sw


IF as_customerid <> "" THEN

	Select customernm,
			 status,
		  	 payid,
		    partner,
			 MEMBERID
	  Into :ls_customernm,
		    :is_cus_status,
		    :ls_payid,
		    :ls_partner,
			 :ls_memberid
	  From customerm
	 Where customerid = :as_customerid;
	 
	 ls_customerid = as_customerid

END IF

If SQLCA.SQLCode = 100 Then		//Not Found
	
	f_msg_usr_err(201, Title, "Customer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
   Return -1
	
End If

Select hotbillflag
  Into :is_hotbillflag
  From customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호(납입자번호)")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

If IsNull(is_hotbillflag) Then is_hotbillflag = ""
If is_hotbillflag = 'S' Then    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   f_msg_usr_err(201, Title, "즉시불처리중인고객")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] 	= ls_customernm
dw_cond.object.customerid[1] 	= ls_customerid

//
//IF as_customerid <> "" THEN
//	li_sw = 1
//ELSE
//	li_sw = 2
//END IF
//
//IF li_sw = 1  THEN
//	Select customernm,
//			 status,
//		  	 payid,
//		    partner,
//			 MEMBERID
//	  Into :ls_customernm,
//		    :is_cus_status,
//		    :ls_payid,
//		    :ls_partner,
//			 :ls_memberid
//	  From customerm
//	 Where customerid = :as_customerid;
//	 
//	 ls_customerid = as_customerid
//ELSE
//	Select customerid,
//			 customernm,
//			 status,
//		  	 payid,
//		    partner
//	  Into :ls_customerid,
//	       :ls_customernm,
//		    :is_cus_status,
//		    :ls_payid,
//		    :ls_partner
//	  From customerm
//	 Where memberid = :as_memberid;
//	 ls_memberid = as_customerid
//END IF
//
//If SQLCA.SQLCode = 100 Then		//Not Found
//	IF li_sw = 1 THEN
//   	f_msg_usr_err(201, Title, "Customer ID")
//   	dw_cond.SetFocus()
//   	dw_cond.SetColumn("customerid")
//	ELSE
//   	f_msg_usr_err(201, Title, "Member ID")
//   	dw_cond.SetFocus()
//   	dw_cond.SetColumn("memberid")
//	END IF
//   Return -1
//End If
//
//Select hotbillflag
//  Into :is_hotbillflag
//  From customerm
// Where customerid = :ls_payid;
//
//If SQLCA.SQLCode = 100 Then		//Not Found
//   f_msg_usr_err(201, Title, "고객번호(납입자번호)")
//   dw_cond.SetFocus()
//   dw_cond.SetColumn("customerid")
//   Return -1
//End If
//
//If IsNull(is_hotbillflag) Then is_hotbillflag = ""
//If is_hotbillflag = 'S' Then    //현재 Hotbilling고객이면 개통신청 못하게 한다.
//   f_msg_usr_err(201, Title, "즉시불처리중인고객")
//   dw_cond.SetFocus()
//   dw_cond.SetColumn("customerid")
//   Return -1
//End If
//
//dw_cond.object.customernm[1] 	= ls_customernm
//dw_cond.object.customerid[1] 	= ls_customerid
////dw_cond.object.memberid[1] 	= ls_memberid



Return 0

end function

public subroutine wf_set_item (string as_itemcod, decimal ad_saleamt, string as_chk);long ll_found, ll_row, ll_priority
String ls_onefee, ls_bilyn


	ll_row = dw_item.insertrow(0)	
	dw_item.object.itemcod[ll_row] = as_itemcod					
	dw_item.object.sale_amt[ll_row] = ad_saleamt
	dw_item.object.chk[ll_row] = as_chk
	
	SELECT ONEOFFCHARGE_YN, BILITEM_YN, PRIORITY INTO :ls_onefee, :ls_bilyn, :ll_priority
	FROM ITEMMST
   WHERE ITEMCOD = :as_itemcod;
	
	dw_item.object.oneoffcharge_yn[ll_row] = ls_onefee					
	dw_item.object.bilitem_yn[ll_row] = ls_bilyn
	dw_item.object.itemmst_priority[ll_row] = ll_priority

				
end subroutine

public function integer wf_itemcod_chk (integer ai_selectab);Long    	ll_row, 					ll_gubun[], 	ll_type[], 	ll_cnt, 	ll_cnt_1
Integer 	li_rc, 					i
String  	ls_chk
Boolean 	ib_jon, 					ib_jon_1, &
			lb_check 	= False, &
			lb_check_2 	= False

ib_jon   = False
ib_jon_1 = False

ll_cnt 					= 0



For i = 1 To tab_1.idw_tabpage[ai_selectab].RowCount()
	ll_gubun[i]      = tab_1.idw_tabpage[ai_selectab].Object.groupno[i]
	ll_type[i]       = tab_1.idw_tabpage[ai_selectab].Object.grouptype[i]
	ls_chk           = tab_1.idw_tabpage[ai_selectab].Object.chk[i]	
	If ls_chk = 'Y' Then			ll_cnt ++
	IF ll_type[i] = 1 Then
		ib_jon   = True
	Else
		ib_jon_1 = True
	End If
   
Next

//If ll_cnt = 0 Then
//	f_msg_info(9000, Title, "품목을 선택하여야 합니다.")	
//	Return  -2
//End If

ll_cnt   = 0
ll_cnt_1 = 0
ls_chk   = ''

//동일 그룹일때 선택유형이 0이면 하나만 선택해야하고 동일 그룹일때 선택유형이 1이면 하나 이상  선택하여야한다.
//선택유형이 0인것중 group이  여러종류로 구성되어있다면..각동일그룹에서 하나씩만 선택되어야한다.
long cnt = 0, t, cnt_group = 0
For i = 1 To UpperBound(ll_gubun)  
	If ll_type[i] = 0 Then 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If tab_1.idw_tabpage[ai_selectab].Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group 중 한개 품목은 필수로 선택하셔야 하는 품목이 있습니다.")	
			Return -2	
		ElseIf cnt > 1 Then			
			f_msg_info(9000, Title, "동일Group 중 한개 품목만 필수로 선택하셔야 하는 품목이 있습니다.")	
			Return -2
		End If
		cnt = 0
	ElseIf ll_type[i] = 1 Then
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If tab_1.idw_tabpage[ai_selectab].Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group중 한 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2		
		End If
		cnt = 0
	ElseIf ll_type[i] = 2 Then
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If tab_1.idw_tabpage[ai_selectab].Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group중 두 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2			
		ElseIf cnt < 2 Then
			f_msg_info(9000, Title, "동일Group중 두 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2
		End If
		cnt = 0	
	ElseIf ll_type[i] = 8 Then  //동일품목모두선택필수 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				cnt_group++
				If tab_1.idw_tabpage[ai_selectab].Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt <> cnt_group Then
			f_msg_info(9000, Title, "동일Group중 모두 선택이 필수인 품목이 있습니다.")	
			Return -2			
		End If
		cnt = 0
		cnt_group = 0
   ElseIf ll_type[i] = 9 Then  //제한없음
	    //액션없음
	End If
Next


return 1   //정상 return
end function

public function integer wf_read_contno (string wfs_contno, integer wfl_row);/*------------------------------------------------------------------------	
	Desc.	: 	장비 contno
	Arg	:	String ls_contno
	Ret.	:	0 		Seccess
				-1 	Error
	Ver.	: 	1.0
---------------------------------------------------------------------------*/
Integer 	li_cnt, li_rows
Long 		ll_adseq, ll_old_adseq = 0, 	ll_iseqno, ll_row
String 	ls_adtype, ls_contno, ls_serialno

String 	ls_modelno, ls_modelnm, ls_status, ls_status2, &
			ls_itemcod, ls_saledt,	ls_modelno_de,	ls_itemcod_de,	ls_desc
String  	ls_sale_modelcd /*판매모델*/, ls_entstore /*입고처*/, ls_settle_partner /*개통처*/
DEC{2}	ldc_saleamt


ls_contno = wfs_contno
ls_saledt = String(dw_cond.object.requestdt[1],'yyyymmdd')//String(fdt_get_dbserver_now(), 'yyyymmdd')
//ls_status = fs_get_control("E1", "A100", ls_desc)
//2010.05.19 CJH 수정. Moving Goods 빼고 Returning Goods를 넣음...
ls_status = fs_get_control("E1", "A102", ls_desc)
ls_status2= fs_get_control("E1", "A104", ls_desc)
ls_modelno_de = Trim(dw_detail.object.modelno[wfl_row])
ls_itemcod_de = Trim(dw_detail.object.itemcod[wfl_row])


//messagebox("test","test")
//Select count(*)	Into :li_cnt	From admst
//Where  contno = :ls_contno;
//

Select count(*)	Into :li_cnt	From admst
Where  contno = :ls_contno
and    status in ( :ls_status, :ls_status2 )
and    mv_partner = :gs_shopid;

//Data Not Fount
If li_cnt = 0 Then	
 	f_msg_usr_err(201, Title, "control No")
	dw_detail.Object.contno[wfl_row] = "" 
	Return - 1
End If

//해당 정보 가져오기
//1. ADMST의 MODELNO Read
SELECT ADSEQ, 				trim(MODELNO), 		trim(itemcod),  trim(status), ISEQNO,
       adtype, 			mv_partner, 			serialno, 		entstore
  INTO :ll_adseq, 		:ls_modelno, 			:ls_itemcod, 	 :ls_status,	:ll_iseqno,
       :ls_adtype, 		:is_partner, 			:ls_serialno	,:ls_entstore
  FROM ADMST
 WHERE CONTNO = :ls_contno  ;
 
//ITEMMST : 'R'(SOLD) 
SELECT count(A.ITEMCOD)
  INTO :li_rows
  FROM ITEMMST A, ADMODEL_ITEM B
 WHERE A.ITEMCOD = B.ITEMCOD
	AND A.ITEMCOD  = :ls_itemcod
	AND A.QUOTA_YN = 'R';
	
 IF SQLCA.SQLCode < 0 THEN
		f_msg_sql_err(Title, "Itemmst Select Error(ITEMCOD)")
		Return -1
 ELSE
	IF li_rows > 0 THEN
		 
		//장비모델 셋팅 확인
			SELECT A.MODELNO
			     , A.MODELNM
				  , trim(A.sale_modelcd)
			  INTO :ls_modelno
			     , :ls_modelnm
				  , :ls_sale_modelcd 
		     FROM ADMODEL A
			     , ADMODEL_ITEM B
		    WHERE A.MODELNO = B.MODELNO
			   AND B.ITEMCOD = :ls_itemcod;
				
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, Title, "장비모델 Select Error")
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, Title, "서비스에 해당하는 장비모델이 없습니다.")
				Return -1
			Else
				//Price read
				select sale_unitamt, sale_item  INto :ldc_saleamt, :ls_itemcod
				  from model_price
				 where modelno =  :ls_modelno
					AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
																	  FROM model_price
																	 WHERE modelno =  :ls_modelno
																		AND to_char(fromdt, 'yyyymmdd') <= :ls_saledt ) ;
																		
				
				IF IsNull(ldc_saleamt) then ldc_saleamt = 0
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(Title, "Select Error(model_price)")
					Return  -1
				End If
				
				dw_detail.object.adseq[wfl_row] 		= ll_adseq
				dw_detail.object.adtype[wfl_row] 	= ls_adtype
				dw_detail.object.itemcod[wfl_row] 	= ls_itemcod
				dw_detail.object.modelno[wfl_row] 	= ls_modelno
				dw_detail.object.modelnm[wfl_row] 	= ls_modelnm
				dw_detail.object.sale_amt[wfl_row] 	= ldc_saleamt
				dw_detail.object.CONTNO[wfl_row]		= ls_contno 
				dw_detail.object.serialno[wfl_row]	= ls_serialno
				dw_detail.object.sale_modelcd[wfl_row]	= ls_sale_modelcd
				dw_detail.object.entstore[wfl_row]   = ls_entstore
				
				//개통처세팅
//				SELECT REF_CODE1 INTO :ls_settle_partner
//				FROM SYSCOD2T
//				WHERE GRCODE = 'B816'
//				  AND CODE = :ls_entstore;

				//개통처세팅
				SELECT CODE INTO :ls_settle_partner
				FROM SYSCOD2T
				WHERE GRCODE = 'ZM300'
				  AND REF_CODE1 = :ls_adtype;

				If SQLCA.SQLCode <> 0 Then
					f_msg_sql_err(Title, "Select Error(ls_settle_partner)")
					Return  -1
				End If
				
				dw_cond.object.settle_partner[1] = ls_settle_partner
				dw_detail.object.settle_partner[wfl_row]   = ls_settle_partner
				
				dw_detail1.object.sale_modelcd[1]	= ls_sale_modelcd  //단말할부 모델
			End If 	
	END IF
 END IF


								

return 0
end function

public function integer wf_mobile_sales (long row, string as_modelcd, string as_priceplan, integer ai_month, string as_fromdt); string ls_itemcod
 decimal ld_saleamt, ld_stdamt
 long ll_row
 
// if isnull(ai_month) then ai_month = 1
 
 //기준금액(일시불)
 SELECT SALEAMT into :ld_stdamt FROM PRICEPLAN_RATE_MOBILE
			WHERE SALE_MODELCD = :as_modelcd
				  AND PRICEPLAN = :as_priceplan
				  AND MTH = 1
				  AND FROMDT = (SELECT MAX(FROMDT) FROM PRICEPLAN_RATE_MOBILE 
													  WHERE   SALE_MODELCD = :as_modelcd  
															AND PRICEPLAN = :as_priceplan  
															AND MTH = :ai_month 
															AND FROMDT <= :as_fromdt);
															
															
//If SQLCA.SQLCode = 100 then
//		f_msg_sql_err(Title, "판매 정책이 등록되어 있지 않아 금액을 불러올 수 없습니다. 관리자에게 문의하세요")
//		//Return  -1
//End If
																	
 //할부															
 SELECT SALEAMT, ITEMCOD into :ld_saleamt, :ls_itemcod FROM PRICEPLAN_RATE_MOBILE
			WHERE SALE_MODELCD = :as_modelcd
				  AND PRICEPLAN = :as_priceplan
				  AND MTH = :ai_month
				  AND FROMDT = (SELECT MAX(FROMDT) FROM PRICEPLAN_RATE_MOBILE 
													  WHERE   SALE_MODELCD = :as_modelcd  
															AND PRICEPLAN = :as_priceplan  
															AND MTH = :ai_month 
															AND FROMDT <= :as_fromdt);
															
//If SQLCA.SQLCode <> 0 Then
//		f_msg_sql_err(Title, "Select Error(할부금액)")
//		//Return  -1
//elseif SQLCA.SQLCode = 100 then
//		f_msg_sql_err(Title, "판매 정책이 등록되어 있지 않아 금액을 불러올 수 없습니다. 관리자에게 문의하세요")
//		//Return  -1
//End If															
															
if ai_month = 1 then			//일시불이면 모델아이템 가져오기														
			SELECT B.ITEMCOD  into :ls_itemcod FROM ADMODEL A, ADMODEL_ITEM B
			WHERE A.MODELNO = B.MODELNO
				AND A.SALE_MODELCD = :as_modelcd;
end if		
	
dw_detail1.object.sale_amt[row] = ld_stdamt
dw_detail1.object.pay_amt[row] = ld_saleamt
dw_detail1.object.itemcod[row] = ls_itemcod

		
return 0
end function

on mobile_w_reg_activeorder_new.create
int iCurrent
call super::create
this.gb_3=create gb_3
this.gb_2=create gb_2
this.dw_detail1=create dw_detail1
this.dw_item=create dw_item
this.uo_1=create uo_1
this.dw_detail=create dw_detail
this.p_1=create p_1
this.gb_4=create gb_4
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_3
this.Control[iCurrent+2]=this.gb_2
this.Control[iCurrent+3]=this.dw_detail1
this.Control[iCurrent+4]=this.dw_item
this.Control[iCurrent+5]=this.uo_1
this.Control[iCurrent+6]=this.dw_detail
this.Control[iCurrent+7]=this.p_1
this.Control[iCurrent+8]=this.gb_4
end on

on mobile_w_reg_activeorder_new.destroy
call super::destroy
destroy(this.gb_3)
destroy(this.gb_2)
destroy(this.dw_detail1)
destroy(this.dw_item)
destroy(this.uo_1)
destroy(this.dw_detail)
destroy(this.p_1)
destroy(this.gb_4)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	mobile_w_reg_activeorder
	Desc	: 	서비스 개통신청
	Ver.	:	2.0
	Date	:  2015.02.20
	Programer : HMK
-------------------------------------------------------------------------*/
//call w_a_condition::open

String ls_ref_desc, ls_temp, &
		 ls_memberid, ls_customernm

iu_cust_db_app = Create u_cust_db_app


SetRedraw(True)

//수정불가능
dw_cond.object.priceplan.Protect 	   = 1
dw_cond.object.svccod.Protect 		   = 1


//날짜 Setting
dw_cond.object.orderdt[1] 				= Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] 				= gs_SHOPid
dw_cond.object.reg_partner[1] 		= gs_SHOPid
dw_cond.object.sale_partner[1] 		= gs_SHOPid
dw_cond.object.maintain_partner[1] 	= gs_SHOPid



IF gs_onOff = '1' then 
   wfi_get_customerid(gs_cid, "")
   dw_cond.object.svccod.Protect = 0
	gs_onOff = '0'
END IF

il_orderno = 0

uo_1.Hide()
ii_enable_max_tab = 6 //MAX tab 갯수
//TriggerEvent("ue_reset")
p_reset.TriggerEvent("ue_enable")

p_insert.visible = false
p_delete.visible = false

dw_detail.Enabled = False
dw_detail1.Enabled = False
tab_1.Enabled = False

p_1.visible = false  //요금확인

gb_4.visible = false
dw_item.visible = false








end event

event ue_ok;//해당 서비스에 해당하는 품목 조회
String 	ls_svccod, 		ls_priceplan, 		ls_customerid, &
			ls_partner, 	ls_requestdt,		ls_where,&
			ls_contract_no,		ls_sysdt,				&
			ls_result[],	ls_selfequip, ls_settle_partner, ls_serialno, ls_modelno
Long 		ll_row, 			ll_result,			ll_hot_cnt,				ll_cnt,					&
			ll_status_cnt
Int 	   li_cnt, i

ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_requestdt    = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_customerid   = Trim(dw_cond.object.customerid[1])
ls_svccod       = Trim(dw_cond.object.svccod[1])
ls_priceplan    = Trim(dw_cond.object.priceplan[1])
ls_partner      = Trim(dw_cond.object.partner[1])
ls_selfequip	 = Trim(dw_cond.object.selfequip[1])
ls_settle_partner	 = Trim(dw_cond.object.settle_partner[1])
ls_serialno			= Trim(dw_cond.object.serialno[1])
ls_modelno			= Trim(dw_cond.object.modelno[1])

If IsNull(ls_customerid) 		Then ls_customerid 		= ""
If IsNull(ls_svccod) 			Then ls_svccod 			= ""
If IsNull(ls_priceplan) 		Then ls_priceplan 		= ""
If IsNull(ls_requestdt) 		Then ls_requestdt 		= ""
If IsNull(ls_partner) 			Then ls_partner 			= ""
If IsNull(ls_selfequip) 		Then ls_selfequip 		= "N"
If IsNull(ls_settle_partner) 		Then ls_settle_partner 		= ""
If IsNull(ls_serialno) 		Then ls_serialno 		= ""
If IsNull(ls_modelno) 		Then ls_modelno 		= ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	ll_row = wfi_get_customerid(ls_customerid, "")		//올바른 고객인지 확인
	If ll_row = -1 Then Return
End If


SELECT COUNT(*) INTO :ll_hot_cnt
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_customerid
AND    HOTBILLFLAG IN ('S', 'E');

IF ll_hot_cnt > 0 THEN
	f_msg_info(200, Title, "Hot Bill 이력이 있어서 개통이 불가합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
END IF


If ls_requestdt = "" Then
	f_msg_info(200, Title, "개통요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If

If ls_requestdt < ls_sysdt Then
	f_msg_usr_err(210, Title, "개통요청일은 오늘날짜 이상이여야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If		


If ls_svccod = "" Then
//	f_msg_info(200, Title, "신청서비스")
	dw_cond.SetFocus()
	dw_cond.Setrow(1)
	dw_cond.SetColumn("svccod")
	Return
End If

If ls_priceplan = "" Then
	f_msg_info(200, Title, "Price Plan")
	dw_cond.SetFocus()
	dw_cond.Setrow(1)
	dw_cond.SetColumn("priceplan")
	Return
End If

if ls_selfequip = 'Y' then
		If ls_settle_partner = "" Then
			f_msg_info(200, Title, "자가폰의 경우에는 개통처를 선택하세요.")
			dw_cond.SetFocus()
			dw_cond.Setrow(1)
			dw_cond.SetColumn("settle_partner")
			Return
		End If
		
		If ls_serialno = "" Then
			f_msg_info(200, Title, "자가폰의 경우에는 serialno를 입력하세요.")
			dw_cond.SetFocus()
			dw_cond.Setrow(1)
			dw_cond.SetColumn("serialno")
			Return
		End If
		
		If ls_modelno = "" Then
			f_msg_info(200, Title, "자가폰의 경우에는 modelno를 입력하세요.")
			dw_cond.SetFocus()
			dw_cond.Setrow(1)
			dw_cond.SetColumn("modelno")
			Return
		End If
		
end if

SetRedraw(False)

If ll_row >= 0 Then

	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.Enabled = true
	dw_detail.SetFocus()

	dw_cond.Enabled 		= False
	p_ok.TriggerEvent("ue_disable")
	
	gb_4.visible = true
	//dw_item.visible = true
	tab_1.Trigger Event ue_init()
	if ls_selfequip = 'Y' then //자가폰이면
	
			//검색을 찾으면 Tab를 활성화 시킨다.
			for i = 2 to ii_enable_max_tab //자가폰은 약정선택 안함
				tab_1.Trigger Event ue_tabpage_retrieve(i, i)
			next
			tab_1.SelectedTab = 2
			tab_1.Enabled = True
			dw_detail.Enabled = false

	else
			//검색을 찾으면 Tab를 활성화 시킨다.
			for i = 1 to ii_enable_max_tab
				tab_1.Trigger Event ue_tabpage_retrieve(1, i)
			next
			//tab_1.Enabled = True

	end if
	
	
End If

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
//dw_detail2.Setfocus()
end event

event ue_extra_insert;//Insert시 조건
DEC		lc_troubleno,		lc_num
LONG		ll_master_row,		ll_seq,			i,			ll_row
STRING	ls_partner

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1								//Tab 1
//		Select seq_troubleno.nextval 
//		Into :lc_num
//		From dual;
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select seq_troubleno.nextval")
//			RollBack;
//			Return -1
//		End If	
		
//		SELECT CODENM INTO :ls_partner
//		FROM   SYSCOD2T
//		WHERE  GRCODE = 'B333'
//		AND    CODE = :gs_shopid;
		
//		IF IsNull(ls_partner) OR ls_partner = '' THEN ls_partner = "A100013"   //없으면 빌링센터로 기본..
//				
//		tab_1.idw_tabpage[1].object.customer_trouble_troubleno.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_customerid.Protect     = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_cregno.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_pid.Protect            = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_contractseq.Protect    = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_validkey.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_svccod.Protect         = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_priceplan.Protect      = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_requestdt.Protect      = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user.Protect   = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_trouble_note.Protect   = 0
//		tab_1.idw_tabpage[1].object.troubletypeb_troubletypec.Protect       = 0
//		tab_1.idw_tabpage[1].object.troubletypea_troubletypeb.Protect       = 1
//		tab_1.idw_tabpage[1].object.troubletypemst_troubletypea.Protect     = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_troubletype.Protect    = 1
//		tab_1.idw_tabpage[1].object.partner_auth.Protect                    = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_trouble_status.Protect = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sms_yn.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_email_yn.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_partner.Protect        = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_send_msg.Protect       = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.Protect  = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_sendno.Protect         = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_country.Protect        = 0	
////		tab_1.idw_tabpage[1].object.customer_trouble_partner.Protect        = 0	
//	   tab_1.idw_tabpage[1].object.customer_trouble_troubleno[al_insert_row]    = lc_num	//Trouble Num Setting
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user[al_insert_row] = gs_user_id //접수자
//		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt[al_insert_row]    = fdt_get_dbserver_now() //date
////		tab_1.idw_tabpage[1].object.customer_trouble_requestdt[al_insert_row]    = fd_date_next(Date(fdt_get_dbserver_now()),0) //date
//		tab_1.idw_tabpage[1].object.customer_trouble_requestdt[al_insert_row]    = fdt_get_dbserver_now() //date
//		//Log
//		tab_1.idw_tabpage[1].object.customer_trouble_crt_user[al_insert_row] = gs_user_id
//		tab_1.idw_tabpage[1].object.customer_trouble_crtdt[al_insert_row]    = fdt_get_dbserver_now()
//		tab_1.idw_tabpage[1].object.customer_trouble_pgm_id[al_insert_row]   = gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[1].object.customer_trouble_updt_user[1]            = gs_user_id
//		tab_1.idw_tabpage[1].object.customer_trouble_updtdt[1]               = fdt_get_dbserver_now()
//		//receipt_partner 항목에 로그인샵으로 변경 요청함 - 이윤주 대리(2011.09.21)
//		//현재는 파라미터로 open시 전달받은 user를 sysusr1t의 emp_group으로 처리하고 있었음.
//		//2011.09.22 kem modify
////		tab_1.idw_tabpage[1].object.customer_trouble_receipt_partner[1]      = gs_user_group
//		tab_1.idw_tabpage[1].object.customer_trouble_receipt_partner[1]      = GS_ShopID
//		
////		tab_1.idw_tabpage[1].object.customer_trouble_partner[1]     		   = gs_user_group		
//		tab_1.idw_tabpage[1].object.customer_trouble_partner[1]     		   = ls_partner		
////		customer_trouble_receipt_partner
	Case 2							   //Tab 2
		
//		If ll_master_row = 0 Then Return -1
//		lc_troubleno = dw_master.object.troubleno[ll_master_row]
//		
//		//Seq Number
//		Select nvl(max(seq) + 1, 1)
//		Into :ll_seq
//		From troubl_response
//		Where troubleno = :lc_troubleno ;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Seq")
//			RollBack;
//			Return -1
//		End If				
//		
//		//Seq 비교 확인
//		ll_row = tab_1.idw_tabpage[2].RowCount()
//		If ll_row <> 0 Then
//			For i = 1 To ll_row
//				//seq number 이 같으면
//				If ll_seq = tab_1.idw_tabpage[2].object.troubl_response_seq[i] Then
//					ll_seq += 1
//				End If	
//			Next
//		End If	
//		
//		//모든 row 를 삭제하고 다시 insert할때.
////		If al_insert_row = 1 Then
////			tab_1.idw_tabpage[2].object.customer_trouble_troubleno[al_insert_row] = &
////				lc_troubleno
////			tab_1.idw_tabpage[2].object.customer_trouble_troubletype[al_insert_row] = &
////				dw_master.object.customer_trouble_troubletype[ll_master_row]
////			tab_1.idw_tabpage[2].object.customer_trouble_customerid[al_insert_row] = &
////				dw_master.object.customer_trouble_customerid[ll_master_row]
////			tab_1.idw_tabpage[2].object.customer_trouble_note[al_insert_row] = &
////			 	dw_master.object.customer_trouble_note[ll_master_row]
////		End If
//			
//		tab_1.idw_tabpage[2].object.troubl_response_seq[al_insert_row]            = ll_seq  //seq
//		tab_1.idw_tabpage[2].object.troubl_response_response_user[al_insert_row]  = gs_user_id //처리자
//		tab_1.idw_tabpage[2].object.troubl_response_responsedt[al_insert_row]     = Date(fdt_get_dbserver_now()) //date
//		tab_1.idw_tabpage[2].object.troubl_response_partner[al_insert_row]        = gs_user_group //조치자의 Parter
//		tab_1.idw_tabpage[2].object.troubl_response_troubleno[al_insert_row]      = lc_troubleno
//		tab_1.idw_tabpage[2].object.close_yn[al_insert_row]                       = is_closeyn  //처리완료
//		tab_1.idw_tabpage[2].object.troubl_response_trouble_status[al_insert_row] = is_trouble_status //master에 있는 내용
//		tab_1.idw_tabpage[2].object.partner[al_insert_row]                        = is_partner
//		//Log
//		tab_1.idw_tabpage[2].object.troubl_response_crt_user[al_insert_row]  = gs_user_id
//		tab_1.idw_tabpage[2].object.troubl_response_crtdt[al_insert_row]     = fdt_get_dbserver_now()
//		tab_1.idw_tabpage[2].object.troubl_response_pgm_id[al_insert_row]    = gs_pgm_id[gi_open_win_no]
//		tab_1.idw_tabpage[2].object.troubl_response_updt_user[al_insert_row] = gs_user_id	
//		tab_1.idw_tabpage[2].object.troubl_response_updtdt[al_insert_row]    = fdt_get_dbserver_now()
//
//		tab_1.idw_tabpage[2].SetColumn("troubl_response_response_note")
//		tab_1.idw_tabpage[2].SetFocus()
//			
	
End Choose

Return 0 
end event

event ue_reset;call super::ue_reset;String ls_ref_desc, ls_temp
Int li_rc, li_ret

//ii_error_chk = -1

//p_save.PictureName = "Active_e.gif"
//
dw_detail.AcceptText()

//If dw_detail.ModifiedCount() > 0 or &
//	dw_detail.DeletedCount() > 0 or &
//	dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0  then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = -1 
			li_ret = Event ue_save()
			If Isnull( li_ret ) or li_ret < 0 then return -1
		CASE 2

		CASE ELSE
			Return -1
	END CHOOSE
		
end If
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_detail.insertrow(0)
dw_detail1.Reset()
dw_detail1.insertrow(0)
dw_item.Reset()


dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetColumn("customerid")
dw_cond.SetFocus()


//ii_error_chk = 0

dw_cond.object.priceplan.Protect 	= 1
dw_cond.object.svccod.Protect 		= 1

dw_cond.object.orderdt[1] 				= Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] 			= fdt_get_dbserver_now()
dw_cond.object.partner[1] 				= gs_SHOPid
dw_cond.object.reg_partner[1] 		= gs_SHOPid
dw_cond.object.sale_partner[1] 		= gs_SHOPid



// 2008-02-21 스케쥴 인덱스 리셋 hcjung
GL_SCHEDULSEQ = 0

// 2009-07-04 스케쥴 인덱스 리셋 CJH
il_SCHEDULESEQ = 0


il_orderno = 0

SetRedraw(False)

dw_cond.Enabled = true
dw_detail.Enabled 		= False
dw_detail1.Enabled 		= False
tab_1.Enabled 		= False
st_horizontal.Visible 	= False
gb_4.visible = false
dw_item.visible = false
p_1.visible = false  //요금확인

//of_ResizeBars()
//of_ResizePanels()


SetRedraw(True)


return 0
end event

event ue_extra_delete;////Delete 조건
//Dec lc_troubleno
//Long ll_master_row, ll_cnt
//String ls_receipt_user, ls_troubletype
//Integer li_check = 1
//
//ll_master_row = dw_master.GetRow()
//If ll_master_row = 0 Then  Return 0    //삭제 가능
//
//Choose Case tab_1.SelectedTab
//	Case 1						//Tab
//		lc_troubleno = dw_master.object.troubleno[ll_master_row]
//		ls_receipt_user = dw_master.object.receipt_user[ll_master_row]	
//		ls_troubletype = dw_master.object.troubletype[ll_master_row]		
//		
////		=========================================================================================
////		2008-03-05 hcjung				
////		보스 연동 대상인 장애는 삭제할 수 없다. 
////		=========================================================================================	
//		SELECT COUNT(*) 
//		  INTO :li_check
//		  FROM TROUBLE_BOSS 
//		 WHERE USE_YN = 'Y'
//		   AND TROUBLETYPE = :ls_troubletype;
//
//		IF SQLCA.SQLCode < 0 THEN
//			f_msg_sql_err(This.Title,"TROUBLETYPE Select Error")
//			Return -1
//		END IF	
//		
//		IF  li_check > 0 THEN
//			f_msg_usr_err(9000, Title, "삭제불가! 보스 연동 대상은 삭제할 수 없습니다.")  //삭제 안됨
//			RETURN -1
//		END IF	
//		
//		If ls_receipt_user <> gs_user_id Then
//			f_msg_usr_err(9000, Title, "삭제불가! 접수자만 삭제가능합니다.")  //삭제 안됨
//			Return -1
//		End if			
//		
//		//trouble_shoothing table에 해당 사항이 있으면 삭제 불가능
//		Select count(*)
//		Into :ll_cnt
//		From troubl_response
//		Where troubleno = :lc_troubleno;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Error")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "삭제불가! 민원처리건이 존재합니다.")  //삭제 안됨 
//			Return -1
//		Else 							
//			is_check = "DEL"							   //삭제 가능
//		End If
//		
//End Choose
//
Return 0 
end event

event ue_extra_save;Long    ll_row, ll_gubun[], ll_type[], ll_cnt, ll_cnt_1
Integer li_rc, i, j, p, ii, li_row
String  ls_chk, ls_validkey
Boolean ib_jon, ib_jon_1, lb_check = False, lb_check_2 = False

dw_master.AcceptText()
dw_item.AcceptText()
dw_detail1.AcceptText()

ubs_dbmgr_activeorder	lu_dbmgr

SetNull(il_contractseq)

li_row = dw_item.rowcount()
if li_row = 0 then 
	messagebox("금액확인", "금액확인을 눌러 확인 후 저장을 진행하세요")
	return -1
end if

//p_1.triggerevent(clicked!)

//저장
lu_dbmgr = Create ubs_dbmgr_activeorder
lu_dbmgr.is_caller   = "ubs_w_reg_activeorder%save"
lu_dbmgr.is_title    = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail               //단말기
lu_dbmgr.idw_data[3] = dw_detail1   	     	  //단말할부
lu_dbmgr.idw_data[4] = dw_item	   	     	  //품목
lu_dbmgr.is_data[1]  = gs_user_id
lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//lu_dbmgr.is_data[4]  = is_cus_status           //고객상태

lu_dbmgr.uf_prc_db_05()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	Return -1
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	Return -1
End If

If li_rc = -3 Then
	Destroy lu_dbmgr
	Return -1
End If

il_orderno = lu_dbmgr.il_data[1]

Destroy lu_dbmgr



Return 0
end event

event ue_save;String 	ls_quota_yn, 	ls_chk,				ls_customernm, 	ls_memberid, 	ls_priceplan
String 	ls_onefee,  	ls_bil,				ls_reqdt, 			ls_orderdt, 	ls_svccod
String	ls_customerid,	ls_itemcod
String	ls_sms_yn,		ls_cellphone,		ls_send_flag,		ls_cell,			ls_massage
String	ls_sender,		ls_sysdate,			ls_sms_msg
Long 		i, 				ll_row, 				j, 					k,					m
Long		ll_len,			ll_item_cnt
Int 		li_rc, 			tabno
Boolean 	lb_quota,	lb_direct
Double   ldc_basicamt,	ldc_total

Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

ls_svccod 		= Trim(dw_cond.Object.svccod[1])
ls_priceplan 	= Trim(dw_cond.Object.priceplan[1])
ls_customerid  = Trim(dw_cond.object.customerid[1])
ls_reqdt 		= String(dw_cond.object.requestdt[1], 'yyyymmdd')

This.Trigger Event ue_extra_save(li_rc)

//commit; test용

IF li_rc = 0 Then

	//=========================================
	//즉시불 처리 항목 여부 check
	// bilitem_yn = 'N' AND oneoffcharge_yn = 'Y'
	//=========================================
	lb_direct =  False
	iu_cust_msg = Create u_cust_a_msg
	m = 1
	ll_row = dw_item.RowCount()
	If ll_row = 0 Then Return 0
	ldc_total = 0
	For i = 1 To ll_row

		ls_itemcod  = Trim(dw_item.object.itemcod[i])
		ls_chk 		= Trim(dw_item.object.chk[i])
		//ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
		ls_onefee 	= Trim(dw_item.object.ONEOFFCHARGE_YN[i])
		ls_bil 		= Trim(dw_item.object.bilitem_yn[i])
		select oneoffcharge_yn, bilitem_yn 
		into :ls_onefee, :ls_bil
		from itemmst
		where itemcod = :ls_itemcod;
		
		If ls_onefee = 'Y' and ls_bil = 'N' Then
		//If ls_chk = "Y" AND ls_onefee = "Y" and ls_bil = 'N' Then
				IF ls_chk = "Y" THEN
					ldc_basicamt = 0
					select unitcharge  INto :ldc_basicamt
					from priceplan_rate2
					where priceplan = :ls_priceplan
					  AND itemcod   = :ls_itemcod
					 AND to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
																	  FROM priceplan_rate2
																	 WHERE priceplan = :ls_priceplan
																		AND itemcod	  = :ls_itemcod
																		AND to_char(fromdt, 'yyyymmdd') <= :ls_reqdt ) ;
																		
					IF Isnull(ldc_basicamt) THEN ldc_basicamt = 0
					
					
				elseif ls_chk = "M" THEN //장비와 연결된 아이템이거나, 약정품목인 경우는 priceplan_rate2가 아닌 미리 구해놓은 가격으로 처리한다.
					ldc_basicamt = dw_item.object.sale_amt[i]
				end if
				
				ldc_total = ldc_total + ldc_basicamt																
					
				lb_direct = True
				m++
		End If
	Next

	If lb_direct Then			//즉시불 처리
		ls_customerid 	= Trim(dw_cond.object.customerid[1])
		ls_reqdt 		= String(dw_cond.object.requestdt[1], 'yyyymmdd')
		//ls_memberid 	= Trim(dw_cond.object.memberid[1])
		iu_cust_msg.is_pgm_name = "서비스품목 장비 즉시불 등록"
		iu_cust_msg.is_grp_name = "서비스 신청"
		iu_cust_msg.ib_data[1]  = True
		iu_cust_msg.il_data[1]  = il_orderno					//order number
		iu_cust_msg.il_data[2]  = il_contractseq				//contractseq
		iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
		iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
		//iu_cust_msg.is_data[3] 	= ls_memberid 					//member ID
		iu_cust_msg.is_data[4] 	= ls_reqdt 			//
		iu_cust_msg.is_data[5] 	= ls_priceplan 				//가격정책
		iu_cust_msg.is_data[6] 	= ls_svccod 				//서비스
		
	   iu_cust_msg.idw_data[1] = dw_item
		OpenWithParm(b1w_reg_directpay_pop_sams, iu_cust_msg)
		
		IF iu_cust_msg.ib_data[1] THEN
			is_amt_check = iu_cust_msg.is_data[1]
		END IF
		
		IF is_amt_check = 'N' THEN
			li_rc = -3
		END IF	
		
	END IF
END IF
//-2 return 시 rollback되도록 변경 
//원인: 모든 신청메뉴에서 error에 대한 return값을 개념없이 rollback없는 -2값 사용에 대한 조치
If li_rc = -1 Or li_rc = -2 Or li_rc = -3 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"개통신청(처리)")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"개통신청(처리)")

	//SMS 자동 발송 처리...
	ls_send_flag = 'N'
	
	SELECT NVL(SMS_YN, 'N'), NVL(REPLACE(CELLPHONE, '-', ''), '') INTO :ls_sms_yn, :ls_cellphone
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :ls_customerid;
	
	IF ls_sms_yn = 'Y' THEN
		ll_len = LenA(ls_cellphone)
		
		IF ll_len < 10 OR ll_len > 11 THEN
			F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_cellphone)
			ls_send_flag = 'N'
		ELSE
			ls_cell = MidA(ls_cellphone, 1, 3)
			
			IF ls_cell <> '010' AND ls_cell <> '011' AND ls_cell <> '016' AND ls_cell <> '017' AND ls_cell <> '018' AND ls_cell <> '019' THEN
				F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_cellphone)
				ls_send_flag = 'N'
			ELSE
				ls_send_flag = 'Y'					
			END IF
		END IF
		
		IF ls_send_flag = 'Y' THEN		
			SELECT MESSAGE, SENDER INTO :ls_massage, :ls_sender
			FROM   SMS_MESSAGE
			WHERE  MSGCOD = 'A01';
			
			SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') INTO :ls_sysdate
			FROM   DUAL;
			
			ls_sms_msg = ls_massage + ' ' + MidA(ls_sysdate, 9, 2) + ':' + MidA(ls_sysdate, 11, 2)
			
			IF LenA(ls_sms_msg) > 80 THEN
				ls_sms_msg = MidA(ls_sms_msg, 1, 80 )
			END IF
			
			INSERT INTO SMS.SC_TRAN
				( TR_NUM, TR_SENDDATE, TR_SENDSTAT, TR_PHONE,
				  TR_CALLBACK, TR_MSG,	TR_MSGTYPE )
			VALUES ( SMS.SC_SEQUENCE.NEXTVAL, SYSDATE, '0', :ls_cellphone,
						:ls_sender, :ls_sms_msg, '0');
						
			IF SQLCA.SQLCode = -1 THEN 
				ROLLBACK;
				f_msg_sql_err(title, "INSERT ERROR! (SMS.SC_TRAN)")
			ELSE
				COMMIT;
			END IF	
		END IF	
	END IF			
	
End if

//저장한거로 인식하게 함.
For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next  

For i = 1 To dw_detail1.RowCount()
	dw_detail1.SetitemStatus(i, 0, Primary!, NotModified!)
Next 

for tabno = 1 to ii_enable_max_tab
		For i = 1 To tab_1.idw_tabpage[tabno].RowCount()
				tab_1.idw_tabpage[tabno].SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
		Next
next


p_save.TriggerEvent("ue_disable")		//버튼 비활성화
p_insert.TriggerEvent("ue_disable")		//버튼 비활성화
p_delete.TriggerEvent("ue_disable")		//버튼 비활성화

dw_detail.Enabled = False
dw_detail1.Enabled = False
tab_1.Enabled = False
p_1.visible = False




Return 0
end event

event type integer ue_insert();//tab2는 맨 마지막에만 insert 되어야 하므로... 조상 스크립트 수정!!

Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)		
		
	Case 2  //tab2는 항상 맨 마지막줄에 insert 시킨다... 
		
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].RowCount() + 1)		
End Choose

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0


end event

event resize;call super::resize;//
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within mobile_w_reg_activeorder_new
integer x = 91
integer y = 56
integer width = 3054
integer height = 588
string dataobject = "mobile_dw_reg_activeorder_cond"
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild 	ldc_priceplan, 	ldc_svcpromise, 		ldc_svccod,		ldc_modelprice, &
						ldc_vprice, 		ldc_validkey_type, 	ldc_wkflag2, ldc_related_order, ldc_sale_modelcd
Long 					li_exist, 			li_exist1,		li_exist2,		ll_i, 					ll_row, 		ll_svcctl_cnt
String 				ls_filter, 			ls_validkey_yn, 		ls_act_gu, 	ls_customerid, &
						ls_currency_type, ls_partner1, ls_salemodelcd, &
       				ls_customer_id, 	ls_svccode,				ls_sql
Boolean 				lb_check, 			lb_confirm
datetime 			ldt_date
Integer				il_acttype_cnt, relation_cnt


SetNull(ldt_date)

This.AcceptText()

Choose Case dwo.name
	Case "selfequip" 
   		is_selfequip = data
	Case "customerid" 
   	  wfi_get_customerid(data, "")
		  This.object.svccod.Protect = 0
	Case "requestdt" 

	Case "svccod"
			ls_customerid 	= Trim(This.object.customerid[1])
			is_svccode 		= data
		
			SELECT svctype	  INTO :is_svctype	  FROM svcmst
		 	 WHERE svccod = :data;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(parent.title, "SELECT svctype from svcmst")				
				Return 1
			END IF
		
			//고객의 납입자의 화폐단위 가져오기
			SELECT bil.currency_type INTO :ls_currency_type 
			  FROM billinginfo bil, customerm cus
			 WHERE bil.customerid = cus.payid 
			   AND cus.customerid = :ls_customerid;
		
			li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data  + &
			   "'  And  String(auth_level) 	>= '"  	+ String(gi_auth) 	+ &
				"'  And  currency_type 			='" 		+ ls_currency_type 	+ &
				"'  And  partner 					= '" 		+ gs_user_group 		+ "' " 

         This.object.priceplan[1] = ""

			
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
      
//			uo_1.Show()
//			istr_cal.caldate = Today()
//			uo_1.uf_InitCal(istr_cal.caldate)


         //dw_detail1 판매모델명 세팅
			li_exist1 	= dw_detail1.GetChild("sale_modelcd", ldc_sale_modelcd)		//DDDW 구함
			If li_exist1 = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 판매모델명")
			ls_filter = "svccod = '" + data  + "' " 

         dw_detail1.object.sale_modelcd[1] = ""
			
			ldc_sale_modelcd.SetTransObject(SQLCA)
			li_exist1 =ldc_sale_modelcd.Retrieve()
			ldc_sale_modelcd.SetFilter(ls_filter)			//Filter정함
			ldc_sale_modelcd.Filter()
		
			If li_exist1 < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			
	Case "priceplan"
			
			is_priceplan = data
		
			ls_svccode = Trim(This.object.svccod[1])		
			ls_customerid = Trim(This.object.customerid[1])
			
			
			ls_salemodelcd = dw_detail1.object.sale_modelcd[1]
			
			//dw_detail1 가격정책 세팅
			li_exist2 	= dw_detail1.GetChild("priceplan", ldc_modelprice)		//DDDW 구함
			If li_exist2 = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 판매모델별 가격정책")
			ls_filter = "b.svccod = '" + ls_svccode  + &
			            "'and a.sale_modelcd = '" +ls_salemodelcd + "' " 

         dw_detail1.object.priceplan[1] = ""
			
			ldc_modelprice.SetTransObject(SQLCA)
			li_exist2 =ldc_modelprice.Retrieve()
			ldc_modelprice.SetFilter(ls_filter)			//Filter정함
			ldc_modelprice.Filter()
		
			If li_exist2 < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
			//dw_detail1 가격정책 세팅
			dw_detail1.object.priceplan[1] = data
			
						
End Choose	
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
			is_cus_status 				= dw_cond.iu_cust_help.is_data[3]
					
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 Then
				return -1
			End IF
		End If
		dw_cond.object.svccod.Protect = 0		
  Case "reg_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			dw_cond.Object.reg_partner[row] = &
			dw_cond.iu_cust_help.is_data[1]
			dw_cond.Object.reg_partnernm[row] = &
			dw_cond.iu_cust_help.is_data[1]
		End If

End Choose

Return 0 
end event

event dw_cond::ue_init;//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"


dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')

end event

event dw_cond::ue_key;string ls_customerid

Choose Case key
	Case KeyEnter!
		if this.getcolumnname() = 'customerid' then
			Send(Handle(this), 256, 9, 0)  //엔터키를 탭처럼
		end if
	Case KeyEscape!
		Parent.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose


end event

type p_ok from w_a_reg_m_tm2`p_ok within mobile_w_reg_activeorder_new
integer x = 3159
integer y = 116
end type

type p_close from w_a_reg_m_tm2`p_close within mobile_w_reg_activeorder_new
integer x = 3163
integer y = 244
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within mobile_w_reg_activeorder_new
integer x = 27
integer width = 3506
integer height = 660
integer taborder = 0
borderstyle borderstyle = stylebox!
end type

type dw_master from w_a_reg_m_tm2`dw_master within mobile_w_reg_activeorder_new
boolean visible = false
integer y = 620
integer width = 2688
integer height = 244
integer taborder = 30
end type

event dw_master::itemchanged;DataWindowChild ldc_child, ldc
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

event dw_master::constructor;call super::constructor;this.SetRowFocusIndicator(off!)

is_selfequip = dw_cond.object.selfequip[1]


IF is_selfequip = "UBS" THEN //UBS폰
	this.dataobject = 'mobile_cnd_reg_quotainfo_pop_ad_v20_sams'
ELSE                         //자가폰
	this.dataobject = 'mobile_cnd_reg_self_ad_v20_sams'	
END IF
end event

event dw_master::retrieveend;call super::retrieveend;//Setting
Long ll_row, i
ll_row = this.RowCount()
//임대여서 자료 없을때
If ll_row = 0 Then 
	dw_cond.object.cnt[1] = 1
	Return 0
End If

dw_cond.object.cnt[1] = ll_row
For i = 1 To ll_row
	this.object.amt[i] = this.object.sale_amt[i]
Next
If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

Return 0
end event

type p_insert from w_a_reg_m_tm2`p_insert within mobile_w_reg_activeorder_new
integer y = 2396
end type

type p_delete from w_a_reg_m_tm2`p_delete within mobile_w_reg_activeorder_new
integer y = 2396
end type

type p_save from w_a_reg_m_tm2`p_save within mobile_w_reg_activeorder_new
integer x = 622
integer y = 2396
end type

type p_reset from w_a_reg_m_tm2`p_reset within mobile_w_reg_activeorder_new
integer x = 914
integer y = 2396
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within mobile_w_reg_activeorder_new
integer x = 32
integer y = 1364
integer width = 3543
integer height = 996
integer taborder = 40
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 6 //사용할 Tab Page의 갯수 (15 이하)

//priceplandet	,	groupno
//기본료			,	1
//보증금			,	2
//개통비			,	3
//부가서비스	,	4
//기기판매 		,	5
//약정			,	6
//할부			, 	7
//기본료 2		,	8


is_tab_title[1] = "약정"    //6
is_tab_title[2] = "개통비"  //3
is_tab_title[3] = "보증금"  //2
is_tab_title[4] = "기본료"  //1
is_tab_title[5] = "중지기본료"  //8
is_tab_title[6] = "부가서비스"  //4
//is_tab_title[1] = "기기판매"    //5
//is_tab_title[2] = "할부"  		//7

is_dwobject[1] = "mobile_dw_reg_activeorder_con"
is_dwobject[2] = "mobile_dw_reg_activeorder_mas"
is_dwobject[3] = "mobile_dw_reg_activeorder_mas"
is_dwobject[4] = "mobile_dw_reg_activeorder_mas"
is_dwobject[5] = "mobile_dw_reg_activeorder_mas"
is_dwobject[6] = "mobile_dw_reg_activeorder_mas"




end event

event tab_1::ue_tabpage_retrieve;

long ll_row
string ls_priceplan, ls_svccod



tab_1.idw_tabpage[ai_select_tabpage].SetRowFocusIndicator(off!)




//is_tab_title[1] = "약정"    //6
//is_tab_title[2] = "개통비"  //3
//is_tab_title[3] = "보증금"  //2
//is_tab_title[4] = "기본료"  //1
//is_tab_title[5] = "기본료1"  //8
//is_tab_title[6] = "부가서비스"  //4


//IF al_master_row = 0 THEN RETURN -1		//해당 정보 없음

tab_1.idw_tabpage[ai_select_tabpage].accepttext()
ls_priceplan = dw_cond.object.priceplan[1]


CHOOSE CASE ai_select_tabpage
	CASE 1								//Tab 1
		
		ls_svccod = dw_cond.object.svccod[1]
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_svccod)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
	CASE 2								//Tab 2
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_priceplan,3)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
	CASE 3								//Tab 3
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_priceplan,2)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
	CASE 4								//Tab 4
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_priceplan,1)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
	
	CASE 5								//Tab 5
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_priceplan,8)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		
	CASE 6								//Tab 6
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve(ls_priceplan,4)	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			RETURN -1
		END IF
		

		
END CHOOSE



RETURN 0 
		

		
end event

event tab_1::ue_itemchanged;
integer li_seltab, i
long ll_groupno, ll_grouptype, ll_row
dec ld_saleamt
date ld_reqdt
string ls_priceplan, ls_requestdt, ls_itemcod, ls_paytype

li_seltab = tab_1.SelectedTab

CHOOSE CASE li_seltab
	CASE 1
		
		ls_paytype = dw_detail1.object.pay_type[1]
		if isnull(ls_paytype) or ls_paytype = '' then
			messagebox("선택", "일시불이나 할부를 선택하세요")
			return -1
		end if
		
		ls_itemcod = tab_1.idw_tabpage[li_seltab].object.itemcod[row]
		ld_saleamt = 0	
		
		
	CASE 2,3,4													//Tab 1
		CHOOSE CASE dwo.name
			CASE "chk"
				
							
		END CHOOSE		
	CASE 5,6
		p_1.visible = True  //요금확인 활성화
END CHOOSE


if dw_item.rowcount() > 0 then  // 이미 요금확인을 했는데 변경을 했으면, 다시 요금확인하도록 reset()
	dw_item.reset()
end if


return 0
end event

event tab_1::selectionchanging;int li_rtn, li_seq, li_return, i

string ls_fromdt, ls_svccode, ls_pay_type, ls_itemcod, ls_chk, ls_p_itemcod, ls_penalty_cd
integer li_ret, li_i, li_sale_month, li_install_mon

ib_update = true


ls_svccode = Trim(dw_cond.object.svccod[1])
if 	isnull(ls_svccode) or ls_svccode = ''  then return

For i = 1 To tab_1.idw_tabpage[newindex].RowCount()
		tab_1.idw_tabpage[newindex].SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
Next

li_ret = wf_itemcod_chk(oldindex)
IF li_ret <= 0 Then

	Return 1
End IF

//단말할부개월수 <= 약정할부개월수 START
ls_pay_type		= dw_detail1.object.pay_type[1]   //할부
li_sale_month	= integer(dw_detail1.object.sale_month[1]) //단말할부개월수
ls_p_itemcod 	= dw_detail1.object.p_itemcod[1]
ls_penalty_cd = dw_detail1.object.penalty_cd[1]
if is_selfequip = 'N' and ls_penalty_cd = 'P' and (isnull(ls_p_itemcod) or ls_p_itemcod = '') Then
	messagebox("위약품목","위약품목을 선택하세요")
	Return 1
end if

IF ls_pay_type = 'M' THEN   //할부일때
	For li_i = 1 To tab_1.idw_tabpage[1].RowCount()
		ls_itemcod = tab_1.idw_tabpage[1].object.itemcod[li_i]
		ls_chk = tab_1.idw_tabpage[1].object.chk[li_i]
		if ls_chk = 'Y' THEN
			select to_number(ref_code1) into :li_install_mon
			from syscod2t
			where grcode = 'ZM104'
			  and code = :ls_itemcod;
			 
			if li_install_mon < li_sale_month  THEN
						messagebox("약정개월수", " 단말할부개월수(" + string(li_sale_month) + ")는 약정개월수 (" + string(li_install_mon) + ")  보다 작아야 합니다")
						Return 1
			end if
		END IF
	Next
END IF
//단말할부개월수 <= 약정할부개월수 END

if newindex = 5 then
	p_1.visible = True  //요금확인 활성화
end if

end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within mobile_w_reg_activeorder_new
integer y = 1328
end type

type gb_3 from groupbox within mobile_w_reg_activeorder_new
integer x = 23
integer y = 1004
integer width = 3511
integer height = 328
integer taborder = 50
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 255
long backcolor = 29478337
string text = "단말할부"
end type

type gb_2 from groupbox within mobile_w_reg_activeorder_new
integer x = 23
integer y = 676
integer width = 3506
integer height = 312
integer taborder = 60
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 255
long backcolor = 29478337
string text = "장비등록"
end type

type dw_detail1 from u_d_indicator within mobile_w_reg_activeorder_new
integer x = 50
integer y = 1052
integer width = 3447
integer height = 260
integer taborder = 70
boolean bringtotop = true
string dataobject = "mobile_dw_reg_activeorder_gr2"
boolean hscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;
this.SetRowFocusIndicator(off!)

this.insertrow(0)
if is_selfequip = 'N' then  //UBS 폰일때만 단말 판매 활성화
	this.enabled = true
else 
	this.enabled = false
end if
end event

event itemchanged;call super::itemchanged;string as_salemodelcd, as_priceplan, as_fromdt, ls_itemcod, ls_svccod, ls_penalty_cd, ls_filter
integer ai_month, li_ret, i, li_exist, li_exist1
decimal ld_saleamt
long ll_row
datawindowchild ldc_p_itemcod
datawindowchild ldc_month

string ls_pay_type, ls_chk
integer li_i, li_install_mon, li_sale_month


if row <= 0 then return -1


as_salemodelcd = this.object.sale_modelcd[row]
as_priceplan = this.object.priceplan[row]
ai_month = this.object.sale_month[row]


//as_fromdt        = String(fdt_get_dbserver_now(),'yyyymmdd')
as_fromdt    = String(dw_cond.object.requestdt[1],'yyyymmdd')

CHOOSE CASE dwo.name
	CASE 'sale_modelcd'
		
		 li_ret = wf_mobile_sales(row, data, as_priceplan, ai_month, as_fromdt)
		 if li_ret = -1 then   return -1
		
	CASE 'priceplan'
		
		li_ret = wf_mobile_sales(row, as_salemodelcd, data, ai_month, as_fromdt)
		if li_ret = -1 then   return -1

	CASE 'pay_type'
		
		li_exist 	= This.GetChild("sale_month", ldc_month)		//DDDW 구함
		If li_exist1 = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 할부개월수")
			
		if data = 'S' then //일시불이면 일시불..
			
			li_ret = wf_mobile_sales(row, as_salemodelcd, as_priceplan, 1, as_fromdt)
			if li_ret = -1 then   return -1
			
			this.object.sale_month[1] = 1
			
			ls_filter = "CODE  = '1'"  //일시불만
					
			ldc_month.SetTransObject(SQLCA)
			li_exist1 =ldc_month.Retrieve()
			ldc_month.SetFilter(ls_filter)			//Filter정함
			ldc_month.Filter()
		
			If li_exist1 < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
				Return 1  		//선택 취소 focus는 그곳에
			End If  
			
		else
			if this.getitemnumber(row, 'sale_month') = 1 then this.setitem(1, 'sale_month', 12)
			li_ret = wf_mobile_sales(row, as_salemodelcd, as_priceplan, 12, as_fromdt)
			if li_ret = -1 then   return -1
			
			ls_filter = "CODE  <> '1'"  // 일시불은 제외하고 보여준다
					
			ldc_month.SetTransObject(SQLCA)
			li_exist1 =ldc_month.Retrieve()
			ldc_month.SetFilter(ls_filter)			//Filter정함
			ldc_month.Filter()
		
			If li_exist1 < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
				Return 1  		//선택 취소 focus는 그곳에
			End If  
		end if
		
			ls_svccod = dw_cond.object.svccod[1]	
			ls_penalty_cd = this.object.penalty_cd[1]
			
			//This.object.p_itemcod[1] = ""
		   li_exist 	= This.GetChild("p_itemcod", ldc_p_itemcod)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 위약품목")
			
			ls_filter = "A.svccod  = '" + ls_svccod  + "'  And penaltycd = '" + ls_penalty_cd + "'"
				
			ldc_p_itemcod.SetTransObject(SQLCA)
			li_exist =ldc_p_itemcod.Retrieve()
			ldc_p_itemcod.SetFilter(ls_filter)			//Filter정함
			ldc_p_itemcod.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
		
		
	CASE 'sale_month'
		
		
		li_ret = wf_mobile_sales(row, as_salemodelcd, as_priceplan, integer(data), as_fromdt)
		if li_ret = -1 then   return -1
		
		//단말할부개월수 <= 약정할부개월수 START
		ls_pay_type		= dw_detail1.object.pay_type[1]   //할부		
		
		IF ls_pay_type = 'M' THEN   //할부일때
			For li_i = 1 To tab_1.idw_tabpage[1].RowCount()
				ls_itemcod = tab_1.idw_tabpage[1].object.itemcod[li_i]
				ls_chk = tab_1.idw_tabpage[1].object.chk[li_i]
				if ls_chk = 'Y' THEN
					select to_number(ref_code1) into :li_install_mon
					from syscod2t
					where grcode = 'ZM104'
					  and code = :ls_itemcod;
					 
					if li_install_mon < integer(data)   THEN
						messagebox("약정개월수", " 단말할부개월수(" + data + ")는 약정개월수 (" + string(li_install_mon) + ")  보다 작아야 합니다")
						Return -1
					end if
				END IF
			Next
		END IF
		//단말할부개월수 <= 약정할부개월수 END
		
		
	CASE 'penalty_cd'
		
						
			ls_svccod = dw_cond.object.svccod[1]	
			ls_penalty_cd = this.object.penalty_cd[1]
			
			This.object.p_itemcod[1] = ""
		   li_exist 	= This.GetChild("p_itemcod", ldc_p_itemcod)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 위약품목")
			
			ls_filter = "A.svccod  = '" + ls_svccod  + "'  And penaltycd = '" + ls_penalty_cd + "'"

			ldc_p_itemcod.SetTransObject(SQLCA)
			li_exist =ldc_p_itemcod.Retrieve()
			ldc_p_itemcod.SetFilter(ls_filter)			//Filter정함
			ldc_p_itemcod.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
		
		
		
END CHOOSE


tab_1.Enabled = True

if dw_item.rowcount() > 0 then  // 이미 요금확인을 했는데 변경을 했으면, 다시 요금확인하도록 reset()
	dw_item.reset()
end if



end event

type dw_item from u_d_indicator within mobile_w_reg_activeorder_new
integer x = 3890
integer y = 96
integer width = 2153
integer height = 1196
integer taborder = 80
boolean bringtotop = true
string dataobject = "mobile_dw_reg_activeorder_item_onair"
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;
this.SetRowFocusIndicator(off!)

end event

type uo_1 from u_calendar_sams within mobile_w_reg_activeorder_new
event destroy ( )
boolean visible = false
integer x = 2747
integer y = 4
integer height = 712
integer taborder = 20
boolean bringtotop = true
end type

on uo_1.destroy
call u_calendar_sams::destroy
end on

event ue_popup;//messageBox('11', string(istr_cal.caldate, 'yyyymmdd') +  ' ' + String(dw_cond.Object.customerid[1]))

String ls_customerid, ls_caldt
date		ldt_reqdt
//MessageBox('11', string(id_date_selected, 'yyyymmdd')) 

iu_cust_msg = Create u_cust_a_msg
//스케쥴관리 추가
ls_customerid 	= Trim(dw_cond.object.customerid[1])
//ls_caldt 		= String(istr_cal.caldate, 'yyyymmdd')
ls_caldt 		=  string(id_date_selected, 'yyyymmdd')
ldt_reqdt 		=  date(id_date_selected)
dw_cond.Object.requestdt[1] =  id_date_selected
iu_cust_msg.is_pgm_name = "Service Request"
iu_cust_msg.is_grp_name = "스케쥴관리"
iu_cust_msg.ib_data[1]  = True
iu_cust_msg.id_data[1] = ldt_reqdt
iu_cust_msg.is_data[1] = ls_customerid					//customer ID
iu_cust_msg.is_data[2] = ls_caldt						//날짜
iu_cust_msg.is_data[3] = gs_user_id                //user id
iu_cust_msg.is_data[4] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
iu_cust_msg.is_data[5] = '0'
iu_cust_msg.is_data[6] = ''
iu_cust_msg.is_data[7] = ''
iu_cust_msg.is_data[8] = ''
 
OpenWithParm(ssrt_reg_schedule_pop_sams, iu_cust_msg)

il_SCHEDULESEQ = LONG(iu_cust_msg.is_data[1])

Destroy iu_cust_msg






end event

event ue_clicked();call super::ue_clicked;dw_cond.Object.requestdt[1] =  id_date_selected

end event

type dw_detail from u_d_indicator within mobile_w_reg_activeorder_new
integer x = 50
integer y = 728
integer width = 3451
integer height = 252
integer taborder = 100
boolean bringtotop = true
string dataobject = "mobile_cnd_reg_quotainfo_pop_ad_v20_sams"
boolean hscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;
this.SetRowFocusIndicator(off!)

this.insertrow(0)
if is_selfequip = 'N' then  //UBS 폰일때만 단말 판매 활성화
	this.enabled = true
else 
	this.enabled = false
end if
end event

event itemchanged;call super::itemchanged;DataWindowChild ldc_child, ldc
String ls_status, ls_desc, ls_filter, ls_modelnm, ls_itemcod
Integer li_exist, li_row

if row <= 0 then return 2
 
Choose Case dwo.name
	Case "contno" 
		If IsNull(data) Then data = ""
		If data <> "" Then
			If wf_read_contno(data, row) = - 1 Then 
				Return 2
			End If
		END IF
End Choose


//dw_detail1.event itemChanged(1, dw_detail1.object.sale_month, string(1))
dw_detail1.Enabled = true



end event

event ue_init;ib_delete = True
ib_insert = True


end event

type p_1 from u_p_pnext within mobile_w_reg_activeorder_new
integer x = 3598
integer y = 728
boolean bringtotop = true
end type

event clicked;string ls_ad_itemcod, ls_paytype, ls_chk, ls_itemcod, ls_cont, ls_install_itemcod
string ls_priceplan, ls_requestdt, ls_penalty_cd, ls_p_itemcod
dec ldc_ad_sale_amt, ldc_sale_amt, ldc_pay_amt, ld_unitamt, ld_punitamt
integer i, li_tab, li_chk_cnt
date ld_reqdt

//실시간요금세팅
dw_item.reset() //초기화
dw_item.visible = true




//정보
ls_priceplan = dw_detail1.object.priceplan[1]
ld_reqdt =   dw_cond.object.orderdt[1]
ls_requestdt = string(ld_reqdt, 'yyyymmdd')

//장비
ls_ad_itemcod = dw_detail.object.itemcod[1]    //단말품목
ldc_ad_sale_amt = dw_detail.object.sale_amt[1] //출고가


//단말할부
ls_paytype = dw_detail1.object.pay_type[1]  //일시불(S), 할부(M)
ls_install_itemcod = dw_detail1.object.itemcod[1]
ldc_sale_amt = dw_detail1.object.sale_amt[1] //일시불금액
ldc_pay_amt = dw_detail1.object.pay_amt[1]//할부금액

//위약
ls_penalty_cd = dw_detail1.object.penalty_cd[1]
ls_p_itemcod = dw_detail1.object.p_itemcod[1]
if ls_p_itemcod = '' then
	messagebox("확인", "위약품목을 선택하세요")
	dw_item.reset()
	return
end if 

select unitcharge
				  into :ld_punitamt
				 from priceplan_rate2
				where priceplan = :ls_priceplan
				 and itemcod = :ls_p_itemcod
				 and fromdt = (select max(fromdt)
								from priceplan_rate2
								where priceplan = :ls_priceplan 
								and itemcod = :ls_p_itemcod
								and fromdt <= to_date(:ls_requestdt,'yyyy-mm-dd'));

//약정
for i = 1 to tab_1.idw_tabpage[1].rowcount()
	ls_chk = tab_1.idw_tabpage[1].object.chk[i]
	if ls_chk = 'Y' then
		ls_itemcod = tab_1.idw_tabpage[1].object.itemcod[i]
		ls_cont    = tab_1.idw_tabpage[1].object.ref_code1[i]
	end if
next


//Mobile Sales
if ls_paytype = 'S' and  ls_cont = '0'   then  //일시불 & 무약정(No Contract) 이면 출고가

     if  ls_ad_itemcod <> '' then 
     	wf_set_item(ls_ad_itemcod,ldc_ad_sale_amt,'M')
		//dw_detail1.object.pay_amt[1] = ldc_ad_sale_amt //출고
	  end if
	  
elseif ls_paytype = 'S' and  ls_cont <> '0' then  //일시불 & 약정
	
	  if  ls_ad_itemcod <> '' then 
		  wf_set_item(ls_ad_itemcod, ldc_sale_amt,'M')
		 //위약품목은 위약금계산프로시저에서 자동계산함
		  wf_set_item(ls_p_itemcod, ld_punitamt,'Y')  //위약품목
	  end if
else																//할부(installment)
	
	  if  ls_install_itemcod <> '' then 
		  wf_set_item(ls_install_itemcod,ldc_pay_amt,'M')
		  //위약품목은 위약금계산프로시저에서 자동계산함
		  wf_set_item(ls_p_itemcod, ld_punitamt,'Y')   //위약품목
	  end if
end if


//약정
if  ls_itemcod <> '' then 
	if wf_itemcod_chk(1) < 0 then 
			dw_item.reset()
			return
	end if
	wf_set_item(ls_itemcod,0,'M')
	
end if

//일반품목
li_chk_cnt = 0 
for li_tab = 2 to ii_enable_max_tab
		for i = 1 to tab_1.idw_tabpage[li_tab].rowcount()
			ls_chk = tab_1.idw_tabpage[li_tab].object.chk[i]
			if ls_chk = 'Y' then
				li_chk_cnt++
				ls_itemcod = tab_1.idw_tabpage[li_tab].object.itemcod[i]
				
				select unitcharge
				  into :ld_unitamt
				 from priceplan_rate2
				where priceplan = :ls_priceplan
				 and itemcod = :ls_itemcod
				 and fromdt = (select max(fromdt)
								from priceplan_rate2
								where priceplan = :ls_priceplan 
								and itemcod = :ls_itemcod
								and fromdt <= to_date(:ls_requestdt,'yyyy-mm-dd'));
								
				wf_set_item(ls_itemcod,ld_unitamt,'Y')
				
			end if
		next
		if wf_itemcod_chk(li_tab) < 0 then 
			dw_item.reset()
			return
		end if
		
		
next


p_save.TriggerEvent("ue_enable")
dw_detail.enabled = false
end event

type gb_4 from groupbox within mobile_w_reg_activeorder_new
integer x = 3845
integer y = 8
integer width = 2222
integer height = 1324
integer taborder = 90
integer textsize = -9
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 255
long backcolor = 29478337
string text = "실시간요금확인"
end type

