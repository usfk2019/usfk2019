$PBExportHeader$p0w_prc_out_2.srw
$PBExportComments$[juede] 카드판매출고처리 - 충전기본료적용
forward
global type p0w_prc_out_2 from w_a_prc
end type
end forward

global type p0w_prc_out_2 from w_a_prc
integer width = 2272
integer height = 1964
event dropdownlist pbm_dwndropdown
end type
global p0w_prc_out_2 p0w_prc_out_2

type variables
Dec{2} ic_amt, ic_sale_amt
String is_hope_no, is_priceplan, is_partner, is_lotno, is_opendt, is_crtdt
String is_model, is_use_period, is_hope_cont, is_remark, is_level_code, is_partner_main = ''
String is_sale 	//판매 처리 여부 
//String is_dealy 	//연장 일수
String is_contno_fr, is_contno_to

Dec{2} ic_basic_fee, ic_basic_rate, ic_r_first, ic_b_f_first, ic_b_r_first
Long il_extdays, il_len //연장일수
end variables

forward prototypes
public function integer wf_dropdownlist (datawindow adw_obj, long al_row, string as_col)
end prototypes

public function integer wf_dropdownlist (datawindow adw_obj, long al_row, string as_col);//string ls_sql 
//dataWindowChild	dwc_child
//dw_input.GetChild (as_col, dwc_child)
//
//dwc_child.SetTransObject (SQLCA)
//Choose case lower(as_col)
//	case "partner_prefix"
//		ls_sql = " select partnernm, partner, prefixno " + &
//					"   from partnermst                   " 
//		
//		If is_partner_yn = 'Y' Then
//			ls_sql = ls_sql + " where levelcod <= (select ref_content from sysctl1t where module = 'A1' and Ref_no = 'C100')" 
//		End If
//		
//		If is_prefix <> '' Then
//			If is_partner_yn = 'Y' Then
//				ls_sql = ls_sql + "   and prefixno like  '" + is_prefix + "%' and prefixno <> '"+ is_prefix +"'              "
//			Else
//				ls_sql = ls_sql + " where prefixno like  '" + is_prefix + "%' and prefixno <> '"+ is_prefix +"'              "
//			End If
//		End If
//		
//		ls_sql = ls_sql + " order by partnernm, partner "
//		
//	Case Else
//		
//End Choose
//
//messagebox('', ls_sql)
//
//If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)
//
//dwc_child.Retrieve()
//
return 0
end function

on p0w_prc_out_2.create
call super::create
end on

on p0w_prc_out_2.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: 	p0w_prc_out
	Desc	:  카드 판매출고 처리
				1. 발행된 카드의 정보를 가져와서 판매 출고 처리 
	Date	: 	2003.05.07
	Auth.	:	Y.K.MIN
-------------------------------------------------------------------------*/
String ls_tmp, ls_ref_desc, ls_filter, ls_partner_yn, ls_prefix[], ls_sql, ls_temp
Integer li_dealy,li_exist, ll_row
Date ld_nextdate
DataWindowChild ldc_partner, ldc_prefix

dw_input.SetReDraw(False)

dw_input.object.opendt[1] = Date(fdt_get_dbserver_now())
dw_input.object.priceplan.protect = 1

//관리대상 레벨 코드 A1 C100
ls_ref_desc = ""
is_level_code = fs_get_control("A1", "C100", ls_ref_desc)

//판매출고 대상 관리대상대리점 여부  khpark add 2005.01.13 start
ls_ref_desc = ""
ls_partner_yn = fs_get_control("P0", "P002", ls_ref_desc)

//If ls_partner_yn = 'Y' Then   //관리대상대리점이상만 판매출고 가능
//	dw_input.Modify("partner_prefix.dddw.name=''")
//	dw_input.Modify("partner_prefix.dddw.DataColumn=''")
//	dw_input.Modify("partner_prefix.dddw.DisplayColumn=''")
//	dw_input.Object.partner_prefix[1] = ''				
//	dw_input.Modify("partner_prefix.dddw.name=p0dc_dddw_control_par")
//	dw_input.Modify("partner_prefix.dddw.DataColumn='partner'")
//	dw_input.Modify("partner_prefix.dddw.DisplayColumn='partnernm'")
//Else                          //모든 대리점 판매출고 가능
//	dw_input.Modify("partner_prefix.dddw.name=''")
//	dw_input.Modify("partner_prefix.dddw.DataColumn=''")
//	dw_input.Modify("partner_prefix.dddw.DisplayColumn=''")
//	dw_input.Object.partner_prefix[1] = ''				
//	dw_input.Modify("partner_prefix.dddw.name=p0dc_dddw_control_par1")
//	dw_input.Modify("partner_prefix.dddw.DataColumn='partner'")
//	dw_input.Modify("partner_prefix.dddw.DisplayColumn='partnernm'")	
//End IF
//판매출고 대상 관리대상대리점 여부  khpark add 2005.01.13 end

//ohj 20050820 선불카드대리점 prefix가 존재하면... 해당 prefix로 시작되는 대리점만 가져온다.
//단 그 prefix대리점은 제외

//선불카드:prefix관리여부 1 ; 대리점prefixno 2
ls_ref_desc = ""
ls_temp =  fs_get_control("P0", "P003", ls_ref_desc)
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";", ls_prefix[])
End If

If Isnull(ls_prefix[2]) Then ls_prefix[2] = '' 

dataWindowChild	dwc_child
dw_input.GetChild ("partner_prefix", dwc_child)

dwc_child.SetTransObject (SQLCA)

ls_sql = " select partnernm, partner, prefixno " + &
         "   from partnermst                   " 

If ls_partner_yn = 'Y' Then
	ls_sql = ls_sql + " where levelcod <= (select ref_content from sysctl1t where module = 'A1' and Ref_no = 'C100')" 
End If

If ls_prefix[1] = 'Y' Then
	If ls_prefix[2] <> '' Then
		If ls_partner_yn = 'Y' Then
			ls_sql = ls_sql + "  and prefixno like '" + ls_prefix[2] + "%' and prefixno <> '"+ ls_prefix[2] +"'              "
		Else
			ls_sql = ls_sql + "where prefixno like '" + ls_prefix[2] + "%' and prefixno <> '"+ ls_prefix[2] +"'              "
		End If
	End If
End If

ls_sql = ls_sql + " order by partnernm, partner "

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve()

// 관리 대상대리점 prefixno  length  가져오기
SELECT LENGTH(MAX(PREFIXNO))  
  INTO :il_len
  FROM PARTNERMST  
 WHERE LEVELCOD = :is_level_code  ;
 
If sqlca.sqlcode < 0 Then
	f_msg_sql_err(title,  " Select Error(partnermst) prefixno max length select error" )
	Return
End If

dw_input.SetReDraw(True)	
	
end event

event type integer ue_input();call super::ue_input;String ls_where
Long ll_rc

Dec{2} lc_amt, lc_sale_amt, lc_rate
String ls_priceplan, ls_partner_prefix, ls_lotno, ls_crtdt, ls_partner
String ls_use_period, ls_model, ls_remark, ls_contno_fr, ls_contno_to
DateTime ldt_sysdate
String ls_sysdate, ls_opendt
Int li_contno_len, li_return

ls_model = Trim(dw_input.object.model[1])
If IsNull(ls_model) Then ls_model = ""
If ls_model = "" Then
	f_msg_usr_err(200, Title, "Model")
	dw_input.SetFocus()
	dw_input.SetColumn("Model")
	Return -1
End If

lc_amt = dw_input.object.price[1]
If IsNull(lc_amt) Then lc_amt = 0
If lc_amt < 0 Then
	f_msg_usr_err(200, Title, "카드금액")
	dw_input.SetFocus()
	dw_input.SetColumn("price")
	Return -1
End If

ls_contno_fr = Trim(dw_input.object.contno_fr[1])
If IsNull(ls_contno_fr) Then ls_contno_fr = ""

ls_contno_to = Trim(dw_input.object.contno_to[1])
If IsNull(ls_contno_to) Then ls_contno_to = ""

ls_lotno = Trim(dw_input.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

If ls_contno_fr = "" AND ls_lotno = "" Then
	f_msg_usr_err(200, Title, "관리번호 From 혹은 Lot#를 입력하셔야 합니다.")
	dw_input.SetFocus()
	dw_input.SetColumn("contno_fr")
	Return -1
End If

ls_partner = Trim(dw_input.object.partner_prefix[1])
If IsNull(ls_partner) Then ls_partner = ""
If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_input.SetFocus()
	dw_input.SetColumn("partner_prefix")
	Return -1
End If

ls_priceplan = Trim(dw_input.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""
If ls_priceplan = "" Then
	f_msg_usr_err(200, Title, "가격정책")
	dw_input.SetFocus()
	dw_input.SetColumn("priceplan")
	Return -1
End If

lc_sale_amt = dw_input.object.sale_amt[1]
If IsNull(lc_sale_amt) Then lc_sale_amt = 0
If lc_sale_amt < 0 Then
	f_msg_usr_err(200, Title, "판매금액")
	dw_input.SetFocus()
	dw_input.SetColumn("sale_amt")
	Return -1
End If

ls_opendt = String(dw_input.object.opendt[1], 'yyyymmdd')
If IsNull(ls_opendt) Then ls_opendt = ""
If ls_opendt = "" Then
	f_msg_usr_err(200, Title, "판매일자")
	dw_input.SetFocus()
	dw_input.SetColumn("opendt")
	Return -1
Else
	ldt_sysdate = fdt_get_dbserver_now()
	ls_sysdate = String(ldt_sysdate, "yyyymmdd")
	If ls_opendt < ls_sysdate Then
		f_msg_usr_err(200, Title, "판매일자는 현재일자보다 같거나 커야 합니다.")
		dw_input.SetFocus()
		dw_input.SetColumn("opendt")
		Return -1
	End If
End If

ls_use_period = String(dw_input.object.use_period[1], 'yyyymmdd')
If IsNull(ls_use_period) Then ls_use_period = ""
If ls_use_period = "" Then
	f_msg_usr_err(200, Title, "유효기간")
	dw_input.SetFocus()
	dw_input.SetColumn("use_period")
	Return -1
Else
	ldt_sysdate = fdt_get_dbserver_now()
	//ls_sysdate = String(ldt_sysdate, "yyyymmdd")
	If ls_use_period <= ls_opendt Then
		f_msg_usr_err(200, Title, "유효기간는 판매일자보다 커야 합니다.")
		dw_input.SetFocus()
		dw_input.SetColumn("use_period")
		Return -1
	End If
End If

ls_remark = Trim(dw_input.object.remark[1])
If IsNull(ls_remark) Then ls_remark = ""

//ohj 수정.20050822
If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_amt <> 0 Then
	li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_amt, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays)
	
	If li_return = -1 Then
		f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
		Return -1
	End If	
	
End If

//충전정책 가져옴
//lc_rate = fdc_refill_ratefirst(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//
//If lc_rate < -1 Then
//	f_msg_usr_err(2100, Title, " Select Error(REFILLPOLICY)")
//	Return -1
//End If
//lc_sale_amt = lc_amt * (lc_rate /100)
//dw_input.object.sale_amt[1] = lc_sale_amt

//***** 사용자 입력사항 Instance 변수에 저장 *****
ic_amt        = lc_amt
ic_sale_amt   = lc_sale_amt
is_priceplan  = ls_priceplan
is_partner    = ls_partner		// 대리점 코드
is_lotno      = ls_lotno
is_remark     = ls_remark
is_use_period = ls_use_period
is_opendt     = ls_opendt
is_model      = ls_model
is_contno_fr  = ls_contno_fr
is_contno_to  = ls_contno_to
Return 0
end event

event type integer ue_process();call super::ue_process;Integer	li_rc
String	ls_contno_first, ls_contno_last

Long		ll_total_cnt, ll_total_amt

//***** 처리부분 ***** modify 2005.03.29
p0c_dbmgr_1 iu_db  

iu_db = Create p0c_dbmgr_1

iu_db.is_title = Title
iu_db.is_caller = "p0w_prc_out%saleout"

iu_db.ic_data[1] = ic_amt				//카드금액
iu_db.ic_data[2] = ic_sale_amt	   //판매금액  
iu_db.ic_data[3] = ic_b_f_first     //기본료   2005.03.29 add
iu_db.ic_data[4] = ic_b_r_first    //기본료율 2005.03.29 add
iu_db.is_data[1] = is_model			//모델명
iu_db.is_data[2] = is_contno_fr
iu_db.is_data[3] = is_contno_to
iu_db.is_data[4] = is_partner			//대리점코드
iu_db.is_data[5] = is_priceplan		//가격정책
iu_db.is_data[6] = is_lotno			//LOT NO
iu_db.is_data[7] = is_use_period		//유효기간
iu_db.is_data[8] = is_opendt			//개통일자
iu_db.is_data[9] = is_remark	
iu_db.il_data[1] = il_extdays       //연장일수 2005.03.29 add
iu_db.uf_prc_db()

ll_total_cnt = iu_db.ic_data[1]
ll_total_amt = iu_db.ic_data[2]
w_msg_wait.wf_progress_init(0, ll_total_cnt, 0, 1)

li_rc				 = iu_db.ii_rc
ls_contno_first = iu_db.is_data[1]
ls_contno_last  = iu_db.is_data[2]

Destroy iu_db


//***** 결과 *****
If li_rc < 0 Then	//실패
	Return -1
Else					//성공
	is_msg_process = "판매출고처리  " + String(ll_total_cnt) + "건" +"~r~n"  + &
						  "판매금액 " + String(ll_total_amt, '#,###,###,###') + "~r~n" + &
						  "관리번호 From " + ls_contno_first + "~r~n" + &
						  "         To   " + ls_contno_last
	Return 0
End If



end event

type p_ok from w_a_prc`p_ok within p0w_prc_out_2
integer x = 1934
integer y = 72
end type

type dw_input from w_a_prc`dw_input within p0w_prc_out_2
integer y = 56
integer width = 1783
integer height = 880
string dataobject = "p0dw_cnd_prc_out_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::itemchanged;call super::itemchanged;DataWindowChild ldc_model, ldc_partner_prefix, ldc_priceplan
Long ll_row
Dec ldc_amt, lc_rate
Dec{2} lc_sale_amt, lc_amt
Date ld_nextdate, ld_opendt
String ls_partner_prefix, ls_partner, ls_priceplan, ls_opendt, ls_model, ls_pp, ls_pricep
String ls_filter, ls_no
Integer li_dealy, li_return

li_return = 0 //2005.08.11 add

//2005.03.29  basic fee&rate add


//카드 금액을 가져오기 위한 것
Choose Case dwo.name
	Case "opendt"	//판매일자
		
		ld_opendt =This.object.opendt[1]
		
		//refillpolicy extdays add 2005.03.29=========================================START
		//il_extdays = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
      ls_partner   = dw_input.object.partner_prefix[1]
		ls_priceplan = dw_input.object.priceplan[1]
		lc_amt       = dw_input.Object.price[1]
      ls_opendt    = string(ld_opendt, 'yyyymmdd')
		
		If IsNull(ls_partner)   Then ls_partner =""
		If IsNull(ls_priceplan) Then ls_priceplan =""
		If IsNull(ls_opendt)    Then ls_opendt = ''
		If IsNull(lc_amt)       Then lc_amt = 0
		
		If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_amt <> 0 Then
			li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_amt, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays) //2005.08.11 modify
		
			//refillpolicy extdays add 2005.03.29==========================================END
			If li_return = -1 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
				Return -1
			End If	
			
			If il_extdays = 0 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
				Return -1
			End If
			
			ld_nextdate = fd_date_next(ld_opendt, il_extdays)
			This.object.use_period[row] = ld_nextdate
		
		End If 		
		
	Case "model" 
		If This.GetChild('model', ldc_model) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_model.GetRow()
		ldc_amt = ldc_model.GetItemNumber(ll_row, "price")
	
		
		This.object.price[1] = ldc_amt	
		
		ld_opendt = This.object.opendt[1]
		ls_opendt = String(ld_opendt,'yyyymmdd')
		
      ls_partner   = dw_input.object.partner_prefix[1]
		ls_priceplan = dw_input.object.priceplan[1]
		
		If IsNull(ls_partner)   Then ls_partner = ""
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_opendt)    Then ls_opendt = ""
		
//		If ls_partner <> "" and ls_priceplan <> "" and ls_opendt <> "" And ldc_amt <> 0 Then			
//			//refillpolicy extdays add 2005.03.29=========================================START
//			//il_extdays = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//			li_return = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, ldc_amt, il_extdays)	
//		End If
		//refillpolicy extdays add 2005.03.29==========================================END
		
		If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_amt <> 0 Then
			li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_amt, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays) //2005.08.11 modify
		
			//refillpolicy extdays add 2005.03.29==========================================END
			If li_return = -1 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
				Return -1
			End If	
			
			If il_extdays = 0 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
				Return -1
			End If			
			
			ld_nextdate = fd_date_next(ld_opendt, il_extdays)
			This.object.use_period[row] = ld_nextdate	
			
		End If 		
		
	Case "contno_fr"
		This.object.contno_to[1] = data
		
		Select priceplan
		  into :ls_priceplan
		  from p_cardmst
		 where contno = :data;
		If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(p_cardmst)- 가격정책" )
			Return
		End If
		
		This.object.priceplan[1] = ls_priceplan
		
	Case "partner_prefix" 
	   
		This.object.priceplan.protect = 0
		
		ls_pp = This.object.priceplan[1]
		If isnull(ls_pp) then ls_pp = ''
		
		If ls_pp <> '' Then
			select priceplan
			  into :ls_pricep
			  from partner_priceplan
			 where partner   = :data
				and priceplan = :ls_pp   ;
			If sqlca.sqlcode < 0 then
				f_msg_sql_err(title,  " Select Error(partner_priceplan)-대리점별 가격정책찾기" )
				Return
			ElseIf sqlca.sqlcode = 100 Then
				This.object.priceplan[1]  = ""		
			End If
		End If		
		
		ls_model = Trim(This.object.model[1])
		
		If IsNull(ls_model) Then ls_model = ""
		
		If ls_model = "" Then
		   f_msg_info(9000, Title,  "모델을 먼저 선택하여 주십시요.")
		End If
		
		//선택된 대리점 값
		If This.GetChild('partner_prefix', ldc_partner_prefix) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_partner_prefix.GetRow()
		ls_partner = ldc_partner_prefix.GetItemString(ll_row, "partner")
		
		//선택된 가격정책 값
		If This.GetChild('priceplan', ldc_priceplan) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ls_filter = "partner_priceplan_partner = '" + data + "' "
	   ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		ldc_priceplan.SetTransObject(SQLCA)
		ldc_priceplan.Retrieve() 

      //관리대상대리점 구하기
		select prefixno
		  into :ls_no
		  from partnermst
		 where partner = :ls_partner  ;
		 If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-대리점 prefix" )
			Return
		 End If
		 
		Select partner
		  Into :is_partner_main
		  from partnermst
		 Where prefixno = substr(:ls_no, 1, :il_len);
		If sqlca.sqlcode < 0 then
			f_msg_sql_err(title,  " Select Error(PARTNERmst)-관리대상대리점" )
			Return
		End If
		
		ld_opendt = This.object.opendt[1]
		
		ls_opendt = String(ld_opendt,'yyyymmdd')      
		ls_priceplan = dw_input.object.priceplan[1]
		lc_amt       = dw_input.Object.price[1]     

		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_opendt)    Then ls_opendt = ""
		If IsNull(lc_amt)       Then lc_amt = 0
		
		If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_amt <> 0 Then
			li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_amt, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays)
		
			If li_return = -1 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
				Return -1
			End If	
			
			If il_extdays = 0 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
				Return -1
			End If
			
			lc_sale_amt = lc_amt * (lc_rate /100)
			This.object.sale_amt[1] = lc_sale_amt
			
			ld_nextdate = fd_date_next(ld_opendt, il_extdays)
			This.object.use_period[row] = ld_nextdate
		End If
		
	Case "priceplan" 
		ls_model = Trim(This.object.model[1])
		If IsNull(ls_model) Then ls_model = ""
		
		If ls_model = "" Then
		   f_msg_info(9000, Title,  "모델을 먼저 선택하여 주십시요.")
		End If
		
		//선택된 대리점 값
		If This.GetChild('partner_prefix', ldc_partner_prefix) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_partner_prefix.GetRow()
		ls_partner = ldc_partner_prefix.GetItemString(ll_row, "partner")
		
		//선택된 가격정책 값
		If This.GetChild('priceplan', ldc_priceplan) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row       = ldc_priceplan.GetRow()
		ls_priceplan = ldc_priceplan.GetItemString(ll_row, "partner_priceplan_priceplan")
		ld_opendt    = This.object.opendt[1]
		ls_opendt    = String(ld_opendt,'yyyymmdd')
		lc_amt       = dw_input.Object.price[1]
		
		If IsNull(ls_partner)   Then ls_partner =""
		If IsNull(ls_priceplan) Then ls_priceplan =""
		If IsNull(ls_opendt)    Then ls_opendt = ''
		If IsNull(lc_amt)       Then lc_amt = 0
		
//		If ls_partner <> "" And ls_priceplan <> "" And ls_opendt <> "" And lc_amt <> 0 Then
////			lc_amt = This.object.price[1]
////			ls_opendt = String(This.object.opendt[1], 'yyyymmdd')
//			
//			//충전정책 가져옴 2005.03.29 ====2005.08.11 modify============================start
//			//lc_rate = fdc_refill_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//			li_return = fdc_refill_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt,lc_rate)
//			If li_return = -1 Then
//				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 요율")
//				Return -1
//			End If				
//			//ic_basic_fee = fdc_basic_feefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//			li_return = fdc_basic_feefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt,ic_basic_fee)
//			If li_return = -1 Then
//				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-기본료")
//				Return -1
//			End If				
//			//ic_basic_rate = fdc_basic_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//			li_return = fdc_basic_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_amt,ic_basic_rate)			
//			If li_return = -1 Then
//				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.-기본요율")
//				Return -1
//			End If				
//			//il_extdays = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, lc_amt)
//			li_return = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, lc_amt,il_extdays)
//			If li_return = -1 Then
//				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다. - 연장일수")
//				Return -1
//			End If				
			//충전정책 가져옴 2005.03.29 ===================================================End			
			//If lc_rate < -1 Then
			//	f_msg_usr_err(2100, Title, " Select Error(REFILLPOLICY)")
			//	Return -1
			//End If
			
		If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_amt <> 0 Then
			li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_amt, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays)
		
			If li_return = -1 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
				Return -1
			End If	
			
			If il_extdays = 0 Then
				f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
				Return -1
			End If
			
			lc_sale_amt = lc_amt * (lc_rate /100)
			This.object.sale_amt[1] = lc_sale_amt
			
			ld_nextdate = fd_date_next(ld_opendt, il_extdays)
			This.object.use_period[row] = ld_nextdate
		End If
		
End Choose
end event

type dw_msg_time from w_a_prc`dw_msg_time within p0w_prc_out_2
integer y = 1536
integer width = 2185
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p0w_prc_out_2
integer y = 1024
integer width = 2185
integer height = 480
end type

type ln_up from w_a_prc`ln_up within p0w_prc_out_2
integer beginx = 37
integer beginy = 1004
integer endx = 1787
integer endy = 1004
end type

type ln_down from w_a_prc`ln_down within p0w_prc_out_2
integer beginx = 37
integer beginy = 1832
integer endx = 1787
integer endy = 1832
end type

type p_close from w_a_prc`p_close within p0w_prc_out_2
integer x = 1934
integer y = 184
end type

type gb_cond from w_a_prc`gb_cond within p0w_prc_out_2
integer x = 27
integer width = 1856
integer height = 972
end type

