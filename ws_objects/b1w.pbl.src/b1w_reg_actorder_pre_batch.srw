$PBExportHeader$b1w_reg_actorder_pre_batch.srw
$PBExportComments$[kem] 신규고객개통신청처리Batch
forward
global type b1w_reg_actorder_pre_batch from w_a_inq_m
end type
type p_fileread from u_p_fileread within b1w_reg_actorder_pre_batch
end type
type p_reset from u_p_reset within b1w_reg_actorder_pre_batch
end type
type p_insert from u_p_insert within b1w_reg_actorder_pre_batch
end type
type p_delete from u_p_delete within b1w_reg_actorder_pre_batch
end type
end forward

global type b1w_reg_actorder_pre_batch from w_a_inq_m
integer width = 3781
event type integer ue_fileread ( )
event ue_reset ( )
event ue_delete ( )
event ue_insert ( )
p_fileread p_fileread
p_reset p_reset
p_insert p_insert
p_delete p_delete
end type
global b1w_reg_actorder_pre_batch b1w_reg_actorder_pre_batch

type variables
String is_pathname, is_svctype
end variables

forward prototypes
public subroutine fi_location_error (integer find_row)
end prototypes

event type integer ue_fileread();//승인 요청 된 파일 불러옴
String ls_filename
Int li_rc

//파일 선택
//li_rc = GetFileOpenName("Select XLS" , is_pathname, ls_filename, 'xls', &
//						'Excel Files(*.XLS), *.XLS')
						
li_rc = GetFileOpenName("Select Txt" , is_pathname, ls_filename, 'txt', &
						'Text Files(*.TXT), *.TXT')
						
If li_rc = -1 Then 			//Error
    f_msg_usr_err(9000, Title, "파일을 열수 없습니다.") 
	Return -1
End If
						
If li_rc = 1 Then
	dw_detail.reset()
	dw_detail.importfile(is_pathname)
End If

Long	ll_rows
Int i

ll_rows = dw_detail.rowCount()

IF ll_rows = 0 THEN
	RETURN 0
END IF


p_ok.TriggerEvent("ue_enable")

Return 0
end event

event ue_reset();dw_cond.reset()
dw_cond.insertRow(0)
dw_detail.reset()
end event

event ue_delete();Int li_row
li_row = dw_detail.getRow()
dw_detail.deleteRow(li_row)


dw_detail.AcceptText()
If dw_detail.Rowcount() > 0 Then
	p_ok.TriggerEvent("ue_enable")
Else
	p_ok.TriggerEvent("ue_disable")
End If

end event

event ue_insert();Int li_row
li_row = dw_detail.getRow()
dw_detail.insertRow(li_row+1)

dw_detail.AcceptText()
If dw_detail.Rowcount() > 0 Then
	p_ok.TriggerEvent("ue_enable")
Else
	p_ok.TriggerEvent("ue_disable")
End If
end event

public subroutine fi_location_error (integer find_row);//
end subroutine

on b1w_reg_actorder_pre_batch.create
int iCurrent
call super::create
this.p_fileread=create p_fileread
this.p_reset=create p_reset
this.p_insert=create p_insert
this.p_delete=create p_delete
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_fileread
this.Control[iCurrent+2]=this.p_reset
this.Control[iCurrent+3]=this.p_insert
this.Control[iCurrent+4]=this.p_delete
end on

on b1w_reg_actorder_pre_batch.destroy
call super::destroy
destroy(this.p_fileread)
destroy(this.p_reset)
destroy(this.p_insert)
destroy(this.p_delete)
end on

event ue_ok();call super::ue_ok;String ls_activate_yn, ls_svccod, ls_priceplan, ls_remark
String ls_sysdt, ls_activedt, ls_birthdt, ls_validkey_j[]
String ls_partner, ls_reg_partner, ls_sale_partner, ls_maintain_partner
Long ll_rows, ll_long, i, j, li_rc
Int  li_cnt

String ls_uni_check
String ls_tot_loc[]

String ls_validkey, ls_validkey1, ls_validkey2, ls_validkey3, ls_validkey4, ls_password
String ls_enterdt, ls_pricemodel, ls_reg, ls_ref_desc, ls_bil_fromdt


b1u_dbmgr3 lu_dbmgr3

dw_detail.acceptText()

ls_activate_yn      = Trim(dw_cond.object.activate_yn[1])
ls_svccod           = Trim(dw_cond.object.svccod[1])
ls_priceplan        = Trim(dw_cond.object.priceplan[1])
ls_remark           = Trim(dw_cond.object.remark[1])
ls_partner          = Trim(dw_cond.Object.partner[1])
ls_reg_partner      = Trim(dw_cond.Object.reg_partner[1])
ls_sale_partner     = Trim(dw_cond.Object.sale_partner[1])
ls_maintain_partner = Trim(dw_cond.Object.maintain_partner[1])
ls_sysdt            = String(fdt_get_dbserver_now(),'yyyymmdd')


IF IsNull(ls_activate_yn) THEN ls_activate_yn = ""
IF IsNull(ls_svccod) THEN ls_svccod = ""
IF IsNull(ls_priceplan) THEN ls_priceplan = ""
IF IsNull(ls_remark) THEN ls_remark = ""
IF IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""
If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""


ll_rows = dw_detail.rowCount()

IF ll_rows = 0 THEN
	RETURN
END IF


//필수항목 체크
IF ls_svccod = "" THEN
	f_msg_info(200, Title, "신청서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return	
END IF

IF ls_priceplan = "" THEN
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return	
END IF

IF ls_partner = "" THEN
	f_msg_info(200, Title, "수행처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return	
END IF

IF ls_reg_partner = "" THEN
	f_msg_info(200, Title, "유치처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reg_partner")
	Return	
END IF

IF ls_sale_partner = "" THEN
	f_msg_info(200, Title, "매출처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sale_partner")
	Return	
END IF


//인증Key 중복될 경우 체크
ls_uni_check = dw_detail.object.validkey[1]

IF ls_uni_check = "Duplicate" THEN 
	
	For j = 1 To ll_rows
		ls_validkey_j[j] = dw_detail.object.validkey[j]
		CHOOSE CASE j
			CASE 1  // Row가 1행일때 
				IF  ll_rows > 1 THEN	ll_long = dw_detail.Find(" validkey = '" + ls_validkey_j[j] + "'", j + 1, ll_rows)
				If ll_long > 0 Then
					f_msg_usr_err(210, Title,"인증Key가 중복되었습니다.")
					dw_detail.SetFocus()
					dw_detail.ScrollToRow(ll_long)
					dw_detail.SetRow(ll_long)
					dw_detail.SetColumn("validkey")
					Return
				End If
				
			CASE ll_rows // Row가 맨 마지막
				IF  ll_rows > 1 THEN	ll_long = dw_detail.Find(" validkey = '" + ls_validkey_j[j] + "'", 1, j - 1)
				If ll_long > 0 Then
					f_msg_usr_err(210, Title,"인증Key가 중복되었습니다.")
					dw_detail.SetFocus()
					dw_detail.ScrollToRow(ll_long)
					dw_detail.SetRow(ll_long)
					dw_detail.SetColumn("validkey")
					Return
				End If
				
			CASE ELSE	  
				IF ll_rows > 1 THEN
					ll_long = dw_detail.Find(" validkey = '" + ls_validkey_j[j] + "'", 1, j -1)
					If ll_long > 0 Then
						f_msg_usr_err(210, Title,"인증Key가 중복되었습니다.")
						dw_detail.SetFocus()
						dw_detail.ScrollToRow(ll_long)
						dw_detail.SetRow(ll_long)
						dw_detail.SetColumn("validkey")
						Return
					Else
						ll_long = dw_detail.Find(" validkey = '" + ls_validkey_j[j] + "'", j + 1, ll_rows)
						If ll_long > 0 Then
							f_msg_usr_err(210, Title,"인증Key가 중복되었습니다.")
							dw_detail.SetFocus()
							dw_detail.ScrollToRow(ll_long)
							dw_detail.SetRow(ll_long)
							dw_detail.SetColumn("validkey")
							Return
						End If						
					END IF
				END IF
		END CHOOSE		
	Next

END IF											

		ls_reg = fs_get_control('B0','P200',ls_ref_desc) //고객상태:가입
	
	SetPointer(HourGlass!)

//Validation Check - 필수 항목: 인증Key, 
//개통처리 - 과금시작일 필수.
FOR i=1 TO ll_rows
	ls_validkey   = dw_detail.object.validkey[i]
	ls_validkey1  = dw_detail.object.validkey1[i]
	ls_validkey2  = dw_detail.object.validkey2[i]
	ls_validkey3  = dw_detail.object.validkey3[i]
	ls_validkey4  = dw_detail.object.validkey4[i]
	ls_password   = dw_detail.object.passwd[i]
	ls_enterdt    = String(dw_detail.Object.enterdt[i],'yyyymmdd')
	ls_pricemodel = Trim(dw_detail.object.pricemodel[i])
		
	IF IsNull(ls_validkey) THEN ls_validkey = ""
	IF IsNull(ls_password) THEN ls_password = ""
	IF IsNull(ls_enterdt) THEN ls_enterdt = ""
	IF IsNull(ls_pricemodel) THEN ls_pricemodel = ""
	
	
	IF ls_validkey = "" THEN
		f_msg_info(200, Title, "인증Key(IPN)")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("validkey")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_validkey1 = "" THEN
		f_msg_info(200, Title, "인증Key(국가코드)")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("validkey1")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_validkey2 = "" THEN
		f_msg_info(200, Title, "인증Key(지역)")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("validkey2")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_validkey3 = "" THEN
		f_msg_info(200, Title, "인증Key(국번)")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("validkey3")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_validkey4 = "" THEN
		f_msg_info(200, Title, "인증Key(번호)")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("validkey4")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_password = "" THEN
		f_msg_info(200, Title, "Password")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("passwd")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_enterdt = "" THEN
		f_msg_info(200, Title, "개통일")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("enterdt")
		SetPointer(Arrow!)
		Return
	END IF
	
	IF ls_pricemodel = "" THEN
		f_msg_info(200, Title, "가격모델")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("pricemodel")
		SetPointer(Arrow!)
		Return
	END IF
	
		
	IF ls_activate_yn = "Y" THEN
	
		ls_bil_fromdt = String(dw_detail.object.bil_fromdt[i],"YYYYMMDD")
		IF IsNull(ls_bil_fromdt) THEN ls_bil_fromdt = ""
		IF ls_bil_fromdt = "" THEN
			f_msg_info(200, Title, "과금시작일")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("bil_fromdt")
			SetPointer(Arrow!)
			Return	
		END IF
	
		If ls_bil_fromdt < ls_enterdt Then
			f_msg_usr_err(210, Title, "'과금시작일'은 '가입일자(개통일)'보다 크거나 같아야 합니다.")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("enterdt")
			SetPointer(Arrow!)
			Return
		End If

	END IF

NEXT

dw_detail.acceptText()

//가입처리
lu_dbmgr3 = Create b1u_dbmgr3

lu_dbmgr3.is_caller = "b1w_reg_actorder_pre_batch%ok"
lu_dbmgr3.is_title = Title
lu_dbmgr3.idw_data[1] = dw_detail
lu_dbmgr3.is_data[1]  = ls_activate_yn
lu_dbmgr3.is_data[2]  = ls_svccod
lu_dbmgr3.is_data[3]  = ls_priceplan
lu_dbmgr3.is_data[4]  = ls_remark
lu_dbmgr3.is_data[5]  = ls_partner
lu_dbmgr3.is_data[6]  = ls_reg_partner
lu_dbmgr3.is_data[7]  = ls_sale_partner
lu_dbmgr3.is_data[8]  = ls_maintain_partner

lu_dbmgr3.uf_prc_db_04()
li_rc = lu_dbmgr3.ii_rc
		
//Rollback Or Commit
If li_rc < 0 Then
	Destroy lu_dbmgr3
	RollBack;
	f_msg_info(3010,Title,"선불제 일괄 개통처리")
	SetPointer(Arrow!)
	Return
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	COMMIT;
END IF
		
f_msg_info(3000,This.Title,"선불제 일괄 개통처리")

dw_detail.reset()

Destroy lu_dbmgr3
SetPointer(Arrow!)
Return
end event

event open;call super::open;String ls_ref_desc


//서비스타입 : 선불제
fs_get_control('B0','P101', ls_ref_desc)
is_svctype = ls_ref_desc

dw_cond.object.partner[1] = gs_user_group
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.maintain_partner[1] = gs_user_group


p_ok.TriggerEvent("ue_disable")
end event

type dw_cond from w_a_inq_m`dw_cond within b1w_reg_actorder_pre_batch
integer x = 55
integer y = 52
integer width = 2542
integer height = 412
string dataobject = "b1dw_cnd_actorder_pre_batch"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod
Long li_exist
String ls_filter, ls_validkey_yn
Boolean lb_check
DateTime ld_null

SetNull(ld_null)

//신청서비스에 해당하는 가격정책
Choose Case dwo.name
	Case "activate_yn"
		
		If data = 'Y' Then
			This.object.bil_fromdt[row] = Date(fdt_get_dbserver_now())
		Else
			This.Object.bil_fromdt[row] = ld_null
		End If
		
	Case "svccod"
		
		li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " 
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
		//선택할수 있게
		dw_cond.object.priceplan[1] = ""
		dw_cond.object.priceplan.Protect = 0

End Choose	
end event

type p_ok from w_a_inq_m`p_ok within b1w_reg_actorder_pre_batch
integer x = 3346
integer y = 132
end type

type p_close from w_a_inq_m`p_close within b1w_reg_actorder_pre_batch
integer x = 3351
integer y = 248
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_reg_actorder_pre_batch
integer width = 2587
integer height = 488
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_reg_actorder_pre_batch
integer x = 32
integer y = 520
integer width = 3685
integer height = 1184
string dataobject = "b1dw_actorder_pre_batch"
boolean ib_sort_use = false
end type

type p_fileread from u_p_fileread within b1w_reg_actorder_pre_batch
integer x = 2725
integer y = 132
boolean bringtotop = true
end type

type p_reset from u_p_reset within b1w_reg_actorder_pre_batch
integer x = 2729
integer y = 248
boolean bringtotop = true
end type

type p_insert from u_p_insert within b1w_reg_actorder_pre_batch
integer x = 3035
integer y = 132
boolean bringtotop = true
end type

type p_delete from u_p_delete within b1w_reg_actorder_pre_batch
integer x = 3040
integer y = 248
boolean bringtotop = true
end type

