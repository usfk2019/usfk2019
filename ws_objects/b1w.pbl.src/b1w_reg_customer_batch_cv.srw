$PBExportHeader$b1w_reg_customer_batch_cv.srw
$PBExportComments$[chooys] 신규고객개통신청Batch
forward
global type b1w_reg_customer_batch_cv from w_a_inq_m
end type
type p_fileread from u_p_fileread within b1w_reg_customer_batch_cv
end type
type p_reset from u_p_reset within b1w_reg_customer_batch_cv
end type
type p_insert from u_p_insert within b1w_reg_customer_batch_cv
end type
type p_delete from u_p_delete within b1w_reg_customer_batch_cv
end type
end forward

global type b1w_reg_customer_batch_cv from w_a_inq_m
integer width = 3570
event type integer ue_fileread ( )
event ue_reset ( )
event ue_delete ( )
event ue_insert ( )
p_fileread p_fileread
p_reset p_reset
p_insert p_insert
p_delete p_delete
end type
global b1w_reg_customer_batch_cv b1w_reg_customer_batch_cv

type variables
String is_pathname
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

end event

event ue_insert();Int li_row
li_row = dw_detail.getRow()
dw_detail.insertRow(li_row+1)
end event

public subroutine fi_location_error (integer find_row);//
end subroutine

on b1w_reg_customer_batch_cv.create
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

on b1w_reg_customer_batch_cv.destroy
call super::destroy
destroy(this.p_fileread)
destroy(this.p_reset)
destroy(this.p_insert)
destroy(this.p_delete)
end on

event ue_ok();call super::ue_ok;String ls_activate_yn
String ls_svccod
String ls_priceplan
String ls_remark
String ls_bil_fromdt
String ls_sysdt
String ls_activedt
String ls_birthdt
Long ll_rows, ll_long
Long i, j
Long li_rc
Int  li_cnt

String ls_uni_check

String ls_tot_loc[]

b1u_dbmgr3 lu_dbmgr3

dw_detail.acceptText()

ls_activate_yn = Trim(dw_cond.object.activate_yn[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_remark = Trim(dw_cond.object.remark[1])
//ls_bil_fromdt = String(dw_cond.object.bil_fromdt[1],"YYYYMMDD")
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')


IF IsNull(ls_activate_yn) THEN ls_activate_yn = ""
IF IsNull(ls_svccod) THEN ls_svccod = ""
IF IsNull(ls_priceplan) THEN ls_priceplan = ""
IF IsNull(ls_remark) THEN ls_remark = ""
//IF IsNull(ls_bil_fromdt) THEN ls_bil_fromdt = ""


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

//아파트, 동, 호수 중복될 경우 체크
ls_uni_check = dw_detail.object.uni_check[1]

IF ls_uni_check = "Duplicate" THEN 
	
	For j = 1 To ll_rows
		ls_tot_loc[j] = dw_detail.object.total_location[j]
		CHOOSE CASE j
			CASE 1  // Row가 1행일때 
				IF  ll_rows > 1 THEN	ll_long = dw_detail.Find(" total_location = '" + ls_tot_loc[j] + "'", j + 1, ll_rows)
				If ll_long > 0 Then
					f_msg_usr_err(210, Title,"아파트, 동, 호수가 중복되었습니다.")
					dw_detail.SetFocus()
					dw_detail.ScrollToRow(ll_long)
					dw_detail.SetRow(ll_long)
					dw_detail.SetColumn("location")
					Return
				End If
			CASE ll_rows // Row가 맨 마지막
				IF  ll_rows > 1 THEN	ll_long = dw_detail.Find(" total_location = '" + ls_tot_loc[j] + "'", 1, j - 1)
				If ll_long > 0 Then
					f_msg_usr_err(210, Title,"아파트, 동, 호수가 중복되었습니다.")
					dw_detail.SetFocus()
					dw_detail.ScrollToRow(ll_long)
					dw_detail.SetRow(ll_long)
					dw_detail.SetColumn("location")
					Return
				End If					
			CASE ELSE	  
				IF ll_rows > 1 THEN
					ll_long = dw_detail.Find(" total_location = '" + ls_tot_loc[j] + "'", 1, j -1)
					If ll_long > 0 Then
						f_msg_usr_err(210, Title,"아파트, 동, 호수가 중복되었습니다.")
						dw_detail.SetFocus()
						dw_detail.ScrollToRow(ll_long)
						dw_detail.SetRow(ll_long)
						dw_detail.SetColumn("location")
						Return
					End If					
					IF ll_long > 0 THEN
					else
						ll_long = dw_detail.Find(" total_location = '" + ls_tot_loc[j] + "'", j + 1, ll_rows)
						If ll_long > 0 Then
							f_msg_usr_err(210, Title,"아파트, 동, 호수가 중복되었습니다.")
							dw_detail.SetFocus()
							dw_detail.ScrollToRow(ll_long)
							dw_detail.SetRow(ll_long)
							dw_detail.SetColumn("location")
							Return
						End If						
					END IF
				END IF
		END CHOOSE		
	Next

END IF											

	String ls_location
	String ls_buildingno
	String ls_roomno
	String ls_reg
	String ls_desc
	String ls_customernm
	String ls_enterdt
	String ls_phone1
	String ls_phone2
	String ls_bil_addr1
	String ls_bil_addr2
	String ls_ssno
	String ls_corpnm
	String ls_corpno
	String ls_representative
	String ls_cregno
	String ls_passportno
	

	ls_reg = fs_get_control('B0','P200',ls_desc) //고객상태:가입
	
	SetPointer(HourGlass!)

//Validation Check - 필수 항목: 아파트ID, 동, 호, 고객명, 주민번호, 가입일자, 전화번호1, 전화번호2, 청구지주소1,청구지주소2
//개통처리 - 과금시작일 필수.
FOR i=1 TO ll_rows
	ls_location = dw_detail.object.location[i]
	//아파트ID Validation Check
	SELECT COUNT(*)
	INTO :li_cnt
	FROM locmst
	WHERE location = :ls_location;
	
	IF li_cnt = 0 THEN
		f_msg_usr_err(210, Title, ls_location+"는 존재하지 않는 아파트ID 입니다.")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("location")
		SetPointer(Arrow!)
		Return
	END IF
	
	
	
	ls_buildingno = Trim(dw_detail.object.buildingno[i])
	IF IsNull(ls_buildingno) THEN ls_buildingno = ""
	IF ls_buildingno = "" THEN
		f_msg_info(200, Title, "동")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("buildingno")
		SetPointer(Arrow!)
		Return
	END IF
	//아파트 동, 호 대문자로 변경
	ls_buildingno = upper(ls_buildingno)
	IF ls_buildingno > "0" AND ls_buildingno < "9999" THEN
			ls_buildingno = fs_fill_zeroes(ls_buildingno,-4)
	END IF
	dw_detail.object.buildingno[i] = ls_buildingno
	
	
	
	ls_roomno = Trim(dw_detail.object.roomno[i])
	IF IsNull(ls_roomno) THEN ls_roomno = ""
	IF ls_roomno = "" THEN
		f_msg_info(200, Title, "호")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("roomno")
		SetPointer(Arrow!)
		Return
	END IF
	ls_roomno = upper(ls_roomno)
	IF ls_roomno > "0" AND ls_roomno < "9999" THEN
		ls_roomno = fs_fill_zeroes(ls_roomno,-4)
	END IF
	dw_detail.object.roomno[i] = ls_roomno
	
	
	//가입고객인 아파트 동.호 중복체크
	//같은 아파트, 같은 동, 같은 호에 "가입"상태인 고객이 있으면 등록 불가
				
		SELECT count(*)
		INTO :li_cnt
		FROM customerm
		WHERE location = :ls_location
		AND buildingno = :ls_buildingno
		AND roomno = :ls_roomno
		AND status = :ls_reg;
		
		If li_cnt <> 0 Then
				f_msg_usr_err(9000, THIS.title, "이미 등록된 아파트 정보입니다.")
				dw_detail.SetFocus()
				dw_detail.ScrollToRow(i)
				dw_detail.SetRow(i)
				dw_detail.SetColumn("roomno")
				SetPointer(Arrow!)
				Return
		End If
	
	
	ls_customernm = dw_detail.object.customernm[i]
	IF IsNull(ls_customernm) THEN ls_customernm = ""
	IF ls_customernm = "" THEN
		f_msg_info(200, Title, "고객명")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("customernm")
		SetPointer(Arrow!)
		Return
	END IF
				
				
	
	ls_enterdt = String(dw_detail.object.enterdt[i],"YYYYMMDD")
	IF IsNull(ls_enterdt) THEN ls_enterdt = ""
	IF ls_enterdt = "" THEN
		f_msg_info(200, Title, "가입일자")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("enterdt")
		SetPointer(Arrow!)
		Return
	END IF
	
//	If ls_enterdt < ls_sysdt Then
//		f_msg_usr_err(9000, Title, "'개통일(가입일자)'은 오늘날짜 보다 크거나 같아야 합니다.")
//		dw_detail.SetRow(i)
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("enterdt")
//		Return
//	End If	
	
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


	ls_ssno = dw_detail.object.ssno[i]
	IF IsNull(ls_ssno) THEN ls_ssno = ""

	ls_corpnm = Trim(dw_detail.object.corpnm[i])
	IF IsNull(ls_corpnm) THEN ls_corpnm = ""

	ls_corpno = Trim(dw_detail.object.corpno[i])
	IF IsNull(ls_corpno) THEN ls_corpno = ""
		
	ls_representative = Trim(dw_detail.object.representative[i])
	IF IsNull(ls_representative) THEN ls_representative = ""
	
	ls_cregno = Trim(dw_detail.object.cregno[i])
	IF IsNull(ls_cregno) THEN ls_cregno = ""
		
	ls_passportno = Trim(dw_detail.object.passportno[i])
	IF IsNull(ls_passportno) THEN ls_passportno = ""	
	
		
	//개인회원
	IF ls_ssno <> "" THEN
		//주민번호 Validation Check
		If fi_check_juminnum(ls_ssno) = -1 Then
			f_msg_usr_err(9000, Title, "올바르지 않은 주민등록번호입니다.")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("ssno")
			SetPointer(Arrow!)
			Return
		End If
		
		IF MidA(ls_ssno,7,1) = "1" OR MidA(ls_ssno,7,1) = "2" THEN
			ls_birthdt = "19"+ MidA(ls_ssno,1,6)
		ELSE
			ls_birthdt = "20"+ MidA(ls_ssno,1,6)
		END IF
				
		IF not IsDate(MidA(ls_birthdt,1,4) +"-"+ MidA(ls_birthdt,5,2) +"-"+ MidA(ls_birthdt,7,2)) THEN
			f_msg_usr_err(9000, Title, "올바르지 않은 주민등록번호입니다.")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("ssno")
			SetPointer(Arrow!)
			Return
		END IF
		
		//주민번호 중복체크
		SELECT COUNT(*)
		INTO :li_cnt
		FROM customerm
		WHERE ssno = :ls_ssno
		AND status = :ls_reg;
		
		IF li_cnt <> 0 THEN
			f_msg_usr_err(9000, Title, "등록된 주민번호로 가입상태인 고객이 있습니다.")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("ssno")
			SetPointer(Arrow!)
			Return
		END IF
		
	//법인회원
	ELSEIF ls_corpnm <> "" OR ls_corpno <> "" OR ls_representative <> "" OR ls_cregno <> "" THEN
	
		IF ls_corpno = "" THEN
			f_msg_info(200, Title, "법인명")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("corpno")
			SetPointer(Arrow!)
			Return
		END IF

	
		IF ls_corpno = "" THEN
			f_msg_info(200, Title, "법인등록번호")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("corpno")
			SetPointer(Arrow!)
			Return
		END IF

		IF ls_representative = "" THEN
			f_msg_info(200, Title, "대표자성명")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("representative")
			SetPointer(Arrow!)
			Return
		END IF
		

		IF ls_cregno = "" THEN
			f_msg_info(200, Title, "사업자등록번호")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("cregno")
			SetPointer(Arrow!)
			Return
		END IF
	
	//외국인
	ELSEIF ls_passportno <>"" THEN
		//여권번호중복체크
		SELECT COUNT(*)
		INTO :li_cnt
		FROM customerm
		WHERE passportno = :ls_passportno;
		
		IF li_cnt <> 0 THEN
			f_msg_usr_err(9000, Title, "이미 등록된 여권번호입니다.")
			dw_detail.SetFocus()
			dw_detail.ScrollToRow(i)
			dw_detail.SetRow(i)
			dw_detail.SetColumn("passportno")
			SetPointer(Arrow!)
			Return
		END IF
		
	//주민번호 미입력.	
	ELSE	
		f_msg_info(200, Title, "주민번호")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("ssno")
		SetPointer(Arrow!)
		Return	
	END IF


	ls_phone1 = dw_detail.object.phone1[i]
	IF IsNull(ls_phone1) THEN ls_phone1 = ""
	IF ls_phone1 = "" THEN
		f_msg_info(200, Title, "전화번호1")
		dw_detail.SetFocus()
		dw_detail.ScrollToRow(i)
		dw_detail.SetRow(i)
		dw_detail.SetColumn("phone1")
		SetPointer(Arrow!)
		Return
	END IF
	
	ls_phone2 = dw_detail.object.phone2[i]
	IF IsNull(ls_phone2) THEN ls_phone2 = ""

//	IF ls_phone2 = "" THEN
//		f_msg_info(200, Title, "전화번호2")
//		dw_detail.SetRow(i)
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("phone2")
//		Return
//	END IF
	
//	ls_bil_addr1 = dw_detail.object.bil_addr1[i]
//	IF IsNull(ls_bil_addr1) THEN ls_bil_addr1 = ""
//	IF ls_bil_addr1 = "" THEN
//		f_msg_info(200, Title, "청구지주소1")
//		dw_detail.SetRow(i)
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("bil_addr1")
//		SetPointer(Arrow!)
//		Return
//	END IF
//	
//	ls_bil_addr2 = dw_detail.object.bil_addr2[i]
//	IF IsNull(ls_bil_addr2) THEN ls_bil_addr2 = ""
//	IF ls_bil_addr2 = "" THEN
//		f_msg_info(200, Title, "청구지주소2")
//		dw_detail.SetRow(i)
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("bil_addr2")
//		SetPointer(Arrow!)
//		Return
//	END IF
NEXT

dw_detail.acceptText()

//가입처리
lu_dbmgr3 = Create b1u_dbmgr3

lu_dbmgr3.is_caller = "b1w_reg_customer_batch_cv%ok"
lu_dbmgr3.is_title = Title
lu_dbmgr3.idw_data[1] = dw_detail
lu_dbmgr3.is_data[1] = ls_activate_yn
lu_dbmgr3.is_data[2] = ls_svccod
lu_dbmgr3.is_data[3] = ls_priceplan
lu_dbmgr3.is_data[4] = ls_remark
lu_dbmgr3.uf_prc_db_01()
li_rc = lu_dbmgr3.ii_rc
		
//Rollback Or Commit
If li_rc < 0 Then
	Destroy lu_dbmgr3
	RollBack;
	f_msg_info(3010,Title,"신규고객개통신청")
	SetPointer(Arrow!)
	Return
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	COMMIT;
END IF
		
f_msg_info(3000,This.Title,"신규고객개통신청")

dw_detail.reset()

Destroy lu_dbmgr3
SetPointer(Arrow!)
Return
end event

event open;call super::open;p_ok.TriggerEvent("ue_disable")
end event

type dw_cond from w_a_inq_m`dw_cond within b1w_reg_customer_batch_cv
integer width = 2441
integer height = 212
string dataobject = "b1dw_cnd_reg_customer_batch_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod
Long li_exist
String ls_filter, ls_validkey_yn
Boolean lb_check

//신청서비스에 해당하는 가격정책
Choose Case dwo.name
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

type p_ok from w_a_inq_m`p_ok within b1w_reg_customer_batch_cv
integer x = 3191
end type

type p_close from w_a_inq_m`p_close within b1w_reg_customer_batch_cv
integer x = 3195
integer y = 180
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_reg_customer_batch_cv
integer width = 2482
integer height = 288
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_reg_customer_batch_cv
integer x = 32
integer width = 3470
string dataobject = "b1dw_mst_reg_customer_batch_cv"
boolean ib_sort_use = false
end type

type p_fileread from u_p_fileread within b1w_reg_customer_batch_cv
integer x = 2569
integer y = 64
boolean bringtotop = true
end type

type p_reset from u_p_reset within b1w_reg_customer_batch_cv
integer x = 2574
integer y = 180
boolean bringtotop = true
end type

type p_insert from u_p_insert within b1w_reg_customer_batch_cv
integer x = 2880
integer y = 64
boolean bringtotop = true
end type

type p_delete from u_p_delete within b1w_reg_customer_batch_cv
integer x = 2885
integer y = 180
boolean bringtotop = true
end type

