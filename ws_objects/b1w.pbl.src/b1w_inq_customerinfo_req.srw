$PBExportHeader$b1w_inq_customerinfo_req.srw
$PBExportComments$[ssong]고객정보요청파일Write
forward
global type b1w_inq_customerinfo_req from w_a_inq_m_m
end type
type p_filewrite from u_p_filewrite within b1w_inq_customerinfo_req
end type
end forward

global type b1w_inq_customerinfo_req from w_a_inq_m_m
integer width = 2967
integer height = 1932
event ue_filewrite ( )
p_filewrite p_filewrite
end type
global b1w_inq_customerinfo_req b1w_inq_customerinfo_req

type variables
String is_filename[], is_filepath, is_filenm

end variables

event ue_filewrite();// MAC 검증값은 Host 접속이용기관에서만 이용
// PC 접속이용기관에서는 모뎀프로그램에서 생성
String ls_file_name, ls_partner, ls_workno, ls_filename, ls_partner_key
Int li_rc
Long   ll_workno
b1u_dbmgr8 lu_dbmgr 

dw_cond.Accepttext()
This.TriggerEvent("ue_ok")

li_rc = dw_detail.RowCount()
If li_rc = 0 Then Return

//파트너
ls_partner = dw_master.Object.partner[dw_master.Getrow()]
//작업번호
ls_workno  = string(dw_master.Object.workno[dw_master.Getrow()])
//사업자 key 
ls_partner_key = dw_cond.Object.partner_key[1]

SetPointer(HourGlass!)

//출금이체신청처리
lu_dbmgr = Create b1u_dbmgr8
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "validkey%Write"
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1] = is_filepath			    //filepath
lu_dbmgr.is_data[2] = is_filenm  			    //filename
lu_dbmgr.is_data[3] = ls_partner		    		 //partner
lu_dbmgr.is_data[4] = ls_workno		    		 //작업번호
lu_dbmgr.is_data[5] = ls_partner_key   		 //사업자 key 
lu_dbmgr.is_data[6] = string(date(fdt_get_dbserver_now()),'yymmdd') //현재년월일
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc
ls_filename = lu_dbmgr.is_filename
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
     p_filewrite.TriggerEvent("ue_enabled")
	Case Else
		COMMIT;
		MessageBox(Title, "처리가 완료되었습니다. ~r~n" + &
		                  '경로 및 파일명 : '+ls_filename +' ~r~n'+ &
		                  "(총건수 : " + String(li_rc) + "건)")
		p_filewrite.TriggerEvent("ue_disable")
End Choose



return
end event

on b1w_inq_customerinfo_req.create
int iCurrent
call super::create
this.p_filewrite=create p_filewrite
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_filewrite
end on

on b1w_inq_customerinfo_req.destroy
call super::destroy
destroy(this.p_filewrite)
end on

event ue_ok;call super::ue_ok;
String ls_partner, ls_fromdt, ls_todt, ls_partkey
String ls_where
Long   ll_rows

dw_cond.AcceptText()

ls_partkey = Trim(dw_cond.Object.partner_key[1])
ls_partner = Trim(dw_cond.Object.linkpartner[1])
ls_fromdt  = Trim(String(dw_cond.Object.fromdt[1],'yyyymmdd'))
ls_todt    = Trim(String(dw_cond.Object.todt[1],'yyyymmdd'))

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partkey) Then ls_partkey = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

If ls_partner = "" Then
	f_msg_info(200, Title, "사업자")
	dw_cond.SetColumn("linkpartner")
	dw_cond.SetFocus()
	Return
End If

If ls_partkey = "" Then
	f_msg_info(200, Title, "사업자 Key")
	dw_cond.SetColumn("partner_key")
	dw_cond.SetFocus()
	Return
End If

If ls_fromdt = "" Then
	f_msg_info(200, Title, "작업일자 from")
	dw_cond.SetColumn("fromdt")
	dw_cond.SetFocus()
	Return
End If

If ls_todt = "" Then
	f_msg_info(200, Title, "작업일자 to")
	dw_cond.SetColumn("todt")
	dw_cond.SetFocus()
	Return
End If

IF  (ls_fromdt > ls_todt) THEN
	f_msg_info(200, Title, "작업일자from 은 작업일자to 보다 작아야 합니다.")
	dw_cond.SetColumn("fromdt")
	dw_cond.SetFocus()
	RETURN
END IF

//Dynamic SQL
ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "' "
End If

If ls_fromdt <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(CRTDT,'YYYYMMDD') >= '" + ls_fromdt + "' "
End If

If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(CRTDT,'YYYYMMDD') <= '" + ls_todt + "' "
End IF

dw_master.is_where = ls_where
ll_rows = dw_master.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIF ll_rows > 0 Then
	p_filewrite.TriggerEvent("ue_enable")
End If
end event

event open;call super::open;String	ls_ref_desc, ls_temp
String ls_dir
Date ld_sysdt, ld_orderdt
Int	 li_cnt, li_day

ld_sysdt = date(fdt_get_dbserver_now())
//고객정보요청파일이름
ls_temp = fs_get_control("Z1", "A310", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_filename[])	

If is_filename[1] = "" Then
	f_msg_usr_err(9000, Title, "고객정보요청파일 경로 정보가 없습니다.(SYSCTL1T:Z1:A300)")
	Close(This)
ElseIf is_filename[2] = "" Then
	f_msg_usr_err(9000, Title, "고객정보요청 Filename 정보가 없습니다.(SYSCTL1T:Z1:A300)")
	Close(This)
Else
	is_filepath = is_filename[1] 
	is_filenm   = is_filename[2] + String(ld_sysdt, "yymmdd")
End If

If RightA(is_filepath, 1) = "\" Then
	
Else
	is_filepath = is_filepath + "\"
End If
//
////출금이체신청 이용기관명
//
//is_coname = Trim(fs_get_control("B7", "A600", ls_ref_desc))
//If is_coname = "" Then
//	f_msg_usr_err(9000, Title, "이용기관명 정보가 없습니다.(SYSCTL1T:B7:A600)")
//	Close(This)
//Else
//	dw_cond.Object.idtname[1] = is_coname
//End If
//
////파일저장위치
//is_filepath =  fs_get_control("B7", "A400", ls_ref_desc)
//If is_filepath = "" Then
//	f_msg_usr_err(9000, Title, "파일저장 위치에 대한 정보가 없습니다.(SYSCTL1T:B7:A400)")
//	Close(This)
//End If	
//
//dw_cond.Object.browse[1] = is_filepath
//
//If Right(is_filepath, 1) = "\" Then
//	
//Else
//	is_filepath = is_filepath + "\"
//End If
//
////이용기관입금은행(입금은행;입금계좌번호)
//ls_ref_desc = ""
//ls_temp = ""
//ls_temp = fs_get_control("B7", "A110", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , is_bank[])
//
//dw_cond.Object.jubank[1]  = is_bank[1]
//dw_cond.Object.account[1] = is_bank[2]
//
////예금주명
//ls_ref_desc = ""
//is_name = fs_get_control("B7", "A610", ls_ref_desc)
//dw_cond.Object.name[1]  = is_name
//
//
////출금형태
//ls_ref_desc = ""
//is_outtype = fs_get_control("B7", "A200", ls_ref_desc)
//dw_cond.Object.partout[1]  = is_outtype
//
////출금내역
//ls_ref_desc = ""
//is_remark = fs_get_control("B7", "A609", ls_ref_desc)
//dw_cond.Object.remark[1]  = is_remark
//
////출금최소금액
//ls_ref_desc = ""
//is_mintramt = fs_get_control("B7", "A230", ls_ref_desc)
//dw_cond.Object.minmoney[1]  = integer(is_mintramt)
//
////출금이체신청처리상태(미처리;신청;응답확인;입금처리;0;1;2;3)
//ls_ref_desc = ""
//ls_temp = ""
//ls_temp = fs_get_control("B7", "A510", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";", is_bankreqstatus[])
//
////결재방법(BILLINGINFO:PAY_METHOD)
//is_pay_method = fs_get_control("B0", "P130", ls_ref_desc)
//
////입금유형(REQDTL:PAYTYPE)
//ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , is_pay_type[])
//
//
////입금처리가 아닌 파일이 있는지 확인
//li_cnt = 0
//SELECT NVL(count(*),0)
//INTO :li_cnt
//FROM banktextstatus
//WHERE status <> :is_bankreqstatus[4];
//	
//IF li_cnt = 0 THEN
//	p_save.TriggerEvent("ue_enable")
//ELSE
//	p_save.TriggerEvent("ue_disable")
//END IF
//
////file write 활성화 결정
////미처리
//li_cnt = 0
//SELECT count(*)
//INTO :li_cnt
//FROM banktextstatus
//WHERE status = :is_bankreqstatus[1];
//	
//IF (li_cnt = 0) THEN
//	p_filewrite.TriggerEvent("ue_disable")
//ELSE
//	p_filewrite.TriggerEvent("ue_enable")
//END IF
end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_customerinfo_req
integer y = 80
integer width = 1810
integer height = 312
string dataobject = "b1dw_inq_cnd_customerinforeq"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_customerinfo_req
integer x = 2034
integer y = 88
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_customerinfo_req
integer x = 2341
integer y = 88
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_customerinfo_req
integer x = 41
integer y = 40
integer width = 1847
integer height = 364
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_customerinfo_req
integer x = 37
integer y = 428
integer width = 2866
integer height = 588
string dataobject = "b1dw_inq_mst_customerinforeq"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.crtdt_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_customerinfo_req
integer x = 27
integer y = 1048
integer width = 2875
integer height = 764
string dataobject = "b1dw_inq_det_customerinforeq"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_retrieve;call super::ue_retrieve;String ls_workno, ls_where
Long   ll_rows

ls_workno = Trim(String(dw_master.Object.workno[al_select_row]))


//Retrieve
If al_select_row > 0 Then
	ls_where = "to_char(workno) = '"+ ls_workno +"' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_customerinfo_req
integer y = 1020
end type

type p_filewrite from u_p_filewrite within b1w_inq_customerinfo_req
integer x = 2034
integer y = 208
boolean bringtotop = true
end type

