﻿$PBExportHeader$p0w_prc_cardmst_2_v20.srw
$PBExportComments$[ohj]  카드발행 Window_cyberpass pin 자리수 적용 & 기본료 & 기본율 & 유효기간 & 서비스별 언어맨트v20
forward
global type p0w_prc_cardmst_2_v20 from w_a_prc
end type
end forward

global type p0w_prc_cardmst_2_v20 from w_a_prc
integer width = 2149
integer height = 1944
end type
global p0w_prc_cardmst_2_v20 p0w_prc_cardmst_2_v20

type variables
Integer ii_delay //연장일수

Dec ic_delay

Dec ic_price
Dec ic_sale_amt
Dec ic_quantity
String is_model
String is_contno
String is_wantedno
String is_partner
String is_priceplan
String is_lotno
String is_enddt
String is_opendt
String is_issuedt
String is_remark
String is_confirm
String is_stock
String is_eday, is_level_code, is_partner_main
String is_wkflag2, is_default_wkflag2,	is_pid_len, is_refill_yn, is_partner_yn

//2005.03.28 add
Long il_extdays, il_len
Dec{2} ic_basic_fee, ic_basic_rate ,ic_b_f_first, ic_b_r_first


end variables

on p0w_prc_cardmst_2_v20.create
call super::create
end on

on p0w_prc_cardmst_2_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: 	p0w_prc_cardmst_cpass
	Desc	:  카드발행_cpass
	Date	: 	2004.09.03
	Auth.	:	Kwon Jung Min
-------------------------------------------------------------------------*/
String ls_tmp, ls_delay, ls_ref_desc, ls_pid_len, ls_type, ls_prefix[], ls_sql, &
       ls_partner_yn, ls_temp
Integer li_dealy
Date ld_nextdate

//is_default_wkflag2 = fs_get_control("B1", "P204", ls_ref_desc)		//멘트언어
ls_pid_len = fs_get_control("P0", "P102", ls_ref_desc)		//길이

//2005.08.22 ohj 추가
//관리대상 레벨 코드 A1 C100
ls_ref_desc = ""
is_level_code = fs_get_control("A1", "C100", ls_ref_desc)

//판매출고 대상 관리대상대리점 여부  khpark add 2005.01.13 start
ls_ref_desc = ""
ls_partner_yn = fs_get_control("P0", "P002", ls_ref_desc)

dw_input.SetReDraw(False)

dw_input.Object.issuedt[1] = Date(fdt_get_dbserver_now())
dw_input.Object.pid_len[1] = ls_pid_len
//dw_input.Object.wkflag2[1] = is_default_wkflag2

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
dw_input.GetChild ("partner", dwc_child)

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

event type integer ue_input();call super::ue_input;Long ll_rc

String ls_model
Dec lc_price
String ls_partner
Dec lc_sale_amt
String ls_priceplan
String ls_contno
Integer li_quantity,	li_chk_len, li_return
String ls_wantedno
String ls_lotno
String ls_remark
String ls_issuedt
String ls_opendt
String ls_enddt
String ls_confirm
String ls_stock, ls_wkflag2,	ls_pid_len, ls_refill_yn

Dec lc_rate
String ls_sysdate
DateTime ldt_sysdate
Date ld_nextdate


ldt_sysdate = fdt_get_dbserver_now()
ls_sysdate = String(ldt_sysdate, "yyyymmdd")

ls_confirm = Trim(dw_input.object.confirm[1])
If IsNull(ls_confirm) Then ls_confirm = "N"
ls_stock = Trim(dw_input.object.stock[1])
If IsNull(ls_stock) Then ls_stock = "N"
lc_price = dw_input.object.price[1]
ls_partner = dw_input.object.partner[1]
ls_lotno = dw_input.object.lotno[1]
ls_remark = dw_input.object.remark[1]
ls_pid_len = dw_input.object.pid_len[1]	//길이
ls_refill_yn = dw_input.Object.refill_yn[1]
lc_sale_amt = dw_input.object.saleamt[1]

ls_pid_len = Trim(dw_input.object.pid_len[1])
If IsNull(ls_pid_len) Then ls_pid_len = ""
If ls_pid_len = "" Then
	f_msg_usr_err(200, Title, "길이")
	dw_input.SetFocus()
	dw_input.SetColumn("pid_len")
	Return -1
ELSE
	IF Integer(ls_pid_len) > 20 THEN
		f_msg_info(9000, This.Title, "길이는 20자리를 넘을수 없습니다.")
		dw_input.SetFocus()
		dw_input.SetColumn("pid_len")
		Return -1		
	END IF
End If

ls_model = Trim(dw_input.object.model[1])
If IsNull(ls_model) Then ls_model = ""
If ls_model = "" Then
	f_msg_usr_err(200, Title, "Model")
	dw_input.SetFocus()
	dw_input.SetColumn("Model")
	Return -1
End If

IF ls_confirm = "Y" THEN
	If ls_partner = "" Then
		f_msg_usr_err(200, Title, "대리점")
		dw_input.SetFocus()
		dw_input.SetColumn("partner")
		Return -1
	End If
END IF

ls_priceplan = Trim(dw_input.object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""
If ls_priceplan = "" Then
	f_msg_usr_err(200, Title, "가격정책")
	dw_input.SetFocus()
	dw_input.SetColumn("priceplan")
	Return -1
End If

ls_wkflag2 = Trim(dw_input.object.wkflag2[1])
If IsNull(ls_wkflag2) Then ls_wkflag2 = ""
If ls_wkflag2 = "" Then
	f_msg_usr_err(200, Title, "멘트언어")
	dw_input.SetFocus()
	dw_input.SetColumn("wkflag2")
	Return -1
End If

ls_contno = Trim(dw_input.object.contno[1])
If IsNull(ls_contno) Then ls_contno = ""
//If ls_contno = "" or Len(ls_contno) <> 2 Then
//	f_msg_usr_err(200, Title, "관리번호 2자리")
//	dw_input.SetFocus()
//	dw_input.SetColumn("contno")
//	Return -1
//End If

li_quantity = dw_input.object.quantity[1]
If IsNull(li_quantity) Then li_quantity = 0
If li_quantity = 0 Then
	f_msg_usr_err(200, Title, "수량")
	dw_input.SetFocus()
	dw_input.SetColumn("quantity")
	Return -1
End If

ls_wantedno = Trim(dw_input.object.wantedno[1])
If IsNull(ls_wantedno) Then ls_wantedno = ""
IF ls_wantedno <> "" THEN
	li_chk_len = Integer(ls_pid_len) - Integer(LenA(ls_wantedno))			//길이가 희망번호 길이를 포함했는지 check
	
	IF li_chk_len <= 0 THEN
		f_msg_usr_err(200, Title, "길이")		
		dw_input.SetFocus()
		dw_input.SetColumn("pid_len")
		Return -1
	END IF
END IF

ls_issuedt = String(dw_input.object.issuedt[1], 'yyyymmdd')
If IsNull(ls_issuedt) Then ls_issuedt = ""
If ls_issuedt = "" Then
	f_msg_usr_err(200, Title, "발행일자")
	dw_input.SetFocus()
	dw_input.SetColumn("issuedt")
	Return -1
Else
	If ls_issuedt < ls_sysdate Then
		f_msg_usr_err(200, Title, "발행일자 >= 현재일자")
		dw_input.SetFocus()
		dw_input.SetColumn("opendt")
		Return -1
	End If
End If

ls_opendt = String(dw_input.object.opendt[1], 'yyyymmdd')
IF ls_confirm = "Y" THEN
	If IsNull(ls_opendt) Then ls_opendt = ""
	If ls_opendt = "" Then
		f_msg_usr_err(200, Title, "개통일자")
		dw_input.SetFocus()
		dw_input.SetColumn("opendt")
		Return -1
	Else
		If ls_opendt < ls_sysdate Then
			f_msg_usr_err(200, Title, "판매일자 >= 현재일자")
			dw_input.SetFocus()
			dw_input.SetColumn("opendt")
			Return -1
		End If
	End If
	
	ls_enddt = String(dw_input.object.enddt[1],"YYYYMMDD")
	If ls_opendt >= ls_enddt Then
			f_msg_usr_err(200, Title, "판매일자 >= 유효일자")
			dw_input.SetFocus()
			dw_input.SetColumn("enddt")
			Return -1
	End If
	
	//If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_price <> 0 Then
		li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_price, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays) //2005.08.11 modify
	
		//refillpolicy extdays add 2005.03.29==========================================END
		If li_return = -1 Then
			f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
			Return -1
		End If	
		
		If il_extdays = 0 Then
			f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
			Return -1
		End If
	//End If
	
	If isnull(lc_sale_amt) Then lc_sale_amt = 0 
	If isnull(lc_price)    Then lc_price    = 0 
	
	If lc_price = 0 Then
		f_msg_usr_err(9000, Title, "카드금액을 입력하세요!")
		Return -1
	End If
	
	If lc_sale_amt = 0 Then
		f_msg_usr_err(9000, Title, "판매금액을 입력하세요!")
		Return -1
	End If
END IF

//***** 사용자 입력사항 Instance 변수에 저장 *****
ic_price = lc_price
ic_sale_amt = lc_sale_amt
ic_quantity = li_quantity
is_model = ls_model
is_contno = ls_contno
is_wantedno = ls_wantedno
is_partner = ls_partner
is_priceplan = ls_priceplan
is_lotno = ls_lotno
is_enddt = ls_enddt
is_opendt = ls_opendt
is_issuedt = ls_issuedt
is_remark = ls_remark
is_confirm = ls_confirm
is_stock = ls_stock  //재고확정
is_wkflag2 = ls_wkflag2
is_pid_len = ls_pid_len
is_refill_yn = ls_refill_yn

RETURN 0
end event

event type integer ue_process();call super::ue_process;Integer	li_rc
String	ls_contno_first, ls_contno_last

Long		ll_total_cnt, ll_total_amt

//***** 처리부분 *****
p0c_dbmgr7_v20 iu_db

iu_db = Create p0c_dbmgr7_v20

iu_db.is_title = Title

iu_db.ic_data[1] = ic_price			//카드금액
iu_db.ic_data[2] = ic_sale_amt	   //판매금액  
iu_db.ic_data[3] = ic_quantity		//판매수량
//basic 요금 추가 2005.03.28 start ----------
iu_db.ic_data[4] = ic_basic_fee
iu_db.ic_data[5] = ic_basic_rate
//basic 요금 추가 2005.03.28 end ------------
iu_db.is_data[1] = is_model			//모델명
iu_db.is_data[2] = is_contno			//관리번호
iu_db.is_data[3] = is_wantedno		//희망번호
iu_db.is_data[4] = is_partner			//대리점
iu_db.is_data[5] = is_priceplan		//가격정책
iu_db.is_data[6] = is_lotno			//LOT NO
iu_db.is_data[7] = is_enddt		   //유효기간
iu_db.is_data[8] = is_opendt			//개통일자
iu_db.is_data[9] = is_issuedt			//발행일자
iu_db.is_data[10] = is_remark			//비고
iu_db.is_data[11] = is_confirm		//판매출고확정여부
iu_db.is_data[12] = is_stock			//재고확정여부
iu_db.is_data[14] = is_wkflag2		//멘트언어
iu_db.is_data[15] = is_pid_len		//길이
//변수이름 수정 2005.03.28 start -------------
iu_db.il_data[1] = il_extdays			//연장일수
//변수이름 수정 2005.03.28 end   -------------
//충전여부 추가 2005.08.01 kem
iu_db.is_data[16] = is_refill_yn    //충전여부


IF is_confirm = "N" THEN  
	iu_db.is_caller = "p0w_prc_cardmst_2_v20%sale_no"
	iu_db.uf_prc_db_02()
ELSEIF is_confirm = "Y" THEN 
	iu_db.is_caller = "p0w_prc_cardmst_2_v20%sale_yes"
	iu_db.uf_prc_db_02()
END IF

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
	is_msg_process = "카드발행 처리 " + String(ll_total_cnt) + "건" +"~r~n"  + &
						  "판매금액 " + String(ll_total_amt, '#,###,###,###') + "~r~n" + &
						  "관리번호 From " + ls_contno_first + "~r~n" + &
						  "         To   " + ls_contno_last
	Return 0
End If
end event

type p_ok from w_a_prc`p_ok within p0w_prc_cardmst_2_v20
integer x = 1833
integer y = 56
end type

type dw_input from w_a_prc`dw_input within p0w_prc_cardmst_2_v20
integer width = 1714
integer height = 816
string dataobject = "p0dw_cnd_prc_cardmst_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_input::itemchanged;call super::itemchanged;DataWindowChild ldc_model, ldc_partner, ldc_priceplan, ldc_wkflag2
Long ll_row
Dec ldc_amt, lc_rate
Dec{2} lc_sale_amt, lc_amt
Date ld_nextdate, ld_opendt
String ls_partner, ls_priceplan, ls_opendt, ls_model, ls_no
String ls_filter, ls_confirm, ls_contnoprefix, ls_pidprefix, ls_svccod
Dec lc_price, lc_ext
String ls_enddt
Date ld_null

//2005.08.11 juede add
Integer li_return

SetNull(ld_null)

//모델선택시 카드 금액을 보여줌
Choose Case dwo.name
	Case "confirm"  //판매출고 확정
		ls_confirm = data
		This.Object.model[1] = ""
		This.Object.price[1] = 0
		This.Object.saleamt[1] = 0
		This.Object.quantity[1] = 0
		This.Object.contno[1] = ""
		This.Object.lotno[1] = ""
		This.Object.remark[1] = ""
		
		//판매출고확정
		IF  data = "Y" THEN
			//가격정책을 p0dc_dddw_partner_priceplan으로 변경
			Modify("priceplan.dddw.name=''")
			Modify("priceplan.dddw.DataColumn=''")
			Modify("priceplan.dddw.DisplayColumn=''")
			This.Object.priceplan[row] = ''				
			Modify("priceplan.dddw.name=p0dc_dddw_partner_priceplan")
			Modify("priceplan.dddw.DataColumn='partner_priceplan_priceplan'")
			Modify("priceplan.dddw.DisplayColumn='priceplanmst_priceplan_desc'")
			
			//Model을 대리점별 모델(p0dc_dddw_par_model)로 변경
//			Modify("model.dddw.name=''")
//			Modify("model.dddw.DataColumn=''")
//			Modify("model.dddw.DisplayColumn=''")
//			This.Object.model[row] = ''				
//			Modify("model.dddw.name=p0dc_dddw_par_model")
//			Modify("model.dddw.DataColumn='salepricemodel_pricemodel'")
//			Modify("model.dddw.DisplayColumn='salepricemodel_pricemodelnm'")
			
			
			dw_input.Object.priceplan.protect = 1
			dw_input.Object.enddt[1] = ld_null
			dw_input.Object.opendt[1] = Date(fdt_get_dbserver_now())
		//발행만...
		ELSE
			//가격정책을 p0dc_dddw_priceplan으로 변경
				Modify("priceplan.dddw.name=''")
				Modify("priceplan.dddw.DataColumn=''")
				Modify("priceplan.dddw.DisplayColumn=''")
				This.Object.priceplan[row] = ''				
				Modify("priceplan.dddw.name=p0dc_dddw_priceplan")
				Modify("priceplan.dddw.DataColumn='priceplanmst_priceplan'")
				Modify("priceplan.dddw.DisplayColumn='priceplanmst_priceplan_desc'")
			
			//Model을 카드모델(p0dc_dddw_model)로 변경
//			Modify("model.dddw.name=''")
//			Modify("model.dddw.DataColumn=''")
//			Modify("model.dddw.DisplayColumn=''")
//			This.Object.model[row] = ''				
//			Modify("model.dddw.name=p0dc_dddw_model")
//			Modify("model.dddw.DataColumn='pricemodel'")
//			Modify("model.dddw.DisplayColumn='pricemodelnm'")
			
			
			dw_input.Object.priceplan.protect = 0
			This.Object.partner[1] = ""
			This.Object.saleamt[1] = 0
			This.Object.enddt[1] = ld_null
			This.Object.opendt[1] = ld_null
		END IF
	
	Case "model"
		ls_partner = Trim(This.object.partner[1])
		If IsNull(ls_partner) Then ls_partner = ""
		
		ls_confirm = Trim(This.object.confirm[1])
		If IsNull(ls_confirm) Then ls_confirm = ""
		
		IF ls_partner = "" AND ls_confirm = "Y" THEN
		   f_msg_info(9000, Title,  "대리점을 먼저 선택하여 주십시요.")
			dw_input.object.model[1] = ""
			RETURN 0
		End If
		
		If This.GetChild('model', ldc_model) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_model.GetRow()
		
		IF ls_confirm = "Y" THEN
			ldc_amt = ldc_model.GetItemNumber(ll_row, "price")
			//유효기간
			This.object.enddt[1] = ld_null
		END IF
		
		This.object.price[1] = ldc_amt
	
	Case "partner"
		ls_model = This.Object.model[1]
		IF IsNull(ls_model) THEN
			ls_model = ""
		END IF
		
		//선택된 대리점 값
		If This.GetChild('partner', ldc_partner) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ll_row = ldc_partner.GetRow()
		ls_partner = ldc_partner.GetItemString(ll_row, "partner")		
		
		//대리점에 해당하는 모델
		If This.GetChild('model', ldc_model) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ls_filter = "partner_pricemodel_partner = '"+ ls_partner +"'"
		ldc_model.setFilter(ls_filter)
		ldc_model.filter()
		ldc_model.SetTransObject(SQLCA)
		ldc_model.Retrieve()
		
		This.Object.model[1] = ""		
		
		//가격정책 Setting
		If This.GetChild('priceplan', ldc_priceplan) = - 1 Then 
		   MessageBox("Error", "Not a DataWindowChild")
		End If
		
		ls_filter = "partner_priceplan_partner = '"+ ls_partner +"'"
		ldc_priceplan.setFilter(ls_filter)
		ldc_priceplan.filter()
		ldc_priceplan.SetTransObject(SQLCA)
		ldc_priceplan.Retrieve()
		
		This.Object.priceplan[1] = ""
		dw_input.Object.priceplan.protect = 0
	
		Select pidprefix, contnoprefix
		Into   :ls_pidprefix, :ls_contnoprefix
		From	 partner_cardctl
		Where  partner = :ls_partner;
		
		dw_input.Object.contno[1] = ls_contnoprefix
		dw_input.Object.wantedno[1] = ls_pidprefix
		
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
		
	Case "priceplan" 
		ls_partner = Trim(This.object.partner[1])
		If IsNull(ls_partner) Then ls_partner = ""
		
		ls_confirm = Trim(This.object.confirm[1])
		If IsNull(ls_confirm) Then ls_confirm = ""
		
		IF ls_confirm = "Y" Then //판매출고 확정
			If ls_partner = "" Then
				f_msg_info(9000, Title,  "대리점을 먼저 선택하여 주십시요.")
				dw_input.object.priceplan[1] = ""
				Return -1
			End If	
			
			ls_priceplan = Trim(This.object.priceplan[1])
			If IsNull(ls_priceplan) Then ls_priceplan = ""
			
			ls_opendt = String(This.object.opendt[1],"YYYYMMDD")
			lc_price = This.object.price[1]
			
			If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_price <> 0 Then
				li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_price, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays) //2005.08.11 modify
			
				//refillpolicy extdays add 2005.03.29==========================================END
				If li_return = -1 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
					Return -1
				End If	
				
				If il_extdays = 0 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
					Return -1
				End If
				
				lc_sale_amt = lc_price * (lc_rate /100)
				dw_input.object.saleamt[1] = lc_sale_amt
				//유효기간계산 2005.03.29 ========================START
				ls_confirm = Trim(This.object.confirm[1])
				If IsNull(ls_confirm) Then ls_confirm = ""
				
				If ls_confirm = "Y" Then 
					ld_opendt =This.object.opendt[1]
					ld_nextdate = fd_date_next(ld_opendt, il_extdays)
					This.object.enddt[1] = ld_nextdate
				End If					
			End If
				
//			IF ls_priceplan <> ""  AND ls_partner <>"" AND lc_price > 0 THEN
//				//판매금액 계산
//				
//					//충전정책 가져옴 refillpolicy 수정 2005.03.28  start ***********************
//					li_return = fdc_refill_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_price, lc_rate)
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "충전 정책이 정의되지 않았습니다.  충전 정책을 확인하여 주시기 바랍니다.")
//						Return -1
//					End If
//					/* basic fee, rate *start****************************************/
//					li_return = fdc_basic_feefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_price, ic_basic_fee) 
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "충전 정책이 정의되지 않았습니다.  충전 정책을 확인하여 주시기 바랍니다.")
//						Return -1
//					End If					
//					li_return = fdc_basic_ratefirst_new(ls_partner, ls_priceplan, ls_opendt, lc_price,ic_basic_rate)
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "충전 정책이 정의되지 않았습니다.  충전 정책을 확인하여 주시기 바랍니다.")
//						Return -1
//					End If					
//					li_return = fl_refill_extdays_new(ls_partner, ls_priceplan, ls_opendt, lc_price,il_extdays) 
//					If li_return = -1 Then
//						f_msg_usr_err(9000, Title, "충전 정책이 정의되지 않았습니다.  충전 정책을 확인하여 주시기 바랍니다.")
//						Return -1
//					End If					
//					/* basic fee, rate *end******************************************/
//					
//					//MessageBox("rate",ls_partner+","+ls_priceplan+","+ls_opendt+","+String(lc_price)+","+String(lc_rate))
//					
//					//If lc_rate < -1 Then
//					//	f_msg_usr_err(2100, Title, " Select Error(REFILLPOLICY)")
//					//	Return -1
//					//End If
//										
//					lc_sale_amt = lc_price * (lc_rate /100)
//					dw_input.object.saleamt[1] = lc_sale_amt
//					//유효기간계산 2005.03.29 ========================START
//					ls_confirm = Trim(This.object.confirm[1])
//					If IsNull(ls_confirm) Then ls_confirm = ""
//					
//					If ls_confirm = "Y" Then 
//						ld_opendt =This.object.opendt[1]
//						ld_nextdate = fd_date_next(ld_opendt, il_extdays)
//						This.object.enddt[1] = ld_nextdate
//					End If					
//					//유효기간계산 2005.03.29 =========================END					
//			END IF

		END IF
		
		//가격정책의 서비스 코드 가져오기와서 언어맨트 dddw Retrieve
		SELECT SVCCOD
		  INTO :ls_svccod
		  FROM PRICEPLANMST
		 WHERE PRICEPLAN = :data;
		 
		ll_row = This.GetChild("wkflag2", ldc_wkflag2)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
		ldc_wkflag2.Filter()
		ldc_wkflag2.SetTransObject(SQLCA)
		ll_row = ldc_wkflag2.Retrieve()
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
			Return -1
		End If
		
	Case "opendt"
		ls_confirm = Trim(This.object.confirm[1])
		If IsNull(ls_confirm) Then ls_confirm = ""
		
		If ls_confirm = "Y" Then 							
			
			ls_partner = Trim(This.object.partner[1])
			If IsNull(ls_partner) Then ls_partner = ""
			ls_priceplan = Trim(This.object.priceplan[1])
			If IsNull(ls_priceplan) Then ls_priceplan = ""
			
			ls_opendt = String(This.object.opendt[1],"YYYYMMDD")
			lc_price = This.object.price[1]
			
			If ls_partner <> "" and is_partner_main <> '' and ls_priceplan <> "" and ls_opendt <> "" And lc_price <> 0 Then
				li_return= fdc_refillpolicy_first_v20(ls_partner, is_partner_main, ls_priceplan, ls_opendt, lc_price, lc_rate, ic_b_f_first, ic_b_r_first, il_extdays) //2005.08.11 modify
			
				//refillpolicy extdays add 2005.03.29==========================================END
				If li_return = -1 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 가격정책이 정의되지 않았습니다. 충전 정책을 확인하여 주시기 바랍니다.")
					Return -1
				End If	
				
				If il_extdays = 0 Then
					f_msg_usr_err(9000, Title, "선택한 대리점의 충전 정책에 연장일수를 입력하세요!")
					Return -1
				End If
				
				lc_sale_amt = lc_price * (lc_rate /100)
				dw_input.object.saleamt[1] = lc_sale_amt
				
				ld_opendt =This.object.opendt[1]
				ld_nextdate = fd_date_next(ld_opendt, il_extdays)
				This.object.enddt[1] = ld_nextdate		
				
			End If
		End If
		
	Case "wkflag2"
		ls_priceplan = fs_snvl(This.object.priceplan[1], '')	
		If ls_priceplan = '' Then
			f_msg_info(9000, Title,  "가격정책을 먼저 선택해 주세요!")
			dw_input.object.wkflag2[1] = ""
			Return -1
		End If	
End Choose

RETURN 0
end event

type dw_msg_time from w_a_prc`dw_msg_time within p0w_prc_cardmst_2_v20
integer y = 1468
integer width = 2080
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p0w_prc_cardmst_2_v20
integer y = 924
integer width = 2080
integer height = 524
end type

type ln_up from w_a_prc`ln_up within p0w_prc_cardmst_2_v20
integer beginy = 904
integer endx = 2098
integer endy = 904
end type

type ln_down from w_a_prc`ln_down within p0w_prc_cardmst_2_v20
integer beginy = 1764
integer endx = 2098
integer endy = 1764
end type

type p_close from w_a_prc`p_close within p0w_prc_cardmst_2_v20
integer x = 1833
integer y = 164
end type

type gb_cond from w_a_prc`gb_cond within p0w_prc_cardmst_2_v20
integer width = 1765
integer height = 880
end type

