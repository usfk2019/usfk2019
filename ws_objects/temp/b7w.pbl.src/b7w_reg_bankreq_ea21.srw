$PBExportHeader$b7w_reg_bankreq_ea21.srw
$PBExportComments$[parkkh] CMS 출금의뢰신청(EA21)
forward
global type b7w_reg_bankreq_ea21 from w_a_reg_m_sql
end type
type p_2 from u_p_create within b7w_reg_bankreq_ea21
end type
type hpb_1 from hprogressbar within b7w_reg_bankreq_ea21
end type
type p_filewrite from u_p_filewrite within b7w_reg_bankreq_ea21
end type
end forward

global type b7w_reg_bankreq_ea21 from w_a_reg_m_sql
integer width = 3118
integer height = 1984
event ue_filewrite ( )
p_2 p_2
hpb_1 hpb_1
p_filewrite p_filewrite
end type
global b7w_reg_bankreq_ea21 b7w_reg_bankreq_ea21

type variables
String is_filename[], is_filepath, is_coid
String is_bankreqstatus[], is_dir, is_filenm
String is_receiptcod[], is_drawingresult[]
String is_bank[], is_outtype, is_remark, is_mintramt
String is_pay_type[], is_pay_method, is_table
date id_trdt


end variables

event ue_filewrite();// MAC 검증값은 Host 접속이용기관에서만 이용
// PC 접속이용기관에서는 모뎀프로그램에서 생성
String ls_file_name, ls_outdt
Int li_rc
b7u_dbmgr lu_dbmgr 

This.TriggerEvent("ue_ok")

li_rc = dw_detail.RowCount()
If li_rc = 0 Then Return

//CMS 출금의뢰일
ls_outdt = String(dw_cond.Object.outdt[1], "yyyymmdd")

SetPointer(HourGlass!)

//출금이체신청처리
lu_dbmgr = Create b7u_dbmgr
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "Bankreqea21%ue_filewrite"
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_filenm			        //filename
lu_dbmgr.is_data[2] = is_filepath			    //filepath
lu_dbmgr.is_data[3] = ls_outdt		    		//출금의뢰일자
lu_dbmgr.is_data[4] = is_bank[1]			    //입금은행
lu_dbmgr.is_data[5] = is_bank[2]			    //입금계좌번호
lu_dbmgr.is_data[6] = is_coid			        //기관식별코드
lu_dbmgr.is_data[7] = is_bankreqstatus[1]       //출금이체신청 작업상태(미처리)
lu_dbmgr.is_data[8] = is_bankreqstatus[2]       //출금이체신청 작업상태(신청)
lu_dbmgr.is_data[9] = gs_pgm_id[gi_open_win_no]  //pgmid

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

Destroy lu_dbmgr

SetPointer(Arrow!)

Choose Case li_rc
	Case -3
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 처리 할 수 없습니다.")
		 p_filewrite.TriggerEvent("ue_enabled")
	Case -2
		f_msg_usr_err(9000, Title, "Error>> " + is_filepath + "은 이미 처리가 되었습니다.")
		 p_filewrite.TriggerEvent("ue_enabled")
	Case -1
//		f_msg_usr_err(9000, Title, "Error>> Database Error")
	Case Else
		COMMIT;
		MessageBox(Title, "처리가 완료되었습니다. " + &
		                  "(" + ls_file_name + " : " + String(li_rc) + "건)")
		p_filewrite.TriggerEvent("ue_disable")
End Choose

p_save.TriggerEvent("ue_disable")


return
end event

on b7w_reg_bankreq_ea21.create
int iCurrent
call super::create
this.p_2=create p_2
this.hpb_1=create hpb_1
this.p_filewrite=create p_filewrite
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_2
this.Control[iCurrent+2]=this.hpb_1
this.Control[iCurrent+3]=this.p_filewrite
end on

on b7w_reg_bankreq_ea21.destroy
call super::destroy
destroy(this.p_2)
destroy(this.hpb_1)
destroy(this.p_filewrite)
end on

event open;call super::open;String	ls_ref_desc, ls_temp
String ls_dir
Date ld_sysdt, ld_orderdt
Int	 li_cnt

ld_sysdt = date(fdt_get_dbserver_now())

//이체신청파일이름
ls_temp = fs_get_control("B7", "A420", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_filename[])
If is_filename[1] = "" Then
	f_msg_usr_err(9000, Title, "의뢰신청 Filename 정보가 없습니다.(SYSCTL1T:B7:A420)")
	Close(This)
Else
	is_filenm = is_filename[1] + String(ld_sysdt, "mmdd")
	dw_cond.Object.filename[1] = is_filenm
End If

//출금이체신청 이용기관식별코드
ls_ref_desc = ""
is_coid = Trim(fs_get_control("B7", "A100", ls_ref_desc))
If is_coid = "" Then
	f_msg_usr_err(9000, Title, "이용기관코드에 대한 정보가 없습니다.(SYSCTL1T:B7:A100)")
	Close(This)
Else
	dw_cond.Object.idtno[1] = is_coid
End If

//파일저장위치
is_filepath =  fs_get_control("B7", "A400", ls_ref_desc)
If is_filepath = "" Then
	f_msg_usr_err(9000, Title, "파일저장 위치에 대한 정보가 없습니다.(SYSCTL1T:B7:A400)")
	Close(This)
End If	

If RightA(ls_dir, 1) = "\" Then
	dw_cond.Object.browse[1] = is_filepath 
Else
	dw_cond.Object.browse[1] = is_filepath 
End If

//이용기관입금은행(입금은행;입금계좌번호)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A110", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_bank[])

dw_cond.Object.jubank[1]  = is_bank[1]
dw_cond.Object.account[1] = is_bank[2]

//출금형태
ls_ref_desc = ""
is_outtype = fs_get_control("B7", "A200", ls_ref_desc)
dw_cond.Object.partout[1]  = is_outtype

//통장기재내용
ls_ref_desc = ""
is_remark = fs_get_control("B7", "A210", ls_ref_desc)
dw_cond.Object.remark[1]  = is_remark

//출금최소금액
ls_ref_desc = ""
is_mintramt = fs_get_control("B7", "A230", ls_ref_desc)
dw_cond.Object.minmoney[1]  = integer(is_mintramt)

//출금이체신청처리상태(미처리;신청;응답확인;입금처리;0;1;2;3)
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_bankreqstatus[])

//결재방법(BILLINGINFO:PAY_METHOD)
is_pay_method = fs_get_control("B0", "P130", ls_ref_desc)

//입금유형(REQDTL:PAYTYPE)
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_pay_type[])

//save 활성화 결정
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM banktextstatus
WHERE status <> :is_bankreqstatus[4];
	
IF li_cnt = 0 THEN
	p_save.TriggerEvent("ue_enable")
ELSE
	p_save.TriggerEvent("ue_disable")
END IF

//file write 활성화 결정
li_cnt = 0
SELECT count(*)
INTO :li_cnt
FROM banktextstatus
WHERE status = :is_bankreqstatus[1];
	
IF (li_cnt = 0) THEN
	p_filewrite.TriggerEvent("ue_disable")
ELSE
	p_filewrite.TriggerEvent("ue_enable")
END IF
end event

event ue_ok();call super::ue_ok;String ls_chargedt, ls_outdt, ls_trdt, ls_where, ls_temp, ls_ref_desc, ls_bank_code
Long ll_rows
Int li_rc, li_holiday, li_cnt
date ld_outdt
String ls_paycod, ls_tmp, ls_name[]

//선수금 코드
ls_tmp= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_paycod =ls_name[5] 

li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM REQPAY
WHERE prc_yn <> 'Y'
 And  paytype <> :ls_paycod;
	
IF li_cnt <> 0 THEN
	f_msg_usr_err(9000, Title, "미처리입금자료가 있습니다. ~r~n~r~n미처리입금조정자료를 확인하기시바랍니다.")
	dw_cond.SetColumn("chargedt")
	dw_cond.SetFocus()
	Return
END IF

//청구주기	
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
If IsNull(ls_chargedt) Then ls_chargedt = ""
If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "청구주기")
	dw_cond.SetColumn("chargedt")
	dw_cond.SetFocus()
	Return
End If

//청구의뢰일자       
ld_outdt = dw_cond.Object.outdt[1]
ls_outdt = string(dw_cond.Object.outdt[1],'yyyymmdd')
If IsNull(ls_outdt) Then ls_outdt = ""
If ls_outdt = "" Then
	f_msg_usr_err(200, Title, "출금의뢰일자")
	dw_cond.SetColumn("outdt")
	dw_cond.SetFocus()
	Return
End If

//접수일자 조건2- 일요일 혹은 공휴일이면 안된다.
//공휴일조건 체크
SELECT count(*)
INTO :li_holiday
FROM holiday
WHERE to_char(hday,'yyyymmdd') = :ls_outdt;

//일요일 조건 체크
IF(li_holiday > 0 OR DayName(ld_outdt) = "Sunday" OR DayName(ld_outdt) = "Saturday") THEN
	f_msg_usr_err(210, Title, "출금의뢰일자는 일(토)요일,공휴일일 수 없습니다.")
	dw_cond.SetColumn("outdt")
	dw_cond.SetFocus()
	return
END IF

//청구의뢰일자- 오늘날짜 보다 적을 수 없다.
IF(ls_outdt <= String(fdt_get_dbserver_now(),"YYYYMMDD")) THEN
	f_msg_usr_err(200, Title, "출금의뢰일자는 오늘날짜보다 커야 합니다.")
	dw_cond.SetColumn("outdt")
	dw_cond.SetFocus()
	RETURN 
END IF

//청구기준일
ls_trdt = string(dw_cond.Object.trdt[1],'yyyymmdd')
If IsNull(ls_trdt) Then ls_trdt = ""
If ls_trdt = "" Then
	f_msg_usr_err(200, Title, "청구기준일")
	dw_cond.SetColumn("trdt")
	dw_cond.SetFocus()
	Return
End If

//입력한 청구기준일- 현재청구기준일 보다 클 수 없다.
IF (ls_trdt > String(id_trdt,"YYYYMMDD")) THEN
	f_msg_usr_err(210, Title, "청구기준일은 현재청구기준일보다 작아야 합니다.")
	dw_cond.Object.trdt[1] = id_trdt
	dw_cond.SetColumn("trdt")
	dw_cond.SetFocus()
	RETURN 
END IF

//입력한 청구기준일- 현재청구기준일 일자는 같아야 한다.
IF ( RightA(ls_trdt,2) <> String(id_trdt,"DD")) THEN
	f_msg_usr_err(210, Title, "청구기준일 일자")
	dw_cond.Object.trdt[1] = id_trdt
	dw_cond.SetColumn("trdt")
	dw_cond.SetFocus()
	RETURN 
END IF



dw_detail.SetRedraw(false)


ll_rows = dw_detail.Retrieve(ls_trdt,ls_chargedt,is_pay_method,long(is_mintramt))
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	dw_detail.SetRedraw(true)
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "")
	dw_detail.SetRedraw(true)
	Return
End If

dw_detail.SetRedraw(true)

return
end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_outdt, ls_trdt, ls_chargedt
Long ll_rows
Date ld_cmsacpdt
Int li_holiday, li_cnt, li_rc
b7u_dbmgr  lu_dbmgr
 
This.TriggerEvent("ue_ok")

li_rc = dw_detail.RowCount()

If li_rc = 0 Then Return -5

//청구의뢰일자       
ls_outdt = string(dw_cond.Object.outdt[1],'yyyymmdd')
//청구기준일
ls_trdt = string(dw_cond.Object.trdt[1],'yyyymmdd')
//청구주기
ls_chargedt = trim(dw_cond.Object.chargedt[1])

//출금이체신청처리
lu_dbmgr = Create b7u_dbmgr
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "Bankreqea21%ue_save"
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_filenm			        //filename
lu_dbmgr.is_data[2] = ls_outdt   			    //출금일자
lu_dbmgr.is_data[3] = ls_trdt   			    //입력한 청구기준일
lu_dbmgr.is_data[4] = ls_chargedt   			//청구주기
lu_dbmgr.is_data[5] = is_remark		    		//통장기재내용
lu_dbmgr.is_data[6] = is_outtype			    //출금형태
lu_dbmgr.is_data[7] = is_pay_type[3]            //입금유형(자동이체)
lu_dbmgr.is_data[8] = is_bankreqstatus[1]       //출금의뢰신청 작업상태(미처리)
lu_dbmgr.is_data[9] = is_mintramt				//최소출금액
lu_dbmgr.is_data[10] = gs_pgm_id[gi_open_win_no]  //pgmid
lu_dbmgr.is_data[11] = is_pay_method            //결재방법(자동이체)
lu_dbmgr.is_data[12] = is_table 			    //reqinfo, reqinfoh (table명)

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc
If li_rc < 0 Then 
	Destroy lu_dbmgr
	return li_rc
End If

Destroy lu_dbmgr

return 0
end event

event ue_save();Integer li_return

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

SetPointer(HourGlass!)

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		SetPointer(Arrow!)
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
		
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		SetPointer(Arrow!)
		If iu_mdb_app.ii_rc = -1 Then Return
//		f_msg_info(3000, This.Title, "Save")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
		
		This.TriggerEvent("ue_filewrite")		

End Choose

SetPointer(Arrow!)
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_bankreq_ea21
integer y = 60
integer width = 2249
integer height = 552
string dataobject = "b7dw_cnd_reg_banktext_ea21"
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;string ls_mmdd
DATE ld_outdt, ld_reqdt, ld_date
setnull(ld_date)

Choose Case dwo.name
	Case "outdt"
	
		ls_mmdd = string(dw_cond.Object.outdt[1],'mmdd')
		
		is_filenm = is_filename[1] + ls_mmdd
		dw_cond.Object.filename[1] = is_filenm

	Case "chargedt"
	
		SELECT reqdt,
			   add_months(inputclosedt,1)
		 INTO  :id_trdt,
			   :ld_outdt
		FROM reqconf
		WHERE chargedt = :data;
								 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "itemchanged-SELECT reqconf")
			dw_cond.Object.outdt[1] = ld_date	
			dw_cond.Object.trdt[1] = ld_date
			Return 2
		End If	

//		dw_cond.Object.outdt[1] = ld_outdt			
		dw_cond.Object.trdt[1] = id_trdt
		
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_bankreq_ea21
integer x = 2405
integer y = 92
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_bankreq_ea21
integer x = 2711
integer y = 92
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_bankreq_ea21
integer x = 41
integer y = 8
integer width = 2281
integer height = 624
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_bankreq_ea21
integer x = 2405
integer y = 220
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_bankreq_ea21
integer x = 41
integer y = 660
integer width = 2985
integer height = 1152
string dataobject = "b7dw_inq_reg_banktext_ea21"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.reqdtl_payid_t
uf_init(ldwo_sort)

end event

event dw_detail::retrieveend;call super::retrieveend;int li_cnt 

li_cnt = 0
SELECT NVl(count(*),0)
INTO :li_cnt
FROM banktextstatus
WHERE status <> :is_bankreqstatus[4];
	
IF  li_cnt = 0 THEN
	p_save.TriggerEvent("ue_enable")
ELSE
	p_save.TriggerEvent("ue_disable")
END IF

//file write 활성화 결정
li_cnt = 0
SELECT NVL(count(*),0)
INTO :li_cnt
FROM banktextstatus
WHERE status = :is_bankreqstatus[1];
	
IF (li_cnt = 0) THEN
	p_filewrite.TriggerEvent("ue_disable")
ELSE
	p_filewrite.TriggerEvent("ue_enable")
END IF

end event

type p_2 from u_p_create within b7w_reg_bankreq_ea21
boolean visible = false
integer x = 2345
integer y = 80
boolean bringtotop = true
boolean enabled = false
end type

type hpb_1 from hprogressbar within b7w_reg_bankreq_ea21
boolean visible = false
integer x = 1993
integer y = 380
integer width = 800
integer height = 80
boolean bringtotop = true
unsignedinteger maxposition = 100
unsignedinteger position = 100
integer setstep = 1
end type

type p_filewrite from u_p_filewrite within b7w_reg_bankreq_ea21
event type integer ue_filewrite ( )
integer x = 2711
integer y = 220
boolean bringtotop = true
boolean originalsize = false
end type

