$PBExportHeader$b1w_1_reg_svc_actorder_v20_sams_test.srw
$PBExportComments$Service Request
forward
global type b1w_1_reg_svc_actorder_v20_sams_test from w_a_reg_m_m3
end type
type uo_1 from u_calendar_sams within b1w_1_reg_svc_actorder_v20_sams_test
end type
end forward

global type b1w_1_reg_svc_actorder_v20_sams_test from w_a_reg_m_m3
integer width = 4041
integer height = 2052
uo_1 uo_1
end type
global b1w_1_reg_svc_actorder_v20_sams_test b1w_1_reg_svc_actorder_v20_sams_test

type variables
Long il_orderno, il_validkey_cnt, il_contractseq
String is_act_gu, is_cus_status, is_validkey_yn, is_svctype, is_svccode, is_type
String is_confirm_svccod[]
String is_langtype   //언어선택
String is_n_langtype, is_n_auth_method, is_n_validitem1, is_n_validitem2, is_n_validitem3
String is_validkey_type

//인증Key 관리
Integer ii_cnt
String  is_moveyn

//회선정산관련 추가
String is_in_svctype, is_out_svctype, is_validkey_msg, is_inout_svc_gu
String is_bonsa_partner
String is_hotbillflag   //고객hotbillflag
String is_validkeyloc, is_h323id[]
String is_reg_partner, is_priceplan, is_customerid

String is_callforward_code[], is_callforward_type, is_addition_itemcod

String is_partner_cus_yn, is_date_allow_yn

// 달력관련 추가-1hera
s_calendar_sams istr_cal

//SCHEDULE_DETAIL.SCHEDULESEQ
Long		il_SCHEDULESEQ
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public function string wfs_get_control (string as_module, string as_ref_no, ref string as_ref_desc)
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine of_resizepanels ()
public function integer wf_itemcod_chk ()
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
		
	
	Else
		ab_check = False
		
	End If
 
Return 0
end function

public function string wfs_get_control (string as_module, string as_ref_no, ref string as_ref_desc);String ls_return, ls_ref_content


SELECT ref_desc, ref_content
  INTO :as_ref_desc, :ls_ref_content
  FROM SYSCTL1T
 WHERE MODULE = :as_module
   AND REF_NO = :as_ref_no;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "System Control select error")
	ls_return = "0"
	Return ls_return
ElseIf SQLCA.SQLCode = 100 Then
	ls_return = "1"
	Return ls_return
Else
	ls_return = "2" + ls_ref_content
End If
	
Return ls_return
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
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
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
ELSE
	Select customerid,
			 customernm,
			 status,
		  	 payid,
		    partner
	  Into :ls_customerid,
	       :ls_customernm,
		    :is_cus_status,
		    :ls_payid,
		    :ls_partner
	  From customerm
	 Where memberid = :as_memberid;
	 ls_memberid = as_customerid
END IF

If SQLCA.SQLCode = 100 Then		//Not Found
	IF li_sw = 1 THEN
   	f_msg_usr_err(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	f_msg_usr_err(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
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
dw_cond.object.memberid[1] 	= ls_memberid

//고객정보 partner 관리시 2005-12-21 khpark modify 
IF is_partner_cus_yn <> '0' Then
	dw_cond.object.reg_partner[1] 			= ls_partner
	dw_cond.object.sale_partner[1] 			= ls_partner
	dw_cond.object.reg_partnernm[1] 			= ls_partner
	dw_cond.object.sale_partnernm[1] 		= ls_partner
	dw_cond.object.maintain_partner[1] 		= ls_partner
	dw_cond.object.maintain_partnernm[1] 	= ls_partner
End IF

Return 0

end function

public subroutine of_resizepanels ();// parkkh modify 2004.04.27
Long ll_Width, ll_Height, ll_long, ll_long_1, ll_long_2

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return

ll_Width 	= WorkSpaceWidth()
ll_Height 	= WorkspaceHeight()

If il_validkey_cnt > 0 Then
	// Middle processing
	idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness )
	idrg_Middle.Resize(idrg_Middle.Width, st_horizontal.Y - st_horizontal2.Y - cii_BarThickness)
	// Bottom Processing
	idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness )
	idrg_Bottom.Resize(idrg_Middle.Width, p_insert.Y - st_horizontal.Y - cii_BarThickness * 2 )	
Else
	// Middle processing
	idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)
	idrg_Middle.Resize(idrg_Middle.Width, p_insert.Y - st_horizontal2.Y - cii_BarThickness * 2)		
End If

dw_cond.SetFocus()
dw_cond.Setrow(1)
dw_cond.SetColumn("memberid")
end subroutine

public function integer wf_itemcod_chk ();Long    	ll_row, 					ll_gubun[], 	ll_type[], 	ll_cnt, 	ll_cnt_1
Integer 	li_rc, 					i
String  	ls_chk
Boolean 	ib_jon, 					ib_jon_1, &
			lb_check 	= False, &
			lb_check_2 	= False
String 	ls_addition_code[], 	ls_callforward_info

ib_jon   = False
ib_jon_1 = False

ll_cnt 					= 0
is_callforward_type 	= ''
ls_callforward_info 	= 'N'

For i = 1 To dw_detail2.RowCount()
	ll_gubun[i]      = dw_detail2.Object.groupno[i]
	ll_type[i]       = dw_detail2.Object.grouptype[i]
	ls_chk           = dw_detail2.Object.chk[i]	
	If ls_chk = 'Y' Then			ll_cnt ++
	IF ll_type[i] = 1 Then
		ib_jon   = True
	Else
		ib_jon_1 = True
	End If
	
	//2005-07-06 khpark add start     //착신전환부가서비스 check
	IF ls_chk = 'Y' Then
		ls_addition_code[i] = dw_detail2.object.itemmst_addition_code[i]
		CHOOSE CASE ls_addition_code[i]    
			CASE is_callforward_code[1],is_callforward_code[2],is_callforward_code[3]   //착신전환유형일때 
				//착신전환부가서비스 품목은 하나만 선택 가능하다.
				IF ls_callforward_info = 'Y' Then
					f_msg_info(9000, Title, "품목구성이 올바르지않습니다.(착신전환부가서비스품목하나이상선택)")						
					return -2
				End IF
				is_callforward_type =  ls_addition_code[i]
				is_addition_itemcod =  dw_detail2.object.itemcod[i]
				ls_callforward_info = 'Y'
		END CHOOSE	
   End IF
   //2005-07-06 khpark add end		
   
Next

If ll_cnt = 0 Then
	f_msg_info(9000, Title, "품목을 선택하여야 합니다.")	
	Return  -2
End If

ll_cnt   = 0
ll_cnt_1 = 0
ls_chk   = ''

//동일 그룹일때 선택유형이 0이면 하나만 선택해야하고 동일 그룹일때 선택유형이 1이면 하나 이상  선택하여야한다.
//선택유형이 0인것중 group이  여러종류로 구성되어있다면..각동일그룹에서 하나씩만 선택되어야한다.
long cnt = 0, t
For i = 1 To UpperBound(ll_gubun)  
	If ll_type[i] = 0 Then 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail2.Object.chk[t] = 'Y' Then
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
				If dw_detail2.Object.chk[t] = 'Y' Then
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
				If dw_detail2.Object.chk[t] = 'Y' Then
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
	End If
Next


return 1   //정상 return
end function

public subroutine of_refreshbars ();dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('memberid')

end subroutine

public subroutine of_resizebars ();// parkkh modify 2004.04.27
st_horizontal2.Move(idrg_Middle.X, st_horizontal2.Y)
st_horizontal2.Resize(idrg_Top.Width, cii_Barthickness)

st_horizontal.Move(idrg_Middle.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('memberid')


end subroutine

on b1w_1_reg_svc_actorder_v20_sams_test.create
int iCurrent
call super::create
this.uo_1=create uo_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.uo_1
end on

on b1w_1_reg_svc_actorder_v20_sams_test.destroy
call super::destroy
destroy(this.uo_1)
end on

event open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder_v20
	Desc	: 	서비스 개통신청
	Ver.	:	2.0
	Date	:   2005.04.13.
	Programer : Park Kyung Hae(khpark)
-------------------------------------------------------------------------*/
call w_a_condition::open

String ls_ref_desc, ls_temp, &
		 ls_memberid, ls_customernm

iu_cust_db_app = Create u_cust_db_app

//// Set the TopLeft, TopRight, and Bottom Controls
idrg_Top 		= dw_master
idrg_Middle 	= dw_detail2
idrg_Bottom 	= dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop 					= idrg_Top.Y
ii_WindowMiddle 				= idrg_Middle.Y
st_horizontal.BackColor 	= BackColor
st_horizontal2.BackColor 	= BackColor
il_HiddenColor 				= BackColor

dw_detail.Enabled = False
dw_detail.visible = False

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

//수정불가능
dw_cond.object.priceplan.Protect 	   = 1
dw_cond.object.prmtype.Protect 		   = 1
dw_cond.object.svccod.Protect 		   = 1
dw_cond.object.acttype.Protect 		   = 1
dw_cond.object.related_order.Protect 	= 1

//날짜 Setting
dw_cond.object.orderdt[1] 				= Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] 			= fdt_get_dbserver_now()
dw_cond.object.partner[1] 				= gs_SHOPid
dw_cond.object.reg_partner[1] 		= gs_SHOPid
dw_cond.object.sale_partner[1] 		= gs_SHOPid
dw_cond.object.reg_partnernm[1] 		= gs_SHOPid
dw_cond.object.sale_partnernm[1] 	= gs_SHOPid
dw_cond.object.maintain_partner[1] 	= gs_SHOPid
dw_cond.object.maintain_partnernm[1] = gs_SHOPid

IF gs_onOff = '1' then 
   wfi_get_customerid(gs_cid, "")
   dw_cond.object.svccod.Protect = 0
//	dw_cond.object.customerid[1] 		= gs_CID
	gs_onOff = '0'
END IF

//ls_ref_desc = ""
////gkid default 값
//is_gkid = fs_get_control("00", "G100", ls_ref_desc)
//dw_cond.object.gkid[1] = is_gkid

il_orderno = 0

//비과금 서비스 값
is_type = fs_get_control("B0", "P103", ls_ref_desc)

//구매확인Call 서비스코드 값
ls_temp = wfs_get_control("B0", "P300", ls_ref_desc)
If LeftA(ls_temp, 1) = "2" Then
	fi_cut_string(ls_temp, ";", is_confirm_svccod[])
ElseIf LeftA(ls_temp, 1) = "0" Then
	Return
End If

//서비스Type : 입중계서비스 
is_in_svctype = fs_get_control("B0", "P108", ls_ref_desc)
//서비스Type : 출중계서비스
is_out_svctype = fs_get_control("B0", "P109", ls_ref_desc)

//ValidInfo LangType
//is_langtype = fs_get_control("B1", "P204", ls_ref_desc)

//본사대리점코드
is_bonsa_partner = fs_get_control("A1", "C102", ls_ref_desc)

dw_cond.object.priority[1] = '0'
dw_cond.object.langtype[1] = is_langtype

//부가서비스유형코드  //2005-07-06 khpark add
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_callforward_code[])

//고객정보 partner 관리여부 2005-12-21 khpark add
ls_ref_desc = ""
is_partner_cus_yn = fs_get_control("00", "Z911", ls_ref_desc)

////Validkey 할당모듈 사용여부
//is_moveyn = fs_get_control("B1", "P401", ls_ref_desc)
//
////2005.02.14 OHJ VALIDKEY_LOC 컨트롤..
//is_validkeyloc = fs_get_control("00","Z400", ls_ref_desc)
//
////2005.02.14 OHJ　h323id 컨트롤..
//ls_ref_desc = ""
//ls_temp = fs_get_control("00", "Z700", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , is_h323id[]) 


uo_1.Hide()
PostEvent("resize")





end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String 	ls_svccod, 		ls_priceplan, 		ls_customerid, &
			ls_partner, 	ls_requestdt,		ls_where,&
			ls_contract_no,ls_gkid, 			ls_auth_method, 		ls_sysdt, &
			ls_ip_address, ls_h323id, 			ls_bil_fromdt, 		ls_reg_partner,&
			ls_sale_artner,ls_langtype, 		ls_ref_desc, 			ls_temp,&
			ls_result[],	ls_memberid,		ls_sale_partner,     ls_related_orderno
Long 		ll_row, 			ll_result
Int 	   li_cnt

ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_requestdt    = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_bil_fromdt   = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_related_orderno = String(dw_cond.object.related_order[1])

ls_customerid   = Trim(dw_cond.object.customerid[1])
ls_memberid     = Trim(dw_cond.object.memberid[1])
ls_svccod       = Trim(dw_cond.object.svccod[1])
ls_priceplan    = Trim(dw_cond.object.priceplan[1])
ls_partner      = Trim(dw_cond.object.partner[1])
is_act_gu       = Trim(dw_cond.object.act_gu[1])
ls_reg_partner  = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])

If IsNull(ls_memberid) 		Then ls_memberid 		= ""
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_svccod) 		Then ls_svccod 		= ""
If IsNull(ls_priceplan) 	Then ls_priceplan 	= ""
If IsNull(ls_requestdt) 	Then ls_requestdt 	= ""
If IsNull(ls_bil_fromdt) 	Then ls_bil_fromdt 	= ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
If IsNull(is_act_gu) 		Then is_act_gu 		= ""
If IsNull(ls_reg_partner) 	Then ls_reg_partner 	= ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""
If IsNull(ls_related_orderno) Then ls_related_orderno = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	ll_row = wfi_get_customerid(ls_customerid, "")		//올바른 고객인지 확인
	If ll_row = -1 Then Return
End If

If ls_requestdt = "" Then
	f_msg_info(200, Title, "개통요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If

IF is_date_allow_yn = 'N' Then  //고객정보 partner 관리시 2005-12-22 khpark modify
	If ls_requestdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("requestdt")
		Return
	End If		
End iF

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

//If is_act_gu = "" Then
//	f_msg_info(200, Title, "개통처리")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("act_gu")
//	Return
//End IF

If is_act_gu = "Y" Then
	If ls_bil_fromdt = "" Then
		f_msg_info(200, Title, "과금시작일")
		dw_cond.SetFocus()
		dw_cond.Setrow(1)
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If
	
	IF is_date_allow_yn = 'N' Then   //고객정보 partner 관리시 2005-12-22 khpark modify
		If ls_bil_fromdt < ls_sysdt Then
			f_msg_usr_err(210, Title, "과금시작일은 오늘날짜 이상이여야 합니다.")
			dw_cond.SetFocus()
			dw_cond.Setrow(1)
			dw_cond.SetColumn("bil_fromdt")
			Return
		End If		
	End IF

End IF

//parkkh modify by 입중계출중계서비스추가 start 
IF is_inout_svc_gu = 'N' Then
	If ls_partner = "" Then
		f_msg_info(200, Title, "수행처")
		dw_cond.SetFocus()
		dw_cond.Setrow(1)
		dw_cond.SetColumn("partner")
		Return
	End If
	
	If ls_reg_partner = "" Then
		f_msg_info(200, Title, "Attraction Place")
		dw_cond.SetFocus()
 		dw_cond.Setrow(1)
		dw_cond.SetColumn("reg_partner")
		Return
	End If
	
	If ls_sale_partner = "" Then
		f_msg_info(200, Title, "Sales Location")
		dw_cond.SetFocus()
		dw_cond.Setrow(1)
		dw_cond.SetColumn("sale_partner")
		Return
	End If
End IF

// related_orderno check
SELECT count(*) INTO :li_cnt FROM svc_relation WHERE priceplan = :ls_priceplan;

IF li_cnt > 0 AND ls_related_orderno = "" THEN
	f_msg_info(200,Title,"Realation Order No")
	dw_cond.SetFocus()
	dw_cond.Setrow(1)
	dw_cond.SetColumn("related_order")
	Return
END IF

//IF is_inout_svc_gu = 'N' Then
dw_detail.dataObject = "b1dw_reg_svc_actorder_ipn_v20"
dw_detail.Trigger Event Constructor()
//Elseif is_inout_svc_gu = 'Y' Then
//	dw_detail.dataObject = "b1dw_reg_svc_actorder_ipn_1_v20"
//    dw_detail.Trigger Event Constructor()
//End If

//parkkh modify by 입중계출중계서비스추가 end

is_n_langtype  	= Trim(dw_cond.object.langtype[1])
is_validkey_type 	= Trim(dw_cond.object.validkey_type[1])
If IsNull(is_n_langtype) 		Then is_n_langtype 		= ""
If IsNull(is_validkey_type) 	Then is_validkey_type 	= ""

ls_where = ""
ls_where += "det.priceplan ='" + ls_priceplan + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row = 0 Then
	//f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

SetRedraw(False)

If ll_row >= 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail2.SetFocus()

	dw_detail2.Enabled 	= True
	dw_cond.Enabled 		= False
	p_ok.TriggerEvent("ue_disable")
End If

If il_validkey_cnt > 0 Then
	dw_detail.ib_insert 	= True
	dw_detail.ib_delete 	= True	
	dw_detail.Enabled 	= True
	dw_detail.visible 	= True	
	dw_detail.setfocus()	
	st_horizontal.Visible = True
	
	If is_inout_svc_gu = 'N' Then   //입출중계서비스가 아닐때만..Check
		//해당 Priceplan 인증KeyLocation 입력여부 
		ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccode, ii_cnt)
		
		//인증Key Location 입력여부
		IF ii_cnt > 0 Then
			dw_detail.Object.validkey_loc.visible 		= True
			dw_detail.Object.validkey_loc_t.visible 	= True
		Else
			dw_detail.Object.validkey_loc.visible 		= False
			dw_detail.Object.validkey_loc_t.visible 	= False
		End IF	
	End IF

Else 
	dw_detail.ib_insert 		= False
	dw_detail.ib_delete 		= False
	dw_detail.Enabled 		= False
	dw_detail.visible 		= False
	st_horizontal.Visible 	= False
End If

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event ue_reset();String ls_ref_desc, ls_temp
Int li_rc, li_ret

ii_error_chk = -1

//p_save.PictureName = "Active_e.gif"
//
dw_detail.AcceptText()

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
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

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("memberid")

ii_error_chk = 0

dw_cond.object.priceplan.Protect 	= 1
dw_cond.object.prmtype.Protect 		= 1
dw_cond.object.svccod.Protect 		= 1

//Reset 하면 related_orderno도 다시 없어지게...
dw_cond.object.related_order.visible = false;
dw_cond.object.t_5.visible = false;
dw_cond.object.related_order.Protect 	= 1

dw_cond.object.orderdt[1] 				= Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] 			= fdt_get_dbserver_now()
dw_cond.object.partner[1] 				= gs_SHOPid
dw_cond.object.reg_partner[1] 		= gs_SHOPid
dw_cond.object.sale_partner[1] 		= gs_SHOPid
dw_cond.object.reg_partnernm[1] 		= gs_SHOPid
dw_cond.object.sale_partnernm[1] 	= gs_SHOPid
dw_cond.object.maintain_partner[1] 	= gs_SHOPid
dw_cond.object.maintain_partnernm[1] = gs_SHOPid
dw_cond.object.priority[1] 			= '0'
dw_cond.object.langtype[1] 			= is_langtype
IF gs_onOff = '1' then 
   wfi_get_customerid(gs_cid, "")
   dw_cond.object.svccod.Protect = 0
//	dw_cond.object.customerid[1] 		= gs_CID
	gs_onOff = '0'
END IF


// 2008-02-21 스케쥴 인덱스 리셋 hcjung
GL_SCHEDULSEQ = 0



is_validkey_yn 	= 'N'
il_validkey_cnt 	= 0
//dw_cond.object.gkid[1] = is_gkid


il_orderno = 0

SetRedraw(False)

dw_detail.Enabled 		= False
dw_detail.visible 		= False
st_horizontal.Visible 	= False

of_ResizeBars()
of_ResizePanels()


SetRedraw(True)

end event

event type integer ue_save();String 	ls_quota_yn, 	ls_chk, ls_customernm, 	ls_memberid, 	ls_priceplan
String 	ls_onefee,  	ls_bil, ls_reqdt, 		ls_orderdt, 	ls_svccod
Long 		i, 				ll_row, 						j, 				k,		m
Int 		li_rc
Boolean 	lb_quota,	lb_direct
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

ls_svccod 		= trim(dw_cond.Object.svccod[1])
ls_priceplan 	= trim(dw_cond.Object.priceplan[1])


This.Trigger Event ue_extra_save(li_rc)

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
	//===============================================
	//Schedule 입력했으면 orderno Update
	//===============================================
	IF GL_SCHEDULSEQ > 0 then
		UPDATE SCHEDULE_DETAIL  
         SET ORDERNO 		= :il_orderno, 
			    SVCCOD 			= :LS_SVCCOD,
				 PRICEPLAN 		= :ls_priceplan
       WHERE SCHEDULESEQ 	= :gl_schedulseq;

		If SQLCA.SQLCode < 0 Then
			Rollback ;
			f_msg_sql_err(Title, "SCHEDULE_DETAIL Update Error")
			return -1
		ELSE
			Commit ;
		End If			
	END IF
	
End if

//저장한거로 인식하게 함.
For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next  

For i = 1 To dw_detail2.RowCount()
	dw_detail2.SetitemStatus(i, 0, Primary!, NotModified!)
Next 

p_save.TriggerEvent("ue_disable")		//버튼 비활성화
p_insert.TriggerEvent("ue_disable")		//버튼 비활성화
p_delete.TriggerEvent("ue_disable")		//버튼 비활성화
dw_detail.ib_insert = False
dw_detail.ib_delete = False

dw_detail2.enabled = False
dw_detail.enabled = False

String ls_customerid


iu_cust_msg = Create u_cust_a_msg
j = 1
//-------------------------------------------------
//할부 품목을 신청했으면 Quota_yn =  Y 
ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0
ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_orderdt 		= String(dw_cond.object.orderdt[1], 'yyyymmdd')


lb_quota = False
For i = 1 To ll_row
	ls_chk 		= Trim(dw_detail2.object.chk[i])
	ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
	ls_bil 		= Trim(dw_detail2.object.bilitem_yn[i])
	
	If ls_chk = "Y" AND ls_quota_yn = "Y" Then
		iu_cust_msg.is_data[j] = Trim(dw_detail2.object.itemcod[i])
		lb_quota = TRUE
		j++
	End If
Next

If lb_quota Then			//할부 Check한게 있으면
	ls_customerid = Trim(dw_cond.object.customerid[1])
	
	iu_cust_msg.is_pgm_name = "서비스품목 할부 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.is_pgm_id 	= gs_pgm_id[gi_open_win_no]
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno						//order number
	iu_cust_msg.il_data[2]  = il_contractseq					//contractseq
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	iu_cust_msg.is_data2[4] = is_act_gu                   //개통처리 여부
	 
    OpenWithParm(b1w_reg_quotainfo_pop_2_SAMS, iu_cust_msg)
End If


Boolean lb_rental = False

iu_cust_msg = Create u_cust_a_msg
k = 1
//임대 품목을 신청했으면 ==> quota_yn = R
ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0
For i = 1 To ll_row
	ls_chk 		= Trim(dw_detail2.object.chk[i])
	ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
	ls_onefee 	= Trim(dw_detail2.object.ONEOFFCHARGE_YN[i])
	ls_bil 		= Trim(dw_detail2.object.bilitem_yn[i])
	If ls_chk = "Y" AND ls_quota_yn = "R"  Then
		iu_cust_msg.is_data[k] = Trim(dw_detail2.object.itemcod[i])
		lb_rental = True
		k++
	End If
Next

If lb_rental Then			//임대 Check한게 있으면
	ls_customerid = Trim(dw_cond.object.customerid[1])
	ls_customernm = Trim(dw_cond.object.customernm[1])
	ls_reqdt 		= String(dw_cond.object.requestdt[1], 'yyyymmdd')

	iu_cust_msg.is_pgm_name = "서비스품목 장비임대 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno						//order number
	iu_cust_msg.il_data[2]  = il_contractseq					//contractseq
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	iu_cust_msg.is_data2[4] = is_act_gu                   //개통처리 여부
	iu_cust_msg.is_data2[5] = ls_customernm               //
	iu_cust_msg.is_data2[6] = ls_reqdt              		 //req date
	 
    OpenWithParm(b1w_reg_rental_pop_v20_sams, iu_cust_msg)
	
End If


//=========================================
//즉시불 처리 항목 여부 check
// bilitem_yn = 'N' AND oneoffcharge_yn = 'Y'
//=========================================


lb_direct =  False
iu_cust_msg = Create u_cust_a_msg
m = 1
ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0
For i = 1 To ll_row
	ls_chk 		= Trim(dw_detail2.object.chk[i])
	ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
	ls_onefee 	= Trim(dw_detail2.object.ONEOFFCHARGE_YN[i])
	ls_bil 		= Trim(dw_detail2.object.bilitem_yn[i])
	If ls_chk = "Y" AND ls_onefee = "Y" and ls_bil = 'N' Then
		iu_cust_msg.is_data[m] = Trim(dw_detail2.object.itemcod[i])
		lb_direct = True
		m++
	End If
Next

If lb_direct Then			//즉시불 처리
	ls_customerid 	= Trim(dw_cond.object.customerid[1])
	ls_reqdt 		= String(dw_cond.object.requestdt[1], 'yyyymmdd')
	ls_memberid 	= Trim(dw_cond.object.memberid[1])
	ls_priceplan 	= Trim(dw_cond.object.priceplan[1])
	ls_svccod 		= Trim(dw_cond.object.svccod[1])
	iu_cust_msg.is_pgm_name = "서비스품목 장비 즉시불 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno					//order number
	iu_cust_msg.il_data[2]  = il_contractseq				//contractseq
	iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
	iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
	iu_cust_msg.is_data[3] 	= ls_memberid 					//member ID
	iu_cust_msg.is_data[4] 	= ls_reqdt 			//
	iu_cust_msg.is_data[5] 	= ls_priceplan 				//가격정책
	iu_cust_msg.is_data[6] 	= ls_svccod 				//서비스
	
	iu_cust_msg.idw_data[1] = dw_detail2
	OpenWithParm(b1w_reg_directpay_pop_sams, iu_cust_msg)
END IF


//iu_cust_msg = Create u_cust_a_msg
////선수금등록 2004-12-20 kem 추가
//ls_customerid 	= Trim(dw_cond.object.customerid[1])
//ls_memberid 	= Trim(dw_cond.object.memberid[1])
//ls_priceplan 	= Trim(dw_cond.object.priceplan[1])
//
//iu_cust_msg.is_pgm_name = "후불서비스 선수금등록"
//iu_cust_msg.is_grp_name = "후불서비스 신청"
//iu_cust_msg.ib_data[1]  = True
//iu_cust_msg.il_data[1]  = il_orderno					//order number
//iu_cust_msg.il_data[2]  = il_contractseq				//contractseq
//iu_cust_msg.is_data[2] = ls_customerid					//customer ID
//iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no] //Pgm ID
//iu_cust_msg.is_data[4] = ls_memberid 					//member ID
//iu_cust_msg.is_data[5] = ls_priceplan 					//가격정책
//iu_cust_msg.idw_data[1] = dw_detail2
// 
// 
//OpenWithParm(b1w_reg_prepay_popup, iu_cust_msg)
//
//TriggerEvent("ue_reset")
Return 0
end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;
Long    ll_row, ll_gubun[], ll_type[], ll_cnt, ll_cnt_1
Integer li_rc, i, j, p
String  ls_chk
Boolean ib_jon, ib_jon_1, lb_check = False, lb_check_2 = False

b1u_dbmgr_v20	lu_dbmgr

SetNull(il_contractseq)
ll_row  = dw_detail2.RowCount()
//If ll_row = 0 Then 
//	ai_return = 0
//	Return
//End if

//2005-07-06 khpark modify start
//itemcod check 윈도우 함수로 뺀다. wf_itemcod_chk()
//ue_extra_insert에서도 check한다.
//2005-07-29 kem modify (ll_row check)

If ll_row > 0 Then
	ai_return = wf_itemcod_chk()
	IF ai_return <= 0 Then
		return
	End IF
End If
//2005-07-06 khpark modify end

If il_validkey_cnt > 0 Then
	ll_row  = dw_detail.RowCount()
	If ll_row = 0 Then 
		f_msg_usr_err(9000, Title, is_validkey_msg +"를 입력하셔야 합니다.")		
		ai_return = -2
		Return
	End if
End if

//저장
lu_dbmgr = Create b1u_dbmgr_v20
lu_dbmgr.is_caller   = "b1w_reg_svc_actorder_v20%save"
lu_dbmgr.is_title    = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2               //품목
lu_dbmgr.idw_data[3] = dw_detail			     		//인증KEY
lu_dbmgr.is_data[1]  = gs_user_id
lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[3]  = is_act_gu                 //개통처리 check
lu_dbmgr.is_data[4]  = is_cus_status             //고객상태
lu_dbmgr.is_data[5]  = is_svctype                //svctype
lu_dbmgr.is_data[6]  = string(il_validkey_cnt)   //인증KEY갯수
lu_dbmgr.is_data[7]  = is_type         			 //MVNO svc type
lu_dbmgr.is_data[8]  = is_inout_svc_gu    		 //입중계출중계 서비스여부
//khpark add 2005-07-07
lu_dbmgr.is_data[9]  = is_callforward_type    	 //착신전환부가서비스선택유형
lu_dbmgr.is_data[10]  = is_addition_itemcod    	 //착신전환품목서비스선택유형

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	ai_return = -1
	Return
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	ai_return = -2	
	Return
End If

If li_rc = -3 Then
	Destroy lu_dbmgr
	ai_return = -3		
	Return
End If

il_orderno = lu_dbmgr.il_data[1]

If is_act_gu = "Y" Then
	il_contractseq = lu_dbmgr.il_data[2]
End If

Destroy lu_dbmgr

ai_return = li_rc

Return
end event

event resize;//If newwidth < dw_detail2.X  Then
//	dw_detail2.Width = 0
//Else
//	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
//End If
//
end event

event ue_insert();//override
Long ll_row, ll_cnt
Int li_return

ll_cnt = dw_detail.RowCount()
If ll_cnt >= il_validkey_cnt Then
	f_msg_usr_err(9000,title,"해당가격정책에 인증KEY 등록은 ~r~n~r~n" +string(il_validkey_cnt)+ "개까지 등록 가능합니다.")
	Return
End If

This.Trigger Event ue_extra_insert(ll_row,li_return)
uo_1.Hide()

If li_return < 0 Then
	Return
End If


end event

event ue_extra_insert(long al_insert_row, ref integer ai_return);call super::ue_extra_insert;long   ll_row
String ls_svccod, ls_partner

//2005-07-06 khpark add start
//2005-07-29 kem modify (itemcod 가 있는지 체크) 추가
If dw_detail2.Rowcount() > 0 Then
	ai_return = wf_itemcod_chk()
	IF ai_return <= 0 Then
		return
	End IF
End If
//2005-07-06 khpark modify end

is_reg_partner = Trim(dw_cond.Object.reg_partner[1])
is_priceplan   = Trim(dw_cond.Object.priceplan[1])
is_customerid  = Trim(dw_cond.Object.customerid[1])
ls_svccod      = fs_snvl(dw_cond.Object.svccod[1], '')
ls_partner 		= Trim(dw_cond.Object.partner[1])

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "인증정보수정등록"
iu_cust_msg.is_grp_name = "서비스개통신청"
iu_cust_msg.is_data[1] = "Ue_extra_insert"
iu_cust_msg.is_data[2] =  is_validkey_type  //인증KeyType
iu_cust_msg.is_data[3] = is_n_langtype      //멘트언어
iu_cust_msg.is_data[4] = is_priceplan       //가격정책
iu_cust_msg.is_data[5] = is_reg_partner     //유치처
iu_cust_msg.is_data[6] = is_customerid      //고객번호
iu_cust_msg.is_data[8] = ls_svccod                         //서비스코드  언어맨트때문에 추가 0711
iu_cust_msg.is_data[9] = ls_partner  //add - ssrt Shopid
iu_cust_msg.ii_data[1] = ii_cnt             //발신지Location check yn ii_cnt
iu_cust_msg.il_data[1] = 1                  //현재row
iu_cust_msg.idw_data[1] = dw_detail
//2005-07-06 khpark add
iu_cust_msg.is_data[7] = is_callforward_type //착신전환유형

//dw_detail의 dddw의 retrieve를 위해서
//b1w_reg_svc_actorder_validinfo_pop_v20 에서 close 시 rowscopy 하는데.. 
//이때, dw_detail에 한건도 없을 경우 dddw가 셋팅이 제대로 되지 않아 insertrow 하고 deleterow 한다.
ll_row = dw_detail.rowcount()
If ll_row =  0 Then
	dw_detail.insertrow(0)
	dw_detail.deleterow(0)
End IF

//IF is_inout_svc_gu = 'N' Then    //입출중계서비스가 아닐 경우
	OpenWithParm(b1w_reg_svcorder_validinfo_pop_v20_sams, iu_cust_msg)
	
//Else                             //입출중계서비스일 경우
//	OpenWithParm(b1w_reg_svcorder_validinfo_pop_1_v20, iu_cust_msg)
//End IF

end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 32
integer y = 60
integer width = 2674
integer height = 692
integer taborder = 10
string dataobject = "b1dw_1_cnd_reg_svc_actorder_v20_sams_tes"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild 	ldc_priceplan, 	ldc_svcpromise, 		ldc_svccod,&
						ldc_vprice, 		ldc_validkey_type, 	ldc_wkflag2, ldc_related_order
Long 					li_exist, 			ll_i, 					ll_row, 		ll_svcctl_cnt
String 				ls_filter, 			ls_validkey_yn, 		ls_act_gu, 	ls_customerid, &
						ls_currency_type, ls_partner1, &
       				ls_customer_id, 	ls_svccode,				ls_sql
Boolean 				lb_check, 			lb_confirm
datetime 			ldt_date
Integer				il_acttype_cnt, relation_cnt

//선불고객에는 선불 서비스만
//If dwo.name = "customerid" Then
//   wfi_get_child(data)
//End If

SetNull(ldt_date)

This.AcceptText()

Choose Case dwo.name
	Case "memberid" 
   	  wfi_get_customerid("", data)
		  This.object.svccod.Protect = 0
	Case "customerid" 
   	  wfi_get_customerid(data, "")
		  This.object.svccod.Protect = 0
	Case "requestdt" 
			ls_act_gu 	= This.object.act_gu[row]
			If ls_act_gu = 'Y' Then
				This.object.bil_fromdt[row] = This.object.requestdt[row]
			End If
	Case "act_gu" 
			If data = 'Y' Then
				This.object.bil_fromdt[row] = This.object.requestdt[row]
			ElseIf  data = 'N'Then
				This.object.bil_fromdt[row] = ldt_date
			End If
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
			This.object.related_order[1] = ""
			This.object.related_order.visible = false;
  		   This.object.t_5.visible = false;
		   This.object.related_order.Protect = 1
			
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
		
			If is_svctype = is_type Then  //비과금서비스Type일때(김은미대리추가사항)
				This.object.act_gu[1] 				= 'N'
				This.object.bil_fromdt[1] 			= ldt_date
				This.object.act_gu.Protect 		= 1
				This.object.bil_fromdt.Protect 	= 1
			
				ls_partner1 = Trim(This.object.partner1[1])
				If IsNull(ls_partner1) Then ls_partner1 = ""
				If ls_partner1 = "" Then
					SELECT PARTNER INTO :ls_partner1	FROM SVCMST
				 	 WHERE SVCTYPE = :is_type
				   	AND SVCCOD  = :data ;
					
					If SQLCA.SQLCode <> 0 Then
						f_msg_usr_err(2100, Title, "Retrieve()")
						Return 1
					End If
					This.object.partner1[1] = ls_partner1
				End If
			Else 
				lb_confirm = False
				For ll_row = 1 To UpperBound ( is_confirm_svccod[] )
					If data = is_confirm_svccod[ll_row] Then	lb_confirm = True
				Next
			
				If lb_confirm = True Then
					This.object.act_gu[1] 			= 'N'
					This.object.act_gu.Protect 	= 1
				Else
					This.object.act_gu[1] 			= 'N'
					This.object.bil_fromdt[1] 		= ldt_date
					This.object.act_gu.Protect 	= 0
					This.object.bil_fromdt.Protect = 0
				End If
			
				This.object.partner1[1] 		= ""
				This.object.vpricecod[1] 		= ""
				This.object.vpricecod.Protect = 1
			End If
		
      	//회선정산(입중계출중계서비스Type)일 경우 컬럼별 Check
			//2004-08-26 parkkh modify start
			IF (is_in_svctype = is_svctype) or ( is_out_svctype = is_svctype) Then
				This.object.inout_svc_gu[1] 	= 'Y'
				is_inout_svc_gu 					= 'Y'
				is_validkey_msg					 = 'Route-No.'
				IF is_partner_cus_yn = '0' Then   //고객정보 partner 관리안할경우 2005-12-21 khpark modify
					This.object.partner[1] 				= is_bonsa_partner
					This.object.reg_partner[1] 		= is_bonsa_partner
					This.object.sale_partner[1] 		= is_bonsa_partner
					This.object.maintain_partner[1] 	= is_bonsa_partner
					This.object.reg_partnernm[1] 		= is_bonsa_partner
					This.object.sale_partnernm[1] 	= is_bonsa_partner
					This.object.maintain_partnernm[1] = is_bonsa_partner
				End IF
			Else 
				This.object.inout_svc_gu[1] = 'N'
				is_inout_svc_gu = 'N'
				is_validkey_msg = '인증KEY'
				IF is_partner_cus_yn = '0' Then  //고객정보 partner 관리안할경우 2005-12-21 khpark modify
					This.object.partner[1] 				= is_bonsa_partner
					This.object.reg_partner[1] 		= is_bonsa_partner
					This.object.sale_partner[1] 		= is_bonsa_partner
					This.object.maintain_partner[1] 	= is_bonsa_partner
					This.object.reg_partnernm[1] 		= is_bonsa_partner
					This.object.sale_partnernm[1] 	= is_bonsa_partner
					This.object.maintain_partnernm[1] = is_bonsa_partner 
				End IF
			End IF
			//2004-008-26 parkkh modify end 
      
			uo_1.Show()
			istr_cal.caldate = Today()
			uo_1.uf_InitCal(istr_cal.caldate)

			//언어맨트수정 07/11
			ll_row = This.GetChild("langtype", ldc_wkflag2)
			If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
			ls_filter = "svccod = '" + data + "' "
			ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
			ldc_wkflag2.Filter()
			ldc_wkflag2.SetTransObject(SQLCA)
			ll_row = ldc_wkflag2.Retrieve()
		
			If ll_row < 0 Then 				//디비 오류 
				f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
				Return -1
			End If		
			
			// 2007-07-03 hcjung 장비 반납 여부 체크할 서비스인지 확인해서 체크 박스 활성화
			Select count(*)
		  	  Into :il_acttype_cnt
		     From syscod2t
			 where grcode = 'Z_CCdia_02'  // 시스템 코드
			   and code = :data;
				
			IF il_acttype_cnt > 0 THEN
				This.object.acttype.Protect = 0
				This.object.acttype[1]      = 'Y'
			ELSE
				This.object.acttype[1]      = 'N'
				This.object.acttype.Protect = 1
			END IF
				
	Case "priceplan"
			Select nvl(validkeycnt,0)
		  	  Into :il_validkey_cnt
		     From priceplanmst
			 where priceplan  = :data;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(parent.title, "SELECT validkey_yn from priceplanmst")				
				Return 1
			End If	
		
			If il_validkey_cnt > 0 Then
				This.object.langtype.Protect 					= 0
				This.Object.validkey_type.Protect 			= 0
				This.Object.langtype.Background.Color 		=  RGB(108, 147, 137)
				This.Object.langtype.Color 					= RGB(255, 255, 255)		
				This.Object.validkey_type.Background.Color =  RGB(108, 147, 137)
				This.Object.validkey_type.Color 				= RGB(255, 255, 255)		
			ElseIf il_validkey_cnt = 0 Then
				This.Object.langtype[1] 						= ""
				This.object.langtype.Protect 					= 1
				This.Object.langtype.Background.Color 		= RGB(255, 251, 240)
				This.Object.langtype.Color 					= RGB(0, 0, 0)		
				This.Object.validkey_type[1] 					= ""
				This.object.validkey_type.Protect 			= 1
				This.Object.validkey_type.Background.Color = RGB(255, 251, 240)
				This.Object.validkey_type.Color 				= RGB(0, 0, 0)		
			End If
		
			//가격정책별 인증KEYTYPE
			li_exist = This.GetChild("validkey_type", ldc_validkey_type)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
			ls_filter = "a.priceplan = '" + data  + "'  " 
			ldc_validkey_type.SetTransObject(SQLCA)
			li_exist =ldc_validkey_type.Retrieve()
			ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
			ldc_validkey_type.Filter()
	
			If li_exist < 0 Then 				
		  		f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If
			is_priceplan = data
		
			ls_svccode = Trim(This.object.svccod[1])		
		
			//언어맨트수정 07/11
			ll_row = This.GetChild("langtype", ldc_wkflag2)
			If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
			ls_filter = "svccod = '" + ls_svccode + "' "
			ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
			ldc_wkflag2.Filter()
			ldc_wkflag2.SetTransObject(SQLCA)
			ll_row = ldc_wkflag2.Retrieve()
		
			If ll_row < 0 Then 				//디비 오류 
				f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
				Return -1
			End If	
		
			//2005-12-23 khpark 개통일 check 여부 
      	IF b1fi_date_allow_chk_yn_v20(parent.title,ls_svccode,data,is_date_allow_yn) < 0 Then
			 	return 1
			End IF
			
			// 선행 서비스가 필요한 서비스를 선택하면 선행 신청을 고르게 한다.
//			This.object.related_order[1] = ""
			
			SELECT count(*) 
			  INTO :relation_cnt
			  FROM svc_relation
			 WHERE priceplan = :data;
			
		   IF relation_cnt > 0 THEN
				This.object.related_order.visible = true;
    		   This.object.t_5.visible = true;
			
    			ls_customerid = Trim(This.object.customerid[1])
			
			   li_exist 	= This.GetChild("related_order", ldc_related_order)		//DDDW 구함
			   If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 연관 서비스")

			   ls_sql = "  SELECT a.orderno, " &
		         		+ "   to_char(a.orderdt,'yyyy-mm-dd') orderdt," &
							+ "   c.priceplan_desc," &
							+ "   a.customerid," &
							+ "   b.priceplan" &
							+ "   FROM svcorder a, svc_relation b, priceplanmst c" &
							+ "   WHERE a.priceplan = b.pre_priceplan " &
							+ "	AND a.priceplan = c.priceplan" &
							+ "	AND nvl(a.related_orderno,'0') = '0' " &
							+ "   AND a.order_type = '10' " &
							+ "   AND a.customerid = '" + ls_customerid +  "'  And  b.priceplan = '" + data + "' " &
							+ "	ORDER BY a.orderdt ASC"
				
				
//            ls_filter = " a.customerid = '" + ls_customerid +  "'  And  b.priceplan = '" + data + "' "
//            ls_filter = " a.customerid = '" + ls_customerid +  "'"
//            ls_filter = " b.priceplan = '" + data + "'"
				
//				ldc_related_order.SetFilter(ls_filter)			//Filter정함
//			   ldc_related_order.Filter()
			   ldc_related_order.SetTransObject(SQLCA)
				ldc_related_order.SetSQLSelect(ls_sql)
			   li_exist =ldc_related_order.Retrieve()
			   
		
			   IF li_exist < 0 THEN
                f_msg_usr_err(2100, Title, "Retrieve()")
		  		    RETURN 1  		//선택 취소 focus는 그곳에
				END IF

			   //선택할수 있게
  			   This.object.related_order.Protect = 0

         ELSE
				This.object.related_order.visible = false;
    		   This.object.t_5.visible = false;
 			   This.object.related_order.Protect = 1
			END IF  
						
End Choose	
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

////유치파트너
//This.idwo_help_col[2] 	= This.Object.reg_partner
//This.is_help_win[2] 		= "b1w_hlp_partner"
//This.is_data[2] 			= "CloseWithReturn"
//
////매출 파트너 
//This.idwo_help_col[3] 	= This.Object.sale_partner
//This.is_help_win[3] 		= "b1w_hlp_partner"
//This.is_data[3] 			= "CloseWithReturn"
//
////관리 파트너 
//This.idwo_help_col[4] 	= This.Object.maintain_partner
//This.is_help_win[4] 		= "b1w_hlp_partner"
//This.is_data[4] 			= "CloseWithReturn"
//
dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('memberid')

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
			Object.memberid[1] 		= iu_cust_help.is_data[4]
			
			
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
//	Case "sale_partner"
//		If dw_cond.iu_cust_help.ib_data[1] Then
//			dw_cond.Object.sale_partner[row] = &
//			dw_cond.iu_cust_help.is_data[1]
//			dw_cond.Object.sale_partnernm[row] = &
//			dw_cond.iu_cust_help.is_data[1]
//		End If
//  Case "maintain_partner"
//		If dw_cond.iu_cust_help.ib_data[1] Then
//			dw_cond.Object.maintain_partner[row] = &
//			dw_cond.iu_cust_help.is_data[1]
//			dw_cond.Object.maintain_partnernm[row] = &
//			dw_cond.iu_cust_help.is_data[1]
//		End If
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m3`p_ok within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 3662
end type

type p_close from w_a_reg_m_m3`p_close within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 3662
integer y = 164
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 23
integer width = 2697
integer height = 772
integer taborder = 0
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_1_reg_svc_actorder_v20_sams_test
boolean visible = false
integer x = 41
integer y = 644
integer width = 2190
integer height = 36
integer taborder = 0
end type

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 23
integer y = 1460
integer width = 3611
integer height = 356
integer taborder = 0
string dataobject = "b1dw_reg_svc_actorder_ipn_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

////Help Window
//This.idwo_help_col[1] = This.Object.validkey
//This.is_help_win[1] = "b1w_hlp_validkeymst_2"
//This.is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;long   li_return, ll_row
String ls_svccod

This.accepttext()


//2005-07-06 khpark add start
//2005-07-29 kem modify (ll_row check)
If dw_detail2.Rowcount() > 0 Then
	li_return = wf_itemcod_chk()
	IF li_return <= 0 Then
		return li_return
	End IF
End If
//2005-07-06 khpark add end

If row <= 0 Then return li_return

ls_svccod      = fs_snvl(dw_cond.Object.svccod[1], '')

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "인증정보수정등록"
iu_cust_msg.is_grp_name = "서비스개통신청"
iu_cust_msg.is_data[1] = "Doubleclicked"
iu_cust_msg.is_data[2] = This.object.validkey_type[row]    //인증KeyType
iu_cust_msg.is_data[3] = This.object.langtype[row]         //멘트언어
iu_cust_msg.is_data[4] = is_priceplan                      //가격정책
iu_cust_msg.is_data[5] = is_reg_partner                    //유치처
iu_cust_msg.is_data[6] = is_customerid                     //고객번호
iu_cust_msg.is_data[8] = ls_svccod                         //서비스코드  언어맨트때문에 추가 0711
iu_cust_msg.ii_data[1] = ii_cnt              //발신지Location check yn ii_cnt
iu_cust_msg.il_data[1] = row                 //현재row
iu_cust_msg.idw_data[1] = dw_detail
//2005-07-06 khpark add
iu_cust_msg.is_data[7] = is_callforward_type //착신전환유형

//IF is_inout_svc_gu = 'N' Then
	OpenWithParm(b1w_reg_svcorder_validinfo_pop_v20, iu_cust_msg)
//Else 
//	OpenWithParm(b1w_reg_svcorder_validinfo_pop_1_v20, iu_cust_msg)
//END IF

Return 0
end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 55
integer y = 1828
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 347
integer y = 1828
end type

type p_save from w_a_reg_m_m3`p_save within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 640
integer y = 1828
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 1390
integer y = 1828
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 23
integer y = 820
integer width = 3616
integer height = 592
integer taborder = 0
string dataobject = "b1dw_reg_svc_actorder_v20_sams"
end type

event dw_detail2::constructor;call super::constructor;dw_detail2.SetRowFocusIndicator(off!)
end event

event dw_detail2::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn, ls_quota_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If


For i = 1 To rowcount
	
	ls_mainitem_yn = Trim(dw_detail2.object.mainitem_yn[i])
	ls_quota_yn    = Trim(dw_detail2.object.quota_yn[i])
	
	If IsNull(ls_mainitem_yn) Or ls_mainitem_yn = "" Then ls_mainitem_yn = "N"
	If IsNull(ls_quota_yn)    Or ls_quota_yn    = "" Then ls_quota_yn    = "N"

//	If ls_mainitem_yn = "Y" And ls_quota_yn = "N" Then
//		dw_detail2.object.chk[i] = ls_mainitem_yn
//	ElseIf ls_mainitem_yn = "Y" And ls_quota_yn = "Y" Then
//		dw_detail2.object.chk[i] = "N"
//	Else
//		dw_detail2.object.chk[i] = "N"
//	End If
	//2006-6-30 ModiFy All Check로 - SSRT
	dw_detail2.object.chk[i] = "Y"
	
//	If dw_detail.object.mainitem_yn[i] = "Y" Then
//		dw_detail.object.itemcod.Color = RGB(255,0,255)
//		dw_detail.object.itemnm.Color = RGB(255,0,255)
//		dw_detail.object.quota_yn.Color = RGB(255,0,255)
//		dw_detail.object.chk.Color = RGB(255,0,255)
//	Else
//		dw_detail.object.itemcod.Color = RGB(0,0,0)
//		dw_detail.object.itemnm.Color = RGB(0,0,0)
//		dw_detail.object.quota_yn.Color = RGB(0,0,0)
//		dw_detail.object.chk.Color = RGB(0,0,0)
//	End If

	This.SetItemStatus(i, 0, Primary!, NotModified!)

Next
end event

event dw_detail2::ue_init();call super::ue_init;ib_delete = False
ib_insert = False

end event

event dw_detail2::itemchanged;call super::itemchanged;String ls_mainitem_yn, ls_quota_yn
Long   i, ll_groupno, ll_grouptype, ll_groupno_1, ll_grouptype_1

If dwo.name = "chk" Then
	ls_mainitem_yn = Trim(This.object.mainitem_yn[row])
	ls_quota_yn    = Trim(This.object.quota_yn[row])
	ll_groupno     = This.object.groupno[row]
	ll_grouptype   = This.object.grouptype[row]
	
	If IsNull(ls_mainitem_yn) 	Or ls_mainitem_yn = "" 	Then ls_mainitem_yn 	= "N"
	If IsNull(ls_quota_yn) 		Or ls_quota_yn = "" 		Then ls_quota_yn 		= "N"
	
	//품목group이 동일할때 선택type이 0이면 한품목만 선택 가능
	If ll_grouptype = 0 Then
		If data = "Y" Then
			For i = 1 To dw_detail2.RowCount()
				If i = row Then continue
				
				ll_groupno_1    = This.object.groupno[i]
				ll_grouptype_1  = This.object.grouptype[i]
				
				If ll_groupno = ll_groupno_1  Then					
					IF ll_grouptype_1 = 0 Then
						This.object.chk[i] = "N"
					End If
				End If
				
			Next
		End If
		
	ElseIF ls_mainitem_yn = "Y" and ls_quota_yn = "Y" Then
		If data = "Y" Then
			For i = 1 To dw_detail2.RowCount()
				If i = row Then continue
				
				ls_mainitem_yn = Trim(This.object.mainitem_yn[i])
				ls_quota_yn    = Trim(This.object.quota_yn[i])
				
				If ls_mainitem_yn = "Y" And ls_quota_yn = "Y" Then
					This.object.chk[i] = "N"
				End If	
			Next
		End If
	End If	
End If


end event

event dw_detail2::getfocus;call super::getfocus;ib_insert = True
ib_delete = True

end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_1_reg_svc_actorder_v20_sams_test
integer x = 18
integer y = 776
integer height = 36
end type

event st_horizontal2::mousemove;Constant Integer li_MoveLimit = 50


end event

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_1_reg_svc_actorder_v20_sams_test
boolean visible = false
integer x = 23
integer y = 1420
integer height = 36
end type

event st_horizontal::mousemove;Constant Integer li_MoveLimit = 50

end event

type uo_1 from u_calendar_sams within b1w_1_reg_svc_actorder_v20_sams_test
boolean visible = false
integer x = 2757
integer y = 40
integer height = 712
boolean bringtotop = true
end type

on uo_1.destroy
call u_calendar_sams::destroy
end on

event ue_popup();call super::ue_popup;//messageBox('11', string(istr_cal.caldate, 'yyyymmdd') +  ' ' + String(dw_cond.Object.customerid[1]))

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

//il_SCHEDULESEQ = iu_cust_msg.il_data[1]

//Destroy iu_cust_msg






end event

event ue_clicked();call super::ue_clicked;dw_cond.Object.requestdt[1] =  id_date_selected

end event

